///|
/// Editor calls change the frozen presentation; they never advance the mission.
pub fn editor_scene(source : String, wave : Int) -> Bool {
  if !load_scene(source, false) {
    return false
  }
  guard app.val is Some(a) else { return false }
  guard a.game.scene is Some(scene) else { return false }
  if wave < 0 || wave >= scene.waves.length() {
    return false
  }
  a.editing = true
  a.edit_action = false
  a.game.units.clear()
  a.game.wave = wave
  @sim.append_wave(a.game)
  @rig.update_animator(
    a.animator,
    a.game.pilot,
    a.game.pilot.position.add(@sim.vec(0.0, 3.0, 20.0)),
    0.0,
    1000.0,
  )
  |> ignore
  true
}

///|
pub fn editor_camera(
  ex : Double,
  ey : Double,
  ez : Double,
  tx : Double,
  ty : Double,
  tz : Double,
) -> Unit {
  if app.val is Some(a) {
    a.eye = @sim.vec(ex, ey, ez)
    a.edit_target = @sim.vec(tx, ty, tz)
  }
}

///|
pub fn editor_selection(
  x : Double,
  y : Double,
  z : Double,
  w : Double,
  h : Double,
  d : Double,
) -> Unit {
  if app.val is Some(a) {
    a.edit_selection = if w > 0.0 {
      Some(
        @sim.solid("selection", @sim.vec(x, y, z), @sim.vec(w, h, d), 0xf2c878),
      )
    } else {
      None
    }
  }
}

///|
pub fn editor_active(active : Bool) -> Unit {
  if app.val is Some(a) {
    a.edit_active = active
  }
}

///|
pub fn editor_attack(source : String, time : Double) -> Bool {
  let g = @sim.attack_preview(source, time) catch { _ => return false }
  guard app.val is Some(a) else { return false }
  a.game = g
  a.edit_action = true
  a.editing = true
  true
}

///|
fn draw_selection(
  a : App,
  ctx : @engine.EngineContext,
  commands : Array[@gfx.DrawTrianglesCommand],
  vp : @math3d.Mat4,
) -> Unit {
  guard a.edit_selection is Some(s) else { return }
  let p = s.center
  let h = s.size.scale(0.5)
  for x in [-1.0, 1.0] {
    for y in [-1.0, 1.0] {
      beam(
        a,
        ctx,
        commands,
        p.add(@sim.vec(x * h.x, y * h.y, -h.z)),
        p.add(@sim.vec(x * h.x, y * h.y, h.z)),
        0.06,
        0xf2c878,
        vp,
      )
      beam(
        a,
        ctx,
        commands,
        p.add(@sim.vec(x * h.x, -h.y, y * h.z)),
        p.add(@sim.vec(x * h.x, h.y, y * h.z)),
        0.06,
        0xf2c878,
        vp,
      )
      beam(
        a,
        ctx,
        commands,
        p.add(@sim.vec(-h.x, x * h.y, y * h.z)),
        p.add(@sim.vec(h.x, x * h.y, y * h.z)),
        0.06,
        0xf2c878,
        vp,
      )
    }
  }
}

///|
fn draw_attack(
  a : App,
  ctx : @engine.EngineContext,
  commands : Array[@gfx.DrawTrianglesCommand],
  vp : @math3d.Mat4,
) -> Unit {
  for i in 0..<=30 {
    let coordinate = -30.0 + i.to_double() * 2.0
    beam(
      a,
      ctx,
      commands,
      @sim.vec(coordinate, 0.025, -30.0),
      @sim.vec(coordinate, 0.025, 30.0),
      0.04,
      0x70848e,
      vp,
    )
    beam(
      a,
      ctx,
      commands,
      @sim.vec(-30.0, 0.025, coordinate),
      @sim.vec(30.0, 0.025, coordinate),
      0.04,
      0x70848e,
      vp,
    )
  }
  let action = @sim.rifle_action(a.game)
  let age = a.game.attack_age
  let recoil = if age >= 0.0 && age < action.recoilDuration {
    action.recoilStrength *
    @math.sin(@math.PI * age / action.recoilDuration) *
    @math.exp(-3.0 * age / action.recoilDuration)
  } else {
    0.0
  }
  submit(
    a,
    ctx,
    commands,
    a.cube,
    trs(
      @sim.vec(0.0, 3.0, 0.0),
      @sim.vec(0.9, 0.8, 4.0),
      rotation=@math3d.Quaternion::from_axis_angle(
        @sim.vec(1.0, 0.0, 0.0),
        -recoil,
      ),
    ),
    material(0x9aadb1),
    vp,
  )
  if a.game.units[0].hp > 0.0 {
    submit(
      a,
      ctx,
      commands,
      a.cube,
      trs(@sim.vec(0.0, 3.0, 16.0), @sim.vec(5.4, 6.0, 5.4)),
      material(0xc57f61),
      vp,
    )
  }
  if age < action.flashDuration {
    submit(
      a,
      ctx,
      commands,
      a.sphere,
      trs(@sim.vec(0.0, 3.0, 2.4), @sim.vec(0.55, 0.55, 0.55)),
      material(action.flashColor, glow=true),
      vp,
    )
  }
}
