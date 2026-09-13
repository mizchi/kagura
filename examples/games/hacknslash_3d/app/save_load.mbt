// Portable character save codec; storage and world progress have separate contracts.

// Encode game state as a simple key=value format
// Format:
// floor|score|legacy_sp|weapon|armor|accessory|skills|items|
// level|xp|next_xp|pending_choices|offer_ids|weapon_set|tree-v1|positions|extra_equipment|inventory-v1|
// encoded_world_progress|archetype|alive_or_dead|hunter_preset

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
  // 8-12: level progression
  parts.push(self.world.level_progress.level.to_string())
  parts.push(self.world.level_progress.xp.to_string())
  parts.push(self.world.level_progress.next_level_xp.to_string())
  parts.push(self.world.level_progress.pending_choices.to_string())
  let offer_parts : Array[String] = []
  for offer in self.world.level_progress.current_offers {
    offer_parts.push(@game.skill_id_to_int(offer).to_string())
  }
  parts.push(join_strings(offer_parts, ","))
  // 13: weapon motion set; old saves default to the cleaver.
  parts.push(self.world.player_weapon.profile().id)
  // 14: tree point economy version; old saves receive their points once.
  parts.push("tree-v1")
  // 15-17: spatial layout and the five additional body slots.
  let positions : Array[String] = []
  for i in 0..<self.world.inventory.capacity {
    let position = match self.world.inventory.grid {
      Some(grid) => grid.placement(i)
      None => None
    }
    positions.push(
      match position {
        Some(pos) =>
          pos.x.to_string() +
          "," +
          pos.y.to_string() +
          "," +
          (if pos.rotated { "1" } else { "0" })
        None => "-"
      },
    )
  }
  parts.push(join_strings(positions, ";"))
  let extra = @game.equipment_slots()
    .filter(slot => slot.index() >= 3)
    .map(slot => serialize_opt_item(self.world.equipment.item_for_slot(slot)))
  parts.push(join_strings(extra, ";"))
  parts.push("inventory-v1")
  parts.push(js_encode_world_progress(self.world.serialize_world_progress()))
  parts.push(self.world.archetype.to_string())
  parts.push(if self.world.mode == @game.GameOver { "dead" } else { "alive" })
  parts.push(self.world.hunter_preset.profile().id)
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
  a.cooldown_reduction.to_string() +
  "~" +
  a.str_bonus.to_string() +
  "~" +
  a.int_bonus.to_string() +
  "~" +
  a.dex_bonus.to_string() +
  "~" +
  a.str_scaling.to_string() +
  "~" +
  a.int_scaling.to_string() +
  "~" +
  a.dex_scaling.to_string() +
  "~" +
  a.spell_damage_pct.to_string() +
  "~" +
  a.chain_bonus.to_string() +
  "~" +
  join_strings(
    a.tag_bonuses.map(entry => {
      join_strings(
        [
          @game.skill_tag_to_int(entry.tag).to_string(),
          entry.damage_pct.to_string(),
          entry.cooldown_reduction.to_string(),
          entry.extra_targets.to_string(),
          entry.aoe_radius_pct.to_string(),
          entry.crit_bonus.to_string(),
        ],
        ":",
      )
    }),
    "/",
  )
}

///|
fn deserialize_item_tag_bonuses(value : String) -> Array[@game.TagBonusEntry] {
  let entries : Array[@game.TagBonusEntry] = []
  let tags = [
    @game.Lightning,
    @game.Fire,
    @game.Cold,
    @game.Physical,
    @game.Projectile,
    @game.AoE,
    @game.Defense,
    @game.Utility,
  ]
  for value in split_string(value, '/') {
    let fields = split_string(value, ':')
    if fields.length() != 6 {
      continue
    }
    let id = parse_int(fields[0])
    if id < 0 || id >= tags.length() {
      continue
    }
    entries.push({
      tag: tags[id],
      damage_pct: parse_double(fields[1]),
      cooldown_reduction: parse_double(fields[2]),
      extra_targets: parse_int(fields[3]),
      aoe_radius_pct: parse_double(fields[4]),
      crit_bonus: parse_double(fields[5]),
    })
  }
  entries
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
    str_bonus: if parts.length() > 8 {
      parse_int(parts[8])
    } else {
      0
    },
    int_bonus: if parts.length() > 9 {
      parse_int(parts[9])
    } else {
      0
    },
    dex_bonus: if parts.length() > 10 {
      parse_int(parts[10])
    } else {
      0
    },
    str_scaling: if parts.length() > 11 {
      parse_double(parts[11])
    } else {
      0.0
    },
    int_scaling: if parts.length() > 12 {
      parse_double(parts[12])
    } else {
      0.0
    },
    dex_scaling: if parts.length() > 13 {
      parse_double(parts[13])
    } else {
      0.0
    },
    spell_damage_pct: if parts.length() > 14 {
      parse_double(parts[14])
    } else {
      0.0
    },
    chain_bonus: if parts.length() > 15 {
      parse_int(parts[15])
    } else {
      0
    },
    tag_bonuses: if parts.length() > 16 {
      deserialize_item_tag_bonuses(parts[16])
    } else {
      []
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
  // name,rarity_int,slot_int,atk,def,hp,icon_id,prefix_data,suffix_data,
  // str_bonus,int_bonus,dex_bonus,str_scaling,int_scaling,dex_scaling
  let rarity_int = match item.rarity {
    @game.Common => 0
    @game.Uncommon => 1
    @game.Rare => 2
    @game.Epic => 3
  }
  let slot_int = item.slot.index()
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
  serialize_opt_affix(item.suffix) +
  "," +
  item.str_bonus.to_string() +
  "," +
  item.int_bonus.to_string() +
  "," +
  item.dex_bonus.to_string() +
  "," +
  item.str_scaling.to_string() +
  "," +
  item.int_scaling.to_string() +
  "," +
  item.dex_scaling.to_string()
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
  let slot = @game.equip_slot_from_index(parse_int(parts[2])).or(@game.Weapon)
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
    str_bonus: if parts.length() > 9 {
      parse_int(parts[9])
    } else {
      0
    },
    int_bonus: if parts.length() > 10 {
      parse_int(parts[10])
    } else {
      0
    },
    dex_bonus: if parts.length() > 11 {
      parse_int(parts[11])
    } else {
      0
    },
    str_scaling: if parts.length() > 12 {
      parse_double(parts[12])
    } else {
      0.0
    },
    int_scaling: if parts.length() > 13 {
      parse_double(parts[13])
    } else {
      0.0
    },
    dex_scaling: if parts.length() > 14 {
      parse_double(parts[14])
    } else {
      0.0
    },
    prefix,
    suffix,
    icon_id: parse_int(parts[6]),
  })
}

