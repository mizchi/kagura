// Pure game logic types — no rendering dependencies

///|
pub(all) struct Player {
  mut x : Double
  mut y : Double
  mut hp : Int
  max_hp : Int
  size : Double
  mut damage_timer : Int
  mut iframe_timer : Int
  mut facing_angle : Double
  mut dash_timer : Int
  mut dash_cooldown_timer : Int
  mut dash_vx : Double
  mut dash_vy : Double
  mut counter_timer : Int // >0 = counter stance active (invincible + reflect)
  mut counter_cooldown_timer : Int
}

///|
pub(all) struct Enemy {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut hp : Int
  max_hp : Int
  speed : Double
  size : Double
  mut alive : Bool
  mut damage_timer : Int
  kind : EnemyKind
  mut path_cache : Array[@terrain.Point]
  mut path_index : Int
  mut path_timer : Int
  mut shoot_cooldown : Int
  mut pending_bolt_timer : Int
  mut pending_bolt_target_x : Double
  mut pending_bolt_target_y : Double
  mut charge_timer : Int
  mut charge_cooldown : Int
  mut meteor_cast_timer : Int // >0 = casting meteor, counts down
  mut meteor_target_x : Double
  mut meteor_target_y : Double
  mut beam_cast_timer : Int // >0 = charging beam
  mut beam_target_x : Double
  mut beam_target_y : Double
}

///|
pub(all) struct ItemLogEntry {
  text : String
  color : Int // hex color from rarity
  mut frames_remaining : Int
}

///|
pub(all) struct ItemDrop {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  kind : ItemKind
  mut alive : Bool
  spawn_frame : Int
}

///|
pub(all) struct Projectile {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut age : Int
  mut alive : Bool
  mut damage : Int
  mut is_player : Bool
  kind : ProjectileKind
}

///|
pub(all) enum ProjectileKind {
  Arrow
  Fireball(Int)
  HomingMissile
  EnemyBolt
} derive(Eq, Show)

///|
pub(all) struct DungeonData {
  mut grid : @terrain.Grid2D
  rooms : Array[@terrain.Room]
  mut start_x : Double
  mut start_y : Double
  height_map : Array[Double]
}

///|
pub(all) enum EnemyKind {
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
} derive(Eq)

///|
pub(all) enum ItemKind {
  Health
  Score
  Equipment(ItemData)
}

///|
pub fn ItemKind::op_equal(self : ItemKind, other : ItemKind) -> Bool {
  match (self, other) {
    (Health, Health) => true
    (Score, Score) => true
    _ => false
  }
}

///|
pub(all) enum GameMode {
  Title
  CharacterSelect
  Playing
  GameOver
} derive(Eq)

///|
pub(all) enum UIMode {
  None
  Inventory
  Skills
  LevelUp
} derive(Eq)

///|
pub(all) enum GameEvent {
  HitSparks(Double, Double)
  DeathBurst(Double, Double)
  DashTrail(Double, Double)
  PlayerHurt(Double, Double)
  PlayerDamageNumber(Double, Double, Int)
  EnemyDamageNumber(Double, Double, Int)
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
  IceNovaCast(Double, Double, Double)
  MeteorCastStart(Double, Double, Double)
  MeteorImpact(Double, Double, Double)
  BeamFire(Double, Double, Double, Double, Bool) // x0, y0, x1, y1, is_player
  MeleeSlash(Double, Double, Double) // x, y, radius
  AttackTriggered
  HurtTriggered
  FloorComplete
}
