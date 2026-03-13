///|
fn main {
  println("=== HACKNSLASH AUTOPLAY REBALANCE TUNER ===")
  let seeds : Array[Int] = [42, 137, 256, 512]
  let args = @sys.get_cli_args()
  let output_path = if args.length() >= 2 { Some(args[1]) } else { None }
  let experiment_id = if args.length() >= 3 {
    args[2]
  } else {
    "local-autoplay-rebalance"
  }
  let created_at_utc = if args.length() >= 4 {
    args[3]
  } else {
    "1970-01-01T00:00:00Z"
  }
  let hypothesis_name = if args.length() >= 5 {
    args[4]
  } else {
    "autoplay_rebalance"
  }
  let runner = if args.length() >= 6 { args[5] } else { "balance_autoplay" }
  let start_floor = if args.length() >= 7 { parse_int(args[6], 5) } else { 5 }
  let sim_max_frames = if args.length() >= 8 {
    parse_int(args[7], 7200)
  } else {
    7200
  }
  let max_generations = if args.length() >= 9 {
    parse_int(args[8], 40)
  } else {
    40
  }
  let archetype_name = if args.length() >= 10 { args[9] } else { "melee" }
  let build_policy_name = if args.length() >= 11 {
    args[10]
  } else {
    "aligned"
  }
  let hypothesis = match @blib.balance_hypothesis_from_name(hypothesis_name) {
    Some(h) => h
    None => {
      println("Unknown hypothesis: " + hypothesis_name)
      @sys.exit(1)
      panic()
    }
  }
  let targets = hypothesis.targets.to_dec_targets()
  let specs = @blib.param_specs_for_hypothesis(hypothesis.name)
  let archetype = match @game.character_archetype_from_string(archetype_name) {
    Some(value) => value
    None => {
      println("Unknown archetype: " + archetype_name)
      @sys.exit(1)
      panic()
    }
  }
  let build_policy = match @game.archetype_build_policy_from_string(
    build_policy_name,
  ) {
    Some(value) => value
    None => {
      println("Unknown build policy: " + build_policy_name)
      @sys.exit(1)
      panic()
    }
  }
  let sim = @blib.make_autoplay_rebalance_sim(
    0,
    sim_max_frames,
    start_floor,
    archetype,
    build_policy,
  )
  let initial = @dec.initial_params(specs)
  let (base_loss, base_metrics) = @dec.compute_loss_averaged(
    sim, initial, targets, seeds,
  )
  println("Baseline loss: " + fmt(base_loss))
  print_metrics(base_metrics)
  let config : @dec.TuneConfig = {
    ..@dec.TuneConfig::default(specs, targets),
    max_generations,
    seeds,
  }
  let result = @dec.tune(config, sim)
  println("")
  println("Optimized loss: " + fmt(result.loss))
  print_metrics(result.metrics)
  match output_path {
    Some(path) => {
      let export_config : AutoplayExperimentConfig = {
        experiment_id,
        created_at_utc,
        runner,
        hypothesis_name: hypothesis.name,
        archetype_name: @game.character_archetype_to_string(archetype),
        build_policy_name: @game.archetype_build_policy_to_string(build_policy),
        start_floor,
        sim_max_frames,
        max_generations,
        seed_count: seeds.length(),
        specs,
      }
      write_autoplay_experiment_parquet_file(
        path, export_config, base_loss, base_metrics, initial, result,
      ) catch {
        err => {
          println("")
          println("Failed to write parquet: " + err.to_string())
          @sys.exit(1)
        }
      }
      println("")
      println("Saved parquet: " + path)
    }
    None => ()
  }
  println("")
  println("=== TUNED PARAMS ===")
  let names = @dec.param_names(specs)
  for i = 0; i < names.length(); i = i + 1 {
    println(names[i] + "=" + fmt(result.params[i]))
  }
}

///|
fn print_metrics(m : @dec.Metrics) -> Unit {
  println(
    "  Surv:" +
    fmt(m.get("survival_frames")) +
    " Floor:" +
    fmt(m.get("floors_cleared")) +
    " Kills:" +
    fmt(m.get("total_kills")) +
    " Dmg:" +
    fmt(m.get("total_damage")),
  )
  println(
    "  HP:" +
    fmt(m.get("avg_hp_ratio")) +
    " CV:" +
    fmt(m.get("hp_cv")) +
    " FTime:" +
    fmt(m.get("floor_time")) +
    " NearDeath:" +
    fmt(m.get("near_death_rate")),
  )
  println(
    "  KillInt:" +
    fmt(m.get("kill_interval")) +
    " KillCV:" +
    fmt(m.get("kill_cv")) +
    " KPF:" +
    fmt(m.get("kills_per_floor")) +
    " DmgInt:" +
    fmt(m.get("damage_interval")),
  )
}

///|
fn fmt(v : Double) -> String {
  let sign = if v < 0.0 { "-" } else { "" }
  let abs_v = if v < 0.0 { -v } else { v }
  let int_part = abs_v.to_int()
  let frac = ((abs_v - int_part.to_double()) * 100.0).to_int()
  let p = if frac < 10 { "0" + frac.to_string() } else { frac.to_string() }
  sign + int_part.to_string() + "." + p
}

///|
fn parse_int(s : String, fallback : Int) -> Int {
  let mut result = 0
  let mut negative = false
  let mut found_digit = false
  for i, c in s {
    if i == 0 && c == '-' {
      negative = true
      continue
    }
    let d = c.to_int() - '0'.to_int()
    if d >= 0 && d <= 9 {
      result = result * 10 + d
      found_digit = true
    }
  }
  if !found_digit {
    fallback
  } else if negative {
    -result
  } else {
    result
  }
}
