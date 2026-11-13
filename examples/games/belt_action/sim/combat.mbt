///|
pub fn Game::begin_attack(self : Game, heavy : Bool) -> Unit {
  let p = self.player
  p.action = if heavy { "breaker" } else { "strike" }
  p.combo = if heavy {
    0
  } else if p.combo_timer > 0 {
    (p.combo + 1) % 3
  } else {
    0
  }
  p.combo_timer = 72
  p.age = 0
  p.serial += 1
  p.buffer = 0
  self.attacks += 1
}

///|
fn guarded(e : Enemy, p : Player) -> Bool {
  (e.kind == 1 || e.kind == 3) &&
  (
    e.action == "approach" ||
    e.action == "windup" ||
    e.action == "active" ||
    e.action == "reset"
  ) &&
  (p.x - e.x) * e.facing > 0.0
}

///|
pub fn Enemy::braced(self : Enemy) -> Bool {
  self.hp > 0 &&
  (self.kind == 1 || self.kind == 3) &&
  (self.action == "windup" || self.action == "active" || self.action == "reset")
}

///|
pub fn Enemy::open(self : Enemy) -> Bool {
  self.hp > 0 && (self.action == "recover" || self.action == "stunned")
}

///|
pub fn Game::resolve_strike(self : Game) -> Unit {
  let p = self.player
  let heavy = p.action == "breaker"
  let finisher = !heavy && p.combo == 2
  let reach = if heavy { 105.0 } else if finisher { 100.0 } else { 88.0 }
  for e in self.enemies {
    let forward = (e.x - p.x) * p.facing
    if e.hp <= 0 ||
      e.last_hit == p.serial ||
      forward < -8.0 ||
      forward > reach ||
      (e.z - p.z).abs() > 28.0 {
      continue
    }
    e.last_hit = p.serial
    if guarded(e, p) && (!heavy || e.braced()) {
      self.blocks += 1
      self.hit_stop = 3
      self.effect(e.x - e.facing * 15.0, e.z - 38.0, "block")
      continue
    }
    let broke = guarded(e, p) && heavy && e.kind == 1
    e.hp = (e.hp - self.damage * (if heavy || finisher { 2 } else { 1 })).max(0)
    e.flash = 10
    e.x = clamp(
      e.x +
      p.facing * (if finisher { 62.0 } else if heavy { 24.0 } else { 12.0 }),
      self.stage.to_double() * 760.0 + 24.0,
      self.gate_x() - 25.0,
    )
    if e.hp == 0 {
      e.action = "down"
      e.death_age = 0
      self.score += if e.kind == 3 { 1500 } else { 200 + e.kind * 100 }
    } else if e.kind != 3 && e.action != "stunned" && e.action != "recover" {
      e.action = "stunned"
      e.timer = if broke { 40 } else if heavy || finisher { 28 } else { 13 }
      e.phase_total = e.timer
    }
    self.hits += 1
    self.chain += 1
    self.chain_timer = 120
    self.best_combo = self.best_combo.max(self.chain)
    self.score += if broke { 80 } else { 30 }
    self.hit_stop = if heavy || finisher { 8 } else { 5 }
    self.shake = if heavy || finisher { 9 } else { 4 }
    self.effect(
      e.x - p.facing * 18.0,
      e.z - 42.0,
      if broke {
        "break"
      } else if heavy || finisher {
        "heavy"
      } else {
        "hit"
      },
    )
  }
}

///|
pub fn Game::hurt_player(
  self : Game,
  damage : Int32,
  direction : Double,
) -> Unit {
  let p = self.player
  if p.invulnerable > 0 || self.mode != "playing" {
    return
  }
  p.hp = (p.hp - damage).max(0)
  p.action = "hurt"
  p.age = 0
  p.invulnerable = 76
  p.x = clamp(
    p.x + direction * 24.0,
    self.stage.to_double() * 760.0 + 20.0,
    self.gate_x() - 20.0,
  )
  self.taken += damage
  self.chain = 0
  self.hit_stop = 7
  self.shake = 12
  self.effect(p.x, p.z - 36.0, "hurt")
  if p.hp == 0 {
    self.set_mode("lost")
  }
}

///|
pub fn Game::update_enemies(self : Game) -> Unit {
  let mut occupied = self.enemies.any(e => {
    e.hp > 0 && (e.action == "windup" || e.action == "active" || e.quiet_beat())
  })
  for e in self.enemies {
    if e.hp <= 0 {
      e.death_age += 1
      continue
    }
    if e.flash > 0 {
      e.flash -= 1
    }
    if e.action == "windup" {
      e.timer -= 1
      if e.timer <= 0 {
        e.action = "active"
        e.timer = 9
        e.phase_total = 9
        let d = (self.player.x - e.x) * e.facing
        if d >= -12.0 &&
          d <= e.attack_reach() &&
          (self.player.z - e.aim_z).abs() <= e.attack_depth() {
          let hp = self.player.hp
          self.hurt_player(1, e.facing)
          e.attack_hit = self.player.hp < hp
        }
      }
      continue
    }
    if e.action == "active" ||
      e.action == "recover" ||
      e.action == "stunned" ||
      e.action == "reset" {
      e.timer -= 1
      if e.timer <= 0 {
        if e.action == "active" {
          // Whiffing opens a long counter window. Taking the hit cannot be
          // converted into the same free damage trade.
          let connected = e.attack_hit && (e.kind == 1 || e.kind == 3)
          e.action = if connected { "reset" } else { "recover" }
          e.timer = if connected {
            default_reaction_budget.guard_reset_frames()
          } else {
            e.recovery_frames()
          }
          e.phase_total = e.timer
        } else if e.action == "stunned" && e.kind == 1 && !occupied {
          // A broken guard grants one fixed opening, then a fully telegraphed
          // retaliation. Repeated hits cannot renew that opening forever.
          self.begin_enemy_attack(e)
          occupied = true
        } else {
          e.action = "approach"
          e.timer = 16
          e.phase_total = 16
        }
      }
      continue
    }
    e.timer = (e.timer - 1).max(0)
    let dx = self.player.x - e.x
    let dz = self.player.z - e.z
    e.facing = if dx < 0.0 { -1.0 } else { 1.0 }
    let speed = if e.kind == 2 {
      1.85
    } else if e.kind == 3 {
      0.95
    } else {
      1.2
    }
    if dx.abs() > 72.0 {
      e.x += clamp(dx, -speed, speed)
    }
    e.z += clamp(dz, -speed * 0.6, speed * 0.6)
    if !occupied && dx.abs() <= 96.0 && dz.abs() <= 29.0 && e.timer == 0 {
      self.begin_enemy_attack(e)
      occupied = true
    }
  }
}

///|
fn Game::begin_enemy_attack(self : Game, e : Enemy) -> Unit {
  e.action = "windup"
  e.facing = if self.player.x < e.x { -1 } else { 1 }
  e.aim_z = self.player.z
  e.timer = e.windup_frames(self.windup)
  e.phase_total = e.timer
  e.attack_hit = false
}
