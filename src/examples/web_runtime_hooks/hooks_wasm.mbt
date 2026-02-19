///|
let web_canvas_selector : Ref[String] = Ref::new("#app")

///|
let web_hooks_installed : Ref[Bool] = Ref::new(false)

///|
let web_fullscreen_state : Ref[Bool] = Ref::new(false)

///|
let web_cursor_mode_state : Ref[Int] = Ref::new(0)

///|
let web_device_scale_state : Ref[Double] = Ref::new(1.0)

///|
let web_vsync_state : Ref[Bool] = Ref::new(true)

///|
let web_close_requested : Ref[Bool] = Ref::new(false)

///|
let web_attention_requests : Ref[Int] = Ref::new(0)

///|
fn bool_to_int(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
fn int_to_bool(value : Int) -> Bool {
  value != 0
}

///|
fn backend_kind_to_int(kind : @gfx.GraphicsBackendKind) -> Int {
  match kind {
    @gfx.GraphicsBackendKind::WgpuNative => 0
    @gfx.GraphicsBackendKind::WebGpu => 1
    @gfx.GraphicsBackendKind::WebGl2 => 2
    @gfx.GraphicsBackendKind::Null => 3
  }
}

///|
extern "wasm" fn host_prepare_surface(width : Int, height : Int) -> Int = "game_engine_web" "prepare_surface"

///|
extern "wasm" fn host_surface_kind() -> Int = "game_engine_web" "surface_kind"

///|
extern "wasm" fn host_surface_id() -> Int = "game_engine_web" "surface_id"

///|
extern "wasm" fn host_surface_width(fallback_width : Int) -> Int = "game_engine_web" "surface_width"

///|
extern "wasm" fn host_surface_height(fallback_height : Int) -> Int = "game_engine_web" "surface_height"

///|
extern "wasm" fn host_surface_dpr() -> Double = "game_engine_web" "surface_dpr"

///|
extern "wasm" fn host_should_close() -> Int = "game_engine_web" "should_close"

///|
extern "wasm" fn host_gfx_try_initialize(
  kind : Int,
  width : Int,
  height : Int,
) -> Int = "game_engine_web" "gfx_try_initialize"

///|
extern "wasm" fn host_gfx_begin(
  kind : Int,
  clear_r : Double,
  clear_g : Double,
  clear_b : Double,
  clear_a : Double,
) -> Unit = "game_engine_web" "gfx_begin"

///|
extern "wasm" fn host_gfx_draw(
  kind : Int,
  draw_calls : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend_mode : Int,
  dst_image_id : Int,
  shader_id : Int,
  index_offset : Int,
  region_count : Int,
  total_index_count : Int,
  vertex_float_count : Int,
  index_count : Int,
  src_image_count : Int,
  uniform_dword_count : Int,
  payload_has_triangle : Int,
  payload_ax : Double,
  payload_ay : Double,
  payload_bx : Double,
  payload_by : Double,
  payload_cx : Double,
  payload_cy : Double,
  payload_au : Double,
  payload_av : Double,
  payload_bu : Double,
  payload_bv : Double,
  payload_cu : Double,
  payload_cv : Double,
  payload_uniform_r : Double,
  payload_uniform_g : Double,
  payload_uniform_b : Double,
  payload_uniform_a : Double,
  payload_texture_seed : Int,
) -> Unit = "game_engine_web" "gfx_draw"

///|
extern "wasm" fn host_gfx_end(kind : Int, present : Int) -> Unit = "game_engine_web" "gfx_end"

///|
extern "wasm" fn host_shutdown() -> Unit = "game_engine_web" "shutdown"

///|
fn bridge_web_try_initialize(
  canvas_selector : String,
  options : @platform.WindowOptions,
) -> Bool {
  web_hooks_installed.val &&
  canvas_selector == web_canvas_selector.val &&
  int_to_bool(host_prepare_surface(options.width, options.height))
}

///|
fn bridge_web_poll(_active : Bool) -> Unit {
  ()
}

///|
fn bridge_web_should_close() -> Bool {
  web_close_requested.val || int_to_bool(host_should_close())
}

///|
fn bridge_web_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  let _ = host_prepare_surface(width, height)
  @core.new_outside_size(width.to_double(), height.to_double())
}

