///|
/// Species and combat roles are separate: heavy goblins and skeletal casters
/// reuse their species' body while keeping the existing role-specific AI.
pub(all) enum EnemySpecies {
  Zombie
  Goblin
  Kobold
  Skeleton
  Wolf
} derive(Eq, Debug)
///|
pub extend EnemySpecies with Eq::{not_equal, equal}
///|
pub extend EnemySpecies with @moonbitlang/core/debug.Debug::{to_repr}
///|
pub extend EnemySpecies with Show::{to_string, output}
///|
pub impl Show for EnemySpecies with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn enemy_species(kind : EnemyKind) -> EnemySpecies {
  match kind {
    Zombie => EnemySpecies::Zombie
    Wolf => EnemySpecies::Wolf
    Basic | Swarm | Tank | Berserker => Goblin
    Fast | Exploder | Teleporter => Kobold
    Ranged | Summoner | Caster | Boss => Skeleton
  }
}

///|
pub fn enemy_species_name(species : EnemySpecies) -> String {
  match species {
    Goblin => "ゴブリン"
    Kobold => "コボルト"
    Skeleton => "スケルトン"
    Zombie => "ゾンビ"
    Wolf => "灰狼"
  }
}
