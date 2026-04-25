///|
/// Release all buffer entries in a cache array
fn release_buffer_entries(entries : Array[BufferEntry?]) -> Unit {
  for i = 0; i < entries.length(); i = i + 1 {
    match entries[i] {
      Some(entry) => ffi_destroy(entry.buffer)
      None => ()
    }
  }
}

///|
/// Release all GPU resources and reset state
pub fn release_gpu_resources(state : GpuState, gpu : @core.Any) -> Unit {
  match state.draw_cache {
    Some(cache) => {
      release_buffer_entries(cache.vertex_buffers)
      release_buffer_entries(cache.index_buffers)
      release_buffer_entries(cache.uniform_buffers)
    }
    None => ()
  }
  state.textures.each(fn(_id, entry) { ffi_destroy(entry.texture) })
  state.textures = {}
  match state.default_texture {
    Some(tex) => ffi_destroy(tex)
    None => ()
  }
  let context = gpu._get("context")
  if !(@core.is_nullish(context)) {
    let unconfigure = context._get("unconfigure")
    if !(@core.is_nullish(unconfigure)) {
      context._call("unconfigure", []) |> ignore
    }
  }
  state.custom_pipelines = {}
  state.render_targets.each(fn(_id, entry) { ffi_destroy(entry.texture) })
  state.render_targets = {}
  state.depth_textures.each(fn(_key, entry) { ffi_destroy(entry.texture) })
  state.depth_textures = {}
  state.pipeline = None
  state.pipeline_format = ""
  state.pipeline_offscreen = None
  state.uniform_bgl = None
  state.tex_bgl = None
  state.default_texture = None
  state.default_tex_view = None
  state.default_sampler = None
  state.linear_sampler = None
  state.draw_cache = None
  state.pending_buffer_cleanup = []
  gpu._set("commands", @core.new_array())
  let js_textures = gpu._get("textures")
  if !(@core.is_nullish(js_textures)) {
    js_textures._call("clear", []) |> ignore
  }
  reset_gpu_state()
}