///|
fn bridge_web_current_surface(
  _canvas_selector : String,
  options : @platform.WindowOptions,
) -> @platform.SurfaceToken {
  let _ = host_prepare_surface(options.width, options.height)
  let surface_id = host_surface_id()
  let surface_width = host_surface_width(options.width)
  let surface_height = host_surface_height(options.height)
  let surface_dpr = host_surface_dpr()
  match host_surface_kind() {
    1 =>
      @platform.create_webgl_surface_token(
        surface_id, surface_width, surface_height, surface_dpr,
      )
    _ =>
      @platform.create_webgpu_surface_token(
        surface_id, surface_width, surface_height, surface_dpr,
      )
  }
}

///|
fn bridge_web_capture_input(_active : Bool, _tick : Int) -> @core.InputSnapshot {
  @core.empty_input_snapshot()
}

///|
fn bridge_web_set_fullscreen(
  _canvas_selector : String,
  active : Bool,
  enabled : Bool,
) -> Bool {
  if active {
    web_fullscreen_state.val = enabled
  }
  web_fullscreen_state.val
}

///|
fn bridge_web_is_fullscreen(
  _canvas_selector : String,
  active : Bool,
  current : Bool,
) -> Bool {
  if active {
    web_fullscreen_state.val
  } else {
    current
  }
}

///|
fn bridge_web_set_cursor_mode(
  _canvas_selector : String,
  active : Bool,
  mode : @platform.CursorMode,
) -> @platform.CursorMode {
  if active {
    web_cursor_mode_state.val = @platform.cursor_mode_to_int(mode)
  }
  @platform.cursor_mode_from_int(web_cursor_mode_state.val)
}

///|
fn bridge_web_cursor_mode(
  _canvas_selector : String,
  active : Bool,
  current : @platform.CursorMode,
) -> @platform.CursorMode {
  if active {
    @platform.cursor_mode_from_int(web_cursor_mode_state.val)
  } else {
    current
  }
}

///|
fn bridge_web_set_device_scale_factor(
  _canvas_selector : String,
  active : Bool,
  scale : Double,
) -> Double {
  let normalized = if scale <= 0.0 { 1.0 } else { scale }
  if active {
    web_device_scale_state.val = normalized
  }
  web_device_scale_state.val
}

///|
fn bridge_web_device_scale_factor(
  _canvas_selector : String,
  active : Bool,
  current : Double,
) -> Double {
  if active {
    web_device_scale_state.val
  } else if current <= 0.0 {
    1.0
  } else {
    current
  }
}

///|
fn bridge_web_set_vsync_enabled(
  _canvas_selector : String,
  active : Bool,
  enabled : Bool,
) -> Bool {
  if active {
    web_vsync_state.val = enabled
  }
  web_vsync_state.val
}

///|
fn bridge_web_is_vsync_enabled(
  _canvas_selector : String,
  active : Bool,
  current : Bool,
) -> Bool {
  if active {
    web_vsync_state.val
  } else {
    current
  }
}

///|
fn bridge_web_close_window(_canvas_selector : String, active : Bool) -> Unit {
  if active {
    web_close_requested.val = true
  }
}

///|
fn bridge_web_request_attention(
  _canvas_selector : String,
  active : Bool,
) -> Unit {
  if active {
    web_attention_requests.val = web_attention_requests.val + 1
  }
}

///|
fn bridge_web_gfx_try_initialize(
  kind : @gfx.GraphicsBackendKind,
  width : Int,
  height : Int,
) -> Bool {
  if !web_hooks_installed.val {
    false
  } else {
    int_to_bool(
      host_gfx_try_initialize(backend_kind_to_int(kind), width, height),
    )
  }
}

