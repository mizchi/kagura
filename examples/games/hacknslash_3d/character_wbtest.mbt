///|
test "PlayerCharacter::compute_skinning caches unchanged pose" {
  let character = PlayerCharacter::new()
  let first = character.compute_skinning()
  let second = character.compute_skinning()
  assert_eq(first.length(), char_num_bones)
  assert_eq(second.length(), char_num_bones)
  assert_eq(character.skinning_cache_builds, 1)
}

///|
test "PlayerCharacter::update invalidates skinning cache" {
  let character = PlayerCharacter::new()
  let _ = character.compute_skinning()
  let _ = character.compute_skinning()
  assert_eq(character.skinning_cache_builds, 1)

  character.update(1.0 / 60.0)
  let _ = character.compute_skinning()
  assert_eq(character.skinning_cache_builds, 2)
}
