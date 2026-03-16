///|
pub(all) enum CharacterArchetype {
  Melee
  Mage
  Summoner
  Ranger
}

///|
pub(all) enum ArchetypeBuildPolicy {
  ArchetypeAligned
  AntiSynergy
}

///|
pub fn default_character_archetype() -> CharacterArchetype {
  Melee
}

///|
pub fn default_archetype_build_policy() -> ArchetypeBuildPolicy {
  ArchetypeAligned
}

///|
pub fn CharacterArchetype::to_string(self : CharacterArchetype) -> String {
  match self {
    Melee => "melee"
    Mage => "mage"
    Summoner => "summoner"
    Ranger => "ranger"
  }
}

///|
pub fn character_archetype_to_string(
  archetype : CharacterArchetype,
) -> String {
  archetype.to_string()
}

///|
pub fn ArchetypeBuildPolicy::to_string(self : ArchetypeBuildPolicy) -> String {
  match self {
    ArchetypeAligned => "aligned"
    AntiSynergy => "anti_synergy"
  }
}

///|
pub fn archetype_build_policy_to_string(
  policy : ArchetypeBuildPolicy,
) -> String {
  policy.to_string()
}

///|
pub fn character_archetype_from_string(name : String) -> CharacterArchetype? {
  match name {
    "melee" | "str" | "warrior" => Some(Melee)
    "mage" | "int" | "magic" => Some(Mage)
    "summoner" | "summon" => Some(Summoner)
    "ranger" | "dex" | "ranged" => Some(Ranger)
    _ => None
  }
}

///|
pub fn archetype_build_policy_from_string(
  name : String,
) -> ArchetypeBuildPolicy? {
  match name {
    "" | "aligned" | "archetype_aligned" | "default" => Some(
      ArchetypeAligned,
    )
    "anti_synergy" | "anti-synergy" | "antisynergy" | "offspec" | "mismatch" => Some(
      AntiSynergy,
    )
    _ => None
  }
}

///|
pub fn CharacterArchetype::base_strength(self : CharacterArchetype) -> Int {
  match self {
    Melee => 14
    Mage => 8
    Summoner => 8
    Ranger => 8
  }
}

///|
pub fn CharacterArchetype::base_intelligence(
  self : CharacterArchetype,
) -> Int {
  match self {
    Melee => 8
    Mage => 12
    Summoner => 14
    Ranger => 8
  }
}

///|
pub fn CharacterArchetype::base_dexterity(self : CharacterArchetype) -> Int {
  match self {
    Melee => 8
    Mage => 8
    Summoner => 10
    Ranger => 14
  }
}

///|
pub fn CharacterArchetype::hp_modifier(self : CharacterArchetype) -> Int {
  match self {
    Melee => 2
    Mage => -3
    Summoner => 0
    Ranger => 0
  }
}

///|
pub fn CharacterArchetype::speed_modifier(self : CharacterArchetype) -> Double {
  match self {
    Melee => 1.0
    Mage => 0.8 // slower = harder to kite, glass cannon trade-off
    Summoner => 0.95
    Ranger => 1.0
  }
}

///|
pub fn CharacterArchetype::starting_skill_ids(
  self : CharacterArchetype,
) -> Array[SkillId] {
  match self {
    Melee => [PowerStrike]
    Mage => [ChainLightning]
    Summoner => [HomingMissile]
    Ranger => [CriticalHit]
  }
}

///|
/// Skills available to each archetype. Skills not in this list cannot be learned.
pub fn CharacterArchetype::allowed_skills(
  self : CharacterArchetype,
) -> Array[SkillId] {
  match self {
    Melee => [PowerStrike, Whirlwind, DashMastery, Vitality, CriticalHit, LifeSteal, Counter, PhysicalMastery, AoEMastery]
    Mage => [ChainLightning, SplittingFireball, IceNova, DashMastery, Vitality, HomingMissile, LightningMastery, FireMastery, ColdMastery]
    Summoner => [HomingMissile, IceNova, ChainLightning, DashMastery, Vitality, LifeSteal, ProjectileMastery, ColdMastery]
    Ranger => [CriticalHit, DashMastery, Vitality, LifeSteal, PowerStrike, HomingMissile, ProjectileMastery, PhysicalMastery]
  }
}

///|
pub fn CharacterArchetype::can_learn_skill(
  self : CharacterArchetype,
  id : SkillId,
) -> Bool {
  for skill in self.allowed_skills() {
    if skill == id {
      return true
    }
  }
  false
}

