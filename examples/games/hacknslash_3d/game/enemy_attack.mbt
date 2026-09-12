///|
pub(all) enum EnemyAttackMotion {
  NoAttack
  Punch
  SpearThrust
  CastSpell
  BowShot
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
    (enemy.attack_motion == Punch || enemy.attack_motion == SpearThrust) {
    enemy.attack_hit_pending = true
  }
  if enemy.attack_frame > enemy.attack_windup + enemy.attack_recovery {
    enemy.attack_motion = NoAttack
  }
}

///|
fn try_start_enemy_melee(
  enemy : Enemy,
  player : Player,
  grid : @terrain.Grid2D,
) -> Bool {
  if enemy.attack_cooldown > 0 {
    return false
  }
  let motion = match enemy.kind {
    Fast | Teleporter => SpearThrust
    Basic | Swarm | Tank | Berserker => Punch
    _ => return false
  }
  let range = if motion == SpearThrust { 26.0 } else { 16.0 }
  let dx = player.x - enemy.x
  let dy = player.y - enemy.y
  if dx * dx + dy * dy > range * range ||
    enemy_direct_chase_path_blocked(
      grid,
      enemy.x,
      enemy.y,
      player.x,
      player.y,
      1.0,
    ) {
    return false
  }
  let windup = if motion == SpearThrust { 24 } else { 18 }
  let recovery = if motion == SpearThrust { 24 } else { 22 }
  enemy.begin_attack(motion, windup, recovery, player.x, player.y)
  enemy.attack_cooldown = windup + recovery + 18
  true
}

///|
fn enemy_melee_hits(
  enemy : Enemy,
  player : Player,
  grid : @terrain.Grid2D,
) -> Bool {
  if check_wall_collision(grid, enemy.x, enemy.y, 1.0) ||
    check_wall_collision(grid, player.x, player.y, 1.0) {
    return false
  }
  let dx = player.x - enemy.x
  let dy = player.y - enemy.y
  let ax = enemy.attack_target_x - enemy.x
  let ay = enemy.attack_target_y - enemy.y
  let len = (ax * ax + ay * ay).sqrt()
  let reach = if enemy.attack_motion == SpearThrust { 30.0 } else { 18.0 }
  let width = if enemy.attack_motion == SpearThrust { 7.0 } else { 10.0 }
  if len > 0.001 {
    let forward = (dx * ax + dy * ay) / len
    let lateral = (dx * ay - dy * ax).abs() / len
    if forward < -player.size / 4.0 ||
      forward > reach ||
      lateral > width + player.size / 2.0 {
      return false
    }
  } else if dx * dx + dy * dy > width * width {
    return false
  }
  !enemy_direct_chase_path_blocked(
    grid,
    enemy.x,
    enemy.y,
    player.x,
    player.y,
    1.0,
  )
}
