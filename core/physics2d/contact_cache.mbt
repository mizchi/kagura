///|
/// Warm-start impulse cache, keyed on an unordered pair of body ids.
///
/// ## Why this is not a `Map`
///
/// It was `Map[Int64, ContactManifold2D]`, keyed on the two body ids packed into
/// an `Int64`. MoonBit compiles `Int64` to `BigInt` on the JS target, so building
/// one key allocated six heap values and hashing it eight more — and the cache is
/// touched twice per contact per frame, once to read the previous frame's
/// impulses in `phase_contact_constraints` and once to write this frame's in
/// `phase_save_contact_cache`.
///
/// 2D also built a **second** `Map` every frame and then copied it into the first,
/// so each contact paid two key constructions, two hashes and two inserts.
///
/// It also stored more than anything read. The manifold carried `local_a`,
/// `local_b` and `penetration`, written for every contact every frame and read by
/// nothing; the two `Vec2::sub` calls that produced the first two were pure
/// waste. Warm starting reads the cached normal and the two accumulated
/// impulses, so those are the columns that exist here.
///
/// Open addressing over a 32-bit hash of the id pair, with both ids stored and
/// compared on probe, so distinct pairs never alias however the hash collides.
/// Rows are pooled across `clear()` — it runs every frame — so a steady contact
/// count settles into zero allocation.
pub struct ContactCache2D {
  mut count : Int
  mut slots : FixedArray[Int]
  mut slot_mask : Int
  id_a : Array[Int]
  id_b : Array[Int]
  normal_x : Array[Double]
  normal_y : Array[Double]
  normal_impulse : Array[Double]
  tangent_impulse : Array[Double]
}

///|
let contact_cache_initial_slots2d : Int = 64

///|
pub fn ContactCache2D::new() -> ContactCache2D {
  {
    count: 0,
    slots: FixedArray::make(contact_cache_initial_slots2d, 0),
    slot_mask: contact_cache_initial_slots2d - 1,
    id_a: [],
    id_b: [],
    normal_x: [],
    normal_y: [],
    normal_impulse: [],
    tangent_impulse: [],
  }
}

///|
/// Number of cached pairs.
pub fn ContactCache2D::length(self : ContactCache2D) -> Int {
  self.count
}

///|
pub fn ContactCache2D::clear(self : ContactCache2D) -> Unit {
  self.slots.fill(0)
  self.count = 0
}

///|
fn contact_cache_hash2d(id_a : Int, id_b : Int) -> Int {
  let lo = if id_a < id_b { id_a } else { id_b }
  let hi = if id_a < id_b { id_b } else { id_a }
  let mut h = (lo * 73856093) ^ (hi * 19349663)
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
/// Row index for a pair, or -1. Order of the two ids does not matter.
pub fn ContactCache2D::find(
  self : ContactCache2D,
  id_a : Int,
  id_b : Int,
) -> Int {
  let mask = self.slot_mask
  let mut slot = contact_cache_hash2d(id_a, id_b) & mask
  for ;; {
    let stored = self.slots[slot]
    if stored == 0 {
      return -1
    }
    let row = stored - 1
    let ra = self.id_a[row]
    let rb = self.id_b[row]
    if (ra == id_a && rb == id_b) || (ra == id_b && rb == id_a) {
      return row
    }
    slot = (slot + 1) & mask
  }
}

///|
/// Whether a pair is cached. Convenience for tests; the hot path uses `find`.
pub fn ContactCache2D::contains(
  self : ContactCache2D,
  id_a : Int,
  id_b : Int,
) -> Bool {
  self.find(id_a, id_b) >= 0
}

///|
fn ContactCache2D::grow_slots(self : ContactCache2D) -> Unit {
  let new_capacity = (self.slot_mask + 1) * 2
  let new_mask = new_capacity - 1
  let slots = FixedArray::make(new_capacity, 0)
  for row = 0; row < self.count; row = row + 1 {
    let mut slot = contact_cache_hash2d(self.id_a[row], self.id_b[row]) &
      new_mask
    while slots[slot] != 0 {
      slot = (slot + 1) & new_mask
    }
    slots[slot] = row + 1
  }
  self.slots = slots
  self.slot_mask = new_mask
}

///|
/// Store the impulses for a pair, replacing any row already there.
pub fn ContactCache2D::store(
  self : ContactCache2D,
  id_a : Int,
  id_b : Int,
  normal : @vector.Vec2,
  normal_impulse : Double,
  tangent_impulse : Double,
) -> Unit {
  let mask = self.slot_mask
  let mut slot = contact_cache_hash2d(id_a, id_b) & mask
  for ;; {
    let stored = self.slots[slot]
    if stored == 0 {
      let row = self.count
      if row < self.id_a.length() {
        self.id_a[row] = id_a
        self.id_b[row] = id_b
        self.normal_x[row] = normal.x
        self.normal_y[row] = normal.y
        self.normal_impulse[row] = normal_impulse
        self.tangent_impulse[row] = tangent_impulse
      } else {
        self.id_a.push(id_a)
        self.id_b.push(id_b)
        self.normal_x.push(normal.x)
        self.normal_y.push(normal.y)
        self.normal_impulse.push(normal_impulse)
        self.tangent_impulse.push(tangent_impulse)
      }
      self.slots[slot] = row + 1
      self.count = row + 1
      if self.count * 4 > (mask + 1) * 3 {
        self.grow_slots()
      }
      return
    }
    let row = stored - 1
    let ra = self.id_a[row]
    let rb = self.id_b[row]
    if (ra == id_a && rb == id_b) || (ra == id_b && rb == id_a) {
      self.normal_x[row] = normal.x
      self.normal_y[row] = normal.y
      self.normal_impulse[row] = normal_impulse
      self.tangent_impulse[row] = tangent_impulse
      return
    }
    slot = (slot + 1) & mask
  }
}
