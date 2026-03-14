// Pre-built 3D meshes (environment + items only; characters use skeletal models)

///|
fn Meshes3D::new() -> Meshes3D {
  {
    item: @mesh3d.Mesh3D::sphere(0.2, 5, 3),
    projectile: @mesh3d.Mesh3D::sphere(0.15, 4, 3),
    arrow: make_arrow_mesh(0.5, 0.04),
    floor_tile: @mesh3d.Mesh3D::plane(1.0, 1.0),
    wall: make_wall_mesh(1.0, 1.2, 1.0),
    wall_low: make_wall_mesh(1.0, 0.8, 1.0),
    wall_tall: make_wall_mesh(1.0, 1.8, 1.0),
    ledge: make_wall_mesh(1.0, 0.2, 1.0),
    pillar: make_pillar_mesh(0.15, 1.5),
    debris: make_wall_mesh(0.2, 0.08, 0.2),
    crate: make_wall_mesh(0.35, 0.3, 0.35),
  }
}

// Custom wall mesh: a box with specified dimensions, bottom at y=0

///|
fn make_wall_mesh(
  width : Double,
  height : Double,
  depth : Double,
) -> @mesh3d.Mesh3D {
  let hw = width / 2.0
  let hd = depth / 2.0
  let data : Array[Double] = []
  let indices : Array[Int] = []
  let mut base = 0
  // +Z face (front)
  push_vert(data, -hw, 0.0, hd, 0.0, 0.0, 1.0, 0.0, 1.0)
  push_vert(data, hw, 0.0, hd, 0.0, 0.0, 1.0, 1.0, 1.0)
  push_vert(data, hw, height, hd, 0.0, 0.0, 1.0, 1.0, 0.0)
  push_vert(data, -hw, height, hd, 0.0, 0.0, 1.0, 0.0, 0.0)
  push_quad(indices, base)
  base = base + 4
  // -Z face (back)
  push_vert(data, hw, 0.0, -hd, 0.0, 0.0, -1.0, 0.0, 1.0)
  push_vert(data, -hw, 0.0, -hd, 0.0, 0.0, -1.0, 1.0, 1.0)
  push_vert(data, -hw, height, -hd, 0.0, 0.0, -1.0, 1.0, 0.0)
  push_vert(data, hw, height, -hd, 0.0, 0.0, -1.0, 0.0, 0.0)
  push_quad(indices, base)
  base = base + 4
  // +X face (right)
  push_vert(data, hw, 0.0, hd, 1.0, 0.0, 0.0, 0.0, 1.0)
  push_vert(data, hw, 0.0, -hd, 1.0, 0.0, 0.0, 1.0, 1.0)
  push_vert(data, hw, height, -hd, 1.0, 0.0, 0.0, 1.0, 0.0)
  push_vert(data, hw, height, hd, 1.0, 0.0, 0.0, 0.0, 0.0)
  push_quad(indices, base)
  base = base + 4
  // -X face (left)
  push_vert(data, -hw, 0.0, -hd, -1.0, 0.0, 0.0, 0.0, 1.0)
  push_vert(data, -hw, 0.0, hd, -1.0, 0.0, 0.0, 1.0, 1.0)
  push_vert(data, -hw, height, hd, -1.0, 0.0, 0.0, 1.0, 0.0)
  push_vert(data, -hw, height, -hd, -1.0, 0.0, 0.0, 0.0, 0.0)
  push_quad(indices, base)
  base = base + 4
  // +Y face (top)
  push_vert(data, -hw, height, hd, 0.0, 1.0, 0.0, 0.0, 1.0)
  push_vert(data, hw, height, hd, 0.0, 1.0, 0.0, 1.0, 1.0)
  push_vert(data, hw, height, -hd, 0.0, 1.0, 0.0, 1.0, 0.0)
  push_vert(data, -hw, height, -hd, 0.0, 1.0, 0.0, 0.0, 0.0)
  push_quad(indices, base)
  @mesh3d.Mesh3D::new(data, indices)
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
  // Tip (+X)
  // Top face: tip, left-back, right-back
  push_vert(data, hl, 0.0, 0.0, 0.0, 1.0, 0.0, 0.5, 0.0)
  push_vert(data, -hl, t, -t, 0.0, 1.0, 0.0, 0.0, 1.0)
  push_vert(data, -hl, t, t, 0.0, 1.0, 0.0, 1.0, 1.0)
  indices.push(0)
  indices.push(1)
  indices.push(2)
  // Bottom face
  push_vert(data, hl, 0.0, 0.0, 0.0, -1.0, 0.0, 0.5, 0.0)
  push_vert(data, -hl, -t, t, 0.0, -1.0, 0.0, 0.0, 1.0)
  push_vert(data, -hl, -t, -t, 0.0, -1.0, 0.0, 1.0, 1.0)
  indices.push(3)
  indices.push(4)
  indices.push(5)
  // Right face (+Z)
  push_vert(data, hl, 0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0.0)
  push_vert(data, -hl, t, t, 0.0, 0.0, 1.0, 0.0, 1.0)
  push_vert(data, -hl, -t, t, 0.0, 0.0, 1.0, 1.0, 1.0)
  indices.push(6)
  indices.push(7)
  indices.push(8)
  // Left face (-Z)
  push_vert(data, hl, 0.0, 0.0, 0.0, 0.0, -1.0, 0.5, 0.0)
  push_vert(data, -hl, -t, -t, 0.0, 0.0, -1.0, 0.0, 1.0)
  push_vert(data, -hl, t, -t, 0.0, 0.0, -1.0, 1.0, 1.0)
  indices.push(9)
  indices.push(10)
  indices.push(11)
  @mesh3d.Mesh3D::new(data, indices)
}

///|
fn push_vert(
  data : Array[Double],
  px : Double,
  py : Double,
  pz : Double,
  nx : Double,
  ny : Double,
  nz : Double,
  u : Double,
  v : Double,
) -> Unit {
  data.push(px)
  data.push(py)
  data.push(pz)
  data.push(nx)
  data.push(ny)
  data.push(nz)
  data.push(u)
  data.push(v)
}

///|
fn push_quad(indices : Array[Int], base : Int) -> Unit {
  indices.push(base)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base)
}
