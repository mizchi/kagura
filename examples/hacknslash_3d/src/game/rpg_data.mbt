// RPG data structures: inventory, skills, equipment, stats

// --- Item System ---

pub(all) enum ItemRarity {
  Common
  Uncommon
  Rare
  Epic
}

pub fn ItemRarity::color(self : ItemRarity) -> Int {
  match self {
    Common => 0xAAAAAA
    Uncommon => 0x00CC00
    Rare => 0x3366FF
    Epic => 0xCC00FF
  }
}

pub(all) enum EquipSlot {
  Weapon
  Armor
  Accessory
}

pub(all) struct Affix {
  name : String
  atk : Int
  def : Int
  hp : Int
  crit : Double
  life_steal : Double
}

pub(all) struct ItemData {
  name : String
  rarity : ItemRarity
  slot : EquipSlot
  atk_bonus : Int
  def_bonus : Int
  hp_bonus : Int
  prefix : Affix?
  suffix : Affix?
  icon_id : Int
}

fn affix_sum_int(item : ItemData, base : Int, f : (Affix) -> Int) -> Int {
  let mut v = base
  match item.prefix {
    Some(a) => v = v + f(a)
    None => ()
  }
  match item.suffix {
    Some(a) => v = v + f(a)
    None => ()
  }
  v
}

fn affix_sum_double(item : ItemData, f : (Affix) -> Double) -> Double {
  let mut v = 0.0
  match item.prefix {
    Some(a) => v = v + f(a)
    None => ()
  }
  match item.suffix {
    Some(a) => v = v + f(a)
    None => ()
  }
  v
}

pub fn ItemData::total_atk(self : ItemData) -> Int {
  affix_sum_int(self, self.atk_bonus, fn(a) { a.atk })
}

pub fn ItemData::total_def(self : ItemData) -> Int {
  affix_sum_int(self, self.def_bonus, fn(a) { a.def })
}

pub fn ItemData::total_hp(self : ItemData) -> Int {
  affix_sum_int(self, self.hp_bonus, fn(a) { a.hp })
}

pub fn ItemData::total_crit(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.crit })
}

pub fn ItemData::total_life_steal(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.life_steal })
}

pub fn ItemData::display_name(self : ItemData) -> String {
  let mut n = ""
  match self.prefix {
    Some(a) => n = a.name + " "
    None => ()
  }
  n = n + self.name
  match self.suffix {
    Some(a) => n = n + " " + a.name
    None => ()
  }
  n
}

pub(all) struct Inventory {
  items : Array[ItemData?]
  capacity : Int
}

pub fn Inventory::new(capacity : Int) -> Inventory {
  let items : Array[ItemData?] = []
  for _i in 0..<capacity {
    items.push(None)
  }
  { items, capacity }
}

pub fn Inventory::add(self : Inventory, item : ItemData) -> Bool {
  for i in 0..<self.capacity {
    if self.items[i] is None {
      self.items[i] = Some(item)
      return true
    }
  }
  false
}

pub fn Inventory::remove(self : Inventory, index : Int) -> ItemData? {
  if index < 0 || index >= self.capacity {
    return None
  }
  let item = self.items[index]
  self.items[index] = None
  item
}

pub fn Inventory::count(self : Inventory) -> Int {
  let mut c = 0
  for item in self.items {
    if item is Some(_) {
      c = c + 1
    }
  }
  c
}

// --- Equipment ---

pub(all) struct Equipment {
  mut weapon : ItemData?
  mut armor : ItemData?
  mut accessory : ItemData?
}

pub fn Equipment::new() -> Equipment {
  { weapon: None, armor: None, accessory: None }
}

pub fn Equipment::equip(self : Equipment, item : ItemData) -> ItemData? {
  match item.slot {
    Weapon => {
      let old = self.weapon
      self.weapon = Some(item)
      old
    }
    Armor => {
      let old = self.armor
      self.armor = Some(item)
      old
    }
    Accessory => {
      let old = self.accessory
      self.accessory = Some(item)
      old
    }
  }
}

fn equipment_sum(equip : Equipment, f : (ItemData) -> Int) -> Int {
  let mut total = 0
  match equip.weapon {
    Some(item) => total = total + f(item)
    None => ()
  }
  match equip.armor {
    Some(item) => total = total + f(item)
    None => ()
  }
  match equip.accessory {
    Some(item) => total = total + f(item)
    None => ()
  }
  total
}

fn equipment_sum_f(equip : Equipment, f : (ItemData) -> Double) -> Double {
  let mut total = 0.0
  match equip.weapon {
    Some(item) => total = total + f(item)
    None => ()
  }
  match equip.armor {
    Some(item) => total = total + f(item)
    None => ()
  }
  match equip.accessory {
    Some(item) => total = total + f(item)
    None => ()
  }
  total
}

