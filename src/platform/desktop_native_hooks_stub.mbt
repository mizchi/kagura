///|
pub struct DesktopNativeHooks {
  try_initialize : (WindowOptions) -> Bool
  poll : (Bool) -> Unit
  should_close : () -> Bool
  outside_size : (Int, Int) -> @core.OutsideSize
}

///|
pub fn new_desktop_native_hooks(
  try_initialize : (WindowOptions) -> Bool,
  poll : (Bool) -> Unit,
  should_close : () -> Bool,
  outside_size : (Int, Int) -> @core.OutsideSize,
) -> DesktopNativeHooks {
  { try_initialize, poll, should_close, outside_size }
}

///|
fn default_desktop_try_initialize(_options : WindowOptions) -> Bool {
  false
}

///|
fn default_desktop_poll(_active : Bool) -> Unit {
  ()
}

///|
fn default_desktop_should_close() -> Bool {
  false
}

///|
fn default_desktop_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  @core.new_outside_size(width.to_double(), height.to_double())
}

///|
fn default_desktop_native_hooks() -> DesktopNativeHooks {
  new_desktop_native_hooks(
    default_desktop_try_initialize, default_desktop_poll, default_desktop_should_close,
    default_desktop_outside_size,
  )
}

///|
let desktop_native_hooks : Ref[DesktopNativeHooks] = Ref::new(
  default_desktop_native_hooks(),
)

///|
pub fn set_desktop_native_hooks(hooks : DesktopNativeHooks) -> Unit {
  desktop_native_hooks.val = hooks
}

///|
pub fn reset_desktop_native_hooks() -> Unit {
  desktop_native_hooks.val = default_desktop_native_hooks()
}

///|
fn desktop_try_native_initialize(options : WindowOptions) -> Bool {
  (desktop_native_hooks.val.try_initialize)(options)
}

///|
fn desktop_poll_native(active : Bool) -> Unit {
  (desktop_native_hooks.val.poll)(active)
}

///|
fn desktop_native_should_close() -> Bool {
  (desktop_native_hooks.val.should_close)()
}

///|
fn desktop_native_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  (desktop_native_hooks.val.outside_size)(width, height)
}
