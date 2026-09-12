///|
fn publish_ui_snapshot_frame(state : GameState) -> Unit {
  @ui.publish_ui_snapshot(state.ui_snapshot())
}
