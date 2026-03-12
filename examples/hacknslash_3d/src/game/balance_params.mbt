// BalanceParams: tunable game parameters for automatic balance optimization
// All values are Double for smooth optimization; cast to Int at use site

///|
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
  // New: damage & survivability knobs
  enemy_contact_damage : Double // base contact damage (default 1)
  player_base_hp : Double // player starting HP before equipment (default 10)
  spawn_density : Double // multiplier for enemy count per room (default 1.0)
  spell_cooldown_mult : Double // global spell cooldown multiplier
  spell_damage_mult : Double // global spell damage multiplier
  enemy_bolt_damage : Double // ranged enemy projectile damage
  ranged_shot_cooldown : Double // ranged enemy attack interval
  levelup_xp_base : Double
  levelup_xp_growth : Double
  drop_equipment_weight : Double
  drop_health_weight : Double
  drop_score_weight : Double
  drop_weapon_weight : Double
  drop_armor_weight : Double
  drop_accessory_weight : Double
  item_rarity_bonus_per_floor : Double
  enemy_hp_floor_scale : Double
  enemy_speed_floor_scale : Double
  enemy_damage_floor_scale : Double
  affix_profile : Int // 0=Classic, 1=GlassCannon, 2=Tank, 3=Mobility, 4=Expanded
}

///|
pub let balance_param_count : Int = 39

///|
pub fn BalanceParams::default() -> BalanceParams {
  {
    player_speed: 1.25,
    enemy_speed_basic: 0.8,
    enemy_speed_fast: 2.2,
    enemy_speed_tank: 0.4,
    attack_cooldown: 20.0,
    arrow_speed: 4.0,
    arrow_range: 160.0,
    bow_cooldown: 15.0,
    chase_range: 120.0,
    knockback_strength: 2.0,
    iframe_duration: 28.0,
    dash_duration: 5.0,
    dash_cooldown: 50.0,
    dash_speed_mult: 2.5,
    basic_hp: 6.5,
    fast_hp: 4.0,
    tank_hp: 8.0,
    ranged_hp: 2.0,
    boss_hp_base: 27.0,
    boss_hp_per_floor: 3.5,
    enemy_contact_damage: 2.0,
    player_base_hp: 4.0,
    spawn_density: 1.0,
    spell_cooldown_mult: 1.1,
    spell_damage_mult: 0.5,
    enemy_bolt_damage: 3.0,
    ranged_shot_cooldown: 56.0,
    levelup_xp_base: 10.0,
    levelup_xp_growth: 6.0,
    drop_equipment_weight: 30.0,
    drop_health_weight: 30.0,
    drop_score_weight: 40.0,
    drop_weapon_weight: 1.0,
    drop_armor_weight: 1.0,
    drop_accessory_weight: 1.0,
    item_rarity_bonus_per_floor: 0.0,
    enemy_hp_floor_scale: 0.15,
    enemy_speed_floor_scale: 0.03,
    enemy_damage_floor_scale: 0.08,
    affix_profile: 0,
  }
}

///|
pub fn BalanceParams::to_array(self : BalanceParams) -> Array[Double] {
  [
    self.player_speed,
    self.enemy_speed_basic,
    self.enemy_speed_fast,
    self.enemy_speed_tank,
    self.attack_cooldown,
    self.arrow_speed,
    self.arrow_range,
    self.bow_cooldown,
    self.chase_range,
    self.knockback_strength,
    self.iframe_duration,
    self.dash_duration,
    self.dash_cooldown,
    self.dash_speed_mult,
    self.basic_hp,
    self.fast_hp,
    self.tank_hp,
    self.ranged_hp,
    self.boss_hp_base,
    self.boss_hp_per_floor,
    self.enemy_contact_damage,
    self.player_base_hp,
    self.spawn_density,
    self.spell_cooldown_mult,
    self.spell_damage_mult,
    self.enemy_bolt_damage,
    self.ranged_shot_cooldown,
    self.levelup_xp_base,
    self.levelup_xp_growth,
    self.drop_equipment_weight,
    self.drop_health_weight,
    self.drop_score_weight,
    self.drop_weapon_weight,
    self.drop_armor_weight,
    self.drop_accessory_weight,
    self.item_rarity_bonus_per_floor,
    self.enemy_hp_floor_scale,
    self.enemy_speed_floor_scale,
    self.enemy_damage_floor_scale,
  ]
}

