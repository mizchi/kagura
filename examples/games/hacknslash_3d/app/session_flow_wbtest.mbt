///|
test "death confirmation retains growth and equipment and resumes at the checkpoint" {
  let s = GameState::new_with_params(seed=42, @game.BalanceParams::default(), hunting_grounds=true)
  s.world.mode = @game.GameOver
  s.world.player.hp = 0
  s.world.score = 777
  s.world.skills.skill_points = 8
  let armor = serialize_opt_item(s.world.equipment.armor)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [13]))
  assert_true(s.world.mode == @game.Playing)
  assert_eq(s.world.score, 777)
  assert_eq(s.world.skills.skill_points, 8)
  assert_eq(serialize_opt_item(s.world.equipment.armor), armor)
  assert_true(s.world.near_waypoint())
  assert_eq(s.world.player.hp, s.world.player_stats.max_hp)
  assert_true(s.character.anim_state == Idle)
}

///|
test "an empty save slot creates a clean character without carrying the previous session" {
  let s = GameState::new_with_params(seed=42, @game.BalanceParams::default(), hunting_grounds=true)
  s.world.score = 999
  s.world.level_progress.level = 12
  s.world.skills.skill_points = 40
  s.world.ui_mode = @game.Inventory
  s.set_paused(true)
  assert_true(s.select_save_slot(2))
  assert_eq(s.active_save_slot, 2)
  assert_true(s.world.mode == @game.CharacterSelect)
  assert_eq(s.world.score, 0)
  assert_eq(s.world.level_progress.level, 1)
  assert_false(s.paused)
  assert_true(s.world.ui_mode == @game.UIMode::None)
  assert_true(s.world.atlas.unwrap().unlocked == [true, false, false, false])
}

///|
test "save codec restores the oath, inventory and checkpoint after death" {
  let s = GameState::new_with_params(seed=42, @game.BalanceParams::default(), hunting_grounds=true)
  s.world.apply_archetype(@game.Mage)
  s.world.mode = @game.Playing
  assert_true(s.world.prepare_region(1))
  let (x, y) = @game.world_waypoint_position(1)
  assert_true(s.world.enter_region(1, x, y))
  assert_true(s.world.activate_nearby_waypoint())
  s.world.score = 512
  s.world.level_progress.level = 7
  s.world.skills.skill_points = 8
  s.world.player.hp = 0
  s.world.mode = @game.GameOver
  let data = s.serialize_save()
  let restored = GameState::new_with_params(seed=9, @game.BalanceParams::default(), hunting_grounds=true)
  assert_true(restored.restore_save(data))
  assert_true(restored.world.archetype is @game.Mage)
  assert_eq(restored.world.level_progress.level, 7)
  assert_eq(restored.world.skills.skill_points, 8)
  assert_eq(restored.world.score, 512)
  assert_eq(restored.world.player_stats.max_hp, s.world.player_stats.max_hp)
  assert_eq(restored.world.player.hp, restored.world.player_stats.max_hp)
  assert_eq((restored.world.player.x, restored.world.player.y), (x, y))
  assert_eq(restored.world.atlas.unwrap().last_waypoint, 1)
  assert_true(restored.world.mode == @game.Playing)
  assert_eq(serialize_opt_item(restored.world.equipment.armor), serialize_opt_item(s.world.equipment.armor))
}
