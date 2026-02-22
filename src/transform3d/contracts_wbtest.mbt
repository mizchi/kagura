///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-4
}

///|
fn vec3_approx(a : @math3d.Vec3, b : @math3d.Vec3) -> Bool {
  a.approx_eq(b, 1.0e-4)
}

///|
test "Transform3D::new is identity" {
  let t = Transform3D::new()
  assert_true(vec3_approx(t.position, @math3d.Vec3::zero()))
  assert_true(t.rotation.approx_eq(@math3d.Quaternion::identity(), 1.0e-6))
  assert_true(vec3_approx(t.scale, @math3d.Vec3::one()))
}

///|
test "to_mat4 identity transform" {
  let t = Transform3D::new()
  let m = t.to_mat4()
  assert_true(m.approx_eq(@math3d.Mat4::identity(), 1.0e-6))
}

///|
test "to_mat4 translation only" {
  let t = Transform3D::from_position(@math3d.Vec3::new(3.0, 4.0, 5.0))
  let m = t.to_mat4()
  let expected = @math3d.Mat4::translation(3.0, 4.0, 5.0)
  assert_true(m.approx_eq(expected, 1.0e-6))
}

///|
test "to_mat4 scale only" {
  let t = Transform3D::new().with_scale(@math3d.Vec3::new(2.0, 3.0, 4.0))
  let m = t.to_mat4()
  let expected = @math3d.Mat4::scaling(2.0, 3.0, 4.0)
  assert_true(m.approx_eq(expected, 1.0e-6))
}

///|
test "to_mat4 rotation only" {
  let pi = 3.14159265358979
  let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), pi / 2.0)
  let t = Transform3D::new().with_rotation(q)
  let m = t.to_mat4()
  let expected = @math3d.Mat4::rotation_y(pi / 2.0)
  assert_true(m.approx_eq(expected, 1.0e-4))
}

///|
test "to_mat4 TRS composition" {
  let pos = @math3d.Vec3::new(1.0, 2.0, 3.0)
  let pi = 3.14159265358979
  let rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_z(),
    pi / 4.0,
  )
  let sc = @math3d.Vec3::new(2.0, 2.0, 2.0)
  let t = Transform3D::from_components(pos, rot, sc)
  let m = t.to_mat4()
  // Verify by composing T * R * S manually
  let mt = @math3d.Mat4::translation(1.0, 2.0, 3.0)
  let mr = @math3d.Mat4::rotation_z(pi / 4.0)
  let ms = @math3d.Mat4::scaling(2.0, 2.0, 2.0)
  let expected = mt.multiply(mr).multiply(ms)
  assert_true(m.approx_eq(expected, 1.0e-4))
}

///|
test "with_position/rotation/scale" {
  let t = Transform3D::new()
  let t2 = t.with_position(@math3d.Vec3::new(1.0, 0.0, 0.0))
  assert_true(approx(t2.position.x, 1.0))
  let t3 = t2.with_scale(@math3d.Vec3::new(3.0, 3.0, 3.0))
  assert_true(approx(t3.scale.x, 3.0))
  // Original unchanged
  assert_true(approx(t.position.x, 0.0))
}

///|
test "translate" {
  let t = Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0))
  let t2 = t.translate(@math3d.Vec3::new(2.0, 3.0, 0.0))
  assert_true(approx(t2.position.x, 3.0))
  assert_true(approx(t2.position.y, 3.0))
}

///|
test "scale_by" {
  let t = Transform3D::new().with_scale(@math3d.Vec3::new(2.0, 2.0, 2.0))
  let t2 = t.scale_by(@math3d.Vec3::new(3.0, 1.0, 1.0))
  assert_true(approx(t2.scale.x, 6.0))
  assert_true(approx(t2.scale.y, 2.0))
}

///|
test "forward/right/up identity" {
  let t = Transform3D::new()
  assert_true(vec3_approx(t.forward(), @math3d.Vec3::new(0.0, 0.0, -1.0)))
  assert_true(vec3_approx(t.right(), @math3d.Vec3::new(1.0, 0.0, 0.0)))
  assert_true(vec3_approx(t.up(), @math3d.Vec3::new(0.0, 1.0, 0.0)))
}

///|
test "forward after 90deg Y rotation" {
  let pi = 3.14159265358979
  let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), pi / 2.0)
  let t = Transform3D::new().with_rotation(q)
  // After 90deg Y rotation, forward (-Z) should become (-X)
  assert_true(vec3_approx(t.forward(), @math3d.Vec3::new(-1.0, 0.0, 0.0)))
}

///|
test "look_at" {
  let t = Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 5.0))
  let t2 = t.look_at(@math3d.Vec3::zero(), @math3d.Vec3::unit_y())
  // After looking at origin from (0,0,5), forward should be (0,0,-1)
  let fwd = t2.forward()
  assert_true(vec3_approx(fwd, @math3d.Vec3::new(0.0, 0.0, -1.0)))
}

///|
test "look_at sideways" {
  let t = Transform3D::from_position(@math3d.Vec3::zero())
  let t2 = t.look_at(@math3d.Vec3::new(1.0, 0.0, 0.0), @math3d.Vec3::unit_y())
  let fwd = t2.forward()
  assert_true(vec3_approx(fwd, @math3d.Vec3::new(1.0, 0.0, 0.0)))
}

///|
test "rotate applies additional rotation" {
  let pi = 3.14159265358979
  let q1 = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), pi / 2.0)
  let q2 = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), pi / 2.0)
  let t = Transform3D::new().with_rotation(q1).rotate(q2)
  // Two 90deg Y rotations = 180deg
  let fwd = t.forward()
  assert_true(vec3_approx(fwd, @math3d.Vec3::new(0.0, 0.0, 1.0)))
}
