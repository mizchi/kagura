///|
/// Read-only targeting footprint. AI does not need ownership or mutable player state.
pub(all) struct CombatTarget {
  x : Double
  y : Double
  size : Double
}

///|
pub fn Player::combat_target(self : Player) -> CombatTarget {
  { x: self.x, y: self.y, size: self.size, }
}

///|
pub fn Enemy::combat_target(self : Enemy) -> CombatTarget {
  { x: self.x, y: self.y, size: self.size, }
}

///|
fn enemy_aggro_target(
  enemy : Enemy,
  player : Player,
  zombies : Array[SummonedZombie],
  grid : @terrain.Grid2D,
) -> CombatTarget {
  let mut target = player.combat_target()
  let mut nearest = summoned_zombie_taunt_radius * summoned_zombie_taunt_radius
  for zombie in zombies {
    let ally = zombie.body
    let dx = ally.x - enemy.x
    let dy = ally.y - enemy.y
    let distance = dx * dx + dy * dy
    if ally.alive &&
      distance < nearest &&
      !enemy_direct_chase_path_blocked(
        grid,
        enemy.x,
        enemy.y,
        ally.x,
        ally.y,
        1.0,
      ) {
      target = ally.combat_target()
      nearest = distance
    }
  }
  target
}

///|
/// First contact along a swept projectile, including an origin inside the circle.
fn segment_circle_contact(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
  x : Double,
  y : Double,
  radius : Double,
) -> Double? {
  let dx = x1 - x0
  let dy = y1 - y0
  let px = x0 - x
  let py = y0 - y
  let c = px * px + py * py - radius * radius
  if c <= 0.0 {
    return Some(0.0)
  }
  let a = dx * dx + dy * dy
  if a < 0.000001 {
    return None
  }
  let b = px * dx + py * dy
  let discriminant = b * b - a * c
  if discriminant < 0.0 {
    return None
  }
  let t = (-b - discriminant.sqrt()) / a
  if t >= 0.0 && t <= 1.0 {
    Some(t)
  } else {
    None
  }
}
