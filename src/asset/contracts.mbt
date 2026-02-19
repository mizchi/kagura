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
pub struct ImageSpec {
  width : Int
  height : Int
  format : String
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
  { width, height, format: "rgba8unorm" }
}
