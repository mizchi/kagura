///|
pub fn AnimationPlayer::new(clip : AnimationClip) -> AnimationPlayer {
  { clip, time: 0.0, playing: true, looping: true, speed: 1.0 }
}

///|
/// Advance the animation time by dt seconds.
pub fn AnimationPlayer::update(self : AnimationPlayer, dt : Double) -> Unit {
  if not(self.playing) {
    return
  }
  self.time = self.time + dt * self.speed
  if self.looping && self.clip.duration > 0.0 {
    // Wrap around using modulo (safe even for large dt values)
    self.time = self.time % self.clip.duration
    if self.time < 0.0 {
      self.time = self.time + self.clip.duration
    }
  } else {
    // Clamp
    if self.time < 0.0 {
      self.time = 0.0
    }
    if self.time > self.clip.duration {
      self.time = self.clip.duration
    }
  }
}

///|
/// Sample all channels at the current time, returning one NodePose per affected node.
pub fn AnimationPlayer::sample(self : AnimationPlayer) -> Array[NodePose] {
  let pose_map : Map[Int, NodePose] = {}
  for channel in self.clip.channels {
    let node_idx = channel.node_index
    let pose = match pose_map.get(node_idx) {
      Some(p) => p
      None => {
        let p : NodePose = {
          node_index: node_idx,
          translation: None,
          rotation: None,
          scale: None,
        }
        pose_map[node_idx] = p
        p
      }
    }
    match channel.target {
      Translation => {
        let v = sample_vec3(channel, self.time)
        pose_map[node_idx] = { ..pose, translation: Some(v) }
      }
      Rotation => {
        let q = sample_quat(channel, self.time)
        pose_map[node_idx] = { ..pose, rotation: Some(q) }
      }
      Scale => {
        let v = sample_vec3(channel, self.time)
        pose_map[node_idx] = { ..pose, scale: Some(v) }
      }
    }
  }
  let result : Array[NodePose] = []
  pose_map.each(fn(_k, v) { result.push(v) })
  result
}

///|
pub fn AnimationPlayer::play(self : AnimationPlayer) -> Unit {
  self.playing = true
}

///|
pub fn AnimationPlayer::pause(self : AnimationPlayer) -> Unit {
  self.playing = false
}

///|
pub fn AnimationPlayer::set_looping(
  self : AnimationPlayer,
  looping : Bool,
) -> Unit {
  self.looping = looping
}

///|
pub fn AnimationPlayer::set_speed(
  self : AnimationPlayer,
  speed : Double,
) -> Unit {
  self.speed = speed
}

///|
pub fn AnimationPlayer::set_time(self : AnimationPlayer, time : Double) -> Unit {
  self.time = time
}

///|
pub fn AnimationPlayer::current_time(self : AnimationPlayer) -> Double {
  self.time
}
