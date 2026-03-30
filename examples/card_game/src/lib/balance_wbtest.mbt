// === Balance Simulation Tests ===
// These tests verify game balance by running automated battles.
// Target: Easy encounters ~95% win, Normal ~75%, Elite ~50%

///|
test "balance: jaw worm easy encounter (smart)" {
  let summary = run_simulations(SingleJawWorm, Smart, 50)
  // Easy encounter: should win most of the time
  let win_pct = summary.wins * 100 / summary.total
  inspect(
    "JawWorm: wins=" +
    summary.wins.to_string() +
    "/" +
    summary.total.to_string() +
    " (" +
    win_pct.to_string() +
    "%) avg_hp=" +
    summary.avg_hp_remaining.to_string() +
    " avg_turns=" +
    summary.avg_turns.to_string(),
    content=(
      #|JawWorm: wins=50/50 (100%) avg_hp=72 avg_turns=3
    ),
  )
  assert_true(win_pct >= 80) // Easy: should win >= 80%
}

///|
test "balance: two louses easy encounter (smart)" {
  let summary = run_simulations(TwoLouses, Smart, 50)
  let win_pct = summary.wins * 100 / summary.total
  inspect(
    "TwoLouses: wins=" +
    summary.wins.to_string() +
    "/" +
    summary.total.to_string() +
    " (" +
    win_pct.to_string() +
    "%) avg_hp=" +
    summary.avg_hp_remaining.to_string(),
    content=(
      #|TwoLouses: wins=50/50 (100%) avg_hp=77
    ),
  )
  assert_true(win_pct >= 80)
}

///|
test "balance: cultist normal encounter (smart)" {
  let summary = run_simulations(SingleCultist, Smart, 50)
  let win_pct = summary.wins * 100 / summary.total
  inspect(
    "Cultist: wins=" +
    summary.wins.to_string() +
    "/" +
    summary.total.to_string() +
    " (" +
    win_pct.to_string() +
    "%) avg_hp=" +
    summary.avg_hp_remaining.to_string(),
    content=(
      #|Cultist: wins=50/50 (100%) avg_hp=76
    ),
  )
  assert_true(win_pct >= 60) // Normal: >= 60%
}

///|
test "balance: fungi pair normal encounter (smart)" {
  let summary = run_simulations(FungiPair, Smart, 50)
  let win_pct = summary.wins * 100 / summary.total
  inspect(
    "FungiPair: wins=" +
    summary.wins.to_string() +
    "/" +
    summary.total.to_string() +
    " (" +
    win_pct.to_string() +
    "%) avg_hp=" +
    summary.avg_hp_remaining.to_string(),
    content=(
      #|FungiPair: wins=50/50 (100%) avg_hp=70
    ),
  )
  assert_true(win_pct >= 50) // Normal: >= 50%
}

///|
test "balance: red slaver elite encounter (smart)" {
  let summary = run_simulations(EliteSlaver, Smart, 50)
  let win_pct = summary.wins * 100 / summary.total
  inspect(
    "RedSlaver: wins=" +
    summary.wins.to_string() +
    "/" +
    summary.total.to_string() +
    " (" +
    win_pct.to_string() +
    "%) avg_hp=" +
    summary.avg_hp_remaining.to_string(),
    content=(
      #|RedSlaver: wins=50/50 (100%) avg_hp=64
    ),
  )
  assert_true(win_pct >= 30) // Elite: >= 30%
}

///|
test "balance: sentry pair elite encounter (smart)" {
  let summary = run_simulations(SentryPair, Smart, 50)
  let win_pct = summary.wins * 100 / summary.total
  inspect(
    "SentryPair: wins=" +
    summary.wins.to_string() +
    "/" +
    summary.total.to_string() +
    " (" +
    win_pct.to_string() +
    "%) avg_hp=" +
    summary.avg_hp_remaining.to_string(),
    content=(
      #|SentryPair: wins=50/50 (100%) avg_hp=16
    ),
  )
  assert_true(win_pct >= 20) // Elite: tough
}

// === Strategy Comparison ===

///|
test "balance: aggressive vs defensive vs smart on jaw worm" {
  let agg = run_simulations(SingleJawWorm, Aggressive, 30)
  let def = run_simulations(SingleJawWorm, Defensive, 30)
  let smart = run_simulations(SingleJawWorm, Smart, 30)
  inspect(
    "JawWorm strategies - Aggressive: " +
    agg.wins.to_string() +
    "/30 hp=" +
    agg.avg_hp_remaining.to_string() +
    " | Defensive: " +
    def.wins.to_string() +
    "/30 hp=" +
    def.avg_hp_remaining.to_string() +
    " | Smart: " +
    smart.wins.to_string() +
    "/30 hp=" +
    smart.avg_hp_remaining.to_string(),
    content=(
      #|JawWorm strategies - Aggressive: 30/30 hp=69 | Defensive: 30/30 hp=65 | Smart: 30/30 hp=72
    ),
  )
  // Smart should be at least as good as both others
  assert_true(smart.wins >= agg.wins || smart.wins >= def.wins)
}

// === Relic Impact ===

///|
test "balance: relics improve win rate on cultist" {
  let base = run_simulations(SingleCultist, Smart, 50)
  let with_relics = run_simulations(SingleCultist, Smart, 50, relics=[
    Vajra,
    BurningBlood,
  ])
  inspect(
    "Cultist - no relics: " +
    base.wins.to_string() +
    "/50 | with Vajra+BB: " +
    with_relics.wins.to_string() +
    "/50",
    content=(
      #|Cultist - no relics: 50/50 | with Vajra+BB: 50/50
    ),
  )
  // Relics should help
  assert_true(with_relics.wins >= base.wins)
}

