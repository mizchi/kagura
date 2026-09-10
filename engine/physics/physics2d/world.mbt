///|
pub fn PhysicsWorld2D::new(
  gravity : @vector.Vec2,
  broadphase_cell_size : Double,
  solver_config? : SolverConfig2D = SolverConfig2D::default(),
) -> PhysicsWorld2D {
  {
    bodies: [],
    gravity,
    broadphase: SpatialHashGrid2D::new(broadphase_cell_size),
    solver_config,
    contact_cache: Map([]),
    velocity_state: VelocityState2D::new(),
    joints_distance: [],
    joints_revolute: [],
  }
}

///|
pub fn PhysicsWorld2D::add_body(
  self : PhysicsWorld2D,
  body : RigidBody2D,
) -> Unit {
  self.bodies.push(body)
}

///|
pub fn PhysicsWorld2D::get_body(
  self : PhysicsWorld2D,
  id : Int,
) -> RigidBody2D? {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    if self.bodies[i].id == id {
      return Some(self.bodies[i])
    }
  }
  None
}

///|
pub fn PhysicsWorld2D::body_count(self : PhysicsWorld2D) -> Int {
  self.bodies.length()
}

///|
pub fn PhysicsWorld2D::apply_force(
  self : PhysicsWorld2D,
  body_id : Int,
  force : @vector.Vec2,
) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    if self.bodies[i].id == body_id {
      self.bodies[i] = self.bodies[i].apply_force(force)
      break
    }
  }
}

///|
pub fn PhysicsWorld2D::apply_impulse(
  self : PhysicsWorld2D,
  body_id : Int,
  impulse : @vector.Vec2,
) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    if self.bodies[i].id == body_id {
      self.bodies[i] = self.bodies[i].apply_impulse(impulse)
      break
    }
  }
}

///|
pub fn PhysicsWorld2D::add_distance_joint(
  self : PhysicsWorld2D,
  joint : DistanceJoint2D,
) -> Unit {
  self.joints_distance.push(joint)
}

///|
pub fn PhysicsWorld2D::add_revolute_joint(
  self : PhysicsWorld2D,
  joint : RevoluteJoint2D,
) -> Unit {
  self.joints_revolute.push(joint)
}

///|
let sleep_velocity_threshold : Double = 0.5

///|
let sleep_angular_threshold : Double = 0.2

///|
let sleep_time_threshold : Double = 0.5 // seconds at rest before sleeping

///|
/// Union-Find for island detection.
fn uf_find(parent : Array[Int], i : Int) -> Int {
  let mut x = i
  // Path compression loop (no recursion to avoid stack issues)
  for ;; {
    if parent[x] == x {
      break x
    }
    parent[x] = parent[parent[x]]
    x = parent[x]
  }
}

