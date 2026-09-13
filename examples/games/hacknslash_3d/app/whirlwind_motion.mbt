///|
/// Root rotation spins the equipped rig; movement remains owned by simulation.
/// The loop is weapon-independent, including the bow's left-hand attachment.
fn PlayerCharacter::sample_whirlwind(self : PlayerCharacter) -> Unit {
  let phase = self.action_time *
    60.0 /
    @game.whirlwind_cycle_frames.to_double() *
    @math.PI *
    2.0
  let stride = @math.sin(phase * 2.0)
  self.local_poses[0] = self.local_poses[0].with_position(
    @math3d.Vec3::new(0.0, -0.04, 0.0),
  )
  self.rotate_bone(0, 0.0, -phase, 0.0)
  self.rotate_bone(1, 0.08, -0.15, 0.0)
  self.rotate_bone(5, -0.08, 0.20, 0.0)
  self.rotate_bone(2, -0.3, 0.2, -1.15)
  self.rotate_bone(3, -0.2, 0.0, -0.15)
  self.rotate_bone(6, -0.25, -0.2, 1.05)
  self.rotate_bone(7, -0.35, 0.0, 0.15)
  self.rotate_bone(8, stride * 0.3, 0.0, -0.15)
  self.rotate_bone(10, -stride * 0.3, 0.0, 0.15)
  self.rotate_bone(9, 0.2 + stride * 0.12, 0.0, 0.0)
  self.rotate_bone(11, 0.2 - stride * 0.12, 0.0, 0.0)
  self.rotate_bone(12, -0.55, -0.2, -0.35)
  self.rotate_bone(13, -0.55, -0.2, 0.35)
}
