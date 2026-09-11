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
/// Returns the pair count; read the pairs as `pair_id_a[p]` / `pair_id_b[p]` for
/// `p` in `0 ..< count`. `get_pairs` is this plus one heap tuple per pair.
pub fn SpatialHashGrid2D::get_pairs_into(self : SpatialHashGrid2D) -> Int {
  self.reset_pairs()
  let ids_a = self.pair_id_a
  let ids_b = self.pair_id_b
  let mut count = 0
  for ci = 0; ci < self.cell_count; ci = ci + 1 {
    let bucket = self.cell_items[ci]
    let bucket_len = bucket.length()
    for i = 0; i < bucket_len; i = i + 1 {
      // Hoisted: this used to be re-read from `entries` for every `j`.
      let a = self.entries[bucket[i]]
      let a_id = a.id
      let a_aabb = a.aabb
      for j = i + 1; j < bucket_len; j = j + 1 {
        let b = self.entries[bucket[j]]
        let b_id = b.id
        let min_id = if a_id < b_id { a_id } else { b_id }
        let max_id = if a_id > b_id { a_id } else { b_id }
        if self.mark_pair(min_id, max_id) && a_aabb.intersects(b.aabb) {
          if count < ids_a.length() {
            ids_a[count] = min_id
            ids_b[count] = max_id
          } else {
            ids_a.push(min_id)
            ids_b.push(max_id)
          }
          count = count + 1
        }
      }
    }
  }
  count
}

///|
/// Candidate pairs as tuples. Prefer `get_pairs_into` on a hot path: this adds
/// one heap tuple per pair on top of it.
pub fn SpatialHashGrid2D::get_pairs(
  self : SpatialHashGrid2D,
) -> Array[(Int, Int)] {
  let count = self.get_pairs_into()
  let result : Array[(Int, Int)] = Array(capacity=count)
  for p = 0; p < count; p = p + 1 {
    result.push((self.pair_id_a[p], self.pair_id_b[p]))
  }
  result
}
