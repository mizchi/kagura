// Pure game logic types — no rendering dependencies

///|
pub(all) struct Player {
  mut x : Double
  mut y : Double
  mut hp : Int32
  max_hp : Int32
  size : Double
  mut damage_timer : Int32
  mut iframe_timer : Int32
  mut facing_angle : Double
  mut dash_timer : Int32
  mut dash_cooldown_timer : Int32
  mut dash_vx : Double
  mut dash_vy : Double
  mut counter_timer : Int32 // >0 = counter stance active (invincible + reflect)
  mut counter_cooldown_timer : Int32
}

///|
pub(all) struct Enemy {
  mut camp : EnemyCamp?
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut hp : Int32
  max_hp : Int32
  speed : Double
  size : Double
  mut alive : Bool
  mut damage_timer : Int32
  kind : EnemyKind
  mut move_speed : Double
  mut move_angle : Double
  mut travel_distance : Double
  mut path_cache : Array[@terrain.Point]
  mut path_index : Int32
  mut path_timer : Int32
  mut shoot_cooldown : Int32
  mut pending_bolt_timer : Int32
  mut pending_bolt_target_x : Double
  mut pending_bolt_target_y : Double
  mut charge_timer : Int32
  mut charge_cooldown : Int32
  mut meteor_cast_timer : Int32 // >0 = casting meteor, counts down
  mut meteor_target_x : Double
  mut meteor_target_y : Double
  mut beam_cast_timer : Int32 // >0 = charging beam
  mut beam_target_x : Double
  mut beam_target_y : Double
  mut attack_motion : EnemyAttackMotion
  mut attack_frame : Int32
  mut attack_windup : Int32
  mut attack_recovery : Int32
  mut attack_cooldown : Int32
  mut attack_target_x : Double
  mut attack_target_y : Double
  mut knockback_x : Double
  mut knockback_y : Double
  mut stagger_frames : Int32
  mut attack_hit_pending : Bool
  mut pounce : EnemyPounce?
  room_index : Int32 // which room this enemy was spawned in (-1 = unknown)
}

///|
pub(all) struct ItemLogEntry {
  text : String
  color : Int32 // hex color from rarity
  mut frames_remaining : Int32
}

///|
#derive(ToJson, FromJson)
pub(all) struct ItemDrop {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  kind : ItemKind
  mut alive : Bool
  spawn_frame : Int32
  // Optional for compatibility with world progress saved before manual drops.
  mut pickup_blocked : Bool?
  // Session identity, reassigned when loading legacy or saved region loot.
  mut pickup_id : Int32?
}

///|
pub extend ItemDrop with ToJson::{to_json}

///|
pub extend ItemDrop with @moonbitlang/core/json.FromJson::{from_json}

///|
pub(all) struct Projectile {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut age : Int32
  mut alive : Bool
  mut damage : Int32
  mut is_player : Bool
  kind : ProjectileKind
}

///|
#derive(Eq, Debug)
pub(all) enum ProjectileKind {
  Arrow
  Fireball(Int32)
  HomingMissile
  EnemyBolt
}

///|
pub impl Show for ProjectileKind with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct DungeonData {
  mut grid : @terrain.Grid2D
  rooms : Array[@terrain.Room]
  mut start_x : Double
  mut start_y : Double
  height_map : Array[Double]
  mut terrain_surface : @terrain3d.HeightField?
  mut landscape : Landscape?
}

///|
#derive(Eq, ToJson, FromJson)
pub(all) enum EnemyKind {
  Zombie
  Wolf
  Basic
  Fast
  Tank
  Ranged
  Boss
  Exploder // charges at player, explodes on death dealing massive AoE
  Summoner // periodically spawns Basic minions
  Berserker // gets faster and stronger as HP decreases
  Teleporter // blinks behind player periodically
  Swarm // tiny, weak, spawns in large groups
  Caster // channels area damage spells, must be interrupted
}

///|
pub extend EnemyKind with ToJson::{to_json}

///|
pub extend EnemyKind with @moonbitlang/core/json.FromJson::{from_json}

///|
#derive(ToJson, FromJson)
pub(all) enum ItemKind {
  Health
  Score
  Equipment(ItemData)
}

///|
pub extend ItemKind with ToJson::{to_json}

///|
pub extend ItemKind with @moonbitlang/core/json.FromJson::{from_json}

///|
pub fn ItemKind::op_equal(self : ItemKind, other : ItemKind) -> Bool {
  match (self, other) {
    (Health, Health) => true
    (Score, Score) => true
    _ => false
  }
}

///|
#derive(Eq)
pub(all) enum GameMode {
  Title
  CharacterSelect
  Playing
  GameOver
}

///|
#derive(Eq)
pub(all) enum UIMode {
  None
  Inventory
  Skills
  Waypoints
  LevelUp
}

///|
pub(all) enum GameEvent {
  HitSparks(Double, Double)
  DeathBurst(Double, Double)
  DashTrail(Double, Double)
  PlayerHurt(Double, Double)
  PlayerDamageNumber(Double, Double, Int32)
  EnemyDamageNumber(Double, Double, Int32)
  ChestOpened(Double, Double)
  ItemPickup(Double, Double, Bool)
  GroundTelegraphRing(Double, Double, Double) // player skill indicators (blue)
  GroundTelegraphLine(Double, Double, Double, Double)
  EnemyTelegraphRing(Double, Double, Double) // enemy attack warnings (red)
  ChainLightningArc(Double, Double, Double, Double)
  HomingMissileLaunch(Double, Double, Double, Double)
  HomingMissileTrail(Double, Double, Double, Double)
  HomingMissileImpact(Double, Double)
  FireballCast(Double, Double)
  FireballTrail(Double, Double)
  FireballBurst(Double, Double)
  EnemyAreaDamage(Double, Double, Double, Int32)
  SummonReleased(Double, Double, Bool)
  IceNovaCast(Double, Double, Double)
  MeteorCastStart(Double, Double, Double)
  MeteorImpact(Double, Double, Double)
  BeamFire(Double, Double, Double, Double, Bool) // x0, y0, x1, y1, is_player
  MeleeSlash(Double, Double, Double) // x, y, radius
  RoomCleared(Int32, Double, Double) // room_index, center_x, center_y
  GuardBlocked(Double, Double, Bool)
  CombatImpact(CombatImpactKind, Double, Double, Double, Int32)
  MeleeImpact(PlayerWeaponKind, CleaverComboStep, Double, Double, Double, Int32) // weapon, combo, x, y, angle, hit count
  EnemyMeleeWarning(Double, Double)
  AttackTriggered
  HurtTriggered
  FloorComplete
}

///|
pub extend ProjectileKind with Eq::{not_equal, equal}

///|
pub extend ProjectileKind with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ProjectileKind with Show::{to_string, output}

///|
pub extend EnemyKind with Eq::{not_equal, equal}

///|
pub extend GameMode with Eq::{not_equal, equal}

///|
pub extend UIMode with Eq::{not_equal, equal}
