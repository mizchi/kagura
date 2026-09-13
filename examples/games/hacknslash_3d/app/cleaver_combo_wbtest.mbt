///|
test "cleaver combo poses differ and finisher animation holds through gameplay recovery" {
  let actor = CharacterModel::new()
  let poses : Array[Array[Double]] = []
  for step in [@game.Opening, @game.Return, @game.Finisher] {
    actor.trigger_attack(combo=step)
    actor.update(step.profile().windup.to_double() / 60.0)
    ignore(actor.compute_skinning())
    let q = actor.local_poses[2].rotation
    poses.push([q.x, q.y, q.z, q.w])
    actor.update((step.profile().recovery - 1).to_double() / 60.0)
    assert_eq(actor.anim_state, Attacking)
    actor.update(2.0 / 60.0)
    assert_eq(actor.anim_state, Idle)
  }
  assert_true(poses[0] != poses[1])
  assert_true(poses[1] != poses[2])
  let state = GameState::new(seed=42)
  state.apply_melee_feedback(
    @game.MeleeImpact(@game.Cleaver, @game.Finisher, 0.0, 0.0, 0.0, 1),
  )
  assert_eq(state.combat_feedback.hitstop, 6)
}

///|
test "the heavy blade clears the hat in anticipation and every cut points forward at contact" {
  let actor = CharacterModel::new()
  actor.trigger_attack(combo=@game.Finisher)
  actor.update(12.0 / 60.0)
  ignore(actor.compute_skinning())
  let tip = actor.skeleton.compute_world_transforms(actor.local_poses)[4].mul_vec4(
    @math3d.Vec4::new(0.0, 0.02, 0.82, 1.0),
  )
  assert_true(tip.y > 1.45)
  for step in [@game.Opening, @game.Return, @game.Finisher] {
    actor.trigger_attack(combo=step)
    actor.update(step.profile().windup.to_double() / 60.0)
    ignore(actor.compute_skinning())
    let tip = actor.skeleton.compute_world_transforms(actor.local_poses)[4].mul_vec4(
      @math3d.Vec4::new(0.0, 0.02, 0.82, 1.0),
    )
    assert_true(tip.z > 0.8)
    assert_true(tip.y < 1.0)
  }
}

///|
test "keyboard melee assist does not turn a forward step toward an enemy behind the hunter" {
  let s = GameState::new(seed=42)
  s.world.player.facing_angle = 0.0
  s.world.enemies.clear()
  s.world.enemies.push(
    @game.make_enemy(
      s.world.player.x - 12.0,
      s.world.player.y,
      @game.Basic,
      100,
      0.0,
      8.0,
    ),
  )
  assert_eq(hunter_assisted_aim(s.world), 0.0)
}

///|
test "movement steers the next keyboard cut while each active strike commits its direction" {
  let s = GameState::new(seed=42)
  s.world.mode = @game.Playing
  s.world.enemies.clear()
  s.world.enemies.push(
    @game.make_enemy(
      s.world.player.x + 200.0,
      s.world.player.y,
      @game.Basic,
      100,
      0.0,
      8.0,
    ),
  )
  s.camera = s.camera.orbit(-s.camera.yaw, 0.0)
  s.world.player.facing_angle = 0.0
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87, 74]))
  let attack = s.world.weapon_attack.unwrap()
  assert_true((attack.angle + @math.PI / 2.0).abs() < 0.001)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [68, 74]))
  assert_true(
    (s.world.weapon_attack.unwrap().angle - attack.angle).abs() < 0.001,
  )
}
