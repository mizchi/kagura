///|
test "noop game layout returns configured dimensions" {
  let game = new_noop_game(320, 240)
  let logical = game.layout(@core.new_outside_size(800.0, 600.0))
  assert_eq(logical.width, 320)
  assert_eq(logical.height, 240)
}

///|
test "noop game update returns none" {
  let game = new_noop_game(320, 240)
  match game.update(@core.empty_input_snapshot()) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "default_run_options has expected defaults" {
  let opts = default_run_options()
  assert_eq(opts.init_unfocused, false)
  assert_eq(opts.screen_transparent, false)
  assert_eq(opts.screen_cleared_every_frame, true)
}
