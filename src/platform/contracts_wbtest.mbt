///|
fn default_window_options_for_test() -> WindowOptions {
  {
    title: "test",
    width: 320,
    height: 240,
    transparent: false,
    resizable: true,
  }
}

///|
let test_native_init_calls : Ref[Int] = Ref::new(0)

///|
let test_native_poll_calls : Ref[Int] = Ref::new(0)

///|
let test_native_should_close_value : Ref[Bool] = Ref::new(false)

///|
fn test_native_try_initialize(_options : WindowOptions) -> Bool {
  test_native_init_calls.val = test_native_init_calls.val + 1
  true
}

///|
fn test_native_poll(active : Bool) -> Unit {
  if active {
    test_native_poll_calls.val = test_native_poll_calls.val + 1
  }
}

///|
fn test_native_should_close() -> Bool {
  test_native_should_close_value.val
}

///|
fn test_native_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  @core.new_outside_size((width * 2).to_double(), (height * 3).to_double())
}

///|
let test_web_init_calls : Ref[Int] = Ref::new(0)

///|
let test_web_poll_calls : Ref[Int] = Ref::new(0)

///|
let test_web_should_close_value : Ref[Bool] = Ref::new(false)

///|
fn test_web_try_initialize(
  _canvas_selector : String,
  _options : WindowOptions,
) -> Bool {
  test_web_init_calls.val = test_web_init_calls.val + 1
  true
}

///|
fn test_web_poll(active : Bool) -> Unit {
  if active {
    test_web_poll_calls.val = test_web_poll_calls.val + 1
  }
}

///|
fn test_web_should_close() -> Bool {
  test_web_should_close_value.val
}

///|
fn test_web_outside_size(width : Int, height : Int) -> @core.OutsideSize {
  @core.new_outside_size((width * 4).to_double(), (height * 5).to_double())
}

///|
fn test_web_current_surface(
  _canvas_selector : String,
  options : WindowOptions,
) -> SurfaceToken {
  {
    kind: SurfaceKind::WebGlCanvasContext,
    opaque_id: 99,
    width: options.width + 1,
    height: options.height + 2,
    device_scale_factor: 2.0,
  }
}

///|
fn is_webgl_canvas_context(kind : SurfaceKind) -> Bool {
  match kind {
    SurfaceKind::WebGlCanvasContext => true
    _ => false
  }
}

///|
fn is_webgpu_canvas_context(kind : SurfaceKind) -> Bool {
  match kind {
    SurfaceKind::WebGpuCanvasContext => true
    _ => false
  }
}

///|
test "desktop native hooks can be overridden and reset" {
  reset_desktop_native_hooks()
  test_native_init_calls.val = 0
  test_native_poll_calls.val = 0
  test_native_should_close_value.val = true

  set_desktop_native_hooks(
    new_desktop_native_hooks(
      test_native_try_initialize, test_native_poll, test_native_should_close, test_native_outside_size,
    ),
  )

  let p = create_desktop_glfw_platform()
  p.initialize(default_window_options_for_test())
  p.poll_events()

  let outside = p.outside_size()
  assert_eq(outside.width.to_int(), 640)
  assert_eq(outside.height.to_int(), 720)
  assert_true(p.should_close())
  assert_eq(test_native_init_calls.val, 1)
  assert_eq(test_native_poll_calls.val, 1)

  reset_desktop_native_hooks()

  let before_init_calls = test_native_init_calls.val
  let before_poll_calls = test_native_poll_calls.val
  let p2 = create_desktop_glfw_platform()
  p2.initialize(default_window_options_for_test())
  p2.poll_events()

  let outside2 = p2.outside_size()
  assert_eq(outside2.width.to_int(), 320)
  assert_eq(outside2.height.to_int(), 240)
  assert_true(!p2.should_close())
  assert_eq(test_native_init_calls.val, before_init_calls)
  assert_eq(test_native_poll_calls.val, before_poll_calls)
}

///|
test "web canvas hooks can be overridden and reset" {
  reset_web_canvas_hooks()
  test_web_init_calls.val = 0
  test_web_poll_calls.val = 0
  test_web_should_close_value.val = true

  set_web_canvas_hooks(
    new_web_canvas_hooks(
      test_web_try_initialize, test_web_poll, test_web_should_close, test_web_outside_size,
      test_web_current_surface,
    ),
  )

  let p = create_web_canvas_platform("#hooked")
  p.initialize(default_window_options_for_test())
  p.poll_events()

  let outside = p.outside_size()
  assert_eq(outside.width.to_int(), 1280)
  assert_eq(outside.height.to_int(), 1200)
  assert_true(p.should_close())
  assert_eq(test_web_init_calls.val, 1)
  assert_eq(test_web_poll_calls.val, 1)

  let surface = p.current_surface()
  assert_true(is_webgl_canvas_context(surface.kind))
  assert_eq(surface.opaque_id, 99)
  assert_eq(surface.width, 321)
  assert_eq(surface.height, 242)
  assert_eq(surface.device_scale_factor, 2.0)

  reset_web_canvas_hooks()

  let before_init_calls = test_web_init_calls.val
  let before_poll_calls = test_web_poll_calls.val
  let p2 = create_web_canvas_platform("#default")
  p2.initialize(default_window_options_for_test())
  p2.poll_events()

  let outside2 = p2.outside_size()
  assert_eq(outside2.width.to_int(), 320)
  assert_eq(outside2.height.to_int(), 240)
  assert_true(!p2.should_close())
  let surface2 = p2.current_surface()
  assert_true(is_webgpu_canvas_context(surface2.kind))
  assert_eq(test_web_init_calls.val, before_init_calls)
  assert_eq(test_web_poll_calls.val, before_poll_calls)
}

///|
test "desktop platform stub provides input and size" {
  let p = create_desktop_glfw_platform()
  p.initialize(default_window_options_for_test())
  p.poll_events()

  let outside = p.outside_size()
  assert_eq(outside.width.to_int(), 320)
  assert_eq(outside.height.to_int(), 240)

  let input = p.capture_input(1)
  assert_eq(input.pressed_keys.length(), 0)

  let monitor = p.monitor_info()
  assert_true(monitor.device_scale_factor >= 1.0)
}

///|
test "web platform stub has surface token" {
  let p = create_web_canvas_platform("#app")
  p.initialize(default_window_options_for_test())
  p.poll_events()

  let token = p.current_surface()
  assert_eq(token.width, 320)
  assert_eq(token.height, 240)
}
