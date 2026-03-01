///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-4
}

///|
fn decode(bits : Int) -> Double {
  @gfx.f32_bits_to_double(bits)
}

///|
test "DirectionalLight::default" {
  let d = DirectionalLight::default()
  assert_true(approx(d.direction.y, -1.0))
  assert_true(approx(d.intensity, 1.0))
}

///|
test "AmbientLight::default" {
  let a = AmbientLight::default()
  assert_true(approx(a.intensity, 0.2))
}

///|
test "LightingEnvironment::default" {
  let env = LightingEnvironment::default()
  assert_true(approx(env.directional.intensity, 1.0))
  assert_true(approx(env.ambient.intensity, 0.2))
}

///|
test "light_uniform_dwords layout" {
  let dir = DirectionalLight::new(
    @math3d.Vec3::new(0.0, -1.0, 0.0),
    @math3d.Vec3::new(1.0, 0.9, 0.8),
    2.0,
  )
  let amb = AmbientLight::new(@math3d.Vec3::new(0.3, 0.3, 0.4), 0.5)
  let env = LightingEnvironment::new(dir, amb)
  let dw = light_uniform_dwords(env)
  assert_eq(dw.length(), 12)
  // Direction
  assert_true(approx(decode(dw[0]), 0.0))
  assert_true(approx(decode(dw[1]), -1.0))
  assert_true(approx(decode(dw[2]), 0.0))
  assert_true(approx(decode(dw[3]), 0.0)) // padding
  // Color * intensity
  assert_true(approx(decode(dw[4]), 2.0)) // 1.0 * 2.0
  assert_true(approx(decode(dw[5]), 1.8)) // 0.9 * 2.0
  assert_true(approx(decode(dw[6]), 1.6)) // 0.8 * 2.0
  assert_true(approx(decode(dw[7]), 2.0)) // intensity
  // Ambient
  assert_true(approx(decode(dw[8]), 0.15)) // 0.3 * 0.5
  assert_true(approx(decode(dw[9]), 0.15)) // 0.3 * 0.5
  assert_true(approx(decode(dw[10]), 0.2)) // 0.4 * 0.5
  assert_true(approx(decode(dw[11]), 0.5)) // ambient intensity
}

///|
test "normal_matrix_uniform_dwords identity" {
  let model = @math3d.Mat4::identity()
  let dw = normal_matrix_uniform_dwords(model)
  assert_eq(dw.length(), 12)
  // Column 0: (1, 0, 0, 0)
  assert_true(approx(decode(dw[0]), 1.0))
  assert_true(approx(decode(dw[1]), 0.0))
  assert_true(approx(decode(dw[2]), 0.0))
  assert_true(approx(decode(dw[3]), 0.0))
  // Column 1: (0, 1, 0, 0)
  assert_true(approx(decode(dw[4]), 0.0))
  assert_true(approx(decode(dw[5]), 1.0))
  assert_true(approx(decode(dw[6]), 0.0))
  assert_true(approx(decode(dw[7]), 0.0))
  // Column 2: (0, 0, 1, 0)
  assert_true(approx(decode(dw[8]), 0.0))
  assert_true(approx(decode(dw[9]), 0.0))
  assert_true(approx(decode(dw[10]), 1.0))
  assert_true(approx(decode(dw[11]), 0.0))
}

///|
test "normal_matrix_uniform_dwords with uniform scale" {
  // For uniform scale, normal matrix = identity (inverse-transpose of scale cancels)
  let model = @math3d.Mat4::scaling(3.0, 3.0, 3.0)
  let dw = normal_matrix_uniform_dwords(model)
  // Normal matrix should be (1/3)*I (inverse-transpose of 3I = (1/3)*I)
  assert_true(approx(decode(dw[0]), 1.0 / 3.0))
  assert_true(approx(decode(dw[5]), 1.0 / 3.0))
  assert_true(approx(decode(dw[10]), 1.0 / 3.0))
}

///|
test "normal_matrix_uniform_dwords with non-uniform scale" {
  let model = @math3d.Mat4::scaling(2.0, 1.0, 1.0)
  let dw = normal_matrix_uniform_dwords(model)
  // inverse-transpose of diag(2,1,1) = diag(1/2, 1, 1)
  assert_true(approx(decode(dw[0]), 0.5))
  assert_true(approx(decode(dw[5]), 1.0))
  assert_true(approx(decode(dw[10]), 1.0))
}

///|
test "PointLight::new stores fields correctly" {
  let p = PointLight::new(
    @math3d.Vec3::new(1.0, 2.0, 3.0),
    @math3d.Vec3::new(1.0, 0.5, 0.0),
    2.0,
    10.0,
  )
  assert_true(approx(p.position.x, 1.0))
  assert_true(approx(p.position.y, 2.0))
  assert_true(approx(p.position.z, 3.0))
  assert_true(approx(p.intensity, 2.0))
  assert_true(approx(p.radius, 10.0))
}

///|
test "SpotLight::new normalizes direction" {
  let s = SpotLight::new(
    @math3d.Vec3::new(0.0, 5.0, 0.0),
    @math3d.Vec3::new(0.0, -2.0, 0.0),
    @math3d.Vec3::one(),
    1.0,
    10.0,
    0.3,
    0.5,
  )
  assert_true(approx(s.direction.x, 0.0))
  assert_true(approx(s.direction.y, -1.0))
  assert_true(approx(s.direction.z, 0.0))
  assert_true(approx(s.inner_angle, 0.3))
  assert_true(approx(s.outer_angle, 0.5))
}

///|
test "LightingEnvironment backward compat (no point/spot)" {
  let env = LightingEnvironment::new(
    DirectionalLight::default(),
    AmbientLight::default(),
  )
  assert_true(approx(env.directional.intensity, 1.0))
  assert_true(approx(env.ambient.intensity, 0.2))
  assert_eq(env.point_lights.length(), 0)
  assert_eq(env.spot_lights.length(), 0)
}

///|
test "LightingEnvironment with point_lights and spot_lights" {
  let pl = PointLight::new(
    @math3d.Vec3::zero(),
    @math3d.Vec3::one(),
    1.0,
    5.0,
  )
  let sl = SpotLight::new(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, -1.0, 0.0),
    @math3d.Vec3::one(),
    1.0,
    10.0,
    0.2,
    0.4,
  )
  let env = LightingEnvironment::new(
    DirectionalLight::default(),
    AmbientLight::default(),
    point_lights=[pl],
    spot_lights=[sl],
  )
  assert_eq(env.point_lights.length(), 1)
  assert_eq(env.spot_lights.length(), 1)
  assert_true(approx(env.point_lights[0].radius, 5.0))
  assert_true(approx(env.spot_lights[0].outer_angle, 0.4))
}
