///|
pub fn World::each_entity(self : World, f : (EntityId) -> Unit) -> Unit {
  for id in 0..<self.alive.length() {
    if self.alive[id] {
      f({ value: id })
    }
  }
}

///|
pub fn World::each_with_transform(
  self : World,
  f : (EntityId, @transform3d.Transform3D) -> Unit,
) -> Unit {
  // Component arrays grow lazily, so `transforms.length() <= alive.length()`.
  // Iterating by the shorter bound skips the dead-tail entities for free.
  // `unsafe_get` skips the bounds-check function call (we already bound
  // the loop above).
  let alive = self.alive
  let transforms = self.transforms
  for id in 0..<transforms.length() {
    if alive.unsafe_get(id) {
      match transforms.unsafe_get(id) {
        Some(t) => f({ value: id }, t)
        None => ()
      }
    }
  }
}

///|
pub fn World::each_with_transform_velocity(
  self : World,
  f : (EntityId, @transform3d.Transform3D, Velocity) -> Unit,
) -> Unit {
  let alive = self.alive
  let transforms = self.transforms
  let velocities = self.velocities
  let n = if transforms.length() < velocities.length() {
    transforms.length()
  } else {
    velocities.length()
  }
  for id in 0..<n {
    if alive.unsafe_get(id) {
      match transforms.unsafe_get(id) {
        Some(t) =>
          match velocities.unsafe_get(id) {
            Some(v) => f({ value: id }, t, v)
            None => ()
          }
        None => ()
      }
    }
  }
}

///|
pub fn World::each_with_tag(
  self : World,
  tag : Tag,
  f : (EntityId) -> Unit,
) -> Unit {
  let alive = self.alive
  let tags_arr = self.tags
  for id in 0..<tags_arr.length() {
    if alive.unsafe_get(id) {
      match tags_arr.unsafe_get(id) {
        Some(tags) => if tags.contains(tag) { f({ value: id }) }
        None => ()
      }
    }
  }
}

///|
pub fn World::entities_with_tag(self : World, tag : Tag) -> Array[EntityId] {
  let result : Array[EntityId] = []
  self.each_with_tag(tag, fn(eid) { result.push(eid) })
  result
}
