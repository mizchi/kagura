// Headless auto-play runner with ASCII art visualization

fn main {
  let world = @game.GameWorld::new(seed=42)
  world.auto_play = true
  world.mode = @game.Playing
  let max_frames = 18000 // 5 minutes at 60fps
  let report_interval = 300 // every 5 seconds
  let ascii_interval = 600 // every 10 seconds
  println("=== HEADLESS AUTO-PLAY START ===")
  println("Seed: 42 | Max frames: " + max_frames.to_string())
  println("")
  for frame = 0; frame < max_frames; frame = frame + 1 {
    world.tick_auto()
    // Drain events for logging
    let events = world.drain_events()
    for event in events {
      match event {
        @game.FloorComplete =>
          println(
            "[F " + world.frame_count.to_string() + "] === FLOOR " + world.floor.to_string() + " ===",
          )
        @game.HurtTriggered =>
          println(
            "[F " + world.frame_count.to_string() + "] Player hurt! HP: " + world.player.hp.to_string() + "/" + world.player_stats.max_hp.to_string(),
          )
        _ => ()
      }
    }
    // Check game over
    if world.mode == @game.GameOver {
      println("")
      println(
        "[F " + world.frame_count.to_string() + "] GAME OVER on Floor " + world.floor.to_string() + " | Score: " + world.score.to_string(),
      )
      break
    }
    // Periodic status report
    if frame > 0 && frame % report_interval == 0 {
      let mut alive = 0
      for e in world.enemies {
        if e.alive {
          alive = alive + 1
        }
      }
      println(
        "[F " + world.frame_count.to_string() + "] Floor " + world.floor.to_string() + " | HP " + world.player.hp.to_string() + "/" + world.player_stats.max_hp.to_string() + " | Score " + world.score.to_string() + " | Enemies " + alive.to_string() + " | ATK " + world.player_stats.atk.to_string() + " DEF " + world.player_stats.def.to_string(),
      )
    }
    // Periodic ASCII minimap
    if frame > 0 && frame % ascii_interval == 0 {
      print_ascii_map(world)
    }
  }
  if world.mode != @game.GameOver {
    println("")
    println(
      "[F " + world.frame_count.to_string() + "] TIME LIMIT | Floor " + world.floor.to_string() + " | Score " + world.score.to_string(),
    )
  }
  println("")
  println("=== HEADLESS AUTO-PLAY END ===")
}

fn print_ascii_map(world : @game.GameWorld) -> Unit {
  let ts = @game.tile_size
  let pcx = (world.player.x / ts).to_int()
  let pcy = (world.player.y / ts).to_int()
  let radius = 15
  let grid = world.dungeon.grid
  let buf = StringBuilder::new()
  buf.write_string("  MAP (")
  buf.write_string(pcx.to_string())
  buf.write_string(",")
  buf.write_string(pcy.to_string())
  buf.write_string("):\n")
  for dy = -radius; dy <= radius; dy = dy + 1 {
    buf.write_string("  ")
    for dx = -radius; dx <= radius; dx = dx + 1 {
      let gx = pcx + dx
      let gy = pcy + dy
      if dx == 0 && dy == 0 {
        buf.write_char('@')
        continue
      }
      // Check for enemy at this tile
      let mut has_enemy = false
      let mut is_boss = false
      for enemy in world.enemies {
        if enemy.alive {
          let ex = (enemy.x / ts).to_int()
          let ey = (enemy.y / ts).to_int()
          if ex == gx && ey == gy {
            has_enemy = true
            if enemy.kind == @game.Boss {
              is_boss = true
            }
            break
          }
        }
      }
      if has_enemy {
        buf.write_char(if is_boss { 'B' } else { 'E' })
        continue
      }
      if gx < 0 || gx >= grid.width || gy < 0 || gy >= grid.height {
        buf.write_char(' ')
        continue
      }
      let tile = grid.get(gx, gy)
      let c = if tile == @terrain.Wall {
        '#'
      } else if tile == @terrain.Floor || tile == @terrain.Corridor {
        '.'
      } else if tile == @terrain.Door {
        '+'
      } else {
        ' '
      }
      buf.write_char(c)
    }
    buf.write_char('\n')
  }
  println(buf.to_string())
}
