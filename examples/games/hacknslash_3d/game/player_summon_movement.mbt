///|
fn GameWorld::move_summoned_body(
  self : GameWorld,
  body : Enemy,
  vx : Double,
  vy : Double,
  grid : @terrain.Grid2D,
) -> Unit {
  let (x, y) = slide_move(grid, body.x, body.y, vx, vy, body.size)
  if body.pounce_airborne() &&
    ((x - body.x - vx).abs() > 0.01 || (y - body.y - vy).abs() > 0.01) {
    body.stop_pounce()
  }
  let dx = x - body.x
  let dy = y - body.y
  body.move_speed = (dx * dx + dy * dy).sqrt()
  if body.move_speed > 0.001 {
    body.move_angle = @math.atan2(dy, dx)
    body.travel_distance += body.move_speed
  }
  body.x = x
  body.y = y
  body.vx = 0.0
  body.vy = 0.0
}

///|
fn GameWorld::move_summoned_zombie(
  self : GameWorld,
  body : Enemy,
  tx : Double,
  ty : Double,
  following : Bool,
  grid : @terrain.Grid2D,
) -> Unit {
  let dx = tx - body.x
  let dy = ty - body.y
  let distance = (dx * dx + dy * dy).sqrt()
  if following && distance > 320.0 {
    let (x, y) = self.zombie_spawn_point()
    body.x = x
    body.y = y
    body.path_cache.clear()
    body.path_timer = 0
    return
  }
  if distance < (if following { 28.0 } else { 12.0 }) {
    body.move_speed = 0.0
    return
  }
  let mut goal_x = tx
  let mut goal_y = ty
  if enemy_direct_chase_path_blocked(grid, body.x, body.y, tx, ty, body.size) {
    if body.path_timer <= 0 {
      body.path_timer = 30
      body.path_index = 1
      body.path_cache = @pathfind.find_path(
        grid,
        { x: (body.x / tile_size).to_int(), y: (body.y / tile_size).to_int(), },
        { x: (tx / tile_size).to_int(), y: (ty / tile_size).to_int(), },
      ).unwrap_or([])
    }
    body.path_timer -= 1
    if body.path_index < body.path_cache.length() {
      let (x, y) = enemy_margin_aware_waypoint(
        grid,
        body.path_cache[body.path_index],
        body.size / 2.0,
      )
      goal_x = x
      goal_y = y
      if (x - body.x).abs() + (y - body.y).abs() < 6.0 {
        body.path_index += 1
      }
    }
  }
  let gx = goal_x - body.x
  let gy = goal_y - body.y
  let length = (gx * gx + gy * gy).sqrt().max(0.001)
  let speed = body.speed *
    zombie_shuffle_speed(body) *
    (if following && distance > 80.0 { 2.0 } else { 1.0 })
  self.move_summoned_body(body, gx / length * speed, gy / length * speed, grid)
}

///|
fn GameWorld::resolve_summon_separation(self : GameWorld) -> Unit {
  for index, zombie in self.summons.zombies {
    if !zombie.body.alive {
      continue
    }
    for enemy in self.enemies {
      if enemy.alive {
        resolve_creature_pair(zombie.body, enemy, self.dungeon.grid)
      }
    }
    for other in 0..<index {
      if self.summons.zombies[other].body.alive {
        resolve_creature_pair(
          zombie.body,
          self.summons.zombies[other].body,
          self.dungeon.grid,
        )
      }
    }
  }
}
