fn main {
  let state = GameState::new(seed=42)
  let snapshot_mode = get_snapshot_mode()
  if snapshot_mode == "playing" {
    state.mode = mode_playing
    let frames = get_snapshot_frames()
    for i = 0; i < frames; i = i + 1 {
      state.update(@core.empty_input_snapshot())
    }
  } else if snapshot_mode == "gameover" {
    state.mode = mode_gameover
  }
  let snapshot_tick = get_snapshot_tick()
  let rendered_frames : Ref[Int] = Ref::new(0)
  @engine.run(
    update=fn(input) { state.update(input) },
    draw=fn(ctx) {
      let cmds = state.draw(ctx)
      if snapshot_tick > 0 {
        rendered_frames.val = rendered_frames.val + 1
        js_set_snapshot_tick(rendered_frames.val)
      }
      cmds
    },
    width=screen_w,
    height=screen_h,
    title="Hack & Slash 3D",
    canvas="#app",
  )
}
