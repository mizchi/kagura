///|
pub fn PlayerWeaponKind::is_melee(self : PlayerWeaponKind) -> Bool {
  self == Cleaver || self == Spear || self == Knuckles
}

///|
/// Prefer aim alignment, then distance. Never pull an attack backwards or through cover.
pub fn GameWorld::melee_lock_target(
  self : GameWorld,
  angle : Double,
  weapon : PlayerWeaponKind,
) -> Enemy? {
  if !weapon.is_melee() {
    return None
  }
  let range = weapon.profile().reach + 12.0
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  let mut target : Enemy? = None
  let mut score = 10000.0
  for enemy in self.enemies {
    if !enemy.alive {
      continue
    }
    let dx = enemy.x - self.player.x
    let dy = enemy.y - self.player.y
    let dist = (dx * dx + dy * dy).sqrt()
    if dist < 0.001 || dist > range {
      continue
    }
    let alignment = (dx * c + dy * s) / dist
    if alignment < 0.5 ||
      enemy_direct_chase_path_blocked(
        self.dungeon.grid,
        self.player.x,
        self.player.y,
        enemy.x,
        enemy.y,
        1.0,
      ) {
      continue
    }
    let candidate = dist / range + (1.0 - alignment) * 1.5
    if candidate < score {
      score = candidate
      target = Some(enemy)
    }
  }
  target
}

///|
pub fn GameWorld::assist_melee_angle(
  self : GameWorld,
  angle : Double,
  weapon : PlayerWeaponKind,
) -> Double {
  match self.melee_lock_target(angle, weapon) {
    Some(enemy) => @math.atan2(enemy.y - self.player.y, enemy.x - self.player.x)
    None => angle
  }
}

///|
fn apply_melee_reaction(
  enemy : Enemy,
  weapon : PlayerWeaponKind,
  angle : Double,
  combo? : CleaverComboStep = Opening,
) -> Unit {
  if !enemy.alive {
    return
  }
  let heavy = enemy.kind == Tank || enemy.kind == Boss
  let force = (match weapon {
      Cleaver => if combo == Finisher { 5.5 } else { 3.8 }
      Spear => 3.2
      _ => 2.3
    }) *
    (if heavy { 0.3 } else { 1.0 })
  enemy.knockback_x = @math.cos(angle) * force
  enemy.knockback_y = @math.sin(angle) * force
  if !heavy {
    enemy.stagger_frames = if weapon == Knuckles {
      6
    } else if weapon == Cleaver && combo == Finisher {
      14
    } else {
      10
    }
    enemy.attack_motion = NoAttack
    enemy.attack_hit_pending = false
    enemy.pending_bolt_timer = 0
    enemy.meteor_cast_timer = 0
    enemy.beam_cast_timer = 0
    enemy.charge_timer = 0
    enemy.attack_cooldown = enemy.attack_cooldown.max(enemy.stagger_frames + 10)
  }
}

///|
fn GameWorld::step_into_melee(
  self : GameWorld,
  attack : PlayerWeaponAttack,
) -> Unit {
  if !attack.weapon.is_melee() {
    return
  }
  let windup = attack.profile().windup
  let step_frames = if attack.weapon == Cleaver { 4 } else { 3 }
  if attack.frame < windup - step_frames || attack.frame >= windup {
    return
  }
  let mut step = match attack.weapon {
    Spear => 2.0
    Knuckles => 1.2
    Cleaver => if attack.combo == Finisher { 1.4 } else { 2.5 }
    _ => 1.6
  }
  let c = @math.cos(attack.angle)
  let s = @math.sin(attack.angle)
  // Limit the swept body against every living enemy, not just the chosen target.
  for enemy in self.enemies {
    if !enemy.alive {
      continue
    }
    let dx = enemy.x - self.player.x
    let dy = enemy.y - self.player.y
    let forward = dx * c + dy * s
    let lateral = (dx * s - dy * c).abs()
    let radius = (self.player.size + enemy.size) / 2.0 + 2.0
    if forward >= 0.0 && lateral < radius {
      let clearance = forward - (radius * radius - lateral * lateral).sqrt()
      step = step.min(clearance.max(0.0))
    }
  }
  let (x, y) = slide_move(
    self.dungeon.grid,
    self.player.x,
    self.player.y,
    @math.cos(attack.angle) * step,
    @math.sin(attack.angle) * step,
    self.player.size,
  )
  self.player.x = x
  self.player.y = y
}
