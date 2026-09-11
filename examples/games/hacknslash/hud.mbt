// HUD: HP bar, floor, score, enemy count, minimap

///|
fn render_hud(state : GameState) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let hp_ratio = state.player.hp.to_double() / state.player.max_hp.to_double()
  let hp_width = 60.0 * hp_ratio
  let hp_color = if hp_ratio > 0.5 {
    0x00CC00
  } else if hp_ratio > 0.25 {
    0xCCAA00
  } else {
    0xCC0000
  }
  // Count alive enemies
  let mut alive_count = 0
  for enemy in state.enemies {
    if enemy.alive {
      alive_count = alive_count + 1
    }
  }
  @scene.group(x=0.0, y=0.0, children=[
    // HP bar background
    @scene.rect(x=4.0, y=4.0, w=62.0, h=8.0, fill=0x440000, alpha=0.8),
    // HP bar fill
    @scene.rect(x=5.0, y=5.0, w=hp_width, h=6.0, fill=hp_color),
    // HP text
    @scene.label(x=36.0, y=8.0, content="HP", color=0xFFFFFF, scale=0.5),
    // Floor
    @scene.label(
      x=sw / 2.0,
      y=8.0,
      content="FLOOR " + state.floor.to_string(),
      color=0xCCCCCC,
      scale=0.7,
    ),
    // Score
    @scene.label(
      x=sw - 40.0,
      y=8.0,
      content=state.score.to_string(),
      color=0xFFCC00,
      scale=0.8,
    ),
    // Enemy count
    @scene.label(
      x=sw - 40.0,
      y=20.0,
      content="x" + alive_count.to_string(),
      color=0xCC2222,
      scale=0.6,
    ),
    // Dash cooldown indicator
    @scene.show(fn() { state.player.dash_cooldown_timer > 0 }, fn() {
      let cd_ratio = state.player.dash_cooldown_timer.to_double() /
        dash_cooldown.to_double()
      @scene.rect(
        x=5.0,
        y=14.0,
        w=60.0 * (1.0 - cd_ratio),
        h=2.0,
        fill=0x66DDFF,
        alpha=0.6,
      )
    }),
    // Minimap
    render_minimap(state),
  ])
}

///|
fn render_minimap(state : GameState) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let mm_w = 60.0
  let mm_h = 45.0
  let mm_x = sw - mm_w - 4.0
  let mm_y = sh - mm_h - 4.0
  let scale_x = mm_w / map_cols.to_double()
  let scale_y = mm_h / map_rows.to_double()
  @scene.group(x=mm_x, y=mm_y, children=[
    // Background
    @scene.rect(w=mm_w, h=mm_h, fill=0x000000, alpha=0.5),
    // Tiles (only floor/corridor as dots)
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      // Sample every 2 tiles for performance
      for row = 0; row < map_rows; row = row + 2 {
        for col = 0; col < map_cols; col = col + 2 {
          let tile = state.dungeon.grid.get(col, row)
          if tile == @terrain.Floor ||
            tile == @terrain.Corridor ||
            tile == @terrain.Door {
            let tx = col.to_double() * scale_x
            let ty = row.to_double() * scale_y
            nodes.push(
              @scene.rect(
                x=tx,
                y=ty,
                w=scale_x * 2.0,
                h=scale_y * 2.0,
                fill=0x444455,
                alpha=0.6,
              ),
            )
          }
        }
      }
      nodes
    }),
    // Items
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      for item in state.items {
        if item.alive {
          let ix = item.x / tile_size * scale_x
          let iy = item.y / tile_size * scale_y
          nodes.push(@scene.rect(x=ix, y=iy, w=1.0, h=1.0, fill=0xFFFF00))
        }
      }
      nodes
    }),
    // Enemies
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      for enemy in state.enemies {
        if enemy.alive {
          let ex = enemy.x / tile_size * scale_x
          let ey = enemy.y / tile_size * scale_y
          let color = if enemy.kind == kind_boss { 0xFF2266 } else { 0xCC2222 }
          nodes.push(@scene.rect(x=ex, y=ey, w=1.0, h=1.0, fill=color))
        }
      }
      nodes
    }),
    // Player
    {
      let ppx = state.player.x / tile_size * scale_x
      let ppy = state.player.y / tile_size * scale_y
      @scene.rect(x=ppx - 1.0, y=ppy - 1.0, w=2.0, h=2.0, fill=0x00FF66)
    },
  ])
}
