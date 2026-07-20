///|
/// `SurfaceProvider` impls for kagura's platform shells. The core types
/// (`SurfaceKind`, `SurfaceToken`, `SurfaceProvider`, `create_*_surface_token`)
/// live in `mizchi/gfx` (`@gfx`) so that gfx itself does not depend on
/// platform; this file only adapts the platform-specific shell types
/// (`DesktopGlfwPlatform`, `WebCanvasPlatform`) to that contract.
///
/// Ebiten refs:
/// - internal/ui/ui_glfw.go (native window + graphics surface binding)
/// - internal/ui/ui_js.go  (browser canvas binding)

///|
pub impl @gfx.SurfaceProvider for DesktopGlfwPlatform with fn current_surface(
  self,
) {
  let outside = if self.native_active {
    desktop_native_outside_size(self.options.width, self.options.height)
  } else {
    @core.new_outside_size(
      self.options.width.to_double(),
      self.options.height.to_double(),
    )
  }
  {
    kind: @gfx.SurfaceKind::MetalLayer,
    opaque_id: 1,
    width: outside.width.to_int(),
    height: outside.height.to_int(),
    device_scale_factor: 1.0,
  }
}

///|
pub impl @gfx.SurfaceProvider for WebCanvasPlatform with fn current_surface(
  self,
) {
  if self.web_active {
    web_current_surface(self.canvas_selector, self.options)
  } else {
    {
      kind: @gfx.SurfaceKind::WebGpuCanvasContext,
      opaque_id: 2,
      width: self.options.width,
      height: self.options.height,
      device_scale_factor: 1.0,
    }
  }
}

///|
pub extend DesktopGlfwPlatform with @mizchi/gfx.SurfaceProvider::{
  current_surface,
}

///|
pub extend WebCanvasPlatform with @mizchi/gfx.SurfaceProvider::{current_surface}
