///|
test "selected bird edits preserve live state and computed speed is read only" {
  let game = Game::new()
  game.debug_pause(true)
  let state = game.debug_state()
  let inspector = debug_inspector()
  let next = inspector.edit(state, subject="bird", field="velocity", value=-2)
  game.debug_replace(next)
  assert_eq(game.velocity, -2.0)
  assert_eq(game.bird_y.get(), state.bird_y)
  let fields = inspector.describe(game.debug_state())[0].fields
  assert_eq(fields[2].to_json(), {
    "id": "speed",
    "label": "Speed",
    "kind": "number",
    "value": 2,
    "unit": "px/tick",
    "access": "readonly",
  })
  let rejected = try {
    ignore(inspector.edit(state, subject="bird", field="speed", value=2))
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
}
