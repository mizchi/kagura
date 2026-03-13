///|
fn metric_map(entries : Array[(String, Double)]) -> @dec.Metrics {
  let metrics = @dec.Metrics::new()
  for entry in entries {
    let (name, value) = entry
    metrics.set(name, value)
  }
  metrics
}

///|
test "new_autoplay_experiment_parquet_file builds baseline and optimized rows" {
  let specs : Array[@dec.ParamSpec] = [
    { name: "player_speed", initial: 1.25, min: 1.2, max: 2.0 },
    { name: "spell_damage_mult", initial: 0.5, min: 0.35, max: 1.0 },
  ]
  let config : AutoplayExperimentConfig = {
    experiment_id: "exp-001",
    created_at_utc: "2026-03-13T00:00:00Z",
    runner: "balance_autoplay",
    hypothesis_name: "autoplay_rebalance",
    start_floor: 5,
    sim_max_frames: 7200,
    max_generations: 40,
    seed_count: 4,
    specs,
  }
  let baseline_metrics = metric_map([
    ("survival_frames", 7200.0),
    ("floors_cleared", 3.25),
    ("total_damage", 0.25),
    ("equip_upgrades", 2.0),
    ("learned_skill_count", 3.0),
  ])
  let tuned_metrics = metric_map([
    ("survival_frames", 7200.0),
    ("floors_cleared", 3.0),
    ("total_damage", 2.0),
    ("equip_upgrades", 4.0),
    ("learned_skill_count", 5.0),
    ("near_death_rate", 0.04),
  ])
  let tuned : @dec.TuneResult = {
    params: [1.2, 0.4],
    loss: 5.25,
    generation: 17,
    metrics: tuned_metrics,
  }
  let file = new_autoplay_experiment_parquet_file(
    config,
    6.26,
    baseline_metrics,
    [1.25, 0.5],
    tuned,
  )

  let names = file.columns().map(fn(column) { column.name() })
  assert_eq(names, [
    "experiment_id", "created_at_utc", "runner", "hypothesis_name", "run_kind", "generation",
    "loss", "start_floor", "sim_max_frames", "max_generations", "seed_count", "survival_frames",
    "floors_cleared", "total_kills", "total_damage", "score", "avg_hp_ratio", "hp_cv",
    "floor_time", "kill_interval", "kill_cv", "kills_per_floor", "damage_interval",
    "equip_upgrades", "learned_skill_count", "near_death_rate", "player_speed", "spell_damage_mult",
  ])

  let rows = file.rows()
  assert_eq(rows.length(), 2)
  assert_eq(rows[0][0], @parquet.Value::String("exp-001"))
  assert_eq(rows[0][2], @parquet.Value::String("balance_autoplay"))
  assert_eq(rows[0][3], @parquet.Value::String("autoplay_rebalance"))
  assert_eq(rows[0][4], @parquet.Value::String("before_change"))
  assert_eq(rows[0][6], @parquet.Value::String("6.26"))
  assert_eq(rows[0][12], @parquet.Value::String("3.25"))
  assert_eq(rows[0][14], @parquet.Value::String("0.25"))
  assert_eq(rows[0][23], @parquet.Value::String("2"))
  assert_eq(rows[0][24], @parquet.Value::String("3"))
  assert_eq(rows[0][26], @parquet.Value::String("1.25"))
  assert_eq(rows[0][27], @parquet.Value::String("0.5"))
  assert_eq(rows[1][4], @parquet.Value::String("after_tune"))
  assert_eq(rows[1][5], @parquet.Value::Int32(17))
  assert_eq(rows[1][6], @parquet.Value::String("5.25"))
  assert_eq(rows[1][14], @parquet.Value::String("2"))
  assert_eq(rows[1][23], @parquet.Value::String("4"))
  assert_eq(rows[1][24], @parquet.Value::String("5"))
  assert_eq(rows[1][25], @parquet.Value::String("0.04"))
  assert_eq(rows[1][26], @parquet.Value::String("1.2"))
  assert_eq(rows[1][27], @parquet.Value::String("0.4"))
}

///|
test "new_autoplay_experiment_parquet_file encodes to bytes" {
  let specs : Array[@dec.ParamSpec] = [
    { name: "player_speed", initial: 1.25, min: 1.2, max: 2.0 },
  ]
  let config : AutoplayExperimentConfig = {
    experiment_id: "exp-encode",
    created_at_utc: "2026-03-13T00:00:00Z",
    runner: "balance_autoplay",
    hypothesis_name: "default",
    start_floor: 5,
    sim_max_frames: 7200,
    max_generations: 40,
    seed_count: 4,
    specs,
  }
  let tuned : @dec.TuneResult = {
    params: [1.2],
    loss: 5.25,
    generation: 17,
    metrics: metric_map([("survival_frames", 7200.0)]),
  }
  let file = new_autoplay_experiment_parquet_file(
    config,
    6.26,
    metric_map([("survival_frames", 7200.0)]),
    [1.25],
    tuned,
  )
  let bytes = @parquet.write_bytes(file) catch { _ => panic() }
  assert_true(bytes.length() > 0)
}
