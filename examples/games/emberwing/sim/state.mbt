///|
pub fn vec(x : Double, y : Double, z : Double) -> @math3d.Vec3 {
  @math3d.Vec3::new(x, y, z)
}

///|
pub fn clamp(x : Double, low : Double, high : Double) -> Double {
  if x < low {
    low
  } else if x > high {
    high
  } else {
    x
  }
}

///|
pub(all) struct Input {
  aim_x : Double
  aim_y : Double
  move_x : Double
  move_y : Double
  aspect : Double
  locking : Bool
  flame : Bool
}

///|
pub fn idle_input() -> Input {
  {
    aim_x: 0,
    aim_y: 0,
    move_x: 0,
    move_y: 0,
    aspect: 16.0 / 9,
    locking: false,
    flame: false,
  }
}

///|
pub(all) struct Enemy {
  id : Int
  mut position : @math3d.Vec3
  origin : @math3d.Vec3
  phase : Double
  mut hp : Double
  mut flash : Double
  mut shot_clock : Double
  elite : Bool
  boss : Bool
}

///|
pub(all) struct Fireball {
  target : Int
  mut position : @math3d.Vec3
  mut velocity : @math3d.Vec3
  mut age : Double
  trail : Array[@math3d.Vec3]
}

///|
pub(all) struct Shot {
  mut position : @math3d.Vec3
  velocity : @math3d.Vec3
  mut age : Double
}

///|
pub(all) struct Bowl {
  id : Int
  points : Int
  scale : Double
  mut position : @math3d.Vec3
  mut age : Double
  mut velocity_y : Double
  phase : Double
}

///|
pub(all) struct Rock {
  mut position : @math3d.Vec3
  velocity : @math3d.Vec3
  radius : Double
  phase : Double
  mut age : Double
}

///|
pub(all) struct Beam {
  origin : @math3d.Vec3
  direction : @math3d.Vec3
  aim : @math3d.Vec3
  warning : Double
  radius : Double
  mut age : Double
  mut hit : Bool
}

///|
pub(all) struct LockTarget {
  id : Int
  enemy : Int
  position : @math3d.Vec3
  radius : Double
  boss : Bool
  elite : Bool
}

///|
pub(all) struct Game {
  seed : Int
  mut mode : String
  mut time : Double
  mut wave : Int
  mut next_wave : Double
  mut next_rock : Double
  mut boss_spawned : Bool
  mut boss_defeated : Bool
  mut boss_clock : Double
  mut boss_salvo : Int
  mut victory_clock : Double
  mut beam_event : Int
  mut serial : Int
  mut hp : Int
  mut score : Int
  mut kills : Int
  mut best_chain : Int
  mut hit_timer : Double
  mut heat : Double
  mut overheated : Bool
  mut breathing : Bool
  mut was_locking : Bool
  mut lock_clock : Double
  mut fire_clock : Double
  mut player : @math3d.Vec3
  mut aim : @math3d.Vec3
  mut aim_x : Double
  mut aim_y : Double
  mut aspect : Double
  mut volley_event : Int
  mut hit_event : Int
  mut lock_event : Int
  enemies : Array[Enemy]
  locks : Array[Int]
  balls : Array[Fireball]
  shots : Array[Shot]
  bowls : Array[Bowl]
  rocks : Array[Rock]
  beams : Array[Beam]
}

///|
pub fn new_game(seed : Int) -> Game {
  let g : Game = {
    seed,
    mode: "title",
    time: 0,
    wave: 0,
    next_wave: 1.5,
    next_rock: 12,
    boss_spawned: false,
    boss_defeated: false,
    boss_clock: 0,
    boss_salvo: 0,
    victory_clock: 0,
    beam_event: 0,
    serial: 0,
    hp: 6,
    score: 0,
    kills: 0,
    best_chain: 0,
    hit_timer: 0,
    heat: 0,
    overheated: false,
    breathing: false,
    was_locking: false,
    lock_clock: 0,
    fire_clock: 0,
    player: vec(0, -0.5, 2),
    aim: vec(0, 0, -60),
    aim_x: 0,
    aim_y: 0,
    aspect: 16.0 / 9,
    volley_event: 0,
    hit_event: 0,
    lock_event: 0,
    enemies: [],
    locks: [],
    balls: [],
    shots: [],
    bowls: [],
    rocks: [],
    beams: [],
  }
  spawn_wave(g)
  g
}

