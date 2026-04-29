///|
let baumgarte_factor : Double = 0.2

///|
let slop : Double = 0.005

///|
let max_angular_velocity : Double = 20.0

///|
/// Below this closing speed, restitution is zeroed to prevent micro-bouncing.
let restitution_velocity_threshold : Double = 1.0

///|
fn clamp_angular(omega : Double) -> Double {
  if omega > max_angular_velocity {
    max_angular_velocity
  } else if omega < -max_angular_velocity {
    -max_angular_velocity
  } else {
    omega
  }
}

///|
/// 2D cross: ω × r = Vec2(-ω*r.y, ω*r.x)
fn cross_scalar_vec(omega : Double, r : @vector.Vec2) -> @vector.Vec2 {
  @vector.Vec2::new(-omega * r.y, omega * r.x)
}

///|
/// Pre-compute restitution bias for a contact (called once before solver iterations).
fn compute_restitution_bias(
  a : RigidBody2D,
  b : RigidBody2D,
  contact : Contact2D,
) -> Double {
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let v_a = a.velocity.add(cross_scalar_vec(a.angular_velocity, r_a))
  let v_b = b.velocity.add(cross_scalar_vec(b.angular_velocity, r_b))
  let v_rel = v_a.sub(v_b)
  let v_n = v_rel.dot(contact.normal)
  if v_n > restitution_velocity_threshold {
    let e = if a.restitution < b.restitution {
      a.restitution
    } else {
      b.restitution
    }
    e * v_n
  } else {
    0.0
  }
}

///|
/// Velocity impulse resolution with accumulated impulse clamping (Box2D-style).
/// The accumulated impulse ensures proper Coulomb friction across solver iterations.
/// Returns updated bodies and new accumulated impulses (normal, tangent).
fn resolve_velocity2d_acc(
  a : RigidBody2D,
  b : RigidBody2D,
  contact : Contact2D,
  restitution_bias : Double,
  acc_jn : Double,
  acc_jt : Double,
) -> (RigidBody2D, RigidBody2D, Double, Double) {
  let inv_mass_sum = a.inv_mass + b.inv_mass
  if inv_mass_sum < 1.0e-12 {
    return (a, b, acc_jn, acc_jt)
  }
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let n = contact.normal
  // Fixed tangent direction (perpendicular to normal)
  let tangent = @vector.Vec2::new(-n.y, n.x)
  let r_a_cross_n = r_a.cross(n)
  let r_b_cross_n = r_b.cross(n)
  let r_a_cross_t = r_a.cross(tangent)
  let r_b_cross_t = r_b.cross(tangent)
  let denom_n = inv_mass_sum +
    r_a_cross_n * r_a_cross_n * a.inv_inertia +
    r_b_cross_n * r_b_cross_n * b.inv_inertia
  let denom_t = inv_mass_sum +
    r_a_cross_t * r_a_cross_t * a.inv_inertia +
    r_b_cross_t * r_b_cross_t * b.inv_inertia
  // Current relative velocity
  let v_a = a.velocity.add(cross_scalar_vec(a.angular_velocity, r_a))
  let v_b = b.velocity.add(cross_scalar_vec(b.angular_velocity, r_b))
  let v_rel = v_a.sub(v_b)
  // --- Normal impulse with accumulated clamping ---
  let v_n = v_rel.dot(n)
  let j_n_delta = -(v_n + restitution_bias) / denom_n
  // Clamp accumulated normal impulse: only repulsive (<=0 in our convention)
  let new_acc_jn = {
    let raw = acc_jn + j_n_delta
    if raw > 0.0 {
      0.0
    } else {
      raw
    }
  }
  let j_n = new_acc_jn - acc_jn // actual delta to apply
  let mut a_new = a
  let mut b_new = b
  if j_n.abs() > 1.0e-15 {
    let impulse_n = n.scale(j_n)
    a_new = {
      ..a_new,
      velocity: a_new.velocity.add(impulse_n.scale(a.inv_mass)),
      angular_velocity: clamp_angular(
        a_new.angular_velocity + r_a_cross_n * j_n * a.inv_inertia,
      ),
    }
    b_new = {
      ..b_new,
      velocity: b_new.velocity.sub(impulse_n.scale(b.inv_mass)),
      angular_velocity: clamp_angular(
        b_new.angular_velocity - r_b_cross_n * j_n * b.inv_inertia,
      ),
    }
  }
  // --- Friction impulse with accumulated Coulomb clamping ---
  // Recompute relative velocity after normal impulse
  let v_a2 = a_new.velocity.add(cross_scalar_vec(a_new.angular_velocity, r_a))
  let v_b2 = b_new.velocity.add(cross_scalar_vec(b_new.angular_velocity, r_b))
  let v_rel2 = v_a2.sub(v_b2)
  let v_t = v_rel2.dot(tangent)
  let mu = (a.friction + b.friction) * 0.5
  // Coulomb friction limit from accumulated normal impulse
  let friction_limit = new_acc_jn.abs() * mu
  let mut new_acc_jt = acc_jt
  if v_t.abs() > 1.0e-8 {
    let j_t_delta = -v_t / denom_t
    let raw_acc_jt = acc_jt + j_t_delta
    // Clamp accumulated friction within Coulomb cone
    new_acc_jt = if raw_acc_jt > friction_limit {
      friction_limit
    } else if raw_acc_jt < -friction_limit {
      -friction_limit
    } else {
      raw_acc_jt
    }
    let j_t = new_acc_jt - acc_jt // actual delta to apply
    if j_t.abs() > 1.0e-15 {
      let impulse_t = tangent.scale(j_t)
      a_new = {
        ..a_new,
        velocity: a_new.velocity.add(impulse_t.scale(a.inv_mass)),
        angular_velocity: clamp_angular(
          a_new.angular_velocity + r_a_cross_t * j_t * a.inv_inertia,
        ),
      }
      b_new = {
        ..b_new,
        velocity: b_new.velocity.sub(impulse_t.scale(b.inv_mass)),
        angular_velocity: clamp_angular(
          b_new.angular_velocity - r_b_cross_t * j_t * b.inv_inertia,
        ),
      }
    }
  }
  (a_new, b_new, new_acc_jn, new_acc_jt)
}

