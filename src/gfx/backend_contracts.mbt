///|
/// Graphics backend selection contracts.
///
/// Ebiten refs:
/// - internal/graphicsdriver/graphics.go
/// - internal/ui/ui_glfw.go (platform dependent surface binding)

///|
pub enum GraphicsBackendKind {
  WgpuNative
  WebGpu
  WebGl2
  Null
} derive(Show)

///|
pub struct GraphicsBackendOptions {
  enable_validation : Bool
  prefer_low_power : Bool
  enable_vsync : Bool
} derive(Show)

///|
pub struct StubGraphicsDriver {
  backend : GraphicsBackendKind
  width : Int
  height : Int
  mut initialized : Bool
  mut native_active : Bool
  mut web_active : Bool
  mut next_id : Int
  mut begin_count : Int
  mut end_count : Int
  mut draw_count : Int
}

///|
pub type NativeGraphicsDriver = StubGraphicsDriver

///|
pub type WebGpuGraphicsDriver = StubGraphicsDriver

///|
pub type WebGlGraphicsDriver = StubGraphicsDriver

///|
pub type NullGraphicsDriver = StubGraphicsDriver

///|
pub trait GraphicsBackendFactory {
  create(
    Self,
    kind : GraphicsBackendKind,
    surface : @platform.SurfaceToken,
    options : GraphicsBackendOptions,
  ) -> Unit raise
}

///|
pub fn default_graphics_backend_options() -> GraphicsBackendOptions {
  { enable_validation: true, prefer_low_power: false, enable_vsync: true }
}

///|
pub fn create_wgpu_native_graphics(
  surface : @platform.SurfaceToken,
  options : GraphicsBackendOptions,
) -> NativeGraphicsDriver {
  let _ = options
  {
    backend: GraphicsBackendKind::WgpuNative,
    width: surface.width,
    height: surface.height,
    initialized: false,
    native_active: false,
    web_active: false,
    next_id: 0,
    begin_count: 0,
    end_count: 0,
    draw_count: 0,
  }
}

///|
pub fn create_webgpu_graphics(
  surface : @platform.SurfaceToken,
  options : GraphicsBackendOptions,
) -> WebGpuGraphicsDriver {
  let _ = options
  {
    backend: GraphicsBackendKind::WebGpu,
    width: surface.width,
    height: surface.height,
    initialized: false,
    native_active: false,
    web_active: false,
    next_id: 0,
    begin_count: 0,
    end_count: 0,
    draw_count: 0,
  }
}

///|
pub fn create_webgl_graphics(
  surface : @platform.SurfaceToken,
  options : GraphicsBackendOptions,
) -> WebGlGraphicsDriver {
  let _ = options
  {
    backend: GraphicsBackendKind::WebGl2,
    width: surface.width,
    height: surface.height,
    initialized: false,
    native_active: false,
    web_active: false,
    next_id: 0,
    begin_count: 0,
    end_count: 0,
    draw_count: 0,
  }
}

///|
pub fn create_null_graphics(width : Int, height : Int) -> NullGraphicsDriver {
  {
    backend: GraphicsBackendKind::Null,
    width,
    height,
    initialized: false,
    native_active: false,
    web_active: false,
    next_id: 0,
    begin_count: 0,
    end_count: 0,
    draw_count: 0,
  }
}

///|
pub impl GraphicsDriver for StubGraphicsDriver with initialize(self) {
  match self.backend {
    GraphicsBackendKind::WgpuNative =>
      self.native_active = native_try_initialize(self.width, self.height)
    GraphicsBackendKind::WebGpu | GraphicsBackendKind::WebGl2 =>
      self.web_active = web_graphics_try_initialize(
        self.backend,
        self.width,
        self.height,
      )
    _ => ()
  }
  self.initialized = true
}

///|
pub impl GraphicsDriver for StubGraphicsDriver with begin(self, pass) {
  let _ = self.backend
  if self.initialized {
    self.begin_count = self.begin_count + 1
    native_on_begin(self.native_active, pass)
    web_graphics_on_begin(self.web_active, self.backend, pass)
  }
}

///|
pub impl GraphicsDriver for StubGraphicsDriver with end(self, present) {
  if self.initialized {
    self.end_count = self.end_count + 1
    native_on_end(self.native_active, present)
    web_graphics_on_end(self.web_active, self.backend, present)
  }
}

///|
pub impl GraphicsDriver for StubGraphicsDriver with new_image(
  self,
  width,
  height,
) {
  self.next_id = self.next_id + 1
  let _ = self.width
  let _ = self.height
  { id: self.next_id, width, height }
}

///|
pub impl GraphicsDriver for StubGraphicsDriver with new_shader(self, source) {
  self.next_id = self.next_id + 1
  { id: self.next_id, source }
}

///|
pub impl GraphicsDriver for StubGraphicsDriver with draw_triangles(
  self,
  command,
) {
  if self.initialized {
    self.draw_count = self.draw_count + 1
    native_on_draw(self.native_active, command)
    web_graphics_on_draw(self.web_active, self.backend, command)
  }
}
