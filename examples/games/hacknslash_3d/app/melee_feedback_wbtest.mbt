///|
test "only confirmed melee impacts stop time and repeated hits use a bounded stop" {
  let s = GameState::new(seed=42)
  s.apply_melee_feedback(@game.AttackTriggered)
  assert_eq(s.combat_feedback.hitstop, 0)
  s.apply_melee_feedback(
    @game.MeleeImpact(@game.Cleaver, @game.Opening, 0.0, 0.0, 0.0, 3),
  )
  assert_eq(s.combat_feedback.hitstop, 4)
  s.apply_melee_feedback(
    @game.MeleeImpact(@game.Knuckles, @game.Opening, 0.0, 0.0, 0.0, 1),
  )
  assert_eq(s.combat_feedback.hitstop, 4)
  assert_eq(s.combat_feedback.impacts, 2)
}

///|
test "web damage view projects readable numbers and bounds sustained combat memory" {
  let s = GameState::new(seed=42)
  s.world.mode = @game.Playing
  for i in 0..<100 {
    s.spawn_damage_popup(s.world.player.x, s.world.player.y, i + 1, 0xFFF0BB)
  }
  assert_true(s.damage_popups.length() <= 48)
  let view = s.hunter_combat_view()
  assert_true(view.damage.length() > 0)
  assert_true(view.damage[0].x >= 0.0 && view.damage[0].x <= 100.0)
  assert_true(view.damage[0].y >= 0.0 && view.damage[0].y <= 100.0)
  for _ in 0..<60 {
    s.update_damage_popups()
  }
  assert_eq(s.hunter_combat_view().damage.length(), 0)
}

///|
test "camera look ahead eases toward the automatic target without rotating the camera" {
  let s = aim_test_state()
  s.world.player.facing_angle = 0.0
  s.world.enemies = [
    @game.make_enemy(
      s.world.player.x + 32.0,
      s.world.player.y,
      @game.Basic,
      100,
      0.0,
      8.0,
    ),
  ]
  let yaw = s.camera.yaw
  s.update_combat_camera()
  assert_true(s.camera.target.x > s.world.player.x / tile_size)
  assert_true(s.camera.target.x < s.world.player.x / tile_size + 0.5)
  for _ in 0..<120 {
    s.update_combat_camera()
  }
  assert_true(s.camera.target.x <= s.world.player.x / tile_size + 1.25)
  assert_eq(s.camera.yaw, yaw)
}

///|
test "hitstop freezes world and actor clocks but Escape and dodge remain responsive" {
  let s = GameState::new(seed=42)
  s.world.mode = @game.Playing
  s.world.enemies.clear()
  s.combat_feedback.hitstop = 4
  let frame = s.world.frame_count
  let time = s.character.time
  s.update(@core.empty_input_snapshot())
  assert_eq(s.world.frame_count, frame)
  assert_eq(s.character.time, time)
  assert_eq(s.combat_feedback.hitstop, 3)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(s.paused)
  assert_eq(s.combat_feedback.hitstop, 3)
  s.update(@core.empty_input_snapshot())
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_false(s.paused)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87, 32]))
  assert_true(s.world.player.dash_timer > 0)
  assert_eq(s.combat_feedback.hitstop, 0)
}

///|
test "melee motion keeps exact contact and distinct weapon impact cues" {
  assert_eq(melee_motion_phase(0.0), 0.0)
  assert_eq(melee_motion_phase(0.5), 0.5)
  assert_true((melee_motion_phase(1.0) - 1.0).abs() < 0.0001)
  assert_true(melee_motion_phase(0.25) < 0.15)
  assert_eq(
    sound_cue_for_event(
      @game.MeleeImpact(@game.Cleaver, @game.Opening, 0.0, 0.0, 0.0, 1),
    ),
    Some(SfxMeleeCleaver),
  )
  assert_eq(
    sound_cue_for_event(
      @game.MeleeImpact(@game.Spear, @game.Opening, 0.0, 0.0, 0.0, 1),
    ),
    Some(SfxMeleePierce),
  )
  assert_eq(
    sound_cue_for_event(
      @game.MeleeImpact(@game.Knuckles, @game.Opening, 0.0, 0.0, 0.0, 1),
    ),
    Some(SfxMeleePunch),
  )
}
