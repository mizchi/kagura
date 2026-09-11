///|
/// Body id -> body array index, so a lookup by id is not a scan.
///
/// `PhysicsWorld::get_body` walked every body, and the callers that matter call it
/// per frame: `@ecs.system_sync_from_physics` once per entity, so the pair was
/// quadratic in the body count -- 98 ms for 10,000 bodies, 95% of it the scan
/// (`docs/performance/ecs-write-path.md`). The joint precomputes did the same
/// twice per joint per frame.
///
/// Open addressing over a 32-bit hash of the id, the same shape as
/// `ContactCache3D` and the broadphase cell table. Bodies are only ever appended,
/// never removed or reordered, so an entry stays valid for the world's lifetime;
/// `insert` keeps the first id it sees, which is what the scan returned when a
/// caller assigned the same id twice.
struct BodyIndex3D {
  mut slot_id : FixedArray[Int]
  mut slot_index : FixedArray[Int]
  mut mask : Int
  mut count : Int
  /// How many of the world's bodies are in the table. Filled in on demand by
  /// `ensure`, never on `add_body`: hashing every body as it is added made
  /// `build_pile_1024` 2.1x slower (66.5 -> 142.4 us) for a world that may never
  /// look one up by id. Bodies are append-only, so catching up is a suffix scan.
  mut indexed : Int
}

///|
let initial_body_index_capacity3d : Int = 64

///|
pub fn BodyIndex3D::new() -> BodyIndex3D {
  {
    slot_id: FixedArray::make(initial_body_index_capacity3d, 0),
    slot_index: FixedArray::make(initial_body_index_capacity3d, 0),
    mask: initial_body_index_capacity3d - 1,
    count: 0,
    indexed: 0,
  }
}

///|
fn body_id_hash3d(id : Int) -> Int {
  let mut h = id
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
fn BodyIndex3D::grow(self : BodyIndex3D) -> Unit {
  let new_capacity = (self.mask + 1) * 2
  let new_mask = new_capacity - 1
  let slot_id = FixedArray::make(new_capacity, 0)
  let slot_index = FixedArray::make(new_capacity, 0)
  for s = 0; s <= self.mask; s = s + 1 {
    let stored = self.slot_index[s]
    if stored != 0 {
      let id = self.slot_id[s]
      let mut slot = body_id_hash3d(id) & new_mask
      while slot_index[slot] != 0 {
        slot = (slot + 1) & new_mask
      }
      slot_id[slot] = id
      slot_index[slot] = stored
    }
  }
  self.slot_id = slot_id
  self.slot_index = slot_index
  self.mask = new_mask
}

///|
/// Record `index` for `id`, keeping an existing entry if the id is already there.
fn BodyIndex3D::insert(self : BodyIndex3D, id : Int, index : Int) -> Unit {
  let mut slot = body_id_hash3d(id) & self.mask
  for ;; {
    let stored = self.slot_index[slot]
    if stored == 0 {
      self.slot_id[slot] = id
      self.slot_index[slot] = index + 1
      self.count = self.count + 1
      if self.count * 4 > (self.mask + 1) * 3 {
        self.grow()
      }
      return
    }
    if self.slot_id[slot] == id {
      // First one wins, which is what the linear scan did.
      return
    }
    slot = (slot + 1) & self.mask
  }
}

///|
/// Bring the table up to date with `bodies`, which only ever grows.
///
/// Call this before `find`. After the first call in a frame it is one comparison,
/// so the per-frame paths can call it unconditionally.
pub fn BodyIndex3D::ensure(
  self : BodyIndex3D,
  bodies : Array[RigidBody],
) -> Unit {
  while self.indexed < bodies.length() {
    self.insert(bodies[self.indexed].id, self.indexed)
    self.indexed = self.indexed + 1
  }
}

///|
/// The body array index for `id`, or -1. Call `ensure` first.
///
/// A body's id is what this is keyed on, so ids must not change after the body is
/// added -- nothing in the engine rewrites one.
pub fn BodyIndex3D::find(self : BodyIndex3D, id : Int) -> Int {
  let mask = self.mask
  let mut slot = body_id_hash3d(id) & mask
  for ;; {
    let stored = self.slot_index[slot]
    if stored == 0 {
      return -1
    }
    if self.slot_id[slot] == id {
      return stored - 1
    }
    slot = (slot + 1) & mask
  }
}
