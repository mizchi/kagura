///|
/// Stable ESM export facade. Implementations belong to the capability packages.

///|
pub fn apply_object_patch(a0 : @core.Any, a1 : @core.Any) -> @core.Any {
  @ui_sync.apply_object_patch(a0, a1)
}

///|
pub fn command_needs_depth(a0 : @core.Any) -> Bool {
  @render.command_needs_depth(a0)
}

///|
pub fn create_control_input(a0 : @core.Any) -> @core.Any {
  @input.create_control_input(a0)
}

///|
pub fn create_dependency_gate() -> @core.Any {
  @ui_sync.create_dependency_gate()
}

///|
pub fn create_gamepad_reader(a0 : @core.Any) -> @core.Any {
  @input.create_gamepad_reader(a0)
}

///|
pub fn create_motion_player(a0 : @core.Any) -> @core.Any {
  @playback.create_motion_player(a0)
}

///|
pub fn equal_dwords(a0 : @core.Any, a1 : @core.Any, a2 : @core.Any) -> Bool {
  @render.equal_dwords(a0, a1, a2)
}

///|
pub fn get_instance_count(a0 : @core.Any) -> Int {
  @render.get_instance_count(a0)
}

///|
pub fn get_resource_cache_key(a0 : @core.Any) -> Int {
  @render.get_resource_cache_key(a0)
}

///|
pub fn install_frame_profiler(a0 : @core.Any) -> @core.Any {
  @diagnostics.install_frame_profiler(a0)
}

///|
pub fn instance_uniform_shader(a0 : String, a1 : @core.Any) -> String {
  @render.instance_uniform_shader(a0, a1)
}

///|
pub fn is_3d_shader(a0 : String) -> Bool {
  @render.is_3d_shader(a0)
}

///|
pub fn is_stride32(a0 : String) -> Bool {
  @render.is_stride32(a0)
}

///|
pub fn is_stride64(a0 : String) -> Bool {
  @render.is_stride64(a0)
}

///|
pub fn normalize_gamepad(a0 : @core.Any) -> @core.Any {
  @input.normalize_gamepad(a0)
}

///|
pub fn parse_texture_bindings(a0 : String) -> @core.Any {
  @render.parse_texture_bindings(a0)
}

///|
pub fn percentile(a0 : @core.Any, a1 : Double) -> Double {
  @diagnostics.percentile(a0, a1)
}

///|
pub fn read_frame_profile(a0 : @core.Any) -> @core.Any {
  @diagnostics.read_frame_profile(a0)
}

///|
pub fn register_geometry(
  a0 : @core.Any,
  a1 : @core.Any,
  a2 : @core.Any,
  a3 : @core.Any,
  a4 : @core.Any,
) -> @core.Any {
  @render.register_geometry(a0, a1, a2, a3, a4)
}

///|
pub fn register_static_geometry(
  a0 : @core.Any,
  a1 : @core.Any,
  a2 : @core.Any,
) -> @core.Any {
  @render.register_static_geometry(a0, a1, a2)
}

///|
pub fn snapshot_draw_geometry(
  a0 : @core.Any,
  a1 : @core.Any,
  a2 : @core.Any,
) -> @core.Any {
  @render.snapshot_draw_geometry(a0, a1, a2)
}

///|
pub fn stick_vector(
  a0 : @core.Any,
  a1 : @core.Any,
  a2 : @core.Any,
  a3 : @core.Any,
) -> @core.Any {
  @input.stick_vector(a0, a1, a2, a3)
}

///|
pub fn summarize_intervals(a0 : @core.Any) -> @core.Any {
  @diagnostics.summarize_intervals(a0)
}

///|
pub fn unregister_geometry(a0 : @core.Any, a1 : @core.Any) -> Unit {
  @render.unregister_geometry(a0, a1)
}
