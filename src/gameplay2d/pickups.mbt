///|
pub type PickupEffect = @interactable2d.InteractablePickupEffect

///|
pub(all) struct PickupRewardConfig {
  score_amount : Int
  heal_amount : Int
} derive(Eq, Show)

///|
pub(all) struct BuiltinPickupApplication {
  next_hp : Int
  next_score : Int
  heal_feedback : Bool
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
pub(all) enum PickupResolution {
  Builtin(Int, Int, Bool)
  Equipment(EquipmentPickupPlan)
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

///|
pub fn apply_builtin_pickup_to_actor(
  effect : PickupEffect,
  actor_hp : Int,
  actor_max_hp : Int,
  actor_score : Int,
  rewards : PickupRewardConfig,
) -> BuiltinPickupApplication? {
  match apply_builtin_pickup_effect(effect, actor_hp, actor_max_hp, rewards) {
    Some((next_hp, score_delta, heal_feedback)) =>
      Some({ next_hp, next_score: actor_score + score_delta, heal_feedback })
    None => None
  }
}

///|
pub fn resolve_pickup_resolution(
  effect : PickupEffect,
  actor_hp : Int,
  actor_max_hp : Int,
  rewards : PickupRewardConfig,
  auto_play~ : Bool,
  should_equip~ : Bool,
  inventory_has_space~ : Bool,
  has_previous_equipped~ : Bool,
) -> PickupResolution {
  match effect {
    ScorePickup | HealthPickup =>
      match
        apply_builtin_pickup_effect(effect, actor_hp, actor_max_hp, rewards) {
        Some((next_hp, score_delta, heal_feedback)) =>
          Builtin(next_hp, score_delta, heal_feedback)
        None => abort("builtin pickup effect must resolve")
      }
    EquipmentPickup =>
      Equipment(
        plan_equipment_pickup(
          auto_play~,
          should_equip~,
          inventory_has_space~,
          has_previous_equipped~,
        ),
      )
  }
}
