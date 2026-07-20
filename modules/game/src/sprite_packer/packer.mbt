///|
/// Create default packer config: 2048x2048, padding=1, power_of_two=true.
pub fn PackerConfig::default() -> PackerConfig {
  { max_width: 2048, max_height: 2048, padding: 1, power_of_two: true }
}

///|
/// Pack sprites into an atlas using MaxRects algorithm.
/// Returns None if any sprite cannot fit.
pub fn pack_sprites(
  inputs : Array[SpriteInput],
  config? : PackerConfig = PackerConfig::default(),
) -> PackResult? {
  if inputs.is_empty() {
    let size = if config.power_of_two { 1 } else { 0 }
    return Some({ width: size, height: size, sprites: [] })
  }
  // Sort by area descending (larger sprites first for better packing)
  let indexed : Array[(Int, SpriteInput)] = []
  for i, inp in inputs {
    indexed.push((i, inp))
  }
  indexed.sort_by(fn(a, b) {
    let area_a = a.1.spec.width * a.1.spec.height
    let area_b = b.1.spec.width * b.1.spec.height
    area_b.compare(area_a)
  })
  let pad = config.padding
  let alloc = new_maxrects_allocator(config.max_width, config.max_height)
  let sprites : Array[PackedSprite] = []
  for item in indexed {
    let (_, inp) = item
    let padded_w = inp.spec.width + pad * 2
    let padded_h = inp.spec.height + pad * 2
    match alloc.insert(padded_w, padded_h) {
      None => return None
      Some(pos) =>
        sprites.push({
          key: inp.key,
          x: pos.x + pad,
          y: pos.y + pad,
          width: inp.spec.width,
          height: inp.spec.height,
        })
    }
  }
  // Compute tight bounds
  let mut max_x = 0
  let mut max_y = 0
  for s in sprites {
    let right = s.x + s.width + pad
    let bottom = s.y + s.height + pad
    if right > max_x {
      max_x = right
    }
    if bottom > max_y {
      max_y = bottom
    }
  }
  let width = if config.power_of_two { next_power_of_two(max_x) } else { max_x }
  let height = if config.power_of_two {
    next_power_of_two(max_y)
  } else {
    max_y
  }
  Some({ width, height, sprites })
}

///|
/// Compose packed sprites into an atlas image.
pub fn compose_packed_image(
  inputs : Array[SpriteInput],
  result : PackResult,
) -> @atlas.ImageSpec {
  let pixels : Array[Int] = Array::make(result.width * result.height * 4, 0)
  // Build lookup from key to spec
  let specs : Map[String, @atlas.ImageSpec] = Map([])
  for inp in inputs {
    specs[inp.key] = inp.spec
  }
  for sprite in result.sprites {
    let spec = match specs.get(sprite.key) {
      Some(s) => s
      None => continue
    }
    for row in 0..<sprite.height {
      for col in 0..<sprite.width {
        let src_idx = (row * spec.width + col) * 4
        let dst_x = sprite.x + col
        let dst_y = sprite.y + row
        let dst_idx = (dst_y * result.width + dst_x) * 4
        pixels[dst_idx] = spec.pixels_rgba8[src_idx]
        pixels[dst_idx + 1] = spec.pixels_rgba8[src_idx + 1]
        pixels[dst_idx + 2] = spec.pixels_rgba8[src_idx + 2]
        pixels[dst_idx + 3] = spec.pixels_rgba8[src_idx + 3]
      }
    }
  }
  @atlas.image_spec_with_rgba8(result.width, result.height, pixels)
}

///|
/// Round up to the next power of two.
fn next_power_of_two(n : Int) -> Int {
  if n <= 1 {
    return 1
  }
  let mut v = n - 1
  v = v | (v >> 1)
  v = v | (v >> 2)
  v = v | (v >> 4)
  v = v | (v >> 8)
  v = v | (v >> 16)
  v + 1
}
