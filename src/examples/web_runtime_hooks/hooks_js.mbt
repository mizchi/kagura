///|
let web_canvas_selector : Ref[String] = Ref::new("#app")

///|
let web_hooks_installed : Ref[Bool] = Ref::new(false)

///|
fn bridge_web_try_initialize(
  canvas_selector : String,
  _options : @platform.WindowOptions,
) -> Bool {
  web_hooks_installed.val && canvas_selector == web_canvas_selector.val
}

///|
fn bridge_web_poll(_active : Bool) -> Unit {
  ()
}

///|
fn bridge_web_should_close() -> Bool {
  false
}

///|
fn bridge_web_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  @core.new_outside_size(width.to_double(), height.to_double())
}

///|
fn bridge_web_current_surface(
  _canvas_selector : String,
  options : @platform.WindowOptions,
) -> @platform.SurfaceToken {
  @platform.create_webgpu_surface_token(12, options.width, options.height, 1.0)
}

///|
fn bridge_web_gfx_try_initialize(
  kind : @gfx.GraphicsBackendKind,
  _width : Int,
  _height : Int,
) -> Bool {
  match kind {
    @gfx.GraphicsBackendKind::WebGpu => web_hooks_installed.val
    @gfx.GraphicsBackendKind::WebGl2 => web_hooks_installed.val
    _ => false
  }
}

///|
fn bridge_web_gfx_on_begin(
  _active : Bool,
  _kind : @gfx.GraphicsBackendKind,
  _pass : @gfx.RenderPassDesc,
) -> Unit {
  ()
}

///|
fn bridge_web_gfx_on_end(
  _active : Bool,
  _kind : @gfx.GraphicsBackendKind,
  _present : Bool,
) -> Unit {
  ()
}

///|
fn bridge_web_gfx_on_draw(
  _active : Bool,
  _kind : @gfx.GraphicsBackendKind,
  _command : @gfx.DrawTrianglesCommand,
) -> Unit {
  ()
}

///|
pub fn install(canvas_selector : String) -> Unit {
  web_canvas_selector.val = canvas_selector
  web_hooks_installed.val = true
  @platform.set_web_canvas_hooks(
    @platform.new_web_canvas_hooks(
      bridge_web_try_initialize, bridge_web_poll, bridge_web_should_close, bridge_web_outside_size,
      bridge_web_current_surface,
    ),
  )
  @gfx.set_web_graphics_hooks(
    @gfx.new_web_graphics_hooks(
      bridge_web_gfx_try_initialize, bridge_web_gfx_on_begin, bridge_web_gfx_on_end,
      bridge_web_gfx_on_draw,
    ),
  )
}

///|
pub fn uninstall() -> Unit {
  web_hooks_installed.val = false
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
