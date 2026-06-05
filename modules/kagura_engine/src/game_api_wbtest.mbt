///|
struct TestEngineGame {
  mut update_count : Int
  mut draw_count : Int
}

///|
fn TestEngineGame::new() -> TestEngineGame {
  { update_count: 0, draw_count: 0 }
}

///|
impl EngineGame for TestEngineGame with fn update_game(self, _input) {
  self.update_count += 1
}

///|
impl EngineGame for TestEngineGame with fn draw_game(self, _ctx) {
  self.draw_count += 1
  []
}

///|
fn make_test_engine_ctx() -> EngineContext {
  {
    dst: @gfx.new_image_handle(0, 320, 240),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 320,
    screen_h: 240,
  }
}

///|
test "engine_game_update delegates to EngineGame trait" {
  let game = TestEngineGame::new()
  engine_game_update(game, @core.empty_input_snapshot())
  assert_eq(game.update_count, 1)
}

///|
test "engine_game_draw delegates to EngineGame trait" {
  let game = TestEngineGame::new()
  let _ = engine_game_draw(game, make_test_engine_ctx())
  assert_eq(game.draw_count, 1)
}
