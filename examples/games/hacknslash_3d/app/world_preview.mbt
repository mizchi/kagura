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
