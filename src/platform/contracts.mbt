///|
/// Platform layer contracts (window/event/input).
/// Ebiten refs:
/// - internal/ui/ui.go
/// - internal/ui/ui_glfw.go
/// - internal/ui/input_*.go
/// - internal/inputstate/inputstate.go

///|
pub struct WindowOptions {
  title : String
  width : Int
  height : Int
  transparent : Bool
  resizable : Bool
} derive(Show)

///|
pub struct MonitorInfo {
  width : Int
  height : Int
  device_scale_factor : Double
} derive(Show)

///|
pub fn new_window_options(
  title : String,
  width : Int,
  height : Int,
  transparent : Bool,
  resizable : Bool,
) -> WindowOptions {
  { title, width, height, transparent, resizable }
}

///|
pub trait PlatformDriver {
  /// Ebiten ref: UserInterface.init / Run
  initialize(Self, options : WindowOptions) -> Unit raise

  /// Ebiten ref: ui.loopGame event pump
  poll_events(Self) -> Unit

  /// Ebiten ref: window close handling in ui/inputstate
  should_close(Self) -> Bool

  /// Ebiten ref: Game.Layout outside size inputs
  outside_size(Self) -> @core.OutsideSize

  /// Ebiten ref: inputstate snapshot per tick
  capture_input(Self, tick : Int) -> @core.InputSnapshot

  /// Ebiten ref: device scale factor paths in ui/context
  monitor_info(Self) -> MonitorInfo
}

///|
pub struct DesktopGlfwPlatform {
  mut initialized : Bool
  mut poll_count : Int
  close_after_polls : Int
  mut native_active : Bool
  mut options : WindowOptions
  current_input : @core.InputSnapshot
}

///|
pub struct WebCanvasPlatform {
  canvas_selector : String
  mut initialized : Bool
  mut poll_count : Int
  close_after_polls : Int
  mut web_active : Bool
  mut options : WindowOptions
  current_input : @core.InputSnapshot
}

///|
pub fn create_desktop_glfw_platform() -> DesktopGlfwPlatform {
  {
    initialized: false,
    poll_count: 0,
    close_after_polls: 2,
    native_active: false,
    options: {
      title: "game_engine",
      width: 800,
      height: 600,
      transparent: false,
      resizable: true,
    },
    current_input: @core.empty_input_snapshot(),
  }
}

///|
pub fn create_web_canvas_platform(
  canvas_selector : String,
) -> WebCanvasPlatform {
  {
    canvas_selector,
    initialized: false,
    poll_count: 0,
    close_after_polls: 2,
    web_active: false,
    options: {
      title: "game_engine-web",
      width: 800,
      height: 600,
      transparent: true,
      resizable: true,
    },
    current_input: @core.empty_input_snapshot(),
  }
}

///|
pub impl PlatformDriver for DesktopGlfwPlatform with initialize(self, options) {
  self.options = options
  self.native_active = desktop_try_native_initialize(options)
  self.initialized = true
  self.poll_count = 0
}

///|
pub impl PlatformDriver for DesktopGlfwPlatform with poll_events(self) {
  if self.initialized {
    desktop_poll_native(self.native_active)
    self.poll_count = self.poll_count + 1
  }
}

///|
pub impl PlatformDriver for DesktopGlfwPlatform with should_close(self) {
  if self.native_active {
    self.initialized &&
    (desktop_native_should_close() || self.poll_count >= self.close_after_polls)
  } else {
    self.initialized && self.poll_count >= self.close_after_polls
  }
}

///|
pub impl PlatformDriver for DesktopGlfwPlatform with outside_size(self) {
  if self.native_active {
    desktop_native_outside_size(self.options.width, self.options.height)
  } else {
    @core.new_outside_size(
      self.options.width.to_double(),
      self.options.height.to_double(),
    )
  }
}

///|
pub impl PlatformDriver for DesktopGlfwPlatform with capture_input(self, tick) {
  let _ = tick
  self.current_input
}

///|
pub impl PlatformDriver for DesktopGlfwPlatform with monitor_info(self) {
  let outside = self.outside_size()
  {
    width: outside.width.to_int(),
    height: outside.height.to_int(),
    device_scale_factor: 1.0,
  }
}

///|
pub impl PlatformDriver for WebCanvasPlatform with initialize(self, options) {
  self.options = options
  self.web_active = web_try_initialize(self.canvas_selector, options)
  self.initialized = true
  self.poll_count = 0
}

///|
pub impl PlatformDriver for WebCanvasPlatform with poll_events(self) {
  if self.initialized {
    web_poll(self.web_active)
    self.poll_count = self.poll_count + 1
  }
}

///|
pub impl PlatformDriver for WebCanvasPlatform with should_close(self) {
  if self.web_active {
    self.initialized &&
    (web_should_close() || self.poll_count >= self.close_after_polls)
  } else {
    self.initialized && self.poll_count >= self.close_after_polls
  }
}

///|
pub impl PlatformDriver for WebCanvasPlatform with outside_size(self) {
  if self.web_active {
    web_outside_size(self.options.width, self.options.height)
  } else {
    @core.new_outside_size(
      self.options.width.to_double(),
      self.options.height.to_double(),
    )
  }
}

///|
pub impl PlatformDriver for WebCanvasPlatform with capture_input(self, tick) {
  let _ = tick
  self.current_input
}

///|
pub impl PlatformDriver for WebCanvasPlatform with monitor_info(self) {
  {
    width: self.options.width,
    height: self.options.height,
    device_scale_factor: 1.0,
  }
}
