///|
pub fn RigidBody::new_dynamic(
  id : Int,
  position : @math3d.Vec3,
  mass : Double,
  collider : ColliderShape,
) -> RigidBody {
  {
    id,
    body_type: Dynamic,
    position,
    velocity: @math3d.Vec3::zero(),
    force: @math3d.Vec3::zero(),
    rotation: @math3d.Quaternion::identity(),
    angular_velocity: @math3d.Vec3::zero(),
    torque: @math3d.Vec3::zero(),
    mass,
    inv_mass: 1.0 / mass,
    restitution: 0.5,
    friction: 0.3,
    collider,
    linear_damping: 0.01,
  }
}

///|
pub fn RigidBody::new_static(
  id : Int,
  position : @math3d.Vec3,
  collider : ColliderShape,
) -> RigidBody {
  {
    id,
    body_type: Static,
    position,
    velocity: @math3d.Vec3::zero(),
    force: @math3d.Vec3::zero(),
    rotation: @math3d.Quaternion::identity(),
    angular_velocity: @math3d.Vec3::zero(),
    torque: @math3d.Vec3::zero(),
    mass: 0.0,
    inv_mass: 0.0,
    restitution: 0.5,
    friction: 0.3,
    collider,
    linear_damping: 0.0,
  }
}

///|
pub fn RigidBody::new_kinematic(
  id : Int,
  position : @math3d.Vec3,
  collider : ColliderShape,
) -> RigidBody {
  {
    id,
    body_type: Kinematic,
    position,
    velocity: @math3d.Vec3::zero(),
    force: @math3d.Vec3::zero(),
    rotation: @math3d.Quaternion::identity(),
    angular_velocity: @math3d.Vec3::zero(),
    torque: @math3d.Vec3::zero(),
    mass: 0.0,
    inv_mass: 0.0,
    restitution: 0.5,
    friction: 0.3,
    collider,
    linear_damping: 0.0,
  }
}

///|
pub fn RigidBody::apply_force(self : RigidBody, f : @math3d.Vec3) -> RigidBody {
  { ..self, force: self.force.add(f) }
}

///|
pub fn RigidBody::apply_impulse(
  self : RigidBody,
  impulse : @math3d.Vec3,
) -> RigidBody {
  { ..self, velocity: self.velocity.add(impulse.scale(self.inv_mass)) }
}

///|
pub fn RigidBody::with_restitution(self : RigidBody, e : Double) -> RigidBody {
  { ..self, restitution: e }
}

///|
pub fn RigidBody::with_friction(self : RigidBody, f : Double) -> RigidBody {
  { ..self, friction: f }
}

///|
pub fn RigidBody::with_damping(self : RigidBody, d : Double) -> RigidBody {
  { ..self, linear_damping: d }
}

///|
pub fn RigidBody::world_aabb(self : RigidBody) -> @collision3d.AABB {
  match self.collider {
    SphereShape(offset, radius) => {
      let center = self.position.add(offset)
      let r = @math3d.Vec3::new(radius, radius, radius)
      @collision3d.AABB::new(center.sub(r), center.add(r))
    }
    AABBShape(half_extents, offset) => {
      let center = self.position.add(offset)
      @collision3d.AABB::new(center.sub(half_extents), center.add(half_extents))
    }
  }
}

///|
pub fn RigidBody::is_dynamic(self : RigidBody) -> Bool {
  match self.body_type {
    Dynamic => true
    _ => false
  }
}
