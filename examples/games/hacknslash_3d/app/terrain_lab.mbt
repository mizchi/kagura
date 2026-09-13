///|
struct TerrainLabState {
  mut editing : Bool
  mut config : @terrain3d.TerrainConfig
  mut revision : Int
  mut generation_ms : Double
  mut stats : @terrain3d.HeightFieldStats
}

///|
fn TerrainLabState::new() -> TerrainLabState {
  {
    editing: false,
    config: { ..@terrain3d.TerrainConfig::default(), pattern: @terrain3d.Flat, },
    revision: 0,
    generation_ms: 0.0,
    stats: {
      minimum: 0.0,
      maximum: 0.0,
      max_slope: 0.0,
      triangles: @game.map_cols * @game.map_rows * 2,
    },
  }
}

///|
fn terrain_pattern_index(pattern : @terrain3d.TerrainPattern) -> Int {
  match pattern {
    Flat => 0
    Perlin => 1
    DiamondSquare => 2
    Voronoi => 3
    Hybrid => 4
  }
}

///|
fn GameState::apply_terrain_lab(
  self : GameState,
  command : Array[Double],
) -> Bool {
  if command.length() != 5 ||
    command.any(v => v.is_nan() || v.abs() > 2147483646.0) {
    return false
  }
  let index = command[0].to_int()
  if command[0] != index.to_double() || index < 0 || index > 4 {
    return false
  }
  if self.world.atlas is None || self.world.authored_scene is Some(_) {
    return false
  }
  let start = hunter_terrain_clock()
  let config : @terrain3d.TerrainConfig = {
    pattern: match index {
      1 => Perlin
      2 => DiamondSquare
      3 => Voronoi
      4 => Hybrid
      _ => Flat
    },
    seed: command[1].to_int(),
    amplitude: command[2].clamp(min=0.0, max=8.0),
    scale: command[3].clamp(min=6.0, max=48.0),
    roughness: command[4].clamp(min=0.1, max=0.85),
  }
  self.terrain_lab.config = config
  let camera = self.camera
  if self.world.set_hunting_terrain(config) {
    self.rebuild_dungeon_rendering()
  }
  self.camera = camera
  self.update_combat_camera()
  self.refresh_terrain_stats()
  self.terrain_lab.revision += 1
  self.terrain_lab.generation_ms = (hunter_terrain_clock() - start).max(0.0)
  hunter_save_terrain_preferences(config.to_json().stringify())
  true
}

///|
fn GameState::refresh_terrain_stats(self : GameState) -> Unit {
  self.terrain_lab.stats = match self.world.dungeon.terrain_surface {
    Some(surface) => surface.statistics()
    None =>
      {
        minimum: 0.0,
        maximum: 0.0,
        max_slope: 0.0,
        triangles: @game.map_cols * @game.map_rows * 2,
      }
  }
}

///|
fn GameState::restore_terrain_lab(self : GameState, source : String) -> Unit {
  try {
    let config : @terrain3d.TerrainConfig = @json.from_json(@json.parse(source))
    ignore(
      self.apply_terrain_lab([
        terrain_pattern_index(config.pattern).to_double(),
        config.seed.to_double(),
        config.amplitude,
        config.scale,
        config.roughness,
      ]),
    )
  } catch {
    _ => ()
  }
}

///|
struct TerrainLabView {
  editing : Bool
  enabled : Bool
  pattern : Int
  seed : Int
  amplitude : Double
  scale : Double
  roughness : Double
  revision : Int
  generation_ms : Double
  stats : @terrain3d.HeightFieldStats
  player_height : Double
} derive(ToJson)

///|
fn GameState::terrain_lab_view(self : GameState) -> TerrainLabView {
  let lab = self.terrain_lab
  {
    editing: lab.editing,
    enabled: self.world.atlas is Some(_) && self.world.authored_scene is None,
    pattern: terrain_pattern_index(lab.config.pattern),
    seed: lab.config.seed,
    amplitude: lab.config.amplitude,
    scale: lab.config.scale,
    roughness: lab.config.roughness,
    revision: lab.revision,
    generation_ms: lab.generation_ms,
    stats: lab.stats,
    player_height: @game.get_tile_height(
      self.world.dungeon,
      self.world.player.x,
      self.world.player.y,
    ),
  }
}
