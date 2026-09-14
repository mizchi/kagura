///|
test "each starting build equips its advertised weapon and common removable clothes" {
  for
    (archetype, name, weapon, helmet) in [
      (Melee, "狩人", Cleaver, "狩人の三角帽"),
      (Mage, "魔法使い", Focus, "見習いの尖り帽"),
      (Ranger, "弓使い", Bow, "射手の革帽"),
      (Summoner, "召喚師", Focus, "喚霊の尖り帽"),
    ] {
    let w = GameWorld::new(seed=42, archetype~, hunting_grounds=true)
    assert_eq(archetype.build_name(), name)
    assert_true(w.equipment.weapon.unwrap().motion_weapon() == Some(weapon))
    assert_eq(w.equipment.item_for_slot(Helmet).unwrap().name, helmet)
    for slot in [Weapon, Armor, Helmet, Gloves, Boots] {
      let item = w.equipment.item_for_slot(slot).unwrap()
      assert_true(item.rarity is Common)
      assert_eq(item.total_atk(), 0)
      assert_eq(item.total_def(), 0)
      assert_eq(item.total_hp(), 0)
    }
  }
}

///|
test "starting a mage replaces selection defaults but applying or loading a build preserves equipment" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.begin_starting_build(Mage)
  assert_eq(
    w.equipment.item_for_slot(Armor).unwrap().name,
    "見習いのローブ",
  )
  assert_eq(w.inventory.items[1].unwrap().motion_weapon(), Some(Focus))
  ignore(w.equipment.unequip(Helmet))
  w.apply_archetype(Mage)
  assert_true(w.equipment.item_for_slot(Helmet) is None)
  assert_eq(
    w.equipment.item_for_slot(Armor).unwrap().name,
    "見習いのローブ",
  )
}

///|
test "archer primary slot shoots the equipped bow and its other slots are usable" {
  let w = GameWorld::new(seed=42, archetype=Ranger, hunting_grounds=true)
  assert_eq(w.hunter_slots, [74, 54, 86, 70])
  assert_true(w.skills.get_level(HomingMissile) >= 1)
}
