// Appearance is a value derived from equipment. It owns no combat or animation state.

///|
enum CharacterSpecies {
  Human
  Goblin
  Kobold
  Skeleton
} derive(Eq, Debug)

///|
fn CharacterSpecies::index(self : CharacterSpecies) -> Int {
  match self {
    Human => 0
    Goblin => 1
    Kobold => 2
    Skeleton => 3
  }
}

///|
fn CharacterSpecies::id(self : CharacterSpecies) -> String {
  match self {
    Human => "human"
    Goblin => "goblin"
    Kobold => "kobold"
    Skeleton => "skeleton"
  }
}

///|
enum GearStyle {
  Worn
  Leather
  Plate
  Occult
} derive(Eq, Debug)

///|
fn GearStyle::index(self : GearStyle) -> Int {
  match self {
    Worn => 0
    Leather => 1
    Plate => 2
    Occult => 3
  }
}

///|
struct CharacterOutfit {
  slots : Array[GearStyle?]
} derive(Eq, Debug)

///|
fn CharacterOutfit::empty() -> CharacterOutfit {
  { slots: Array::make(8, None), }
}

///|
fn CharacterOutfit::starter() -> CharacterOutfit {
  let outfit = CharacterOutfit::empty()
  for slot in [@game.Armor, @game.Helmet, @game.Gloves, @game.Boots] {
    outfit.slots[slot.index()] = Some(Worn)
  }
  outfit
}

///|
fn CharacterOutfit::from_equipment(
  equipment : @game.Equipment,
) -> CharacterOutfit {
  {
    slots: @game.equipment_slots().map(slot => {
      equipment
      .item_for_slot(slot)
      .map(item => {
        match item.rarity {
          @game.Common => Worn
          @game.Uncommon => Leather
          @game.Rare => Plate
          @game.Epic => Occult
        }
      })
    }),
  }
}

///|
fn CharacterOutfit::style(
  self : CharacterOutfit,
  slot : @game.EquipSlot,
) -> GearStyle? {
  self.slots[slot.index()]
}

///|
fn CharacterOutfit::key(self : CharacterOutfit) -> Int {
  let mut key = 0
  for style in self.slots {
    key = key * 5 +
      (match style {
        None => 0
        Some(s) => s.index() + 1
      })
  }
  key
}

///|
fn CharacterModel::equip_outfit(
  self : CharacterModel,
  outfit : CharacterOutfit,
) -> Unit {
  if self.outfit == outfit {
    return
  }
  self.outfit = { slots: outfit.slots.copy(), }
  self.refresh_equipped_mesh()
}

///|
fn CharacterModel::refresh_equipped_mesh(self : CharacterModel) -> Unit {
  let key = self.outfit.key() * 5 + self.weapon.kind.index()
  let entry = match self.equipped_cache.get(key) {
    Some(cached) => cached
    None => {
      // Rendering references shared slot assets. A new combination never duplicates GPU buffers.
      let parts = character_outfit_parts(self.species, self.outfit)
      parts.append(
        character_weapon_parts(self.weapon, self.outfit.style(@game.Weapon)),
      )
      let (mesh, skin) = combine_hunter_parts(parts)
      let entry = {
        parts,
        mesh,
        skin,
        packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
      }
      if self.equipped_cache.length() >= 16 {
        self.equipped_cache.clear()
      }
      self.equipped_cache[key] = entry
      self.appearance_builds += 1
      entry
    }
  }
  self.parts = entry.parts
  self.bind_mesh = entry.mesh
  self.skin_data = entry.skin
  self.packed_vertex_data = entry.packed
  // Bone transforms are unchanged. Mid-attack armor swaps keep the exact pose and time.
}

///|
fn GameState::sync_character_equipment(self : GameState) -> Unit {
  self.character.equip_weapon(self.world.player_weapon)
  // The common per-frame path reads only scalar codes; no arrays or meshes are allocated.
  if equipment_appearance_key(self.world.equipment) !=
    self.character.outfit.key() {
    self.character.equip_outfit(
      CharacterOutfit::from_equipment(self.world.equipment),
    )
  }
}

///|
fn character_outfit_preset(style : GearStyle?) -> CharacterOutfit {
  let outfit = CharacterOutfit::empty()
  for
    slot in [
      @game.Armor,
      @game.Helmet,
      @game.Gloves,
      @game.Boots,
      @game.Accessory,
      @game.Amulet,
    ] {
    outfit.slots[slot.index()] = style
  }
  outfit
}

///|
let character_equipment_slots : Array[@game.EquipSlot] = @game.equipment_slots()

///|
fn equipment_appearance_key(equipment : @game.Equipment) -> Int {
  let mut key = 0
  for slot in character_equipment_slots {
    let code = match equipment.item_for_slot(slot) {
      None => 0
      Some(item) =>
        match item.rarity {
          @game.Common => 1
          @game.Uncommon => 2
          @game.Rare => 3
          @game.Epic => 4
        }
    }
    key = key * 5 + code
  }
  key
}
