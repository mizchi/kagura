// Loss functions for game balance optimization

pub(all) struct BalanceTargets {
  target_survival_frames : Double
  target_floors : Double
  target_floor_time : Double
  target_hp_cv : Double // coefficient of variation
}

pub fn BalanceTargets::default() -> BalanceTargets {
  {
    target_survival_frames: 9000.0, // 2.5 min at 60fps
    target_floors: 6.0,
    target_floor_time: 600.0, // 10 sec per floor
    target_hp_cv: 0.35, // moderate tension
  }
}

// Compute loss for a single simulation result
pub fn compute_loss(metrics : SimMetrics, targets : BalanceTargets) -> Double {
  let survival_err = (metrics.survival_frames.to_double() - targets.target_survival_frames) /
    targets.target_survival_frames
  let floor_err = (metrics.floors_cleared.to_double() - targets.target_floors) /
    targets.target_floors
  let floor_time_err = if metrics.floor_times.length() > 0 {
    (metrics.avg_floor_time() - targets.target_floor_time) / targets.target_floor_time
  } else {
    1.0 // penalize no floor clears
  }
  let hp_cv = metrics.hp_coefficient_of_variation()
  let hp_cv_err = (hp_cv - targets.target_hp_cv) / (targets.target_hp_cv + 0.01)
  // Weighted sum of squared errors
  let w_survival = 1.0
  let w_floor = 1.0
  let w_floor_time = 0.5
  let w_hp_cv = 0.3
  w_survival * survival_err * survival_err +
    w_floor * floor_err * floor_err +
    w_floor_time * floor_time_err * floor_time_err +
    w_hp_cv * hp_cv_err * hp_cv_err
}

// Run multiple simulations with different seeds, return average loss
pub fn compute_loss_averaged(
  params : @game.BalanceParams,
  targets : BalanceTargets,
  seeds : Array[Int],
  max_frames : Int,
) -> (Double, SimMetrics) {
  let mut total_loss = 0.0
  let mut total_survival = 0
  let mut total_floors = 0
  let mut total_kills = 0
  let mut total_score = 0
  let all_hp_samples : Array[Double] = []
  let all_floor_times : Array[Int] = []
  let mut total_damage = 0
  for seed in seeds {
    let m = run_simulation(params, seed, max_frames)
    total_loss = total_loss + compute_loss(m, targets)
    total_survival = total_survival + m.survival_frames
    total_floors = total_floors + m.floors_cleared
    total_kills = total_kills + m.total_kills
    total_score = total_score + m.score
    total_damage = total_damage + m.total_damage_taken
    for s in m.hp_samples {
      all_hp_samples.push(s)
    }
    for t in m.floor_times {
      all_floor_times.push(t)
    }
  }
  let n = seeds.length()
  let avg_metrics : SimMetrics = {
    survival_frames: total_survival / n,
    floors_cleared: total_floors / n,
    total_damage_taken: total_damage / n,
    total_kills: total_kills / n,
    score: total_score / n,
    hp_samples: all_hp_samples,
    floor_times: all_floor_times,
  }
  (total_loss / n.to_double(), avg_metrics)
}
