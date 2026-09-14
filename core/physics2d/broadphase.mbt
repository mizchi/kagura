///|
struct BroadphaseEntry2D {
  id : Int
  aabb : AABB2D
}

///|
/// Uniform-grid broadphase.
///
/// The 2D mirror of `collision3d/broadphase.mbt`; see that file for why the cells
/// are not a `Map`. Short version: this was `Map[Int64, Array[Int]]`, and MoonBit
/// compiles `Int64` to `BigInt` on the JS target, so building one cell key
/// allocated six heap values and hashing it eight more.
///
/// 2D carried a second `Int64` map that 3D does not: `get_pairs` deduplicated by
/// inserting into a `Map[Int64, Unit]` for **every candidate pair in every cell**,
/// not once per cell, so a 256-body pile paid that cost thousands of times a
/// frame. Both are now open-addressed tables over 32-bit `Int` hashes with the
/// keys stored and compared on probe, so nothing aliases however the hash
/// collides.
///
/// Cells stay in first-touch order, which is the order `Map::each` walked, and
/// the pair table keeps the same first-wins semantics -- including marking a pair
/// seen even when its AABB test then fails. Pair order and pair membership both
/// reach the solver, and `physics2d_demo` is in the gating frame VRT set, so a
/// reordering here would show up as changed rendered bytes.
pub struct SpatialHashGrid2D {
  cell_size : Double
  inv_cell_size : Double
  entries : Array[BroadphaseEntry2D]
  cell_cx : Array[Int]
  cell_cy : Array[Int]
  cell_items : Array[Array[Int]]
  mut cell_count : Int
  mut slots : FixedArray[Int]
  mut slot_mask : Int
  /// Pair-dedupe table for `get_pairs`, pooled across calls.
  pair_lo : Array[Int]
  pair_hi : Array[Int]
  mut pair_count : Int
  mut pair_slots : FixedArray[Int]
  mut pair_slot_mask : Int
  /// `get_pairs_into`'s output columns, pooled across calls. Distinct from the
  /// dedupe table above, which also holds pairs whose AABB test then failed.
  pair_id_a : Array[Int]
  pair_id_b : Array[Int]
}

///|
let initial_slot_capacity2d : Int = 64

///|
pub fn SpatialHashGrid2D::new(cell_size : Double) -> SpatialHashGrid2D {
  {
    cell_size,
    inv_cell_size: 1.0 / cell_size,
    entries: [],
    cell_cx: [],
    cell_cy: [],
    cell_items: [],
    cell_count: 0,
    slots: FixedArray::make(initial_slot_capacity2d, 0),
    slot_mask: initial_slot_capacity2d - 1,
    pair_lo: [],
    pair_hi: [],
    pair_count: 0,
    pair_slots: FixedArray::make(initial_slot_capacity2d, 0),
    pair_slot_mask: initial_slot_capacity2d - 1,
    pair_id_a: [],
    pair_id_b: [],
  }
}

///|
pub fn SpatialHashGrid2D::clear(self : SpatialHashGrid2D) -> Unit {
  self.entries.clear()
  for i = 0; i < self.cell_count; i = i + 1 {
    self.cell_items[i].clear()
  }
  self.slots.fill(0)
  self.cell_count = 0
}

///|
pub fn SpatialHashGrid2D::count(self : SpatialHashGrid2D) -> Int {
  self.entries.length()
}

///|
fn floor_to_int(x : Double) -> Int {
  let i = x.to_int()
  if x < i.to_double() {
    i - 1
  } else {
    i
  }
}

