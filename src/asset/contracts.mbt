///|
/// Asset contracts (image/shader/material/atlas).
///
/// Ebiten refs:
/// - internal/atlas/image.go
/// - internal/atlas/shader.go

///|
pub struct AssetKey {
  value : String
} derive(Show)

///|
pub fn new_asset_key(value : String) -> AssetKey {
  { value, }
}

///|
pub struct ImageSpec {
  width : Int
  height : Int
  format : String
  palette : @image_palette.ImagePalette2x2
  pixels_rgba8 : Array[Int]
} derive(Show)

///|
pub struct ShaderSpec {
  debug_name : String
  source : String
} derive(Show)

///|
pub struct MaterialSpec {
  shader : AssetKey
  blend : @gfx.BlendMode
  filter : @gfx.FilterMode
  uniform_keys : Array[String]
} derive(Show)

///|
pub struct AtlasRegion {
  x : Int
  y : Int
  width : Int
  height : Int
  atlas_id : Int
} derive(Show)

///|
pub struct ImagePaletteBinding {
  image_id : Int
  palette : @image_palette.ImagePalette2x2
} derive(Show)

///|
pub struct SourceImageDirtyRect {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Show)

///|
pub struct SourceImageBinding {
  image_id : Int
  width : Int
  height : Int
  generation : Int
  dirty_rect : SourceImageDirtyRect?
  palette : @image_palette.ImagePalette2x2
  pixels_rgba8 : Array[Int]
} derive(Show)

///|
pub struct AtlasDrawSource {
  page_image_id : Int
  region : AtlasRegion
  u0 : Double
  v0 : Double
  u1 : Double
  v1 : Double
} derive(Show)

///|
pub fn new_unmanaged_atlas_draw_source(image_id : Int) -> AtlasDrawSource {
  let safe_image_id = if image_id < 0 { 0 } else { image_id }
  {
    page_image_id: safe_image_id,
    region: { x: 0, y: 0, width: 1, height: 1, atlas_id: safe_image_id },
    u0: 0.0,
    v0: 0.0,
    u1: 1.0,
    v1: 1.0,
  }
}

///|
pub trait ImageRepository {
  create_image(Self, key : AssetKey, spec : ImageSpec) -> @gfx.ImageHandle raise
  get_image(Self, key : AssetKey) -> @gfx.ImageHandle?
  remove_image(Self, key : AssetKey) -> Unit raise
}

///|
pub trait ShaderRepository {
  create_shader(Self, key : AssetKey, spec : ShaderSpec) -> @gfx.ShaderHandle raise
  get_shader(Self, key : AssetKey) -> @gfx.ShaderHandle?
  remove_shader(Self, key : AssetKey) -> Unit raise
}

///|
pub trait MaterialRepository {
  register_material(Self, key : AssetKey, spec : MaterialSpec) -> Unit raise
  get_material(Self, key : AssetKey) -> MaterialSpec?
}

///|
pub trait AtlasAllocator {
  allocate(Self, width : Int, height : Int) -> AtlasRegion?
  release(Self, region : AtlasRegion) -> Unit
}

///|
pub fn default_image_spec(width : Int, height : Int) -> ImageSpec {
  let seed = if width > 0 && height > 0 { width * 65537 + height } else { 0 }
  {
    width,
    height,
    format: "rgba8unorm",
    palette: @image_palette.checker_palette_from_seed(seed),
    pixels_rgba8: [],
  }
}

///|
pub fn image_spec_with_palette(
  width : Int,
  height : Int,
  palette : @image_palette.ImagePalette2x2,
) -> ImageSpec {
  { width, height, format: "rgba8unorm", palette, pixels_rgba8: [] }
}

///|
fn clamp_u8_channel(channel : Int) -> Int {
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
  pixels_rgba8 : Array[Int],
  width : Int,
  height : Int,
) -> Array[Int] {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  let expected = safe_width * safe_height * 4
  let normalized : Array[Int] = []
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
  pixels_rgba8 : Array[Int],
  width : Int,
  x : Int,
  y : Int,
  channel_index : Int,
) -> Int {
  let base = (y * width + x) * 4 + channel_index
  if base < 0 || base >= pixels_rgba8.length() {
    0
  } else {
    clamp_u8_channel(pixels_rgba8[base])
  }
}

