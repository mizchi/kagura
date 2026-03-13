///|
pub type LevelUpConfig = @progression.LevelUpConfig

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
  let core = @progression.LevelProgression::new(config~)
  {
    level: core.level,
    xp: core.xp,
    next_level_xp: core.next_level_xp,
    pending_choices: core.pending_choices,
    current_offers: [],
  }
}

///|
fn next_level_xp_for(level : Int, config : LevelUpConfig) -> Int {
  @progression.next_level_xp_for(level, config)
}

///|
fn LevelProgression::to_core(
  self : LevelProgression,
) -> @progression.LevelProgression {
  {
    level: self.level,
    xp: self.xp,
    next_level_xp: self.next_level_xp,
    pending_choices: self.pending_choices,
  }
}

///|
fn LevelProgression::sync_from_core(
  self : LevelProgression,
  core : @progression.LevelProgression,
) -> Unit {
  self.level = core.level
  self.xp = core.xp
  self.next_level_xp = core.next_level_xp
  self.pending_choices = core.pending_choices
}

///|
pub fn SkillTree::can_learn_from_levelup(
  self : SkillTree,
  id : SkillId,
) -> Bool {
  let index = self.find_index(id)
  if index < 0 {
    return false
  }
  let node = self.nodes[index]
  if node.level >= node.max_level {
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
  let index = self.find_index(id)
  if index < 0 {
    return false
  }
  self.nodes[index].level = self.nodes[index].level + 1
  true
}

///|
fn build_levelup_offers(
  skills : SkillTree,
  archetype : CharacterArchetype,
  build_policy : ArchetypeBuildPolicy,
  offer_seed : Int,
) -> Array[SkillId] {
  let available = skills.available_levelup_skill_ids()
  if available.length() == 0 {
    return []
  }
  let ordered : Array[SkillId] = []
  for priority = 0; priority < 128; priority = priority + 1 {
    for candidate in available {
      if archetype.offer_priority_with_policy(build_policy, candidate) == priority {
        ordered.push(candidate)
      }
    }
  }
  if ordered.length() == 0 {
    return []
  }
  let len = ordered.length()
  let offset = ((offer_seed % len) + len) % len
  let offers : Array[SkillId] = []
  let offer_count = @cmp.minimum(3, len)
  for i = 0; i < offer_count; i = i + 1 {
    offers.push(ordered[(offset + i) % len])
  }
  offers
}

///|
pub fn LevelProgression::gain_xp(
  self : LevelProgression,
  skills : SkillTree,
  archetype : CharacterArchetype,
  build_policy : ArchetypeBuildPolicy,
  gained_xp : Int,
  offer_seed : Int,
  config : LevelUpConfig,
) -> Bool {
  let core = self.to_core()
  let leveled = core.gain_xp(gained_xp, config)
  self.sync_from_core(core)
  if self.current_offers.length() == 0 && self.pending_choices > 0 {
    self.current_offers = build_levelup_offers(
      skills,
      archetype,
      build_policy,
      offer_seed + self.level,
    )
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
  archetype : CharacterArchetype,
  build_policy : ArchetypeBuildPolicy,
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
  let core = self.to_core()
  ignore(core.consume_choice())
  self.sync_from_core(core)
  self.current_offers = []
  if self.pending_choices > 0 {
    self.current_offers = build_levelup_offers(
      skills,
      archetype,
      build_policy,
      offer_seed + self.level,
    )
    if self.current_offers.length() == 0 {
      self.pending_choices = 0
    }
  }
  true
}
