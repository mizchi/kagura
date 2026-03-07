// Combat system: attack, damage, knockback

fn try_attack(state : GameState) -> Unit {
  let facing = state.player.facing_angle
  let stats = state.player_stats
  // Crit roll
  let crit_roll = (state.frame_count * 31 + state.seed * 7) % 100
  let is_crit = crit_roll.to_double() / 100.0 < stats.crit_chance
  let damage = if is_crit { stats.atk * 2 } else { stats.atk }
  for enemy in state.enemies {
    if enemy.alive {
      let edx = enemy.x - state.player.x
      let edy = enemy.y - state.player.y
      let dist = (edx * edx + edy * edy).sqrt()
      if dist < attack_range {
        // Arc check: ±60° from facing
        let enemy_angle = @math.atan2(edy, edx)
        let mut angle_diff = enemy_angle - facing
        // Normalize to [-PI, PI]
        while angle_diff > 3.14159 {
          angle_diff = angle_diff - 6.28318
        }
        while angle_diff < -3.14159 {
          angle_diff = angle_diff + 6.28318
        }
        if angle_diff.abs() < 1.0472 {
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
              // Drop equipment item into inventory
              let item = generate_item(drop_seed, state.floor)
              let _ = state.inventory.add(item)
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
