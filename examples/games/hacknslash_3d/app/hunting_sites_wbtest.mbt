///|
test "site props stay inside their occupied footprints and contain grounded geometry" {
  for prop in @game.hunting_site_props(42) {
    let asset = hunting_prop_asset(prop)
    let mut ground = false
    for part in asset.parts {
      assert_true(
        part.material >= 0 && part.material < hunting_palette.length(),
      )
      assert_true(part.mesh.indices.length() > 0)
      for i in 0..<part.mesh.vertex_count() {
        let v = part.mesh.vertex_data
        assert_true(v[i * 8 + 1] >= -0.001)
        assert_true(v[i * 8].abs() <= prop.width.to_double() / 2.0 + 0.001)
        assert_true(v[i * 8 + 2].abs() <= prop.depth.to_double() / 2.0 + 0.001)
        if v[i * 8 + 1] < 0.01 {
          ground = true
        }
      }
    }
    assert_true(ground)
  }
}

///|
test "treasure input pauses with menus and opens the nearest chest only once" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  apply_hunting_site_preview(s, 0, true, false)
  assert_eq(s.hunter_exploration_view().nearby_chest, 0)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [66]))
  assert_false(s.world.chests[0].opened)
  s.update(@core.empty_input_snapshot())
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [66]))
  assert_true(s.world.chests[0].opened)
  let frame = s.world.chests[0].opened_frame
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [66]))
  assert_eq(s.world.chests[0].opened_frame, frame)
}
