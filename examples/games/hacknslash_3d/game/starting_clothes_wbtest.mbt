///|
test "a new hunter wears real removable starting clothes without changing stats" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  for slot in [Armor, Helmet, Gloves, Boots] {
    let item = world.equipment.item_for_slot(slot).unwrap()
    assert_eq(item.def_bonus, 0)
    assert_eq(item.atk_bonus, 0)
    assert_eq(item.hp_bonus, 0)
  }
  ignore(world.equipment.unequip(Helmet))
  world.apply_archetype(world.archetype)
  assert_true(world.equipment.item_for_slot(Helmet) is None)
}
