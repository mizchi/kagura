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
pub impl Show for Verdict with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Measured result of executing a synthesized card.
pub(all) struct SynthEval {
  damage : Int
  block : Int
  energy_gain : Int
  cards_drawn : Int
  strength_gain : Int
  vulnerable : Int
  weak : Int
  hp_cost : Int
  value : Double // weighted total value
  budget : Double // value the cost "should" buy
  verdict : Verdict
} derive(Debug)

///|
pub impl Show for SynthEval with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
/// Tiny linear-congruential PRNG (same family as the battle RNG).
struct Rng {
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
/// Execute a synthesized card in a controlled battle and measure its output.
/// The enemy is given huge HP so multi-hit cards never run out of target, and
/// the player is given ample energy so cost never blocks execution — we are
/// measuring raw output, then comparing it to the cost budget separately.
pub fn eval_synth(card : SynthCard) -> SynthEval {
  let state = BattleState::new([JawWorm], seed=999)
  state.enemies[0].fighter.hp = 100000
  state.enemies[0].fighter.max_hp = 100000
  state.player.energy = 50
  let hp0 = state.player.hp
  let str0 = state.player.status.strength
  let energy0 = state.player.energy
  let hand0 = state.hand.length()
  let out = apply_effects(state, card.effects, 0)
  let damage = out.damage
  let block = out.block
  let hp_cost = hp0 - state.player.hp
  let strength_gain = state.player.status.strength - str0
  let energy_gain = state.player.energy - energy0
  let cards_drawn = state.hand.length() - hand0
  let vulnerable = state.enemies[0].fighter.status.vulnerable
  let weak = state.enemies[0].fighter.status.weak
  // Value weights mirror economy.mbt's baselines.
  let value = damage.to_double() +
    block.to_double() * 0.8 +
    energy_gain.to_double() * 5.5 +
    cards_drawn.to_double() * 2.0 +
    strength_gain.to_double() * 8.0 +
    vulnerable.to_double() * 1.5 +
    weak.to_double() * 1.0 -
    hp_cost.to_double() * 1.0
  // A 0-cost card still buys ~half an energy's worth of value.
  let budget = (if card.cost == 0 { 0.5 } else { card.cost.to_double() }) * 6.0
  let ratio = value / budget
  let verdict = if ratio < 0.7 {
    Underpowered
  } else if ratio <= 1.4 {
    Balanced
  } else {
    Overpowered
  }
  {
    damage,
    block,
    energy_gain,
    cards_drawn,
    strength_gain,
    vulnerable,
    weak,
    hp_cost,
    value,
    budget,
    verdict,
  }
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
pub impl Show for GenSummary with output(self, logger) {
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
