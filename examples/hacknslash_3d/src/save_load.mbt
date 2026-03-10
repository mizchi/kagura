// Save/Load system via localStorage (JS target only)
// Serializes character progress: inventory, equipment, skills, floor, score

///|
extern "js" fn js_storage_set(key : String, value : String) -> Unit =
  #| (key, value) => { try { localStorage.setItem(key, value); } catch(e) {} }

///|
extern "js" fn js_storage_get(key : String) -> String =
  #| (key) => { try { return localStorage.getItem(key) ?? ""; } catch(e) { return ""; } }

///|
extern "js" fn js_storage_remove(key : String) -> Unit =
  #| (key) => { try { localStorage.removeItem(key); } catch(e) {} }

///|
let save_key : String = "hacknslash3d_save"

// Encode game state as a simple key=value format
// Format: floor|score|sp|weapon|armor|accessory|skills|items

///|
fn GameState::serialize_save(self : GameState) -> String {
  let parts : Array[String] = []
  // 0: floor
  parts.push(self.world.floor.to_string())
  // 1: score
  parts.push(self.world.score.to_string())
  // 2: skill points
  parts.push(self.world.skills.skill_points.to_string())
  // 3: weapon
  parts.push(serialize_opt_item(self.world.equipment.weapon))
  // 4: armor
  parts.push(serialize_opt_item(self.world.equipment.armor))
  // 5: accessory
  parts.push(serialize_opt_item(self.world.equipment.accessory))
  // 6: skill levels (comma separated)
  let skill_parts : Array[String] = []
  for node in self.world.skills.nodes {
    skill_parts.push(node.level.to_string())
  }
  parts.push(join_strings(skill_parts, ","))
  // 7: inventory items (semicolon separated)
  let inv_parts : Array[String] = []
  for i in 0..<self.world.inventory.capacity {
    inv_parts.push(serialize_opt_item(self.world.inventory.items[i]))
  }
  parts.push(join_strings(inv_parts, ";"))
  join_strings(parts, "|")
}

///|
fn serialize_opt_item(item : @game.ItemData?) -> String {
  match item {
    None => "-"
    Some(it) => serialize_item(it)
  }
}

///|
fn serialize_affix(a : @game.Affix) -> String {
  a.name +
  "~" +
  a.atk.to_string() +
  "~" +
  a.def.to_string() +
  "~" +
  a.hp.to_string() +
  "~" +
  a.crit.to_string() +
  "~" +
  a.life_steal.to_string() +
  "~" +
  a.speed_bonus.to_string() +
  "~" +
  a.cooldown_reduction.to_string()
}

///|
fn deserialize_affix(s : String) -> @game.Affix? {
  if s == "" {
    return None
  }
  let parts = split_string(s, '~')
  if parts.length() < 6 {
    return None
  }
  Some({
    name: parts[0],
    atk: parse_int(parts[1]),
    def: parse_int(parts[2]),
    hp: parse_int(parts[3]),
    crit: parse_double(parts[4]),
    life_steal: parse_double(parts[5]),
    speed_bonus: if parts.length() > 6 {
      parse_double(parts[6])
    } else {
      0.0
    },
    cooldown_reduction: if parts.length() > 7 {
      parse_double(parts[7])
    } else {
      0.0
    },
  })
}

///|
fn serialize_opt_affix(a : @game.Affix?) -> String {
  match a {
    None => ""
    Some(affix) => serialize_affix(affix)
  }
}

///|
fn serialize_item(item : @game.ItemData) -> String {
  // name,rarity_int,slot_int,atk,def,hp,icon_id,prefix_data,suffix_data
  let rarity_int = match item.rarity {
    @game.Common => 0
    @game.Uncommon => 1
    @game.Rare => 2
    @game.Epic => 3
  }
  let slot_int = match item.slot {
    @game.Weapon => 0
    @game.Armor => 1
    @game.Accessory => 2
  }
  item.name +
  "," +
  rarity_int.to_string() +
  "," +
  slot_int.to_string() +
  "," +
  item.atk_bonus.to_string() +
  "," +
  item.def_bonus.to_string() +
  "," +
  item.hp_bonus.to_string() +
  "," +
  item.icon_id.to_string() +
  "," +
  serialize_opt_affix(item.prefix) +
  "," +
  serialize_opt_affix(item.suffix)
}

