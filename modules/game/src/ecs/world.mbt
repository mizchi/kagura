///|
/// Entity lifecycle store. Tracks which slots are alive and per-slot
/// generations, but holds no component data — components live in
/// `ComponentStore[T]` instances owned by the caller. This mirrors selene's
/// split between entity lifecycle (`selene-core/entity`) and per-component
/// storage.
///
/// Slot policy: spawning prefers a recycled slot from `free_list`; when
/// `despawn` is called the slot is parked on the free list with its
/// generation bumped, so a stale `EntityId` will no longer match. Component
/// stores see the mismatched generation on lookup and treat the slot as
/// empty, so dead-entity reads return `None` without an O(N) compact pass.
pub struct World {
  mut next_index : Int
  alive : Array[Bool]
  generations : Array[Int]
  free_list : Array[Int]
}

///|
pub fn World::new() -> World {
  { next_index: 0, alive: [], generations: [], free_list: [] }
}

///|
pub fn World::spawn(self : World) -> EntityId {
  if self.free_list.length() > 0 {
    let index = self.free_list.pop().unwrap()
    let generation = self.generations[index]
    self.alive[index] = true
    { index, generation }
  } else {
    let index = self.next_index
    self.next_index += 1
    self.alive.push(true)
    self.generations.push(0)
    { index, generation: 0 }
  }
}

///|
pub fn World::despawn(self : World, eid : EntityId) -> Unit {
  if eid.index < 0 || eid.index >= self.alive.length() {
    return
  }
  if self.generations[eid.index] != eid.generation {
    return
  }
  if !self.alive[eid.index] {
    return
  }
  self.alive[eid.index] = false
  // Bump generation so any held EntityId stops matching this slot.
  self.generations[eid.index] = self.generations[eid.index] + 1
  self.free_list.push(eid.index)
}

///|
pub fn World::is_alive(self : World, eid : EntityId) -> Bool {
  eid.index >= 0 &&
  eid.index < self.alive.length() &&
  self.alive[eid.index] &&
  self.generations[eid.index] == eid.generation
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
/// Maximum slot count ever allocated. Component stores can pre-size to this.
pub fn World::capacity(self : World) -> Int {
  self.alive.length()
}

///|
/// Generation currently associated with `index`. Returns -1 for out-of-range.
pub fn World::generation_at(self : World, index : Int) -> Int {
  if index < 0 || index >= self.generations.length() {
    -1
  } else {
    self.generations[index]
  }
}

///|
/// Lazy iterator over live entities. Iterating while spawning/despawning is
/// undefined: snapshot first if you need to mutate during the walk.
pub fn World::iter(self : World) -> Iter[EntityId] {
  let mut i = 0
  let len = self.alive.length()
  Iter::new(fn() {
    while i < len {
      let idx = i
      i = i + 1
      if self.alive[idx] {
        return Some({ index: idx, generation: self.generations[idx] })
      }
    }
    None
  })
}
