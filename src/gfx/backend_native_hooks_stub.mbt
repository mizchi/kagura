///|
pub struct NativeGraphicsHooks {
  try_initialize : (Int, Int) -> Bool
  on_begin : (Bool, RenderPassDesc) -> Unit
  on_end : (Bool, Bool) -> Unit
  on_draw : (Bool, DrawTrianglesCommand) -> Unit
}

///|
pub fn new_native_graphics_hooks(
  try_initialize : (Int, Int) -> Bool,
  on_begin : (Bool, RenderPassDesc) -> Unit,
  on_end : (Bool, Bool) -> Unit,
  on_draw : (Bool, DrawTrianglesCommand) -> Unit,
) -> NativeGraphicsHooks {
  { try_initialize, on_begin, on_end, on_draw }
}

///|
fn default_native_try_initialize(_width : Int, _height : Int) -> Bool {
  false
}

///|
fn default_native_on_begin(_active : Bool, _pass : RenderPassDesc) -> Unit {
  ()
}

///|
fn default_native_on_end(_active : Bool, _present : Bool) -> Unit {
  ()
}

///|
fn default_native_on_draw(
  _active : Bool,
  _command : DrawTrianglesCommand,
) -> Unit {
  ()
}

///|
fn default_native_graphics_hooks() -> NativeGraphicsHooks {
  new_native_graphics_hooks(
    default_native_try_initialize, default_native_on_begin, default_native_on_end,
    default_native_on_draw,
  )
}

///|
let native_graphics_hooks : Ref[NativeGraphicsHooks] = Ref::new(
  default_native_graphics_hooks(),
)

///|
pub fn set_native_graphics_hooks(hooks : NativeGraphicsHooks) -> Unit {
  native_graphics_hooks.val = hooks
}

///|
pub fn reset_native_graphics_hooks() -> Unit {
  native_graphics_hooks.val = default_native_graphics_hooks()
}

///|
fn native_try_initialize(width : Int, height : Int) -> Bool {
  (native_graphics_hooks.val.try_initialize)(width, height)
}

///|
fn native_on_begin(active : Bool, pass : RenderPassDesc) -> Unit {
  (native_graphics_hooks.val.on_begin)(active, pass)
}

///|
fn native_on_end(active : Bool, present : Bool) -> Unit {
  (native_graphics_hooks.val.on_end)(active, present)
}

///|
fn native_on_draw(active : Bool, command : DrawTrianglesCommand) -> Unit {
  (native_graphics_hooks.val.on_draw)(active, command)
}
