///|

///|
fn compute_inv_inertia(mass : Double, collider : ColliderShape) -> Double {
  if mass < 1.0e-12 {
    return 0.0
  }
  let inertia = match collider {
    // Solid sphere: I = 2/5 * m * r^2
    SphereShape(_, radius) => 0.4 * mass * radius * radius
    // Axis-aligned colliders have locked rotation. Letting the solver spend
    // normal impulses on angular motion that never changes this shape makes
    // offset stacks sink through their supports. Use BoxShape for rotation.
    AABBShape(_, _) => return 0.0
    // Scalar approximation for a rotating box.
    BoxShape(he, _) => {
      let hx = he.x
      let hy = he.y
      let hz = he.z
      // Use average inertia: m/3 * (hx^2 + hy^2 + hz^2) / 2 ≈ m/12 * (w^2+h^2+d^2) for full extents
      mass / 3.0 * (hx * hx + hy * hy + hz * hz)
    }
  }
  if inertia < 1.0e-12 {
    0.0
  } else {
    1.0 / inertia
  }
}

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
    inv_inertia: compute_inv_inertia(mass, collider),
    restitution: 0.5,
    friction: 0.3,
    collider,
    linear_damping: 0.01,
    angular_damping: 0.05,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
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
    inv_inertia: 0.0,
    restitution: 0.5,
    friction: 0.3,
    collider,
    linear_damping: 0.0,
    angular_damping: 0.0,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
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
    inv_inertia: 0.0,
    restitution: 0.5,
    friction: 0.3,
    collider,
    linear_damping: 0.0,
    angular_damping: 0.0,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
  }
}

///|
pub fn RigidBody::apply_force(self : RigidBody, f : @math3d.Vec3) -> RigidBody {
  let wake = self.is_dynamic() && f.length_squared() > 0.0
  {
    ..self,
    force: self.force.add(f),
    is_sleeping: if wake {
      false
    } else {
      self.is_sleeping
    },
    sleep_timer: if wake {
      0.0
    } else {
      self.sleep_timer
    },
  }
}

///|
pub fn RigidBody::apply_impulse(
  self : RigidBody,
  impulse : @math3d.Vec3,
) -> RigidBody {
  let wake = self.is_dynamic() && impulse.length_squared() > 0.0
  {
    ..self,
    velocity: self.velocity.add(impulse.scale(self.inv_mass)),
    is_sleeping: if wake {
      false
    } else {
      self.is_sleeping
    },
    sleep_timer: if wake {
      0.0
    } else {
      self.sleep_timer
    },
  }
}

///|
pub fn RigidBody::with_restitution(self : RigidBody, e : Double) -> RigidBody {
  { ..self, restitution: e, }
}

///|
pub fn RigidBody::with_friction(self : RigidBody, f : Double) -> RigidBody {
  { ..self, friction: f, }
}

///|
pub fn RigidBody::with_damping(self : RigidBody, d : Double) -> RigidBody {
  { ..self, linear_damping: d, }
}

///|
pub fn RigidBody::with_bullet(self : RigidBody) -> RigidBody {
  { ..self, is_bullet: true, }
}

///|
pub fn RigidBody::world_aabb(self : RigidBody) -> @collision3d.AABB {
  match self.collider {
    SphereShape(offset, radius) => {
      let center = self.position.add(offset)
      let r = @math3d.Vec3::new(radius, radius, radius)
      @collision3d.AABB::new(center.sub(r), center.add(r))
    }
    BoxShape(half_extents, offset) => {
      let center = self.position.add(self.rotation.rotate_vec3(offset))
      let axes = box_axes(self.rotation)
      let extent = @math3d.Vec3::new(
        axes[0].x.abs() * half_extents.x +
        axes[1].x.abs() * half_extents.y +
        axes[2].x.abs() * half_extents.z,
        axes[0].y.abs() * half_extents.x +
        axes[1].y.abs() * half_extents.y +
        axes[2].y.abs() * half_extents.z,
        axes[0].z.abs() * half_extents.x +
        axes[1].z.abs() * half_extents.y +
        axes[2].z.abs() * half_extents.z,
      )
      @collision3d.AABB::new(center.sub(extent), center.add(extent))
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
