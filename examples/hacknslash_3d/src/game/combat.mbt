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
  match enemy.kind {
    Basic => 1
    Fast => 1
    Tank => 2
    Ranged => 2
    Boss => 8
  }
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
    world.level_progress.gain_xp(
      world.skills,
      enemy_xp_reward(enemy),
      world.frame_count * 97 + world.floor * 13,
      world.params.levelup_config(),
    ),
  )
  let drop_seed = world.frame_count * 7 +
    enemy.x.to_int() * 13 +
    enemy.y.to_int() * 17
  let drop_count = if enemy.kind == Boss { 5 } else { drop_seed % 3 + 1 }
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

///|
fn find_next_chain_target(
  world : GameWorld,
  source_x : Double,
  source_y : Double,
  chained_enemy_indices : Array[Int],
  max_range : Double,
) -> Int {
  let (nearest_index, _nearest_dist_sq) = @physics2d.grid_find_nearest_visible_candidate_index(
    world.dungeon.grid,
    source_x,
    source_y,
    0.0,
    max_range,
    world.enemies.length(),
    fn(index) {
      let enemy = world.enemies[index]
      if not(enemy.alive) {
        return false
      }
      for chained in chained_enemy_indices {
        if chained == index {
          return false
        }
      }
      true
    },
    fn(index) { world.enemies[index].x },
    fn(index) { world.enemies[index].y },
    tile_size,
  )
  nearest_index
}

///|
fn chain_lightning_feedback_endpoint(world : GameWorld) -> (Double, Double) {
  let angle = world.player.facing_angle
  let length = chain_lightning_range * 0.8
  (
    world.player.x + @math.cos(angle) * length,
    world.player.y + @math.sin(angle) * length,
  )
}

///|
fn chain_lightning_telegraph_endpoint(world : GameWorld) -> (Double, Double) {
  match find_nearest_enemy(world, chain_lightning_range) {
    Some(enemy) => (enemy.x, enemy.y)
    None => chain_lightning_feedback_endpoint(world)
  }
}

///|
fn splitting_fireball_telegraph_target(world : GameWorld) -> (Double, Double) {
  match find_nearest_enemy(world, chain_lightning_range) {
    Some(enemy) => (enemy.x, enemy.y)
    None => {
      let angle = world.player.facing_angle
      let length = chain_lightning_range * 0.7
      (
        world.player.x + @math.cos(angle) * length,
        world.player.y + @math.sin(angle) * length,
      )
    }
  }
}

///|
fn homing_missile_feedback_endpoint(world : GameWorld) -> (Double, Double) {
  let angle = world.player.facing_angle
  let length = homing_missile_range * 0.78
  (
    world.player.x + @math.cos(angle) * length,
    world.player.y + @math.sin(angle) * length,
  )
}

///|
fn homing_missile_telegraph_target(world : GameWorld) -> (Double, Double) {
  match find_nearest_enemy(world, homing_missile_range) {
    Some(enemy) => (enemy.x, enemy.y)
    None => homing_missile_feedback_endpoint(world)
  }
}

///|
fn has_spell_unlock(world : GameWorld, id : SkillId) -> Bool {
  world.skills.get_level(id) > 0
}

