///|
/// Input sprite for packing.
pub(all) struct SpriteInput {
  key : String
  spec : @asset.ImageSpec
}

///|
/// A sprite placed in the packed atlas.
pub(all) struct PackedSprite {
  key : String
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Debug)

///|
pub impl Show for PackedSprite with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Result of packing sprites into an atlas.
pub(all) struct PackResult {
  width : Int
  height : Int
  sprites : Array[PackedSprite]
} derive(Debug)

///|
pub impl Show for PackResult with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Configuration for sprite packing.
pub(all) struct PackerConfig {
  max_width : Int
  max_height : Int
  padding : Int
  power_of_two : Bool
} derive(Debug)

///|
pub impl Show for PackerConfig with output(self, logger) {
  logger.write_object(to_repr(self))
}
