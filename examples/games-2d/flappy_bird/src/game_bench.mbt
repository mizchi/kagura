///|
test "bench flappy_bird update" (b : @bench.T) {
  let game = Game::new()
  game.game_mode.set(1) // playing
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  b.bench(name="flappy_bird/update", fn() {
    game.update(input)
    b.keep(game.frame_count.get())
  })
}

///|
test "bench flappy_bird view" (b : @bench.T) {
  let game = Game::new()
  game.game_mode.set(1) // playing
  // Run a few updates to populate pipes
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  for _ in 0..<150 {
    game.update(input)
  }
  b.bench(name="flappy_bird/view", fn() {
    let _ = game.view()
    b.keep(game.pipes.get().length())
  })
}
