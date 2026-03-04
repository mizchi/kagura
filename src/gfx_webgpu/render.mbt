///|
/// Ensure a buffer slot has sufficient capacity, creating a new buffer if needed.
fn ensure_buffer_entry(
  slots : Array[BufferEntry?],
  slot_index : Int,
  min_size : Int,
  usage : Int,
  device : @core.Any,
) -> BufferEntry {
  let required_size = if min_size < 16 { 16 } else { min_size }
  while slots.length() <= slot_index {
    slots.push(None)
  }
  match slots[slot_index] {
    Some(entry) =>
      if entry.size >= required_size {
        return entry
      } else {
        ffi_destroy(entry.buffer)
      }
    None => ()
  }
  let buf_desc = @core.new_object()
  buf_desc._set("size", @core.any(required_size))
  buf_desc._set("usage", @core.any(usage))
  let buffer = ffi_create_buffer(device, buf_desc)
  let entry : BufferEntry = { size: required_size, buffer }
  slots[slot_index] = Some(entry)
  entry
}

///|
/// Draw a default (2D) command using the default pipeline
pub fn draw_default_command(
  state : GpuState,
  device : @core.Any,
  pass : @core.Any,
  cmd : @core.Any,
  draw_index : Int,
  cache : DrawResourceCache,
  pass_format : String,
) -> Unit {
  let vertex_data = cmd._get("vertexData")
  if @core.is_nullish(vertex_data) {
    return
  }
  let vd_length = vertex_data._get("length").cast_int()
  if vd_length == 0 {
    return
  }
  let indices = cmd._get("indices")
  if @core.is_nullish(indices) {
    return
  }
  let idx_length = indices._get("length").cast_int()
  if idx_length == 0 {
    return
  }
  let queue = ffi_queue(device)
  // Vertex buffer
  let vb_byte_length = vertex_data._get("byteLength").cast_int()
  let vb_entry = ensure_buffer_entry(
    cache.vertex_buffers,
    draw_index,
    vb_byte_length,
    BUFFER_USAGE_VERTEX | BUFFER_USAGE_COPY_DST,
    device,
  )
  queue._call("writeBuffer", [vb_entry.buffer, @core.any(0), vertex_data])
  |> ignore
  // Index buffer
  let ib_byte_length = indices._get("byteLength").cast_int()
  let ib_entry = ensure_buffer_entry(
    cache.index_buffers,
    draw_index,
    ib_byte_length,
    BUFFER_USAGE_INDEX | BUFFER_USAGE_COPY_DST,
    device,
  )
  queue._call("writeBuffer", [ib_entry.buffer, @core.any(0), indices]) |> ignore
  // Uniform buffer (RGBA color)
  let ub_entry = ensure_buffer_entry(
    cache.uniform_buffers,
    draw_index,
    16,
    BUFFER_USAGE_UNIFORM | BUFFER_USAGE_COPY_DST,
    device,
  )
  let uniform_r = cmd._get("uniformR")
  let uniform_g = cmd._get("uniformG")
  let uniform_b = cmd._get("uniformB")
  let uniform_a = cmd._get("uniformA")
  let uniform_data = @core.new(@core.global_this()._get("Float32Array"), [
    @core.any([uniform_r, uniform_g, uniform_b, uniform_a]),
  ])
  queue._call("writeBuffer", [ub_entry.buffer, @core.any(0), uniform_data])
  |> ignore
  // Uniform bind group
  while cache.uniform_bind_groups.length() <= draw_index {
    cache.uniform_bind_groups.push(None)
    cache.uniform_bind_buffers.push(None)
  }
  let need_uniform_bg = match cache.uniform_bind_groups[draw_index] {
    None => true
    Some(_) =>
      match cache.uniform_bind_buffers[draw_index] {
        None => true
        Some(buf) => {
          let same = @core.equal(buf, ub_entry.buffer)
          not(same)
        }
      }
  }
  if need_uniform_bg {
    let bg_entry = @core.new_object()
    bg_entry._set("binding", @core.any(0))
    let resource = @core.new_object()
    resource._set("buffer", ub_entry.buffer)
    bg_entry._set("resource", resource)
    let entries = @core.new_array()
    entries._call("push", [bg_entry]) |> ignore
    let bg_desc = @core.new_object()
    bg_desc._set("layout", state.uniform_bgl.unwrap())
    bg_desc._set("entries", entries)
    let uniform_bg = ffi_create_bind_group(device, bg_desc)
    cache.uniform_bind_groups[draw_index] = Some(uniform_bg)
    cache.uniform_bind_buffers[draw_index] = Some(ub_entry.buffer)
  }
  // Texture bind group
  let mut tex_view = state.default_tex_view.unwrap()
  let mut tex_sampler = state.default_sampler.unwrap()
  let mut resolved_image_id = 0
  let mut resolved_revision = -1
  let src_image_id = cmd._get("srcImageId")
  if not(@core.is_nullish(src_image_id)) {
    let img_id = src_image_id.cast_int()
    if img_id > 0 {
      match state.textures.get(img_id) {
        Some(tex_entry) => {
          tex_view = tex_entry.view
          tex_sampler = tex_entry.sampler
          resolved_image_id = img_id
          resolved_revision = tex_entry.revision
        }
        None => ()
      }
    }
  }
  while cache.texture_bind_groups.length() <= draw_index {
    cache.texture_bind_groups.push(None)
    cache.texture_bind_image_ids.push(0)
    cache.texture_bind_revisions.push(0)
  }
  let need_tex_bg = match cache.texture_bind_groups[draw_index] {
    None => true
    Some(_) =>
      cache.texture_bind_image_ids[draw_index] != resolved_image_id ||
      cache.texture_bind_revisions[draw_index] != resolved_revision
  }
  if need_tex_bg {
    let entry0 = @core.new_object()
    entry0._set("binding", @core.any(0))
    entry0._set("resource", tex_view)
    let entry1 = @core.new_object()
    entry1._set("binding", @core.any(1))
    entry1._set("resource", tex_sampler)
    let entries = @core.new_array()
    entries._call("push", [entry0]) |> ignore
    entries._call("push", [entry1]) |> ignore
    let bg_desc = @core.new_object()
    bg_desc._set("layout", state.tex_bgl.unwrap())
    bg_desc._set("entries", entries)
    let tex_bg = ffi_create_bind_group(device, bg_desc)
    cache.texture_bind_groups[draw_index] = Some(tex_bg)
    cache.texture_bind_image_ids[draw_index] = resolved_image_id
    cache.texture_bind_revisions[draw_index] = resolved_revision
  }
  // Select pipeline
  let selected_pipeline = if pass_format != state.pipeline_format {
    match state.pipeline_offscreen {
      Some(p) => p
      None => state.pipeline.unwrap()
    }
  } else {
    state.pipeline.unwrap()
  }
  pass._call("setPipeline", [selected_pipeline]) |> ignore
  pass._call("setBindGroup", [
    @core.any(0),
    cache.uniform_bind_groups[draw_index].unwrap(),
  ])
  |> ignore
  pass._call("setBindGroup", [
    @core.any(1),
    cache.texture_bind_groups[draw_index].unwrap(),
  ])
  |> ignore
  pass._call("setVertexBuffer", [@core.any(0), vb_entry.buffer]) |> ignore
  pass._call("setIndexBuffer", [ib_entry.buffer, @core.any("uint32")]) |> ignore
  let instance_count = cmd._get("instanceCount")
  let ic = if @core.is_nullish(instance_count) { 1 } else { instance_count.cast_int() }
  if ic > 1 {
    pass._call("drawIndexed", [@core.any(idx_length), @core.any(ic)]) |> ignore
  } else {
    pass._call("drawIndexed", [@core.any(idx_length)]) |> ignore
  }
}

