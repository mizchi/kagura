///|
struct BroadphaseEntry2D {
  id : Int
  aabb : AABB2D
}

///|
pub struct SpatialHashGrid2D {
  cell_size : Double
  inv_cell_size : Double
  cells : Map[Int64, Array[Int]]
  entries : Array[BroadphaseEntry2D]
}

///|
pub fn SpatialHashGrid2D::new(cell_size : Double) -> SpatialHashGrid2D {
  {
    cell_size,
    inv_cell_size: 1.0 / cell_size,
    cells: {},
    entries: [],
  }
}

///|
pub fn SpatialHashGrid2D::clear(self : SpatialHashGrid2D) -> Unit {
  self.cells.clear()
  self.entries.clear()
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
fn cell_key2d(cx : Int, cy : Int) -> Int64 {
  let mask = 0xFFFFFFFF
  let x = cx.land(mask).to_int64()
  let y = cy.land(mask).to_int64()
  (x << 32) | y
}

///|
pub fn SpatialHashGrid2D::insert(
  self : SpatialHashGrid2D,
  id : Int,
  aabb : AABB2D,
) -> Unit {
  let idx = self.entries.length()
  self.entries.push({ id, aabb })
  let min_cx = floor_to_int(aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(aabb.min.y * self.inv_cell_size)
  let max_cx = floor_to_int(aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(aabb.max.y * self.inv_cell_size)
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      let key = cell_key2d(cx, cy)
      match self.cells.get(key) {
        Some(bucket) => bucket.push(idx)
        None => self.cells[key] = [idx]
      }
    }
  }
}
