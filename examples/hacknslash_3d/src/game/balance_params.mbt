// BalanceParams: tunable game parameters for automatic balance optimization
// All values are Double for smooth optimization; cast to Int at use site

///|
pub enum BalancePreset {
  Default
  BuildDiverseHackSlash
  MechanicsRoguelike
} derive(Eq, Show)

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
  player_base_hp : Double // player starting HP before equipment (default 8)
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
  item_base_tier_per_floor : Double
  item_prefix_tier_per_floor : Double
  item_suffix_tier_per_floor : Double
  item_modifier_tier_per_floor : Double
  map_room_count_scale : Double
  map_room_size_scale : Double
  map_corridor_width_bonus : Double
  pack_large_room_bonus : Double
  enemy_hp_floor_scale : Double
  enemy_speed_floor_scale : Double
  enemy_damage_floor_scale : Double
  affix_profile : Int // 0=Classic, 1=GlassCannon, 2=Tank, 3=Mobility, 4=Expanded
}

///|
pub let balance_param_count : Int = 47

///|
pub fn balance_preset_from_name(name : String) -> BalancePreset {
  match name {
    "build_diverse_hackslash" | "build_diverse" | "hackslash" =>
      BuildDiverseHackSlash
    "mechanics_roguelike" | "mechanics_roguelike_v2" | "roguelike" =>
      MechanicsRoguelike
    _ => Default
  }
}

///|
pub fn BalanceParams::default() -> BalanceParams {
  {
    player_speed: 1.8,
    enemy_speed_basic: 1.1,
    enemy_speed_fast: 1.7,
    enemy_speed_tank: 0.6,
    attack_cooldown: 23.18,
    arrow_speed: 4.0,
    arrow_range: 180.0,
    bow_cooldown: 15.0,
    chase_range: 120.0,
    knockback_strength: 2.0,
    iframe_duration: 30.0,
    dash_duration: 4.0,
    dash_cooldown: 49.44,
    dash_speed_mult: 2.54,
    basic_hp: 3.0,
    fast_hp: 2.0,
    tank_hp: 8.0,
    ranged_hp: 2.0,
    boss_hp_base: 20.0,
    boss_hp_per_floor: 5.0,
    enemy_contact_damage: 1.0,
    player_base_hp: 12.0,
    spawn_density: 1.8,
    spell_cooldown_mult: 1.26,
    spell_damage_mult: 0.68,
    enemy_bolt_damage: 1.19,
    ranged_shot_cooldown: 56.85,
    levelup_xp_base: 28.96,
    levelup_xp_growth: 2.0,
    drop_equipment_weight: 34.09,
    drop_health_weight: 5.0,
    drop_score_weight: 17.17,
    drop_weapon_weight: 2.84,
    drop_armor_weight: 3.44,
    drop_accessory_weight: 1.0,
    item_rarity_bonus_per_floor: 0.0,
    item_base_tier_per_floor: 0.13,
    item_prefix_tier_per_floor: 0.26,
    item_suffix_tier_per_floor: 0.28,
    item_modifier_tier_per_floor: 0.0,
    map_room_count_scale: 1.45,
    map_room_size_scale: 0.9,
    map_corridor_width_bonus: 0.9,
    pack_large_room_bonus: 0.5,
    enemy_hp_floor_scale: 0.15,
    enemy_speed_floor_scale: 0.03,
    enemy_damage_floor_scale: 0.22,
    affix_profile: 0,
  }
}

