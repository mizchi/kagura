///|
fn is_unique_enemy(id : EnemyId) -> Bool {
  id == CinderDuelist || id == GildedSentinel || id == HollowOracle
}

///|
fn start_unique_battle(run : RunState) -> BattleState {
  let remaining = [CinderDuelist, GildedSentinel, HollowOracle].filter(id => {
    !run.unique_enemies_seen.contains(id)
  })
  let pool = if remaining.is_empty() {
    [CinderDuelist, GildedSentinel, HollowOracle]
  } else {
    remaining
  }
  let enemy = pool[run_random(run) % pool.length()]
  run.unique_enemies_seen.push(enemy)
  let encounter = match enemy {
    CinderDuelist => UniqueDuelist
    GildedSentinel => UniqueSentinel
    _ => UniqueOracle
  }
  start_run_battle(run, encounter)
}

///|
fn unique_enemy_detail(id : EnemyId) -> String {
  match id {
    CinderDuelist =>
      "A duelist who grows stronger before a three-hit flurry. Reward: Ember Seal (+2 starting Strength)."
    GildedSentinel =>
      "A guardian whose defensive turns preserve its shield. Reward: Merchant Charm (20% shop discount)."
    HollowOracle =>
      "An oracle that weakens its foe, then attacks in waves. Reward: Wayfinder (+10 combat gold)."
    _ => ""
  }
}