///|
pub fn cast_chain_lightning(world : GameWorld) -> Bool {
  if not(has_spell_unlock(world, ChainLightning)) {
    return false
  }
  if world.chain_lightning_cooldown_timer > 0 {
    return false
  }
  let (telegraph_x, telegraph_y) = chain_lightning_telegraph_endpoint(world)
  world.events.push(
    GroundTelegraphLine(
      world.player.x,
      world.player.y,
      telegraph_x,
      telegraph_y,
    ),
  )
  world.events.push(
    GroundTelegraphRing(
      telegraph_x, telegraph_y, chain_lightning_telegraph_radius,
    ),
  )
  let chained_enemy_indices : Array[Int] = []
  let mut arc_start_x = world.player.x
  let mut arc_start_y = world.player.y
  let damage = world.params.scale_spell_damage(world.player_stats.atk + 2)
  for _step = 0; _step < chain_lightning_max_targets; _step = _step + 1 {
    let next_index = find_next_chain_target(
      world,
      arc_start_x,
      arc_start_y,
      chained_enemy_indices,
      if chained_enemy_indices.is_empty() {
        chain_lightning_range
      } else {
        chain_lightning_hop_range
      },
    )
    if next_index < 0 {
      break
    }
    let enemy = world.enemies[next_index]
    world.events.push(
      ChainLightningArc(arc_start_x, arc_start_y, enemy.x, enemy.y),
    )
    apply_player_damage_to_enemy(world, enemy, damage, arc_start_x, arc_start_y)
    chained_enemy_indices.push(next_index)
    arc_start_x = enemy.x
    arc_start_y = enemy.y
  }
  if chained_enemy_indices.is_empty() {
    let (end_x, end_y) = chain_lightning_feedback_endpoint(world)
    world.events.push(
      ChainLightningArc(world.player.x, world.player.y, end_x, end_y),
    )
  }
  world.chain_lightning_cooldown_timer = world.params.chain_lightning_cooldown_frames()
  apply_spell_attack_lock(world)
  world.events.push(AttackTriggered)
  true
}

///|
pub fn cast_splitting_fireball(world : GameWorld) -> Bool {
  if not(has_spell_unlock(world, SplittingFireball)) {
    return false
  }
  if world.splitting_fireball_cooldown_timer > 0 {
    return false
  }
  let (telegraph_x, telegraph_y) = splitting_fireball_telegraph_target(world)
  world.events.push(
    GroundTelegraphLine(
      world.player.x,
      world.player.y,
      telegraph_x,
      telegraph_y,
    ),
  )
  world.events.push(
    GroundTelegraphRing(
      telegraph_x, telegraph_y, splitting_fireball_telegraph_radius,
    ),
  )
  let damage = world.params.scale_spell_damage(world.player_stats.atk + 2)
  let target = find_nearest_enemy(world, chain_lightning_range)
  let (vx, vy) = aim_at(world, target, world.params.arrow_speed * 0.8)
  world.projectiles.push({
    x: world.player.x,
    y: world.player.y,
    vx,
    vy,
    age: 0,
    alive: true,
    damage,
    is_player: true,
    kind: Fireball(1),
  })
  world.events.push(FireballCast(world.player.x, world.player.y))
  world.splitting_fireball_cooldown_timer = world.params.splitting_fireball_cooldown_frames()
  apply_spell_attack_lock(world)
  world.events.push(AttackTriggered)
  true
}

///|
pub fn cast_ice_nova(world : GameWorld) -> Bool {
  if not(has_spell_unlock(world, IceNova)) {
    return false
  }
  if world.ice_nova_cooldown_timer > 0 {
    return false
  }
  world.events.push(
    GroundTelegraphRing(world.player.x, world.player.y, ice_nova_radius),
  )
  let damage = world.params.scale_spell_damage(world.player_stats.atk + 1)
  let mut hit_any = false
  let radius_sq = ice_nova_radius * ice_nova_radius
  for enemy in world.enemies {
    if not(enemy.alive) {
      continue
    }
    let dx = enemy.x - world.player.x
    let dy = enemy.y - world.player.y
    if dx * dx + dy * dy <= radius_sq {
      apply_player_damage_to_enemy(
        world,
        enemy,
        damage,
        world.player.x,
        world.player.y,
      )
      hit_any = true
    }
  }
  world.events.push(
    IceNovaCast(world.player.x, world.player.y, ice_nova_radius),
  )
  world.ice_nova_cooldown_timer = world.params.ice_nova_cooldown_frames()
  apply_spell_attack_lock(world)
  world.events.push(AttackTriggered)
  hit_any
}

