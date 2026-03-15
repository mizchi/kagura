// Enemy AI: chase + pathfinding + patrol + ranged + boss

///|
fn enemy_margin_aware_waypoint(
  grid : @terrain.Grid2D,
  wp : @terrain.Point,
  entity_half : Double,
) -> (Double, Double) {
  let cx = wp.x.to_double() * tile_size + tile_size / 2.0
  let cy = wp.y.to_double() * tile_size + tile_size / 2.0
  let margin = entity_half + 1.0
  let mut ox = 0.0
  let mut oy = 0.0
  if wp.x > 0 && grid.get(wp.x - 1, wp.y) == @terrain.Wall {
    let wall_edge = wp.x.to_double() * tile_size
    let desired = wall_edge + margin
    if cx < desired {
      ox = ox + (desired - cx)
    }
  }
  if wp.x + 1 < grid.width && grid.get(wp.x + 1, wp.y) == @terrain.Wall {
    let wall_edge = (wp.x + 1).to_double() * tile_size
    let desired = wall_edge - margin
    if cx > desired {
      ox = ox - (cx - desired)
    }
  }
  if wp.y > 0 && grid.get(wp.x, wp.y - 1) == @terrain.Wall {
    let wall_edge = wp.y.to_double() * tile_size
    let desired = wall_edge + margin
    if cy < desired {
      oy = oy + (desired - cy)
    }
  }
  if wp.y + 1 < grid.height && grid.get(wp.x, wp.y + 1) == @terrain.Wall {
    let wall_edge = (wp.y + 1).to_double() * tile_size
    let desired = wall_edge - margin
    if cy > desired {
      oy = oy - (cy - desired)
    }
  }
  (cx + ox, cy + oy)
}

///|
fn enemy_direct_chase_path_blocked(
  grid : @terrain.Grid2D,
  enemy_x : Double,
  enemy_y : Double,
  target_x : Double,
  target_y : Double,
  enemy_size : Double,
) -> Bool {
  not(
    @physics2d.grid_line_of_sight_clear(
      grid, enemy_x, enemy_y, target_x, target_y, enemy_size, tile_size,
    ),
  )
}

///|
fn update_enemy_bolt_castup(
  enemy : Enemy,
  projectiles : Array[Projectile],
  events : Array[GameEvent],
  player : Player,
  params : BalanceParams,
  floor : Int,
) -> Bool {
  if enemy.pending_bolt_timer <= 0 {
    return false
  }
  enemy.pending_bolt_timer = enemy.pending_bolt_timer - 1
  enemy.vx = 0.0
  enemy.vy = 0.0
  if enemy.pending_bolt_timer == 0 {
    let cdx = enemy.pending_bolt_target_x - enemy.x
    let cdy = enemy.pending_bolt_target_y - enemy.y
    let dist_sq = cdx * cdx + cdy * cdy
    match enemy.kind {
      Ranged =>
        if dist_sq > 0.000001 {
          let dist = dist_sq.sqrt()
          let base_angle = @math.atan2(cdy, cdx)
          let center = enemy_barrage_projectile_count / 2
          let bolt_damage = params.scale_enemy_damage_for_floor(
            params.enemy_bolt_damage_int(),
            floor,
          )
          for idx = 0; idx < enemy_barrage_projectile_count; idx = idx + 1 {
            let offset = (idx - center).to_double()
            let angle = base_angle + offset * enemy_barrage_spread_angle
            let bspeed = 2.0
            projectiles.push({
              x: enemy.x,
              y: enemy.y,
              vx: @math.cos(angle) * bspeed,
              vy: @math.sin(angle) * bspeed,
              age: 0,
              alive: true,
              damage: bolt_damage,
              is_player: false,
              kind: EnemyBolt,
            })
          }
        }
      Tank | Boss => {
        events.push(FireballBurst(enemy.x, enemy.y))
        let damage = params.scale_enemy_damage_for_floor(
          @cmp.maximum(1, params.enemy_bolt_damage_int() - 1),
          floor,
        )
        for idx = 0; idx < enemy_fire_nova_projectile_count; idx = idx + 1 {
          let angle = idx.to_double() *
            (2.0 * @math.PI / enemy_fire_nova_projectile_count.to_double())
          projectiles.push({
            x: enemy.x,
            y: enemy.y,
            vx: @math.cos(angle) * enemy_fire_nova_projectile_speed,
            vy: @math.sin(angle) * enemy_fire_nova_projectile_speed,
            age: 0,
            alive: true,
            damage,
            is_player: false,
            kind: EnemyBolt,
          })
        }
        let pdx = player.x - enemy.x
        let pdy = player.y - enemy.y
        if pdx * pdx + pdy * pdy <=
          enemy_fire_nova_radius * enemy_fire_nova_radius {
          events.push(PlayerHurt(player.x, player.y))
        }
      }
      _ => ()
    }
  }
  true
}

