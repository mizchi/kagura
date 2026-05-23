///|
/// Generic per-component dense storage indexed by `EntityId.index`. Each
/// slot tracks the generation it was written for, so a stale `EntityId`
/// (from a despawned-then-recycled slot) reads back as `None` without
/// having to scrub on despawn.
///
/// Inspired by selene's `Map[Entity, T]`-per-component pattern, but kept
/// dense for cache-friendly iteration. Use one `ComponentStore[T]` per
/// component type; the engine ships built-in instances for `Transform3D`,
/// `Velocity`, etc. (see callers in `examples/ecs/`), and user code can
/// declare its own with `ComponentStore::new()`.
pub struct ComponentStore[T] {
  data : Array[T?]
  generations : Array[Int]
}

///|
pub fn[T] ComponentStore::new() -> ComponentStore[T] {
  { data: [], generations: [] }
}

///|
fn[T] ComponentStore::grow_to(self : ComponentStore[T], index : Int) -> Unit {
  while self.data.length() <= index {
    self.data.push(None)
    self.generations.push(-1)
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
  self.generations[eid.index] = eid.generation
}

///|
pub fn[T] ComponentStore::get(
  self : ComponentStore[T],
  eid : EntityId,
) -> T? {
  if eid.index < 0 || eid.index >= self.data.length() {
    return None
  }
  if self.generations[eid.index] != eid.generation {
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
  if self.generations[eid.index] != eid.generation {
    return
  }
  self.data[eid.index] = None
  self.generations[eid.index] = -1
}

///|
/// Lazy iterator over every (eid, value) the store currently holds. The
/// yielded `EntityId` carries the generation captured at `set` time, so
/// downstream code can re-verify against `World::is_alive` if it cares
/// about lifecycle (the store doesn't observe `despawn` directly).
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
        Some(v) =>
          return Some(({ index: idx, generation: self.generations[idx] }, v))
        None => ()
      }
    }
    None
  })
}

///|
/// Direct callback equivalent of `iter_in`. Avoids the closure-allocation
/// overhead of `Iter::new` on the JS backend; ~5x faster than
/// `iter_in().each(...)` in micro-benchmarks. Use this from hot system
/// loops; use `iter_in` when you want to chain `.filter`/`.map`/etc.
pub fn[T] ComponentStore::each_in(
  self : ComponentStore[T],
  world : World,
  f : (EntityId, T) -> Unit,
) -> Unit {
  let len = self.data.length()
  let wlen = world.alive.length()
  for i in 0..<len {
    if i >= wlen {
      break
    }
    if !world.alive[i] {
      continue
    }
    let gen = self.generations[i]
    if gen != world.generations[i] {
      continue
    }
    match self.data[i] {
      Some(v) => f({ index: i, generation: gen }, v)
      None => ()
    }
  }
}

///|
/// Iterator restricted to entities still alive in `world`. Skips slots
/// whose store-generation no longer matches the world (i.e. the entity was
/// despawned). Use this when you want "all live entities that have T".
pub fn[T] ComponentStore::iter_in(
  self : ComponentStore[T],
  world : World,
) -> Iter[(EntityId, T)] {
  let mut i = 0
  let len = self.data.length()
  Iter::new(fn() {
    while i < len {
      let idx = i
      i = i + 1
      if idx >= world.alive.length() {
        continue
      }
      if !world.alive[idx] {
        continue
      }
      let gen = self.generations[idx]
      if gen != world.generations[idx] {
        continue
      }
      match self.data[idx] {
        Some(v) => return Some(({ index: idx, generation: gen }, v))
        None => ()
      }
    }
    None
  })
}