///|
pub fn cast_homing_missile(world : GameWorld) -> Bool {
  if not(has_spell_unlock(world, HomingMissile)) {
    return false
  }
  if world.homing_missile_cooldown_timer > 0 {
    return false
  }
  let (telegraph_x, telegraph_y) = homing_missile_telegraph_target(world)
  world.events.push(
    GroundTelegraphLine(
      world.player.x,
      world.player.y,
      telegraph_x,
      telegraph_y,
    ),
  )
  world.events.push(
    GroundTelegraphRing(
      telegraph_x, telegraph_y, homing_missile_telegraph_radius,
    ),
  )
  let damage = world.params.scale_spell_damage(world.player_stats.atk + 3)
  let target = find_nearest_enemy(world, homing_missile_range)
  let (dir_x, dir_y) = homing_missile_target_direction(world, target)
  let side_x = -dir_y
  let side_y = dir_x
  for sign in [-1.0, 1.0] {
    let spawn_x = world.player.x + side_x * homing_missile_launch_offset * sign
    let spawn_y = world.player.y + side_y * homing_missile_launch_offset * sign
    let initial_x = dir_x + side_x * homing_missile_initial_spread * sign
    let initial_y = dir_y + side_y * homing_missile_initial_spread * sign
    let initial_dist = (initial_x * initial_x + initial_y * initial_y).sqrt()
    let vx = initial_x / initial_dist * homing_missile_speed
    let vy = initial_y / initial_dist * homing_missile_speed
    world.projectiles.push({
      x: spawn_x,
      y: spawn_y,
      vx,
      vy,
      age: 0,
      alive: true,
      damage,
      is_player: true,
      kind: HomingMissile,
    })
    world.events.push(
      HomingMissileLaunch(spawn_x, spawn_y, telegraph_x, telegraph_y),
    )
  }
  world.homing_missile_cooldown_timer = world.params.homing_missile_cooldown_frames()
  apply_spell_attack_lock(world)
  world.events.push(AttackTriggered)
  true
}

///|
/// Spawn item with scatter velocity (items fly out from death position)
fn spawn_scatter_item(
  world : GameWorld,
  x : Double,
  y : Double,
  kind : ItemKind,
  angle : Double,
  speed : Double,
) -> Unit {
  world.items.push({
    x,
    y,
    vx: @math.cos(angle) * speed,
    vy: @math.sin(angle) * speed,
    kind,
    alive: true,
    spawn_frame: world.frame_count,
  })
}

// Process player arrow hitting enemies

///|
fn spawn_split_fireball_projectiles(
  world : GameWorld,
  projectile : Projectile,
  spawned_projectiles : Array[Projectile],
  remaining_splits : Int,
) -> Unit {
  if remaining_splits <= 0 {
    return
  }
  let base_angle = @math.atan2(projectile.vy, projectile.vx)
  let child_remaining = remaining_splits - 1
  let center = splitting_fireball_split_children / 2
  for child = 0; child < splitting_fireball_split_children; child = child + 1 {
    let offset = (child - center).to_double()
    let angle = base_angle + offset * splitting_fireball_split_angle
    let speed = world.params.arrow_speed * splitting_fireball_split_speed_mult
    spawned_projectiles.push({
      x: projectile.x,
      y: projectile.y,
      vx: @math.cos(angle) * speed,
      vy: @math.sin(angle) * speed,
      age: 0,
      alive: true,
      damage: @cmp.maximum(1, projectile.damage - 1),
      is_player: true,
      kind: Fireball(child_remaining),
    })
  }
}

///|
fn explode_player_fireball(
  world : GameWorld,
  projectile : Projectile,
  spawned_projectiles : Array[Projectile],
  remaining_splits : Int,
) -> Unit {
  if not(projectile.alive) {
    return
  }
  projectile.alive = false
  world.events.push(FireballBurst(projectile.x, projectile.y))
  spawn_split_fireball_projectiles(
    world, projectile, spawned_projectiles, remaining_splits,
  )
}

