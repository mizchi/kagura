///|
pub(all) struct LevelUpConfig {
  xp_base : Int
  xp_growth : Int
}

///|
pub fn LevelUpConfig::default() -> LevelUpConfig {
  { xp_base: 10, xp_growth: 6 }
}

///|
pub(all) struct LevelProgression {
  mut level : Int
  mut xp : Int
  mut next_level_xp : Int
  mut pending_choices : Int
}

///|
pub fn LevelProgression::new(
  config? : LevelUpConfig = LevelUpConfig::default(),
) -> LevelProgression {
  {
    level: 1,
    xp: 0,
    next_level_xp: next_level_xp_for(1, config),
    pending_choices: 0,
  }
}

///|
pub fn next_level_xp_for(level : Int, config : LevelUpConfig) -> Int {
  @cmp.maximum(1, config.xp_base + (level - 1) * config.xp_growth)
}

///|
pub fn LevelProgression::gain_xp(
  self : LevelProgression,
  gained_xp : Int,
  config : LevelUpConfig,
) -> Bool {
  if gained_xp <= 0 {
    return false
  }
  self.xp = self.xp + gained_xp
  let mut leveled = false
  while self.xp >= self.next_level_xp {
    self.xp = self.xp - self.next_level_xp
    self.level = self.level + 1
    self.next_level_xp = next_level_xp_for(self.level, config)
    self.pending_choices = self.pending_choices + 1
    leveled = true
  }
  leveled
}

///|
pub fn LevelProgression::consume_choice(self : LevelProgression) -> Bool {
  if self.pending_choices <= 0 {
    return false
  }
  self.pending_choices = self.pending_choices - 1
  true
}