///|
fn palette_from_rgba8_channels(
  width : Int,
  height : Int,
  pixels_rgba8 : Array[Int],
) -> @image_palette.ImagePalette2x2 {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  let expected = safe_width * safe_height * 4
  if expected <= 0 || pixels_rgba8.length() < expected {
    @image_palette.checker_palette_from_seed(safe_width * 65537 + safe_height)
  } else {
    let x1 = safe_width - 1
    let y1 = safe_height - 1
    @image_palette.new_image_palette_2x2(
      @image_palette.new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, 0, 3),
      ),
      @image_palette.new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, x1, 0, 3),
      ),
      @image_palette.new_rgba(
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 0),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 1),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 2),
        sample_rgba8_channel(pixels_rgba8, safe_width, 0, y1, 3),
      ),
      @image_palette.new_rgba(
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
  width : Int,
  height : Int,
  pixels_rgba8 : Array[Int],
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
fn expected_rgba8_channel_count(width : Int, height : Int) -> Int {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  safe_width * safe_height * 4
}

///|
fn has_valid_rgba8_payload(
  pixels_rgba8 : Array[Int],
  width : Int,
  height : Int,
) -> Bool {
  let expected = expected_rgba8_channel_count(width, height)
  expected > 0 && pixels_rgba8.length() >= expected
}

///|
fn image_palette_eq(
  lhs : @image_palette.ImagePalette2x2,
  rhs : @image_palette.ImagePalette2x2,
) -> Bool {
  let mut ok = true
  for pixel_index in 0..<4 {
    for channel_index in 0..<4 {
      if @image_palette.palette_channel(lhs, pixel_index, channel_index) !=
        @image_palette.palette_channel(rhs, pixel_index, channel_index) {
        ok = false
      }
    }
  }
  ok
}

///|
fn image_pixels_eq(
  lhs : Array[Int],
  rhs : Array[Int],
  width : Int,
  height : Int,
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
fn source_dirty_rect_full(width : Int, height : Int) -> SourceImageDirtyRect {
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
  old_pixels : Array[Int],
  new_pixels : Array[Int],
  width : Int,
  height : Int,
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
          Some({ x: x0, y: y0, width: x1 - x0, height: y1 - y0 })
        }
      }
  }
}

///|
struct SimpleImageEntry {
  key : AssetKey
  handle : @gfx.ImageHandle
  palette : @image_palette.ImagePalette2x2
  pixels_rgba8 : Array[Int]
  generation : Int
  dirty_rect : SourceImageDirtyRect?
} derive(Show)

///|
struct SimpleShaderEntry {
  key : AssetKey
  handle : @gfx.ShaderHandle
} derive(Show)

///|
struct SimpleMaterialEntry {
  key : AssetKey
  spec : MaterialSpec
} derive(Show)

///|
pub struct SimpleImageRepository {
  mut next_image_id : Int
  mut images : Array[SimpleImageEntry]
}

///|
pub struct SimpleShaderRepository {
  mut next_shader_id : Int
  mut shaders : Array[SimpleShaderEntry]
}

///|
pub struct SimpleMaterialRepository {
  mut materials : Array[SimpleMaterialEntry]
}

///|
fn asset_key_eq(lhs : AssetKey, rhs : AssetKey) -> Bool {
  lhs.value == rhs.value
}

///|
fn find_image_handle(
  images : Array[SimpleImageEntry],
  key : AssetKey,
) -> @gfx.ImageHandle? {
  let mut out : @gfx.ImageHandle? = None
  for entry in images {
    if asset_key_eq(entry.key, key) {
      out = Some(entry.handle)
    }
  }
  out
}

///|
fn find_image_palette_by_id(
  images : Array[SimpleImageEntry],
  image_id : Int,
) -> @image_palette.ImagePalette2x2? {
  let mut out : @image_palette.ImagePalette2x2? = None
  for entry in images {
    if entry.handle.id == image_id {
      out = Some(entry.palette)
    }
  }
  out
}