///|
/// Velocity-only impulse resolution (single-pass, no accumulated impulse).
/// Used by resolve_contact2d for backward compatibility with tests.
pub fn resolve_velocity2d(
  a : RigidBody2D,
  b : RigidBody2D,
  contact : Contact2D,
) -> (RigidBody2D, RigidBody2D) {
  let bias = compute_restitution_bias(a, b, contact)
  let (a_new, b_new, _, _) = resolve_velocity2d_acc(
    a, b, contact, bias, 0.0, 0.0,
  )
  (a_new, b_new)
}

///|
/// Combined velocity + position resolution (for backward compatibility with tests).
pub fn resolve_contact2d(
  a : RigidBody2D,
  b : RigidBody2D,
  contact : Contact2D,
) -> (RigidBody2D, RigidBody2D) {
  let (a_new, b_new) = resolve_velocity2d(a, b, contact)
  let inv_mass_sum = a.inv_mass + b.inv_mass
  if inv_mass_sum < 1.0e-12 {
    return (a_new, b_new)
  }
  apply_position_correction2d(a_new, b_new, contact, inv_mass_sum)
}

///|
pub fn apply_position_correction2d(
  a : RigidBody2D,
  b : RigidBody2D,
  contact : Contact2D,
  inv_mass_sum : Double,
) -> (RigidBody2D, RigidBody2D) {
  let correction_mag = if contact.penetration - slop > 0.0 {
    (contact.penetration - slop) * baumgarte_factor / inv_mass_sum
  } else {
    0.0
  }
  if correction_mag < 1.0e-12 {
    return (a, b)
  }
  let correction = contact.normal.scale(correction_mag)
  let a_new : RigidBody2D = {
    ..a,
    position: a.position.sub(correction.scale(a.inv_mass)),
  }
  let b_new : RigidBody2D = {
    ..b,
    position: b.position.add(correction.scale(b.inv_mass)),
  }
  (a_new, b_new)
}

// ============================================================
// TGS Soft Constraint Solver
// ============================================================

///|
let pi : Double = 3.14159265358979323846

