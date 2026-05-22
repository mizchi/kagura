// RPG data structures: inventory, skills, equipment, stats

// --- Tag Bonus System ---

///|
pub(all) struct TagBonus {
  mut damage_pct : Double
  mut cooldown_reduction : Double
  mut extra_targets : Int
  mut aoe_radius_pct : Double
  mut crit_bonus : Double
}

///|
pub fn TagBonus::zero() -> TagBonus {
  {
    damage_pct: 0.0,
    cooldown_reduction: 0.0,
    extra_targets: 0,
    aoe_radius_pct: 0.0,
    crit_bonus: 0.0,
  }
}

///|
pub(all) struct TagBonusEntry {
  tag : SkillTag
  damage_pct : Double
  cooldown_reduction : Double
  extra_targets : Int
  aoe_radius_pct : Double
  crit_bonus : Double
}

///|
pub fn new_tag_bonuses_array() -> Array[TagBonus] {
  let arr : Array[TagBonus] = []
  for _i in 0..<skill_tag_count {
    arr.push(TagBonus::zero())
  }
  arr
}

// --- Item System ---

///|
pub(all) enum ItemRarity {
  Common
  Uncommon
  Rare
  Epic
}

///|
pub fn ItemRarity::color(self : ItemRarity) -> Int {
  match self {
    Common => 0xAAAAAA
    Uncommon => 0x00CC00
    Rare => 0x3366FF
    Epic => 0xCC00FF
  }
}

///|
pub(all) enum EquipSlot {
  Weapon
  Armor
  Accessory
}

///|
pub(all) struct Affix {
  name : String
  atk : Int
  def : Int
  hp : Int
  str_bonus : Int
  int_bonus : Int
  dex_bonus : Int
  crit : Double
  life_steal : Double
  speed_bonus : Double // movement speed multiplier bonus (e.g. 0.1 = +10%)
  cooldown_reduction : Double // attack cooldown reduction fraction (e.g. 0.1 = 10% faster)
  str_scaling : Double
  int_scaling : Double
  dex_scaling : Double
  spell_damage_pct : Double // +% spell damage (legacy, converted to tag bonus)
  chain_bonus : Int // +chain targets (legacy, converted to tag bonus)
  tag_bonuses : Array[TagBonusEntry]
}

///|
pub(all) struct ItemData {
  name : String
  rarity : ItemRarity
  slot : EquipSlot
  atk_bonus : Int
  def_bonus : Int
  hp_bonus : Int
  str_bonus : Int
  int_bonus : Int
  dex_bonus : Int
  str_scaling : Double
  int_scaling : Double
  dex_scaling : Double
  prefix : Affix?
  suffix : Affix?
  icon_id : Int
}

///|
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

///|
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

///|
pub fn ItemData::total_atk(self : ItemData) -> Int {
  affix_sum_int(self, self.atk_bonus, fn(a) { a.atk })
}

///|
pub fn ItemData::total_def(self : ItemData) -> Int {
  affix_sum_int(self, self.def_bonus, fn(a) { a.def })
}

///|
pub fn ItemData::total_hp(self : ItemData) -> Int {
  affix_sum_int(self, self.hp_bonus, fn(a) { a.hp })
}

///|
pub fn ItemData::total_crit(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.crit })
}

///|
pub fn ItemData::total_str_bonus(self : ItemData) -> Int {
  affix_sum_int(self, self.str_bonus, fn(a) { a.str_bonus })
}

///|
pub fn ItemData::total_int_bonus(self : ItemData) -> Int {
  affix_sum_int(self, self.int_bonus, fn(a) { a.int_bonus })
}

///|
pub fn ItemData::total_dex_bonus(self : ItemData) -> Int {
  affix_sum_int(self, self.dex_bonus, fn(a) { a.dex_bonus })
}

///|
pub fn ItemData::total_life_steal(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.life_steal })
}

///|
pub fn ItemData::total_str_scaling(self : ItemData) -> Double {
  self.str_scaling + affix_sum_double(self, fn(a) { a.str_scaling })
}

///|
pub fn ItemData::total_int_scaling(self : ItemData) -> Double {
  self.int_scaling + affix_sum_double(self, fn(a) { a.int_scaling })
}

