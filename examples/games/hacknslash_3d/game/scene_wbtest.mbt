///|
test "authored scene drives collision, spawn and enemy state and survives floor reset" {
  let world = GameWorld::new(seed=42)
  let source = "{\"version\":1,\"rectangles\":[{\"id\":\"floor\",\"kind\":\"floor\",\"x\":8,\"z\":8,\"width\":32,\"depth\":24},{\"id\":\"wall\",\"kind\":\"wall\",\"x\":20,\"z\":16,\"width\":1,\"depth\":8}],\"spawn\":[12.5,15.5],\"enemies\":[{\"id\":\"enemy\",\"x\":28.5,\"z\":15.5,\"kind\":\"basic\",\"hp\":35}]}"
  world.apply_scene_json(source)
  assert_eq(world.player.x, 12.5 * tile_size)
  assert_true(world.dungeon.grid.get(20, 20) == @terrain.Wall)
  assert_true(world.dungeon.grid.get(19, 20) == @terrain.Floor)
  assert_true(check_wall_collision(world.dungeon.grid, 20.5 * tile_size, 20.5 * tile_size, 12.0))
  assert_eq(world.enemies.length(), 1)
  assert_eq(world.enemies[0].hp, 35)
  world.apply_dungeon(999, 2)
  assert_eq(world.player.x, 12.5 * tile_size)
  assert_eq(world.enemies.length(), 1)
}

///|
test "authored scene rejects invalid payload before mutating the world" {
  let world = GameWorld::new(seed=42)
  let before = world.player.x
  let rejected = try {
    world.apply_scene_json("{\"version\":1,\"rectangles\":[],\"spawn\":[],\"enemies\":[]}")
    false
  } catch { _ => true }
  assert_true(rejected)
  assert_eq(world.player.x, before)
}
