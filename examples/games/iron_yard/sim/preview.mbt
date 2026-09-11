///|
pub fn attack_preview(source : String, time : Double) -> Game raise {
  let g = game_from_scene(source, false)
  start_playing(g)
  let frame : CombatFrame = {
    eye: vec(0.0, 3.0, 0.0),
    aim: vec(0.0, 3.0, 16.0),
    rifle: vec(0.0, 3.0, 2.0),
    left: vec(-1.0, 4.0, 0.0),
    right: vec(1.0, 4.0, 0.0),
  }
  let mut elapsed = 0.0
  while elapsed < time - 0.000000001 {
    let dt = min(1.0 / 120.0, time - elapsed)
    advance_combat(g, input(fire=elapsed == 0.0), frame, dt)
    elapsed += dt
  }
  g
}
