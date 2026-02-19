///|
pub struct WebCanvasHooks {
  try_initialize : (String, WindowOptions) -> Bool
  poll : (Bool) -> Unit
  should_close : () -> Bool
  outside_size : (Int, Int) -> @core.OutsideSize
  current_surface : (String, WindowOptions) -> SurfaceToken
}

///|
pub fn new_web_canvas_hooks(
  try_initialize : (String, WindowOptions) -> Bool,
  poll : (Bool) -> Unit,
  should_close : () -> Bool,
  outside_size : (Int, Int) -> @core.OutsideSize,
  current_surface : (String, WindowOptions) -> SurfaceToken,
) -> WebCanvasHooks {
  { try_initialize, poll, should_close, outside_size, current_surface }
}

///|
fn default_web_try_initialize(
  _canvas_selector : String,
  _options : WindowOptions,
) -> Bool {
  false
}

///|
fn default_web_poll(_active : Bool) -> Unit {
  ()
}

///|
fn default_web_should_close() -> Bool {
  false
}

///|
fn default_web_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  @core.new_outside_size(width.to_double(), height.to_double())
}

///|
fn default_web_current_surface(
  _canvas_selector : String,
  options : WindowOptions,
) -> SurfaceToken {
  {
    kind: SurfaceKind::WebGpuCanvasContext,
    opaque_id: 2,
    width: options.width,
    height: options.height,
    device_scale_factor: 1.0,
  }
}

///|
fn default_web_canvas_hooks() -> WebCanvasHooks {
  new_web_canvas_hooks(
    default_web_try_initialize, default_web_poll, default_web_should_close, default_web_outside_size,
    default_web_current_surface,
  )
}

///|
let web_canvas_hooks : Ref[WebCanvasHooks] = Ref::new(
  default_web_canvas_hooks(),
)

///|
pub fn set_web_canvas_hooks(hooks : WebCanvasHooks) -> Unit {
  web_canvas_hooks.val = hooks
}

///|
pub fn reset_web_canvas_hooks() -> Unit {
  web_canvas_hooks.val = default_web_canvas_hooks()
}

///|
fn web_try_initialize(
  canvas_selector : String,
  options : WindowOptions,
) -> Bool {
  (web_canvas_hooks.val.try_initialize)(canvas_selector, options)
}

///|
fn web_poll(active : Bool) -> Unit {
  (web_canvas_hooks.val.poll)(active)
}

///|
fn web_should_close() -> Bool {
  (web_canvas_hooks.val.should_close)()
}

///|
fn web_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  (web_canvas_hooks.val.outside_size)(width, height)
}

///|
fn web_current_surface(
  canvas_selector : String,
  options : WindowOptions,
) -> SurfaceToken {
  (web_canvas_hooks.val.current_surface)(canvas_selector, options)
}
