///|
pub(all) struct EntityId {
  value : Int
} derive(Debug, Eq)

///|
pub impl Show for EntityId with fn output(self, logger) {
  logger.write_object(Repr(self))
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
  logger.write_object(Repr(self))
}

///|
pub(all) struct Velocity {
  x : Double
  y : Double
  z : Double
} derive(Debug)

///|
pub impl Show for Velocity with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct Health {
  current : Int
  max : Int
} derive(Debug)

///|
pub impl Show for Health with fn output(self, logger) {
  logger.write_object(Repr(self))
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
  logger.write_object(Repr(self))
}

///|
pub extend EntityId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EntityId with Eq::{not_equal, equal}

///|
pub extend EntityId with Show::{to_string, output}

///|
pub extend Tag with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Tag with Eq::{not_equal, equal}

///|
pub extend Tag with Show::{to_string, output}

///|
pub extend Velocity with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Velocity with Show::{to_string, output}

///|
pub extend Health with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Health with Show::{to_string, output}

///|
pub extend Sprite with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Sprite with Show::{to_string, output}
