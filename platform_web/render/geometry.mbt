///|
/// Geometry generations and CPU snapshots. GPU allocation stays in the host.
fn geometry_pairs(
  gpu : @core.Any,
) -> @weak.WeakMap[@core.Any, @weak.WeakMap[@core.Any, @core.Any]] {
  let current = gpu._get("_registeredGeometry")
  if !@core.is_nullish(current) {
    return current.cast()
  }
  let pairs : @weak.WeakMap[@core.Any, @weak.WeakMap[@core.Any, @core.Any]] = @weak.WeakMap::new()
  gpu._set("_registeredGeometry", @core.any(pairs))
  pairs
}

///|
extern "js" fn float32_copy(source : @core.Any) -> @core.Any =
  #| (source) => new Float32Array(source)

///|
extern "js" fn uint32_copy(source : @core.Any) -> @core.Any =
  #| (source) => new Uint32Array(source)

///|
extern "js" fn to_uint32(source : @core.Any) -> @core.Any =
  #| (source) => source >>> 0

///|
extern "js" fn unique_symbol() -> @core.Any =
  #| () => Symbol("static geometry")

///|
extern "js" fn type_error(message : String) -> Unit =
  #| (message) => { throw new TypeError(message); }

///|
fn geometry_snapshot(vertices : @core.Any, indices : @core.Any) -> @core.Any {
  @core.from_entries([
    ("vertexData", float32_copy(vertices)),
    ("indices", uint32_copy(indices)),
    ("immutableGeometry", @core.any(true)),
    ("sharedGeometry", @core.any(true)),
  ])
}

///|
/// Re-registering a generation is O(1); advancing revisions owns fresh copies.
pub fn register_geometry(
  gpu : @core.Any,
  id : @core.Any,
  revision : @core.Any,
  vertices : @core.Any,
  indices : @core.Any,
) -> @core.Any {
  if (
      @core.typeof_(id) != "string" &&
      @core.typeof_(id) != "symbol" &&
      !@interop.safe_integer(id)
    ) ||
    !@interop.safe_integer(revision) ||
    @interop.number(revision) < 0 {
    type_error("Invalid geometry identity/revision")
  }
  let registry : @collection.JsMap[@core.Any, @core.Any] = if @core.is_nullish(
      gpu._get("_geometryRegistry"),
    ) {
    let registry : @collection.JsMap[@core.Any, @core.Any] = @collection.JsMap::new()
    gpu._set("_geometryRegistry", @core.any(registry))
    registry
  } else {
    gpu._get("_geometryRegistry").cast()
  }
  let pairs = geometry_pairs(gpu)
  let old = registry.get(id)
  if old is Some(entry) {
    let old_revision = @interop.number(entry._get("revision"))
    if @interop.number(revision) < old_revision {
      @interop.range_error("Stale geometry revision")
    }
    if @interop.number(revision) == old_revision {
      if !@core.equal(entry._get("vertices"), vertices) ||
        !@core.equal(entry._get("sourceIndices"), indices) {
        @core.throw_error("Advance revision when replacing geometry")
      }
      return entry._get("snapshot")
    }
  }
  let by_index = match pairs.get(vertices) {
    Some(map) => map
    None => @weak.WeakMap::new()
  }
  if by_index.get(indices) is Some(owner) && !@core.equal(owner._get("id"), id) {
    @core.throw_error("Geometry arrays already registered with another ID")
  }
  if old is Some(entry) {
    if pairs.get(entry._get("vertices")) is Some(map) {
      map.delete(entry._get("sourceIndices")) |> ignore
    }
  }
  pairs.set(vertices, by_index) |> ignore
  let snapshot = geometry_snapshot(vertices, indices)
  let entry = @core.from_entries([
    ("id", id),
    ("revision", revision),
    ("vertices", vertices),
    ("sourceIndices", indices),
    ("snapshot", snapshot),
  ])
  registry.set(id, entry) |> ignore
  by_index.set(indices, entry) |> ignore
  snapshot
}

