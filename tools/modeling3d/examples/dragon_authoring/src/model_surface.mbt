///|
struct BakedSurfaceSample {
  layer_id : String
  position : @math3d.Vec3
  normal : @math3d.Vec3
  half_span : Double
  thickness : Double
}

///|
struct SurfaceDirection {
  dx : Int
  dy : Int
  dz : Int
  normal : @math3d.Vec3
}

///|
struct SurfaceBasis {
  tangent_u : @math3d.Vec3
  tangent_v : @math3d.Vec3
}

///|
struct DensityGrid {
  step : Double
  half_steps : Int
  size : Int
  densities : Array[Double]
}

///|
struct SurfaceVertex {
  position : @math3d.Vec3
  normal : @math3d.Vec3
}

///|
struct EdgeIndices {
  a : Int
  b : Int
}

///|
struct TetraIndices {
  a : Int
  b : Int
  c : Int
  d : Int
}

///|
fn surface_directions() -> Array[SurfaceDirection] {
  [
    { dx: 1, dy: 0, dz: 0, normal: @math3d.Vec3::unit_x() },
    { dx: -1, dy: 0, dz: 0, normal: @math3d.Vec3::unit_x().scale(-1.0) },
    { dx: 0, dy: 1, dz: 0, normal: @math3d.Vec3::unit_y() },
    { dx: 0, dy: -1, dz: 0, normal: @math3d.Vec3::unit_y().scale(-1.0) },
    { dx: 0, dy: 0, dz: 1, normal: @math3d.Vec3::unit_z() },
    { dx: 0, dy: 0, dz: -1, normal: @math3d.Vec3::unit_z().scale(-1.0) },
  ]
}

///|
fn is_sculpt_layer_voxel_filled(
  layer : SculptLayer,
  ix : Int,
  iy : Int,
  iz : Int,
) -> Bool {
  let half = layer.half_extent
  if ix < -half ||
    ix > half ||
    iy < -half ||
    iy > half ||
    iz < -half ||
    iz > half {
    false
  } else {
    sample_sculpt_layer(layer, voxel_cell_center(layer, ix, iy, iz))
  }
}

///|
fn sculpt_layer_baked_surface_samples(
  layer : SculptLayer,
) -> Array[BakedSurfaceSample] {
  let samples : Array[BakedSurfaceSample] = []
  let half = layer.half_extent
  let face_offset = layer.voxel_size * 0.5
  let face_half_span = layer.voxel_size * 0.5
  let face_thickness = layer.voxel_size * 0.12
  let directions = surface_directions()
  for ix in -half..<=half {
    for iy in -half..<=half {
      for iz in -half..<=half {
        let center = voxel_cell_center(layer, ix, iy, iz)
        if !sample_sculpt_layer(layer, center) {
          continue
        }
        for direction in directions {
          if is_sculpt_layer_voxel_filled(
              layer,
              ix + direction.dx,
              iy + direction.dy,
              iz + direction.dz,
            ) {
            continue
          }
          samples.push({
            layer_id: layer.id,
            position: center.add(direction.normal.scale(face_offset)),
            normal: direction.normal,
            half_span: face_half_span,
            thickness: face_thickness,
          })
        }
      }
    }
  }
  samples
}

///|
fn layer_baked_surface_sample_count(layer : SculptLayer) -> Int {
  sculpt_layer_baked_surface_samples(layer).length()
}

///|
fn sculpt_layer_density(layer : SculptLayer, point : @math3d.Vec3) -> Double {
  let mut density = -layer.voxel_size * 0.5
  for stamp in layer.stamps {
    if !is_sculpt_stamp_enabled(layer, stamp.id) {
      continue
    }
    let influence = stamp.radius - point.distance(stamp.center)
    if influence > 0.0 {
      let contribution = match stamp.mode {
        Add => influence
        Subtract => influence * -1.15
      }
      density = density + contribution
    }
  }
  density
}

