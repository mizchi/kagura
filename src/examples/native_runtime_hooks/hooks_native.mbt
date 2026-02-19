///|
let runtime_title : Ref[String] = Ref::new("game_engine")

///|
fn bridge_desktop_try_initialize(options : @platform.WindowOptions) -> Bool {
  @wgpu_native.ensure_runtime_context(
    options.width,
    options.height,
    options.title,
  )
}

///|
fn bridge_desktop_poll(active : Bool) -> Unit {
  if active {
    @wgpu_native.runtime_poll_events()
  }
}

///|
fn bridge_desktop_should_close() -> Bool {
  @wgpu_native.runtime_should_close()
}

///|
fn bridge_desktop_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  let size = @wgpu_native.runtime_window_size(width, height)
  @core.new_outside_size(size.width.to_double(), size.height.to_double())
}

///|
fn bridge_gfx_try_initialize(width : Int, height : Int) -> Bool {
  @wgpu_native.ensure_runtime_context(width, height, runtime_title.val)
}

///|
fn bridge_gfx_on_begin(_active : Bool, _pass : @gfx.RenderPassDesc) -> Unit {
  ()
}

///|
fn bridge_gfx_on_end(active : Bool, present : Bool) -> Unit {
  if active && present {
    let _ = @wgpu_native.runtime_render_frame()
  }
}

///|
fn bridge_gfx_on_draw(
  _active : Bool,
  _command : @gfx.DrawTrianglesCommand,
) -> Unit {
  ()
}

///|
pub fn install(title : String) -> Unit {
  runtime_title.val = title
  @platform.set_desktop_native_hooks(
    @platform.new_desktop_native_hooks(
      bridge_desktop_try_initialize, bridge_desktop_poll, bridge_desktop_should_close,
      bridge_desktop_outside_size,
    ),
  )
  @gfx.set_native_graphics_hooks(
    @gfx.new_native_graphics_hooks(
      bridge_gfx_try_initialize, bridge_gfx_on_begin, bridge_gfx_on_end, bridge_gfx_on_draw,
    ),
  )
}

///|
pub fn uninstall() -> Unit {
  @gfx.reset_native_graphics_hooks()
  @platform.reset_desktop_native_hooks()
}

///|
pub fn is_ready() -> Bool {
  @wgpu_native.has_runtime_context()
}

///|
pub fn shutdown() -> Unit {
  @wgpu_native.shutdown_runtime_context()
}

///|
pub fn initialize_context(width : Int, height : Int, title : String) -> Bool {
  install(title)
  @wgpu_native.ensure_runtime_context(width, height, title)
}

///|
pub fn should_close() -> Bool {
  @wgpu_native.runtime_should_close()
}

///|
pub fn poll_events() -> Unit {
  @wgpu_native.runtime_poll_events()
}

///|
pub fn render_frame() -> Bool {
  @wgpu_native.runtime_render_frame()
}

///|
pub fn shutdown_context() -> Unit {
  shutdown()
  uninstall()
}
