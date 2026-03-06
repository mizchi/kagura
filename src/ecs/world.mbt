///|
pub struct World {
  mut next_id : Int
  alive : Map[Int, Bool]
  tags : Map[Int, Array[Tag]]
  transforms : Map[Int, @transform3d.Transform3D]
  velocities : Map[Int, Velocity]
  health : Map[Int, Health]
  sprites : Map[Int, Sprite]
  materials : Map[Int, @scene3d.Material]
  physics_body_ids : Map[Int, Int]
  scene_node_ids : Map[Int, Int]
  animation_players : Map[Int, @animation3d.AnimationPlayer]
}

///|
pub fn World::new() -> World {
  {
    next_id: 0,
    alive: {},
    tags: {},
    transforms: {},
    velocities: {},
    health: {},
    sprites: {},
    materials: {},
    physics_body_ids: {},
    scene_node_ids: {},
    animation_players: {},
  }
}

///|
pub fn World::spawn(self : World) -> EntityId {
  let id = self.next_id
  self.next_id += 1
  self.alive[id] = true
  { value: id }
}

///|
pub fn World::spawn_at(
  self : World,
  transform : @transform3d.Transform3D,
) -> EntityId {
  let eid = self.spawn()
  self.transforms[eid.value] = transform
  eid
}

///|
pub fn World::destroy(self : World, eid : EntityId) -> Unit {
  self.alive[eid.value] = false
}

///|
pub fn World::is_alive(self : World, eid : EntityId) -> Bool {
  match self.alive.get(eid.value) {
    Some(true) => true
    _ => false
  }
}

///|
pub fn World::entity_count(self : World) -> Int {
  let mut count = 0
  self.alive.each(fn(_id, alive) { if alive { count += 1 } })
  count
}

///|
pub fn World::compact(self : World) -> Unit {
  let dead : Array[Int] = []
  self.alive.each(fn(id, alive) { if not(alive) { dead.push(id) } })
  for id in dead {
    self.alive.remove(id)
    self.tags.remove(id)
    self.transforms.remove(id)
    self.velocities.remove(id)
    self.health.remove(id)
    self.sprites.remove(id)
    self.materials.remove(id)
    self.physics_body_ids.remove(id)
    self.scene_node_ids.remove(id)
    self.animation_players.remove(id)
  }
}

// Transform

///|
pub fn World::set_transform(
  self : World,
  eid : EntityId,
  t : @transform3d.Transform3D,
) -> Unit {
  self.transforms[eid.value] = t
}

///|
pub fn World::get_transform(
  self : World,
  eid : EntityId,
) -> @transform3d.Transform3D? {
  self.transforms.get(eid.value)
}

// Velocity

///|
pub fn World::set_velocity(self : World, eid : EntityId, v : Velocity) -> Unit {
  self.velocities[eid.value] = v
}

///|
pub fn World::get_velocity(self : World, eid : EntityId) -> Velocity? {
  self.velocities.get(eid.value)
}

// Health

///|
pub fn World::set_health(self : World, eid : EntityId, h : Health) -> Unit {
  self.health[eid.value] = h
}

///|
pub fn World::get_health(self : World, eid : EntityId) -> Health? {
  self.health.get(eid.value)
}

// Sprite

///|
pub fn World::set_sprite(self : World, eid : EntityId, s : Sprite) -> Unit {
  self.sprites[eid.value] = s
}

///|
pub fn World::get_sprite(self : World, eid : EntityId) -> Sprite? {
  self.sprites.get(eid.value)
}

// Material

///|
pub fn World::set_material(
  self : World,
  eid : EntityId,
  m : @scene3d.Material,
) -> Unit {
  self.materials[eid.value] = m
}

///|
pub fn World::get_material(self : World, eid : EntityId) -> @scene3d.Material? {
  self.materials.get(eid.value)
}

// Physics body ID

///|
pub fn World::set_physics_body_id(
  self : World,
  eid : EntityId,
  body_id : Int,
) -> Unit {
  self.physics_body_ids[eid.value] = body_id
}

///|
pub fn World::get_physics_body_id(self : World, eid : EntityId) -> Int? {
  self.physics_body_ids.get(eid.value)
}

// Scene node ID

///|
pub fn World::set_scene_node_id(
  self : World,
  eid : EntityId,
  node_id : Int,
) -> Unit {
  self.scene_node_ids[eid.value] = node_id
}

///|
pub fn World::get_scene_node_id(self : World, eid : EntityId) -> Int? {
  self.scene_node_ids.get(eid.value)
}

// Animation player

///|
pub fn World::set_animation_player(
  self : World,
  eid : EntityId,
  player : @animation3d.AnimationPlayer,
) -> Unit {
  self.animation_players[eid.value] = player
}

///|
pub fn World::get_animation_player(
  self : World,
  eid : EntityId,
) -> @animation3d.AnimationPlayer? {
  self.animation_players.get(eid.value)
}

// Tags

///|
pub fn World::add_tag(self : World, eid : EntityId, tag : Tag) -> Unit {
  match self.tags.get(eid.value) {
    Some(tags) => tags.push(tag)
    None => self.tags[eid.value] = [tag]
  }
}

///|
pub fn World::has_tag(self : World, eid : EntityId, tag : Tag) -> Bool {
  match self.tags.get(eid.value) {
    Some(tags) => tags.contains(tag)
    None => false
  }
}
