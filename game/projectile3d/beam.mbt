///|
/// Immutable, committed aim and timing for a telegraphed travelling beam.
/// The caller owns age, hit history, damage, pause and entity lifetime.
pub struct BeamPath {
  origin : @math3d.Vec3
  aim : @math3d.Vec3
  direction : @math3d.Vec3
  delay : Double
  speed : Double
  length : Double
  range : Double
}

///|
/// Times are seconds, lengths are world units. Inputs must be finite.
/// Reject an empty direction, negative delay or nonpositive speed/length/range.
pub fn BeamPath::new(
  origin : @math3d.Vec3,
  aim : @math3d.Vec3,
  delay~ : Double,
  speed~ : Double,
  length~ : Double,
  range~ : Double,
) -> BeamPath? {
  let direction = aim.sub(origin).normalize()
  if !(delay >= 0 &&
    speed > 0 &&
    length > 0 &&
    range > 0 &&
    direction.length_squared() > 0) {
    return None
  }
  Some({ origin, aim, direction, delay, speed, length, range, })
}

///|
pub fn BeamPath::charge_progress(self : BeamPath, age : Double) -> Double {
  if self.delay == 0 {
    1
  } else {
    (age / self.delay).max(0).min(1)
  }
}

///|
pub fn BeamPath::just_fired(
  self : BeamPath,
  previous_age : Double,
  age : Double,
) -> Bool {
  age > previous_age &&
  age >= self.delay &&
  (previous_age < self.delay || (self.delay == 0 && previous_age == 0))
}

///|
/// The visible segment at this time, or None while charging/after the tail exits.
pub fn BeamPath::segment_at(self : BeamPath, age : Double) -> @math3d.Segment3? {
  self.swept_segment(age, age)
}

///|
/// Space covered from the old tail through the new head. A skipped charge
/// boundary still includes the origin; reverse time produces no sweep.
pub fn BeamPath::swept_segment(
  self : BeamPath,
  previous_age : Double,
  age : Double,
) -> @math3d.Segment3? {
  if age < previous_age || age < self.delay {
    return None
  }
  let tail = ((previous_age - self.delay) * self.speed - self.length).max(0)
  if tail >= self.range {
    return None
  }
  let head = ((age - self.delay) * self.speed).max(0).min(self.range)
  Some(
    @math3d.Segment3::new(
      self.origin.add(self.direction.scale(tail)),
      self.origin.add(self.direction.scale(head)),
    ),
  )
}
