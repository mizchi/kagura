///|
pub(all) enum EnemyAttackMotion {
  NoAttack
  Pounce
  Punch
  Bite
  SpearThrust
  CastSpell
  BowShot
  Charge
} derive(Eq, Debug)

///|
/// Frame zero is anticipation. Impact is exactly windup; the remainder recovers.
pub fn Enemy::begin_attack(
  self : Enemy,
  motion : EnemyAttackMotion,
  windup : Int,
  recovery : Int,
  target_x : Double,
  target_y : Double,
) -> Unit {
  self.pounce = None
  self.attack_motion = motion
  self.attack_frame = 0
  self.attack_windup = windup
  self.attack_recovery = recovery
  self.attack_target_x = target_x
  self.attack_target_y = target_y
  self.attack_hit_pending = false
  self.vx = 0.0
  self.vy = 0.0
}

///|
/// Phase 0.5 is contact for every clip, regardless of gameplay cast duration.
pub fn Enemy::attack_phase(self : Enemy) -> Double {
  if self.attack_motion == Charge {
    return enemy_charge_profile.phase(self.attack_frame)
  }
  if self.attack_motion == NoAttack {
    return 0.0
  }
  if self.attack_frame <= self.attack_windup {
    0.5 *
    self.attack_frame.to_double() /
    self.attack_windup.to_double().max(1.0)
  } else {
    (0.5 +
    0.5 *
    (self.attack_frame - self.attack_windup).to_double() /
    self.attack_recovery.to_double().max(1.0)).min(1.0)
  }
}

///|
fn tick_enemy_attack(enemy : Enemy) -> Unit {
  enemy.attack_hit_pending = false
  if enemy.attack_cooldown > 0 {
    enemy.attack_cooldown -= 1
  }
  if enemy.attack_motion == NoAttack {
    return
  }
  enemy.attack_frame += 1
  if enemy.attack_frame == enemy.attack_windup &&
    enemy.attack_motion.melee_profile() is Some(_) {
    enemy.attack_hit_pending = true
  }
  if enemy.attack_frame > enemy.attack_windup + enemy.attack_recovery {
    enemy.attack_motion = NoAttack
    enemy.pounce = None
  }
}

///|
fn try_start_enemy_melee(
  enemy : Enemy,
  target : CombatTarget,
  grid : @terrain.Grid2D,
  events : Array[GameEvent],
) -> Bool {
  if enemy.attack_cooldown > 0 {
    return false
  }
  let motion = match enemy.kind {
    Wolf => Bite
    Fast | Teleporter => SpearThrust
    Basic | Swarm | Tank | Berserker => Punch
    _ => return false
  }
  let profile = motion.melee_profile().unwrap()
  let range = profile.reach - 2.0
  let dx = target.x - enemy.x
  let dy = target.y - enemy.y
  if dx * dx + dy * dy > range * range ||
    enemy_direct_chase_path_blocked(
      grid,
      enemy.x,
      enemy.y,
      target.x,
      target.y,
      1.0,
    ) {
    return false
  }
  let windup = profile.windup
  let recovery = profile.recovery
  enemy.begin_attack(motion, windup, recovery, target.x, target.y)
  enemy.attack_cooldown = windup + recovery + 18
  events.push(EnemyMeleeWarning(enemy.x, enemy.y))
  true
}

///|
fn enemy_melee_hits(
  enemy : Enemy,
  target : CombatTarget,
  grid : @terrain.Grid2D,
) -> Bool {
  if check_wall_collision(grid, enemy.x, enemy.y, 1.0) ||
    check_wall_collision(grid, target.x, target.y, 1.0) {
    return false
  }
  let dx = target.x - enemy.x
  let dy = target.y - enemy.y
  let ax = enemy.attack_target_x - enemy.x
  let ay = enemy.attack_target_y - enemy.y
  let len = (ax * ax + ay * ay).sqrt()
  guard enemy.attack_motion.melee_profile() is Some(profile) else {
    return false
  }
  let reach = profile.reach
  let width = profile.width
  if len > 0.001 {
    let forward = (dx * ax + dy * ay) / len
    let lateral = (dx * ay - dy * ax).abs() / len
    if forward < -target.size / 4.0 ||
      forward > reach ||
      lateral > width + target.size / 2.0 {
      return false
    }
  } else if dx * dx + dy * dy > width * width {
    return false
  }
  !enemy_direct_chase_path_blocked(
    grid,
    enemy.x,
    enemy.y,
    target.x,
    target.y,
    1.0,
  )
}

///|
/// One footprint and timing contract drives both the damage test and its ground warning.
pub(all) struct EnemyMeleeProfile {
  windup : Int
  recovery : Int
  reach : Double
  width : Double
}

///|
pub fn EnemyAttackMotion::melee_profile(
  self : EnemyAttackMotion,
) -> EnemyMeleeProfile? {
  match self {
    Pounce =>
      Some({
        windup: zombie_pounce_anticipation + zombie_pounce_flight,
        recovery: zombie_pounce_recovery,
        reach: 18.0,
        width: 10.0,
      })
    Bite => Some({ windup: 34, recovery: 30, reach: 24.0, width: 8.0, })
    Punch => Some({ windup: 32, recovery: 28, reach: 24.0, width: 12.0, })
    SpearThrust => Some({ windup: 40, recovery: 30, reach: 38.0, width: 7.0, })
    _ => None
  }
}
