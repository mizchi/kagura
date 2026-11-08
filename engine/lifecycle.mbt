///|
pub(all) struct LifecycleHooks {
  on_start : (String, String) -> Unit
  on_stop : () -> Unit
}

///|
let lifecycle_hooks : Ref[LifecycleHooks?] = Ref(None)

///|
let startup_readiness : Ref[() -> StartupReadiness] = Ref(fn() { Ready })

///|
pub fn set_lifecycle_hooks(
  hooks : LifecycleHooks,
  readiness~ : () -> StartupReadiness = fn() { Ready },
) -> Unit {
  lifecycle_hooks.val = Some(hooks)
  startup_readiness.val = readiness
}

///|
/// Native examples often import both `web_runtime_hooks` (stub on native) and
/// `native_runtime_hooks`. Both packages register in `init`; the stub must not
/// wipe the real GPU install if it happens to run later.
pub fn set_lifecycle_hooks_if_absent(
  hooks : LifecycleHooks,
  readiness~ : () -> StartupReadiness = fn() { Ready },
) -> Unit {
  if lifecycle_hooks.val is None {
    lifecycle_hooks.val = Some(hooks)
    startup_readiness.val = readiness
  }
}

///|
pub fn reset_lifecycle_hooks() -> Unit {
  lifecycle_hooks.val = None
  startup_readiness.val = fn() { Ready }
}

///|
fn begin_session(
  session : RunSession,
  canvas : String,
  title : String,
) -> (() -> StartupReadiness)? {
  if !session.claim_backend() {
    return None
  }
  match lifecycle_hooks.val {
    Some(hooks) => {
      let probe = startup_readiness.val
      session.own(hooks.on_stop)
      (hooks.on_start)(canvas, title)
      Some(probe)
    }
    None => {
      session.fail(Backend, "Runtime hooks are not installed")
      None
    }
  }
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
