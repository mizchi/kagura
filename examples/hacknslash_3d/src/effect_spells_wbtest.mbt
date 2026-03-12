///|
test "queue_chain_lightning_effect stores line placement target" {
  let state = GameState::new(seed=42)

  state.queue_chain_lightning_effect(16.0, 24.0, 48.0, 56.0)

  assert_eq(state.active_effects.length(), 1)
  assert_eq(state.active_effects[0].doc.name, "chain_lightning")
  assert_true(state.active_effects[0].placement.target is Some(_))
}

///|
test "update_active_effects spawns emitters and compacts expired effects" {
  let state = GameState::new(seed=42)

  state.queue_fireball_burst_effect(24.0, 32.0)
  state.update_active_effects(0.08)

  assert_true(state.particle_manager.emitters.length() > 0)
  assert_eq(state.active_effects.length(), 1)

  state.update_active_effects(1.0)
  assert_eq(state.active_effects.length(), 0)
}

///|
test "queue_ice_nova_effect scales placement from gameplay radius" {
  let state = GameState::new(seed=42)

  state.queue_ice_nova_effect(20.0, 28.0, @game.ice_nova_radius)

  assert_eq(state.active_effects.length(), 1)
  assert_true(state.active_effects[0].placement.scale > 1.0)
}

///|
test "queue_ground_ring_telegraph_effect stores telegraph ring document" {
  let state = GameState::new(seed=42)

  state.queue_ground_ring_telegraph_effect(16.0, 24.0, 32.0)

  assert_eq(state.active_effects.length(), 1)
  assert_eq(state.active_effects[0].doc.name, "ground_telegraph_ring")
  assert_true(state.active_effects[0].placement.scale > 1.0)
}

///|
test "queue_ground_line_telegraph_effect stores telegraph line target" {
  let state = GameState::new(seed=42)

  state.queue_ground_line_telegraph_effect(16.0, 24.0, 64.0, 72.0)

  assert_eq(state.active_effects.length(), 1)
  assert_eq(state.active_effects[0].doc.name, "ground_telegraph_line")
  assert_true(state.active_effects[0].placement.target is Some(_))
}
