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
} derive(Show)

///|
/// Result of packing sprites into an atlas.
pub(all) struct PackResult {
  width : Int
  height : Int
  sprites : Array[PackedSprite]
} derive(Show)

///|
/// Configuration for sprite packing.
pub(all) struct PackerConfig {
  max_width : Int
  max_height : Int
  padding : Int
  power_of_two : Bool
} derive(Show)
