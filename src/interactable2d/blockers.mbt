///|
pub fn append_circular_interactable_blockers_to_grid(
  grid : @terrain.Grid2D,
  interactables : Array[CircularInteractable],
  tile_size : Double,
) -> Unit {
  for interactable in interactables {
    if not(interactable_role_is_solid(interactable.role)) {
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
