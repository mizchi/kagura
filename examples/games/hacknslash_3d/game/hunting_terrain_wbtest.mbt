///|
test "terrain experiments keep roads, sites, collision and progress while lifting the woodland" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  ignore(
    w.set_hunting_terrain({
      ..@terrain3d.TerrainConfig::default(),
      pattern: @terrain3d.Flat,
    }),
  )
  let before = Array::makei(map_cols * map_rows, i => {
    w.dungeon.grid.get(i % map_cols, i / map_cols)
  })
  let enemies = w.enemies.length()
  for
    pattern in [
      @terrain3d.Perlin,
      @terrain3d.DiamondSquare,
      @terrain3d.Voronoi,
      @terrain3d.Hybrid,
    ] {
    assert_true(
      w.set_hunting_terrain({ ..@terrain3d.TerrainConfig::default(), pattern, }),
    )
    let field = w.dungeon.terrain_surface.unwrap()
    assert_true(field.statistics().maximum > 1.0)
    assert_true(field.statistics().max_slope <= 0.65)
    assert_true(
      Array::makei(map_cols * map_rows, i => {
        w.dungeon.grid.get(i % map_cols, i / map_cols)
      }) ==
      before,
    )
    assert_eq(w.enemies.length(), enemies)
    for site in hunting_sites {
      assert_eq(field.sample(site.x.to_double(), site.z.to_double()), 0.0)
    }
    for z in 0..<map_rows {
      for x in 0..<map_cols {
        if w.dungeon.grid.get(x, z) == @terrain.Corridor {
          assert_eq(field.sample(x.to_double() + 0.5, z.to_double() + 0.5), 0.0)
        }
      }
    }
  }
  assert_true(
    w.set_hunting_terrain({
      ..@terrain3d.TerrainConfig::default(),
      pattern: @terrain3d.Flat,
    }),
  )
  assert_true(w.dungeon.terrain_surface is None)
}

///|
test "neighbor terrain shares exact boundary heights before and after regional travel" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  ignore(
    w.set_hunting_terrain({
      ..@terrain3d.TerrainConfig::default(),
      pattern: @terrain3d.DiamondSquare,
    }),
  )
  assert_true(w.prepare_region(1))
  let left = w.dungeon.terrain_surface.unwrap()
  let right = w.atlas.unwrap().regions[1].unwrap().dungeon.terrain_surface.unwrap()
  for z in 0..<=map_rows {
    assert_eq(left.at(map_cols - 1, z), right.at(1, z))
    assert_eq(left.at(map_cols - 2, z), right.at(0, z))
  }
  assert_true(w.enter_region(1, 43.5 * tile_size, 62.5 * tile_size))
  assert_eq(w.dungeon.terrain_surface.unwrap().values, right.values)
}
