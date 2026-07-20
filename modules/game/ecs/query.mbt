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
  for id in 0..<self.alive.length() {
    if self.alive[id] {
      match self.transforms[id] {
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
  for id in 0..<self.alive.length() {
    if self.alive[id] {
      match (self.transforms[id], self.velocities[id]) {
        (Some(t), Some(v)) => f({ value: id }, t, v)
        _ => ()
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
  for id in 0..<self.alive.length() {
    if self.alive[id] {
      match self.tags[id] {
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
