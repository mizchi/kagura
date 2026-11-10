///|
pub fn Enemy::windup_frames(self : Enemy, base : Int32) -> Int32 {
  base + (if self.kind == 3 { 24 } else if self.kind == 1 { 12 } else { 0 })
}

///|
pub fn Enemy::recovery_frames(self : Enemy) -> Int32 {
  if self.kind == 3 {
    108
  } else {
    90
  }
}

///|
fn Enemy::quiet_beat(self : Enemy) -> Bool {
  (self.action == "recover" || self.action == "reset") &&
  self.timer > self.phase_total - 24
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
