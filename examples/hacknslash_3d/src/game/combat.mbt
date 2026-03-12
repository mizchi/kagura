// Combat system: bow attack, damage, knockback

// Find nearest enemy in range for auto-aim (uses dist_sq to avoid sqrt)

///|
pub fn find_nearest_enemy(world : GameWorld, max_range : Double) -> Enemy? {
  let mut nearest : Enemy? = None
  let mut nearest_dist_sq = max_range * max_range
  for enemy in world.enemies {
    if enemy.alive {
      let edx = enemy.x - world.player.x
      let edy = enemy.y - world.player.y
      let dist_sq = edx * edx + edy * edy
      if dist_sq < nearest_dist_sq {
        nearest_dist_sq = dist_sq
        nearest = Some(enemy)
      }
    }
  }
  nearest
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
  world.player.hp = @cmp.minimum(world.player_stats.max_hp, world.player.hp + heal)
}

///|
fn apply_enemy_death_rewards(world : GameWorld, enemy : Enemy) -> Unit {
  world.events.push(DeathBurst(enemy.x, enemy.y))
  let kill_score = if enemy.kind == Boss { 100 } else { 10 }
  world.score = world.score + kill_score
  let drop_seed = world.frame_count * 7 + enemy.x.to_int() * 13 + enemy.y.to_int() * 17
  let drop_count = if enemy.kind == Boss { 5 } else { drop_seed % 3 + 1 }
  for di = 0; di < drop_count; di = di + 1 {
    let item_seed = drop_seed + di * 31
    let angle = (item_seed % 628).to_double() / 100.0
    let scatter_speed = 1.5 + (item_seed % 100).to_double() / 100.0
    let roll = (item_seed * 37 + di * 13) % 100
    if roll < 30 {
      let item = generate_item_with_profile(
        item_seed,
        world.floor,
        world.params.get_affix_profile(),
      )
      spawn_scatter_item(
        world,
        enemy.x,
        enemy.y,
        Equipment(item),
        angle,
        scatter_speed,
      )
    } else if roll < 60 {
      spawn_scatter_item(
        world,
        enemy.x,
        enemy.y,
        Health,
        angle,
        scatter_speed,
      )
    } else {
      spawn_scatter_item(
        world,
        enemy.x,
        enemy.y,
        Score,
        angle,
        scatter_speed,
      )
    }
  }
  if enemy.kind == Boss {
    world.skills.skill_points = world.skills.skill_points + 1
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
) -> Int {
  let max_dist_sq = chain_lightning_hop_range * chain_lightning_hop_range
  let mut nearest_index = -1
  let mut nearest_dist_sq = max_dist_sq
  for index = 0; index < world.enemies.length(); index = index + 1 {
    let enemy = world.enemies[index]
    if not(enemy.alive) {
      continue
    }
    let mut already_chained = false
    for chained in chained_enemy_indices {
      if chained == index {
        already_chained = true
        break
      }
    }
    if already_chained {
      continue
    }
    let dx = enemy.x - source_x
    let dy = enemy.y - source_y
    let dist_sq = dx * dx + dy * dy
    if dist_sq < nearest_dist_sq {
      nearest_dist_sq = dist_sq
      nearest_index = index
    }
  }
  nearest_index
}

///|
pub fn cast_chain_lightning(world : GameWorld) -> Bool {
  if world.chain_lightning_cooldown_timer > 0 {
    return false
  }
  let first_target = find_nearest_enemy(world, chain_lightning_range)
  if first_target is None {
    return false
  }
  let chained_enemy_indices : Array[Int] = []
  let mut arc_start_x = world.player.x
  let mut arc_start_y = world.player.y
  for _step = 0; _step < chain_lightning_max_targets; _step = _step + 1 {
    let next_index = find_next_chain_target(
      world,
      arc_start_x,
      arc_start_y,
      chained_enemy_indices,
    )
    if next_index < 0 {
      break
    }
    let enemy = world.enemies[next_index]
    world.events.push(
      ChainLightningArc(arc_start_x, arc_start_y, enemy.x, enemy.y),
    )
    apply_player_damage_to_enemy(
      world,
      enemy,
      world.player_stats.atk + 2,
      arc_start_x,
      arc_start_y,
    )
    chained_enemy_indices.push(next_index)
    arc_start_x = enemy.x
    arc_start_y = enemy.y
  }
  if chained_enemy_indices.is_empty() {
    return false
  }
  world.chain_lightning_cooldown_timer = chain_lightning_cooldown
  world.events.push(AttackTriggered)
  true
}

///|
pub fn cast_splitting_fireball(world : GameWorld) -> Bool {
  if world.splitting_fireball_cooldown_timer > 0 {
    return false
  }
  let target = find_nearest_enemy(world, chain_lightning_range)
  let (vx, vy) = aim_at(world, target, world.params.arrow_speed * 0.8)
  world.projectiles.push({
    x: world.player.x,
    y: world.player.y,
    vx,
    vy,
    alive: true,
    damage: world.player_stats.atk + 2,
    is_player: true,
    kind: Fireball(1),
  })
  world.splitting_fireball_cooldown_timer = splitting_fireball_cooldown
  world.events.push(AttackTriggered)
  true
}

///|
pub fn cast_ice_nova(world : GameWorld) -> Bool {
  if world.ice_nova_cooldown_timer > 0 {
    return false
  }
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
        world.player_stats.atk + 1,
        world.player.x,
        world.player.y,
      )
      hit_any = true
    }
  }
  world.events.push(IceNovaCast(world.player.x, world.player.y, ice_nova_radius))
  world.ice_nova_cooldown_timer = ice_nova_cooldown
  world.events.push(AttackTriggered)
  hit_any
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
    world,
    projectile,
    spawned_projectiles,
    remaining_splits,
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
            apply_player_damage_to_enemy(world, enemy, proj.damage, proj.x, proj.y)
          }
          Fireball(remaining_splits) => {
            apply_player_damage_to_enemy(world, enemy, proj.damage, proj.x, proj.y)
            explode_player_fireball(
              world,
              proj,
              spawned_projectiles,
              remaining_splits,
            )
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
    _ => ()
  }
}
