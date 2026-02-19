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
pub fn[G : @core.Game, P : @platform.PlatformDriver, R : @gfx.GraphicsDriver] run_loop(
  game : G,
  platform : P,
  graphics : R,
  options : RunOptions,
) -> Unit raise {
  let runtime_config = @runtime.default_runtime_config()
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
