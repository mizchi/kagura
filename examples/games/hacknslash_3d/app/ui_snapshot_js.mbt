///|
fn publish_ui_snapshot_frame(state : GameState) -> Unit {
  @ui.publish_ui_snapshot_lazy(fn() { state.ui_snapshot() })
}
