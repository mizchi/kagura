///|
/// Playback state; clip sampling, rendering and host objects are owned by callers.
pub(all) struct Timeline {
  mut time : Double
  mut playing : Bool
  mut speed : Double
  mut looping : Bool
}

///|
pub fn Timeline::new(playing? : Bool = false) -> Timeline {
  { time: 0, playing, speed: 1, looping: true, }
}

///|
/// Sprite frame boundaries historically use repeated subtraction. Keep that
/// rounding convention explicit while pose/viewer clips use modulo.
pub fn Timeline::advance(
  self : Timeline,
  delta : Double,
  duration : Double,
  stop_at_end? : Bool = true,
  subtract_wrap? : Bool = false,
) -> Unit {
  if !self.playing {
    return
  }
  self.time += delta * self.speed
  if self.looping && duration > 0 {
    if subtract_wrap {
      while self.time >= duration {
        self.time -= duration
      }
      while self.time < 0 {
        self.time += duration
      }
    } else {
      self.time = self.time % duration
      if self.time < 0 {
        self.time += duration
      }
    }
  } else if !self.looping || !subtract_wrap {
    let end = duration.max(0)
    let finished = self.time >= end || self.time < 0
    self.time = self.time.max(0).min(end)
    if stop_at_end && finished {
      self.playing = false
    }
  }
}

///|
pub fn Timeline::pause(self : Timeline) -> Unit {
  self.playing = false
}

///|
pub fn Timeline::play(
  self : Timeline,
  duration : Double,
  restart_at_end? : Bool = true,
) -> Unit {
  if restart_at_end && self.time >= duration {
    self.time = 0
  }
  self.playing = true
}

///|
pub fn Timeline::seek(
  self : Timeline,
  time : Double,
  duration : Double,
) -> Unit {
  self.time = time.max(0).min(duration.max(0))
  self.playing = false
}
