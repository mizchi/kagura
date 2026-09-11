///|
pub fn PhysicsWorld::new(
  gravity : @math3d.Vec3,
  broadphase_cell_size : Double,
  solver_config? : SolverConfig3D = SolverConfig3D::default(),
) -> PhysicsWorld {
  {
    bodies: [],
    gravity,
    broadphase: @collision3d.SpatialHashGrid::new(broadphase_cell_size),
    solver_config,
    contact_cache: ContactCache3D::new(),
    velocity_state: VelocityState3D::new(),
    joints_distance: [],
    joints_ball: [],
  }
}

///|
pub fn PhysicsWorld::add_body(self : PhysicsWorld, body : RigidBody) -> Unit {
  self.bodies.push(body)
}

///|
pub fn PhysicsWorld::get_body(self : PhysicsWorld, id : Int) -> RigidBody? {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    if self.bodies[i].id == id {
      return Some(self.bodies[i])
    }
  }
  None
}

///|
pub fn PhysicsWorld::body_count(self : PhysicsWorld) -> Int {
  self.bodies.length()
}

///|
pub fn PhysicsWorld::apply_force(
  self : PhysicsWorld,
  body_id : Int,
  force : @math3d.Vec3,
) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    if self.bodies[i].id == body_id {
      self.bodies[i] = self.bodies[i].apply_force(force)
      break
    }
  }
}

///|
pub fn PhysicsWorld::apply_impulse(
  self : PhysicsWorld,
  body_id : Int,
  impulse : @math3d.Vec3,
) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    if self.bodies[i].id == body_id {
      self.bodies[i] = self.bodies[i].apply_impulse(impulse)
      break
    }
  }
}

///|
pub fn PhysicsWorld::add_distance_joint(
  self : PhysicsWorld,
  joint : DistanceJoint3D,
) -> Unit {
  self.joints_distance.push(joint)
}

///|
pub fn PhysicsWorld::add_ball_joint(
  self : PhysicsWorld,
  joint : BallJoint3D,
) -> Unit {
  self.joints_ball.push(joint)
}

///|
let sleep_velocity_threshold3d : Double = 0.5

///|
/// Whether the solver should move this body at all.
///
/// A sleeping body is as immovable as a static one for the duration of its sleep.
/// Treating it that way is what makes sleep hold: warm starting and
/// `solve_constraint3d` write velocity into whatever body a constraint names, and
/// neither used to check, so a sleeping pile was kicked awake by its own cached
/// impulses every time it settled. Measured on a 64-sphere pile: the island
/// reached full sleep and was woken again 22 times in 1200 frames, never holding
/// it for more than a few dozen frames.
fn body_is_solver_active3d(body : RigidBody) -> Bool {
  body.is_dynamic() && !body.is_sleeping
}

///|
/// Distance from the centre of mass to the collider's outermost point.
fn body_max_extent3d(body : RigidBody) -> Double {
  match body.collider {
    SphereShape(offset, radius) => offset.length() + radius
    AABBShape(half_extents, offset) => offset.length() + half_extents.length()
  }
}

///|
/// One scale-aware speed for the sleep test: the linear speed plus the speed
/// angular motion produces at the body's outermost point.
///
/// This replaces a separate angular threshold, which could not be set correctly
/// for two reasons. It has different units from the linear one, so the two are
/// not comparable and the stricter one silently decides everything; and the
/// speed a given spin produces depends on the body's size, so one rad/s figure
/// cannot suit a marble and a crate at once.
///
/// Measured, the old pair made the angular test roughly five times stricter than
/// the linear one for the 0.5-radius spheres in the benchmark fixtures (0.2 rad/s
/// is 0.1 units/s at the surface, against a 0.5 units/s linear threshold), and it
/// was the sole reason a dense pile never slept: at 1200 frames every body passed
/// the linear test and 164 of 256 failed the angular one. Under this criterion a
/// 64-body pile settles completely. Box2D v3 tests the same quantity.
fn body_sleep_velocity3d(body : RigidBody) -> Double {
  body.velocity.length() +
  body_max_extent3d(body) * body.angular_velocity.length()
}

