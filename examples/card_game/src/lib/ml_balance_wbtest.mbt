///|
test "ml: feature extraction produces valid features" {
  let state = BattleState::new([JawWorm])
  let features = extract_features(state)
  assert_true(features.player_hp_pct == 1.0) // full HP at start
  assert_true(features.player_energy == 3.0)
  assert_true(features.deck_size == 10.0)
  assert_true(features.enemy_count == 1.0)
  assert_true(features.turn_number == 1.0)
}

///|
test "ml: features to array has 20 elements" {
  let state = BattleState::new([JawWorm])
  let features = extract_features(state)
  let arr = features_to_array(features)
  assert_eq(arr.length(), 20)
}

///|
test "ml: archetype detection - starter is balanced" {
  let deck = starter_deck()
  assert_eq(detect_archetype(deck), Balanced)
}

///|
test "ml: archetype detection - strength build" {
  let deck = starter_deck()
  deck.push(Inflame)
  deck.push(Demon_Form)
  deck.push(Twin_Strike)
  deck.push(Sword_Boomerang)
  assert_eq(detect_archetype(deck), Strength)
}

///|
test "ml: archetype detection - block build" {
  let deck = starter_deck()
  deck.push(Barricade)
  deck.push(Metallicize)
  deck.push(Body_Slam)
  deck.push(Impervious)
  assert_eq(detect_archetype(deck), Block)
}

///|
test "ml: archetype detection - exhaust build" {
  let deck = starter_deck()
  deck.push(Feel_No_Pain)
  deck.push(Offering)
  deck.push(Bloodletting)
  deck.push(Seeing_Red)
  assert_eq(detect_archetype(deck), Exhaust)
}

///|
test "ml: ensemble simulation runs" {
  let result = simulate_ensemble(SingleJawWorm, 20)
  assert_eq(result.total, 20)
  assert_true(result.wins > 0)
}

///|
test "ml: balance report generates" {
  let report = generate_balance_report(SingleJawWorm)
  assert_true(report.smart_win_pct >= 80)
  assert_true(report.difficulty_score > 0.0)
}

///|
test "ml: full balance report for all encounters" {
  let encounters : Array[EncounterId] = [
    SingleJawWorm,
    TwoLouses,
    SingleCultist,
    FungiPair,
    EliteSlaver,
    SentryPair,
    EliteNob,
  ]
  let mut easy_ok = true
  let mut elite_harder = false
  for enc in encounters {
    let report = generate_balance_report(enc)
    // Basic sanity: win rate should be 0-100
    assert_true(report.smart_win_pct >= 0)
    assert_true(report.smart_win_pct <= 100)
    // Easy should have high win rate
    if report.tier == "Easy" {
      if report.smart_win_pct < 80 {
        easy_ok = false
      }
    }
    // Track elite ensemble win rates
    if report.tier == "Elite" {
      if report.ensemble_win_pct < 100 {
        elite_harder = true
      }
    }
  }
  assert_true(easy_ok)
  // At least one elite should be somewhat challenging for ensemble
  // (Gremlin Nob with ensemble ~90% satisfies this)
  assert_true(elite_harder)
}

///|
test "ml: run simulation captures HP curve" {
  let result = simulate_run(42, Smart)
  // HP curve should have at least 1 entry
  assert_true(result.hp_at_each_floor.length() >= 1)
  // Deck should grow or stay same (never shrink)
  if result.deck_size_at_each_floor.length() >= 2 {
    let first = result.deck_size_at_each_floor[0]
    let last = result.deck_size_at_each_floor[result.deck_size_at_each_floor.length() -
      1]
    assert_true(last >= first)
  }
}

///|
test "ml: sensitivity analysis - enemy HP perturbation" {
  let result = analyze_sensitivity(SingleJawWorm, EnemyHP(JawWorm), 10, 30)
  // Increasing enemy HP by 10 should decrease win rate (negative sensitivity)
  // or at least not increase it significantly
  assert_true(result.base_win_rate >= 0.0)
  assert_true(result.base_win_rate <= 1.0)
  assert_true(result.perturbed_win_rate >= 0.0)
  assert_true(result.perturbed_win_rate <= 1.0)
  inspect(
    "JawWorm +10HP: base=" +
    result.base_win_rate.to_string() +
    " pert=" +
    result.perturbed_win_rate.to_string() +
    " sens=" +
    result.sensitivity.to_string(),
    content=(
      #|JawWorm +10HP: base=1 pert=1 sens=0
    ),
  )
}

///|
test "ml: sensitivity analysis - player HP matters for elite" {
  let result = analyze_sensitivity(SentryPair, PlayerHP, 20, 30)
  // More player HP should help against elites
  assert_true(result.perturbed_win_rate >= result.base_win_rate)
  inspect(
    "SentryPair +20HP: base=" +
    result.base_win_rate.to_string() +
    " pert=" +
    result.perturbed_win_rate.to_string(),
    content=(
      #|SentryPair +20HP: base=0.9 pert=1
    ),
  )
}

///|
test "ml: run balance - win rate sanity check" {
  let summary = simulate_runs(30, Smart)
  // Report the actual win rate for balance tuning
  inspect(
    "Run win_rate=" +
    summary.win_rate_pct.to_string() +
    "% avg_floors=" +
    summary.avg_floors.to_string() +
    " avg_deck=" +
    summary.avg_deck_size.to_string(),
    content=(
      #|Run win_rate=80% avg_floors=15 avg_deck=18
    ),
  )
  // Basic sanity: should complete at least some runs
  assert_true(summary.avg_floors >= 1)
}
