// Pre-built 3D meshes (environment + items only; characters use skeletal models)

///|
fn Meshes3D::new() -> Meshes3D {
  {
    item: @mesh3d.Mesh3D::sphere(0.2, 5, 3),
    projectile: @mesh3d.Mesh3D::sphere(0.15, 4, 3),
    arrow: make_arrow_mesh(0.65, 0.05),
    floor_tile: @mesh3d.Mesh3D::plane(1.0, 1.0),
    wall: make_wall_mesh(1.0, 0.5, 1.0),
    wall_low: make_wall_mesh(1.0, 0.3, 1.0),
    wall_tall: make_wall_mesh(1.0, 0.7, 1.0),
    ledge: make_wall_mesh(1.0, 0.2, 1.0),
    pillar: make_pillar_mesh(0.15, 0.7),
    debris: make_wall_mesh(0.2, 0.08, 0.2),
    crate: make_wall_mesh(0.35, 0.3, 0.35),
    loot_beam: make_loot_beam_mesh(0.06, 3.0),
    telegraph_disc: @mesh3d.Mesh3D::plane(1.0, 1.0), // unit plane, scaled per marker
  }
}

///|
fn make_wall_mesh(
  width : Double,
  height : Double,
  depth : Double,
) -> @mesh3d.Mesh3D {
  @mesh3d.Mesh3D::box(width, height, depth)
}

// Pillar mesh: narrow tall box for decoration

///|
fn make_pillar_mesh(radius : Double, height : Double) -> @mesh3d.Mesh3D {
  make_wall_mesh(radius * 2.0, height, radius * 2.0)
}

// Arrow mesh: elongated diamond shape pointing along +X axis

