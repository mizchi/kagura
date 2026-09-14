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
  !@physics2d.grid_line_of_sight_clear(
    grid, enemy_x, enemy_y, target_x, target_y, enemy_size, tile_size,
  )
}

///|
fn update_enemy_bolt_castup(
  enemy : Enemy,
  projectiles : Array[Projectile],
  events : Array[GameEvent],
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
          projectiles.push({
            x: enemy.x,
            y: enemy.y,
            vx: cdx / dist * 3.0,
            vy: cdy / dist * 3.0,
            age: 0,
            alive: true,
            damage: params.scale_enemy_damage_for_floor(
              params.enemy_bolt_damage_int(),
              floor,
            ),
            is_player: false,
            kind: Arrow,
          })
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
        events.push(
          EnemyAreaDamage(enemy.x, enemy.y, enemy_fire_nova_radius, damage),
        )
      }
      _ => ()
    }
  }
  true
}

///|
fn start_enemy_tackle(
  enemy : Enemy,
  target : CombatTarget,
  events : Array[GameEvent],
) -> Unit {
  enemy.charge_cooldown = 120
  enemy.charge_timer = enemy_charge_profile.duration()
  let dx = target.x - enemy.x
  let dy = target.y - enemy.y
  let length = (dx * dx + dy * dy).sqrt().max(0.001)
  // Extend the committed aim ray so passing the original target cannot reverse the lunge.
  enemy.begin_attack(
    Charge,
    enemy_charge_profile.windup,
    enemy_charge_profile.active + enemy_charge_profile.recovery,
    enemy.x + dx / length * 10000.0,
    enemy.y + dy / length * 10000.0,
  )
  enemy.pending_bolt_target_x = target.x
  enemy.pending_bolt_target_y = target.y
  events.push(GroundTelegraphLine(enemy.x, enemy.y, target.x, target.y))
  events.push(
    EnemyTelegraphRing(target.x, target.y, enemy_tackle_telegraph_radius),
  )
}

///|
fn update_enemy_tackle(enemy : Enemy) -> Bool {
  if enemy.attack_motion != Charge {
    return false
  }
  enemy.charge_timer = (enemy_charge_profile.duration() - enemy.attack_frame).max(
    0,
  )
  if !enemy.is_charging() {
    enemy.vx = 0.0
    enemy.vy = 0.0
    return true
  }
  let dx = enemy.attack_target_x - enemy.x
  let dy = enemy.attack_target_y - enemy.y
  let dist = (dx * dx + dy * dy).sqrt().max(0.001)
  enemy.vx = dx / dist * enemy.speed * enemy_tackle_speed_mult
  enemy.vy = dy / dist * enemy.speed * enemy_tackle_speed_mult
  true
}

///|
fn try_start_enemy_fire_nova(
  enemy : Enemy,
  target : CombatTarget,
  events : Array[GameEvent],
) -> Bool {
  let dx = target.x - enemy.x
  let dy = target.y - enemy.y
  if dx * dx + dy * dy >
    enemy_fire_nova_trigger_range * enemy_fire_nova_trigger_range {
    return false
  }
  if enemy.shoot_cooldown > 0 || enemy.pending_bolt_timer > 0 {
    return false
  }
  enemy.shoot_cooldown = enemy_fire_nova_cooldown_frames
  enemy.begin_attack(
    CastSpell,
    enemy_fire_nova_cast_frames,
    22,
    target.x,
    target.y,
  )
  enemy.pending_bolt_timer = enemy_fire_nova_cast_frames
  enemy.pending_bolt_target_x = target.x
  enemy.pending_bolt_target_y = target.y
  events.push(EnemyTelegraphRing(enemy.x, enemy.y, enemy_fire_nova_radius))
  true
}

