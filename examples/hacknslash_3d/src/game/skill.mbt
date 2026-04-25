// --- Skill System ---

///|
pub(all) enum SkillTag {
  Lightning
  Fire
  Cold
  Physical
  Projectile
  AoE
  Defense
  Utility
} derive(Eq)

///|
pub fn skill_tag_to_int(tag : SkillTag) -> Int {
  match tag {
    Lightning => 0
    Fire => 1
    Cold => 2
    Physical => 3
    Projectile => 4
    AoE => 5
    Defense => 6
    Utility => 7
  }
}

///|
pub let skill_tag_count : Int = 8

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
  Counter
  LightningMastery
  FireMastery
  ColdMastery
  PhysicalMastery
  ProjectileMastery
  AoEMastery
} derive(Eq)

///|
pub(all) struct SkillNode {
  id : SkillId
  name : String
  max_level : Int
  mut level : Int
  cost : Int
  icon_id : Int
  prereqs : Array[SkillId]
  tree_x : Double // x position in skill tree (0.0-1.0 normalized)
  tree_y : Double // y position in skill tree (0.0-1.0 normalized)
  node_size : Int // 0=small passive, 1=notable, 2=keystone
  connections : Array[SkillId] // visual connections (lines in skill tree UI)
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
      // === MELEE cluster (left) ===
      {
        id: PowerStrike,
        name: "Power Strike",
        max_level: 5,
        level: 0,
        cost: 1,
        icon_id: 10,
        prereqs: [],
        tree_x: 0.18,
        tree_y: 0.25,
        node_size: 1,
        connections: [Whirlwind, CriticalHit, DashMastery, Counter],
      },
      {
        id: Whirlwind,
        name: "Whirlwind",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 11,
        prereqs: [PowerStrike],
        tree_x: 0.08,
        tree_y: 0.48,
        node_size: 1,
        connections: [],
      },
      // === UTILITY cluster (center) ===
      {
        id: DashMastery,
        name: "Dash Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 12,
        prereqs: [],
        tree_x: 0.38,
        tree_y: 0.12,
        node_size: 0,
        connections: [Vitality],
      },
      {
        id: Vitality,
        name: "Vitality",
        max_level: 5,
        level: 0,
        cost: 1,
        icon_id: 13,
        prereqs: [],
        tree_x: 0.42,
        tree_y: 0.48,
        node_size: 0,
        connections: [LifeSteal],
      },
      // === CONVERGENCE (center) ===
      {
        id: CriticalHit,
        name: "Critical Hit",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 14,
        prereqs: [PowerStrike],
        tree_x: 0.25,
        tree_y: 0.68,
        node_size: 1,
        connections: [LifeSteal],
      },
      {
        id: LifeSteal,
        name: "Life Steal",
        max_level: 3,
        level: 0,
        cost: 3,
        icon_id: 15,
        prereqs: [CriticalHit, Vitality],
        tree_x: 0.50,
        tree_y: 0.42,
        node_size: 2,
        connections: [ChainLightning],
      },
      // === SPELL cluster (right) ===
      {
        id: ChainLightning,
        name: "Chain Lightning",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 16,
        prereqs: [],
        tree_x: 0.65,
        tree_y: 0.22,
        node_size: 1,
        connections: [SplittingFireball, IceNova],
      },
      {
        id: SplittingFireball,
        name: "Splitting Fireball",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 17,
        prereqs: [],
        tree_x: 0.85,
        tree_y: 0.18,
        node_size: 1,
        connections: [],
      },
      {
        id: IceNova,
        name: "Ice Nova",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 18,
        prereqs: [],
        tree_x: 0.68,
        tree_y: 0.58,
        node_size: 1,
        connections: [HomingMissile],
      },
      {
        id: HomingMissile,
        name: "Homing Missile",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 19,
        prereqs: [],
        tree_x: 0.88,
        tree_y: 0.65,
        node_size: 1,
        connections: [],
      },
      {
        id: Counter,
        name: "Counter",
        max_level: 3,
        level: 0,
        cost: 2,
        icon_id: 20,
        prereqs: [PowerStrike],
        tree_x: 0.22,
        tree_y: 0.7,
        node_size: 1,
        connections: [],
      },
      // === MASTERY cluster (bottom row) ===
      {
        id: PhysicalMastery,
        name: "Physical Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 21,
        prereqs: [PowerStrike],
        tree_x: 0.10,
        tree_y: 0.88,
        node_size: 0,
        connections: [],
      },
      {
        id: AoEMastery,
        name: "AoE Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 22,
        prereqs: [Whirlwind],
        tree_x: 0.25,
        tree_y: 0.92,
        node_size: 0,
        connections: [],
      },
      {
        id: LightningMastery,
        name: "Lightning Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 23,
        prereqs: [ChainLightning],
        tree_x: 0.58,
        tree_y: 0.82,
        node_size: 0,
        connections: [],
      },
      {
        id: FireMastery,
        name: "Fire Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 24,
        prereqs: [SplittingFireball],
        tree_x: 0.92,
        tree_y: 0.38,
        node_size: 0,
        connections: [],
      },
      {
        id: ColdMastery,
        name: "Cold Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 25,
        prereqs: [IceNova],
        tree_x: 0.75,
        tree_y: 0.82,
        node_size: 0,
        connections: [],
      },
      {
        id: ProjectileMastery,
        name: "Projectile Mastery",
        max_level: 3,
        level: 0,
        cost: 1,
        icon_id: 26,
        prereqs: [HomingMissile],
        tree_x: 0.92,
        tree_y: 0.85,
        node_size: 0,
        connections: [],
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
    Counter => 10
    LightningMastery => 11
    FireMastery => 12
    ColdMastery => 13
    PhysicalMastery => 14
    ProjectileMastery => 15
    AoEMastery => 16
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
    10 => Some(Counter)
    11 => Some(LightningMastery)
    12 => Some(FireMastery)
    13 => Some(ColdMastery)
    14 => Some(PhysicalMastery)
    15 => Some(ProjectileMastery)
    16 => Some(AoEMastery)
    _ => None
  }
}

///|
pub fn skill_tags(id : SkillId) -> Array[SkillTag] {
  match id {
    PowerStrike => [Physical]
    Whirlwind => [Physical, AoE]
    Counter => [Physical, Defense]
    ChainLightning => [Lightning, Projectile]
    SplittingFireball => [Fire, Projectile, AoE]
    IceNova => [Cold, AoE]
    HomingMissile => [Projectile]
    DashMastery => [Utility]
    Vitality => [Defense]
    CriticalHit => [Utility, Physical]
    LifeSteal => [Utility]
    LightningMastery => [Lightning]
    FireMastery => [Fire]
    ColdMastery => [Cold]
    PhysicalMastery => [Physical]
    ProjectileMastery => [Projectile]
    AoEMastery => [AoE]
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
  if !(self.can_learn(id)) {
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
