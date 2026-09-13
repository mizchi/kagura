///|
/// The woodland hunter can combine all paths; legacy archetype rules remain available.
pub fn GameWorld::skill_allowed(self : GameWorld, id : SkillId) -> Bool {
  self.hunting_grounds || self.archetype.can_learn_skill(id)
}

///|
pub fn counter_cooldown_for_level(level : Int) -> Int {
  counter_cooldown_frames - (level - 1).max(0).min(2) * 30
}

///|
/// Spend a point through the same rule used by both web and native menus.
pub fn GameWorld::allocate_skill(self : GameWorld, id : SkillId) -> Bool {
  if self.mode != Playing ||
    self.ui_mode != Skills ||
    !self.skill_allowed(id) ||
    !self.skills.learn(id) {
    return false
  }
  self.refresh_player_stats()
  // A pause submenu can spend points while a level reward is waiting.
  // Rebuild those offers so a newly maxed skill never blocks that reward.
  if self.level_progress.pending_choices > 0 {
    self.level_progress.current_offers = build_level_up_offers(
      self.skills,
      self.archetype,
      self.build_policy,
      self.frame_count + self.level_progress.level,
    )
    if self.level_progress.current_offers.is_empty() {
      self.level_progress.pending_choices = 0
    }
  }
  true
}
