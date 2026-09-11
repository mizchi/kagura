///|
pub fn SpatialHashGrid2D::query_aabb(
  self : SpatialHashGrid2D,
  aabb : AABB2D,
) -> Array[Int] {
  let min_cx = floor_to_int(aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(aabb.min.y * self.inv_cell_size)
  let max_cx = floor_to_int(aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(aabb.max.y * self.inv_cell_size)
  let seen : Map[Int, Unit] = Map([])
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      match self.cell_at(cx, cy) {
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
/// Candidate overlapping pairs, each reported once.
///
/// Walks cells in first-touch order -- the order the old `Map[Int64, _]` gave
/// through `each` -- and dedupes through the grid's pooled pair table instead of
/// a fresh `Map[Int64, Unit]` per call. Both orderings are load-bearing: pair
/// order reaches the solver, and marking a pair seen before its AABB test (so a
/// rejected pair is not retried from another cell) decides pair membership.
pub fn SpatialHashGrid2D::get_pairs(
  self : SpatialHashGrid2D,
) -> Array[(Int, Int)] {
  self.reset_pairs()
  let result : Array[(Int, Int)] = []
  for ci = 0; ci < self.cell_count; ci = ci + 1 {
    let bucket = self.cell_items[ci]
    let bucket_len = bucket.length()
    for i = 0; i < bucket_len; i = i + 1 {
      for j = i + 1; j < bucket_len; j = j + 1 {
        let a = self.entries[bucket[i]]
        let b = self.entries[bucket[j]]
        let min_id = if a.id < b.id { a.id } else { b.id }
        let max_id = if a.id > b.id { a.id } else { b.id }
        if self.mark_pair(min_id, max_id) && a.aabb.intersects(b.aabb) {
          result.push((min_id, max_id))
        }
      }
    }
  }
  result
}
