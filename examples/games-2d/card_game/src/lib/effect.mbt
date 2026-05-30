///|
/// Effect IR (data-driven card effects) — PoC
///
/// Background: most card numerics (cost / base_damage / base_block) already
/// live as data in `CardDef`, but each card's *behaviour* was hand-written as
/// a branch inside `execute_card`. This file introduces a small intermediate
/// representation (IR): a card's behaviour is expressed as `Array[Effect]`
/// data, and a single `interpret_card` interpreter grounds that data onto the
/// real `BattleState`.
///
/// This separates "what a card does" (pattern semantics, as data) from "how
/// the engine applies it" (the interpreter). The migration is incremental:
/// `card_effects` returns `Some(..)` only for cards that have been moved to
/// the IR; everything else still falls back to the legacy branch in
/// `execute_card`. Stateful / irregular cards (Rampage, Corruption, Feed,
/// Fiend Fire, ...) stay in the legacy path until the IR vocabulary grows.

///|
/// A numeric amount, resolved against the current battle state at play time.
/// This lets cards like Heavy Blade (Strength scales 3x) or Body Slam (damage
/// equals current Block) stay data instead of code.
pub(all) enum Amount {
  Const(Int)
  /// Current player Block (Body Slam).
  PlayerBlock
  /// `base` damage, with Strength applied `mult` times instead of once.
  /// The engine's damage path already adds Strength once, so we pre-add the
  /// extra `(mult - 1)` applications here. Heavy Blade = `mult: 3`.
  StrengthScaled(base~ : Int, mult~ : Int)
} derive(Debug, Eq)

///|
/// Which combatants an effect hits.
pub(all) enum EffectTarget {
  /// The enemy the player selected (`target_index`).
  ChosenEnemy
  /// Every living enemy. Damage is rolled once and applied to all (matches the
  /// legacy Cleave / Immolate behaviour where relic modifiers fire a single
  /// time).
  AllEnemies
  /// The first living enemy, re-resolved per hit (legacy Sword Boomerang).
  FirstAliveEnemy
} derive(Debug, Eq)

///|
/// A single primitive effect. A card is an ordered list of these.
pub(all) enum Effect {
  DealDamage(amount~ : Amount, target~ : EffectTarget, hits~ : Int)
  GainBlock(Int)
  ApplyVulnerable(amount~ : Int, target~ : EffectTarget)
  ApplyWeak(amount~ : Int, target~ : EffectTarget)
  GainStrength(Int)
  GainEnergy(Int)
  DrawCards(Int)
  AddMetallicize(Int)
  AddDemonForm(Int)
  SetBarricade
  AddFeelNoPain(Int)
} derive(Debug, Eq)

///|
/// Data-driven card definitions. Returns `Some(effects)` for cards that have
/// been migrated to the IR, `None` for cards still handled by the legacy
/// branch in `execute_card`.
pub fn card_effects(id : CardId) -> Array[Effect]? {
  match id {
    // === Straight attacks ===
    Strike => Some([DealDamage(amount=Const(6), target=ChosenEnemy, hits=1)])
    Bludgeon => Some([DealDamage(amount=Const(32), target=ChosenEnemy, hits=1)])
    Bash =>
      Some([
        DealDamage(amount=Const(8), target=ChosenEnemy, hits=1),
        ApplyVulnerable(amount=2, target=ChosenEnemy),
      ])
    Clothesline =>
      Some([
        DealDamage(amount=Const(12), target=ChosenEnemy, hits=1),
        ApplyWeak(amount=2, target=ChosenEnemy),
      ])
    Uppercut =>
      Some([
        DealDamage(amount=Const(13), target=ChosenEnemy, hits=1),
        ApplyWeak(amount=1, target=ChosenEnemy),
        ApplyVulnerable(amount=1, target=ChosenEnemy),
      ])
    Iron_Wave =>
      Some([
        GainBlock(6),
        DealDamage(amount=Const(5), target=ChosenEnemy, hits=1),
      ])
    Twin_Strike =>
      Some([DealDamage(amount=Const(5), target=ChosenEnemy, hits=2)])
    Pummel => Some([DealDamage(amount=Const(2), target=ChosenEnemy, hits=4)])
    Heavy_Blade =>
      Some([
        DealDamage(
          amount=StrengthScaled(base=14, mult=3),
          target=ChosenEnemy,
          hits=1,
        ),
      ])
    Body_Slam =>
      Some([DealDamage(amount=PlayerBlock, target=ChosenEnemy, hits=1)])
    Sword_Boomerang =>
      Some([DealDamage(amount=Const(3), target=FirstAliveEnemy, hits=3)])
    // === AoE attacks ===
    Cleave => Some([DealDamage(amount=Const(8), target=AllEnemies, hits=1)])
    Immolate => Some([DealDamage(amount=Const(21), target=AllEnemies, hits=1)])
    // === Block / utility skills ===
    Defend => Some([GainBlock(6)])
    Armaments => Some([GainBlock(5)])
    Impervious => Some([GainBlock(30)])
    Shrug_It_Off => Some([GainBlock(8), DrawCards(1)])
    Seeing_Red => Some([GainEnergy(2)])
    Battle_Trance => Some([DrawCards(3)])
    Shockwave =>
      Some([
        ApplyWeak(amount=3, target=AllEnemies),
        ApplyVulnerable(amount=3, target=AllEnemies),
      ])
    // === Powers ===
    Inflame => Some([GainStrength(2)])
    Metallicize => Some([AddMetallicize(3)])
    Demon_Form => Some([AddDemonForm(2)])
    Barricade => Some([SetBarricade])
    Feel_No_Pain => Some([AddFeelNoPain(3)])
    // Everything else stays on the legacy path for now.
    _ => None
  }
}