///|
fn deserialize_item(s : String) -> @game.ItemData? {
  let parts = split_string(s, ',')
  if parts.length() < 7 {
    return None
  }
  let rarity = match parse_int(parts[1]) {
    1 => @game.Uncommon
    2 => @game.Rare
    3 => @game.Epic
    _ => @game.Common
  }
  let slot = match parse_int(parts[2]) {
    1 => @game.Armor
    2 => @game.Accessory
    _ => @game.Weapon
  }
  let prefix = if parts.length() > 7 {
    deserialize_affix(parts[7])
  } else {
    None
  }
  let suffix = if parts.length() > 8 {
    deserialize_affix(parts[8])
  } else {
    None
  }
  Some({
    name: parts[0],
    rarity,
    slot,
    atk_bonus: parse_int(parts[3]),
    def_bonus: parse_int(parts[4]),
    hp_bonus: parse_int(parts[5]),
    prefix,
    suffix,
    icon_id: parse_int(parts[6]),
  })
}

///|
fn GameState::save_game(self : GameState) -> Unit {
  let data = self.serialize_save()
  js_storage_set(save_key, data)
}

///|
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
  self.world.floor = parse_int(parts[0])
  // 1: score
  self.world.score = parse_int(parts[1])
  // 2: skill points
  self.world.skills.skill_points = parse_int(parts[2])
  // 3-5: equipment
  self.world.equipment.weapon = deserialize_opt_item(parts[3])
  self.world.equipment.armor = deserialize_opt_item(parts[4])
  self.world.equipment.accessory = deserialize_opt_item(parts[5])
  // 6: skill levels
  let skill_parts = split_string(parts[6], ',')
  for
    i in 0..<@cmp.minimum(
      skill_parts.length(),
      self.world.skills.nodes.length(),
    ) {
    self.world.skills.nodes[i].level = parse_int(skill_parts[i])
  }
  // 7: inventory
  let inv_parts = split_string(parts[7], ';')
  for i in 0..<@cmp.minimum(inv_parts.length(), self.world.inventory.capacity) {
    self.world.inventory.items[i] = deserialize_opt_item(inv_parts[i])
  }
  // Recompute stats
  self.world.player_stats = @game.compute_player_stats(
    self.world.equipment,
    self.world.skills,
  )
  self.world.player.hp = self.world.player_stats.max_hp
  // Regenerate dungeon for current floor
  self.world.seed = 42 + self.world.floor - 1
  self.world.apply_dungeon(self.world.seed, self.world.floor)
  // Rebuild rendering state
  self.rebuild_dungeon_rendering()
  true
}

///|
fn deserialize_opt_item(s : String) -> @game.ItemData? {
  if s == "-" {
    return None
  }
  deserialize_item(s)
}

///|
fn GameState::delete_save(_self : GameState) -> Unit {
  js_storage_remove(save_key)
}

// Simple string utilities

///|
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

///|
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

///|
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
  if negative {
    -result
  } else {
    result
  }
}

///|
fn parse_double(s : String) -> Double {
  let mut int_part = 0
  let mut frac_part = 0.0
  let mut frac_div = 1.0
  let mut negative = false
  let mut in_frac = false
  for i, c in s {
    if i == 0 && c == '-' {
      negative = true
      continue
    }
    if c == '.' {
      in_frac = true
      continue
    }
    let d = c.to_int() - '0'.to_int()
    if d >= 0 && d <= 9 {
      if in_frac {
        frac_div = frac_div * 10.0
        frac_part = frac_part + d.to_double() / frac_div
      } else {
        int_part = int_part * 10 + d
      }
    }
  }
  let result = int_part.to_double() + frac_part
  if negative {
    -result
  } else {
    result
  }
}