///|
fn try_start_enemy_tackle(
  enemy : Enemy,
  target : CombatTarget,
  events : Array[GameEvent],
) -> Bool {
  if enemy.charge_cooldown > 0 || enemy.charge_timer > 0 {
    return false
  }
  let dx = target.x - enemy.x
  let dy = target.y - enemy.y
  if dx * dx + dy * dy > enemy_tackle_trigger_range * enemy_tackle_trigger_range {
    return false
  }
  start_enemy_tackle(enemy, target, events)
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
  zombies? : Array[SummonedZombie] = [],
) -> Unit {
  let chase_range_sq = params.chase_range * params.chase_range
  update_enemy_camps(enemies, player, grid, zombies)
  for enemy in enemies {
    if !enemy.alive {
      continue
    }
    if enemy.camp is Some(camp) && camp.awareness != Alert {
      enemy.vx = 0.0
      enemy.vy = 0.0
      continue
    }
    if enemy.stagger_frames > 0 {
      enemy.stagger_frames -= 1
      enemy.vx = 0.0
      enemy.vy = 0.0
      continue
    }
    tick_enemy_attack(enemy)
    // Meteor casting: channeled, interruptible by killing the caster
    if enemy.meteor_cast_timer > 0 {
      enemy.meteor_cast_timer = enemy.meteor_cast_timer - 1
      enemy.vx = 0.0
      enemy.vy = 0.0
      // Persistent telegraph marker handles visualization;
      // no per-frame pulse events needed
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
    // Beam charging: channeled, fires on completion
    if enemy.beam_cast_timer > 0 {
      enemy.beam_cast_timer = enemy.beam_cast_timer - 1
      enemy.vx = 0.0
      enemy.vy = 0.0
      if enemy.beam_cast_timer == 0 {
        // Beam fires!
        events.push(
          BeamFire(
            enemy.x,
            enemy.y,
            enemy.beam_target_x,
            enemy.beam_target_y,
            false,
          ),
        )
      }
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if update_enemy_bolt_castup(enemy, projectiles, events, params, floor) {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if update_zombie_pounce(enemy) {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if update_enemy_tackle(enemy) {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if enemy.attack_motion != NoAttack {
      if enemy.kind == Summoner && enemy.attack_frame == enemy.attack_windup {
        spawn_summoned_minion(
          enemy, enemies, params, floor, frame_count, events,
        )
      }
      enemy.vx = 0.0
      enemy.vy = 0.0
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    let target = enemy_aggro_target(enemy, player, zombies, grid)
    let player_tile_x = (target.x / tile_size).to_int()
    let player_tile_y = (target.y / tile_size).to_int()
    let player_room = find_room_at(rooms, target.x, target.y)
    let cdx = target.x - enemy.x
    let cdy = target.y - enemy.y
    let dist_sq = cdx * cdx + cdy * cdy
    let enemy_room = find_room_at(rooms, enemy.x, enemy.y)
    let same_room_visible = player_room >= 0 && enemy_room == player_room
    // Patrol if out of chase range (BEFORE behavior dispatch)
    if dist_sq > chase_range_sq {
      if enemy.camp is Some(_) {
        enemy.vx = 0.0
        enemy.vy = 0.0
        tick_enemy_pattern_cooldowns(enemy)
        continue
      }
      let angle = ((frame_count + enemy.x.to_int()) % 360).to_double() *
        @math.PI /
        180.0
      enemy.vx = @math.cos(angle) * enemy.speed * 0.3
      enemy.vy = @math.sin(angle) * enemy.speed * 0.3
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    // Ranged actors create casting room instead of walking into harmless contact.
    if (enemy.kind == Ranged || enemy.kind == Caster) &&
      dist_sq < ranged_min_distance_sq &&
      dist_sq > 0.000001 {
      let dist = dist_sq.sqrt()
      enemy.vx = -cdx / dist * enemy.speed
      enemy.vy = -cdy / dist * enemy.speed
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    if try_start_zombie_pounce(enemy, target, grid, events) ||
      try_start_enemy_melee(enemy, target, grid, events) {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    // Dispatch special behaviors (only when in chase range)
    let ctx : EnemyAIContext = {
      enemy,
      target,
      grid,
      enemies,
      projectiles,
      events,
      params,
      floor,
      frame_count,
      dist_sq,
      chase_range_sq,
      same_room_visible,
    }
    let behaviors = get_special_behaviors(enemy.kind)
    let mut behavior_consumed = false
    for behavior in behaviors {
      if behavior(ctx) {
        behavior_consumed = true
        break
      }
    }
    if behavior_consumed {
      tick_enemy_pattern_cooldowns(enemy)
      continue
    }
    tick_enemy_pattern_cooldowns(enemy)
    if same_room_visible && dist_sq > 1.0 {
      let dist = dist_sq.sqrt()
      if !enemy_direct_chase_path_blocked(
          grid,
          enemy.x,
          enemy.y,
          target.x,
          target.y,
          enemy.size,
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
    if enemy.path_cache.last() is Some(goal) &&
      (goal.x != player_tile_x || goal.y != player_tile_y) {
      enemy.path_timer = 0
    }
    // Update pathfinding cache periodically
    if enemy.path_timer <= 0 {
      enemy.path_timer = path_update_interval
      let enemy_tile_x = (enemy.x / tile_size).to_int()
      let enemy_tile_y = (enemy.y / tile_size).to_int()
      let start : @terrain.Point = { x: enemy_tile_x, y: enemy_tile_y, }
      let goal : @terrain.Point = { x: player_tile_x, y: player_tile_y, }
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
      let (tx, ty) = enemy_margin_aware_waypoint(grid, target, enemy.size / 2.0)
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
