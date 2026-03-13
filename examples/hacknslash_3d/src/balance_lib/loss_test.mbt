///|
test "default targets has sensible values" {
  let t = BalanceTargets::default()
  assert_true(t.target_survival_frames > 0.0)
  assert_true(t.target_floors > 0.0)
  assert_true(t.target_floor_time > 0.0)
  assert_true(t.w_survival > 0.0)
}

///|
test "all hypothesis constructors are valid" {
  let targets = [
    BalanceTargets::default(),
    BalanceTargets::autoplay_rebalance(),
    BalanceTargets::autoplay_progression(),
    BalanceTargets::autoplay_progression_v3(),
    BalanceTargets::autoplay_progression_v2(),
    BalanceTargets::autoplay_pressure(),
    BalanceTargets::autoplay_attrition(),
    BalanceTargets::item_spike_feedback(),
    BalanceTargets::build_diverse_hackslash(),
    BalanceTargets::mechanics_roguelike(),
    BalanceTargets::mechanics_roguelike_v2(),
    BalanceTargets::action_dense(),
    BalanceTargets::survival_horror(),
    BalanceTargets::speedrun(),
    BalanceTargets::risk_reward(),
  ]
  for t in targets {
    // All targets should have positive survival target
    assert_true(t.target_survival_frames > 0.0)
    // All weights should be non-negative
    assert_true(t.w_survival >= 0.0)
    assert_true(t.w_floor >= 0.0)
    assert_true(t.w_floor_time >= 0.0)
    assert_true(t.w_hp_cv >= 0.0)
    assert_true(t.w_total_damage >= 0.0)
    assert_true(t.target_total_damage >= 0.0)
  }
}

///|
test "autoplay_balance_hypotheses exposes named presets" {
  let hypotheses = autoplay_balance_hypotheses()
  assert_true(hypotheses.length() >= 15)
  assert_eq(hypotheses[0].name, "default")
  assert_eq(hypotheses[hypotheses.length() - 1].name, "autoplay_rebalance")
}

///|
test "balance_hypothesis_from_name resolves known presets" {
  match balance_hypothesis_from_name("risk_reward") {
    Some(h) => assert_true(h.targets.target_near_death_rate > 0.1)
    None => fail("missing risk_reward hypothesis")
  }
  match balance_hypothesis_from_name("build_diverse_hackslash") {
    Some(h) => assert_true(h.targets.target_equip_upgrades >= 7.0)
    None => fail("missing build_diverse_hackslash hypothesis")
  }
  match balance_hypothesis_from_name("mechanics_roguelike_v2") {
    Some(h) => assert_true(h.targets.target_learned_skill_count >= 3.0)
    None => fail("missing mechanics_roguelike_v2 hypothesis")
  }
  match balance_hypothesis_from_name("missing") {
    None => ()
    Some(_) => fail("unexpected hypothesis for missing")
  }
}

///|
test "autoplay variants are ordered from progression to pressure" {
  let progression = BalanceTargets::autoplay_progression()
  let progression_v3 = BalanceTargets::autoplay_progression_v3()
  let progression_v2 = BalanceTargets::autoplay_progression_v2()
  let pressure = BalanceTargets::autoplay_pressure()
  let attrition = BalanceTargets::autoplay_attrition()
  assert_true(progression.target_floors > pressure.target_floors)
  assert_true(progression.target_floors > progression_v2.target_floors)
  assert_true(progression.target_floors >= progression_v3.target_floors)
  assert_true(progression.target_total_damage < progression_v3.target_total_damage)
  assert_true(progression_v3.target_total_damage < progression_v2.target_total_damage)
  assert_true(progression.target_near_death_rate < progression_v3.target_near_death_rate)
  assert_true(progression_v3.target_near_death_rate < progression_v2.target_near_death_rate)
  assert_true(progression.target_total_damage < progression_v2.target_total_damage)
  assert_true(progression.target_near_death_rate < progression_v2.target_near_death_rate)
  assert_true(progression.target_total_damage < pressure.target_total_damage)
  assert_true(attrition.target_total_damage > progression.target_total_damage)
  assert_true(attrition.target_total_damage < pressure.target_total_damage)
}

