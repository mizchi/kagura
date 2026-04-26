// Enemy AI: chase + pathfinding + patrol + ranged + boss

///|
fn update_enemy_ai(
  enemies : Array[Enemy],
  player : Player,
  grid : @terrain.Grid2D,
  frame_count : Int,
  projectiles : Array[Projectile],
) -> Unit {
  let player_tile_x = (player.x / tile_size).to_int()
  let player_tile_y = (player.y / tile_size).to_int()
  for enemy in enemies {
    if !enemy.alive {
      continue
    }
    let cdx = player.x - enemy.x
    let cdy = player.y - enemy.y
    let dist = (cdx * cdx + cdy * cdy).sqrt()
    // Boss charge logic
    if enemy.kind == kind_boss {
      if enemy.charge_timer > 0 {
        enemy.charge_timer = enemy.charge_timer - 1
        // Continue charging in set direction
        continue
      }
      if dist < chase_range && enemy.charge_cooldown <= 0 {
        // Initiate charge
        enemy.charge_cooldown = 120
        enemy.charge_timer = 20
        if dist > 0.001 {
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
    if dist > chase_range {
      let angle = ((frame_count + enemy.x.to_int()) % 360).to_double() *
        3.14159 /
        180.0
      enemy.vx = @math.cos(angle) * enemy.speed * 0.3
      enemy.vy = @math.sin(angle) * enemy.speed * 0.3
      continue
    }
    // Ranged enemy: shoot if in range but far enough
    if enemy.kind == kind_ranged && dist > 60.0 {
      if enemy.shoot_cooldown <= 0 {
        enemy.shoot_cooldown = 120
        if dist > 0.001 {
          let bspeed = 2.0
          projectiles.push({
            x: enemy.x,
            y: enemy.y,
            vx: cdx / dist * bspeed,
            vy: cdy / dist * bspeed,
            alive: true,
            damage: 1,
          })
        }
      }
      // Ranged enemies don't chase when shooting, slight retreat
      if dist > 0.001 {
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
    } else if dist > 1.0 {
      // Direct chase fallback
      enemy.vx = cdx / dist * enemy.speed
      enemy.vy = cdy / dist * enemy.speed
    }
  }
}
