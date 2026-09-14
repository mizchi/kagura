///|
/// Kind 1: terrain; 2: camera obstruction; 3: sparse ground cover.
/// Tags survive material batching, so visibility never rebuilds a mesh.
fn tag_scenery_geometry(
  g : @procedural3d.RigidGeometry,
  start : Int,
  kind : Double,
) -> Unit {
  for i in (start / 8)..<(g.vertices.length() / 8) {
    g.vertices[i * 8 + 7] = kind
  }
}

///|
fn GameState::scenery_draw(
  self : GameState,
  dst : @gfx.ImageHandle,
  region : @gfx.DstRegion,
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  vp : @math3d.Mat4,
  offset? : Int = 0,
) -> @gfx.DrawTrianglesCommand {
  let cmd = @draw3d.new_lit_colored_mesh_draw_command(
    dst,
    self.scenery_shader,
    region,
    offset,
    0,
    0,
    @gfx.BlendMode::from_int(0),
    mesh,
    model,
    vp,
    self.lighting,
    self.scenery_focus(),
    [],
  )
  let eye = self.camera.position()
  let p = self.world.player
  for
    v in [
      eye.x,
      eye.y,
      eye.z,
      if self.camera_settings.mode == 1 {
        1.0
      } else {
        0.0
      },
      p.x / tile_size,
      @game.get_tile_height(self.world.dungeon, p.x, p.y) + 0.75,
      p.y / tile_size,
      0.85,
    ] {
    cmd.uniform_dwords.push(v.to_float().reinterpret_as_int())
  }
  cmd
}
