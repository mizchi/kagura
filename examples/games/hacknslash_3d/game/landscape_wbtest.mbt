///|
test "natural coast blocks walking while bridge decks cross real river beds" {
  let dungeon = generate_world_region(42, 0)
  let land = dungeon.landscape.unwrap()
  assert_true(land.bridges.length() >= 2)
  assert_eq(land.kind(1, 49), Sea)
  assert_true(
    check_wall_collision(dungeon.grid, 1.5 * tile_size, 49.5 * tile_size, 12.0),
  )
  let bridge = land.bridges[0]
  for i in 0..<=30 {
    let t = i.to_double() / 30.0
    let x = bridge.ax + (bridge.bx - bridge.ax) * t
    let z = bridge.az + (bridge.bz - bridge.az) * t
    assert_false(
      check_wall_collision(dungeon.grid, x * tile_size, z * tile_size, 12.0),
    )
  }
  let x = (bridge.ax + bridge.bx) * 0.5
  let z = (bridge.az + bridge.bz) * 0.5
  assert_true(
    get_tile_height(dungeon, x * tile_size, z * tile_size) -
    land.bed.sample(x, z) >
    2.0,
  )
}

///|
test "cave passage connects both mouths and separates floor from mountain canopy" {
  let dungeon = generate_world_region(42, 0)
  let land = dungeon.landscape.unwrap()
  let cave = land.cave
  let start = @terrain.Point::{ x: cave.ax.to_int(), y: cave.az.to_int(), }
  let end = @terrain.Point::{ x: cave.bx.to_int(), y: cave.bz.to_int(), }
  assert_true(@pathfind.find_path(dungeon.grid, start, end) is Some(_))
  for i in 0..<=30 {
    let t = i.to_double() / 30.0
    let x = cave.ax + (cave.bx - cave.ax) * t
    let z = cave.az + (cave.bz - cave.az) * t
    assert_false(
      check_wall_collision(dungeon.grid, x * tile_size, z * tile_size, 12.0),
    )
  }
  assert_true(land.kind(61, 17) == CaveFloor)
  assert_true(land.kind(65, 17) == Mountain)
}

///|
test "natural geography retains legacy version two saves" {
  let old = generate_world_region(42, 0, generator_version=2)
  assert_true(old.landscape is None)
  assert_eq(
    old.terrain_surface.unwrap().values,
    expedition_surface(42, 0).values,
  )
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  assert_eq(w.atlas.unwrap().generator_version, 3)
  assert_true(w.restore_world_progress(w.serialize_world_progress()))
  assert_true(w.dungeon.landscape is Some(_))
}

///|
test "all bridge centers and cave approaches remain traversable across regions and seeds" {
  for seed in [1, 42, 43, 97, -19] {
    for region in world_regions {
      let dungeon = generate_world_region(
        region_seed(seed, region.id),
        region.id,
      )
      let land = dungeon.landscape.unwrap()
      for bridge in land.bridges {
        for i in 0..<=24 {
          let t = i.to_double() / 24.0
          let x = bridge.ax + (bridge.bx - bridge.ax) * t
          let z = bridge.az + (bridge.bz - bridge.az) * t
          if x < 0.5 || x > 99.5 || z < 0.5 || z > 79.5 {
            continue
          }
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
      let (wx, wz) = world_waypoint_position(region.id)
      let start = @terrain.Point::{
        x: (wx / tile_size).to_int(),
        y: (wz / tile_size).to_int(),
      }
      for z in [11, 26] {
        assert_true(
          @pathfind.find_path(dungeon.grid, start, { x: 61, y: z, }) is Some(_),
        )
      }
    }
  }
}