///|
fn make_arrow_mesh(length : Double, thickness : Double) -> @mesh3d.Mesh3D {
  let data : Array[Double] = []
  let indices : Array[Int] = []
  let hl = length / 2.0
  let t = thickness
  let head_w = t * 2.5 // wider arrowhead
  let head_len = length * 0.3 // front 30% is the head
  let tail_t = t * 0.4 // thin tail
  // === Arrowhead (front, wider diamond) ===
  // Top
  @mesh3d.push_vertex(data, hl, 0.0, 0.0, 0.0, 1.0, 0.0, 0.5, 0.0) // 0: tip
  @mesh3d.push_vertex(data, hl - head_len, head_w, -head_w, 0.0, 1.0, 0.0, 0.0, 1.0) // 1
  @mesh3d.push_vertex(data, hl - head_len, head_w, head_w, 0.0, 1.0, 0.0, 1.0, 1.0) // 2
  indices.push(0)
  indices.push(1)
  indices.push(2)
  // Bottom
  @mesh3d.push_vertex(data, hl, 0.0, 0.0, 0.0, -1.0, 0.0, 0.5, 0.0) // 3
  @mesh3d.push_vertex(data, hl - head_len, -head_w, head_w, 0.0, -1.0, 0.0, 0.0, 1.0) // 4
  @mesh3d.push_vertex(data, hl - head_len, -head_w, -head_w, 0.0, -1.0, 0.0, 1.0, 1.0) // 5
  indices.push(3)
  indices.push(4)
  indices.push(5)
  // Right
  @mesh3d.push_vertex(data, hl, 0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0.0) // 6
  @mesh3d.push_vertex(data, hl - head_len, head_w, head_w, 0.0, 0.0, 1.0, 0.0, 1.0) // 7
  @mesh3d.push_vertex(data, hl - head_len, -head_w, head_w, 0.0, 0.0, 1.0, 1.0, 1.0) // 8
  indices.push(6)
  indices.push(7)
  indices.push(8)
  // Left
  @mesh3d.push_vertex(data, hl, 0.0, 0.0, 0.0, 0.0, -1.0, 0.5, 0.0) // 9
  @mesh3d.push_vertex(data, hl - head_len, -head_w, -head_w, 0.0, 0.0, -1.0, 0.0, 1.0) // 10
  @mesh3d.push_vertex(data, hl - head_len, head_w, -head_w, 0.0, 0.0, -1.0, 1.0, 1.0) // 11
  indices.push(9)
  indices.push(10)
  indices.push(11)
  // === Shaft (thin body to tail) ===
  // Top
  @mesh3d.push_vertex(data, hl - head_len, t, -t, 0.0, 1.0, 0.0, 0.0, 0.0) // 12
  @mesh3d.push_vertex(data, hl - head_len, t, t, 0.0, 1.0, 0.0, 1.0, 0.0) // 13
  @mesh3d.push_vertex(data, -hl, tail_t, tail_t, 0.0, 1.0, 0.0, 1.0, 1.0) // 14
  @mesh3d.push_vertex(data, -hl, tail_t, -tail_t, 0.0, 1.0, 0.0, 0.0, 1.0) // 15
  @mesh3d.push_quad(indices, 12)
  // Bottom
  @mesh3d.push_vertex(data, hl - head_len, -t, t, 0.0, -1.0, 0.0, 0.0, 0.0) // 16
  @mesh3d.push_vertex(data, hl - head_len, -t, -t, 0.0, -1.0, 0.0, 1.0, 0.0) // 17
  @mesh3d.push_vertex(data, -hl, -tail_t, -tail_t, 0.0, -1.0, 0.0, 1.0, 1.0) // 18
  @mesh3d.push_vertex(data, -hl, -tail_t, tail_t, 0.0, -1.0, 0.0, 0.0, 1.0) // 19
  @mesh3d.push_quad(indices, 16)
  // === Tail fins (small fletchings) ===
  let fin = t * 3.0
  // Vertical fin
  @mesh3d.push_vertex(data, -hl, -fin, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0) // 20
  @mesh3d.push_vertex(data, -hl + length * 0.12, 0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0.0) // 21
  @mesh3d.push_vertex(data, -hl, fin, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0) // 22
  indices.push(20)
  indices.push(21)
  indices.push(22)
  // Horizontal fin
  @mesh3d.push_vertex(data, -hl, 0.0, -fin, 0.0, 1.0, 0.0, 0.0, 1.0) // 23
  @mesh3d.push_vertex(data, -hl + length * 0.12, 0.0, 0.0, 0.0, 1.0, 0.0, 0.5, 0.0) // 24
  @mesh3d.push_vertex(data, -hl, 0.0, fin, 0.0, 1.0, 0.0, 1.0, 1.0) // 25
  indices.push(23)
  indices.push(24)
  indices.push(25)
  @mesh3d.Mesh3D::new(data, indices)
}

///|
fn make_loot_beam_mesh(width : Double, height : Double) -> @mesh3d.Mesh3D {
  let hw = width / 2.0
  let data : Array[Double] = []
  let indices : Array[Int] = []
  // Two crossed vertical planes for visibility from any angle
  // Plane 1: aligned with X axis
  @mesh3d.push_vertex(data, -hw, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0)
  @mesh3d.push_vertex(data, hw, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
  @mesh3d.push_vertex(data, hw, height, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0)
  @mesh3d.push_vertex(data, -hw, height, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0)
  @mesh3d.push_quad(indices, 0)
  // Plane 2: aligned with Z axis
  @mesh3d.push_vertex(data, 0.0, 0.0, -hw, 1.0, 0.0, 0.0, 0.0, 1.0)
  @mesh3d.push_vertex(data, 0.0, 0.0, hw, 1.0, 0.0, 0.0, 1.0, 1.0)
  @mesh3d.push_vertex(data, 0.0, height, hw, 1.0, 0.0, 0.0, 1.0, 0.0)
  @mesh3d.push_vertex(data, 0.0, height, -hw, 1.0, 0.0, 0.0, 0.0, 0.0)
  @mesh3d.push_quad(indices, 4)
  @mesh3d.Mesh3D::new(data, indices)
}

