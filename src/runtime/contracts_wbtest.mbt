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
}