///|
pub fn BalanceParams::build_diverse_hackslash() -> BalanceParams {
  {
    player_speed: 2.0,
    enemy_speed_basic: 0.8,
    enemy_speed_fast: 1.4,
    enemy_speed_tank: 0.4,
    attack_cooldown: 16.0,
    arrow_speed: 4.5,
    arrow_range: 93.6545947091699,
    bow_cooldown: 14.971207912462834,
    chase_range: 200.0,
    knockback_strength: 1.2,
    iframe_duration: 12.660055056711197,
    dash_duration: 4.904334216202607,
    dash_cooldown: 37.76302876567426,
    dash_speed_mult: 2.507586859390241,
    basic_hp: 7.0,
    fast_hp: 5.0,
    tank_hp: 14.0,
    ranged_hp: 3.5,
    boss_hp_base: 35.0,
    boss_hp_per_floor: 7.0,
    enemy_contact_damage: 1.5,
    player_base_hp: 10.0,
    spawn_density: 1.2,
    spell_cooldown_mult: 1.125592230777317,
    spell_damage_mult: 0.5352601566263829,
    enemy_bolt_damage: 1.7877006387857546,
    ranged_shot_cooldown: 56.284684566415045,
    levelup_xp_base: 10.751973158257536,
    levelup_xp_growth: 5.902750872121251,
    drop_equipment_weight: 45.0,
    drop_health_weight: 8.0,
    drop_score_weight: 47.0,
    drop_weapon_weight: 1.0,
    drop_armor_weight: 1.0,
    drop_accessory_weight: 1.3292847614745906,
    item_rarity_bonus_per_floor: 0.0,
    item_base_tier_per_floor: 0.2173319294818014,
    item_prefix_tier_per_floor: 0.21382298654392617,
    item_suffix_tier_per_floor: 0.15338956128076195,
    item_modifier_tier_per_floor: 0.0,
    map_room_count_scale: 1.0,
    map_room_size_scale: 1.2253745535048524,
    map_corridor_width_bonus: 0.04293665164259668,
    pack_large_room_bonus: 0.3,
    enemy_hp_floor_scale: 0.25,
    enemy_speed_floor_scale: 0.05,
    enemy_damage_floor_scale: 0.15,
    affix_profile: 0,
  }
}

///|
pub fn BalanceParams::mechanics_roguelike() -> BalanceParams {
  {
    player_speed: 1.45,
    enemy_speed_basic: 0.8,
    enemy_speed_fast: 1.3,
    enemy_speed_tank: 0.4,
    attack_cooldown: 31.98915589692,
    arrow_speed: 3.8230630799290046,
    arrow_range: 150.0,
    bow_cooldown: 15.584374516791584,
    chase_range: 200.0,
    knockback_strength: 1.0,
    iframe_duration: 27.503997985124602,
    dash_duration: 6.648466095565617,
    dash_cooldown: 30.0,
    dash_speed_mult: 2.866739317075175,
    basic_hp: 8.0,
    fast_hp: 5.0,
    tank_hp: 14.0,
    ranged_hp: 4.0,
    boss_hp_base: 35.0,
    boss_hp_per_floor: 7.0,
    enemy_contact_damage: 2.0,
    player_base_hp: 10.0,
    spawn_density: 1.2,
    spell_cooldown_mult: 1.1195861600925212,
    spell_damage_mult: 0.7312348672858308,
    enemy_bolt_damage: 4.34362329908358,
    ranged_shot_cooldown: 62.915406323491275,
    levelup_xp_base: 9.084748085001639,
    levelup_xp_growth: 1.7365994739559514,
    drop_equipment_weight: 45.0,
    drop_health_weight: 8.0,
    drop_score_weight: 47.0,
    drop_weapon_weight: 1.0,
    drop_armor_weight: 1.3597392986160064,
    drop_accessory_weight: 1.0,
    item_rarity_bonus_per_floor: 1.0,
    item_base_tier_per_floor: 0.2,
    item_prefix_tier_per_floor: 0.23052515506469717,
    item_suffix_tier_per_floor: 0.23728672821507085,
    item_modifier_tier_per_floor: 0.1,
    map_room_count_scale: 0.9,
    map_room_size_scale: 1.05,
    map_corridor_width_bonus: 0.0,
    pack_large_room_bonus: 0.4,
    enemy_hp_floor_scale: 0.3,
    enemy_speed_floor_scale: 0.05,
    enemy_damage_floor_scale: 0.15,
    affix_profile: 0,
  }
}

