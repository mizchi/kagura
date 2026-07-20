///|
struct BroadphaseEntry {
  id : Int
  aabb : AABB
  min_cx : Int
  min_cy : Int
  min_cz : Int
}

///|
let cell_coord_mask : Int = 0x1FFFFF

///|
let cell_coord_sign_bit : Int = 0x100000

///|
let cell_coord_range : Int = 0x200000

///|
pub struct SpatialHashGrid {
  cell_size : Double
  inv_cell_size : Double
  cells : Map[Int64, Array[Int]]
  entries : Array[BroadphaseEntry]
}

///|
pub fn SpatialHashGrid::new(cell_size : Double) -> SpatialHashGrid {
  { cell_size, inv_cell_size: 1.0 / cell_size, cells: Map([]), entries: [] }
}

///|
pub fn SpatialHashGrid::clear(self : SpatialHashGrid) -> Unit {
  self.cells.clear()
  self.entries.clear()
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
fn cell_key(cx : Int, cy : Int, cz : Int) -> Int64 {
  let x = cx.land(cell_coord_mask).to_int64()
  let y = cy.land(cell_coord_mask).to_int64()
  let z = cz.land(cell_coord_mask).to_int64()
  (x << 42) | (y << 21) | z
}

///|
fn cell_coord_from_bits(bits : Int) -> Int {
  if bits >= cell_coord_sign_bit {
    bits - cell_coord_range
  } else {
    bits
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
  self.entries.push({ id, aabb, min_cx, min_cy, min_cz })
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        let key = cell_key(cx, cy, cz)
        match self.cells.get(key) {
          Some(bucket) => bucket.push(idx)
          None => self.cells[key] = [idx]
        }
      }
    }
  }
}
