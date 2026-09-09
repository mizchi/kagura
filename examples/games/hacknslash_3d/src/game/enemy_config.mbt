// Enemy type configuration: data-only definitions for each enemy kind.
// Edit this file to tweak enemy balance without touching AI/spawn logic.

///|
pub(all) struct EnemyTypeConfig {
  kind : EnemyKind
  hp_param : Double // which BalanceParams HP value to use (direct value)
  speed_param : Double // base speed multiplier
  size : Double // collision/render size
  spawn_weight : Int // relative spawn weight (higher = more common)
  xp_reward : Int // XP given on death
  drop_chance : Int // percent chance to drop item (0-100)
  drop_count_max : Int // max items dropped
}

///|
pub fn enemy_type_configs() -> Array[EnemyTypeConfig] {
  [
    // Basic: standard melee grunt
    {
      kind: Basic,
      hp_param: 1.0,
      speed_param: 1.0,
      size: 10.0,
      spawn_weight: 5,
      xp_reward: 1,
      drop_chance: 40,
      drop_count_max: 1,
    },
    // Fast: quick and fragile
    {
      kind: Fast,
      hp_param: 0.67,
      speed_param: 1.5,
      size: 8.0,
      spawn_weight: 3,
      xp_reward: 1,
      drop_chance: 40,
      drop_count_max: 1,
    },
    // Tank: slow and tough, fire nova on death
    {
      kind: Tank,
      hp_param: 2.5,
      speed_param: 0.5,
      size: 14.0,
      spawn_weight: 2,
      xp_reward: 2,
      drop_chance: 80,
      drop_count_max: 2,
    },
    // Ranged: shoots barrage, can cast meteor
    {
      kind: Ranged,
      hp_param: 0.67,
      speed_param: 0.4,
      size: 8.0,
      spawn_weight: 2,
      xp_reward: 2,
      drop_chance: 40,
      drop_count_max: 1,
    },
    // Exploder: charges then explodes on death
    {
      kind: Exploder,
      hp_param: 0.67,
      speed_param: 1.8,
      size: 7.0,
      spawn_weight: 2,
      xp_reward: 1,
      drop_chance: 40,
      drop_count_max: 1,
    },
    // Berserker: gets faster as HP decreases
    {
      kind: Berserker,
      hp_param: 2.5,
      speed_param: 1.0,
      size: 12.0,
      spawn_weight: 2,
      xp_reward: 2,
      drop_chance: 80,
      drop_count_max: 1,
    },
    // Summoner: spawns Swarm minions periodically
    {
      kind: Summoner,
      hp_param: 0.67,
      speed_param: 0.35,
      size: 9.0,
      spawn_weight: 1,
      xp_reward: 2,
      drop_chance: 80,
      drop_count_max: 1,
    },
    // Teleporter: blinks behind player
    {
      kind: Teleporter,
      hp_param: 0.67,
      speed_param: 1.0,
      size: 8.0,
      spawn_weight: 1,
      xp_reward: 2,
      drop_chance: 40,
      drop_count_max: 1,
    },
    // Caster: channels meteor, must be interrupted
    {
      kind: Caster,
      hp_param: 1.0,
      speed_param: 0.35,
      size: 9.0,
      spawn_weight: 1,
      xp_reward: 2,
      drop_chance: 80,
      drop_count_max: 1,
    },
    // Swarm: tiny, weak, spawns in groups
    {
      kind: Swarm,
      hp_param: 0.33,
      speed_param: 1.5,
      size: 5.0,
      spawn_weight: 1,
      xp_reward: 1,
      drop_chance: 10,
      drop_count_max: 1,
    },
  ]
}

///|
pub fn find_enemy_type_config(kind : EnemyKind) -> EnemyTypeConfig {
  let configs = enemy_type_configs()
  for config in configs {
    if config.kind == kind {
      return config
    }
  }
  // Fallback to Basic
  configs[0]
}

// === Behavior tuning parameters ===

///|
pub let berserker_rage_max_mult : Double = 1.5 // velocity multiplier at 0% HP

///|
pub let teleporter_blink_distance : Double = 30.0

///|
pub let teleporter_blink_cooldown : Int = 180 // 3 seconds

///|
pub let teleporter_angle_offset : Double = 0.3

///|
pub let summoner_cooldown : Int = 240 // 4 seconds

///|
pub let summoner_spawn_offset : Int = 10 // ±pixels from summoner

///|
pub let summoner_minion_speed_mult : Double = 1.2

///|
pub let summoner_minion_size : Double = 6.0

///|
pub let ranged_min_distance_sq : Double = 3600.0 // 60^2

///|
pub let ranged_retreat_speed : Double = 0.3

///|
pub let ranged_meteor_chance : Int = 25 // percent

///|
pub let caster_min_distance_sq : Double = 900.0 // 30^2

///|
pub let exploder_damage_mult : Int = 3

///|
pub let exploder_radius_mult : Double = 1.5

///|
pub let spawn_safe_distance : Int = 8

///|
pub let spawn_area_divisor : Int = 15

///|
pub let spawn_base_count_max : Int = 5
