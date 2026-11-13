///|
#derive(Eq, Debug)
pub(all) enum Job {
  Fighter
  Knight
  Thief
  Priest
  Mage
  Ranger
}

///|
#derive(Eq, Debug)
pub(all) enum Mode {
  Town
  Exploring
  Fighting
  Looting
  Warning
  Cleared
}

///|
#derive(Eq, Debug)
pub(all) enum Tile {
  Wall
  Passage
  Exit
  Down
  Up
  Chest
  Shrine
  Door
  Guardian
}

///|
#derive(Eq, Debug)
pub(all) enum Action {
  Attack
  Defend
  Heal
  Flame
  Potion
}

///|
#derive(Eq, Debug)
pub(all) enum Phase {
  Planning
  Review
  Report
  Won
}

///|
pub(all) struct Hero {
  id : Int32
  job : Job
  mut level : Int32
  mut xp : Int32
  mut hp : Int32
  mut mp : Int32
}

///|
pub(all) struct Foe {
  sweeps : Bool
  kind : Int32
  name : String
  max_hp : Int32
  mut hp : Int32
  attack : Int32
  armor : Int32
  speed : Int32
  mut intent : Int32
}

///|
pub(all) struct Order {
  actor : Int32
  action : Action
  target : Int32
}

///|
pub(all) struct Battle {
  foes : Array[Foe]
  orders : Array[Order]
  boss : Bool
  mut phase : Phase
  mut round : Int32
  mut reward : Int32
}

///|
pub(all) struct Game {
  experience : Array[ExperienceRecord]
  round_inputs : Array[Int32]
  mut experience_sequence : Int32
  mut experience_cause : Int32
  mut experience_battle : Int32
  mut master : MasterData
  mut master_source : String
  mut balance : BalanceParams
  mut mode : Mode
  mut revision : Int32
  mut generation : Int32
  party : Array[Hero]
  mut selected : Int32
  mut floor : Int32
  mut x : Int32
  mut z : Int32
  mut facing : Int32
  mut previous_x : Int32
  mut previous_z : Int32
  mut steps : Int32
  mut light : Int32
  mut danger : Int32
  mut gold : Int32
  mut carried_gold : Int32
  mut potions : Int32
  mut bell : Int32
  mut relic : Bool
  mut clears : Int32
  mut seed : Int32
  mut battle : Battle?
  seen : Array[Bool]
  visited : Array[Bool]
  opened : Array[Int32]
  looted : Array[Int32]
  used_shrines : Array[Int32]
  log : Array[String]
  effects : Array[Effect]
  mut next_effect_id : Int32
  mut event_id : Int32
  mut event : String
}

///|
pub fn Job::code(self : Job) -> Int32 {
  match self {
    Fighter => 0
    Knight => 1
    Thief => 2
    Priest => 3
    Mage => 4
    Ranger => 5
  }
}

///|
pub fn Job::name(self : Job) -> String {
  match self {
    Fighter => "戦士"
    Knight => "護衛"
    Thief => "盗賊"
    Priest => "僧侶"
    Mage => "魔術師"
    Ranger => "弓手"
  }
}

///|
pub fn Hero::name(self : Hero) -> String {
  ["ROWAN", "BRANN", "NYX", "SERA", "IRIS", "FINCH"][self.id]
}

///|
pub fn Hero::max_hp(self : Hero) -> Int32 {
  [24, 28, 20, 18, 16, 20][self.job.code()] + (self.level - 1) * 4
}

///|
pub fn Hero::max_mp(self : Hero) -> Int32 {
  if self.job == Priest {
    8 + self.level - 1
  } else if self.job == Mage {
    10 + self.level - 1
  } else {
    0
  }
}

///|
pub fn Hero::attack(self : Hero) -> Int32 {
  [6, 5, 4, 2, 1, 5][self.job.code()] + self.level - 1
}

///|
pub fn Hero::armor(self : Hero) -> Int32 {
  [1, 3, 1, 0, 0, 1][self.job.code()] + (self.level - 1) / 3
}

///|
fn Hero::speed(self : Hero) -> Int32 {
  [5, 3, 9, 6, 5, 7][self.job.code()]
}

///|
fn new_hero(id : Int32, job : Job) -> Hero {
  let h : Hero = { id, job, level: 1, xp: 0, hp: 0, mp: 0, }
  h.hp = h.max_hp()
  h.mp = h.max_mp()
  h
}

///|
pub fn new_game() -> Game {
  let master = default_master_data()
  let g : Game = {
    experience: [],
    round_inputs: [],
    experience_sequence: 0,
    experience_cause: 0,
    experience_battle: 0,
    mode: Town,
    revision: 0,
    generation: 0,
    balance: master_balance(master),
    master,
    master_source: default_master_source,
    party: [
      new_hero(0, Fighter),
      new_hero(1, Knight),
      new_hero(2, Thief),
      new_hero(3, Priest),
      new_hero(4, Mage),
      new_hero(5, Ranger),
    ],
    selected: -1,
    floor: 0,
    x: 1,
    z: 1,
    facing: 1,
    previous_x: 1,
    previous_z: 1,
    steps: 0,
    light: 70,
    danger: 0,
    gold: 40,
    carried_gold: 0,
    potions: 3,
    bell: 1,
    relic: false,
    clears: 0,
    seed: 731,
    battle: None,
    seen: Array::make(162, false),
    visited: Array::make(162, false),
    opened: [],
    looted: [],
    used_shrines: [],
    log: [
      "灯台宿場へようこそ。地下の守護者から『灯火の印章』を持ち帰ろう。",
    ],
    effects: [],
    next_effect_id: 0,
    event_id: 0,
    event: "",
  }
  g.reveal()
  g
}

///|
fn Game::note(self : Game, message : String, event~ : String = "") -> Unit {
  self.log.push(message)
  if self.log.length() > 9 {
    ignore(self.log.remove(0))
  }
  if event != "" {
    self.event_id += 1
    self.event = event
  }
}

///|
fn Game::roll(self : Game, n : Int32) -> Int32 {
  self.seed = (self.seed * 75 + 74) % 65521
  self.seed % n
}

///|
pub fn Game::active_actor(self : Game) -> Int32 {
  let b = self.battle.unwrap()
  for i in 0..<6 {
    if self.party[i].hp > 0 && !b.orders.any(o => o.actor == i) {
      return i
    }
  }
  -1
}

///|
pub fn Game::mode_name(self : Game) -> String {
  match self.mode {
    Town => "town"
    Exploring => "explore"
    Fighting => "battle"
    Looting => "chest"
    Warning => "warning"
    Cleared => "cleared"
  }
}

///|
pub extend Job with Eq::{equal, not_equal}

///|
pub extend Mode with Eq::{equal, not_equal}

///|
pub extend Tile with Eq::{equal, not_equal}

///|
pub extend Action with Eq::{equal, not_equal}

///|
pub extend Phase with Eq::{equal, not_equal}

///|
pub extend Job with @debug.Debug::{to_repr}

///|
pub extend Mode with @debug.Debug::{to_repr}

///|
pub extend Tile with @debug.Debug::{to_repr}

///|
pub extend Action with @debug.Debug::{to_repr}

///|
pub extend Phase with @debug.Debug::{to_repr}
