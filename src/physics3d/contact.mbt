///|
pub fn generate_contact(a : RigidBody, b : RigidBody) -> Contact? {
  match (a.collider, b.collider) {
    (SphereShape(off_a, r_a), SphereShape(off_b, r_b)) =>
      sphere_sphere(a, off_a, r_a, b, off_b, r_b)
    (AABBShape(he_a, off_a), AABBShape(he_b, off_b)) =>
      aabb_aabb(a, he_a, off_a, b, he_b, off_b)
    (SphereShape(off_a, r_a), AABBShape(he_b, off_b)) =>
      sphere_aabb(a, off_a, r_a, b, he_b, off_b, false)
    (AABBShape(he_a, off_a), SphereShape(off_b, r_b)) =>
      sphere_aabb(b, off_b, r_b, a, he_a, off_a, true)
  }
}

///|
fn sphere_sphere(
  a : RigidBody,
  off_a : @math3d.Vec3,
  r_a : Double,
  b : RigidBody,
  off_b : @math3d.Vec3,
  r_b : Double,
) -> Contact? {
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
    @math3d.Vec3::unit_y()
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
fn aabb_aabb(
  a : RigidBody,
  he_a : @math3d.Vec3,
  off_a : @math3d.Vec3,
  b : RigidBody,
  he_b : @math3d.Vec3,
  off_b : @math3d.Vec3,
) -> Contact? {
  let center_a = a.position.add(off_a)
  let center_b = b.position.add(off_b)
  let diff = center_b.sub(center_a)
  let overlap_x = he_a.x + he_b.x - diff.x.abs()
  let overlap_y = he_a.y + he_b.y - diff.y.abs()
  let overlap_z = he_a.z + he_b.z - diff.z.abs()
  if overlap_x <= 0.0 || overlap_y <= 0.0 || overlap_z <= 0.0 {
    return None
  }
  let (normal, penetration) = if overlap_x <= overlap_y && overlap_x <= overlap_z {
    let nx = if diff.x >= 0.0 { 1.0 } else { -1.0 }
    (@math3d.Vec3::new(nx, 0.0, 0.0), overlap_x)
  } else if overlap_y <= overlap_z {
    let ny = if diff.y >= 0.0 { 1.0 } else { -1.0 }
    (@math3d.Vec3::new(0.0, ny, 0.0), overlap_y)
  } else {
    let nz = if diff.z >= 0.0 { 1.0 } else { -1.0 }
    (@math3d.Vec3::new(0.0, 0.0, nz), overlap_z)
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
fn sphere_aabb(
  sphere_body : RigidBody,
  sphere_off : @math3d.Vec3,
  sphere_r : Double,
  box_body : RigidBody,
  box_he : @math3d.Vec3,
  box_off : @math3d.Vec3,
  swapped : Bool,
) -> Contact? {
  let sphere_center = sphere_body.position.add(sphere_off)
  let box_center = box_body.position.add(box_off)
  let box_aabb = @collision3d.AABB::new(
    box_center.sub(box_he),
    box_center.add(box_he),
  )
  let closest = box_aabb.closest_point(sphere_center)
  let diff = sphere_center.sub(closest)
  let dist_sq = diff.length_squared()
  if dist_sq >= sphere_r * sphere_r {
    return None
  }
  let dist = dist_sq.sqrt()
  let normal = if dist < 1.0e-12 {
    @math3d.Vec3::unit_y()
  } else {
    diff.scale(1.0 / dist)
  }
  let penetration = sphere_r - dist
  if swapped {
    // box is A, sphere is B; diff points from box→sphere = A→B
    Some(
      {
        body_a_id: box_body.id,
        body_b_id: sphere_body.id,
        normal,
        penetration,
        contact_point: closest,
      },
    )
  } else {
    // sphere is A, box is B; diff points from box→sphere = B→A, negate for A→B
    Some(
      {
        body_a_id: sphere_body.id,
        body_b_id: box_body.id,
        normal: normal.negate(),
        penetration,
        contact_point: closest,
      },
    )
  }
}
