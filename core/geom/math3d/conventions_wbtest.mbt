// Pins the conventions stated in the package doc and in
// docs/architecture/coordinates.md. If one of these fails, the docs are wrong
// for every caller, not just this test.

///|
fn near_vec(a : Vec3, b : Vec3) -> Bool {
  approx(a.x, b.x) && approx(a.y, b.y) && approx(a.z, b.z)
}

///|
fn point_through(m : Mat4, p : Vec3) -> Vec3 {
  let r = m.mul_vec4(Vec4::new(p.x, p.y, p.z, 1.0))
  Vec3::new(r.x / r.w, r.y / r.w, r.z / r.w)
}

///|
test "right-handed: positive angles turn counterclockwise seen from the axis tip" {
  let x = Vec3::unit_x()
  let y = Vec3::unit_y()
  let z = Vec3::unit_z()
  assert_true(near_vec(x.cross(y), z))
  let quarter = pi / 2.0
  assert_true(
    near_vec(Quaternion::from_axis_angle(z, quarter).rotate_vec3(x), y),
  )
  assert_true(
    near_vec(
      Quaternion::from_axis_angle(y, quarter).rotate_vec3(x),
      z.scale(-1.0),
    ),
  )
  assert_true(
    near_vec(Quaternion::from_axis_angle(x, quarter).rotate_vec3(y), z),
  )
  assert_true(near_vec(point_through(Mat4::rotation_z(quarter), x), y))
}

///|
test "quaternion components are (x, y, z, w) with w last" {
  let q = Quaternion::new(0.0, 0.0, 0.0, 1.0)
  assert_true(q.approx_eq(Quaternion::identity(), 1.0e-12))
  assert_true(
    near_vec(q.rotate_vec3(Vec3::new(1.0, 2.0, 3.0)), Vec3::new(1.0, 2.0, 3.0)),
  )
}

///|
test "multiply applies the right-hand operand first; then reads in order" {
  let turn_z = Quaternion::from_axis_angle(Vec3::unit_z(), pi / 2.0)
  let turn_x = Quaternion::from_axis_angle(Vec3::unit_x(), pi / 2.0)
  let v = Vec3::unit_y()
  // multiply: turn_x first, then turn_z.
  let product = turn_z.multiply(turn_x).rotate_vec3(v)
  assert_true(near_vec(product, turn_z.rotate_vec3(turn_x.rotate_vec3(v))))
  // then: turn_z first, then turn_x.
  let chained = turn_z.then(turn_x).rotate_vec3(v)
  assert_true(near_vec(chained, turn_x.rotate_vec3(turn_z.rotate_vec3(v))))
  // The order matters: +Y -> +Z -> +Z, versus +Y -> -X -> -X.
  assert_true(near_vec(product, Vec3::unit_z()))
  assert_true(near_vec(chained, Vec3::unit_x().scale(-1.0)))
}

///|
test "Mat4 then composes in application order" {
  let move_x = Mat4::translation(1.0, 0.0, 0.0)
  let turn = Mat4::rotation_z(pi / 2.0)
  assert_true(
    near_vec(point_through(move_x.then(turn), Vec3::zero()), Vec3::unit_y()),
  )
  assert_true(move_x.then(turn).approx_eq(turn.multiply(move_x), 1.0e-12))
  assert_true(
    near_vec(point_through(turn.then(move_x), Vec3::zero()), Vec3::unit_x()),
  )
}

///|
test "from_euler applies roll, then yaw, then pitch" {
  let (pitch, yaw, roll) = (0.3, 0.7, -0.4)
  let q = Quaternion::from_euler(pitch~, yaw~, roll~)
  let expected = Quaternion::from_axis_angle(Vec3::unit_z(), roll)
    .then(Quaternion::from_axis_angle(Vec3::unit_y(), yaw))
    .then(Quaternion::from_axis_angle(Vec3::unit_x(), pitch))
  let v = Vec3::new(0.2, -1.0, 0.5)
  assert_true(near_vec(q.rotate_vec3(v), expected.rotate_vec3(v)))
}

///|
test "look_at and perspective are right-handed with the camera looking down -Z" {
  let view = Mat4::look_at(
    Vec3::new(0.0, 0.0, 5.0),
    Vec3::zero(),
    Vec3::unit_y(),
  )
  assert_true(
    near_vec(point_through(view, Vec3::zero()), Vec3::new(0.0, 0.0, -5.0)),
  )
  assert_true(
    near_vec(point_through(view, Vec3::unit_x()), Vec3::new(1.0, 0.0, -5.0)),
  )
  assert_true(
    near_vec(point_through(view, Vec3::unit_y()), Vec3::new(0.0, 1.0, -5.0)),
  )
  let proj = Mat4::perspective(pi / 3.0, 1.0, 0.5, 100.0)
  assert_true(approx(point_through(proj, Vec3::new(0.0, 0.0, -0.5)).z, 0.0))
  assert_true(approx(point_through(proj, Vec3::new(0.0, 0.0, -100.0)).z, 1.0))
}
