// Adapter: bridge between game simulation and @dec.tune() API

///|
/// Convert BalanceTargets to @dec.BalanceTarget array
pub fn BalanceTargets::to_dec_targets(
  self : BalanceTargets,
) -> Array[@dec.BalanceTarget] {
  [
    {
      metric: "survival_frames",
      target: self.target_survival_frames,
      weight: self.w_survival,
    },
    {
      metric: "floors_cleared",
      target: self.target_floors,
      weight: self.w_floor,
    },
    {
      metric: "floor_time",
      target: self.target_floor_time,
      weight: self.w_floor_time,
    },
    { metric: "hp_cv", target: self.target_hp_cv, weight: self.w_hp_cv },
    {
      metric: "kill_interval",
      target: self.target_kill_interval,
      weight: self.w_kill_interval,
    },
    {
      metric: "kill_cv",
      target: self.target_kill_interval_cv,
      weight: self.w_kill_cv,
    },
    {
      metric: "near_death_rate",
      target: self.target_near_death_rate,
      weight: self.w_near_death,
    },
    {
      metric: "kills_per_floor",
      target: self.target_kills_per_floor,
      weight: self.w_kills_per_floor,
    },
    {
      metric: "damage_interval",
      target: self.target_damage_interval,
      weight: self.w_damage_interval,
    },
    {
      metric: "total_damage",
      target: self.target_total_damage,
      weight: self.w_total_damage,
    },
  ]
}

///|
/// Convert SimMetrics to @dec.Metrics
pub fn SimMetrics::to_dec_metrics(self : SimMetrics) -> @dec.Metrics {
  let m = @dec.Metrics::new()
  m.set("survival_frames", self.survival_frames.to_double())
  m.set("floors_cleared", self.floors_cleared.to_double())
  m.set("floor_time", self.avg_floor_time())
  m.set("hp_cv", self.hp_coefficient_of_variation())
  m.set("kill_interval", self.avg_kill_interval())
  m.set("kill_cv", self.kill_interval_cv())
  m.set("near_death_rate", self.near_death_rate())
  m.set("kills_per_floor", self.kills_per_floor())
  m.set("damage_interval", self.avg_damage_interval())
  // Extra metrics for reporting
  m.set("total_kills", self.total_kills.to_double())
  m.set("total_damage", self.total_damage_taken.to_double())
  m.set("score", self.score.to_double())
  m.set("avg_hp_ratio", self.avg_hp_ratio())
  m.set("equip_upgrades", self.equip_upgrades.to_double())
  m
}

///|
/// Create a simulation function compatible with @dec.tune()
/// affix_profile and max_frames are captured in the closure
pub fn make_sim(
  affix_profile : Int,
  max_frames : Int,
) -> (Array[Double], Int) -> @dec.Metrics {
  fn(params : Array[Double], seed : Int) -> @dec.Metrics {
    let bp = {
      ..@game.BalanceParams::from_array(params).clamp(),
      affix_profile,
    }
    let sim = run_simulation(bp, seed, max_frames)
    sim.to_dec_metrics()
  }
}

///|
pub fn make_autoplay_rebalance_sim(
  affix_profile : Int,
  max_frames : Int,
  start_floor : Int,
) -> (Array[Double], Int) -> @dec.Metrics {
  fn(params : Array[Double], seed : Int) -> @dec.Metrics {
    let bp = {
      ..@game.BalanceParams::from_array(params).clamp(),
      affix_profile,
    }
    let sim = run_simulation_from_floor(bp, seed, max_frames, start_floor)
    sim.to_dec_metrics()
  }
}

