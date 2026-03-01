///|
test "circle-circle overlap" {
  let a = RigidBody2D::new_dynamic(
    0,
    @vector.Vec2::new(0.0, 0.0),
    1.0,
    CircleShape(@vector.Vec2::zero(), 1.0),
  )
  let b = RigidBody2D::new_dynamic(
    1,
    @vector.Vec2::new(1.5, 0.0),
    1.0,
    CircleShape(@vector.Vec2::zero(), 1.0),
  )
  let contact = generate_contact2d(a, b)
  assert_true(not(contact is None))
  let c = contact.unwrap()
  assert_true(c.penetration > 0.0)
  assert_true(c.normal.x > 0.0)
}

///|
test "circle-circle separated" {
  let a = RigidBody2D::new_dynamic(
    0,
    @vector.Vec2::new(0.0, 0.0),
    1.0,
    CircleShape(@vector.Vec2::zero(), 1.0),
  )
  let b = RigidBody2D::new_dynamic(
    1,
    @vector.Vec2::new(3.0, 0.0),
    1.0,
    CircleShape(@vector.Vec2::zero(), 1.0),
  )
  let contact = generate_contact2d(a, b)
  assert_true(contact is None)
}

///|
test "aabb2d-aabb2d overlap" {
  let a = RigidBody2D::new_dynamic(
    0,
    @vector.Vec2::new(0.0, 0.0),
    1.0,
    AABBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
  )
  let b = RigidBody2D::new_dynamic(
    1,
    @vector.Vec2::new(1.5, 0.0),
    1.0,
    AABBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
  )
  let contact = generate_contact2d(a, b)
  assert_true(not(contact is None))
  let c = contact.unwrap()
  assert_true(c.penetration > 0.0)
}

///|
test "aabb2d-aabb2d separated" {
  let a = RigidBody2D::new_dynamic(
    0,
    @vector.Vec2::new(0.0, 0.0),
    1.0,
    AABBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
  )
  let b = RigidBody2D::new_dynamic(
    1,
    @vector.Vec2::new(5.0, 0.0),
    1.0,
    AABBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
  )
  let contact = generate_contact2d(a, b)
  assert_true(contact is None)
}

///|
test "circle-aabb2d overlap" {
  let circle = RigidBody2D::new_dynamic(
    0,
    @vector.Vec2::new(0.0, 0.0),
    1.0,
    CircleShape(@vector.Vec2::zero(), 1.0),
  )
  let box_body = RigidBody2D::new_static(
    1,
    @vector.Vec2::new(1.5, 0.0),
    AABBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
  )
  let contact = generate_contact2d(circle, box_body)
  assert_true(not(contact is None))
  let c = contact.unwrap()
  assert_true(c.penetration > 0.0)
}

///|
test "circle-aabb2d separated" {
  let circle = RigidBody2D::new_dynamic(
    0,
    @vector.Vec2::new(0.0, 0.0),
    1.0,
    CircleShape(@vector.Vec2::zero(), 1.0),
  )
  let box_body = RigidBody2D::new_static(
    1,
    @vector.Vec2::new(5.0, 0.0),
    AABBShape2D(@vector.Vec2::new(1.0, 1.0), @vector.Vec2::zero()),
  )
  let contact = generate_contact2d(circle, box_body)
  assert_true(contact is None)
}
