///|
/// Entity handle. Just an opaque slot index — the previous redesign added
/// a `generation` field for use-after-free detection, but the per-step
/// generation check cost ~100% on hot reads. Stale handles instead read
/// back stale data (same trade-off the original ECS made); call
/// `World::is_alive` if you need to verify a handle.
pub(all) struct EntityId {
  index : Int
} derive(Eq, Debug)

///|
pub impl Show for EntityId with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Sentinel "no entity" handle. `is_alive` is always false.
pub let entity_id_none : EntityId = { index: -1 }

///|
pub(all) enum Tag {
  Player
  Enemy
  Bullet
  Item
  Obstacle
  Custom(String)
} derive(Eq, Debug)

///|
pub impl Show for Tag with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct Velocity {
  x : Double
  y : Double
  z : Double
} derive(Debug)

///|
pub impl Show for Velocity with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct Health {
  current : Int
  max : Int
} derive(Debug)

///|
pub impl Show for Health with output(self, logger) {
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
pub impl Show for Sprite with output(self, logger) {
  logger.write_object(to_repr(self))
}
