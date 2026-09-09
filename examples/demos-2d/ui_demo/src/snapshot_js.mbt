///|
/// Publish the UI snapshot to `globalThis.__kaguraUISnapshot`.
///
/// Refreshed every frame so a Playwright / capture driver reading it at an
/// arbitrary moment never sees stale geometry. A shipping game would gate this
/// behind a debug flag; a demo whose point is the verification loop leaves it on.
fn publish_snapshot(state : DemoState) -> Unit {
  @ui.publish_ui_snapshot(state.ui_snapshot())
}
