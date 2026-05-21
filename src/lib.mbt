///|
/// Public facade (contracts only, no implementation yet).
/// Ebiten refs:
/// - run.go
/// - internal/ui/context.go
/// - internal/graphicsdriver/graphics.go

///|
pub type FixedStepConfig = @core.FixedStepConfig

///|
pub type FixedStepState = @core.FixedStepState

///|
pub type StepResult = @core.StepResult

///|
pub type RunOptions = @core.RunOptions

///|
pub type EngineTermination = @core.EngineTermination

///|
pub type WindowOptions = @platform.WindowOptions

///|
pub type RenderPassDesc = @gfx.RenderPassDesc

///|
pub fn default_fixed_step_config() -> FixedStepConfig {
  @core.default_fixed_step_config()
}

///|
pub fn new_fixed_step_config(
  tps : Int,
  max_updates_per_frame : Int,
) -> FixedStepConfig {
  @core.new_fixed_step_config(tps, max_updates_per_frame)
}

///|
pub fn initial_fixed_step_state() -> FixedStepState {
  @core.initial_fixed_step_state()
}

///|
pub fn[G : @core.Game, P : @platform.PlatformDriver, R : @gfx.GraphicsDriver] run_loop(
  game : G,
  platform : P,
  graphics : R,
  options : RunOptions,
) -> Unit raise {
  let runtime_config = @runtime.new_runtime_config(
    clear_screen_every_frame=options.screen_cleared_every_frame,
  )
  @runtime.run_loop(game, platform, graphics, options, runtime_config)
}

///|
pub fn plan_fixed_updates(
  state : FixedStepState,
  elapsed_ms : Double,
  config : FixedStepConfig,
) -> StepResult {
  @core.step_fixed_timestep(state, elapsed_ms, config)
}

///|
pub fn step_result_updates(result : StepResult) -> Int {
  result.updates
}

///|
pub fn step_result_alpha(result : StepResult) -> Double {
  result.alpha
}

///|
pub fn step_result_next_state(result : StepResult) -> FixedStepState {
  result.next_state
}