///|
let sleep_time_threshold3d : Double = 0.5

///|
fn uf_find3d(parent : Array[Int], i : Int) -> Int {
  let mut x = i
  for ;; {
    if parent[x] == x {
      break x
    }
    parent[x] = parent[parent[x]]
    x = parent[x]
  }
}

///|
fn uf_union3d(parent : Array[Int], rank : Array[Int], a : Int, b : Int) -> Unit {
  let ra = uf_find3d(parent, a)
  let rb = uf_find3d(parent, b)
  if ra == rb {
    return
  }
  if rank[ra] < rank[rb] {
    parent[ra] = rb
  } else if rank[ra] > rank[rb] {
    parent[rb] = ra
  } else {
    parent[rb] = ra
    rank[ra] = rank[ra] + 1
  }
}

///|
/// Phase 1: rebuild the broadphase from current body AABBs and return the
/// candidate pairs.
///
/// `step` and `world_bench.mbt` both call this, so the benchmark can never
/// drift away from the shipped pipeline.
fn PhysicsWorld::phase_broadphase_pairs(self : PhysicsWorld) -> Int {
  let body_count = self.bodies.length()
  self.broadphase.clear()
  for i = 0; i < body_count; i = i + 1 {
    self.broadphase.insert(i, self.bodies[i].world_aabb())
  }
  // Returns a count, and leaves the pairs in the grid's pooled columns. The
  // tuple-returning `get_pairs` is still there for callers outside the step
  // path; inside it, one tuple per pair was 1438 allocations a frame that
  // `phase_contact_constraints` unpacked on the next line.
  self.broadphase.get_pairs_into()
}

