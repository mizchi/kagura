///|
pub(all) struct Input {
  x : Double
  z : Double
  strike : Bool
  breaker : Bool
  evade : Bool
  start : Bool
  retry : Bool
  pause : Bool
}

///|
pub fn idle_input() -> Input {
  {
    x: 0.0,
    z: 0.0,
    strike: false,
    breaker: false,
    evade: false,
    start: false,
    retry: false,
    pause: false,
  }
}

///|
pub(all) struct Player {
  mut x : Double
  mut z : Double
  mut hp : Int32
  max_hp : Int32
  mut facing : Double
  mut action : String
  mut age : Int32
  mut combo : Int32
  mut combo_timer : Int32
  mut serial : Int32
  mut buffer : Int32
  mut heavy_buffer : Bool
  mut invulnerable : Int32
  mut evade_cooldown : Int32
  mut evade_buffer : Int32
  mut evade_x : Double
  mut evade_z : Double
}

///|
pub(all) struct Enemy {
  id : Int32
  mut kind : Int32
  max_hp : Int32
  mut hp : Int32
  mut x : Double
  mut z : Double
  mut facing : Double
  mut action : String
  mut timer : Int32
  mut phase_total : Int32
  mut attack_hit : Bool
  mut aim_z : Double
  mut last_hit : Int32
  mut flash : Int32
  mut death_age : Int32
}

///|
pub(all) struct Burst {
  x : Double
  z : Double
  kind : String
  mut age : Int32
}

///|
pub(all) struct Game {
  mut mode : String
  mut generation : Int32
  mut tick : Int32
  mut frames : Int32
  mut player : Player
  enemies : Array[Enemy]
  bursts : Array[Burst]
  mut serial : Int32
  mut stage : Int32
  mut camera : Double
  mut hit_stop : Int32
  mut shake : Int32
  mut score : Int32
  mut hits : Int32
  mut blocks : Int32
  mut attacks : Int32
  mut dodges : Int32
  mut taken : Int32
  mut best_combo : Int32
  mut chain : Int32
  mut chain_timer : Int32
  mut sound_id : Int32
  mut sound : String
  mut announce : Int32
  mut damage : Int32
  mut windup : Int32
  mut previous_evade : Bool
  mut previous_pause : Bool
  mut previous_retry : Bool
  mut previous_start : Bool
  mut previous_strike : Bool
}

///|
fn new_player() -> Player {
  {
    x: 140.0,
    z: 372.0,
    hp: 6,
    max_hp: 6,
    facing: 1.0,
    action: "idle",
    age: 0,
    combo: -1,
    combo_timer: 0,
    serial: 0,
    buffer: 0,
    heavy_buffer: false,
    invulnerable: 0,
    evade_cooldown: 0,
    evade_buffer: 0,
    evade_x: 1.0,
    evade_z: 0.0,
  }
}

///|
pub fn new_game() -> Game {
  let g : Game = {
    mode: "title",
    generation: 0,
    tick: 0,
    frames: 0,
    player: new_player(),
    enemies: [],
    bursts: [],
    serial: 0,
    stage: 0,
    camera: 0.0,
    hit_stop: 0,
    shake: 0,
    score: 0,
    hits: 0,
    blocks: 0,
    attacks: 0,
    dodges: 0,
    taken: 0,
    best_combo: 0,
    chain: 0,
    chain_timer: 0,
    sound_id: 0,
    sound: "",
    announce: 0,
    damage: 1,
    windup: default_reaction_budget.windup_frames(),
    previous_evade: false,
    previous_pause: false,
    previous_retry: false,
    previous_start: false,
    previous_strike: false,
  }
  g.spawn_stage()
  g
}

///|
pub fn clamp(v : Double, low : Double, high : Double) -> Double {
  v.max(low).min(high)
}

///|
pub fn Game::gate_x(self : Game) -> Double {
  (self.stage + 1).to_double() * 760.0
}

///|
pub fn Game::remaining(self : Game) -> Int32 {
  self.enemies.filter(e => e.hp > 0).length()
}

///|
pub fn Game::spawn(self : Game, kind : Int32, x : Double, z : Double) -> Unit {
  self.serial += 1
  let hp = match kind {
    1 => 5
    2 => 2
    3 => 16
    _ => 3
  }
  self.enemies.push({
    id: self.serial,
    kind,
    x,
    z,
    hp,
    max_hp: hp,
    facing: -1.0,
    action: "approach",
    timer: 18 + self.serial % 3 * 8,
    phase_total: 18 + self.serial % 3 * 8,
    attack_hit: false,
    aim_z: z,
    last_hit: -1,
    flash: 0,
    death_age: 0,
  })
}

///|
fn Game::spawn_stage(self : Game) -> Unit {
  match self.stage {
    0 => {
      self.spawn(0, 460.0, 372.0)
      self.spawn(0, 670.0, 326.0)
    }
    1 => {
      self.spawn(1, 1030.0, 370.0)
      self.spawn(0, 1220.0, 322.0)
      self.spawn(2, 1330.0, 414.0)
    }
    _ => {
      self.spawn(3, 1960.0, 365.0)
      self.spawn(2, 2130.0, 420.0)
    }
  }
}

///|
pub fn Game::start(self : Game) -> Unit {
  self.generation += 1
  self.set_mode("playing")
  self.tick = 0
  self.frames = 0
  self.player = new_player()
  self.enemies.clear()
  self.bursts.clear()
  self.serial = 0
  self.stage = 0
  self.camera = 0.0
  self.hit_stop = 0
  self.shake = 0
  self.score = 0
  self.hits = 0
  self.blocks = 0
  self.attacks = 0
  self.dodges = 0
  self.taken = 0
  self.best_combo = 0
  self.chain = 0
  self.chain_timer = 0
  self.announce = 110
  self.spawn_stage()
}

///|
fn Game::effect(self : Game, x : Double, z : Double, kind : String) -> Unit {
  self.bursts.push({ x, z, kind, age: 0, })
  if self.bursts.length() > 20 {
    ignore(self.bursts.remove(0))
  }
  self.sound_id += 1
  self.sound = kind
}
