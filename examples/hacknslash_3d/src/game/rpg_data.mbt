// RPG data structures: inventory, skills, equipment, stats

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
  spell_damage_pct : Double // +% spell damage (e.g. 0.15 = +15%)
  chain_bonus : Int // +chain targets for ChainLightning
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
      atk * 1.2 + def * 0.8 + hp * 0.35 + str_bonus * 4.0 +
      dex_bonus * 0.75 + int_bonus * 0.2 + str_scaling * 90.0 +
      dex_scaling * 20.0 + crit * 40.0 + ls * 55.0 + spd * 25.0 +
      cdr * 20.0
    Mage =>
      atk * 0.75 + def * 0.35 + hp * 0.2 + int_bonus * 4.0 +
      dex_bonus * 0.6 + str_bonus * 0.2 + int_scaling * 95.0 +
      dex_scaling * 18.0 + crit * 25.0 + ls * 10.0 + spd * 30.0 +
      cdr * 85.0
    Summoner =>
      atk * 0.9 + def * 0.45 + hp * 0.25 + int_bonus * 2.75 +
      dex_bonus * 2.5 + str_bonus * 0.25 + int_scaling * 70.0 +
      dex_scaling * 70.0 + crit * 45.0 + ls * 15.0 + spd * 40.0 +
      cdr * 65.0
    Ranger =>
      atk * 1.0 + def * 0.4 + hp * 0.2 + dex_bonus * 4.0 +
      int_bonus * 0.5 + str_bonus * 0.2 + dex_scaling * 95.0 +
      int_scaling * 15.0 + crit * 90.0 + ls * 20.0 + spd * 55.0 +
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

// --- Skill System ---

///|
pub(all) enum SkillId {
  PowerStrike
  Whirlwind
  DashMastery
  Vitality
  CriticalHit
  LifeSteal
  ChainLightning
  SplittingFireball
  IceNova
  HomingMissile
}

///|
pub(all) struct SkillNode {
  id : SkillId
  name : String
  max_level : Int
  mut level : Int
  cost : Int
  icon_id : Int
  prereqs : Array[SkillId]
  tree_col : Int // column position in skill tree layout (0-3)
  tree_row : Int // row position in skill tree layout (0-4)
}

///|
pub(all) struct SkillTree {
  nodes : Array[SkillNode]
  mut skill_points : Int
}

///|
pub fn SkillTree::new() -> SkillTree {
  {
    nodes: [
      // Row 0: Melee tree root
      {
        id: PowerStrike,
        name: "Power Strike",
        max_level: 5,
        level: 0,
        cost: 1,
        icon_id: 10,
        prereqs: [],
        tree_col: 0,
        tree_row: 0,
      },
      // Row 1: Melee branches
      {
        id: Whirlwind,
        name: "Whirlwind",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 11,
        prereqs: [PowerStrike],
        tree_col: 0,
        tree_row: 1,
      },
      // Row 0: Utility tree
      {
        id: DashMastery,
        name: "Dash Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 12,
        prereqs: [],
        tree_col: 1,
        tree_row: 0,
      },
      {
        id: Vitality,
        name: "Vitality",
        max_level: 5,
        level: 0,
        cost: 1,
        icon_id: 13,
        prereqs: [],
        tree_col: 1,
        tree_row: 1,
      },
      // Row 1: Melee-Utility junction
      {
        id: CriticalHit,
        name: "Critical Hit",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 14,
        prereqs: [PowerStrike],
        tree_col: 0,
        tree_row: 2,
      },
      // Row 2: Convergence
      {
        id: LifeSteal,
        name: "Life Steal",
        max_level: 3,
        level: 0,
        cost: 3,
        icon_id: 15,
        prereqs: [CriticalHit, Vitality],
        tree_col: 1,
        tree_row: 2,
      },
      // Row 0-1: Spell tree (right side)
      {
        id: ChainLightning,
        name: "Chain Lightning",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 16,
        prereqs: [],
        tree_col: 2,
        tree_row: 0,
      },
      {
        id: SplittingFireball,
        name: "Splitting Fireball",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 17,
        prereqs: [],
        tree_col: 3,
        tree_row: 0,
      },
      {
        id: IceNova,
        name: "Ice Nova",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 18,
        prereqs: [],
        tree_col: 2,
        tree_row: 1,
      },
      {
        id: HomingMissile,
        name: "Homing Missile",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 19,
        prereqs: [],
        tree_col: 3,
        tree_row: 1,
      },
    ],
    skill_points: 0,
  }
}

