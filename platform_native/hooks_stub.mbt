///|
pub fn install(_title : String) -> Unit {
  ()
}

///|
pub fn uninstall() -> Unit {
  ()
}

///|
pub fn is_ready() -> Bool {
  false
}

///|
pub fn shutdown() -> Unit {
  ()
}

///|
pub fn initialize_context(
  _width : Int32,
  _height : Int32,
  _title : String,
) -> Bool {
  false
}

///|
pub fn initialize_headless_context(_width : Int32, _height : Int32) -> Bool {
  false
}

///|
pub fn should_close() -> Bool {
  true
}

///|
pub fn poll_events() -> Unit {
  ()
}

///|
pub fn render_frame() -> Bool {
  false
}

///|
pub fn register_source_image_palette(
  _source_image_id : Int32,
  _palette : @atlas.ImagePalette2x2,
) -> Unit {
  ()
}

///|
pub fn register_source_image_solid_color(
  _source_image_id : Int32,
  _color : @atlas.Rgba,
) -> Unit {
  ()
}

///|
pub fn register_source_image_rgba8(
  _source_image_id : Int32,
  _width : Int32,
  _height : Int32,
  _rgba8_channels : Array[Int32],
) -> Unit {
  ()
}

///|
pub fn patch_source_image_rgba8(
  _source_image_id : Int32,
  _width : Int32,
  _height : Int32,
  _dirty_x : Int32,
  _dirty_y : Int32,
  _dirty_width : Int32,
  _dirty_height : Int32,
  _rgba8_channels : Array[Int32],
) -> Bool {
  false
}

///|
pub fn clear_source_image_palettes() -> Unit {
  ()
}

///|
pub fn sync_source_image_palettes(
  bindings : Array[@atlas.ImagePaletteBinding],
) -> Int32 {
  bindings.length()
}

///|
pub fn sync_source_image_palettes_from_repository(
  repository : @atlas.SimpleImageRepository,
) -> Int32 {
  @atlas.list_image_palette_bindings(repository).length()
}

///|
pub fn sync_source_images(bindings : Array[@atlas.SourceImageBinding]) -> Int32 {
  bindings.length()
}

///|
pub fn sync_source_images_from_repository(
  repository : @atlas.SimpleImageRepository,
) -> Int32 {
  @atlas.list_source_image_bindings(repository).length()
}

///|
pub fn sync_dirty_source_images_from_repository(
  repository : @atlas.SimpleImageRepository,
) -> Int32 {
  let count = @atlas.list_dirty_source_image_bindings(repository).length()
  let _ = @atlas.clear_source_image_dirty_flags(repository)
  count
}

///|
pub fn sync_dirty_atlas_pages_from_repository(
  repository : @atlas.SimpleAtlasImageRepository,
) -> Int32 {
  let count = @atlas.list_dirty_atlas_page_bindings(repository).length()
  let _ = @atlas.clear_dirty_atlas_page_flags(repository)
  count
}

///|
pub fn shutdown_context() -> Unit {
  ()
}

///|
fn init {
  @engine.set_lifecycle_hooks({
    on_start: fn(_canvas, _title) { () },
    on_stop: fn() { () },
  })
}
