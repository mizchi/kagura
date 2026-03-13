///|
fn parse_generated_prop_asset_from_glb_bytes(
  bytes : Bytes,
  source_path : String,
) -> GeneratedPropAsset? {
  let (json, buffers) = @gltf.parse_glb(bytes) catch { _ => return None }
  let graph = @gltf.scene_graph_from_gltf(json, buffers) catch {
    _ => return None
  }
  Some({ scene_graph: graph, source_path })
}

///|
fn generated_prop_placement(
  source_path : String,
  floor? : Int = 1,
  anchor? : GeneratedPropAnchor = StartRoomCenter,
  role? : GeneratedPropRole = Decoration,
  pickup_effect? : GeneratedPropPickupEffect = ScorePickup,
  pickup_rarity? : @game.ItemRarity? = None,
  pickup_slot? : @game.EquipSlot? = None,
  scale? : Double = 1.0,
  yaw_degrees? : Double = 0.0,
  x_offset_tiles? : Double = 2.0,
  z_offset_tiles? : Double = 0.0,
) -> GeneratedPropPlacement {
  {
    source_path,
    floor,
    anchor,
    role,
    pickup_effect,
    pickup_rarity,
    pickup_slot,
    scale,
    yaw_degrees,
    x_offset_tiles,
    z_offset_tiles,
  }
}

///|
fn default_generated_prop_manifest() -> Array[GeneratedPropPlacement] {
  default_generated_prop_manifest_for_floor(1)
}

///|
fn default_generated_prop_manifest_for_floor(
  floor : Int,
) -> Array[GeneratedPropPlacement] {
  let _ = floor
  []
}

///|
fn generated_prop_anchor_from_string(value : String) -> GeneratedPropAnchor? {
  match value {
    "start_room" | "start" => Some(StartRoomCenter)
    "largest_non_start_room" | "largest_room" => Some(LargestNonStartRoomCenter)
    "boss_room" | "boss" => Some(BossRoomCenter)
    "treasure_room" | "treasure" => Some(TreasureRoomCenter)
    _ => None
  }
}

///|
fn generated_prop_role_from_string(value : String) -> GeneratedPropRole? {
  match value {
    "decoration" | "decor" => Some(Decoration)
    "blocking" | "blocker" => Some(Blocking)
    "pickup" | "loot" => Some(Pickup)
    _ => None
  }
}

///|
fn generated_prop_pickup_effect_from_string(
  value : String,
) -> GeneratedPropPickupEffect? {
  match value {
    "score" => Some(ScorePickup)
    "health" | "heal" => Some(HealthPickup)
    "equipment" | "equip" | "gear" => Some(EquipmentPickup)
    _ => None
  }
}

///|
fn generated_prop_item_rarity_from_string(value : String) -> @game.ItemRarity? {
  match value {
    "common" => Some(@game.Common)
    "uncommon" => Some(@game.Uncommon)
    "rare" => Some(@game.Rare)
    "epic" => Some(@game.Epic)
    _ => None
  }
}

///|
fn generated_prop_item_slot_from_string(value : String) -> @game.EquipSlot? {
  match value {
    "weapon" => Some(@game.Weapon)
    "armor" => Some(@game.Armor)
    "accessory" => Some(@game.Accessory)
    _ => None
  }
}

///|
fn generated_prop_role_is_solid(role : GeneratedPropRole) -> Bool {
  role == Blocking
}

///|
fn generated_prop_role_is_pickup(role : GeneratedPropRole) -> Bool {
  role == Pickup
}

///|
fn generated_prop_pickup_effect_seed(
  world : @game.GameWorld,
  placement : GeneratedPropPlacement,
) -> Int {
  let mut hash = world.seed * 131 + placement.floor * 17
  for ch in placement.source_path {
    hash = hash * 31 + ch.to_int()
  }
  hash = hash + (placement.x_offset_tiles * 10.0).to_int() * 7
  hash = hash + (placement.z_offset_tiles * 10.0).to_int() * 13
  hash
}

///|
fn generated_prop_item_rarity_multiplier(rarity : @game.ItemRarity) -> Int {
  match rarity {
    @game.Common => 1
    @game.Uncommon => 2
    @game.Rare => 3
    @game.Epic => 5
  }
}

///|
fn generated_prop_item_slot_name(slot : @game.EquipSlot) -> String {
  match slot {
    @game.Weapon => "Sword"
    @game.Armor => "Armor"
    @game.Accessory => "Ring"
  }
}

