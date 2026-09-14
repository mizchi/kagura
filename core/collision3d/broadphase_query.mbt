///|
fn entry_overlap_start_mask(
  entry : BroadphaseEntry,
  cx : Int,
  cy : Int,
  cz : Int,
) -> Int {
  let mut mask = 0
  if entry.min_cx == cx {
    mask = mask | 1
  }
  if entry.min_cy == cy {
    mask = mask | 2
  }
  if entry.min_cz == cz {
    mask = mask | 4
  }
  mask
}

///|
fn bucket_mask_bits_can_emit_pairs(mask_bits : Int) -> Bool {
  for lhs = 0; lhs < 8; lhs = lhs + 1 {
    if (mask_bits & (1 << lhs)) == 0 {
      continue
    }
    for rhs = lhs; rhs < 8; rhs = rhs + 1 {
      if (mask_bits & (1 << rhs)) == 0 {
        continue
      }
      if (lhs | rhs) == 7 {
        return true
      }
    }
  }
  false
}

///|
pub fn SpatialHashGrid::query_aabb(
  self : SpatialHashGrid,
  aabb : AABB,
) -> Array[Int] {
  let min_cx = floor_to_int(aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(aabb.min.y * self.inv_cell_size)
  let min_cz = floor_to_int(aabb.min.z * self.inv_cell_size)
  let max_cx = floor_to_int(aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(aabb.max.y * self.inv_cell_size)
  let max_cz = floor_to_int(aabb.max.z * self.inv_cell_size)
  let seen : Map[Int, Unit] = Map([])
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        match self.cell_at(cx, cy, cz) {
          Some(bucket) =>
            for i = 0; i < bucket.length(); i = i + 1 {
              let entry = self.entries[bucket[i]]
              match seen.get(entry.id) {
                Some(_) => ()
                None =>
                  if entry.aabb.intersects_aabb(aabb) {
                    seen[entry.id] = ()
                    result.push(entry.id)
                  }
              }
            }
          None => ()
        }
      }
    }
  }
  result
}

///|
pub fn SpatialHashGrid::query_sphere(
  self : SpatialHashGrid,
  sphere : Sphere,
) -> Array[Int] {
  let sphere_aabb = AABB::new(
    @math3d.Vec3::new(
      sphere.center.x - sphere.radius,
      sphere.center.y - sphere.radius,
      sphere.center.z - sphere.radius,
    ),
    @math3d.Vec3::new(
      sphere.center.x + sphere.radius,
      sphere.center.y + sphere.radius,
      sphere.center.z + sphere.radius,
    ),
  )
  let min_cx = floor_to_int(sphere_aabb.min.x * self.inv_cell_size)
  let min_cy = floor_to_int(sphere_aabb.min.y * self.inv_cell_size)
  let min_cz = floor_to_int(sphere_aabb.min.z * self.inv_cell_size)
  let max_cx = floor_to_int(sphere_aabb.max.x * self.inv_cell_size)
  let max_cy = floor_to_int(sphere_aabb.max.y * self.inv_cell_size)
  let max_cz = floor_to_int(sphere_aabb.max.z * self.inv_cell_size)
  let seen : Map[Int, Unit] = Map([])
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        match self.cell_at(cx, cy, cz) {
          Some(bucket) =>
            for i = 0; i < bucket.length(); i = i + 1 {
              let entry = self.entries[bucket[i]]
              match seen.get(entry.id) {
                Some(_) => ()
                None =>
                  if entry.aabb.intersects_sphere(sphere) {
                    seen[entry.id] = ()
                    result.push(entry.id)
                  }
              }
            }
          None => ()
        }
      }
    }
  }
  result
}