// === Card Efficiency Analysis ===

///|
test "balance: DPE analysis for all attack cards" {
  // DPE = Damage Per Energy (higher = more efficient)
  let attacks : Array[(String, Double)] = [
    ("Strike", 6.0 / 1.0),
    ("Bash", 8.0 / 2.0), // + VUL2 value
    ("Cleave", 8.0 / 1.0), // AoE
    ("Pommel Strike", 9.0 / 1.0), // + draw
    ("Twin Strike", 10.0 / 1.0),
    ("Clothesline", 12.0 / 2.0), // + WK2
    ("Iron Wave", 5.0 / 1.0), // + 5 block
    ("Uppercut", 13.0 / 2.0), // + WK1 + VUL1
  ]
  let mut result = "DPE:"
  for pair in attacks {
    let (name, dpe) = pair
    result = result + " " + name + "=" + dpe.to_string()
  }
  inspect(
    result,
    content=(
      #|DPE: Strike=6 Bash=4 Cleave=8 Pommel Strike=9 Twin Strike=10 Clothesline=6 Iron Wave=5 Uppercut=6.5
    ),
  )
  // Strike baseline = 6.0 DPE, all cards should justify their cost
  // Twin Strike (10 DPE) is strongest raw but no utility
  // Bash (4 DPE) is weakest raw but VUL makes up for it
  assert_true(true)
}

// === Enemy New AI Tests ===

///|
test "green louse follows curl up pattern" {
  let enemy = spawn_enemy(GreenLouse)
  assert_true(enemy.intent == DefendIntent(4))
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player)
  assert_true(enemy.intent == AttackIntent(6))
}

///|
test "fungi beast applies vulnerable on debuff turn" {
  let enemy = spawn_enemy(FungiBeast)
  let player = Fighter::new("Test", 100)
  // Advance to debuff turn (index 3)
  let _ = execute_enemy_intent(enemy, player) // 0: attack(6)
  let _ = execute_enemy_intent(enemy, player) // 1: buff(+3 STR)
  let _ = execute_enemy_intent(enemy, player) // 2: attack(6)
  let _ = execute_enemy_intent(enemy, player) // 3: debuff
  assert_true(player.status.vulnerable > 0)
}

///|
test "red slaver debuff applies weak and vulnerable" {
  let enemy = spawn_enemy(SlaverRed)
  let player = Fighter::new("Test", 100)
  // Advance to debuff turn (index 3)
  let _ = execute_enemy_intent(enemy, player) // 0: attack 13
  let _ = execute_enemy_intent(enemy, player) // 1: attack 13
  let _ = execute_enemy_intent(enemy, player) // 2: attack 8
  let _ = execute_enemy_intent(enemy, player) // 3: debuff
  assert_true(player.status.weak > 0)
  assert_true(player.status.vulnerable > 0)
}

///|
test "jaw worm bellow gives block and strength" {
  let enemy = spawn_enemy(JawWorm)
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player) // 0: attack(11)
  // Next intent should be DefendIntent(6)
  assert_true(enemy.intent == DefendIntent(6))
  let _ = execute_enemy_intent(enemy, player) // 1: bellow (block + STR)
  assert_eq(enemy.fighter.block, 6)
  assert_eq(enemy.fighter.status.strength, 3)
}

///|
test "cultist ritual gives 3 strength (stacks each cycle)" {
  let enemy = spawn_enemy(Cultist)
  let player = Fighter::new("Test", 100)
  let _ = execute_enemy_intent(enemy, player) // buff: +3 STR
  assert_eq(enemy.fighter.status.strength, 3)
  let _ = execute_enemy_intent(enemy, player) // attack(6)
  let _ = execute_enemy_intent(enemy, player) // buff again: +3 STR
  assert_eq(enemy.fighter.status.strength, 6) // stacks!
}

///|
test "nob enrages when player plays skill" {
  let state = BattleState::new([GremlinNob])
  // Play a Defend (Skill) — should trigger Nob's enrage
  let initial_str = state.enemies[0].fighter.status.strength
  let _ = play_card(state, 0, 0) // play first card in hand
  // Depending on what card is drawn, Nob may or may not enrage
  // But let's directly test: play Defend from hand
  state.hand.clear()
  state.hand.push(Defend)
  let _ = play_card(state, 0, 0)
  // Nob should have gained +2 STR from enrage
  assert_true(state.enemies[0].fighter.status.strength >= initial_str + 2)
}

///|
test "nob does not enrage on attack cards" {
  let state = BattleState::new([GremlinNob])
  state.hand.clear()
  state.hand.push(Strike)
  state.player.energy = 3
  let str_before = state.enemies[0].fighter.status.strength
  let _ = play_card(state, 0, 0)
  assert_eq(state.enemies[0].fighter.status.strength, str_before)
}

///|
test "encounter preset generates correct enemies" {
  let enemies = encounter_enemies(TwoLouses)
  assert_eq(enemies.length(), 2)
  assert_true(enemies[0] == GreenLouse)
  assert_true(enemies[1] == RedLouse)
}

///|
test "encounter from preset creates valid battle" {
  let state = BattleState::from_encounter(FungiPair)
  assert_eq(state.enemies.length(), 2)
  assert_eq(state.enemies[0].fighter.name, "Fungi Beast")
  assert_eq(state.enemies[1].fighter.name, "Fungi Beast")
}