///|
pub fn BalanceParams::from_preset(preset : BalancePreset) -> BalanceParams {
  match preset {
    Default => BalanceParams::default()
    BuildDiverseHackSlash => BalanceParams::build_diverse_hackslash()
    MechanicsRoguelike => BalanceParams::mechanics_roguelike()
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
    self.item_base_tier_per_floor,
    self.item_prefix_tier_per_floor,
    self.item_suffix_tier_per_floor,
    self.item_modifier_tier_per_floor,
    self.map_room_count_scale,
    self.map_room_size_scale,
    self.map_corridor_width_bonus,
    self.pack_large_room_bonus,
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
    item_base_tier_per_floor: arr[36],
    item_prefix_tier_per_floor: arr[37],
    item_suffix_tier_per_floor: arr[38],
    item_modifier_tier_per_floor: arr[39],
    map_room_count_scale: arr[40],
    map_room_size_scale: arr[41],
    map_corridor_width_bonus: arr[42],
    pack_large_room_bonus: arr[43],
    enemy_hp_floor_scale: arr[44],
    enemy_speed_floor_scale: arr[45],
    enemy_damage_floor_scale: arr[46],
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
    "drop_weapon_weight", "drop_armor_weight", "drop_accessory_weight", "item_rarity_bonus_per_floor",
    "item_base_tier_per_floor", "item_prefix_tier_per_floor", "item_suffix_tier_per_floor",
    "item_modifier_tier_per_floor", "map_room_count_scale", "map_room_size_scale",
    "map_corridor_width_bonus", "pack_large_room_bonus", "enemy_hp_floor_scale",
    "enemy_speed_floor_scale", "enemy_damage_floor_scale",
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
    player_base_hp: clamp_d(self.player_base_hp, 8.0, 30.0),
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
    item_rarity_bonus_per_floor: clamp_d(
      self.item_rarity_bonus_per_floor,
      0.0,
      10.0,
    ),
    item_base_tier_per_floor: clamp_d(self.item_base_tier_per_floor, 0.0, 1.5),
    item_prefix_tier_per_floor: clamp_d(
      self.item_prefix_tier_per_floor,
      0.0,
      1.5,
    ),
    item_suffix_tier_per_floor: clamp_d(
      self.item_suffix_tier_per_floor,
      0.0,
      1.5,
    ),
    item_modifier_tier_per_floor: clamp_d(
      self.item_modifier_tier_per_floor,
      0.0,
      1.0,
    ),
    map_room_count_scale: clamp_d(self.map_room_count_scale, 0.75, 2.0),
    map_room_size_scale: clamp_d(self.map_room_size_scale, 0.8, 2.0),
    map_corridor_width_bonus: clamp_d(self.map_corridor_width_bonus, 0.0, 3.0),
    pack_large_room_bonus: clamp_d(self.pack_large_room_bonus, 0.0, 2.0),
    enemy_hp_floor_scale: clamp_d(self.enemy_hp_floor_scale, 0.0, 1.0),
    enemy_speed_floor_scale: clamp_d(self.enemy_speed_floor_scale, 0.0, 0.5),
    enemy_damage_floor_scale: clamp_d(self.enemy_damage_floor_scale, 0.0, 1.0),
    affix_profile: self.affix_profile,
  }
}

///|
pub fn BalanceParams::spell_cooldown_frames(
  self : BalanceParams,
  base : Int,
) -> Int {
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
pub fn BalanceParams::chain_lightning_cooldown_frames(
  self : BalanceParams,
) -> Int {
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
pub fn BalanceParams::drop_table_config(
  self : BalanceParams,
) -> DropTableConfig {
  {
    equipment_weight: @cmp.maximum(0, self.drop_equipment_weight.to_int()),
    health_weight: @cmp.maximum(0, self.drop_health_weight.to_int()),
    score_weight: @cmp.maximum(0, self.drop_score_weight.to_int()),
    weapon_weight: @cmp.maximum(0, self.drop_weapon_weight.to_int()),
    armor_weight: @cmp.maximum(0, self.drop_armor_weight.to_int()),
    accessory_weight: @cmp.maximum(0, self.drop_accessory_weight.to_int()),
    rarity_bonus_per_floor: self.item_rarity_bonus_per_floor,
    base_item_tier_base: 1.0,
    base_item_tier_per_floor: self.item_base_tier_per_floor,
    prefix_tier_base: 0.0,
    prefix_tier_per_floor: self.item_prefix_tier_per_floor,
    suffix_tier_base: 0.0,
    suffix_tier_per_floor: self.item_suffix_tier_per_floor,
    modifier_tier_base: 0.0,
    modifier_tier_per_floor: self.item_modifier_tier_per_floor,
  }
}

///|
pub fn BalanceParams::scale_enemy_hp_for_floor(
  self : BalanceParams,
  base_hp : Int,
  floor : Int,
) -> Int {
  let scale = 1.0 +
    @cmp.maximum(0, floor - 1).to_double() * self.enemy_hp_floor_scale
  @cmp.maximum(1, (base_hp.to_double() * scale).to_int())
}

///|
pub fn BalanceParams::scale_enemy_speed_for_floor(
  self : BalanceParams,
  base_speed : Double,
  floor : Int,
) -> Double {
  base_speed *
  (1.0 + @cmp.maximum(0, floor - 1).to_double() * self.enemy_speed_floor_scale)
}

///|
pub fn BalanceParams::scale_enemy_damage_for_floor(
  self : BalanceParams,
  base_damage : Int,
  floor : Int,
) -> Int {
  let scale = 1.0 +
    @cmp.maximum(0, floor - 1).to_double() * self.enemy_damage_floor_scale
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
