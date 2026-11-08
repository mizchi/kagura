// Game constants — no rendering dependencies

///|
pub let screen_w : Int32 = 640

///|
pub let screen_h : Int32 = 480

///|
pub let tile_size : Double = 16.0

///|
pub let map_cols : Int32 = 100

///|
pub let map_rows : Int32 = 80

///|
pub let world_w : Double = 1600.0

///|
pub let world_h : Double = 1280.0

///|
pub let player_speed : Double = 2.0

///|
pub let enemy_speed_basic : Double = 0.8

///|
pub let enemy_speed_fast : Double = 1.2

///|
pub let enemy_speed_tank : Double = 0.4

///|
pub let attack_cooldown : Int32 = 20

///|
pub let arrow_speed : Double = 4.0

///|
pub let arrow_range : Double = 160.0

///|
pub let bow_cooldown : Int32 = 15

///|
pub let damage_flash_duration : Int32 = 10

///|
pub let chase_range : Double = 120.0

///|
pub let knockback_strength : Double = 4.0

///|
pub let pickup_radius_sq : Double = 64.0

///|
pub let iframe_duration : Int32 = 30

///|
pub let path_update_interval : Int32 = 60

///|
pub let dash_duration : Int32 = 8

///|
pub let dash_cooldown : Int32 = 40

///|
pub let dash_speed_mult : Double = 4.0

///|
pub let chain_lightning_range : Double = 112.0

///|
pub let chain_lightning_hop_range : Double = 104.0

///|
pub let chain_lightning_max_targets : Int32 = 2

///|
pub let chain_lightning_cooldown : Int32 = 40

///|
pub let chain_lightning_telegraph_radius : Double = 18.0

///|
pub let splitting_fireball_cooldown : Int32 = 40

///|
pub let splitting_fireball_telegraph_radius : Double = 22.0

///|
pub let splitting_fireball_split_angle : Double = 0.48

///|
pub let splitting_fireball_split_speed_mult : Double = 0.85

///|
pub let splitting_fireball_split_children : Int32 = 3

///|
pub let splitting_fireball_trail_interval : Int32 = 3

///|
pub let ice_nova_radius : Double = 72.0

///|
pub let ice_nova_cooldown : Int32 = 48

///|
pub let homing_missile_range : Double = 144.0

///|
pub let homing_missile_seek_range : Double = 176.0

///|
pub let homing_missile_speed : Double = 3.2

///|
pub let homing_missile_cooldown : Int32 = 54

///|
pub let homing_missile_turn_rate : Double = 0.52 // radians per simulation tick

///|
pub let homing_missile_launch_offset : Double = 8.0

///|
pub let homing_missile_initial_spread : Double = 0.42

///|
pub let homing_missile_lifetime : Int32 = 34

///|
pub let homing_missile_arc_frames : Int32 = 24

///|
pub let homing_missile_telegraph_radius : Double = 18.0

///|
pub let meteor_cast_frames : Int32 = 120 // 2 seconds to cast

///|
pub let meteor_radius : Double = 48.0 // large AoE radius

///|
pub let meteor_cooldown_frames : Int32 = 300 // 5 seconds between meteors

///|
pub let meteor_damage_mult : Int32 = 4 // multiplier on base contact damage

///|
// Beam attack: straight-line AoE with charge time

///|
pub let beam_cast_frames : Int32 = 60 // 1 second charge

///|
pub let beam_range : Double = 200.0 // max beam length

///|
pub let beam_width : Double = 16.0 // width of damage area

///|
pub let beam_damage_mult : Int32 = 3 // damage multiplier

///|
pub let beam_cooldown_frames : Int32 = 180 // 3 seconds

///|
pub let counter_duration_frames : Int32 = 120 // 2 seconds active

///|
pub let counter_cooldown_frames : Int32 = 300 // 5 seconds cooldown

///|
pub let enemy_bolt_telegraph_frames : Int32 = 14

///|
pub let enemy_bolt_telegraph_radius : Double = 14.0

///|
pub let enemy_barrage_projectile_count : Int32 = 5

///|
pub let enemy_barrage_spread_angle : Double = 0.18

///|
pub let enemy_tackle_trigger_range : Double = 96.0

///|
pub let enemy_tackle_telegraph_frames : Int32 = 12

///|
pub let enemy_tackle_active_frames : Int32 = 9

///|
pub let enemy_tackle_speed_mult : Double = 3.8

///|
pub let enemy_tackle_telegraph_radius : Double = 16.0

///|
pub let enemy_fire_nova_trigger_range : Double = 56.0

///|
pub let enemy_fire_nova_cast_frames : Int32 = 16

///|
pub let enemy_fire_nova_cooldown_frames : Int32 = 90

///|
pub let enemy_fire_nova_radius : Double = 32.0

///|
pub let enemy_fire_nova_projectile_count : Int32 = 8

///|
pub let enemy_fire_nova_projectile_speed : Double = 1.6

///|
pub let enemy_death_explosion_radius : Double = 26.0

///|
pub let enemy_death_explosion_projectile_count : Int32 = 8

///|
/// A readable draw and aim before the arrow is released (60 Hz gameplay).
pub let enemy_bow_draw_frames : Int32 = 36
