// Constants shared with 2D version + 3D-specific

let screen_w : Int = 640

let screen_h : Int = 480

let tile_size : Double = 16.0

let map_cols : Int = 60

let map_rows : Int = 45

let world_w : Double = 960.0

let world_h : Double = 720.0

let player_speed : Double = 2.0

let enemy_speed_basic : Double = 0.8

let enemy_speed_fast : Double = 1.2

let enemy_speed_tank : Double = 0.4

let attack_cooldown : Int = 20

// Bow/arrow constants
let arrow_speed : Double = 4.0

let arrow_range : Double = 160.0

let bow_cooldown : Int = 15

let damage_flash_duration : Int = 10

let chase_range : Double = 120.0

let knockback_strength : Double = 4.0

let pickup_radius_sq : Double = 64.0 // 8.0^2

let iframe_duration : Int = 30

let path_update_interval : Int = 60

// Game mode
enum GameMode {
  Title
  Playing
  GameOver
} derive(Eq)

// Enemy kind
enum EnemyKind {
  Basic
  Fast
  Tank
  Ranged
  Boss
} derive(Eq)

// Item kind
enum ItemKind {
  Health
  Score
} derive(Eq)

// Dash constants
let dash_duration : Int = 8

let dash_cooldown : Int = 40

let dash_speed_mult : Double = 4.0

// Shift key code
let key_shift : Int = 16

// UI mode
enum UIMode {
  None
  Inventory
  Skills
} derive(Eq)

// Key codes for UI
let key_i : Int = 73 // 'I' for inventory

let key_k : Int = 75 // 'K' for skill tree

let key_e : Int = 69 // 'E' for equip

let key_escape : Int = 27

let key_f3 : Int = 114 // F3 for profiler toggle

// Skill keys (number row)
let key_1 : Int = 49

let key_2 : Int = 50

let key_3 : Int = 51
