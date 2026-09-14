// Flat-shaded, rigidly skinned primitives for procedural characters and scenery.
// Buffers use the Mesh3D and SkinData layouts. A loft ring is (y, x radius, z radius).

///|
pub struct RigidGeometry {
  vertices : Array[Double]
  indices : Array[Int]
  joints : Array[Int]
  weights : Array[Double]
}

///|
pub fn RigidGeometry::new() -> RigidGeometry {
  { vertices: [], indices: [], joints: [], weights: [], }
}

///|
/// Append a geometry snapshot, preserving skin weights and offsetting indices.
/// Bone indices keep their meaning in the destination's skeleton.
pub fn RigidGeometry::append(
  self : RigidGeometry,
  source : RigidGeometry,
) -> Unit {
  let offset = self.vertices.length() / 8
  // Copy before appending so self-composition is finite and well-defined.
  let indices = source.indices.map(index => index + offset)
  let vertices = source.vertices.copy()
  let joints = source.joints.copy()
  let weights = source.weights.copy()
  self.vertices.append(vertices)
  self.indices.append(indices)
  self.joints.append(joints)
  self.weights.append(weights)
}

///|
pub fn RigidGeometry::triangle(
  self : RigidGeometry,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  c : @math3d.Vec3,
  bone : Int,
) -> Unit {
  let normal = b.sub(a).cross(c.sub(a)).normalize()
  for p in [a, b, c] {
    self.indices.push(self.vertices.length() / 8)
    @mesh3d.push_vertex(
      self.vertices,
      p.x,
      p.y,
      p.z,
      normal.x,
      normal.y,
      normal.z,
      0.0,
      0.0,
    )
    self.joints.append([bone, 0, 0, 0])
    self.weights.append([1.0, 0.0, 0.0, 0.0])
  }
}

///|
pub fn RigidGeometry::quad(
  self : RigidGeometry,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  c : @math3d.Vec3,
  d : @math3d.Vec3,
  bone : Int,
) -> Unit {
  self.triangle(a, b, c, bone)
  self.triangle(a, c, d, bone)
}

///|
pub fn RigidGeometry::box(
  self : RigidGeometry,
  x : Double,
  y : Double,
  z : Double,
  w : Double,
  h : Double,
  d : Double,
  bone : Int,
) -> Unit {
  let vc = Ref(self.vertices.length() / 8)
  append_box_segment(
    self.vertices,
    self.indices,
    self.joints,
    self.weights,
    vc,
    x - w / 2.0,
    y - h / 2.0,
    z - d / 2.0,
    x + w / 2.0,
    y + h / 2.0,
    z + d / 2.0,
    bone,
    bone,
  )
}

///|
pub fn RigidGeometry::loft(
  self : RigidGeometry,
  x : Double,
  z : Double,
  rings : Array[(Double, Double, Double)],
  sides : Int,
  bone : Int,
) -> Unit {
  if rings.length() < 2 || sides < 3 {
    return
  }
  fn point(ring : Int, side : Int) -> @math3d.Vec3 {
    let (y, rx, rz) = rings[ring]
    let a = side.to_double() * @math.PI * 2.0 / sides.to_double()
    @math3d.Vec3::new(x + @math.sin(a) * rx, y, z + @math.cos(a) * rz)
  }
  for ring in 1..<rings.length() {
    for side in 0..<sides {
      self.quad(
        point(ring - 1, side),
        point(ring - 1, side + 1),
        point(ring, side + 1),
        point(ring, side),
        bone,
      )
    }
  }
  let (bottom, _, _) = rings[0]
  let last = rings.length() - 1
  let (top, _, _) = rings[last]
  for side in 0..<sides {
    self.triangle(
      @math3d.Vec3::new(x, bottom, z),
      point(0, side + 1),
      point(0, side),
      bone,
    )
    self.triangle(
      @math3d.Vec3::new(x, top, z),
      point(last, side),
      point(last, side + 1),
      bone,
    )
  }
}

///|
/// Return an independent mesh snapshot with position/normal/UV vertex layout.
pub fn RigidGeometry::build_mesh(self : RigidGeometry) -> @mesh3d.Mesh3D {
  @mesh3d.Mesh3D::new(self.vertices.copy(), self.indices.copy())
}

///|
/// Four joints and weights per vertex; primitives use one rigid joint per vertex.
pub fn RigidGeometry::build_skin(self : RigidGeometry) -> @skeleton3d.SkinData {
  {
    joint_indices: self.joints.copy(),
    weights: self.weights.copy(),
    vertex_count: self.vertices.length() / 8,
  }
}