///|
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
    enemy_contact_damage: arr[20],
    player_base_hp: arr[21],
    spawn_density: arr[22],
    spell_cooldown_mult: arr[23],
    spell_damage_mult: arr[24],
    enemy_bolt_damage: arr[25],
    ranged_shot_cooldown: arr[26],
    levelup_xp_base: arr[27],
    levelup_xp_growth: arr[28],
    drop_equipment_weight: arr[29],
    drop_health_weight: arr[30],
    drop_score_weight: arr[31],
    drop_weapon_weight: arr[32],
    drop_armor_weight: arr[33],
    drop_accessory_weight: arr[34],
    item_rarity_bonus_per_floor: arr[35],
    enemy_hp_floor_scale: arr[36],
    enemy_speed_floor_scale: arr[37],
    enemy_damage_floor_scale: arr[38],
    affix_profile: 0, // not optimized, set separately
  }
}

///|
pub fn BalanceParams::param_names() -> Array[String] {
  [
    "player_speed", "enemy_speed_basic", "enemy_speed_fast", "enemy_speed_tank",
    "attack_cooldown", "arrow_speed", "arrow_range", "bow_cooldown", "chase_range",
    "knockback_strength", "iframe_duration", "dash_duration", "dash_cooldown", "dash_speed_mult",
    "basic_hp", "fast_hp", "tank_hp", "ranged_hp", "boss_hp_base", "boss_hp_per_floor",
    "enemy_contact_damage", "player_base_hp", "spawn_density", "spell_cooldown_mult",
    "spell_damage_mult", "enemy_bolt_damage", "ranged_shot_cooldown", "levelup_xp_base",
    "levelup_xp_growth", "drop_equipment_weight", "drop_health_weight", "drop_score_weight",
    "drop_weapon_weight", "drop_armor_weight", "drop_accessory_weight",
    "item_rarity_bonus_per_floor", "enemy_hp_floor_scale", "enemy_speed_floor_scale",
    "enemy_damage_floor_scale",
  ]
}

// Clamp parameters to sensible bounds

///|
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
    chase_range: clamp_d(self.chase_range, 60.0, 300.0),
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
    enemy_contact_damage: clamp_d(self.enemy_contact_damage, 1.0, 8.0),
    player_base_hp: clamp_d(self.player_base_hp, 3.0, 30.0),
    spawn_density: clamp_d(self.spawn_density, 0.5, 3.0),
    spell_cooldown_mult: clamp_d(self.spell_cooldown_mult, 0.5, 3.0),
    spell_damage_mult: clamp_d(self.spell_damage_mult, 0.3, 2.0),
    enemy_bolt_damage: clamp_d(self.enemy_bolt_damage, 1.0, 8.0),
    ranged_shot_cooldown: clamp_d(self.ranged_shot_cooldown, 20.0, 180.0),
    levelup_xp_base: clamp_d(self.levelup_xp_base, 1.0, 100.0),
    levelup_xp_growth: clamp_d(self.levelup_xp_growth, 0.0, 50.0),
    drop_equipment_weight: clamp_d(self.drop_equipment_weight, 0.0, 100.0),
    drop_health_weight: clamp_d(self.drop_health_weight, 0.0, 100.0),
    drop_score_weight: clamp_d(self.drop_score_weight, 0.0, 100.0),
    drop_weapon_weight: clamp_d(self.drop_weapon_weight, 0.0, 100.0),
    drop_armor_weight: clamp_d(self.drop_armor_weight, 0.0, 100.0),
    drop_accessory_weight: clamp_d(self.drop_accessory_weight, 0.0, 100.0),
    item_rarity_bonus_per_floor: clamp_d(self.item_rarity_bonus_per_floor, 0.0, 10.0),
    enemy_hp_floor_scale: clamp_d(self.enemy_hp_floor_scale, 0.0, 1.0),
    enemy_speed_floor_scale: clamp_d(self.enemy_speed_floor_scale, 0.0, 0.5),
    enemy_damage_floor_scale: clamp_d(self.enemy_damage_floor_scale, 0.0, 1.0),
    affix_profile: self.affix_profile,
  }
}

