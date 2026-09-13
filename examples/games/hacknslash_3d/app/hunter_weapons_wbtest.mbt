///|
test "hunter equips all motion weapon sets without rebuilding cached geometry" {
  let character = PlayerCharacter::new()
  for _ in 0..<2 {
    for
      kind in [
        @game.Cleaver,
        @game.Spear,
        @game.Knuckles,
        @game.Focus,
        @game.Bow,
      ] {
      character.equip_weapon(kind)
      assert_eq(character.weapon.id, kind.profile().id)
      assert_eq(
        character.weapon.attack_duration,
        (kind.profile().windup + kind.profile().recovery).to_double() / 60.0,
      )
      assert_true(character.parts.length() <= 10)
      character.trigger_attack()
      character.update(kind.profile().windup.to_double() / 60.0)
      let pose = character.compute_skinning()
      assert_eq(pose.length(), 17)
      assert_false(pose[3].approx_eq(@math3d.Mat4::identity(), 0.001))
      character.update(2.0)
      assert_eq(character.anim_state, Idle)
    }
  }
  assert_eq(character.equipped_cache.length(), 5)
}

///|
test "hunter bowstring follows the drawing hand and hides the arrow on the release frame" {
  let character = PlayerCharacter::new()
  character.equip_weapon(@game.Bow)
  character.trigger_attack()
  let contact = @game.Bow.profile().windup.to_double() / 60.0
  character.update(contact - 1.0 / 60.0)
  let _ = character.compute_skinning()
  let world = character.skeleton.compute_world_transforms(character.local_poses)
  let string = world[15].mul_vec4(@math3d.Vec4::new(0.0, 0.0, 0.0, 1.0))
  let hand = world[3].mul_vec4(@math3d.Vec4::new(0.03, -0.13, 0.06, 1.0))
  assert_true(
    (string.x - hand.x).abs() +
    (string.y - hand.y).abs() +
    (string.z - hand.z).abs() <
    0.005,
  )
  assert_eq(character.local_poses[16].scale.x, 1.0)
  character.update(1.0 / 60.0)
  let _ = character.compute_skinning()
  assert_eq(character.local_poses[16].scale.x, 0.0)
}