///|
pub fn SkillTree::new_for_archetype(
  archetype : CharacterArchetype,
) -> SkillTree {
  let tree = SkillTree::new()
  for skill_id in archetype.starting_skill_ids() {
    let index = tree.find_index(skill_id)
    if index >= 0 {
      tree.nodes[index].level = 1
    }
  }
  tree
}

///|
pub fn infer_character_archetype_from_skills(
  skills : SkillTree,
) -> CharacterArchetype? {
  if skills.get_level(PowerStrike) > 0 {
    return Some(Melee)
  }
  if skills.get_level(ChainLightning) > 0 {
    return Some(Mage)
  }
  if skills.get_level(HomingMissile) > 0 {
    return Some(Summoner)
  }
  if skills.get_level(CriticalHit) > 0 {
    return Some(Ranger)
  }
  None
}

///|
pub fn SkillTree::find(self : SkillTree, id : SkillId) -> SkillNode? {
  for node in self.nodes {
    if skill_id_eq(node.id, id) {
      return Some(node)
    }
  }
  None
}

///|
fn SkillTree::find_index(self : SkillTree, id : SkillId) -> Int {
  for i = 0; i < self.nodes.length(); i = i + 1 {
    if skill_id_eq(self.nodes[i].id, id) {
      return i
    }
  }
  -1
}

///|
pub fn SkillTree::learned_node_count(self : SkillTree) -> Int {
  let mut count = 0
  for node in self.nodes {
    if node.level > 0 {
      count = count + 1
    }
  }
  count
}

///|
pub fn skill_id_eq(a : SkillId, b : SkillId) -> Bool {
  skill_id_to_int(a) == skill_id_to_int(b)
}

///|
pub fn skill_id_to_int(id : SkillId) -> Int {
  match id {
    PowerStrike => 0
    Whirlwind => 1
    DashMastery => 2
    Vitality => 3
    CriticalHit => 4
    LifeSteal => 5
    ChainLightning => 6
    SplittingFireball => 7
    IceNova => 8
    HomingMissile => 9
  }
}

///|
pub fn skill_id_from_int(id : Int) -> SkillId? {
  match id {
    0 => Some(PowerStrike)
    1 => Some(Whirlwind)
    2 => Some(DashMastery)
    3 => Some(Vitality)
    4 => Some(CriticalHit)
    5 => Some(LifeSteal)
    6 => Some(ChainLightning)
    7 => Some(SplittingFireball)
    8 => Some(IceNova)
    9 => Some(HomingMissile)
    _ => None
  }
}

///|
pub fn spell_skill_ids() -> Array[SkillId] {
  [ChainLightning, SplittingFireball, IceNova, HomingMissile]
}

///|
pub fn SkillTree::can_learn(self : SkillTree, id : SkillId) -> Bool {
  let index = self.find_index(id)
  if index < 0 {
    return false
  }
  let node = self.nodes[index]
  if node.level >= node.max_level {
    return false
  }
  if self.skill_points < node.cost {
    return false
  }
  for prereq in node.prereqs {
    let prereq_index = self.find_index(prereq)
    if prereq_index < 0 || self.nodes[prereq_index].level == 0 {
      return false
    }
  }
  true
}

///|
pub fn SkillTree::learn(self : SkillTree, id : SkillId) -> Bool {
  if not(self.can_learn(id)) {
    return false
  }
  let index = self.find_index(id)
  if index < 0 {
    return false
  }
  self.skill_points = self.skill_points - self.nodes[index].cost
  self.nodes[index].level = self.nodes[index].level + 1
  true
}

///|
pub fn SkillTree::get_level(self : SkillTree, id : SkillId) -> Int {
  match self.find(id) {
    Some(node) => node.level
    None => 0
  }
}

// --- Player Stats ---

///|
pub(all) struct PlayerStats {
  max_hp : Int
  atk : Int
  attack_power : Int
  spell_power : Int
  ranged_power : Int
  def : Int
  strength : Int
  intelligence : Int
  dexterity : Int
  dash_cooldown : Int
  crit_chance : Double
  life_steal : Double
  speed_bonus : Double // total movement speed bonus from equipment
  cooldown_reduction : Double // total attack cooldown reduction from equipment
  spell_damage_pct : Double // total +% spell damage from equipment
  chain_bonus : Int // total +chain targets from equipment
}

