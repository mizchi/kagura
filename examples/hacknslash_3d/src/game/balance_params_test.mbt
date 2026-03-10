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
    affix_profile: 0,
  }
  let clamped = extreme.clamp()
  assert_true(clamped.player_speed <= 5.0)
  assert_true(clamped.enemy_speed_basic >= 0.2)
  assert_true(clamped.enemy_contact_damage >= 1.0)
  assert_true(clamped.player_base_hp >= 3.0)
  assert_true(clamped.spawn_density >= 0.5)
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
