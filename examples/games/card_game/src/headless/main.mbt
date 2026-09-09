// Headless card game runner: balance simulation & run playtest
// Usage: moon run src/headless --target js

///|
fn main {
  println("=== CARD GAME HEADLESS TEST ===")
  println("")

  // --- 1. Balance Simulation (per-encounter) ---
  println("--- Balance Simulation (Smart AI, 50 runs each) ---")
  let encounters : Array[(@lib.EncounterId, String, String)] = [
    // Act 1
    (@lib.SingleJawWorm, "Jaw Worm", "Easy"),
    (@lib.TwoLouses, "Two Louses", "Easy"),
    (@lib.SingleCultist, "Cultist", "Normal"),
    (@lib.FungiPair, "Fungi Pair", "Normal"),
    (@lib.SlaverFight, "Red Slaver", "Normal"),
    (@lib.EliteSlaver, "Elite Slaver", "Elite"),
    (@lib.SentryPair, "Sentry Pair", "Elite"),
    (@lib.EliteNob, "Gremlin Nob", "Elite"),
    (@lib.BossGuardian, "The Guardian", "Boss"),
    (@lib.BossHexaghost, "Hexaghost", "Boss"),
    // Act 2
    (@lib.SingleChosen, "Chosen", "Normal"),
    (@lib.SnakePlantFight, "Snake Plant", "Normal"),
    (@lib.ChosenSlaver, "Chosen+Slaver", "Normal"),
    (@lib.Act2EliteBook, "Book of Stabbing", "Elite"),
    (@lib.Act2EliteSentryTrio, "Sentry Trio", "Elite"),
    (@lib.BossAutomaton, "Bronze Automaton", "Boss"),
  ]
  let mut all_ok = true
  for entry in encounters {
    let (enc, name, tier) = entry
    let report = @lib.generate_balance_report(enc)
    let smart_pct = report.smart_win_pct
    let ens_pct = report.ensemble_win_pct
    let status = match tier {
      "Easy" =>
        if smart_pct >= 80 {
          "OK"
        } else {
          all_ok = false
          "FAIL"
        }
      "Normal" =>
        if smart_pct >= 50 {
          "OK"
        } else {
          all_ok = false
          "FAIL"
        }
      _ =>
        if smart_pct >= 20 {
          "OK"
        } else {
          all_ok = false
          "FAIL"
        }
    }
    println(
      "  [" +
      status +
      "] " +
      name +
      " (" +
      tier +
      "): smart=" +
      smart_pct.to_string() +
      "% ensemble=" +
      ens_pct.to_string() +
      "% avg_hp=" +
      report.smart_avg_hp.to_string() +
      " difficulty=" +
      report.difficulty_score.to_string(),
    )
  }
  println("")

  // --- 2. Strategy Comparison ---
  println("--- Strategy Comparison (Jaw Worm, 30 runs) ---")
  let agg = @lib.run_simulations(@lib.SingleJawWorm, @lib.Aggressive, 30)
  let def = @lib.run_simulations(@lib.SingleJawWorm, @lib.Defensive, 30)
  let smart = @lib.run_simulations(@lib.SingleJawWorm, @lib.Smart, 30)
  println(
    "  Aggressive: " +
    agg.wins.to_string() +
    "/30 avg_hp=" +
    agg.avg_hp_remaining.to_string(),
  )
  println(
    "  Defensive:  " +
    def.wins.to_string() +
    "/30 avg_hp=" +
    def.avg_hp_remaining.to_string(),
  )
  println(
    "  Smart:      " +
    smart.wins.to_string() +
    "/30 avg_hp=" +
    smart.avg_hp_remaining.to_string(),
  )
  println("")

  // --- 3. Sensitivity Analysis ---
  println("--- Sensitivity Analysis ---")
  let sens_enemy_hp = @lib.analyze_sensitivity(
    @lib.SentryPair,
    @lib.EnemyHP(@lib.Sentry),
    10,
    30,
  )
  println(
    "  Sentry +10HP: base_wr=" +
    sens_enemy_hp.base_win_rate.to_string() +
    " pert_wr=" +
    sens_enemy_hp.perturbed_win_rate.to_string() +
    " sens=" +
    sens_enemy_hp.sensitivity.to_string(),
  )
  let sens_player_hp = @lib.analyze_sensitivity(
    @lib.SentryPair,
    @lib.PlayerHP,
    20,
    30,
  )
  println(
    "  Player +20HP: base_wr=" +
    sens_player_hp.base_win_rate.to_string() +
    " pert_wr=" +
    sens_player_hp.perturbed_win_rate.to_string() +
    " sens=" +
    sens_player_hp.sensitivity.to_string(),
  )
  println("")

  // --- 4. Full Run Simulation ---
  println("--- Run Simulation (30 runs, Smart AI) ---")
  let run_summary = @lib.simulate_runs(30, @lib.Smart)
  println(
    "  Win rate: " +
    run_summary.win_rate_pct.to_string() +
    "% (" +
    run_summary.wins.to_string() +
    "/" +
    run_summary.total.to_string() +
    ")",
  )
  println("  Avg floors: " + run_summary.avg_floors.to_string())
  println("  Avg deck size: " + run_summary.avg_deck_size.to_string())
  if run_summary.win_rate_pct < 10 {
    all_ok = false
  }
  println("")

  // --- 5. Single Run Trace ---
  println("--- Sample Run Trace (seed=42) ---")
  let run = @lib.simulate_run(42, @lib.Smart)
  let mut floor_idx = 0
  while floor_idx < run.hp_at_each_floor.length() {
    let hp = run.hp_at_each_floor[floor_idx]
    let deck = if floor_idx < run.deck_size_at_each_floor.length() {
      run.deck_size_at_each_floor[floor_idx].to_string()
    } else {
      "?"
    }
    println(
      "  Floor " +
      (floor_idx + 1).to_string() +
      ": HP=" +
      hp.to_string() +
      " Deck=" +
      deck,
    )
    floor_idx += 1
  }
  let outcome = if run.won { "VICTORY" } else { "DEFEAT" }
  println(
    "  Result: " +
    outcome +
    " (reached floor " +
    run.floors_reached.to_string() +
    ", cards added: " +
    run.cards_added.to_string() +
    ")",
  )
  println("")

  // --- 6. Fun Metrics Analysis ---
  println("--- Fun Metrics Analysis (40 runs) ---")
  let fun = @lib.analyze_fun_metrics(40)
  let report = @lib.format_fun_report(fun)
  println(report)
  println("")

  // --- 7. Procedural Card Generation + Executable Evaluation ---
  println("--- Procedural Card Generation (1000 cards, multi-turn eval) ---")
  println(@lib.format_generation_report())

  // --- Summary ---
  if all_ok {
    println("=== ALL CHECKS PASSED ===")
  } else {
    println("=== SOME CHECKS FAILED ===")
  }
}