///|
fn generated_prop_item_slot_index(slot : @game.EquipSlot) -> Int {
  match slot {
    @game.Weapon => 0
    @game.Armor => 1
    @game.Accessory => 2
  }
}

///|
fn generated_prop_item_base_stats(
  slot : @game.EquipSlot,
  rarity : @game.ItemRarity,
  floor : Int,
) -> (Int, Int, Int) {
  let rarity_mult = generated_prop_item_rarity_multiplier(rarity)
  let base = 1 + floor / 3
  match slot {
    @game.Weapon => (base * rarity_mult, 0, 0)
    @game.Armor => (0, base * rarity_mult, base)
    @game.Accessory => (base, base, base * rarity_mult)
  }
}

///|
fn generated_prop_item_icon_id(seed : Int, slot : @game.EquipSlot) -> Int {
  let variant = (seed / 7).abs() % 3
  generated_prop_item_slot_index(slot) + variant
}

///|
fn build_generated_prop_equipment_item(
  world : @game.GameWorld,
  placement : GeneratedPropPlacement,
) -> @game.ItemData {
  let seed = generated_prop_pickup_effect_seed(world, placement)
  let item = @game.generate_item(seed, placement.floor)
  let rarity = match placement.pickup_rarity {
    Some(rarity) => rarity
    None => item.rarity
  }
  let slot = match placement.pickup_slot {
    Some(slot) => slot
    None => item.slot
  }
  let (atk_bonus, def_bonus, hp_bonus) = generated_prop_item_base_stats(
    slot,
    rarity,
    placement.floor,
  )
  {
    ..item,
    name: generated_prop_item_slot_name(slot),
    rarity,
    slot,
    atk_bonus,
    def_bonus,
    hp_bonus,
    icon_id: generated_prop_item_icon_id(seed, slot),
  }
}

///|
fn largest_non_start_room_index(world : @game.GameWorld) -> Int {
  let rooms = world.dungeon.rooms
  if rooms.length() <= 1 {
    return 0
  }
  let mut best_idx = 1
  let mut best_area = rooms[1].rect.w * rooms[1].rect.h
  for i = 2; i < rooms.length(); i = i + 1 {
    let area = rooms[i].rect.w * rooms[i].rect.h
    if area > best_area {
      best_idx = i
      best_area = area
    }
  }
  best_idx
}

///|
fn treasure_room_index(world : @game.GameWorld) -> Int {
  let rooms = world.dungeon.rooms
  if rooms.length() <= 1 {
    return 0
  }
  let mut best_idx = 1
  let mut best_dist_sq = -1.0
  for i = 1; i < rooms.length(); i = i + 1 {
    let center = rooms[i].rect.center()
    let cx = center.x.to_double() * tile_size + tile_size / 2.0
    let cy = center.y.to_double() * tile_size + tile_size / 2.0
    let dx = cx - world.dungeon.start_x
    let dy = cy - world.dungeon.start_y
    let dist_sq = dx * dx + dy * dy
    if dist_sq > best_dist_sq {
      best_idx = i
      best_dist_sq = dist_sq
    }
  }
  best_idx
}

///|
fn generated_prop_anchor_center_world(
  world : @game.GameWorld,
  anchor : GeneratedPropAnchor,
) -> (Double, Double) {
  match anchor {
    StartRoomCenter => (world.dungeon.start_x, world.dungeon.start_y)
    LargestNonStartRoomCenter => {
      let rooms = world.dungeon.rooms
      let best_idx = largest_non_start_room_index(world)
      let center = rooms[best_idx].rect.center()
      (
        center.x.to_double() * tile_size + tile_size / 2.0,
        center.y.to_double() * tile_size + tile_size / 2.0,
      )
    }
    BossRoomCenter =>
      generated_prop_anchor_center_world(world, LargestNonStartRoomCenter)
    TreasureRoomCenter => {
      let rooms = world.dungeon.rooms
      let best_idx = treasure_room_index(world)
      let center = rooms[best_idx].rect.center()
      (
        center.x.to_double() * tile_size + tile_size / 2.0,
        center.y.to_double() * tile_size + tile_size / 2.0,
      )
    }
  }
}

///|
fn generated_prop_world_xy(
  world : @game.GameWorld,
  placement : GeneratedPropPlacement,
) -> (Double, Double) {
  let (anchor_x, anchor_y) = generated_prop_anchor_center_world(
    world,
    placement.anchor,
  )
  (
    anchor_x + placement.x_offset_tiles * tile_size,
    anchor_y + placement.z_offset_tiles * tile_size,
  )
}

