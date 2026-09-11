///|
pub(all) struct LifecycleHooks {
  on_start : (String, String) -> Unit
  on_stop : () -> Unit
}

///|
let lifecycle_hooks : Ref[LifecycleHooks?] = Ref(None)

///|
pub fn set_lifecycle_hooks(hooks : LifecycleHooks) -> Unit {
  lifecycle_hooks.val = Some(hooks)
}

///|
/// Native examples often import both `web_runtime_hooks` (stub on native) and
/// `native_runtime_hooks`. Both packages register in `init`; the stub must not
/// wipe the real GPU install if it happens to run later.
pub fn set_lifecycle_hooks_if_absent(hooks : LifecycleHooks) -> Unit {
  if lifecycle_hooks.val is None {
    lifecycle_hooks.val = Some(hooks)
  }
}

///|
pub fn reset_lifecycle_hooks() -> Unit {
  lifecycle_hooks.val = None
}

///|
#warnings("-unused_value")
fn invoke_on_start(canvas : String, title : String) -> Unit {
  match lifecycle_hooks.val {
    Some(hooks) => (hooks.on_start)(canvas, title)
    None => ()
  }
}

///|
#warnings("-unused_value")
fn invoke_on_stop() -> Unit {
  match lifecycle_hooks.val {
    Some(hooks) => (hooks.on_stop)()
    None => ()
  }
}