///|
fn stat_scaling_progress(stat : Int) -> Double {
  let extra = @cmp.maximum(0, stat - 10).to_double()
  let tier1 = @cmp.minimum(extra, 10.0) * 0.04
  let tier2 = @cmp.minimum(@cmp.maximum(0.0, extra - 10.0), 20.0) * 0.02
  let tier3 = @cmp.minimum(@cmp.maximum(0.0, extra - 30.0), 20.0) * 0.01
  let tier4 = @cmp.maximum(0.0, extra - 50.0) * 0.005
  tier1 + tier2 + tier3 + tier4
}

///|
pub fn soulslike_scaled_damage(
  base_damage : Int,
  stat : Int,
  scaling : Double,
) -> Int {
  if base_damage <= 0 {
    return 0
  }
  let multiplier = 1.0 +
    stat_scaling_progress(stat) * @cmp.maximum(0.0, scaling)
  @cmp.maximum(base_damage, (base_damage.to_double() * multiplier).to_int())
}

///|
pub fn player_basic_attack_damage(
  stats : PlayerStats,
  archetype : CharacterArchetype,
) -> Int {
  @cmp.maximum(
    1,
    (stats.ranged_power.to_double() * archetype.basic_attack_multiplier())
      .to_int(),
  )
}

///|
pub fn skill_level_damage_multiplier(id : SkillId, level : Int) -> Double {
  if level <= 0 {
    return 1.0
  }
  // Base multiplier at level 1 + growth per additional level
  let (base, growth) = match id {
    PowerStrike => (2.0, 0.5) // Lv1=2.0, Lv2=2.5, Lv3=3.0, Lv5=4.0
    Whirlwind => (1.5, 0.5) // Lv1=1.5, Lv2=2.0, Lv3=2.5
    ChainLightning => (1.5, 0.4) // Lv1=1.5, Lv2=1.9, Lv3=2.3
    SplittingFireball => (1.5, 0.4)
    IceNova => (1.5, 0.4)
    HomingMissile => (1.5, 0.4)
    _ => (1.0, 0.0)
  }
  base + (level - 1).to_double() * growth
}

///|
pub fn chain_lightning_targets_for_level(level : Int) -> Int {
  @cmp.maximum(1, level + 1)
}

///|
pub fn player_spell_damage(
  stats : PlayerStats,
  params : BalanceParams,
  archetype : CharacterArchetype,
  skill : SkillId,
  skill_level? : Int = 1,
) -> Int {
  let base_damage = match skill {
    ChainLightning => stats.spell_power + 2
    SplittingFireball => stats.spell_power + 2
    IceNova => stats.spell_power + 1
    HomingMissile => stats.ranged_power + 2
    _ => stats.attack_power
  }
  let scaled = params.scale_spell_damage(base_damage)
  let level_mult = skill_level_damage_multiplier(skill, skill_level)
  let spell_pct = 1.0 + stats.spell_damage_pct
  @cmp.maximum(
    1,
    (scaled.to_double() * archetype.skill_damage_multiplier(skill) * level_mult * spell_pct).to_int(),
  )
}

