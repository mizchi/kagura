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
