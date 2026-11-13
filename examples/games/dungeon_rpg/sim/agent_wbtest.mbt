///|
test "agent starts from town with only legitimate choices and masked map knowledge" {
  let s = AgentSession::new(seed=731)
  assert_true(s.choices().any(c => c.id == "enter"))
  assert_false(s.choices().any(c => c.id == "rest"))
  s.step(0, "enter")
  assert_true(s.choices().any(c => c.id == "go:3:1"))
  assert_false(s.choices().any(c => c.id == "go:7:7"))
  let data = s.observe().stringify()
  assert_false(data.contains("\"seed\""))
  assert_false(data.contains("\"effects\""))
}

///|
test "stale and fabricated agent actions are rejected atomically" {
  let s = AgentSession::new()
  let before = s.observe().stringify()
  assert_true(
    try {
      s.step(9, "enter")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(s.observe().stringify(), before)
  assert_true(
    try {
      s.step(0, "go:7:7")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(s.observe().stringify(), before)
}

///|
test "navigation follows known cells and spends the same torch as ordinary movement" {
  let s = AgentSession::new()
  s.step(0, "enter")
  s.step(s.game.revision, "go:3:1")
  assert_eq(s.game.x, 3)
  assert_eq(s.game.z, 1)
  assert_eq(s.game.light, 68)
  assert_true(s.game.visited[cell_id(0, 2, 1)])
}

///|
test "navigation stops at the first encounter instead of moving through combat" {
  let s = AgentSession::new()
  s.step(0, "enter")
  s.game.seen.fill(true)
  s.game.x = 3
  s.game.z = 3
  s.game.danger = 7
  s.step(s.game.revision, "go:5:5")
  assert_eq(s.game.mode, Fighting)
  assert_false(s.game.x == 5 && s.game.z == 5)
}

///|
test "agent spell choices respect actor resources and auto-confirm only a complete round" {
  let s = AgentSession::new()
  s.step(0, "enter")
  s.game.begin_battle(true)
  for _ in 0..<3 {
    s.step(s.game.revision, "guard")
  }
  s.game.party[3].mp = 0
  assert_false(s.choices().any(c => c.command == "heal"))
  s.step(s.game.revision, "guard")
  assert_true(s.choices().any(c => c.id == "flame"))
  s.step(s.game.revision, "flame")
  assert_eq(s.game.party[4].mp, 10)
  s.step(s.game.revision, "attack:0")
  assert_eq(s.game.party[4].mp, 7)
  assert_true(
    s.game.battle.unwrap().phase == Report ||
    s.game.battle.unwrap().phase == Won,
  )
}

///|
test "returning empty handed is an incomplete expedition, not victory" {
  let s = AgentSession::new()
  s.step(0, "enter")
  s.step(s.game.revision, "interact")
  assert_eq(s.outcome, "returned")
  assert_true(s.choices().is_empty())
  assert_true(
    try {
      s.step(s.game.revision, "enter")
      false
    } catch {
      _ => true
    },
  )
}

///|
test "a rescued defeated party ends the autoplay run" {
  let s = AgentSession::new()
  s.step(0, "enter")
  s.game.begin_battle(true)
  for h in s.game.party {
    h.hp = 0
  }
  s.game.party[1].hp = 1
  s.step(s.game.revision, "guard")
  assert_eq(s.outcome, "defeat")
  assert_eq(s.game.mode, Town)
}

///|
test "bringing the seal home ends the autoplay run in victory" {
  let s = AgentSession::new()
  s.step(0, "enter")
  s.game.relic = true
  s.step(s.game.revision, "recall")
  assert_eq(s.outcome, "victory")
}
