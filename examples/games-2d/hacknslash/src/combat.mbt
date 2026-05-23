// Combat system: attack, damage, knockback

///|
fn try_attack(state : GameState) -> Unit {
  let facing = state.player.facing_angle
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
          // 60 degrees = ~1.047 rad
          enemy.hp = enemy.hp - 1
          enemy.damage_timer = damage_flash_duration
          // Knockback
          if dist > 0.001 {
            enemy.vx = enemy.vx + edx / dist * knockback_strength
            enemy.vy = enemy.vy + edy / dist * knockback_strength
          }
          if enemy.hp <= 0 {
            enemy.alive = false
            let kill_score = if enemy.kind == kind_boss { 100 } else { 10 }
            state.score = state.score + kill_score
            // Item drop: 50% health, 30% score gem
            let drop_roll = (
                state.frame_count * 7 +
                enemy.x.to_int() * 13 +
                enemy.y.to_int() * 17
              ) %
              100
            if drop_roll < 50 {
              state.items.push({
                x: enemy.x,
                y: enemy.y,
                kind: item_health,
                alive: true,
                spawn_frame: state.frame_count,
              })
            } else if drop_roll < 80 {
              state.items.push({
                x: enemy.x,
                y: enemy.y,
                kind: item_score,
                alive: true,
                spawn_frame: state.frame_count,
              })
            }
          }
        }
      }
    }
  }
}
