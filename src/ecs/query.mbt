pub fn World::each_entity(self : World, f : (EntityId) -> Unit) -> Unit {
  self.alive.each(fn(id, alive) {
    if alive {
      f({ value: id })
    }
  })
}

pub fn World::each_with_transform(
  self : World,
  f : (EntityId, @transform3d.Transform3D) -> Unit
) -> Unit {
  self.alive.each(fn(id, alive) {
    if alive {
      match self.transforms.get(id) {
        Some(t) => f({ value: id }, t)
        None => ()
      }
    }
  })
}

pub fn World::each_with_transform_velocity(
  self : World,
  f : (EntityId, @transform3d.Transform3D, Velocity) -> Unit
) -> Unit {
  self.alive.each(fn(id, alive) {
    if alive {
      match (self.transforms.get(id), self.velocities.get(id)) {
        (Some(t), Some(v)) => f({ value: id }, t, v)
        _ => ()
      }
    }
  })
}

pub fn World::each_with_tag(
  self : World,
  tag : Tag,
  f : (EntityId) -> Unit
) -> Unit {
  self.alive.each(fn(id, alive) {
    if alive {
      match self.tags.get(id) {
        Some(tags) => if tags.contains(tag) { f({ value: id }) }
        None => ()
      }
    }
  })
}

pub fn World::entities_with_tag(self : World, tag : Tag) -> Array[EntityId] {
  let result : Array[EntityId] = []
  self.each_with_tag(tag, fn(eid) { result.push(eid) })
  result
}
