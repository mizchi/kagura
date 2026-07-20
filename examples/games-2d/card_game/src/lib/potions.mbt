///|
/// Potion System — StS-style consumable items
///
/// === Design ===
/// - Max 3 potion slots per run
/// - Gained randomly after battle victories (~40% chance)
/// - Used during player turn (costs 0 energy)
/// - Adds a resource management layer: save for boss or use now?
///
/// === Potion Types ===
/// - Fire Potion: Deal 20 damage to target enemy
/// - Block Potion: Gain 12 Block
/// - Strength Potion: Gain 2 Strength for this combat
/// - Regen Potion: Heal 5 HP per turn for 5 turns
/// - Fruit Juice: Gain 5 Max HP (used outside combat)
/// - Explosive Potion: Deal 10 damage to ALL enemies
/// - Weak Potion: Apply 3 Weak to target enemy

///|
pub(all) enum PotionId {
  FirePotion // 20 damage to target
  BlockPotion // 12 block
  StrengthPotion // +2 STR this combat
  RegenPotion // Heal 5 HP/turn for 5 turns
  FruitJuice // +5 max HP (used outside combat)
  ExplosivePotion // 10 damage to ALL
  WeakPotion // Apply 3 Weak to target
} derive(Debug, Eq)

///|
pub impl Show for PotionId with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct PotionDef {
  id : PotionId
  name : String
  description : String
  needs_target : Bool // true = target an enemy
  usable_in_combat : Bool // false = map-only (e.g. Fruit Juice)
} derive(Debug)

///|
pub impl Show for PotionDef with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub fn potion_def(id : PotionId) -> PotionDef {
  match id {
    FirePotion =>
      {
        id: FirePotion,
        name: "Fire Potion",
        description: "Deal 20 damage to target enemy.",
        needs_target: true,
        usable_in_combat: true,
      }
    BlockPotion =>
      {
        id: BlockPotion,
        name: "Block Potion",
        description: "Gain 12 Block.",
        needs_target: false,
        usable_in_combat: true,
      }
    StrengthPotion =>
      {
        id: StrengthPotion,
        name: "Strength Potion",
        description: "Gain 2 Strength for this combat.",
        needs_target: false,
        usable_in_combat: true,
      }
    RegenPotion =>
      {
        id: RegenPotion,
        name: "Regen Potion",
        description: "Heal 5 HP at end of turn for 5 turns.",
        needs_target: false,
        usable_in_combat: true,
      }
    FruitJuice =>
      {
        id: FruitJuice,
        name: "Fruit Juice",
        description: "Gain 5 Max HP.",
        needs_target: false,
        usable_in_combat: false,
      }
    ExplosivePotion =>
      {
        id: ExplosivePotion,
        name: "Explosive Potion",
        description: "Deal 10 damage to ALL enemies.",
        needs_target: false,
        usable_in_combat: true,
      }
    WeakPotion =>
      {
        id: WeakPotion,
        name: "Weak Potion",
        description: "Apply 3 Weak to target enemy.",
        needs_target: true,
        usable_in_combat: true,
      }
  }
}

///|
let max_potions : Int = 3

///|
/// Apply a potion effect during combat
pub fn use_potion_in_combat(
  state : BattleState,
  potion : PotionId,
  target_index : Int,
) -> Bool {
  let def = potion_def(potion)
  if !def.usable_in_combat {
    return false
  }
  if state.phase != PlayerTurn {
    return false
  }
  match potion {
    FirePotion => {
      if target_index < 0 || target_index >= state.enemies.length() {
        return false
      }
      if state.enemies[target_index].fighter.is_dead() {
        return false
      }
      let actual = apply_damage(state.enemies[target_index].fighter, 20)
      state.logs.push("[Fire Potion] " + actual.to_string() + " damage!")
      check_battle_end(state)
    }
    BlockPotion => {
      add_block(state.player, 12)
      state.logs.push("[Block Potion] +12 Block!")
    }
    StrengthPotion => {
      state.player.status.strength += 2
      state.logs.push("[Strength Potion] +2 Strength!")
    }
    RegenPotion => {
      state.powers.regen += 5
      state.logs.push("[Regen Potion] Regen 5 for 5 turns!")
    }
    ExplosivePotion => {
      for enemy in state.enemies {
        if !enemy.fighter.is_dead() {
          let actual = apply_damage(enemy.fighter, 10)
          state.logs.push(
            "[Explosive Potion] " +
            enemy.fighter.name +
            " takes " +
            actual.to_string() +
            "!",
          )
        }
      }
      check_battle_end(state)
    }
    WeakPotion => {
      if target_index < 0 || target_index >= state.enemies.length() {
        return false
      }
      if state.enemies[target_index].fighter.is_dead() {
        return false
      }
      state.enemies[target_index].fighter.status.weak += 3
      state.logs.push("[Weak Potion] Apply 3 Weak!")
    }
    FruitJuice => return false // Not usable in combat
  }
  true
}

///|
/// All potion types in the reward pool
fn potion_pool() -> Array[PotionId] {
  [
    FirePotion,
    BlockPotion,
    StrengthPotion,
    RegenPotion,
    FruitJuice,
    ExplosivePotion,
    WeakPotion,
  ]
}

///|
/// Generate a random potion reward
pub fn random_potion(seed : Int) -> PotionId {
  let pool = potion_pool()
  let idx = seed.abs() % pool.length()
  pool[idx]
}
