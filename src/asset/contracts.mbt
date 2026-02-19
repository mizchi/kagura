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

///|
struct SimpleImageEntry {
  key : AssetKey
  handle : @gfx.ImageHandle
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
      let handle = @gfx.new_image_handle(self.next_image_id, width, height)
      self.next_image_id = self.next_image_id + 1
      self.images.push({ key, handle })
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
