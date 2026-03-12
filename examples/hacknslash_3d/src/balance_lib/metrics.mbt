// SimMetrics: statistics collected from a headless simulation run

///|
pub(all) struct SimMetrics {
  survival_frames : Int
  floors_cleared : Int
  total_damage_taken : Int
  total_kills : Int
  score : Int
  hp_samples : Array[Double] // hp/max_hp ratio sampled periodically
  floor_times : Array[Int] // frames per floor
  // Extended metrics
  kill_frames : Array[Int] // frame number of each kill (for kill pacing)
  damage_frames : Array[Int] // frame number of each damage event
  equip_upgrades : Int // number of equipment upgrades
  near_death_count : Int // times HP dropped below 25%
}

///|
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

///|
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

///|
pub fn SimMetrics::hp_coefficient_of_variation(self : SimMetrics) -> Double {
  let mean = self.avg_hp_ratio()
  if mean < 0.001 {
    return 0.0
  }
  self.hp_variance().sqrt() / mean
}

///|
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

// Kill pacing: average frames between kills (lower = more action-dense)

///|
pub fn SimMetrics::avg_kill_interval(self : SimMetrics) -> Double {
  if self.kill_frames.length() < 2 {
    return 0.0
  }
  let mut sum = 0
  for i = 1; i < self.kill_frames.length(); i = i + 1 {
    sum = sum + self.kill_frames[i] - self.kill_frames[i - 1]
  }
  sum.to_double() / (self.kill_frames.length() - 1).to_double()
}

// Kill pacing variance (low = monotonous, high = varied encounters)

///|
pub fn SimMetrics::kill_interval_cv(self : SimMetrics) -> Double {
  if self.kill_frames.length() < 3 {
    return 0.0
  }
  let mean = self.avg_kill_interval()
  if mean < 0.001 {
    return 0.0
  }
  let mut sum_sq = 0.0
  for i = 1; i < self.kill_frames.length(); i = i + 1 {
    let interval = (self.kill_frames[i] - self.kill_frames[i - 1]).to_double()
    let d = interval - mean
    sum_sq = sum_sq + d * d
  }
  let variance = sum_sq / (self.kill_frames.length() - 1).to_double()
  variance.sqrt() / mean
}

// Damage pacing: average frames between damage events

///|
pub fn SimMetrics::avg_damage_interval(self : SimMetrics) -> Double {
  if self.damage_frames.length() < 2 {
    return 0.0
  }
  let mut sum = 0
  for i = 1; i < self.damage_frames.length(); i = i + 1 {
    sum = sum + self.damage_frames[i] - self.damage_frames[i - 1]
  }
  sum.to_double() / (self.damage_frames.length() - 1).to_double()
}

// Kills per floor (combat density per area)

///|
pub fn SimMetrics::kills_per_floor(self : SimMetrics) -> Double {
  if self.floors_cleared == 0 {
    return self.total_kills.to_double()
  }
  self.total_kills.to_double() / self.floors_cleared.to_double()
}

// Near-death rate: fraction of time spent below 25% HP

///|
pub fn SimMetrics::near_death_rate(self : SimMetrics) -> Double {
  if self.hp_samples.length() == 0 {
    return 0.0
  }
  let mut count = 0
  for s in self.hp_samples {
    if s < 0.25 {
      count = count + 1
    }
  }
  count.to_double() / self.hp_samples.length().to_double()
}

// Run a single headless simulation and collect metrics

///|
pub fn run_simulation(
  params : @game.BalanceParams,
  seed : Int,
  max_frames : Int,
) -> SimMetrics {
  run_simulation_from_floor(params, seed, max_frames, 1)
}

///|
pub fn run_simulation_from_floor(
  params : @game.BalanceParams,
  seed : Int,
  max_frames : Int,
  start_floor : Int,
) -> SimMetrics {
  let world = @game.GameWorld::new(seed~, params~)
  if start_floor > 1 {
    world.floor = start_floor
    world.apply_dungeon(seed + start_floor * 1000, start_floor)
  }
  world.auto_play = true
  world.mode = @game.Playing
  let hp_samples : Array[Double] = []
  let floor_times : Array[Int] = []
  let kill_frames : Array[Int] = []
  let damage_frames : Array[Int] = []
  let mut total_damage = 0
  let mut total_kills = 0
  let mut floor_start_frame = 0
  let mut equip_upgrades = 0
  let mut near_death_count = 0
  let sample_interval = 30
  let mut prev_weapon_atk = 0
  let mut prev_armor_def = 0
  for frame = 0; frame < max_frames; frame = frame + 1 {
    world.tick_auto()
    // Sample HP ratio
    if frame % sample_interval == 0 {
      let ratio = world.player.hp.to_double() /
        world.player_stats.max_hp.to_double()
      hp_samples.push(ratio)
      if ratio < 0.25 {
        near_death_count = near_death_count + 1
      }
    }
    // Track equipment upgrades
    let cur_atk = world.player_stats.atk
    let cur_def = world.player_stats.def
    if cur_atk > prev_weapon_atk || cur_def > prev_armor_def {
      if frame > 0 {
        equip_upgrades = equip_upgrades + 1
      }
      prev_weapon_atk = cur_atk
      prev_armor_def = cur_def
    }
    // Process events
    let events = world.drain_events()
    for event in events {
      match event {
        @game.FloorComplete => {
          floor_times.push(frame - floor_start_frame)
          floor_start_frame = frame
        }
        @game.HurtTriggered => {
          total_damage = total_damage + 1
          damage_frames.push(frame)
        }
        @game.DeathBurst(_, _) => {
          total_kills = total_kills + 1
          kill_frames.push(frame)
        }
        _ => ()
      }
    }
    if world.mode == @game.GameOver {
      return {
        survival_frames: frame,
        floors_cleared: @cmp.maximum(0, world.floor - start_floor),
        total_damage_taken: total_damage,
        total_kills,
        score: world.score,
        hp_samples,
        floor_times,
        kill_frames,
        damage_frames,
        equip_upgrades,
        near_death_count,
      }
    }
  }
  {
    survival_frames: max_frames,
    floors_cleared: @cmp.maximum(0, world.floor - start_floor),
    total_damage_taken: total_damage,
    total_kills,
    score: world.score,
    hp_samples,
    floor_times,
    kill_frames,
    damage_frames,
    equip_upgrades,
    near_death_count,
  }
}
