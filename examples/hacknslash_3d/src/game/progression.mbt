///|
pub(all) struct LevelUpConfig {
  xp_base : Int
  xp_growth : Int
}

///|
pub fn LevelUpConfig::default() -> LevelUpConfig {
  { xp_base: 10, xp_growth: 6 }
}

///|
pub(all) struct LevelProgression {
  mut level : Int
  mut xp : Int
  mut next_level_xp : Int
  mut pending_choices : Int
  mut current_offers : Array[SkillId]
}

///|
pub fn LevelProgression::new(
  config? : LevelUpConfig = LevelUpConfig::default(),
) -> LevelProgression {
  {
    level: 1,
    xp: 0,
    next_level_xp: config.xp_base,
    pending_choices: 0,
    current_offers: [],
  }
}

///|
fn next_level_xp_for(level : Int, config : LevelUpConfig) -> Int {
  @cmp.maximum(1, config.xp_base + (level - 1) * config.xp_growth)
}

///|
pub fn SkillTree::can_learn_from_levelup(
  self : SkillTree,
  id : SkillId,
) -> Bool {
  match self.find(id) {
    None => false
    Some(node) => {
      if node.level >= node.max_level {
        return false
      }
      for prereq in node.prereqs {
        match self.find(prereq) {
          None => return false
          Some(p) => if p.level == 0 { return false }
        }
      }
      true
    }
  }
}

///|
pub fn SkillTree::available_levelup_skill_ids(
  self : SkillTree,
) -> Array[SkillId] {
  let ids : Array[SkillId] = []
  for node in self.nodes {
    if self.can_learn_from_levelup(node.id) {
      ids.push(node.id)
    }
  }
  ids
}

///|
pub fn SkillTree::learn_from_levelup(self : SkillTree, id : SkillId) -> Bool {
  if not(self.can_learn_from_levelup(id)) {
    return false
  }
  match self.find(id) {
    None => false
    Some(node) => {
      node.level = node.level + 1
      true
    }
  }
}

///|
fn build_levelup_offers(skills : SkillTree, offer_seed : Int) -> Array[SkillId] {
  let available = skills.available_levelup_skill_ids()
  if available.length() == 0 {
    return []
  }
  let len = available.length()
  let start = (offer_seed % len + len) % len
  let offers : Array[SkillId] = []
  let offer_count = @cmp.minimum(3, len)
  for i = 0; i < len; i = i + 1 {
    let candidate = available[(start + i) % len]
    let mut duplicate = false
    for existing in offers {
      if skill_id_eq(existing, candidate) {
        duplicate = true
        break
      }
    }
    if not(duplicate) {
      offers.push(candidate)
      if offers.length() >= offer_count {
        break
      }
    }
  }
  offers
}

///|
pub fn LevelProgression::gain_xp(
  self : LevelProgression,
  skills : SkillTree,
  gained_xp : Int,
  offer_seed : Int,
  config : LevelUpConfig,
) -> Bool {
  if gained_xp <= 0 {
    return false
  }
  self.xp = self.xp + gained_xp
  let mut leveled = false
  while self.xp >= self.next_level_xp {
    self.xp = self.xp - self.next_level_xp
    self.level = self.level + 1
    self.next_level_xp = next_level_xp_for(self.level, config)
    self.pending_choices = self.pending_choices + 1
    leveled = true
  }
  if self.current_offers.length() == 0 && self.pending_choices > 0 {
    self.current_offers = build_levelup_offers(skills, offer_seed + self.level)
    if self.current_offers.length() == 0 {
      self.pending_choices = 0
    }
  }
  leveled
}

///|
pub fn LevelProgression::choose_offer(
  self : LevelProgression,
  skills : SkillTree,
  offer_index : Int,
  offer_seed : Int,
) -> Bool {
  if offer_index < 0 || offer_index >= self.current_offers.length() {
    return false
  }
  let chosen = self.current_offers[offer_index]
  if not(skills.learn_from_levelup(chosen)) {
    return false
  }
  if self.pending_choices > 0 {
    self.pending_choices = self.pending_choices - 1
  }
  self.current_offers = []
  if self.pending_choices > 0 {
    self.current_offers = build_levelup_offers(skills, offer_seed + self.level)
    if self.current_offers.length() == 0 {
      self.pending_choices = 0
    }
  }
  true
}
