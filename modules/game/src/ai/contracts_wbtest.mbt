///|
struct TestSensor {
  id : Int
}

///|
pub impl SensorBridge for TestSensor with capture(self, agent_id, tick) {
  let _ = self.id
  {
    self_x: agent_id.value.to_double(),
    self_y: tick.to_double(),
    health: 100.0,
    visible_entities: [agent_id.value + 1],
    tags: ["enemy"],
  }
}

///|
struct TestActuator {
  mut applied : Int
}

///|
pub impl ActuatorBridge for TestActuator with apply(self, _agent_id, actions) {
  self.applied = self.applied + actions.length()
}

///|
struct TestScheduler {
  id : Int
}

///|
pub impl AIScheduler for TestScheduler with select_agents(self, tick) {
  let _ = self.id
  if tick % 2 == 0 {
    [{ value: 1 }, { value: 2 }]
  } else {
    [{ value: 1 }]
  }
}

///|
pub impl AIScheduler for TestScheduler with budget_for(_self, _agent_id) {
  default_ai_budget()
}

///|
struct TestPolicy {
  id : Int
}

///|
pub impl AIPolicy for TestPolicy with decide(self, context) {
  let _ = self.id
  let entries = context.blackboard.entries
  entries.push({ key: "last_tick", value: context.tick.to_string() })
  {
    actions: [
      ActionIntent::Move(context.perception.self_x, context.perception.self_y),
    ],
    next_blackboard: { entries, },
    trace: [{ stage: "test", score: 1.0, note: "ok" }],
  }
}

///|
test "run_ai_tick updates blackboard and applies actions" {
  let sensor : TestSensor = { id: 0 }
  let actuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }

  let frame = @core.new_frame_budget(1, 0.0, 10)
  let blackboard : BlackboardSnapshot = { entries: [] }
  let next = run_ai_tick(
    policy, sensor, actuator, scheduler, frame, 10, blackboard,
  )

  assert_eq(next.entries.length(), 2)
  assert_eq(actuator.applied, 2)
}

///|
test "AIRuntimeState tracks decisions" {
  let state = AIRuntimeState::new()
  assert_eq(state.total_decisions(), 0)
  assert_eq(state.trace_count(), 0)

  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let hook = create_ai_post_update_hook(
    policy, sensor, actuator, scheduler, state,
  )

  // Tick 10 (even): scheduler returns 2 agents → 2 decisions
  let frame = @core.new_frame_budget(1, 0.0, 10)
  hook(10, frame)
  assert_eq(state.total_decisions(), 2)
  assert_eq(state.last_tick_decision_count(), 2)
  assert_eq(state.total_ticks(), 1)

  // Tick 11 (odd): scheduler returns 1 agent → 1 decision
  let frame2 = @core.new_frame_budget(1, 0.0, 11)
  hook(11, frame2)
  assert_eq(state.total_decisions(), 3)
  assert_eq(state.last_tick_decision_count(), 1)
  assert_eq(state.total_ticks(), 2)
  // Blackboard should have accumulated entries
  assert_true(state.current_blackboard().entries.length() > 0)
}

///|
test "AIRuntimeState with initial blackboard" {
  let initial : BlackboardSnapshot = {
    entries: [{ key: "init", value: "yes" }],
  }
  let state = AIRuntimeState::new_with_blackboard(initial)
  assert_eq(state.current_blackboard().entries.length(), 1)
  assert_eq(state.current_blackboard().entries[0].key, "init")
}

///|
test "AIRuntimeState clear_traces" {
  let state = AIRuntimeState::new()
  state.traces.push([{ stage: "test", score: 1.0, note: "ok" }])
  assert_eq(state.trace_count(), 1)
  state.clear_traces()
  assert_eq(state.trace_count(), 0)
}

///|
test "AIRuntimeState disabled skips tick" {
  let state = AIRuntimeState::new()
  state.set_enabled(false)

  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let hook = create_ai_post_update_hook(
    policy, sensor, actuator, scheduler, state,
  )

  let frame = @core.new_frame_budget(1, 0.0, 10)
  hook(10, frame)
  assert_eq(state.total_decisions(), 0)
  assert_eq(state.total_ticks(), 0)
  assert_eq(actuator.applied, 0)
}

///|
test "AIRuntimeState global budget override" {
  let config : AIRuntimeConfig = {
    ..default_ai_runtime_config(),
    global_budget: Some({
      max_decision_ms: 1,
      max_nodes: 10,
      max_model_tokens: 8,
    }),
  }
  let state = AIRuntimeState::new_with_config(config)
  assert_true(state.get_config().global_budget is Some(_))

  state.clear_budget_override()
  assert_true(state.get_config().global_budget is None)
}

///|
test "AIRuntimeState trace collection" {
  let config : AIRuntimeConfig = {
    ..default_ai_runtime_config(),
    trace_enabled: true,
  }
  let state = AIRuntimeState::new_with_config(config)

  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let hook = create_ai_post_update_hook(
    policy, sensor, actuator, scheduler, state,
  )

  let frame = @core.new_frame_budget(1, 0.0, 10)
  hook(10, frame)
  // Trace enabled: should have captured traces
  assert_eq(state.trace_count(), 1)
  let tick_traces = state.get_traces_for_tick(10)
  assert_true(tick_traces.length() > 0)
  assert_eq(tick_traces[0].stage, "test")
}

