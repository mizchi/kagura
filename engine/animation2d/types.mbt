///|
pub(all) struct SpriteFrame {
  atlas_key : @atlas.AssetKey
  duration : Double
}

///|
pub(all) struct SpriteAnimationClip {
  name : String
  frames : Array[SpriteFrame]
  total_duration : Double
}

///|
pub struct SpriteAnimationPlayer {
  mut clip : SpriteAnimationClip
  timeline : @playback.Timeline
}

///|
pub(all) struct SpriteTransition {
  from_state : String
  to_state : String
  trigger : String
}

///|
pub struct SpriteAnimationStateMachine {
  clips : Map[String, SpriteAnimationClip]
  transitions : Array[SpriteTransition]
  player : SpriteAnimationPlayer
  mut current_state : String
}
