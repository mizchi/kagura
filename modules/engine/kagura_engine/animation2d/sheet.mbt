///|
/// Extract a sub-region from an ImageSpec as a new ImageSpec.
pub fn extract_subimage_spec(
  source : @atlas.ImageSpec,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> @atlas.ImageSpec {
  let pixels : Array[Int] = Array::make(w * h * 4, 0)
  for row in 0..<h {
    let src_y = y + row
    if src_y < source.height {
      for col in 0..<w {
        let src_x = x + col
        if src_x < source.width {
          let src_idx = (src_y * source.width + src_x) * 4
          let dst_idx = (row * w + col) * 4
          pixels[dst_idx] = source.pixels_rgba8[src_idx]
          pixels[dst_idx + 1] = source.pixels_rgba8[src_idx + 1]
          pixels[dst_idx + 2] = source.pixels_rgba8[src_idx + 2]
          pixels[dst_idx + 3] = source.pixels_rgba8[src_idx + 3]
        }
      }
    }
  }
  @atlas.image_spec_with_rgba8(w, h, pixels)
}

///|
/// Split a sprite sheet into individual image specs.
/// Returns the generated asset keys and image specs.
pub fn split_sprite_sheet(
  sheet : @atlas.ImageSpec,
  prefix : String,
  cols : Int,
  rows : Int,
  frame_w : Int,
  frame_h : Int,
) -> Array[(@atlas.AssetKey, @atlas.ImageSpec)] {
  let results : Array[(@atlas.AssetKey, @atlas.ImageSpec)] = []
  let mut idx = 0
  for row in 0..<rows {
    for col in 0..<cols {
      let x = col * frame_w
      let y = row * frame_h
      let key = @atlas.new_asset_key(prefix + "_" + idx.to_string())
      let sub = extract_subimage_spec(sheet, x, y, frame_w, frame_h)
      results.push((key, sub))
      idx = idx + 1
    }
  }
  results
}

///|
/// Split a sprite sheet into individual image specs and register each frame
/// in the atlas repository. Returns the generated asset keys.
pub fn register_sprite_sheet(
  atlas : @atlas.SimpleAtlasImageRepository,
  sheet : @atlas.ImageSpec,
  prefix : String,
  cols : Int,
  rows : Int,
  frame_w : Int,
  frame_h : Int,
) -> Array[@atlas.AssetKey] {
  let frames = split_sprite_sheet(sheet, prefix, cols, rows, frame_w, frame_h)
  let keys : Array[@atlas.AssetKey] = []
  for pair in frames {
    let (key, spec) = pair
    let _ = @atlas.create_atlas_image(atlas, key, spec)
    keys.push(key)
  }
  keys
}