///|
fn generated_prop_blocking_radius(placement : GeneratedPropPlacement) -> Double {
  tile_size * 0.5 * placement.scale
}

///|
fn clone_generated_prop_collision_grid(
  grid : @terrain.Grid2D,
) -> @terrain.Grid2D {
  @physics2d.clone_terrain_grid(grid)
}

///|
fn append_generated_prop_blocking_walls(
  grid : @terrain.Grid2D,
  world : @game.GameWorld,
  placement : GeneratedPropPlacement,
) -> Unit {
  let (prop_x, prop_y) = generated_prop_world_xy(world, placement)
  @physics2d.append_circular_wall_blocker(
    grid,
    prop_x,
    prop_y,
    generated_prop_blocking_radius(placement),
    tile_size,
  )
}

///|
fn GameState::build_generated_prop_enemy_ai_grid(
  self : GameState,
) -> @terrain.Grid2D? {
  let mut has_blocker = false
  for prop in self.generated_props {
    if prop.placement.floor == self.world.floor &&
      generated_prop_role_is_solid(prop.placement.role) {
      has_blocker = true
      break
    }
  }
  if not(has_blocker) {
    return None
  }
  let grid = clone_generated_prop_collision_grid(self.world.dungeon.grid)
  for prop in self.generated_props {
    if prop.placement.floor == self.world.floor &&
      generated_prop_role_is_solid(prop.placement.role) {
      append_generated_prop_blocking_walls(grid, self.world, prop.placement)
    }
  }
  Some(grid)
}

///|
fn generated_prop_player_can_pickup(
  player_x : Double,
  player_y : Double,
  prop_x : Double,
  prop_y : Double,
) -> Bool {
  let dx = prop_x - player_x
  let dy = prop_y - player_y
  dx * dx + dy * dy < pickup_radius_sq
}

///|
fn resolve_generated_prop_actor_block(
  actor_x : Double,
  actor_y : Double,
  actor_size : Double,
  prop_x : Double,
  prop_y : Double,
  prop_radius : Double,
) -> (Double, Double)? {
  let dx = actor_x - prop_x
  let dy = actor_y - prop_y
  let min_dist = actor_size / 2.0 + prop_radius
  let dist_sq = dx * dx + dy * dy
  if dist_sq >= min_dist * min_dist {
    return None
  }
  if dist_sq <= 0.000001 {
    return Some((prop_x + min_dist, prop_y))
  }
  let dist = dist_sq.sqrt()
  let nx = dx / dist
  let ny = dy / dist
  Some((prop_x + nx * min_dist, prop_y + ny * min_dist))
}

///|
fn resolve_generated_prop_player_block(
  player_x : Double,
  player_y : Double,
  player_size : Double,
  prop_x : Double,
  prop_y : Double,
  prop_radius : Double,
) -> (Double, Double)? {
  resolve_generated_prop_actor_block(
    player_x, player_y, player_size, prop_x, prop_y, prop_radius,
  )
}

///|
fn build_generated_prop_scene_graph(
  world : @game.GameWorld,
  base_scene_graph : @scene3d.SceneGraph,
  placement : GeneratedPropPlacement,
) -> @scene3d.SceneGraph {
  let graph = base_scene_graph.clone_graph()
  let (world_x, world_y) = generated_prop_world_xy(world, placement)
  let ground_y = @game.get_tile_height(world.dungeon, world_x, world_y)
  let yaw = placement.yaw_degrees * @math.PI / 180.0
  graph.apply_root_transform(
    @transform3d.Transform3D::from_components(
      @math3d.Vec3::new(world_x / tile_size, ground_y, world_y / tile_size),
      @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), yaw),
      @math3d.Vec3::new(placement.scale, placement.scale, placement.scale),
    ),
  )
  graph
}

///|
fn GameState::set_generated_prop_asset(
  self : GameState,
  asset : GeneratedPropAsset,
  placement : GeneratedPropPlacement,
) -> Unit {
  self.generated_props.push({
    base_scene_graph: asset.scene_graph.clone_graph(),
    scene_graph: build_generated_prop_scene_graph(
      self.world,
      asset.scene_graph,
      placement,
    ),
    placement,
  })
}

