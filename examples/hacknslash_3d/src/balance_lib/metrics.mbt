// SimMetrics: statistics collected from a headless simulation run

pub(all) struct SimMetrics {
  survival_frames : Int
  floors_cleared : Int
  total_damage_taken : Int
  total_kills : Int
  score : Int
  hp_samples : Array[Double] // hp/max_hp ratio sampled periodically
  floor_times : Array[Int] // frames per floor
}

pub fn SimMetrics::avg_hp_ratio(self : SimMetrics) -> Double {
  if self.hp_samples.length() == 0 {
    return 0.0
  }
  let mut sum = 0.0
  for s in self.hp_samples {
    sum = sum + s
  }
  sum / self.hp_samples.length().to_double()
}

pub fn SimMetrics::hp_variance(self : SimMetrics) -> Double {
  let n = self.hp_samples.length()
  if n < 2 {
    return 0.0
  }
  let mean = self.avg_hp_ratio()
  let mut sum_sq = 0.0
  for s in self.hp_samples {
    let d = s - mean
    sum_sq = sum_sq + d * d
  }
  sum_sq / n.to_double()
}

pub fn SimMetrics::hp_coefficient_of_variation(self : SimMetrics) -> Double {
  let mean = self.avg_hp_ratio()
  if mean < 0.001 {
    return 0.0
  }
  self.hp_variance().sqrt() / mean
}

pub fn SimMetrics::avg_floor_time(self : SimMetrics) -> Double {
  if self.floor_times.length() == 0 {
    return 0.0
  }
  let mut sum = 0
  for t in self.floor_times {
    sum = sum + t
  }
  sum.to_double() / self.floor_times.length().to_double()
}

// Run a single headless simulation and collect metrics
pub fn run_simulation(
  params : @game.BalanceParams,
  seed : Int,
  max_frames : Int,
) -> SimMetrics {
  let world = @game.GameWorld::new(seed~, params~)
  world.auto_play = true
  world.mode = @game.Playing
  let hp_samples : Array[Double] = []
  let floor_times : Array[Int] = []
  let mut total_damage = 0
  let mut total_kills = 0
  let mut floor_start_frame = 0
  let sample_interval = 30 // sample HP every 0.5 seconds
  for frame = 0; frame < max_frames; frame = frame + 1 {
    world.tick_auto()
    // Sample HP ratio
    if frame % sample_interval == 0 {
      let ratio = world.player.hp.to_double() / world.player_stats.max_hp.to_double()
      hp_samples.push(ratio)
    }
    // Process events
    let events = world.drain_events()
    for event in events {
      match event {
        @game.FloorComplete => {
          floor_times.push(frame - floor_start_frame)
          floor_start_frame = frame
        }
        @game.HurtTriggered => total_damage = total_damage + 1
        @game.DeathBurst(_, _) => total_kills = total_kills + 1
        _ => ()
      }
    }
    if world.mode == @game.GameOver {
      return {
        survival_frames: frame,
        floors_cleared: world.floor - 1,
        total_damage_taken: total_damage,
        total_kills,
        score: world.score,
        hp_samples,
        floor_times,
      }
    }
  }
  {
    survival_frames: max_frames,
    floors_cleared: world.floor - 1,
    total_damage_taken: total_damage,
    total_kills,
    score: world.score,
    hp_samples,
    floor_times,
  }
}
