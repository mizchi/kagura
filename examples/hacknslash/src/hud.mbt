// HUD: HP bar, floor, score, enemy count

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
  @scene.group(
    x=0.0,
    y=0.0,
    children=[
      // HP bar background
      @scene.rect(x=4.0, y=4.0, w=62.0, h=8.0, fill=0x440000, alpha=0.8),
      // HP bar fill
      @scene.rect(x=5.0, y=5.0, w=hp_width, h=6.0, fill=hp_color),
      // HP text
      @scene.label(
        x=36.0,
        y=8.0,
        content="HP",
        color=0xFFFFFF,
        scale=0.5,
      ),
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
    ],
  )
}
