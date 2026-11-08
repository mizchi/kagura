///|
#derive(Debug)
struct SimpleAtlasImageEntry {
  key : AssetKey
  handle : @gfx.ImageHandle
  region : AtlasRegion
  palette : ImagePalette2x2
  pixels_rgba8 : Array[Int32]
}

///|
pub impl Show for SimpleAtlasImageEntry with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
fn atlas_region_to_dirty_rect(region : AtlasRegion) -> SourceImageDirtyRect {
  { x: region.x, y: region.y, width: region.width, height: region.height, }
}

///|
fn atlas_local_dirty_to_page_dirty(
  region : AtlasRegion,
  local_rect : SourceImageDirtyRect?,
) -> SourceImageDirtyRect? {
  match local_rect {
    Some(rect) =>
      Some({
        x: region.x + rect.x,
        y: region.y + rect.y,
        width: rect.width,
        height: rect.height,
      })
    None => None
  }
}

///|
fn clamp_atlas_coord(value : Int32, bound : Int32) -> Int32 {
  if value < 0 {
    0
  } else if value > bound {
    bound
  } else {
    value
  }
}

///|
fn atlas_uv_from_region(
  region : AtlasRegion,
  atlas_width : Int32,
  atlas_height : Int32,
) -> AtlasDrawSource {
  let safe_width = if atlas_width <= 0 { 1 } else { atlas_width }
  let safe_height = if atlas_height <= 0 { 1 } else { atlas_height }
  let x0 = clamp_atlas_coord(region.x, safe_width)
  let y0 = clamp_atlas_coord(region.y, safe_height)
  let x1 = clamp_atlas_coord(region.x + region.width, safe_width)
  let y1 = clamp_atlas_coord(region.y + region.height, safe_height)
  {
    page_image_id: region.atlas_id,
    region,
    u0: x0.to_double() / safe_width.to_double(),
    v0: y0.to_double() / safe_height.to_double(),
    u1: x1.to_double() / safe_width.to_double(),
    v1: y1.to_double() / safe_height.to_double(),
  }
}

///|
fn mark_atlas_page_dirty(
  repo : SimpleAtlasImageRepository,
  dirty_rect : SourceImageDirtyRect?,
) -> Unit {
  match dirty_rect {
    Some(rect) => {
      repo.page_dirty_rect = merge_dirty_rects(repo.page_dirty_rect, Some(rect))
      repo.page_generation = next_image_generation(repo.page_generation)
    }
    None => ()
  }
}

///|
pub fn new_simple_atlas_image_repository(
  atlas_width : Int32,
  atlas_height : Int32,
  atlas_id : Int32,
) -> SimpleAtlasImageRepository {
  let safe_width = if atlas_width <= 0 { 1 } else { atlas_width }
  let safe_height = if atlas_height <= 0 { 1 } else { atlas_height }
  {
    atlas_width: safe_width,
    atlas_height: safe_height,
    atlas_id,
    next_image_id: 1,
    allocator: new_simple_atlas_allocator(safe_width, safe_height, atlas_id),
    images: [],
    page_generation: 0,
    page_dirty_rect: None,
  }
}

///|
pub fn create_atlas_image(
  repo : SimpleAtlasImageRepository,
  key : AssetKey,
  spec : ImageSpec,
) -> @gfx.ImageHandle? {
  for entry in repo.images {
    if asset_key_eq(entry.key, key) {
      return Some(entry.handle)
    }
  }
  let width = if spec.width <= 0 { 1 } else { spec.width }
  let height = if spec.height <= 0 { 1 } else { spec.height }
  let pixels_rgba8 = normalized_rgba8_channels(spec.pixels_rgba8, width, height)
  match repo.allocator.allocate(width, height) {
    Some(region) => {
      let handle = @gfx.new_image_handle(repo.next_image_id, width, height)
      repo.next_image_id = repo.next_image_id + 1
      repo.images.push({
        key,
        handle,
        region,
        palette: spec.palette,
        pixels_rgba8,
      })
      mark_atlas_page_dirty(repo, Some(atlas_region_to_dirty_rect(region)))
      Some(handle)
    }
    None => None
  }
}

