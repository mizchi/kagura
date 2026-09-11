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
  /// Relax passes per substep, run after the position integration with the
  /// soft-constraint bias switched off.
  ///
  /// This is the "relaxation" half of Box2D v3's Soft Step solver. The biased
  /// pass has to inject velocity to push overlap out, and that velocity stays in
  /// the bodies afterwards; a pass with bias, softness and restitution all
  /// disabled takes it back out. 0 disables it, which is the historical
  /// behaviour.
  relax_iterations : Int
}

///|
pub fn SolverConfig3D::default() -> SolverConfig3D {
  {
    substeps: 4,
    velocity_iterations: 1,
    contact_hertz: 30.0,
    contact_damping_ratio: 1.0,
    relax_iterations: 0,
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
  /// `1 / k_normal`, i.e. `normal_mass` without the softness term folded in. The
  /// relax pass solves the rigid constraint, so it needs the rigid mass.
  unbiased_normal_mass : Double
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
  /// `1 / k_normal`, i.e. `normal_mass` without the softness term folded in. The
  /// relax pass solves the rigid constraint, so it needs the rigid mass.
  unbiased_normal_mass : Double
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
  unbiased_effective_mass : Double
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
  unbiased_effective_mass_x : Double
  unbiased_effective_mass_y : Double
  unbiased_effective_mass_z : Double
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
  contact_cache : ContactCache3D
  /// The solve pass's velocity working set, pooled here so a steady body count
  /// allocates nothing per frame. Only `phase_solve_velocities` touches it.
  velocity_state : VelocityState3D
  /// Body id -> index into `bodies`, so `get_body` and the joint precomputes do
  /// not scan. See `body_index.mbt`.
  body_index : BodyIndex3D
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
