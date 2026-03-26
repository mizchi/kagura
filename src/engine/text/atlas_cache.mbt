///|
/// GlyphAtlas persistent cache serialization.
/// Format: Array[Int] = [magic, w, h, pid, count, nx*1000, ny*1000, rh*1000,
///   (key, ax*1000, ay*1000, aw*1000, ah*1000) × count, pixels...]

///|
let atlas_cache_magic : Int = 0x474C4341

///|
pub fn GlyphAtlas::serialize_to_ints(self : GlyphAtlas) -> Array[Int] {
  let cache = self.cache
  let result : Array[Int] = []
  result.push(atlas_cache_magic)
  result.push(self.width)
  result.push(self.height)
  result.push(cache.atlas_page_id)
  result.push(cache.entry_count())
  result.push((cache.next_x * 1000.0).to_int())
  result.push((cache.next_y * 1000.0).to_int())
  result.push((cache.row_height * 1000.0).to_int())
  cache.entries.each(fn(key, entry) {
    result.push(key)
    result.push((entry.atlas_x * 1000.0).to_int())
    result.push((entry.atlas_y * 1000.0).to_int())
    result.push((entry.atlas_w * 1000.0).to_int())
    result.push((entry.atlas_h * 1000.0).to_int())
  })
  for px in self.pixels {
    result.push(px)
  }
  result
}

///|
pub fn GlyphAtlas::deserialize_from_ints(
  data : Array[Int],
  target_page_id : Int,
) -> GlyphAtlas? {
  if data.length() < 8 || data[0] != atlas_cache_magic {
    return None
  }
  let width = data[1]
  let height = data[2]
  let _page_id = data[3]
  let entry_count = data[4]
  let next_x = data[5].to_double() / 1000.0
  let next_y = data[6].to_double() / 1000.0
  let row_height = data[7].to_double() / 1000.0
  let mut pos = 8
  let cache = GlyphCache::new(width.to_double(), height.to_double(), target_page_id)
  cache.next_x = next_x
  cache.next_y = next_y
  cache.row_height = row_height
  for _i = 0; _i < entry_count; _i = _i + 1 {
    if pos + 5 > data.length() {
      return None
    }
    let key = data[pos]
    let ax = data[pos + 1].to_double() / 1000.0
    let ay = data[pos + 2].to_double() / 1000.0
    let aw = data[pos + 3].to_double() / 1000.0
    let ah = data[pos + 4].to_double() / 1000.0
    pos += 5
    cache.entries.set(
      key,
      {
        glyph_id: key,
        atlas_x: ax,
        atlas_y: ay,
        atlas_w: aw,
        atlas_h: ah,
        atlas_page_id: target_page_id,
      },
    )
  }
  let pixel_count = width * height * 4
  let pixels : Array[Int] = Array::make(pixel_count, 0)
  for i = 0; i < pixel_count; i = i + 1 {
    if pos + i < data.length() {
      pixels[i] = data[pos + i]
    }
  }
  Some({ cache, width, height, pixels, dirty: true, last_used_generation: 0 })
}

///|
/// Replace the first page of a TextRenderer with deserialized data.
pub fn TextRenderer::load_atlas_cache(
  self : TextRenderer,
  data : Array[Int],
) -> Bool {
  match GlyphAtlas::deserialize_from_ints(data, self.base_page_id) {
    Some(atlas) => {
      self.pages[0] = atlas
      true
    }
    None => false
  }
}
