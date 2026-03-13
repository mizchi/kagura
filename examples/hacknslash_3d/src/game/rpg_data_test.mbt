///|
fn mk_affix(
  name : String,
  atk? : Int = 0,
  def? : Int = 0,
  hp? : Int = 0,
  crit? : Double = 0.0,
  ls? : Double = 0.0,
  spd? : Double = 0.0,
  cdr? : Double = 0.0,
) -> Affix {
  {
    name,
    atk,
    def,
    hp,
    crit,
    life_steal: ls,
    speed_bonus: spd,
    cooldown_reduction: cdr,
  }
}

///|
test "affix struct fields" {
  let affix = mk_affix(
    "Test",
    atk=3,
    def=1,
    hp=2,
    crit=0.05,
    ls=0.1,
    spd=0.15,
    cdr=0.2,
  )
  assert_eq(affix.name, "Test")
  assert_eq(affix.atk, 3)
  assert_eq(affix.def, 1)
  assert_eq(affix.hp, 2)
  assert_true((affix.crit - 0.05).abs() < 0.001)
  assert_true((affix.life_steal - 0.1).abs() < 0.001)
  assert_true((affix.speed_bonus - 0.15).abs() < 0.001)
  assert_true((affix.cooldown_reduction - 0.2).abs() < 0.001)
}

///|
test "prefix_table_for returns 10+ entries for each profile" {
  let profiles : Array[AffixProfile] = [
    Classic,
    GlassCannon,
    Tank,
    Mobility,
    Expanded,
  ]
  for profile in profiles {
    let prefixes = prefix_table_for(profile)
    assert_true(prefixes.length() >= 10)
  }
}

///|
test "suffix_table_for returns 10+ entries for each profile" {
  let profiles : Array[AffixProfile] = [
    Classic,
    GlassCannon,
    Tank,
    Mobility,
    Expanded,
  ]
  for profile in profiles {
    let suffixes = suffix_table_for(profile)
    assert_true(suffixes.length() >= 10)
  }
}

///|
test "mobility profile has speed_bonus affixes" {
  let prefixes = prefix_table_for(Mobility)
  let mut has_speed = false
  for p in prefixes {
    if p.speed_bonus > 0.0 {
      has_speed = true
      break
    }
  }
  assert_true(has_speed)
}

///|
test "mobility profile has cooldown_reduction affixes" {
  let suffixes = suffix_table_for(Mobility)
  let mut has_cdr = false
  for s in suffixes {
    if s.cooldown_reduction > 0.0 {
      has_cdr = true
      break
    }
  }
  assert_true(has_cdr)
}

///|
test "classic profile has no speed_bonus or cooldown_reduction" {
  let prefixes = prefix_table_for(Classic)
  let suffixes = suffix_table_for(Classic)
  for p in prefixes {
    assert_true(p.speed_bonus < 0.001)
    assert_true(p.cooldown_reduction < 0.001)
  }
  for s in suffixes {
    assert_true(s.speed_bonus < 0.001)
    assert_true(s.cooldown_reduction < 0.001)
  }
}

///|
test "generate_item deterministic" {
  let item1 = generate_item(42, 3)
  let item2 = generate_item(42, 3)
  assert_eq(item1.name, item2.name)
  assert_eq(item1.atk_bonus, item2.atk_bonus)
  assert_eq(item1.def_bonus, item2.def_bonus)
}

///|
test "generate_item_with_profile uses correct tables" {
  let classic = generate_item_with_profile(1000, 5, Classic)
  let glass = generate_item_with_profile(1000, 5, GlassCannon)
  assert_true(classic.name.length() > 0)
  assert_true(glass.name.length() > 0)
}

///|
test "scale_affix preserves speed_bonus and cooldown_reduction" {
  let affix = mk_affix("Swift", spd=0.15, cdr=0.1, atk=2)
  let scaled = scale_affix(affix, 10)
  // atk scales: 2 * (1 + 10/5) = 6
  assert_eq(scaled.atk, 6)
  assert_true((scaled.speed_bonus - 0.15).abs() < 0.001)
  assert_true((scaled.cooldown_reduction - 0.1).abs() < 0.001)
}

