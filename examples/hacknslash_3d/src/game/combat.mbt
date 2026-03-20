// Combat system: bow attack, damage, knockback

// Find nearest enemy in range for auto-aim (uses dist_sq to avoid sqrt)

///|
pub fn find_nearest_enemy(world : GameWorld, max_range : Double) -> Enemy? {
  let (index, _dist_sq) = @physics2d.grid_find_nearest_visible_candidate_index(
    world.dungeon.grid,
    world.player.x,
    world.player.y,
    0.0,
    max_range,
    world.enemies.length(),
    fn(idx) { world.enemies[idx].alive },
    fn(idx) { world.enemies[idx].x },
    fn(idx) { world.enemies[idx].y },
    tile_size,
  )
  if index >= 0 {
    Some(world.enemies[index])
  } else {
    None
  }
}

///|
fn find_nearest_enemy_index_from_point(
  world : GameWorld,
  source_x : Double,
  source_y : Double,
  max_range : Double,
) -> Int {
  let (nearest_idx, _nearest_dist_sq) = @physics2d.grid_find_nearest_visible_candidate_index(
    world.dungeon.grid,
    source_x,
    source_y,
    0.0,
    max_range,
    world.enemies.length(),
    fn(idx) { world.enemies[idx].alive },
    fn(idx) { world.enemies[idx].x },
    fn(idx) { world.enemies[idx].y },
    tile_size,
  )
  nearest_idx
}

///|
let spell_cast_attack_lock_frames = 18

///|
fn apply_spell_attack_lock(world : GameWorld) -> Unit {
  if world.attack_timer < spell_cast_attack_lock_frames {
    world.attack_timer = spell_cast_attack_lock_frames
  }
}

// Compute arrow velocity toward a target enemy or in facing direction

///|
pub fn aim_at(
  world : GameWorld,
  target : Enemy?,
  speed : Double,
) -> (Double, Double) {
  match target {
    Some(enemy) => {
      let edx = enemy.x - world.player.x
      let edy = enemy.y - world.player.y
      let dist = (edx * edx + edy * edy).sqrt()
      if dist > 0.001 {
        return (edx / dist * speed, edy / dist * speed)
      }
    }
    _ => ()
  }
  let a = world.player.facing_angle
  (@math.cos(a) * speed, @math.sin(a) * speed)
}

///|
fn homing_missile_target_direction(
  world : GameWorld,
  target : Enemy?,
) -> (Double, Double) {
  match target {
    Some(enemy) => {
      let dx = enemy.x - world.player.x
      let dy = enemy.y - world.player.y
      let dist_sq = dx * dx + dy * dy
      if dist_sq > 0.000001 {
        let dist = dist_sq.sqrt()
        return (dx / dist, dy / dist)
      }
    }
    _ => ()
  }
  let angle = world.player.facing_angle
  (@math.cos(angle), @math.sin(angle))
}

// Shoot an arrow toward the given target or in facing direction

///|
pub fn shoot_arrow(world : GameWorld, target : Enemy?) -> Unit {
  let stats = world.player_stats
  let crit_roll = (world.frame_count * 31 + world.seed * 7) % 100
  let is_crit = crit_roll.to_double() / 100.0 < stats.crit_chance
  let damage = if is_crit { stats.atk * 2 } else { stats.atk }
  let (vx, vy) = aim_at(world, target, world.params.arrow_speed)
  world.projectiles.push({
    x: world.player.x,
    y: world.player.y,
    vx,
    vy,
    age: 0,
    alive: true,
    damage,
    is_player: true,
    kind: Arrow,
  })
}

///|
let melee_slash_radius : Double = 28.0

///|
pub fn melee_slash(world : GameWorld) -> Unit {
  let stats = world.player_stats
  let crit_roll = (world.frame_count * 31 + world.seed * 7) % 100
  let is_crit = crit_roll.to_double() / 100.0 < stats.crit_chance
  let base_damage = if is_crit { stats.atk * 2 } else { stats.atk }
  let damage = (base_damage.to_double() * world.archetype.basic_attack_multiplier()).to_int().max(
    1,
  )
  let px = world.player.x
  let py = world.player.y
  let r_sq = melee_slash_radius * melee_slash_radius
  for enemy in world.enemies {
    if not(enemy.alive) {
      continue
    }
    let dx = enemy.x - px
    let dy = enemy.y - py
    if dx * dx + dy * dy <= r_sq + enemy.size * enemy.size {
      apply_player_damage_to_enemy(world, enemy, damage, px, py)
    }
  }
  world.events.push(MeleeSlash(px, py, melee_slash_radius))
}

///|
pub fn spawn_ground_item(
  world : GameWorld,
  x : Double,
  y : Double,
  kind : ItemKind,
) -> Unit {
  world.items.push({
    x,
    y,
    vx: 0.0,
    vy: 0.0,
    kind,
    alive: true,
    spawn_frame: world.frame_count,
  })
}

///|
fn apply_life_steal(world : GameWorld, damage : Int) -> Unit {
  if world.player_stats.life_steal <= 0.0 {
    return
  }
  let heal = (damage.to_double() * world.player_stats.life_steal).to_int()
  if heal <= 0 {
    return
  }
  world.player.hp = @cmp.minimum(
    world.player_stats.max_hp,
    world.player.hp + heal,
  )
}

///|
fn enemy_xp_reward(enemy : Enemy) -> Int {
  if enemy.kind == Boss {
    return 8
  }
  find_enemy_type_config(enemy.kind).xp_reward
}

