///|
/// Homing is opt-in per projectile kind; all timing uses 60 Hz simulation ticks.
pub(all) struct ProjectileHomingProfile {
  seek_range : Double
  min_alignment : Double
  turn_radians : Double
  delay_frames : Int
  lifetime : Int
}

///|
let magic_homing_profile : ProjectileHomingProfile = {
  seek_range: 112.0,
  min_alignment: 0.0,
  turn_radians: 0.06,
  delay_frames: 4,
  lifetime: 90,
}

///|
let missile_homing_profile : ProjectileHomingProfile = {
  seek_range: homing_missile_seek_range,
  min_alignment: -1.0,
  turn_radians: homing_missile_turn_rate,
  delay_frames: 0,
  lifetime: homing_missile_lifetime,
}

///|
pub fn ProjectileKind::homing_profile(
  self : ProjectileKind,
) -> ProjectileHomingProfile? {
  match self {
    Fireball(_) => Some(magic_homing_profile)
    HomingMissile => Some(missile_homing_profile)
    _ => None
  }
}

///|
fn GameWorld::steer_projectile(
  self : GameWorld,
  p : Projectile,
  profile : ProjectileHomingProfile,
) -> Unit {
  if p.age < profile.delay_frames {
    return
  }
  let (index, _) = @physics2d.grid_find_nearest_visible_candidate_index(
    self.dungeon.grid,
    p.x,
    p.y,
    0.0,
    profile.seek_range,
    self.enemies.length(),
    fn(index) {
      let enemy = self.enemies[index]
      if !enemy.alive {
        return false
      }
      if profile.min_alignment <= -1.0 {
        return true
      }
      let dx = enemy.x - p.x
      let dy = enemy.y - p.y
      let dot = dx * p.vx + dy * p.vy
      if profile.min_alignment == 0.0 {
        return dot >= 0.0
      }
      dot >=
      profile.min_alignment *
      ((dx * dx + dy * dy) * (p.vx * p.vx + p.vy * p.vy)).sqrt()
    },
    fn(index) { self.enemies[index].x },
    fn(index) { self.enemies[index].y },
    tile_size,
  )
  if index < 0 {
    return
  }
  let target = self.enemies[index]
  let (vx, vy) = @gameplay2d.turn_velocity_towards(
    p.vx,
    p.vy,
    target.x - p.x,
    target.y - p.y,
    profile.turn_radians,
  )
  p.vx = vx
  p.vy = vy
}
