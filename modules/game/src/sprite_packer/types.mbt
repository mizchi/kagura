///|
/// Input sprite for packing.
pub(all) struct SpriteInput {
  key : String
  spec : @atlas.ImageSpec
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
pub impl Show for PackedSprite with fn output(self, logger) {
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
pub impl Show for PackResult with fn output(self, logger) {
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
pub impl Show for PackerConfig with fn output(self, logger) {
  logger.write_object(to_repr(self))
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
