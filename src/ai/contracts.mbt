///|
/// AI module contracts.
///
/// Game-engine extension (Ebiten has no built-in AI module):
/// - deterministic per-tick decision pipeline
/// - clear boundary between sensing, policy, and actuation

///|
pub struct AgentId {
  value : Int
} derive(Show)

///|
pub struct BlackboardEntry {
  key : String
  value : String
} derive(Show)

///|
pub struct BlackboardSnapshot {
  entries : Array[BlackboardEntry]
} derive(Show)

///|
pub struct SensorSnapshot {
  self_x : Double
  self_y : Double
  health : Double
  visible_entities : Array[Int]
  tags : Array[String]
} derive(Show)

///|
pub enum ActionIntent {
  Idle
  Move(Double, Double)
  Aim(Double, Double)
  Trigger(String)
  EmitEvent(String)
} derive(Show)

///|
pub struct DecisionTrace {
  stage : String
  score : Double
  note : String
} derive(Show)

///|
pub struct AIBudget {
  max_decision_ms : Int
  max_nodes : Int
  max_model_tokens : Int
} derive(Show)

///|
pub struct DecisionContext {
  tick : Int
  frame : @core.FrameBudget
  deterministic_seed : Int
  budget : AIBudget
  perception : SensorSnapshot
  blackboard : BlackboardSnapshot
} derive(Show)

///|
pub struct DecisionResult {
  actions : Array[ActionIntent]
  next_blackboard : BlackboardSnapshot
  trace : Array[DecisionTrace]
} derive(Show)

///|
pub trait SensorBridge {
  capture(Self, agent_id : AgentId, tick : Int) -> SensorSnapshot
}

///|
pub trait ActuatorBridge {
  apply(Self, agent_id : AgentId, actions : Array[ActionIntent]) -> Unit raise
}

///|
pub trait AIScheduler {
  select_agents(Self, tick : Int) -> Array[AgentId]
  budget_for(Self, agent_id : AgentId) -> AIBudget
}

///|
pub trait AIPolicy {
  decide(Self, context : DecisionContext) -> DecisionResult raise
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
