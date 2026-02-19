///|
fn install_test_web_hooks() -> Unit {
  @platform.set_web_canvas_hooks(
    @platform.new_web_canvas_hooks(
      fn(_canvas_selector, _options) { true },
      fn(_active) { () },
      fn() { false },
      fn(width, height) {
        @core.new_outside_size(width.to_double(), height.to_double())
      },
      fn(_canvas_selector, options) {
        @platform.create_webgpu_surface_token(
          77,
          options.width,
          options.height,
          1.0,
        )
      },
      fn(_active, _tick) { @core.empty_input_snapshot() },
      fn(_canvas_selector, _active, enabled) { enabled },
      fn(_canvas_selector, _active, current) { current },
      fn(_canvas_selector, _active, mode) { mode },
      fn(_canvas_selector, _active, current) { current },
      fn(_canvas_selector, _active, scale) { scale },
      fn(_canvas_selector, _active, current) { current },
      fn(_canvas_selector, _active, enabled) { enabled },
      fn(_canvas_selector, _active, current) { current },
      fn(_canvas_selector, _active) { () },
      fn(_canvas_selector, _active) { () },
    ),
  )
  @gfx.set_web_graphics_hooks(
    @gfx.new_web_graphics_hooks(
      fn(_kind, _width, _height) { true },
      fn(_active, _kind, _pass) { () },
      fn(_active, _kind, _present) { () },
      fn(_active, _kind, _command) { () },
    ),
  )
}

///|
fn reset_test_web_hooks() -> Unit {
  @gfx.reset_web_graphics_hooks()
  @platform.reset_web_canvas_hooks()
}

///|
fn install_test_native_hooks() -> Unit {
  @platform.set_desktop_native_hooks(
    @platform.new_desktop_native_hooks(
      fn(_options) { true },
      fn(_active) { () },
      fn() { false },
      fn(width, height) {
        @core.new_outside_size(width.to_double(), height.to_double())
      },
      fn(_active, _tick) { @core.empty_input_snapshot() },
      fn(_active, enabled) { enabled },
      fn(_active, current) { current },
      fn(_active, mode) { mode },
      fn(_active, current) { current },
      fn(_active, scale) { scale },
      fn(_active, current) { current },
      fn(_active, enabled) { enabled },
      fn(_active, current) { current },
      fn(_active) { () },
      fn(_active) { () },
    ),
  )
  @gfx.set_native_graphics_hooks(
    @gfx.new_native_graphics_hooks(
      fn(_width, _height) { true },
      fn(_active, _pass) { () },
      fn(_active, _present) { () },
      fn(_active, _command) { () },
    ),
  )
}

///|
fn reset_test_native_hooks() -> Unit {
  @gfx.reset_native_graphics_hooks()
  @platform.reset_desktop_native_hooks()
}

///|
fn run_counting_game_with_webgpu() -> (Int, Int) raise {
  install_test_web_hooks()
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let gfx_options = @gfx.default_graphics_backend_options()
  let graphics = @gfx.create_webgpu_graphics(surface, gfx_options)
  let options = @core.default_run_options()
  let runtime_config = {
    max_skip_frames: 2,
    enable_vsync: false,
    clear_screen_every_frame: true,
  }
  run_loop(game, platform, graphics, options, runtime_config)
  let result = (graphics.begin_count, graphics.end_count)
  reset_test_web_hooks()
  result
}

///|
fn run_counting_game_with_webgl() -> (Int, Int) raise {
  install_test_web_hooks()
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let gfx_options = @gfx.default_graphics_backend_options()
  let graphics = @gfx.create_webgl_graphics(surface, gfx_options)
  let options = @core.default_run_options()
  let runtime_config = {
    max_skip_frames: 2,
    enable_vsync: false,
    clear_screen_every_frame: true,
  }
  run_loop(game, platform, graphics, options, runtime_config)
  let result = (graphics.begin_count, graphics.end_count)
  reset_test_web_hooks()
  result
}

///|
fn run_counting_game_with_native() -> (Int, Int) raise {
  install_test_native_hooks()
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_desktop_glfw_platform()
  let surface = platform.current_surface()
  let gfx_options = @gfx.default_graphics_backend_options()
  let graphics = @gfx.create_wgpu_native_graphics(surface, gfx_options)
  let options = @core.default_run_options()
  let runtime_config = {
    max_skip_frames: 2,
    enable_vsync: false,
    clear_screen_every_frame: true,
  }
  run_loop(game, platform, graphics, options, runtime_config)
  let result = (graphics.begin_count, graphics.end_count)
  reset_test_native_hooks()
  result
}

///|
test "plan_frame clamps updates by max_skip_frames" {
  let state = @core.initial_fixed_step_state()
  let cfg = @core.new_fixed_step_config(60, 8)
  let step = @core.step_fixed_timestep(state, 1000.0, cfg)
  let plan = plan_frame(step, 2)
  assert_eq(plan.updates, 2)
}

///|
test "run_loop works with noop game + stub platform/gfx" {
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let gfx_options = @gfx.default_graphics_backend_options()
  let graphics = @gfx.create_webgpu_graphics(surface, gfx_options)
  let options = @core.default_run_options()
  let runtime_config = {
    max_skip_frames: 2,
    enable_vsync: false,
    clear_screen_every_frame: true,
  }
  run_loop(game, platform, graphics, options, runtime_config)
  assert_true(!platform.is_vsync_enabled())
}

///|
test "run_loop begin/end counts match between webgpu and webgl" {
  let (webgpu_begin, webgpu_end) = run_counting_game_with_webgpu()
  let (webgl_begin, webgl_end) = run_counting_game_with_webgl()

  assert_eq(webgpu_begin, webgl_begin)
  assert_eq(webgpu_end, webgl_end)
}

///|
test "run_loop begin/end counts match between native and webgpu" {
  let (native_begin, native_end) = run_counting_game_with_native()
  let (webgpu_begin, webgpu_end) = run_counting_game_with_webgpu()

  assert_eq(native_begin, webgpu_begin)
  assert_eq(native_end, webgpu_end)
}
