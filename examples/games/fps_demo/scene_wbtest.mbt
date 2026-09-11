///|
fn authored_fixture() -> String {
  let project = @scenes.project() catch { error => abort(error.to_string()) }
  project.to_json().stringify()
}

///|
test "authored scenes drive game state and reject invalid updates atomically" {
  let state = GameState::new()
  state.apply_scene_project(authored_fixture())
  assert_eq(state.camera.position.z, 5.0)
  assert_eq(state.authored.unwrap().current_id(), "training")
  let before = state.scene_snapshot()
  assert_true(
    try {
      state.apply_scene_project("{}")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(state.scene_snapshot(), before)
  assert_true(
    try {
      state.transition_scene("missing")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(state.scene_snapshot(), before)
}

///|
test "authored walls block camera movement" {
  let state = GameState::new()
  state.apply_scene_project(authored_fixture())
  assert_eq(state.targets.length(), 1)
  state.camera = @camera3d.FPSCamera::new(
    @math3d.Vec3::new(2.99, 1.7, 0.0),
    0.0,
    0.0,
    state.camera.fov_y_rad,
    state.camera.aspect,
    state.camera.near,
    state.camera.far,
  )
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [68])
  for _ in 0..<20 {
    state.update(input)
  }
  assert_true(state.camera.position.x < 3.0)
}

///|
test "standalone startup uses compiled MoonBit scenes" {
  let state = GameState::new()
  state.load_default_scene()
  assert_eq(state.authored.unwrap().current_id(), "training")
}
