///|
pub fn default_image_spec(width : Int32, height : Int32) -> ImageSpec {
  let seed = if width > 0 && height > 0 { width * 65537 + height } else { 0 }
  {
    width,
    height,
    format: "rgba8unorm",
    palette: checker_palette_from_seed(seed),
    pixels_rgba8: [],
  }
}

///|
pub fn image_spec_with_palette(
  width : Int32,
  height : Int32,
  palette : ImagePalette2x2,
) -> ImageSpec {
  { width, height, format: "rgba8unorm", palette, pixels_rgba8: [], }
}

///|
fn clamp_u8_channel(channel : Int32) -> Int32 {
  if channel < 0 {
    0
  } else if channel > 255 {
    255
  } else {
    channel
  }
}

///|
fn normalized_rgba8_channels(
  pixels_rgba8 : Array[Int32],
  width : Int32,
  height : Int32,
) -> Array[Int32] {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  let expected = safe_width * safe_height * 4
  let normalized : Array[Int32] = []
  if expected <= 0 || pixels_rgba8.length() < expected {
    normalized
  } else {
    for i in 0..<expected {
      normalized.push(clamp_u8_channel(pixels_rgba8[i]))
    }
    normalized
  }
}

///|
fn sample_rgba8_channel(
  pixels_rgba8 : Array[Int32],
  width : Int32,
  x : Int32,
  y : Int32,
  channel_index : Int32,
) -> Int32 {
  let base = (y * width + x) * 4 + channel_index
  if base < 0 || base >= pixels_rgba8.length() {
    0
  } else {
    clamp_u8_channel(pixels_rgba8[base])
  }
}

///|
fn palette_from_rgba8_channels(
  width : Int32,
  height : Int32,
  pixels_rgba8 : Array[Int32],
) -> ImagePalette2x2 {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  let expected = safe_width * safe_height * 4
  if expected <= 0 || pixels_rgba8.length() < expected {
    checker_palette_from_seed(safe_width * 65537 + safe_height)
  } else {
    let x1 = safe_width - 1
    let y1 = safe_height - 1
    new_image_palette_2x2(
      new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 3),
      ),
      new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 3),
      ),
      new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 3),
      ),
      new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, y1, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, y1, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, y1, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, y1, 3),
      ),
    )
  }
}

///|
pub fn image_spec_with_rgba8(
  width : Int32,
  height : Int32,
  pixels_rgba8 : Array[Int32],
) -> ImageSpec {
  let normalized = normalized_rgba8_channels(pixels_rgba8, width, height)
  {
    width,
    height,
    format: "rgba8unorm",
    palette: palette_from_rgba8_channels(width, height, normalized),
    pixels_rgba8: normalized,
  }
}

///|
fn expected_rgba8_channel_count(width : Int32, height : Int32) -> Int32 {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  safe_width * safe_height * 4
}

///|
fn has_valid_rgba8_payload(
  pixels_rgba8 : Array[Int32],
  width : Int32,
  height : Int32,
) -> Bool {
  let expected = expected_rgba8_channel_count(width, height)
  expected > 0 && pixels_rgba8.length() >= expected
}

///|
fn image_palette_eq(lhs : ImagePalette2x2, rhs : ImagePalette2x2) -> Bool {
  let mut ok = true
  for pixel_index in 0..<4 {
    for channel_index in 0..<4 {
      if palette_channel(lhs, pixel_index, channel_index) !=
        palette_channel(rhs, pixel_index, channel_index) {
        ok = false
      }
    }
  }
  ok
}

///|
fn image_pixels_eq(
  lhs : Array[Int32],
  rhs : Array[Int32],
  width : Int32,
  height : Int32,
) -> Bool {
  if !has_valid_rgba8_payload(lhs, width, height) ||
    !has_valid_rgba8_payload(rhs, width, height) {
    lhs.length() == 0 && rhs.length() == 0
  } else {
    let expected = expected_rgba8_channel_count(width, height)
    let mut ok = true
    for i in 0..<expected {
      if lhs[i] != rhs[i] {
        ok = false
      }
    }
    ok
  }
}

///|
fn source_dirty_rect_full(
  width : Int32,
  height : Int32,
) -> SourceImageDirtyRect {
  {
    x: 0,
    y: 0,
    width: if width <= 0 {
      1
    } else {
      width
    },
    height: if height <= 0 {
      1
    } else {
      height
    },
  }
}

///|
fn diff_dirty_rect_from_pixels(
  old_pixels : Array[Int32],
  new_pixels : Array[Int32],
  width : Int32,
  height : Int32,
) -> SourceImageDirtyRect? {
  if !has_valid_rgba8_payload(old_pixels, width, height) ||
    !has_valid_rgba8_payload(new_pixels, width, height) {
    if old_pixels.length() == 0 && new_pixels.length() == 0 {
      None
    } else {
      Some(source_dirty_rect_full(width, height))
    }
  } else {
    let mut min_x = width
    let mut min_y = height
    let mut max_x = -1
    let mut max_y = -1
    for y in 0..<height {
      for x in 0..<width {
        let base = (y * width + x) * 4
        let changed = old_pixels[base] != new_pixels[base] ||
          old_pixels[base + 1] != new_pixels[base + 1] ||
          old_pixels[base + 2] != new_pixels[base + 2] ||
          old_pixels[base + 3] != new_pixels[base + 3]
        if changed {
          if x < min_x {
            min_x = x
          }
          if y < min_y {
            min_y = y
          }
          if x > max_x {
            max_x = x
          }
          if y > max_y {
            max_y = y
          }
        }
      }
    }
    if max_x < 0 || max_y < 0 {
      None
    } else {
      Some({
        x: min_x,
        y: min_y,
        width: max_x - min_x + 1,
        height: max_y - min_y + 1,
      })
    }
  }
}

///|
fn merge_dirty_rects(
  lhs : SourceImageDirtyRect?,
  rhs : SourceImageDirtyRect?,
) -> SourceImageDirtyRect? {
  match lhs {
    None => rhs
    Some(a) =>
      match rhs {
        None => Some(a)
        Some(b) => {
          let x0 = if a.x < b.x { a.x } else { b.x }
          let y0 = if a.y < b.y { a.y } else { b.y }
          let ax1 = a.x + a.width
          let bx1 = b.x + b.width
          let ay1 = a.y + a.height
          let by1 = b.y + b.height
          let x1 = if ax1 > bx1 { ax1 } else { bx1 }
          let y1 = if ay1 > by1 { ay1 } else { by1 }
          Some({ x: x0, y: y0, width: x1 - x0, height: y1 - y0, })
        }
      }
  }
}
