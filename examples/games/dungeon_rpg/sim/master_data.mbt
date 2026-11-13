///|
#derive(FromJson)
pub struct MasterEnemy {
  id : String
  kind : Int32
  name : String
  hp : Int32
  attack : Int32
  armor : Int32
  speed : Int32
  sweeps : Bool
}

///|
#derive(FromJson)
pub struct MasterEncounter {
  id : String
  context : String
  enemy1 : String
  enemy2 : String
  enemy3 : Json
}

///|
#derive(FromJson)
pub struct MasterRules {
  id : String
  enemy_hp_scale : Double
  enemy_damage_scale : Double
  encounter_steps : Int32
  sweep_damage : Int32
}

///|
#derive(FromJson)
pub struct MasterTables {
  enemies : Array[MasterEnemy]
  encounters : Array[MasterEncounter]
  rules : Array[MasterRules]
}

///|
#derive(FromJson)
pub struct MasterData {
  format : String
  version : Int32
  game : String
  tables : MasterTables
}

///|
fn master_keys(data : Json, allowed : Array[String]) -> Unit raise {
  guard data is Object(fields) else { fail("invalid_master_data") }
  if fields.length() != allowed.length() {
    fail("invalid_master_fields")
  }
  for key, _ in fields {
    if !allowed.contains(key) {
      fail("invalid_master_fields")
    }
  }
}

///|
fn decode_master(source : String) -> MasterData raise {
  let json = @json.parse(source)
  master_keys(json, ["format", "version", "game", "tables"])
  guard json is { "tables": tables, .. } else { fail("invalid_master_data") }
  master_keys(tables, ["enemies", "encounters", "rules"])
  guard tables
    is {
      "enemies": Array(enemies),
      "encounters": Array(encounters),
      "rules": Array(rules),
      ..
    } else {
    fail("invalid_master_data")
  }
  for row in enemies {
    master_keys(row, [
      "id", "kind", "name", "hp", "attack", "armor", "speed", "sweeps",
    ])
  }
  for row in encounters {
    master_keys(row, ["id", "context", "enemy1", "enemy2", "enemy3"])
  }
  for row in rules {
    master_keys(row, [
      "id", "enemy_hp_scale", "enemy_damage_scale", "encounter_steps", "sweep_damage",
    ])
  }
  let data : MasterData = @json.from_json(json)
  if data.format != "kagura.master-data" ||
    data.version != 1 ||
    data.game != "dungeon_rpg" ||
    data.tables.enemies.length() != 6 ||
    data.tables.encounters.length() != 4 ||
    data.tables.rules.length() != 1 {
    fail("invalid_master_data")
  }
  let ids = ["rat", "skeleton", "slime", "lamp", "guardian", "spirit"]
  let seen : Array[Int32] = []
  for enemy in data.tables.enemies {
    if enemy.kind < 0 || enemy.kind > 5 || seen.contains(enemy.kind) {
      fail("invalid_master_enemy")
    }
    seen.push(enemy.kind)
    if enemy.id != ids[enemy.kind] ||
      enemy.name.length() < 1 ||
      enemy.name.length() > 40 ||
      enemy.hp < 1 ||
      enemy.hp > 500 ||
      enemy.attack < 1 ||
      enemy.attack > 100 ||
      enemy.armor < 0 ||
      enemy.armor > 50 ||
      enemy.speed < 1 ||
      enemy.speed > 30 {
      fail("invalid_master_enemy")
    }
  }
  let contexts = ["b1_a", "b1_b", "b2", "guardian"]
  let used : Array[String] = []
  let row_ids : Array[String] = []
  for e in data.tables.encounters {
    if !contexts.contains(e.id) ||
      row_ids.contains(e.id) ||
      !contexts.contains(e.context) ||
      used.contains(e.context) ||
      !ids.contains(e.enemy1) ||
      !ids.contains(e.enemy2) {
      fail("invalid_master_encounter")
    }
    match e.enemy3 {
      Null => ()
      String(id) => if !ids.contains(id) { fail("invalid_master_reference") }
      _ => fail("invalid_master_reference")
    }
    used.push(e.context)
    row_ids.push(e.id)
  }
  let r = data.tables.rules[0]
  if r.id != "expedition" ||
    !(r.enemy_hp_scale >= 0.5 &&
    r.enemy_hp_scale <= 3.0 &&
    r.enemy_damage_scale >= 0.5 &&
    r.enemy_damage_scale <= 3.0) ||
    r.encounter_steps < 4 ||
    r.encounter_steps > 16 ||
    r.sweep_damage < 1 ||
    r.sweep_damage > 30 {
    fail("invalid_master_rules")
  }
  for value in [r.enemy_hp_scale, r.enemy_damage_scale] {
    let steps = (value - 0.5) / 0.05
    if (steps - (steps + 0.5).to_int().to_double()).abs() > 0.0000001 {
      fail("invalid_master_rules")
    }
  }
  data
}

///|
fn default_master_data() -> MasterData {
  decode_master(default_master_source) catch {
    e => abort("invalid built-in master data: " + e.to_string())
  }
}

///|
fn master_balance(data : MasterData) -> BalanceParams {
  let r = data.tables.rules[0]
  {
    enemy_hp_scale: r.enemy_hp_scale,
    enemy_damage_scale: r.enemy_damage_scale,
    encounter_steps: r.encounter_steps,
  }
}

///|
pub fn Game::configure_master_data(self : Game, source : String) -> Unit raise {
  if self.mode != Town {
    fail("master_data_locked")
  }
  let data = decode_master(source)
  let rules = data.tables.rules[0]
  // All validation finishes before changing any rule or game state.
  self.master = data
  self.master_source = source
  self.balance = {
    enemy_hp_scale: rules.enemy_hp_scale,
    enemy_damage_scale: rules.enemy_damage_scale,
    encounter_steps: rules.encounter_steps,
  }
}

///|
pub fn Game::master_data_source(self : Game) -> String {
  self.master_source
}

///|
fn Game::spawn_foe(self : Game, id : String) -> Foe {
  let e = self.master.tables.enemies.filter(e => e.id == id)[0]
  {
    kind: e.kind,
    name: e.name,
    max_hp: e.hp,
    hp: e.hp,
    attack: e.attack,
    armor: e.armor,
    speed: e.speed,
    sweeps: e.sweeps,
    intent: 0,
  }
}

///|
fn Game::spawn_encounter(self : Game, context : String) -> Array[Foe] {
  let row = self.master.tables.encounters.filter(e => e.context == context)[0]
  let foes = [self.spawn_foe(row.enemy1), self.spawn_foe(row.enemy2)]
  if row.enemy3 is String(id) {
    foes.push(self.spawn_foe(id))
  }
  foes
}

///|
pub extend MasterEnemy with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend MasterEncounter with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend MasterRules with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend MasterTables with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend MasterData with @moonbitlang/core/json.FromJson::{from_json}
