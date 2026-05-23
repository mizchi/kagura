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
    {
      metric: "equip_upgrades",
      target: self.target_equip_upgrades,
      weight: self.w_equip_upgrades,
    },
    {
      metric: "learned_skill_count",
      target: self.target_learned_skill_count,
      weight: self.w_learned_skill_count,
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
  m.set("learned_skill_count", self.learned_skill_count.to_double())
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
  archetype : @game.CharacterArchetype,
  build_policy : @game.ArchetypeBuildPolicy,
) -> (Array[Double], Int) -> @dec.Metrics {
  fn(params : Array[Double], seed : Int) -> @dec.Metrics {
    let bp = {
      ..@game.BalanceParams::from_array(params).clamp(),
      affix_profile,
    }
    let sim = run_simulation_from_floor(
      bp,
      seed,
      max_frames,
      start_floor,
      archetype~,
      build_policy~,
    )
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
    (8.0, 30.0), // player_base_hp
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
    (0.0, 1.5), // item_base_tier_per_floor
    (0.0, 1.5), // item_prefix_tier_per_floor
    (0.0, 1.5), // item_suffix_tier_per_floor
    (0.0, 1.0), // item_modifier_tier_per_floor
    (0.75, 2.0), // map_room_count_scale
    (0.8, 2.0), // map_room_size_scale
    (0.0, 3.0), // map_corridor_width_bonus
    (0.0, 2.0), // pack_large_room_bonus
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
    (8.0, 10.0), // player_base_hp
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
    (0.0, 1.0), // item_base_tier_per_floor
    (0.0, 1.0), // item_prefix_tier_per_floor
    (0.0, 1.0), // item_suffix_tier_per_floor
    (0.0, 0.8), // item_modifier_tier_per_floor
    (0.85, 1.6), // map_room_count_scale
    (0.9, 1.7), // map_room_size_scale
    (0.0, 2.0), // map_corridor_width_bonus
    (0.0, 1.5), // pack_large_room_bonus
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
pub fn param_specs_autoplay_progression() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  let bounds : Array[(Double, Double)] = [
    (1.15, 1.7), // player_speed
    (0.8, 2.1), // enemy_speed_basic
    (1.2, 2.8), // enemy_speed_fast
    (0.4, 1.2), // enemy_speed_tank
    (22.0, 42.0), // attack_cooldown
    (2.5, 3.8), // arrow_speed
    (130.0, 180.0), // arrow_range
    (18.0, 38.0), // bow_cooldown
    (130.0, 220.0), // chase_range
    (2.0, 3.8), // knockback_strength
    (10.0, 26.0), // iframe_duration
    (4.0, 10.0), // dash_duration
    (35.0, 75.0), // dash_cooldown
    (2.5, 4.0), // dash_speed_mult
    (4.5, 10.0), // basic_hp
    (2.5, 8.0), // fast_hp
    (8.0, 22.0), // tank_hp
    (2.0, 7.0), // ranged_hp
    (20.0, 52.0), // boss_hp_base
    (2.0, 6.5), // boss_hp_per_floor
    (1.0, 3.0), // enemy_contact_damage
    (8.0, 12.0), // player_base_hp
    (1.0, 1.7), // spawn_density
    (1.0, 1.8), // spell_cooldown_mult
    (0.45, 0.9), // spell_damage_mult
    (1.0, 3.2), // enemy_bolt_damage
    (45.0, 110.0), // ranged_shot_cooldown
    (6.0, 24.0), // levelup_xp_base
    (2.0, 12.0), // levelup_xp_growth
    (10.0, 55.0), // drop_equipment_weight
    (5.0, 35.0), // drop_health_weight
    (5.0, 55.0), // drop_score_weight
    (1.0, 6.0), // drop_weapon_weight
    (1.0, 6.0), // drop_armor_weight
    (1.0, 6.0), // drop_accessory_weight
    (0.0, 4.0), // item_rarity_bonus_per_floor
    (0.0, 1.0), // item_base_tier_per_floor
    (0.0, 0.8), // item_prefix_tier_per_floor
    (0.0, 0.8), // item_suffix_tier_per_floor
    (0.0, 0.6), // item_modifier_tier_per_floor
    (0.95, 1.6), // map_room_count_scale
    (1.0, 1.7), // map_room_size_scale
    (0.0, 2.0), // map_corridor_width_bonus
    (0.0, 1.5), // pack_large_room_bonus
    (0.0, 0.35), // enemy_hp_floor_scale
    (0.0, 0.15), // enemy_speed_floor_scale
    (0.0, 0.3), // enemy_damage_floor_scale
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
pub fn param_specs_build_diverse() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  let bounds : Array[(Double, Double)] = [
    (1.0, 2.0), // player_speed
    (0.8, 2.4), // enemy_speed_basic
    (1.0, 3.0), // enemy_speed_fast
    (0.4, 1.6), // enemy_speed_tank
    (16.0, 42.0), // attack_cooldown
    (2.5, 4.5), // arrow_speed
    (90.0, 170.0), // arrow_range
    (12.0, 32.0), // bow_cooldown
    (110.0, 220.0), // chase_range
    (1.5, 4.0), // knockback_strength
    (10.0, 28.0), // iframe_duration
    (4.0, 12.0), // dash_duration
    (28.0, 70.0), // dash_cooldown
    (2.2, 4.0), // dash_speed_mult
    (4.0, 12.0), // basic_hp
    (2.0, 10.0), // fast_hp
    (8.0, 24.0), // tank_hp
    (2.0, 9.0), // ranged_hp
    (18.0, 60.0), // boss_hp_base
    (1.5, 7.5), // boss_hp_per_floor
    (1.0, 4.0), // enemy_contact_damage
    (8.0, 10.0), // player_base_hp
    (1.0, 2.2), // spawn_density
    (0.8, 1.8), // spell_cooldown_mult
    (0.45, 1.2), // spell_damage_mult
    (1.0, 4.0), // enemy_bolt_damage
    (35.0, 110.0), // ranged_shot_cooldown
    (4.0, 18.0), // levelup_xp_base
    (0.5, 8.0), // levelup_xp_growth
    (20.0, 75.0), // drop_equipment_weight
    (5.0, 35.0), // drop_health_weight
    (5.0, 35.0), // drop_score_weight
    (1.0, 8.0), // drop_weapon_weight
    (1.0, 8.0), // drop_armor_weight
    (1.0, 8.0), // drop_accessory_weight
    (0.0, 6.0), // item_rarity_bonus_per_floor
    (0.0, 1.4), // item_base_tier_per_floor
    (0.0, 1.2), // item_prefix_tier_per_floor
    (0.0, 1.2), // item_suffix_tier_per_floor
    (0.0, 0.8), // item_modifier_tier_per_floor
    (1.0, 1.8), // map_room_count_scale
    (1.0, 1.9), // map_room_size_scale
    (0.0, 2.5), // map_corridor_width_bonus
    (0.0, 1.8), // pack_large_room_bonus
    (0.0, 0.45), // enemy_hp_floor_scale
    (0.0, 0.2), // enemy_speed_floor_scale
    (0.0, 0.35), // enemy_damage_floor_scale
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
pub fn param_specs_item_spike_feedback() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  let bounds : Array[(Double, Double)] = [
    (0.95, 1.8), // player_speed
    (0.8, 2.2), // enemy_speed_basic
    (1.0, 2.8), // enemy_speed_fast
    (0.4, 1.5), // enemy_speed_tank
    (16.0, 40.0), // attack_cooldown
    (2.5, 4.5), // arrow_speed
    (100.0, 175.0), // arrow_range
    (12.0, 34.0), // bow_cooldown
    (110.0, 220.0), // chase_range
    (1.5, 4.0), // knockback_strength
    (10.0, 28.0), // iframe_duration
    (4.0, 12.0), // dash_duration
    (28.0, 70.0), // dash_cooldown
    (2.2, 4.0), // dash_speed_mult
    (4.0, 12.0), // basic_hp
    (2.0, 10.0), // fast_hp
    (8.0, 24.0), // tank_hp
    (2.0, 9.0), // ranged_hp
    (18.0, 60.0), // boss_hp_base
    (1.5, 7.5), // boss_hp_per_floor
    (1.0, 4.0), // enemy_contact_damage
    (8.0, 10.0), // player_base_hp
    (1.0, 2.0), // spawn_density
    (0.8, 1.8), // spell_cooldown_mult
    (0.5, 1.3), // spell_damage_mult
    (1.0, 4.0), // enemy_bolt_damage
    (35.0, 110.0), // ranged_shot_cooldown
    (4.0, 18.0), // levelup_xp_base
    (0.5, 8.0), // levelup_xp_growth
    (30.0, 85.0), // drop_equipment_weight
    (5.0, 25.0), // drop_health_weight
    (5.0, 25.0), // drop_score_weight
    (2.0, 10.0), // drop_weapon_weight
    (2.0, 10.0), // drop_armor_weight
    (2.0, 10.0), // drop_accessory_weight
    (1.0, 8.0), // item_rarity_bonus_per_floor
    (0.3, 1.5), // item_base_tier_per_floor
    (0.2, 1.4), // item_prefix_tier_per_floor
    (0.2, 1.2), // item_suffix_tier_per_floor
    (0.1, 1.0), // item_modifier_tier_per_floor
    (1.0, 1.7), // map_room_count_scale
    (1.1, 1.9), // map_room_size_scale
    (0.5, 2.5), // map_corridor_width_bonus
    (0.3, 2.2), // pack_large_room_bonus
    (0.05, 0.4), // enemy_hp_floor_scale
    (0.01, 0.18), // enemy_speed_floor_scale
    (0.05, 0.35), // enemy_damage_floor_scale
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
pub fn param_specs_mechanics_roguelike() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  let bounds : Array[(Double, Double)] = [
    (0.9, 1.5), // player_speed
    (0.9, 2.5), // enemy_speed_basic
    (1.2, 3.2), // enemy_speed_fast
    (0.5, 1.8), // enemy_speed_tank
    (18.0, 48.0), // attack_cooldown
    (2.5, 4.2), // arrow_speed
    (90.0, 160.0), // arrow_range
    (14.0, 36.0), // bow_cooldown
    (110.0, 220.0), // chase_range
    (1.5, 3.5), // knockback_strength
    (10.0, 28.0), // iframe_duration
    (4.0, 11.0), // dash_duration
    (30.0, 72.0), // dash_cooldown
    (2.2, 3.8), // dash_speed_mult
    (4.0, 11.0), // basic_hp
    (2.0, 9.0), // fast_hp
    (8.0, 24.0), // tank_hp
    (2.0, 8.0), // ranged_hp
    (22.0, 64.0), // boss_hp_base
    (2.0, 8.0), // boss_hp_per_floor
    (1.5, 4.5), // enemy_contact_damage
    (8.0, 12.0), // player_base_hp
    (1.2, 2.4), // spawn_density
    (1.0, 1.9), // spell_cooldown_mult
    (0.4, 0.85), // spell_damage_mult
    (1.5, 4.8), // enemy_bolt_damage
    (35.0, 95.0), // ranged_shot_cooldown
    (5.0, 20.0), // levelup_xp_base
    (1.0, 10.0), // levelup_xp_growth
    (10.0, 45.0), // drop_equipment_weight
    (5.0, 35.0), // drop_health_weight
    (5.0, 25.0), // drop_score_weight
    (1.0, 6.0), // drop_weapon_weight
    (1.0, 6.0), // drop_armor_weight
    (1.0, 6.0), // drop_accessory_weight
    (0.5, 5.0), // item_rarity_bonus_per_floor
    (0.1, 1.2), // item_base_tier_per_floor
    (0.1, 1.0), // item_prefix_tier_per_floor
    (0.1, 1.0), // item_suffix_tier_per_floor
    (0.0, 0.7), // item_modifier_tier_per_floor
    (0.95, 1.5), // map_room_count_scale
    (1.0, 1.6), // map_room_size_scale
    (0.0, 1.5), // map_corridor_width_bonus
    (0.0, 1.2), // pack_large_room_bonus
    (0.1, 0.55), // enemy_hp_floor_scale
    (0.02, 0.25), // enemy_speed_floor_scale
    (0.08, 0.45), // enemy_damage_floor_scale
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
pub fn param_specs_mechanics_roguelike_v2() -> Array[@dec.ParamSpec] {
  let d = @game.BalanceParams::default()
  let names = @game.BalanceParams::param_names()
  let defaults = d.to_array()
  let bounds : Array[(Double, Double)] = [
    (0.9, 1.45), // player_speed
    (0.95, 2.5), // enemy_speed_basic
    (1.3, 3.2), // enemy_speed_fast
    (0.5, 1.8), // enemy_speed_tank
    (18.0, 48.0), // attack_cooldown
    (2.5, 4.2), // arrow_speed
    (90.0, 150.0), // arrow_range
    (14.0, 36.0), // bow_cooldown
    (110.0, 220.0), // chase_range
    (1.5, 3.2), // knockback_strength
    (10.0, 28.0), // iframe_duration
    (4.0, 11.0), // dash_duration
    (30.0, 72.0), // dash_cooldown
    (2.2, 3.8), // dash_speed_mult
    (4.5, 11.0), // basic_hp
    (2.5, 9.0), // fast_hp
    (8.0, 24.0), // tank_hp
    (2.0, 8.0), // ranged_hp
    (22.0, 64.0), // boss_hp_base
    (2.0, 8.0), // boss_hp_per_floor
    (1.5, 4.5), // enemy_contact_damage
    (8.0, 12.0), // player_base_hp
    (1.0, 2.3), // spawn_density
    (1.0, 1.9), // spell_cooldown_mult
    (0.35, 0.8), // spell_damage_mult
    (1.8, 4.8), // enemy_bolt_damage
    (35.0, 90.0), // ranged_shot_cooldown
    (2.5, 10.0), // levelup_xp_base
    (0.2, 4.5), // levelup_xp_growth
    (15.0, 55.0), // drop_equipment_weight
    (5.0, 30.0), // drop_health_weight
    (5.0, 25.0), // drop_score_weight
    (1.0, 7.0), // drop_weapon_weight
    (1.0, 7.0), // drop_armor_weight
    (1.0, 7.0), // drop_accessory_weight
    (1.0, 6.0), // item_rarity_bonus_per_floor
    (0.2, 1.3), // item_base_tier_per_floor
    (0.2, 1.1), // item_prefix_tier_per_floor
    (0.2, 1.1), // item_suffix_tier_per_floor
    (0.1, 0.8), // item_modifier_tier_per_floor
    (0.9, 1.35), // map_room_count_scale
    (1.05, 1.75), // map_room_size_scale
    (0.0, 1.5), // map_corridor_width_bonus
    (0.3, 1.6), // pack_large_room_bonus
    (0.12, 0.55), // enemy_hp_floor_scale
    (0.04, 0.25), // enemy_speed_floor_scale
    (0.1, 0.45), // enemy_damage_floor_scale
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
pub fn param_specs_for_hypothesis(
  hypothesis_name : String,
) -> Array[@dec.ParamSpec] {
  if hypothesis_name == "autoplay_progression" ||
    hypothesis_name == "autoplay_progression_v2" ||
    hypothesis_name == "autoplay_progression_v3" {
    param_specs_autoplay_progression()
  } else if hypothesis_name == "item_spike_feedback" {
    param_specs_item_spike_feedback()
  } else if hypothesis_name == "build_diverse_hackslash" {
    param_specs_build_diverse()
  } else if hypothesis_name == "mechanics_roguelike" {
    param_specs_mechanics_roguelike()
  } else if hypothesis_name == "mechanics_roguelike_v2" {
    param_specs_mechanics_roguelike_v2()
  } else if hypothesis_name == "autoplay_rebalance" ||
    hypothesis_name == "autoplay_pressure" ||
    hypothesis_name == "autoplay_attrition" {
    param_specs_autoplay_rebalance()
  } else {
    param_specs()
  }
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
