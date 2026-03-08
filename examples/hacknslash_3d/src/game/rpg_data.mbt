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
  speed_bonus : Double // movement speed multiplier bonus (e.g. 0.1 = +10%)
  cooldown_reduction : Double // attack cooldown reduction fraction (e.g. 0.1 = 10% faster)
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

pub fn ItemData::total_speed_bonus(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.speed_bonus })
}

pub fn ItemData::total_cooldown_reduction(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.cooldown_reduction })
}

pub fn Equipment::total_speed_bonus(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_speed_bonus)
}

pub fn Equipment::total_cooldown_reduction(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_cooldown_reduction)
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
  speed_bonus : Double // total movement speed bonus from equipment
  cooldown_reduction : Double // total attack cooldown reduction from equipment
}

pub fn compute_player_stats(
  equipment : Equipment,
  skills : SkillTree,
  base_hp~ : Int = 10
) -> PlayerStats {
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
    speed_bonus: equipment.total_speed_bonus(),
    cooldown_reduction: equipment.total_cooldown_reduction(),
  }
}

// --- Affix Tables ---

// Affix profile IDs for selecting different affix table sets
pub(all) enum AffixProfile {
  Classic // original 10+10
  GlassCannon // high atk, negative hp/def
  Tank // high def/hp, sustain
  Mobility // speed & cooldown focused
  Expanded // all axes mixed
}

fn a(
  name : String,
  atk~ : Int = 0,
  def~ : Int = 0,
  hp~ : Int = 0,
  crit~ : Double = 0.0,
  ls~ : Double = 0.0,
  spd~ : Double = 0.0,
  cdr~ : Double = 0.0
) -> Affix {
  { name, atk, def, hp, crit, life_steal: ls, speed_bonus: spd, cooldown_reduction: cdr }
}

pub fn prefix_table() -> Array[Affix] {
  prefix_table_for(Classic)
}

pub fn suffix_table() -> Array[Affix] {
  suffix_table_for(Classic)
}

pub fn prefix_table_for(profile : AffixProfile) -> Array[Affix] {
  let classic : Array[Affix] = [
    a("Keen", atk=2, crit=0.05),
    a("Brutal", atk=4),
    a("Sturdy", def=3, hp=2),
    a("Vampiric", atk=1, ls=0.08),
    a("Blazing", atk=3, crit=0.03),
    a("Iron", def=4),
    a("Mighty", atk=5, def=-1),
    a("Blessed", atk=1, def=1, hp=3, ls=0.02),
    a("Savage", atk=3, crit=0.08),
    a("Arcane", atk=2, hp=2, crit=0.04),
  ]
  match profile {
    Classic => classic
    GlassCannon => [
      a("Deadly", atk=6, hp=-3),
      a("Frenzied", atk=5, crit=0.1, def=-2),
      a("Reckless", atk=7, def=-3, hp=-2),
      a("Brutal", atk=4),
      a("Keen", atk=2, crit=0.05),
      a("Savage", atk=3, crit=0.08),
      a("Blazing", atk=3, crit=0.03),
      a("Piercing", atk=4, crit=0.06, hp=-1),
      a("Berserker", atk=6, crit=0.04, def=-2),
      a("Wrathful", atk=5, ls=0.03, hp=-2),
    ]
    Tank => [
      a("Fortified", def=5, hp=3),
      a("Stalwart", def=4, hp=4),
      a("Iron", def=4),
      a("Sturdy", def=3, hp=2),
      a("Blessed", atk=1, def=1, hp=3, ls=0.02),
      a("Guardian", def=3, hp=2, ls=0.04),
      a("Resilient", def=2, hp=5),
      a("Warden", def=6, atk=-1),
      a("Enduring", hp=4, ls=0.05),
      a("Titanic", def=3, hp=6, atk=-2),
    ]
    Mobility => [
      a("Swift", spd=0.15, atk=1),
      a("Fleet", spd=0.2),
      a("Rapid", cdr=0.15, atk=1),
      a("Hasty", spd=0.1, cdr=0.1),
      a("Nimble", spd=0.12, crit=0.03),
      a("Windborne", spd=0.18, def=-1),
      a("Keen", atk=2, crit=0.05),
      a("Relentless", cdr=0.2, hp=-1),
      a("Agile", spd=0.1, def=1),
      a("Tempest", spd=0.15, cdr=0.1, atk=2, hp=-2),
    ]
    Expanded => {
      // Mix of all axes
      let result : Array[Affix] = []
      // classic core
      result.push(a("Keen", atk=2, crit=0.05))
      result.push(a("Brutal", atk=4))
      result.push(a("Sturdy", def=3, hp=2))
      result.push(a("Vampiric", atk=1, ls=0.08))
      // glass cannon
      result.push(a("Deadly", atk=6, hp=-3))
      result.push(a("Frenzied", atk=5, crit=0.1, def=-2))
      // tank
      result.push(a("Fortified", def=5, hp=3))
      result.push(a("Guardian", def=3, hp=2, ls=0.04))
      // mobility
      result.push(a("Swift", spd=0.15, atk=1))
      result.push(a("Rapid", cdr=0.15, atk=1))
      result.push(a("Hasty", spd=0.1, cdr=0.1))
      result.push(a("Tempest", spd=0.15, cdr=0.1, atk=2, hp=-2))
      result
    }
  }
}

