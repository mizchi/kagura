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
    (OBBShape2D(he_a, off_a), OBBShape2D(he_b, off_b)) =>
      obb_obb(a, he_a, off_a, b, he_b, off_b)
    (OBBShape2D(he_a, off_a), CircleShape(off_b, r_b)) =>
      obb_circle(a, he_a, off_a, b, off_b, r_b, false)
    (CircleShape(off_a, r_a), OBBShape2D(he_b, off_b)) =>
      obb_circle(b, he_b, off_b, a, off_a, r_a, true)
    (OBBShape2D(he_a, off_a), AABBShape2D(he_b, off_b)) =>
      obb_obb(a, he_a, off_a, { ..b, angle: 0.0 }, he_b, off_b)
    (AABBShape2D(he_a, off_a), OBBShape2D(he_b, off_b)) =>
      obb_obb({ ..a, angle: 0.0 }, he_a, off_a, b, he_b, off_b)
  }
}

///|
fn project_obb_on_axis(
  center : @vector.Vec2,
  axis_x : @vector.Vec2,
  axis_y : @vector.Vec2,
  he : @vector.Vec2,
  axis : @vector.Vec2,
) -> (Double, Double) {
  let c = center.dot(axis)
  let r = (axis_x.dot(axis) * he.x).abs() + (axis_y.dot(axis) * he.y).abs()
  (c - r, c + r)
}

///|
fn point_in_obb(
  point : @vector.Vec2,
  center : @vector.Vec2,
  half_extents : @vector.Vec2,
  angle : Double,
) -> Bool {
  let diff = point.sub(center)
  let lx = diff.rotate(-angle)
  lx.x.abs() <= half_extents.x && lx.y.abs() <= half_extents.y
}

///|
fn obb_obb(
  a : RigidBody2D,
  he_a : @vector.Vec2,
  off_a : @vector.Vec2,
  b : RigidBody2D,
  he_b : @vector.Vec2,
  off_b : @vector.Vec2,
) -> Contact2D? {
  let center_a = a.position.add(off_a.rotate(a.angle))
  let center_b = b.position.add(off_b.rotate(b.angle))
  let ax_a = @vector.Vec2::new(@math.cos(a.angle), @math.sin(a.angle))
  let ay_a = @vector.Vec2::new(-@math.sin(a.angle), @math.cos(a.angle))
  let ax_b = @vector.Vec2::new(@math.cos(b.angle), @math.sin(b.angle))
  let ay_b = @vector.Vec2::new(-@math.sin(b.angle), @math.cos(b.angle))
  let axes : Array[@vector.Vec2] = [ax_a, ay_a, ax_b, ay_b]
  let mut min_overlap = 1.0e30
  let mut best_axis = @vector.Vec2::zero()
  for i = 0; i < axes.length(); i = i + 1 {
    let axis = axes[i]
    let (min_a, max_a) = project_obb_on_axis(center_a, ax_a, ay_a, he_a, axis)
    let (min_b, max_b) = project_obb_on_axis(center_b, ax_b, ay_b, he_b, axis)
    let overlap = if max_a < min_b || max_b < min_a {
      return None
    } else {
      let o1 = max_a - min_b
      let o2 = max_b - min_a
      if o1 < o2 {
        o1
      } else {
        o2
      }
    }
    if overlap < min_overlap {
      min_overlap = overlap
      let dir = center_b.sub(center_a)
      best_axis = if dir.dot(axis) >= 0.0 { axis } else { axis.negate() }
    }
  }
  // Contact point: average of vertices penetrating into the other body
  let local_corners_a : Array[@vector.Vec2] = [
    @vector.Vec2::new(-he_a.x, -he_a.y),
    @vector.Vec2::new(he_a.x, -he_a.y),
    @vector.Vec2::new(he_a.x, he_a.y),
    @vector.Vec2::new(-he_a.x, he_a.y),
  ]
  let local_corners_b : Array[@vector.Vec2] = [
    @vector.Vec2::new(-he_b.x, -he_b.y),
    @vector.Vec2::new(he_b.x, -he_b.y),
    @vector.Vec2::new(he_b.x, he_b.y),
    @vector.Vec2::new(-he_b.x, he_b.y),
  ]
  let mut cp_sum = @vector.Vec2::zero()
  let mut cp_count = 0
  // Vertices of A inside B
  for i = 0; i < 4; i = i + 1 {
    let v = center_a.add(local_corners_a[i].rotate(a.angle))
    if point_in_obb(v, center_b, he_b, b.angle) {
      cp_sum = cp_sum.add(v)
      cp_count = cp_count + 1
    }
  }
  // Vertices of B inside A
  for i = 0; i < 4; i = i + 1 {
    let v = center_b.add(local_corners_b[i].rotate(b.angle))
    if point_in_obb(v, center_a, he_a, a.angle) {
      cp_sum = cp_sum.add(v)
      cp_count = cp_count + 1
    }
  }
  let contact_point = if cp_count > 0 {
    cp_sum.scale(1.0 / cp_count.to_double())
  } else {
    // Edge-edge: project centers onto normal, use midpoint along normal
    let mid = center_a.add(center_b).scale(0.5)
    let proj_diff = center_b.sub(center_a).dot(best_axis)
    mid.sub(best_axis.scale(proj_diff * 0.5))
  }
  Some({
    body_a_id: a.id,
    body_b_id: b.id,
    normal: best_axis,
    penetration: min_overlap,
    contact_point,
  })
}