///|
test "equipment speed_bonus and cooldown_reduction aggregate" {
  let equip = Equipment::new()
  let weapon : ItemData = {
    name: "Sword",
    rarity: Rare,
    slot: Weapon,
    atk_bonus: 5,
    def_bonus: 0,
    hp_bonus: 0,
    prefix: Some(mk_affix("Swift", spd=0.15, atk=1)),
    suffix: Some(mk_affix("of Alacrity", cdr=0.2)),
    icon_id: 0,
  }
  let armor : ItemData = {
    name: "Armor",
    rarity: Uncommon,
    slot: Armor,
    atk_bonus: 0,
    def_bonus: 3,
    hp_bonus: 2,
    prefix: Some(mk_affix("Hasty", spd=0.1, cdr=0.1)),
    suffix: None,
    icon_id: 1,
  }
  equip.equip(weapon) |> ignore
  equip.equip(armor) |> ignore
  assert_true((equip.total_speed_bonus() - 0.25).abs() < 0.001)
  assert_true((equip.total_cooldown_reduction() - 0.3).abs() < 0.001)
}

///|
test "compute_player_stats with custom base_hp" {
  let equip = Equipment::new()
  let skills = SkillTree::new()
  let stats_default = compute_player_stats(equip, skills)
  let stats_custom = compute_player_stats(equip, skills, base_hp=20)
  assert_eq(stats_default.max_hp, 10)
  assert_eq(stats_custom.max_hp, 20)
}

///|
test "compute_player_stats includes speed_bonus and cooldown_reduction" {
  let equip = Equipment::new()
  let weapon : ItemData = {
    name: "Sword",
    rarity: Rare,
    slot: Weapon,
    atk_bonus: 5,
    def_bonus: 0,
    hp_bonus: 0,
    prefix: Some(mk_affix("Swift", spd=0.15)),
    suffix: Some(mk_affix("of Tempo", cdr=0.12)),
    icon_id: 0,
  }
  equip.equip(weapon) |> ignore
  let skills = SkillTree::new()
  let stats = compute_player_stats(equip, skills)
  assert_true((stats.speed_bonus - 0.15).abs() < 0.001)
  assert_true((stats.cooldown_reduction - 0.12).abs() < 0.001)
}

///|
test "inventory add_fifo keeps newest items when capacity is full" {
  let inv = Inventory::new(2)
  ignore(
    inv.add_fifo({
      name: "Oldest",
      rarity: Common,
      slot: Weapon,
      atk_bonus: 1,
      def_bonus: 0,
      hp_bonus: 0,
      prefix: None,
      suffix: None,
      icon_id: 0,
    }),
  )
  ignore(
    inv.add_fifo({
      name: "Middle",
      rarity: Common,
      slot: Weapon,
      atk_bonus: 2,
      def_bonus: 0,
      hp_bonus: 0,
      prefix: None,
      suffix: None,
      icon_id: 1,
    }),
  )
  let dropped = inv.add_fifo({
    name: "Newest",
    rarity: Common,
    slot: Weapon,
    atk_bonus: 3,
    def_bonus: 0,
    hp_bonus: 0,
    prefix: None,
    suffix: None,
    icon_id: 2,
  })
  let dropped_name = match dropped {
    Some(item) => item.name
    None => panic()
  }
  assert_eq(dropped_name, "Oldest")
  let first = match inv.items[0] {
    Some(item) => item.name
    None => panic()
  }
  let second = match inv.items[1] {
    Some(item) => item.name
    None => panic()
  }
  assert_eq(first, "Middle")
  assert_eq(second, "Newest")
}

