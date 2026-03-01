///|
pub fn PhysicsWorld::new(
  gravity : @math3d.Vec3,
  broadphase_cell_size : Double,
) -> PhysicsWorld {
  {
    bodies: [],
    gravity,
    broadphase: @collision3d.SpatialHashGrid::new(broadphase_cell_size),
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
pub fn PhysicsWorld::step(self : PhysicsWorld, dt : Double) -> Unit {
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
        force: @math3d.Vec3::zero(),
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
    match generate_contact(body_a, body_b) {
      Some(contact) => {
        let (a_new, b_new) = resolve_contact(body_a, body_b, contact)
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
