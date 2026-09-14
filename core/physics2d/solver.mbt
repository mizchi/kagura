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
  vel : VelocityState2D,
  use_bias : Bool,
) -> Unit {
  let c = constraints[ci]
  let ia = c.idx_a
  let ib = c.idx_b
  let a = bodies[ia]
  let b = bodies[ib]
  let a_inv_mass = a.inv_mass
  let b_inv_mass = b.inv_mass
  let a_inv_inertia = a.inv_inertia
  let b_inv_inertia = b.inv_inertia
  let r_a = c.r_a
  let r_b = c.r_b
  let n = c.contact.normal
  let nx = n.x
  let ny = n.y
  let tx = -ny
  let ty = nx
  // Current separation from current body positions: > 0 separated, < 0 overlapping.
  let dx = b.position.x + r_b.x - (a.position.x + r_a.x)
  let dy = b.position.y + r_b.y - (a.position.y + r_a.y)
  let separation = dx * nx + dy * ny - c.contact.penetration
  // Bias: push apart when overlapping beyond slop
  let bias = if use_bias && separation + slop < 0.0 {
    -c.bias_coefficient * (separation + slop)
  } else {
    0.0
  }
  // Velocities live in `vel` for the duration of the pass; see
  // `velocity_state.mbt`. The vector expressions below are expanded by hand and
  // never reassociated -- `n.scale(j).scale(inv_mass)` is `(n.x * j) * inv_mass`
  // while `w + r_cross * j * inv_inertia` associates left -- so this is
  // bit-identical to the version it replaces rather than merely close. The 2D
  // frame VRT gate compares rendered bytes, so "close" would fail it.
  let mut avx = vel.vx[ia]
  let mut avy = vel.vy[ia]
  let mut aw = vel.w[ia]
  let mut bvx = vel.vx[ib]
  let mut bvy = vel.vy[ib]
  let mut bw = vel.w[ib]
  // Current relative velocity at contact point
  let vax = avx + -aw * r_a.y
  let vay = avy + aw * r_a.x
  let vbx = bvx + -bw * r_b.y
  let vby = bvy + bw * r_b.x
  // --- Normal impulse ---
  let v_n = (vax - vbx) * nx + (vay - vby) * ny
  // On a relax pass the constraint is rigid: no bias to push overlap out, no
  // softness term, and no restitution -- restitution is energy the biased pass
  // already accounted for, and re-adding it here would defeat the point.
  let lambda = if use_bias {
    -(v_n + c.restitution_bias + bias + c.gamma * c.acc_jn) * c.normal_mass
  } else {
    // The rigid effective mass, recomputed here rather than stored on the
    // constraint. Storing it measured the same (25.1-25.5 us against
    // 25.2-25.9 us on `phase_save_contact_cache_pile_256`), so this is a design
    // choice and not a measured win: relaxation is off by default, and the
    // default path should not carry a field for it. Same expression
    // `precompute_constraint2d` uses for `k_normal`, so the value is the same.
    let r_a_cross_n = r_a.x * ny - r_a.y * nx
    let r_b_cross_n = r_b.x * ny - r_b.y * nx
    let k_normal = a_inv_mass +
      b_inv_mass +
      r_a_cross_n * r_a_cross_n * a_inv_inertia +
      r_b_cross_n * r_b_cross_n * b_inv_inertia
    if k_normal > 1.0e-12 {
      -v_n * (1.0 / k_normal)
    } else {
      0.0
    }
  }
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
    let inx = nx * delta_jn
    let iny = ny * delta_jn
    let r_a_cross_n = r_a.x * ny - r_a.y * nx
    let r_b_cross_n = r_b.x * ny - r_b.y * nx
    avx = avx + inx * a_inv_mass
    avy = avy + iny * a_inv_mass
    aw = clamp_angular(aw + r_a_cross_n * delta_jn * a_inv_inertia)
    bvx = bvx - inx * b_inv_mass
    bvy = bvy - iny * b_inv_mass
    bw = clamp_angular(bw - r_b_cross_n * delta_jn * b_inv_inertia)
  }
  // --- Friction impulse ---
  // Re-derived from the velocities the normal pass just wrote, which is what
  // re-reading `bodies[c.idx_a]` did.
  let vax2 = avx + -aw * r_a.y
  let vay2 = avy + aw * r_a.x
  let vbx2 = bvx + -bw * r_b.y
  let vby2 = bvy + bw * r_b.x
  let v_t = (vax2 - vbx2) * tx + (vay2 - vby2) * ty
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
      let itx = tx * delta_jt
      let ity = ty * delta_jt
      let r_a_cross_t = r_a.x * ty - r_a.y * tx
      let r_b_cross_t = r_b.x * ty - r_b.y * tx
      avx = avx + itx * a_inv_mass
      avy = avy + ity * a_inv_mass
      aw = clamp_angular(aw + r_a_cross_t * delta_jt * a_inv_inertia)
      bvx = bvx - itx * b_inv_mass
      bvy = bvy - ity * b_inv_mass
      bw = clamp_angular(bw - r_b_cross_t * delta_jt * b_inv_inertia)
    }
  }
  vel.vx[ia] = avx
  vel.vy[ia] = avy
  vel.w[ia] = aw
  vel.vx[ib] = bvx
  vel.vy[ib] = bvy
  vel.w[ib] = bw
  // `acc_jn` / `acc_jt` are the only mutable fields, so assign them instead of
  // rebuilding the constraint: that was one struct per constraint per iteration.
  constraints[ci].acc_jn = cur_acc_jn
  constraints[ci].acc_jt = cur_acc_jt
}
