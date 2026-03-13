///|
pub(all) enum InteractableRole {
  Decoration
  Blocking
  Pickup
} derive(Eq, Show)

///|
pub(all) enum InteractableAnchor {
  StartRoomCenter
  LargestNonStartRoomCenter
  BossRoomCenter
  TreasureRoomCenter
} derive(Eq, Show)

///|
pub(all) enum InteractablePickupEffect {
  ScorePickup
  HealthPickup
  EquipmentPickup
} derive(Eq, Show)

///|
pub fn interactable_role_from_string(value : String) -> InteractableRole? {
  match value {
    "decoration" | "decor" => Some(Decoration)
    "blocking" | "blocker" => Some(Blocking)
    "pickup" | "loot" => Some(Pickup)
    _ => None
  }
}

///|
pub fn interactable_anchor_from_string(value : String) -> InteractableAnchor? {
  match value {
    "start_room" | "start" => Some(StartRoomCenter)
    "largest_non_start_room" | "largest_room" => Some(LargestNonStartRoomCenter)
    "boss_room" | "boss" => Some(BossRoomCenter)
    "treasure_room" | "treasure" => Some(TreasureRoomCenter)
    _ => None
  }
}

///|
pub fn interactable_pickup_effect_from_string(
  value : String,
) -> InteractablePickupEffect? {
  match value {
    "score" => Some(ScorePickup)
    "health" | "heal" => Some(HealthPickup)
    "equipment" | "equip" | "gear" => Some(EquipmentPickup)
    _ => None
  }
}

///|
pub fn interactable_role_is_solid(role : InteractableRole) -> Bool {
  role == Blocking
}

///|
pub fn interactable_role_is_pickup(role : InteractableRole) -> Bool {
  role == Pickup
}

///|
pub fn circular_interactable_can_pickup(
  actor_x : Double,
  actor_y : Double,
  target_x : Double,
  target_y : Double,
  pickup_radius_sq : Double,
) -> Bool {
  let dx = target_x - actor_x
  let dy = target_y - actor_y
  dx * dx + dy * dy < pickup_radius_sq
}

///|
pub fn resolve_circular_interactable_block(
  actor_x : Double,
  actor_y : Double,
  actor_size : Double,
  blocker_x : Double,
  blocker_y : Double,
  blocker_radius : Double,
) -> (Double, Double)? {
  let dx = actor_x - blocker_x
  let dy = actor_y - blocker_y
  let min_dist = actor_size / 2.0 + blocker_radius
  let dist_sq = dx * dx + dy * dy
  if dist_sq >= min_dist * min_dist {
    return None
  }
  if dist_sq <= 0.000001 {
    return Some((blocker_x + min_dist, blocker_y))
  }
  let dist = dist_sq.sqrt()
  let nx = dx / dist
  let ny = dy / dist
  Some((blocker_x + nx * min_dist, blocker_y + ny * min_dist))
}
