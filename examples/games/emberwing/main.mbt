///|
priv struct App {
  game : @sim.Game
  mut input : @sim.Input
  mut previous : Double
  mut accumulator : Double
  mut clock : Double
  mut aspect : Double
  mut render_ms : Double
  mut draws : Int
  mut triangles : Int
  shader : @gfx.ShaderHandle
  sky_shader : @gfx.ShaderHandle
  lighting : @light3d.LightingEnvironment
  sky : @mesh3d.Mesh3D
  dragon : @mesh3d.Mesh3D
  wings : Array[@mesh3d.Mesh3D]
  duck : Array[@mesh3d.Mesh3D]
  bowl : @mesh3d.Mesh3D
  island : @mesh3d.Mesh3D
  glow : @mesh3d.Mesh3D
  plane : @mesh3d.Mesh3D
  rock : @mesh3d.Mesh3D
  crown : @mesh3d.Mesh3D
}

///|
extern "js" fn now() -> Double =
  #| () => performance.now() / 1000

///|
extern "js" fn publish(source : String) -> Unit =
  #| source => globalThis.__emberwingFrame?.(JSON.parse(source))

///|
extern "js" fn install_host(
  input : (Double, Double, Double, Double, Bool, Bool) -> Unit,
  command : (String) -> Unit,
) -> Unit =
  #| (input, command) => {
  #|   fetch("assets/host.mjs").then(r => { if (!r.ok) throw Error(`host: ${r.status}`); return r.text(); })
  #|     .then(async text => { const url = URL.createObjectURL(new Blob([text], {type:"text/javascript"}));
  #|       try { (await import(url)).install({input, command}); } finally { URL.revokeObjectURL(url); } })
  #|     .catch(error => { console.error(error); document.body.append(Object.assign(document.createElement("pre"), {textContent: String(error)})); });
  #| }

///|
fn main {
  @hooks.install("#app")
  let sky = @draw3d.sky_mesh()
  @hooks.register_static_geometry(sky.vertex_data, sky.indices)
  let a : App = {
    game: @sim.new_game(73),
    input: @sim.idle_input(),
    previous: now(),
    accumulator: 0,
    clock: 0,
    aspect: 16.0 / 9,
    render_ms: 0,
    draws: 0,
    triangles: 0,
    shader: @gfx.new_shader_handle(401, palette_shader),
    sky_shader: @gfx.new_shader_handle(402, @draw3d.shader3d_sky_wgsl()),
    lighting: @light3d.LightingEnvironment::new(
      @light3d.DirectionalLight::new(
        @sim.vec(-0.5, -0.85, -0.3),
        rgb(0xffe5ba),
        0.75,
      ),
      @light3d.AmbientLight::new(rgb(0xc9e4e4), 0.56),
    ),
    sky,
    dragon: dragon_body(),
    wings: [dragon_wing(-1), dragon_wing(1)],
    duck: kawaiko_meshes(),
    bowl: bowl_mesh(),
    island: island_mesh(),
    glow: palette_mesh(@mesh3d.Mesh3D::sphere(1, 6, 4), 0xffffff, glow=1),
    plane: palette_mesh(@mesh3d.Mesh3D::plane(1, 1), 0xffffff),
    rock: rock_mesh(),
    crown: crown_mesh(),
  }
  install_host(
    fn(x, y, mx, my, lock, flame) {
      a.input = {
        aim_x: x,
        aim_y: y,
        move_x: mx,
        move_y: my,
        locking: lock,
        flame,
        aspect: a.aspect,
      }
    },
    fn(action) {
      @sim.command(a.game, action)
      a.input = @sim.idle_input()
      a.accumulator = 0
      a.previous = now()
    },
  )
  @engine.run(
    update=fn(_) { update(a) },
    draw=fn(ctx) { draw(a, ctx) },
    after_render=fn(draw_ms, render_ms) { a.render_ms = draw_ms + render_ms },
    width=1280,
    height=720,
    title="EMBERWING",
    canvas="#app",
  )
}

///|
fn update(a : App) -> Unit {
  let current = now()
  let dt = @sim.clamp(current - a.previous, 0, 0.1)
  a.previous = current
  if a.game.mode == "playing" || a.game.mode == "title" {
    a.clock += dt
  }
  a.accumulator += dt
  while a.accumulator >= 1.0 / 60 {
    @sim.step(a.game, { ..a.input, aspect: a.aspect, }, 1.0 / 60)
    a.accumulator -= 1.0 / 60
  }
}

///|
priv struct TargetView {
  id : Int
  x : Double
  y : Double
  depth : Double
  locked : Bool
  elite : Bool
  boss : Bool
} derive(ToJson)

///|
priv struct BowlView {
  x : Double
  y : Double
  age : Double
  points : Int
} derive(ToJson)

