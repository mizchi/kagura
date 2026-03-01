///|
pub fn PhysicsWorld2D::new(
  gravity : @vector.Vec2,
  broadphase_cell_size : Double,
) -> PhysicsWorld2D {
  {
    bodies: [],
    gravity,
    broadphase: SpatialHashGrid2D::new(broadphase_cell_size),
  }
}

///|
pub fn PhysicsWorld2D::add_body(self : PhysicsWorld2D, body : RigidBody2D) -> Unit {
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
pub fn PhysicsWorld2D::step(self : PhysicsWorld2D, dt : Double) -> Unit {
  // 1. Velocity integration (dynamic only)
  for i = 0; i < self.bodies.length(); i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      let accel = self.gravity.add(body.force.scale(body.inv_mass))
      let new_vel = body.velocity.add(accel.scale(dt)).scale(
        1.0 - body.linear_damping * dt,
      )
      self.bodies[i] = {
        ..body,
        velocity: new_vel,
        force: @vector.Vec2::zero(),
      }
    }
  }
  // 2. Broadphase
  self.broadphase.clear()
  for i = 0; i < self.bodies.length(); i = i + 1 {
    self.broadphase.insert(i, self.bodies[i].world_aabb())
  }
  let pairs = self.broadphase.get_pairs()
  // 3. Narrowphase + impulse resolution
  for p = 0; p < pairs.length(); p = p + 1 {
    let (idx_a, idx_b) = pairs[p]
    let body_a = self.bodies[idx_a]
    let body_b = self.bodies[idx_b]
    if body_a.inv_mass < 1.0e-12 && body_b.inv_mass < 1.0e-12 {
      continue p
    }
    match generate_contact2d(body_a, body_b) {
      Some(contact) => {
        let (a_new, b_new) = resolve_contact2d(body_a, body_b, contact)
        self.bodies[idx_a] = a_new
        self.bodies[idx_b] = b_new
      }
      None => ()
    }
  }
  // 4. Position integration (dynamic only)
  for i = 0; i < self.bodies.length(); i = i + 1 {
    let body = self.bodies[i]
    if body.is_dynamic() {
      self.bodies[i] = {
        ..body,
        position: body.position.add(body.velocity.scale(dt)),
      }
    }
  }
}