///|
pub fn CharacterArchetype::offer_priority(
  self : CharacterArchetype,
  id : SkillId,
) -> Int {
  match self {
    Melee => match id {
      PowerStrike => 0
      Counter => 1
      Whirlwind => 2
      PhysicalMastery => 3
      AoEMastery => 4
      Vitality => 5
      CriticalHit => 6
      LifeSteal => 7
      DashMastery => 8
      HomingMissile => 9
      ChainLightning => 10
      IceNova => 11
      SplittingFireball => 12
      _ => 20
    }
    Mage => match id {
      ChainLightning => 0
      SplittingFireball => 1
      IceNova => 2
      LightningMastery => 3
      FireMastery => 4
      ColdMastery => 5
      Vitality => 6
      DashMastery => 7
      HomingMissile => 8
      CriticalHit => 9
      LifeSteal => 10
      PowerStrike => 11
      Whirlwind => 12
      Counter => 13
      _ => 20
    }
    Summoner => match id {
      HomingMissile => 0
      IceNova => 1
      ProjectileMastery => 2
      ColdMastery => 3
      Vitality => 4
      DashMastery => 5
      ChainLightning => 6
      LifeSteal => 7
      SplittingFireball => 8
      CriticalHit => 9
      PowerStrike => 10
      Whirlwind => 11
      Counter => 12
      _ => 20
    }
    Ranger => match id {
      CriticalHit => 0
      DashMastery => 1
      ProjectileMastery => 2
      PhysicalMastery => 3
      Vitality => 4
      LifeSteal => 5
      HomingMissile => 6
      PowerStrike => 7
      ChainLightning => 8
      SplittingFireball => 9
      IceNova => 10
      Whirlwind => 11
      Counter => 12
      _ => 20
    }
  }
}

///|
pub fn CharacterArchetype::offer_priority_with_policy(
  self : CharacterArchetype,
  policy : ArchetypeBuildPolicy,
  id : SkillId,
) -> Int {
  let aligned = self.offer_priority(id)
  match policy {
    ArchetypeAligned => aligned
    AntiSynergy => 100 - aligned
  }
}

///|
pub fn CharacterArchetype::basic_attack_multiplier(
  self : CharacterArchetype,
) -> Double {
  match self {
    Melee => 1.0
    Mage => 0.65
    Summoner => 0.9
    Ranger => 1.35
  }
}

///|
pub fn CharacterArchetype::skill_damage_multiplier(
  self : CharacterArchetype,
  id : SkillId,
) -> Double {
  match self {
    Melee => match id {
      PowerStrike | Whirlwind | Counter => 1.35
      ChainLightning | SplittingFireball | IceNova => 0.7
      HomingMissile => 0.8
      LightningMastery | FireMastery | ColdMastery | PhysicalMastery |
      ProjectileMastery | AoEMastery => 1.0
      _ => 1.0
    }
    Mage => match id {
      ChainLightning => 0.85
      SplittingFireball | IceNova => 1.0
      HomingMissile => 0.65
      PowerStrike | Whirlwind => 0.55
      LightningMastery | FireMastery | ColdMastery | PhysicalMastery |
      ProjectileMastery | AoEMastery => 1.0
      _ => 1.0
    }
    Summoner => match id {
      HomingMissile => 1.4
      ChainLightning | SplittingFireball => 0.8
      PowerStrike | Whirlwind => 0.7
      LightningMastery | FireMastery | ColdMastery | PhysicalMastery |
      ProjectileMastery | AoEMastery => 1.0
      _ => 1.0
    }
    Ranger => match id {
      HomingMissile => 1.05
      ChainLightning | SplittingFireball | IceNova => 0.75
      PowerStrike | Whirlwind => 0.85
      LightningMastery | FireMastery | ColdMastery | PhysicalMastery |
      ProjectileMastery | AoEMastery => 1.0
      _ => 1.0
    }
  }
}

///|
pub fn selectable_archetypes() -> Array[CharacterArchetype] {
  [Melee, Mage, Ranger]
}

///|
pub fn CharacterArchetype::display_name(self : CharacterArchetype) -> String {
  match self {
    Melee => "WARRIOR"
    Mage => "MAGE"
    Summoner => "SUMMONER"
    Ranger => "RANGER"
  }
}

///|
pub fn CharacterArchetype::display_description(
  self : CharacterArchetype,
) -> String {
  match self {
    Melee => "STR-focused melee fighter"
    Mage => "INT-focused spell caster"
    Summoner => "INT/DEX balanced summoner"
    Ranger => "DEX-focused ranged attacker"
  }
}

///|
pub fn CharacterArchetype::anti_synergy_target(
  self : CharacterArchetype,
) -> CharacterArchetype {
  match self {
    Melee => Mage
    Mage => Melee
    Summoner => Melee
    Ranger => Mage
  }
}
