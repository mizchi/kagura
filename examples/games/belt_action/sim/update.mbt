///|
fn Game::follow_camera(self : Game) -> Unit {
  let target = clamp(self.player.x - 320.0, 0.0, 2280.0 - 960.0 + 100.0)
  self.camera += (target - self.camera) * 0.12
}

///|
pub fn Game::step(self : Game, input : Input) -> Unit {
  let pause = input.pause && !self.previous_pause
  let evade = input.evade && !self.previous_evade
  let retry = input.retry && !self.previous_retry
  let start = input.start && !self.previous_start
  let strike = input.strike && !self.previous_strike
  self.previous_pause = input.pause
  self.previous_evade = input.evade
  self.previous_retry = input.retry
  self.previous_start = input.start
  self.previous_strike = input.strike
  if self.mode == "title" {
    if input.start || input.strike || input.breaker || input.evade {
      self.start()
    } else {
      return
    }
  } else if (self.mode == "lost" || self.mode == "cleared") &&
    (start || retry || strike) {
    self.start()
    return
  }
  if retry {
    self.start()
    return
  }
  if self.mode == "paused" && start {
    self.set_mode("playing")
  }
  if pause {
    self.set_mode(if self.mode == "paused" {
      "playing"
    } else if self.mode == "playing" {
      "paused"
    } else {
      self.mode
    })
  }
  if self.mode != "playing" {
    return
  }
  self.frames += 1
  let p = self.player
  let amount = (input.x * input.x + input.z * input.z).sqrt().max(1.0)
  let x = clamp(input.x / amount, -1.0, 1.0)
  let z = clamp(input.z / amount, -1.0, 1.0)
  if evade {
    p.evade_buffer = 12
    p.evade_x = if x.abs() + z.abs() < 0.1 { -p.facing } else { x }
    p.evade_z = z
  }
  if input.strike || input.breaker {
    p.buffer = 7
    p.heavy_buffer = input.breaker
  }
  for b in self.bursts {
    b.age += 1
  }
  for i = self.bursts.length() - 1; i >= 0; i = i - 1 {
    if self.bursts[i].age > 20 {
      ignore(self.bursts.remove(i))
    }
  }
  if self.shake > 0 {
    self.shake -= 1
  }
  if self.hit_stop > 0 {
    self.hit_stop -= 1
    return
  }
  self.tick += 1
  if self.announce > 0 {
    self.announce -= 1
  }
  if p.invulnerable > 0 {
    p.invulnerable -= 1
  }
  if p.evade_cooldown > 0 {
    p.evade_cooldown -= 1
  }
  if p.combo_timer > 0 {
    p.combo_timer -= 1
  }
  if self.chain_timer > 0 {
    self.chain_timer -= 1
  } else {
    self.chain = 0
  }
  if p.evade_buffer > 0 &&
    p.evade_cooldown == 0 &&
    (
      p.action == "idle" ||
      (p.action == "strike" && p.age >= 10) ||
      (p.action == "breaker" && p.age >= 20)
    ) {
    p.action = "evade"
    p.age = 0
    p.evade_cooldown = 58
    p.evade_buffer = 0
    p.invulnerable = 14
    self.dodges += 1
    self.effect(p.x, p.z, "evade")
  }
  if p.action == "idle" {
    if x.abs() > 0.1 {
      p.facing = if x < 0.0 { -1.0 } else { 1.0 }
    }
    p.x += x * 3.4
    p.z += z * 2.3
    if p.buffer > 0 {
      self.begin_attack(p.heavy_buffer)
    }
  } else {
    p.age += 1
    if p.action == "strike" {
      if p.age >= 4 && p.age <= 7 {
        self.resolve_strike()
      }
      if p.age <= 6 {
        p.x += p.facing * 1.5
      }
      if p.age >= 19 {
        p.action = "idle"
      }
    } else if p.action == "breaker" {
      if p.age >= 13 && p.age <= 16 {
        self.resolve_strike()
      }
      if p.age >= 10 && p.age <= 15 {
        p.x += p.facing * 2.4
      }
      if p.age >= 36 {
        p.action = "idle"
      }
    } else if p.action == "evade" {
      p.x += p.evade_x * (if p.age < 12 { 6.5 } else { 2.2 })
      p.z += p.evade_z * (if p.age < 12 { 5.2 } else { 1.6 })
      if p.age >= 18 {
        p.action = "idle"
      }
    } else if p.action == "hurt" && p.age >= 22 {
      p.action = "idle"
    }
  }
  if p.buffer > 0 {
    p.buffer -= 1
  }
  if p.evade_buffer > 0 {
    p.evade_buffer -= 1
  }
  p.x = clamp(
    p.x,
    self.stage.to_double() * 760.0 + 20.0,
    self.gate_x() - (if self.remaining() > 0 { 20.0 } else { 0.0 }),
  )
  p.z = clamp(p.z, 300.0, 445.0)
  self.update_enemies()
  if self.mode != "playing" {
    return
  }
  if self.remaining() == 0 {
    if self.stage == 2 {
      self.set_mode("cleared")
      self.effect(p.x, p.z - 55.0, "clear")
    } else if p.x >= self.gate_x() - 45.0 {
      self.stage += 1
      self.announce = 110
      p.x = self.stage.to_double() * 760.0 + 40.0
      self.spawn_stage()
      self.effect(p.x, p.z, "gate")
    }
  }
  self.follow_camera()
}
