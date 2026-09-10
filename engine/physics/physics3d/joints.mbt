///|
let joint_pi3d : Double = 3.14159265358979323846

///|
fn find_body_index3d(bodies : Array[RigidBody], id : Int) -> Int {
  for i = 0; i < bodies.length(); i = i + 1 {
    if bodies[i].id == id {
      return i
    }
  }
  -1
}

///|
fn rotate_by_quat(v : @math3d.Vec3, q : @math3d.Quaternion) -> @math3d.Vec3 {
  // Rotate vector v by quaternion q: q * v * q^-1
  let qv = @math3d.Quaternion::new(0.0, v.x, v.y, v.z)
  let conj = @math3d.Quaternion::new(q.w, -q.x, -q.y, -q.z)
  let result = q.multiply(qv).multiply(conj)
  @math3d.Vec3::new(result.x, result.y, result.z)
}

// ============================================================
// Distance Joint (3D)
// ============================================================

///|
pub fn precompute_distance_joint3d(
  joint : DistanceJoint3D,
  bodies : Array[RigidBody],
  sub_dt : Double,
) -> DistanceJointConstraint3D? {
  let idx_a = find_body_index3d(bodies, joint.body_a_id)
  let idx_b = find_body_index3d(bodies, joint.body_b_id)
  if idx_a < 0 || idx_b < 0 {
    return None
  }
  let a = bodies[idx_a]
  let b = bodies[idx_b]
  let r_a = rotate_by_quat(joint.local_anchor_a, a.rotation)
  let r_b = rotate_by_quat(joint.local_anchor_b, b.rotation)
  let world_a = a.position.add(r_a)
  let world_b = b.position.add(r_b)
  let delta = world_b.sub(world_a)
  let current_length = delta.length()
  let axis = if current_length > 1.0e-8 {
    delta.scale(1.0 / current_length)
  } else {
    @math3d.Vec3::unit_x()
  }
  // Effective mass along the axis
  let r_a_cross_n = r_a.cross(axis)
  let r_b_cross_n = r_b.cross(axis)
  let k = a.inv_mass +
    b.inv_mass +
    r_a_cross_n.dot(r_a_cross_n) * a.inv_inertia +
    r_b_cross_n.dot(r_b_cross_n) * b.inv_inertia
  // Soft constraint params
  let omega = 2.0 * joint_pi3d * joint.hertz
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
/// Velocities come from `vel`, not from the bodies: the joints share the solve
/// pass with the contacts, so they have to share its working set. See
/// `velocity_state.mbt`.
pub fn solve_distance_joint3d(
  constraints : Array[DistanceJointConstraint3D],
  ci : Int,
  bodies : Array[RigidBody],
  joint : DistanceJoint3D,
  vel : VelocityState3D,
) -> Unit {
  let c = constraints[ci]
  let ia = c.idx_a
  let ib = c.idx_b
  let a = bodies[ia]
  let b = bodies[ib]
  let r_a = c.r_a
  let r_b = c.r_b
  let axis = c.axis
  let world_a = a.position.add(r_a)
  let world_b = b.position.add(r_b)
  let delta = world_b.sub(world_a)
  let current_length = delta.dot(axis)
  let error = current_length - joint.rest_length
  let bias = c.bias_coefficient * error
  // Relative velocity along axis
  let avx = vel.vx[ia]
  let avy = vel.vy[ia]
  let avz = vel.vz[ia]
  let awx = vel.wx[ia]
  let awy = vel.wy[ia]
  let awz = vel.wz[ia]
  let bvx = vel.vx[ib]
  let bvy = vel.vy[ib]
  let bvz = vel.vz[ib]
  let bwx = vel.wx[ib]
  let bwy = vel.wy[ib]
  let bwz = vel.wz[ib]
  let vax = avx + (awy * r_a.z - awz * r_a.y)
  let vay = avy + (awz * r_a.x - awx * r_a.z)
  let vaz = avz + (awx * r_a.y - awy * r_a.x)
  let vbx = bvx + (bwy * r_b.z - bwz * r_b.y)
  let vby = bvy + (bwz * r_b.x - bwx * r_b.z)
  let vbz = bvz + (bwx * r_b.y - bwy * r_b.x)
  let v_rel = (vbx - vax) * axis.x + (vby - vay) * axis.y + (vbz - vaz) * axis.z
  let lambda = -(v_rel + bias + c.gamma * c.acc_impulse) * c.effective_mass
  let new_acc = c.acc_impulse + lambda
  let delta_impulse = new_acc - c.acc_impulse
  if delta_impulse.abs() > 1.0e-15 {
    let ix = axis.x * delta_impulse
    let iy = axis.y * delta_impulse
    let iz = axis.z * delta_impulse
    let r_a_cross = r_a.cross(axis)
    let r_b_cross = r_b.cross(axis)
    let a_inv_mass = a.inv_mass
    let b_inv_mass = b.inv_mass
    let sa = delta_impulse * a.inv_inertia
    let sb = delta_impulse * b.inv_inertia
    vel.vx[ia] = avx - ix * a_inv_mass
    vel.vy[ia] = avy - iy * a_inv_mass
    vel.vz[ia] = avz - iz * a_inv_mass
    vel.wx[ia] = awx - r_a_cross.x * sa
    vel.wy[ia] = awy - r_a_cross.y * sa
    vel.wz[ia] = awz - r_a_cross.z * sa
    vel.vx[ib] = bvx + ix * b_inv_mass
    vel.vy[ib] = bvy + iy * b_inv_mass
    vel.vz[ib] = bvz + iz * b_inv_mass
    vel.wx[ib] = bwx + r_b_cross.x * sb
    vel.wy[ib] = bwy + r_b_cross.y * sb
    vel.wz[ib] = bwz + r_b_cross.z * sb
  }
  constraints[ci] = { ..c, acc_impulse: new_acc, }
}

// ============================================================
// Ball Joint (3D point-to-point, 3 rows: x, y, z)
// ============================================================

///|
pub fn precompute_ball_joint3d(
  joint : BallJoint3D,
  bodies : Array[RigidBody],
  sub_dt : Double,
) -> BallJointConstraint3D? {
  let idx_a = find_body_index3d(bodies, joint.body_a_id)
  let idx_b = find_body_index3d(bodies, joint.body_b_id)
  if idx_a < 0 || idx_b < 0 {
    return None
  }
  let a = bodies[idx_a]
  let b = bodies[idx_b]
  let r_a = rotate_by_quat(joint.local_anchor_a, a.rotation)
  let r_b = rotate_by_quat(joint.local_anchor_b, b.rotation)
  // Soft constraint params
  let omega = 2.0 * joint_pi3d * joint.hertz
  let gamma = 1.0 /
    (sub_dt * (2.0 * joint.damping_ratio * omega + sub_dt * omega * omega))
  let beta = sub_dt * omega * omega * gamma
  // Effective mass for each axis
  let ux = @math3d.Vec3::unit_x()
  let uy = @math3d.Vec3::unit_y()
  let uz = @math3d.Vec3::unit_z()
  let k_x = a.inv_mass +
    b.inv_mass +
    r_a.cross(ux).dot(r_a.cross(ux)) * a.inv_inertia +
    r_b.cross(ux).dot(r_b.cross(ux)) * b.inv_inertia
  let k_y = a.inv_mass +
    b.inv_mass +
    r_a.cross(uy).dot(r_a.cross(uy)) * a.inv_inertia +
    r_b.cross(uy).dot(r_b.cross(uy)) * b.inv_inertia
  let k_z = a.inv_mass +
    b.inv_mass +
    r_a.cross(uz).dot(r_a.cross(uz)) * a.inv_inertia +
    r_b.cross(uz).dot(r_b.cross(uz)) * b.inv_inertia
  let eff_x = if k_x + gamma > 1.0e-12 { 1.0 / (k_x + gamma) } else { 0.0 }
  let eff_y = if k_y + gamma > 1.0e-12 { 1.0 / (k_y + gamma) } else { 0.0 }
  let eff_z = if k_z + gamma > 1.0e-12 { 1.0 / (k_z + gamma) } else { 0.0 }
  Some({
    idx_a,
    idx_b,
    r_a,
    r_b,
    effective_mass_x: eff_x,
    effective_mass_y: eff_y,
    effective_mass_z: eff_z,
    gamma,
    bias_coefficient: beta,
    acc_impulse_x: 0.0,
    acc_impulse_y: 0.0,
    acc_impulse_z: 0.0,
  })
}

///|
/// See `solve_distance_joint3d` for why velocities come from `vel`.
pub fn solve_ball_joint3d(
  constraints : Array[BallJointConstraint3D],
  ci : Int,
  bodies : Array[RigidBody],
  vel : VelocityState3D,
) -> Unit {
  let c = constraints[ci]
  let ia = c.idx_a
  let ib = c.idx_b
  let a = bodies[ia]
  let b = bodies[ib]
  let r_a = c.r_a
  let r_b = c.r_b
  let error = b.position.add(r_b).sub(a.position.add(r_a))
  let avx = vel.vx[ia]
  let avy = vel.vy[ia]
  let avz = vel.vz[ia]
  let awx = vel.wx[ia]
  let awy = vel.wy[ia]
  let awz = vel.wz[ia]
  let bvx = vel.vx[ib]
  let bvy = vel.vy[ib]
  let bvz = vel.vz[ib]
  let bwx = vel.wx[ib]
  let bwy = vel.wy[ib]
  let bwz = vel.wz[ib]
  let vax = avx + (awy * r_a.z - awz * r_a.y)
  let vay = avy + (awz * r_a.x - awx * r_a.z)
  let vaz = avz + (awx * r_a.y - awy * r_a.x)
  let vbx = bvx + (bwy * r_b.z - bwz * r_b.y)
  let vby = bvy + (bwz * r_b.x - bwx * r_b.z)
  let vbz = bvz + (bwx * r_b.y - bwy * r_b.x)
  let v_rel_x = vbx - vax
  let v_rel_y = vby - vay
  let v_rel_z = vbz - vaz
  // Per-axis solve
  let bias_x = c.bias_coefficient * error.x
  let lx = -(v_rel_x + bias_x + c.gamma * c.acc_impulse_x) * c.effective_mass_x
  let new_ax = c.acc_impulse_x + lx
  let dx = new_ax - c.acc_impulse_x
  let bias_y = c.bias_coefficient * error.y
  let ly = -(v_rel_y + bias_y + c.gamma * c.acc_impulse_y) * c.effective_mass_y
  let new_ay = c.acc_impulse_y + ly
  let dy = new_ay - c.acc_impulse_y
  let bias_z = c.bias_coefficient * error.z
  let lz = -(v_rel_z + bias_z + c.gamma * c.acc_impulse_z) * c.effective_mass_z
  let new_az = c.acc_impulse_z + lz
  let dz = new_az - c.acc_impulse_z
  if dx.abs() > 1.0e-15 || dy.abs() > 1.0e-15 || dz.abs() > 1.0e-15 {
    let impulse = @math3d.Vec3::new(dx, dy, dz)
    let angular_a = r_a.cross(impulse)
    let angular_b = r_b.cross(impulse)
    let a_inv_mass = a.inv_mass
    let b_inv_mass = b.inv_mass
    let a_inv_inertia = a.inv_inertia
    let b_inv_inertia = b.inv_inertia
    vel.vx[ia] = avx - dx * a_inv_mass
    vel.vy[ia] = avy - dy * a_inv_mass
    vel.vz[ia] = avz - dz * a_inv_mass
    vel.wx[ia] = awx - angular_a.x * a_inv_inertia
    vel.wy[ia] = awy - angular_a.y * a_inv_inertia
    vel.wz[ia] = awz - angular_a.z * a_inv_inertia
    vel.vx[ib] = bvx + dx * b_inv_mass
    vel.vy[ib] = bvy + dy * b_inv_mass
    vel.vz[ib] = bvz + dz * b_inv_mass
    vel.wx[ib] = bwx + angular_b.x * b_inv_inertia
    vel.wy[ib] = bwy + angular_b.y * b_inv_inertia
    vel.wz[ib] = bwz + angular_b.z * b_inv_inertia
  }
  constraints[ci] = {
    ..c,
    acc_impulse_x: new_ax,
    acc_impulse_y: new_ay,
    acc_impulse_z: new_az,
  }
}
