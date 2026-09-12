///|
fn publish_scene_snapshot(snapshot : @kagura_ui.UISnapshot) -> Unit {
  @engine.publish_capture_context(snapshot.to_json())
}