///|
/// Pre-compute a soft contact constraint (TGS Soft style).
/// hertz controls contact stiffness, damping_ratio controls oscillation.
fn precompute_constraint2d(
  a : RigidBody2D,
  b : RigidBody2D,
  idx_a : Int,
  idx_b : Int,
  contact : Contact2D,
  hertz : Double,
  damping_ratio : Double,
  sub_dt : Double,
) -> ContactConstraint2D {
  let inv_mass_sum = a.inv_mass + b.inv_mass
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let n = contact.normal
  let tangent = @vector.Vec2::new(-n.y, n.x)
  let r_a_cross_n = r_a.cross(n)
  let r_b_cross_n = r_b.cross(n)
  let r_a_cross_t = r_a.cross(tangent)
  let r_b_cross_t = r_b.cross(tangent)
  // Normal effective mass (without gamma)
  let k_normal = inv_mass_sum +
    r_a_cross_n * r_a_cross_n * a.inv_inertia +
    r_b_cross_n * r_b_cross_n * b.inv_inertia
  // Tangent effective mass (no softening)
  let k_tangent = inv_mass_sum +
    r_a_cross_t * r_a_cross_t * a.inv_inertia +
    r_b_cross_t * r_b_cross_t * b.inv_inertia
  // Soft constraint parameters
  let omega = 2.0 * pi * hertz
  let gamma = 1.0 /
    (sub_dt * (2.0 * damping_ratio * omega + sub_dt * omega * omega))
  let beta = sub_dt * omega * omega * gamma
  // Softened normal mass
  let normal_mass = if k_normal + gamma > 1.0e-12 {
    1.0 / (k_normal + gamma)
  } else {
    0.0
  }
  let tangent_mass = if k_tangent > 1.0e-12 { 1.0 / k_tangent } else { 0.0 }
  // Restitution bias
  let v_a = a.velocity.add(cross_scalar_vec(a.angular_velocity, r_a))
  let v_b = b.velocity.add(cross_scalar_vec(b.angular_velocity, r_b))
  let v_rel = v_a.sub(v_b)
  let v_n = v_rel.dot(n)
  let e = if a.restitution < b.restitution {
    a.restitution
  } else {
    b.restitution
  }
  let restitution_bias = if v_n > restitution_velocity_threshold {
    e * v_n
  } else {
    0.0
  }
  {
    idx_a,
    idx_b,
    contact,
    r_a,
    r_b,
    normal_mass,
    tangent_mass,
    gamma,
    bias_coefficient: beta,
    restitution_bias,
    acc_jn: 0.0,
    acc_jt: 0.0,
  }
}

///|
/// TGS Soft velocity constraint solve.
/// Updates body velocities and accumulated impulses in-place.
fn solve_constraint2d(
  constraints : Array[ContactConstraint2D],
  ci : Int,
  bodies : Array[RigidBody2D],
) -> Unit {
  let c = constraints[ci]
  let a = bodies[c.idx_a]
  let b = bodies[c.idx_b]
  let n = c.contact.normal
  let tangent = @vector.Vec2::new(-n.y, n.x)
  // Compute current separation from current body positions
  // separation > 0 = separated, < 0 = overlapping
  let d = b.position.add(c.r_b).sub(a.position.add(c.r_a))
  let separation = d.dot(n) - c.contact.penetration
  // Bias: push apart when overlapping beyond slop
  let bias = if separation + slop < 0.0 {
    -c.bias_coefficient * (separation + slop)
  } else {
    0.0
  }
  // Current relative velocity at contact point
  let v_a = a.velocity.add(cross_scalar_vec(a.angular_velocity, c.r_a))
  let v_b = b.velocity.add(cross_scalar_vec(b.angular_velocity, c.r_b))
  let v_rel = v_a.sub(v_b)
  // --- Normal impulse ---
  let v_n = v_rel.dot(n)
  let lambda = -(v_n + c.restitution_bias + bias + c.gamma * c.acc_jn) *
    c.normal_mass
  let new_acc_jn = {
    let raw = c.acc_jn + lambda
    if raw > 0.0 {
      0.0
    } else {
      raw
    }
  }
  let delta_jn = new_acc_jn - c.acc_jn
  let cur_acc_jn = new_acc_jn
  let mut cur_acc_jt = c.acc_jt
  if delta_jn.abs() > 1.0e-15 {
    let impulse_n = n.scale(delta_jn)
    let r_a_cross_n = c.r_a.cross(n)
    let r_b_cross_n = c.r_b.cross(n)
    bodies[c.idx_a] = {
      ..a,
      velocity: a.velocity.add(impulse_n.scale(a.inv_mass)),
      angular_velocity: clamp_angular(
        a.angular_velocity + r_a_cross_n * delta_jn * a.inv_inertia,
      ),
    }
    bodies[c.idx_b] = {
      ..b,
      velocity: b.velocity.sub(impulse_n.scale(b.inv_mass)),
      angular_velocity: clamp_angular(
        b.angular_velocity - r_b_cross_n * delta_jn * b.inv_inertia,
      ),
    }
  }
  // --- Friction impulse ---
  let a2 = bodies[c.idx_a]
  let b2 = bodies[c.idx_b]
  let v_a2 = a2.velocity.add(cross_scalar_vec(a2.angular_velocity, c.r_a))
  let v_b2 = b2.velocity.add(cross_scalar_vec(b2.angular_velocity, c.r_b))
  let v_rel2 = v_a2.sub(v_b2)
  let v_t = v_rel2.dot(tangent)
  let mu = (a.friction + b.friction) * 0.5
  let friction_limit = cur_acc_jn.abs() * mu
  if v_t.abs() > 1.0e-8 {
    let lambda_t = -v_t * c.tangent_mass
    let raw_acc_jt = cur_acc_jt + lambda_t
    let new_acc_jt = if raw_acc_jt > friction_limit {
      friction_limit
    } else if raw_acc_jt < -friction_limit {
      -friction_limit
    } else {
      raw_acc_jt
    }
    let delta_jt = new_acc_jt - cur_acc_jt
    cur_acc_jt = new_acc_jt
    if delta_jt.abs() > 1.0e-15 {
      let impulse_t = tangent.scale(delta_jt)
      let r_a_cross_t = c.r_a.cross(tangent)
      let r_b_cross_t = c.r_b.cross(tangent)
      bodies[c.idx_a] = {
        ..a2,
        velocity: a2.velocity.add(impulse_t.scale(a2.inv_mass)),
        angular_velocity: clamp_angular(
          a2.angular_velocity + r_a_cross_t * delta_jt * a2.inv_inertia,
        ),
      }
      bodies[c.idx_b] = {
        ..b2,
        velocity: b2.velocity.sub(impulse_t.scale(b2.inv_mass)),
        angular_velocity: clamp_angular(
          b2.angular_velocity - r_b_cross_t * delta_jt * b2.inv_inertia,
        ),
      }
    }
  }
  // Write back accumulated impulses
  constraints[ci] = { ..c, acc_jn: cur_acc_jn, acc_jt: cur_acc_jt }
}

