///|
test "starter appearance follows equipment identity independently of rarity" {
  let mage = @game.GameWorld::new(
    seed=42,
    archetype=@game.Mage,
    hunting_grounds=true,
  )
  let ranger = @game.GameWorld::new(
    seed=42,
    archetype=@game.Ranger,
    hunting_grounds=true,
  )
  assert_true(
    CharacterOutfit::from_equipment(mage.equipment).style(@game.Helmet) ==
    Some(Occult),
  )
  assert_true(
    CharacterOutfit::from_equipment(ranger.equipment).style(@game.Helmet) ==
    Some(Leather),
  )
  assert_eq(
    CharacterOutfit::from_equipment(mage.equipment).key(),
    equipment_appearance_key(mage.equipment),
  )
  assert_false(
    equipment_appearance_key(mage.equipment) ==
    equipment_appearance_key(ranger.equipment),
  )
}

///|
test "selection describes the actual starting items and save round trip keeps their appearance" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.CharacterSelect
  let builds = s.starting_build_views()
  assert_eq(builds[1].name, "魔法使い")
  assert_eq(builds[1].weapon, @game.Focus.profile().name)
  assert_true(builds[1].equipment.contains("見習いのローブ"))
  assert_eq(builds[2].skills[0], "通常攻撃")
  s.world.begin_starting_build(@game.Mage)
  s.world.mode = @game.Playing
  let key = equipment_appearance_key(s.world.equipment)
  let data = s.serialize_save()
  assert_true(s.restore_save(data))
  assert_eq(equipment_appearance_key(s.world.equipment), key)
  assert_eq(
    s.world.equipment.item_for_slot(@game.Helmet).unwrap().name,
    "見習いの尖り帽",
  )
}
