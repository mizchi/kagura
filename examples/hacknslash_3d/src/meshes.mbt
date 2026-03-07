// Pre-built 3D meshes (environment + items only; characters use skeletal models)

fn Meshes3D::new() -> Meshes3D {
  {
    item: @mesh3d.Mesh3D::sphere(0.2, 5, 3),
    projectile: @mesh3d.Mesh3D::sphere(0.15, 4, 3),
    floor_tile: @mesh3d.Mesh3D::plane(1.0, 1.0),
    wall: make_wall_mesh(1.0, 1.5, 1.0), // width, height, depth — taller walls
    pillar: make_pillar_mesh(0.15, 2.0), // narrow tall pillar
  }
}

// Custom wall mesh: a box with specified dimensions, bottom at y=0
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
  push_vert(data, -hw, 0.0, hd, 0.0, 0.0, 1.0)
  push_vert(data, hw, 0.0, hd, 0.0, 0.0, 1.0)
  push_vert(data, hw, height, hd, 0.0, 0.0, 1.0)
  push_vert(data, -hw, height, hd, 0.0, 0.0, 1.0)
  push_quad(indices, base)
  base = base + 4
  // -Z face (back)
  push_vert(data, hw, 0.0, -hd, 0.0, 0.0, -1.0)
  push_vert(data, -hw, 0.0, -hd, 0.0, 0.0, -1.0)
  push_vert(data, -hw, height, -hd, 0.0, 0.0, -1.0)
  push_vert(data, hw, height, -hd, 0.0, 0.0, -1.0)
  push_quad(indices, base)
  base = base + 4
  // +X face (right)
  push_vert(data, hw, 0.0, hd, 1.0, 0.0, 0.0)
  push_vert(data, hw, 0.0, -hd, 1.0, 0.0, 0.0)
  push_vert(data, hw, height, -hd, 1.0, 0.0, 0.0)
  push_vert(data, hw, height, hd, 1.0, 0.0, 0.0)
  push_quad(indices, base)
  base = base + 4
  // -X face (left)
  push_vert(data, -hw, 0.0, -hd, -1.0, 0.0, 0.0)
  push_vert(data, -hw, 0.0, hd, -1.0, 0.0, 0.0)
  push_vert(data, -hw, height, hd, -1.0, 0.0, 0.0)
  push_vert(data, -hw, height, -hd, -1.0, 0.0, 0.0)
  push_quad(indices, base)
  base = base + 4
  // +Y face (top)
  push_vert(data, -hw, height, hd, 0.0, 1.0, 0.0)
  push_vert(data, hw, height, hd, 0.0, 1.0, 0.0)
  push_vert(data, hw, height, -hd, 0.0, 1.0, 0.0)
  push_vert(data, -hw, height, -hd, 0.0, 1.0, 0.0)
  push_quad(indices, base)
  @mesh3d.Mesh3D::new(data, indices)
}

// Pillar mesh: narrow tall box for decoration
fn make_pillar_mesh(
  radius : Double,
  height : Double,
) -> @mesh3d.Mesh3D {
  make_wall_mesh(radius * 2.0, height, radius * 2.0)
}

fn push_vert(
  data : Array[Double],
  px : Double,
  py : Double,
  pz : Double,
  nx : Double,
  ny : Double,
  nz : Double,
) -> Unit {
  data.push(px)
  data.push(py)
  data.push(pz)
  data.push(nx)
  data.push(ny)
  data.push(nz)
  data.push(0.0) // u
  data.push(0.0) // v
}

fn push_quad(indices : Array[Int], base : Int) -> Unit {
  indices.push(base)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base)
}
