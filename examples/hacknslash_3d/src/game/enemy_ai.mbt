// Enemy AI: chase + pathfinding + patrol + ranged + boss

///|
pub fn update_enemy_ai(
  enemies : Array[Enemy],
  player : Player,
  grid : @terrain.Grid2D,
  rooms : Array[@terrain.Room],
  frame_count : Int,
  projectiles : Array[Projectile],
  params? : BalanceParams = BalanceParams::default(),
) -> Unit {
  let player_tile_x = (player.x / tile_size).to_int()
  let player_tile_y = (player.y / tile_size).to_int()
  let player_room = find_room_at(rooms, player.x, player.y)
  let chase_range_sq = params.chase_range * params.chase_range
  for enemy in enemies {
    if not(enemy.alive) {
      continue
    }
    let cdx = player.x - enemy.x
    let cdy = player.y - enemy.y
    let dist_sq = cdx * cdx + cdy * cdy
    let enemy_room = find_room_at(rooms, enemy.x, enemy.y)
    let same_room_visible = player_room >= 0 && enemy_room == player_room
    // Boss charge logic
    if enemy.kind == Boss {
      if enemy.charge_timer > 0 {
        enemy.charge_timer = enemy.charge_timer - 1
        // Continue charging in set direction
        continue
      }
      if dist_sq < chase_range_sq && enemy.charge_cooldown <= 0 {
        // Initiate charge
        enemy.charge_cooldown = 120
        enemy.charge_timer = 20
        if dist_sq > 0.000001 {
          let dist = dist_sq.sqrt()
          enemy.vx = cdx / dist * enemy.speed * 3.0
          enemy.vy = cdy / dist * enemy.speed * 3.0
        }
        continue
      }
      if enemy.charge_cooldown > 0 {
        enemy.charge_cooldown = enemy.charge_cooldown - 1
      }
    }
    // Patrol if out of chase range
    if dist_sq > chase_range_sq {
      let angle = ((frame_count + enemy.x.to_int()) % 360).to_double() *
        @math.PI /
        180.0
      enemy.vx = @math.cos(angle) * enemy.speed * 0.3
      enemy.vy = @math.sin(angle) * enemy.speed * 0.3
      continue
    }
    // Ranged enemy: shoot if in range but far enough
    if enemy.kind == Ranged && dist_sq > 3600.0 { // 60.0^2
      if dist_sq > 0.000001 {
        let dist = dist_sq.sqrt()
        if enemy.shoot_cooldown <= 0 {
          enemy.shoot_cooldown = 120
          let bspeed = 2.0
          projectiles.push({
            x: enemy.x,
            y: enemy.y,
            vx: cdx / dist * bspeed,
            vy: cdy / dist * bspeed,
            alive: true,
            damage: 1,
            is_player: false,
          })
        }
        // Ranged enemies don't chase when shooting, slight retreat
        enemy.vx = -(cdx / dist) * enemy.speed * 0.3
        enemy.vy = -(cdy / dist) * enemy.speed * 0.3
      }
      if enemy.shoot_cooldown > 0 {
        enemy.shoot_cooldown = enemy.shoot_cooldown - 1
      }
      continue
    }
    if enemy.shoot_cooldown > 0 {
      enemy.shoot_cooldown = enemy.shoot_cooldown - 1
    }
    if same_room_visible && dist_sq > 1.0 {
      let dist = dist_sq.sqrt()
      enemy.path_cache = []
      enemy.path_index = 0
      enemy.path_timer = path_update_interval
      enemy.vx = cdx / dist * enemy.speed
      enemy.vy = cdy / dist * enemy.speed
      continue
    }
    // Update pathfinding cache periodically
    if enemy.path_timer <= 0 {
      enemy.path_timer = path_update_interval
      let enemy_tile_x = (enemy.x / tile_size).to_int()
      let enemy_tile_y = (enemy.y / tile_size).to_int()
      let start : @terrain.Point = { x: enemy_tile_x, y: enemy_tile_y }
      let goal : @terrain.Point = { x: player_tile_x, y: player_tile_y }
      match @pathfind.find_path(grid, start, goal) {
        Some(path) => {
          enemy.path_cache = path
          enemy.path_index = 1 // skip start tile
        }
        None => {
          enemy.path_cache = []
          enemy.path_index = 0
        }
      }
    } else {
      enemy.path_timer = enemy.path_timer - 1
    }
    // Movement: follow path or direct chase
    if enemy.path_cache.length() > 0 &&
      enemy.path_index < enemy.path_cache.length() {
      let target = enemy.path_cache[enemy.path_index]
      let tx = target.x.to_double() * tile_size + tile_size / 2.0
      let ty = target.y.to_double() * tile_size + tile_size / 2.0
      let pdx = tx - enemy.x
      let pdy = ty - enemy.y
      let pdist = (pdx * pdx + pdy * pdy).sqrt()
      if pdist < tile_size / 2.0 {
        // Reached waypoint, advance
        enemy.path_index = enemy.path_index + 1
      }
      if pdist > 0.001 {
        enemy.vx = pdx / pdist * enemy.speed
        enemy.vy = pdy / pdist * enemy.speed
      }
    } else if dist_sq > 1.0 {
      // Direct chase fallback
      let dist = dist_sq.sqrt()
      enemy.vx = cdx / dist * enemy.speed
      enemy.vy = cdy / dist * enemy.speed
    }
  }
}
