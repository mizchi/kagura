// HUD: HP bar, floor, score, enemy count, dash cooldown (no minimap)

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
      @scene.rect(x=8.0, y=8.0, w=124.0, h=16.0, fill=0x440000, alpha=0.8),
      // HP bar fill
      @scene.rect(x=10.0, y=10.0, w=hp_width * 2.0, h=12.0, fill=hp_color),
      // HP text
      @scene.label(
        x=72.0,
        y=16.0,
        content="HP",
        color=0xFFFFFF,
      ),
      // Floor
      @scene.label(
        x=sw / 2.0,
        y=16.0,
        content="FLOOR " + state.floor.to_string(),
        color=0xCCCCCC,
        scale=1.2,
      ),
      // Score
      @scene.label(
        x=sw - 80.0,
        y=16.0,
        content=state.score.to_string(),
        color=0xFFCC00,
        scale=1.5,
      ),
      // Enemy count
      @scene.label(
        x=sw - 80.0,
        y=36.0,
        content="x" + alive_count.to_string(),
        color=0xCC2222,
        scale=1.0,
      ),
      // Dash cooldown indicator
      @scene.show(fn() { state.player.dash_cooldown_timer > 0 }, fn() {
        let cd_ratio = state.player.dash_cooldown_timer.to_double() / dash_cooldown.to_double()
        @scene.rect(x=10.0, y=28.0, w=120.0 * (1.0 - cd_ratio), h=4.0, fill=0x66DDFF, alpha=0.6)
      }),
      // Floor announce overlay
      @scene.show(fn() { state.floor_announce_timer > 0 }, fn() {
        let sh = screen_h.to_double()
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0,
          content="FLOOR " + state.floor.to_string(),
          color=0xFFCC00,
          scale=3.0,
        )
      }),
    ],
  )
}

fn GameState::view_title(self : GameState) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  @scene.fragment([
    @scene.rect(w=sw, h=sh, fill=0x1A1A2E),
    @scene.label(
      x=sw / 2.0,
      y=sh / 2.0 - 60.0,
      content="HACK N SLASH",
      scale=3.0,
      color=0xFF4444,
    ),
    @scene.label(
      x=sw / 2.0,
      y=sh / 2.0 - 10.0,
      content="3D",
      scale=2.0,
      color=0x44AAFF,
    ),
    @scene.show(fn() { self.frame_count / 30 % 2 == 0 }, fn() {
      @scene.label(
        x=sw / 2.0,
        y=sh / 2.0 + 40.0,
        content="PRESS SPACE",
        color=0xFFCC00,
        scale=1.5,
      )
    }),
  ])
}

fn GameState::view_gameover(self : GameState) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  @scene.fragment([
    @scene.rect(w=sw, h=sh, fill=0x2E0000),
    @scene.label(
      x=sw / 2.0,
      y=sh / 2.0 - 60.0,
      content="GAME OVER",
      color=0xFF0000,
      scale=3.0,
    ),
    @scene.label(
      x=sw / 2.0,
      y=sh / 2.0 + 5.0,
      content="FLOOR " + self.floor.to_string(),
      color=0xFFCC00,
      scale=1.5,
    ),
    @scene.label(
      x=sw / 2.0,
      y=sh / 2.0 + 40.0,
      content="SCORE " + self.score.to_string(),
      scale=2.0,
    ),
    @scene.show(fn() { self.frame_count / 30 % 2 == 0 }, fn() {
      @scene.label(
        x=sw / 2.0,
        y=sh / 2.0 + 80.0,
        content="PRESS SPACE",
        color=0x888888,
        scale=1.5,
      )
    }),
  ])
}
