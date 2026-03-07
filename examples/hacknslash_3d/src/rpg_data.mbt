// RPG data structures: inventory, skills, equipment, stats

// --- Item System ---

enum ItemRarity {
  Common
  Uncommon
  Rare
  Epic
}

fn ItemRarity::color(self : ItemRarity) -> Int {
  match self {
    Common => 0xAAAAAA
    Uncommon => 0x00CC00
    Rare => 0x3366FF
    Epic => 0xCC00FF
  }
}

enum EquipSlot {
  Weapon
  Armor
  Accessory
}

struct ItemData {
  name : String
  rarity : ItemRarity
  slot : EquipSlot
  atk_bonus : Int
  def_bonus : Int
  hp_bonus : Int
  icon_id : Int
}

struct Inventory {
  items : Array[ItemData?]
  capacity : Int
}

fn Inventory::new(capacity : Int) -> Inventory {
  let items : Array[ItemData?] = []
  for _i in 0..<capacity {
    items.push(None)
  }
  { items, capacity }
}

fn Inventory::add(self : Inventory, item : ItemData) -> Bool {
  for i in 0..<self.capacity {
    if self.items[i] is None {
      self.items[i] = Some(item)
      return true
    }
  }
  false
}

fn Inventory::remove(self : Inventory, index : Int) -> ItemData? {
  if index < 0 || index >= self.capacity {
    return None
  }
  let item = self.items[index]
  self.items[index] = None
  item
}

fn Inventory::count(self : Inventory) -> Int {
  let mut c = 0
  for item in self.items {
    if item is Some(_) {
      c = c + 1
    }
  }
  c
}

// --- Equipment ---

struct Equipment {
  mut weapon : ItemData?
  mut armor : ItemData?
  mut accessory : ItemData?
}

fn Equipment::new() -> Equipment {
  { weapon: None, armor: None, accessory: None }
}

fn Equipment::equip(self : Equipment, item : ItemData) -> ItemData? {
  let prev = match item.slot {
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
  prev
}

fn Equipment::total_atk(self : Equipment) -> Int {
  let mut total = 0
  match self.weapon {
    Some(item) => total = total + item.atk_bonus
    None => ()
  }
  match self.armor {
    Some(item) => total = total + item.atk_bonus
    None => ()
  }
  match self.accessory {
    Some(item) => total = total + item.atk_bonus
    None => ()
  }
  total
}

fn Equipment::total_def(self : Equipment) -> Int {
  let mut total = 0
  match self.weapon {
    Some(item) => total = total + item.def_bonus
    None => ()
  }
  match self.armor {
    Some(item) => total = total + item.def_bonus
    None => ()
  }
  match self.accessory {
    Some(item) => total = total + item.def_bonus
    None => ()
  }
  total
}

fn Equipment::total_hp(self : Equipment) -> Int {
  let mut total = 0
  match self.weapon {
    Some(item) => total = total + item.hp_bonus
    None => ()
  }
  match self.armor {
    Some(item) => total = total + item.hp_bonus
    None => ()
  }
  match self.accessory {
    Some(item) => total = total + item.hp_bonus
    None => ()
  }
  total
}

// --- Skill System ---

enum SkillId {
  PowerStrike
  Whirlwind
  DashMastery
  Vitality
  CriticalHit
  LifeSteal
}

struct SkillNode {
  id : SkillId
  name : String
  max_level : Int
  mut level : Int
  cost : Int
  icon_id : Int
  prereqs : Array[SkillId]
}

struct SkillTree {
  nodes : Array[SkillNode]
  mut skill_points : Int
}

fn SkillTree::new() -> SkillTree {
  {
    nodes: [
      {
        id: PowerStrike,
        name: "Power Strike",
        max_level: 5,
        level: 0,
        cost: 1,
        icon_id: 10,
        prereqs: [],
      },
      {
        id: Whirlwind,
        name: "Whirlwind",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 11,
        prereqs: [PowerStrike],
      },
      {
        id: DashMastery,
        name: "Dash Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 12,
        prereqs: [],
      },
      {
        id: Vitality,
        name: "Vitality",
        max_level: 5,
        level: 0,
        cost: 1,
        icon_id: 13,
        prereqs: [],
      },
      {
        id: CriticalHit,
        name: "Critical Hit",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 14,
        prereqs: [PowerStrike],
      },
      {
        id: LifeSteal,
        name: "Life Steal",
        max_level: 3,
        level: 0,
        cost: 3,
        icon_id: 15,
        prereqs: [CriticalHit, Vitality],
      },
    ],
    skill_points: 0,
  }
}

fn SkillTree::find(self : SkillTree, id : SkillId) -> SkillNode? {
  for node in self.nodes {
    if skill_id_eq(node.id, id) {
      return Some(node)
    }
  }
  None
}

fn skill_id_eq(a : SkillId, b : SkillId) -> Bool {
  skill_id_to_int(a) == skill_id_to_int(b)
}

fn skill_id_to_int(id : SkillId) -> Int {
  match id {
    PowerStrike => 0
    Whirlwind => 1
    DashMastery => 2
    Vitality => 3
    CriticalHit => 4
    LifeSteal => 5
  }
}

fn SkillTree::can_learn(self : SkillTree, id : SkillId) -> Bool {
  match self.find(id) {
    None => false
    Some(node) => {
      if node.level >= node.max_level {
        return false
      }
      if self.skill_points < node.cost {
        return false
      }
      // Check prereqs
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

fn SkillTree::learn(self : SkillTree, id : SkillId) -> Bool {
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

fn SkillTree::get_level(self : SkillTree, id : SkillId) -> Int {
  match self.find(id) {
    Some(node) => node.level
    None => 0
  }
}

// --- Player Stats (computed from base + equipment + skills) ---

struct PlayerStats {
  max_hp : Int
  atk : Int
  def : Int
  dash_cooldown : Int
  crit_chance : Double
  life_steal : Double
}

fn compute_player_stats(
  equipment : Equipment,
  skills : SkillTree,
) -> PlayerStats {
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
    crit_chance: crit_level.to_double() * 0.1,
    life_steal: ls_level.to_double() * 0.05,
  }
}

// --- Item Generation ---

fn generate_item(seed : Int, floor : Int) -> ItemData {
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
  let rarity_name = match rarity {
    Common => "Common"
    Uncommon => "Fine"
    Rare => "Rare"
    Epic => "Epic"
  }
  {
    name: rarity_name + " " + slot_name,
    rarity,
    slot,
    atk_bonus: atk,
    def_bonus: def,
    hp_bonus: hp,
    icon_id: slot_roll + rarity_roll % 3,
  }
}