///|
/// Draw a custom shader command
pub fn draw_custom_command(
  state : GpuState,
  device : @core.Any,
  pass : @core.Any,
  cmd : @core.Any,
  format : String,
) -> Unit {
  let vertex_data = cmd._get("vertexData")
  if @core.is_nullish(vertex_data) {
    return
  }
  let vd_length = vertex_data._get("length").cast_int()
  if vd_length == 0 {
    return
  }
  let indices = cmd._get("indices")
  if @core.is_nullish(indices) {
    return
  }
  let idx_length = indices._get("length").cast_int()
  if idx_length == 0 {
    return
  }
  let shader_id = cmd._get("shaderId").cast_int()
  let shader_source = cmd._get("shaderSource").cast_string()
  let blend_mode = cmd._get("blendMode").cast_int()
  let pipeline_info = get_or_create_custom_pipeline(
    state, device, shader_id, shader_source, blend_mode, format,
  )
  let queue = ffi_queue(device)
  // Vertex buffer (temporary)
  let vb_byte_length = vertex_data._get("byteLength").cast_int()
  let vb_size = if vb_byte_length < 16 { 16 } else { vb_byte_length }
  let vb_desc = @core.new_object()
  vb_desc._set("size", @core.any(vb_size))
  vb_desc._set("usage", @core.any(BUFFER_USAGE_VERTEX | BUFFER_USAGE_COPY_DST))
  let vb = ffi_create_buffer(device, vb_desc)
  queue._call("writeBuffer", [vb, @core.any(0), vertex_data]) |> ignore
  // Index buffer (temporary)
  let ib_byte_length = indices._get("byteLength").cast_int()
  let ib_size = if ib_byte_length < 16 { 16 } else { ib_byte_length }
  let ib_desc = @core.new_object()
  ib_desc._set("size", @core.any(ib_size))
  ib_desc._set("usage", @core.any(BUFFER_USAGE_INDEX | BUFFER_USAGE_COPY_DST))
  let ib = ffi_create_buffer(device, ib_desc)
  queue._call("writeBuffer", [ib, @core.any(0), indices]) |> ignore
  // Uniform buffer (16-byte aligned)
  let uniform_dwords = cmd._get("uniformDwords")
  let uniform_bytes = if @core.is_nullish(uniform_dwords) {
    0
  } else {
    uniform_dwords._get("byteLength").cast_int()
  }
  let aligned_size = if uniform_bytes <= 16 {
    16
  } else {
    (uniform_bytes + 15) / 16 * 16
  }
  let ub_desc = @core.new_object()
  ub_desc._set("size", @core.any(aligned_size))
  ub_desc._set("usage", @core.any(BUFFER_USAGE_UNIFORM | BUFFER_USAGE_COPY_DST))
  let ub = ffi_create_buffer(device, ub_desc)
  if not(@core.is_nullish(uniform_dwords)) && uniform_bytes > 0 {
    let u8view = @core.new(@core.global_this()._get("Uint8Array"), [
      uniform_dwords._get("buffer"),
      uniform_dwords._get("byteOffset"),
      uniform_dwords._get("byteLength"),
    ])
    queue._call("writeBuffer", [ub, @core.any(0), u8view]) |> ignore
  }
  // Build bind group entries
  let bg_entries = @core.new_array()
  let entry0 = @core.new_object()
  entry0._set("binding", @core.any(0))
  let resource0 = @core.new_object()
  resource0._set("buffer", ub)
  entry0._set("resource", resource0)
  bg_entries._call("push", [entry0]) |> ignore
  let tex_bindings = parse_texture_bindings(shader_source)
  let sampler = match state.linear_sampler {
    Some(s) => s
    None =>
      match state.default_sampler {
        Some(s) => s
        None => {
          let desc = @core.new_object()
          desc._set("magFilter", @core.any("linear"))
          desc._set("minFilter", @core.any("linear"))
          ffi_create_sampler(device, desc)
        }
      }
  }
  let src_image_ids = cmd._get("srcImageIds")
  let mut src_index = 0
  for i = 0; i < tex_bindings.length(); i = i + 1 {
    let tb = tex_bindings[i]
    if tb.type_ == "texture" {
      let mut tex_view_any : @core.Any = state.default_tex_view.unwrap()
      if not(@core.is_nullish(src_image_ids)) {
        let ids_len = src_image_ids._get("length").cast_int()
        if src_index < ids_len {
          let img_id = src_image_ids._get_by_index(src_index).cast_int()
          if img_id > 0 {
            match state.textures.get(img_id) {
              Some(tex_entry) => tex_view_any = tex_entry.view
              None => ()
            }
          }
          src_index = src_index + 1
        }
      }
      let entry = @core.new_object()
      entry._set("binding", @core.any(tb.binding))
      entry._set("resource", tex_view_any)
      bg_entries._call("push", [entry]) |> ignore
    } else {
      let entry = @core.new_object()
      entry._set("binding", @core.any(tb.binding))
      entry._set("resource", sampler)
      bg_entries._call("push", [entry]) |> ignore
    }
  }
  let bg_desc = @core.new_object()
  bg_desc._set("layout", pipeline_info.bind_group_layout)
  bg_desc._set("entries", bg_entries)
  let bind_group = ffi_create_bind_group(device, bg_desc)
  pass._call("setPipeline", [pipeline_info.pipeline]) |> ignore
  pass._call("setBindGroup", [@core.any(0), bind_group]) |> ignore
  pass._call("setVertexBuffer", [@core.any(0), vb]) |> ignore
  pass._call("setIndexBuffer", [ib, @core.any("uint32")]) |> ignore
  let custom_instance_count = cmd._get("instanceCount")
  let custom_ic = if @core.is_nullish(custom_instance_count) {
    1
  } else {
    custom_instance_count.cast_int()
  }
  if custom_ic > 1 {
    pass._call("drawIndexed", [@core.any(idx_length), @core.any(custom_ic)])
    |> ignore
  } else {
    pass._call("drawIndexed", [@core.any(idx_length)]) |> ignore
  }
  state.pending_buffer_cleanup.push(vb)
  state.pending_buffer_cleanup.push(ib)
  state.pending_buffer_cleanup.push(ub)
}

