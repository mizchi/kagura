// Live enemy state drives warnings, so interruption and death remove them immediately.

///|
fn GameState::push_melee_warnings(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  for enemy in self.world.enemies {
    if !enemy.alive || enemy.attack_frame > enemy.attack_windup + 4 {
      continue
    }
    guard enemy.attack_motion.melee_profile() is Some(profile) else { continue }
    let dx = enemy.attack_target_x - enemy.x
    let dy = enemy.attack_target_y - enemy.y
    let angle = @math.atan2(dy, dx)
    let c = @math.cos(angle)
    let s = @math.sin(angle)
    let reach = profile.reach / tile_size
    let width = profile.width * 2.0 / tile_size
    let x = enemy.x / tile_size
    let z = enemy.y / tile_size
    let height = 0.05
    let progress = (enemy.attack_frame.to_double() /
    enemy.attack_windup.to_double()).min(1.0)
    let center_x = x + c * reach * 0.5
    let center_z = z + s * reach * 0.5
    let yaw = @math.PI / 2.0 - angle
    let imminent = enemy.attack_windup - enemy.attack_frame <= 8
    let edge = if imminent {
      @math3d.Vec4::new(2.0, 1.05, 0.48, 1.0)
    } else {
      @math3d.Vec4::new(1.65, 0.32, 0.12, 1.0)
    }
    self.push_surface_combat_mesh(
      combat_core,
      combat_transform(center_x, height, center_z, width, 0.015, reach, yaw~),
      @math3d.Vec4::new(0.48 + progress * 0.5, 0.10, 0.055, 1.0),
      vp,
      dst,
      cmds,
    )
    for side in [-1.0, 1.0] {
      self.push_surface_combat_mesh(
        combat_core,
        combat_transform(
          center_x - s * width * 0.5 * side,
          height + 0.016,
          center_z + c * width * 0.5 * side,
          0.045,
          0.018,
          reach,
          yaw~,
        ),
        edge,
        vp,
        dst,
        cmds,
      )
    }
    for t in [0.0, progress, 1.0] {
      self.push_surface_combat_mesh(
        combat_core,
        combat_transform(
          x + c * reach * t,
          height + 0.017,
          z + s * reach * t,
          width,
          0.02,
          0.045,
          yaw~,
        ),
        edge,
        vp,
        dst,
        cmds,
      )
    }
    // The shrinking ring and forward-moving bar communicate the same remaining time.
    self.push_surface_combat_mesh(
      combat_ring,
      combat_transform(
        x,
        height + 0.02,
        z,
        0.34 + (1.0 - progress) * 0.45,
        1.0,
        0.34 + (1.0 - progress) * 0.45,
      ),
      edge,
      vp,
      dst,
      cmds,
    )
  }
  if self.world.ui_mode == @game.UIMode::None && !self.ground_targeting {
    if self.world.melee_lock_target(
        self.world.player.facing_angle,
        self.world.player_weapon,
      )
      is Some(enemy) {
      let r = (enemy.size * 0.5 + 3.0) / tile_size
      let height = 0.085
      self.push_surface_combat_mesh(
        combat_ring,
        combat_transform(
          enemy.x / tile_size,
          height,
          enemy.y / tile_size,
          r,
          1.0,
          r,
        ),
        @math3d.Vec4::new(1.4, 1.25, 0.6, 1.0),
        vp,
        dst,
        cmds,
      )
    }
  }
}

///|
fn GameState::push_melee_impact(
  self : GameState,
  visual : CombatVisual,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let t = visual.age.to_double() / 12.0
  let x = visual.x / tile_size
  let z = visual.y / tile_size
  let y = @game.get_tile_height(self.world.dungeon, visual.x, visual.y) + 0.65
  let size = (1.0 - t) * 0.55 * visual.radius
  let color = @math3d.Vec4::new(
    2.0 * (1.0 - t * 0.6),
    1.6 * (1.0 - t),
    0.8 * (1.0 - t),
    1.0,
  )
  for a in [visual.angle, visual.angle + 1.0, visual.angle - 1.0] {
    self.push_combat_mesh(
      combat_core,
      combat_transform(x, y, z, 0.035, size * 0.8, size * 1.8, yaw=a),
      color,
      vp,
      dst,
      cmds,
    )
  }
  if visual.age < 6 {
    self.push_combat_mesh(
      combat_ring,
      combat_transform(x, y, z, 0.20 + t, 1.0, 0.20 + t),
      color,
      vp,
      dst,
      cmds,
    )
  }
}
