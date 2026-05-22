///|
test "sound_cue_for_event maps combat and pickup events" {
  assert_eq(sound_cue_for_event(@game.AttackTriggered), Some(SfxAttack))
  assert_eq(sound_cue_for_event(@game.HurtTriggered), Some(SfxHurt))
  assert_eq(
    sound_cue_for_event(@game.ItemPickup(0.0, 0.0, true)),
    Some(SfxPickupHealth),
  )
  assert_eq(
    sound_cue_for_event(@game.ItemPickup(0.0, 0.0, false)),
    Some(SfxPickupLoot),
  )
  assert_eq(
    sound_cue_for_event(@game.ChainLightningArc(0.0, 0.0, 1.0, 1.0)),
    Some(SfxSpellChainLightning),
  )
  assert_eq(
    sound_cue_for_event(@game.FireballCast(0.0, 0.0)),
    Some(SfxSpellFireball),
  )
  assert_eq(
    sound_cue_for_event(@game.HomingMissileLaunch(0.0, 0.0, 1.0, 1.0)),
    Some(SfxSpellHomingMissile),
  )
  assert_eq(
    sound_cue_for_event(@game.IceNovaCast(0.0, 0.0, 3.0)),
    Some(SfxSpellIceNova),
  )
  assert_eq(sound_cue_for_event(@game.FloorComplete), Some(SfxFloorComplete))
}

///|
test "sound_cue_for_event ignores purely visual events" {
  assert_eq(sound_cue_for_event(@game.HitSparks(0.0, 0.0)), None)
  assert_eq(sound_cue_for_event(@game.FireballTrail(0.0, 0.0)), None)
  assert_eq(sound_cue_for_event(@game.GroundTelegraphRing(0.0, 0.0, 2.0)), None)
}

///|
test "play_sound_cue reports muted state when audio is muted" {
  let state = GameState::new(seed=42)

  state.set_audio_muted(true)
  state.play_sound_cue(SfxAttack)

  assert_true(state.audio_muted)
  assert_eq(state.audio_last_played_cue, "attack")
  assert_eq(state.audio_last_played_state, "muted")
  assert_eq(state.playing_audio_player_count(), 0)
}
