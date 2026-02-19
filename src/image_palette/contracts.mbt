///|
/// Source-image palette contracts.
///
/// 2x2 RGBA texel palette intended as a minimal transferable form
/// between asset/image repositories and backend upload layers.

///|
pub struct Rgba {
  r : Int
  g : Int
  b : Int
  a : Int
} derive(Show)

///|
pub struct ImagePalette2x2 {
  p00 : Rgba
  p10 : Rgba
  p01 : Rgba
  p11 : Rgba
} derive(Show)

///|
pub fn clamp_channel(channel : Int) -> Int {
  if channel < 0 {
    0
  } else if channel > 255 {
    255
  } else {
    channel
  }
}

///|
pub fn new_rgba(r : Int, g : Int, b : Int, a : Int) -> Rgba {
  {
    r: clamp_channel(r),
    g: clamp_channel(g),
    b: clamp_channel(b),
    a: clamp_channel(a),
  }
}

///|
pub fn new_image_palette_2x2(
  p00 : Rgba,
  p10 : Rgba,
  p01 : Rgba,
  p11 : Rgba,
) -> ImagePalette2x2 {
  { p00, p10, p01, p11 }
}

///|
pub fn new_solid_palette(color : Rgba) -> ImagePalette2x2 {
  { p00: color, p10: color, p01: color, p11: color }
}

///|
fn channel_from_rgba(color : Rgba, channel_index : Int) -> Int {
  match channel_index {
    0 => color.r
    1 => color.g
    2 => color.b
    3 => color.a
    _ => -1
  }
}

///|
pub fn palette_channel(
  palette : ImagePalette2x2,
  pixel_index : Int,
  channel_index : Int,
) -> Int {
  let color = match pixel_index {
    0 => Some(palette.p00)
    1 => Some(palette.p10)
    2 => Some(palette.p01)
    3 => Some(palette.p11)
    _ => None
  }
  match color {
    Some(rgba) => channel_from_rgba(rgba, channel_index)
    None => -1
  }
}

///|
pub fn checker_palette_from_seed(seed : Int) -> ImagePalette2x2 {
  let normalized_seed = if seed < 0 { 0 } else { seed }
  let seed0 = (normalized_seed * 53 + 17) & 255
  let seed1 = (normalized_seed * 97 + 73) & 255
  let seed2 = (normalized_seed * 193 + 151) & 255
  let inv0 = 255 - seed0
  let inv1 = 255 - seed1
  let inv2 = 255 - seed2
  {
    p00: new_rgba(seed0, seed1, seed2, 255),
    p10: new_rgba(inv0, inv1, inv2, 255),
    p01: new_rgba(inv0, seed1, seed2, 255),
    p11: new_rgba(seed0, inv1, inv2, 255),
  }
}
