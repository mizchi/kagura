///|
pub fn SpriteAnimationStateMachine::new(
  clips : Map[String, SpriteAnimationClip],
  transitions : Array[SpriteTransition],
  initial_state : String,
) -> SpriteAnimationStateMachine {
  let clip = match clips.get(initial_state) {
    Some(c) => c
    None => {
      // Fallback: use the first clip in the map
      let mut first : SpriteAnimationClip? = None
      clips.each(fn(_k, v) { if first is None { first = Some(v) } })
      match first {
        Some(c) => c
        None =>
          // Empty fallback
          { name: "", frames: [], total_duration: 0.0 }
      }
    }
  }
  let player = SpriteAnimationPlayer::new(clip)
  { clips, transitions, player, current_state: initial_state }
}

///|
/// Trigger a state transition. Returns true if transition occurred.
pub fn SpriteAnimationStateMachine::trigger(
  self : SpriteAnimationStateMachine,
  name : String,
) -> Bool {
  for t in self.transitions {
    if t.from_state == self.current_state && t.trigger == name {
      match self.clips.get(t.to_state) {
        Some(clip) => {
          self.current_state = t.to_state
          self.player.set_clip(clip)
          return true
        }
        None => ()
      }
    }
  }
  false
}

///|
pub fn SpriteAnimationStateMachine::update(
  self : SpriteAnimationStateMachine,
  dt : Double,
) -> Unit {
  self.player.update(dt)
}

///|
pub fn SpriteAnimationStateMachine::current_key(
  self : SpriteAnimationStateMachine,
) -> @atlas.AssetKey {
  self.player.current_key()
}

///|
pub fn SpriteAnimationStateMachine::current_state_name(
  self : SpriteAnimationStateMachine,
) -> String {
  self.current_state
}
