///|
/// Validation: for every card, the IR interpreter (`execute_card` ->
/// `apply_effects`) must produce exactly the same battle-state changes as the
/// original hand-written branch (`execute_card_legacy`).

///|
/// Capture every part of the battle state a card can affect, as a flat Int
/// vector that is cheap to compare.
fn fingerprint(state : BattleState) -> Array[Int] {
  let fp = [
    state.player.hp,
    state.player.max_hp,
    state.player.block,
    state.player.energy,
    state.player.status.strength,
    state.powers.metallicize,
    state.powers.demon_form,
    state.powers.feel_no_pain,
    state.powers.flex_loss,
    state.powers.rampage_bonus,
    if state.powers.barricade {
      1
    } else {
      0
    },
    if state.powers.corruption {
      1
    } else {
      0
    },
    state.hand.length(),
    state.draw_pile.length(),
    state.discard_pile.length(),
    state.exhaust_pile.length(),
  ]
  for enemy in state.enemies {
    fp.push(enemy.fighter.hp)
    fp.push(enemy.fighter.status.vulnerable)
    fp.push(enemy.fighter.status.weak)
    fp.push(enemy.fighter.status.strength)
  }
  fp
}

///|
/// A two-enemy battle with Block/Strength pre-loaded so scaling cards
/// (Heavy Blade, Body Slam, Entrench, Rampage, ...) are exercised.
fn fixture_normal() -> BattleState {
  let state = BattleState::new([JawWorm, Cultist], seed=7)
  state.player.block = 10
  state.player.status.strength = 3
  state
}

///|
/// Low-HP variant: enemies and player near death so kill/heal branches
/// (Feed's Max HP bonus, Reaper's lifesteal) actually fire.
fn fixture_lethal() -> BattleState {
  let state = BattleState::new([JawWorm, Cultist], seed=11)
  state.player.hp = 30
  state.player.block = 8
  state.player.status.strength = 4
  state.enemies[0].fighter.hp = 5
  state.enemies[1].fighter.hp = 6
  state
}

///|
/// Run one card through the IR path and the legacy path on two identical
/// states and assert the resulting fingerprints match.
fn assert_ir_matches_legacy(
  card : CardId,
  make : () -> BattleState,
) -> Unit raise {
  let ir_state = make()
  let legacy_state = make()
  execute_card(ir_state, card, 0) // IR path (card_effects -> apply_effects)
  execute_card_legacy(legacy_state, card, 0) // original branch
  assert_eq(fingerprint(ir_state), fingerprint(legacy_state))
}

///|
test "every card is expressed in the Effect IR" {
  for card in all_card_ids() {
    assert_true(card_effects(card) is Some(_))
  }
}

///|
test "Effect IR reproduces legacy behaviour for all cards (normal)" {
  for card in all_card_ids() {
    assert_ir_matches_legacy(card, fixture_normal)
  }
}

///|
test "Effect IR reproduces legacy behaviour for all cards (lethal)" {
  for card in all_card_ids() {
    assert_ir_matches_legacy(card, fixture_lethal)
  }
}