///|
fn roll_drop_item_kind(world : GameWorld, item_seed : Int) -> ItemKind {
  let config = world.params.drop_table_config()
  let equipment_weight = @cmp.maximum(0, config.equipment_weight)
  let health_weight = @cmp.maximum(0, config.health_weight)
  let score_weight = @cmp.maximum(0, config.score_weight)
  let total_weight = equipment_weight + health_weight + score_weight
  let roll = if total_weight <= 0 {
    0
  } else {
    (item_seed * 37 % total_weight + total_weight) % total_weight
  }
  if roll < equipment_weight {
    Equipment(
      generate_item_with_profile_and_drop_config(
        item_seed,
        world.floor,
        world.params.get_affix_profile(),
        config,
      ),
    )
  } else if roll < equipment_weight + health_weight {
    Health
  } else {
    Score
  }
}

///|
fn apply_enemy_death_rewards(world : GameWorld, enemy : Enemy) -> Unit {
  world.events.push(DeathBurst(enemy.x, enemy.y))
  // Exploder: massive AoE on death (larger radius, more damage)
  if enemy.kind == Exploder {
    world.events.push(FireballBurst(enemy.x, enemy.y))
    world.events.push(FireballBurst(enemy.x, enemy.y))
    let explode_radius = enemy_death_explosion_radius * exploder_radius_mult
    let dx = world.player.x - enemy.x
    let dy = world.player.y - enemy.y
    if dx * dx + dy * dy <= explode_radius * explode_radius &&
      world.player.iframe_timer <= 0 {
      let explosion_damage = world.params.scale_enemy_damage_for_floor(
        world.params.enemy_contact_damage.to_int() * exploder_damage_mult,
        world.floor,
      )
      world.deal_player_damage(explosion_damage)
    }
    world.events.push(
      EnemyTelegraphRing(enemy.x, enemy.y, explode_radius),
    )
  }
  if enemy.kind == Tank || enemy.kind == Boss {
    world.events.push(FireballBurst(enemy.x, enemy.y))
    let dx = world.player.x - enemy.x
    let dy = world.player.y - enemy.y
    if dx * dx + dy * dy <=
      enemy_death_explosion_radius * enemy_death_explosion_radius &&
      world.player.iframe_timer <= 0 {
      let explosion_damage = world.params.scale_enemy_damage_for_floor(
        @cmp.maximum(1, world.params.enemy_contact_damage.to_int()),
        world.floor,
      )
      world.deal_player_damage(explosion_damage)
    }
    let bolt_damage = world.params.scale_enemy_damage_for_floor(
      @cmp.maximum(1, world.params.enemy_bolt_damage_int() - 1),
      world.floor,
    )
    for idx = 0; idx < enemy_death_explosion_projectile_count; idx = idx + 1 {
      let angle = idx.to_double() *
        (2.0 * @math.PI / enemy_death_explosion_projectile_count.to_double())
      world.projectiles.push({
        x: enemy.x,
        y: enemy.y,
        vx: @math.cos(angle) * enemy_fire_nova_projectile_speed,
        vy: @math.sin(angle) * enemy_fire_nova_projectile_speed,
        age: 0,
        alive: true,
        damage: bolt_damage,
        is_player: false,
        kind: EnemyBolt,
      })
    }
  }
  let kill_score = if enemy.kind == Boss { 100 } else { 10 }
  world.score = world.score + kill_score
  ignore(
    world.level_progress.add_xp(
      world.skills,
      world.archetype,
      world.build_policy,
      enemy_xp_reward(enemy),
      world.frame_count * 97 + world.floor * 13,
      world.params.levelup_config(),
    ),
  )
  let drop_seed = world.frame_count * 7 +
    enemy.x.to_int() * 13 +
    enemy.y.to_int() * 17
  // Drop chance: Boss always, Tank 80%, others 40%
  let drop_roll = (drop_seed * 31 + 17) % 100
  let drop_chance = if enemy.kind == Boss {
    100
  } else {
    find_enemy_type_config(enemy.kind).drop_chance
  }
  if drop_roll < drop_chance {
    let drop_count = if enemy.kind == Boss {
      3
    } else if enemy.kind == Tank {
      drop_seed % 2 + 1
    } else {
      1
    }
    for di = 0; di < drop_count; di = di + 1 {
      let item_seed = drop_seed + di * 31
      let angle = (item_seed % 628).to_double() / 100.0
      let scatter_speed = 1.5 + (item_seed % 100).to_double() / 100.0
      spawn_scatter_item(
        world,
        enemy.x,
        enemy.y,
        roll_drop_item_kind(world, item_seed + di * 13),
        angle,
        scatter_speed,
      )
    }
  }
  if world.level_progress.pending_choices > 0 {
    world.open_levelup_ui_if_needed()
  }
}

///|
fn apply_player_damage_to_enemy(
  world : GameWorld,
  enemy : Enemy,
  damage : Int,
  source_x : Double,
  source_y : Double,
) -> Unit {
  enemy.hp = enemy.hp - damage
  enemy.damage_timer = damage_flash_duration
  world.events.push(HitSparks(enemy.x, enemy.y))
  world.events.push(EnemyDamageNumber(enemy.x, enemy.y, damage))
  apply_life_steal(world, damage)
  let edx = source_x - enemy.x
  let edy = source_y - enemy.y
  let dist_sq = edx * edx + edy * edy
  if dist_sq > 0.001 {
    let dist = dist_sq.sqrt()
    enemy.vx = enemy.vx - edx / dist * world.params.knockback_strength
    enemy.vy = enemy.vy - edy / dist * world.params.knockback_strength
  }
  if enemy.hp <= 0 {
    enemy.alive = false
    apply_enemy_death_rewards(world, enemy)
  }
}
