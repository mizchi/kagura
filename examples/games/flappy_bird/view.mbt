///|
fn Game::view(self : Game) -> @scene.SceneNode {
  let sw = self.screen_w.to_double()
  let sh = self.screen_h.to_double()
  let gy = self.ground.y
  let time = if self.game_mode.get() == 2 {
    0.0
  } else {
    self.frame_count.get().to_double()
  }
  @scene.group(key="world", children=[
    @scene.rect(
      key="sky",
      w=sw,
      h=sh,
      fill=self.layout.background,
      children=sky_details(sw, gy, time),
    ),
    @scene.rect(
      key="ground",
      y=gy,
      w=sw,
      h=sh - gy,
      fill=self.ground.color,
      children=ground_details(sw, sh - gy, time),
    ),
    @scene.group(key="pipes", children=[
      @scene.for_each(fn() {
        let nodes : Array[@scene.SceneNode] = []
        for pipe in self.pipes.get() {
          if pipe.gap_y > 0.0 {
            nodes.push(pipe_view(pipe.x, 0.0, pipe.gap_y, true))
          }
          let lower = pipe.gap_y + pipe_gap
          if gy > lower {
            nodes.push(pipe_view(pipe.x, lower, gy - lower, false))
          }
        }
        nodes
      }),
    ]),
    // Preserve the editable collision rectangle and world/body inspection subject.
    @scene.subject(
      "bird",
      @scene.rect(
        key="body",
        name="Bird body",
        x=self.bird.x,
        y=self.bird_y.get(),
        w=self.bird.width,
        h=self.bird.height,
        fill=self.bird.color,
        alpha=0.0,
        children=bird_details(
          self.bird.width,
          self.bird.height,
          self.bird.color,
          time.to_int(),
          self.velocity,
          self.game_mode.get() == 2,
        ),
      ),
    ),
    @scene.group(key="hud", children=[
      @scene.label(
        key="score",
        x=sw / 2.0,
        y=22.0,
        content=self.score.get().to_string(),
        color=0x214B4C,
        scale=1.6,
      ),
      @scene.show(fn() { self.game_mode.get() == 0 }, fn() {
        @scene.fragment([
          pixel_panel(sw / 2.0 - 118.0, sh / 2.0 - 70.0, 236.0, 52.0, 0x407878),
          pixel_panel(sw / 2.0 - 118.0, sh / 2.0 - 73.0, 236.0, 52.0, 0xFFF6DA),
          @scene.label(
            key="title",
            x=sw / 2.0,
            y=sh / 2.0 - 55.0,
            content="FLAPPY BIRD",
            color=0x214B4C,
            scale=1.7,
          ),
          @scene.label(
            key="subtitle",
            x=sw / 2.0,
            y=sh / 2.0 - 32.0,
            content="TAP / SPACE TO FLY",
            color=0x407878,
            scale=0.65,
          ),
          pixel_panel(sw / 2.0 - 56.0, sh / 2.0 + 34.0, 112.0, 24.0, 0x214B4C),
          @scene.label(
            key="start",
            x=sw / 2.0,
            y=sh / 2.0 + 46.0,
            content="TAP TO START",
            color=0xFFF6DA,
            scale=0.8,
          ),
        ])
      }),
      @scene.show(fn() { self.game_mode.get() == 2 }, fn() {
        @scene.fragment([
          pixel_panel(sw / 2.0 - 94.0, sh / 2.0 - 48.0, 188.0, 111.0, 0x407878),
          pixel_panel(sw / 2.0 - 94.0, sh / 2.0 - 52.0, 188.0, 111.0, 0xFFF6DA),
          @scene.label(
            key="game-over",
            x=sw / 2.0,
            y=sh / 2.0 - 30.0,
            content="GAME OVER",
            color=0x214B4C,
            scale=1.35,
          ),
          @scene.label(
            key="result",
            x=sw / 2.0,
            y=sh / 2.0 + 1.0,
            content="SCORE  " + self.score.get().to_string(),
            color=0x9A4F35,
            scale=1.0,
          ),
          @scene.label(
            key="restart",
            x=sw / 2.0,
            y=sh / 2.0 + 37.0,
            content="TAP / SPACE TO RETRY",
            color=0x407878,
            scale=0.65,
          ),
        ])
      }),
    ]),
  ])
}
