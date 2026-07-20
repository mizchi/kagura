///|
/// Procedural card generation + executable-grounded evaluation.
///
/// This is the loop the Effect IR unlocks. The paper "Grounding Machine
/// Creativity in Game Design Knowledge Representations" (Liu & Tatar) found
/// that asking an LLM to emit engine code directly produced artifacts that
/// *never compiled* (pass@k = 0.0) — the dominant failure being references to
/// types/structures that don't exist ("grounding failures").
///
/// Expressing a card as `Array[Effect]` data sidesteps that entire failure
/// class: any value of that type is, by construction, runnable. So a generator
/// (here a PRNG; it could equally be an LLM constrained to this grammar)
/// cannot produce an un-runnable card. We then *execute* each candidate
/// through the same `apply_effects` interpreter real cards use and measure its
/// output against this project's stated balance baselines (see `economy.mbt`:
/// Strike ~6 DPE, Defend ~5 BPE, a draw ~2.0, an energy ~5.5).

///|
/// A synthesized card: a cost plus a list of IR effects.
pub(all) struct SynthCard {
  cost : Int
  effects : Array[Effect]
} derive(Debug)

///|
/// How a generated card scores against its energy budget.
pub(all) enum Verdict {
  Underpowered
  Balanced
  Overpowered
} derive(Debug, Eq)

///|
pub impl Show for Verdict with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Measured result of evaluating a synthesized card over the horizon. All
/// figures are *differential* (with the card minus without it).
pub(all) struct SynthEval {
  damage : Int // extra damage dealt to the dummy
  prevented : Int // extra incoming damage absorbed by Block
  extra_hp_lost : Int // extra HP given up (self-damage cards)
  value : Double // weighted total value
  budget : Double // value the cost "should" buy
  verdict : Verdict
} derive(Debug)

///|
pub impl Show for SynthEval with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Tiny linear-congruential PRNG (same family as the battle RNG).
priv struct Rng {
  mut s : Int
}

///|
fn Rng::next(self : Rng) -> Int {
  self.s = self.s * 1103515245 + 12345
  (self.s >> 16) & 0x7FFF
}

///|
/// Inclusive range.
fn Rng::range(self : Rng, lo : Int, hi : Int) -> Int {
  lo + self.next() % (hi - lo + 1)
}

///|
/// Generate one card from the parametric core of the IR. Every branch yields a
/// runnable effect, so the generator can never emit an invalid card.
pub fn gen_card(seed : Int) -> SynthCard {
  let rng = { s: seed }
  let cost = rng.range(0, 3)
  let n_effects = rng.range(1, 2)
  let effects : Array[Effect] = []
  let mut i = 0
  while i < n_effects {
    let effect = match rng.range(0, 7) {
      0 =>
        DealDamage(
          amount=Const(rng.range(4, 14)),
          target=ChosenEnemy,
          hits=rng.range(1, 2),
        )
      1 => GainBlock(rng.range(4, 12))
      2 => ApplyVulnerable(amount=rng.range(1, 2), target=ChosenEnemy)
      3 => ApplyWeak(amount=rng.range(1, 2), target=ChosenEnemy)
      4 => GainStrength(rng.range(1, 2))
      5 => DrawCards(rng.range(1, 2))
      6 => GainEnergy(1)
      _ => LoseHP(rng.range(2, 6))
    }
    effects.push(effect)
    i += 1
  }
  { cost, effects }
}

///|
/// Horizon (turns) the multi-turn evaluator simulates. Long enough for
/// persistent powers (Demon Form, Metallicize) and Strength scaling to show
/// their deferred value.
const EVAL_HORIZON : Int = 6

///|
/// Damage of one "baseline attack" — a stand-in for the rest of the deck. The
/// player throws `EVAL_BASELINE_ATTACKS` of these per turn so that Strength /
/// Vulnerable buffs have something to multiply.
const EVAL_STRIKE_BASE : Int = 6

