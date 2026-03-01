///|
pub(all) enum BodyType {
  Dynamic
  Static
  Kinematic
} derive(Show)

///|
pub(all) enum ColliderShape {
  SphereShape(@math3d.Vec3, Double)
  AABBShape(@math3d.Vec3, @math3d.Vec3)
} derive(Show)

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
  restitution : Double
  friction : Double
  collider : ColliderShape
  linear_damping : Double
} derive(Show)

///|
pub(all) struct Contact {
  body_a_id : Int
  body_b_id : Int
  normal : @math3d.Vec3
  penetration : Double
  contact_point : @math3d.Vec3
} derive(Show)

///|
pub(all) struct PhysicsWorld {
  bodies : Array[RigidBody]
  gravity : @math3d.Vec3
  broadphase : @collision3d.SpatialHashGrid
}
