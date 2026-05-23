///|
test "bench survivor update" (b : @bench.T) {
  let state = SurvivorState::new()
  state.game_mode = 1 // playing
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  b.bench(name="survivor/update", fn() {
    state.update(input)
    b.keep(state.frame_count)
  })
}

///|
test "bench survivor view" (b : @bench.T) {
  let state = SurvivorState::new()
  state.game_mode = 1 // playing
  // Run some updates to populate enemies/gems
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  for _ in 0..<300 {
    state.update(input)
  }
  b.bench(name="survivor/view", fn() {
    let _ = state.view()
    b.keep(state.enemies.length())
  })
}
