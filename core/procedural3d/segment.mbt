///|
/// Capped tapered segment between arbitrary points; suitable for limbs and props.
pub fn RigidGeometry::segment(
  self : RigidGeometry,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  radius_a : Double,
  radius_b : Double,
  sides : Int,
  bone : Int,
) -> Unit {
  let delta = b.sub(a)
  if delta.length() < 0.000001 || sides < 3 {
    return
  }
  let axis = delta.normalize()
  let reference = if axis.z.abs() > 0.9 {
    @math3d.Vec3::unit_x()
  } else {
    @math3d.Vec3::unit_z()
  }
  let right = axis.cross(reference).normalize()
  let front = axis.cross(right).normalize()
  fn point(center : @math3d.Vec3, radius : Double, i : Int) -> @math3d.Vec3 {
    let angle = i.to_double() * @math.PI * 2.0 / sides.to_double()
    center
    .add(right.scale(@math.cos(angle) * radius))
    .add(front.scale(@math.sin(angle) * radius))
  }
  for i in 0..<sides {
    let a0 = point(a, radius_a, i)
    let a1 = point(a, radius_a, i + 1)
    let b0 = point(b, radius_b, i)
    let b1 = point(b, radius_b, i + 1)
    self.quad(a0, a1, b1, b0, bone)
    self.triangle(a, a1, a0, bone)
    self.triangle(b, b0, b1, bone)
  }
}