///|
fn GameState::refresh_generated_props_for_current_floor(
  self : GameState,
) -> Unit {
  let refreshed : Array[GeneratedPropState] = []
  for prop in self.generated_props {
    if prop.placement.floor == self.world.floor {
      refreshed.push({
        ..prop,
        scene_graph: build_generated_prop_scene_graph(
          self.world,
          prop.base_scene_graph,
          prop.placement,
        ),
      })
    } else {
      refreshed.push(prop)
    }
  }
  self.generated_props = refreshed
}

///|
fn GameState::apply_generated_prop_roles_for_current_floor(
  self : GameState,
) -> Unit {
  let retained : Array[GeneratedPropState] = []
  let player_size = self.world.player.size
  let player_half = player_size / 2.0
  let mut player_x = self.world.player.x
  let mut player_y = self.world.player.y
  for prop in self.generated_props {
    if prop.placement.floor != self.world.floor {
      retained.push(prop)
      continue
    }
    let (prop_x, prop_y) = generated_prop_world_xy(self.world, prop.placement)
    if generated_prop_role_is_solid(prop.placement.role) {
      let prop_radius = generated_prop_blocking_radius(prop.placement)
      match
        resolve_generated_prop_actor_block(
          player_x, player_y, player_size, prop_x, prop_y, prop_radius,
        ) {
        Some((next_x, next_y)) => {
          let clamped_x = if next_x < player_half {
            player_half
          } else if next_x > world_w - player_half {
            world_w - player_half
          } else {
            next_x
          }
          let clamped_y = if next_y < player_half {
            player_half
          } else if next_y > world_h - player_half {
            world_h - player_half
          } else {
            next_y
          }
          if not(
              @game.check_wall_collision(
                self.world.dungeon.grid,
                clamped_x,
                player_y,
                player_size,
              ),
            ) {
            player_x = clamped_x
          }
          if not(
              @game.check_wall_collision(
                self.world.dungeon.grid,
                player_x,
                clamped_y,
                player_size,
              ),
            ) {
            player_y = clamped_y
          }
        }
        None => ()
      }
      for enemy in self.world.enemies {
        if not(enemy.alive) {
          continue
        }
        match
          resolve_generated_prop_actor_block(
            enemy.x,
            enemy.y,
            enemy.size,
            prop_x,
            prop_y,
            prop_radius,
          ) {
          Some((next_x, next_y)) => {
            if not(
                @game.check_wall_collision(
                  self.world.dungeon.grid,
                  next_x,
                  enemy.y,
                  enemy.size,
                ),
              ) {
              enemy.x = next_x
            }
            if not(
                @game.check_wall_collision(
                  self.world.dungeon.grid,
                  enemy.x,
                  next_y,
                  enemy.size,
                ),
              ) {
              enemy.y = next_y
            }
          }
          None => ()
        }
      }
      retained.push(prop)
      continue
    }
    if generated_prop_role_is_pickup(prop.placement.role) &&
      generated_prop_player_can_pickup(player_x, player_y, prop_x, prop_y) {
      match prop.placement.pickup_effect {
        ScorePickup => {
          self.world.score = self.world.score + 5
          spawn_item_pickup(self.particle_manager, prop_x, prop_y, false)
        }
        HealthPickup => {
          let healed = self.world.player.hp + 2
          self.world.player.hp = if healed > self.world.player_stats.max_hp {
            self.world.player_stats.max_hp
          } else {
            healed
          }
          spawn_item_pickup(self.particle_manager, prop_x, prop_y, true)
        }
        EquipmentPickup => {
          let item = build_generated_prop_equipment_item(
            self.world,
            prop.placement,
          )
          if not(self.world.collect_equipment_pickup(item)) {
            retained.push(prop)
            continue
          }
          spawn_item_pickup(self.particle_manager, prop_x, prop_y, false)
        }
      }
      continue
    }
    retained.push(prop)
  }
  self.world.player.x = player_x
  self.world.player.y = player_y
  self.generated_props = retained
}

///|
fn GameState::append_generated_prop_draw_commands(
  self : GameState,
  camera : @camera3d.Camera3D,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  for prop in self.generated_props {
    if prop.placement.floor != self.world.floor {
      continue
    }
    let prop_cmds = @scene3d.render_scene3d_graph_gpu(
      prop.scene_graph,
      camera,
      lighting=self.lighting,
      dst,
      self.shader3d,
      screen_w,
      screen_h,
      shader3d_textured=Some(self.shader3d_textured),
      shader3d_pbr=Some(self.shader3d_pbr),
      shader3d_pbr_textured=Some(self.shader3d_pbr_textured),
    )
    for cmd in prop_cmds {
      cmds.push(cmd)
    }
  }
}