pub fn suffix_table_for(profile : AffixProfile) -> Array[Affix] {
  let classic : Array[Affix] = [
    a("of Power", atk=3),
    a("of the Bear", def=2, hp=5),
    a("of Precision", crit=0.1),
    a("of Leeching", ls=0.1),
    a("of Thorns", def=4),
    a("of Haste", atk=1, crit=0.05),
    a("of Vitality", hp=6),
    a("of Fury", atk=4, hp=-2, crit=0.06),
    a("of the Wolf", atk=2, def=1, hp=2, ls=0.03),
    a("of Fortune", atk=1, def=1, hp=1, crit=0.03, ls=0.03),
  ]
  match profile {
    Classic => classic
    GlassCannon => [
      a("of Annihilation", atk=5, def=-2),
      a("of Fury", atk=4, hp=-2, crit=0.06),
      a("of Slaughter", atk=4, crit=0.08),
      a("of Power", atk=3),
      a("of Precision", crit=0.1),
      a("of Carnage", atk=6, hp=-4, crit=0.05),
      a("of Ruin", atk=5, def=-1, crit=0.04),
      a("of the Blade", atk=3, crit=0.07),
      a("of Leeching", ls=0.1),
      a("of Devastation", atk=7, hp=-3),
    ]
    Tank => [
      a("of the Bear", def=2, hp=5),
      a("of the Mountain", def=5, hp=3),
      a("of Vitality", hp=6),
      a("of Thorns", def=4),
      a("of Regeneration", hp=3, ls=0.06),
      a("of the Bulwark", def=6, atk=-1),
      a("of Leeching", ls=0.1),
      a("of Stone", def=3, hp=4),
      a("of the Sentinel", def=4, hp=2, ls=0.02),
      a("of Endurance", hp=8, atk=-2),
    ]
    Mobility => [
      a("of the Wind", spd=0.2),
      a("of Alacrity", cdr=0.2),
      a("of Swiftness", spd=0.15, atk=1),
      a("of Tempo", cdr=0.15, crit=0.03),
      a("of the Gale", spd=0.18, cdr=0.08),
      a("of Celerity", spd=0.12, cdr=0.12),
      a("of Haste", atk=1, crit=0.05),
      a("of Quickening", cdr=0.18, hp=-1),
      a("of the Falcon", spd=0.15, crit=0.05),
      a("of Lightning", spd=0.1, cdr=0.1, atk=2),
    ]
    Expanded => {
      let result : Array[Affix] = []
      // classic core
      result.push(a("of Power", atk=3))
      result.push(a("of the Bear", def=2, hp=5))
      result.push(a("of Precision", crit=0.1))
      result.push(a("of Leeching", ls=0.1))
      // glass cannon
      result.push(a("of Fury", atk=4, hp=-2, crit=0.06))
      result.push(a("of Annihilation", atk=5, def=-2))
      // tank
      result.push(a("of Vitality", hp=6))
      result.push(a("of Regeneration", hp=3, ls=0.06))
      // mobility
      result.push(a("of the Wind", spd=0.2))
      result.push(a("of Alacrity", cdr=0.2))
      result.push(a("of the Gale", spd=0.18, cdr=0.08))
      result.push(a("of Lightning", spd=0.1, cdr=0.1, atk=2))
      result
    }
  }
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
    speed_bonus: affix.speed_bonus,
    cooldown_reduction: affix.cooldown_reduction,
  }
}

// --- Item Generation ---

pub fn generate_item(seed : Int, floor : Int) -> ItemData {
  generate_item_with_profile(seed, floor, Classic)
}

pub fn generate_item_with_profile(
  seed : Int,
  floor : Int,
  profile : AffixProfile
) -> ItemData {
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
  let prefixes = prefix_table_for(profile)
  let suffixes = suffix_table_for(profile)
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
