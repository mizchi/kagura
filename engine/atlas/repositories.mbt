///|
#derive(Debug)
struct SimpleImageEntry {
  key : AssetKey
  handle : @gfx.ImageHandle
  palette : ImagePalette2x2
  pixels_rgba8 : Array[Int32]
  generation : Int32
  dirty_rect : SourceImageDirtyRect?
}

///|
pub impl Show for SimpleImageEntry with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
struct SimpleShaderEntry {
  key : AssetKey
  handle : @gfx.ShaderHandle
}

///|
pub impl Show for SimpleShaderEntry with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
struct SimpleMaterialEntry {
  key : AssetKey
  spec : MaterialSpec
}

///|
pub impl Show for SimpleMaterialEntry with fn output(self, logger) {
  logger.write_object(Repr(self))
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
  image_id : Int32,
) -> ImagePalette2x2? {
  let mut out : ImagePalette2x2? = None
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
  image_id : Int32,
) -> Array[Int32]? {
  let mut out : Array[Int32]? = None
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
  image_id : Int32,
) -> Int32? {
  let mut out : Int32? = None
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
  { next_image_id: 1, images: [], }
}

///|
pub fn get_image_palette_by_id(
  repo : SimpleImageRepository,
  image_id : Int32,
) -> ImagePalette2x2? {
  find_image_palette_by_id(repo.images, image_id)
}

///|
pub fn list_image_palette_bindings(
  repo : SimpleImageRepository,
) -> Array[ImagePaletteBinding] {
  let bindings : Array[ImagePaletteBinding] = []
  for entry in repo.images {
    bindings.push({ image_id: entry.handle.id, palette: entry.palette, })
  }
  bindings
}

///|
pub fn get_image_pixels_by_id(
  repo : SimpleImageRepository,
  image_id : Int32,
) -> Array[Int32]? {
  find_image_pixels_by_id(repo.images, image_id)
}

///|
pub fn get_image_generation_by_id(
  repo : SimpleImageRepository,
  image_id : Int32,
) -> Int32 {
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
pub fn clear_source_image_dirty_flags(repo : SimpleImageRepository) -> Int32 {
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
fn next_image_generation(current : Int32) -> Int32 {
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
  { next_shader_id: 1, shaders: [], }
}

///|
pub fn new_simple_material_repository() -> SimpleMaterialRepository {
  { materials: [], }
}

///|
pub impl ImageRepository for SimpleImageRepository with fn create_image(
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
pub impl ImageRepository for SimpleImageRepository with fn get_image(self, key) {
  find_image_handle(self.images, key)
}

///|
pub impl ImageRepository for SimpleImageRepository with fn remove_image(
  self,
  key,
) {
  let next : Array[SimpleImageEntry] = []
  for entry in self.images {
    if !asset_key_eq(entry.key, key) {
      next.push(entry)
    }
  }
  self.images = next
}

///|
pub impl ShaderRepository for SimpleShaderRepository with fn create_shader(
  self,
  key,
  spec,
) {
  match find_shader_handle(self.shaders, key) {
    Some(handle) => handle
    None => {
      let handle = @gfx.new_shader_handle(self.next_shader_id, spec.source)
      self.next_shader_id = self.next_shader_id + 1
      self.shaders.push({ key, handle, })
      handle
    }
  }
}

///|
pub impl ShaderRepository for SimpleShaderRepository with fn get_shader(
  self,
  key,
) {
  find_shader_handle(self.shaders, key)
}

///|
pub impl ShaderRepository for SimpleShaderRepository with fn remove_shader(
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
pub impl MaterialRepository for SimpleMaterialRepository with fn register_material(
  self,
  key,
  spec,
) {
  let next : Array[SimpleMaterialEntry] = []
  let mut replaced = false
  for entry in self.materials {
    if asset_key_eq(entry.key, key) {
      next.push({ key, spec, })
      replaced = true
    } else {
      next.push(entry)
    }
  }
  if !replaced {
    next.push({ key, spec, })
  }
  self.materials = next
}

///|
pub impl MaterialRepository for SimpleMaterialRepository with fn get_material(
  self,
  key,
) {
  find_material_spec(self.materials, key)
}

///|
pub extend SimpleImageEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SimpleImageEntry with Show::{to_string, output}

///|
pub extend SimpleShaderEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SimpleShaderEntry with Show::{to_string, output}

///|
pub extend SimpleMaterialEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SimpleMaterialEntry with Show::{to_string, output}
