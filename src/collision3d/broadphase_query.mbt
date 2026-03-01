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
  let seen : Map[Int, Unit] = {}
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        let key = cell_key(cx, cy, cz)
        match self.cells.get(key) {
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
  let seen : Map[Int, Unit] = {}
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        let key = cell_key(cx, cy, cz)
        match self.cells.get(key) {
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
  let seen : Map[Int, Unit] = {}
  let result : Array[Int] = []
  for cx = min_cx; cx <= max_cx; cx = cx + 1 {
    for cy = min_cy; cy <= max_cy; cy = cy + 1 {
      for cz = min_cz; cz <= max_cz; cz = cz + 1 {
        let key = cell_key(cx, cy, cz)
        match self.cells.get(key) {
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
pub fn SpatialHashGrid::get_pairs(
  self : SpatialHashGrid,
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
            if a.aabb.intersects_aabb(b.aabb) {
              result.push((min_id, max_id))
            }
          }
        }
      }
    }
  })
  result
}