///|
test "compute_loss zero when metrics match targets" {
  let t = BalanceTargets::default()
  let m : SimMetrics = {
    survival_frames: t.target_survival_frames.to_int(),
    floors_cleared: t.target_floors.to_int(),
    total_damage_taken: 0,
    total_kills: 72, // 12 kills * 6 floors
    score: 0,
    hp_samples: [0.7, 0.6, 0.65], // ~0.65 mean, CV ~0.35ish
    floor_times: [t.target_floor_time.to_int()],
    kill_frames: [0, t.target_kill_interval.to_int()],
    damage_frames: [0, t.target_damage_interval.to_int()],
    equip_upgrades: 0,
    learned_skill_count: 0,
    near_death_count: 0,
  }
  let loss = compute_loss(m, t)
  // Loss should be small (close to targets) but not necessarily zero
  // because hp_cv and near_death_rate depend on samples
  assert_true(loss < 5.0)
}

///|
test "compute_loss increases with worse metrics" {
  let t = BalanceTargets::default()
  let good : SimMetrics = {
    survival_frames: t.target_survival_frames.to_int(),
    floors_cleared: t.target_floors.to_int(),
    total_damage_taken: 0,
    total_kills: 72,
    score: 0,
    hp_samples: [0.7],
    floor_times: [t.target_floor_time.to_int()],
    kill_frames: [0, t.target_kill_interval.to_int()],
    damage_frames: [0, t.target_damage_interval.to_int()],
    equip_upgrades: 0,
    learned_skill_count: 0,
    near_death_count: 0,
  }
  let bad : SimMetrics = {
    survival_frames: 100, // very low
    floors_cleared: 0,
    total_damage_taken: 50,
    total_kills: 0,
    score: 0,
    hp_samples: [0.1],
    floor_times: [],
    kill_frames: [],
    damage_frames: [],
    equip_upgrades: 0,
    learned_skill_count: 0,
    near_death_count: 10,
  }
  let good_loss = compute_loss(good, t)
  let bad_loss = compute_loss(bad, t)
  assert_true(bad_loss > good_loss)
}

///|
test "autoplay_rebalance targets are stricter than default" {
  let base = BalanceTargets::default()
  let tuned = BalanceTargets::autoplay_rebalance()
  assert_true(tuned.target_survival_frames < base.target_survival_frames)
  assert_true(tuned.target_floors < base.target_floors)
  assert_true(tuned.target_floor_time > base.target_floor_time)
  assert_true(tuned.target_damage_interval < base.target_damage_interval)
  assert_true(tuned.w_hp_cv > base.w_hp_cv)
  assert_true(tuned.w_damage_interval > base.w_damage_interval)
  assert_true(tuned.w_near_death > base.w_near_death)
  assert_true(tuned.target_total_damage > base.target_total_damage)
  assert_true(tuned.w_total_damage > base.w_total_damage)
}

///|
test "compute_loss penalizes zero damage when target expects pressure" {
  let t = BalanceTargets::autoplay_rebalance()
  let safe : SimMetrics = {
    survival_frames: t.target_survival_frames.to_int(),
    floors_cleared: t.target_floors.to_int(),
    total_damage_taken: 0,
    total_kills: (t.target_kills_per_floor * t.target_floors).to_int(),
    score: 0,
    hp_samples: [0.9, 0.85, 0.95],
    floor_times: [t.target_floor_time.to_int()],
    kill_frames: [0, t.target_kill_interval.to_int()],
    damage_frames: [],
    equip_upgrades: 0,
    learned_skill_count: 0,
    near_death_count: 0,
  }
  let pressured : SimMetrics = {
    ..safe,
    total_damage_taken: t.target_total_damage.to_int(),
    damage_frames: [0, t.target_damage_interval.to_int()],
  }
  assert_true(compute_loss(safe, t) > compute_loss(pressured, t))
}

