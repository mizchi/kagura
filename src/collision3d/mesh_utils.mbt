///|
pub fn aabb_from_mesh(mesh : @mesh3d.Mesh3D) -> AABB {
  let data = mesh.vertex_data
  let stride = @mesh3d.vertex3d_stride
  let count = mesh.vertex_count()
  guard count > 0
  let mut min_x = data[0]
  let mut min_y = data[1]
  let mut min_z = data[2]
  let mut max_x = min_x
  let mut max_y = min_y
  let mut max_z = min_z
  for i in 1..<count {
    let base = i * stride
    let x = data[base]
    let y = data[base + 1]
    let z = data[base + 2]
    if x < min_x {
      min_x = x
    }
    if y < min_y {
      min_y = y
    }
    if z < min_z {
      min_z = z
    }
    if x > max_x {
      max_x = x
    }
    if y > max_y {
      max_y = y
    }
    if z > max_z {
      max_z = z
    }
  }
  AABB::new(
    @math3d.Vec3::new(min_x, min_y, min_z),
    @math3d.Vec3::new(max_x, max_y, max_z),
  )
}
