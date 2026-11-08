///|
/// Asset contracts (image/shader/material/atlas).
///
/// Ebiten refs:
/// - internal/atlas/image.go
/// - internal/atlas/shader.go

///|
#derive(Debug)
pub struct AssetKey {
  value : String
}

///|
pub impl Show for AssetKey with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn new_asset_key(value : String) -> AssetKey {
  { value, }
}

///|
#derive(Debug)
pub struct ImageSpec {
  width : Int32
  height : Int32
  format : String
  palette : ImagePalette2x2
  pixels_rgba8 : Array[Int32]
}

///|
pub impl Show for ImageSpec with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct ShaderSpec {
  debug_name : String
  source : String
}

///|
pub impl Show for ShaderSpec with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct MaterialSpec {
  shader : AssetKey
  blend : @gfx.BlendMode
  filter : @gfx.FilterMode
  uniform_keys : Array[String]
}

///|
pub impl Show for MaterialSpec with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct AtlasRegion {
  x : Int32
  y : Int32
  width : Int32
  height : Int32
  atlas_id : Int32
}

///|
pub impl Show for AtlasRegion with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn new_atlas_region(
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
  atlas_id : Int32,
) -> AtlasRegion {
  { x, y, width, height, atlas_id, }
}

///|
#derive(Debug)
pub struct ImagePaletteBinding {
  image_id : Int32
  palette : ImagePalette2x2
}

///|
pub impl Show for ImagePaletteBinding with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct SourceImageDirtyRect {
  x : Int32
  y : Int32
  width : Int32
  height : Int32
}

///|
pub impl Show for SourceImageDirtyRect with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct SourceImageBinding {
  image_id : Int32
  width : Int32
  height : Int32
  generation : Int32
  dirty_rect : SourceImageDirtyRect?
  palette : ImagePalette2x2
  pixels_rgba8 : Array[Int32]
}

///|
pub impl Show for SourceImageBinding with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct AtlasDrawSource {
  page_image_id : Int32
  region : AtlasRegion
  u0 : Double
  v0 : Double
  u1 : Double
  v1 : Double
}

///|
pub impl Show for AtlasDrawSource with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn new_source_image_binding(
  image_id : Int32,
  width : Int32,
  height : Int32,
  generation : Int32,
  dirty_rect : SourceImageDirtyRect?,
  palette : ImagePalette2x2,
  pixels_rgba8 : Array[Int32],
) -> SourceImageBinding {
  { image_id, width, height, generation, dirty_rect, palette, pixels_rgba8, }
}

///|
pub fn new_source_image_dirty_rect(
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> SourceImageDirtyRect {
  { x, y, width, height, }
}

///|
pub fn new_unmanaged_atlas_draw_source(image_id : Int32) -> AtlasDrawSource {
  let safe_image_id = if image_id < 0 { 0 } else { image_id }
  {
    page_image_id: safe_image_id,
    region: { x: 0, y: 0, width: 1, height: 1, atlas_id: safe_image_id, },
    u0: 0.0,
    v0: 0.0,
    u1: 1.0,
    v1: 1.0,
  }
}

///|
pub trait ImageRepository {
  fn create_image(Self, key : AssetKey, spec : ImageSpec) -> @gfx.ImageHandle raise
  fn get_image(Self, key : AssetKey) -> @gfx.ImageHandle?
  fn remove_image(Self, key : AssetKey) -> Unit raise
}

///|
pub trait ShaderRepository {
  fn create_shader(Self, key : AssetKey, spec : ShaderSpec) -> @gfx.ShaderHandle raise
  fn get_shader(Self, key : AssetKey) -> @gfx.ShaderHandle?
  fn remove_shader(Self, key : AssetKey) -> Unit raise
}

///|
pub trait MaterialRepository {
  fn register_material(Self, key : AssetKey, spec : MaterialSpec) -> Unit raise
  fn get_material(Self, key : AssetKey) -> MaterialSpec?
}

///|
pub trait AtlasAllocator {
  fn allocate(Self, width : Int32, height : Int32) -> AtlasRegion?
  fn release(Self, region : AtlasRegion) -> Unit
}

///|
pub struct SimpleImageRepository {
  mut next_image_id : Int32
  mut images : Array[SimpleImageEntry]
}

///|
pub struct SimpleShaderRepository {
  mut next_shader_id : Int32
  mut shaders : Array[SimpleShaderEntry]
}

///|
pub struct SimpleMaterialRepository {
  mut materials : Array[SimpleMaterialEntry]
}

///|
pub struct SimpleAtlasAllocator {
  atlas_width : Int32
  atlas_height : Int32
  atlas_id : Int32
  mut cursor_x : Int32
  mut cursor_y : Int32
  mut row_height : Int32
  mut allocated : Array[AtlasRegion]
}

///|
///
/// Atlas image repository with page-level dirty tracking.
///
/// Ebiten refs:
/// - internal/atlas/image.go
/// - internal/atlas/image.go (writePixels / region updates)
pub struct SimpleAtlasImageRepository {
  atlas_width : Int32
  atlas_height : Int32
  atlas_id : Int32
  mut next_image_id : Int32
  allocator : SimpleAtlasAllocator
  mut images : Array[SimpleAtlasImageEntry]
  mut page_generation : Int32
  mut page_dirty_rect : SourceImageDirtyRect?
}

///|
/// Multi-page atlas repository that auto-creates new pages when
/// the current page runs out of space.
///
/// Ebiten refs:
/// - internal/atlas/image.go (multi-backend page management)
pub struct MultiPageAtlasRepository {
  page_width : Int32
  page_height : Int32
  mut next_page_id : Int32
  pages : Array[SimpleAtlasImageRepository]
  mut key_page_index : Array[(String, Int32)]
}

///|
#derive(Debug)
pub struct AtlasCompactResult {
  removed_page_ids : Array[Int32]
  removed_page_count : Int32
  remaining_page_count : Int32
}

///|
pub impl Show for AtlasCompactResult with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub struct AtlasPageStats {
  atlas_id : Int32
  image_count : Int32
  allocated_region_count : Int32
  atlas_width : Int32
  atlas_height : Int32
  is_empty : Bool
}

///|
pub impl Show for AtlasPageStats with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub extend AssetKey with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AssetKey with Show::{to_string, output}

///|
pub extend ImageSpec with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ImageSpec with Show::{to_string, output}

///|
pub extend ShaderSpec with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ShaderSpec with Show::{to_string, output}

///|
pub extend MaterialSpec with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MaterialSpec with Show::{to_string, output}

///|
pub extend AtlasRegion with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AtlasRegion with Show::{to_string, output}

///|
pub extend ImagePaletteBinding with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ImagePaletteBinding with Show::{to_string, output}

///|
pub extend SourceImageDirtyRect with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SourceImageDirtyRect with Show::{to_string, output}

///|
pub extend SourceImageBinding with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SourceImageBinding with Show::{to_string, output}

///|
pub extend AtlasDrawSource with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AtlasDrawSource with Show::{to_string, output}

///|
pub extend SimpleImageRepository with ImageRepository::{
  create_image,
  get_image,
  remove_image,
}

///|
pub extend SimpleShaderRepository with ShaderRepository::{
  get_shader,
  remove_shader,
  create_shader,
}

///|
pub extend SimpleMaterialRepository with MaterialRepository::{
  register_material,
  get_material,
}

///|
pub extend SimpleAtlasAllocator with AtlasAllocator::{allocate, release}

///|
pub extend AtlasCompactResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AtlasCompactResult with Show::{to_string, output}

///|
pub extend AtlasPageStats with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AtlasPageStats with Show::{to_string, output}
