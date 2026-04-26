///|
struct TestScene {
  mut update_count : Int
  mut draw_count : Int
}

///|
fn TestScene::new() -> TestScene {
  { update_count: 0, draw_count: 0 }
}

///|
impl Scene for TestScene with update(self, _input) {
  self.update_count = self.update_count + 1
}

///|
impl Scene for TestScene with draw(self, ctx) {
  self.draw_count = self.draw_count + 1
  let _ = ctx
  []
}

///|
fn make_test_input() -> @core.InputSnapshot {
  @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
}

///|
fn make_test_ctx() -> @engine.EngineContext {
  {
    dst: @gfx.new_image_handle(0, 640, 480),
    shader: @gfx.new_shader_handle(0, ""),
    screen_w: 640,
    screen_h: 480,
  }
}

///|
test "SceneManager initial scene draws" {
  let scene = TestScene::new()
  let manager = SceneManager::new(scene)
  let ctx = make_test_ctx()
  let _ = manager.draw(ctx)
  assert_eq(scene.draw_count, 1)
}

///|
test "SceneManager initial scene updates" {
  let scene = TestScene::new()
  let manager = SceneManager::new(scene)
  let input = make_test_input()
  manager.update(input)
  assert_eq(scene.update_count, 1)
}

///|
test "SceneManager transition_to starts transition" {
  let scene1 = TestScene::new()
  let scene2 = TestScene::new()
  let manager = SceneManager::new(scene1)
  assert_false(manager.is_transitioning())
  manager.transition_to(scene2, duration=1.0)
  assert_true(manager.is_transitioning())
}

///|
test "SceneManager transition progress advances" {
  let scene1 = TestScene::new()
  let scene2 = TestScene::new()
  let manager = SceneManager::new(scene1)
  manager.transition_to(scene2, duration=1.0)
  let input = make_test_input()
  // dt = 0.25, duration = 1.0 => progress = 0.25
  manager.update(input, dt=0.25)
  assert_true(manager.is_transitioning())
  let p = manager.transition_progress()
  assert_true(p > 0.24 && p < 0.26)
}

///|
test "SceneManager transition completes and switches scene" {
  let scene1 = TestScene::new()
  let scene2 = TestScene::new()
  let manager = SceneManager::new(scene1)
  manager.transition_to(scene2, duration=0.5)
  let input = make_test_input()
  // Advance past transition
  manager.update(input, dt=0.6)
  assert_false(manager.is_transitioning())
  // After transition, scene2 should receive updates
  manager.update(input, dt=0.1)
  assert_true(scene2.update_count > 0)
}

///|
test "SceneManager fade_alpha peaks at midpoint" {
  let scene1 = TestScene::new()
  let scene2 = TestScene::new()
  let manager = SceneManager::new(scene1)
  // No transition => 0
  assert_true(manager.transition_overlay_alpha() < 0.001)
  manager.transition_to(scene2, duration=1.0)
  let input = make_test_input()
  // At progress 0.5 => alpha should be 1.0
  manager.update(input, dt=0.5)
  let alpha = manager.transition_overlay_alpha()
  assert_true(alpha > 0.9)
}

///|
test "SceneManager draw switches to next scene at halfway" {
  let scene1 = TestScene::new()
  let scene2 = TestScene::new()
  let manager = SceneManager::new(scene1)
  let ctx = make_test_ctx()
  let input = make_test_input()
  manager.transition_to(scene2, duration=1.0)
  // Before halfway
  manager.update(input, dt=0.3)
  let _ = manager.draw(ctx)
  assert_eq(scene1.draw_count, 1)
  assert_eq(scene2.draw_count, 0)
  // After halfway
  manager.update(input, dt=0.3)
  let _ = manager.draw(ctx)
  assert_eq(scene2.draw_count, 1)
}
