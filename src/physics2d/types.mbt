///|
pub(all) enum BodyType2D {
  Dynamic
  Static
  Kinematic
} derive(Show)

///|
pub(all) enum ColliderShape2D {
  CircleShape(@vector.Vec2, Double)
  AABBShape2D(@vector.Vec2, @vector.Vec2)
} derive(Show)

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
  linear_damping : Double
  collider : ColliderShape2D
} derive(Show)

///|
pub(all) struct Contact2D {
  body_a_id : Int
  body_b_id : Int
  normal : @vector.Vec2
  penetration : Double
  contact_point : @vector.Vec2
} derive(Show)

///|
pub(all) struct PhysicsWorld2D {
  bodies : Array[RigidBody2D]
  gravity : @vector.Vec2
  broadphase : SpatialHashGrid2D
}
