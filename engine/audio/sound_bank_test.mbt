///|
test "sound bank isolates cues, suppresses overlap, and replays completed voices" {
  let context = @kagura_audio.MixerAudioContext::new(44100)
  let bank : @kagura_audio.SoundBank[String] = @kagura_audio.SoundBank::new(
    context,
  )
  let clip = @kagura_audio.new_audio_clip(
    @kagura_audio.default_audio_format(),
    Bytes::make(4410 * 4, 16),
    false,
  )
  assert_eq(bank.play("unknown"), @kagura_audio.CuePlayback::Missing)
  bank.register("hit", clip, volume=0.5)
  bank.register("cast", clip)
  assert_eq(bank.loaded_count(), 2)
  assert_eq(bank.play("hit"), @kagura_audio.CuePlayback::Played)
  let out : FixedArray[Float] = FixedArray::make(882, 0.0)
  context.render(441, out)
  assert_eq(bank.play("hit"), @kagura_audio.CuePlayback::Suppressed)
  assert_eq(bank.play("cast"), @kagura_audio.CuePlayback::Played)
  assert_eq(bank.playing_count(), 2)
  for _ in 0..<11 {
    context.render(441, out)
  }
  assert_eq(bank.play("hit"), @kagura_audio.CuePlayback::Played)
  assert_eq(bank.play("hit", restart=true), @kagura_audio.CuePlayback::Played)
}

///|
test "mute stops all cues and replacing a clip does not leak voices" {
  let context = @kagura_audio.MixerAudioContext::new(44100)
  let bank : @kagura_audio.SoundBank[Int] = @kagura_audio.SoundBank::new(
    context,
  )
  let clip = @kagura_audio.new_audio_clip(
    @kagura_audio.default_audio_format(),
    Bytes::make(4410 * 4, 16),
    false,
  )
  bank.register(7, clip)
  ignore(bank.play(7))
  let previous = bank.player(7).unwrap()
  bank.register(7, clip)
  assert_eq(bank.loaded_count(), 1)
  assert_eq(bank.playing_count(), 0)
  match context.state(previous) {
    @kagura_audio.Stopped => ()
    _ => fail("replacing a cue must dispose its previous voice")
  }
  ignore(bank.play(7))
  bank.set_muted(true)
  assert_true(bank.is_muted())
  assert_eq(bank.playing_count(), 0)
  assert_eq(bank.play(7), @kagura_audio.CuePlayback::Muted)
  bank.register(7, clip)
  assert_eq(bank.loaded_count(), 1)
  assert_eq(bank.playing_count(), 0)
  bank.set_muted(false)
  assert_eq(bank.play(7), @kagura_audio.CuePlayback::Played)
  bank.clear()
  assert_eq(bank.loaded_count(), 0)
  assert_eq(bank.play(7), @kagura_audio.CuePlayback::Missing)
}

///|
test "pausing a sound bank freezes voices and resumes only those that were playing" {
  let context = @kagura_audio.MixerAudioContext::new(44100)
  let bank : @kagura_audio.SoundBank[String] = @kagura_audio.SoundBank::new(
    context,
  )
  let clip = @kagura_audio.new_audio_clip(
    @kagura_audio.default_audio_format(),
    Bytes::make(4410 * 4, 16),
    false,
  )
  bank.register("attack", clip)
  bank.register("idle", clip)
  ignore(bank.play("attack"))
  let out : FixedArray[Float] = FixedArray::make(882, 0.0)
  context.render(441, out)
  let voice = bank.player("attack").unwrap()
  let position = context.current_position(voice)
  bank.set_paused(true)
  bank.set_paused(true)
  for _ in 0..<20 {
    context.render(441, out)
  }
  assert_eq(context.current_position(voice), position)
  assert_eq(bank.playing_count(), 0)
  assert_eq(bank.play("idle"), @kagura_audio.CuePlayback::Suppressed)
  bank.set_paused(false)
  assert_eq(bank.playing_count(), 1)
  context.render(441, out)
  assert_true(context.current_position(voice) > position)
  bank.set_paused(true)
  bank.set_muted(true)
  bank.set_muted(false)
  bank.set_paused(false)
  assert_eq(bank.playing_count(), 0)
  ignore(bank.play("attack"))
  bank.set_paused(true)
  bank.register("attack", clip)
  bank.set_paused(false)
  assert_eq(bank.playing_count(), 0)
}
