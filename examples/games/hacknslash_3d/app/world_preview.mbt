///|
/// Deterministic playable previews for boundary crossing and waypoint UI captures.
fn apply_world_preview(state : GameState, id : Int, boundary : Bool) -> Unit {
  guard state.world.atlas is Some(atlas) else { return }
  if id < 0 || id >= @game.world_regions.length() {
    return
  }
  state.world.mode = @game.Playing
  if id != atlas.current {
    ignore(state.world.prepare_region(id))
    let (x, y) = @game.world_waypoint_position(id)
    ignore(state.world.enter_region(id, x, y))
  }
  ignore(state.world.activate_nearby_waypoint())
  if boundary {
    state.world.player.x = 75.5 * tile_size
    state.world.player.y = 40.5 * tile_size
    state.world.enemies = []
  }
  state.rebuild_dungeon_rendering()
}

///|
/// Playable combat practice: regular AI on an open clearing, with learned spells.
fn apply_hunter_arts_preview(state : GameState) -> Unit {
  let w = state.world
  w.mode = @game.Playing
  for x in 12..<34 {
    for z in 40..<58 {
      w.dungeon.grid.set(x, z, @terrain.Floor)
    }
  }
  w.enemies = [
    @game.make_enemy(w.player.x + 54.0, w.player.y, @game.Basic, 100, 0.0, 10.0),
    @game.make_enemy(
      w.player.x + 72.0,
      w.player.y + 16.0,
      @game.Fast,
      100,
      0.0,
      10.0,
    ),
    @game.make_enemy(
      w.player.x + 92.0,
      w.player.y,
      @game.Ranged,
      100,
      0.0,
      10.0,
    ),
  ]
  for id in [@game.ChainLightning, @game.HomingMissile, @game.Counter] {
    ignore(w.skills.learn_level_up_skill(id))
  }
  w.player.hp = 100
  w.player_stats = { ..w.player_stats, max_hp: 100, }
  state.rebuild_dungeon_rendering()
}

///|
/// Close combat fixture: real AI, no autoplay, generous health, reproducible spacing.
fn apply_melee_preview(state : GameState) -> Unit {
  apply_hunter_arts_preview(state)
  let w = state.world
  w.player.facing_angle = 0.0
  w.enemies = [
    @game.make_enemy(
      w.player.x + 23.0,
      w.player.y + 5.0,
      @game.Basic,
      160,
      0.22,
      10.0,
    ),
    @game.make_enemy(
      w.player.x + 42.0,
      w.player.y - 20.0,
      @game.Fast,
      160,
      0.16,
      10.0,
    ),
  ]
  state.camera = state.camera.with_distance(10.5)
}

///|
/// A live wolf encounter for checking pursuit, warned bites and counterattacks.
fn apply_wolf_combat_preview(state : GameState) -> Unit {
  apply_hunter_arts_preview(state)
  let w = state.world
  w.player.facing_angle = 0.0
  w.enemies = [
    @game.make_enemy(w.player.x + 64.0, w.player.y, @game.Wolf, 24, 0.9, 11.0),
  ]
  state.camera = state.camera.with_distance(9.0)
}

///|
fn apply_hunting_site_preview(
  state : GameState,
  id : Int,
  peaceful : Bool,
  overview : Bool,
) -> Unit {
  let site = @game.hunting_sites[id.max(0).min(3)]
  state.world.mode = @game.Playing
  state.world.auto_play = false
  if peaceful {
    state.world.enemies.clear()
  }
  if state.world.chests.length() <= site.id {
    return
  }
  let chest = state.world.chests[site.id]
  state.world.player.x = chest.x
  state.world.player.y = chest.y + 24.0
  state.world.player.facing_angle = -@math.PI / 2.0
  state.camera = state.camera
    .with_distance(if overview { 18.0 } else { 11.0 })
    .orbit(0.35 - state.camera.yaw, 0.85 - state.camera.pitch)
    .with_target(
      @math3d.Vec3::new(
        site.x.to_double() + 0.5,
        0.35,
        site.z.to_double() + 0.5,
      ),
    )
  state.motion_preview = overview
}

///|
/// Repeatable woodland viewpoint, with live movement and terrain/camera editors.
fn apply_hunting_terrain_preview(state : GameState) -> Unit {
  state.world.mode = @game.Playing
  state.world.auto_play = false
  state.world.enemies.clear()
  // Open woodland north of the road, away from the protected settlement pads.
  state.world.player.x = 53.5 * tile_size
  state.world.player.y = 16.5 * tile_size
  for z in 15..<18 {
    for x in 52..<55 {
      state.world.dungeon.grid.set(x, z, @terrain.Floor)
    }
  }
  state.world.player.facing_angle = -@math.PI / 2.0
  state.camera = state.camera
    .orbit(0.35 - state.camera.yaw, 0.55 - state.camera.pitch)
    .with_distance(22.0)
  state.camera_settings.quarter = {
    ..state.camera_settings.quarter,
    tilt: 0.55 * 180.0 / @math.PI,
    distance: 22.0,
  }
  state.rebuild_dungeon_rendering()
  state.update_combat_camera()
}

///|
/// A live zombie encounter for checking pursuit, warned pounces and counterattacks.
fn apply_zombie_combat_preview(state : GameState) -> Unit {
  apply_hunter_arts_preview(state)
  let w = state.world
  w.player.facing_angle = 0.0
  w.enemies = [
    @game.make_enemy(
      w.player.x + 76.0,
      w.player.y,
      @game.Zombie,
      24,
      0.55,
      11.0,
    ),
  ]
  state.camera = state.camera.with_distance(9.0)
}

///|
/// Interactive summon sandbox, with the same input and simulation as a saved hunter.
fn apply_player_summon_preview(state : GameState, peaceful : Bool) -> Unit {
  apply_hunter_arts_preview(state)
  let w = state.world
  w.apply_archetype(@game.CharacterArchetype::Summoner)
  state.sync_character_equipment()
  w.player.facing_angle = 0.0
  w.enemies = if peaceful {
    []
  } else {
    [
      @game.make_enemy(
        w.player.x + 100.0,
        w.player.y - 20.0,
        @game.Basic,
        180,
        0.55,
        11.0,
      ),
      @game.make_enemy(
        w.player.x + 115.0,
        w.player.y + 22.0,
        @game.Basic,
        180,
        0.55,
        11.0,
      ),
      @game.make_enemy(
        w.player.x + 140.0,
        w.player.y,
        @game.Ranged,
        160,
        0.4,
        10.0,
      ),
    ]
  }
  // Allow the player to complete the first summon before ranged actors commit aim.
  for enemy in w.enemies {
    enemy.shoot_cooldown = 120
  }
  state.camera = state.camera.with_distance(11.0)
}
