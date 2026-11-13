///|
pub fn Enemy::windup_frames(self : Enemy, base : Int32) -> Int32 {
  base +
  frames_from_ms(
    if self.kind == 3 {
      boss_extra_windup_ms
    } else if self.kind == 1 {
      shield_extra_windup_ms
    } else {
      0
    },
  )
}

///|
pub fn Enemy::recovery_frames(self : Enemy) -> Int32 {
  default_reaction_budget.counter_frames() +
  (if self.kind == 3 { frames_from_ms(boss_extra_recovery_ms) } else { 0 })
}

///|
fn Enemy::quiet_beat(self : Enemy) -> Bool {
  (self.action == "recover" || self.action == "reset") &&
  self.timer > self.phase_total - default_reaction_budget.spacing_frames()
}

///|
pub fn Enemy::phase_remaining(self : Enemy) -> Double {
  clamp(self.timer.to_double() / self.phase_total.max(1).to_double(), 0, 1)
}

///|
pub fn Enemy::attack_depth(self : Enemy) -> Double {
  if self.kind == 3 {
    38
  } else {
    29
  }
}

///|
pub fn Enemy::attack_reach(self : Enemy) -> Double {
  if self.kind == 3 {
    130
  } else {
    101
  }
}
