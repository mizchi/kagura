///|
struct TestSceneGame {
  mut update_count : Int
  mut view_count : Int
}

///|
fn TestSceneGame::new() -> TestSceneGame {
  { update_count: 0, view_count: 0, }
}

///|
impl SceneGame for TestSceneGame with fn update_game(self, _input) {
  self.update_count += 1
}

///|
impl SceneGame for TestSceneGame with fn view_game(self) {
  self.view_count += 1
  rect(w=1.0, h=1.0)
}

///|
test "scene_game_update delegates to SceneGame trait" {
  let game = TestSceneGame::new()
  scene_game_update(game, @core.empty_input_snapshot())
  assert_eq(game.update_count, 1)
}

///|
test "scene_game_view delegates to SceneGame trait" {
  let game = TestSceneGame::new()
  let _ = scene_game_view(game)
  assert_eq(game.view_count, 1)
}

///|
test "capture_viewport keeps the example size when no headless override is set" {
  let (width, height) = @engine.capture_viewport(320, 240)
  assert_eq(width, 320)
  assert_eq(height, 240)
}
