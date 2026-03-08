// Combat system: bow attack, damage, knockback

// Find nearest enemy in range for auto-aim (uses dist_sq to avoid sqrt)
fn find_nearest_enemy(state : GameState, max_range : Double) -> Enemy? {
  let mut nearest : Enemy? = None
  let mut nearest_dist_sq = max_range * max_range
  for enemy in state.enemies {
    if enemy.alive {
      let edx = enemy.x - state.player.x
      let edy = enemy.y - state.player.y
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
fn aim_at(state : GameState, target : Enemy?, speed : Double) -> (Double, Double) {
  match target {
    Some(enemy) => {
      let edx = enemy.x - state.player.x
      let edy = enemy.y - state.player.y
      let dist = (edx * edx + edy * edy).sqrt()
      if dist > 0.001 {
        return (edx / dist * speed, edy / dist * speed)
      }
    }
    _ => ()
  }
  let a = state.player.facing_angle
  (@math.cos(a) * speed, @math.sin(a) * speed)
}

// Shoot an arrow toward the given target or in facing direction
fn shoot_arrow(state : GameState, target : Enemy?) -> Unit {
  let stats = state.player_stats
  let crit_roll = (state.frame_count * 31 + state.seed * 7) % 100
  let is_crit = crit_roll.to_double() / 100.0 < stats.crit_chance
  let damage = if is_crit { stats.atk * 2 } else { stats.atk }
  let (vx, vy) = aim_at(state, target, arrow_speed)
  state.projectiles.push({
    x: state.player.x,
    y: state.player.y,
    vx,
    vy,
    alive: true,
    damage,
    is_player: true,
  })
}

fn spawn_ground_item(state : GameState, x : Double, y : Double, kind : ItemKind) -> Unit {
  state.items.push({ x, y, kind, alive: true, spawn_frame: state.frame_count })
}

// Process player arrow hitting enemies
fn process_player_arrows(state : GameState) -> Unit {
  for proj in state.projectiles {
    if not(proj.alive) || not(proj.is_player) {
      continue
    }
    for enemy in state.enemies {
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
        spawn_hit_sparks(state.particle_manager, enemy.x, enemy.y)
        // Life steal
        if state.player_stats.life_steal > 0.0 {
          let heal = (proj.damage.to_double() * state.player_stats.life_steal).to_int()
          if heal > 0 {
            state.player.hp = @cmp.minimum(
              state.player_stats.max_hp, state.player.hp + heal,
            )
          }
        }
        // Knockback
        let dist = dist_sq.sqrt()
        if dist > 0.001 {
          enemy.vx = enemy.vx - edx / dist * knockback_strength
          enemy.vy = enemy.vy - edy / dist * knockback_strength
        }
        if enemy.hp <= 0 {
          enemy.alive = false
          spawn_death_burst(state.particle_manager, enemy.x, enemy.y)
          let kill_score = if enemy.kind == Boss { 100 } else { 10 }
          state.score = state.score + kill_score
          // Drop item
          let drop_seed = state.frame_count * 7 +
            enemy.x.to_int() * 13 +
            enemy.y.to_int() * 17
          let drop_roll = drop_seed % 100
          if drop_roll < 30 {
            let item = generate_item(drop_seed, state.floor)
            if not(state.inventory.add(item)) {
              spawn_ground_item(state, enemy.x, enemy.y, Score)
            }
          } else if drop_roll < 60 {
            spawn_ground_item(state, enemy.x, enemy.y, Health)
          } else if drop_roll < 80 {
            spawn_ground_item(state, enemy.x, enemy.y, Score)
          }
          if enemy.kind == Boss {
            state.skills.skill_points = state.skills.skill_points + 1
          }
        }
        break // arrow consumed
      }
    }
  }
}

// Skill activation via number keys
fn activate_skill(state : GameState, slot : Int) -> Unit {
  match slot {
    0 => {
      // Slot 1: Power Strike — burst of 3 arrows
      let level = state.skills.get_level(PowerStrike)
      if level > 0 && state.attack_timer <= 0 {
        state.attack_timer = attack_cooldown
        state.screen_flash = 2
        let a = state.player.facing_angle
        // 3-way spread
        for i = -1; i <= 1; i = i + 1 {
          let spread = a + i.to_double() * 0.3
          state.projectiles.push({
            x: state.player.x,
            y: state.player.y,
            vx: @math.cos(spread) * arrow_speed,
            vy: @math.sin(spread) * arrow_speed,
            alive: true,
            damage: state.player_stats.atk * (1 + level),
            is_player: true,
          })
        }
        state.character.trigger_attack()
      }
    }
    1 => {
      // Slot 2: Whirlwind — 8-way arrow burst
      let level = state.skills.get_level(Whirlwind)
      if level > 0 && state.attack_timer <= 0 {
        state.attack_timer = attack_cooldown + 5
        state.screen_flash = 3
        for i = 0; i < 8; i = i + 1 {
          let a = i.to_double() * @math.PI / 4.0
          state.projectiles.push({
            x: state.player.x,
            y: state.player.y,
            vx: @math.cos(a) * arrow_speed,
            vy: @math.sin(a) * arrow_speed,
            alive: true,
            damage: state.player_stats.atk * level,
            is_player: true,
          })
        }
        state.character.trigger_attack()
        spawn_death_burst(state.particle_manager, state.player.x, state.player.y)
      }
    }
    2 => {
      // Slot 3: Dash
      let level = state.skills.get_level(DashMastery)
      if level > 0 && state.player.dash_cooldown_timer <= 0 {
        let fdx = @math.cos(state.player.facing_angle)
        let fdy = @math.sin(state.player.facing_angle)
        start_dash(state, fdx, fdy)
      }
    }
    _ => ()
  }
}