///|
test "AIRuntimeState recent trace ticks" {
  let config : AIRuntimeConfig = {
    ..default_ai_runtime_config(),
    trace_enabled: true,
  }
  let state = AIRuntimeState::new_with_config(config)

  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let hook = create_ai_post_update_hook(
    policy, sensor, actuator, scheduler, state,
  )

  // Run 3 ticks
  hook(10, @core.new_frame_budget(1, 0.0, 10))
  hook(11, @core.new_frame_budget(1, 0.0, 11))
  hook(12, @core.new_frame_budget(1, 0.0, 12))

  let recent = state.get_recent_trace_ticks(2)
  assert_eq(recent.length(), 2)
  // Newest first
  assert_eq(recent[0], 12)
  assert_eq(recent[1], 11)
}

///|
test "AIRuntimeState seed configuration" {
  let state = AIRuntimeState::new()
  assert_eq(state.get_config().base_seed, 42)
  state.set_seed(100)
  assert_eq(state.get_config().base_seed, 100)
}

///|
test "blackboard persists across agents within same tick" {
  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let frame = @core.new_frame_budget(1, 0.0, 10)
  let blackboard : BlackboardSnapshot = {
    entries: [{ key: "initial", value: "true" }],
  }
  // Even tick: 2 agents, each appends "last_tick" entry
  let result = run_ai_tick(
    policy, sensor, actuator, scheduler, frame, 10, blackboard,
  )
  // 1 initial + 2 appended by each agent
  assert_eq(result.entries.length(), 3)
  assert_eq(result.entries[0].key, "initial")
  assert_eq(result.entries[1].key, "last_tick")
  assert_eq(result.entries[2].key, "last_tick")
}

///|
test "odd tick runs single agent" {
  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let frame = @core.new_frame_budget(1, 0.0, 11)
  let blackboard : BlackboardSnapshot = { entries: [] }
  // Odd tick: 1 agent
  let result = run_ai_tick(
    policy, sensor, actuator, scheduler, frame, 11, blackboard,
  )
  assert_eq(result.entries.length(), 1)
  assert_eq(actuator.applied, 1)
}

///|
test "default_ai_budget has expected values" {
  let budget = default_ai_budget()
  assert_eq(budget.max_decision_ms, 2)
  assert_eq(budget.max_nodes, 128)
  assert_eq(budget.max_model_tokens, 64)
}

///|
test "default_ai_runtime_config has expected defaults" {
  let config = default_ai_runtime_config()
  assert_eq(config.enabled, true)
  assert_true(config.global_budget is None)
  assert_eq(config.base_seed, 42)
  assert_eq(config.trace_enabled, false)
  assert_eq(config.max_trace_history, 64)
}

///|
test "AIRuntimeState re-enable after disable resumes ticking" {
  let state = AIRuntimeState::new()
  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let hook = create_ai_post_update_hook(
    policy, sensor, actuator, scheduler, state,
  )
  state.set_enabled(false)
  hook(10, @core.new_frame_budget(1, 0.0, 10))
  assert_eq(state.total_ticks(), 0)
  state.set_enabled(true)
  hook(11, @core.new_frame_budget(1, 0.0, 11))
  assert_eq(state.total_ticks(), 1)
  assert_true(state.total_decisions() > 0)
}

///|
test "AIRuntimeState set_budget overrides scheduler budget" {
  let state = AIRuntimeState::new()
  let custom_budget : AIBudget = {
    max_decision_ms: 99,
    max_nodes: 999,
    max_model_tokens: 9999,
  }
  state.set_budget(custom_budget)
  match state.get_config().global_budget {
    Some(b) => {
      assert_eq(b.max_decision_ms, 99)
      assert_eq(b.max_nodes, 999)
      assert_eq(b.max_model_tokens, 9999)
    }
    None => panic()
  }
}

///|
test "AIRuntimeState set_trace_enabled toggles trace collection" {
  let state = AIRuntimeState::new()
  assert_eq(state.get_config().trace_enabled, false)
  state.set_trace_enabled(true)
  assert_eq(state.get_config().trace_enabled, true)
  state.set_trace_enabled(false)
  assert_eq(state.get_config().trace_enabled, false)
}

///|
test "AIRuntimeState get_traces_for_tick returns empty for unknown tick" {
  let state = AIRuntimeState::new()
  let traces = state.get_traces_for_tick(999)
  assert_eq(traces.length(), 0)
}

///|
test "AIRuntimeState trace history trimming" {
  let config : AIRuntimeConfig = {
    ..default_ai_runtime_config(),
    trace_enabled: true,
    max_trace_history: 2,
  }
  let state = AIRuntimeState::new_with_config(config)

  let sensor : TestSensor = { id: 0 }
  let actuator : TestActuator = { applied: 0 }
  let scheduler : TestScheduler = { id: 0 }
  let policy : TestPolicy = { id: 0 }
  let hook = create_ai_post_update_hook(
    policy, sensor, actuator, scheduler, state,
  )

  // Run 4 ticks, but max_trace_history is 2
  hook(10, @core.new_frame_budget(1, 0.0, 10))
  hook(11, @core.new_frame_budget(1, 0.0, 11))
  hook(12, @core.new_frame_budget(1, 0.0, 12))
  hook(13, @core.new_frame_budget(1, 0.0, 13))
  // Only 2 most recent should remain in traces array
  assert_true(state.trace_count() <= 2)
}
