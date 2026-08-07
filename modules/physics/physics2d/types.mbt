///|
pub(all) enum BodyType2D {
  Dynamic
  Static
  Kinematic
} derive(Debug)

///|
pub impl Show for BodyType2D with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) enum ColliderShape2D {
  CircleShape(@vector.Vec2, Double)
  AABBShape2D(@vector.Vec2, @vector.Vec2)
  OBBShape2D(@vector.Vec2, @vector.Vec2) // (half_extents, offset) rotated by body.angle
} derive(Debug)

///|
pub impl Show for ColliderShape2D with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct RigidBody2D {
  id : Int
  body_type : BodyType2D
  position : @vector.Vec2
  velocity : @vector.Vec2
  force : @vector.Vec2
  angle : Double
  angular_velocity : Double
  torque : Double
  mass : Double
  inv_mass : Double
  restitution : Double
  friction : Double
  inv_inertia : Double
  angular_damping : Double
  linear_damping : Double
  collider : ColliderShape2D
  is_sleeping : Bool
  sleep_timer : Double // seconds at rest
  is_bullet : Bool // enable CCD for this body
} derive(Debug)

///|
pub impl Show for RigidBody2D with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct Contact2D {
  body_a_id : Int
  body_b_id : Int
  normal : @vector.Vec2
  penetration : Double
  contact_point : @vector.Vec2
} derive(Debug)

///|
pub impl Show for Contact2D with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct SolverConfig2D {
  substeps : Int // default 4
  velocity_iterations : Int // default 1 per substep
  contact_hertz : Double // default 30.0 Hz
  contact_damping_ratio : Double // default 1.0 (critically damped)
}

///|
pub fn SolverConfig2D::default() -> SolverConfig2D {
  {
    substeps: 4,
    velocity_iterations: 1,
    contact_hertz: 30.0,
    contact_damping_ratio: 1.0,
  }
}

///|
pub(all) struct ContactConstraint2D {
  idx_a : Int
  idx_b : Int
  contact : Contact2D
  r_a : @vector.Vec2
  r_b : @vector.Vec2
  normal_mass : Double
  tangent_mass : Double
  gamma : Double
  bias_coefficient : Double // beta = sub_dt * omega^2 * gamma
  restitution_bias : Double
  mut acc_jn : Double
  mut acc_jt : Double
}

///|
pub(all) struct ManifoldPoint2D {
  local_a : @vector.Vec2 // contact point in body A's local space
  local_b : @vector.Vec2 // contact point in body B's local space
  penetration : Double
  normal_impulse : Double // cached normal impulse for warm starting
  tangent_impulse : Double // cached tangent impulse for warm starting
}

///|
pub(all) struct ContactManifold2D {
  body_a_id : Int
  body_b_id : Int
  normal : @vector.Vec2
  points : Array[ManifoldPoint2D] // max 2 for 2D
}

///|
pub(all) struct DistanceJoint2D {
  body_a_id : Int
  body_b_id : Int
  local_anchor_a : @vector.Vec2 // anchor in body A local space
  local_anchor_b : @vector.Vec2 // anchor in body B local space
  rest_length : Double
  hertz : Double // frequency for soft constraint
  damping_ratio : Double
}

///|
pub(all) struct DistanceJointConstraint2D {
  idx_a : Int
  idx_b : Int
  r_a : @vector.Vec2
  r_b : @vector.Vec2
  axis : @vector.Vec2 // normalized direction from A anchor to B anchor
  effective_mass : Double
  gamma : Double
  bias_coefficient : Double
  mut acc_impulse : Double
}

///|
pub(all) struct RevoluteJoint2D {
  body_a_id : Int
  body_b_id : Int
  local_anchor_a : @vector.Vec2
  local_anchor_b : @vector.Vec2
  hertz : Double
  damping_ratio : Double
}

///|
pub(all) struct RevoluteJointConstraint2D {
  idx_a : Int
  idx_b : Int
  r_a : @vector.Vec2
  r_b : @vector.Vec2
  effective_mass_x : Double
  effective_mass_y : Double
  gamma : Double
  bias_coefficient : Double
  mut acc_impulse_x : Double
  mut acc_impulse_y : Double
}

///|
pub(all) struct PhysicsWorld2D {
  bodies : Array[RigidBody2D]
  gravity : @vector.Vec2
  broadphase : SpatialHashGrid2D
  solver_config : SolverConfig2D
  contact_cache : Map[Int64, ContactManifold2D]
  joints_distance : Array[DistanceJoint2D]
  joints_revolute : Array[RevoluteJoint2D]
}

///|
pub extend BodyType2D with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BodyType2D with Show::{to_string, output}

///|
pub extend ColliderShape2D with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ColliderShape2D with Show::{to_string, output}

///|
pub extend RigidBody2D with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RigidBody2D with Show::{to_string, output}

///|
pub extend Contact2D with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Contact2D with Show::{to_string, output}
