///|
pub(all) struct EntityId {
  value : Int
} derive(Show, Eq)

///|
pub(all) enum Tag {
  Player
  Enemy
  Bullet
  Item
  Obstacle
  Custom(String)
} derive(Show, Eq)

///|
pub(all) struct Velocity {
  x : Double
  y : Double
  z : Double
} derive(Show)

///|
pub(all) struct Health {
  current : Int
  max : Int
} derive(Show)

///|
pub(all) struct Sprite {
  image_id : Int
  width : Double
  height : Double
  color : Int
  alpha : Double
} derive(Show)
