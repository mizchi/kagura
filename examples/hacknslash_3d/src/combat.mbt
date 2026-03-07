// Combat system: attack, damage, knockback

// Check if any enemy is within attack range (for auto-attack)
fn has_enemy_in_range(state : GameState) -> Bool {
  let whirlwind_level = state.skills.get_level(Whirlwind)
  let effective_range = if whirlwind_level > 0 {
    attack_range + whirlwind_level.to_double() * 6.0
  } else {
    attack_range
  }
  for enemy in state.enemies {
    if enemy.alive {
      let edx = enemy.x - state.player.x
      let edy = enemy.y - state.player.y
      let dist = (edx * edx + edy * edy).sqrt()
      if dist < effective_range {
        // For non-whirlwind, also check arc
        if whirlwind_level > 0 {
          return true
        }
        let enemy_angle = @math.atan2(edy, edx)
        let mut angle_diff = enemy_angle - state.player.facing_angle
        while angle_diff > 3.14159 {
          angle_diff = angle_diff - 6.28318
        }
        while angle_diff < -3.14159 {
          angle_diff = angle_diff + 6.28318
        }
        if angle_diff.abs() < 1.5708 { // ±90° for auto-attack detection (wider than hit arc)
          return true
        }
      }
    }
  }
  false
}

// Skill activation via number keys (1=PowerStrike burst, 2=Whirlwind spin, 3=Dash)
fn activate_skill(state : GameState, slot : Int) -> Unit {
  match slot {
    0 => {
      // Slot 1: Power Strike — immediate strong attack if learned
      let level = state.skills.get_level(PowerStrike)
      if level > 0 && state.attack_timer <= 0 {
        state.attack_timer = attack_cooldown
        state.screen_flash = 3
        try_attack(state)
        state.character.trigger_attack()
      }
    }
    1 => {
      // Slot 2: Whirlwind — 360° spin attack if learned
      let level = state.skills.get_level(Whirlwind)
      if level > 0 && state.attack_timer <= 0 {
        state.attack_timer = attack_cooldown + 5
        state.screen_flash = 3
        try_attack(state)
        state.character.trigger_attack()
        // Extra particle burst for whirlwind
        spawn_death_burst(state.particle_manager, state.player.x, state.player.y)
      }
    }
    2 => {
      // Slot 3: Dash — instant dash in facing direction
      let level = state.skills.get_level(DashMastery)
      if level > 0 && state.player.dash_cooldown_timer <= 0 {
        let fdx = @math.cos(state.player.facing_angle)
        let fdy = @math.sin(state.player.facing_angle)
        state.player.dash_timer = dash_duration
        state.player.dash_cooldown_timer = state.player_stats.dash_cooldown
        state.player.dash_vx = fdx * player_speed * dash_speed_mult
        state.player.dash_vy = fdy * player_speed * dash_speed_mult
        state.player.iframe_timer = dash_duration
        spawn_dash_trail(state.particle_manager, state.player.x, state.player.y)
      }
    }
    _ => ()
  }
}

fn try_attack(state : GameState) -> Unit {
  let facing = state.player.facing_angle
  let stats = state.player_stats
  // Crit roll
  let crit_roll = (state.frame_count * 31 + state.seed * 7) % 100
  let is_crit = crit_roll.to_double() / 100.0 < stats.crit_chance
  let damage = if is_crit { stats.atk * 2 } else { stats.atk }
  // Whirlwind: 360° AoE with extended range per level
  let whirlwind_level = state.skills.get_level(Whirlwind)
  let is_whirlwind = whirlwind_level > 0
  let effective_range = if is_whirlwind {
    attack_range + whirlwind_level.to_double() * 6.0
  } else {
    attack_range
  }
  for enemy in state.enemies {
    if enemy.alive {
      let edx = enemy.x - state.player.x
      let edy = enemy.y - state.player.y
      let dist = (edx * edx + edy * edy).sqrt()
      if dist < effective_range {
        // Whirlwind hits 360°, normal attack ±60° from facing
        let in_arc = if is_whirlwind {
          true
        } else {
          let enemy_angle = @math.atan2(edy, edx)
          let mut angle_diff = enemy_angle - facing
          while angle_diff > 3.14159 {
            angle_diff = angle_diff - 6.28318
          }
          while angle_diff < -3.14159 {
            angle_diff = angle_diff + 6.28318
          }
          angle_diff.abs() < 1.0472
        }
        if in_arc {
          enemy.hp = enemy.hp - damage
          enemy.damage_timer = damage_flash_duration
          spawn_hit_sparks(state.particle_manager, enemy.x, enemy.y)
          // Life steal
          if stats.life_steal > 0.0 {
            let heal = (damage.to_double() * stats.life_steal).to_int()
            if heal > 0 {
              state.player.hp = @cmp.minimum(stats.max_hp, state.player.hp + heal)
            }
          }
          // Knockback
          if dist > 0.001 {
            enemy.vx = enemy.vx + edx / dist * knockback_strength
            enemy.vy = enemy.vy + edy / dist * knockback_strength
          }
          if enemy.hp <= 0 {
            enemy.alive = false
            spawn_death_burst(state.particle_manager, enemy.x, enemy.y)
            let kill_score = if enemy.kind == kind_boss { 100 } else { 10 }
            state.score = state.score + kill_score
            // Drop item or health/score
            let drop_seed = state.frame_count * 7 + enemy.x.to_int() * 13 + enemy.y.to_int() * 17
            let drop_roll = drop_seed % 100
            if drop_roll < 30 {
              // Drop equipment item into inventory; if full, drop as health pickup
              let item = generate_item(drop_seed, state.floor)
              if not(state.inventory.add(item)) {
                state.items.push({ x: enemy.x, y: enemy.y, kind: item_score, alive: true, spawn_frame: state.frame_count })
              }
            } else if drop_roll < 60 {
              state.items.push({ x: enemy.x, y: enemy.y, kind: item_health, alive: true, spawn_frame: state.frame_count })
            } else if drop_roll < 80 {
              state.items.push({ x: enemy.x, y: enemy.y, kind: item_score, alive: true, spawn_frame: state.frame_count })
            }
            // Skill points from bosses
            if enemy.kind == kind_boss {
              state.skills.skill_points = state.skills.skill_points + 1
            }
          }
        }
      }
    }
  }
}
