///|
fn publish_snapshot(state : DemoState) -> Unit {
  @engine.publish_capture_context(state.ui_snapshot().to_json())
}
