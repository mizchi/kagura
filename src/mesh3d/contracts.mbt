///|
/// 3D mesh data with stride-8 vertex layout (px,py,pz, nx,ny,nz, u,v).

///|
pub let vertex3d_stride : Int = 8

///|
pub struct Mesh3D {
  vertex_data : Array[Double]
  indices : Array[Int]
} derive(Show)

///|
pub fn Mesh3D::new(vertex_data : Array[Double], indices : Array[Int]) -> Mesh3D {
  { vertex_data, indices }
}

///|
pub fn Mesh3D::vertex_count(self : Mesh3D) -> Int {
  self.vertex_data.length() / vertex3d_stride
}

///|
pub fn Mesh3D::triangle_count(self : Mesh3D) -> Int {
  self.indices.length() / 3
}

///|
fn push_vertex(
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
/// Unit cube centered at origin with side length `size`.
pub fn Mesh3D::cube(size : Double) -> Mesh3D {
  let h = size / 2.0
  let data : Array[Double] = []
  let indices : Array[Int] = []
  let mut base = 0
  // +Z face (front)
  push_vertex(data, -h, -h, h, 0.0, 0.0, 1.0, 0.0, 1.0)
  push_vertex(data, h, -h, h, 0.0, 0.0, 1.0, 1.0, 1.0)
  push_vertex(data, h, h, h, 0.0, 0.0, 1.0, 1.0, 0.0)
  push_vertex(data, -h, h, h, 0.0, 0.0, 1.0, 0.0, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base + 0)
  base = base + 4
  // -Z face (back)
  push_vertex(data, h, -h, -h, 0.0, 0.0, -1.0, 0.0, 1.0)
  push_vertex(data, -h, -h, -h, 0.0, 0.0, -1.0, 1.0, 1.0)
  push_vertex(data, -h, h, -h, 0.0, 0.0, -1.0, 1.0, 0.0)
  push_vertex(data, h, h, -h, 0.0, 0.0, -1.0, 0.0, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base + 0)
  base = base + 4
  // +X face (right)
  push_vertex(data, h, -h, h, 1.0, 0.0, 0.0, 0.0, 1.0)
  push_vertex(data, h, -h, -h, 1.0, 0.0, 0.0, 1.0, 1.0)
  push_vertex(data, h, h, -h, 1.0, 0.0, 0.0, 1.0, 0.0)
  push_vertex(data, h, h, h, 1.0, 0.0, 0.0, 0.0, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base + 0)
  base = base + 4
  // -X face (left)
  push_vertex(data, -h, -h, -h, -1.0, 0.0, 0.0, 0.0, 1.0)
  push_vertex(data, -h, -h, h, -1.0, 0.0, 0.0, 1.0, 1.0)
  push_vertex(data, -h, h, h, -1.0, 0.0, 0.0, 1.0, 0.0)
  push_vertex(data, -h, h, -h, -1.0, 0.0, 0.0, 0.0, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base + 0)
  base = base + 4
  // +Y face (top)
  push_vertex(data, -h, h, h, 0.0, 1.0, 0.0, 0.0, 1.0)
  push_vertex(data, h, h, h, 0.0, 1.0, 0.0, 1.0, 1.0)
  push_vertex(data, h, h, -h, 0.0, 1.0, 0.0, 1.0, 0.0)
  push_vertex(data, -h, h, -h, 0.0, 1.0, 0.0, 0.0, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base + 0)
  base = base + 4
  // -Y face (bottom)
  push_vertex(data, -h, -h, -h, 0.0, -1.0, 0.0, 0.0, 1.0)
  push_vertex(data, h, -h, -h, 0.0, -1.0, 0.0, 1.0, 1.0)
  push_vertex(data, h, -h, h, 0.0, -1.0, 0.0, 1.0, 0.0)
  push_vertex(data, -h, -h, h, 0.0, -1.0, 0.0, 0.0, 0.0)
  indices.push(base + 0)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base + 0)
  { vertex_data: data, indices }
}

///|
/// XZ plane centered at origin with given width and depth.
pub fn Mesh3D::plane(
  width : Double,
  depth : Double,
  subdivisions~ : Int = 4,
) -> Mesh3D {
  let hw = width / 2.0
  let hd = depth / 2.0
  let n = subdivisions
  let data : Array[Double] = []
  let indices : Array[Int] = []
  // Generate (n+1)×(n+1) grid of vertices
  for row in 0..=n {
    let t = row.to_double() / n.to_double()
    let z = -hd + t * depth
    let v = t
    for col in 0..=n {
      let s = col.to_double() / n.to_double()
      let x = -hw + s * width
      let u = s
      push_vertex(data, x, 0.0, z, 0.0, 1.0, 0.0, u, v)
    }
  }
  // Generate triangles (CCW winding when viewed from above: +Y direction)
  let cols = n + 1
  for row in 0..<n {
    for col in 0..<n {
      let tl = row * cols + col
      let tr = tl + 1
      let bl = tl + cols
      let br = bl + 1
      // Triangle 1: tl, bl, tr (CCW from above)
      indices.push(tl)
      indices.push(bl)
      indices.push(tr)
      // Triangle 2: tr, bl, br (CCW from above)
      indices.push(tr)
      indices.push(bl)
      indices.push(br)
    }
  }
  { vertex_data: data, indices }
}

///|
/// UV sphere with given radius, number of horizontal segments, and vertical rings.
pub fn Mesh3D::sphere(radius : Double, segments : Int, rings : Int) -> Mesh3D {
  let data : Array[Double] = []
  let indices : Array[Int] = []
  for ring in 0..<=rings {
    let phi = @math.PI * ring.to_double() / rings.to_double()
    let sin_phi = @math.sin(phi)
    let cos_phi = @math.cos(phi)
    for seg in 0..<=segments {
      let theta = 2.0 * @math.PI * seg.to_double() / segments.to_double()
      let sin_theta = @math.sin(theta)
      let cos_theta = @math.cos(theta)
      let nx = cos_theta * sin_phi
      let ny = cos_phi
      let nz = sin_theta * sin_phi
      let u = seg.to_double() / segments.to_double()
      let v = ring.to_double() / rings.to_double()
      push_vertex(data, radius * nx, radius * ny, radius * nz, nx, ny, nz, u, v)
    }
  }
  let cols = segments + 1
  for ring in 0..<rings {
    for seg in 0..<segments {
      let curr = ring * cols + seg
      let next = curr + cols
      indices.push(curr)
      indices.push(next)
      indices.push(curr + 1)
      indices.push(curr + 1)
      indices.push(next)
      indices.push(next + 1)
    }
  }
  { vertex_data: data, indices }
}
