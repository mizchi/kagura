// Constants shared with 2D version + 3D-specific

let screen_w : Int = 640

let screen_h : Int = 480

let tile_size : Double = 16.0

let map_cols : Int = 40

let map_rows : Int = 30

let world_w : Double = 640.0

let world_h : Double = 480.0

let player_speed : Double = 2.0

let enemy_speed_basic : Double = 0.8

let enemy_speed_fast : Double = 1.2

let enemy_speed_tank : Double = 0.4

let attack_range : Double = 24.0

let attack_cooldown : Int = 20

let damage_flash_duration : Int = 10

let chase_range : Double = 120.0

let knockback_strength : Double = 4.0

let iframe_duration : Int = 30

let path_update_interval : Int = 60

// Game mode constants
let mode_title : Int = 0

let mode_playing : Int = 1

let mode_gameover : Int = 2

// Enemy kind constants
let kind_basic : Int = 0

let kind_fast : Int = 1

let kind_tank : Int = 2

let kind_ranged : Int = 3

let kind_boss : Int = 4

// Item kind constants
let item_health : Int = 0

let item_score : Int = 1

// Dash constants
let dash_duration : Int = 8

let dash_cooldown : Int = 40

let dash_speed_mult : Double = 4.0

// Shift key code
let key_shift : Int = 16

// UI mode constants
let ui_mode_none : Int = 0

let ui_mode_inventory : Int = 1

let ui_mode_skills : Int = 2

// Key codes for UI
let key_i : Int = 73 // 'I' for inventory

let key_k : Int = 75 // 'K' for skill tree

let key_e : Int = 69 // 'E' for equip

let key_escape : Int = 27

let key_f3 : Int = 114 // F3 for profiler toggle
