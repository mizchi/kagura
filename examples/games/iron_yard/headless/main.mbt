///|
pub fn create(ai : Bool) -> @sim.Game {
  @sim.new_game(ai~)
}

///|
pub fn create_scene(source : String, ai : Bool) -> @sim.Game {
  @sim.game_from_scene(source, ai) catch {
    _ => panic()
  }
}

///|
pub fn replay_attack(source : String, time : Double) -> String {
  let g = @sim.attack_preview(source, time) catch { _ => panic() }
  let snapshot = @json.parse(@sim.snapshot(g)) catch { _ => panic() }
  guard snapshot is Object(fields) else { panic() }
  fields["attackAge"] = g.attack_age.to_json()
  fields["projectilePositions"] = g.projectiles
    .map(fn(p) { @sim.vector_json(p.position) })
    .to_json()
  fields["effects"] = g.effects
    .map(fn(e) -> Json {
      { "position": @sim.vector_json(e.position), "kind": e.kind, "age": e.age }
    })
    .to_json()
  snapshot.stringify()
}

///|
pub fn create_configured(
  ai : Bool,
  x : Double,
  z : Double,
  yaw : Double,
) -> @sim.Game {
  @sim.new_game(ai~, spawn=@sim.vec(x, 0.0, z), yaw~)
}

///|
pub fn start_playing(g : @sim.Game) -> Unit {
  @sim.start_playing(g)
}

///|
pub fn pause(g : @sim.Game) -> Unit {
  @sim.pause(g)
}

///|
pub fn snapshot(g : @sim.Game) -> String {
  @sim.snapshot(g)
}

///|
pub fn step(
  g : @sim.Game,
  forward : Double,
  strafe : Double,
  boost : Bool,
  jump : Bool,
  fire : Bool,
  lock : Bool,
  yaw : Double,
  pitch : Double,
  dt : Double,
) -> String {
  let i = @sim.input(
    forward~,
    strafe~,
    boost~,
    jump~,
    fire~,
    lock~,
    yaw~,
    pitch~,
  )
  @sim.advance_motion(g, i, dt)
  if g.phase == "playing" {
    let eye = @sim.camera_position(g.pilot)
    let aim = @sim.view_focus(eye, @sim.camera_aim(g.pilot), @sim.colliders(g))
    let muzzle = g.pilot.position.add(@sim.vec(0.0, 3.0, 1.0))
    @sim.advance_combat(
      g,
      i,
      { eye, aim, rifle: muzzle, left: muzzle, right: muzzle, },
      dt,
    )
    @sim.finish_mission(g, dt)
  }
  @sim.snapshot(g)
}

///|
pub fn rig_check(source : String) -> String {
  let asset = @rig.read_asset(source) catch { _ => return "{\"ok\":false}" }
  let a = @rig.new_animator(asset)
  let p = @sim.new_pilot(@sim.default_stage())
  let frame = @rig.update_animator(
    a,
    p,
    @sim.vec(0.0, 4.0, 50.0),
    0.016,
    1000.0,
  )
  let j : Json = {
    "ok": true,
    "batches": asset.batches.length(),
    "bones": asset.bones.length(),
    "rifle": @sim.vector_json(frame.rifle),
    "world": a.world.map(fn(m) {
      let v = @rig.transform_point(m, @sim.vec(0.0, 0.0, 0.0))
      @sim.vector_json(v)
    }),
  }
  j.stringify()
}
