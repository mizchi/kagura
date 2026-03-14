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
  damage : Int
  is_player : Bool
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
  GroundTelegraphRing(Double, Double, Double)
  GroundTelegraphLine(Double, Double, Double, Double)
  ChainLightningArc(Double, Double, Double, Double)
  HomingMissileLaunch(Double, Double, Double, Double)
  HomingMissileTrail(Double, Double, Double, Double)
  HomingMissileImpact(Double, Double)
  FireballCast(Double, Double)
  FireballTrail(Double, Double)
  FireballBurst(Double, Double)
  IceNovaCast(Double, Double, Double)
  MeteorCastStart(Double, Double, Double) // x, y, radius - casting begins
  MeteorImpact(Double, Double, Double) // x, y, radius - meteor lands
  AttackTriggered
  HurtTriggered
  FloorComplete
}
