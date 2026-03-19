///|
/// Platform surface bridge contracts.
///
/// Ebiten refs:
/// - internal/ui/ui_glfw.go (native window + graphics surface binding)
/// - internal/ui/ui_js.go (browser canvas binding)

///|
pub enum SurfaceKind {
  MetalLayer
  WebGpuCanvasContext
  WebGlCanvasContext
  OffscreenBuffer
} derive(Show)

///|
pub struct SurfaceToken {
  kind : SurfaceKind
  opaque_id : Int
  width : Int
  height : Int
  device_scale_factor : Double
} derive(Show)

///|
pub trait SurfaceProvider {
  current_surface(Self) -> SurfaceToken raise
}

///|
pub fn create_offscreen_surface_token(
  width : Int,
  height : Int,
) -> SurfaceToken {
  {
    kind: SurfaceKind::OffscreenBuffer,
    opaque_id: 0,
    width,
    height,
    device_scale_factor: 1.0,
  }
}

///|
pub fn create_webgpu_surface_token(
  opaque_id : Int,
  width : Int,
  height : Int,
  device_scale_factor : Double,
) -> SurfaceToken {
  {
    kind: SurfaceKind::WebGpuCanvasContext,
    opaque_id,
    width,
    height,
    device_scale_factor,
  }
}

///|
pub fn create_webgl_surface_token(
  opaque_id : Int,
  width : Int,
  height : Int,
  device_scale_factor : Double,
) -> SurfaceToken {
  {
    kind: SurfaceKind::WebGlCanvasContext,
    opaque_id,
    width,
    height,
    device_scale_factor,
  }
}

///|
pub impl SurfaceProvider for DesktopGlfwPlatform with current_surface(self) {
  let outside = if self.native_active {
    desktop_native_outside_size(self.options.width, self.options.height)
  } else {
    @core.new_outside_size(
      self.options.width.to_double(),
      self.options.height.to_double(),
    )
  }
  {
    kind: SurfaceKind::MetalLayer,
    opaque_id: 1,
    width: outside.width.to_int(),
    height: outside.height.to_int(),
    device_scale_factor: 1.0,
  }
}

///|
pub impl SurfaceProvider for WebCanvasPlatform with current_surface(self) {
  if self.web_active {
    web_current_surface(self.canvas_selector, self.options)
  } else {
    {
      kind: SurfaceKind::WebGpuCanvasContext,
      opaque_id: 2,
      width: self.options.width,
      height: self.options.height,
      device_scale_factor: 1.0,
    }
  }
}
