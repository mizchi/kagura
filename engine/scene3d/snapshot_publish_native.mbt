///|
/// No-op on native: there is no browser global to publish to. Native capture
/// can write `Scene3DSnapshot::to_json` itself.
pub fn publish_scene3d_snapshot_lazy(build : () -> Scene3DSnapshot) -> Unit {
  ignore(build)
}