///|
fn obb_circle(
  obb_body : RigidBody2D,
  obb_he : @vector.Vec2,
  obb_off : @vector.Vec2,
  circle_body : RigidBody2D,
  circle_off : @vector.Vec2,
  circle_r : Double,
  swapped : Bool,
) -> Contact2D? {
  let obb_center = obb_body.position.add(obb_off.rotate(obb_body.angle))
  let circle_center = circle_body.position.add(circle_off)
  // Transform circle center into OBB local space
  let diff = circle_center.sub(obb_center)
  let loc = diff.rotate(-obb_body.angle)
  // Clamp to AABB in local space
  let mut closest_x = loc.x
  let mut closest_y = loc.y
  if closest_x > obb_he.x {
    closest_x = obb_he.x
  } else if closest_x < -obb_he.x {
    closest_x = -obb_he.x
  }
  if closest_y > obb_he.y {
    closest_y = obb_he.y
  } else if closest_y < -obb_he.y {
    closest_y = -obb_he.y
  }
  let inside = loc.x == closest_x && loc.y == closest_y
  if inside {
    // Circle center inside OBB: push out along nearest face
    let dx_pos = obb_he.x - loc.x
    let dx_neg = obb_he.x + loc.x
    let dy_pos = obb_he.y - loc.y
    let dy_neg = obb_he.y + loc.y
    let mut min_dist = dx_pos
    let mut loc_normal = @vector.Vec2::new(1.0, 0.0)
    if dx_neg < min_dist {
      min_dist = dx_neg
      loc_normal = @vector.Vec2::new(-1.0, 0.0)
    }
    if dy_pos < min_dist {
      min_dist = dy_pos
      loc_normal = @vector.Vec2::new(0.0, 1.0)
    }
    if dy_neg < min_dist {
      min_dist = dy_neg
      loc_normal = @vector.Vec2::new(0.0, -1.0)
    }
    let penetration = min_dist + circle_r
    let world_normal = loc_normal.rotate(obb_body.angle)
    let cp_local = @vector.Vec2::new(closest_x, closest_y)
    let contact_point = obb_center.add(cp_local.rotate(obb_body.angle))
    if swapped {
      // A=circle, B=obb; normal from A(circle) toward B(obb)
      Some({
        body_a_id: circle_body.id,
        body_b_id: obb_body.id,
        normal: world_normal.negate(),
        penetration,
        contact_point,
      })
    } else {
      // A=obb, B=circle; normal from A(obb) toward B(circle)
      Some({
        body_a_id: obb_body.id,
        body_b_id: circle_body.id,
        normal: world_normal,
        penetration,
        contact_point,
      })
    }
  } else {
    // Circle center outside OBB
    let closest_local = @vector.Vec2::new(closest_x, closest_y)
    let diff_local = loc.sub(closest_local)
    let dist_sq = diff_local.length_squared()
    if dist_sq >= circle_r * circle_r {
      return None
    }
    let dist = dist_sq.sqrt()
    let loc_normal = if dist < 1.0e-12 {
      @vector.Vec2::unit_y()
    } else {
      diff_local.scale(1.0 / dist)
    }
    let penetration = circle_r - dist
    let world_normal = loc_normal.rotate(obb_body.angle)
    let contact_point = obb_center.add(closest_local.rotate(obb_body.angle))
    if swapped {
      Some({
        body_a_id: circle_body.id,
        body_b_id: obb_body.id,
        normal: world_normal.negate(),
        penetration,
        contact_point,
      })
    } else {
      Some({
        body_a_id: obb_body.id,
        body_b_id: circle_body.id,
        normal: world_normal,
        penetration,
        contact_point,
      })
    }
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
  Some({ body_a_id: a.id, body_b_id: b.id, normal, penetration, contact_point })
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
  Some({ body_a_id: a.id, body_b_id: b.id, normal, penetration, contact_point })
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
  if box_aabb.contains_point(circle_center) {
    // Circle center is inside AABB: find nearest face to escape
    let dx_left = circle_center.x - box_aabb.min.x
    let dx_right = box_aabb.max.x - circle_center.x
    let dy_bottom = circle_center.y - box_aabb.min.y
    let dy_top = box_aabb.max.y - circle_center.y
    let mut min_dist = dx_left
    // face_outward: outward normal of the nearest box face
    let mut face_outward = @vector.Vec2::new(-1.0, 0.0)
    if dx_right < min_dist {
      min_dist = dx_right
      face_outward = @vector.Vec2::new(1.0, 0.0)
    }
    if dy_bottom < min_dist {
      min_dist = dy_bottom
      face_outward = @vector.Vec2::new(0.0, -1.0)
    }
    if dy_top < min_dist {
      min_dist = dy_top
      face_outward = @vector.Vec2::new(0.0, 1.0)
    }
    let penetration = min_dist + circle_r
    let contact_point = circle_center.add(face_outward.scale(min_dist))
    // Convention: contact.normal points from A to B
    if swapped {
      // A=box, B=circle; from box toward circle escape = face_outward
      Some({
        body_a_id: box_body.id,
        body_b_id: circle_body.id,
        normal: face_outward,
        penetration,
        contact_point,
      })
    } else {
      // A=circle, B=box; from circle toward box interior = -face_outward
      Some({
        body_a_id: circle_body.id,
        body_b_id: box_body.id,
        normal: face_outward.negate(),
        penetration,
        contact_point,
      })
    }
  } else {
    // Circle center is outside AABB: use closest point
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
      Some({
        body_a_id: box_body.id,
        body_b_id: circle_body.id,
        normal,
        penetration,
        contact_point: closest,
      })
    } else {
      Some({
        body_a_id: circle_body.id,
        body_b_id: box_body.id,
        normal: normal.negate(),
        penetration,
        contact_point: closest,
      })
    }
  }
}