///|
/// Register an image with a precomputed atlas region (bypasses allocator).
/// Used by sprite_packer to register MaxRects-packed results directly.
pub fn register_precomputed_image(
  repo : SimpleAtlasImageRepository,
  key : AssetKey,
  region : AtlasRegion,
  spec : ImageSpec,
) -> @gfx.ImageHandle {
  for entry in repo.images {
    if asset_key_eq(entry.key, key) {
      return entry.handle
    }
  }
  let width = if spec.width <= 0 { 1 } else { spec.width }
  let height = if spec.height <= 0 { 1 } else { spec.height }
  let pixels_rgba8 = normalized_rgba8_channels(spec.pixels_rgba8, width, height)
  let handle = @gfx.new_image_handle(repo.next_image_id, width, height)
  repo.next_image_id = repo.next_image_id + 1
  repo.images.push({ key, handle, region, palette: spec.palette, pixels_rgba8, })
  mark_atlas_page_dirty(repo, Some(atlas_region_to_dirty_rect(region)))
  handle
}

///|
pub fn get_atlas_image_region(
  repo : SimpleAtlasImageRepository,
  key : AssetKey,
) -> AtlasRegion? {
  let mut out : AtlasRegion? = None
  for entry in repo.images {
    if asset_key_eq(entry.key, key) {
      out = Some(entry.region)
    }
  }
  out
}

///|
pub fn get_atlas_draw_source(
  repo : SimpleAtlasImageRepository,
  key : AssetKey,
) -> AtlasDrawSource? {
  let mut out : AtlasDrawSource? = None
  for entry in repo.images {
    if asset_key_eq(entry.key, key) {
      out = Some(
        atlas_uv_from_region(entry.region, repo.atlas_width, repo.atlas_height),
      )
    }
  }
  out
}

///|
pub fn update_atlas_image_spec(
  repo : SimpleAtlasImageRepository,
  key : AssetKey,
  spec : ImageSpec,
) -> @gfx.ImageHandle? {
  let width = if spec.width <= 0 { 1 } else { spec.width }
  let height = if spec.height <= 0 { 1 } else { spec.height }
  let pixels_rgba8 = normalized_rgba8_channels(spec.pixels_rgba8, width, height)
  let next : Array[SimpleAtlasImageEntry] = []
  let mut updated : @gfx.ImageHandle? = None
  let mut page_dirty_rect : SourceImageDirtyRect? = None
  for entry in repo.images {
    if asset_key_eq(entry.key, key) {
      if entry.handle.width == width && entry.handle.height == height {
        let old_has_pixels = has_valid_rgba8_payload(
          entry.pixels_rgba8,
          width,
          height,
        )
        let new_has_pixels = has_valid_rgba8_payload(
          pixels_rgba8, width, height,
        )
        let pixels_changed = !image_pixels_eq(
          entry.pixels_rgba8,
          pixels_rgba8,
          width,
          height,
        )
        let palette_changed = !image_palette_eq(entry.palette, spec.palette)
        let diff_rect = if pixels_changed {
          diff_dirty_rect_from_pixels(
            entry.pixels_rgba8,
            pixels_rgba8,
            width,
            height,
          )
        } else {
          None
        }
        let palette_rect = if palette_changed &&
          !(old_has_pixels && new_has_pixels) {
          Some(source_dirty_rect_full(width, height))
        } else {
          None
        }
        let local_dirty_rect = merge_dirty_rects(diff_rect, palette_rect)
        page_dirty_rect = merge_dirty_rects(
          page_dirty_rect,
          atlas_local_dirty_to_page_dirty(entry.region, local_dirty_rect),
        )
        if pixels_changed || palette_changed {
          next.push({
            key: entry.key,
            handle: entry.handle,
            region: entry.region,
            palette: spec.palette,
            pixels_rgba8,
          })
        } else {
          next.push(entry)
        }
        updated = Some(entry.handle)
      } else {
        next.push(entry)
      }
    } else {
      next.push(entry)
    }
  }
  repo.images = next
  mark_atlas_page_dirty(repo, page_dirty_rect)
  updated
}

///|
pub fn remove_atlas_image(
  repo : SimpleAtlasImageRepository,
  key : AssetKey,
) -> Unit {
  let next : Array[SimpleAtlasImageEntry] = []
  let mut released_dirty_rect : SourceImageDirtyRect? = None
  for entry in repo.images {
    if asset_key_eq(entry.key, key) {
      repo.allocator.release(entry.region)
      released_dirty_rect = merge_dirty_rects(
        released_dirty_rect,
        Some(atlas_region_to_dirty_rect(entry.region)),
      )
    } else {
      next.push(entry)
    }
  }
  repo.images = next
  mark_atlas_page_dirty(repo, released_dirty_rect)
  let _ = atlas_allocator_reset_if_empty(repo.allocator)
}