///|
const EVAL_BASELINE_ATTACKS : Int = 2

///|
/// The training dummy's base attack and Strength (so Disarm / Weak have
/// something to bite into).
const EVAL_ENEMY_ATTACK : Int = 8

///|
const EVAL_ENEMY_STRENGTH : Int = 3

///|
/// Value a single energy buys (Strike ≈ 6 damage for 1 energy).
const EVAL_PER_ENERGY : Double = 6.0

///|
/// What the multi-turn simulation accumulated.
priv struct HorizonResult {
  damage : Int // damage dealt to the dummy over the horizon
  prevented : Int // incoming damage absorbed by Block
  hp_lost : Int // incoming damage that got through to HP
  immediate : Double // one-off utility value (energy / draw / self-HP)
}

///|
/// Simulate `EVAL_HORIZON` turns of a controlled battle. The player plays
/// `EVAL_BASELINE_ATTACKS` baseline attacks each turn (the rest of the deck);
/// when `play` is set, the candidate card is additionally played on turn 1.
/// Persistent powers, Strength scaling and debuffs therefore accrue over the
/// remaining turns, so their deferred value is captured.
fn run_horizon(card : SynthCard, play : Bool) -> HorizonResult {
  let state = BattleState::new([JawWorm], seed=999)
  let enemy = state.enemies[0].fighter
  enemy.hp = 1000000
  enemy.max_hp = 1000000
  enemy.status.strength = EVAL_ENEMY_STRENGTH
  let hp_before = enemy.hp
  // Clean-slate player so the differential isolates the card.
  state.player.hp = 100000
  state.player.max_hp = 100000
  state.player.block = 0
  state.player.status.strength = 0
  let mut prevented = 0
  let mut hp_lost = 0
  let mut immediate = 0.0
  let mut turn = 1
  while turn <= EVAL_HORIZON {
    // --- start of turn ---
    if turn > 1 && !state.powers.barricade {
      state.player.block = 0
    }
    if state.powers.demon_form > 0 {
      state.player.status.strength += state.powers.demon_form
    }
    state.player.energy = 3
    // --- play the candidate card (turn 1 only) ---
    if play && turn == 1 {
      let hp0 = state.player.hp
      let energy0 = state.player.energy
      let hand0 = state.hand.length()
      let _ = apply_effects(state, card.effects, 0)
      let energy_gain = state.player.energy - energy0
      let drawn = state.hand.length() - hand0
      let hp_cost = hp0 - state.player.hp
      // Energy spent IS the card's cost (already in the budget), so only count
      // net energy gained. Card draw and self-HP are one-off.
      immediate += (if energy_gain > 0 { energy_gain.to_double() } else { 0.0 }) *
        5.5 +
        drawn.to_double() * 2.0 -
        hp_cost.to_double() * 1.0
    }
    // --- baseline attacks (rest of deck); routed through apply_damage so
    //     Vulnerable on the dummy is honoured ---
    let mut k = 0
    while k < EVAL_BASELINE_ATTACKS {
      let dmg = calculate_attack_damage(EVAL_STRIKE_BASE, state.player)
      let _ = apply_damage(enemy, dmg)
      k += 1
    }
    // --- end of turn powers ---
    if state.powers.metallicize > 0 {
      state.player.block += state.powers.metallicize
    }
    if state.powers.flex_loss > 0 {
      state.player.status.strength -= state.powers.flex_loss
      state.powers.flex_loss = 0
    }
    // --- enemy attacks back ---
    let mut atk = EVAL_ENEMY_ATTACK +
      (if enemy.status.strength > 0 { enemy.status.strength } else { 0 })
    if enemy.status.weak > 0 {
      atk = (atk.to_double() * 0.75).to_int()
    }
    let absorbed = if state.player.block >= atk {
      atk
    } else {
      state.player.block
    }
    state.player.block -= absorbed
    prevented += absorbed
    hp_lost += atk - absorbed
    // tick the dummy's debuffs
    if enemy.status.vulnerable > 0 {
      enemy.status.vulnerable -= 1
    }
    if enemy.status.weak > 0 {
      enemy.status.weak -= 1
    }
    turn += 1
  }
  { damage: hp_before - enemy.hp, prevented, hp_lost, immediate }
}