///|
fn bridge_web_gfx_on_begin(
  active : Bool,
  kind : @gfx.GraphicsBackendKind,
  pass : @gfx.RenderPassDesc,
) -> Unit {
  if active {
    host_gfx_begin(
      backend_kind_to_int(kind),
      pass.clear_color.r,
      pass.clear_color.g,
      pass.clear_color.b,
      pass.clear_color.a,
    )
  }
}

///|
fn bridge_web_gfx_on_end(
  active : Bool,
  kind : @gfx.GraphicsBackendKind,
  present : Bool,
) -> Unit {
  if active {
    host_gfx_end(backend_kind_to_int(kind), bool_to_int(present))
  }
}

///|
fn bridge_web_gfx_on_draw(
  active : Bool,
  kind : @gfx.GraphicsBackendKind,
  command : @gfx.DrawTrianglesCommand,
) -> Unit {
  if active {
    let dispatch = @gfx.build_draw_command_dispatch(command)
    let payload = @payload2d.decode_triangle_payload(
      command.vertex_data,
      command.indices,
      command.uniform_dwords,
      command.src_image_ids,
    )
    let payload_has_triangle = if payload.has_payload { 1 } else { 0 }
    host_gfx_draw(
      backend_kind_to_int(kind),
      dispatch.draw_calls,
      dispatch.pipeline_id,
      dispatch.uniform_hash,
      dispatch.blend_mode,
      dispatch.dst_image_id,
      dispatch.shader_id,
      dispatch.index_offset,
      dispatch.region_count,
      dispatch.total_index_count,
      dispatch.vertex_float_count,
      dispatch.index_count,
      dispatch.src_image_count,
      dispatch.uniform_dword_count,
      payload_has_triangle,
      payload.ax,
      payload.ay,
      payload.bx,
      payload.by,
      payload.cx,
      payload.cy,
      payload.au,
      payload.av,
      payload.bu,
      payload.bv,
      payload.cu,
      payload.cv,
      payload.uniform_r,
      payload.uniform_g,
      payload.uniform_b,
      payload.uniform_a,
      payload.texture_seed,
    )
  }
}

///|
fn bridge_web_gfx_on_resize(
  active : Bool,
  kind : @gfx.GraphicsBackendKind,
  width : Int,
  height : Int,
) -> Unit {
  if active {
    let _ = kind
    let _ = host_prepare_surface(width, height)
  }
}

///|
pub fn install(canvas_selector : String) -> Unit {
  web_canvas_selector.val = canvas_selector
  web_hooks_installed.val = true
  web_fullscreen_state.val = false
  web_cursor_mode_state.val = 0
  web_device_scale_state.val = 1.0
  web_vsync_state.val = true
  web_close_requested.val = false
  web_attention_requests.val = 0
  @platform.set_web_canvas_hooks(
    @platform.new_web_canvas_hooks(
      bridge_web_try_initialize, bridge_web_poll, bridge_web_should_close, bridge_web_outside_size,
      bridge_web_current_surface, bridge_web_capture_input, bridge_web_set_fullscreen,
      bridge_web_is_fullscreen, bridge_web_set_cursor_mode, bridge_web_cursor_mode,
      bridge_web_set_device_scale_factor, bridge_web_device_scale_factor, bridge_web_set_vsync_enabled,
      bridge_web_is_vsync_enabled, bridge_web_close_window, bridge_web_request_attention,
    ),
  )
  @gfx.set_web_graphics_hooks(
    @gfx.new_web_graphics_hooks(
      bridge_web_gfx_try_initialize, bridge_web_gfx_on_begin, bridge_web_gfx_on_end,
      bridge_web_gfx_on_draw, bridge_web_gfx_on_resize,
    ),
  )
}

///|
pub fn uninstall() -> Unit {
  web_hooks_installed.val = false
  web_close_requested.val = false
  host_shutdown()
  @gfx.reset_web_graphics_hooks()
  @platform.reset_web_canvas_hooks()
}

///|
pub fn is_ready() -> Bool {
  web_hooks_installed.val
}

///|
pub fn shutdown() -> Unit {
  uninstall()
}
