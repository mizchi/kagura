///|
/// Effect IR (data-driven card effects)
///
/// Background: most card numerics (cost / base_damage / base_block) already
/// live as data in `CardDef`, but each card's *behaviour* was hand-written as
/// a branch inside `execute_card`. This file expresses a card's behaviour as
/// `Array[Effect]` data, and a single interpreter (`apply_effects`) grounds
/// that data onto the real `BattleState`.
///
/// This separates "what a card does" (pattern semantics, as data) from "how
/// the engine applies it" (the interpreter). Every card now has an IR entry in
/// `card_effects`; `execute_card_legacy` is kept only as a reference fallback.
/// Because the IR is closed, typed data, anything that produces a value of
/// type `Array[Effect]` (a hand author, a procedural generator, an LLM) is
/// guaranteed to be runnable — see `generator.mbt` for the
/// generate-then-evaluate loop this enables.

///|
/// A numeric amount, resolved against the current battle state at play time.
/// This keeps cards like Heavy Blade (Strength scales 3x), Body Slam (damage
/// equals current Block) or Rampage (grows each play) as data, not code.
pub(all) enum Amount {
  Const(Int)
  /// Current player Block (Body Slam).
  PlayerBlock
  /// `base` damage, with Strength applied `mult` times instead of once.
  /// The engine's damage path already adds Strength once, so we pre-add the
  /// extra `(mult - 1)` applications here. Heavy Blade = `mult: 3`.
  StrengthScaled(base~ : Int, mult~ : Int)
  /// `base` plus the accumulated Rampage bonus (Rampage).
  RampageScaled(base~ : Int)
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
///
/// The first group is the "parametric core" the procedural generator draws
/// from (bounded, always sensible). The rest are named nodes for bespoke card
/// mechanics — still declarative data, but card-specific.
pub(all) enum Effect {
  // --- parametric core ---
  DealDamage(amount~ : Amount, target~ : EffectTarget, hits~ : Int)
  GainBlock(Int)
  ApplyVulnerable(amount~ : Int, target~ : EffectTarget)
  ApplyWeak(amount~ : Int, target~ : EffectTarget)
  GainStrength(Int)
  GainEnergy(Int)
  DrawCards(Int)
  LoseHP(Int)
  // --- powers / persistent ---
  AddMetallicize(Int)
  AddDemonForm(Int)
  SetBarricade
  AddFeelNoPain(Int)
  SetCorruption
  AddTempStrength(Int) // Flex: +STR now, lost at end of turn
  // --- bespoke card nodes ---
  ReduceEnemyStrength(amount~ : Int, target~ : EffectTarget) // Disarm
  DoubleStrength // Limit Break
  DoubleBlock // Entrench
  IncreaseRampage(Int) // Rampage tail
  AddCardToDiscard(CardId) // Anger
  RecallTopDiscardToDraw // Headbutt
  ExhaustRandomFromHand // True Grit
  DealDamageWithKillBonus(
    amount~ : Amount,
    max_hp~ : Int,
    target~ : EffectTarget
  ) // Feed
  WhirlwindDamage(per~ : Int) // Whirlwind: spend all energy, X hits to all
  FiendFire(per~ : Int) // Fiend Fire: exhaust hand, `per` damage each
  ReaperDamage(per~ : Int) // Reaper: hit all, heal unblocked
} derive(Debug, Eq)

///|
/// Data-driven definition for every card. The behaviour lives here as data;
/// `apply_effects` interprets it.
pub fn card_effects(id : CardId) -> Array[Effect]? {
  match id {
    // === Straight attacks ===
    Strike => Some([DealDamage(amount=Const(6), target=ChosenEnemy, hits=1)])
    Bludgeon => Some([DealDamage(amount=Const(32), target=ChosenEnemy, hits=1)])
    Carnage => Some([DealDamage(amount=Const(20), target=ChosenEnemy, hits=1)])
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
    Pommel_Strike =>
      Some([
        DealDamage(amount=Const(9), target=ChosenEnemy, hits=1),
        DrawCards(1),
      ])
    Anger =>
      Some([
        DealDamage(amount=Const(6), target=ChosenEnemy, hits=1),
        AddCardToDiscard(Anger),
      ])
    Headbutt =>
      Some([
        DealDamage(amount=Const(9), target=ChosenEnemy, hits=1),
        RecallTopDiscardToDraw,
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
    Rampage =>
      Some([
        DealDamage(amount=RampageScaled(base=8), target=ChosenEnemy, hits=1),
        IncreaseRampage(5),
      ])
    Feed =>
      Some([
        DealDamageWithKillBonus(amount=Const(10), max_hp=3, target=ChosenEnemy),
      ])
    // === AoE attacks ===
    Cleave => Some([DealDamage(amount=Const(8), target=AllEnemies, hits=1)])
    Immolate => Some([DealDamage(amount=Const(21), target=AllEnemies, hits=1)])
    Whirlwind => Some([WhirlwindDamage(per=5)])
    Reaper => Some([ReaperDamage(per=4)])
    Fiend_Fire => Some([FiendFire(per=7)])
    // === Block / utility skills ===
    Defend => Some([GainBlock(6)])
    Armaments => Some([GainBlock(5)])
    Impervious => Some([GainBlock(30)])
    Shrug_It_Off => Some([GainBlock(8), DrawCards(1)])
    True_Grit => Some([GainBlock(7), ExhaustRandomFromHand])
    Entrench => Some([DoubleBlock])
    Seeing_Red => Some([GainEnergy(2)])
    Battle_Trance => Some([DrawCards(3)])
    Bloodletting => Some([LoseHP(3), GainEnergy(2)])
    Offering => Some([LoseHP(6), GainEnergy(2), DrawCards(3)])
    Flex => Some([AddTempStrength(2)])
    Limit_Break => Some([DoubleStrength])
    Shockwave =>
      Some([
        ApplyWeak(amount=3, target=AllEnemies),
        ApplyVulnerable(amount=3, target=AllEnemies),
      ])
    Disarm => Some([ReduceEnemyStrength(amount=2, target=ChosenEnemy)])
    // === Powers ===
    Inflame => Some([GainStrength(2)])
    Metallicize => Some([AddMetallicize(3)])
    Demon_Form => Some([AddDemonForm(2)])
    Barricade => Some([SetBarricade])
    Feel_No_Pain => Some([AddFeelNoPain(3)])
    Corruption => Some([SetCorruption])
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
    RampageScaled(base~) => base + state.powers.rampage_bonus
  }
}

///|
/// Resolve a target style to a concrete enemy index (or -1 if none).
fn resolve_index(
  state : BattleState,
  target : EffectTarget,
  target_index : Int,
) -> Int {
  match target {
    FirstAliveEnemy => first_alive_enemy(state)
    _ => target_index
  }
}

///|
/// Apply one damage instance, returning total damage dealt (for logging).
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
    ChosenEnemy | FirstAliveEnemy => {
      let mut h = 0
      while h < hits {
        let idx = resolve_index(state, target, target_index)
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
      let idx = resolve_index(state, target, target_index)
      if idx >= 0 && idx < state.enemies.length() {
        state.enemies[idx].fighter.status.vulnerable += vulnerable
        state.enemies[idx].fighter.status.weak += weak
      }
    }
  }
}

///|
/// Summary of what an effect list did, used for logging and evaluation.
pub(all) struct EffectOutcome {
  mut damage : Int
  mut block : Int
} derive(Debug)

///|
/// Core interpreter: apply an effect list to the battle state. This is the
/// single grounding point for the IR — every card and every generated card
/// flows through here.
fn apply_effects(
  state : BattleState,
  effects : Array[Effect],
  target_index : Int,
) -> EffectOutcome {
  let out : EffectOutcome = { damage: 0, block: 0 }
  for effect in effects {
    match effect {
      DealDamage(amount~, target~, hits~) =>
        out.damage += deal_damage(state, amount, target, hits, target_index)
      GainBlock(n) => {
        add_block(state.player, n)
        out.block += n
      }
      ApplyVulnerable(amount~, target~) =>
        apply_status(state, target, amount, 0, target_index)
      ApplyWeak(amount~, target~) =>
        apply_status(state, target, 0, amount, target_index)
      GainStrength(n) => state.player.status.strength += n
      GainEnergy(n) => state.player.energy += n
      DrawCards(n) => draw_cards(state, n)
      LoseHP(n) => {
        state.player.hp -= n
        if state.player.hp < 0 {
          state.player.hp = 0
        }
      }
      AddMetallicize(n) => state.powers.metallicize += n
      AddDemonForm(n) => state.powers.demon_form += n
      SetBarricade => state.powers.barricade = true
      AddFeelNoPain(n) => state.powers.feel_no_pain += n
      SetCorruption => state.powers.corruption = true
      AddTempStrength(n) => {
        state.player.status.strength += n
        state.powers.flex_loss += n
      }
      ReduceEnemyStrength(amount~, target~) => {
        let idx = resolve_index(state, target, target_index)
        if idx >= 0 && idx < state.enemies.length() {
          state.enemies[idx].fighter.status.strength -= amount
        }
      }
      DoubleStrength => {
        let s = state.player.status.strength
        state.player.status.strength += s
      }
      DoubleBlock => {
        let b = state.player.block
        state.player.block += b
        out.block += b
      }
      IncreaseRampage(n) => state.powers.rampage_bonus += n
      AddCardToDiscard(card) => state.discard_pile.push(card)
      RecallTopDiscardToDraw =>
        if state.discard_pile.length() > 0 {
          match state.discard_pile.pop() {
            Some(card) => state.draw_pile.push(card)
            None => ()
          }
        }
      ExhaustRandomFromHand =>
        if state.hand.length() > 0 {
          let idx = next_random(state) % state.hand.length()
          let exhausted = remove_at(state.hand, idx)
          state.exhaust_pile.push(exhausted)
          trigger_exhaust(state)
        }
      DealDamageWithKillBonus(amount~, max_hp~, target~) => {
        let idx = resolve_index(state, target, target_index)
        if idx >= 0 && idx < state.enemies.length() {
          let hp_before = state.enemies[idx].fighter.hp
          let base = eval_amount(state, amount)
          out.damage += apply_attack_with_relics(
            state,
            base,
            state.enemies[idx].fighter,
          )
          if hp_before > 0 && state.enemies[idx].fighter.is_dead() {
            state.player.max_hp += max_hp
            state.player.hp += max_hp
          }
        }
      }
      WhirlwindDamage(per~) => {
        let x = state.player.energy
        state.player.energy = 0
        let damage = calculate_attack_damage(per, state.player)
        let (modified, relic_logs) = relics_on_attack(
          state.relics,
          state.relic_state,
          state.player,
          damage,
        )
        for log in relic_logs {
          state.logs.push(log)
        }
        let mut hit = 0
        while hit < x {
          for enemy in state.enemies {
            if !enemy.fighter.is_dead() {
              out.damage += apply_damage(enemy.fighter, modified)
            }
          }
          hit += 1
        }
      }
      FiendFire(per~) => {
        let count = state.hand.length()
        while state.hand.length() > 0 {
          match state.hand.pop() {
            Some(card) => {
              state.exhaust_pile.push(card)
              trigger_exhaust(state)
            }
            None => ()
          }
        }
        let mut i = 0
        while i < count {
          out.damage += apply_attack_with_relics(
            state,
            per,
            state.enemies[target_index].fighter,
          )
          i += 1
        }
      }
      ReaperDamage(per~) => {
        let damage = calculate_attack_damage(per, state.player)
        let (modified, relic_logs) = relics_on_attack(
          state.relics,
          state.relic_state,
          state.player,
          damage,
        )
        for log in relic_logs {
          state.logs.push(log)
        }
        let mut heal = 0
        for enemy in state.enemies {
          if !enemy.fighter.is_dead() {
            let hp_before = enemy.fighter.hp
            let _ = apply_damage(enemy.fighter, modified)
            heal += hp_before - enemy.fighter.hp
          }
        }
        out.damage += heal
        if heal > 0 {
          state.player.hp = if state.player.hp + heal > state.player.max_hp {
            state.player.max_hp
          } else {
            state.player.hp + heal
          }
        }
      }
    }
  }
  out
}

///|
/// Interpret a card's IR and emit a summary log line.
fn interpret_card(
  state : BattleState,
  card_id : CardId,
  effects : Array[Effect],
  target_index : Int,
) -> Unit {
  let def = card_def(card_id)
  let out = apply_effects(state, effects, target_index)
  let mut msg = def.name
  if out.damage > 0 {
    msg = msg + ": " + out.damage.to_string() + " damage!"
  } else if out.block > 0 {
    msg = msg + ": gain " + out.block.to_string() + " Block."
  } else {
    msg = msg + " played."
  }
  state.logs.push(msg)
}

///|
pub extend Amount with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Amount with Eq::{not_equal, equal}

///|
pub extend EffectTarget with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EffectTarget with Eq::{not_equal, equal}

///|
pub extend Effect with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Effect with Eq::{not_equal, equal}

///|
pub extend EffectOutcome with @moonbitlang/core/debug.Debug::{to_repr}