///|
fn surface_basis(normal : @math3d.Vec3) -> SurfaceBasis {
  let helper = if normal.y.abs() < 0.9 {
    @math3d.Vec3::unit_y()
  } else {
    @math3d.Vec3::unit_x()
  }
  let tangent_u = helper.cross(normal).normalize()
  let tangent_v = normal.cross(tangent_u).normalize()
  { tangent_u, tangent_v }
}

///|
fn sculpt_layer_surface_normal(
  layer : SculptLayer,
  point : @math3d.Vec3,
  sample_step : Double,
) -> @math3d.Vec3 {
  let dx = @math3d.Vec3::new(sample_step, 0.0, 0.0)
  let dy = @math3d.Vec3::new(0.0, sample_step, 0.0)
  let dz = @math3d.Vec3::new(0.0, 0.0, sample_step)
  let gradient = @math3d.Vec3::new(
    sculpt_layer_density(layer, point.add(dx)) -
    sculpt_layer_density(layer, point.sub(dx)),
    sculpt_layer_density(layer, point.add(dy)) -
    sculpt_layer_density(layer, point.sub(dy)),
    sculpt_layer_density(layer, point.add(dz)) -
    sculpt_layer_density(layer, point.sub(dz)),
  )
  if gradient.length() > 1.0e-9 {
    gradient.scale(-1.0).normalize()
  } else {
    @math3d.Vec3::unit_y()
  }
}

///|
fn build_sculpt_layer_density_grid(layer : SculptLayer) -> DensityGrid {
  let step = layer.voxel_size * 0.5
  let half_steps = layer.half_extent * 2 + 1
  let size = half_steps * 2 + 1
  let densities : Array[Double] = []
  for ix in 0..<size {
    let x = (ix - half_steps).to_double() * step
    for iy in 0..<size {
      let y = (iy - half_steps).to_double() * step
      for iz in 0..<size {
        let z = (iz - half_steps).to_double() * step
        densities.push(sculpt_layer_density(layer, @math3d.Vec3::new(x, y, z)))
      }
    }
  }
  { step, half_steps, size, densities }
}

///|
fn density_grid_index(grid : DensityGrid, ix : Int, iy : Int, iz : Int) -> Int {
  ix * grid.size * grid.size + iy * grid.size + iz
}

///|
fn density_grid_value(
  grid : DensityGrid,
  ix : Int,
  iy : Int,
  iz : Int,
) -> Double {
  grid.densities[density_grid_index(grid, ix, iy, iz)]
}

///|
fn density_grid_position(
  grid : DensityGrid,
  ix : Int,
  iy : Int,
  iz : Int,
) -> @math3d.Vec3 {
  @math3d.Vec3::new(
    (ix - grid.half_steps).to_double() * grid.step,
    (iy - grid.half_steps).to_double() * grid.step,
    (iz - grid.half_steps).to_double() * grid.step,
  )
}

///|
fn interpolate_surface_vertex(
  layer : SculptLayer,
  a_pos : @math3d.Vec3,
  b_pos : @math3d.Vec3,
  a_density : Double,
  b_density : Double,
  normal_step : Double,
) -> SurfaceVertex {
  let denom = a_density - b_density
  let t = if denom.abs() < 1.0e-9 {
    0.5
  } else {
    clamp_double(a_density / denom, 0.0, 1.0)
  }
  let position = a_pos.lerp(b_pos, t)
  {
    position,
    normal: sculpt_layer_surface_normal(layer, position, normal_step),
  }
}

///|
fn average_surface_normal(vertices : Array[SurfaceVertex]) -> @math3d.Vec3 {
  let mut total = @math3d.Vec3::zero()
  for vertex in vertices {
    total = total.add(vertex.normal)
  }
  if total.length() > 1.0e-9 {
    total.normalize()
  } else {
    @math3d.Vec3::unit_y()
  }
}

