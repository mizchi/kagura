///|
pub fn SpriteAnimationPlayer::new(
  clip : SpriteAnimationClip,
) -> SpriteAnimationPlayer {
  { clip, timeline: @playback.Timeline::new(playing=true), }
}

///|
pub fn SpriteAnimationPlayer::update(
  self : SpriteAnimationPlayer,
  dt : Double,
) -> Unit {
  if !self.timeline.playing || self.clip.frames.is_empty() {
    return
  }
  self.timeline.advance(dt, self.clip.total_duration, subtract_wrap=true)
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
    if self.timeline.time < elapsed {
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
  self.timeline.playing = true
}

///|
pub fn SpriteAnimationPlayer::pause(self : SpriteAnimationPlayer) -> Unit {
  self.timeline.playing = false
}

///|
pub fn SpriteAnimationPlayer::set_clip(
  self : SpriteAnimationPlayer,
  clip : SpriteAnimationClip,
) -> Unit {
  self.clip = clip
  self.timeline.time = 0.0
  self.timeline.playing = true
}

///|
pub fn SpriteAnimationPlayer::set_speed(
  self : SpriteAnimationPlayer,
  speed : Double,
) -> Unit {
  self.timeline.speed = speed
}

///|
pub fn SpriteAnimationPlayer::set_looping(
  self : SpriteAnimationPlayer,
  looping : Bool,
) -> Unit {
  self.timeline.looping = looping
}
