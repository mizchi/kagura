///|
struct BroadphaseEntry {
  id : Int
  aabb : AABB
  min_cx : Int
  min_cy : Int
  min_cz : Int
}

///|
/// Uniform-grid broadphase.
///
/// ## Why the cells are not a `Map`
///
/// This used to be `cells : Map[Int64, Array[Int]]`, keyed on the three cell
/// coordinates packed into an `Int64`. That is the textbook spatial hash, and on
/// a target with native 64-bit integers it is the right shape. On the JS target
/// it is not: MoonBit compiles `Int64` to `BigInt`, so a key is a heap value and
/// every operation on it allocates. Measured in the generated JS, one cell touch
/// cost six `BigInt` allocations to build the key (`cell_key`), eight more to
/// hash it (`Int64::hash` splits it into two 32-bit halves through
/// `BigInt.asUintN`), and a `BigInt` compare per probe. A body's AABB touches up
/// to eight cells, so a 256-body pile paid tens of thousands of `BigInt`
/// allocations per frame before a single overlap test ran.
///
/// So the table is open-addressed over 32-bit `Int` hashes instead, and the cells
/// live in parallel arrays.
///
/// Two properties are deliberate:
///
/// - **Cells stay in first-touch order.** `MoonBit`'s `Map` keeps a linked list in
///   insertion order and `get_pairs` walked it with `each`, so pairs came out in
///   first-touch cell order. The solver consumes pairs in the order it gets them
///   and its result depends on that order, so `cell_count`-indexed iteration
///   reproduces the old pair sequence exactly rather than merely equivalently.
/// - **Collisions compare coordinates, they do not pack them.** Squeezing three
///   coordinates into one `Int` would have meant ~10 bits per axis; storing them
///   and comparing on probe keeps the +-1M cell range the `Int64` key had.
///
/// The cell arrays and their item buckets are pooled across `clear()`, because
/// `clear()` runs every frame: `cell_count` says how many of them are live, so
/// the buckets above it keep their capacity instead of being reallocated.
pub struct SpatialHashGrid {
  cell_size : Double
  inv_cell_size : Double
  entries : Array[BroadphaseEntry]
  cell_cx : Array[Int]
  cell_cy : Array[Int]
  cell_cz : Array[Int]
  cell_items : Array[Array[Int]]
  mut cell_count : Int
  mut slots : FixedArray[Int]
  mut slot_mask : Int
  /// Per-cell overlap masks, reused by `get_pairs` across cells and frames. It
  /// used to allocate one array per occupied cell per frame.
  mut mask_scratch : FixedArray[Int]
}

///|
/// Initial slot count. Grows by doubling; a power of two so the slot index is a
/// mask rather than a modulo.
let initial_slot_capacity : Int = 64

///|
pub fn SpatialHashGrid::new(cell_size : Double) -> SpatialHashGrid {
  {
    cell_size,
    inv_cell_size: 1.0 / cell_size,
    entries: [],
    cell_cx: [],
    cell_cy: [],
    cell_cz: [],
    cell_items: [],
    cell_count: 0,
    slots: FixedArray::make(initial_slot_capacity, 0),
    slot_mask: initial_slot_capacity - 1,
    mask_scratch: FixedArray::make(16, 0),
  }
}

///|
pub fn SpatialHashGrid::clear(self : SpatialHashGrid) -> Unit {
  self.entries.clear()
  for i = 0; i < self.cell_count; i = i + 1 {
    self.cell_items[i].clear()
  }
  // Wiping every slot is O(capacity) where recomputing each live cell's slot
  // would be O(cells), but capacity is at most 2x cells here and a fill writes
  // constants where the other way would re-hash.
  self.slots.fill(0)
  self.cell_count = 0
}

