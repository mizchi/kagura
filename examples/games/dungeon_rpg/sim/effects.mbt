///|
/// Receipts describe resolved events. Playback clocks never change game rules.
#derive(Eq)
pub(all) enum EffectKind {
  Impact
  FlameHit
  Recovery
  GuardHit
}

///|
pub extend EffectKind with Eq::{equal, not_equal}

///|
pub(all) enum EffectTarget {
  Party(Int32)
  Enemy(Int32)
}

///|
pub(all) struct Effect {
  id : Int32
  kind : EffectKind
  target : EffectTarget
  amount : Int32
}

///|
fn Game::cue(
  self : Game,
  kind : EffectKind,
  target : EffectTarget,
  amount : Int32,
) -> Unit {
  if amount <= 0 {
    return
  }
  self.next_effect_id += 1
  self.effects.push({ id: self.next_effect_id, kind, target, amount, })
  if self.effects.length() > 48 {
    ignore(self.effects.remove(0))
  }
}
