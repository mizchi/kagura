// Combat system: bow attack, damage, knockback

// Find nearest enemy in range for auto-aim (uses dist_sq to avoid sqrt)
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
pub fn aim_at(world : GameWorld, target : Enemy?, speed : Double) -> (Double, Double) {
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
  })
}

pub fn spawn_ground_item(world : GameWorld, x : Double, y : Double, kind : ItemKind) -> Unit {
  world.items.push({ x, y, kind, alive: true, spawn_frame: world.frame_count })
}

// Process player arrow hitting enemies
pub fn process_player_arrows(world : GameWorld) -> Unit {
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
        proj.alive = false
        enemy.hp = enemy.hp - proj.damage
        enemy.damage_timer = damage_flash_duration
        world.events.push(HitSparks(enemy.x, enemy.y))
        // Life steal
        if world.player_stats.life_steal > 0.0 {
          let heal = (proj.damage.to_double() * world.player_stats.life_steal).to_int()
          if heal > 0 {
            world.player.hp = @cmp.minimum(
              world.player_stats.max_hp, world.player.hp + heal,
            )
          }
        }
        // Knockback
        let dist = dist_sq.sqrt()
        if dist > 0.001 {
          enemy.vx = enemy.vx - edx / dist * world.params.knockback_strength
          enemy.vy = enemy.vy - edy / dist * world.params.knockback_strength
        }
        if enemy.hp <= 0 {
          enemy.alive = false
          world.events.push(DeathBurst(enemy.x, enemy.y))
          let kill_score = if enemy.kind == Boss { 100 } else { 10 }
          world.score = world.score + kill_score
          // Drop item
          let drop_seed = world.frame_count * 7 +
            enemy.x.to_int() * 13 +
            enemy.y.to_int() * 17
          let drop_roll = drop_seed % 100
          if drop_roll < 30 {
            let item = generate_item(drop_seed, world.floor)
            if not(world.inventory.add(item)) {
              spawn_ground_item(world, enemy.x, enemy.y, Score)
            }
          } else if drop_roll < 60 {
            spawn_ground_item(world, enemy.x, enemy.y, Health)
          } else if drop_roll < 80 {
            spawn_ground_item(world, enemy.x, enemy.y, Score)
          }
          if enemy.kind == Boss {
            world.skills.skill_points = world.skills.skill_points + 1
          }
        }
        break // arrow consumed
      }
    }
  }
}

// Skill activation via number keys
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
    _ => ()
  }
}
