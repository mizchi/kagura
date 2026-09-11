///|
test "parse_interactable_role parses known roles" {
  assert_eq(parse_interactable_role("decoration"), Some(Decoration))
  assert_eq(parse_interactable_role("blocking"), Some(Blocking))
  assert_eq(parse_interactable_role("pickup"), Some(Pickup))
  assert_eq(parse_interactable_role("unknown"), None)
}

///|
test "parse_interactable_anchor parses known anchors" {
  assert_eq(parse_interactable_anchor("start_room"), Some(StartRoomCenter))
  assert_eq(
    parse_interactable_anchor("largest_non_start_room"),
    Some(LargestNonStartRoomCenter),
  )
  assert_eq(parse_interactable_anchor("boss_room"), Some(BossRoomCenter))
  assert_eq(
    parse_interactable_anchor("treasure_room"),
    Some(TreasureRoomCenter),
  )
  assert_eq(parse_interactable_anchor("unknown"), None)
}

///|
test "parse_interactable_pickup_effect parses known effects" {
  assert_eq(parse_interactable_pickup_effect("score"), Some(ScorePickup))
  assert_eq(parse_interactable_pickup_effect("health"), Some(HealthPickup))
  assert_eq(
    parse_interactable_pickup_effect("equipment"),
    Some(EquipmentPickup),
  )
  assert_eq(parse_interactable_pickup_effect("unknown"), None)
}

///|
test "interactable role helpers classify solid and pickup roles" {
  assert_false(interactable_role_blocks_movement(Decoration))
  assert_true(interactable_role_blocks_movement(Blocking))
  assert_false(interactable_role_blocks_movement(Pickup))
  assert_false(interactable_role_is_pickup(Decoration))
  assert_false(interactable_role_is_pickup(Blocking))
  assert_true(interactable_role_is_pickup(Pickup))
}

///|
test "is_circular_pickup_in_range uses squared radius" {
  assert_true(is_circular_pickup_in_range(32.0, 48.0, 36.0, 48.0, 400.0))
  assert_false(is_circular_pickup_in_range(32.0, 48.0, 64.0, 48.0, 400.0))
}

///|
test "resolve_circular_blocker_overlap pushes actor out on overlap" {
  let out = resolve_circular_blocker_overlap(32.0, 48.0, 12.0, 32.0, 48.0, 8.0)
  let (px, py) = match out {
    Some(pair) => pair
    None => panic()
  }
  assert_true(px > 32.0)
  assert_eq(py, 48.0)
}