///|
fn find_image_pixels_by_id(
  images : Array[SimpleImageEntry],
  image_id : Int,
) -> Array[Int]? {
  let mut out : Array[Int]? = None
  for entry in images {
    if entry.handle.id == image_id {
      out = Some(entry.pixels_rgba8)
    }
  }
  out
}

///|
fn find_image_generation_by_id(
  images : Array[SimpleImageEntry],
  image_id : Int,
) -> Int? {
  let mut out : Int? = None
  for entry in images {
    if entry.handle.id == image_id {
      out = Some(entry.generation)
    }
  }
  out
}

///|
fn find_shader_handle(
  shaders : Array[SimpleShaderEntry],
  key : AssetKey,
) -> @gfx.ShaderHandle? {
  let mut out : @gfx.ShaderHandle? = None
  for entry in shaders {
    if asset_key_eq(entry.key, key) {
      out = Some(entry.handle)
    }
  }
  out
}

///|
fn find_material_spec(
  materials : Array[SimpleMaterialEntry],
  key : AssetKey,
) -> MaterialSpec? {
  let mut out : MaterialSpec? = None
  for entry in materials {
    if asset_key_eq(entry.key, key) {
      out = Some(entry.spec)
    }
  }
  out
}

///|
pub fn new_simple_image_repository() -> SimpleImageRepository {
  { next_image_id: 1, images: [] }
}

///|
pub fn get_image_palette_by_id(
  repo : SimpleImageRepository,
  image_id : Int,
) -> @image_palette.ImagePalette2x2? {
  find_image_palette_by_id(repo.images, image_id)
}

///|
pub fn list_image_palette_bindings(
  repo : SimpleImageRepository,
) -> Array[ImagePaletteBinding] {
  let bindings : Array[ImagePaletteBinding] = []
  for entry in repo.images {
    bindings.push({ image_id: entry.handle.id, palette: entry.palette })
  }
  bindings
}

///|
pub fn get_image_pixels_by_id(
  repo : SimpleImageRepository,
  image_id : Int,
) -> Array[Int]? {
  find_image_pixels_by_id(repo.images, image_id)
}

///|
pub fn get_image_generation_by_id(
  repo : SimpleImageRepository,
  image_id : Int,
) -> Int {
  match find_image_generation_by_id(repo.images, image_id) {
    Some(generation) => if generation <= 0 { 1 } else { generation }
    None => 0
  }
}

///|
pub fn list_source_image_bindings(
  repo : SimpleImageRepository,
) -> Array[SourceImageBinding] {
  let bindings : Array[SourceImageBinding] = []
  for entry in repo.images {
    bindings.push({
      image_id: entry.handle.id,
      width: entry.handle.width,
      height: entry.handle.height,
      generation: entry.generation,
      dirty_rect: entry.dirty_rect,
      palette: entry.palette,
      pixels_rgba8: entry.pixels_rgba8,
    })
  }
  bindings
}

///|
pub fn list_dirty_source_image_bindings(
  repo : SimpleImageRepository,
) -> Array[SourceImageBinding] {
  let bindings : Array[SourceImageBinding] = []
  for entry in repo.images {
    match entry.dirty_rect {
      Some(rect) =>
        bindings.push({
          image_id: entry.handle.id,
          width: entry.handle.width,
          height: entry.handle.height,
          generation: entry.generation,
          dirty_rect: Some(rect),
          palette: entry.palette,
          pixels_rgba8: entry.pixels_rgba8,
        })
      None => ()
    }
  }
  bindings
}

///|
pub fn clear_source_image_dirty_flags(repo : SimpleImageRepository) -> Int {
  let next : Array[SimpleImageEntry] = []
  let mut cleared = 0
  for entry in repo.images {
    match entry.dirty_rect {
      Some(_) => {
        next.push({
          key: entry.key,
          handle: entry.handle,
          palette: entry.palette,
          pixels_rgba8: entry.pixels_rgba8,
          generation: entry.generation,
          dirty_rect: None,
        })
        cleared = cleared + 1
      }
      None => next.push(entry)
    }
  }
  repo.images = next
  cleared
}

///|
fn next_image_generation(current : Int) -> Int {
  if current <= 0 {
    1
  } else {
    current + 1
  }
}

