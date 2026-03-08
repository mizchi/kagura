// Balance tuner CLI: CMA-ES optimization for game parameters

fn main {
  println("=== BALANCE TUNER (CMA-ES) ===")
  println("")
  let max_generations = 40
  let sim_max_frames = 9000
  let seeds : Array[Int] = [42, 137, 256, 512]
  let targets = @blib.BalanceTargets::default()
  println(
    "Targets: survival=" + targets.target_survival_frames.to_string() +
    " floors=" + targets.target_floors.to_string() +
    " floor_time=" + targets.target_floor_time.to_string() +
    " hp_cv=" + targets.target_hp_cv.to_string(),
  )
  println("Seeds: " + seeds.length().to_string() + " | Frames: " + sim_max_frames.to_string())
  println("")
  // Default baseline
  let default_params = @game.BalanceParams::default()
  let (default_loss, default_metrics) = @blib.compute_loss_averaged(
    default_params, targets, seeds, sim_max_frames,
  )
  println("=== BASELINE ===")
  print_metrics("Default", default_loss, default_metrics)
  println("")
  // Init CMA-ES
  let cma = @blib.CmaEs::new(default_params.to_array(), 0.3, seed=42)
  cma.best_loss = default_loss
  let init_arr = default_params.to_array()
  for i = 0; i < cma.n; i = i + 1 {
    cma.best_params[i] = init_arr[i]
  }
  println(
    "CMA-ES: pop=" + cma.pop_size.to_string() +
    " mu=" + cma.mu.to_string() +
    " dim=" + cma.n.to_string(),
  )
  println("")
  for gen = 0; gen < max_generations; gen = gen + 1 {
    let population = cma.sample_population()
    let fitnesses : Array[(Double, Int)] = []
    for i, candidate in population {
      let params = @game.BalanceParams::from_array(candidate).clamp()
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
    if (gen + 1) % 5 == 0 || gen == 0 || gen == max_generations - 1 {
      let median = fitnesses[fitnesses.length() / 2].0
      println(
        "[Gen " + (gen + 1).to_string() + "/" + max_generations.to_string() +
        "] best=" + format_f(cma.best_loss) +
        " gen=" + format_f(gen_best) +
        " med=" + format_f(median) +
        " sigma=" + format_f(cma.sigma),
      )
    }
  }
  println("")
  let best_params = cma.best_balance_params()
  let (final_loss, final_metrics) = @blib.compute_loss_averaged(
    best_params, targets, seeds, sim_max_frames,
  )
  println("=== OPTIMIZED ===")
  print_metrics("Optimized", final_loss, final_metrics)
  println("")
  println("=== COMPARISON ===")
  println("  Default:   " + format_f(default_loss))
  println("  Optimized: " + format_f(final_loss))
  if default_loss > 0.0001 {
    println("  Improvement: " + format_f((1.0 - final_loss / default_loss) * 100.0) + "%")
  }
  println("")
  println("=== PARAMS ===")
  let names = @game.BalanceParams::param_names()
  let defs = default_params.to_array()
  let vals = best_params.to_array()
  for i = 0; i < names.length(); i = i + 1 {
    let c = if (vals[i] - defs[i]).abs() > 0.01 { " <-" } else { "" }
    println("  " + names[i] + ": " + format_f(defs[i]) + " -> " + format_f(vals[i]) + c)
  }
  println("")
}

fn print_metrics(label : String, loss : Double, m : @blib.SimMetrics) -> Unit {
  println("  " + label + " loss: " + format_f(loss))
  println(
    "  Surv: " + m.survival_frames.to_string() +
    "f | Floor: " + m.floors_cleared.to_string() +
    " | Kills: " + m.total_kills.to_string() +
    " | Score: " + m.score.to_string(),
  )
  println(
    "  HP: " + format_f(m.avg_hp_ratio()) +
    " | CV: " + format_f(m.hp_coefficient_of_variation()) +
    " | FTime: " + format_f(m.avg_floor_time()) +
    " | Dmg: " + m.total_damage_taken.to_string(),
  )
}

fn format_f(v : Double) -> String {
  let sign = if v < 0.0 { "-" } else { "" }
  let abs_v = if v < 0.0 { -v } else { v }
  let int_part = abs_v.to_int()
  let frac = ((abs_v - int_part.to_double()) * 10000.0).to_int()
  let s = frac.to_string()
  let p = if frac < 10 {
    "000" + s
  } else if frac < 100 {
    "00" + s
  } else if frac < 1000 {
    "0" + s
  } else {
    s
  }
  sign + int_part.to_string() + "." + p
}
