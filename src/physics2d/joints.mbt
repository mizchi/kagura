///|
let joint_pi : Double = 3.14159265358979323846

// ============================================================
// Distance Joint
// ============================================================

///|
fn find_body_index(bodies : Array[RigidBody2D], id : Int) -> Int {
  for i = 0; i < bodies.length(); i = i + 1 {
    if bodies[i].id == id {
      return i
    }
  }
  -1
}

///|
fn rotate_vec2(v : @vector.Vec2, angle : Double) -> @vector.Vec2 {
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  @vector.Vec2::new(v.x * c - v.y * s, v.x * s + v.y * c)
}

///|
pub fn precompute_distance_joint(
  joint : DistanceJoint2D,
  bodies : Array[RigidBody2D],
  sub_dt : Double,
) -> DistanceJointConstraint2D? {
  let idx_a = find_body_index(bodies, joint.body_a_id)
  let idx_b = find_body_index(bodies, joint.body_b_id)
  if idx_a < 0 || idx_b < 0 {
    return None
  }
  let a = bodies[idx_a]
  let b = bodies[idx_b]
  // Rotate local anchors to world space
  let r_a = rotate_vec2(joint.local_anchor_a, a.angle)
  let r_b = rotate_vec2(joint.local_anchor_b, b.angle)
  let world_a = a.position.add(r_a)
  let world_b = b.position.add(r_b)
  let delta = world_b.sub(world_a)
  let current_length = delta.length()
  let axis = if current_length > 1.0e-8 {
    delta.scale(1.0 / current_length)
  } else {
    @vector.Vec2::new(1.0, 0.0)
  }
  // Effective mass along the axis
  let r_a_cross_n = r_a.x * axis.y - r_a.y * axis.x
  let r_b_cross_n = r_b.x * axis.y - r_b.y * axis.x
  let k = a.inv_mass +
    b.inv_mass +
    r_a_cross_n * r_a_cross_n * a.inv_inertia +
    r_b_cross_n * r_b_cross_n * b.inv_inertia
  // Soft constraint params
  let omega = 2.0 * joint_pi * joint.hertz
  let gamma = 1.0 /
    (sub_dt * (2.0 * joint.damping_ratio * omega + sub_dt * omega * omega))
  let beta = sub_dt * omega * omega * gamma
  let effective_mass = if k + gamma > 1.0e-12 { 1.0 / (k + gamma) } else { 0.0 }
  Some({
    idx_a,
    idx_b,
    r_a,
    r_b,
    axis,
    effective_mass,
    gamma,
    bias_coefficient: beta,
    acc_impulse: 0.0,
  })
}

///|
pub fn solve_distance_joint(
  constraints : Array[DistanceJointConstraint2D],
  ci : Int,
  bodies : Array[RigidBody2D],
  joint : DistanceJoint2D,
) -> Unit {
  let c = constraints[ci]
  let a = bodies[c.idx_a]
  let b = bodies[c.idx_b]
  // Recompute current separation
  let world_a = a.position.add(c.r_a)
  let world_b = b.position.add(c.r_b)
  let delta = world_b.sub(world_a)
  let current_length = delta.dot(c.axis)
  let error = current_length - joint.rest_length
  let bias = c.bias_coefficient * error
  // Relative velocity along axis
  let r_a_perp = @vector.Vec2::new(-c.r_a.y, c.r_a.x)
  let r_b_perp = @vector.Vec2::new(-c.r_b.y, c.r_b.x)
  let v_a = a.velocity.add(r_a_perp.scale(a.angular_velocity))
  let v_b = b.velocity.add(r_b_perp.scale(b.angular_velocity))
  let v_rel = v_b.sub(v_a).dot(c.axis)
  let lambda = -(v_rel + bias + c.gamma * c.acc_impulse) * c.effective_mass
  let new_acc = c.acc_impulse + lambda
  let delta_impulse = new_acc - c.acc_impulse
  if delta_impulse.abs() > 1.0e-15 {
    let impulse = c.axis.scale(delta_impulse)
    let r_a_cross = c.r_a.x * c.axis.y - c.r_a.y * c.axis.x
    let r_b_cross = c.r_b.x * c.axis.y - c.r_b.y * c.axis.x
    bodies[c.idx_a] = {
      ..a,
      velocity: a.velocity.sub(impulse.scale(a.inv_mass)),
      angular_velocity: a.angular_velocity -
      r_a_cross * delta_impulse * a.inv_inertia,
    }
    bodies[c.idx_b] = {
      ..b,
      velocity: b.velocity.add(impulse.scale(b.inv_mass)),
      angular_velocity: b.angular_velocity +
      r_b_cross * delta_impulse * b.inv_inertia,
    }
  }
  constraints[ci] = { ..c, acc_impulse: new_acc }
}

// ============================================================
// Revolute Joint (point-to-point constraint, 2 rows: x and y)
// ============================================================

