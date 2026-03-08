// BalanceParams: tunable game parameters for automatic balance optimization
// All values are Double for smooth optimization; cast to Int at use site

pub(all) struct BalanceParams {
  player_speed : Double
  enemy_speed_basic : Double
  enemy_speed_fast : Double
  enemy_speed_tank : Double
  attack_cooldown : Double
  arrow_speed : Double
  arrow_range : Double
  bow_cooldown : Double
  chase_range : Double
  knockback_strength : Double
  iframe_duration : Double
  dash_duration : Double
  dash_cooldown : Double
  dash_speed_mult : Double
  basic_hp : Double
  fast_hp : Double
  tank_hp : Double
  ranged_hp : Double
  boss_hp_base : Double
  boss_hp_per_floor : Double
}

pub let balance_param_count : Int = 20

pub fn BalanceParams::default() -> BalanceParams {
  {
    player_speed: 2.0,
    enemy_speed_basic: 0.8,
    enemy_speed_fast: 1.2,
    enemy_speed_tank: 0.4,
    attack_cooldown: 20.0,
    arrow_speed: 4.0,
    arrow_range: 160.0,
    bow_cooldown: 15.0,
    chase_range: 120.0,
    knockback_strength: 4.0,
    iframe_duration: 30.0,
    dash_duration: 8.0,
    dash_cooldown: 40.0,
    dash_speed_mult: 4.0,
    basic_hp: 3.0,
    fast_hp: 2.0,
    tank_hp: 8.0,
    ranged_hp: 2.0,
    boss_hp_base: 20.0,
    boss_hp_per_floor: 2.0,
  }
}

pub fn BalanceParams::to_array(self : BalanceParams) -> Array[Double] {
  [
    self.player_speed, self.enemy_speed_basic, self.enemy_speed_fast,
    self.enemy_speed_tank, self.attack_cooldown, self.arrow_speed,
    self.arrow_range, self.bow_cooldown, self.chase_range,
    self.knockback_strength, self.iframe_duration, self.dash_duration,
    self.dash_cooldown, self.dash_speed_mult, self.basic_hp, self.fast_hp,
    self.tank_hp, self.ranged_hp, self.boss_hp_base, self.boss_hp_per_floor,
  ]
}

pub fn BalanceParams::from_array(arr : Array[Double]) -> BalanceParams {
  {
    player_speed: arr[0],
    enemy_speed_basic: arr[1],
    enemy_speed_fast: arr[2],
    enemy_speed_tank: arr[3],
    attack_cooldown: arr[4],
    arrow_speed: arr[5],
    arrow_range: arr[6],
    bow_cooldown: arr[7],
    chase_range: arr[8],
    knockback_strength: arr[9],
    iframe_duration: arr[10],
    dash_duration: arr[11],
    dash_cooldown: arr[12],
    dash_speed_mult: arr[13],
    basic_hp: arr[14],
    fast_hp: arr[15],
    tank_hp: arr[16],
    ranged_hp: arr[17],
    boss_hp_base: arr[18],
    boss_hp_per_floor: arr[19],
  }
}

pub fn BalanceParams::param_names() -> Array[String] {
  [
    "player_speed", "enemy_speed_basic", "enemy_speed_fast",
    "enemy_speed_tank", "attack_cooldown", "arrow_speed",
    "arrow_range", "bow_cooldown", "chase_range",
    "knockback_strength", "iframe_duration", "dash_duration",
    "dash_cooldown", "dash_speed_mult", "basic_hp", "fast_hp",
    "tank_hp", "ranged_hp", "boss_hp_base", "boss_hp_per_floor",
  ]
}

// Clamp parameters to sensible bounds
pub fn BalanceParams::clamp(self : BalanceParams) -> BalanceParams {
  {
    player_speed: clamp_d(self.player_speed, 0.5, 5.0),
    enemy_speed_basic: clamp_d(self.enemy_speed_basic, 0.2, 3.0),
    enemy_speed_fast: clamp_d(self.enemy_speed_fast, 0.3, 4.0),
    enemy_speed_tank: clamp_d(self.enemy_speed_tank, 0.1, 2.0),
    attack_cooldown: clamp_d(self.attack_cooldown, 5.0, 60.0),
    arrow_speed: clamp_d(self.arrow_speed, 1.0, 10.0),
    arrow_range: clamp_d(self.arrow_range, 40.0, 400.0),
    bow_cooldown: clamp_d(self.bow_cooldown, 3.0, 40.0),
    chase_range: clamp_d(self.chase_range, 40.0, 300.0),
    knockback_strength: clamp_d(self.knockback_strength, 0.5, 10.0),
    iframe_duration: clamp_d(self.iframe_duration, 5.0, 60.0),
    dash_duration: clamp_d(self.dash_duration, 3.0, 20.0),
    dash_cooldown: clamp_d(self.dash_cooldown, 10.0, 80.0),
    dash_speed_mult: clamp_d(self.dash_speed_mult, 1.5, 8.0),
    basic_hp: clamp_d(self.basic_hp, 1.0, 20.0),
    fast_hp: clamp_d(self.fast_hp, 1.0, 15.0),
    tank_hp: clamp_d(self.tank_hp, 3.0, 30.0),
    ranged_hp: clamp_d(self.ranged_hp, 1.0, 10.0),
    boss_hp_base: clamp_d(self.boss_hp_base, 5.0, 60.0),
    boss_hp_per_floor: clamp_d(self.boss_hp_per_floor, 0.5, 10.0),
  }
}

fn clamp_d(v : Double, lo : Double, hi : Double) -> Double {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}
