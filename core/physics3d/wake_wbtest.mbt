///|
test "explicit nonzero impulses and forces wake sleeping dynamic bodies" {
  let world = PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
  let body = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::zero(),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 0.5),
  )
  world.add_body({ ..body, is_sleeping: true, sleep_timer: 1.0, })
  world.apply_impulse(1, @math3d.Vec3::new(4.0, 0.0, 0.0))
  assert_false(world.get_body(1).unwrap().is_sleeping)
  world.step(1.0 / 60.0)
  assert_true(world.get_body(1).unwrap().position.x > 0.0)
  world.bodies[0] = { ..body, is_sleeping: true, sleep_timer: 1.0, }
  world.apply_force(1, @math3d.Vec3::new(10.0, 0.0, 0.0))
  assert_false(world.get_body(1).unwrap().is_sleeping)
  world.step(1.0 / 60.0)
  assert_true(world.get_body(1).unwrap().position.x > 0.0)
}

///|
test "zero input keeps settled bodies asleep" {
  let body = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::zero(),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 0.5),
  )
  let sleeping = { ..body, is_sleeping: true, sleep_timer: 1.0, }
  assert_true(sleeping.apply_impulse(@math3d.Vec3::zero()).is_sleeping)
  assert_true(sleeping.apply_force(@math3d.Vec3::zero()).is_sleeping)
}
