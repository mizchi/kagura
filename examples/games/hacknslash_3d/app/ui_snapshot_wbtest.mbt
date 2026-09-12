///|
fn snapshot_ids(snapshot : @ui.UISnapshot) -> Array[String] {
  snapshot.nodes.map(node => node.id)
}

///|
fn snapshot_has_id(snapshot : @ui.UISnapshot, id : String) -> Bool {
  snapshot_ids(snapshot).contains(id)
}

///|
fn snapshot_node(snapshot : @ui.UISnapshot, id : String) -> @ui.UISnapshotNode {
  for node in snapshot.nodes {
    if node.id == id {
      return node
    }
  }
  abort("missing snapshot node " + id)
}

///|
test "title snapshot names the title labels" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Title
  let snapshot = state.ui_snapshot()
  assert_eq(snapshot.state, "title")
  assert_true(snapshot_has_id(snapshot, "title"))
  assert_eq(snapshot_node(snapshot, "title").text, Some("HACK N SLASH"))
  assert_true(snapshot_has_id(snapshot, "subtitle"))
  assert_eq(snapshot_node(snapshot, "subtitle").text, Some("3D"))
}

///|
test "title snapshot fallback metrics stay on the 640 screen" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Title
  let snapshot = state.ui_snapshot()
  let title = snapshot_node(snapshot, "title")
  assert_true(title.left >= -0.5)
  assert_true(title.left + title.width <= 640.5)
}

///|
test "playing snapshot publishes HP bar and floor chrome" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let snapshot = state.ui_snapshot()
  assert_eq(snapshot.state, "playing")
  assert_true(snapshot_has_id(snapshot, "hp_bar"))
  assert_true(snapshot_has_id(snapshot, "hp_label"))
  assert_true(snapshot_has_id(snapshot, "hp_text"))
  assert_true(snapshot_has_id(snapshot, "floor"))
  assert_true(snapshot_has_id(snapshot, "gold"))
  let hp_bar = snapshot_node(snapshot, "hp_bar")
  assert_eq(hp_bar.left, 8.0)
  assert_eq(hp_bar.width, 140.0)
  assert_eq(hp_bar.height, 14.0)
  assert_eq(snapshot_node(snapshot, "hp_bar").path, "hud>hp_bar")
  assert_eq(snapshot_node(snapshot, "hp_label").path, "hud>hp_label")
  let floor = snapshot_node(snapshot, "floor")
  assert_eq(floor.path, "hud>floor")
  assert_true(floor.top >= -0.5)
}

///|
test "gameover snapshot names the result labels" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.GameOver
  let snapshot = state.ui_snapshot()
  assert_eq(snapshot.state, "gameover")
  assert_eq(snapshot_node(snapshot, "gameover").text, Some("GAME OVER"))
}

///|
test "inventory overlay snapshot names the header" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.world.ui_mode = @game.Inventory
  let snapshot = state.ui_snapshot()
  assert_eq(snapshot.state, "inventory")
  assert_eq(snapshot_node(snapshot, "inventory_title").text, Some("INVENTORY"))
  assert_eq(snapshot_node(snapshot, "inventory_title").path, "inventory>title")
}