///|
pub fn compute_player_stats(
  equipment : Equipment,
  skills : SkillTree,
  base_hp? : Int = 8,
  archetype? : CharacterArchetype? = infer_character_archetype_from_skills(
    skills,
  ),
) -> PlayerStats {
  let base_atk = 1
  let base_def = 0
  let vitality_level = skills.get_level(Vitality)
  let power_strike_level = skills.get_level(PowerStrike)
  let dash_mastery_level = skills.get_level(DashMastery)
  let crit_level = skills.get_level(CriticalHit)
  let ls_level = skills.get_level(LifeSteal)
  let spell_unlocks = spell_skill_ids()
    |> ids => {
      let mut count = 0
      for id in ids {
        if skills.get_level(id) > 0 {
          count += 1
        }
      }
      count
    }
  let base_strength = match archetype {
    Some(a) => a.base_strength()
    None => 10
  }
  let base_intelligence = match archetype {
    Some(a) => a.base_intelligence()
    None => 10
  }
  let base_dexterity = match archetype {
    Some(a) => a.base_dexterity()
    None => 10
  }
  let strength = base_strength + equipment.total_str_bonus() + power_strike_level
  let intelligence = base_intelligence + equipment.total_int_bonus() + spell_unlocks
  let dexterity = base_dexterity + equipment.total_dex_bonus() + dash_mastery_level
  let attack_power = soulslike_scaled_damage(
    base_atk + equipment.total_atk() + power_strike_level,
    strength,
    0.15 + equipment.total_str_scaling(),
  )
  let spell_power = soulslike_scaled_damage(
    base_atk + equipment.total_atk() + @cmp.maximum(1, spell_unlocks),
    intelligence,
    0.2 + equipment.total_int_scaling(),
  )
  let ranged_power = soulslike_scaled_damage(
    base_atk + equipment.total_atk(),
    dexterity,
    0.2 + equipment.total_dex_scaling(),
  )
  {
    max_hp: {
      let hp_mod = match archetype {
        Some(a) => a.hp_modifier()
        None => 0
      }
      base_hp + equipment.total_hp() + vitality_level * 3 + hp_mod
    },
    atk: attack_power,
    attack_power,
    spell_power,
    ranged_power,
    def: base_def + equipment.total_def(),
    strength,
    intelligence,
    dexterity,
    dash_cooldown: 40 - dash_mastery_level * 8,
    crit_chance: crit_level.to_double() * 0.1 + equipment.total_crit(),
    life_steal: ls_level.to_double() * 0.05 + equipment.total_life_steal(),
    speed_bonus: {
      let archetype_speed = match archetype {
        Some(a) => a.speed_modifier() - 1.0
        None => 0.0
      }
      equipment.total_speed_bonus() + archetype_speed
    },
    cooldown_reduction: equipment.total_cooldown_reduction(),
    spell_damage_pct: equipment.total_spell_damage_pct(),
    chain_bonus: equipment.total_chain_bonus(),
  }
}

// --- DPS Calculation ---

///|
pub(all) struct SkillDpsInfo {
  skill_id : SkillId
  damage_per_hit : Int
  hits_per_cast : Int
  cooldown_frames : Int
  dps : Double
}

///|
pub fn compute_skill_dps(
  skill_id : SkillId,
  level : Int,
  stats : PlayerStats,
  params : BalanceParams,
  archetype : CharacterArchetype,
) -> SkillDpsInfo {
  if level <= 0 {
    return {
      skill_id,
      damage_per_hit: 0,
      hits_per_cast: 0,
      cooldown_frames: 60,
      dps: 0.0,
    }
  }
  let (damage, hits, cd) = match skill_id {
    PowerStrike => {
      let dmg = (player_basic_attack_damage(stats, archetype).to_double() *
        skill_level_damage_multiplier(PowerStrike, level)).to_int().max(1)
      (dmg, 3, params.attack_cooldown.to_int())
    }
    Whirlwind => {
      let dmg = (player_basic_attack_damage(stats, archetype).to_double() *
        skill_level_damage_multiplier(Whirlwind, level)).to_int().max(1)
      (dmg, 4, params.attack_cooldown.to_int() + 5) // 8-way, ~4 avg hits
    }
    ChainLightning => {
      let dmg = player_spell_damage(
        stats,
        params,
        archetype,
        ChainLightning,
        skill_level=level,
      )
      let targets = chain_lightning_targets_for_level(level) + stats.chain_bonus
      (dmg, targets, params.chain_lightning_cooldown_frames())
    }
    SplittingFireball => {
      let dmg = player_spell_damage(
        stats,
        params,
        archetype,
        SplittingFireball,
        skill_level=level,
      )
      (dmg, 2, params.splitting_fireball_cooldown_frames()) // main + 1 split avg
    }
    IceNova => {
      let dmg = player_spell_damage(
        stats,
        params,
        archetype,
        IceNova,
        skill_level=level,
      )
      (dmg, 3, params.ice_nova_cooldown_frames()) // AoE avg hits
    }
    HomingMissile => {
      let dmg = player_spell_damage(
        stats,
        params,
        archetype,
        HomingMissile,
        skill_level=level,
      )
      (dmg, 2, params.homing_missile_cooldown_frames())
    }
    _ => (0, 0, 60)
  }
  let effective_cd = @cmp.maximum(1, cd)
  let casts_per_sec = 60.0 / effective_cd.to_double()
  let dps = damage.to_double() * hits.to_double() * casts_per_sec
  { skill_id, damage_per_hit: damage, hits_per_cast: hits, cooldown_frames: cd, dps }
}

