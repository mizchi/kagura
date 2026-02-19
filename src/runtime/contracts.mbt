///|
/// Runtime orchestration contracts.
/// Ebiten refs:
/// - internal/ui/run.go
/// - internal/ui/context.go
/// - gameforui.go

///|
pub struct RuntimeConfig {
  max_skip_frames : Int
  enable_vsync : Bool
  clear_screen_every_frame : Bool
} derive(Show)

///|
pub struct FramePlan {
  updates : Int
  should_draw : Bool
} derive(Show)

///|
pub fn default_runtime_config() -> RuntimeConfig {
  { max_skip_frames: 5, enable_vsync: true, clear_screen_every_frame: true }
}

///|
pub fn plan_frame(fixed : @core.StepResult, max_skip_frames : Int) -> FramePlan {
  let cap = if max_skip_frames <= 0 { 1 } else { max_skip_frames }
  let updates = if fixed.updates > cap { cap } else { fixed.updates }
  let should_draw = updates > 0 || fixed.alpha > 0.0
  { updates, should_draw }
}

///|
pub fn[G : @core.Game, P : @platform.PlatformDriver, R : @gfx.GraphicsDriver] run_loop(
  game : G,
  platform : P,
  graphics : R,
  run_options : @core.RunOptions,
  runtime_config : RuntimeConfig,
) -> Unit raise {
  let _ = run_options.init_unfocused
  let _ = run_options.screen_cleared_every_frame
  let _ = runtime_config.enable_vsync
  let fixed_cfg = @core.default_fixed_step_config()
  let mut fixed_state = @core.initial_fixed_step_state()
  let mut should_stop = false

  let window_options = @platform.new_window_options(
    "game_engine",
    800,
    600,
    run_options.screen_transparent,
    true,
  )
  platform.initialize(window_options)
  graphics.initialize()

  while !platform.should_close() && !should_stop {
    platform.poll_events()

    let outside = platform.outside_size()
    let _ = game.layout(outside)

    let step = @core.step_fixed_timestep(fixed_state, 16.6667, fixed_cfg)
    fixed_state = step.next_state
    let frame_plan = plan_frame(step, runtime_config.max_skip_frames)

    for _ in 0..<frame_plan.updates {
      let input = platform.capture_input(fixed_state.tick)
      match game.update(input) {
        Some(@core.EngineTermination::RegularTermination) => should_stop = true
        Some(@core.EngineTermination::Fatal(_)) => should_stop = true
        None => ()
      }
    }

    if frame_plan.should_draw {
      let pass = @gfx.new_render_pass_desc(
        @gfx.new_color(0.0, 0.0, 0.0, 1.0),
        runtime_config.clear_screen_every_frame,
      )
      graphics.begin(pass)
      game.draw(
        @core.new_frame_budget(frame_plan.updates, step.alpha, fixed_state.tick),
      )
      graphics.end(true)
    }
  }
}