///|
fn GameState::save_game(self : GameState) -> Unit {
  ignore(self.persist_save())
}

///|
fn GameState::load_game(self : GameState) -> Bool {
  self.restore_save(js_storage_get(save_slot_key(self.active_save_slot)))
}

///|
fn GameState::restore_save(self : GameState, data : String) -> Bool {
  if !valid_save_data(data) {
    return false
  }
  let parts = split_string(data, '|')
  self.world.apply_archetype(
    if parts.length() > 19 {
      @game.character_archetype_from_string(parts[19]).or(@game.Melee)
    } else {
      @game.Melee
    },
  )
  // 0: floor
  self.world.floor = parse_int(parts[0])
  // 1: score
  self.world.score = parse_int(parts[1])
  // 2: skill points
  self.world.skills.skill_points = parse_int(parts[2]).max(0)
  self.world.equipment.clear()
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
  self.world.inventory.clear()
  let inv_parts = split_string(parts[7], ';')
  for i in 0..<@cmp.minimum(inv_parts.length(), self.world.inventory.capacity) {
    self.world.inventory.items[i] = deserialize_opt_item(inv_parts[i])
  }
  // 8-12: level progression (optional for backward compatibility)
  let level_progress = @game.LevelProgression::new(
    config=self.world.params.levelup_config(),
  )
  if parts.length() >= 13 {
    level_progress.level = @cmp.maximum(1, parse_int(parts[8]))
    level_progress.xp = @cmp.maximum(0, parse_int(parts[9]))
    level_progress.next_level_xp = @cmp.maximum(1, parse_int(parts[10]))
    level_progress.pending_choices = @cmp.maximum(0, parse_int(parts[11]))
    let offers = split_string(parts[12], ',')
    level_progress.current_offers = []
    for offer_str in offers {
      if offer_str == "" {
        continue
      }
      match @game.skill_id_from_int(parse_int(offer_str)) {
        Some(id) => level_progress.current_offers.push(id)
        None => ()
      }
    }
    if level_progress.pending_choices > 0 &&
      level_progress.current_offers.length() == 0 {
      level_progress.pending_choices = 0
    }
  }
  let positions : Array[(Int, Int, Bool)?] = []
  if parts.length() > 15 {
    for entry in split_string(parts[15], ';') {
      let fields = split_string(entry, ',')
      positions.push(
        if fields.length() == 3 {
          Some((parse_int(fields[0]), parse_int(fields[1]), fields[2] == "1"))
        } else {
          None
        },
      )
    }
  }
  self.world.inventory.restore_layout(positions)
  if parts.length() > 16 {
    for entry in split_string(parts[16], ';') {
      if deserialize_opt_item(entry) is Some(item) {
        ignore(self.world.equipment.equip(item))
      }
    }
  }
  self.world.level_progress = level_progress
  let migrate_tree_points = self.world.hunting_grounds && parts.length() < 15
  if migrate_tree_points {
    self.world.skills.skill_points += 3 + level_progress.level - 1
  }
  self.world.player_weapon = if parts.length() > 13 {
    @game.player_weapon_from_id(parts[13]).or(@game.Cleaver)
  } else {
    @game.Cleaver
  }
  self.world.weapon_attack = None
  self.world.hunter_preset = if parts.length() > 21 {
    @game.hunter_preset_from_id(parts[21]).or(@game.default_hunter_preset(self.world.archetype))
  } else {
    @game.default_hunter_preset(self.world.archetype)
  }
  self.sync_character_equipment()
  // Recompute stats
  self.world.refresh_player_stats()
  self.world.player.hp = self.world.player_stats.max_hp
  // Regenerate dungeon for current floor
  self.world.seed = 42 + self.world.floor - 1
  self.world.apply_dungeon(self.world.seed, self.world.floor)
  let restored_world = if parts.length() > 18 {
    self.world.restore_world_progress(js_decode_world_progress(parts[18]))
  } else {
    false
  }
  if parts.length() > 20 && parts[20] == "dead" {
    self.world.mode = @game.GameOver
    ignore(self.world.respawn_at_waypoint())
  }
  // Rebuild rendering state
  self.rebuild_dungeon_rendering()
  self.world.open_levelup_ui_if_needed()
  if migrate_tree_points || parts.length() < 19 || restored_world {
    self.save_game()
  }
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
fn GameState::delete_save(self : GameState) -> Unit {
  ignore(js_storage_remove(save_slot_key(self.active_save_slot)))
}

// Simple string utilities

///|
fn split_string(s : String, sep : Char) -> Array[String] {
  let parts : Array[String] = []
  let buf = StringBuilder()
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
  let buf = StringBuilder()
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
