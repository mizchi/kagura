///|
let baumgarte_factor : Double = 0.2

///|
let slop : Double = 0.005

///|
let max_angular_velocity : Double = 20.0

///|
let restitution_velocity_threshold : Double = 1.0

///|
fn clamp_angular_vec(omega : @math3d.Vec3) -> @math3d.Vec3 {
  let len = omega.length()
  if len > max_angular_velocity {
    omega.scale(max_angular_velocity / len)
  } else {
    omega
  }
}

///|
/// Pre-compute restitution bias for a 3D contact.
fn compute_restitution_bias3d(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
) -> Double {
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let v_a = a.velocity.add(a.angular_velocity.cross(r_a))
  let v_b = b.velocity.add(b.angular_velocity.cross(r_b))
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
/// Velocity impulse resolution with accumulated impulse clamping for 3D.
/// Includes angular impulse from off-center contacts.
fn resolve_velocity3d_acc(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
  restitution_bias : Double,
  acc_jn : Double,
  acc_jt : Double,
) -> (RigidBody, RigidBody, Double, Double) {
  let inv_mass_sum = a.inv_mass + b.inv_mass
  if inv_mass_sum < 1.0e-12 {
    return (a, b, acc_jn, acc_jt)
  }
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let n = contact.normal
  // Effective mass computation with angular terms
  let r_a_cross_n = r_a.cross(n)
  let r_b_cross_n = r_b.cross(n)
  let denom_n = inv_mass_sum +
    r_a_cross_n.dot(r_a_cross_n) * a.inv_inertia +
    r_b_cross_n.dot(r_b_cross_n) * b.inv_inertia
  // Current relative velocity at contact
  let v_a = a.velocity.add(a.angular_velocity.cross(r_a))
  let v_b = b.velocity.add(b.angular_velocity.cross(r_b))
  let v_rel = v_a.sub(v_b)
  // --- Normal impulse ---
  let v_n = v_rel.dot(n)
  let j_n_delta = -(v_n + restitution_bias) / denom_n
  let new_acc_jn = {
    let raw = acc_jn + j_n_delta
    if raw > 0.0 {
      0.0
    } else {
      raw
    }
  }
  let j_n = new_acc_jn - acc_jn
  let mut a_new = a
  let mut b_new = b
  if j_n.abs() > 1.0e-15 {
    let impulse_n = n.scale(j_n)
    a_new = {
      ..a_new,
      velocity: a_new.velocity.add(impulse_n.scale(a.inv_mass)),
      angular_velocity: clamp_angular_vec(
        a_new.angular_velocity.add(r_a_cross_n.scale(j_n * a.inv_inertia)),
      ),
    }
    b_new = {
      ..b_new,
      velocity: b_new.velocity.sub(impulse_n.scale(b.inv_mass)),
      angular_velocity: clamp_angular_vec(
        b_new.angular_velocity.sub(r_b_cross_n.scale(j_n * b.inv_inertia)),
      ),
    }
  }
  // --- Friction impulse ---
  let v_a2 = a_new.velocity.add(a_new.angular_velocity.cross(r_a))
  let v_b2 = b_new.velocity.add(b_new.angular_velocity.cross(r_b))
  let v_rel2 = v_a2.sub(v_b2)
  let tangent_vel = v_rel2.sub(n.scale(v_rel2.dot(n)))
  let tangent_len = tangent_vel.length()
  let mu = (a.friction + b.friction) * 0.5
  let friction_limit = new_acc_jn.abs() * mu
  let mut new_acc_jt = acc_jt
  if tangent_len > 1.0e-8 {
    let tangent = tangent_vel.scale(1.0 / tangent_len)
    let r_a_cross_t = r_a.cross(tangent)
    let r_b_cross_t = r_b.cross(tangent)
    let denom_t = inv_mass_sum +
      r_a_cross_t.dot(r_a_cross_t) * a.inv_inertia +
      r_b_cross_t.dot(r_b_cross_t) * b.inv_inertia
    let v_t = v_rel2.dot(tangent)
    let j_t_delta = -v_t / denom_t
    let raw_acc_jt = acc_jt + j_t_delta
    new_acc_jt = if raw_acc_jt > friction_limit {
      friction_limit
    } else if raw_acc_jt < -friction_limit {
      -friction_limit
    } else {
      raw_acc_jt
    }
    let j_t = new_acc_jt - acc_jt
    if j_t.abs() > 1.0e-15 {
      let impulse_t = tangent.scale(j_t)
      a_new = {
        ..a_new,
        velocity: a_new.velocity.add(impulse_t.scale(a.inv_mass)),
        angular_velocity: clamp_angular_vec(
          a_new.angular_velocity.add(r_a_cross_t.scale(j_t * a.inv_inertia)),
        ),
      }
      b_new = {
        ..b_new,
        velocity: b_new.velocity.sub(impulse_t.scale(b.inv_mass)),
        angular_velocity: clamp_angular_vec(
          b_new.angular_velocity.sub(r_b_cross_t.scale(j_t * b.inv_inertia)),
        ),
      }
    }
  }
  (a_new, b_new, new_acc_jn, new_acc_jt)
}

///|
/// Single-pass velocity resolution (backward compat).
pub fn resolve_velocity3d(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
) -> (RigidBody, RigidBody) {
  let bias = compute_restitution_bias3d(a, b, contact)
  let (a_new, b_new, _, _) = resolve_velocity3d_acc(
    a, b, contact, bias, 0.0, 0.0,
  )
  (a_new, b_new)
}

///|
/// Combined velocity + position resolution (backward compat).
pub fn resolve_contact(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
) -> (RigidBody, RigidBody) {
  let (a_new, b_new) = resolve_velocity3d(a, b, contact)
  let inv_mass_sum = a.inv_mass + b.inv_mass
  if inv_mass_sum < 1.0e-12 {
    return (a_new, b_new)
  }
  apply_position_correction(a_new, b_new, contact, inv_mass_sum)
}

///|
fn apply_position_correction(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
  inv_mass_sum : Double,
) -> (RigidBody, RigidBody) {
  let correction_mag = if contact.penetration - slop > 0.0 {
    (contact.penetration - slop) * baumgarte_factor / inv_mass_sum
  } else {
    0.0
  }
  if correction_mag < 1.0e-12 {
    return (a, b)
  }
  let correction = contact.normal.scale(correction_mag)
  let a_new = { ..a, position: a.position.sub(correction.scale(a.inv_mass)) }
  let b_new = { ..b, position: b.position.add(correction.scale(b.inv_mass)) }
  (a_new, b_new)
}

// ============================================================
// TGS Soft Constraint Solver (3D)
// ============================================================

///|
let pi3d : Double = 3.14159265358979323846

///|
fn precompute_constraint3d(
  a : RigidBody,
  b : RigidBody,
  idx_a : Int,
  idx_b : Int,
  contact : Contact,
  hertz : Double,
  damping_ratio : Double,
  sub_dt : Double,
) -> ContactConstraint3D {
  let inv_mass_sum = a.inv_mass + b.inv_mass
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let n = contact.normal
  let r_a_cross_n = r_a.cross(n)
  let r_b_cross_n = r_b.cross(n)
  let k_normal = inv_mass_sum +
    r_a_cross_n.dot(r_a_cross_n) * a.inv_inertia +
    r_b_cross_n.dot(r_b_cross_n) * b.inv_inertia
  // Compute tangent direction from relative velocity
  let v_a = a.velocity.add(a.angular_velocity.cross(r_a))
  let v_b = b.velocity.add(b.angular_velocity.cross(r_b))
  let v_rel = v_a.sub(v_b)
  let v_n_scalar = v_rel.dot(n)
  let tangent_vel = v_rel.sub(n.scale(v_n_scalar))
  let tangent_len = tangent_vel.length()
  let tangent = if tangent_len > 1.0e-8 {
    tangent_vel.scale(1.0 / tangent_len)
  } else {
    let ax = if n.x.abs() < 0.9 {
      @math3d.Vec3::unit_x()
    } else {
      @math3d.Vec3::unit_y()
    }
    n.cross(ax).normalize()
  }
  let r_a_cross_t = r_a.cross(tangent)
  let r_b_cross_t = r_b.cross(tangent)
  let k_tangent = inv_mass_sum +
    r_a_cross_t.dot(r_a_cross_t) * a.inv_inertia +
    r_b_cross_t.dot(r_b_cross_t) * b.inv_inertia
  // Soft constraint params
  let omega = 2.0 * pi3d * hertz
  let gamma = 1.0 /
    (sub_dt * (2.0 * damping_ratio * omega + sub_dt * omega * omega))
  let beta = sub_dt * omega * omega * gamma
  let normal_mass = if k_normal + gamma > 1.0e-12 {
    1.0 / (k_normal + gamma)
  } else {
    0.0
  }
  let tangent_mass = if k_tangent > 1.0e-12 { 1.0 / k_tangent } else { 0.0 }
  let e = if a.restitution < b.restitution {
    a.restitution
  } else {
    b.restitution
  }
  let restitution_bias = if v_n_scalar > restitution_velocity_threshold {
    e * v_n_scalar
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
    tangent_dir: tangent,
    gamma,
    bias_coefficient: beta,
    restitution_bias,
    acc_jn: 0.0,
    acc_jt: 0.0,
  }
}

///|
fn solve_constraint3d(
  constraints : Array[ContactConstraint3D],
  ci : Int,
  bodies : Array[RigidBody],
) -> Unit {
  let c = constraints[ci]
  let a = bodies[c.idx_a]
  let b = bodies[c.idx_b]
  let n = c.contact.normal
  // Current separation
  let d = b.position.add(c.r_b).sub(a.position.add(c.r_a))
  let separation = d.dot(n) - c.contact.penetration
  let bias = if separation + slop < 0.0 {
    -c.bias_coefficient * (separation + slop)
  } else {
    0.0
  }
  let v_a = a.velocity.add(a.angular_velocity.cross(c.r_a))
  let v_b = b.velocity.add(b.angular_velocity.cross(c.r_b))
  let v_rel = v_a.sub(v_b)
  // --- Normal ---
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
      angular_velocity: clamp_angular_vec(
        a.angular_velocity.add(r_a_cross_n.scale(delta_jn * a.inv_inertia)),
      ),
    }
    bodies[c.idx_b] = {
      ..b,
      velocity: b.velocity.sub(impulse_n.scale(b.inv_mass)),
      angular_velocity: clamp_angular_vec(
        b.angular_velocity.sub(r_b_cross_n.scale(delta_jn * b.inv_inertia)),
      ),
    }
  }
  // --- Friction ---
  let a2 = bodies[c.idx_a]
  let b2 = bodies[c.idx_b]
  let v_a2 = a2.velocity.add(a2.angular_velocity.cross(c.r_a))
  let v_b2 = b2.velocity.add(b2.angular_velocity.cross(c.r_b))
  let v_rel2 = v_a2.sub(v_b2)
  let tangent = c.tangent_dir
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
        angular_velocity: clamp_angular_vec(
          a2.angular_velocity.add(r_a_cross_t.scale(delta_jt * a2.inv_inertia)),
        ),
      }
      bodies[c.idx_b] = {
        ..b2,
        velocity: b2.velocity.sub(impulse_t.scale(b2.inv_mass)),
        angular_velocity: clamp_angular_vec(
          b2.angular_velocity.sub(r_b_cross_t.scale(delta_jt * b2.inv_inertia)),
        ),
      }
    }
  }
  constraints[ci] = { ..c, acc_jn: cur_acc_jn, acc_jt: cur_acc_jt }
}
