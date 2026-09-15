///|
test "ground probe rejects self, walls and jump ascent and accepts slope normals" {
  let player = @physics3d.RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(0.0, 0.5, 0.0),
    2.0,
    SphereShape(@math3d.Vec3::zero(), 0.5),
  )
  let floor = @physics3d.RigidBody::new_static(
    2,
    @math3d.Vec3::new(0.0, -0.1, 0.0),
    AABBShape(@math3d.Vec3::new(5.0, 0.1, 5.0), @math3d.Vec3::zero()),
  )
  let wall = @physics3d.RigidBody::new_static(
    3,
    @math3d.Vec3::new(0.6, 1.0, 0.0),
    AABBShape(@math3d.Vec3::new(0.1, 3.0, 5.0), @math3d.Vec3::zero()),
  )
  let config = MotorConfig::default()
  assert_true(sphere_ground_contact(player, [player, wall], config) is None)
  let ground = sphere_ground_contact(player, [player, floor, wall], config).unwrap()
  assert_eq(ground.body_id, floor.id)
  assert_true(ground.normal.sub(@math3d.Vec3::unit_y()).length() < 0.0001)
  let jumping = { ..player, velocity: @math3d.Vec3::new(0.0, 5.0, 0.0), }
  assert_true(sphere_ground_contact(jumping, [floor], config) is None)
  let rotation = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_z(),
    0.4,
  )
  let normal = rotation.rotate_vec3(@math3d.Vec3::unit_y())
  let ramp = {
    ..floor,
    position: @math3d.Vec3::zero(),
    rotation,
    collider: @physics3d.BoxShape(
      @math3d.Vec3::new(3.0, 0.1, 3.0),
      @math3d.Vec3::zero(),
    ),
  }
  let on_ramp = { ..player, position: normal.scale(0.6), }
  let support = sphere_ground_contact(on_ramp, [ramp], config).unwrap()
  assert_true(support.normal.sub(normal).length() < 0.0001)
}
