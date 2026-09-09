// Balance tuner using @dec.tune() API

///|
fn main {
  println("=== AFFIX PROFILE BALANCE TUNER ===")
  println("")
  let max_generations = 40
  let sim_max_frames = 9000
  let seeds : Array[Int] = [42, 137, 256, 512]
  let specs = @blib.param_specs()
  let targets = @blib.BalanceTargets::default().to_dec_targets()
  let profiles : Array[(String, Int)] = [
    ("Classic", 0),
    ("GlassCannon", 1),
    ("Tank", 2),
    ("Mobility", 3),
    ("Expanded", 4),
  ]
  println(
    "Seeds: " +
    seeds.length().to_string() +
    " | Frames: " +
    sim_max_frames.to_string() +
    " | Gens: " +
    max_generations.to_string(),
  )
  println("")

  // Baselines
  println("=== BASELINES ===")
  for profile in profiles {
    let (name, id) = profile
    let sim = @blib.make_sim(id, sim_max_frames)
    let initial = @dec.initial_params(specs)
    let (loss, avg) = @dec.compute_loss_averaged(sim, initial, targets, seeds)
    println("--- " + name + " (loss=" + fmt(loss) + ") ---")
    print_metrics(avg)
  }
  println("")

  // Optimize each profile
  let results : Array[(String, @dec.TuneResult, Double)] = []
  for profile in profiles {
    let (name, id) = profile
    println("============================================")
    println("  Optimizing: " + name)
    println("============================================")
    let sim = @blib.make_sim(id, sim_max_frames)
    let initial = @dec.initial_params(specs)
    let (base_loss, _) = @dec.compute_loss_averaged(
      sim, initial, targets, seeds,
    )
    println("  Baseline loss: " + fmt(base_loss))
    let config : @dec.TuneConfig = {
      ..@dec.TuneConfig::default(specs, targets),
      max_generations,
      seeds,
    }
    let result = @dec.tune(config, sim)
    let imp = if base_loss > 0.0001 {
      (1.0 - result.loss / base_loss) * 100.0
    } else {
      0.0
    }
    println(
      "  Optimized loss: " +
      fmt(result.loss) +
      " (improvement: " +
      fmt(imp) +
      "%)",
    )
    print_metrics(result.metrics)
    println("")
    results.push((name, result, base_loss))
  }

  // Summary
  println(
    "╔══════════════════════════════════════════╗",
  )
  println("║     AFFIX PROFILE COMPARISON SUMMARY     ║")
  println(
    "╚══════════════════════════════════════════╝",
  )
  println("")
  for r in results {
    let (name, result, base_loss) = r
    let imp = if base_loss > 0.0001 {
      (1.0 - result.loss / base_loss) * 100.0
    } else {
      0.0
    }
    println("--- " + name + " ---")
    println(
      "  Loss: " +
      fmt(base_loss) +
      " -> " +
      fmt(result.loss) +
      " (" +
      fmt(imp) +
      "%)",
    )
    print_metrics(result.metrics)
    println("")
  }

  // Parameter changes
  println("=== PARAMETER CHANGES ===")
  let names = @dec.param_names(specs)
  let defaults = @dec.initial_params(specs)
  let mut header = pad("param", 22) + pad("default", 10)
  for r in results {
    header = header + pad(r.0, 14)
  }
  println(header)
  for i = 0; i < names.length(); i = i + 1 {
    let mut any_changed = false
    for r in results {
      if (r.1.params[i] - defaults[i]).abs() > 0.01 {
        any_changed = true
        break
      }
    }
    if any_changed {
      let mut line = pad(names[i], 22) + pad(fmt(defaults[i]), 10)
      for r in results {
        let mark = if (r.1.params[i] - defaults[i]).abs() > 0.01 {
          "*"
        } else {
          " "
        }
        line = line + pad(fmt(r.1.params[i]) + mark, 14)
      }
      println(line)
    }
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
fn pad(s : String, width : Int) -> String {
  let mut r = s
  while r.length() < width {
    r = r + " "
  }
  r
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
