///|
/// Bind a JS host to the shared platform contract. The host owns DOM event
/// listeners; this module never defines a second input or window contract.
pub fn install(hooks : @platform.WebCanvasHooks) -> Unit {
  @platform.set_web_canvas_hooks(hooks)
}

///|
/// Restore the contract's deterministic fallback. Host resources are released
/// by the runtime integration before calling this function.
pub fn uninstall() -> Unit {
  @platform.reset_web_canvas_hooks()
}

///|
/// The returned shell implements both PlatformDriver and gfx.SurfaceProvider.
/// Install the host hooks before initializing it through PlatformDriver.
pub fn create_platform(canvas_selector : String) -> @platform.WebCanvasPlatform {
  @platform.create_web_canvas_platform(canvas_selector)
}