///|
/// Phase 2: narrowphase over the candidate pairs, constraint precompute, and
/// warm starting from the previous frame's impulse cache.
///
/// Warm starting applies impulses to `self.bodies`, so this phase mutates the
/// world as well as returning the constraints.
fn PhysicsWorld::phase_contact_constraints(
  self : PhysicsWorld,
  pair_count : Int,
  sub_dt : Double,
) -> Array[ContactConstraintRuntime3D] {
  let config = self.solver_config
  let (contact_gamma, contact_bias_coefficient) = soft_constraint_params3d(
    config.contact_hertz,
    config.contact_damping_ratio,
    sub_dt,
  )
  let constraints : Array[ContactConstraintRuntime3D] = Array(
    capacity=pair_count,
  )
  let pair_id_a = self.broadphase.pair_id_a
  let pair_id_b = self.broadphase.pair_id_b
  for p = 0; p < pair_count; p = p + 1 {
    let idx_a = pair_id_a[p]
    let idx_b = pair_id_b[p]
    let mut body_a = self.bodies[idx_a]
    let mut body_b = self.bodies[idx_b]
    // A pair with nothing movable on either side has no constraint to solve.
    // That covers static/static, static/asleep and asleep/asleep -- and skipping
    // the last two is what lets a settled island stay settled, as well as making
    // a sleeping scene cheap: its contacts are never built or solved.
    let active_a = body_is_solver_active3d(body_a)
    let active_b = body_is_solver_active3d(body_b)
    if !active_a && !active_b {
      continue
    }
    // One side is moving and the other is asleep: the sleeper has to rejoin the
    // simulation, or a body landing on a settled pile would rest on something
    // that never reacts. Waking spreads one ring of contacts per frame, which is
    // simpler than the island bookkeeping Box2D uses to wake all at once, and
    // errs on the side of the pile staying rigid for those frames.
    if !active_b && body_b.is_dynamic() {
      body_b = { ..body_b, is_sleeping: false, sleep_timer: 0.0, }
      self.bodies[idx_b] = body_b
    } else if !active_a && body_a.is_dynamic() {
      body_a = { ..body_a, is_sleeping: false, sleep_timer: 0.0, }
      self.bodies[idx_a] = body_a
    }
    if body_a.inv_mass >= 1.0e-12 || body_b.inv_mass >= 1.0e-12 {
      match generate_contact(body_a, body_b) {
        Some(contact) => {
          let constraint = precompute_constraint3d(
            body_a, body_b, idx_a, idx_b, contact, contact_gamma, contact_bias_coefficient,
          )
          // Warm starting: look up cached impulses from previous frame
          let cached = self.contact_cache.find(body_a.id, body_b.id)
          if cached >= 0 {
            let cache = self.contact_cache
            let dot = cache.normal_x[cached] * contact.normal.x +
              cache.normal_y[cached] * contact.normal.y +
              cache.normal_z[cached] * contact.normal.z
            if dot > 0.9 {
              let warm_factor = 0.8
              let jn = cache.normal_impulse[cached] * warm_factor
              let jt = cache.tangent_impulse[cached] * warm_factor
              // `acc_jn` / `acc_jt` are the constraint's only mutable fields, so
              // assign them rather than rebuilding the struct: `{ ..constraint,
              // .. }` allocated a second ~30-field object for every cached
              // contact, on top of the one `precompute_constraint3d` just built.
              constraint.acc_jn = jn
              constraint.acc_jt = jt
              if jn.abs() > 1.0e-15 || jt.abs() > 1.0e-15 {
                // Measured, this block was 517us of the 918us this phase costs on
                // a 256-sphere pile -- 56% of it, and ~14% of the frame. Not the
                // arithmetic: the allocation. Per cached contact it built three
                // structs and seven `Vec3` to add one vector to two velocities.
                // Expanded to scalars it is two structs and two `Vec3`.
                //
                // Grouping preserved: `n.scale(jn).add(t.scale(jt))` is
                // `n.x * jn + t.x * jt`, and `.scale(inv_mass)` applies after.
                let n = contact.normal
                let t = constraint.tangent_dir
                let ix = n.x * jn + t.x * jt
                let iy = n.y * jn + t.y * jt
                let iz = n.z * jn + t.z * jt
                let ba = self.bodies[idx_a]
                let ima = body_a.inv_mass
                self.bodies[idx_a] = {
                  ..ba,
                  velocity: @math3d.Vec3::new(
                    ba.velocity.x + ix * ima,
                    ba.velocity.y + iy * ima,
                    ba.velocity.z + iz * ima,
                  ),
                }
                let bb = self.bodies[idx_b]
                let imb = body_b.inv_mass
                self.bodies[idx_b] = {
                  ..bb,
                  velocity: @math3d.Vec3::new(
                    bb.velocity.x - ix * imb,
                    bb.velocity.y - iy * imb,
                    bb.velocity.z - iz * imb,
                  ),
                }
              }
            }
          }
          constraints.push(constraint)
        }
        None => ()
      }
    }
  }
  constraints
}

///|
/// Phase 3: precompute the joint constraints for this frame.
fn PhysicsWorld::phase_joint_constraints(
  self : PhysicsWorld,
  sub_dt : Double,
) -> (Array[DistanceJointConstraint3D], Array[BallJointConstraint3D]) {
  let distance_joint_count = self.joints_distance.length()
  let dist_constraints : Array[DistanceJointConstraint3D] = Array(
    capacity=distance_joint_count,
  )
  for j = 0; j < distance_joint_count; j = j + 1 {
    match
      precompute_distance_joint3d(self.joints_distance[j], self.bodies, sub_dt) {
      Some(c) => dist_constraints.push(c)
      None => ()
    }
  }
  let ball_joint_count = self.joints_ball.length()
  let ball_constraints : Array[BallJointConstraint3D] = Array(
    capacity=ball_joint_count,
  )
  for j = 0; j < ball_joint_count; j = j + 1 {
    match precompute_ball_joint3d(self.joints_ball[j], self.bodies, sub_dt) {
      Some(c) => ball_constraints.push(c)
      None => ()
    }
  }
  (dist_constraints, ball_constraints)
}