///|
fn uf_union(parent : Array[Int], rank : Array[Int], a : Int, b : Int) -> Unit {
  let ra = uf_find(parent, a)
  let rb = uf_find(parent, b)
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
/// Generate a unique key for a body pair (order-independent).
fn contact_pair_key(id_a : Int, id_b : Int) -> Int64 {
  let min_id = if id_a < id_b { id_a } else { id_b }
  let max_id = if id_a < id_b { id_b } else { id_a }
  (min_id.to_int64() << 32) | (max_id.to_int64() & 0xFFFFFFFFL)
}

///|
/// Phase 1: rebuild the broadphase from current body AABBs and return the
/// candidate pairs.
///
/// `step` and `world_bench.mbt` both call this, so the benchmark can never
/// drift away from the shipped pipeline.
fn PhysicsWorld2D::phase_broadphase_pairs(
  self : PhysicsWorld2D,
) -> Array[(Int, Int)] {
  let body_count = self.bodies.length()
  self.broadphase.clear()
  for i = 0; i < body_count; i = i + 1 {
    self.broadphase.insert(i, self.bodies[i].world_aabb())
  }
  self.broadphase.get_pairs()
}

///|
/// Phase 2: narrowphase over the candidate pairs.
///
/// Kept separate from the constraint precompute so a benchmark can price
/// collision detection without the solver setup behind it.
///
/// Note: avoid `continue` in for-loop due to MoonBit JS codegen bug
fn PhysicsWorld2D::phase_narrowphase(
  self : PhysicsWorld2D,
  pairs : Array[(Int, Int)],
) -> Array[(Int, Int, Contact2D)] {
  let raw_contacts : Array[(Int, Int, Contact2D)] = Array(
    capacity=pairs.length(),
  )
  for p = 0; p < pairs.length(); p = p + 1 {
    let (idx_a, idx_b) = pairs[p]
    let body_a = self.bodies[idx_a]
    let body_b = self.bodies[idx_b]
    if body_a.inv_mass >= 1.0e-12 || body_b.inv_mass >= 1.0e-12 {
      match generate_contact2d(body_a, body_b) {
        Some(contact) => raw_contacts.push((idx_a, idx_b, contact))
        None => ()
      }
    }
  }
  raw_contacts
}

///|
/// Phase 3: constraint precompute plus warm starting from the previous frame's
/// impulse cache.
///
/// Warm starting applies impulses to `self.bodies`, so this phase mutates the
/// world as well as returning the constraints.
fn PhysicsWorld2D::phase_contact_constraints(
  self : PhysicsWorld2D,
  raw_contacts : Array[(Int, Int, Contact2D)],
  sub_dt : Double,
) -> Array[ContactConstraint2D] {
  let config = self.solver_config
  let constraints : Array[ContactConstraint2D] = Array(
    capacity=raw_contacts.length(),
  )
  for c = 0; c < raw_contacts.length(); c = c + 1 {
    let (idx_a, idx_b, contact) = raw_contacts[c]
    let body_a = self.bodies[idx_a]
    let body_b = self.bodies[idx_b]
    let mut constraint = precompute_constraint2d(
      body_a,
      body_b,
      idx_a,
      idx_b,
      contact,
      config.contact_hertz,
      config.contact_damping_ratio,
      sub_dt,
    )
    // Warm starting: look up cached impulses from previous frame
    let pair_key = contact_pair_key(body_a.id, body_b.id)
    match self.contact_cache.get(pair_key) {
      Some(cached) =>
        // Check normal similarity (dot > 0.9 means similar direction)
        if cached.normal.dot(contact.normal) > 0.9 {
          if cached.points.length() > 0 {
            let pt = cached.points[0]
            // Apply warm start impulses (scaled down slightly for stability)
            let warm_factor = 0.8
            constraint = {
              ..constraint,
              acc_jn: pt.normal_impulse * warm_factor,
              acc_jt: pt.tangent_impulse * warm_factor,
            }
            // Apply warm impulse to bodies
            let n = contact.normal
            let tangent = @vector.Vec2::new(-n.y, n.x)
            let jn = pt.normal_impulse * warm_factor
            let jt = pt.tangent_impulse * warm_factor
            if jn.abs() > 1.0e-15 || jt.abs() > 1.0e-15 {
              let impulse = n.scale(jn).add(tangent.scale(jt))
              self.bodies[idx_a] = {
                ..self.bodies[idx_a],
                velocity: self.bodies[idx_a].velocity.add(
                  impulse.scale(body_a.inv_mass),
                ),
              }
              self.bodies[idx_b] = {
                ..self.bodies[idx_b],
                velocity: self.bodies[idx_b].velocity.sub(
                  impulse.scale(body_b.inv_mass),
                ),
              }
            }
          }
        }
      None => ()
    }
    constraints.push(constraint)
  }
  constraints
}

///|
/// Phase 3b: precompute the joint constraints for this frame.
fn PhysicsWorld2D::phase_joint_constraints(
  self : PhysicsWorld2D,
  sub_dt : Double,
) -> (Array[DistanceJointConstraint2D], Array[RevoluteJointConstraint2D]) {
  let dist_constraints : Array[DistanceJointConstraint2D] = Array(
    capacity=self.joints_distance.length(),
  )
  for j = 0; j < self.joints_distance.length(); j = j + 1 {
    match
      precompute_distance_joint(self.joints_distance[j], self.bodies, sub_dt) {
      Some(c) => dist_constraints.push(c)
      None => ()
    }
  }
  let rev_constraints : Array[RevoluteJointConstraint2D] = Array(
    capacity=self.joints_revolute.length(),
  )
  for j = 0; j < self.joints_revolute.length(); j = j + 1 {
    match
      precompute_revolute_joint(self.joints_revolute[j], self.bodies, sub_dt) {
      Some(c) => rev_constraints.push(c)
      None => ()
    }
  }
  (dist_constraints, rev_constraints)
}

///|
/// Phase 4a: integrate velocities for one substep.
fn PhysicsWorld2D::phase_integrate_velocities(
  self : PhysicsWorld2D,
  sub_dt : Double,
) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() && !body.is_sleeping {
      let accel = self.gravity.add(body.force.scale(body.inv_mass))
      let new_vel = body.velocity
        .add(accel.scale(sub_dt))
        .scale(1.0 - body.linear_damping * sub_dt)
      let angular_accel = body.torque * body.inv_inertia
      let new_angular_vel = (body.angular_velocity + angular_accel * sub_dt) *
        (1.0 - body.angular_damping * sub_dt)
      self.bodies[i] = {
        ..body,
        velocity: new_vel,
        angular_velocity: new_angular_vel,
      }
    }
  }
}

