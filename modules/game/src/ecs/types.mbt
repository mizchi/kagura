///|
pub(all) struct EntityId {
  value : Int
} derive(Debug, Eq)

///|
pub impl Show for EntityId with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) enum Tag {
  Player
  Enemy
  Bullet
  Item
  Obstacle
  Custom(String)
} derive(Debug, Eq)

///|
pub impl Show for Tag with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct Velocity {
  x : Double
  y : Double
  z : Double
} derive(Debug)

///|
pub impl Show for Velocity with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct Health {
  current : Int
  max : Int
} derive(Debug)

///|
pub impl Show for Health with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct Sprite {
  image_id : Int
  width : Double
  height : Double
  color : Int
  alpha : Double
} derive(Debug)

///|
pub impl Show for Sprite with fn output(self, logger) {
  logger.write_object(to_repr(self))
}