///|
/// Phase 4a: integrate velocities for one substep.
///
/// Reads and writes `vel`, not the bodies. `step` loads the buffer once before
/// the substep loop and stores it once after, so a substep's accelerations,
/// impulses and the next substep's accelerations all land in the same flat
/// arrays -- which is what removes the `RigidBody` rebuild that used to happen
/// here once per moving body per substep (2048 of them a frame on the 256-body
/// pile, each carrying four or five `Vec3`).
///
/// Grouping is preserved site for site: `scale(s)` is `x * s` with `s` computed
/// once, and `Vec3::length_squared` is `((x*x) + (y*y)) + (z*z)`.
fn PhysicsWorld::phase_integrate_velocities(
  self : PhysicsWorld,
  vel : VelocityState3D,
  sub_dt : Double,
) -> Unit {
  let gravity = self.gravity
  let body_count = self.bodies.length()
  for i = 0; i < body_count; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() && !body.is_sleeping {
      let force = body.force
      let inv_mass = body.inv_mass
      let accel_x = gravity.x + force.x * inv_mass
      let accel_y = gravity.y + force.y * inv_mass
      let accel_z = gravity.z + force.z * inv_mass
      let linear_decay = 1.0 - body.linear_damping * sub_dt
      vel.vx[i] = (vel.vx[i] + accel_x * sub_dt) * linear_decay
      vel.vy[i] = (vel.vy[i] + accel_y * sub_dt) * linear_decay
      vel.vz[i] = (vel.vz[i] + accel_z * sub_dt) * linear_decay
      let wx = vel.wx[i]
      let wy = vel.wy[i]
      let wz = vel.wz[i]
      let torque = body.torque
      if wx * wx + wy * wy + wz * wz <= 1.0e-24 &&
        torque.x * torque.x + torque.y * torque.y + torque.z * torque.z <=
        1.0e-24 {
        vel.wx[i] = 0.0
        vel.wy[i] = 0.0
        vel.wz[i] = 0.0
      } else {
        let inv_inertia = body.inv_inertia
        let angular_decay = 1.0 - body.angular_damping * sub_dt
        vel.wx[i] = (wx + torque.x * inv_inertia * sub_dt) * angular_decay
        vel.wy[i] = (wy + torque.y * inv_inertia * sub_dt) * angular_decay
        vel.wz[i] = (wz + torque.z * inv_inertia * sub_dt) * angular_decay
      }
    }
  }
}

///|
/// Phase 4b: relaxation over contacts and joints for one substep.
fn PhysicsWorld::phase_solve_velocities(
  self : PhysicsWorld,
  constraints : Array[ContactConstraintRuntime3D],
  dist_constraints : Array[DistanceJointConstraint3D],
  ball_constraints : Array[BallJointConstraint3D],
  vel : VelocityState3D,
  iterations : Int,
  use_bias? : Bool = true,
) -> Unit {
  // Velocities live in `vel` for the whole substep loop, so this pass neither
  // loads nor stores -- it allocates nothing at all. Positions and masses are
  // still read straight from the bodies; neither changes here.
  for _iter = 0; _iter < iterations; _iter = _iter + 1 {
    for ci = 0; ci < constraints.length(); ci = ci + 1 {
      solve_constraint3d(constraints, ci, self.bodies, vel, use_bias)
    }
    for di = 0; di < dist_constraints.length(); di = di + 1 {
      solve_distance_joint3d(
        dist_constraints,
        di,
        self.bodies,
        self.joints_distance[di],
        vel,
        use_bias,
      )
    }
    for bi = 0; bi < ball_constraints.length(); bi = bi + 1 {
      solve_ball_joint3d(ball_constraints, bi, self.bodies, vel, use_bias)
    }
  }
}

