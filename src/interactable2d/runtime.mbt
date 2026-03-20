///|
pub(all) struct CircularInteractable {
  x : Double
  y : Double
  radius : Double
  role : InteractableRole
}

///|
pub(all) struct CircularInteractionFrame {
  actor_x : Double
  actor_y : Double
  pickup_contact_index : Int?
}

///|
pub fn CircularInteractable::new(
  x : Double,
  y : Double,
  radius : Double,
  role : InteractableRole,
) -> CircularInteractable {
  { x, y, radius, role }
}

///|
pub fn resolve_actor_circular_blockers(
  interactables : Array[CircularInteractable],
  actor_x : Double,
  actor_y : Double,
  actor_size : Double,
  can_stand : (Double, Double, Double) -> Bool,
) -> (Double, Double) {
  let mut next_x = actor_x
  let mut next_y = actor_y
  for interactable in interactables {
    if not(interactable_role_blocks_movement(interactable.role)) {
      continue
    }
    match
      resolve_circular_blocker_overlap(
        next_x,
        next_y,
        actor_size,
        interactable.x,
        interactable.y,
        interactable.radius,
      ) {
      Some((blocked_x, blocked_y)) => {
        if can_stand(blocked_x, next_y, actor_size) {
          next_x = blocked_x
        }
        if can_stand(next_x, blocked_y, actor_size) {
          next_y = blocked_y
        }
      }
      None => ()
    }
  }
  (next_x, next_y)
}

///|
pub fn find_first_circular_pickup_index(
  interactables : Array[CircularInteractable],
  actor_x : Double,
  actor_y : Double,
  pickup_radius_sq : Double,
) -> Int? {
  for i = 0; i < interactables.length(); i = i + 1 {
    let interactable = interactables[i]
    if interactable_role_is_pickup(interactable.role) &&
      is_circular_pickup_in_range(
        actor_x,
        actor_y,
        interactable.x,
        interactable.y,
        pickup_radius_sq,
      ) {
      return Some(i)
    }
  }
  None
}

///|
pub fn resolve_circular_interaction_frame(
  interactables : Array[CircularInteractable],
  actor_x : Double,
  actor_y : Double,
  actor_size : Double,
  pickup_radius_sq : Double,
  can_stand : (Double, Double, Double) -> Bool,
) -> CircularInteractionFrame {
  let (resolved_x, resolved_y) = resolve_actor_circular_blockers(
    interactables, actor_x, actor_y, actor_size, can_stand,
  )
  {
    actor_x: resolved_x,
    actor_y: resolved_y,
    pickup_contact_index: find_first_circular_pickup_index(
      interactables, resolved_x, resolved_y, pickup_radius_sq,
    ),
  }
}
