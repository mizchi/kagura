///|
/// The MoonBit render callback, called from the JS wrapper
fn render_impl(args : @core.Any) -> @core.Any {
  let gpu = args._get_by_index(0)
  let device = args._get_by_index(1)
  let context = args._get_by_index(2)
  let clear_color = args._get_by_index(3)
  let format : String = args._get_by_index(4).cast()
  let state = get_gpu_state()
  sync_js_textures(state, gpu)
  let result = render_gpu(state, gpu, device, context, clear_color, format)
  @core.any(result)
}

///|
/// Install GFX helpers on globalThis.__kaguraGfx for use from hooks_js.mbt.
pub fn install_gfx_helpers() -> Unit {
  let gfx = @core.new_object()
  gfx._set(
    "ensurePipeline",
    @core.from_fn3(fn(
      gpu : @core.Any,
      device : @core.Any,
      format : @core.Any,
    ) -> @core.Any {
      let state = get_gpu_state()
      let fmt : String = format.cast()
      sync_js_textures(state, gpu)
      let result = ensure_gpu_pipeline(state, device, fmt)
      @core.any(result)
    }),
  )
  let render_callback = @core.from_fn1(fn(args : @core.Any) -> @core.Any {
    render_impl(args)
  })
  gfx._set("_renderCallback", render_callback)
  js_install_render_wrapper(gfx)
  gfx._set(
    "release",
    @core.from_fn1(fn(gpu : @core.Any) -> @core.Any {
      let state = get_gpu_state()
      release_gpu_resources(state, gpu)
      @core.undefined()
    }),
  )
  gfx._set(
    "finalizeTexture",
    @core.from_fn1(fn(gpu : @core.Any) -> @core.Any {
      let state = get_gpu_state()
      let device = gpu._get("device")
      if @core.is_nullish(device) {
        return @core.undefined()
      }
      sync_js_textures(state, gpu)
      finalize_texture_upload(state, gpu, device)
      @core.undefined()
    }),
  )
  @core.global_this()._set("__kaguraGfx", gfx)
}

///|
/// JS helper: install a 5-arg render function that packs args and calls _renderCallback
extern "js" fn js_install_render_wrapper(gfx : @core.Any) -> Unit =
  #| function(gfx) {
  #|   gfx.render = function(gpu, device, context, clearColor, format) {
  #|     return gfx._renderCallback([gpu, device, context, clearColor, format]);
  #|   };
  #| }

///|
/// Sync textures from JS gpu.textures Map into MoonBit GpuState.textures
fn sync_js_textures(state : GpuState, gpu : @core.Any) -> Unit {
  let js_textures = gpu._get("textures")
  if @core.is_nullish(js_textures) {
    return
  }
  let entries = js_textures._call("entries", [])
  while true {
    let next = entries._call("next", [])
    let done = next._get("done")
    if !@core.is_nullish(done) && done.cast_bool() {
      break
    }
    let value = next._get("value")
    let image_id : Int = value._get_by_index(0).cast()
    let js_entry = value._get_by_index(1)
    match state.textures.get(image_id) {
      Some(existing) => {
        let js_rev = js_entry._get("revision")
        if !@core.is_nullish(js_rev) {
          let rev : Int = js_rev.cast()
          existing.revision = rev
        }
      }
      None => {
        let texture = js_entry._get("texture")
        let view = js_entry._get("view")
        let sampler = js_entry._get("sampler")
        let width : Int = js_entry._get("width").cast()
        let height : Int = js_entry._get("height").cast()
        let rev_any = js_entry._get("revision")
        let revision = if @core.is_nullish(rev_any) {
          0
        } else {
          rev_any.cast()
        }
        let entry : TextureEntry = {
          texture,
          view,
          sampler,
          width,
          height,
          revision,
        }
        state.textures.set(image_id, entry)
      }
    }
  }
}
