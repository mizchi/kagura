///|
fn test_slide_body() -> RigidBody {
  let box = RigidBody::new_static(
    0,
    @math3d.Vec3::new(0.0, 2.0, 0.0),
    BoxShape(@math3d.Vec3::new(1.2, 0.12, 4.0), @math3d.Vec3::zero()),
  )
  {
    ..box,
    rotation: @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), 0.4),
    restitution: 0.05,
    friction: 0.25,
  }
}

///|
test "rotated boxes use their inclined face for sphere contacts and raycasts" {
  let ramp = test_slide_body()
  let normal = ramp.rotation.rotate_vec3(@math3d.Vec3::unit_y())
  let ball = RigidBody::new_dynamic(
    1,
    ramp.position.add(normal.scale(0.5)),
    1.0,
    SphereShape(@math3d.Vec3::zero(), 0.5),
  )
  let contact = generate_contact(ramp, ball).unwrap()
  assert_true(contact.normal.sub(normal).length() < 0.0001)
  assert_true((contact.penetration - 0.12).abs() < 0.0001)
  let reversed = generate_contact(ball, ramp).unwrap()
  assert_true(reversed.normal.add(normal).length() < 0.0001)
  let hit = ramp.raycast(
    @collision3d.Ray::new(
      @math3d.Vec3::new(0.0, 6.0, 0.0),
      @math3d.Vec3::new(0.0, -1.0, 0.0),
    ),
  )
  assert_true(hit.hit)
  assert_true((hit.point.y - (2.0 + 0.12 / normal.y)).abs() < 0.001)
  assert_false(
    ramp.intersects_sphere(
      @collision3d.Sphere::new(@math3d.Vec3::new(0.0, 3.4, 3.0), 0.2),
    ),
  )
}

///|
test "a ball falls onto a finite slope and travels downhill under gravity" {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.81, 0.0), 2.0)
  world.add_body(test_slide_body())
  world.add_body(
    RigidBody::new_dynamic(
      1,
      @math3d.Vec3::new(0.0, 4.0, -2.0),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.4),
    )
    .with_restitution(0.05)
    .with_friction(0.25),
  )
  for _ in 0..<120 {
    world.step(1.0 / 60.0)
  }
  let ball = world.get_body(1).unwrap()
  assert_true(ball.position.z > 0.0)
  assert_true(ball.velocity.z > 0.5)
  assert_true(ball.position.y > 0.0)
}

///|
test "oriented box SAT rejects empty corners of the broadphase bounds" {
  let ramp = test_slide_body()
  let empty = RigidBody::new_dynamic(
    1,
    @math3d.Vec3::new(0.0, 3.4, 3.0),
    1.0,
    AABBShape(@math3d.Vec3::new(0.2, 0.2, 0.2), @math3d.Vec3::zero()),
  )
  assert_true(ramp.world_aabb().intersects_aabb(empty.world_aabb()))
  assert_true(generate_contact(ramp, empty) is None)
  let touching = { ..empty, position: ramp.position, }
  assert_true(generate_contact(ramp, touching) is Some(_))
}
