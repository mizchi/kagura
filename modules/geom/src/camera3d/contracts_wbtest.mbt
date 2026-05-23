///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
let pi : Double = 3.14159265358979323846

///|
test "Camera3D new_perspective" {
  let cam = Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 5.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    pi / 4.0,
    16.0 / 9.0,
    0.1,
    100.0,
  )
  assert_true(approx(cam.position.x, 0.0))
  assert_true(approx(cam.position.z, 5.0))
  assert_true(approx(cam.fov_y_rad, pi / 4.0))
}

///|
test "Camera3D new_orthographic" {
  let cam = Camera3D::new_orthographic(
    @math3d.Vec3::new(0.0, 10.0, 0.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_z(),
    -10.0,
    10.0,
    -10.0,
    10.0,
    0.1,
    100.0,
  )
  assert_true(approx(cam.position.y, 10.0))
  assert_true(approx(cam.near, 0.1))
}

///|
test "Camera3D view_matrix" {
  let cam = Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 5.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    pi / 4.0,
    1.0,
    0.1,
    100.0,
  )
  let view = cam.view_matrix()
  // Eye should map to origin in view space
  let eye_view = view.mul_vec4(@math3d.Vec4::new(0.0, 0.0, 5.0, 1.0))
  assert_true(approx(eye_view.x, 0.0))
  assert_true(approx(eye_view.y, 0.0))
  assert_true(approx(eye_view.z, 0.0))
}

///|
test "Camera3D projection_matrix perspective" {
  let cam = Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 5.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    pi / 4.0,
    16.0 / 9.0,
    0.1,
    100.0,
  )
  let proj = cam.projection_matrix()
  // element[11] should be -1 for perspective
  assert_true(approx(proj.elements[11], -1.0))
}

///|
test "Camera3D projection_matrix orthographic" {
  let cam = Camera3D::new_orthographic(
    @math3d.Vec3::new(0.0, 10.0, 0.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_z(),
    -10.0,
    10.0,
    -10.0,
    10.0,
    0.1,
    100.0,
  )
  let proj = cam.projection_matrix()
  // element[15] should be 1 for orthographic
  assert_true(approx(proj.elements[15], 1.0))
}

///|
test "Camera3D view_projection_matrix" {
  let cam = Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 5.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    pi / 4.0,
    1.0,
    0.1,
    100.0,
  )
  let vp = cam.view_projection_matrix()
  let expected = cam.projection_matrix().multiply(cam.view_matrix())
  assert_true(vp.approx_eq(expected, 1.0e-9))
}
