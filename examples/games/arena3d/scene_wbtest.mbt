///|
fn authored_fixture() -> String {
  let project = @scenes.project() catch { error => abort(error.to_string()) }
  project.to_json().stringify()
}

///|
test "authored scenes drive game state and reject invalid updates atomically" {
  let state = GameState::new()
  state.apply_scene_project(authored_fixture())
  assert_eq(state.player.position.z, 5.0)
  assert_eq(state.authored.unwrap().current_id(), "training")
  let before = state.scene_snapshot()
  assert_true(try { state.apply_scene_project("{}"); false } catch { _ => true })
  assert_eq(state.scene_snapshot(), before)
  assert_true(try { state.transition_scene("missing"); false } catch { _ => true })
  assert_eq(state.scene_snapshot(), before)
}

///|
test "walking into a portal activates the destination and reset keeps authored state" {
  let state = GameState::new()
  state.apply_scene_project(authored_fixture())
  let up = @core.new_input_snapshot(0.0,0.0,0.0,0.0,[87])
  for _ in 0..<35 { state.update(up) }
  assert_eq(state.authored.unwrap().current_id(), "second")
  state.reset()
  assert_eq(state.player.position.z, 5.0)
  assert_eq(state.items.length(), 1)
  assert_eq(state.enemies.length(), 1)
}

///|
test "standalone startup uses compiled MoonBit scenes" {
  let state = GameState::new()
  state.load_default_scene()
  assert_eq(state.authored.unwrap().current_id(), "training")
}
