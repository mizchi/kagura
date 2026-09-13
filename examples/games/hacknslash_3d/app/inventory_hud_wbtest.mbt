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
  assert_eq(state.world.inventory.count(), 5)
  state.world.ui_mode = @game.UIMode::None
  assert_false(state.apply_inventory_command([-1, -1, 7, 0, 0]))
}
