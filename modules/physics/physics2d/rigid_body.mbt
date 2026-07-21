///|
fn compute_inv_inertia(collider : ColliderShape2D, mass : Double) -> Double {
  if mass < 1.0e-12 {
    return 0.0
  }
  let inertia = match collider {
    CircleShape(_, radius) => 0.5 * mass * radius * radius
    AABBShape2D(he, _) | OBBShape2D(he, _) =>
      mass / 3.0 * (he.x * he.x + he.y * he.y)
  }
  if inertia < 1.0e-12 {
    0.0
  } else {
    1.0 / inertia
  }
}

///|
pub fn RigidBody2D::new_dynamic(
  id : Int,
  position : @vector.Vec2,
  mass : Double,
  collider : ColliderShape2D,
) -> RigidBody2D {
  {
    id,
    body_type: Dynamic,
    position,
    velocity: @vector.Vec2::zero(),
    force: @vector.Vec2::zero(),
    angle: 0.0,
    angular_velocity: 0.0,
    torque: 0.0,
    mass,
    inv_mass: 1.0 / mass,
    restitution: 0.5,
    friction: 0.3,
    inv_inertia: compute_inv_inertia(collider, mass),
    angular_damping: 0.05,
    collider,
    linear_damping: 0.01,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
  }
}

///|
pub fn RigidBody2D::new_static(
  id : Int,
  position : @vector.Vec2,
  collider : ColliderShape2D,
) -> RigidBody2D {
  {
    id,
    body_type: Static,
    position,
    velocity: @vector.Vec2::zero(),
    force: @vector.Vec2::zero(),
    angle: 0.0,
    angular_velocity: 0.0,
    torque: 0.0,
    mass: 0.0,
    inv_mass: 0.0,
    restitution: 0.5,
    friction: 0.3,
    inv_inertia: 0.0,
    angular_damping: 0.0,
    collider,
    linear_damping: 0.0,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
  }
}

///|
pub fn RigidBody2D::new_kinematic(
  id : Int,
  position : @vector.Vec2,
  collider : ColliderShape2D,
) -> RigidBody2D {
  {
    id,
    body_type: Kinematic,
    position,
    velocity: @vector.Vec2::zero(),
    force: @vector.Vec2::zero(),
    angle: 0.0,
    angular_velocity: 0.0,
    torque: 0.0,
    mass: 0.0,
    inv_mass: 0.0,
    restitution: 0.5,
    friction: 0.3,
    inv_inertia: 0.0,
    angular_damping: 0.0,
    collider,
    linear_damping: 0.0,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
  }
}

///|
pub fn RigidBody2D::apply_force(
  self : RigidBody2D,
  f : @vector.Vec2,
) -> RigidBody2D {
  { ..self, force: self.force.add(f) }
}

///|
pub fn RigidBody2D::apply_impulse(
  self : RigidBody2D,
  impulse : @vector.Vec2,
) -> RigidBody2D {
  { ..self, velocity: self.velocity.add(impulse.scale(self.inv_mass)) }
}

///|
pub fn RigidBody2D::with_restitution(
  self : RigidBody2D,
  e : Double,
) -> RigidBody2D {
  { ..self, restitution: e }
}

///|
pub fn RigidBody2D::with_friction(
  self : RigidBody2D,
  f : Double,
) -> RigidBody2D {
  { ..self, friction: f }
}

///|
pub fn RigidBody2D::with_damping(self : RigidBody2D, d : Double) -> RigidBody2D {
  { ..self, linear_damping: d }
}

///|
pub fn RigidBody2D::with_bullet(self : RigidBody2D) -> RigidBody2D {
  { ..self, is_bullet: true }
}

///|
pub fn RigidBody2D::world_aabb(self : RigidBody2D) -> AABB2D {
  match self.collider {
    CircleShape(offset, radius) => {
      let center = self.position.add(offset)
      let r = @vector.Vec2::new(radius, radius)
      AABB2D::new(center.sub(r), center.add(r))
    }
    AABBShape2D(half_extents, offset) => {
      let center = self.position.add(offset)
      AABB2D::new(center.sub(half_extents), center.add(half_extents))
    }
    OBBShape2D(half_extents, offset) => {
      let center = self.position.add(offset.rotate(self.angle))
      let cos_a = @math.cos(self.angle).abs()
      let sin_a = @math.sin(self.angle).abs()
      let ex = half_extents.x * cos_a + half_extents.y * sin_a
      let ey = half_extents.x * sin_a + half_extents.y * cos_a
      let ext = @vector.Vec2::new(ex, ey)
      AABB2D::new(center.sub(ext), center.add(ext))
    }
  }
}

///|
pub fn RigidBody2D::is_dynamic(self : RigidBody2D) -> Bool {
  match self.body_type {
    Dynamic => true
    _ => false
  }
}
