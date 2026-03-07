// Save/Load system via localStorage (JS target only)
// Serializes character progress: inventory, equipment, skills, floor, score

extern "js" fn js_storage_set(key : String, value : String) -> Unit =
  #| (key, value) => { try { localStorage.setItem(key, value); } catch(e) {} }

extern "js" fn js_storage_get(key : String) -> String =
  #| (key) => { try { return localStorage.getItem(key) ?? ""; } catch(e) { return ""; } }

extern "js" fn js_storage_remove(key : String) -> Unit =
  #| (key) => { try { localStorage.removeItem(key); } catch(e) {} }

let save_key : String = "hacknslash3d_save"

// Encode game state as a simple key=value format
// Format: floor|score|sp|weapon|armor|accessory|skills|items
fn GameState::serialize_save(self : GameState) -> String {
  let parts : Array[String] = []
  // 0: floor
  parts.push(self.floor.to_string())
  // 1: score
  parts.push(self.score.to_string())
  // 2: skill points
  parts.push(self.skills.skill_points.to_string())
  // 3: weapon
  parts.push(serialize_opt_item(self.equipment.weapon))
  // 4: armor
  parts.push(serialize_opt_item(self.equipment.armor))
  // 5: accessory
  parts.push(serialize_opt_item(self.equipment.accessory))
  // 6: skill levels (comma separated)
  let skill_parts : Array[String] = []
  for node in self.skills.nodes {
    skill_parts.push(node.level.to_string())
  }
  parts.push(join_strings(skill_parts, ","))
  // 7: inventory items (semicolon separated)
  let inv_parts : Array[String] = []
  for i in 0..<self.inventory.capacity {
    inv_parts.push(serialize_opt_item(self.inventory.items[i]))
  }
  parts.push(join_strings(inv_parts, ";"))
  join_strings(parts, "|")
}

fn serialize_opt_item(item : ItemData?) -> String {
  match item {
    None => "-"
    Some(it) => serialize_item(it)
  }
}

fn serialize_item(item : ItemData) -> String {
  // name,rarity_int,slot_int,atk,def,hp,icon_id
  let rarity_int = match item.rarity {
    Common => 0
    Uncommon => 1
    Rare => 2
    Epic => 3
  }
  let slot_int = match item.slot {
    Weapon => 0
    Armor => 1
    Accessory => 2
  }
  item.name + "," +
  rarity_int.to_string() + "," +
  slot_int.to_string() + "," +
  item.atk_bonus.to_string() + "," +
  item.def_bonus.to_string() + "," +
  item.hp_bonus.to_string() + "," +
  item.icon_id.to_string()
}

fn deserialize_item(s : String) -> ItemData? {
  let parts = split_string(s, ',')
  if parts.length() < 7 {
    return None
  }
  let rarity = match parse_int(parts[1]) {
    1 => Uncommon
    2 => Rare
    3 => Epic
    _ => Common
  }
  let slot = match parse_int(parts[2]) {
    1 => Armor
    2 => Accessory
    _ => Weapon
  }
  Some({
    name: parts[0],
    rarity,
    slot,
    atk_bonus: parse_int(parts[3]),
    def_bonus: parse_int(parts[4]),
    hp_bonus: parse_int(parts[5]),
    icon_id: parse_int(parts[6]),
  })
}

fn GameState::save_game(self : GameState) -> Unit {
  let data = self.serialize_save()
  js_storage_set(save_key, data)
}

fn GameState::load_game(self : GameState) -> Bool {
  let data = js_storage_get(save_key)
  if data == "" {
    return false
  }
  let parts = split_string(data, '|')
  if parts.length() < 8 {
    return false
  }
  // 0: floor
  self.floor = parse_int(parts[0])
  // 1: score
  self.score = parse_int(parts[1])
  // 2: skill points
  self.skills.skill_points = parse_int(parts[2])
  // 3-5: equipment
  self.equipment.weapon = deserialize_opt_item(parts[3])
  self.equipment.armor = deserialize_opt_item(parts[4])
  self.equipment.accessory = deserialize_opt_item(parts[5])
  // 6: skill levels
  let skill_parts = split_string(parts[6], ',')
  for i in 0..<@cmp.minimum(skill_parts.length(), self.skills.nodes.length()) {
    self.skills.nodes[i].level = parse_int(skill_parts[i])
  }
  // 7: inventory
  let inv_parts = split_string(parts[7], ';')
  for i in 0..<@cmp.minimum(inv_parts.length(), self.inventory.capacity) {
    self.inventory.items[i] = deserialize_opt_item(inv_parts[i])
  }
  // Recompute stats
  self.player_stats = compute_player_stats(self.equipment, self.skills)
  self.player.hp = self.player_stats.max_hp
  // Regenerate dungeon for current floor
  self.seed = 42 + self.floor - 1
  let dungeon = generate_dungeon(self.seed)
  self.dungeon.grid = dungeon.grid
  self.dungeon.rooms.clear()
  for room in dungeon.rooms {
    self.dungeon.rooms.push(room)
  }
  self.dungeon.start_x = dungeon.start_x
  self.dungeon.start_y = dungeon.start_y
  self.player.x = dungeon.start_x
  self.player.y = dungeon.start_y
  self.enemies = spawn_enemies_for_floor(dungeon.rooms, 0, self.seed, self.floor)
  self.items = []
  self.projectiles = []
  self.dungeon_graph = build_dungeon_graph(self.dungeon, self.meshes)
  let (groups, wall_mesh) = build_dungeon_mesh_groups(self.dungeon, self.meshes)
  self.dungeon_mesh_groups = groups
  self.dungeon_wall_mesh = wall_mesh
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(self.player.x / tile_size, 0.0, self.player.y / tile_size),
  )
  true
}

fn deserialize_opt_item(s : String) -> ItemData? {
  if s == "-" {
    return None
  }
  deserialize_item(s)
}

fn GameState::delete_save(_self : GameState) -> Unit {
  js_storage_remove(save_key)
}

// Simple string utilities
fn split_string(s : String, sep : Char) -> Array[String] {
  let parts : Array[String] = []
  let buf = StringBuilder::new()
  for c in s {
    if c == sep {
      parts.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(c)
    }
  }
  parts.push(buf.to_string())
  parts
}

fn join_strings(parts : Array[String], sep : String) -> String {
  let buf = StringBuilder::new()
  for i, part in parts {
    if i > 0 {
      buf.write_string(sep)
    }
    buf.write_string(part)
  }
  buf.to_string()
}

fn parse_int(s : String) -> Int {
  let mut result = 0
  let mut negative = false
  for i, c in s {
    if i == 0 && c == '-' {
      negative = true
      continue
    }
    let d = c.to_int() - '0'.to_int()
    if d >= 0 && d <= 9 {
      result = result * 10 + d
    }
  }
  if negative { -result } else { result }
}
