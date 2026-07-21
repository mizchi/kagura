///|
pub fn SpriteAnimationPlayer::new(
  clip : SpriteAnimationClip,
) -> SpriteAnimationPlayer {
  { clip, time: 0.0, playing: true, looping: true, speed: 1.0 }
}

///|
pub fn SpriteAnimationPlayer::update(
  self : SpriteAnimationPlayer,
  dt : Double,
) -> Unit {
  if !self.playing || self.clip.frames.is_empty() {
    return
  }
  self.time = self.time + dt * self.speed
  if self.looping {
    if self.clip.total_duration > 0.0 {
      while self.time >= self.clip.total_duration {
        self.time = self.time - self.clip.total_duration
      }
      while self.time < 0.0 {
        self.time = self.time + self.clip.total_duration
      }
    }
  } else if self.time >= self.clip.total_duration {
    self.time = self.clip.total_duration
    self.playing = false
  } else if self.time < 0.0 {
    self.time = 0.0
    self.playing = false
  }
}

///|
/// Get the current frame index (discrete step).
pub fn SpriteAnimationPlayer::current_frame_index(
  self : SpriteAnimationPlayer,
) -> Int {
  if self.clip.frames.is_empty() {
    return 0
  }
  let mut elapsed = 0.0
  for i in 0..<self.clip.frames.length() {
    elapsed = elapsed + self.clip.frames[i].duration
    if self.time < elapsed {
      return i
    }
  }
  self.clip.frames.length() - 1
}

///|
/// Get the current frame's atlas key.
pub fn SpriteAnimationPlayer::current_key(
  self : SpriteAnimationPlayer,
) -> @atlas.AssetKey {
  let idx = self.current_frame_index()
  self.clip.frames[idx].atlas_key
}

///|
pub fn SpriteAnimationPlayer::play(self : SpriteAnimationPlayer) -> Unit {
  self.playing = true
}

///|
pub fn SpriteAnimationPlayer::pause(self : SpriteAnimationPlayer) -> Unit {
  self.playing = false
}

///|
pub fn SpriteAnimationPlayer::set_clip(
  self : SpriteAnimationPlayer,
  clip : SpriteAnimationClip,
) -> Unit {
  self.clip = clip
  self.time = 0.0
  self.playing = true
}

///|
pub fn SpriteAnimationPlayer::set_speed(
  self : SpriteAnimationPlayer,
  speed : Double,
) -> Unit {
  self.speed = speed
}

///|
pub fn SpriteAnimationPlayer::set_looping(
  self : SpriteAnimationPlayer,
  looping : Bool,
) -> Unit {
  self.looping = looping
}
