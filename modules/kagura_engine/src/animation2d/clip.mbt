///|
/// Create a clip with uniform frame duration.
pub fn SpriteAnimationClip::uniform(
  name : String,
  keys : Array[@asset.AssetKey],
  frame_duration : Double,
) -> SpriteAnimationClip {
  let frames : Array[SpriteFrame] = []
  for key in keys {
    frames.push({ atlas_key: key, duration: frame_duration })
  }
  let total = frame_duration * keys.length().to_double()
  { name, frames, total_duration: total }
}

///|
/// Create a clip with custom per-frame durations.
pub fn SpriteAnimationClip::new(
  name : String,
  frames : Array[SpriteFrame],
) -> SpriteAnimationClip {
  let mut total = 0.0
  for f in frames {
    total = total + f.duration
  }
  { name, frames, total_duration: total }
}

///|
/// Generate asset keys like "prefix_0", "prefix_1", ..., "prefix_{count-1}".
pub fn sprite_sheet_keys(
  prefix : String,
  count : Int,
) -> Array[@asset.AssetKey] {
  let keys : Array[@asset.AssetKey] = []
  for i in 0..<count {
    keys.push(@asset.new_asset_key(prefix + "_" + i.to_string()))
  }
  keys
}
