///|
test "LevelProgression gains xp and increments pending choices" {
  let progression = LevelProgression::new()
  let leveled = progression.gain_xp(10, LevelUpConfig::default())
  assert_true(leveled)
  assert_eq(progression.level, 2)
  assert_eq(progression.pending_choices, 1)
}

///|
test "LevelProgression can consume a pending choice" {
  let progression = LevelProgression::{
    level: 2,
    xp: 0,
    next_level_xp: 16,
    pending_choices: 2,
  }
  assert_true(progression.consume_choice())
  assert_eq(progression.pending_choices, 1)
}

///|
test "next_level_xp_for uses base and growth" {
  let config = LevelUpConfig::{ xp_base: 10, xp_growth: 6 }
  assert_eq(next_level_xp_for(1, config), 10)
  assert_eq(next_level_xp_for(4, config), 28)
}
