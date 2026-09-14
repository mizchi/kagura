///|
/// Outdoor sky is independent of terrain generation, detail streaming and saves.
fn GameState::push_sky_commands(
  self : GameState,
  camera : @camera3d.Camera3D,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if !self.world.hunting_grounds ||
    self.motion_preview ||
    self.world.authored_scene is Some(_) {
    return
  }
  @web_hooks.register_static_geometry(
    self.sky_mesh.vertex_data,
    self.sky_mesh.indices,
  )
  cmds.push(
    @draw3d.new_sky_draw_command(
      dst,
      self.sky_shader,
      self.sky_mesh,
      camera.view_projection_matrix(),
      camera.position,
      @draw3d.SkySettings::default(),
    ),
  )
}