///|
/// Generate ParamSpecs from BalanceParams defaults and clamp bounds
pub fn param_specs() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  // min/max from BalanceParams::clamp()
  let bounds : Array[(Double, Double)] = [
    (0.5, 5.0), // player_speed
    (0.2, 3.0), // enemy_speed_basic
    (0.3, 4.0), // enemy_speed_fast
    (0.1, 2.0), // enemy_speed_tank
    (5.0, 60.0), // attack_cooldown
    (1.0, 10.0), // arrow_speed
    (40.0, 400.0), // arrow_range
    (3.0, 40.0), // bow_cooldown
    (60.0, 300.0), // chase_range
    (0.5, 10.0), // knockback_strength
    (5.0, 60.0), // iframe_duration
    (3.0, 20.0), // dash_duration
    (10.0, 80.0), // dash_cooldown
    (1.5, 8.0), // dash_speed_mult
    (1.0, 20.0), // basic_hp
    (1.0, 15.0), // fast_hp
    (3.0, 30.0), // tank_hp
    (1.0, 10.0), // ranged_hp
    (5.0, 60.0), // boss_hp_base
    (0.5, 10.0), // boss_hp_per_floor
    (1.0, 8.0), // enemy_contact_damage
    (3.0, 30.0), // player_base_hp
    (0.5, 3.0), // spawn_density
    (0.5, 3.0), // spell_cooldown_mult
    (0.3, 2.0), // spell_damage_mult
    (1.0, 8.0), // enemy_bolt_damage
    (20.0, 180.0), // ranged_shot_cooldown
    (1.0, 100.0), // levelup_xp_base
    (0.0, 50.0), // levelup_xp_growth
    (0.0, 100.0), // drop_equipment_weight
    (0.0, 100.0), // drop_health_weight
    (0.0, 100.0), // drop_score_weight
    (0.0, 100.0), // drop_weapon_weight
    (0.0, 100.0), // drop_armor_weight
    (0.0, 100.0), // drop_accessory_weight
    (0.0, 10.0), // item_rarity_bonus_per_floor
    (0.0, 1.0), // enemy_hp_floor_scale
    (0.0, 0.5), // enemy_speed_floor_scale
    (0.0, 1.0), // enemy_damage_floor_scale
  ]
  let specs : Array[@dec.ParamSpec] = []
  for i = 0; i < names.length(); i = i + 1 {
    let (lo, hi) = bounds[i]
    specs.push({ name: names[i], initial: defaults[i], min: lo, max: hi })
  }
  specs
}

///|
pub fn param_specs_autoplay_rebalance() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  let bounds : Array[(Double, Double)] = [
    (1.2, 2.0), // player_speed
    (0.8, 2.5), // enemy_speed_basic
    (1.2, 3.5), // enemy_speed_fast
    (0.4, 1.5), // enemy_speed_tank
    (20.0, 50.0), // attack_cooldown
    (2.5, 4.0), // arrow_speed
    (120.0, 180.0), // arrow_range
    (15.0, 40.0), // bow_cooldown
    (120.0, 240.0), // chase_range
    (2.0, 4.5), // knockback_strength
    (10.0, 30.0), // iframe_duration
    (4.0, 10.0), // dash_duration
    (35.0, 80.0), // dash_cooldown
    (2.5, 4.0), // dash_speed_mult
    (3.0, 12.0), // basic_hp
    (2.0, 10.0), // fast_hp
    (8.0, 25.0), // tank_hp
    (2.0, 8.0), // ranged_hp
    (20.0, 60.0), // boss_hp_base
    (2.0, 8.0), // boss_hp_per_floor
    (1.0, 4.0), // enemy_contact_damage
    (3.0, 10.0), // player_base_hp
    (1.0, 2.0), // spawn_density
    (1.0, 2.2), // spell_cooldown_mult
    (0.35, 1.0), // spell_damage_mult
    (1.0, 4.0), // enemy_bolt_damage
    (40.0, 120.0), // ranged_shot_cooldown
    (6.0, 30.0), // levelup_xp_base
    (2.0, 15.0), // levelup_xp_growth
    (10.0, 60.0), // drop_equipment_weight
    (5.0, 40.0), // drop_health_weight
    (5.0, 60.0), // drop_score_weight
    (1.0, 6.0), // drop_weapon_weight
    (1.0, 6.0), // drop_armor_weight
    (1.0, 6.0), // drop_accessory_weight
    (0.0, 5.0), // item_rarity_bonus_per_floor
    (0.0, 0.5), // enemy_hp_floor_scale
    (0.0, 0.2), // enemy_speed_floor_scale
    (0.0, 0.4), // enemy_damage_floor_scale
  ]
  let specs : Array[@dec.ParamSpec] = []
  for i = 0; i < names.length(); i = i + 1 {
    let (lo, hi) = bounds[i]
    let initial = clamp_param_initial(defaults[i], lo, hi)
    specs.push({ name: names[i], initial, min: lo, max: hi })
  }
  specs
}

///|
fn clamp_param_initial(initial : Double, lo : Double, hi : Double) -> Double {
  if initial < lo {
    lo
  } else if initial > hi {
    hi
  } else {
    initial
  }
}
