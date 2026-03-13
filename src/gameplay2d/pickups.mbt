pub type PickupEffect = @interactable2d.InteractablePickupEffect

///|
pub(all) struct PickupRewardConfig {
  score_amount : Int
  heal_amount : Int
} derive(Eq, Show)

///|
pub fn PickupRewardConfig::new(
  score_amount~ : Int,
  heal_amount~ : Int,
) -> PickupRewardConfig {
  { score_amount, heal_amount }
}

///|
pub(all) struct EquipmentPickupPlan {
  store_incoming : Bool
  store_previous_equipped : Bool
  equip_incoming : Bool
  use_fifo_storage : Bool
} derive(Eq, Show)

///|
pub fn plan_equipment_pickup(
  auto_play~ : Bool,
  should_equip~ : Bool,
  inventory_has_space~ : Bool,
  has_previous_equipped~ : Bool,
) -> EquipmentPickupPlan {
  if not(auto_play) {
    return {
      store_incoming: inventory_has_space,
      store_previous_equipped: false,
      equip_incoming: false,
      use_fifo_storage: false,
    }
  }
  if should_equip {
    return {
      store_incoming: false,
      store_previous_equipped: has_previous_equipped,
      equip_incoming: true,
      use_fifo_storage: not(inventory_has_space),
    }
  }
  {
    store_incoming: true,
    store_previous_equipped: false,
    equip_incoming: false,
    use_fifo_storage: not(inventory_has_space),
  }
}

///|
pub fn apply_builtin_pickup_effect(
  effect : PickupEffect,
  actor_hp : Int,
  actor_max_hp : Int,
  rewards : PickupRewardConfig,
) -> (Int, Int, Bool)? {
  match effect {
    ScorePickup => Some((actor_hp, rewards.score_amount, false))
    HealthPickup => {
      let next_hp = if actor_hp + rewards.heal_amount > actor_max_hp {
        actor_max_hp
      } else {
        actor_hp + rewards.heal_amount
      }
      Some((next_hp, 0, true))
    }
    EquipmentPickup => None
  }
}
