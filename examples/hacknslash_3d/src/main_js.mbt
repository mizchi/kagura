extern "js" fn js_now() -> Double =
  #| () => (globalThis.performance?.now?.() ?? Date.now())

fn main {
  let state = GameState::new(seed=42)
  let snapshot_mode = get_snapshot_mode()
  if snapshot_mode == "playing" {
    state.world.mode = @game.Playing
    let frames = get_snapshot_frames()
    for i = 0; i < frames; i = i + 1 {
      state.update(@core.empty_input_snapshot())
    }
  } else if snapshot_mode == "gameover" {
    state.world.mode = @game.GameOver
  }
  let snapshot_tick = get_snapshot_tick()
  let rendered_frames : Ref[Int] = Ref::new(0)
  // Fixed 60fps timestep accumulator
  let fixed_dt : Double = 1000.0 / 60.0 // 16.667ms
  let accum : Ref[Double] = Ref::new(0.0)
  let prev_time : Ref[Double] = Ref::new(js_now())
  let last_input : Ref[@core.InputSnapshot] = Ref::new(
    @core.empty_input_snapshot(),
  )
  @engine.run(
    update=fn(input) {
      last_input.val = input
      let now = js_now()
      let elapsed = now - prev_time.val
      prev_time.val = now
      // Cap accumulated time to avoid spiral of death (max 3 updates)
      accum.val = accum.val + @cmp.minimum(elapsed, fixed_dt * 3.0)
      while accum.val >= fixed_dt {
        state.update(input)
        accum.val = accum.val - fixed_dt
      }
    },
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
