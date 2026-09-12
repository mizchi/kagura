///|
/// Species and combat roles are separate: heavy goblins and skeletal casters
/// reuse their species' body while keeping the existing role-specific AI.
pub(all) enum EnemySpecies {
  Goblin
  Kobold
  Skeleton
} derive(Eq, Debug)

///|
pub impl Show for EnemySpecies with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn enemy_species(kind : EnemyKind) -> EnemySpecies {
  match kind {
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
  }
}
