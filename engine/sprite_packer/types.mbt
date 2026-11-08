///|
/// Input sprite for packing.
pub(all) struct SpriteInput {
  key : String
  spec : @atlas.ImageSpec
}

///|
/// A sprite placed in the packed atlas.
#derive(Debug)
pub(all) struct PackedSprite {
  key : String
  x : Int32
  y : Int32
  width : Int32
  height : Int32
}

///|
pub impl Show for PackedSprite with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Result of packing sprites into an atlas.
#derive(Debug)
pub(all) struct PackResult {
  width : Int32
  height : Int32
  sprites : Array[PackedSprite]
}

///|
pub impl Show for PackResult with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Configuration for sprite packing.
#derive(Debug)
pub(all) struct PackerConfig {
  max_width : Int32
  max_height : Int32
  padding : Int32
  power_of_two : Bool
}

///|
pub impl Show for PackerConfig with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub extend PackedSprite with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PackedSprite with Show::{to_string, output}

///|
pub extend PackResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PackResult with Show::{to_string, output}

///|
pub extend PackerConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PackerConfig with Show::{to_string, output}