///|
pub fn BalanceParams::spell_cooldown_frames(self : BalanceParams, base : Int) -> Int {
  @cmp.maximum(1, (base.to_double() * self.spell_cooldown_mult).to_int())
}

///|
pub fn BalanceParams::scale_spell_damage(
  self : BalanceParams,
  base_damage : Int,
) -> Int {
  @cmp.maximum(1, (base_damage.to_double() * self.spell_damage_mult).to_int())
}

///|
pub fn BalanceParams::chain_lightning_cooldown_frames(self : BalanceParams) -> Int {
  self.spell_cooldown_frames(chain_lightning_cooldown)
}

///|
pub fn BalanceParams::splitting_fireball_cooldown_frames(
  self : BalanceParams,
) -> Int {
  self.spell_cooldown_frames(splitting_fireball_cooldown)
}

///|
pub fn BalanceParams::ice_nova_cooldown_frames(self : BalanceParams) -> Int {
  self.spell_cooldown_frames(ice_nova_cooldown)
}

///|
pub fn BalanceParams::homing_missile_cooldown_frames(
  self : BalanceParams,
) -> Int {
  self.spell_cooldown_frames(homing_missile_cooldown)
}

///|
pub fn BalanceParams::enemy_bolt_damage_int(self : BalanceParams) -> Int {
  @cmp.maximum(1, self.enemy_bolt_damage.to_int())
}

///|
pub fn BalanceParams::ranged_shot_cooldown_frames(self : BalanceParams) -> Int {
  @cmp.maximum(1, self.ranged_shot_cooldown.to_int())
}

///|
pub fn BalanceParams::levelup_config(self : BalanceParams) -> LevelUpConfig {
  {
    xp_base: @cmp.maximum(1, self.levelup_xp_base.to_int()),
    xp_growth: @cmp.maximum(0, self.levelup_xp_growth.to_int()),
  }
}

///|
pub fn BalanceParams::drop_table_config(self : BalanceParams) -> DropTableConfig {
  {
    equipment_weight: @cmp.maximum(0, self.drop_equipment_weight.to_int()),
    health_weight: @cmp.maximum(0, self.drop_health_weight.to_int()),
    score_weight: @cmp.maximum(0, self.drop_score_weight.to_int()),
    weapon_weight: @cmp.maximum(0, self.drop_weapon_weight.to_int()),
    armor_weight: @cmp.maximum(0, self.drop_armor_weight.to_int()),
    accessory_weight: @cmp.maximum(0, self.drop_accessory_weight.to_int()),
    rarity_bonus_per_floor: self.item_rarity_bonus_per_floor,
  }
}

///|
pub fn BalanceParams::scale_enemy_hp_for_floor(
  self : BalanceParams,
  base_hp : Int,
  floor : Int,
) -> Int {
  let scale = 1.0 + @cmp.maximum(0, floor - 1).to_double() * self.enemy_hp_floor_scale
  @cmp.maximum(1, (base_hp.to_double() * scale).to_int())
}

///|
pub fn BalanceParams::scale_enemy_speed_for_floor(
  self : BalanceParams,
  base_speed : Double,
  floor : Int,
) -> Double {
  base_speed * (1.0 + @cmp.maximum(0, floor - 1).to_double() * self.enemy_speed_floor_scale)
}

///|
pub fn BalanceParams::scale_enemy_damage_for_floor(
  self : BalanceParams,
  base_damage : Int,
  floor : Int,
) -> Int {
  let scale = 1.0 + @cmp.maximum(0, floor - 1).to_double() * self.enemy_damage_floor_scale
  @cmp.maximum(1, (base_damage.to_double() * scale).to_int())
}

///|
pub fn BalanceParams::get_affix_profile(self : BalanceParams) -> AffixProfile {
  match self.affix_profile {
    1 => GlassCannon
    2 => Tank
    3 => Mobility
    4 => Expanded
    _ => Classic
  }
}

///|
fn clamp_d(v : Double, lo : Double, hi : Double) -> Double {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}
