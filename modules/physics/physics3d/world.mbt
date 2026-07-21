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
    contact_cache: Map([]),
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
let sleep_velocity_threshold_sq3d : Double = sleep_velocity_threshold3d *
  sleep_velocity_threshold3d

///|
let sleep_angular_threshold3d : Double = 0.2

///|
let sleep_angular_threshold_sq3d : Double = sleep_angular_threshold3d *
  sleep_angular_threshold3d

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
fn contact_pair_key3d(id_a : Int, id_b : Int) -> Int64 {
  let min_id = if id_a < id_b { id_a } else { id_b }
  let max_id = if id_a < id_b { id_b } else { id_a }
  (min_id.to_int64() << 32) | (max_id.to_int64() & 0xFFFFFFFFL)
}

///|
pub fn PhysicsWorld::step(self : PhysicsWorld, dt : Double) -> Unit {
  let config = self.solver_config
  let substeps = config.substeps
  let sub_dt = dt / substeps.to_double()
  let body_count = self.bodies.length()
  // 1. Broadphase (once per frame)
  self.broadphase.clear()
  for i = 0; i < body_count; i = i + 1 {
    self.broadphase.insert(i, self.bodies[i].world_aabb())
  }
  let pairs = self.broadphase.get_pairs()
  let pair_count = pairs.length()
  let (contact_gamma, contact_bias_coefficient) = soft_constraint_params3d(
    config.contact_hertz,
    config.contact_damping_ratio,
    sub_dt,
  )
  // 2. Narrowphase + constraint precompute
  let constraints : Array[ContactConstraintRuntime3D] = Array::new(
    capacity=pair_count,
  )
  for p = 0; p < pair_count; p = p + 1 {
    let (idx_a, idx_b) = pairs[p]
    let body_a = self.bodies[idx_a]
    let body_b = self.bodies[idx_b]
    if body_a.inv_mass >= 1.0e-12 || body_b.inv_mass >= 1.0e-12 {
      match generate_contact(body_a, body_b) {
        Some(contact) => {
          let mut constraint = precompute_constraint3d(
            body_a, body_b, idx_a, idx_b, contact, contact_gamma, contact_bias_coefficient,
          )
          // Warm starting: look up cached impulses from previous frame
          let pair_key = contact_pair_key3d(body_a.id, body_b.id)
          match self.contact_cache.get(pair_key) {
            Some(cached) =>
              if cached.normal.dot(contact.normal) > 0.9 {
                if cached.points.length() > 0 {
                  let pt = cached.points[0]
                  let warm_factor = 0.8
                  constraint = {
                    ..constraint,
                    acc_jn: pt.normal_impulse * warm_factor,
                    acc_jt: pt.tangent_impulse * warm_factor,
                  }
                  let n = contact.normal
                  let tangent = constraint.tangent_dir
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
        None => ()
      }
    }
  }
  // 3b. Precompute joint constraints
  let distance_joint_count = self.joints_distance.length()
  let dist_constraints : Array[DistanceJointConstraint3D] = Array::new(
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
  let ball_constraints : Array[BallJointConstraint3D] = Array::new(
    capacity=ball_joint_count,
  )
  for j = 0; j < ball_joint_count; j = j + 1 {
    match precompute_ball_joint3d(self.joints_ball[j], self.bodies, sub_dt) {
      Some(c) => ball_constraints.push(c)
      None => ()
    }
  }
  // 4. Substep loop
  for _s = 0; _s < substeps; _s = _s + 1 {
    // 4a. Velocity integration (dynamic, non-sleeping only)
    for i = 0; i < body_count; i = i + 1 {
      let body = self.bodies[i]
      if body.is_dynamic() && !body.is_sleeping {
        let accel = self.gravity.add(body.force.scale(body.inv_mass))
        let new_vel = body.velocity
          .add(accel.scale(sub_dt))
          .scale(1.0 - body.linear_damping * sub_dt)
        let new_angular_vel = if body.angular_velocity.length_squared() <=
          1.0e-24 &&
          body.torque.length_squared() <= 1.0e-24 {
          @math3d.Vec3::zero()
        } else {
          let angular_accel = body.torque.scale(body.inv_inertia)
          body.angular_velocity
          .add(angular_accel.scale(sub_dt))
          .scale(1.0 - body.angular_damping * sub_dt)
        }
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
        solve_constraint3d(constraints, ci, self.bodies)
      }
      for di = 0; di < dist_constraints.length(); di = di + 1 {
        solve_distance_joint3d(
          dist_constraints,
          di,
          self.bodies,
          self.joints_distance[di],
        )
      }
      for bi = 0; bi < ball_constraints.length(); bi = bi + 1 {
        solve_ball_joint3d(ball_constraints, bi, self.bodies)
      }
    }
    // 4c. Position + rotation integration (dynamic, non-sleeping only)
    // For bullet bodies, check CCD before full position update
    for i = 0; i < body_count; i = i + 1 {
      let body = self.bodies[i]
      if body.is_dynamic() && !body.is_sleeping {
        let omega = body.angular_velocity
        let omega_len_sq = omega.length_squared()
        let new_rotation = if omega_len_sq > 1.0e-24 {
          let omega_len = omega_len_sq.sqrt()
          let axis = omega.scale(1.0 / omega_len)
          let angle = omega_len * sub_dt
          body.rotation
          .multiply(@math3d.Quaternion::from_axis_angle(axis, angle))
          .normalize()
        } else {
          body.rotation
        }
        if body.is_bullet {
          match ccd_sweep_body3d(i, self.bodies, sub_dt) {
            Some(toi) => {
              let safe_toi = if toi > 0.01 { toi * 0.95 } else { 0.0 }
              let safe_rotation = if omega_len_sq > 1.0e-24 {
                let omega_len = omega_len_sq.sqrt()
                let axis = omega.scale(1.0 / omega_len)
                let angle = omega_len * sub_dt * safe_toi
                body.rotation
                .multiply(@math3d.Quaternion::from_axis_angle(axis, angle))
                .normalize()
              } else {
                body.rotation
              }
              self.bodies[i] = {
                ..body,
                position: body.position.add(
                  body.velocity.scale(sub_dt * safe_toi),
                ),
                rotation: safe_rotation,
              }
            }
            None =>
              self.bodies[i] = {
                ..body,
                position: body.position.add(body.velocity.scale(sub_dt)),
                rotation: new_rotation,
              }
          }
        } else {
          self.bodies[i] = {
            ..body,
            position: body.position.add(body.velocity.scale(sub_dt)),
            rotation: new_rotation,
          }
        }
      }
    }
  }
  // 5. Save constraint impulses to cache for next frame warm starting
  self.contact_cache.clear()
  for c = 0; c < constraints.length(); c = c + 1 {
    let con = constraints[c]
    let body_a = self.bodies[con.idx_a]
    let body_b = self.bodies[con.idx_b]
    let pair_key = contact_pair_key3d(body_a.id, body_b.id)
    let local_a = con.contact.contact_point.sub(body_a.position)
    let local_b = con.contact.contact_point.sub(body_b.position)
    self.contact_cache.set(pair_key, {
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
  // 6. Clear forces (once per frame)
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
  // 7. Sleeping: update sleep timers and detect islands
  let n = body_count
  if n > 0 {
    let mut has_sleeping_body = false
    let mut has_sleep_candidate = false
    // Update sleep timers per body
    for i = 0; i < n; i = i + 1 {
      let body = self.bodies[i]
      if body.is_dynamic() {
        if body.is_sleeping {
          has_sleeping_body = true
        }
        let speed_sq = body.velocity.length_squared()
        let angular_speed_sq = body.angular_velocity.length_squared()
        if speed_sq < sleep_velocity_threshold_sq3d &&
          angular_speed_sq < sleep_angular_threshold_sq3d {
          let sleep_timer = body.sleep_timer + dt
          if sleep_timer >= sleep_time_threshold3d {
            has_sleep_candidate = true
          }
          self.bodies[i] = { ..body, sleep_timer, }
        } else {
          self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0 }
        }
      }
    }
    if has_sleeping_body || has_sleep_candidate {
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
            self.bodies[i] = { ..body, is_sleeping: false, sleep_timer: 0.0 }
          }
        }
      }
    }
  }
}