///|
pub fn compute_total_dps(
  skills : SkillTree,
  stats : PlayerStats,
  params : BalanceParams,
  archetype : CharacterArchetype,
) -> Double {
  let mut total = 0.0
  // Basic auto-attack DPS
  let arrow_dmg = player_basic_attack_damage(stats, archetype)
  let bow_cd = @cmp.maximum(
    3,
    (params.bow_cooldown * (1.0 - stats.cooldown_reduction)).to_int(),
  )
  total = total + arrow_dmg.to_double() * 60.0 / bow_cd.to_double()
  // Skill DPS contributions
  let skill_ids : Array[SkillId] = [
    PowerStrike, Whirlwind, ChainLightning, SplittingFireball, IceNova,
    HomingMissile,
  ]
  for id in skill_ids {
    let level = skills.get_level(id)
    if level > 0 {
      let info = compute_skill_dps(id, level, stats, params, archetype)
      total = total + info.dps
    }
  }
  total
}

// --- Affix Tables ---

// Affix profile IDs for selecting different affix table sets

///|
pub(all) enum AffixProfile {
  Classic // original 10+10
  GlassCannon // high atk, negative hp/def
  Tank // high def/hp, sustain
  Mobility // speed & cooldown focused
  Expanded // all axes mixed
}

///|
fn a(
  name : String,
  atk? : Int = 0,
  def? : Int = 0,
  hp? : Int = 0,
  str? : Int = 0,
  int_? : Int = 0,
  dex? : Int = 0,
  crit? : Double = 0.0,
  ls? : Double = 0.0,
  spd? : Double = 0.0,
  cdr? : Double = 0.0,
  str_scale? : Double = 0.0,
  int_scale? : Double = 0.0,
  dex_scale? : Double = 0.0,
  spell_dmg? : Double = 0.0,
  chain? : Int = 0,
) -> Affix {
  {
    name,
    atk,
    def,
    hp,
    str_bonus: str,
    int_bonus: int_,
    dex_bonus: dex,
    crit,
    life_steal: ls,
    speed_bonus: spd,
    cooldown_reduction: cdr,
    str_scaling: str_scale,
    int_scaling: int_scale,
    dex_scaling: dex_scale,
    spell_damage_pct: spell_dmg,
    chain_bonus: chain,
  }
}

///|
pub fn prefix_table() -> Array[Affix] {
  prefix_table_for(Classic)
}

///|
pub fn suffix_table() -> Array[Affix] {
  suffix_table_for(Classic)
}

///|
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
    a("Crackling", int_=2, spell_dmg=0.12, chain=1),
    a("Volatile", atk=1, spell_dmg=0.15),
  ]
  match profile {
    Classic => classic
    GlassCannon =>
      [
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
    Tank =>
      [
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
    Mobility =>
      [
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

///|
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
    a("of Arcing", int_=1, chain=1, spell_dmg=0.08),
    a("of Storms", spell_dmg=0.2, int_=2),
  ]
  match profile {
    Classic => classic
    GlassCannon =>
      [
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
    Tank =>
      [
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
    Mobility =>
      [
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

///|
pub fn scale_affix(affix : Affix, floor : Int) -> Affix {
  let scale = 1 + floor / 5
  {
    name: affix.name,
    atk: affix.atk * scale,
    def: affix.def * scale,
    hp: affix.hp * scale,
    str_bonus: affix.str_bonus * scale,
    int_bonus: affix.int_bonus * scale,
    dex_bonus: affix.dex_bonus * scale,
    crit: affix.crit,
    life_steal: affix.life_steal,
    speed_bonus: affix.speed_bonus,
    cooldown_reduction: affix.cooldown_reduction,
    str_scaling: affix.str_scaling,
    int_scaling: affix.int_scaling,
    dex_scaling: affix.dex_scaling,
    spell_damage_pct: affix.spell_damage_pct,
    chain_bonus: affix.chain_bonus,
  }
}

// --- Item Generation ---

///|
pub fn generate_item(seed : Int, floor : Int) -> ItemData {
  generate_item_with_profile(seed, floor, Classic)
}

///|
pub fn generate_item_with_profile(
  seed : Int,
  floor : Int,
  profile : AffixProfile,
) -> ItemData {
  generate_item_with_profile_and_drop_config(
    seed,
    floor,
    profile,
    DropTableConfig::default(),
  )
}