///|
pub fn update_image_spec(
  repo : SimpleImageRepository,
  key : AssetKey,
  spec : ImageSpec,
) -> @gfx.ImageHandle? {
  let width = if spec.width <= 0 { 1 } else { spec.width }
  let height = if spec.height <= 0 { 1 } else { spec.height }
  let pixels_rgba8 = normalized_rgba8_channels(spec.pixels_rgba8, width, height)
  let next : Array[SimpleImageEntry] = []
  let mut updated : @gfx.ImageHandle? = None
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
        let dirty_rect = merge_dirty_rects(
          entry.dirty_rect,
          merge_dirty_rects(diff_rect, palette_rect),
        )
        if pixels_changed || palette_changed {
          next.push({
            key: entry.key,
            handle: entry.handle,
            palette: spec.palette,
            pixels_rgba8,
            generation: next_image_generation(entry.generation),
            dirty_rect,
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
  updated
}

///|
pub fn new_simple_shader_repository() -> SimpleShaderRepository {
  { next_shader_id: 1, shaders: [] }
}

///|
pub fn new_simple_material_repository() -> SimpleMaterialRepository {
  { materials: [] }
}

///|
pub impl ImageRepository for SimpleImageRepository with create_image(
  self,
  key,
  spec,
) {
  match find_image_handle(self.images, key) {
    Some(handle) => handle
    None => {
      let width = if spec.width <= 0 { 1 } else { spec.width }
      let height = if spec.height <= 0 { 1 } else { spec.height }
      let pixels_rgba8 = normalized_rgba8_channels(
        spec.pixels_rgba8,
        width,
        height,
      )
      let handle = @gfx.new_image_handle(self.next_image_id, width, height)
      self.next_image_id = self.next_image_id + 1
      self.images.push({
        key,
        handle,
        palette: spec.palette,
        pixels_rgba8,
        generation: 1,
        dirty_rect: Some(source_dirty_rect_full(width, height)),
      })
      handle
    }
  }
}

///|
pub impl ImageRepository for SimpleImageRepository with get_image(self, key) {
  find_image_handle(self.images, key)
}

///|
pub impl ImageRepository for SimpleImageRepository with remove_image(self, key) {
  let next : Array[SimpleImageEntry] = []
  for entry in self.images {
    if !asset_key_eq(entry.key, key) {
      next.push(entry)
    }
  }
  self.images = next
}

///|
pub impl ShaderRepository for SimpleShaderRepository with create_shader(
  self,
  key,
  spec,
) {
  match find_shader_handle(self.shaders, key) {
    Some(handle) => handle
    None => {
      let handle = @gfx.new_shader_handle(self.next_shader_id, spec.source)
      self.next_shader_id = self.next_shader_id + 1
      self.shaders.push({ key, handle })
      handle
    }
  }
}

///|
pub impl ShaderRepository for SimpleShaderRepository with get_shader(self, key) {
  find_shader_handle(self.shaders, key)
}

///|
pub impl ShaderRepository for SimpleShaderRepository with remove_shader(
  self,
  key,
) {
  let next : Array[SimpleShaderEntry] = []
  for entry in self.shaders {
    if !asset_key_eq(entry.key, key) {
      next.push(entry)
    }
  }
  self.shaders = next
}

///|
pub impl MaterialRepository for SimpleMaterialRepository with register_material(
  self,
  key,
  spec,
) {
  let next : Array[SimpleMaterialEntry] = []
  let mut replaced = false
  for entry in self.materials {
    if asset_key_eq(entry.key, key) {
      next.push({ key, spec })
      replaced = true
    } else {
      next.push(entry)
    }
  }
  if !replaced {
    next.push({ key, spec })
  }
  self.materials = next
}

///|
pub impl MaterialRepository for SimpleMaterialRepository with get_material(
  self,
  key,
) {
  find_material_spec(self.materials, key)
}

///|
pub struct SimpleAtlasAllocator {
  atlas_width : Int
  atlas_height : Int
  atlas_id : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut row_height : Int
  mut allocated : Array[AtlasRegion]
}

///|
fn atlas_region_eq(lhs : AtlasRegion, rhs : AtlasRegion) -> Bool {
  lhs.x == rhs.x &&
  lhs.y == rhs.y &&
  lhs.width == rhs.width &&
  lhs.height == rhs.height &&
  lhs.atlas_id == rhs.atlas_id
}

///|
pub fn new_simple_atlas_allocator(
  atlas_width : Int,
  atlas_height : Int,
  atlas_id : Int,
) -> SimpleAtlasAllocator {
  {
    atlas_width: if atlas_width <= 0 {
      1
    } else {
      atlas_width
    },
    atlas_height: if atlas_height <= 0 {
      1
    } else {
      atlas_height
    },
    atlas_id,
    cursor_x: 0,
    cursor_y: 0,
    row_height: 0,
    allocated: [],
  }
}

///|
pub impl AtlasAllocator for SimpleAtlasAllocator with allocate(
  self,
  width,
  height,
) {
  if width <= 0 || height <= 0 {
    None
  } else if width > self.atlas_width || height > self.atlas_height {
    None
  } else {
    if self.cursor_x + width > self.atlas_width {
      self.cursor_x = 0
      self.cursor_y = self.cursor_y + self.row_height
      self.row_height = 0
    }
    if self.cursor_y + height > self.atlas_height {
      None
    } else {
      let region : AtlasRegion = {
        x: self.cursor_x,
        y: self.cursor_y,
        width,
        height,
        atlas_id: self.atlas_id,
      }
      self.cursor_x = self.cursor_x + width
      if height > self.row_height {
        self.row_height = height
      }
      self.allocated.push(region)
      Some(region)
    }
  }
}

///|
pub impl AtlasAllocator for SimpleAtlasAllocator with release(self, region) {
  let next : Array[AtlasRegion] = []
  for current in self.allocated {
    if !atlas_region_eq(current, region) {
      next.push(current)
    }
  }
  self.allocated = next
}

///|
struct SimpleAtlasImageEntry {
  key : AssetKey
  handle : @gfx.ImageHandle
  region : AtlasRegion
  palette : @image_palette.ImagePalette2x2
  pixels_rgba8 : Array[Int]
} derive(Show)

///|
///
/// Atlas image repository with page-level dirty tracking.
///
/// Ebiten refs:
/// - internal/atlas/image.go
/// - internal/atlas/image.go (writePixels / region updates)
pub struct SimpleAtlasImageRepository {
  atlas_width : Int
  atlas_height : Int
  atlas_id : Int
  mut next_image_id : Int
  allocator : SimpleAtlasAllocator
  mut images : Array[SimpleAtlasImageEntry]
  mut page_generation : Int
  mut page_dirty_rect : SourceImageDirtyRect?
}

///|
fn atlas_region_to_dirty_rect(region : AtlasRegion) -> SourceImageDirtyRect {
  { x: region.x, y: region.y, width: region.width, height: region.height }
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
fn clamp_atlas_coord(value : Int, bound : Int) -> Int {
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
  atlas_width : Int,
  atlas_height : Int,
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
  atlas_width : Int,
  atlas_height : Int,
  atlas_id : Int,
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
}

///|
fn new_blank_rgba8_channels(width : Int, height : Int) -> Array[Int] {
  let safe_width = if width <= 0 { 1 } else { width }
  let safe_height = if height <= 0 { 1 } else { height }
  let out : Array[Int] = []
  for _ in 0..<(safe_width * safe_height * 4) {
    out.push(0)
  }
  out
}

///|
fn fill_atlas_page_pixels_from_entry(
  pixels_rgba8 : Array[Int],
  atlas_width : Int,
  atlas_height : Int,
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
  let fallback_r = @image_palette.palette_channel(entry.palette, 0, 0)
  let fallback_g = @image_palette.palette_channel(entry.palette, 0, 1)
  let fallback_b = @image_palette.palette_channel(entry.palette, 0, 2)
  let fallback_a = @image_palette.palette_channel(entry.palette, 0, 3)
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
fn compose_atlas_page_rgba8(repo : SimpleAtlasImageRepository) -> Array[Int] {
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
pub fn clear_dirty_atlas_page_flags(repo : SimpleAtlasImageRepository) -> Int {
  match repo.page_dirty_rect {
    Some(_) => {
      repo.page_dirty_rect = None
      1
    }
    None => 0
  }
}
