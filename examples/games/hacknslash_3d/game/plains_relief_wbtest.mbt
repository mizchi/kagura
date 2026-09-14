///|
fn surface_roughness(
  field : @terrain3d.HeightField,
  plan : ExpeditionPlan,
) -> Double {
  let mut total = 0.0
  for z in 3..<(map_rows - 3) {
    for x in 3..<(map_cols - 3) {
      let px = x.to_double()
      let pz = z.to_double()
      if plan.routes.any(r => r.projection(px, pz).0 < r.width + 5.0) ||
        plan.pads.any(p => {
          (px - p.x) * (px - p.x) + (pz - p.z) * (pz - p.z) <
          (p.radius + 5.0) * (p.radius + 5.0)
        }) {
        continue
      }
      total += (field.at(x - 1, z) + field.at(x + 1, z) - 2.0 * field.at(x, z)).abs()
      total += (field.at(x, z - 1) + field.at(x, z + 1) - 2.0 * field.at(x, z)).abs()
    }
  }
  total
}

///|
test "plains relief reduces small bumps without removing roads or natural boundaries" {
  for region in world_regions {
    let seed = region_seed(42, region.id)
    let old = expedition_surface(seed, region.id)
    let smooth = expedition_surface(seed, region.id, plains_relief=0.0)
    let plan = expedition_plan(seed, region.id)
    assert_true(
      surface_roughness(smooth, plan) < surface_roughness(old, plan) * 0.65,
    )
    for relief in [0.0, 0.35, 1.0] {
      let dungeon = generate_world_region(seed, region.id, plains_relief=relief)
      assert_eq(validate_expedition(dungeon, region.id).unreachable_targets, 0)
      assert_true(dungeon.landscape is Some(_))
      let land = dungeon.landscape.unwrap()
      assert_eq(land.kind(61, 17), CaveFloor)
      assert_eq(
        land.bridges.length(),
        generate_landscape(seed, region.id).bridges.length(),
      )
      for bridge in land.bridges {
        for i in 0..<=24 {
          let t = i.to_double() / 24.0
          let x = bridge.ax + (bridge.bx - bridge.ax) * t
          let z = bridge.az + (bridge.bz - bridge.az) * t
          if x >= 0.5 && x <= 99.5 && z >= 0.5 && z <= 79.5 {
            assert_false(
              check_wall_collision(
                dungeon.grid,
                x * tile_size,
                z * tile_size,
                12.0,
              ),
            )
          }
        }
      }
    }
  }
}

///|
test "adjusted plains retain shared seams and reachable goals across seeds" {
  for seed in [43, -19] {
    let w = GameWorld::new(seed~, hunting_grounds=true)
    for id in [3, 2, 1] {
      ignore(w.prepare_region(id))
    }
    for relief in [0.0, 0.35] {
      assert_true(w.set_plains_relief(relief))
      for region in world_regions {
        let dungeon = w.atlas.unwrap().regions[region.id].unwrap().dungeon
        assert_eq(
          validate_expedition(dungeon, region.id).unreachable_targets,
          0,
        )
        let a = dungeon.terrain_surface.unwrap()
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
  }
}

///|
test "relief applies to cached and future regions and survives world saves" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  assert_true(w.prepare_region(1))
  w.chests[0].opened = true
  let enemies = w.enemies.length()
  let hp = w.player.hp
  let position = (w.player.x, w.player.y)
  assert_true(w.set_plains_relief(0.25))
  assert_eq(w.atlas.unwrap().plains_relief, 0.25)
  assert_true(w.chests[0].opened)
  assert_eq(w.enemies.length(), enemies)
  assert_eq(w.player.hp, hp)
  assert_eq((w.player.x, w.player.y), position)
  assert_true(w.prepare_region(2))
  for id in [0, 1, 2] {
    let a = w.atlas.unwrap().regions[id].unwrap().dungeon.landscape.unwrap()
    let b = generate_landscape(region_seed(42, id), id, plains_relief=0.25)
    assert_eq(a.walk.values, b.walk.values)
  }
  let copy = GameWorld::new(seed=99, hunting_grounds=true)
  assert_true(copy.restore_world_progress(w.serialize_world_progress()))
  assert_eq(copy.atlas.unwrap().plains_relief, 0.25)
  assert_eq(
    copy.dungeon.landscape.unwrap().walk.values,
    w.dungeon.landscape.unwrap().walk.values,
  )
  assert_false(w.set_plains_relief(-0.1))
  assert_false(w.set_plains_relief(1.1))
  assert_false(w.set_plains_relief(0.25))
}

///|
test "old saves default to original relief and malformed relief is rejected" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  let expected = w.dungeon.landscape.unwrap().walk.values.copy()
  let data = @json.parse(w.serialize_world_progress())
  guard data is Object(root) else { fail("object") }
  root.remove("plains_relief")
  assert_true(w.restore_world_progress(data.stringify()))
  assert_eq(w.atlas.unwrap().plains_relief, 1.0)
  assert_eq(w.dungeon.landscape.unwrap().walk.values, expected)
  root["plains_relief"] = 2.0
  assert_false(w.restore_world_progress(data.stringify()))
}
