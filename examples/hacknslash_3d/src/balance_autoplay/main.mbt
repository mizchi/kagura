fn main {
  println("=== HACKNSLASH AUTOPLAY REBALANCE TUNER ===")
  let max_generations = 40
  let sim_max_frames = 7200
  let seeds : Array[Int] = [42, 137, 256, 512]
  let start_floor = 5
  let specs = @blib.param_specs_autoplay_rebalance()
  let targets = @blib.BalanceTargets::autoplay_rebalance().to_dec_targets()
  let sim = @blib.make_autoplay_rebalance_sim(0, sim_max_frames, start_floor)
  let initial = @dec.initial_params(specs)
  let (base_loss, base_metrics) = @dec.compute_loss_averaged(
    sim,
    initial,
    targets,
    seeds,
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
  println("")
  println("=== TUNED PARAMS ===")
  let names = @dec.param_names(specs)
  for i = 0; i < names.length(); i = i + 1 {
    println(names[i] + "=" + fmt(result.params[i]))
  }
}

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

fn fmt(v : Double) -> String {
  let sign = if v < 0.0 { "-" } else { "" }
  let abs_v = if v < 0.0 { -v } else { v }
  let int_part = abs_v.to_int()
  let frac = ((abs_v - int_part.to_double()) * 100.0).to_int()
  let p = if frac < 10 { "0" + frac.to_string() } else { frac.to_string() }
  sign + int_part.to_string() + "." + p
}
