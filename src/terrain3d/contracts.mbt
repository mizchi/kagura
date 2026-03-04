///|
/// Convert a Grid2D to a 3D mesh for visualization.
/// Each walkable tile becomes a floor quad, each wall becomes a raised block.
pub fn grid_to_mesh3d(
  grid : @terrain.Grid2D,
  tile_size~ : Double = 1.0,
  wall_height~ : Double = 1.0,
) -> @mesh3d.Mesh3D {
  let vdata : Array[Double] = []
  let indices : Array[Int] = []
  let mut vi = 0
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let tile = grid.get(x, y)
      let fx = x.to_double() * tile_size
      let fz = y.to_double() * tile_size
      match tile {
        Wall => {
          vi = add_box(
            vdata, indices, vi, fx, 0.0, fz, tile_size, wall_height, tile_size,
          )
        }
        Door => {
          // Half-height block
          let h = wall_height * 0.5
          vi = add_box(vdata, indices, vi, fx, 0.0, fz, tile_size, h, tile_size)
        }
        Water => {
          // Low floor
          vi = add_floor_quad(
            vdata, indices, vi, fx, -0.1, fz, tile_size,
          )
        }
        Empty => ()
        _ => {
          // Floor/Corridor/Start/Goal/etc: floor quad at y=0
          vi = add_floor_quad(vdata, indices, vi, fx, 0.0, fz, tile_size)
        }
      }
    }
  }
  @mesh3d.Mesh3D::new(vdata, indices)
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
/// Add a floor quad (2 triangles) at the given position facing up (+Y).
fn add_floor_quad(
  vdata : Array[Double],
  indices : Array[Int],
  vi : Int,
  x : Double,
  y : Double,
  z : Double,
  size : Double,
) -> Int {
  let x1 = x + size
  let z1 = z + size
  // Normal: up (+Y)
  push_vert(vdata, x, y, z, 0.0, 1.0, 0.0, 0.0, 0.0)
  push_vert(vdata, x1, y, z, 0.0, 1.0, 0.0, 1.0, 0.0)
  push_vert(vdata, x1, y, z1, 0.0, 1.0, 0.0, 1.0, 1.0)
  push_vert(vdata, x, y, z1, 0.0, 1.0, 0.0, 0.0, 1.0)
  indices.push(vi)
  indices.push(vi + 1)
  indices.push(vi + 2)
  indices.push(vi)
  indices.push(vi + 2)
  indices.push(vi + 3)
  vi + 4
}

///|
/// Add a box (6 faces, 24 vertices) at the given position.
fn add_box(
  vdata : Array[Double],
  indices : Array[Int],
  vi : Int,
  x : Double,
  y : Double,
  z : Double,
  sx : Double,
  sy : Double,
  sz : Double,
) -> Int {
  let x1 = x + sx
  let y1 = y + sy
  let z1 = z + sz
  let mut v = vi
  // Top face (+Y)
  push_vert(vdata, x, y1, z, 0.0, 1.0, 0.0, 0.0, 0.0)
  push_vert(vdata, x1, y1, z, 0.0, 1.0, 0.0, 1.0, 0.0)
  push_vert(vdata, x1, y1, z1, 0.0, 1.0, 0.0, 1.0, 1.0)
  push_vert(vdata, x, y1, z1, 0.0, 1.0, 0.0, 0.0, 1.0)
  indices.push(v)
  indices.push(v + 1)
  indices.push(v + 2)
  indices.push(v)
  indices.push(v + 2)
  indices.push(v + 3)
  v = v + 4
  // Bottom face (-Y)
  push_vert(vdata, x, y, z1, 0.0, -1.0, 0.0, 0.0, 0.0)
  push_vert(vdata, x1, y, z1, 0.0, -1.0, 0.0, 1.0, 0.0)
  push_vert(vdata, x1, y, z, 0.0, -1.0, 0.0, 1.0, 1.0)
  push_vert(vdata, x, y, z, 0.0, -1.0, 0.0, 0.0, 1.0)
  indices.push(v)
  indices.push(v + 1)
  indices.push(v + 2)
  indices.push(v)
  indices.push(v + 2)
  indices.push(v + 3)
  v = v + 4
  // Front face (+Z)
  push_vert(vdata, x, y, z1, 0.0, 0.0, 1.0, 0.0, 1.0)
  push_vert(vdata, x1, y, z1, 0.0, 0.0, 1.0, 1.0, 1.0)
  push_vert(vdata, x1, y1, z1, 0.0, 0.0, 1.0, 1.0, 0.0)
  push_vert(vdata, x, y1, z1, 0.0, 0.0, 1.0, 0.0, 0.0)
  indices.push(v)
  indices.push(v + 1)
  indices.push(v + 2)
  indices.push(v)
  indices.push(v + 2)
  indices.push(v + 3)
  v = v + 4
  // Back face (-Z)
  push_vert(vdata, x1, y, z, 0.0, 0.0, -1.0, 0.0, 1.0)
  push_vert(vdata, x, y, z, 0.0, 0.0, -1.0, 1.0, 1.0)
  push_vert(vdata, x, y1, z, 0.0, 0.0, -1.0, 1.0, 0.0)
  push_vert(vdata, x1, y1, z, 0.0, 0.0, -1.0, 0.0, 0.0)
  indices.push(v)
  indices.push(v + 1)
  indices.push(v + 2)
  indices.push(v)
  indices.push(v + 2)
  indices.push(v + 3)
  v = v + 4
  // Right face (+X)
  push_vert(vdata, x1, y, z, 1.0, 0.0, 0.0, 0.0, 1.0)
  push_vert(vdata, x1, y, z1, 1.0, 0.0, 0.0, 1.0, 1.0)
  push_vert(vdata, x1, y1, z1, 1.0, 0.0, 0.0, 1.0, 0.0)
  push_vert(vdata, x1, y1, z, 1.0, 0.0, 0.0, 0.0, 0.0)
  indices.push(v)
  indices.push(v + 1)
  indices.push(v + 2)
  indices.push(v)
  indices.push(v + 2)
  indices.push(v + 3)
  v = v + 4
  // Left face (-X)
  push_vert(vdata, x, y, z1, -1.0, 0.0, 0.0, 0.0, 1.0)
  push_vert(vdata, x, y, z, -1.0, 0.0, 0.0, 1.0, 1.0)
  push_vert(vdata, x, y1, z, -1.0, 0.0, 0.0, 1.0, 0.0)
  push_vert(vdata, x, y1, z1, -1.0, 0.0, 0.0, 0.0, 0.0)
  indices.push(v)
  indices.push(v + 1)
  indices.push(v + 2)
  indices.push(v)
  indices.push(v + 2)
  indices.push(v + 3)
  v = v + 4
  v
}
