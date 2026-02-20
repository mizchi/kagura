///|
/// Runtime integration helpers for AI tick execution.

///|
/// Configuration for AI runtime behavior.
pub struct AIRuntimeConfig {
  mut enabled : Bool
  mut global_budget : AIBudget?
  mut base_seed : Int
  mut trace_enabled : Bool
  max_trace_history : Int
} derive(Show)

///|
pub fn default_ai_runtime_config() -> AIRuntimeConfig {
  {
    enabled: true,
    global_budget: None,
    base_seed: 42,
    trace_enabled: false,
    max_trace_history: 64,
  }
}

///|
pub struct AIRuntimeState {
  mut blackboard : BlackboardSnapshot
  mut traces : Array[Array[DecisionTrace]]
  mut tick_traces : Map[Int, Array[DecisionTrace]]
  mut total_decisions : Int
  mut total_ticks : Int
  mut last_tick_decision_count : Int
  config : AIRuntimeConfig
}

///|
pub fn AIRuntimeState::new() -> AIRuntimeState {
  {
    blackboard: { entries: [] },
    traces: [],
    tick_traces: {},
    total_decisions: 0,
    total_ticks: 0,
    last_tick_decision_count: 0,
    config: default_ai_runtime_config(),
  }
}

///|
pub fn AIRuntimeState::new_with_config(
  config : AIRuntimeConfig,
) -> AIRuntimeState {
  {
    blackboard: { entries: [] },
    traces: [],
    tick_traces: {},
    total_decisions: 0,
    total_ticks: 0,
    last_tick_decision_count: 0,
    config,
  }
}

///|
pub fn AIRuntimeState::new_with_blackboard(
  blackboard : BlackboardSnapshot,
) -> AIRuntimeState {
  {
    blackboard,
    traces: [],
    tick_traces: {},
    total_decisions: 0,
    total_ticks: 0,
    last_tick_decision_count: 0,
    config: default_ai_runtime_config(),
  }
}

///|
pub fn AIRuntimeState::current_blackboard(
  self : AIRuntimeState,
) -> BlackboardSnapshot {
  self.blackboard
}

///|
pub fn AIRuntimeState::total_decisions(self : AIRuntimeState) -> Int {
  self.total_decisions
}

///|
pub fn AIRuntimeState::total_ticks(self : AIRuntimeState) -> Int {
  self.total_ticks
}

///|
pub fn AIRuntimeState::last_tick_decision_count(self : AIRuntimeState) -> Int {
  self.last_tick_decision_count
}

///|
pub fn AIRuntimeState::trace_count(self : AIRuntimeState) -> Int {
  self.traces.length()
}

///|
pub fn AIRuntimeState::clear_traces(self : AIRuntimeState) -> Unit {
  self.traces = []
  self.tick_traces = {}
}

///|
pub fn AIRuntimeState::get_config(self : AIRuntimeState) -> AIRuntimeConfig {
  self.config
}

///|
pub fn AIRuntimeState::set_enabled(self : AIRuntimeState, v : Bool) -> Unit {
  self.config.enabled = v
}

///|
pub fn AIRuntimeState::set_budget(
  self : AIRuntimeState,
  budget : AIBudget,
) -> Unit {
  self.config.global_budget = Some(budget)
}

///|
pub fn AIRuntimeState::clear_budget_override(self : AIRuntimeState) -> Unit {
  self.config.global_budget = None
}

///|
pub fn AIRuntimeState::set_seed(self : AIRuntimeState, seed : Int) -> Unit {
  self.config.base_seed = seed
}

///|
pub fn AIRuntimeState::set_trace_enabled(
  self : AIRuntimeState,
  v : Bool,
) -> Unit {
  self.config.trace_enabled = v
}

///|
/// Get traces collected for a specific tick.
pub fn AIRuntimeState::get_traces_for_tick(
  self : AIRuntimeState,
  tick : Int,
) -> Array[DecisionTrace] {
  match self.tick_traces.get(tick) {
    Some(traces) => traces
    None => []
  }
}

///|
/// Get the most recent N tick traces (newest first).
pub fn AIRuntimeState::get_recent_trace_ticks(
  self : AIRuntimeState,
  count : Int,
) -> Array[Int] {
  let ticks : Array[Int] = []
  self.tick_traces.each(fn(k, _v) { ticks.push(k) })
  // Sort descending (newest first)
  ticks.sort_by(fn(a, b) { b - a })
  let n = if count < ticks.length() { count } else { ticks.length() }
  let result : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    result.push(ticks[i])
  }
  result
}

///|
/// Create an on_post_update callback for RuntimeHooks that runs AI tick.
pub fn[P : AIPolicy, S : SensorBridge, A : ActuatorBridge, C : AIScheduler] create_ai_post_update_hook(
  policy : P,
  sensors : S,
  actuator : A,
  scheduler : C,
  state : AIRuntimeState,
) -> (Int, @core.FrameBudget) -> Unit {
  fn(tick : Int, frame : @core.FrameBudget) {
    if not(state.config.enabled) {
      return
    }
    let seed = state.config.base_seed + tick
    let agents = scheduler.select_agents(tick) catch { _ => [] }
    let mut current_bb = state.blackboard
    let mut decision_count = 0
    let tick_traces : Array[DecisionTrace] = []
    for agent_id in agents {
      let sensor_snapshot = sensors.capture(agent_id, tick) catch {
        _ => continue
      }
      let budget = match state.config.global_budget {
        Some(b) => b
        None =>
          scheduler.budget_for(agent_id) catch {
            _ => default_ai_budget()
          }
      }
      let decision = policy.decide({
        tick,
        frame,
        deterministic_seed: seed + decision_count,
        budget,
        perception: sensor_snapshot,
        blackboard: current_bb,
      }) catch {
        _ => continue
      }
      actuator.apply(agent_id, decision.actions) catch {
        _ => ()
      }
      current_bb = decision.next_blackboard
      if state.config.trace_enabled {
        for t in decision.trace {
          tick_traces.push(t)
        }
      }
      decision_count = decision_count + 1
    }
    state.blackboard = current_bb
    state.total_decisions = state.total_decisions + decision_count
    state.last_tick_decision_count = decision_count
    state.total_ticks = state.total_ticks + 1
    // Store traces if enabled
    if state.config.trace_enabled && tick_traces.length() > 0 {
      state.traces.push(tick_traces)
      state.tick_traces.set(tick, tick_traces)
      // Trim trace history if needed
      while state.traces.length() > state.config.max_trace_history {
        let _ = state.traces.remove(0)
      }
    }
  }
}
