///|
fn clip_surface_polygon(
  points : Array[(Double, Double)],
  a : Double,
  b : Double,
  c : Double,
) -> Array[(Double, Double)] {
  let output : Array[(Double, Double)] = []
  if points.length() == 0 {
    return output
  }
  let mut previous = points[points.length() - 1]
  let mut previous_distance = a * previous.0 + b * previous.1 + c
  for current in points {
    let distance = a * current.0 + b * current.1 + c
    if (distance >= 0.0) != (previous_distance >= 0.0) {
      let t = previous_distance / (previous_distance - distance)
      output.push(
        (
          previous.0 + (current.0 - previous.0) * t,
          previous.1 + (current.1 - previous.1) * t,
        ),
      )
    }
    if distance >= 0.0 {
      output.push(current)
    }
    previous = current
    previous_distance = distance
  }
  output
}

///|
/// Project a convex XZ polygon onto the surface, splitting along all underlying
/// triangle edges. Unlike vertex-only draping, interiors stay exactly on the
/// terrain as well. Suitable for small ground decals / contact shadows.
pub fn HeightField::project_polygon(
  self : HeightField,
  points : Array[(Double, Double)],
  lift? : Double = 0.01,
) -> @mesh3d.Mesh3D {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  if points.length() < 3 ||
    points.any(p => {
      p.0.is_nan() || p.1.is_nan() || p.0.abs() > 1.0e9 || p.1.abs() > 1.0e9
    }) {
    return @mesh3d.Mesh3D::new(vertices, indices)
  }
  let mut min_x = points[0].0
  let mut max_x = min_x
  let mut min_z = points[0].1
  let mut max_z = min_z
  for (x, z) in points {
    min_x = min_x.min(x)
    max_x = max_x.max(x)
    min_z = min_z.min(z)
    max_z = max_z.max(z)
  }
  for
    z in min_z.floor().to_int().max(0)..<=max_z
    .floor()
    .to_int()
    .min(self.cells_z - 1) {
    for
      x in min_x.floor().to_int().max(0)..<=max_x
      .floor()
      .to_int()
      .min(self.cells_x - 1) {
      let px = x.to_double()
      let pz = z.to_double()
      let mut clipped = clip_surface_polygon(points, 1.0, 0.0, -px)
      clipped = clip_surface_polygon(clipped, -1.0, 0.0, px + 1.0)
      clipped = clip_surface_polygon(clipped, 0.0, 1.0, -pz)
      clipped = clip_surface_polygon(clipped, 0.0, -1.0, pz + 1.0)
      let a = self.at(x, z)
      let b = self.at(x, z + 1)
      let c = self.at(x + 1, z + 1)
      let d = self.at(x + 1, z)
      for triangle in 0..<2 {
        let polygon = if triangle == 0 {
          clip_surface_polygon(clipped, -1.0, 1.0, px - pz)
        } else {
          clip_surface_polygon(clipped, 1.0, -1.0, pz - px)
        }
        let gx = if triangle == 0 { c - b } else { d - a }
        let gz = if triangle == 0 { b - a } else { c - d }
        let normal = (gx * gx + 1.0 + gz * gz).sqrt()
        for i in 1..<(polygon.length() - 1) {
          let p = polygon[0]
          let q = polygon[i]
          let r = polygon[i + 1]
          let area = (q.0 - p.0) * (r.1 - p.1) - (q.1 - p.1) * (r.0 - p.0)
          if area.abs() < 1.0e-10 {
            continue
          }
          let corners = if area < 0.0 { [p, q, r] } else { [p, r, q] }
          for (vx, vz) in corners {
            indices.push(vertices.length() / 8)
            @mesh3d.push_vertex(
              vertices,
              vx,
              a + gx * (vx - px) + gz * (vz - pz) + lift,
              vz,
              -gx / normal,
              1.0 / normal,
              -gz / normal,
              0.0,
              0.0,
            )
          }
        }
      }
    }
  }
  @mesh3d.Mesh3D::new(vertices, indices)
}