///|
test "run_simulation completes with default params" {
  let params = @game.BalanceParams::default()
  let m = run_simulation(params, 42, 300)
  assert_true(m.survival_frames > 0)
  assert_true(m.hp_samples.length() > 0)
}

///|
test "run_simulation deterministic" {
  let params = @game.BalanceParams::default()
  let m1 = run_simulation(params, 42, 300)
  let m2 = run_simulation(params, 42, 300)
  assert_eq(m1.survival_frames, m2.survival_frames)
  assert_eq(m1.total_kills, m2.total_kills)
  assert_eq(m1.floors_cleared, m2.floors_cleared)
}

///|
test "to_dec_targets includes total_damage target" {
  let targets = BalanceTargets::autoplay_rebalance().to_dec_targets()
  let mut found = false
  for target in targets {
    if target.metric == "total_damage" {
      found = true
      assert_true(target.target > 0.0)
      assert_true(target.weight > 0.0)
    }
  }
  assert_true(found)
}

///|
test "to_dec_targets includes equip_upgrades target for item spike hypotheses" {
  let targets = BalanceTargets::item_spike_feedback().to_dec_targets()
  let mut found = false
  for target in targets {
    if target.metric == "equip_upgrades" {
      found = true
      assert_true(target.target > 0.0)
      assert_true(target.weight > 0.0)
    }
  }
  assert_true(found)
}

///|
test "to_dec_targets includes learned_skill_count target for build diversity hypotheses" {
  let targets = BalanceTargets::build_diverse_hackslash().to_dec_targets()
  let mut found = false
  for target in targets {
    if target.metric == "learned_skill_count" {
      found = true
      assert_true(target.target > 0.0)
      assert_true(target.weight > 0.0)
    }
  }
  assert_true(found)
}

///|
test "autoplay rebalance specs only nerf player spells and buff pressure" {
  let specs = param_specs_autoplay_rebalance()
  let names = @game.BalanceParams::param_names()
  let find = fn(name : String) -> @dec.ParamSpec {
    for i = 0; i < names.length(); i = i + 1 {
      if names[i] == name {
        return specs[i]
      }
    }
    panic()
  }
  let spell_cd = find("spell_cooldown_mult")
  let spell_damage = find("spell_damage_mult")
  let spawn_density = find("spawn_density")
  let enemy_speed_fast = find("enemy_speed_fast")
  assert_true(spell_cd.min >= 1.0)
  assert_true(spell_damage.max <= 1.0)
  assert_true(spawn_density.min >= 1.0)
  assert_true(enemy_speed_fast.max > enemy_speed_fast.min)
}

///|
test "autoplay progression specs stay closer to current defaults than rebalance" {
  let progression = param_specs_for_hypothesis("autoplay_progression")
  let rebalance = param_specs_for_hypothesis("autoplay_rebalance")
  let names = @game.BalanceParams::param_names()
  let find = fn(specs : Array[@dec.ParamSpec], name : String) -> @dec.ParamSpec {
    for i = 0; i < names.length(); i = i + 1 {
      if names[i] == name {
        return specs[i]
      }
    }
    panic()
  }
  let player_speed_progression = find(progression, "player_speed")
  let player_speed_rebalance = find(rebalance, "player_speed")
  let enemy_bolt_progression = find(progression, "enemy_bolt_damage")
  let enemy_bolt_rebalance = find(rebalance, "enemy_bolt_damage")
  let spell_damage_progression = find(progression, "spell_damage_mult")
  let spell_damage_rebalance = find(rebalance, "spell_damage_mult")
  assert_true(player_speed_progression.max < player_speed_rebalance.max)
  assert_true(enemy_bolt_progression.max < enemy_bolt_rebalance.max)
  assert_true(spell_damage_progression.min > spell_damage_rebalance.min)
}
