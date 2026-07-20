///|
fn make_test_state_machine() -> SpriteAnimationStateMachine {
  let idle = SpriteAnimationClip::uniform(
    "idle",
    sprite_sheet_keys("idle", 2),
    0.2,
  )
  let walk = SpriteAnimationClip::uniform(
    "walk",
    sprite_sheet_keys("walk", 4),
    0.1,
  )
  let clips : Map[String, SpriteAnimationClip] = Map([])
  clips["idle"] = idle
  clips["walk"] = walk
  let transitions = [
    { from_state: "idle", to_state: "walk", trigger: "move" },
    { from_state: "walk", to_state: "idle", trigger: "stop" },
  ]
  SpriteAnimationStateMachine::new(clips, transitions, "idle")
}

///|
test "state machine starts in initial state" {
  let sm = make_test_state_machine()
  assert_eq(sm.current_state_name(), "idle")
  assert_eq(sm.current_key().value, "idle_0")
}

///|
test "state machine trigger transition" {
  let sm = make_test_state_machine()
  let result = sm.trigger("move")
  assert_true(result)
  assert_eq(sm.current_state_name(), "walk")
  assert_eq(sm.current_key().value, "walk_0")
}

///|
test "state machine invalid trigger returns false" {
  let sm = make_test_state_machine()
  let result = sm.trigger("attack")
  assert_true(!result)
  assert_eq(sm.current_state_name(), "idle")
}

///|
test "state machine round-trip transition" {
  let sm = make_test_state_machine()
  let _ = sm.trigger("move")
  assert_eq(sm.current_state_name(), "walk")
  let _ = sm.trigger("stop")
  assert_eq(sm.current_state_name(), "idle")
}

///|
test "state machine update advances player" {
  let sm = make_test_state_machine()
  sm.update(0.25) // past first idle frame (0.2)
  assert_eq(sm.current_key().value, "idle_1")
}
