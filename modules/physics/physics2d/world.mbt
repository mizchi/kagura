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
pub fn PhysicsWorld2D::step(self : PhysicsWorld2D, dt : Double) -> Unit {
  let config = self.solver_config
  let substeps = config.substeps
  let sub_dt = dt / substeps.to_double()
  // 1. Broadphase (once per frame)
  self.broadphase.clear()
  for i = 0; i < self.bodies.length(); i = i + 1 {
    self.broadphase.insert(i, self.bodies[i].world_aabb())
  }
  let pairs = self.broadphase.get_pairs()
  // 2. Narrowphase: detect contacts once
  // Note: avoid `continue` in for-loop due to MoonBit JS codegen bug
  let raw_contacts : Array[(Int, Int, Contact2D)] = []
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
  // 3. Precompute constraints with warm starting from cache
  let constraints : Array[ContactConstraint2D] = []
  let new_cache : Map[Int64, ContactManifold2D] = Map([])
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
  // 3b. Precompute joint constraints
  let dist_constraints : Array[DistanceJointConstraint2D] = []
  for j = 0; j < self.joints_distance.length(); j = j + 1 {
    match
      precompute_distance_joint(self.joints_distance[j], self.bodies, sub_dt) {
      Some(c) => dist_constraints.push(c)
      None => ()
    }
  }
  let rev_constraints : Array[RevoluteJointConstraint2D] = []
  for j = 0; j < self.joints_revolute.length(); j = j + 1 {
    match
      precompute_revolute_joint(self.joints_revolute[j], self.bodies, sub_dt) {
      Some(c) => rev_constraints.push(c)
      None => ()
    }
  }
  // 4. Substep loop
  for _s = 0; _s < substeps; _s = _s + 1 {
    // 4a. Velocity integration (dynamic, non-sleeping only)
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
    // 4b. Velocity solve (contacts + joints)
    for _iter = 0; _iter < config.velocity_iterations; _iter = _iter + 1 {
      for ci = 0; ci < constraints.length(); ci = ci + 1 {
        solve_constraint2d(constraints, ci, self.bodies)
      }
      for di = 0; di < dist_constraints.length(); di = di + 1 {
        solve_distance_joint(
          dist_constraints,
          di,
          self.bodies,
          self.joints_distance[di],
        )
      }
      for ri = 0; ri < rev_constraints.length(); ri = ri + 1 {
        solve_revolute_joint(rev_constraints, ri, self.bodies)
      }
    }
    // 4c. Position integration (dynamic, non-sleeping only)
    // For bullet bodies, check CCD before full position update
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
  // 5. Save constraint impulses to cache for next frame warm starting
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
  // 6. Clear forces (once per frame)
  for i = 0; i < self.bodies.length(); i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      self.bodies[i] = { ..body, force: @vector.Vec2::zero(), torque: 0.0 }
    }
  }
  // 7. Sleeping: update sleep timers and detect islands
  let n = self.bodies.length()
  if n > 0 {
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
          self.bodies[i] = { ..body, sleep_timer: body.sleep_timer + dt }
        } else {
          // Wake up if moving
          self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0 }
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
              self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0 }
            }
        }
      }
    }
  }
}
