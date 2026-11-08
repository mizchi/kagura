///|
pub type PickupEffect = @interactable2d.InteractablePickupEffect

///|
#derive(Eq, Debug)
pub(all) struct PickupRewardConfig {
  score_amount : Int32
  heal_amount : Int32
}

///|
pub impl Show for PickupRewardConfig with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Eq, Debug)
pub(all) struct BuiltinPickupResult {
  next_hp : Int32
  next_score : Int32
  heal_feedback : Bool
}

///|
pub impl Show for BuiltinPickupResult with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn PickupRewardConfig::new(
  score_amount~ : Int32,
  heal_amount~ : Int32,
) -> PickupRewardConfig {
  { score_amount, heal_amount, }
}

///|
#derive(Eq, Debug)
pub(all) struct EquipmentPickupPlan {
  store_incoming : Bool
  store_previous_equipped : Bool
  equip_incoming : Bool
  use_fifo_storage : Bool
}

///|
pub impl Show for EquipmentPickupPlan with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Eq, Debug)
pub(all) enum PickupResolution {
  Builtin(Int32, Int32, Bool)
  Equipment(EquipmentPickupPlan)
}

///|
pub impl Show for PickupResolution with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn plan_equipment_pickup(
  auto_play~ : Bool,
  should_equip~ : Bool,
  inventory_has_space~ : Bool,
  has_previous_equipped~ : Bool,
) -> EquipmentPickupPlan {
  if !auto_play {
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
      use_fifo_storage: !inventory_has_space,
    }
  }
  {
    store_incoming: true,
    store_previous_equipped: false,
    equip_incoming: false,
    use_fifo_storage: !inventory_has_space,
  }
}

///|
pub fn resolve_builtin_pickup_effect(
  effect : PickupEffect,
  actor_hp : Int32,
  actor_max_hp : Int32,
  rewards : PickupRewardConfig,
) -> (Int32, Int32, Bool)? {
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
pub fn apply_builtin_pickup(
  effect : PickupEffect,
  actor_hp : Int32,
  actor_max_hp : Int32,
  actor_score : Int32,
  rewards : PickupRewardConfig,
) -> BuiltinPickupResult? {
  match resolve_builtin_pickup_effect(effect, actor_hp, actor_max_hp, rewards) {
    Some((next_hp, score_delta, heal_feedback)) =>
      Some({ next_hp, next_score: actor_score + score_delta, heal_feedback, })
    None => None
  }
}

///|
pub fn resolve_pickup(
  effect : PickupEffect,
  actor_hp : Int32,
  actor_max_hp : Int32,
  rewards : PickupRewardConfig,
  auto_play~ : Bool,
  should_equip~ : Bool,
  inventory_has_space~ : Bool,
  has_previous_equipped~ : Bool,
) -> PickupResolution {
  match effect {
    ScorePickup | HealthPickup =>
      match
        resolve_builtin_pickup_effect(effect, actor_hp, actor_max_hp, rewards) {
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

///|
pub extend PickupRewardConfig with Eq::{not_equal, equal}

///|
pub extend PickupRewardConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PickupRewardConfig with Show::{to_string, output}

///|
pub extend BuiltinPickupResult with Eq::{not_equal, equal}

///|
pub extend BuiltinPickupResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BuiltinPickupResult with Show::{to_string, output}

///|
pub extend EquipmentPickupPlan with Eq::{not_equal, equal}

///|
pub extend EquipmentPickupPlan with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EquipmentPickupPlan with Show::{to_string, output}

///|
pub extend PickupResolution with Eq::{not_equal, equal}

///|
pub extend PickupResolution with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PickupResolution with Show::{to_string, output}