///|
pub fn precompute_revolute_joint(
  joint : RevoluteJoint2D,
  bodies : Array[RigidBody2D],
  sub_dt : Double,
) -> RevoluteJointConstraint2D? {
  let idx_a = find_body_index(bodies, joint.body_a_id)
  let idx_b = find_body_index(bodies, joint.body_b_id)
  if idx_a < 0 || idx_b < 0 {
    return None
  }
  let a = bodies[idx_a]
  let b = bodies[idx_b]
  let r_a = rotate_vec2(joint.local_anchor_a, a.angle)
  let r_b = rotate_vec2(joint.local_anchor_b, b.angle)
  // Soft constraint params
  let omega = 2.0 * joint_pi * joint.hertz
  let gamma = 1.0 /
    (sub_dt * (2.0 * joint.damping_ratio * omega + sub_dt * omega * omega))
  let beta = sub_dt * omega * omega * gamma
  // Effective mass for X axis (1,0)
  let r_a_cross_x = -r_a.y // r_a cross (1,0) = r_a.x*0 - r_a.y*1
  let r_b_cross_x = -r_b.y
  let k_x = a.inv_mass +
    b.inv_mass +
    r_a_cross_x * r_a_cross_x * a.inv_inertia +
    r_b_cross_x * r_b_cross_x * b.inv_inertia
  // Effective mass for Y axis (0,1)
  let r_a_cross_y = r_a.x // r_a cross (0,1) = r_a.x*1 - r_a.y*0
  let r_b_cross_y = r_b.x
  let k_y = a.inv_mass +
    b.inv_mass +
    r_a_cross_y * r_a_cross_y * a.inv_inertia +
    r_b_cross_y * r_b_cross_y * b.inv_inertia
  let eff_mass_x = if k_x + gamma > 1.0e-12 { 1.0 / (k_x + gamma) } else { 0.0 }
  let eff_mass_y = if k_y + gamma > 1.0e-12 { 1.0 / (k_y + gamma) } else { 0.0 }
  Some({
    idx_a,
    idx_b,
    r_a,
    r_b,
    effective_mass_x: eff_mass_x,
    effective_mass_y: eff_mass_y,
    gamma,
    bias_coefficient: beta,
    acc_impulse_x: 0.0,
    acc_impulse_y: 0.0,
  })
}

///|
pub fn solve_revolute_joint(
  constraints : Array[RevoluteJointConstraint2D],
  ci : Int,
  bodies : Array[RigidBody2D],
) -> Unit {
  let c = constraints[ci]
  let a = bodies[c.idx_a]
  let b = bodies[c.idx_b]
  // Position error
  let world_a = a.position.add(c.r_a)
  let world_b = b.position.add(c.r_b)
  let error = world_b.sub(world_a)
  // Relative velocity at anchor
  let r_a_perp = @vector.Vec2::new(-c.r_a.y, c.r_a.x)
  let r_b_perp = @vector.Vec2::new(-c.r_b.y, c.r_b.x)
  let v_a = a.velocity.add(r_a_perp.scale(a.angular_velocity))
  let v_b = b.velocity.add(r_b_perp.scale(b.angular_velocity))
  let v_rel = v_b.sub(v_a)
  // X constraint
  let bias_x = c.bias_coefficient * error.x
  let lambda_x = -(v_rel.x + bias_x + c.gamma * c.acc_impulse_x) *
    c.effective_mass_x
  let new_acc_x = c.acc_impulse_x + lambda_x
  let delta_x = new_acc_x - c.acc_impulse_x
  // Y constraint
  let bias_y = c.bias_coefficient * error.y
  let lambda_y = -(v_rel.y + bias_y + c.gamma * c.acc_impulse_y) *
    c.effective_mass_y
  let new_acc_y = c.acc_impulse_y + lambda_y
  let delta_y = new_acc_y - c.acc_impulse_y
  if delta_x.abs() > 1.0e-15 || delta_y.abs() > 1.0e-15 {
    let impulse = @vector.Vec2::new(delta_x, delta_y)
    // Cross products for angular impulse
    let angular_a = c.r_a.x * impulse.y - c.r_a.y * impulse.x
    let angular_b = c.r_b.x * impulse.y - c.r_b.y * impulse.x
    bodies[c.idx_a] = {
      ..a,
      velocity: a.velocity.sub(impulse.scale(a.inv_mass)),
      angular_velocity: a.angular_velocity - angular_a * a.inv_inertia,
    }
    bodies[c.idx_b] = {
      ..b,
      velocity: b.velocity.add(impulse.scale(b.inv_mass)),
      angular_velocity: b.angular_velocity + angular_b * b.inv_inertia,
    }
  }
  constraints[ci] = { ..c, acc_impulse_x: new_acc_x, acc_impulse_y: new_acc_y }
}
