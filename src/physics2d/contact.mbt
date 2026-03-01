///|
pub fn generate_contact2d(a : RigidBody2D, b : RigidBody2D) -> Contact2D? {
  match (a.collider, b.collider) {
    (CircleShape(off_a, r_a), CircleShape(off_b, r_b)) =>
      circle_circle(a, off_a, r_a, b, off_b, r_b)
    (AABBShape2D(he_a, off_a), AABBShape2D(he_b, off_b)) =>
      aabb2d_aabb2d(a, he_a, off_a, b, he_b, off_b)
    (CircleShape(off_a, r_a), AABBShape2D(he_b, off_b)) =>
      circle_aabb2d(a, off_a, r_a, b, he_b, off_b, false)
    (AABBShape2D(he_a, off_a), CircleShape(off_b, r_b)) =>
      circle_aabb2d(b, off_b, r_b, a, he_a, off_a, true)
  }
}

///|
fn circle_circle(
  a : RigidBody2D,
  off_a : @vector.Vec2,
  r_a : Double,
  b : RigidBody2D,
  off_b : @vector.Vec2,
  r_b : Double,
) -> Contact2D? {
  let center_a = a.position.add(off_a)
  let center_b = b.position.add(off_b)
  let diff = center_b.sub(center_a)
  let dist_sq = diff.length_squared()
  let r_sum = r_a + r_b
  if dist_sq >= r_sum * r_sum {
    return None
  }
  let dist = dist_sq.sqrt()
  let normal = if dist < 1.0e-12 {
    @vector.Vec2::unit_y()
  } else {
    diff.scale(1.0 / dist)
  }
  let penetration = r_sum - dist
  let contact_point = center_a.add(normal.scale(r_a - penetration * 0.5))
  Some(
    {
      body_a_id: a.id,
      body_b_id: b.id,
      normal,
      penetration,
      contact_point,
    },
  )
}

///|
fn aabb2d_aabb2d(
  a : RigidBody2D,
  he_a : @vector.Vec2,
  off_a : @vector.Vec2,
  b : RigidBody2D,
  he_b : @vector.Vec2,
  off_b : @vector.Vec2,
) -> Contact2D? {
  let center_a = a.position.add(off_a)
  let center_b = b.position.add(off_b)
  let diff = center_b.sub(center_a)
  let overlap_x = he_a.x + he_b.x - diff.x.abs()
  let overlap_y = he_a.y + he_b.y - diff.y.abs()
  if overlap_x <= 0.0 || overlap_y <= 0.0 {
    return None
  }
  let (normal, penetration) = if overlap_x <= overlap_y {
    let nx = if diff.x >= 0.0 { 1.0 } else { -1.0 }
    (@vector.Vec2::new(nx, 0.0), overlap_x)
  } else {
    let ny = if diff.y >= 0.0 { 1.0 } else { -1.0 }
    (@vector.Vec2::new(0.0, ny), overlap_y)
  }
  let contact_point = center_a.add(center_b).scale(0.5)
  Some(
    {
      body_a_id: a.id,
      body_b_id: b.id,
      normal,
      penetration,
      contact_point,
    },
  )
}

///|
fn circle_aabb2d(
  circle_body : RigidBody2D,
  circle_off : @vector.Vec2,
  circle_r : Double,
  box_body : RigidBody2D,
  box_he : @vector.Vec2,
  box_off : @vector.Vec2,
  swapped : Bool,
) -> Contact2D? {
  let circle_center = circle_body.position.add(circle_off)
  let box_center = box_body.position.add(box_off)
  let box_aabb = AABB2D::new(box_center.sub(box_he), box_center.add(box_he))
  let closest = box_aabb.closest_point(circle_center)
  let diff = circle_center.sub(closest)
  let dist_sq = diff.length_squared()
  if dist_sq >= circle_r * circle_r {
    return None
  }
  let dist = dist_sq.sqrt()
  let normal = if dist < 1.0e-12 {
    @vector.Vec2::unit_y()
  } else {
    diff.scale(1.0 / dist)
  }
  let penetration = circle_r - dist
  if swapped {
    Some(
      {
        body_a_id: box_body.id,
        body_b_id: circle_body.id,
        normal,
        penetration,
        contact_point: closest,
      },
    )
  } else {
    Some(
      {
        body_a_id: circle_body.id,
        body_b_id: box_body.id,
        normal: normal.negate(),
        penetration,
        contact_point: closest,
      },
    )
  }
}