///|
fn polygon_vertex_angle(
  vertex : SurfaceVertex,
  center : @math3d.Vec3,
  basis : SurfaceBasis,
) -> Double {
  let delta = vertex.position.sub(center)
  @math.atan2(delta.dot(basis.tangent_v), delta.dot(basis.tangent_u))
}

///|
fn oriented_surface_polygon(
  vertices : Array[SurfaceVertex],
  reference_normal : @math3d.Vec3,
) -> Array[SurfaceVertex] {
  if vertices.length() <= 2 {
    return vertices
  }
  let mut center = @math3d.Vec3::zero()
  for vertex in vertices {
    center = center.add(vertex.position)
  }
  center = center.scale(1.0 / vertices.length().to_double())
  let basis = surface_basis(reference_normal)
  let ordered : Array[SurfaceVertex] = []
  for vertex in vertices {
    ordered.push(vertex)
  }
  for i in 0..<ordered.length() {
    let start = i + 1
    for j in start..<ordered.length() {
      if polygon_vertex_angle(ordered[j], center, basis) <
        polygon_vertex_angle(ordered[i], center, basis) {
        let tmp = ordered[i]
        ordered[i] = ordered[j]
        ordered[j] = tmp
      }
    }
  }
  let face_normal = ordered[1].position
    .sub(ordered[0].position)
    .cross(ordered[2].position.sub(ordered[0].position))
  if face_normal.dot(reference_normal) >= 0.0 {
    ordered
  } else {
    let reversed : Array[SurfaceVertex] = [ordered[0]]
    for i in 1..<ordered.length() {
      reversed.push(ordered[ordered.length() - i])
    }
    reversed
  }
}

///|
fn append_baked_mesh_vertex(
  data : Array[Double],
  vertex : SurfaceVertex,
  inflate : Double,
  u : Double,
  v : Double,
) -> Unit {
  let position = vertex.position.add(vertex.normal.scale(inflate))
  data.push(position.x)
  data.push(position.y)
  data.push(position.z)
  data.push(vertex.normal.x)
  data.push(vertex.normal.y)
  data.push(vertex.normal.z)
  data.push(u)
  data.push(v)
}

///|
fn append_surface_triangle(
  data : Array[Double],
  indices : Array[Int],
  a : SurfaceVertex,
  b : SurfaceVertex,
  c : SurfaceVertex,
  inflate : Double,
) -> Unit {
  let base = data.length() / @mesh3d.vertex3d_stride
  append_baked_mesh_vertex(data, a, inflate, 0.0, 1.0)
  append_baked_mesh_vertex(data, b, inflate, 1.0, 1.0)
  append_baked_mesh_vertex(data, c, inflate, 0.5, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 1)
  indices.push(base + 0)
}

///|
fn append_surface_polygon(
  data : Array[Double],
  indices : Array[Int],
  polygon : Array[SurfaceVertex],
  inflate : Double,
) -> Unit {
  if polygon.length() == 3 {
    append_surface_triangle(
      data,
      indices,
      polygon[0],
      polygon[1],
      polygon[2],
      inflate,
    )
  } else if polygon.length() == 4 {
    append_surface_triangle(
      data,
      indices,
      polygon[0],
      polygon[1],
      polygon[2],
      inflate,
    )
    append_surface_triangle(
      data,
      indices,
      polygon[0],
      polygon[2],
      polygon[3],
      inflate,
    )
  }
}

///|
fn polygonize_tetrahedron(
  layer : SculptLayer,
  positions : Array[@math3d.Vec3],
  densities : Array[Double],
  normal_step : Double,
) -> Array[SurfaceVertex] {
  let intersections : Array[SurfaceVertex] = []
  let edges : Array[EdgeIndices] = [
    { a: 0, b: 1 },
    { a: 1, b: 2 },
    { a: 2, b: 0 },
    { a: 0, b: 3 },
    { a: 1, b: 3 },
    { a: 2, b: 3 },
  ]
  for edge in edges {
    let a_density = densities[edge.a]
    let b_density = densities[edge.b]
    if (a_density > 0.0) == (b_density > 0.0) {
      continue
    }
    intersections.push(
      interpolate_surface_vertex(
        layer,
        positions[edge.a],
        positions[edge.b],
        a_density,
        b_density,
        normal_step,
      ),
    )
  }
  if intersections.length() < 3 {
    []
  } else {
    oriented_surface_polygon(
      intersections,
      average_surface_normal(intersections),
    )
  }
}

