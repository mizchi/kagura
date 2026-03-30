///|
test "fun: detailed run completes" {
  let result = simulate_detailed_run(42, Smart)
  assert_true(result.floors_reached >= 1)
  assert_true(result.battles.length() >= 1)
  // First battle should be won (easy encounter)
  assert_true(result.battles[0].won)
}

///|
test "fun: battle stats are populated" {
  let result = simulate_detailed_run(42, Smart)
  let b = result.battles[0]
  assert_true(b.floor >= 1)
  assert_true(b.hp_before > 0)
  assert_true(b.damage_dealt > 0)
  assert_true(b.cards_played > 0)
  assert_true(b.turns >= 1)
}

///|
test "fun: metrics analysis runs without crash" {
  let m = analyze_fun_metrics(10)
  // Tension should be between 0 and 1
  assert_true(m.tension_ratio >= 0.0)
  assert_true(m.tension_ratio <= 1.0)
  // Synergy multiplier should be positive
  assert_true(m.synergy_multiplier > 0.0)
  // Decision impact should be non-negative (Smart >= Aggressive for runs)
  assert_true(m.decision_impact >= -1.0)
  assert_true(m.decision_impact <= 1.0)
  // Comeback rate 0-1
  assert_true(m.comeback_rate >= 0.0)
  assert_true(m.comeback_rate <= 1.0)
}

///|
test "fun: format report produces non-empty string" {
  let m = analyze_fun_metrics(5)
  let report = format_fun_report(m)
  assert_true(report.length() > 100)
  // Should contain all 7 sections
  assert_true(report.contains("TENSION"))
  assert_true(report.contains("DRAW VARIANCE"))
  assert_true(report.contains("SYNERGY EXPLOSION"))
  assert_true(report.contains("RESOURCE TRADEOFF"))
  assert_true(report.contains("ENEMY DIFFERENTIATION"))
  assert_true(report.contains("DECISION WEIGHT"))
  assert_true(report.contains("COMEBACK POTENTIAL"))
}
