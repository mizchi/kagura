///|
test "expedition generates repeatable branching routes with meaningful elevation" {
  let a = expedition_plan(42, 0)
  let b = expedition_plan(42, 0)
  assert_eq(a.to_json().stringify(), b.to_json().stringify())
  assert_true(
    a.to_json().stringify() != expedition_plan(43, 0).to_json().stringify(),
  )
  assert_true(a.routes.length() >= a.pads.length())
  let dungeon = generate_world_region(42, 0)
  let field = dungeon.terrain_surface.unwrap()
  assert_true(field.statistics().maximum - field.statistics().minimum > 6.0)
  for site in hunting_sites {
    assert_true(
      field.sample(site.x.to_double() + 0.5, site.z.to_double() + 0.5) >= 1.0,
    )
  }
}

///|
test "expedition essential sites and portals are reachable across seeds with bounded slope" {
  for seed in [1, 7, 42, 43, 97, 1001, -19] {
    for region in world_regions {
      let dungeon = generate_world_region(
        region_seed(seed, region.id),
        region.id,
      )
      let report = validate_expedition(dungeon, region.id)
      assert_eq(report.unreachable_targets, 0)
      assert_true(report.max_walk_slope <= 0.72)
      assert_true(report.ground_triangles <= 16000)
    }
  }
}

///|
test "opened expedition caches unlock local return travel and survive saves" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  w.ui_mode = Waypoints
  assert_false(w.travel_to_expedition_site(0))
  w.chests[0].opened = true
  assert_true(w.travel_to_expedition_site(0))
  assert_true(w.near_expedition_anchor())
  assert_true(w.ui_mode == UIMode::None)
  let copy = GameWorld::new(seed=99, hunting_grounds=true)
  assert_true(copy.restore_world_progress(w.serialize_world_progress()))
  assert_true(copy.chests[0].opened)
  assert_eq(copy.atlas.unwrap().generator_version, 3)
  assert_true(copy.dungeon.terrain_surface is Some(_))
  copy.mode = Playing
  copy.ui_mode = Waypoints
  assert_false(copy.travel_to_expedition_site(1))
}

///|
test "unversioned archives retain their original geography" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  let json = @json.parse(w.serialize_world_progress())
  guard json is Object(root) else { fail("object") }
  root["version"] = 3
  root.remove("generator_version")
  assert_true(w.restore_world_progress(json.stringify()))
  assert_eq(w.atlas.unwrap().generator_version, 1)
  assert_true(w.dungeon.terrain_surface is None)
  assert_true(w.prepare_region(1))
  assert_true(
    w.atlas.unwrap().regions[1].unwrap().dungeon.terrain_surface is None,
  )
}

///|
test "expedition seam collars are identical for every neighbor and generation order" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  for id in [3, 2, 1] {
    assert_true(w.prepare_region(id))
  }
  for region in world_regions {
    let a = w.atlas.unwrap().regions[region.id].unwrap().dungeon.terrain_surface.unwrap()
    if region_neighbor(region.id, 1, 0) is Some(id) {
      let b = w.atlas.unwrap().regions[id].unwrap().dungeon.terrain_surface.unwrap()
      for z in 0..<=map_rows {
        for x in 0..<=2 {
          assert_eq(a.at(map_cols - 2 + x, z), b.at(x, z))
        }
      }
    }
    if region_neighbor(region.id, 0, 1) is Some(id) {
      let b = w.atlas.unwrap().regions[id].unwrap().dungeon.terrain_surface.unwrap()
      for x in 0..<=map_cols {
        for z in 0..<=2 {
          assert_eq(a.at(x, map_rows - 2 + z), b.at(x, z))
        }
      }
    }
  }
}