///|
fn start_enemy_tackle(
  enemy : Enemy,
  player : Player,
  events : Array[GameEvent],
) -> Unit {
  enemy.charge_cooldown = 120
  enemy.charge_timer = enemy_tackle_telegraph_frames +
    enemy_tackle_active_frames
  enemy.pending_bolt_target_x = player.x
  enemy.pending_bolt_target_y = player.y
  events.push(GroundTelegraphLine(enemy.x, enemy.y, player.x, player.y))
  events.push(
    EnemyTelegraphRing(player.x, player.y, enemy_tackle_telegraph_radius),
  )
}

///|
fn update_enemy_tackle(enemy : Enemy) -> Bool {
  if enemy.charge_timer <= 0 {
    return false
  }
  enemy.charge_timer = enemy.charge_timer - 1
  if enemy.charge_timer >= enemy_tackle_active_frames {
    enemy.vx = 0.0
    enemy.vy = 0.0
    return true
  }
  let dx = enemy.pending_bolt_target_x - enemy.x
  let dy = enemy.pending_bolt_target_y - enemy.y
  let dist_sq = dx * dx + dy * dy
  if dist_sq > 0.000001 {
    let dist = dist_sq.sqrt()
    enemy.vx = dx / dist * enemy.speed * enemy_tackle_speed_mult
    enemy.vy = dy / dist * enemy.speed * enemy_tackle_speed_mult
  } else {
    enemy.vx = 0.0
    enemy.vy = 0.0
  }
  true
}

///|
fn try_start_enemy_fire_nova(
  enemy : Enemy,
  player : Player,
  events : Array[GameEvent],
) -> Bool {
  let dx = player.x - enemy.x
  let dy = player.y - enemy.y
  if dx * dx + dy * dy >
    enemy_fire_nova_trigger_range * enemy_fire_nova_trigger_range {
    return false
  }
  if enemy.shoot_cooldown > 0 || enemy.pending_bolt_timer > 0 {
    return false
  }
  enemy.shoot_cooldown = enemy_fire_nova_cooldown_frames
  enemy.pending_bolt_timer = enemy_fire_nova_cast_frames
  enemy.pending_bolt_target_x = player.x
  enemy.pending_bolt_target_y = player.y
  events.push(EnemyTelegraphRing(enemy.x, enemy.y, enemy_fire_nova_radius))
  true
}

///|
fn try_start_enemy_tackle(
  enemy : Enemy,
  player : Player,
  events : Array[GameEvent],
) -> Bool {
  if enemy.charge_cooldown > 0 || enemy.charge_timer > 0 {
    return false
  }
  let dx = player.x - enemy.x
  let dy = player.y - enemy.y
  if dx * dx + dy * dy > enemy_tackle_trigger_range * enemy_tackle_trigger_range {
    return false
  }
  start_enemy_tackle(enemy, player, events)
  true
}

///|
fn tick_enemy_pattern_cooldowns(enemy : Enemy) -> Unit {
  if enemy.shoot_cooldown > 0 {
    enemy.shoot_cooldown = enemy.shoot_cooldown - 1
  }
  if enemy.charge_cooldown > 0 {
    enemy.charge_cooldown = enemy.charge_cooldown - 1
  }
}