pub fn Equipment::total_atk(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_atk)
}

pub fn Equipment::total_def(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_def)
}

pub fn Equipment::total_hp(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_hp)
}

pub fn Equipment::total_crit(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_crit)
}

pub fn Equipment::total_life_steal(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_life_steal)
}

// --- Skill System ---

pub(all) enum SkillId {
  PowerStrike
  Whirlwind
  DashMastery
  Vitality
  CriticalHit
  LifeSteal
}

pub(all) struct SkillNode {
  id : SkillId
  name : String
  max_level : Int
  mut level : Int
  cost : Int
  icon_id : Int
  prereqs : Array[SkillId]
}

pub(all) struct SkillTree {
  nodes : Array[SkillNode]
  mut skill_points : Int
}

pub fn SkillTree::new() -> SkillTree {
  {
    nodes: [
      { id: PowerStrike, name: "Power Strike", max_level: 5, level: 0, cost: 1, icon_id: 10, prereqs: [] },
      { id: Whirlwind, name: "Whirlwind", max_level: 3, level: 0, cost: 2, icon_id: 11, prereqs: [PowerStrike] },
      { id: DashMastery, name: "Dash Mastery", max_level: 3, level: 0, cost: 1, icon_id: 12, prereqs: [] },
      { id: Vitality, name: "Vitality", max_level: 5, level: 0, cost: 1, icon_id: 13, prereqs: [] },
      { id: CriticalHit, name: "Critical Hit", max_level: 3, level: 0, cost: 2, icon_id: 14, prereqs: [PowerStrike] },
      { id: LifeSteal, name: "Life Steal", max_level: 3, level: 0, cost: 3, icon_id: 15, prereqs: [CriticalHit, Vitality] },
    ],
    skill_points: 0,
  }
}

pub fn SkillTree::find(self : SkillTree, id : SkillId) -> SkillNode? {
  for node in self.nodes {
    if skill_id_eq(node.id, id) {
      return Some(node)
    }
  }
  None
}

pub fn skill_id_eq(a : SkillId, b : SkillId) -> Bool {
  skill_id_to_int(a) == skill_id_to_int(b)
}

pub fn skill_id_to_int(id : SkillId) -> Int {
  match id {
    PowerStrike => 0
    Whirlwind => 1
    DashMastery => 2
    Vitality => 3
    CriticalHit => 4
    LifeSteal => 5
  }
}

pub fn SkillTree::can_learn(self : SkillTree, id : SkillId) -> Bool {
  match self.find(id) {
    None => false
    Some(node) => {
      if node.level >= node.max_level {
        return false
      }
      if self.skill_points < node.cost {
        return false
      }
      for prereq in node.prereqs {
        match self.find(prereq) {
          None => return false
          Some(p) =>
            if p.level == 0 {
              return false
            }
        }
      }
      true
    }
  }
}

pub fn SkillTree::learn(self : SkillTree, id : SkillId) -> Bool {
  if not(self.can_learn(id)) {
    return false
  }
  match self.find(id) {
    None => false
    Some(node) => {
      self.skill_points = self.skill_points - node.cost
      node.level = node.level + 1
      true
    }
  }
}

pub fn SkillTree::get_level(self : SkillTree, id : SkillId) -> Int {
  match self.find(id) {
    Some(node) => node.level
    None => 0
  }
}

// --- Player Stats ---

pub(all) struct PlayerStats {
  max_hp : Int
  atk : Int
  def : Int
  dash_cooldown : Int
  crit_chance : Double
  life_steal : Double
}

pub fn compute_player_stats(equipment : Equipment, skills : SkillTree) -> PlayerStats {
  let base_hp = 10
  let base_atk = 1
  let base_def = 0
  let vitality_level = skills.get_level(Vitality)
  let power_strike_level = skills.get_level(PowerStrike)
  let dash_mastery_level = skills.get_level(DashMastery)
  let crit_level = skills.get_level(CriticalHit)
  let ls_level = skills.get_level(LifeSteal)
  {
    max_hp: base_hp + equipment.total_hp() + vitality_level * 3,
    atk: base_atk + equipment.total_atk() + power_strike_level,
    def: base_def + equipment.total_def(),
    dash_cooldown: 40 - dash_mastery_level * 8,
    crit_chance: crit_level.to_double() * 0.1 + equipment.total_crit(),
    life_steal: ls_level.to_double() * 0.05 + equipment.total_life_steal(),
  }
}

// --- Affix Tables ---

