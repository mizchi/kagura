///|
/// GPU shader stage constants
pub const SHADER_STAGE_VERTEX : Int = 1

///|
pub const SHADER_STAGE_FRAGMENT : Int = 2

///|
pub const SHADER_STAGE_COMPUTE : Int = 4

///|
/// Default 2D shader WGSL source
let default_shader_code : String = "struct Uniforms { color: vec4f }\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(1) @binding(0) var tex: texture_2d<f32>;\n@group(1) @binding(1) var tex_sampler: sampler;\nstruct VertexOutput {\n  @builtin(position) position: vec4f,\n  @location(0) uv: vec2f,\n}\n@vertex fn vs_main(@location(0) pos: vec2f, @location(1) uv: vec2f) -> VertexOutput {\n  var out: VertexOutput;\n  out.position = vec4f(pos, 0.0, 1.0);\n  out.uv = uv;\n  return out;\n}\n@fragment fn fs_main(input: VertexOutput) -> @location(0) vec4f {\n  let tex_color = textureSample(tex, tex_sampler, input.uv);\n  return tex_color * uniforms.color;\n}"

///|
/// Texture entry in the texture registry
pub(all) struct TextureEntry {
  texture : @core.Any
  view : @core.Any
  sampler : @core.Any
  width : Int
  height : Int
  mut revision : Int
}

///|
/// Buffer entry for resource caching
pub(all) struct BufferEntry {
  mut size : Int
  mut buffer : @core.Any
}

///|
/// Draw resource cache for default pipeline commands
pub(all) struct DrawResourceCache {
  vertex_buffers : Array[BufferEntry?]
  index_buffers : Array[BufferEntry?]
  uniform_buffers : Array[BufferEntry?]
  uniform_bind_groups : Array[@core.Any?]
  uniform_bind_buffers : Array[@core.Any?]
  texture_bind_groups : Array[@core.Any?]
  texture_bind_image_ids : Array[Int]
  texture_bind_revisions : Array[Int]
}

///|
/// Create a new empty DrawResourceCache
pub fn DrawResourceCache::new() -> DrawResourceCache {
  {
    vertex_buffers: [],
    index_buffers: [],
    uniform_buffers: [],
    uniform_bind_groups: [],
    uniform_bind_buffers: [],
    texture_bind_groups: [],
    texture_bind_image_ids: [],
    texture_bind_revisions: [],
  }
}

///|
/// Cached custom pipeline entry
pub(all) struct CustomPipelineEntry {
  pipeline : @core.Any
  bind_group_layout : @core.Any
  stride32 : Bool
}

///|
/// Render target entry
pub(all) struct RenderTargetEntry {
  texture : @core.Any
  view : @core.Any
  width : Int
  height : Int
}

///|
/// Depth texture entry
pub(all) struct DepthTextureEntry {
  texture : @core.Any
  view : @core.Any
  width : Int
  height : Int
}

///|
/// Main GPU state structure, holds all pipeline and resource state
pub(all) struct GpuState {
  // Pipeline
  mut pipeline : @core.Any?
  mut pipeline_format : String
  mut pipeline_offscreen : @core.Any?
  mut uniform_bgl : @core.Any?
  mut tex_bgl : @core.Any?
  // Default resources
  mut default_texture : @core.Any?
  mut default_tex_view : @core.Any?
  mut default_sampler : @core.Any?
  mut linear_sampler : @core.Any?
  // Caches
  mut draw_cache : DrawResourceCache?
  mut custom_pipelines : Map[String, CustomPipelineEntry]
  mut render_targets : Map[Int, RenderTargetEntry]
  mut depth_textures : Map[String, DepthTextureEntry]
  // Texture registry (imageId -> TextureEntry)
  mut textures : Map[Int, TextureEntry]
  // Pending
  mut pending_buffer_cleanup : Array[@core.Any]
  mut screen_target_id : Int
}

///|
/// Create a new GpuState with default values
pub fn GpuState::new() -> GpuState {
  {
    pipeline: None,
    pipeline_format: "",
    pipeline_offscreen: None,
    uniform_bgl: None,
    tex_bgl: None,
    default_texture: None,
    default_tex_view: None,
    default_sampler: None,
    linear_sampler: None,
    draw_cache: None,
    custom_pipelines: Map([]),
    render_targets: Map([]),
    depth_textures: Map([]),
    textures: Map([]),
    pending_buffer_cleanup: [],
    screen_target_id: 0,
  }
}

///|
/// Global GpuState singleton
let global_gpu_state : Ref[GpuState?] = Ref(None)

///|
/// Get or create global GpuState
pub fn get_gpu_state() -> GpuState {
  match global_gpu_state.val {
    Some(s) => s
    None => {
      let s = GpuState::new()
      global_gpu_state.val = Some(s)
      s
    }
  }
}

///|
/// Reset global GpuState
pub fn reset_gpu_state() -> Unit {
  global_gpu_state.val = None
}