///|
pub fn update_enemy_ai(
  enemies : Array[Enemy],
  player : Player,
  grid : @terrain.Grid2D,
  rooms : Array[@terrain.Room],
  frame_count : Int,
  projectiles : Array[Projectile],
  events : Array[GameEvent],
  params? : BalanceParams = BalanceParams::default(),
  floor? : Int = 1,
) -> Unit {
  let player_tile_x = (player.x / tile_size).to_int()
  let player_tile_y = (player.y / tile_size).to_int()
  let player_room = find_room_at(rooms, player.x, player.y)
  let chase_range_sq = params.chase_range * params.chase_range
  for enemy in enemies {
    if not(enemy.alive) {
      continue
    }
    // Meteor casting: channeled, interruptible by killing the caster
    if enemy.meteor_cast_timer > 0 {
      enemy.meteor_cast_timer = enemy.meteor_cast_timer - 1
      enemy.vx = 0.0
      enemy.vy = 0.0
      // Frequent telegraph pulses for high visibility (every 10 frames)
      if enemy.meteor_cast_timer % 10 == 0 && enemy.meteor_cast_timer > 0 {
        // Outer ring (full radius)
        events.push(
          EnemyTelegraphRing(
            enemy.meteor_target_x,
            enemy.meteor_target_y,
            meteor_radius,
          ),
        )
        // Inner ring (shrinks as cast progresses = urgency)
        let progress = 1.0 -
          enemy.meteor_cast_timer.to_double() / meteor_cast_frames.to_double()
        let inner_radius = meteor_radius * (1.0 - progress * 0.7)
        events.push(
          EnemyTelegraphRing(
            enemy.meteor_target_x,
            enemy.meteor_target_y,
            inner_radius,
          ),
        )
        // Line from caster to target
        events.push(
          GroundTelegraphLine(
            enemy.x,
            enemy.y,
            enemy.meteor_target_x,
            enemy.meteor_target_y,
          ),
        )
      }
      if enemy.meteor_cast_timer == 0 {
        events.push(
          MeteorImpact(
            enemy.meteor_target_x,
            enemy.meteor_target_y,
            meteor_radius,
          ),
        )
        enemy.shoot_cooldown = meteor_cooldown_frames
      }
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if update_enemy_bolt_castup(
        enemy, projectiles, events, player, params, floor,
      ) {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if update_enemy_tackle(enemy) {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    let cdx = player.x - enemy.x
    let cdy = player.y - enemy.y
    let dist_sq = cdx * cdx + cdy * cdy
    let enemy_room = find_room_at(rooms, enemy.x, enemy.y)
    let same_room_visible = player_room >= 0 && enemy_room == player_room
    match enemy.kind {
      Boss => {
        if try_start_enemy_fire_nova(enemy, player, events) {
          tick_enemy_pattern_cooldowns(enemy)
          continue
        }
        if try_start_enemy_tackle(enemy, player, events) {
          tick_enemy_pattern_cooldowns(enemy)
          continue
        }
      }
      Tank =>
        if try_start_enemy_fire_nova(enemy, player, events) {
          tick_enemy_pattern_cooldowns(enemy)
          continue
        }
      Fast | Exploder =>
        // Exploder always charges toward player; Fast uses tackle
        if try_start_enemy_tackle(enemy, player, events) {
          tick_enemy_pattern_cooldowns(enemy)
          continue
        }
      Berserker => {
        // Berserker gets faster as HP decreases
        let hp_ratio = enemy.hp.to_double() /
          enemy.max_hp.to_double().max(1.0)
        let rage_mult = 1.0 + (1.0 - hp_ratio) * 1.5
        enemy.vx = enemy.vx * rage_mult
        enemy.vy = enemy.vy * rage_mult
        if try_start_enemy_tackle(enemy, player, events) {
          tick_enemy_pattern_cooldowns(enemy)
          continue
        }
      }
      Summoner =>
        // Summoner behavior: uses ranged attack pattern (handled below)
        ()
      Teleporter => {
        // Teleport behind player every 3 seconds
        if enemy.shoot_cooldown <= 0 && dist_sq < chase_range_sq {
          let behind_angle = @math.atan2(
              -cdy,
              -cdx,
            ) +
            0.3
          let tp_dist = 30.0
          let new_x = player.x + @math.cos(behind_angle) * tp_dist
          let new_y = player.y + @math.sin(behind_angle) * tp_dist
          if not(
              check_wall_collision(
                grid,
                new_x,
                new_y,
                enemy.size,
              ),
            ) {
            enemy.x = new_x
            enemy.y = new_y
            events.push(DeathBurst(enemy.x, enemy.y))
          }
          enemy.shoot_cooldown = 180 // 3 second cooldown
        }
      }
      _ => ()
    }
    // Patrol if out of chase range
    if dist_sq > chase_range_sq {
      let angle = ((frame_count + enemy.x.to_int()) % 360).to_double() *
        @math.PI /
        180.0
      enemy.vx = @math.cos(angle) * enemy.speed * 0.3
      enemy.vy = @math.sin(angle) * enemy.speed * 0.3
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    // Caster: always tries to cast meteor when in range
    if enemy.kind == Caster &&
      enemy.shoot_cooldown <= 0 &&
      dist_sq < chase_range_sq &&
      dist_sq > 900.0 { // 30^2 - minimum distance
      enemy.meteor_cast_timer = meteor_cast_frames
      enemy.meteor_target_x = player.x
      enemy.meteor_target_y = player.y
      events.push(MeteorCastStart(player.x, player.y, meteor_radius))
      events.push(EnemyTelegraphRing(player.x, player.y, meteor_radius))
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    // Summoner: periodically spawn a Basic minion
    if enemy.kind == Summoner &&
      enemy.shoot_cooldown <= 0 &&
      dist_sq < chase_range_sq {
      enemy.shoot_cooldown = 240 // 4 seconds between summons
      let summon_x = enemy.x + ((frame_count * 17) % 20 - 10).to_double()
      let summon_y = enemy.y + ((frame_count * 13) % 20 - 10).to_double()
      let summon_hp = params.scale_enemy_hp_for_floor(
        params.basic_hp.to_int(),
        floor,
      )
      let summon_speed = params.scale_enemy_speed_for_floor(
        params.enemy_speed_basic,
        floor,
      )
      enemies.push(make_enemy(summon_x, summon_y, Swarm, summon_hp / 2, summon_speed * 1.2, 6.0))
      events.push(DeathBurst(enemy.x, enemy.y))
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    // Ranged enemy: shoot or cast meteor if in range
    if enemy.kind == Ranged && dist_sq > 3600.0 { // 60.0^2
      if dist_sq > 0.000001 {
        let dist = dist_sq.sqrt()
        if enemy.shoot_cooldown <= 0 {
          // 25% chance to cast meteor instead of normal barrage
          let meteor_roll = (frame_count * 31 + enemy.x.to_int() * 7) % 100
          if meteor_roll < 25 {
            // Start meteor cast
            enemy.meteor_cast_timer = meteor_cast_frames
            enemy.meteor_target_x = player.x
            enemy.meteor_target_y = player.y
            events.push(
              MeteorCastStart(player.x, player.y, meteor_radius),
            )
            events.push(
              EnemyTelegraphRing(player.x, player.y, meteor_radius),
            )
            tick_enemy_pattern_cooldowns(enemy)
            continue
          }
          enemy.shoot_cooldown = params.ranged_shot_cooldown_frames()
          enemy.pending_bolt_timer = enemy_bolt_telegraph_frames
          enemy.pending_bolt_target_x = player.x
          enemy.pending_bolt_target_y = player.y
          events.push(GroundTelegraphLine(enemy.x, enemy.y, player.x, player.y))
          events.push(
            EnemyTelegraphRing(player.x, player.y, enemy_bolt_telegraph_radius),
          )
        }
        // Ranged enemies don't chase when shooting, slight retreat
        enemy.vx = -(cdx / dist) * enemy.speed * 0.3
        enemy.vy = -(cdy / dist) * enemy.speed * 0.3
      }
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    tick_enemy_pattern_cooldowns(enemy)
    if same_room_visible && dist_sq > 1.0 {
      let dist = dist_sq.sqrt()
      if not(
          enemy_direct_chase_path_blocked(
            grid,
            enemy.x,
            enemy.y,
            player.x,
            player.y,
            enemy.size,
          ),
        ) {
        let chase_vx = cdx / dist * enemy.speed
        let chase_vy = cdy / dist * enemy.speed
        enemy.path_cache = []
        enemy.path_index = 0
        enemy.path_timer = path_update_interval
        enemy.vx = chase_vx
        enemy.vy = chase_vy
        continue
      }
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
      let (tx, ty) = enemy_margin_aware_waypoint(
        grid, target, enemy.size / 2.0,
      )
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
