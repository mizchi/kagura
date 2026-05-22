///|
test "EnemyModels::compute_skinning caches unchanged pose" {
  let enemies = EnemyModels::new()
  let first = enemies.compute_skinning()
  let second = enemies.compute_skinning()
  assert_eq(first.length(), enemy_bone_count)
  assert_eq(second.length(), enemy_bone_count)
  assert_eq(enemies.skinning_cache_builds, 1)
}

///|
test "EnemyModels::update invalidates skinning cache" {
  let enemies = EnemyModels::new()
  let _ = enemies.compute_skinning()
  let _ = enemies.compute_skinning()
  assert_eq(enemies.skinning_cache_builds, 1)

  enemies.update(1.0 / 60.0)
  let _ = enemies.compute_skinning()
  assert_eq(enemies.skinning_cache_builds, 2)
}

///|
test "EnemyModels::get_skinned_mesh caches unchanged pose" {
  let enemies = EnemyModels::new()
  let first = enemies.get_skinned_mesh(@game.Basic)
  let second = enemies.get_skinned_mesh(@game.Basic)
  assert_eq(first.vertex_count(), enemies.basic.bind_mesh.vertex_count())
  assert_eq(second.vertex_count(), enemies.basic.bind_mesh.vertex_count())
  assert_eq(enemies.skinned_mesh_cache_builds, 1)
}

///|
test "EnemyModels::update invalidates skinned mesh cache" {
  let enemies = EnemyModels::new()
  let _ = enemies.get_skinned_mesh(@game.Basic)
  let _ = enemies.get_skinned_mesh(@game.Fast)
  assert_eq(enemies.skinned_mesh_cache_builds, 1)

  enemies.update(1.0 / 60.0)
  let _ = enemies.get_skinned_mesh(@game.Basic)
  assert_eq(enemies.skinned_mesh_cache_builds, 2)
}