///|
pub fn ItemData::total_dex_scaling(self : ItemData) -> Double {
  self.dex_scaling + affix_sum_double(self, fn(a) { a.dex_scaling })
}

///|
pub fn ItemData::total_spell_damage_pct(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.spell_damage_pct })
}

///|
pub fn ItemData::total_chain_bonus(self : ItemData) -> Int {
  affix_sum_int(self, 0, fn(a) { a.chain_bonus })
}

///|
pub fn ItemData::total_stat_score(self : ItemData) -> Double {
  self.total_atk().to_double() +
  self.total_def().to_double() +
  self.total_hp().to_double() +
  self.total_str_bonus().to_double() * 1.5 +
  self.total_int_bonus().to_double() * 1.5 +
  self.total_dex_bonus().to_double() * 1.5 +
  self.total_crit() * 100.0 +
  self.total_life_steal() * 100.0 +
  self.total_speed_bonus() * 100.0 +
  self.total_cooldown_reduction() * 100.0 +
  self.total_str_scaling() * 40.0 +
  self.total_int_scaling() * 40.0 +
  self.total_dex_scaling() * 40.0
}

///|
pub fn ItemData::archetype_fit_score(
  self : ItemData,
  archetype : CharacterArchetype,
) -> Double {
  let atk = self.total_atk().to_double()
  let def = self.total_def().to_double()
  let hp = self.total_hp().to_double()
  let str_bonus = self.total_str_bonus().to_double()
  let int_bonus = self.total_int_bonus().to_double()
  let dex_bonus = self.total_dex_bonus().to_double()
  let str_scaling = self.total_str_scaling()
  let int_scaling = self.total_int_scaling()
  let dex_scaling = self.total_dex_scaling()
  let crit = self.total_crit()
  let ls = self.total_life_steal()
  let spd = self.total_speed_bonus()
  let cdr = self.total_cooldown_reduction()
  match archetype {
    Melee =>
      atk * 1.2 +
      def * 0.8 +
      hp * 0.35 +
      str_bonus * 4.0 +
      dex_bonus * 0.75 +
      int_bonus * 0.2 +
      str_scaling * 90.0 +
      dex_scaling * 20.0 +
      crit * 40.0 +
      ls * 55.0 +
      spd * 25.0 +
      cdr * 20.0
    Mage =>
      atk * 0.75 +
      def * 0.35 +
      hp * 0.2 +
      int_bonus * 4.0 +
      dex_bonus * 0.6 +
      str_bonus * 0.2 +
      int_scaling * 95.0 +
      dex_scaling * 18.0 +
      crit * 25.0 +
      ls * 10.0 +
      spd * 30.0 +
      cdr * 85.0
    Summoner =>
      atk * 0.9 +
      def * 0.45 +
      hp * 0.25 +
      int_bonus * 2.75 +
      dex_bonus * 2.5 +
      str_bonus * 0.25 +
      int_scaling * 70.0 +
      dex_scaling * 70.0 +
      crit * 45.0 +
      ls * 15.0 +
      spd * 40.0 +
      cdr * 65.0
    Ranger =>
      atk * 1.0 +
      def * 0.4 +
      hp * 0.2 +
      dex_bonus * 4.0 +
      int_bonus * 0.5 +
      str_bonus * 0.2 +
      dex_scaling * 95.0 +
      int_scaling * 15.0 +
      crit * 90.0 +
      ls * 20.0 +
      spd * 55.0 +
      cdr * 35.0
  }
}

///|
pub fn ItemData::build_policy_fit_score(
  self : ItemData,
  archetype : CharacterArchetype,
  build_policy : ArchetypeBuildPolicy,
) -> Double {
  match build_policy {
    ArchetypeAligned => self.archetype_fit_score(archetype)
    AntiSynergy => self.archetype_fit_score(archetype.anti_synergy_target())
  }
}

///|
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

///|
pub(all) struct Inventory {
  items : Array[ItemData?]
  capacity : Int
}

///|
pub fn Inventory::new(capacity : Int) -> Inventory {
  let items : Array[ItemData?] = []
  for _i in 0..<capacity {
    items.push(None)
  }
  { items, capacity }
}