///|
fn new_blank_rgba8_channels(width : Int32, height : Int32) -> Array[Int32] {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  let out : Array[Int32] = []
  for _ in 0..<(safe_width * safe_height * 4) {
    out.push(0)
  }
  out
}

///|
fn fill_atlas_page_pixels_from_entry(
  pixels_rgba8 : Array[Int32],
  atlas_width : Int32,
  atlas_height : Int32,
  entry : SimpleAtlasImageEntry,
) -> Unit {
  let image_width = if entry.handle.width <= 0 { 1 } else { entry.handle.width }
  let image_height = if entry.handle.height <= 0 {
    1
  } else {
    entry.handle.height
  }
  let has_pixels = has_valid_rgba8_payload(
    entry.pixels_rgba8,
    image_width,
    image_height,
  )
  let fallback_r = palette_channel(entry.palette, 0, 0)
  let fallback_g = palette_channel(entry.palette, 0, 1)
  let fallback_b = palette_channel(entry.palette, 0, 2)
  let fallback_a = palette_channel(entry.palette, 0, 3)
  for local_y in 0..<image_height {
    let atlas_y = entry.region.y + local_y
    if atlas_y < 0 || atlas_y >= atlas_height {
      continue
    }
    for local_x in 0..<image_width {
      let atlas_x = entry.region.x + local_x
      if atlas_x < 0 || atlas_x >= atlas_width {
        continue
      }
      let dst_base = (atlas_y * atlas_width + atlas_x) * 4
      if has_pixels {
        let src_base = (local_y * image_width + local_x) * 4
        pixels_rgba8[dst_base] = entry.pixels_rgba8[src_base]
        pixels_rgba8[dst_base + 1] = entry.pixels_rgba8[src_base + 1]
        pixels_rgba8[dst_base + 2] = entry.pixels_rgba8[src_base + 2]
        pixels_rgba8[dst_base + 3] = entry.pixels_rgba8[src_base + 3]
      } else {
        pixels_rgba8[dst_base] = fallback_r
        pixels_rgba8[dst_base + 1] = fallback_g
        pixels_rgba8[dst_base + 2] = fallback_b
        pixels_rgba8[dst_base + 3] = fallback_a
      }
    }
  }
}

///|
fn compose_atlas_page_rgba8(repo : SimpleAtlasImageRepository) -> Array[Int32] {
  let pixels_rgba8 = new_blank_rgba8_channels(
    repo.atlas_width,
    repo.atlas_height,
  )
  for entry in repo.images {
    fill_atlas_page_pixels_from_entry(
      pixels_rgba8,
      repo.atlas_width,
      repo.atlas_height,
      entry,
    )
  }
  pixels_rgba8
}

///|
pub fn list_dirty_atlas_page_bindings(
  repo : SimpleAtlasImageRepository,
) -> Array[SourceImageBinding] {
  let bindings : Array[SourceImageBinding] = []
  match repo.page_dirty_rect {
    Some(rect) => {
      let page_pixels_rgba8 = compose_atlas_page_rgba8(repo)
      bindings.push({
        image_id: repo.atlas_id,
        width: repo.atlas_width,
        height: repo.atlas_height,
        generation: if repo.page_generation <= 0 {
          1
        } else {
          repo.page_generation
        },
        dirty_rect: Some(rect),
        palette: palette_from_rgba8_channels(
          repo.atlas_width,
          repo.atlas_height,
          page_pixels_rgba8,
        ),
        pixels_rgba8: page_pixels_rgba8,
      })
    }
    None => ()
  }
  bindings
}

///|
pub fn clear_dirty_atlas_page_flags(repo : SimpleAtlasImageRepository) -> Int32 {
  match repo.page_dirty_rect {
    Some(_) => {
      repo.page_dirty_rect = None
      1
    }
    None => 0
  }
}

///|
pub fn atlas_page_is_empty(repo : SimpleAtlasImageRepository) -> Bool {
  repo.images.length() == 0
}

///|
pub fn atlas_page_image_count(repo : SimpleAtlasImageRepository) -> Int32 {
  repo.images.length()
}

///|
pub fn atlas_page_stats(repo : SimpleAtlasImageRepository) -> AtlasPageStats {
  {
    atlas_id: repo.atlas_id,
    image_count: repo.images.length(),
    allocated_region_count: repo.allocator.allocated.length(),
    atlas_width: repo.atlas_width,
    atlas_height: repo.atlas_height,
    is_empty: repo.images.length() == 0,
  }
}

///|
pub extend SimpleAtlasImageEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SimpleAtlasImageEntry with Show::{to_string, output}
