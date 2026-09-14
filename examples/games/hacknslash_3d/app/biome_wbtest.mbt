///|
test "biome transitions stay continuous across all region borders" {
  for
    (x, z) in [
      (98.0, 40.0),
      (98.0, 118.0),
      (50.0, 78.0),
      (150.0, 78.0),
      (98.0, 78.0),
    ] {
    let a = biome_weights(x - 0.001, z - 0.001)
    let b = biome_weights(x + 0.001, z + 0.001)
    assert_true((a.fold(init=0.0, (n, v) => n + v) - 1.0).abs() < 0.000001)
    assert_true(a.all(v => v >= 0.0 && v <= 1.0))
    assert_true(a.filter(v => v > 0.05).length() >= 2)
    for i in 0..<4 {
      assert_true((a[i] - b[i]).abs() < 0.001)
    }
  }
  assert_eq(biome_weights(20.0, 30.0), [1.0, 0.0, 0.0, 0.0])
  assert_eq(biome_weights(170.0, 140.0), [0.0, 0.0, 0.0, 1.0])
}

///|
test "plant species mix at the edge without adding geometry or changing collision" {
  let species = Array::make(4, 0)
  for roll in 0..<100 {
    species[biome_species(98.0, 40.0, roll)] += 1
  }
  assert_true(species[0] > 20 && species[1] > 20)
  let world = @game.GameWorld::new(seed=42, hunting_grounds=true)
  let chunk = build_hunting_chunk(world.dungeon, world.seed, 4, 2, region=0)
  for material, group in chunk.groups {
    for i in 0..<(group.mesh.vertex_data.length() / 8) {
      assert_eq(group.mesh.vertex_data[i * 8 + 6], material.to_double())
      assert_true(
        group.mesh.vertex_data[i * 8 + 7] >= 1.0 &&
        group.mesh.vertex_data[i * 8 + 7] <= 3.0,
      )
    }
  }
}
