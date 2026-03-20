///|
pub fn stamp_circular_blockers_on_grid(
  grid : @terrain.Grid2D,
  interactables : Array[CircularInteractable],
  tile_size : Double,
) -> Unit {
  for interactable in interactables {
    if not(interactable_role_blocks_movement(interactable.role)) {
      continue
    }
    @physics2d.append_circular_wall_blocker(
      grid,
      interactable.x,
      interactable.y,
      interactable.radius,
      tile_size,
    )
  }
}