///|
/// Evaluate a synthesized card by the *differential* of a multi-turn
/// simulation: (output with the card) − (output without it). This isolates the
/// card's true contribution, including deferred value from Strength scaling and
/// persistent powers that a single-shot snapshot misses.
pub fn eval_synth(card : SynthCard) -> SynthEval {
  let with_card = run_horizon(card, true)
  let without = run_horizon(card, false)
  let damage = with_card.damage - without.damage
  let prevented = with_card.prevented - without.prevented
  let extra_hp_lost = with_card.hp_lost - without.hp_lost
  let value = damage.to_double() +
    prevented.to_double() * 0.8 -
    extra_hp_lost.to_double() * 0.5 +
    with_card.immediate
  // A 0-cost card still buys roughly two-thirds of an energy's value.
  let budget = (if card.cost == 0 { 0.66 } else { card.cost.to_double() }) *
    EVAL_PER_ENERGY
  let ratio = value / budget
  let verdict = if ratio < 0.7 {
    Underpowered
  } else if ratio <= 1.5 {
    Balanced
  } else {
    Overpowered
  }
  { damage, prevented, extra_hp_lost, value, budget, verdict }
}

///|
/// Build a SynthCard from a designed card: cost from `card_def`, behaviour from
/// the IR. Lets the evaluator grade the hand-authored set too.
pub fn synth_of_card(id : CardId) -> SynthCard {
  let effects = match card_effects(id) {
    Some(e) => e
    None => []
  }
  { cost: card_def(id).cost, effects }
}

///|
/// Evaluate a designed card through the same loop generated cards use.
pub fn eval_card(id : CardId) -> SynthEval {
  eval_synth(synth_of_card(id))
}

///|
/// Human-readable description of an effect (for logs / demos).
pub fn describe_effect(effect : Effect) -> String {
  match effect {
    DealDamage(amount~, target~, hits~) => {
      let amt = match amount {
        Const(n) => n.to_string()
        PlayerBlock => "block"
        StrengthScaled(base~, mult~) =>
          base.to_string() + "+" + mult.to_string() + "xSTR"
        RampageScaled(base~) => base.to_string() + "+rampage"
      }
      let tgt = match target {
        ChosenEnemy => "target"
        AllEnemies => "all"
        FirstAliveEnemy => "front"
      }
      "deal " +
      amt +
      (if hits > 1 { " x" + hits.to_string() } else { "" }) +
      " to " +
      tgt
    }
    GainBlock(n) => "gain " + n.to_string() + " block"
    ApplyVulnerable(amount~, ..) =>
      "apply " + amount.to_string() + " vulnerable"
    ApplyWeak(amount~, ..) => "apply " + amount.to_string() + " weak"
    GainStrength(n) => "gain " + n.to_string() + " strength"
    GainEnergy(n) => "gain " + n.to_string() + " energy"
    DrawCards(n) => "draw " + n.to_string()
    LoseHP(n) => "lose " + n.to_string() + " HP"
    _ => "special"
  }
}

///|
pub fn describe_card(card : SynthCard) -> String {
  let parts : Array[String] = []
  for e in card.effects {
    parts.push(describe_effect(e))
  }
  let mut body = ""
  let mut first = true
  for p in parts {
    if first {
      body = p
      first = false
    } else {
      body = body + ", " + p
    }
  }
  "[" + card.cost.to_string() + "E] " + body
}

///|
/// Aggregate result of generating and grading a batch of cards.
pub(all) struct GenSummary {
  generated : Int
  runnable : Int // cards that executed without error
  underpowered : Int
  balanced : Int
  overpowered : Int
} derive(Debug)