///|
/// Resolve an `Amount` to the base damage fed into the engine's damage path.
fn eval_amount(state : BattleState, amount : Amount) -> Int {
  match amount {
    Const(n) => n
    PlayerBlock => state.player.block
    // Engine adds Strength once downstream, so pre-add the extra applications.
    StrengthScaled(base~, mult~) =>
      base + state.player.status.strength * (mult - 1)
  }
}

///|
/// Apply one damage instance to the chosen target style, returning total
/// damage dealt (for logging).
fn deal_damage(
  state : BattleState,
  amount : Amount,
  target : EffectTarget,
  hits : Int,
  target_index : Int,
) -> Int {
  let mut total = 0
  match target {
    AllEnemies => {
      // Roll relic/status modifiers once, then apply to every living enemy
      // (matches legacy Cleave / Immolate).
      let base = eval_amount(state, amount)
      let damage = calculate_attack_damage(base, state.player)
      let (modified, relic_logs) = relics_on_attack(
        state.relics,
        state.relic_state,
        state.player,
        damage,
      )
      for log in relic_logs {
        state.logs.push(log)
      }
      let mut h = 0
      while h < hits {
        for enemy in state.enemies {
          if !enemy.fighter.is_dead() {
            total += apply_damage(enemy.fighter, modified)
          }
        }
        h += 1
      }
    }
    ChosenEnemy => {
      let mut h = 0
      while h < hits {
        let base = eval_amount(state, amount)
        total += apply_attack_with_relics(
          state,
          base,
          state.enemies[target_index].fighter,
        )
        h += 1
      }
    }
    FirstAliveEnemy => {
      let mut h = 0
      while h < hits {
        let idx = first_alive_enemy(state)
        if idx >= 0 {
          let base = eval_amount(state, amount)
          total += apply_attack_with_relics(
            state,
            base,
            state.enemies[idx].fighter,
          )
        }
        h += 1
      }
    }
  }
  total
}

///|
/// Apply a status effect to the targeted enemies.
fn apply_status(
  state : BattleState,
  target : EffectTarget,
  vulnerable : Int,
  weak : Int,
  target_index : Int,
) -> Unit {
  match target {
    AllEnemies =>
      for enemy in state.enemies {
        if !enemy.fighter.is_dead() {
          enemy.fighter.status.vulnerable += vulnerable
          enemy.fighter.status.weak += weak
        }
      }
    ChosenEnemy | FirstAliveEnemy => {
      let idx = match target {
        FirstAliveEnemy => first_alive_enemy(state)
        _ => target_index
      }
      if idx >= 0 && idx < state.enemies.length() {
        state.enemies[idx].fighter.status.vulnerable += vulnerable
        state.enemies[idx].fighter.status.weak += weak
      }
    }
  }
}

///|
/// Interpret a card's IR against the battle state.
fn interpret_card(
  state : BattleState,
  card_id : CardId,
  effects : Array[Effect],
  target_index : Int,
) -> Unit {
  let def = card_def(card_id)
  let mut damage_dealt = 0
  let mut block_gained = 0
  for effect in effects {
    match effect {
      DealDamage(amount~, target~, hits~) =>
        damage_dealt += deal_damage(state, amount, target, hits, target_index)
      GainBlock(n) => {
        add_block(state.player, n)
        block_gained += n
      }
      ApplyVulnerable(amount~, target~) =>
        apply_status(state, target, amount, 0, target_index)
      ApplyWeak(amount~, target~) =>
        apply_status(state, target, 0, amount, target_index)
      GainStrength(n) => state.player.status.strength += n
      GainEnergy(n) => state.player.energy += n
      DrawCards(n) => draw_cards(state, n)
      AddMetallicize(n) => state.powers.metallicize += n
      AddDemonForm(n) => state.powers.demon_form += n
      SetBarricade => state.powers.barricade = true
      AddFeelNoPain(n) => state.powers.feel_no_pain += n
    }
  }
  // Auto-generated log line summarising the resolved effect.
  let mut msg = def.name
  if damage_dealt > 0 {
    msg = msg + ": " + damage_dealt.to_string() + " damage!"
  } else if block_gained > 0 {
    msg = msg + ": gain " + block_gained.to_string() + " Block."
  } else {
    msg = msg + " played."
  }
  state.logs.push(msg)
}
