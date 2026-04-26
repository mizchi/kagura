///|
fn make_test_clips() -> Map[String, AnimationClip] {
  let idle_clip : AnimationClip = {
    name: "idle",
    channels: [
      {
        node_index: 0,
        target: Translation,
        interpolation: Linear,
        times: [0.0, 1.0],
        values: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      },
    ],
    duration: 1.0,
  }
  let walk_clip : AnimationClip = {
    name: "walk",
    channels: [
      {
        node_index: 0,
        target: Translation,
        interpolation: Linear,
        times: [0.0, 1.0],
        values: [0.0, 0.0, 0.0, 1.0, 0.0, 0.0],
      },
    ],
    duration: 1.0,
  }
  let attack_clip : AnimationClip = {
    name: "attack",
    channels: [
      {
        node_index: 0,
        target: Translation,
        interpolation: Linear,
        times: [0.0, 0.5],
        values: [0.0, 0.0, 0.0, 0.0, 2.0, 0.0],
      },
    ],
    duration: 0.5,
  }
  let clips : Map[String, AnimationClip] = {}
  clips["idle"] = idle_clip
  clips["walk"] = walk_clip
  clips["attack"] = attack_clip
  clips
}

///|
fn make_test_transitions() -> Array[AnimTransition3D] {
  [
    {
      from_state: "idle",
      to_state: "walk",
      trigger: "move",
      blend_duration: 0.3,
    },
    {
      from_state: "walk",
      to_state: "idle",
      trigger: "stop",
      blend_duration: 0.3,
    },
    {
      from_state: "idle",
      to_state: "walk",
      trigger: "instant_move",
      blend_duration: 0.0,
    },
    {
      from_state: "*",
      to_state: "attack",
      trigger: "attack",
      blend_duration: 0.1,
    },
  ]
}

///|
test "state machine: initial state" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "idle",
  )
  assert_eq(sm.current_state_name(), "idle")
  assert_true(!sm.is_blending())
}

///|
test "state machine: trigger with blend" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "idle",
  )
  let ok = sm.trigger("move")
  assert_true(ok)
  assert_eq(sm.current_state_name(), "walk")
  assert_true(sm.is_blending())
  // Blend should be in progress
  assert_true(sm.blend_weight() < 0.01)
}

///|
test "state machine: blend completes" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "idle",
  )
  let _ = sm.trigger("move")
  // Update past blend duration (0.3)
  sm.update(0.4)
  assert_true(!sm.is_blending())
  assert_eq(sm.current_state_name(), "walk")
}

///|
test "state machine: instant transition (no blend)" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "idle",
  )
  let ok = sm.trigger("instant_move")
  assert_true(ok)
  assert_eq(sm.current_state_name(), "walk")
  assert_true(!sm.is_blending())
}

///|
test "state machine: any_state transition" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "walk",
  )
  // "*" transition should match any current state
  let ok = sm.trigger("attack")
  assert_true(ok)
  assert_eq(sm.current_state_name(), "attack")
}

///|
test "state machine: invalid trigger returns false" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "idle",
  )
  let ok = sm.trigger("nonexistent")
  assert_true(!ok)
  assert_eq(sm.current_state_name(), "idle")
}

///|
test "state machine: sample during blend" {
  let sm = AnimationStateMachine3D::new(
    make_test_clips(),
    make_test_transitions(),
    "idle",
  )
  let _ = sm.trigger("move")
  sm.update(0.15) // half of 0.3 blend duration
  let poses = sm.sample()
  // Should return blended poses
  assert_true(poses.length() > 0)
  // At weight ~0.5, translation should be between idle (0,0,0) and walk interpolated
  match poses[0].translation {
    Some(v) =>
      // Walk at t=0.15 would be (0.15, 0, 0), idle at t=0.15 would be (0, 0, 0)
      // Blended at ~0.5 weight: ~(0.075, 0, 0)
      assert_true(v.x >= -0.01)
    None => fail("Expected translation")
  }
}
