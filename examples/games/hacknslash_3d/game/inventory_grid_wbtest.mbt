///|
fn inventory_test_item(
  slot : EquipSlot,
  icon? : Int = 0,
  power? : Int = 1,
) -> ItemData {
  {
    name: "Test",
    rarity: Rare,
    slot,
    atk_bonus: power,
    def_bonus: power,
    hp_bonus: power,
    str_bonus: 0,
    int_bonus: 0,
    dex_bonus: 0,
    str_scaling: 0.0,
    int_scaling: 0.0,
    dex_scaling: 0.0,
    prefix: None,
    suffix: None,
    icon_id: icon,
  }
}

///|
test "grid inventory moves, rotates and equips atomically without losing a displaced item" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Inventory
  world.inventory.clear()
  world.equipment.clear()
  let spear = inventory_test_item(Weapon, icon=41, power=7)
  let coat = inventory_test_item(Armor, power=4)
  assert_true(world.inventory.add(spear))
  assert_true(world.inventory.add(coat))
  assert_true(world.transfer_inventory(Bag(0), Cell(4, 4, true)))
  assert_true(world.inventory.grid.unwrap().placement(0).unwrap().rotated)
  assert_false(world.transfer_inventory(Bag(0), Cell(7, 5, false)))
  assert_eq(world.inventory.grid.unwrap().placement(0).unwrap().x, 4)
  assert_false(world.transfer_inventory(Bag(0), Wear(Armor)))
  assert_true(world.transfer_inventory(Bag(0), Wear(Weapon)))
  assert_eq(world.equipment.weapon.unwrap().atk_bonus, 7)
  assert_true(world.player_weapon == Spear)
  assert_eq(world.inventory.count(), 1)
  assert_true(world.transfer_inventory(Equipped(Weapon), Cell(4, 4, true)))
  assert_true(world.equipment.weapon is None)
  assert_eq(world.inventory.count(), 2)
  assert_true(world.transfer_inventory(Bag(1), Wear(Armor)))
  let better = inventory_test_item(Armor, power=9)
  assert_true(world.inventory.add(better))
  assert_true(world.transfer_inventory(Bag(1), Wear(Armor)))
  assert_eq(world.inventory.items[1].unwrap().def_bonus, 4)
  assert_eq(world.equipment.armor.unwrap().def_bonus, 9)
}

///|
test "full bags reject unequipping and pickup instead of destroying items" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Inventory
  world.inventory.clear()
  let ring = inventory_test_item(Accessory)
  for _ in 0..<48 {
    assert_true(world.inventory.add(ring))
  }
  let armor = inventory_test_item(Armor, power=3)
  world.equipment.armor = Some(armor)
  assert_false(world.transfer_inventory(Equipped(Armor), Cell(0, 0, false)))
  assert_eq(world.inventory.count(), 48)
  assert_eq(world.equipment.armor.unwrap().def_bonus, 3)
  assert_false(world.collect_equipment_pickup(armor))
  assert_eq(world.inventory.count(), 48)
  world.inventory.clear()
  for _ in 0..<8 {
    assert_true(world.inventory.add(armor))
  }
  assert_eq(world.inventory.count(), 8)
  assert_false(world.collect_equipment_pickup(ring))
}

///|
test "all equipment slots contribute stats and imported overflow remains recoverable" {
  let equipment = Equipment::new()
  for slot in equipment_slots() {
    ignore(equipment.equip(inventory_test_item(slot)))
  }
  assert_eq(equipment.total_atk(), 8)
  let inventory = Inventory::new_grid(2, 2)
  inventory.items[0] = Some(inventory_test_item(Armor))
  inventory.items[1] = Some(inventory_test_item(Accessory))
  inventory.repack()
  assert_eq(inventory.count(), 2)
  assert_true(inventory.grid.unwrap().placement(0) is None)
  assert_true(inventory.grid.unwrap().placement(1) is Some(_))
}

///|
test "bag swaps preserve identities, equipment swaps validate slots, and in-flight attacks reject changes" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Inventory
  world.inventory.clear()
  assert_true(
    world.inventory.add(inventory_test_item(Weapon, icon=41, power=7)),
  )
  assert_true(
    world.inventory.add(inventory_test_item(Weapon, icon=42, power=3)),
  )
  assert_true(world.transfer_inventory(Bag(0), Cell(3, 0, false)))
  assert_true(world.player_weapon == Cleaver)
  assert_true(world.transfer_inventory(Bag(1), Cell(3, 0, false)))
  assert_eq(world.inventory.items[0].unwrap().atk_bonus, 7)
  assert_eq(world.inventory.items[1].unwrap().atk_bonus, 3)
  assert_eq(world.inventory.grid.unwrap().placement(1).unwrap().x, 3)
  assert_true(world.transfer_inventory(Bag(0), Wear(Weapon)))
  world.weapon_attack = Some({ weapon: Spear, angle: 0.0, frame: 2, })
  assert_false(world.transfer_inventory(Bag(1), Wear(Weapon)))
  assert_eq(world.equipment.weapon.unwrap().atk_bonus, 7)
  assert_eq(world.inventory.items[1].unwrap().atk_bonus, 3)
  world.weapon_attack = None
  assert_true(world.transfer_inventory(Equipped(Weapon), Cell(3, 0, false)))
  assert_true(world.player_weapon == Knuckles)
  assert_eq(world.equipment.weapon.unwrap().atk_bonus, 3)
  assert_eq(world.inventory.items[0].unwrap().atk_bonus, 7)
}

///|
test "invalid saved positions are repaired without changing valid placements or losing overflow" {
  let inventory = Inventory::new_grid(3, 3)
  inventory.items[0] = Some(inventory_test_item(Armor))
  inventory.items[1] = Some(inventory_test_item(Accessory))
  inventory.items[2] = Some(inventory_test_item(Accessory))
  inventory.items[3] = Some(inventory_test_item(Armor))
  inventory.restore_layout([
    Some((0, 0, false)),
    Some((0, 0, false)),
    Some((-5, 7, false)),
    None,
  ])
  let grid = inventory.grid.unwrap()
  assert_eq(grid.placement(0).unwrap().x, 0)
  assert_eq(grid.placement(1).unwrap().x, 2)
  assert_eq(grid.placement(2).unwrap().y, 1)
  assert_true(grid.placement(3) is None)
  assert_eq(inventory.count(), 4)
  assert_eq(grid.used_cells(), 8)
}
