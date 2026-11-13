///|
test "experience records round boundaries commands cancellation and causal receipts" {
  let g = new_game()
  g.enter()
  g.begin_battle(false)
  g.command("guard", -1)
  g.command("undo", -1)
  g.command("all-guard", -1)
  let data = g.experience_events(0).stringify()
  assert_true(data.contains("loop.start"))
  assert_true(data.contains("input.accepted"))
  assert_true(data.contains("undo"))
  assert_true(data.contains("loop.resolved"))
  assert_false(data.contains("loop.ready"))
  g.command("continue", -1)
  assert_true(g.experience_events(0).stringify().contains("loop.ready"))
}

///|
test "experience records each floor arrival without claiming exposure or human understanding" {
  let g = new_game()
  g.command("enter", -1)
  g.x = 7
  g.z = 7
  g.command("interact", -1)
  let data = g.experience_events(0).stringify()
  assert_true(data.contains("arc.reached"))
  assert_false(data.contains("arc.exposed"))
  assert_false(data.contains("arc.understood"))
  assert_false(g.snapshot().contains("experience"))
  let last = g.experience_sequence
  assert_true(g.experience_events(last).stringify().contains("\"events\":[]"))
}

///|
test "failed commands retain their rejection and bounded logs expose missing events" {
  let g = new_game()
  let revision = g.revision
  ignore(g.command("unknown", -1) catch { _ => () })
  assert_eq(g.revision, revision)
  assert_true(g.experience_events(0).stringify().contains("input.rejected"))
  for _ in 0..<4200 {
    ignore(g.command("unknown", -1) catch { _ => () })
  }
  assert_true(g.experience_events(0).stringify().contains("\"dropped\":true"))
}
