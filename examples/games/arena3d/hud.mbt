///|
fn GameState::append_hud(
  self : GameState,
  commands : Array[@gfx.DrawTrianglesCommand],
  ctx : @engine.EngineContext,
) -> Unit {
  let frame = @renderer2d.RenderFrame2D::new(
    dst=ctx.dst,
    shader=ctx.shader,
    screen_w=ctx.screen_w,
    screen_h=ctx.screen_h,
  )
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  let scale = if sw < 500.0 { 0.7 } else { 1.0 }
  @renderer2d.append_rect_fill(
    commands,
    frame,
    @renderer2d.RectFill2D::new(
      x=0.0,
      y=0.0,
      w=sw,
      h=57.0,
      color=@renderer2d.color_from_hex_alpha(0x15232C, 0.9),
    ),
  )
  arena_label(
    commands,
    frame,
    "ARENA 3D  /  " +
    (if self.first_person { "FIRST PERSON" } else { "THIRD PERSON" }),
    sw / 2.0,
    16.0,
    scale,
  )
  arena_label(
    commands,
    frame,
    "SCORE \{self.score}   PROPS \{self.props.length()}   V: VIEW   R: RESET",
    sw / 2.0,
    40.0,
    scale * 0.85,
  )
  @renderer2d.append_rect_fill(
    commands,
    frame,
    @renderer2d.RectFill2D::new(
      x=0.0,
      y=sh - 46.0,
      w=sw,
      h=46.0,
      color=@renderer2d.color_from_hex_alpha(0x15232C, 0.9),
    ),
  )
  arena_label(
    commands,
    frame,
    "WASD MOVE / SPACE JUMP / CLICK OR F SHOOT",
    sw / 2.0,
    sh - 31.0,
    scale * 0.8,
  )
  arena_label(
    commands,
    frame,
    "RIGHT DRAG LOOK / Q E TURN / I K TILT",
    sw / 2.0,
    sh - 13.0,
    scale * 0.8,
  )
  let cross = @renderer2d.color_from_hex_alpha(
    if self.shot_frames > 0 {
      0xFFCF75
    } else {
      0xF5F2DE
    },
    0.95,
  )
  for
    (x, y, w, h) in [
      (sw / 2.0 - 9.0, sh / 2.0 - 1.0, 6.0, 2.0),
      (sw / 2.0 + 3.0, sh / 2.0 - 1.0, 6.0, 2.0),
      (sw / 2.0 - 1.0, sh / 2.0 - 9.0, 2.0, 6.0),
      (sw / 2.0 - 1.0, sh / 2.0 + 3.0, 2.0, 6.0),
    ] {
    @renderer2d.append_rect_fill(
      commands,
      frame,
      @renderer2d.RectFill2D::new(x~, y~, w~, h~, color=cross),
    )
  }
  if self.mode != mode_playing {
    @renderer2d.append_rect_fill(
      commands,
      frame,
      @renderer2d.RectFill2D::new(
        x=sw / 2.0 - 145.0,
        y=sh / 2.0 - 40.0,
        w=290.0,
        h=80.0,
        color=@renderer2d.color_from_hex_alpha(0x15232C, 0.95),
      ),
    )
    arena_label(
      commands,
      frame,
      if self.mode == mode_gameover {
        "HIT!  R TO RETRY"
      } else {
        "SPACE TO START"
      },
      sw / 2.0,
      sh / 2.0,
      1.2,
    )
  }
}

///|
fn arena_label(
  commands : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  text : String,
  x : Double,
  y : Double,
  scale : Double,
) -> Unit {
  @renderer2d.append_dot_text(
    commands,
    frame,
    @renderer2d.DotText2D::new(
      chars=text.to_array().map(c => c.to_int()),
      cx=x,
      cy=y,
      scale~,
      color=@renderer2d.color_from_hex_alpha(0xE8EEE8, 1.0),
    ),
  )
}
