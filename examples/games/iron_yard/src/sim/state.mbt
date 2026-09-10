///|
pub(all) struct Enemy {
  id : Int
  home : @math3d.Vec3
  mut position : @math3d.Vec3
  mut velocity : @math3d.Vec3
  mut yaw : Double
  mut hp : Double
  mut lock : Double
  mut mode : String
  mut last_seen : @math3d.Vec3?
  mut memory : Double
  mut cooldown : Double
  mut warning : Double
  mut aim : @math3d.Vec3
  mut path : Array[@math3d.Vec3]
  mut repath : Double
  mut patrol_side : Double
  mut strafe : Double
}

///|
pub(all) struct Projectile {
  id : Int
  kind : Int
  target : Int
  owner : Int
  mut position : @math3d.Vec3
  mut velocity : @math3d.Vec3
  mut age : Double
  trail : Array[@math3d.Vec3]
}

///|
pub(all) struct Effect {
  position : @math3d.Vec3
  kind : Int
  mut age : Double
}

///|
pub(all) struct QueuedShot {
  target : Int
  side : Int
  mut delay : Double
}

///|
pub(all) struct CombatFrame {
  eye : @math3d.Vec3
  aim : @math3d.Vec3
  rifle : @math3d.Vec3
  left : @math3d.Vec3
  right : @math3d.Vec3
}

///|
pub(all) struct Game {
  stage : Stage
  ai : Bool
  mut pilot : Pilot
  units : Array[Enemy]
  mut phase : String
  mut elapsed : Double
  mut wave : Int
  mut hp : Double
  mut damage_flash : Double
  mut projectiles : Array[Projectile]
  mut effects : Array[Effect]
  mut queue : Array[QueuedShot]
  mut was_locking : Bool
  mut rifle_cooldown : Double
  mut missile_cooldown : Double
  mut attack_age : Double
  mut next_id : Int
  mut shots : Int
  mut missiles : Int
  mut hits : Int
  mut kills : Int
  mut enemy_shots : Int
  mut enemy_hits : Int
}

///|
pub fn new_enemy(id : Int) -> Enemy {
  let positions = [
    vec(-9.0, 0.0, -9.0),
    vec(10.0, 0.0, 20.0),
    vec(-6.0, 0.0, 41.0),
  ]
  let yaws = [0.5, 3.6, @math.PI]
  let index = id % 3
  let position = positions[index]
  {
    id,
    home: position,
    position,
    velocity: vec(0.0, 0.0, 0.0),
    yaw: yaws[index],
    hp: 180.0,
    lock: 0.0,
    mode: "patrol",
    last_seen: None,
    memory: 0.0,
    cooldown: 3.0 + index.to_double() * 0.65,
    warning: 0.0,
    aim: vec(0.0, 0.0, 0.0),
    path: [],
    repath: 0.0,
    patrol_side: 1.0,
    strafe: if index % 2 == 0 {
      -1.0
    } else {
      1.0
    },
  }
}

///|
pub fn new_game(ai? : Bool = true) -> Game {
  let stage = default_stage()
  {
    stage,
    ai,
    pilot: new_pilot(stage),
    units: [new_enemy(0), new_enemy(1), new_enemy(2)],
    phase: "ready",
    elapsed: 0.0,
    wave: 0,
    hp: 1000.0,
    damage_flash: 0.0,
    projectiles: [],
    effects: [],
    queue: [],
    was_locking: false,
    rifle_cooldown: 0.0,
    missile_cooldown: 0.0,
    attack_age: 1000.0,
    next_id: 0,
    shots: 0,
    missiles: 0,
    hits: 0,
    kills: 0,
    enemy_shots: 0,
    enemy_hits: 0,
  }
}

///|
pub fn enemy_box(e : Enemy) -> Solid {
  solid(
    e.id.to_string(),
    e.position.add(vec(0.0, 3.0, 0.0)),
    vec(5.4, 6.0, 5.4),
    0,
  )
}

///|
pub fn colliders(g : Game) -> Array[Solid] {
  let boxes = g.stage.solids.copy()
  for e in g.units {
    if e.hp > 0.0 {
      boxes.push(enemy_box(e))
    }
  }
  boxes
}

///|
pub fn cancel_combat(g : Game) -> Unit {
  g.queue = []
  g.was_locking = false
  for e in g.units {
    e.lock = 0.0
  }
}

///|
pub fn pause(g : Game) -> Unit {
  if g.phase == "playing" {
    g.phase = "paused"
  }
  cancel_combat(g)
}

///|
pub fn start_playing(g : Game) -> Unit {
  if g.phase == "ready" || g.phase == "paused" {
    g.phase = "playing"
  }
}

///|
pub fn visible(
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  solids : Array[Solid],
) -> Bool {
  for s in solids {
    if box_intersection(a, b.sub(a), s) is Some(_) {
      return false
    }
  }
  true
}
