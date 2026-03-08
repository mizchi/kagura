// Balance tuner: Affix profile comparison (playtest3)
// Compare how different modifier pools affect game balance

fn main {
  println("=== AFFIX PROFILE COMPARISON ===")
  println("")
  let max_generations = 40
  let sim_max_frames = 9000
  let seeds : Array[Int] = [42, 137, 256, 512]
  let default_params = @game.BalanceParams::default()
  let targets = @blib.BalanceTargets::default()
  let profiles : Array[(String, Int)] = [
    ("Classic", 0),
    ("GlassCannon", 1),
    ("Tank", 2),
    ("Mobility", 3),
    ("Expanded", 4),
  ]
  println(
    "Seeds: " + seeds.length().to_string() + " | Frames: " +
    sim_max_frames.to_string() + " | Gens: " + max_generations.to_string(),
  )
  println("Target: Default (balanced)")
  println("")
  // Baselines per profile (before optimization)
  println("=== BASELINES (default params, different affixes) ===")
  for profile in profiles {
    let (name, id) = profile
    let params = { ..default_params, affix_profile: id }
    let (loss, am) = @blib.compute_loss_averaged_full(params, targets, seeds, sim_max_frames)
    println("--- " + name + " (loss=" + fmt(loss) + ") ---")
    let b = am.base
    println(
      "  Surv:" + b.survival_frames.to_string() +
      " Floor:" + b.floors_cleared.to_string() +
      " Kills:" + b.total_kills.to_string() +
      " Dmg:" + b.total_damage_taken.to_string(),
    )
    println(
      "  HP:" + fmt(am.avg_hp_ratio) +
      " CV:" + fmt(am.hp_cv) +
      " FTime:" + fmt(am.avg_floor_time) +
      " NearDeath:" + fmt(am.near_death_rate),
    )
  }
  println("")
  // Optimize each profile
  let results : Array[(String, Double, Double, @blib.AveragedMetrics, @game.BalanceParams)] = []
  for profile in profiles {
    let (name, id) = profile
    println("============================================")
    println("  " + name)
    println("============================================")
    let base_params = { ..default_params, affix_profile: id }
    let (base_loss, _) = @blib.compute_loss_averaged_full(
      base_params, targets, seeds, sim_max_frames,
    )
    println("  Baseline loss: " + fmt(base_loss))
    let cma = @blib.CmaEs::new(base_params.to_array(), 0.3, seed=42)
    cma.best_loss = base_loss
    let init_arr = base_params.to_array()
    for i = 0; i < cma.n; i = i + 1 {
      cma.best_params[i] = init_arr[i]
    }
    for gen = 0; gen < max_generations; gen = gen + 1 {
      let population = cma.sample_population()
      let fitnesses : Array[(Double, Int)] = []
      for i, candidate in population {
        let params = { ..@game.BalanceParams::from_array(candidate).clamp(), affix_profile: id }
        let (loss, _) = @blib.compute_loss_averaged(params, targets, seeds, sim_max_frames)
        fitnesses.push((loss, i))
      }
      fitnesses.sort_by(fn(a, b) { a.0.compare(b.0) })
      let sorted_pop : Array[Array[Double]] = []
      for entry in fitnesses {
        sorted_pop.push(population[entry.1])
      }
      cma.update(sorted_pop)
      let gen_best = fitnesses[0].0
      if gen_best < cma.best_loss {
        cma.best_loss = gen_best
        let best_arr = sorted_pop[0]
        for i = 0; i < cma.n; i = i + 1 {
          cma.best_params[i] = best_arr[i]
        }
      }
      if (gen + 1) % 10 == 0 || gen == 0 || gen == max_generations - 1 {
        println(
          "  [Gen " + (gen + 1).to_string() + "] best=" +
          fmt(cma.best_loss) + " sigma=" + fmt(cma.sigma),
        )
      }
    }
    let best_params = { ..cma.best_balance_params(), affix_profile: id }
    let (final_loss, final_am) = @blib.compute_loss_averaged_full(
      best_params, targets, seeds, sim_max_frames,
    )
    println("")
    print_am("  Optimized", final_loss, final_am)
    let imp = if base_loss > 0.0001 {
      (1.0 - final_loss / base_loss) * 100.0
    } else {
      0.0
    }
    println("  Improvement: " + fmt(imp) + "%")
    println("")
    results.push((name, base_loss, final_loss, final_am, best_params))
  }
  // Summary
  println("╔══════════════════════════════════════════╗")
  println("║     AFFIX PROFILE COMPARISON SUMMARY     ║")
  println("╚══════════════════════════════════════════╝")
  println("")
  for result in results {
    let (name, bl, fl, am, _) = result
    let imp = if bl > 0.0001 { (1.0 - fl / bl) * 100.0 } else { 0.0 }
    println("--- " + name + " ---")
    println(
      "  Loss: " + fmt(bl) + " -> " + fmt(fl) + " (" + fmt(imp) + "%)",
    )
    let b = am.base
    println(
      "  Surv:" + b.survival_frames.to_string() +
      " Floor:" + b.floors_cleared.to_string() +
      " Kills:" + b.total_kills.to_string() +
      " Dmg:" + b.total_damage_taken.to_string(),
    )
    println(
      "  HP:" + fmt(am.avg_hp_ratio) +
      " CV:" + fmt(am.hp_cv) +
      " NearDeath:" + fmt(am.near_death_rate),
    )
    println(
      "  FTime:" + fmt(am.avg_floor_time) +
      " KillInt:" + fmt(am.avg_kill_interval) +
      " KPF:" + fmt(am.kills_per_floor) +
      " DmgInt:" + fmt(am.avg_damage_interval),
    )
    println("")
  }
  // Param diff
  println("=== PARAMETER CHANGES ===")
  let names = @game.BalanceParams::param_names()
  let defs = default_params.to_array()
  let mut header = pad("param", 22) + pad("default", 10)
  for result in results {
    header = header + pad(result.0, 14)
  }
  println(header)
  for i = 0; i < names.length(); i = i + 1 {
    let mut any_changed = false
    for result in results {
      let vals = result.4.to_array()
      if (vals[i] - defs[i]).abs() > 0.01 {
        any_changed = true
        break
      }
    }
    if any_changed {
      let mut line = pad(names[i], 22) + pad(fmt(defs[i]), 10)
      for result in results {
        let vals = result.4.to_array()
        let mark = if (vals[i] - defs[i]).abs() > 0.01 { "*" } else { " " }
        line = line + pad(fmt(vals[i]) + mark, 14)
      }
      println(line)
    }
  }
  println("")
}

fn pad(s : String, width : Int) -> String {
  let mut r = s
  while r.length() < width {
    r = r + " "
  }
  r
}

fn print_am(label : String, loss : Double, am : @blib.AveragedMetrics) -> Unit {
  let b = am.base
  println("  " + label + " loss=" + fmt(loss))
  println(
    "  Surv:" + b.survival_frames.to_string() +
    " Floor:" + b.floors_cleared.to_string() +
    " Kills:" + b.total_kills.to_string() +
    " Score:" + b.score.to_string() +
    " Dmg:" + b.total_damage_taken.to_string(),
  )
  println(
    "  HP:" + fmt(am.avg_hp_ratio) +
    " CV:" + fmt(am.hp_cv) +
    " FTime:" + fmt(am.avg_floor_time) +
    " NearDeath:" + fmt(am.near_death_rate),
  )
  println(
    "  KillInt:" + fmt(am.avg_kill_interval) +
    " KillCV:" + fmt(am.kill_interval_cv) +
    " KPF:" + fmt(am.kills_per_floor) +
    " DmgInt:" + fmt(am.avg_damage_interval),
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
