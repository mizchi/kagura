///|
test "balance_param_count matches to_array length" {
  let params = BalanceParams::default()
  assert_eq(params.to_array().length(), balance_param_count)
}

///|
test "to_array/from_array roundtrip" {
  let params = BalanceParams::default()
  let arr = params.to_array()
  let restored = BalanceParams::from_array(arr)
  let arr2 = restored.to_array()
  for i = 0; i < arr.length(); i = i + 1 {
    assert_true((arr[i] - arr2[i]).abs() < 0.0001)
  }
}

///|
test "param_names matches param count" {
  assert_eq(BalanceParams::param_names().length(), balance_param_count)
}

///|
test "clamp enforces bounds" {
  let extreme : BalanceParams = {
    player_speed: 100.0,
    enemy_speed_basic: -1.0,
    enemy_speed_fast: 0.0,
    enemy_speed_tank: 0.0,
    attack_cooldown: 0.0,
    arrow_speed: 0.0,
    arrow_range: 0.0,
    bow_cooldown: 0.0,
    chase_range: 0.0,
    knockback_strength: 0.0,
    iframe_duration: 0.0,
    dash_duration: 0.0,
    dash_cooldown: 0.0,
    dash_speed_mult: 0.0,
    basic_hp: 0.0,
    fast_hp: 0.0,
    tank_hp: 0.0,
    ranged_hp: 0.0,
    boss_hp_base: 0.0,
    boss_hp_per_floor: 0.0,
    enemy_contact_damage: 0.0,
    player_base_hp: 0.0,
    spawn_density: 0.0,
    spell_cooldown_mult: 0.0,
    spell_damage_mult: 0.0,
    enemy_bolt_damage: 0.0,
    ranged_shot_cooldown: 0.0,
    levelup_xp_base: 0.0,
    levelup_xp_growth: -10.0,
    drop_equipment_weight: -1.0,
    drop_health_weight: -1.0,
    drop_score_weight: -1.0,
    drop_weapon_weight: -1.0,
    drop_armor_weight: -1.0,
    drop_accessory_weight: -1.0,
    item_rarity_bonus_per_floor: -1.0,
    item_base_tier_per_floor: -1.0,
    item_prefix_tier_per_floor: -1.0,
    item_suffix_tier_per_floor: -1.0,
    item_modifier_tier_per_floor: -1.0,
    map_room_count_scale: 0.0,
    map_room_size_scale: 0.0,
    map_corridor_width_bonus: -1.0,
    pack_large_room_bonus: -1.0,
    enemy_hp_floor_scale: -1.0,
    enemy_speed_floor_scale: -1.0,
    enemy_damage_floor_scale: -1.0,
    affix_profile: 0,
  }
  let clamped = extreme.clamp()
  assert_true(clamped.player_speed <= 5.0)
  assert_true(clamped.enemy_speed_basic >= 0.2)
  assert_true(clamped.enemy_contact_damage >= 1.0)
  assert_true(clamped.player_base_hp >= 3.0)
  assert_true(clamped.spawn_density >= 0.5)
  assert_true(clamped.spell_cooldown_mult >= 0.5)
  assert_true(clamped.spell_damage_mult >= 0.3)
  assert_true(clamped.enemy_bolt_damage >= 1.0)
  assert_true(clamped.ranged_shot_cooldown >= 20.0)
  assert_true(clamped.levelup_xp_base >= 1.0)
  assert_true(clamped.drop_equipment_weight >= 0.0)
  assert_true(clamped.item_base_tier_per_floor >= 0.0)
  assert_true(clamped.map_room_count_scale >= 0.75)
  assert_true(clamped.enemy_hp_floor_scale >= 0.0)
}

///|
test "get_affix_profile mapping" {
  let params = BalanceParams::default()
  assert_true(
    match { ..params, affix_profile: 0 }.get_affix_profile() {
      Classic => true
      _ => false
    },
  )
  assert_true(
    match { ..params, affix_profile: 1 }.get_affix_profile() {
      GlassCannon => true
      _ => false
    },
  )
  assert_true(
    match { ..params, affix_profile: 2 }.get_affix_profile() {
      Tank => true
      _ => false
    },
  )
  assert_true(
    match { ..params, affix_profile: 3 }.get_affix_profile() {
      Mobility => true
      _ => false
    },
  )
  assert_true(
    match { ..params, affix_profile: 4 }.get_affix_profile() {
      Expanded => true
      _ => false
    },
  )
  assert_true(
    match { ..params, affix_profile: 99 }.get_affix_profile() {
      Classic => true
      _ => false
    },
  )
}

///|
test "spell cooldown and damage helpers apply global multipliers" {
  let params = {
    ..BalanceParams::default(),
    spell_cooldown_mult: 1.5,
    spell_damage_mult: 0.5,
  }
  assert_eq(params.chain_lightning_cooldown_frames(), 48)
  assert_eq(params.splitting_fireball_cooldown_frames(), 60)
  assert_eq(params.ice_nova_cooldown_frames(), 72)
  assert_eq(params.homing_missile_cooldown_frames(), 81)
  assert_eq(params.scale_spell_damage(9), 4)
}

