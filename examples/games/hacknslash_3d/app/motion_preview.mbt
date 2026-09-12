///|
/// Deterministic authoring fixture: ?snapshot=motions&frames=0..48. Uses the
/// actual game rig, materials and rendering path. P resumes normal combat.
fn apply_enemy_motion_preview(state : GameState, frame : Int) -> Unit {
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  state.world.projectiles.clear()
  let px = state.world.player.x
  let py = state.world.player.y
  let roles = [
    (@game.Basic, @game.Punch),
    (@game.Fast, @game.SpearThrust),
    (@game.Caster, @game.CastSpell),
  ]
  for i in 0..<roles.length() {
    let (kind, motion) = roles[i]
    let x = px + (i - 1).to_double() * tile_size * 1.8
    let y = py - tile_size * 2.5
    let enemy = @game.make_enemy(x, y, kind, 100, 0.0, 10.0)
    enemy.begin_attack(motion, 24, 24, x, y + 100.0)
    enemy.attack_frame = frame.max(0).min(48)
    state.world.enemies.push(enemy)
  }
  state.camera = state.camera
    .with_distance(9.5)
    .orbit(-state.camera.yaw, 0.85 - state.camera.pitch)
    .with_target(@math3d.Vec3::new(px / tile_size, 0.45, py / tile_size - 1.8))
  state.motion_preview = true
}

///|
/// Bow authoring fixture: ?snapshot=bow&frames=0..48, release at frame 24.
fn apply_bow_motion_preview(state : GameState, frame : Int) -> Unit {
  apply_enemy_motion_preview(state, frame)
  state.world.enemies.clear()
  let x = state.world.player.x
  let y = state.world.player.y - tile_size * 2.5
  let archer = @game.make_enemy(x, y, @game.Ranged, 100, 0.0, 10.0)
  archer.begin_attack(@game.BowShot, 24, 24, x, y + 100.0)
  archer.attack_frame = frame.max(0).min(48)
  state.world.enemies.push(archer)
  if frame >= 24 {
    state.world.projectiles.push({
      x,
      y: y + (frame - 24).to_double() * 3.0,
      vx: 0.0,
      vy: 3.0,
      age: frame - 24,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.Arrow,
    })
  }
  state.camera = state.camera.with_distance(6.0).orbit(0.6, -0.15)
}
