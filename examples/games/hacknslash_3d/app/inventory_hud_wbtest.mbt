///|
test "inventory view describes occupied cells, all body slots, and committed stats" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  assert_true(state.hunter_hud_view().inventory_grid is None)
  state.world.ui_mode = @game.Inventory
  let view = state.hunter_hud_view().inventory_grid.unwrap()
  assert_eq(view.width, 8)
  assert_eq(view.height, 6)
  assert_eq(view.equipment.length(), 8)
  assert_eq(view.items.length(), 6)
  assert_eq(view.items[0].cells.length(), 4)
  assert_eq(view.items[1].cells.length(), 4)
  assert_eq(view.items[1].width, 2)
  assert_eq(view.items[1].height, 3)
  assert_true(state.apply_inventory_command([0, 0, 0, 0, 0]))
  assert_true(state.world.player_weapon == @game.Spear)
  assert_eq(
    state.hunter_hud_view().inventory_grid.unwrap().equipment[0].item.unwrap().source,
    -1,
  )
  assert_false(state.apply_inventory_command([1, 3, 0, 0, 0]))
  // The initial weapon returns to the bag when the spear is equipped.
  assert_eq(state.world.inventory.count(), 6)
  state.world.ui_mode = @game.UIMode::None
  assert_false(state.apply_inventory_command([-1, -1, 7, 0, 0]))
}

///|
test "discard command exposes a ground label at the terrain height and removes it after pickup" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.Playing
  s.world.ui_mode = @game.Inventory
  let item = s.world.inventory.items[0].unwrap()
  assert_true(s.apply_inventory_command([0, -2, 0, 0, 0]))
  assert_false(s.apply_inventory_command([1, -3, 0, 0, 0]))
  s.update_combat_camera()
  let labels = s.hunter_hud_view().loot
  assert_eq(labels.length(), 1)
  assert_eq(labels[0].name, item.display_name())
  assert_true(labels[0].blocked)
  let drop = s.world.items[0]
  let expected = project_world_label_position(
    s.camera.to_camera3d(),
    @math3d.Vec3::new(
      drop.x / tile_size,
      @game.get_tile_height(s.world.dungeon, drop.x, drop.y) + 1.05,
      drop.y / tile_size,
    ),
    100.0,
    100.0,
  ).unwrap()
  assert_eq(labels[0].x, expected.0)
  assert_eq(labels[0].y, expected.1)
  drop.alive = false
  assert_eq(s.hunter_hud_view().loot.length(), 0)
}

///|
test "loot interaction publishes exact ids and reach and respects pause and targeting" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.Playing
  s.world.ui_mode = @game.Inventory
  assert_true(s.apply_inventory_command([0, -2, 0, 0, 0]))
  s.world.ui_mode = @game.UIMode::None
  let label = s.hunter_loot_view()[0]
  assert_true(label.id > 0)
  assert_true(label.reachable)
  assert_true(label.nearest)
  s.paused = true
  assert_false(s.apply_loot_pickup(label.id))
  s.paused = false
  s.ground_targeting = true
  assert_false(s.apply_loot_pickup(label.id))
  s.ground_targeting = false
  assert_true(s.apply_loot_pickup(label.id))
  assert_eq(s.hunter_loot_view().length(), 0)
  assert_eq(s.world.inventory.count(), 6)
}
