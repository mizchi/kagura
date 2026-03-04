///|
/// Build a blend state JS object for the given blend mode
fn build_blend_state(blend_mode : Int) -> @core.Any? {
  if blend_mode == 0 {
    let blend = @core.new_object()
    let color = @core.new_object()
    color._set("srcFactor", @core.any("one"))
    color._set("dstFactor", @core.any("zero"))
    color._set("operation", @core.any("add"))
    let alpha = @core.new_object()
    alpha._set("srcFactor", @core.any("one"))
    alpha._set("dstFactor", @core.any("zero"))
    alpha._set("operation", @core.any("add"))
    blend._set("color", color)
    blend._set("alpha", alpha)
    Some(blend)
  } else if blend_mode == 1 {
    let blend = @core.new_object()
    let color = @core.new_object()
    color._set("srcFactor", @core.any("src-alpha"))
    color._set("dstFactor", @core.any("one-minus-src-alpha"))
    color._set("operation", @core.any("add"))
    let alpha = @core.new_object()
    alpha._set("srcFactor", @core.any("one"))
    alpha._set("dstFactor", @core.any("one-minus-src-alpha"))
    alpha._set("operation", @core.any("add"))
    blend._set("color", color)
    blend._set("alpha", alpha)
    Some(blend)
  } else if blend_mode == 2 {
    let blend = @core.new_object()
    let color = @core.new_object()
    color._set("srcFactor", @core.any("src-alpha"))
    color._set("dstFactor", @core.any("one"))
    color._set("operation", @core.any("add"))
    let alpha = @core.new_object()
    alpha._set("srcFactor", @core.any("one"))
    alpha._set("dstFactor", @core.any("one"))
    alpha._set("operation", @core.any("add"))
    blend._set("color", color)
    blend._set("alpha", alpha)
    Some(blend)
  } else {
    None
  }
}

///|
fn build_default_alpha_blend() -> @core.Any {
  let blend = @core.new_object()
  let color = @core.new_object()
  color._set("srcFactor", @core.any("src-alpha"))
  color._set("dstFactor", @core.any("one-minus-src-alpha"))
  color._set("operation", @core.any("add"))
  let alpha = @core.new_object()
  alpha._set("srcFactor", @core.any("one"))
  alpha._set("dstFactor", @core.any("one-minus-src-alpha"))
  alpha._set("operation", @core.any("add"))
  blend._set("color", color)
  blend._set("alpha", alpha)
  blend
}

///|
fn build_fragment_target(format : String, blend : @core.Any?) -> @core.Any {
  let target = @core.new_object()
  target._set("format", @core.any(format))
  match blend {
    Some(b) => target._set("blend", b)
    None => ()
  }
  target
}

///|
fn build_2d_vertex_layout() -> @core.Any {
  let layout = @core.new_object()
  layout._set("arrayStride", @core.any(16))
  let attr0 = @core.new_object()
  attr0._set("shaderLocation", @core.any(0))
  attr0._set("offset", @core.any(0))
  attr0._set("format", @core.any("float32x2"))
  let attr1 = @core.new_object()
  attr1._set("shaderLocation", @core.any(1))
  attr1._set("offset", @core.any(8))
  attr1._set("format", @core.any("float32x2"))
  let attrs = @core.new_array()
  attrs._call("push", [attr0]) |> ignore
  attrs._call("push", [attr1]) |> ignore
  layout._set("attributes", attrs)
  layout
}

///|
fn build_3d_vertex_layout() -> @core.Any {
  let layout = @core.new_object()
  layout._set("arrayStride", @core.any(32))
  let attr0 = @core.new_object()
  attr0._set("shaderLocation", @core.any(0))
  attr0._set("offset", @core.any(0))
  attr0._set("format", @core.any("float32x3"))
  let attr1 = @core.new_object()
  attr1._set("shaderLocation", @core.any(1))
  attr1._set("offset", @core.any(12))
  attr1._set("format", @core.any("float32x3"))
  let attr2 = @core.new_object()
  attr2._set("shaderLocation", @core.any(2))
  attr2._set("offset", @core.any(24))
  attr2._set("format", @core.any("float32x2"))
  let attrs = @core.new_array()
  attrs._call("push", [attr0]) |> ignore
  attrs._call("push", [attr1]) |> ignore
  attrs._call("push", [attr2]) |> ignore
  layout._set("attributes", attrs)
  layout
}