///|
/// Build a render pass descriptor JS object
fn build_render_pass_desc(
  target_view : @core.Any,
  r : Double,
  g : Double,
  b : Double,
  a : Double,
  load_op : String,
  depth_attachment : @core.Any?,
) -> @core.Any {
  let clear_value = @core.new_object()
  clear_value._set("r", @core.Any::float(r))
  clear_value._set("g", @core.Any::float(g))
  clear_value._set("b", @core.Any::float(b))
  clear_value._set("a", @core.Any::float(a))
  let color_att = @core.new_object()
  color_att._set("view", target_view)
  color_att._set("clearValue", clear_value)
  color_att._set("loadOp", @core.any(load_op))
  color_att._set("storeOp", @core.any("store"))
  let color_atts = @core.new_array()
  color_atts._call("push", [color_att]) |> ignore
  let desc = @core.new_object()
  desc._set("colorAttachments", color_atts)
  match depth_attachment {
    Some(da) => desc._set("depthStencilAttachment", da)
    None => ()
  }
  desc
}

///|
/// Main render function
pub fn render_gpu(
  state : GpuState,
  gpu : @core.Any,
  device : @core.Any,
  context : @core.Any,
  clear_color : @core.Any,
  format : String,
) -> Bool {
  if @core.is_nullish(device) || @core.is_nullish(context) {
    return false
  }
  let safe_format = if format.length() > 0 { format } else { "bgra8unorm" }
  if not(ensure_gpu_pipeline(state, device, safe_format)) {
    return false
  }
  let config = @core.new_object()
  config._set("device", device)
  config._set("format", @core.any(safe_format))
  config._set("alphaMode", @core.any("opaque"))
  context._call("configure", [config]) |> ignore
  let r = clear_color._get_by_index(0).cast_double()
  let g = clear_color._get_by_index(1).cast_double()
  let b = clear_color._get_by_index(2).cast_double()
  let a = clear_color._get_by_index(3).cast_double()
  let commands = gpu._get("commands")
  let cmd_length = if @core.is_nullish(commands) ||
    not(@core.is_array(commands)) {
    0
  } else {
    commands._get("length").cast_int()
  }
  let queue = ffi_queue(device)
  if cmd_length == 0 {
    let texture = context._call("getCurrentTexture", [])
    let view = texture._call("createView", [])
    let encoder = ffi_create_command_encoder(device)
    let pass_desc = build_render_pass_desc(view, r, g, b, a, "clear", None)
    let pass = ffi_begin_render_pass(encoder, pass_desc)
    pass._call("end", []) |> ignore
    ffi_submit_one(queue, ffi_finish(encoder))
    gpu._set("commands", @core.new_array())
    return true
  }
  // Check if any custom commands exist
  let mut has_custom = false
  for i = 0; i < cmd_length; i = i + 1 {
    let cmd = commands._get_by_index(i)
    let is_custom = cmd._get("isCustom")
    if not(@core.is_nullish(is_custom)) && is_custom.cast_bool() {
      has_custom = true
      break
    }
  }
  if not(has_custom) {
    // Fast path: single-pass default rendering
    let texture = context._call("getCurrentTexture", [])
    let view = texture._call("createView", [])
    let encoder = ffi_create_command_encoder(device)
    let pass_desc = build_render_pass_desc(view, r, g, b, a, "clear", None)
    let pass = ffi_begin_render_pass(encoder, pass_desc)
    let cache = match state.draw_cache {
      Some(c) => c
      None => {
        let c = DrawResourceCache::new()
        state.draw_cache = Some(c)
        c
      }
    }
    for draw_index = 0; draw_index < cmd_length; draw_index = draw_index + 1 {
      let cmd = commands._get_by_index(draw_index)
      draw_default_command(
        state, device, pass, cmd, draw_index, cache, safe_format,
      )
    }
    pass._call("end", []) |> ignore
    ffi_submit_one(queue, ffi_finish(encoder))
    gpu._set("commands", @core.new_array())
    return true
  }
  // Multi-pass rendering path
  state.pending_buffer_cleanup = []
  let cache = match state.draw_cache {
    Some(c) => c
    None => {
      let c = DrawResourceCache::new()
      state.draw_cache = Some(c)
      c
    }
  }
  let screen_texture = context._call("getCurrentTexture", [])
  let screen_view = screen_texture._call("createView", [])
  let encoder = ffi_create_command_encoder(device)
  let mut current_pass : @core.Any? = None
  let mut current_pass_target = -999
  let mut current_pass_has_depth = false
  let pass_started : Map[Int, Bool] = {}
  let mut default_draw_index = 0
  let last_cmd = commands._get_by_index(cmd_length - 1)
  let screen_target_id = last_cmd._get("dstImageId").cast_int()
  state.screen_target_id = screen_target_id
  for i = 0; i < cmd_length; i = i + 1 {
    let cmd = commands._get_by_index(i)
    let target_id = cmd._get("dstImageId").cast_int()
    let is_custom_cmd = not(@core.is_nullish(cmd._get("isCustom"))) &&
      cmd._get("isCustom").cast_bool()
    let needs_depth = is_custom_cmd &&
      is_stride32(cmd._get("shaderSource").cast_string())
    if target_id != current_pass_target || needs_depth != current_pass_has_depth {
      match current_pass {
        Some(p) => p._call("end", []) |> ignore
        None => ()
      }
      let is_screen = target_id == 0 || target_id == state.screen_target_id
      let mut target_view : @core.Any = screen_view
      let mut pass_format = safe_format
      let mut target_width = screen_texture._get("width").cast_int()
      let mut target_height = screen_texture._get("height").cast_int()
      if not(is_screen) {
        let rt_width_raw = cmd._get("dstWidth")
        let rt_height_raw = cmd._get("dstHeight")
        let rt_width = if @core.is_nullish(rt_width_raw) {
          1
        } else {
          rt_width_raw.cast_int()
        }
        let rt_height = if @core.is_nullish(rt_height_raw) {
          1
        } else {
          rt_height_raw.cast_int()
        }
        let rt = ensure_render_target(
          state, device, target_id, rt_width, rt_height,
        )
        target_view = rt.view
        pass_format = "rgba8unorm"
        target_width = rt_width
        target_height = rt_height
      }
      let depth_attachment : @core.Any? = if needs_depth {
        let depth = ensure_depth_texture(
          state, device, target_width, target_height,
        )
        let da = @core.new_object()
        da._set("view", depth.view)
        da._set("depthClearValue", @core.Any::float(1.0))
        let depth_load = if pass_started.get(target_id) == Some(true) {
          "load"
        } else {
          "clear"
        }
        da._set("depthLoadOp", @core.any(depth_load))
        da._set("depthStoreOp", @core.any("store"))
        Some(da)
      } else {
        None
      }
      let load_op = if pass_started.get(target_id) == Some(true) {
        "load"
      } else {
        "clear"
      }
      let pass_desc = build_render_pass_desc(
        target_view, r, g, b, a, load_op, depth_attachment,
      )
      current_pass = Some(ffi_begin_render_pass(encoder, pass_desc))
      current_pass_target = target_id
      current_pass_has_depth = needs_depth
      pass_started.set(target_id, true)
      ignore(pass_format)
    }
    let is_screen_pass = target_id == 0 || target_id == state.screen_target_id
    let current_format = if is_screen_pass { safe_format } else { "rgba8unorm" }
    match current_pass {
      Some(pass) =>
        if is_custom_cmd {
          draw_custom_command(state, device, pass, cmd, current_format)
        } else {
          draw_default_command(
            state, device, pass, cmd, default_draw_index, cache, current_format,
          )
          default_draw_index = default_draw_index + 1
        }
      None => ()
    }
  }
  match current_pass {
    Some(p) => p._call("end", []) |> ignore
    None => ()
  }
  ffi_submit_one(queue, ffi_finish(encoder))
  for i = 0; i < state.pending_buffer_cleanup.length(); i = i + 1 {
    ffi_destroy(state.pending_buffer_cleanup[i])
  }
  state.pending_buffer_cleanup = []
  gpu._set("commands", @core.new_array())
  true
}

///|
/// Helper: cast Any to Double
fn @core.Any::cast_double(self : @core.Any) -> Double {
  self.cast()
}