///|
pub impl Show for GenSummary with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Generate `count` cards, execute each, and tally the verdicts. Because the
/// IR is closed typed data, `runnable` always equals `generated` — the loop
/// the paper could not reach with free-form code generation.
pub fn generate_and_grade(count : Int, seed? : Int = 1) -> GenSummary {
  let mut runnable = 0
  let mut under = 0
  let mut balanced = 0
  let mut over = 0
  let mut i = 0
  while i < count {
    let card = gen_card(seed + i * 1103515245)
    let result = eval_synth(card)
    runnable += 1 // execution is total over well-typed IR
    match result.verdict {
      Underpowered => under += 1
      Balanced => balanced += 1
      Overpowered => over += 1
    }
    i += 1
  }
  {
    generated: count,
    runnable,
    underpowered: under,
    balanced,
    overpowered: over,
  }
}

///|
/// Generate cards and keep only those graded `Balanced` (a designer-assist
/// filter). Returns up to `keep` accepted cards.
pub fn generate_balanced(
  keep : Int,
  max_tries? : Int = 1000,
  seed? : Int = 1,
) -> Array[SynthCard] {
  let kept : Array[SynthCard] = []
  let mut tries = 0
  while kept.length() < keep && tries < max_tries {
    let card = gen_card(seed + tries * 1103515245)
    if eval_synth(card).verdict == Balanced {
      kept.push(card)
    }
    tries += 1
  }
  kept
}

///|
/// Grade every designed card with the same evaluator (a calibration check).
pub fn grade_designed_cards() -> GenSummary {
  let mut under = 0
  let mut balanced = 0
  let mut over = 0
  let ids = all_card_ids()
  for id in ids {
    match eval_card(id).verdict {
      Underpowered => under += 1
      Balanced => balanced += 1
      Overpowered => over += 1
    }
  }
  {
    generated: ids.length(),
    runnable: ids.length(),
    underpowered: under,
    balanced,
    overpowered: over,
  }
}

///|
/// Build a reproducible multi-line report of the generate→evaluate loop, for
/// the headless runner.
pub fn format_generation_report(
  count? : Int = 1000,
  seed? : Int = 12345,
) -> String {
  let lines : Array[String] = []
  let s = generate_and_grade(count, seed~)
  lines.push(
    "  generated=" +
    s.generated.to_string() +
    " runnable=" +
    s.runnable.to_string() +
    " (no grounding failures)",
  )
  let total = s.underpowered + s.balanced + s.overpowered
  lines.push(
    "  underpowered=" +
    s.underpowered.to_string() +
    " balanced=" +
    s.balanced.to_string() +
    " overpowered=" +
    s.overpowered.to_string() +
    " (of " +
    total.to_string() +
    ")",
  )
  lines.push("  sample balanced generated cards:")
  let kept = generate_balanced(6, seed=seed + 99)
  for card in kept {
    let e = eval_synth(card)
    lines.push(
      "    " +
      describe_card(card) +
      "  value=" +
      e.value.to_string() +
      " budget=" +
      e.budget.to_string(),
    )
  }
  let cal = grade_designed_cards()
  lines.push(
    "  evaluator vs designed cards: underpowered=" +
    cal.underpowered.to_string() +
    " balanced=" +
    cal.balanced.to_string() +
    " overpowered=" +
    cal.overpowered.to_string() +
    " (of " +
    cal.generated.to_string() +
    ")",
  )
  let mut out = ""
  let mut first = true
  for line in lines {
    if first {
      out = line
      first = false
    } else {
      out = out + "\n" + line
    }
  }
  out
}

///|
pub extend SynthCard with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Verdict with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Verdict with Eq::{not_equal, equal}

///|
pub extend Verdict with Show::{to_string, output}

///|
pub extend SynthEval with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SynthEval with Show::{to_string, output}

///|
pub extend GenSummary with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GenSummary with Show::{to_string, output}
