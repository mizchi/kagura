///|
/// WebGPU FFI layer - bypasses mizchi/js @webgpu bindings that lack JS return statements.
/// All functions use extern "js" arrow functions which have implicit returns.

// --- GPU Usage Constants ---
pub const TEXTURE_USAGE_COPY_DST : Int = 2

///|
pub const TEXTURE_USAGE_TEXTURE_BINDING : Int = 4

///|
pub const TEXTURE_USAGE_RENDER_ATTACHMENT : Int = 16

///|
pub const BUFFER_USAGE_COPY_DST : Int = 8

///|
pub const BUFFER_USAGE_INDEX : Int = 16

///|
pub const BUFFER_USAGE_VERTEX : Int = 32

///|
pub const BUFFER_USAGE_UNIFORM : Int = 64

// --- Device property access ---

///|
extern "js" fn ffi_queue(device : @core.Any) -> @core.Any =
  #| (d) => d.queue

// --- Device methods (return values) ---

///|
extern "js" fn ffi_create_texture(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createTexture(desc)

///|
extern "js" fn ffi_create_sampler(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createSampler(desc ?? {})

///|
extern "js" fn ffi_create_buffer(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createBuffer(desc)

///|
extern "js" fn ffi_create_shader_module(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createShaderModule(desc)

///|
extern "js" fn ffi_create_bind_group_layout(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createBindGroupLayout(desc)

///|
extern "js" fn ffi_create_pipeline_layout(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createPipelineLayout(desc)

///|
extern "js" fn ffi_create_render_pipeline(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createRenderPipeline(desc)

///|
extern "js" fn ffi_create_bind_group(
  device : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (d, desc) => d.createBindGroup(desc)

///|
extern "js" fn ffi_create_command_encoder(device : @core.Any) -> @core.Any =
  #| (d) => d.createCommandEncoder()

// --- Texture methods ---

///|
extern "js" fn ffi_create_view(texture : @core.Any) -> @core.Any =
  #| (t) => t.createView()

///|
extern "js" fn ffi_destroy(obj : @core.Any) -> Unit =
  #| (o) => { if (o && o.destroy) o.destroy(); }

// --- Command encoder methods ---

///|
extern "js" fn ffi_begin_render_pass(
  encoder : @core.Any,
  desc : @core.Any,
) -> @core.Any =
  #| (e, desc) => e.beginRenderPass(desc)

///|
extern "js" fn ffi_finish(encoder : @core.Any) -> @core.Any =
  #| (e) => e.finish()

// --- Pipeline methods ---

///|
extern "js" fn ffi_get_bind_group_layout(
  pipeline : @core.Any,
  index : Int,
) -> @core.Any =
  #| (p, i) => p.getBindGroupLayout(i)

// --- Queue convenience ---

///|
extern "js" fn ffi_submit_one(queue : @core.Any, cmd_buf : @core.Any) -> Unit =
  #| (q, b) => q.submit([b])

// --- GPUExtent3D creation (bypasses %identity tail-position bug) ---

///|
extern "js" fn make_extent3d(width : Int, height : Int) -> @core.Any =
  #| (w, h) => ({ width: w, height: h })
