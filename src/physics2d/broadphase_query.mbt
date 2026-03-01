///|
pub fn SpatialHashGrid2D::query_aabb(
  self : SpatialHashGrid2D,
  aabb : AABB2D,
) -> Array[Int] {
  let min_cx = floor_to_int(aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(aabb.min.y * self.inv_cell_size)
  let max_cx = floor_to_int(aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(aabb.max.y * self.inv_cell_size)
  let seen : Map[Int, Unit] = {}
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      let key = cell_key2d(cx, cy)
      match self.cells.get(key) {
        Some(bucket) =>
          for i = 0; i < bucket.length(); i = i + 1 {
            let entry = self.entries[bucket[i]]
            match seen.get(entry.id) {
              Some(_) => ()
              None =>
                if entry.aabb.intersects(aabb) {
                  seen[entry.id] = ()
                  result.push(entry.id)
                }
            }
          }
        None => ()
      }
    }
  }
  result
}

///|
pub fn SpatialHashGrid2D::get_pairs(
  self : SpatialHashGrid2D,
) -> Array[(Int, Int)] {
  let seen : Map[Int64, Unit] = {}
  let result : Array[(Int, Int)] = []
  self.cells.each(fn(_key, bucket) {
    for i = 0; i < bucket.length(); i = i + 1 {
      for j = i + 1; j < bucket.length(); j = j + 1 {
        let a = self.entries[bucket[i]]
        let b = self.entries[bucket[j]]
        let min_id = if a.id < b.id { a.id } else { b.id }
        let max_id = if a.id > b.id { a.id } else { b.id }
        let pair_key = (min_id.to_int64() << 32) | max_id.to_int64()
        match seen.get(pair_key) {
          Some(_) => ()
          None => {
            seen[pair_key] = ()
            if a.aabb.intersects(b.aabb) {
              result.push((min_id, max_id))
            }
          }
        }
      }
    }
  })
  result
}
