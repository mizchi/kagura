///|
fn[P : @platform.PlatformDriver + @gfx.SurfaceProvider] check_lifecycle(
  driver : P,
) -> Unit raise {
  let options = @platform.new_window_options("contract", 640, 360, false, true)
  @platform.PlatformDriver::initialize(driver, options)
  assert_false(@platform.PlatformDriver::should_close(driver))
  assert_eq(@platform.PlatformDriver::outside_size(driver).width, 640.0)
  assert_eq(@gfx.SurfaceProvider::current_surface(driver).width, 640)
  @platform.PlatformDriver::close_window(driver)
  assert_true(@platform.PlatformDriver::should_close(driver))
  @platform.PlatformDriver::initialize(driver, options)
  assert_false(@platform.PlatformDriver::should_close(driver))
  @platform.PlatformDriver::set_cursor_mode(
    driver,
    @platform.cursor_mode_from_int(1),
  )
  inspect(@platform.PlatformDriver::cursor_mode(driver), content="Hidden")
}

///|
test "JS adapter satisfies the shared platform and surface contracts" {
  @mizchi/kagura_platform_js.uninstall()
  check_lifecycle(@mizchi/kagura_platform_js.create_platform("#contract"))
}

///|
test "native shell satisfies the same platform and surface contracts" {
  @platform.reset_desktop_native_hooks()
  check_lifecycle(@platform.create_desktop_glfw_platform())
}

///|
test "JS installation connects the shared shell and uninstall restores fallback" {
  let initialized = Ref("")
  let polls = Ref(0)
  let captured_tick = Ref(-1)
  // The engine may create its shell before the host installs its hooks.
  let driver = @platform.create_web_canvas_platform("#host")
  @mizchi/kagura_platform_js.install(
    @platform.new_web_canvas_hooks(
      fn(selector, _options) {
        initialized.val = selector
        true
      },
      fn(active) { if active { polls.val += 1 } },
      fn() { false },
      fn(_width, _height) { @core.new_outside_size(960.0, 540.0) },
      fn(_selector, _options) {
        @gfx.create_webgpu_surface_token(42, 960, 540, 1.0)
      },
      fn(_active, tick) {
        captured_tick.val = tick
        @core.empty_input_snapshot()
      },
      fn(_s, _a, enabled) { enabled },
      fn(_s, _a, current) { current },
      fn(_s, _a, mode) { mode },
      fn(_s, _a, current) { current },
      fn(_s, _a, scale) { scale },
      fn(_s, _a, current) { current },
      fn(_s, _a, enabled) { enabled },
      fn(_s, _a, current) { current },
      fn(_s, _a) { () },
      fn(_s, _a) { () },
      fn(_s, _a, _e) { () },
      fn(_s, _a) { false },
      fn(_s, _a, current) { current },
      fn(_s, _a, current) { current },
    ),
  )
  let options = @platform.new_window_options("host", 640, 360, false, true)
  driver.initialize(options)
  driver.poll_events()
  let _ = driver.capture_input(17)
  assert_eq(initialized.val, "#host")
  assert_eq(polls.val, 1)
  assert_eq(captured_tick.val, 17)
  assert_eq(driver.outside_size().width, 960.0)
  assert_eq(driver.current_surface().opaque_id, 42)
  @mizchi/kagura_platform_js.uninstall()
  let fallback = @mizchi/kagura_platform_js.create_platform("#fallback")
  fallback.initialize(options)
  fallback.poll_events()
  assert_eq(fallback.outside_size().width, 640.0)
  assert_eq(polls.val, 1)
  assert_eq(initialized.val, "#host")
}
