///|
/// Fixed-step simulation contract.
/// Ebiten refs:
/// - internal/clock/clock.go
/// - internal/ui/context.go (updateFrameImpl / update count handling)
pub struct FixedStepConfig {
  tps : Int
  max_updates_per_frame : Int
} derive(Show)

///|
/// Scheduler state carried between frames.
/// Ebiten refs:
/// - internal/ui/context.go (tick progression and frame accumulator semantics)
pub struct FixedStepState {
  accumulator_ms : Double
  tick : Int
} derive(Show)

///|
/// Planned updates for one rendered frame.
/// Ebiten refs:
/// - run.go (Update / Draw separation)
/// - internal/ui/context.go (skip / interpolation flow)
pub struct StepResult {
  updates : Int
  alpha : Double
  next_state : FixedStepState
} derive(Show)

///|
pub fn default_fixed_step_config() -> FixedStepConfig {
  { tps: 60, max_updates_per_frame: 5 }
}

///|
pub fn new_fixed_step_config(
  tps : Int,
  max_updates_per_frame : Int,
) -> FixedStepConfig {
  { tps, max_updates_per_frame }
}

///|
pub fn initial_fixed_step_state() -> FixedStepState {
  { accumulator_ms: 0.0, tick: 0 }
}

///|
fn safe_tps(config : FixedStepConfig) -> Int {
  if config.tps <= 0 {
    60
  } else {
    config.tps
  }
}

///|
fn safe_max_updates(config : FixedStepConfig) -> Int {
  if config.max_updates_per_frame <= 0 {
    1
  } else {
    config.max_updates_per_frame
  }
}

///|
pub fn step_fixed_timestep(
  state : FixedStepState,
  elapsed_ms : Double,
  config : FixedStepConfig,
) -> StepResult {
  let tps = safe_tps(config)
  let max_updates = safe_max_updates(config)
  let tick_ms = 1000.0 / tps.to_double()

  let normalized_elapsed = if elapsed_ms < 0.0 { 0.0 } else { elapsed_ms }
  let mut accumulator = state.accumulator_ms + normalized_elapsed

  let mut updates = 0
  while accumulator >= tick_ms && updates < max_updates {
    accumulator = accumulator - tick_ms
    updates = updates + 1
  }

  // Spiral-of-death protection: drop remaining backlog once capped.
  if updates == max_updates && accumulator >= tick_ms {
    accumulator = 0.0
  }

  {
    updates,
    alpha: accumulator / tick_ms,
    next_state: { accumulator_ms: accumulator, tick: state.tick + updates },
  }
}
