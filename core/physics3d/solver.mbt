///|
let baumgarte_factor : Double = 0.2

///|
let slop : Double = 0.005

///|
let max_angular_velocity : Double = 20.0

///|
let max_angular_velocity_sq : Double = max_angular_velocity *
  max_angular_velocity

///|
let restitution_velocity_threshold : Double = 1.0

///|
fn clamp_angular_vec(omega : @math3d.Vec3) -> @math3d.Vec3 {
  let len_sq = omega.length_squared()
  if len_sq > max_angular_velocity_sq {
    omega.scale(max_angular_velocity / len_sq.sqrt())
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
  let a_new = { ..a, position: a.position.sub(correction.scale(a.inv_mass)), }
  let b_new = { ..b, position: b.position.add(correction.scale(b.inv_mass)), }
  (a_new, b_new)
}

// ============================================================
// TGS Soft Constraint Solver (3D)
// ============================================================

///|
let pi3d : Double = 3.14159265358979323846

///|
fn soft_constraint_params3d(
  hertz : Double,
  damping_ratio : Double,
  sub_dt : Double,
) -> (Double, Double) {
  let omega = 2.0 * pi3d * hertz
  let gamma = 1.0 /
    (sub_dt * (2.0 * damping_ratio * omega + sub_dt * omega * omega))
  let bias_coefficient = sub_dt * omega * omega * gamma
  (gamma, bias_coefficient)
}

///|
fn precompute_constraint3d(
  a : RigidBody,
  b : RigidBody,
  idx_a : Int,
  idx_b : Int,
  contact : Contact,
  gamma : Double,
  bias_coefficient : Double,
) -> ContactConstraintRuntime3D {
  let inv_mass_sum = a.inv_mass + b.inv_mass
  let r_a = contact.contact_point.sub(a.position)
  let r_b = contact.contact_point.sub(b.position)
  let n = contact.normal
  let r_a_cross_n = r_a.cross(n)
  let r_b_cross_n = r_b.cross(n)
  let k_normal = inv_mass_sum +
    r_a_cross_n.dot(r_a_cross_n) * a.inv_inertia +
    r_b_cross_n.dot(r_b_cross_n) * b.inv_inertia
  // Relative velocity at the contact, and the tangent direction derived from
  // it, as scalars. These are pure temporaries -- only `tangent` is kept -- and
  // this runs once per contact per frame, so building five or six `Vec3` here to
  // throw them away was the single largest allocation site left in the frame
  // after the solve pass moved to flat arrays. Grouping is preserved verbatim:
  // `scale(1.0 / len)` is `t * (1.0 / len)`, not `t / len`.
  let av = a.velocity
  let bv = b.velocity
  let aw = a.angular_velocity
  let bw = b.angular_velocity
  let mut vrx = 0.0
  let mut vry = 0.0
  let mut vrz = 0.0
  if aw.x * aw.x + aw.y * aw.y + aw.z * aw.z <= 1.0e-24 &&
    bw.x * bw.x + bw.y * bw.y + bw.z * bw.z <= 1.0e-24 {
    vrx = av.x - bv.x
    vry = av.y - bv.y
    vrz = av.z - bv.z
  } else {
    let vax = av.x + (aw.y * r_a.z - aw.z * r_a.y)
    let vay = av.y + (aw.z * r_a.x - aw.x * r_a.z)
    let vaz = av.z + (aw.x * r_a.y - aw.y * r_a.x)
    let vbx = bv.x + (bw.y * r_b.z - bw.z * r_b.y)
    let vby = bv.y + (bw.z * r_b.x - bw.x * r_b.z)
    let vbz = bv.z + (bw.x * r_b.y - bw.y * r_b.x)
    vrx = vax - vbx
    vry = vay - vby
    vrz = vaz - vbz
  }
  let v_n_scalar = vrx * n.x + vry * n.y + vrz * n.z
  let tvx = vrx - n.x * v_n_scalar
  let tvy = vry - n.y * v_n_scalar
  let tvz = vrz - n.z * v_n_scalar
  let tangent_len = (tvx * tvx + tvy * tvy + tvz * tvz).sqrt()
  let tangent = if tangent_len > 1.0e-8 {
    let inv = 1.0 / tangent_len
    @math3d.Vec3::new(tvx * inv, tvy * inv, tvz * inv)
  } else {
    // Degenerate: no sliding velocity, so pick any axis orthogonal to the
    // normal. `Vec3::normalize` zeroes below 1e-12 rather than dividing.
    let axx = if n.x.abs() < 0.9 { 1.0 } else { 0.0 }
    let axy = if n.x.abs() < 0.9 { 0.0 } else { 1.0 }
    let cx = n.y * 0.0 - n.z * axy
    let cy = n.z * axx - n.x * 0.0
    let cz = n.x * axy - n.y * axx
    let clen = (cx * cx + cy * cy + cz * cz).sqrt()
    if clen < 1.0e-12 {
      @math3d.Vec3::zero()
    } else {
      let inv = 1.0 / clen
      @math3d.Vec3::new(cx * inv, cy * inv, cz * inv)
    }
  }
  let r_a_cross_t = r_a.cross(tangent)
  let r_b_cross_t = r_b.cross(tangent)
  let k_tangent = inv_mass_sum +
    r_a_cross_t.dot(r_a_cross_t) * a.inv_inertia +
    r_b_cross_t.dot(r_b_cross_t) * b.inv_inertia
  // Soft constraint params
  let normal_mass = if k_normal + gamma > 1.0e-12 {
    1.0 / (k_normal + gamma)
  } else {
    0.0
  }
  let unbiased_normal_mass = if k_normal > 1.0e-12 {
    1.0 / k_normal
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
    r_a_cross_n,
    r_b_cross_n,
    r_a_cross_t,
    r_b_cross_t,
    has_normal_angular: r_a_cross_n.length_squared() > 1.0e-24 ||
    r_b_cross_n.length_squared() > 1.0e-24,
    has_tangent_angular: r_a_cross_t.length_squared() > 1.0e-24 ||
    r_b_cross_t.length_squared() > 1.0e-24,
    normal_mass,
    unbiased_normal_mass,
    tangent_mass,
    tangent_dir: tangent,
    friction: (a.friction + b.friction) * 0.5,
    gamma,
    bias_coefficient,
    restitution_bias,
    acc_jn: 0.0,
    acc_jt: 0.0,
  }
}

///|
/// One Gauss-Seidel pass over a single contact constraint.
///
/// Velocities come from `vel` rather than from the bodies, and stay there: this
/// used to read two `RigidBody` structs and write two freshly built ones, with
/// every intermediate a `Vec3`. See `velocity_state.mbt` for what that cost.
///
/// The vector expressions below are expanded by hand rather than reassociated.
/// Grouping is load-bearing — `n.scale(j).scale(inv_mass)` is
/// `(n.x * j) * inv_mass` while `r.scale(j * inv_inertia)` is
/// `r.x * (j * inv_inertia)` — and keeping each site's grouping is what makes this
/// bit-identical to the version it replaces rather than merely close.
fn solve_constraint3d(
  constraints : Array[ContactConstraintRuntime3D],
  ci : Int,
  bodies : Array[RigidBody],
  vel : VelocityState3D,
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
  let contact = c.contact
  let n = contact.normal
  let nx = n.x
  let ny = n.y
  let nz = n.z
  let r_a = c.r_a
  let r_b = c.r_b
  // Current separation.
  let dx = b.position.x + r_b.x - (a.position.x + r_a.x)
  let dy = b.position.y + r_b.y - (a.position.y + r_a.y)
  let dz = b.position.z + r_b.z - (a.position.z + r_a.z)
  let separation = dx * nx + dy * ny + dz * nz - contact.penetration
  let bias = if use_bias && separation + slop < 0.0 {
    -c.bias_coefficient * (separation + slop)
  } else {
    0.0
  }
  let mut avx = vel.vx[ia]
  let mut avy = vel.vy[ia]
  let mut avz = vel.vz[ia]
  let mut awx = vel.wx[ia]
  let mut awy = vel.wy[ia]
  let mut awz = vel.wz[ia]
  let mut bvx = vel.vx[ib]
  let mut bvy = vel.vy[ib]
  let mut bvz = vel.vz[ib]
  let mut bwx = vel.wx[ib]
  let mut bwy = vel.wy[ib]
  let mut bwz = vel.wz[ib]
  let mut a_has_angular = false
  let mut b_has_angular = false
  // --- Normal ---
  let v_n = if !c.has_normal_angular {
    (avx - bvx) * nx + (avy - bvy) * ny + (avz - bvz) * nz
  } else {
    a_has_angular = awx * awx + awy * awy + awz * awz > 1.0e-24
    b_has_angular = bwx * bwx + bwy * bwy + bwz * bwz > 1.0e-24
    if a_has_angular || b_has_angular {
      let vax = avx + (awy * r_a.z - awz * r_a.y)
      let vay = avy + (awz * r_a.x - awx * r_a.z)
      let vaz = avz + (awx * r_a.y - awy * r_a.x)
      let vbx = bvx + (bwy * r_b.z - bwz * r_b.y)
      let vby = bvy + (bwz * r_b.x - bwx * r_b.z)
      let vbz = bvz + (bwx * r_b.y - bwy * r_b.x)
      (vax - vbx) * nx + (vay - vby) * ny + (vaz - vbz) * nz
    } else {
      (avx - bvx) * nx + (avy - bvy) * ny + (avz - bvz) * nz
    }
  }
  // On a relax pass the constraint is rigid: no bias to push overlap out, no
  // softness term, and no restitution -- restitution is energy the biased pass
  // already accounted for, and re-adding it here would defeat the point.
  let lambda = if use_bias {
    -(v_n + c.restitution_bias + bias + c.gamma * c.acc_jn) * c.normal_mass
  } else {
    -v_n * c.unbiased_normal_mass
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
    let inz = nz * delta_jn
    avx = avx + inx * a_inv_mass
    avy = avy + iny * a_inv_mass
    avz = avz + inz * a_inv_mass
    bvx = bvx - inx * b_inv_mass
    bvy = bvy - iny * b_inv_mass
    bvz = bvz - inz * b_inv_mass
    if c.has_normal_angular {
      let sa = delta_jn * a_inv_inertia
      let r_a_cross_n = c.r_a_cross_n
      awx = awx + r_a_cross_n.x * sa
      awy = awy + r_a_cross_n.y * sa
      awz = awz + r_a_cross_n.z * sa
      let a_len_sq = awx * awx + awy * awy + awz * awz
      if a_len_sq > max_angular_velocity_sq {
        let scale = max_angular_velocity / a_len_sq.sqrt()
        awx = awx * scale
        awy = awy * scale
        awz = awz * scale
      }
      let sb = delta_jn * b_inv_inertia
      let r_b_cross_n = c.r_b_cross_n
      bwx = bwx - r_b_cross_n.x * sb
      bwy = bwy - r_b_cross_n.y * sb
      bwz = bwz - r_b_cross_n.z * sb
      let b_len_sq = bwx * bwx + bwy * bwy + bwz * bwz
      if b_len_sq > max_angular_velocity_sq {
        let scale = max_angular_velocity / b_len_sq.sqrt()
        bwx = bwx * scale
        bwy = bwy * scale
        bwz = bwz * scale
      }
      if a_inv_inertia >= 1.0e-12 {
        a_has_angular = true
      }
      if b_inv_inertia >= 1.0e-12 {
        b_has_angular = true
      }
    }
  }
  // --- Friction ---
  let friction_limit = -cur_acc_jn * c.friction
  if friction_limit > 1.0e-15 {
    let tangent = c.tangent_dir
    let tx = tangent.x
    let ty = tangent.y
    let tz = tangent.z
    let v_t = if !c.has_tangent_angular {
      (avx - bvx) * tx + (avy - bvy) * ty + (avz - bvz) * tz
    } else {
      if !c.has_normal_angular {
        a_has_angular = awx * awx + awy * awy + awz * awz > 1.0e-24
        b_has_angular = bwx * bwx + bwy * bwy + bwz * bwz > 1.0e-24
      }
      if !a_has_angular && !b_has_angular {
        (avx - bvx) * tx + (avy - bvy) * ty + (avz - bvz) * tz
      } else {
        let vax = avx + (awy * r_a.z - awz * r_a.y)
        let vay = avy + (awz * r_a.x - awx * r_a.z)
        let vaz = avz + (awx * r_a.y - awy * r_a.x)
        let vbx = bvx + (bwy * r_b.z - bwz * r_b.y)
        let vby = bvy + (bwz * r_b.x - bwx * r_b.z)
        let vbz = bvz + (bwx * r_b.y - bwy * r_b.x)
        (vax - vbx) * tx + (vay - vby) * ty + (vaz - vbz) * tz
      }
    }
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
      let itz = tz * delta_jt
      avx = avx + itx * a_inv_mass
      avy = avy + ity * a_inv_mass
      avz = avz + itz * a_inv_mass
      bvx = bvx - itx * b_inv_mass
      bvy = bvy - ity * b_inv_mass
      bvz = bvz - itz * b_inv_mass
      if c.has_tangent_angular {
        let sa = delta_jt * a_inv_inertia
        let r_a_cross_t = c.r_a_cross_t
        awx = awx + r_a_cross_t.x * sa
        awy = awy + r_a_cross_t.y * sa
        awz = awz + r_a_cross_t.z * sa
        let a_len_sq = awx * awx + awy * awy + awz * awz
        if a_len_sq > max_angular_velocity_sq {
          let scale = max_angular_velocity / a_len_sq.sqrt()
          awx = awx * scale
          awy = awy * scale
          awz = awz * scale
        }
        let sb = delta_jt * b_inv_inertia
        let r_b_cross_t = c.r_b_cross_t
        bwx = bwx - r_b_cross_t.x * sb
        bwy = bwy - r_b_cross_t.y * sb
        bwz = bwz - r_b_cross_t.z * sb
        let b_len_sq = bwx * bwx + bwy * bwy + bwz * bwz
        if b_len_sq > max_angular_velocity_sq {
          let scale = max_angular_velocity / b_len_sq.sqrt()
          bwx = bwx * scale
          bwy = bwy * scale
          bwz = bwz * scale
        }
      }
    }
  }
  // Unconditional stores: when nothing was applied these write back the values
  // just read, which is what the AoS version's `bodies_dirty` guard achieved by
  // skipping an equivalent no-op struct rebuild.
  vel.vx[ia] = avx
  vel.vy[ia] = avy
  vel.vz[ia] = avz
  vel.wx[ia] = awx
  vel.wy[ia] = awy
  vel.wz[ia] = awz
  vel.vx[ib] = bvx
  vel.vy[ib] = bvy
  vel.vz[ib] = bvz
  vel.wx[ib] = bwx
  vel.wy[ib] = bwy
  vel.wz[ib] = bwz
  constraints[ci].acc_jn = cur_acc_jn
  constraints[ci].acc_jt = cur_acc_jt
}
