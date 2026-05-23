///|
fn make_runtime_test_clock(samples : Array[Double]) -> () -> Double {
  let index : Ref[Int] = Ref::new(0)
  fn() {
    if index.val < samples.length() {
      let value = samples[index.val]
      index.val = index.val + 1
      value
    } else if samples.length() > 0 {
      samples[samples.length() - 1]
    } else {
      0.0
    }
  }
}

///|
fn install_resizing_probe_web_hooks(
  resized_widths : Ref[Array[Int]],
  resized_heights : Ref[Array[Int]],
) -> Unit {
  let poll_count : Ref[Int] = Ref::new(0)
  @platform.set_web_canvas_hooks(
    @platform.new_web_canvas_hooks(
      fn(_canvas_selector, _options) { true },
      fn(_active) { poll_count.val = poll_count.val + 1 },
      fn() { poll_count.val >= 2 },
      fn(_width, _height) {
        let size = if poll_count.val <= 1 { (320, 240) } else { (640, 360) }
        @core.new_outside_size(size.0.to_double(), size.1.to_double())
      },
      fn(_canvas_selector, options) {
        @gfx.create_webgpu_surface_token(
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
      fn(_s, _a, _e) { () },
      fn(_s, _a) { false },
      fn(_s, _a, c) { c },
      fn(_s, _a, c) { c },
    ),
  )
  @gfx.set_web_graphics_hooks(
    @gfx.new_web_graphics_hooks(
      fn(_kind, _width, _height) { true },
      fn(_active, _kind, _pass) { () },
      fn(_active, _kind, _present) { () },
      fn(_active, _kind, _command) { () },
      fn(_active, _kind, width, height) {
        resized_widths.val.push(width)
        resized_heights.val.push(height)
      },
    ),
  )
}

///|
test "run_loop uses runtime clock deltas instead of a fixed frame step" {
  install_test_web_hooks_with_tick_input(max_polls=3)
  let observed_ticks : Ref[Array[Int]] = Ref::new([])
  let hooks = new_runtime_hooks(fn(tick, _input) {
    observed_ticks.val.push(tick)
  })
  set_runtime_clock_provider(make_runtime_test_clock([0.0, 0.0, 5.0, 25.0]))
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let graphics = @gfx.create_webgpu_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  run_loop_with_hooks(
    game,
    platform,
    graphics,
    @core.default_run_options(),
    { max_skip_frames: 5, enable_vsync: false, clear_screen_every_frame: true },
    hooks,
  )
  assert_eq(observed_ticks.val.length(), 2)
  assert_true(observed_ticks.val[1] > observed_ticks.val[0])
  reset_runtime_clock_provider()
  reset_test_web_hooks()
}

///|
test "run_loop applies Game.layout logical size to graphics resize" {
  let resized_widths : Ref[Array[Int]] = Ref::new([])
  let resized_heights : Ref[Array[Int]] = Ref::new([])
  install_resizing_probe_web_hooks(resized_widths, resized_heights)
  set_runtime_clock_provider(make_runtime_test_clock([0.0, 0.0, 16.7]))
  let game = @core.new_noop_game(160, 120)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let graphics = @gfx.create_webgpu_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  run_loop(game, platform, graphics, @core.default_run_options(), {
    max_skip_frames: 5,
    enable_vsync: false,
    clear_screen_every_frame: true,
  })
  assert_eq(resized_widths.val, [160])
  assert_eq(resized_heights.val, [120])
  reset_runtime_clock_provider()
  reset_test_web_hooks()
}

///|
test "run_loop honors RunOptions.screen_cleared_every_frame" {
  install_test_web_hooks(max_polls=1)
  let clear_enabled : Ref[Array[Int]] = Ref::new([])
  @gfx.set_web_graphics_hooks(
    @gfx.new_web_graphics_hooks(
      fn(_kind, _width, _height) { true },
      fn(_active, _kind, pass) {
        clear_enabled.val.push(if pass.clear_enabled { 1 } else { 0 })
      },
      fn(_active, _kind, _present) { () },
      fn(_active, _kind, _command) { () },
      fn(_active, _kind, _width, _height) { () },
    ),
  )
  set_runtime_clock_provider(make_runtime_test_clock([0.0, 0.0]))
  let options = @core.new_run_options(screen_cleared_every_frame=false)
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let graphics = @gfx.create_webgpu_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  run_loop(game, platform, graphics, options, {
    max_skip_frames: 5,
    enable_vsync: false,
    clear_screen_every_frame: true,
  })
  assert_eq(clear_enabled.val, [0])
  reset_runtime_clock_provider()
  reset_test_web_hooks()
}

///|
test "run_loop passes init_unfocused through window options" {
  install_test_web_hooks(max_polls=1)
  set_runtime_clock_provider(make_runtime_test_clock([0.0, 0.0]))
  let options = @core.new_run_options(init_unfocused=true)
  let game = @core.new_noop_game(320, 240)
  let platform = @platform.create_web_canvas_platform("#app")
  let surface = platform.current_surface()
  let graphics = @gfx.create_webgpu_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  run_loop(game, platform, graphics, options, {
    max_skip_frames: 5,
    enable_vsync: false,
    clear_screen_every_frame: true,
  })
  assert_false(platform.options.focused)
  reset_runtime_clock_provider()
  reset_test_web_hooks()
}
