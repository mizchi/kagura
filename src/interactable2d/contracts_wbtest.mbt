///|
test "interactable_role_from_string parses known roles" {
  assert_eq(interactable_role_from_string("decoration"), Some(Decoration))
  assert_eq(interactable_role_from_string("blocking"), Some(Blocking))
  assert_eq(interactable_role_from_string("pickup"), Some(Pickup))
  assert_eq(interactable_role_from_string("unknown"), None)
}

///|
test "interactable_anchor_from_string parses known anchors" {
  assert_eq(
    interactable_anchor_from_string("start_room"),
    Some(StartRoomCenter),
  )
  assert_eq(
    interactable_anchor_from_string("largest_non_start_room"),
    Some(LargestNonStartRoomCenter),
  )
  assert_eq(interactable_anchor_from_string("boss_room"), Some(BossRoomCenter))
  assert_eq(
    interactable_anchor_from_string("treasure_room"),
    Some(TreasureRoomCenter),
  )
  assert_eq(interactable_anchor_from_string("unknown"), None)
}

///|
test "interactable_pickup_effect_from_string parses known effects" {
  assert_eq(interactable_pickup_effect_from_string("score"), Some(ScorePickup))
  assert_eq(
    interactable_pickup_effect_from_string("health"),
    Some(HealthPickup),
  )
  assert_eq(
    interactable_pickup_effect_from_string("equipment"),
    Some(EquipmentPickup),
  )
  assert_eq(interactable_pickup_effect_from_string("unknown"), None)
}

///|
test "interactable role helpers classify solid and pickup roles" {
  assert_false(interactable_role_is_solid(Decoration))
  assert_true(interactable_role_is_solid(Blocking))
  assert_false(interactable_role_is_solid(Pickup))
  assert_false(interactable_role_is_pickup(Decoration))
  assert_false(interactable_role_is_pickup(Blocking))
  assert_true(interactable_role_is_pickup(Pickup))
}

///|
test "circular_interactable_can_pickup uses squared radius" {
  assert_true(circular_interactable_can_pickup(32.0, 48.0, 36.0, 48.0, 400.0))
  assert_false(circular_interactable_can_pickup(32.0, 48.0, 64.0, 48.0, 400.0))
}

///|
test "resolve_circular_interactable_block pushes actor out on overlap" {
  let out = resolve_circular_interactable_block(
    32.0, 48.0, 12.0, 32.0, 48.0, 8.0,
  )
  let (px, py) = match out {
    Some(pair) => pair
    None => panic()
  }
  assert_true(px > 32.0)
  assert_eq(py, 48.0)
}
