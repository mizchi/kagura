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
  // Only grow the `alive` array on spawn. Component arrays grow lazily
  // via `grow_to` inside each set_*, so entities that never receive a
  // given component pay zero cost for that component's slot.
  let id = self.next_id
  self.next_id += 1
  self.alive.push(true)
  { value: id }
}

///|
/// Grow `arr` so that index `id` is in range, filling new slots with None.
/// Single-step amortized when callers spawn then immediately set components.
fn[T] grow_to(arr : Array[T?], id : Int) -> Unit {
  while arr.length() <= id {
    arr.push(None)
  }
}

///|
pub fn World::spawn_at(
  self : World,
  transform : @transform3d.Transform3D,
) -> EntityId {
  let eid = self.spawn()
  grow_to(self.transforms, eid.value)
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
/// Clear out the dead-entity slots of a component column. Bounded by the
/// column's own length since lazy growth can leave columns shorter than
/// `alive`.
fn[T] clear_dead(arr : Array[T?], alive : Array[Bool]) -> Unit {
  for id in 0..<arr.length() {
    if !alive[id] {
      arr[id] = None
    }
  }
}

///|
pub fn World::compact(self : World) -> Unit {
  // Keep slots, free component data. Preserves live EntityId references.
  clear_dead(self.tags, self.alive)
  clear_dead(self.transforms, self.alive)
  clear_dead(self.velocities, self.alive)
  clear_dead(self.health, self.alive)
  clear_dead(self.sprites, self.alive)
  clear_dead(self.materials, self.alive)
  clear_dead(self.physics_body_ids, self.alive)
  clear_dead(self.scene_node_ids, self.alive)
  clear_dead(self.animation_players, self.alive)
}

// Transform

///|
pub fn World::set_transform(
  self : World,
  eid : EntityId,
  t : @transform3d.Transform3D,
) -> Unit {
  grow_to(self.transforms, eid.value)
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
  grow_to(self.velocities, eid.value)
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
  grow_to(self.health, eid.value)
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
  grow_to(self.sprites, eid.value)
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
  grow_to(self.materials, eid.value)
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
  grow_to(self.physics_body_ids, eid.value)
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
  grow_to(self.scene_node_ids, eid.value)
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
  grow_to(self.animation_players, eid.value)
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
  grow_to(self.tags, eid.value)
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