///|
/// Two-prime spatial hash, avalanched. Without the final mix, neighbouring cells
/// land in neighbouring slots and a grid walk probes long runs.
fn cell_hash2d(cx : Int, cy : Int) -> Int {
  let mut h = (cx * 73856093) ^ (cy * 19349663)
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
fn SpatialHashGrid2D::grow_slots(self : SpatialHashGrid2D) -> Unit {
  let new_capacity = (self.slot_mask + 1) * 2
  let new_mask = new_capacity - 1
  let slots = FixedArray::make(new_capacity, 0)
  for ci = 0; ci < self.cell_count; ci = ci + 1 {
    let mut slot = cell_hash2d(self.cell_cx[ci], self.cell_cy[ci]) & new_mask
    while slots[slot] != 0 {
      slot = (slot + 1) & new_mask
    }
    slots[slot] = ci + 1
  }
  self.slots = slots
  self.slot_mask = new_mask
}

///|
/// Index of an existing cell, or -1. Probing stops at the first empty slot, which
/// is sound because cells are never removed individually -- `clear()` wipes the
/// whole table.
fn SpatialHashGrid2D::find_cell(
  self : SpatialHashGrid2D,
  cx : Int,
  cy : Int,
) -> Int {
  let mask = self.slot_mask
  let mut slot = cell_hash2d(cx, cy) & mask
  for ;; {
    let stored = self.slots[slot]
    if stored == 0 {
      return -1
    }
    let ci = stored - 1
    if self.cell_cx[ci] == cx && self.cell_cy[ci] == cy {
      return ci
    }
    slot = (slot + 1) & mask
  }
}

///|
fn SpatialHashGrid2D::find_or_create_cell(
  self : SpatialHashGrid2D,
  cx : Int,
  cy : Int,
) -> Int {
  let mask = self.slot_mask
  let mut slot = cell_hash2d(cx, cy) & mask
  for ;; {
    let stored = self.slots[slot]
    if stored == 0 {
      let ci = self.cell_count
      if ci < self.cell_cx.length() {
        self.cell_cx[ci] = cx
        self.cell_cy[ci] = cy
      } else {
        self.cell_cx.push(cx)
        self.cell_cy.push(cy)
        self.cell_items.push([])
      }
      self.slots[slot] = ci + 1
      self.cell_count = ci + 1
      if self.cell_count * 4 > (mask + 1) * 3 {
        self.grow_slots()
      }
      return ci
    }
    let ci = stored - 1
    if self.cell_cx[ci] == cx && self.cell_cy[ci] == cy {
      return ci
    }
    slot = (slot + 1) & mask
  }
}

///|
/// Items in a cell, or `None` when nothing has been inserted there.
fn SpatialHashGrid2D::cell_at(
  self : SpatialHashGrid2D,
  cx : Int,
  cy : Int,
) -> Array[Int]? {
  let ci = self.find_cell(cx, cy)
  if ci < 0 {
    None
  } else {
    Some(self.cell_items[ci])
  }
}

///|
pub fn SpatialHashGrid2D::insert(
  self : SpatialHashGrid2D,
  id : Int,
  aabb : AABB2D,
) -> Unit {
  let idx = self.entries.length()
  self.entries.push({ id, aabb, })
  let min_cx = floor_to_int(aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(aabb.min.y * self.inv_cell_size)
  let max_cx = floor_to_int(aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(aabb.max.y * self.inv_cell_size)
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      self.cell_items[self.find_or_create_cell(cx, cy)].push(idx)
    }
  }
}

///|
/// Drop every recorded pair, keeping the arrays.
fn SpatialHashGrid2D::reset_pairs(self : SpatialHashGrid2D) -> Unit {
  self.pair_slots.fill(0)
  self.pair_count = 0
}

///|
fn pair_hash2d(lo : Int, hi : Int) -> Int {
  let mut h = (lo * 73856093) ^ (hi * 19349663)
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
fn SpatialHashGrid2D::grow_pair_slots(self : SpatialHashGrid2D) -> Unit {
  let new_capacity = (self.pair_slot_mask + 1) * 2
  let new_mask = new_capacity - 1
  let slots = FixedArray::make(new_capacity, 0)
  for row = 0; row < self.pair_count; row = row + 1 {
    let mut slot = pair_hash2d(self.pair_lo[row], self.pair_hi[row]) & new_mask
    while slots[slot] != 0 {
      slot = (slot + 1) & new_mask
    }
    slots[slot] = row + 1
  }
  self.pair_slots = slots
  self.pair_slot_mask = new_mask
}

///|
/// Record a pair, returning true when it was not already there.
///
/// The caller marks a pair seen *before* testing its AABBs, so a pair rejected in
/// one cell is not retried from another. That is the previous `Map[Int64, Unit]`
/// behaviour and it is preserved deliberately.
fn SpatialHashGrid2D::mark_pair(
  self : SpatialHashGrid2D,
  lo : Int,
  hi : Int,
) -> Bool {
  let mask = self.pair_slot_mask
  let mut slot = pair_hash2d(lo, hi) & mask
  for ;; {
    let stored = self.pair_slots[slot]
    if stored == 0 {
      let row = self.pair_count
      if row < self.pair_lo.length() {
        self.pair_lo[row] = lo
        self.pair_hi[row] = hi
      } else {
        self.pair_lo.push(lo)
        self.pair_hi.push(hi)
      }
      self.pair_slots[slot] = row + 1
      self.pair_count = row + 1
      if self.pair_count * 4 > (mask + 1) * 3 {
        self.grow_pair_slots()
      }
      return true
    }
    let row = stored - 1
    if self.pair_lo[row] == lo && self.pair_hi[row] == hi {
      return false
    }
    slot = (slot + 1) & mask
  }
}
