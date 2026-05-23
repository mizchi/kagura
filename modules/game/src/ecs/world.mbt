///|
/// Entity lifecycle store. Tracks only which slots are alive; component
/// data lives in `ComponentStore[T]` instances owned by the caller.
///
/// Slot policy: spawning monotonically appends. `despawn` flips `alive` to
/// false but never recycles the slot or its component data (use
/// `ComponentStore::remove` if you need to reclaim the value early).
/// This keeps held `EntityId`s from silently aliasing a different entity.
pub struct World {
  mut next_index : Int
  alive : Array[Bool]
}

///|
pub fn World::new() -> World {
  { next_index: 0, alive: [] }
}

///|
pub fn World::spawn(self : World) -> EntityId {
  let index = self.next_index
  self.next_index += 1
  self.alive.push(true)
  { index }
}

///|
pub fn World::despawn(self : World, eid : EntityId) -> Unit {
  if eid.index < 0 || eid.index >= self.alive.length() {
    return
  }
  self.alive[eid.index] = false
}

///|
pub fn World::is_alive(self : World, eid : EntityId) -> Bool {
  eid.index >= 0 &&
  eid.index < self.alive.length() &&
  self.alive[eid.index]
}

///|
pub fn World::entity_count(self : World) -> Int {
  let mut count = 0
  for v in self.alive {
    if v {
      count = count + 1
    }
  }
  count
}

///|
/// Slot count ever allocated. Useful for pre-sizing component stores.
pub fn World::capacity(self : World) -> Int {
  self.alive.length()
}

///|
/// Lazy iterator over live entities. Iterating while spawning/despawning
/// is undefined: snapshot first if you need to mutate during the walk.
pub fn World::iter(self : World) -> Iter[EntityId] {
  let mut i = 0
  let len = self.alive.length()
  Iter::new(fn() {
    while i < len {
      let idx = i
      i = i + 1
      if self.alive[idx] {
        return Some({ index: idx })
      }
    }
    None
  })
}
