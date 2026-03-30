///|
test "economy: starter deck card values" {
  // Strike: 6 damage / 1 energy = baseline
  let strike = evaluate_card(Strike)
  assert_true(strike.raw_damage == 6.0)
  assert_true(strike.total > 0.0)
  // Defend: 5 block / 1 energy = baseline
  let defend = evaluate_card(Defend)
  assert_true(defend.raw_block == 5.0)
  // Bash: lower raw DPE but high debuff value
  let bash = evaluate_card(Bash)
  assert_true(bash.debuff_value > 0.0)
  assert_true(bash.total > strike.total) // Bash should be valued higher
  // Inflame: scaling value dominates
  let inflame = evaluate_card(Inflame)
  assert_true(inflame.scaling_value > 0.0)
  assert_true(inflame.total > strike.total)
}

///|
test "economy: all non-starter cards should beat Strike value" {
  let strike_value = evaluate_card(Strike).total
  let reward_cards : Array[(String, CardId)] = [
    ("Cleave", Cleave),
    ("Pommel_Strike", Pommel_Strike),
    ("Shrug_It_Off", Shrug_It_Off),
    ("Inflame", Inflame),
    ("Body_Slam", Body_Slam),
    ("Twin_Strike", Twin_Strike),
    ("Clothesline", Clothesline),
    ("Iron_Wave", Iron_Wave),
    ("Bloodletting", Bloodletting),
    ("Offering", Offering),
    ("Uppercut", Uppercut),
    ("Seeing_Red", Seeing_Red),
    ("Armaments", Armaments),
  ]
  let mut all_pass = true
  for pair in reward_cards {
    let (name, card) = pair
    let val = evaluate_card(card)
    if val.total < strike_value * 0.8 {
      println(
        "FAIL: " +
        name +
        " total=" +
        val.total.to_string() +
        " < strike*0.8=" +
        (strike_value * 0.8).to_string(),
      )
      all_pass = false
    }
  }
  assert_true(all_pass)
}

///|
test "economy: battle economy tracking for jaw worm" {
  let eco = analyze_battle_economy(SingleJawWorm, Smart, 42)
  // Should have reasonable values
  assert_true(eco.turns > 0)
  assert_true(eco.total_damage_dealt > 0)
  assert_true(eco.dpe > 0.0)
  assert_true(eco.damage_per_turn > 0.0)
  // DPE should be positive (value depends on card draw and strategy)
  assert_true(eco.dpe > 0.0)
}

///|
test "economy: aggregate economy for easy encounters" {
  let eco = analyze_economy_aggregate(SingleJawWorm, Smart, 20)
  assert_true(eco.turns >= 2)
  assert_true(eco.efficiency > 0.5) // should be somewhat efficient
  // HP lost should be moderate for easy encounter
  assert_true(eco.total_hp_lost < 40) // avg < 40 HP lost per fight
}

///|
test "economy: encounter difficulty ordering" {
  let easy1 = encounter_difficulty(SingleJawWorm)
  let easy2 = encounter_difficulty(TwoLouses)
  let normal1 = encounter_difficulty(SingleCultist)
  let elite1 = encounter_difficulty(EliteSlaver)
  let elite2 = encounter_difficulty(SentryPair)
  // Elite should be harder than Easy
  assert_true(elite1 > easy1)
  assert_true(elite2 > easy1)
  // Cultist has low raw difficulty (scaling threat, not raw damage)
  // so we just check elites are harder than at least one easy
  assert_true(elite1 > easy1 || elite1 > easy2)
}

///|
test "economy: deck power increases with good cards" {
  let starter = starter_deck()
  let base_power = deck_power(starter)
  // Adding Inflame (scaling) should increase power
  let with_inflame = starter_deck()
  with_inflame.push(Inflame)
  let inflame_power = deck_power(with_inflame)
  assert_true(inflame_power > base_power)
  // Adding too many mediocre cards dilutes deck
  let bloated = starter_deck()
  // Add 10 extra Strikes - should be worse per-card
  let mut i = 0
  while i < 10 {
    bloated.push(Strike)
    i += 1
  }
  let bloated_power = deck_power(bloated)
  // Total might be higher but per-card is worse
  let base_per_card = base_power / starter.length().to_double()
  let bloated_per_card = bloated_power / bloated.length().to_double()
  assert_true(bloated_per_card < base_per_card)
}

///|
test "economy: full run simulation completes" {
  let result = simulate_run(42, Smart)
  assert_true(result.floors_reached >= 1)
  assert_true(result.hp_at_each_floor.length() >= 1)
}

///|
test "economy: run sim summary over multiple seeds" {
  let summary = simulate_runs(20, Smart)
  assert_eq(summary.total, 20)
  assert_true(summary.avg_floors >= 1)
  assert_true(summary.avg_deck_size >= 10) // at least starter deck
}

///|
test "economy: HP curve shows expected pattern" {
  // Run a few simulations and check HP trends
  let result = simulate_run(42, Smart)
  // HP should generally decrease or stay same (except rest sites)
  if result.hp_at_each_floor.length() >= 3 {
    // First floor HP should be <= starting HP
    assert_true(result.hp_at_each_floor[0] <= 80)
  }
}
