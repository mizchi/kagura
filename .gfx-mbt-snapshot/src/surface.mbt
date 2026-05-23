///|
/// GPU surface descriptor types. A `SurfaceToken` is a backend-agnostic
/// handle that downstream `GraphicsDriver` impls (WebGPU, wgpu-native,
/// offscreen, etc.) interpret to acquire the actual presentation target.
///
/// The kagura platform layer implements `SurfaceProvider` for its
/// platform-specific shells (GLFW desktop, browser canvas); other hosts
/// can create tokens directly with the `create_*_surface_token` helpers.
///
/// Ebiten refs:
/// - internal/ui/ui_glfw.go (native window + graphics surface binding)
/// - internal/ui/ui_js.go  (browser canvas binding)

///|
pub(all) enum SurfaceKind {
  MetalLayer
  WebGpuCanvasContext
  WebGlCanvasContext
  OffscreenBuffer
} derive(Debug)

///|
pub impl Show for SurfaceKind with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct SurfaceToken {
  kind : SurfaceKind
  opaque_id : Int
  width : Int
  height : Int
  device_scale_factor : Double
} derive(Debug)

///|
pub impl Show for SurfaceToken with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// A host platform that can hand a backend the GPU surface to render
/// onto (a canvas context, a CAMetalLayer, an offscreen buffer ...).
///
/// Kagura's platform package implements this for `DesktopGlfwPlatform`
/// and `WebCanvasPlatform`; other hosts implement it themselves or use
/// the `create_*_surface_token` helpers below for static cases.
pub(open) trait SurfaceProvider {
  /// Return the surface to render to right now. May `raise` if the
  /// host is not yet active.
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
