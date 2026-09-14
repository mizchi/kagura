///|
/// Rebuild geometry only: combat progress, opened caches and loot retain identity.
/// The caller pauses play and invalidates render caches after this operation.
pub fn GameWorld::set_plains_relief(self : GameWorld, value : Double) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if !self.hunting_grounds ||
    self.authored_scene is Some(_) ||
    atlas.generator_version < 2 ||
    value.is_nan() ||
    value < 0.0 ||
    value > 1.0 ||
    (atlas.plains_relief == value && atlas.elevation is None) {
    return false
  }
  self.capture_region()
  atlas.plains_relief = value
  atlas.elevation = None
  atlas.revision += 1
  for entry in atlas.regions {
    guard entry is Some(region) else { continue }
    let generated = generate_world_region(
      region.seed,
      region.id,
      generator_version=atlas.generator_version,
      plains_relief=value,
    )
    let dungeon = region.dungeon
    dungeon.grid = generated.grid
    dungeon.terrain_surface = generated.terrain_surface
    dungeon.landscape = generated.landscape
    for enemy in region.enemies {
      let (x, y) = hunting_safe_position(dungeon, enemy.x, enemy.y, enemy.size)
      enemy.x = x
      enemy.y = y
    }
    for item in region.items {
      let (x, y) = hunting_safe_position(dungeon, item.x, item.y, 4.0)
      item.x = x
      item.y = y
    }
  }
  let (x, y) = hunting_safe_position(
    self.dungeon,
    self.player.x,
    self.player.y,
    self.player.size,
  )
  self.player.x = x
  self.player.y = y
  self.auto_nav_path = []
  self.auto_nav_index = 0
  self.auto_nav_target = None
  for zombie in self.summons.zombies {
    let summon = zombie.body
    let (x, y) = hunting_safe_position(
      self.dungeon,
      summon.x,
      summon.y,
      summon.size,
    )
    summon.x = x
    summon.y = y
  }
  true
}