///|
/// Phase 4b: relaxation over contacts and joints for one substep.
fn PhysicsWorld2D::phase_solve_velocities(
  self : PhysicsWorld2D,
  constraints : Array[ContactConstraint2D],
  dist_constraints : Array[DistanceJointConstraint2D],
  rev_constraints : Array[RevoluteJointConstraint2D],
  iterations : Int,
) -> Unit {
  // Velocities move into flat arrays for the duration of the pass and back out
  // at the end, so the constraint loops below allocate nothing. Positions and
  // masses are still read straight from the bodies -- neither changes here.
  let vel = self.velocity_state
  vel.load(self.bodies)
  for _iter = 0; _iter < iterations; _iter = _iter + 1 {
    for ci = 0; ci < constraints.length(); ci = ci + 1 {
      solve_constraint2d(constraints, ci, self.bodies, vel)
    }
    for di = 0; di < dist_constraints.length(); di = di + 1 {
      solve_distance_joint(
        dist_constraints,
        di,
        self.bodies,
        self.joints_distance[di],
        vel,
      )
    }
    for ri = 0; ri < rev_constraints.length(); ri = ri + 1 {
      solve_revolute_joint(rev_constraints, ri, self.bodies, vel)
    }
  }
  vel.store(self.bodies)
}

///|
/// Phase 4c: integrate positions for one substep, taking the CCD path for
/// bullet bodies.
fn PhysicsWorld2D::phase_integrate_positions(
  self : PhysicsWorld2D,
  sub_dt : Double,
) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() && !body.is_sleeping {
      if body.is_bullet {
        match ccd_sweep_body(i, self.bodies, sub_dt) {
          Some(toi) => {
            // Advance only to TOI (with small margin)
            let safe_toi = if toi > 0.01 { toi * 0.95 } else { 0.0 }
            self.bodies[i] = {
              ..body,
              position: body.position.add(
                body.velocity.scale(sub_dt * safe_toi),
              ),
              angle: body.angle + body.angular_velocity * sub_dt * safe_toi,
            }
          }
          None =>
            self.bodies[i] = {
              ..body,
              position: body.position.add(body.velocity.scale(sub_dt)),
              angle: body.angle + body.angular_velocity * sub_dt,
            }
        }
      } else {
        self.bodies[i] = {
          ..body,
          position: body.position.add(body.velocity.scale(sub_dt)),
          angle: body.angle + body.angular_velocity * sub_dt,
        }
      }
    }
  }
}