///|
pub fn unregister_geometry(gpu : @core.Any, id : @core.Any) -> Unit {
  if @core.is_nullish(gpu._get("_geometryRegistry")) {
    return
  }
  let registry : @collection.JsMap[@core.Any, @core.Any] = gpu
    ._get("_geometryRegistry")
    .cast()
  if registry.get(id) is Some(entry) {
    if geometry_pairs(gpu).get(entry._get("vertices")) is Some(map) {
      map.delete(entry._get("sourceIndices")) |> ignore
    }
    registry.delete(id) |> ignore
  }
}

///|
/// Weak ownership lets replaced terrain/model meshes disappear with their arrays.
pub fn register_static_geometry(
  gpu : @core.Any,
  vertices : @core.Any,
  indices : @core.Any,
) -> @core.Any {
  let pairs = geometry_pairs(gpu)
  let by_index = match pairs.get(vertices) {
    Some(map) => map
    None => @weak.WeakMap::new()
  }
  if by_index.get(indices) is Some(registered) {
    return registered._get("snapshot")
  }
  pairs.set(vertices, by_index) |> ignore
  let snapshot = geometry_snapshot(vertices, indices)
  by_index.set(
    indices,
    @core.from_entries([("id", unique_symbol()), ("snapshot", snapshot)]),
  )
  |> ignore
  snapshot
}

///|
/// Separate monomorphic loops; a converter callback in the inner loop is costly.
fn snapshot_vertices(
  cache : @weak.WeakMap[@core.Any, @core.Any],
  source : @core.Any,
) -> @core.Any {
  if cache.get(source) is Some(previous) &&
    @interop.length(previous) == @interop.length(source) {
    let mut i = 0
    while i < @interop.length(source) {
      if !@object.Object::is_(
          previous._get_by_index(i),
          @core.any(
            @jsmath.Math::fround(@interop.number(source._get_by_index(i))),
          ),
        ) {
        break
      }
      i = i + 1
    }
    if i == @interop.length(source) {
      return previous
    }
  }
  let packed = float32_copy(source)
  cache.set(source, packed) |> ignore
  packed
}

///|
fn snapshot_indices(
  cache : @weak.WeakMap[@core.Any, @core.Any],
  source : @core.Any,
) -> @core.Any {
  if cache.get(source) is Some(previous) &&
    @interop.length(previous) == @interop.length(source) {
    let mut i = 0
    while i < @interop.length(source) {
      if !@core.equal(
          previous._get_by_index(i),
          to_uint32(source._get_by_index(i)),
        ) {
        break
      }
      i = i + 1
    }
    if i == @interop.length(source) {
      return previous
    }
  }
  let packed = uint32_copy(source)
  cache.set(source, packed) |> ignore
  packed
}

///|
/// Snapshot mutable inputs before a draw is queued; previous draws keep contents.
pub fn snapshot_draw_geometry(
  gpu : @core.Any,
  vertices : @core.Any,
  indices : @core.Any,
) -> @core.Any {
  let registered = gpu._get("_registeredGeometry")
  if !@core.is_nullish(registered) {
    let pairs : @weak.WeakMap[@core.Any, @weak.WeakMap[@core.Any, @core.Any]] = registered.cast()
    if pairs.get(vertices) is Some(map) && map.get(indices) is Some(entry) {
      return entry._get("snapshot")
    }
  }
  let mut cache = gpu._get("_geometrySnapshots")
  if @core.is_nullish(cache) {
    let vertices : @weak.WeakMap[@core.Any, @core.Any] = @weak.WeakMap::new()
    let indices : @weak.WeakMap[@core.Any, @core.Any] = @weak.WeakMap::new()
    cache = @core.from_entries([
      ("vertices", @core.any(vertices)),
      ("indices", @core.any(indices)),
    ])
    gpu._set("_geometrySnapshots", cache)
  }
  @core.from_entries([
    ("vertexData", snapshot_vertices(cache._get("vertices").cast(), vertices)),
    ("indices", snapshot_indices(cache._get("indices").cast(), indices)),
    ("immutableGeometry", @core.any(true)),
  ])
}
