///|
pub let zombie_pounce_anticipation : Int = 36

///|
pub let zombie_pounce_flight : Int = 14

///|
pub let zombie_pounce_recovery : Int = 40

///|
pub let zombie_pounce_range : Double = 60.0

///|
pub let zombie_stride_distance : Double = 16.0

///|
pub(all) struct EnemyPounce {
  dx : Double
  dy : Double
  distance : Double
  landing_x : Double
  landing_y : Double
}

///|
fn try_start_zombie_pounce(
  enemy : Enemy,
  target : CombatTarget,
  grid : @terrain.Grid2D,
  events : Array[GameEvent],
) -> Bool {
  if enemy.kind != Zombie || enemy.attack_cooldown > 0 {
    return false
  }
  let dx = target.x - enemy.x
  let dy = target.y - enemy.y
  let distance = (dx * dx + dy * dy).sqrt()
  if distance > zombie_pounce_range ||
    distance < 0.01 ||
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
  let profile = Pounce.melee_profile().unwrap()
  enemy.begin_attack(
    Pounce,
    profile.windup,
    profile.recovery,
    enemy.x + dx / distance * 10000.0,
    enemy.y + dy / distance * 10000.0,
  )
  let travel = (distance - 10.0).max(0.0).min(44.0)
  enemy.pounce = Some({
    dx: dx / distance,
    dy: dy / distance,
    distance: travel,
    landing_x: enemy.x + dx / distance * travel,
    landing_y: enemy.y + dy / distance * travel,
  })
  enemy.attack_cooldown = profile.windup + profile.recovery + 45
  events.push(EnemyMeleeWarning(enemy.x, enemy.y))
  true
}

///|
pub fn Enemy::pounce_airborne(self : Enemy) -> Bool {
  self.attack_motion == Pounce &&
  self.pounce is Some(_) &&
  self.attack_frame > zombie_pounce_anticipation &&
  self.attack_frame <= self.attack_windup
}

///|
fn update_zombie_pounce(enemy : Enemy) -> Bool {
  if enemy.attack_motion != Pounce {
    return false
  }
  enemy.vx = 0.0
  enemy.vy = 0.0
  if enemy.pounce_airborne() {
    let leap = enemy.pounce.unwrap()
    enemy.vx = leap.dx * leap.distance / zombie_pounce_flight.to_double()
    enemy.vy = leap.dy * leap.distance / zombie_pounce_flight.to_double()
  }
  true
}

///|
fn Enemy::stop_pounce(self : Enemy) -> Unit {
  self.pounce = None
  self.attack_frame = self.attack_windup
  self.attack_hit_pending = false
  self.vx = 0.0
  self.vy = 0.0
}

///|
/// Uneven forward progress: push with one leg, then drag the other. Never advances a blocked gait.
fn zombie_shuffle_speed(enemy : Enemy) -> Double {
  let phase = enemy.travel_distance / zombie_stride_distance
  let cycle = phase - phase.floor()
  if cycle < 0.5 {
    1.0
  } else {
    0.35
  }
}