///|
pub fn SpatialHashGrid::count(self : SpatialHashGrid) -> Int {
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
/// The classic three-prime spatial hash, avalanched.
///
/// The raw xor of the three products maps neighbouring cells to neighbouring
/// slots, and a broadphase walks neighbouring cells, so without the final mix
/// the probe sequences of adjacent lookups overlap and pile up.
fn cell_hash(cx : Int, cy : Int, cz : Int) -> Int {
  let mut h = (cx * 73856093) ^ (cy * 19349663) ^ (cz * 83492791)
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
/// Rebuild the slot table at double capacity, re-probing every live cell.
fn SpatialHashGrid::grow_slots(self : SpatialHashGrid) -> Unit {
  let new_capacity = (self.slot_mask + 1) * 2
  let new_mask = new_capacity - 1
  let slots = FixedArray::make(new_capacity, 0)
  for ci = 0; ci < self.cell_count; ci = ci + 1 {
    let mut slot = cell_hash(
        self.cell_cx[ci],
        self.cell_cy[ci],
        self.cell_cz[ci],
      ) &
      new_mask
    while slots[slot] != 0 {
      slot = (slot + 1) & new_mask
    }
    slots[slot] = ci + 1
  }
  self.slots = slots
  self.slot_mask = new_mask
}

///|
/// Slot index of an existing cell, or -1. Linear probing stops at the first
/// empty slot, which is sound because cells are never removed individually --
/// `clear()` wipes the whole table.
fn SpatialHashGrid::find_cell(
  self : SpatialHashGrid,
  cx : Int,
  cy : Int,
  cz : Int,
) -> Int {
  let mask = self.slot_mask
  let mut slot = cell_hash(cx, cy, cz) & mask
  for ;; {
    let stored = self.slots[slot]
    if stored == 0 {
      return -1
    }
    let ci = stored - 1
    if self.cell_cx[ci] == cx &&
      self.cell_cy[ci] == cy &&
      self.cell_cz[ci] == cz {
      return ci
    }
    slot = (slot + 1) & mask
  }
}

///|
fn SpatialHashGrid::find_or_create_cell(
  self : SpatialHashGrid,
  cx : Int,
  cy : Int,
  cz : Int,
) -> Int {
  let mask = self.slot_mask
  let mut slot = cell_hash(cx, cy, cz) & mask
  for ;; {
    let stored = self.slots[slot]
    if stored == 0 {
      let ci = self.cell_count
      if ci < self.cell_cx.length() {
        self.cell_cx[ci] = cx
        self.cell_cy[ci] = cy
        self.cell_cz[ci] = cz
      } else {
        self.cell_cx.push(cx)
        self.cell_cy.push(cy)
        self.cell_cz.push(cz)
        self.cell_items.push([])
      }
      self.slots[slot] = ci + 1
      self.cell_count = ci + 1
      // Keep the load factor under 3/4; past that linear probing degrades.
      if self.cell_count * 4 > (mask + 1) * 3 {
        self.grow_slots()
      }
      return ci
    }
    let ci = stored - 1
    if self.cell_cx[ci] == cx &&
      self.cell_cy[ci] == cy &&
      self.cell_cz[ci] == cz {
      return ci
    }
    slot = (slot + 1) & mask
  }
}

///|
pub fn SpatialHashGrid::insert(
  self : SpatialHashGrid,
  id : Int,
  aabb : AABB,
) -> Unit {
  let idx = self.entries.length()
  let min_cx = floor_to_int(aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(aabb.min.y * self.inv_cell_size)
  let min_cz = floor_to_int(aabb.min.z * self.inv_cell_size)
  let max_cx = floor_to_int(aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(aabb.max.y * self.inv_cell_size)
  let max_cz = floor_to_int(aabb.max.z * self.inv_cell_size)
  self.entries.push({ id, aabb, min_cx, min_cy, min_cz, })
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        self.cell_items[self.find_or_create_cell(cx, cy, cz)].push(idx)
      }
    }
  }
}

///|
/// Items in a cell, or `None` when nothing has been inserted there.
///
/// The queries walk a coordinate range and most of the cells in it are empty, so
/// this keeps the "cell exists" test out of every caller.
fn SpatialHashGrid::cell_at(
  self : SpatialHashGrid,
  cx : Int,
  cy : Int,
  cz : Int,
) -> Array[Int]? {
  let ci = self.find_cell(cx, cy, cz)
  if ci < 0 {
    None
  } else {
    Some(self.cell_items[ci])
  }
}

///|
/// Grow the shared mask buffer to hold at least `needed` entries.
fn SpatialHashGrid::reserve_mask_scratch(
  self : SpatialHashGrid,
  needed : Int,
) -> Unit {
  if self.mask_scratch.length() < needed {
    let mut capacity = self.mask_scratch.length() * 2
    while capacity < needed {
      capacity = capacity * 2
    }
    self.mask_scratch = FixedArray::make(capacity, 0)
  }
}
