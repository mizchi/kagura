///|
/// Native has no browser global to publish into. Writing the snapshot next to a
/// captured frame is the native capture's job (generalising that path out of
/// `tools/modeling3d/` is tracked separately), so this stays a no-op and keeps
/// `DemoState::update` target-agnostic.
fn publish_snapshot(_state : DemoState) -> Unit {

}
