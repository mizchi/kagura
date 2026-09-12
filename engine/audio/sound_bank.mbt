///|
/// Outcome of a cue request. Playback errors remain errors, not missing cues.
pub(all) enum CuePlayback {
  Played
  Suppressed
  Muted
  Missing
} derive(Eq, Debug)

///|
pub impl Show for CuePlayback with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Owns one non-overlapping voice per game-defined key in an existing mixer.
/// The game retains responsibility for event mapping, asset loading and gains.
pub struct SoundBank[Key] {
  priv context : MixerAudioContext
  priv entries : Array[(Key, PlayerId)]
  priv mut muted : Bool
}

///|
pub fn[Key] SoundBank::new(context : MixerAudioContext) -> SoundBank[Key] {
  { context, entries: [], muted: false, }
}

///|
pub fn[Key : Eq] SoundBank::player(
  self : SoundBank[Key],
  cue : Key,
) -> PlayerId? {
  for (key, player) in self.entries {
    if key == cue {
      return Some(player)
    }
  }
  None
}

///|
/// Replacing a cue disposes its previous voice, including an actively playing one.
pub fn[Key : Eq] SoundBank::register(
  self : SoundBank[Key],
  cue : Key,
  clip : AudioClip,
  volume? : Double = 1.0,
) -> Unit raise {
  let player = self.context.create_player(clip)
  self.context.set_volume(player, volume)
  for i in 0..<self.entries.length() {
    let (key, old) = self.entries[i]
    if key == cue {
      self.context.dispose(old)
      self.entries[i] = (cue, player)
      return
    }
  }
  self.entries.push((cue, player))
}

///|
/// Finish the previous cue by default. Explicit restart is useful for UI sounds.
pub fn[Key : Eq] SoundBank::play(
  self : SoundBank[Key],
  cue : Key,
  restart? : Bool = false,
) -> CuePlayback raise {
  if self.muted {
    return Muted
  }
  match self.player(cue) {
    None => Missing
    Some(player) => {
      match self.context.state(player) {
        Playing => if !restart { return Suppressed }
        _ => ()
      }
      self.context.seek(player, 0.0)
      self.context.play(player)
      Played
    }
  }
}

///|
pub fn[Key] SoundBank::set_muted(self : SoundBank[Key], muted : Bool) -> Unit {
  self.muted = muted
  if muted {
    for (_, player) in self.entries {
      self.context.stop(player) catch {
        _ => ()
      }
    }
  }
}

///|
pub fn[Key] SoundBank::is_muted(self : SoundBank[Key]) -> Bool {
  self.muted
}

///|
pub fn[Key] SoundBank::loaded_count(self : SoundBank[Key]) -> Int {
  self.entries.length()
}

///|
pub fn[Key] SoundBank::playing_count(self : SoundBank[Key]) -> Int {
  let mut count = 0
  for (_, player) in self.entries {
    match self.context.state(player) {
      Playing => count += 1
      _ => ()
    }
  }
  count
}

///|
pub fn[Key] SoundBank::clear(self : SoundBank[Key]) -> Unit {
  for (_, player) in self.entries {
    self.context.dispose(player)
  }
  self.entries.clear()
}