///|
pub fn spawn_enemy(
  g : Game,
  position : @math3d.Vec3,
  phase : Int,
  elite? : Bool = false,
  boss? : Bool = false,
) -> Unit {
  if g.enemies.length() >= 120 {
    return
  }
  g.serial += 1
  g.enemies.push({
    id: g.serial,
    position,
    origin: position,
    phase: phase.to_double() * 0.83,
    hp: if boss {
      boss_max_hp()
    } else if elite {
      4.0
    } else {
      1.0
    },
    flash: 0,
    shot_clock: 1.1 + (phase % 9).to_double() * 0.19,
    elite,
    boss,
  })
}

///|
fn spawn_wave(g : Game) -> Unit {
  g.wave += 1
  let count = 18 + g.wave * 6
  for i = 0; i < count; i = i + 1 {
    let column = (i % 8).to_double() - 3.5
    let row = (i / 8).to_double()
    let pattern = (g.wave + g.seed % 3) % 3
    let x = if pattern == 0 {
      column * 3.1
    } else if pattern == 1 {
      column * 2.7 + @math.sin(row * 1.8) * 2
    } else {
      @math.cos(i.to_double() * 0.9) * (5 + row * 0.7)
    }
    let y = if pattern == 2 {
      @math.sin(i.to_double() * 0.9) * 5.5 + 2
    } else {
      (row - ((count - 1) / 8).to_double() * 0.5) * 1.6 + 1
    }
    spawn_enemy(
      g,
      vec(x, y, -44 - row * 3.8),
      i + g.wave * 11,
      elite=g.wave >= 5 && i % 8 == 0,
    )
  }
}

///|
pub fn command(g : Game, action : String) -> Unit {
  match action {
    "start" | "restart" | "practice-boss" | "practice-swarm" => {
      g.enemies.clear()
      g.locks.clear()
      g.balls.clear()
      g.shots.clear()
      g.bowls.clear()
      g.rocks.clear()
      g.beams.clear()
      g.time = 0
      g.wave = 0
      g.next_wave = 9
      g.next_rock = 12
      g.boss_spawned = false
      g.boss_defeated = false
      g.boss_clock = 0
      g.boss_salvo = 0
      g.victory_clock = 0
      g.hp = 6
      g.score = 0
      g.kills = 0
      g.best_chain = 0
      g.serial = 0
      g.heat = 0
      g.overheated = false
      g.hit_timer = 0
      g.lock_clock = 0
      g.fire_clock = 0
      g.player = vec(0, -0.5, 2)
      g.mode = "playing"
      if action == "practice-boss" {
        g.time = 84
        g.wave = 9
        g.next_rock = 90
        spawn_boss(g)
      } else if action == "practice-swarm" {
        g.time = 68
        g.wave = 8
        g.next_rock = 69
        spawn_wave(g)
      } else {
        spawn_wave(g)
      }
    }
    "pause" => if g.mode == "playing" { g.mode = "paused" }
    "resume" => if g.mode == "paused" { g.mode = "playing" }
    "title" => g.mode = "title"
    _ => ()
  }
  g.was_locking = false
  g.breathing = false
  g.locks.clear()
}

///|
pub fn camera(aspect : Double) -> @camera3d.Camera3D {
  let ratio = clamp(aspect, 0.35, 4)
  let distance = 15.0 / clamp(ratio, 0.4, 1)
  @camera3d.Camera3D::new_perspective(
    vec(0, 2.3, distance),
    vec(0, 0.2, -35),
    vec(0, 1, 0),
    0.88,
    ratio,
    0.1,
    400,
  )
}

///|
pub fn project(vp : @math3d.Mat4, p : @math3d.Vec3) -> @math3d.Vec3 {
  let clip = vp.mul_vec4(@math3d.Vec4::from_vec3(p, 1))
  if clip.w <= 0.1 {
    return vec(9, 9, -1)
  }
  vec(clip.x / clip.w, clip.y / clip.w, clip.w)
}

///|
pub fn mouth(g : Game) -> @math3d.Vec3 {
  g.player.add(vec(0, 0.6, -3.3))
}

///|
fn aim_point(input : Input) -> @math3d.Vec3 {
  let inv = camera(input.aspect).view_projection_matrix().inverse()
  let h = inv.mul_vec4(
    @math3d.Vec4::new(
      clamp(input.aim_x, -1, 1),
      clamp(input.aim_y, -1, 1),
      0.8,
      1,
    ),
  )
  let eye = camera(input.aspect).position
  let ray = vec(h.x / h.w, h.y / h.w, h.z / h.w).sub(eye)
  eye.add(ray.scale((-70.0 - eye.z) / ray.z))
}
