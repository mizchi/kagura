///|
/// Entity-Component-System storage. Components are stored in dense Arrays
/// indexed by entity id (`EntityId.value`). Lookups and iteration are O(1)
/// per slot, avoiding the Map hashing overhead the previous implementation
/// paid on every system tick.
///
/// Slot policy: entities are spawned with sequentially increasing ids and
/// every component array is padded to `next_id` length with `None` at spawn
/// time. `destroy` flips `alive[id] = false` but keeps the slot; `compact`
/// Nones out the dead entities' component slots to free the component data
/// without renumbering live ids (callers can keep dangling EntityId
/// references safely - they just observe the entity as dead).
pub struct World {
  mut next_id : Int
  alive : Array[Bool]
  tags : Array[Array[Tag]?]
  transforms : Array[@transform3d.Transform3D?]
  velocities : Array[Velocity?]
  health : Array[Health?]
  sprites : Array[Sprite?]
  materials : Array[@scene3d.Material?]
  physics_body_ids : Array[Int?]
  scene_node_ids : Array[Int?]
  animation_players : Array[@animation3d.AnimationPlayer?]
}

///|
pub fn World::new() -> World {
  {
    next_id: 0,
    alive: [],
    tags: [],
    transforms: [],
    velocities: [],
    health: [],
    sprites: [],
    materials: [],
    physics_body_ids: [],
    scene_node_ids: [],
    animation_players: [],
  }
}

///|
pub fn World::spawn(self : World) -> EntityId {
  let id = self.next_id
  self.next_id += 1
  self.alive.push(true)
  self.tags.push(None)
  self.transforms.push(None)
  self.velocities.push(None)
  self.health.push(None)
  self.sprites.push(None)
  self.materials.push(None)
  self.physics_body_ids.push(None)
  self.scene_node_ids.push(None)
  self.animation_players.push(None)
  { value: id }
}

///|
pub fn World::spawn_at(
  self : World,
  transform : @transform3d.Transform3D,
) -> EntityId {
  let eid = self.spawn()
  self.transforms[eid.value] = Some(transform)
  eid
}

///|
pub fn World::destroy(self : World, eid : EntityId) -> Unit {
  if eid.value >= 0 && eid.value < self.alive.length() {
    self.alive[eid.value] = false
  }
}

///|
pub fn World::is_alive(self : World, eid : EntityId) -> Bool {
  eid.value >= 0 && eid.value < self.alive.length() && self.alive[eid.value]
}

///|
pub fn World::entity_count(self : World) -> Int {
  let mut count = 0
  for v in self.alive {
    if v {
      count = count + 1
    }
  }
  count
}

///|
pub fn World::compact(self : World) -> Unit {
  // Keep slots, free component data. Preserves live EntityId references.
  for id in 0..<self.alive.length() {
    if !self.alive[id] {
      self.tags[id] = None
      self.transforms[id] = None
      self.velocities[id] = None
      self.health[id] = None
      self.sprites[id] = None
      self.materials[id] = None
      self.physics_body_ids[id] = None
      self.scene_node_ids[id] = None
      self.animation_players[id] = None
    }
  }
}

// Transform

///|
pub fn World::set_transform(
  self : World,
  eid : EntityId,
  t : @transform3d.Transform3D,
) -> Unit {
  self.transforms[eid.value] = Some(t)
}

///|
pub fn World::get_transform(
  self : World,
  eid : EntityId,
) -> @transform3d.Transform3D? {
  if eid.value >= 0 && eid.value < self.transforms.length() {
    self.transforms[eid.value]
  } else {
    None
  }
}

// Velocity

///|
pub fn World::set_velocity(self : World, eid : EntityId, v : Velocity) -> Unit {
  self.velocities[eid.value] = Some(v)
}

///|
pub fn World::get_velocity(self : World, eid : EntityId) -> Velocity? {
  if eid.value >= 0 && eid.value < self.velocities.length() {
    self.velocities[eid.value]
  } else {
    None
  }
}

// Health

///|
pub fn World::set_health(self : World, eid : EntityId, h : Health) -> Unit {
  self.health[eid.value] = Some(h)
}

///|
pub fn World::get_health(self : World, eid : EntityId) -> Health? {
  if eid.value >= 0 && eid.value < self.health.length() {
    self.health[eid.value]
  } else {
    None
  }
}

// Sprite

///|
pub fn World::set_sprite(self : World, eid : EntityId, s : Sprite) -> Unit {
  self.sprites[eid.value] = Some(s)
}

///|
pub fn World::get_sprite(self : World, eid : EntityId) -> Sprite? {
  if eid.value >= 0 && eid.value < self.sprites.length() {
    self.sprites[eid.value]
  } else {
    None
  }
}

// Material

///|
pub fn World::set_material(
  self : World,
  eid : EntityId,
  m : @scene3d.Material,
) -> Unit {
  self.materials[eid.value] = Some(m)
}

///|
pub fn World::get_material(self : World, eid : EntityId) -> @scene3d.Material? {
  if eid.value >= 0 && eid.value < self.materials.length() {
    self.materials[eid.value]
  } else {
    None
  }
}

// Physics body ID

///|
pub fn World::set_physics_body_id(
  self : World,
  eid : EntityId,
  body_id : Int,
) -> Unit {
  self.physics_body_ids[eid.value] = Some(body_id)
}

///|
pub fn World::get_physics_body_id(self : World, eid : EntityId) -> Int? {
  if eid.value >= 0 && eid.value < self.physics_body_ids.length() {
    self.physics_body_ids[eid.value]
  } else {
    None
  }
}

// Scene node ID

///|
pub fn World::set_scene_node_id(
  self : World,
  eid : EntityId,
  node_id : Int,
) -> Unit {
  self.scene_node_ids[eid.value] = Some(node_id)
}

///|
pub fn World::get_scene_node_id(self : World, eid : EntityId) -> Int? {
  if eid.value >= 0 && eid.value < self.scene_node_ids.length() {
    self.scene_node_ids[eid.value]
  } else {
    None
  }
}

// Animation player

///|
pub fn World::set_animation_player(
  self : World,
  eid : EntityId,
  player : @animation3d.AnimationPlayer,
) -> Unit {
  self.animation_players[eid.value] = Some(player)
}

///|
pub fn World::get_animation_player(
  self : World,
  eid : EntityId,
) -> @animation3d.AnimationPlayer? {
  if eid.value >= 0 && eid.value < self.animation_players.length() {
    self.animation_players[eid.value]
  } else {
    None
  }
}

// Tags

///|
pub fn World::add_tag(self : World, eid : EntityId, tag : Tag) -> Unit {
  match self.tags[eid.value] {
    Some(tags) => tags.push(tag)
    None => self.tags[eid.value] = Some([tag])
  }
}

///|
pub fn World::has_tag(self : World, eid : EntityId, tag : Tag) -> Bool {
  if eid.value < 0 || eid.value >= self.tags.length() {
    return false
  }
  match self.tags[eid.value] {
    Some(tags) => tags.contains(tag)
    None => false
  }
}
