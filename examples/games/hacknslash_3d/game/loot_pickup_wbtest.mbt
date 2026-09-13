///|
test "manual pickup retrieves an exact discarded item without leaving and cannot pick it twice" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  w.ui_mode = Inventory
  let item = w.inventory.items[0].unwrap()
  assert_true(w.transfer_inventory(Bag(0), Ground))
  let id = w.items[0].pickup_id.unwrap()
  w.tick_items_phase()
  assert_true(w.items[0].alive)
  assert_false(w.pickup_item(id)) // No loot input while arranging equipment.
  w.ui_mode = UIMode::None
  assert_true(w.pickup_item(id))
  assert_false(w.pickup_item(id))
  assert_eq(w.inventory.items[0].unwrap().to_json(), item.to_json())
  assert_eq(w.events.filter(e => e is ItemPickup(_, _, _)).length(), 1)
}

///|
test "pickup identities survive compaction and nearest pickup respects distance and walls" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  let x = w.player.x
  let y = w.player.y
  spawn_ground_item(w, x + 12.0, y, Score)
  spawn_ground_item(w, x + 20.0, y, Score)
  let first = w.items[0].pickup_id.unwrap()
  let second = w.items[1].pickup_id.unwrap()
  assert_eq(w.nearest_pickup_id().unwrap(), first)
  assert_true(w.pickup_item(first))
  w.tick_items_phase()
  assert_eq(w.items.length(), 1)
  assert_true(w.pickup_item(second))
  assert_eq(w.score, 10)
  spawn_ground_item(w, x + 100.0, y, Score)
  assert_false(w.pickup_item(w.items[w.items.length() - 1].pickup_id.unwrap()))
  assert_true(w.nearest_pickup_id() is None)
  w.items.clear()
  w.player.x = 8.5 * tile_size
  w.player.y = 8.5 * tile_size
  w.dungeon.grid.set(8, 8, @terrain.Floor)
  w.dungeon.grid.set(9, 8, @terrain.Wall)
  w.dungeon.grid.set(10, 8, @terrain.Floor)
  spawn_ground_item(w, 10.5 * tile_size, w.player.y, Score)
  assert_false(w.pickup_item(w.items[0].pickup_id.unwrap()))
  assert_true(w.nearest_pickup_id() is None)
}

///|
test "manual pickup leaves loot intact when a shaped bag is full and invalidates saved session ids" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  w.inventory.clear()
  for _ in 0..<48 {
    assert_true(w.inventory.add(inventory_test_item(Accessory)))
  }
  spawn_ground_item(
    w,
    w.player.x,
    w.player.y,
    Equipment(inventory_test_item(Weapon)),
  )
  let id = w.items[0].pickup_id.unwrap()
  assert_false(w.pickup_item(id))
  assert_true(w.items[0].alive)
  assert_eq(w.inventory.count(), 48)
  let saved = w.serialize_world_progress()
  assert_true(w.restore_world_progress(saved))
  assert_true(w.items[0].pickup_id.unwrap() != id)
  assert_false(w.pickup_item(id))
  assert_true(w.items[0].alive)
}