///|
/// Phase 5: publish this frame's accumulated impulses for next frame's warm
/// start.
fn PhysicsWorld2D::phase_save_contact_cache(
  self : PhysicsWorld2D,
  constraints : Array[ContactConstraint2D],
) -> Unit {
  let new_cache : Map[Int64, ContactManifold2D] = Map([])
  for c = 0; c < constraints.length(); c = c + 1 {
    let con = constraints[c]
    let body_a = self.bodies[con.idx_a]
    let body_b = self.bodies[con.idx_b]
    let pair_key = contact_pair_key(body_a.id, body_b.id)
    let local_a = con.contact.contact_point.sub(body_a.position)
    let local_b = con.contact.contact_point.sub(body_b.position)
    new_cache.set(pair_key, {
      body_a_id: body_a.id,
      body_b_id: body_b.id,
      normal: con.contact.normal,
      points: [
        {
          local_a,
          local_b,
          penetration: con.contact.penetration,
          normal_impulse: con.acc_jn,
          tangent_impulse: con.acc_jt,
        },
      ],
    })
  }
  // Replace old cache with new
  self.contact_cache.clear()
  new_cache.each(fn(k, v) { self.contact_cache.set(k, v) })
}

///|
/// Phase 6: clear the per-frame force accumulators.
fn PhysicsWorld2D::phase_clear_forces(self : PhysicsWorld2D) -> Unit {
  for i = 0; i < self.bodies.length(); i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      self.bodies[i] = { ..body, force: @vector.Vec2::zero(), torque: 0.0, }
    }
  }
}

///|
/// Phase 7: advance sleep timers, then sleep or wake whole contact islands.
fn PhysicsWorld2D::phase_update_sleep(
  self : PhysicsWorld2D,
  constraints : Array[ContactConstraint2D],
  dt : Double,
) -> Unit {
  let n = self.bodies.length()
  if n == 0 {
    return
  }
  // Build Union-Find for islands from active contacts
  let parent : Array[Int] = Array::make(n, 0)
  let rank : Array[Int] = Array::make(n, 0)
  for i = 0; i < n; i = i + 1 {
    parent[i] = i
  }
  for c = 0; c < constraints.length(); c = c + 1 {
    let con = constraints[c]
    uf_union(parent, rank, con.idx_a, con.idx_b)
  }
  // Update sleep timers per body
  for i = 0; i < n; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      let speed = body.velocity.length()
      let angular_speed = body.angular_velocity.abs()
      if speed < sleep_velocity_threshold &&
        angular_speed < sleep_angular_threshold {
        self.bodies[i] = { ..body, sleep_timer: body.sleep_timer + dt, }
      } else {
        // Wake up if moving
        self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0, }
      }
    }
  }
  // Check islands: if ALL dynamic bodies in an island are sleepy, put them to sleep
  // If ANY body in an island is awake/active, wake the whole island
  let island_can_sleep : Map[Int, Bool] = Map([])
  for i = 0; i < n; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      let root = uf_find(parent, i)
      let can_sleep = body.sleep_timer >= sleep_time_threshold
      match island_can_sleep.get(root) {
        Some(prev) => island_can_sleep.set(root, prev && can_sleep)
        None => island_can_sleep.set(root, can_sleep)
      }
    }
  }
  // Apply sleep/wake per island
  for i = 0; i < n; i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      let root = uf_find(parent, i)
      match island_can_sleep.get(root) {
        Some(true) =>
          if !body.is_sleeping {
            self.bodies[i] = {
              ..body,
              is_sleeping: true,
              velocity: @vector.Vec2::zero(),
              angular_velocity: 0.0,
            }
          }
        _ =>
          if body.is_sleeping {
            self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0, }
          }
      }
    }
  }
}

///|
pub fn PhysicsWorld2D::step(self : PhysicsWorld2D, dt : Double) -> Unit {
  let config = self.solver_config
  let substeps = config.substeps
  let sub_dt = dt / substeps.to_double()
  let pairs = self.phase_broadphase_pairs()
  let raw_contacts = self.phase_narrowphase(pairs)
  let constraints = self.phase_contact_constraints(raw_contacts, sub_dt)
  let (dist_constraints, rev_constraints) = self.phase_joint_constraints(sub_dt)
  for _s = 0; _s < substeps; _s = _s + 1 {
    self.phase_integrate_velocities(sub_dt)
    self.phase_solve_velocities(
      constraints,
      dist_constraints,
      rev_constraints,
      config.velocity_iterations,
    )
    self.phase_integrate_positions(sub_dt)
  }
  self.phase_save_contact_cache(constraints)
  self.phase_clear_forces()
  self.phase_update_sleep(constraints, dt)
}
