///|
test "sound_cue_for_event maps combat and pickup events" {
  assert_eq(sound_cue_for_event(@game.AttackTriggered), Some(SfxAttack))
  assert_eq(sound_cue_for_event(@game.HitSparks(0.0, 0.0)), Some(SfxEnemyHit))
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
  assert_eq(sound_cue_for_event(@game.FireballTrail(0.0, 0.0)), None)
  assert_eq(sound_cue_for_event(@game.GroundTelegraphRing(0.0, 0.0, 2.0)), None)
}

///|
test "repeated combat cues finish naturally and can play again after mute" {
  let state = GameState::new(seed=42)
  let clip = @audio.new_audio_clip(
    @audio.default_audio_format(),
    Bytes::make(4410 * 4, 16),
    false,
  )
  state.audio_bank.register(SfxSpellChainLightning, clip)
  let player = state.audio_bank.player(SfxSpellChainLightning).unwrap()
  state.play_sound_cue(SfxSpellChainLightning)
  let output : FixedArray[Float] = FixedArray::make(882, 0.0)
  state.audio_ctx.render(441, output)
  let position = state.audio_ctx.current_position(player)
  assert_true(position > 0.0)
  // Each arc in a chain must not rewind the same sound to its first transient.
  state.play_sound_cue(SfxSpellChainLightning)
  assert_eq(state.audio_ctx.current_position(player), position)
  assert_eq(state.audio_last_played_state, "suppressed")
  for _ in 0..<11 {
    state.audio_ctx.render(441, output)
  }
  state.play_sound_cue(SfxSpellChainLightning)
  assert_eq(state.audio_ctx.current_position(player), 0.0)
  assert_eq(state.playing_audio_player_count(), 1)
  state.set_audio_muted(true)
  state.audio_ctx.render(441, output)
  assert_eq(state.playing_audio_player_count(), 0)
  state.set_audio_muted(false)
  state.play_sound_cue(SfxSpellChainLightning)
  assert_eq(state.playing_audio_player_count(), 1)
}

///|
test "play_sound_cue reports muted state when audio is muted" {
  let state = GameState::new(seed=42)

  state.set_audio_muted(true)
  state.play_sound_cue(SfxAttack)

  assert_true(state.audio_bank.is_muted())
  assert_eq(state.audio_last_played_cue, "attack")
  assert_eq(state.audio_last_played_state, "muted")
  assert_eq(state.playing_audio_player_count(), 0)
}
