///|
pub(all) enum BodyType {
  Dynamic
  Static
  Kinematic
} derive(Debug)

///|
pub impl Show for BodyType with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) enum ColliderShape {
  SphereShape(@math3d.Vec3, Double)
  AABBShape(@math3d.Vec3, @math3d.Vec3)
} derive(Debug)

///|
pub impl Show for ColliderShape with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct RigidBody {
  id : Int
  body_type : BodyType
  position : @math3d.Vec3
  velocity : @math3d.Vec3
  force : @math3d.Vec3
  rotation : @math3d.Quaternion
  angular_velocity : @math3d.Vec3
  torque : @math3d.Vec3
  mass : Double
  inv_mass : Double
  inv_inertia : Double
  restitution : Double
  friction : Double
  collider : ColliderShape
  linear_damping : Double
  angular_damping : Double
  is_sleeping : Bool
  sleep_timer : Double
  is_bullet : Bool
} derive(Debug)

///|
pub impl Show for RigidBody with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct Contact {
  body_a_id : Int
  body_b_id : Int
  normal : @math3d.Vec3
  penetration : Double
  contact_point : @math3d.Vec3
} derive(Debug)

///|
pub impl Show for Contact with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct SolverConfig3D {
  substeps : Int
  velocity_iterations : Int
  contact_hertz : Double
  contact_damping_ratio : Double
}

///|
pub fn SolverConfig3D::default() -> SolverConfig3D {
  {
    substeps: 4,
    velocity_iterations: 1,
    contact_hertz: 30.0,
    contact_damping_ratio: 1.0,
  }
}

///|
pub(all) struct ContactConstraint3D {
  idx_a : Int
  idx_b : Int
  contact : Contact
  r_a : @math3d.Vec3
  r_b : @math3d.Vec3
  normal_mass : Double
  tangent_mass : Double
  tangent_dir : @math3d.Vec3
  gamma : Double
  bias_coefficient : Double
  restitution_bias : Double
  mut acc_jn : Double
  mut acc_jt : Double
}

///|
priv struct ContactConstraintRuntime3D {
  idx_a : Int
  idx_b : Int
  contact : Contact
  r_a : @math3d.Vec3
  r_b : @math3d.Vec3
  r_a_cross_n : @math3d.Vec3
  r_b_cross_n : @math3d.Vec3
  r_a_cross_t : @math3d.Vec3
  r_b_cross_t : @math3d.Vec3
  has_normal_angular : Bool
  has_tangent_angular : Bool
  normal_mass : Double
  tangent_mass : Double
  tangent_dir : @math3d.Vec3
  friction : Double
  gamma : Double
  bias_coefficient : Double
  restitution_bias : Double
  mut acc_jn : Double
  mut acc_jt : Double
}

///|

///|
pub(all) struct ManifoldPoint3D {
  local_a : @math3d.Vec3
  local_b : @math3d.Vec3
  penetration : Double
  normal_impulse : Double
  tangent_impulse : Double
}

///|
pub(all) struct ContactManifold3D {
  body_a_id : Int
  body_b_id : Int
  normal : @math3d.Vec3
  points : Array[ManifoldPoint3D]
}

///|
pub(all) struct DistanceJoint3D {
  body_a_id : Int
  body_b_id : Int
  local_anchor_a : @math3d.Vec3
  local_anchor_b : @math3d.Vec3
  rest_length : Double
  hertz : Double
  damping_ratio : Double
}

///|
pub(all) struct DistanceJointConstraint3D {
  idx_a : Int
  idx_b : Int
  r_a : @math3d.Vec3
  r_b : @math3d.Vec3
  axis : @math3d.Vec3
  effective_mass : Double
  gamma : Double
  bias_coefficient : Double
  mut acc_impulse : Double
}

///|
pub(all) struct BallJoint3D {
  body_a_id : Int
  body_b_id : Int
  local_anchor_a : @math3d.Vec3
  local_anchor_b : @math3d.Vec3
  hertz : Double
  damping_ratio : Double
}

///|
pub(all) struct BallJointConstraint3D {
  idx_a : Int
  idx_b : Int
  r_a : @math3d.Vec3
  r_b : @math3d.Vec3
  effective_mass_x : Double
  effective_mass_y : Double
  effective_mass_z : Double
  gamma : Double
  bias_coefficient : Double
  mut acc_impulse_x : Double
  mut acc_impulse_y : Double
  mut acc_impulse_z : Double
}

///|
pub(all) struct PhysicsWorld {
  bodies : Array[RigidBody]
  gravity : @math3d.Vec3
  broadphase : @collision3d.SpatialHashGrid
  solver_config : SolverConfig3D
  contact_cache : Map[Int64, ContactManifold3D]
  joints_distance : Array[DistanceJoint3D]
  joints_ball : Array[BallJoint3D]
}

///|
pub extend BodyType with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BodyType with Show::{to_string, output}

///|
pub extend ColliderShape with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ColliderShape with Show::{to_string, output}

///|
pub extend RigidBody with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RigidBody with Show::{to_string, output}

///|
pub extend Contact with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Contact with Show::{to_string, output}