///|
priv struct DangerView {
  kind : String
  x : Double
  y : Double
  from_x : Double
  from_y : Double
  radius : Double
  remaining : Double
  progress : Double
} derive(ToJson)

///|
priv struct Hud {
  mode : String
  time : Double
  wave : Int
  hp : Int
  score : Int
  kills : Int
  best_chain : Int
  locks : Int
  fireballs : Int
  bowls : Int
  heat : Double
  overheated : Bool
  breathing : Bool
  aiming : Bool
  aim_x : Double
  aim_y : Double
  hit_timer : Double
  volley_event : Int
  hit_event : Int
  lock_event : Int
  targets : Array[TargetView]
  dishes : Array[BowlView]
  draw_calls : Int
  triangles : Int
  cpu_ms : Double
  player_x : Double
  player_y : Double
  player_screen_x : Double
  player_screen_y : Double
  player_radius : Double
  shots : Int
  rocks : Int
  beams : Int
  beam_event : Int
  boss_active : Bool
  boss_defeated : Bool
  boss_hp : Double
  boss_max_hp : Double
  boss_phase : Int
  dangers : Array[DangerView]
} derive(ToJson)

///|
fn hud(a : App, vp : @math3d.Mat4) -> String {
  let g = a.game
  let targets = @sim.lock_targets(g).map(fn(e) {
    let p = @sim.project(vp, e.position)
    TargetView::{
      id: e.id,
      x: p.x,
      y: p.y,
      depth: p.z,
      locked: g.locks.contains(e.id),
      elite: e.elite,
      boss: e.boss,
    }
  })
  let dishes = g.bowls.map(fn(b) {
    let p = @sim.project(vp, b.position.add(@sim.vec(0, 1, 0)))
    BowlView::{ x: p.x, y: p.y, age: b.age, points: b.points, }
  })
  let dangers : Array[DangerView] = []
  fn danger(
    kind : String,
    p : @math3d.Vec3,
    origin : @math3d.Vec3,
    radius : Double,
    remaining : Double,
    progress : Double,
  ) -> Unit {
    let screen = @sim.project(vp, p)
    let from = @sim.project(vp, origin)
    let edge = @sim.project(vp, p.add(@sim.vec(0, radius, 0)))
    dangers.push({
      kind,
      x: screen.x,
      y: screen.y,
      from_x: from.x,
      from_y: from.y,
      radius: (edge.y - screen.y).abs(),
      remaining,
      progress,
    })
  }
  for rock in g.rocks {
    let eta = (g.player.z - rock.position.z) / rock.velocity.z
    if eta > 0 && eta < 2.1 {
      danger(
        "rock",
        rock.position.add(rock.velocity.scale(eta)),
        rock.position,
        rock.radius + @sim.player_radius(),
        eta,
        1 - eta / 2.1,
      )
    }
  }
  for beam in g.beams {
    if beam.age < beam.warning + 0.35 {
      danger(
        "beam",
        beam.aim,
        beam.origin,
        beam.radius + @sim.player_radius(),
        beam.warning - beam.age,
        @sim.clamp(beam.age / beam.warning, 0, 1),
      )
    }
  }
  let mut boss_hp = 0.0
  for e in g.enemies {
    if e.boss {
      boss_hp = e.hp
    }
  }
  let player_screen = @sim.project(vp, g.player)
  let view : Hud = {
    mode: g.mode,
    time: g.time,
    wave: g.wave,
    hp: g.hp,
    score: g.score,
    kills: g.kills,
    best_chain: g.best_chain,
    locks: g.locks.length(),
    fireballs: g.balls.length(),
    bowls: g.bowls.length(),
    heat: g.heat,
    overheated: g.overheated,
    breathing: g.breathing,
    aiming: a.input.locking,
    aim_x: a.input.aim_x,
    aim_y: a.input.aim_y,
    hit_timer: g.hit_timer,
    volley_event: g.volley_event,
    hit_event: g.hit_event,
    lock_event: g.lock_event,
    targets,
    dishes,
    draw_calls: a.draws,
    triangles: a.triangles,
    cpu_ms: a.render_ms,
    player_x: g.player.x,
    player_y: g.player.y,
    player_screen_x: player_screen.x,
    player_screen_y: player_screen.y,
    player_radius: (@sim.project(
      vp,
      g.player.add(@sim.vec(0, @sim.player_radius(), 0)),
    ).y -
    player_screen.y).abs(),
    shots: g.shots.length(),
    rocks: g.rocks.length(),
    beams: g.beams.length(),
    beam_event: g.beam_event,
    boss_active: g.boss_spawned && !g.boss_defeated,
    boss_defeated: g.boss_defeated,
    boss_hp,
    boss_max_hp: @sim.boss_max_hp(),
    boss_phase: if boss_hp <= @sim.boss_max_hp() * 0.5 {
      2
    } else {
      1
    },
    dangers,
  }
  ToJson::to_json(view).stringify()
}