///|
pub fn SpatialHashGrid::query_ray(
  self : SpatialHashGrid,
  ray : Ray,
  max_distance : Double,
) -> Array[Int] {
  let end = ray.point_at(max_distance)
  let min_x = if ray.origin.x < end.x { ray.origin.x } else { end.x }
  let min_y = if ray.origin.y < end.y { ray.origin.y } else { end.y }
  let min_z = if ray.origin.z < end.z { ray.origin.z } else { end.z }
  let max_x = if ray.origin.x > end.x { ray.origin.x } else { end.x }
  let max_y = if ray.origin.y > end.y { ray.origin.y } else { end.y }
  let max_z = if ray.origin.z > end.z { ray.origin.z } else { end.z }
  let min_cx = floor_to_int(min_x * self.inv_cell_size)
  let min_cy = floor_to_int(min_y * self.inv_cell_size)
  let min_cz = floor_to_int(min_z * self.inv_cell_size)
  let max_cx = floor_to_int(max_x * self.inv_cell_size)
  let max_cy = floor_to_int(max_y * self.inv_cell_size)
  let max_cz = floor_to_int(max_z * self.inv_cell_size)
  let seen : Map[Int, Unit] = Map([])
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        match self.cell_at(cx, cy, cz) {
          Some(bucket) =>
            for i = 0; i < bucket.length(); i = i + 1 {
              let entry = self.entries[bucket[i]]
              match seen.get(entry.id) {
                Some(_) => ()
                None => {
                  let hit = ray.intersects_aabb(entry.aabb)
                  if hit.hit && hit.distance <= max_distance {
                    seen[entry.id] = ()
                    result.push(entry.id)
                  }
                }
              }
            }
          None => ()
        }
      }
    }
  }
  result
}

///|
/// Candidate overlapping pairs, each reported once, as two parallel columns in
/// the grid's own pooled arrays.
///
/// Returns the pair count; read the pairs as `pair_id_a[p]` / `pair_id_b[p]` for
/// `p` in `0 ..< count`. `get_pairs` is this plus one heap tuple per pair, which
/// on a 256-body pile is 1438 tuples a frame that the caller unpacks immediately.
///
/// Cells are walked in first-touch order, which is the order the old
/// `Map[Int64, _]` gave through `each` -- `Map` keeps an insertion-ordered
/// linked list. Pair order reaches the solver, so this is load-bearing.
pub fn SpatialHashGrid::get_pairs_into(self : SpatialHashGrid) -> Int {
  let ids_a = self.pair_id_a
  let ids_b = self.pair_id_b
  let mut count = 0
  for ci = 0; ci < self.cell_count; ci = ci + 1 {
    let bucket = self.cell_items[ci]
    let bucket_len = bucket.length()
    if bucket_len < 2 {
      continue
    }
    let cx = self.cell_cx[ci]
    let cy = self.cell_cy[ci]
    let cz = self.cell_cz[ci]
    self.reserve_mask_scratch(bucket_len)
    let bucket_masks = self.mask_scratch
    let mut mask_bits = 0
    for i = 0; i < bucket_len; i = i + 1 {
      let mask = entry_overlap_start_mask(self.entries[bucket[i]], cx, cy, cz)
      bucket_masks[i] = mask
      mask_bits = mask_bits | (1 << mask)
    }
    if !bucket_mask_bits_can_emit_pairs(mask_bits) {
      continue
    }
    for i = 0; i < bucket_len; i = i + 1 {
      let mask_i = bucket_masks[i]
      // Hoisted: this used to be re-read from `entries` for every `j`.
      let a = self.entries[bucket[i]]
      let a_id = a.id
      let a_aabb = a.aabb
      for j = i + 1; j < bucket_len; j = j + 1 {
        if (mask_i | bucket_masks[j]) != 7 {
          continue
        }
        let b = self.entries[bucket[j]]
        if a_aabb.intersects_aabb(b.aabb) {
          let b_id = b.id
          let min_id = if a_id < b_id { a_id } else { b_id }
          let max_id = if a_id > b_id { a_id } else { b_id }
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
pub fn SpatialHashGrid::get_pairs(self : SpatialHashGrid) -> Array[(Int, Int)] {
  let count = self.get_pairs_into()
  let result : Array[(Int, Int)] = Array(capacity=count)
  for p = 0; p < count; p = p + 1 {
    result.push((self.pair_id_a[p], self.pair_id_b[p]))
  }
  result
}
