///|
/// Three retained meshes, using the same radius and phase as contact detection.
fn GameState::push_whirlwind_trail(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let channel = self.world.arts.whirlwind
  if !channel.active {
    return
  }
  let p = self.world.player
  let x = p.x / tile_size
  let z = p.y / tile_size
  let y = @game.get_tile_height(self.world.dungeon, p.x, p.y)
  let radius = self.world.whirlwind_radius() / tile_size
  let angle = @math.PI / 2.0 -
    p.facing_angle -
    channel.frame.to_double() /
    @game.whirlwind_cycle_frames.to_double() *
    @math.PI *
    2.0
  let contact = (channel.frame - @game.whirlwind_contact_frame).abs() < 3
  self.push_surface_combat_mesh(
    combat_ring,
    combat_transform(x, 0.04, z, radius, 1.0, radius),
    @math3d.Vec4::new(0.40, 0.62, 0.51, 1.0),
    vp,
    dst,
    cmds,
  )
  for i in 0..<2 {
    let r = radius * (if i == 0 { 1.0 } else { 0.8 })
    self.push_combat_mesh(
      combat_arc,
      combat_transform(
        x,
        y + 0.46 + i.to_double() * 0.12,
        z,
        r,
        1.0,
        r,
        yaw=angle + i.to_double() * @math.PI,
      ),
      if contact {
        @math3d.Vec4::new(1.65, 1.9, 1.5, 1.0)
      } else {
        @math3d.Vec4::new(0.9, 1.2, 1.03, 1.0)
      },
      vp,
      dst,
      cmds,
    )
  }
}