///|
/// Ensure the default GPU pipeline is created. Returns true if ready.
pub fn ensure_gpu_pipeline(
  state : GpuState,
  device : @core.Any,
  format : String,
) -> Bool {
  match state.pipeline {
    Some(_) => if state.pipeline_format == format { return true }
    None => ()
  }
  // Create shader module
  let sm_desc = @core.new_object()
  sm_desc._set("code", @core.any(default_shader_code))
  let shader_module = ffi_create_shader_module(device, sm_desc)
  // Texture bind group layout
  let tex_entry0 = @core.new_object()
  tex_entry0._set("binding", @core.any(0))
  tex_entry0._set("visibility", @core.any(SHADER_STAGE_FRAGMENT))
  let tex_desc0 = @core.new_object()
  tex_desc0._set("sampleType", @core.any("float"))
  tex_entry0._set("texture", tex_desc0)
  let tex_entry1 = @core.new_object()
  tex_entry1._set("binding", @core.any(1))
  tex_entry1._set("visibility", @core.any(SHADER_STAGE_FRAGMENT))
  tex_entry1._set("sampler", @core.new_object())
  let tex_entries = @core.new_array()
  tex_entries._call("push", [tex_entry0]) |> ignore
  tex_entries._call("push", [tex_entry1]) |> ignore
  let bgl_desc = @core.new_object()
  bgl_desc._set("entries", tex_entries)
  let tex_bgl = ffi_create_bind_group_layout(device, bgl_desc)
  // Uniform bind group layout
  let uni_entry = @core.new_object()
  uni_entry._set("binding", @core.any(0))
  uni_entry._set(
    "visibility",
    @core.any(SHADER_STAGE_FRAGMENT | SHADER_STAGE_VERTEX),
  )
  let buf_desc = @core.new_object()
  buf_desc._set("type", @core.any("uniform"))
  uni_entry._set("buffer", buf_desc)
  let uni_entries = @core.new_array()
  uni_entries._call("push", [uni_entry]) |> ignore
  let ubgl_desc = @core.new_object()
  ubgl_desc._set("entries", uni_entries)
  let uniform_bgl = ffi_create_bind_group_layout(device, ubgl_desc)
  // Pipeline layout
  let bgl_array = @core.new_array()
  bgl_array._call("push", [uniform_bgl]) |> ignore
  bgl_array._call("push", [tex_bgl]) |> ignore
  let pl_desc = @core.new_object()
  pl_desc._set("bindGroupLayouts", bgl_array)
  let pipeline_layout = ffi_create_pipeline_layout(device, pl_desc)
  // Vertex layout (2D)
  let vertex_layout = build_2d_vertex_layout()
  let buffers = @core.new_array()
  buffers._call("push", [vertex_layout]) |> ignore
  // Build pipeline descriptor
  let vertex_desc = @core.new_object()
  vertex_desc._set("module", shader_module)
  vertex_desc._set("entryPoint", @core.any("vs_main"))
  vertex_desc._set("buffers", buffers)
  let frag_target = build_fragment_target(
    format,
    Some(build_default_alpha_blend()),
  )
  let frag_targets = @core.new_array()
  frag_targets._call("push", [frag_target]) |> ignore
  let frag_desc = @core.new_object()
  frag_desc._set("module", shader_module)
  frag_desc._set("entryPoint", @core.any("fs_main"))
  frag_desc._set("targets", frag_targets)
  let primitive = @core.new_object()
  primitive._set("topology", @core.any("triangle-list"))
  primitive._set("cullMode", @core.any("none"))
  let pipeline_desc = @core.new_object()
  pipeline_desc._set("layout", pipeline_layout)
  pipeline_desc._set("vertex", vertex_desc)
  pipeline_desc._set("fragment", frag_desc)
  pipeline_desc._set("primitive", primitive)
  let pipeline = ffi_create_render_pipeline(device, pipeline_desc)
  // Offscreen pipeline (rgba8unorm) if format differs
  let offscreen_pipeline = if format != "rgba8unorm" {
    let off_frag_target = build_fragment_target(
      "rgba8unorm",
      Some(build_default_alpha_blend()),
    )
    let off_targets = @core.new_array()
    off_targets._call("push", [off_frag_target]) |> ignore
    let off_frag = @core.new_object()
    off_frag._set("module", shader_module)
    off_frag._set("entryPoint", @core.any("fs_main"))
    off_frag._set("targets", off_targets)
    let off_desc = @core.new_object()
    off_desc._set("layout", pipeline_layout)
    off_desc._set("vertex", vertex_desc)
    off_desc._set("fragment", off_frag)
    off_desc._set("primitive", primitive)
    ffi_create_render_pipeline(device, off_desc)
  } else {
    pipeline
  }
  // Default 1x1 white texture
  let dtex_desc = @core.new_object()
  dtex_desc._set("size", make_extent3d(1, 1))
  dtex_desc._set("format", @core.any("rgba8unorm"))
  dtex_desc._set(
    "usage",
    @core.any(TEXTURE_USAGE_TEXTURE_BINDING | TEXTURE_USAGE_COPY_DST),
  )
  let default_tex = ffi_create_texture(device, dtex_desc)
  // Write white pixel
  let white_pixel = @core.new(@core.global_this()._get("Uint8Array"), [
    @core.any([255, 255, 255, 255]),
  ])
  let tex_dest = @core.new_object()
  tex_dest._set("texture", default_tex)
  let data_layout = @core.new_object()
  data_layout._set("bytesPerRow", @core.any(4))
  let queue = ffi_queue(device)
  queue._call("writeTexture", [
    tex_dest,
    white_pixel,
    data_layout,
    make_extent3d(1, 1),
  ])
  |> ignore
  // Samplers
  let ns_desc = @core.new_object()
  ns_desc._set("magFilter", @core.any("nearest"))
  ns_desc._set("minFilter", @core.any("nearest"))
  let default_sampler = ffi_create_sampler(device, ns_desc)
  let ls_desc = @core.new_object()
  ls_desc._set("magFilter", @core.any("linear"))
  ls_desc._set("minFilter", @core.any("linear"))
  ls_desc._set("addressModeU", @core.any("clamp-to-edge"))
  ls_desc._set("addressModeV", @core.any("clamp-to-edge"))
  let linear_sampler = ffi_create_sampler(device, ls_desc)
  // Store state
  state.pipeline = Some(pipeline)
  state.pipeline_format = format
  state.pipeline_offscreen = Some(offscreen_pipeline)
  state.uniform_bgl = Some(uniform_bgl)
  state.tex_bgl = Some(tex_bgl)
  state.default_texture = Some(default_tex)
  state.default_tex_view = Some(ffi_create_view(default_tex))
  state.default_sampler = Some(default_sampler)
  state.linear_sampler = Some(linear_sampler)
  state.draw_cache = None
  true
}

