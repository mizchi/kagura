///|
fn Game::view(self : Game) -> @scene.SceneNode {
  let sw = self.screen_w.to_double()
  let sh = self.screen_h.to_double()
  let ground_y = self.ground.y
  @scene.group(key="world", children=[
    // Sky
    @scene.rect(key="sky", w=sw, h=sh, fill=self.layout.background),
    // Ground
    @scene.rect(
      key="ground",
      x=0.0,
      y=ground_y,
      w=sw,
      h=self.ground.height,
      fill=self.ground.color,
    ),
    // Pipes
    @scene.group(key="pipes", children=[
      @scene.for_each(fn() {
        let nodes : Array[@scene.SceneNode] = []
        for pipe in self.pipes.get() {
          if pipe.gap_y > 0.0 {
            nodes.push(
              @scene.rect(x=pipe.x, w=pipe_width, h=pipe.gap_y, fill=0x228B22),
            )
          }
          let lower_y = pipe.gap_y + pipe_gap
          let lower_h = ground_y - lower_y
          if lower_h > 0.0 {
            nodes.push(
              @scene.rect(
                x=pipe.x,
                y=lower_y,
                w=pipe_width,
                h=lower_h,
                fill=0x228B22,
              ),
            )
          }
        }
        nodes
      }),
    ]),
    // Render path: world/body. Selecting it inspects logical subject "bird".
    // The key identifies this visual; inspection.mbt declares the editable state.
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
      ),
    ),
    @scene.group(key="hud", children=[
      // Score
      @scene.label(
        x=sw / 2.0 - 10.0,
        y=20.0,
        key="score",
        content=self.score.get().to_string(),
        color=0x1A2A4A,
      ),
      // Title "TAP" (blinking)
      @scene.show(
        fn() {
          self.game_mode.get() == 0 && self.frame_count.get() / 30 % 2 == 0
        },
        fn() {
          @scene.label(
            x=sw / 2.0,
            y=sh / 2.0 + 30.0,
            key="title",
            content="TAP",
            scale=2.0,
            color=0x1A2A4A,
          )
        },
      ),
      // Game over overlay
      @scene.show(fn() { self.game_mode.get() == 2 }, fn() {
        @scene.fragment([
          @scene.rect(
            x=sw / 2.0 - 50.0,
            y=sh / 2.0 - 20.0,
            w=100.0,
            h=40.0,
            fill=0x1A1A2E,
          ),
          @scene.label(
            x=sw / 2.0,
            y=sh / 2.0,
            key="game-over",
            content="END",
            scale=2.0,
            color=0xFFFFFF,
          ),
        ])
      }),
    ]),
  ])
}
