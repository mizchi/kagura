///|
/// Generic per-component dense storage indexed by `EntityId.index`. One
/// `ComponentStore[T]` per component type; built-in instances are wired
/// up by callers, and user code can declare its own with
/// `ComponentStore::new()` instead of editing `World`.
///
/// Inspired by selene's `Map[Entity, T]`-per-component pattern, but kept
/// dense (`Array[T?]`) for cache-friendly iteration. Lookups do not
/// consult `World::alive` — a stale handle from a despawned entity reads
/// back the lingering value until something overwrites the slot. Call
/// `iter_in(world)` (or the `*_each` query helpers) to walk only live
/// entities.
pub struct ComponentStore[T] {
  data : Array[T?]
}

///|
pub fn[T] ComponentStore::new() -> ComponentStore[T] {
  { data: [] }
}

///|
fn[T] ComponentStore::grow_to(self : ComponentStore[T], index : Int) -> Unit {
  while self.data.length() <= index {
    self.data.push(None)
  }
}

///|
pub fn[T] ComponentStore::set(
  self : ComponentStore[T],
  eid : EntityId,
  value : T,
) -> Unit {
  if eid.index < 0 {
    return
  }
  self.grow_to(eid.index)
  self.data[eid.index] = Some(value)
}

///|
pub fn[T] ComponentStore::get(
  self : ComponentStore[T],
  eid : EntityId,
) -> T? {
  if eid.index < 0 || eid.index >= self.data.length() {
    return None
  }
  self.data[eid.index]
}

///|
pub fn[T] ComponentStore::has(
  self : ComponentStore[T],
  eid : EntityId,
) -> Bool {
  self.get(eid) is Some(_)
}

///|
pub fn[T] ComponentStore::remove(
  self : ComponentStore[T],
  eid : EntityId,
) -> Unit {
  if eid.index < 0 || eid.index >= self.data.length() {
    return
  }
  self.data[eid.index] = None
}

///|
/// Bounds-check-free write. The caller guarantees `eid.index` is in
/// range (typically because the eid came from an `*_each`/`iter_in`
/// walk of the same store). Skipping the grow + bounds check saves ~30%
/// per set on hot paths.
pub fn[T] ComponentStore::overwrite(
  self : ComponentStore[T],
  eid : EntityId,
  value : T,
) -> Unit {
  self.data.unsafe_set(eid.index, Some(value))
}

///|
/// Free component data for entities the world considers dead. Call after a
/// batch of despawns to reclaim memory without renumbering live ids.
pub fn[T] ComponentStore::cleanup(
  self : ComponentStore[T],
  world : World,
) -> Unit {
  let len = self.data.length()
  let wlen = world.alive.length()
  for i in 0..<len {
    if i >= wlen {
      break
    }
    if !world.alive[i] {
      self.data[i] = None
    }
  }
}

///|
/// Direct callback over every live (eid, value) the store currently holds.
/// Hot-path API for systems: avoids the closure allocation per step that
/// `iter_in().each(...)` pays on the JS backend.
pub fn[T] ComponentStore::each_in(
  self : ComponentStore[T],
  world : World,
  f : (EntityId, T) -> Unit,
) -> Unit {
  let data = self.data
  let alive = world.alive
  let len = data.length()
  let wlen = alive.length()
  let bound = if len < wlen { len } else { wlen }
  for i in 0..<bound {
    // Bound = min(data, alive); both indices are in-range so skip bounds
    // checks on the hot path.
    if !alive.unsafe_get(i) {
      continue
    }
    match data.unsafe_get(i) {
      Some(v) => f({ index: i }, v)
      None => ()
    }
  }
}

///|
/// Lazy iterator over every (eid, value) the store currently holds,
/// regardless of liveness. Use `iter_in` or `each_in` when you want only
/// live entities.
pub fn[T] ComponentStore::iter(
  self : ComponentStore[T],
) -> Iter[(EntityId, T)] {
  let mut i = 0
  let len = self.data.length()
  Iter::new(fn() {
    while i < len {
      let idx = i
      i = i + 1
      match self.data[idx] {
        Some(v) => return Some(({ index: idx }, v))
        None => ()
      }
    }
    None
  })
}

///|
/// Lazy iterator restricted to live entities in `world`.
pub fn[T] ComponentStore::iter_in(
  self : ComponentStore[T],
  world : World,
) -> Iter[(EntityId, T)] {
  let mut i = 0
  let len = self.data.length()
  let wlen = world.alive.length()
  let bound = if len < wlen { len } else { wlen }
  Iter::new(fn() {
    while i < bound {
      let idx = i
      i = i + 1
      if !world.alive[idx] {
        continue
      }
      match self.data[idx] {
        Some(v) => return Some(({ index: idx }, v))
        None => ()
      }
    }
    None
  })
}
