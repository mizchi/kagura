///|
/// Shared runtime context between platform and gfx native hooks.
///
/// Ebiten refs:
/// - internal/ui/ui_glfw.go (window/event lifecycle)
/// - internal/graphicsdriver/* (backend initialization and frame present)

///|
let runtime_context : Ref[TriangleContext?] = Ref::new(None)

///|
pub fn has_runtime_context() -> Bool {
  match runtime_context.val {
    Some(_) => true
    None => false
  }
}

///|
pub fn ensure_runtime_context(
  width : Int,
  height : Int,
  title : String,
) -> Bool {
  if has_runtime_context() {
    true
  } else {
    match try_init_triangle_context(width, height, title) {
      Some(ctx) => {
        runtime_context.val = Some(ctx)
        true
      }
      None => false
    }
  }
}

///|
pub fn runtime_poll_events() -> Unit {
  match runtime_context.val {
    Some(ctx) => poll(ctx)
    None => ()
  }
}

///|
pub fn runtime_should_close() -> Bool {
  match runtime_context.val {
    Some(ctx) => !should_continue(ctx)
    None => false
  }
}

///|
pub fn runtime_window_size(
  fallback_width : Int,
  fallback_height : Int,
) -> WindowSize {
  match runtime_context.val {
    Some(ctx) => get_window_size(ctx.window)
    None => { width: fallback_width, height: fallback_height }
  }
}

///|
pub fn runtime_render_frame() -> Bool {
  match runtime_context.val {
    Some(ctx) => {
      render_triangle_frame(ctx)
      true
    }
    None => false
  }
}

///|
pub fn shutdown_runtime_context() -> Unit {
  match runtime_context.val {
    Some(ctx) => {
      shutdown_triangle_context(ctx)
      runtime_context.val = None
    }
    None => ()
  }
}
