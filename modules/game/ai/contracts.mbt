///|
/// AI module contracts.
///
/// Game-engine extension (Ebiten has no built-in AI module):
/// - deterministic per-tick decision pipeline
/// - clear boundary between sensing, policy, and actuation

///|
pub struct AgentId {
  value : Int
} derive(Debug)

///|
pub impl Show for AgentId with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct BlackboardEntry {
  key : String
  value : String
} derive(Debug)

///|
pub impl Show for BlackboardEntry with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct BlackboardSnapshot {
  entries : Array[BlackboardEntry]
} derive(Debug)

///|
pub impl Show for BlackboardSnapshot with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct SensorSnapshot {
  self_x : Double
  self_y : Double
  health : Double
  visible_entities : Array[Int]
  tags : Array[String]
} derive(Debug)

///|
pub impl Show for SensorSnapshot with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub enum ActionIntent {
  Idle
  Move(Double, Double)
  Aim(Double, Double)
  Trigger(String)
  EmitEvent(String)
} derive(Debug)

///|
pub impl Show for ActionIntent with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct DecisionTrace {
  stage : String
  score : Double
  note : String
} derive(Debug)

///|
pub impl Show for DecisionTrace with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct AIBudget {
  max_decision_ms : Int
  max_nodes : Int
  max_model_tokens : Int
} derive(Debug)

///|
pub impl Show for AIBudget with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct DecisionContext {
  tick : Int
  frame : @core.FrameBudget
  deterministic_seed : Int
  budget : AIBudget
  perception : SensorSnapshot
  blackboard : BlackboardSnapshot
} derive(Debug)

///|
pub impl Show for DecisionContext with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub struct DecisionResult {
  actions : Array[ActionIntent]
  next_blackboard : BlackboardSnapshot
  trace : Array[DecisionTrace]
} derive(Debug)

///|
pub impl Show for DecisionResult with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub trait SensorBridge {
  fn capture(Self, agent_id : AgentId, tick : Int) -> SensorSnapshot
}

///|
pub trait ActuatorBridge {
  fn apply(Self, agent_id : AgentId, actions : Array[ActionIntent]) -> Unit raise
}

///|
pub trait AIScheduler {
  fn select_agents(Self, tick : Int) -> Array[AgentId]
  fn budget_for(Self, agent_id : AgentId) -> AIBudget
}

///|
pub trait AIPolicy {
  fn decide(Self, context : DecisionContext) -> DecisionResult raise
}

///|
pub fn default_ai_budget() -> AIBudget {
  { max_decision_ms: 2, max_nodes: 128, max_model_tokens: 64 }
}

///|
pub fn[P : AIPolicy, S : SensorBridge, A : ActuatorBridge, C : AIScheduler] run_ai_tick(
  policy : P,
  sensors : S,
  actuator : A,
  scheduler : C,
  frame : @core.FrameBudget,
  tick : Int,
  blackboard : BlackboardSnapshot,
) -> BlackboardSnapshot raise {
  let mut current_blackboard = blackboard
  let agents = scheduler.select_agents(tick)
  let mut seed = tick

  for agent_id in agents {
    let sensor_snapshot = sensors.capture(agent_id, tick)
    let budget = scheduler.budget_for(agent_id)
    let decision = policy.decide({
      tick,
      frame,
      deterministic_seed: seed,
      budget,
      perception: sensor_snapshot,
      blackboard: current_blackboard,
    })
    actuator.apply(agent_id, decision.actions)
    current_blackboard = decision.next_blackboard
    seed = seed + 1
  }

  current_blackboard
}

///|
pub extend AgentId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AgentId with Show::{to_string, output}

///|
pub extend BlackboardEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BlackboardEntry with Show::{to_string, output}

///|
pub extend BlackboardSnapshot with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BlackboardSnapshot with Show::{to_string, output}

///|
pub extend SensorSnapshot with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SensorSnapshot with Show::{to_string, output}

///|
pub extend ActionIntent with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ActionIntent with Show::{to_string, output}

///|
pub extend DecisionTrace with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DecisionTrace with Show::{to_string, output}

///|
pub extend AIBudget with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AIBudget with Show::{to_string, output}

///|
pub extend DecisionContext with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DecisionContext with Show::{to_string, output}

///|
pub extend DecisionResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DecisionResult with Show::{to_string, output}
