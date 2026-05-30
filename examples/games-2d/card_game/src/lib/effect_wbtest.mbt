///|
/// PoC validation: for every card migrated to the Effect IR, the IR
/// interpreter (`execute_card`) must produce exactly the same battle-state
/// changes as the original hand-written branch (`execute_card_legacy`).

///|
/// Capture the parts of the battle state a card can affect, as a flat Int
/// vector that is cheap to compare.
fn fingerprint(state : BattleState) -> Array[Int] {
  let fp = [
    state.player.hp,
    state.player.block,
    state.player.energy,
    state.player.status.strength,
    state.powers.metallicize,
    state.powers.demon_form,
    state.powers.feel_no_pain,
    if state.powers.barricade {
      1
    } else {
      0
    },
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
/// Build a fresh, deterministic two-enemy battle and pre-load Block/Strength
/// so scaling cards (Heavy Blade, Body Slam, ...) are exercised.
fn fixture() -> BattleState {
  let state = BattleState::new([JawWorm, Cultist], seed=7)
  state.player.block = 10
  state.player.status.strength = 3
  state
}

///|
/// Run one card through the IR path and the legacy path on two identical
/// states and assert the resulting fingerprints match.
fn assert_ir_matches_legacy(card : CardId) -> Unit raise {
  let ir_state = fixture()
  let legacy_state = fixture()
  execute_card(ir_state, card, 0) // IR path (card_effects -> interpret_card)
  execute_card_legacy(legacy_state, card, 0) // original branch
  assert_eq(fingerprint(ir_state), fingerprint(legacy_state))
}

///|
test "Effect IR reproduces legacy behaviour for migrated cards" {
  let migrated = [
    Strike,
    Bludgeon,
    Bash,
    Clothesline,
    Uppercut,
    Iron_Wave,
    Twin_Strike,
    Pummel,
    Heavy_Blade,
    Body_Slam,
    Sword_Boomerang,
    Cleave,
    Immolate,
    Defend,
    Armaments,
    Impervious,
    Shrug_It_Off,
    Seeing_Red,
    Battle_Trance,
    Shockwave,
    Inflame,
    Metallicize,
    Demon_Form,
    Barricade,
    Feel_No_Pain,
  ]
  for card in migrated {
    // Sanity: each listed card really is IR-driven.
    assert_true(card_effects(card) is Some(_))
    assert_ir_matches_legacy(card)
  }
}

///|
test "non-migrated cards are not claimed by the IR" {
  // A few intentionally-legacy cards must return None so they keep using
  // execute_card_legacy.
  assert_true(card_effects(Rampage) is None)
  assert_true(card_effects(Whirlwind) is None)
  assert_true(card_effects(Feed) is None)
  assert_true(card_effects(Fiend_Fire) is None)
  assert_true(card_effects(Corruption) is None)
}