///|
pub fn process_player_projectiles(
  world : GameWorld,
  spawned_projectiles : Array[Projectile],
) -> Unit {
  for proj in world.projectiles {
    if not(proj.alive) || not(proj.is_player) {
      continue
    }
    for enemy in world.enemies {
      if not(enemy.alive) {
        continue
      }
      let edx = proj.x - enemy.x
      let edy = proj.y - enemy.y
      let dist_sq = edx * edx + edy * edy
      let hit_radius = enemy.size / 2.0 + 4.0
      if dist_sq < hit_radius * hit_radius {
        match proj.kind {
          Arrow => {
            proj.alive = false
            apply_player_damage_to_enemy(
              world,
              enemy,
              proj.damage,
              proj.x,
              proj.y,
            )
          }
          Fireball(remaining_splits) => {
            apply_player_damage_to_enemy(
              world,
              enemy,
              proj.damage,
              proj.x,
              proj.y,
            )
            explode_player_fireball(
              world, proj, spawned_projectiles, remaining_splits,
            )
          }
          HomingMissile => {
            proj.alive = false
            apply_player_damage_to_enemy(
              world,
              enemy,
              proj.damage,
              proj.x,
              proj.y,
            )
            world.events.push(HomingMissileImpact(proj.x, proj.y))
          }
          EnemyBolt => ()
        }
        break // arrow consumed
      }
    }
  }
}

// Skill activation via number keys

///|
pub fn activate_skill(world : GameWorld, slot : Int) -> Unit {
  match slot {
    0 => {
      // Slot 1: Power Strike — burst of 3 arrows
      let level = world.skills.get_level(PowerStrike)
      if level > 0 && world.attack_timer <= 0 {
        world.attack_timer = world.params.attack_cooldown.to_int()
        world.screen_flash = 2
        let a = world.player.facing_angle
        // 3-way spread
        for i = -1; i <= 1; i = i + 1 {
          let spread = a + i.to_double() * 0.3
          world.projectiles.push({
            x: world.player.x,
            y: world.player.y,
            vx: @math.cos(spread) * world.params.arrow_speed,
            vy: @math.sin(spread) * world.params.arrow_speed,
            age: 0,
            alive: true,
            damage: world.player_stats.atk * (1 + level),
            is_player: true,
            kind: Arrow,
          })
        }
        world.events.push(AttackTriggered)
      }
    }
    1 => {
      // Slot 2: Whirlwind — 8-way arrow burst
      let level = world.skills.get_level(Whirlwind)
      if level > 0 && world.attack_timer <= 0 {
        world.attack_timer = world.params.attack_cooldown.to_int() + 5
        world.screen_flash = 3
        for i = 0; i < 8; i = i + 1 {
          let a = i.to_double() * @math.PI / 4.0
          world.projectiles.push({
            x: world.player.x,
            y: world.player.y,
            vx: @math.cos(a) * world.params.arrow_speed,
            vy: @math.sin(a) * world.params.arrow_speed,
            age: 0,
            alive: true,
            damage: world.player_stats.atk * level,
            is_player: true,
            kind: Arrow,
          })
        }
        world.events.push(AttackTriggered)
        world.events.push(DeathBurst(world.player.x, world.player.y))
      }
    }
    2 => {
      // Slot 3: Dash
      let level = world.skills.get_level(DashMastery)
      if level > 0 && world.player.dash_cooldown_timer <= 0 {
        let fdx = @math.cos(world.player.facing_angle)
        let fdy = @math.sin(world.player.facing_angle)
        start_dash(world, fdx, fdy)
      }
    }
    3 => ignore(cast_chain_lightning(world))
    4 => ignore(cast_splitting_fireball(world))
    5 => ignore(cast_ice_nova(world))
    6 => ignore(cast_homing_missile(world))
    _ => ()
  }
}
