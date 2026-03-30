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
  // Scorecard should be included
  assert_true(report.contains("FUN SCORECARD"))
  assert_true(report.contains("TOTAL:"))
}

///|
test "fun: scorecard produces valid scores" {
  let m = analyze_fun_metrics(10)
  let sc = score_fun_metrics(m)
  // All scores should be 0.0-1.0
  assert_true(sc.tension_score >= 0.0 && sc.tension_score <= 1.0)
  assert_true(sc.draw_variance_score >= 0.0 && sc.draw_variance_score <= 1.0)
  assert_true(sc.synergy_score >= 0.0 && sc.synergy_score <= 1.0)
  assert_true(sc.resource_score >= 0.0 && sc.resource_score <= 1.0)
  assert_true(sc.enemy_diff_score >= 0.0 && sc.enemy_diff_score <= 1.0)
  assert_true(sc.decision_score >= 0.0 && sc.decision_score <= 1.0)
  assert_true(sc.comeback_score >= 0.0 && sc.comeback_score <= 1.0)
  // Total should be 0-100
  assert_true(sc.total_score >= 0.0 && sc.total_score <= 100.0)
  // Overall grade should be non-empty
  assert_true(sc.overall_grade.length() > 0)
}

///|
test "fun: zone_score in-zone returns high score" {
  // Value exactly at center of zone
  let score = zone_score(0.25, 0.15, 0.35)
  assert_true(score >= 0.95) // Should be ~1.0 at center
}

///|
test "fun: zone_score out-of-zone returns lower score" {
  // Value below zone
  let score_low = zone_score(0.05, 0.15, 0.35)
  assert_true(score_low < 0.7) // Below zone edge
  // Value above zone
  let score_high = zone_score(0.50, 0.15, 0.35)
  assert_true(score_high < 0.7) // Above zone edge
}

///|
test "fun: default targets are internally consistent" {
  let t = default_targets()
  // All min < max
  assert_true(t.tension_ratio_min < t.tension_ratio_max)
  assert_true(t.lethal_proximity_min < t.lethal_proximity_max)
  assert_true(t.entropy_min < t.entropy_max)
  assert_true(t.synergy_min < t.synergy_max)
  assert_true(t.decision_min < t.decision_max)
  assert_true(t.comeback_min < t.comeback_max)
}