///|
/// Get or create a custom pipeline for the given shader/blend mode combo
pub fn get_or_create_custom_pipeline(
  state : GpuState,
  device : @core.Any,
  shader_id : Int,
  shader_source : String,
  blend_mode : Int,
  format : String,
) -> CustomPipelineEntry {
  let key = "\{shader_id}_\{format}_\{blend_mode}"
  match state.custom_pipelines.get(key) {
    Some(entry) => return entry
    None => ()
  }
  let sm_desc = @core.new_object()
  sm_desc._set("code", @core.any(shader_source))
  let shader_module = ffi_create_shader_module(device, sm_desc)
  let stride32 = is_stride32(shader_source)
  let vertex_layout = if stride32 {
    build_3d_vertex_layout()
  } else {
    build_2d_vertex_layout()
  }
  let buffers = @core.new_array()
  buffers._call("push", [vertex_layout]) |> ignore
  let vertex_desc = @core.new_object()
  vertex_desc._set("module", shader_module)
  vertex_desc._set("entryPoint", @core.any("vs_main"))
  vertex_desc._set("buffers", buffers)
  let blend = build_blend_state(blend_mode)
  let frag_target = build_fragment_target(format, blend)
  let frag_targets = @core.new_array()
  frag_targets._call("push", [frag_target]) |> ignore
  let frag_desc = @core.new_object()
  frag_desc._set("module", shader_module)
  frag_desc._set("entryPoint", @core.any("fs_main"))
  frag_desc._set("targets", frag_targets)
  let primitive = @core.new_object()
  primitive._set("topology", @core.any("triangle-list"))
  primitive._set("cullMode", @core.any(if stride32 { "back" } else { "none" }))
  let pipeline_desc = @core.new_object()
  pipeline_desc._set("layout", @core.any("auto"))
  pipeline_desc._set("vertex", vertex_desc)
  pipeline_desc._set("fragment", frag_desc)
  pipeline_desc._set("primitive", primitive)
  if stride32 {
    let depth_stencil = @core.new_object()
    depth_stencil._set("format", @core.any("depth24plus"))
    depth_stencil._set("depthWriteEnabled", @core.any(true))
    depth_stencil._set("depthCompare", @core.any("less"))
    pipeline_desc._set("depthStencil", depth_stencil)
  }
  let pipeline = ffi_create_render_pipeline(device, pipeline_desc)
  let bgl = ffi_get_bind_group_layout(pipeline, 0)
  let entry : CustomPipelineEntry = {
    pipeline,
    bind_group_layout: bgl,
    stride32,
  }
  state.custom_pipelines.set(key, entry)
  entry
}