///|
/// Phase 4c: integrate positions and rotations for one substep, taking the CCD
/// path for bullet bodies.
fn PhysicsWorld::phase_integrate_positions(
  self : PhysicsWorld,
  vel : VelocityState3D,
  sub_dt : Double,
) -> Unit {
  let body_count = self.bodies.length()
  for i = 0; i < body_count; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() && !body.is_sleeping {
      // Velocity comes from the buffer; the body's own copy is a substep stale
      // by now. The `RigidBody` rebuild stays -- position and rotation do
      // change here -- but the velocity `Vec3` that used to be built to scale
      // and add does not.
      let vx = vel.vx[i]
      let vy = vel.vy[i]
      let vz = vel.vz[i]
      let wx = vel.wx[i]
      let wy = vel.wy[i]
      let wz = vel.wz[i]
      let position = body.position
      let omega_len_sq = wx * wx + wy * wy + wz * wz
      let new_rotation = if omega_len_sq > 1.0e-24 {
        let omega_len = omega_len_sq.sqrt()
        let inv_omega_len = 1.0 / omega_len
        let axis = @math3d.Vec3::new(
          wx * inv_omega_len,
          wy * inv_omega_len,
          wz * inv_omega_len,
        )
        let angle = omega_len * sub_dt
        body.rotation
        .multiply(@math3d.Quaternion::from_axis_angle(axis, angle))
        .normalize()
      } else {
        body.rotation
      }
      if body.is_bullet {
        match ccd_sweep_body3d(i, self.bodies, vel, sub_dt) {
          Some(toi) => {
            let safe_toi = if toi > 0.01 { toi * 0.95 } else { 0.0 }
            let safe_rotation = if omega_len_sq > 1.0e-24 {
              let omega_len = omega_len_sq.sqrt()
              let inv_omega_len = 1.0 / omega_len
              let axis = @math3d.Vec3::new(
                wx * inv_omega_len,
                wy * inv_omega_len,
                wz * inv_omega_len,
              )
              let angle = omega_len * sub_dt * safe_toi
              body.rotation
              .multiply(@math3d.Quaternion::from_axis_angle(axis, angle))
              .normalize()
            } else {
              body.rotation
            }
            let step_dt = sub_dt * safe_toi
            self.bodies[i] = {
              ..body,
              position: @math3d.Vec3::new(
                position.x + vx * step_dt,
                position.y + vy * step_dt,
                position.z + vz * step_dt,
              ),
              rotation: safe_rotation,
            }
          }
          None =>
            self.bodies[i] = {
              ..body,
              position: @math3d.Vec3::new(
                position.x + vx * sub_dt,
                position.y + vy * sub_dt,
                position.z + vz * sub_dt,
              ),
              rotation: new_rotation,
            }
        }
      } else {
        self.bodies[i] = {
          ..body,
          position: @math3d.Vec3::new(
            position.x + vx * sub_dt,
            position.y + vy * sub_dt,
            position.z + vz * sub_dt,
          ),
          rotation: new_rotation,
        }
      }
    }
  }
}

///|
/// Phase 5: publish this frame's accumulated impulses for next frame's warm
/// start.
fn PhysicsWorld::phase_save_contact_cache(
  self : PhysicsWorld,
  constraints : Array[ContactConstraintRuntime3D],
) -> Unit {
  self.contact_cache.clear()
  for c = 0; c < constraints.length(); c = c + 1 {
    let con = constraints[c]
    self.contact_cache.store(
      self.bodies[con.idx_a].id,
      self.bodies[con.idx_b].id,
      con.contact.normal,
      con.acc_jn,
      con.acc_jt,
    )
  }
}

///|
/// Phase 6: clear the per-frame force accumulators.
fn PhysicsWorld::phase_clear_forces(self : PhysicsWorld) -> Unit {
  let body_count = self.bodies.length()
  for i = 0; i < body_count; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      self.bodies[i] = {
        ..body,
        force: @math3d.Vec3::zero(),
        torque: @math3d.Vec3::zero(),
      }
    }
  }
}

