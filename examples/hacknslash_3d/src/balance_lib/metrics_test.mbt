///|
test "avg_hp_ratio empty" {
  let m : SimMetrics = {
    survival_frames: 0, floors_cleared: 0, total_damage_taken: 0,
    total_kills: 0, score: 0, hp_samples: [], floor_times: [],
    kill_frames: [], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  assert_true!(m.avg_hp_ratio() < 0.001)
}

///|
test "avg_hp_ratio computes mean" {
  let m : SimMetrics = {
    survival_frames: 100, floors_cleared: 1, total_damage_taken: 0,
    total_kills: 0, score: 0, hp_samples: [1.0, 0.5, 0.5], floor_times: [],
    kill_frames: [], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  let avg = m.avg_hp_ratio()
  assert_true!((avg - 0.6666).abs() < 0.01)
}

///|
test "hp_coefficient_of_variation" {
  let m : SimMetrics = {
    survival_frames: 100, floors_cleared: 1, total_damage_taken: 0,
    total_kills: 0, score: 0, hp_samples: [0.5, 0.5, 0.5], floor_times: [],
    kill_frames: [], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  // All same => variance=0 => cv=0
  assert_true!(m.hp_coefficient_of_variation() < 0.001)
}

///|
test "avg_floor_time" {
  let m : SimMetrics = {
    survival_frames: 600, floors_cleared: 3, total_damage_taken: 0,
    total_kills: 0, score: 0, hp_samples: [], floor_times: [100, 200, 300],
    kill_frames: [], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  assert_true!((m.avg_floor_time() - 200.0).abs() < 0.01)
}

///|
test "avg_kill_interval" {
  let m : SimMetrics = {
    survival_frames: 300, floors_cleared: 1, total_damage_taken: 0,
    total_kills: 4, score: 0, hp_samples: [], floor_times: [],
    kill_frames: [10, 60, 110, 160], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  // intervals: 50, 50, 50 => avg = 50
  assert_true!((m.avg_kill_interval() - 50.0).abs() < 0.01)
}

///|
test "kill_interval_cv uniform kills" {
  let m : SimMetrics = {
    survival_frames: 300, floors_cleared: 1, total_damage_taken: 0,
    total_kills: 4, score: 0, hp_samples: [], floor_times: [],
    kill_frames: [0, 100, 200, 300], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  // uniform intervals => cv = 0
  assert_true!(m.kill_interval_cv() < 0.001)
}

///|
test "kills_per_floor" {
  let m : SimMetrics = {
    survival_frames: 300, floors_cleared: 3, total_damage_taken: 0,
    total_kills: 30, score: 0, hp_samples: [], floor_times: [],
    kill_frames: [], damage_frames: [], equip_upgrades: 0, near_death_count: 0,
  }
  assert_true!((m.kills_per_floor() - 10.0).abs() < 0.01)
}

///|
test "near_death_rate" {
  let m : SimMetrics = {
    survival_frames: 100, floors_cleared: 1, total_damage_taken: 0,
    total_kills: 0, score: 0,
    hp_samples: [0.1, 0.2, 0.5, 0.8], // 2 out of 4 below 0.25
    floor_times: [], kill_frames: [], damage_frames: [],
    equip_upgrades: 0, near_death_count: 0,
  }
  assert_true!((m.near_death_rate() - 0.5).abs() < 0.01)
}

///|
test "avg_damage_interval" {
  let m : SimMetrics = {
    survival_frames: 300, floors_cleared: 1, total_damage_taken: 3,
    total_kills: 0, score: 0, hp_samples: [], floor_times: [],
    kill_frames: [], damage_frames: [100, 200, 300],
    equip_upgrades: 0, near_death_count: 0,
  }
  assert_true!((m.avg_damage_interval() - 100.0).abs() < 0.01)
}