pub fn prefix_table() -> Array[Affix] {
  [
    { name: "Keen", atk: 2, def: 0, hp: 0, crit: 0.05, life_steal: 0.0 },
    { name: "Brutal", atk: 4, def: 0, hp: 0, crit: 0.0, life_steal: 0.0 },
    { name: "Sturdy", atk: 0, def: 3, hp: 2, crit: 0.0, life_steal: 0.0 },
    { name: "Vampiric", atk: 1, def: 0, hp: 0, crit: 0.0, life_steal: 0.08 },
    { name: "Blazing", atk: 3, def: 0, hp: 0, crit: 0.03, life_steal: 0.0 },
    { name: "Iron", atk: 0, def: 4, hp: 0, crit: 0.0, life_steal: 0.0 },
    { name: "Mighty", atk: 5, def: -1, hp: 0, crit: 0.0, life_steal: 0.0 },
    { name: "Blessed", atk: 1, def: 1, hp: 3, crit: 0.0, life_steal: 0.02 },
    { name: "Savage", atk: 3, def: 0, hp: 0, crit: 0.08, life_steal: 0.0 },
    { name: "Arcane", atk: 2, def: 0, hp: 2, crit: 0.04, life_steal: 0.0 },
  ]
}

pub fn suffix_table() -> Array[Affix] {
  [
    { name: "of Power", atk: 3, def: 0, hp: 0, crit: 0.0, life_steal: 0.0 },
    { name: "of the Bear", atk: 0, def: 2, hp: 5, crit: 0.0, life_steal: 0.0 },
    { name: "of Precision", atk: 0, def: 0, hp: 0, crit: 0.1, life_steal: 0.0 },
    { name: "of Leeching", atk: 0, def: 0, hp: 0, crit: 0.0, life_steal: 0.1 },
    { name: "of Thorns", atk: 0, def: 4, hp: 0, crit: 0.0, life_steal: 0.0 },
    { name: "of Haste", atk: 1, def: 0, hp: 0, crit: 0.05, life_steal: 0.0 },
    { name: "of Vitality", atk: 0, def: 0, hp: 6, crit: 0.0, life_steal: 0.0 },
    { name: "of Fury", atk: 4, def: 0, hp: -2, crit: 0.06, life_steal: 0.0 },
    { name: "of the Wolf", atk: 2, def: 1, hp: 2, crit: 0.0, life_steal: 0.03 },
    { name: "of Fortune", atk: 1, def: 1, hp: 1, crit: 0.03, life_steal: 0.03 },
  ]
}

pub fn scale_affix(affix : Affix, floor : Int) -> Affix {
  let scale = 1 + floor / 5
  {
    name: affix.name,
    atk: affix.atk * scale,
    def: affix.def * scale,
    hp: affix.hp * scale,
    crit: affix.crit,
    life_steal: affix.life_steal,
  }
}

// --- Item Generation ---

pub fn generate_item(seed : Int, floor : Int) -> ItemData {
  let rng = seed.land(0x7FFFFFFF)
  let slot_roll = rng % 3
  let slot = match slot_roll {
    0 => Weapon
    1 => Armor
    _ => Accessory
  }
  let rarity_roll = (rng / 3) % 100
  let rarity = if rarity_roll < 50 {
    Common
  } else if rarity_roll < 80 {
    Uncommon
  } else if rarity_roll < 95 {
    Rare
  } else {
    Epic
  }
  let rarity_mult = match rarity {
    Common => 1
    Uncommon => 2
    Rare => 3
    Epic => 5
  }
  let base = 1 + floor / 3
  let (atk, def, hp) = match slot {
    Weapon => (base * rarity_mult, 0, 0)
    Armor => (0, base * rarity_mult, base)
    Accessory => (base, base, base * rarity_mult)
  }
  let slot_name = match slot {
    Weapon => "Sword"
    Armor => "Armor"
    Accessory => "Ring"
  }
  let prefixes = prefix_table()
  let suffixes = suffix_table()
  let prefix_seed = (rng / 300) % prefixes.length()
  let suffix_seed = (rng / 3000) % suffixes.length()
  let (prefix, suffix) : (Affix?, Affix?) = match rarity {
    Common => (None, None)
    Uncommon => {
      if (rng / 30) % 2 == 0 {
        (Some(scale_affix(prefixes[prefix_seed], floor)), None)
      } else {
        (None, Some(scale_affix(suffixes[suffix_seed], floor)))
      }
    }
    Rare => (
      Some(scale_affix(prefixes[prefix_seed], floor)),
      Some(scale_affix(suffixes[suffix_seed], floor)),
    )
    Epic => (
      Some(scale_affix(prefixes[prefix_seed], floor)),
      Some(scale_affix(suffixes[suffix_seed], floor)),
    )
  }
  {
    name: slot_name,
    rarity,
    slot,
    atk_bonus: atk,
    def_bonus: def,
    hp_bonus: hp,
    prefix,
    suffix,
    icon_id: slot_roll + rarity_roll % 3,
  }
}
