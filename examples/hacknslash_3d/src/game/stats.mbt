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
  spell_damage_pct : Double // total +% spell damage (legacy)
  chain_bonus : Int // total +chain targets (legacy)
  tag_bonuses : Array[TagBonus] // per-tag bonuses (indexed by skill_tag_to_int)
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
pub fn tag_damage_multiplier(stats : PlayerStats, skill : SkillId) -> Double {
  let tags = skill_tags(skill)
  // damage_pct: take MAX across tags (prevent double-dipping)
  let mut max_damage_pct = 0.0
  // crit_bonus: additive across tags
  let mut _total_crit = 0.0
  for tag in tags {
    let idx = skill_tag_to_int(tag)
    if idx < stats.tag_bonuses.length() {
      let bonus = stats.tag_bonuses[idx]
      if bonus.damage_pct > max_damage_pct {
        max_damage_pct = bonus.damage_pct
      }
      _total_crit = _total_crit + bonus.crit_bonus
    }
  }
  // Also include legacy spell_damage_pct (take max with tag bonus)
  if stats.spell_damage_pct > max_damage_pct {
    max_damage_pct = stats.spell_damage_pct
  }
  1.0 + max_damage_pct
}

///|
pub fn effective_aoe_radius(
  stats : PlayerStats,
  skill : SkillId,
  base_radius : Double,
) -> Double {
  let tags = skill_tags(skill)
  let mut total_aoe_pct = 0.0
  for tag in tags {
    let idx = skill_tag_to_int(tag)
    if idx < stats.tag_bonuses.length() {
      total_aoe_pct = total_aoe_pct + stats.tag_bonuses[idx].aoe_radius_pct
    }
  }
  base_radius * (1.0 + total_aoe_pct)
}

///|
pub fn effective_extra_chain_targets(
  stats : PlayerStats,
  skill : SkillId,
) -> Int {
  let tags = skill_tags(skill)
  let mut total = stats.chain_bonus // legacy
  for tag in tags {
    let idx = skill_tag_to_int(tag)
    if idx < stats.tag_bonuses.length() {
      total = total + stats.tag_bonuses[idx].extra_targets
    }
  }
  total
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
  let tag_mult = tag_damage_multiplier(stats, skill)
  @cmp.maximum(
    1,
    (scaled.to_double() * archetype.skill_damage_multiplier(skill) * level_mult * tag_mult).to_int(),
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
  // Aggregate tag bonuses from equipment affixes and mastery skills
  let tag_bonuses = new_tag_bonuses_array()
  // Collect from equipment affixes
  let equip_items : Array[ItemData?] = [
    equipment.weapon, equipment.armor, equipment.accessory,
  ]
  for opt_item in equip_items {
    match opt_item {
      Some(item) => {
        let affixes : Array[Affix?] = [item.prefix, item.suffix]
        for opt_affix in affixes {
          match opt_affix {
            Some(affix) =>
              for entry in affix.tag_bonuses {
                let idx = skill_tag_to_int(entry.tag)
                tag_bonuses[idx].damage_pct = tag_bonuses[idx].damage_pct +
                  entry.damage_pct
                tag_bonuses[idx].cooldown_reduction = tag_bonuses[idx].cooldown_reduction +
                  entry.cooldown_reduction
                tag_bonuses[idx].extra_targets = tag_bonuses[idx].extra_targets +
                  entry.extra_targets
                tag_bonuses[idx].aoe_radius_pct = tag_bonuses[idx].aoe_radius_pct +
                  entry.aoe_radius_pct
                tag_bonuses[idx].crit_bonus = tag_bonuses[idx].crit_bonus +
                  entry.crit_bonus
              }
            None => ()
          }
        }
      }
      None => ()
    }
  }
  // Convert legacy spell_damage_pct/chain_bonus into tag bonuses
  // (legacy spell_damage_pct stays on PlayerStats for backward compat)
  // Mastery skill bonuses
  let mastery_skills : Array[(SkillId, Int)] = [
    (LightningMastery, skill_tag_to_int(Lightning)),
    (FireMastery, skill_tag_to_int(Fire)),
    (ColdMastery, skill_tag_to_int(Cold)),
    (PhysicalMastery, skill_tag_to_int(Physical)),
    (ProjectileMastery, skill_tag_to_int(Projectile)),
    (AoEMastery, skill_tag_to_int(AoE)),
  ]
  for pair in mastery_skills {
    let (mastery_id, tag_idx) = pair
    let mastery_level = skills.get_level(mastery_id)
    if mastery_level > 0 {
      let per_level_dmg = 0.08 // +8% damage per level
      let per_level_crit = 0.02 // +2% crit per level
      tag_bonuses[tag_idx].damage_pct = tag_bonuses[tag_idx].damage_pct +
        mastery_level.to_double() * per_level_dmg
      tag_bonuses[tag_idx].crit_bonus = tag_bonuses[tag_idx].crit_bonus +
        mastery_level.to_double() * per_level_crit
    }
  }
  // AoE mastery also adds aoe_radius_pct
  let aoe_mastery_level = skills.get_level(AoEMastery)
  if aoe_mastery_level > 0 {
    let aoe_idx = skill_tag_to_int(AoE)
    tag_bonuses[aoe_idx].aoe_radius_pct = tag_bonuses[aoe_idx].aoe_radius_pct +
      aoe_mastery_level.to_double() * 0.10
  }
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
    tag_bonuses,
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
      let targets = chain_lightning_targets_for_level(level) +
        effective_extra_chain_targets(stats, ChainLightning)
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