///|
pub fn Inventory::add(self : Inventory, item : ItemData) -> Bool {
  for i in 0..<self.capacity {
    if self.items[i] is None {
      self.items[i] = Some(item)
      return true
    }
  }
  false
}

///|
fn inventory_compact(inv : Inventory) -> Int {
  let mut write = 0
  for read in 0..<inv.capacity {
    match inv.items[read] {
      Some(item) => {
        if write != read {
          inv.items[write] = Some(item)
          inv.items[read] = None
        }
        write = write + 1
      }
      None => ()
    }
  }
  write
}

///|
pub fn Inventory::add_fifo(self : Inventory, item : ItemData) -> ItemData? {
  let used = inventory_compact(self)
  if used < self.capacity {
    self.items[used] = Some(item)
    return None
  }
  if self.capacity <= 0 {
    return Some(item)
  }
  let dropped = self.items[0]
  for i = 1; i < self.capacity; i = i + 1 {
    self.items[i - 1] = self.items[i]
  }
  self.items[self.capacity - 1] = Some(item)
  dropped
}

///|
pub fn Inventory::remove(self : Inventory, index : Int) -> ItemData? {
  if index < 0 || index >= self.capacity {
    return None
  }
  let item = self.items[index]
  self.items[index] = None
  item
}

///|
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

///|
pub(all) struct Equipment {
  mut weapon : ItemData?
  mut armor : ItemData?
  mut accessory : ItemData?
}

///|
pub fn Equipment::new() -> Equipment {
  { weapon: None, armor: None, accessory: None }
}

///|
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

///|
pub fn Equipment::clone(self : Equipment) -> Equipment {
  { weapon: self.weapon, armor: self.armor, accessory: self.accessory }
}

///|
pub fn Equipment::item_for_slot(
  self : Equipment,
  slot : EquipSlot,
) -> ItemData? {
  match slot {
    Weapon => self.weapon
    Armor => self.armor
    Accessory => self.accessory
  }
}

///|
pub fn Equipment::should_equip(self : Equipment, item : ItemData) -> Bool {
  match self.item_for_slot(item.slot) {
    Some(equipped) => item.total_stat_score() > equipped.total_stat_score()
    None => true
  }
}

///|
pub fn Equipment::should_equip_for_build(
  self : Equipment,
  item : ItemData,
  archetype : CharacterArchetype,
  build_policy : ArchetypeBuildPolicy,
) -> Bool {
  match self.item_for_slot(item.slot) {
    Some(equipped) =>
      item.build_policy_fit_score(archetype, build_policy) >
      equipped.build_policy_fit_score(archetype, build_policy)
    None => true
  }
}

///|
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

///|
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

///|
pub fn Equipment::total_atk(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_atk)
}

///|
pub fn Equipment::total_def(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_def)
}

///|
pub fn Equipment::total_hp(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_hp)
}

///|
pub fn Equipment::total_crit(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_crit)
}

///|
pub fn Equipment::total_str_bonus(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_str_bonus)
}

///|
pub fn Equipment::total_int_bonus(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_int_bonus)
}

///|
pub fn Equipment::total_dex_bonus(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_dex_bonus)
}

///|
pub fn Equipment::total_life_steal(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_life_steal)
}

///|
pub fn ItemData::total_speed_bonus(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.speed_bonus })
}

///|
pub fn ItemData::total_cooldown_reduction(self : ItemData) -> Double {
  affix_sum_double(self, fn(a) { a.cooldown_reduction })
}

///|
pub fn Equipment::total_speed_bonus(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_speed_bonus)
}

///|
pub fn Equipment::total_cooldown_reduction(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_cooldown_reduction)
}

///|
pub fn Equipment::total_str_scaling(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_str_scaling)
}

///|
pub fn Equipment::total_int_scaling(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_int_scaling)
}

///|
pub fn Equipment::total_dex_scaling(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_dex_scaling)
}

///|
pub fn Equipment::total_spell_damage_pct(self : Equipment) -> Double {
  equipment_sum_f(self, ItemData::total_spell_damage_pct)
}

///|
pub fn Equipment::total_chain_bonus(self : Equipment) -> Int {
  equipment_sum(self, ItemData::total_chain_bonus)
}
