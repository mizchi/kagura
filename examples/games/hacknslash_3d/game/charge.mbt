///|
/// Gameplay frames and normalized animation phases are shared by both rigs.
pub(all) struct ChargeProfile {
  windup : Int
  active : Int
  recovery : Int
}

///|
pub let player_charge_profile : ChargeProfile = {
  windup: 12,
  active: 12,
  recovery: 18,
}

///|
pub let enemy_charge_profile : ChargeProfile = {
  windup: enemy_tackle_telegraph_frames,
  active: enemy_tackle_active_frames,
  recovery: 16,
}

///|
pub let player_charge_cooldown : Int = 180

///|
pub fn ChargeProfile::duration(self : ChargeProfile) -> Int {
  self.windup + self.active + self.recovery
}

///|
pub fn ChargeProfile::is_active(self : ChargeProfile, frame : Int) -> Bool {
  frame >= self.windup && frame < self.windup + self.active
}

///|
pub fn ChargeProfile::phase(self : ChargeProfile, frame : Int) -> Double {
  if frame <= self.windup {
    0.3 * frame.max(0).to_double() / self.windup.to_double()
  } else if frame <= self.windup + self.active {
    0.3 + 0.4 * (frame - self.windup).to_double() / self.active.to_double()
  } else {
    (0.7 +
    0.3 *
    (frame - self.windup - self.active).to_double() /
    self.recovery.to_double()).min(1.0)
  }
}

///|
pub(all) struct PlayerCharge {
  angle : Double
  mut frame : Int
  // Enemy array indices remain stable until the floor changes, which cancels charge.
  hit_enemies : Array[Int]
}

///|
pub fn GameWorld::request_charge(self : GameWorld, angle : Double) -> Bool {
  if self.hunter_action_locked() ||
    self.mode != Playing ||
    self.ui_mode != UIMode::None ||
    self.player.hp <= 0 ||
    self.charge_cooldown > 0 ||
    self.player_charge is Some(_) ||
    self.weapon_attack is Some(_) ||
    self.attack_timer > 0 ||
    self.player.dash_timer > 0 {
    return false
  }
  self.player_charge = Some({ angle, frame: 0, hit_enemies: [], })
  self.charge_cooldown = player_charge_cooldown
  self.player.facing_angle = angle
  true
}

///|
pub fn GameWorld::tick_player_charge(
  self : GameWorld,
  grid : @terrain.Grid2D,
) -> Unit {
  guard self.player_charge is Some(charge) else { return }
  if self.player.dash_timer > 0 || self.player.hp <= 0 {
    self.player_charge = None
    return
  }
  charge.frame += 1
  self.player.facing_angle = charge.angle
  let profile = player_charge_profile
  if profile.is_active(charge.frame) {
    let speed = self.params.player_speed * 3.5
    let steps = speed.ceil().to_int().max(1)
    let dx = @math.cos(charge.angle) * speed / steps.to_double()
    let dy = @math.sin(charge.angle) * speed / steps.to_double()
    for _ in 0..<steps {
      let x = self.player.x + dx
      let y = self.player.y + dy
      if check_wall_collision(grid, x, y, self.player.size) {
        charge.frame = profile.windup + profile.active
        break
      }
      self.player.x = x
      self.player.y = y
      for i, enemy in self.enemies {
        if !enemy.alive || charge.hit_enemies.contains(i) {
          continue
        }
        let reach = (self.player.size + enemy.size) / 2.0 + 3.0
        let ex = enemy.x - x
        let ey = enemy.y - y
        if ex * ex + ey * ey <= reach * reach &&
          !enemy_direct_chase_path_blocked(grid, x, y, enemy.x, enemy.y, 1.0) {
          charge.hit_enemies.push(i)
          apply_player_damage_to_enemy(
            self,
            enemy,
            (self.player_stats.atk * 2).max(1),
            x,
            y,
          )
        }
      }
    }
    if charge.frame % 3 == 0 {
      self.events.push(DashTrail(self.player.x, self.player.y))
    }
  }
  if charge.frame >= profile.duration() {
    self.player_charge = None
  }
}

///|
pub fn Enemy::is_charging(self : Enemy) -> Bool {
  self.attack_motion == Charge &&
  enemy_charge_profile.is_active(self.attack_frame)
}

///|
fn Enemy::stop_charge(self : Enemy) -> Unit {
  self.attack_frame = enemy_charge_profile.windup + enemy_charge_profile.active
  self.charge_timer = enemy_charge_profile.recovery
  self.vx = 0.0
  self.vy = 0.0
}
