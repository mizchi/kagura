///|
fn publish_ui_snapshot_frame(state : GameState) -> Unit {
  @engine.publish_capture_context(state.ui_snapshot().to_json())
}
