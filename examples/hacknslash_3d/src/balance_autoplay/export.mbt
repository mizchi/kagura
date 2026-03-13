///|
let autoplay_experiment_metric_names : Array[String] = [
  "survival_frames",
  "floors_cleared",
  "total_kills",
  "total_damage",
  "score",
  "avg_hp_ratio",
  "hp_cv",
  "floor_time",
  "kill_interval",
  "kill_cv",
  "kills_per_floor",
  "damage_interval",
  "equip_upgrades",
  "learned_skill_count",
  "near_death_rate",
]

///|
struct AutoplayExperimentConfig {
  experiment_id : String
  created_at_utc : String
  runner : String
  hypothesis_name : String
  start_floor : Int
  sim_max_frames : Int
  max_generations : Int
  seed_count : Int
  specs : Array[@dec.ParamSpec]
}

///|
fn autoplay_experiment_columns(
  specs : Array[@dec.ParamSpec],
) -> Array[@parquet.Column] {
  let columns : Array[@parquet.Column] = [
    @parquet.new_column("experiment_id", @parquet.String, @parquet.Required),
    @parquet.new_column("created_at_utc", @parquet.String, @parquet.Required),
    @parquet.new_column("runner", @parquet.String, @parquet.Required),
    @parquet.new_column("hypothesis_name", @parquet.String, @parquet.Required),
    @parquet.new_column("run_kind", @parquet.String, @parquet.Required),
    @parquet.new_column("generation", @parquet.Int32, @parquet.Required),
    @parquet.new_column("loss", @parquet.String, @parquet.Required),
    @parquet.new_column("start_floor", @parquet.Int32, @parquet.Required),
    @parquet.new_column("sim_max_frames", @parquet.Int32, @parquet.Required),
    @parquet.new_column("max_generations", @parquet.Int32, @parquet.Required),
    @parquet.new_column("seed_count", @parquet.Int32, @parquet.Required),
  ]
  for name in autoplay_experiment_metric_names {
    columns.push(@parquet.new_column(name, @parquet.String, @parquet.Required))
  }
  for name in @dec.param_names(specs) {
    columns.push(@parquet.new_column(name, @parquet.String, @parquet.Required))
  }
  columns
}

///|
fn numeric_value(value : Double) -> @parquet.Value {
  @parquet.Value::String(value.to_string())
}

///|
fn autoplay_experiment_row(
  config : AutoplayExperimentConfig,
  run_kind : String,
  generation : Int,
  loss : Double,
  metrics : @dec.Metrics,
  params : Array[Double],
) -> Array[@parquet.Value] {
  let row : Array[@parquet.Value] = [
    @parquet.Value::String(config.experiment_id),
    @parquet.Value::String(config.created_at_utc),
    @parquet.Value::String(config.runner),
    @parquet.Value::String(config.hypothesis_name),
    @parquet.Value::String(run_kind),
    @parquet.Value::Int32(generation),
    numeric_value(loss),
    @parquet.Value::Int32(config.start_floor),
    @parquet.Value::Int32(config.sim_max_frames),
    @parquet.Value::Int32(config.max_generations),
    @parquet.Value::Int32(config.seed_count),
  ]
  for name in autoplay_experiment_metric_names {
    row.push(numeric_value(metrics.get(name)))
  }
  for value in params {
    row.push(numeric_value(value))
  }
  row
}

///|
fn new_autoplay_experiment_parquet_file(
  config : AutoplayExperimentConfig,
  baseline_loss : Double,
  baseline_metrics : @dec.Metrics,
  baseline_params : Array[Double],
  tuned : @dec.TuneResult,
) -> @parquet.ParquetFile {
  let columns = autoplay_experiment_columns(config.specs)
  let rows = [
    autoplay_experiment_row(
      config,
      "before_change",
      0,
      baseline_loss,
      baseline_metrics,
      baseline_params,
    ),
    autoplay_experiment_row(
      config,
      "after_tune",
      tuned.generation,
      tuned.loss,
      tuned.metrics,
      tuned.params,
    ),
  ]
  @parquet.new_parquet_file(columns, rows, Some("hacknslash-balance-autoplay"))
}

///|
fn write_autoplay_experiment_parquet_file(
  path : String,
  config : AutoplayExperimentConfig,
  baseline_loss : Double,
  baseline_metrics : @dec.Metrics,
  baseline_params : Array[Double],
  tuned : @dec.TuneResult,
) -> Unit raise {
  let file = new_autoplay_experiment_parquet_file(
    config,
    baseline_loss,
    baseline_metrics,
    baseline_params,
    tuned,
  )
  @parquet.write_file(path, file)
}
