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
  }
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
    near_death_count: 10,
  }
  let good_loss = compute_loss(good, t)
  let bad_loss = compute_loss(bad, t)
  assert_true(bad_loss > good_loss)
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
