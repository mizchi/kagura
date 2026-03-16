
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
  let cl_level = world.skills.get_level(ChainLightning)
  let damage = player_spell_damage(
    world.player_stats,
    world.params,
    world.archetype,
    ChainLightning,
    skill_level=cl_level,
  )
  let max_targets = chain_lightning_targets_for_level(cl_level) +
    effective_extra_chain_targets(world.player_stats, ChainLightning)
  for _step = 0; _step < max_targets; _step = _step + 1 {
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
  let damage = player_spell_damage(
    world.player_stats,
    world.params,
    world.archetype,
    SplittingFireball,
    skill_level=world.skills.get_level(SplittingFireball),
  )
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
  let nova_radius = effective_aoe_radius(
    world.player_stats, IceNova, ice_nova_radius,
  )
  world.events.push(
    GroundTelegraphRing(world.player.x, world.player.y, nova_radius),
  )
  let damage = player_spell_damage(
    world.player_stats,
    world.params,
    world.archetype,
    IceNova,
    skill_level=world.skills.get_level(IceNova),
  )
  let mut hit_any = false
  let radius_sq = nova_radius * nova_radius
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
    IceNovaCast(world.player.x, world.player.y, nova_radius),
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
  let damage = player_spell_damage(
    world.player_stats,
    world.params,
    world.archetype,
    HomingMissile,
    skill_level=world.skills.get_level(HomingMissile),
  )
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
      // Slot 1: Power Strike
      let level = world.skills.get_level(PowerStrike)
      if level > 0 && world.attack_timer <= 0 {
        world.attack_timer = world.params.attack_cooldown.to_int()
        match world.archetype {
          Melee => {
            // Melee: enhanced circular AoE with damage multiplier
            let damage = (player_basic_attack_damage(
              world.player_stats,
              world.archetype,
            ).to_double() * skill_level_damage_multiplier(PowerStrike, level)).to_int().max(1)
            let radius = melee_slash_radius * 1.3
            let r_sq = radius * radius
            let px = world.player.x
            let py = world.player.y
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
            world.events.push(MeleeSlash(px, py, radius))
          }
          _ => {
            // Ranged: burst of 3 arrows
            let a = world.player.facing_angle
            for i = -1; i <= 1; i = i + 1 {
              let spread = a + i.to_double() * 0.3
              world.projectiles.push({
                x: world.player.x,
                y: world.player.y,
                vx: @math.cos(spread) * world.params.arrow_speed,
                vy: @math.sin(spread) * world.params.arrow_speed,
                age: 0,
                alive: true,
                damage: (player_basic_attack_damage(
                  world.player_stats,
                  world.archetype,
                ).to_double() * skill_level_damage_multiplier(PowerStrike, level)).to_int().max(1),
                is_player: true,
                kind: Arrow,
              })
            }
          }
        }
        world.events.push(AttackTriggered)
      }
    }
    1 => {
      // Slot 2: Whirlwind
      let level = world.skills.get_level(Whirlwind)
      if level > 0 && world.attack_timer <= 0 {
        world.attack_timer = world.params.attack_cooldown.to_int() + 5
        match world.archetype {
          Melee => {
            // Melee: large 360-degree AoE slash
            let damage = (player_basic_attack_damage(
              world.player_stats,
              world.archetype,
            ).to_double() * skill_level_damage_multiplier(Whirlwind, level)).to_int().max(1)
            let radius = effective_aoe_radius(
              world.player_stats, Whirlwind, melee_slash_radius * 1.8,
            )
            let r_sq = radius * radius
            let px = world.player.x
            let py = world.player.y
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
            world.events.push(MeleeSlash(px, py, radius))
            world.events.push(DeathBurst(px, py))
          }
          _ => {
            // Ranged: 8-way arrow burst
            for i = 0; i < 8; i = i + 1 {
              let a = i.to_double() * @math.PI / 4.0
              world.projectiles.push({
                x: world.player.x,
                y: world.player.y,
                vx: @math.cos(a) * world.params.arrow_speed,
                vy: @math.sin(a) * world.params.arrow_speed,
                age: 0,
                alive: true,
                damage: (player_basic_attack_damage(
                  world.player_stats,
                  world.archetype,
                ).to_double() * skill_level_damage_multiplier(Whirlwind, level)).to_int().max(1),
                is_player: true,
                kind: Arrow,
              })
            }
            world.events.push(DeathBurst(world.player.x, world.player.y))
          }
        }
        world.events.push(AttackTriggered)
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
    7 => {
      // Counter stance: invincible + reflect projectiles
      let level = world.skills.get_level(Counter)
      if level > 0 &&
        world.player.counter_timer <= 0 &&
        world.player.counter_cooldown_timer <= 0 {
        world.player.counter_timer = counter_duration_frames
        world.player.counter_cooldown_timer = counter_cooldown_frames
        world.events.push(DeathBurst(world.player.x, world.player.y))
      }
    }
    _ => ()
  }
}
