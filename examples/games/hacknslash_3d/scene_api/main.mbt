///|
pub fn create(source : String) -> @game.GameWorld {
  let world = @game.GameWorld::new(seed=42)
  try { world.apply_scene_json(source) } catch { error => abort(error.to_string()) }
  world.mode = @game.Playing
  world
}

///|
pub fn snapshot(world : @game.GameWorld) -> String {
  world.scene_snapshot_json()
}

///|
pub fn blocked(world : @game.GameWorld, x : Double, z : Double) -> Bool {
  @game.check_wall_collision(world.dungeon.grid, x * @game.tile_size, z * @game.tile_size, 12.0)
}

///|
pub fn step(world : @game.GameWorld, x : Double, z : Double) -> Unit {
  world.tick(x, z)
}
