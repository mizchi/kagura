///|
test "skill tree view exposes real prerequisites, effects, affordability and mastery" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  state.world.ui_mode = @game.Skills
  let hud = state.hunter_hud_view()
  assert_eq(hud.skill_points, 3)
  assert_eq(hud.nodes.length(), 19)
  let vitality = hud.nodes[3]
  assert_eq(vitality.id, @game.skill_id_to_int(@game.Vitality))
  assert_eq(vitality.effect, "最大体力 +0")
  assert_eq(vitality.next_effect, "最大体力 +3")
  assert_true(vitality.available)
  let leech = hud.nodes[5]
  assert_eq(leech.status, "prerequisite")
  assert_eq(leech.prereqs.length(), 2)
  assert_true(leech.prereqs.contains(@game.skill_id_to_int(@game.CriticalHit)))
  for node in hud.nodes {
    assert_true(node.x >= 0.0 && node.x <= 1.0)
    assert_true(node.y >= 0.0 && node.y <= 1.0)
    assert_true(node.description.length() > 0)
  }
  state.world.skills.skill_points = 0
  assert_eq(state.hunter_hud_view().nodes[3].status, "points")
  state.world.skills.find(@game.Vitality).unwrap().level = 5
  assert_eq(state.hunter_hud_view().nodes[3].status, "maxed")
}

///|
test "newly learned active skills can be cast from physical keys" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  state.world.ui_mode = @game.Skills
  assert_true(state.world.allocate_skill(@game.ChainLightning))
  assert_true(state.world.allocate_skill(@game.HomingMissile))
  assert_eq(state.hunter_hud_view().extra_skills.length(), 2)
  state.world.ui_mode = @game.UIMode::None
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [53]))
  assert_true(state.world.arts.action is Some(_))
  for _ in 0..<10 {
    state.update(@core.empty_input_snapshot())
  }
  assert_true(state.world.chain_lightning_cooldown_timer > 0)
  assert_eq(state.world.splitting_fireball_cooldown_timer, 0)
  for _ in 0..<50 {
    state.update(@core.empty_input_snapshot())
  }
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [54]))
  assert_true(state.world.homing_missile_cooldown_timer > 0)
  assert_eq(state.world.ice_nova_cooldown_timer, 0)
}