///|
fn append_marching_tetra_cell(
  layer : SculptLayer,
  data : Array[Double],
  indices : Array[Int],
  positions : Array[@math3d.Vec3],
  densities : Array[Double],
  normal_step : Double,
  inflate : Double,
) -> Unit {
  let tetrahedra : Array[TetraIndices] = [
    { a: 0, b: 5, c: 1, d: 6 },
    { a: 0, b: 1, c: 2, d: 6 },
    { a: 0, b: 2, c: 3, d: 6 },
    { a: 0, b: 3, c: 7, d: 6 },
    { a: 0, b: 7, c: 4, d: 6 },
    { a: 0, b: 4, c: 5, d: 6 },
  ]
  for tetra in tetrahedra {
    let polygon = polygonize_tetrahedron(
      layer,
      [
        positions[tetra.a],
        positions[tetra.b],
        positions[tetra.c],
        positions[tetra.d],
      ],
      [
        densities[tetra.a],
        densities[tetra.b],
        densities[tetra.c],
        densities[tetra.d],
      ],
      normal_step,
    )
    append_surface_polygon(data, indices, polygon, inflate)
  }
}

///|
fn sculpt_layer_baked_mesh_with_inflate(
  layer : SculptLayer,
  inflate : Double,
) -> @mesh3d.Mesh3D {
  let grid = build_sculpt_layer_density_grid(layer)
  let vertex_data : Array[Double] = []
  let indices : Array[Int] = []
  let max_index = grid.size - 1
  for ix in 0..<max_index {
    for iy in 0..<max_index {
      for iz in 0..<max_index {
        let positions : Array[@math3d.Vec3] = [
          density_grid_position(grid, ix, iy, iz),
          density_grid_position(grid, ix + 1, iy, iz),
          density_grid_position(grid, ix + 1, iy + 1, iz),
          density_grid_position(grid, ix, iy + 1, iz),
          density_grid_position(grid, ix, iy, iz + 1),
          density_grid_position(grid, ix + 1, iy, iz + 1),
          density_grid_position(grid, ix + 1, iy + 1, iz + 1),
          density_grid_position(grid, ix, iy + 1, iz + 1),
        ]
        let densities : Array[Double] = [
          density_grid_value(grid, ix, iy, iz),
          density_grid_value(grid, ix + 1, iy, iz),
          density_grid_value(grid, ix + 1, iy + 1, iz),
          density_grid_value(grid, ix, iy + 1, iz),
          density_grid_value(grid, ix, iy, iz + 1),
          density_grid_value(grid, ix + 1, iy, iz + 1),
          density_grid_value(grid, ix + 1, iy + 1, iz + 1),
          density_grid_value(grid, ix, iy + 1, iz + 1),
        ]
        append_marching_tetra_cell(
          layer,
          vertex_data,
          indices,
          positions,
          densities,
          grid.step,
          inflate,
        )
      }
    }
  }
  @mesh3d.Mesh3D::new(vertex_data, indices)
}

///|
fn sculpt_layer_baked_mesh(layer : SculptLayer) -> @mesh3d.Mesh3D {
  sculpt_layer_baked_mesh_with_inflate(layer, 0.0)
}

///|
fn layer_baked_triangle_count(layer : SculptLayer) -> Int {
  sculpt_layer_baked_mesh(layer).triangle_count()
}

///|
fn layer_baked_vertex_count(layer : SculptLayer) -> Int {
  sculpt_layer_baked_mesh(layer).vertex_count()
}
