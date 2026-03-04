///|
pub struct AnimationStateMachine3D {
  clips : Map[String, AnimationClip]
  transitions : Array[AnimTransition3D]
  mut current_player : AnimationPlayer
  mut next_player : AnimationPlayer?
  mut blend_progress : Double
  mut blend_duration : Double
  mut current_state : String
}

///|
pub fn AnimationStateMachine3D::new(
  clips : Map[String, AnimationClip],
  transitions : Array[AnimTransition3D],
  initial_state : String,
) -> AnimationStateMachine3D {
  let clip = match clips.get(initial_state) {
    Some(c) => c
    None => {
      let mut first : AnimationClip? = None
      clips.each(fn(_k, v) {
        if first is None {
          first = Some(v)
        }
      })
      match first {
        Some(c) => c
        None => { name: "", channels: [], duration: 0.0 }
      }
    }
  }
  let player = AnimationPlayer::new(clip)
  {
    clips,
    transitions,
    current_player: player,
    next_player: None,
    blend_progress: 0.0,
    blend_duration: 0.0,
    current_state: initial_state,
  }
}

///|
/// Trigger a state transition. Returns true if transition started.
pub fn AnimationStateMachine3D::trigger(
  self : AnimationStateMachine3D,
  name : String,
) -> Bool {
  for t in self.transitions {
    if (t.from_state == self.current_state || t.from_state == "*") &&
      t.trigger == name {
      match self.clips.get(t.to_state) {
        Some(clip) => {
          if t.blend_duration > 0.0 {
            // Start cross-fade
            let next = AnimationPlayer::new(clip)
            self.next_player = Some(next)
            self.blend_progress = 0.0
            self.blend_duration = t.blend_duration
          } else {
            // Instant switch
            self.current_player = AnimationPlayer::new(clip)
            self.next_player = None
            self.blend_progress = 0.0
            self.blend_duration = 0.0
          }
          self.current_state = t.to_state
          return true
        }
        None => ()
      }
    }
  }
  false
}

///|
/// Update animation time and blend progress.
pub fn AnimationStateMachine3D::update(
  self : AnimationStateMachine3D,
  dt : Double,
) -> Unit {
  self.current_player.update(dt)
  match self.next_player {
    Some(next) => {
      next.update(dt)
      self.blend_progress = self.blend_progress + dt
      if self.blend_progress >= self.blend_duration {
        // Blend complete: swap
        self.current_player = next
        self.next_player = None
        self.blend_progress = 0.0
        self.blend_duration = 0.0
      }
    }
    None => ()
  }
}

///|
/// Sample the current animation pose, blending if in transition.
pub fn AnimationStateMachine3D::sample(
  self : AnimationStateMachine3D,
) -> Array[NodePose] {
  let current_poses = self.current_player.sample()
  match self.next_player {
    Some(next) => {
      let next_poses = next.sample()
      let weight = if self.blend_duration > 0.0 {
        self.blend_progress / self.blend_duration
      } else {
        1.0
      }
      blend_node_poses(current_poses, next_poses, weight)
    }
    None => current_poses
  }
}

///|
pub fn AnimationStateMachine3D::current_state_name(
  self : AnimationStateMachine3D,
) -> String {
  self.current_state
}

///|
pub fn AnimationStateMachine3D::is_blending(
  self : AnimationStateMachine3D,
) -> Bool {
  self.next_player is Some(_)
}

///|
pub fn AnimationStateMachine3D::blend_weight(
  self : AnimationStateMachine3D,
) -> Double {
  if self.blend_duration > 0.0 {
    self.blend_progress / self.blend_duration
  } else {
    0.0
  }
}
