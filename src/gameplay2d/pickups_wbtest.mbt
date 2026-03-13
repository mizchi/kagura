///|
test "apply_builtin_pickup_effect applies score pickup" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  let result = apply_builtin_pickup_effect(ScorePickup, 3, 10, rewards)
  match result {
    Some((next_hp, score_delta, heal_feedback)) => {
      assert_eq(next_hp, 3)
      assert_eq(score_delta, 5)
      assert_false(heal_feedback)
    }
    None => fail("expected score pickup result")
  }
}

///|
test "apply_builtin_pickup_effect clamps health pickup" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  let result = apply_builtin_pickup_effect(HealthPickup, 9, 10, rewards)
  match result {
    Some((next_hp, score_delta, heal_feedback)) => {
      assert_eq(next_hp, 10)
      assert_eq(score_delta, 0)
      assert_true(heal_feedback)
    }
    None => fail("expected health pickup result")
  }
}

///|
test "apply_builtin_pickup_effect leaves equipment pickup unsupported" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  assert_eq(apply_builtin_pickup_effect(EquipmentPickup, 3, 10, rewards), None)
}

///|
test "apply_builtin_pickup_to_actor applies score delta to actor score" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  let result = apply_builtin_pickup_to_actor(ScorePickup, 3, 10, 7, rewards)
  match result {
    Some(application) => {
      assert_eq(application.next_hp, 3)
      assert_eq(application.next_score, 12)
      assert_false(application.heal_feedback)
    }
    None => fail("expected builtin pickup application")
  }
}

///|
test "apply_builtin_pickup_to_actor clamps health and preserves score" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  let result = apply_builtin_pickup_to_actor(HealthPickup, 9, 10, 7, rewards)
  match result {
    Some(application) => {
      assert_eq(application.next_hp, 10)
      assert_eq(application.next_score, 7)
      assert_true(application.heal_feedback)
    }
    None => fail("expected builtin pickup application")
  }
}

///|
test "resolve_pickup_resolution returns builtin result for score pickup" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  match
    resolve_pickup_resolution(
      ScorePickup,
      3,
      10,
      rewards,
      auto_play=false,
      should_equip=false,
      inventory_has_space=true,
      has_previous_equipped=false,
    ) {
    Builtin(next_hp, score_delta, heal_feedback) => {
      assert_eq(next_hp, 3)
      assert_eq(score_delta, 5)
      assert_false(heal_feedback)
    }
    Equipment(_) => fail("expected builtin pickup resolution")
  }
}

///|
test "resolve_pickup_resolution returns equipment plan for equipment pickup" {
  let rewards = PickupRewardConfig::new(score_amount=5, heal_amount=2)
  match
    resolve_pickup_resolution(
      EquipmentPickup,
      3,
      10,
      rewards,
      auto_play=true,
      should_equip=true,
      inventory_has_space=false,
      has_previous_equipped=true,
    ) {
    Equipment(plan) => {
      assert_false(plan.store_incoming)
      assert_true(plan.store_previous_equipped)
      assert_true(plan.equip_incoming)
      assert_true(plan.use_fifo_storage)
    }
    Builtin(_, _, _) => fail("expected equipment pickup resolution")
  }
}

///|
test "plan_equipment_pickup rejects manual pickup when inventory is full" {
  let plan = plan_equipment_pickup(
    auto_play=false,
    should_equip=false,
    inventory_has_space=false,
    has_previous_equipped=false,
  )
  assert_false(plan.store_incoming)
  assert_false(plan.store_previous_equipped)
  assert_false(plan.equip_incoming)
  assert_false(plan.use_fifo_storage)
}

///|
test "plan_equipment_pickup stores autoplay pickups with fifo when full" {
  let plan = plan_equipment_pickup(
    auto_play=true,
    should_equip=false,
    inventory_has_space=false,
    has_previous_equipped=false,
  )
  assert_true(plan.store_incoming)
  assert_false(plan.store_previous_equipped)
  assert_false(plan.equip_incoming)
  assert_true(plan.use_fifo_storage)
}

///|
test "plan_equipment_pickup equips and stores previous item in autoplay" {
  let plan = plan_equipment_pickup(
    auto_play=true,
    should_equip=true,
    inventory_has_space=true,
    has_previous_equipped=true,
  )
  assert_false(plan.store_incoming)
  assert_true(plan.store_previous_equipped)
  assert_true(plan.equip_incoming)
  assert_false(plan.use_fifo_storage)
}
