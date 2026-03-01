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
    collider,
    linear_damping: 0.01,
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
    collider,
    linear_damping: 0.0,
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
    collider,
    linear_damping: 0.0,
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
pub fn RigidBody2D::with_damping(
  self : RigidBody2D,
  d : Double,
) -> RigidBody2D {
  { ..self, linear_damping: d }
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
  }
}

///|
pub fn RigidBody2D::is_dynamic(self : RigidBody2D) -> Bool {
  match self.body_type {
    Dynamic => true
    _ => false
  }
}
