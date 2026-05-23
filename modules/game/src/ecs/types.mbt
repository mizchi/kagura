///|
/// Entity handle. `index` is the slot inside `World`; `generation` is bumped
/// every time the slot is recycled, so a stale `EntityId` held after a
/// `despawn` will fail the generation check and look like a dead entity.
///
/// Mirrors the index+generation pattern in RhodoniteMBT
/// (`moon/rhodonite_core/src/ecs/types.mbt`).
pub(all) struct EntityId {
  index : Int
  generation : Int
} derive(Eq, Debug)

///|
pub impl Show for EntityId with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Sentinel "no entity" handle. `is_alive` is always false.
pub let entity_id_none : EntityId = { index: -1, generation: -1 }

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