///|
/// TGS relaxation pass: removes excess energy by solving with bias=0, gamma=0.
fn _solve_relaxation2d(
  constraints : Array[ContactConstraint2D],
  ci : Int,
  bodies : Array[RigidBody2D],
) -> Unit {
  let c = constraints[ci]
  let a = bodies[c.idx_a]
  let b = bodies[c.idx_b]
  let n = c.contact.normal
  // Relative velocity at contact
  let v_a = a.velocity.add(cross_scalar_vec(a.angular_velocity, c.r_a))
  let v_b = b.velocity.add(cross_scalar_vec(b.angular_velocity, c.r_b))
  let v_rel = v_a.sub(v_b)
  let v_n = v_rel.dot(n)
  // Relaxation: no bias, no gamma, no restitution
  let r_a_cross_n = c.r_a.cross(n)
  let r_b_cross_n = c.r_b.cross(n)
  let k_normal = a.inv_mass +
    b.inv_mass +
    r_a_cross_n * r_a_cross_n * a.inv_inertia +
    r_b_cross_n * r_b_cross_n * b.inv_inertia
  if k_normal < 1.0e-12 {
    return
  }
  let unsoftened_mass = 1.0 / k_normal
  let lambda = -v_n * unsoftened_mass
  let new_acc_jn = {
    let raw = c.acc_jn + lambda
    if raw > 0.0 {
      0.0
    } else {
      raw
    }
  }
  let delta_jn = new_acc_jn - c.acc_jn
  if delta_jn.abs() > 1.0e-15 {
    let impulse_n = n.scale(delta_jn)
    bodies[c.idx_a] = {
      ..a,
      velocity: a.velocity.add(impulse_n.scale(a.inv_mass)),
      angular_velocity: clamp_angular(
        a.angular_velocity + r_a_cross_n * delta_jn * a.inv_inertia,
      ),
    }
    bodies[c.idx_b] = {
      ..b,
      velocity: b.velocity.sub(impulse_n.scale(b.inv_mass)),
      angular_velocity: clamp_angular(
        b.angular_velocity - r_b_cross_n * delta_jn * b.inv_inertia,
      ),
    }
  }
  // Write back accumulated impulse
  constraints[ci] = { ..c, acc_jn: new_acc_jn }
}
