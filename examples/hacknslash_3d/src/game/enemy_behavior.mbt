// Enemy behavior patterns: composable actions for easy enemy type creation
// Each behavior is a function that returns true if it consumed the frame.

///|
pub(all) struct EnemyAIContext {
  enemy : Enemy
  player : Player
  grid : @terrain.Grid2D
  enemies : Array[Enemy]
  projectiles : Array[Projectile]
  events : Array[GameEvent]
  params : BalanceParams
  floor : Int
  frame_count : Int
  dist_sq : Double
  chase_range_sq : Double
  same_room_visible : Bool
}

// === Reusable behavior actions ===

///|
pub fn behavior_fire_nova(ctx : EnemyAIContext) -> Bool {
  try_start_enemy_fire_nova(ctx.enemy, ctx.player, ctx.events)
}

///|
pub fn behavior_tackle(ctx : EnemyAIContext) -> Bool {
  try_start_enemy_tackle(ctx.enemy, ctx.player, ctx.events)
}

///|
pub fn behavior_berserker_rage(ctx : EnemyAIContext) -> Bool {
  let hp_ratio = ctx.enemy.hp.to_double() /
    ctx.enemy.max_hp.to_double().max(1.0)
  let rage_mult = 1.0 + (1.0 - hp_ratio) * berserker_rage_max_mult
  ctx.enemy.vx = ctx.enemy.vx * rage_mult
  ctx.enemy.vy = ctx.enemy.vy * rage_mult
  false // doesn't consume frame, just modifies velocity
}

///|
pub fn behavior_teleport_behind(ctx : EnemyAIContext) -> Bool {
  if ctx.enemy.shoot_cooldown > 0 || ctx.dist_sq >= ctx.chase_range_sq {
    return false
  }
  let cdx = ctx.player.x - ctx.enemy.x
  let cdy = ctx.player.y - ctx.enemy.y
  let behind_angle = @math.atan2(-cdy, -cdx) + teleporter_angle_offset
  let tp_dist = teleporter_blink_distance
  let new_x = ctx.player.x + @math.cos(behind_angle) * tp_dist
  let new_y = ctx.player.y + @math.sin(behind_angle) * tp_dist
  if not(check_wall_collision(ctx.grid, new_x, new_y, ctx.enemy.size)) {
    ctx.enemy.x = new_x
    ctx.enemy.y = new_y
    ctx.events.push(DeathBurst(ctx.enemy.x, ctx.enemy.y))
  }
  ctx.enemy.shoot_cooldown = teleporter_blink_cooldown
  true
}

///|
pub fn behavior_cast_meteor(ctx : EnemyAIContext) -> Bool {
  if ctx.enemy.shoot_cooldown > 0 ||
    ctx.dist_sq >= ctx.chase_range_sq ||
    ctx.dist_sq < caster_min_distance_sq {
    return false
  }
  ctx.enemy.meteor_cast_timer = meteor_cast_frames
  ctx.enemy.meteor_target_x = ctx.player.x
  ctx.enemy.meteor_target_y = ctx.player.y
  ctx.events.push(MeteorCastStart(ctx.player.x, ctx.player.y, meteor_radius))
  ctx.events.push(
    EnemyTelegraphRing(ctx.player.x, ctx.player.y, meteor_radius),
  )
  true
}

///|
pub fn behavior_summon_minion(ctx : EnemyAIContext) -> Bool {
  if ctx.enemy.shoot_cooldown > 0 || ctx.dist_sq >= ctx.chase_range_sq {
    return false
  }
  ctx.enemy.shoot_cooldown = summoner_cooldown
  let summon_x = ctx.enemy.x +
    ((ctx.frame_count * 17) % (summoner_spawn_offset * 2) - summoner_spawn_offset).to_double()
  let summon_y = ctx.enemy.y +
    ((ctx.frame_count * 13) % (summoner_spawn_offset * 2) - summoner_spawn_offset).to_double()
  let summon_hp = ctx.params.scale_enemy_hp_for_floor(
    ctx.params.basic_hp.to_int(),
    ctx.floor,
  )
  let summon_speed = ctx.params.scale_enemy_speed_for_floor(
    ctx.params.enemy_speed_basic,
    ctx.floor,
  )
  ctx.enemies.push(
    make_enemy(summon_x, summon_y, Swarm, summon_hp / 2, summon_speed * summoner_minion_speed_mult, summoner_minion_size),
  )
  ctx.events.push(DeathBurst(ctx.enemy.x, ctx.enemy.y))
  true
}

///|
pub fn behavior_ranged_barrage(ctx : EnemyAIContext) -> Bool {
  if ctx.dist_sq <= ranged_min_distance_sq || ctx.dist_sq < 0.000001 {
    return false
  }
  let dist = ctx.dist_sq.sqrt()
  if ctx.enemy.shoot_cooldown > 0 {
    // Slight retreat while on cooldown
    let cdx = ctx.player.x - ctx.enemy.x
    let cdy = ctx.player.y - ctx.enemy.y
    ctx.enemy.vx = -(cdx / dist) * ctx.enemy.speed * ranged_retreat_speed
    ctx.enemy.vy = -(cdy / dist) * ctx.enemy.speed * ranged_retreat_speed
    return true
  }
  // Chance to cast meteor instead of barrage
  let meteor_roll = (ctx.frame_count * 31 + ctx.enemy.x.to_int() * 7) % 100
  if meteor_roll < ranged_meteor_chance {
    return behavior_cast_meteor(ctx)
  }
  ctx.enemy.shoot_cooldown = ctx.params.ranged_shot_cooldown_frames()
  ctx.enemy.pending_bolt_timer = enemy_bolt_telegraph_frames
  ctx.enemy.pending_bolt_target_x = ctx.player.x
  ctx.enemy.pending_bolt_target_y = ctx.player.y
  ctx.events.push(
    GroundTelegraphLine(
      ctx.enemy.x, ctx.enemy.y, ctx.player.x, ctx.player.y,
    ),
  )
  ctx.events.push(
    EnemyTelegraphRing(
      ctx.player.x, ctx.player.y, enemy_bolt_telegraph_radius,
    ),
  )
  let cdx = ctx.player.x - ctx.enemy.x
  let cdy = ctx.player.y - ctx.enemy.y
  ctx.enemy.vx = -(cdx / dist) * ctx.enemy.speed * ranged_retreat_speed
  ctx.enemy.vy = -(cdy / dist) * ctx.enemy.speed * ranged_retreat_speed
  true
}

// === Behavior dispatch per enemy kind ===

///|
pub fn get_special_behaviors(
  kind : EnemyKind,
) -> Array[(EnemyAIContext) -> Bool] {
  match kind {
    Boss => [behavior_fire_nova, behavior_tackle]
    Tank => [behavior_fire_nova]
    Fast | Exploder => [behavior_tackle]
    Berserker => [behavior_berserker_rage, behavior_tackle]
    Teleporter => [behavior_teleport_behind]
    Caster => [behavior_cast_meteor]
    Summoner => [behavior_summon_minion]
    Ranged => [behavior_ranged_barrage]
    Basic | Swarm => []
  }
}