///|
test "available_levelup_skill_ids excludes locked and maxed skills" {
  let skills = SkillTree::new()
  let offers0 = skills.available_levelup_skill_ids()
  assert_eq(offers0.length(), 7)
  assert_true(contains_skill_id(offers0, PowerStrike))
  assert_true(contains_skill_id(offers0, DashMastery))
  assert_true(contains_skill_id(offers0, Vitality))
  assert_true(contains_skill_id(offers0, ChainLightning))
  assert_true(contains_skill_id(offers0, SplittingFireball))
  assert_true(contains_skill_id(offers0, IceNova))
  assert_true(contains_skill_id(offers0, HomingMissile))
  assert_false(contains_skill_id(offers0, Whirlwind))
  skills.learn_from_levelup(Vitality) |> ignore
  skills.learn_from_levelup(PowerStrike) |> ignore
  let offers1 = skills.available_levelup_skill_ids()
  assert_true(contains_skill_id(offers1, Whirlwind))
  assert_true(contains_skill_id(offers1, CriticalHit))
}

///|
test "level_progression gain_xp creates three offers and choosing one learns it" {
  let skills = SkillTree::new()
  let progress = LevelProgression::new()
  let config = LevelUpConfig::default()
  let leveled = progress.gain_xp(skills, 12, 17, config)
  assert_true(leveled)
  assert_eq(progress.level, 2)
  assert_eq(progress.pending_choices, 1)
  assert_eq(progress.current_offers.length(), 3)
  let chosen = progress.current_offers[1]
  assert_true(progress.choose_offer(skills, 1, 33))
  assert_eq(skills.get_level(chosen), 1)
  assert_eq(progress.pending_choices, 0)
  assert_eq(progress.current_offers.length(), 0)
}

///|
test "generate_item_with_profile_and_drop_config applies slot weights" {
  let config : DropTableConfig = {
    ..DropTableConfig::default(),
    weapon_weight: 100,
    armor_weight: 0,
    accessory_weight: 0,
  }
  let item = generate_item_with_profile_and_drop_config(42, 5, Classic, config)
  match item.slot {
    Weapon => ()
    _ => fail("expected weapon slot")
  }
}

///|
test "roll_item_rarity becomes stronger with floor bias" {
  let config : DropTableConfig = {
    ..DropTableConfig::default(),
    rarity_bonus_per_floor: 4.0,
  }
  let low = roll_item_rarity(123, 1, config)
  let high = roll_item_rarity(123, 12, config)
  assert_true(item_rarity_rank(high) >= item_rarity_rank(low))
}

///|
test "generate_item_with_profile_and_drop_config scales base and affix tiers by floor" {
  let config : DropTableConfig = {
    ..DropTableConfig::default(),
    base_item_tier_base: 1,
    base_item_tier_per_floor: 0.5,
    prefix_tier_base: 1,
    prefix_tier_per_floor: 0.4,
    suffix_tier_base: 1,
    suffix_tier_per_floor: 0.4,
    modifier_tier_base: 1,
    modifier_tier_per_floor: 0.3,
    rarity_bonus_per_floor: 6.0,
  }
  let low = generate_item_with_profile_and_drop_config(123, 2, Expanded, config)
  let high = generate_item_with_profile_and_drop_config(123, 12, Expanded, config)
  assert_true(high.total_stat_score() >= low.total_stat_score())
}

///|
fn contains_skill_id(ids : Array[SkillId], id : SkillId) -> Bool {
  for current in ids {
    if skill_id_eq(current, id) {
      return true
    }
  }
  false
}

///|
test "equipment should_equip compares total stat score across matching slot" {
  let equip = Equipment::new()
  ignore(
    equip.equip({
      name: "Bronze Charm",
      rarity: Common,
      slot: Accessory,
      atk_bonus: 0,
      def_bonus: 0,
      hp_bonus: 3,
      prefix: None,
      suffix: None,
      icon_id: 0,
    }),
  )
  let better : ItemData = {
    name: "Crit Charm",
    rarity: Common,
    slot: Accessory,
    atk_bonus: 0,
    def_bonus: 0,
    hp_bonus: 0,
    prefix: Some(mk_affix("Sharp", crit=0.08)),
    suffix: None,
    icon_id: 1,
  }
  assert_true(equip.should_equip(better))
}