///|
/// Phase 7: advance sleep timers, then sleep or wake whole contact islands.
///
/// The union-find pass is skipped entirely when no body is asleep and none has
/// been at rest long enough to fall asleep.
fn PhysicsWorld::phase_update_sleep(
  self : PhysicsWorld,
  constraints : Array[ContactConstraintRuntime3D],
  dt : Double,
) -> Unit {
  let n = self.bodies.length()
  if n == 0 {
    return
  }
  let mut has_sleeping_body = false
  let mut has_sleep_candidate = false
  // Update sleep timers per body
  for i = 0; i < n; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      if body.is_sleeping {
        has_sleeping_body = true
      }
      if body_sleep_velocity3d(body) < sleep_velocity_threshold3d {
        let sleep_timer = body.sleep_timer + dt
        if sleep_timer >= sleep_time_threshold3d {
          has_sleep_candidate = true
        }
        self.bodies[i] = { ..body, sleep_timer, }
      } else {
        self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0, }
      }
    }
  }
  if !has_sleeping_body && !has_sleep_candidate {
    return
  }
  let parent : Array[Int] = Array::make(n, 0)
  let rank : Array[Int] = Array::make(n, 0)
  for i = 0; i < n; i = i + 1 {
    parent[i] = i
  }
  for c = 0; c < constraints.length(); c = c + 1 {
    let con = constraints[c]
    uf_union3d(parent, rank, con.idx_a, con.idx_b)
  }
  // Check islands
  let island_can_sleep : Array[Bool] = Array::make(n, true)
  for i = 0; i < n; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      let root = uf_find3d(parent, i)
      island_can_sleep[root] = island_can_sleep[root] &&
        body.sleep_timer >= sleep_time_threshold3d
    }
  }
  // Apply sleep/wake per island
  for i = 0; i < n; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      let root = uf_find3d(parent, i)
      if island_can_sleep[root] {
        if !body.is_sleeping {
          self.bodies[i] = {
            ..body,
            is_sleeping: true,
            velocity: @math3d.Vec3::zero(),
            angular_velocity: @math3d.Vec3::zero(),
          }
        }
      } else if body.is_sleeping {
        self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0, }
      }
    }
  }
}

///|
pub fn PhysicsWorld::step(self : PhysicsWorld, dt : Double) -> Unit {
  let config = self.solver_config
  let substeps = config.substeps
  let sub_dt = dt / substeps.to_double()
  let pairs = self.phase_broadphase_pairs()
  let constraints = self.phase_contact_constraints(pairs, sub_dt)
  let (dist_constraints, ball_constraints) = self.phase_joint_constraints(
    sub_dt,
  )
  let relax_iterations = config.relax_iterations
  // One load in, one store out, for the whole substep loop. Everything inside
  // reads and writes the flat arrays: the phases below build no `RigidBody` for
  // velocity's sake, and `phase_solve_velocities` no longer pays a load and a
  // store per substep (and another per relaxation pass).
  //
  // Ordering is load-bearing. `phase_contact_constraints` and the joint
  // precomputes above read velocity off the bodies for restitution and bias, so
  // the load has to come after them -- which it does, and at that point the two
  // agree to the bit. `phase_update_sleep` below reads it off the bodies too,
  // so the store has to come before that.
  let vel = self.velocity_state
  vel.load(self.bodies)
  for _s = 0; _s < substeps; _s = _s + 1 {
    self.phase_integrate_velocities(vel, sub_dt)
    self.phase_solve_velocities(
      constraints,
      dist_constraints,
      ball_constraints,
      vel,
      config.velocity_iterations,
    )
    self.phase_integrate_positions(vel, sub_dt)
    // Relaxation: the biased pass above had to inject velocity to push overlap
    // out, and that velocity is still in the buffer. Solving the same
    // constraints rigidly takes it back out. Off by default.
    if relax_iterations > 0 {
      self.phase_solve_velocities(
        constraints,
        dist_constraints,
        ball_constraints,
        vel,
        relax_iterations,
        use_bias=false,
      )
    }
  }
  vel.store(self.bodies)
  self.phase_save_contact_cache(constraints)
  self.phase_clear_forces()
  self.phase_update_sleep(constraints, dt)
}
