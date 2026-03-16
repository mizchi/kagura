///|
test "resolve_circular_blockers_for_actor applies blocking in sequence" {
  let interactables = [
    CircularInteractable::new(32.0, 48.0, 8.0, Blocking),
    CircularInteractable::new(48.0, 48.0, 8.0, Blocking),
  ]
  let (x, y) = resolve_circular_blockers_for_actor(
    interactables,
    32.0,
    48.0,
    12.0,
    fn(_, _, _) { true },
  )
  assert_true(x > 32.0)
  assert_eq(y, 48.0)
}

///|
test "resolve_circular_blockers_for_actor respects can_stand callback" {
  let interactables = [CircularInteractable::new(32.0, 48.0, 8.0, Blocking)]
  let (x, y) = resolve_circular_blockers_for_actor(
    interactables,
    32.0,
    48.0,
    12.0,
    fn(next_x, _, _) { next_x < 40.0 },
  )
  assert_eq(x, 32.0)
  assert_eq(y, 48.0)
}

///|
test "find_first_circular_pickup_contact_index returns first pickup in range" {
  let interactables = [
    CircularInteractable::new(32.0, 48.0, 8.0, Decoration),
    CircularInteractable::new(36.0, 48.0, 8.0, Pickup),
    CircularInteractable::new(34.0, 48.0, 8.0, Pickup),
  ]
  assert_eq(
    find_first_circular_pickup_contact_index(interactables, 32.0, 48.0, 400.0),
    Some(1),
  )
}

///|
test "find_first_circular_pickup_contact_index ignores non pickup roles" {
  let interactables = [CircularInteractable::new(36.0, 48.0, 8.0, Blocking)]
  assert_eq(
    find_first_circular_pickup_contact_index(interactables, 32.0, 48.0, 400.0),
    None,
  )
}

///|
test "resolve_circular_interactable_frame returns resolved actor position and pickup contact" {
  let interactables = [
    CircularInteractable::new(32.0, 48.0, 8.0, Blocking),
    CircularInteractable::new(52.0, 48.0, 8.0, Pickup),
  ]
  let result = resolve_circular_interactable_frame(
    interactables,
    32.0,
    48.0,
    12.0,
    400.0,
    fn(_, _, _) { true },
  )
  assert_true(result.actor_x > 32.0)
  assert_eq(result.actor_y, 48.0)
  assert_eq(result.pickup_contact_index, Some(1))
}

///|
test "resolve_circular_interactable_frame returns none when no pickup is in range" {
  let interactables = [CircularInteractable::new(32.0, 48.0, 8.0, Blocking)]
  let result = resolve_circular_interactable_frame(
    interactables,
    32.0,
    48.0,
    12.0,
    400.0,
    fn(_, _, _) { true },
  )
  assert_true(result.actor_x > 32.0)
  assert_eq(result.pickup_contact_index, None)
}