///|
test "enemy ranged pressure helpers apply parameter values" {
  let params = {
    ..BalanceParams::default(),
    enemy_bolt_damage: 3.8,
    ranged_shot_cooldown: 45.0,
  }
  assert_eq(params.enemy_bolt_damage_int(), 3)
  assert_eq(params.ranged_shot_cooldown_frames(), 45)
}

///|
test "levelup and drop table configs follow tuned parameters" {
  let params = {
    ..BalanceParams::default(),
    levelup_xp_base: 18.0,
    levelup_xp_growth: 7.0,
    drop_equipment_weight: 40.0,
    drop_health_weight: 20.0,
    drop_score_weight: 10.0,
    drop_weapon_weight: 6.0,
    drop_armor_weight: 3.0,
    drop_accessory_weight: 1.0,
    item_rarity_bonus_per_floor: 2.5,
    item_base_tier_per_floor: 0.4,
    item_prefix_tier_per_floor: 0.3,
    item_suffix_tier_per_floor: 0.2,
    item_modifier_tier_per_floor: 0.1,
  }
  let levelup = params.levelup_config()
  assert_eq(levelup.xp_base, 18)
  assert_eq(levelup.xp_growth, 7)
  let drop = params.drop_table_config()
  assert_eq(drop.equipment_weight, 40)
  assert_eq(drop.health_weight, 20)
  assert_eq(drop.score_weight, 10)
  assert_eq(drop.weapon_weight, 6)
  assert_eq(drop.armor_weight, 3)
  assert_eq(drop.accessory_weight, 1)
  assert_true((drop.rarity_bonus_per_floor - 2.5).abs() < 0.001)
  assert_true((drop.base_item_tier_per_floor - 0.4).abs() < 0.001)
  assert_true((drop.prefix_tier_per_floor - 0.3).abs() < 0.001)
  assert_true((drop.suffix_tier_per_floor - 0.2).abs() < 0.001)
  assert_true((drop.modifier_tier_per_floor - 0.1).abs() < 0.001)
}

///|
test "enemy floor scaling helpers increase pressure on deeper floors" {
  let params = {
    ..BalanceParams::default(),
    enemy_hp_floor_scale: 0.2,
    enemy_speed_floor_scale: 0.05,
    enemy_damage_floor_scale: 0.15,
  }
  assert_eq(params.scale_enemy_hp_for_floor(10, 1), 10)
  assert_eq(params.scale_enemy_hp_for_floor(10, 4), 16)
  assert_true((params.scale_enemy_speed_for_floor(1.0, 5) - 1.2).abs() < 0.001)
  assert_eq(params.scale_enemy_damage_for_floor(2, 5), 3)
}

///|
test "map exploration helpers expose broader room and pack tuning" {
  let params = {
    ..BalanceParams::default(),
    map_room_count_scale: 1.4,
    map_room_size_scale: 1.3,
    map_corridor_width_bonus: 1.0,
    pack_large_room_bonus: 0.75,
  }
  assert_true((params.map_room_count_scale - 1.4).abs() < 0.001)
  assert_true((params.map_room_size_scale - 1.3).abs() < 0.001)
  assert_true((params.map_corridor_width_bonus - 1.0).abs() < 0.001)
  assert_true((params.pack_large_room_bonus - 0.75).abs() < 0.001)
}

///|
test "balance preset parser maps known names" {
  assert_true(
    match balance_preset_from_name("build_diverse_hackslash") {
      BuildDiverseHackSlash => true
      _ => false
    },
  )
  assert_true(
    match balance_preset_from_name("mechanics_roguelike_v2") {
      MechanicsRoguelike => true
      _ => false
    },
  )
  assert_true(
    match balance_preset_from_name("unknown") {
      Default => true
      _ => false
    },
  )
}

///|
test "balance presets expose distinct gameplay priorities" {
  let build_diverse = BalanceParams::from_preset(
    balance_preset_from_name("build_diverse_hackslash"),
  )
  let mechanics = BalanceParams::from_preset(
    balance_preset_from_name("mechanics_roguelike_v2"),
  )

  assert_true(build_diverse.player_speed > mechanics.player_speed)
  assert_true(build_diverse.map_room_size_scale > mechanics.map_room_size_scale)
  assert_true(build_diverse.arrow_range < mechanics.arrow_range)
  assert_true(
    build_diverse.pack_large_room_bonus < mechanics.pack_large_room_bonus,
  )
  assert_true(mechanics.enemy_bolt_damage > build_diverse.enemy_bolt_damage)
  assert_true(
    mechanics.item_rarity_bonus_per_floor >
    build_diverse.item_rarity_bonus_per_floor,
  )
}
