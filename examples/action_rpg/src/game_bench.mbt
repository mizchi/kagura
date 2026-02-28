///|
test "bench action_rpg update" (b : @bench.T) {
  let state = ShowcaseState::new()
  state.mode = 1 // playing
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  b.bench(name="action_rpg/update", fn() {
    state.update(input)
    b.keep(state.frame_count)
  })
}

///|
test "bench action_rpg view" (b : @bench.T) {
  let state = ShowcaseState::new()
  state.mode = 1 // playing
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  for _ in 0..<60 {
    state.update(input)
  }
  b.bench(name="action_rpg/view", fn() {
    let _ = state.view()
    b.keep(state.frame_count)
  })
}
