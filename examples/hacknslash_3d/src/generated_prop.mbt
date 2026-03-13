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
  role? : GeneratedPropRole = @interactable2d.Decoration,
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
  @interactable2d.interactable_anchor_from_string(value)
}

///|
fn generated_prop_role_from_string(value : String) -> GeneratedPropRole? {
  @interactable2d.interactable_role_from_string(value)
}

///|
fn generated_prop_pickup_effect_from_string(
  value : String,
) -> GeneratedPropPickupEffect? {
  @interactable2d.interactable_pickup_effect_from_string(value)
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
  @interactable2d.interactable_role_is_solid(role)
}

///|
fn generated_prop_role_is_pickup(role : GeneratedPropRole) -> Bool {
  @interactable2d.interactable_role_is_pickup(role)
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

fn generated_prop_anchor_candidates(
  world : @game.GameWorld,
) -> Array[@interactable2d.AnchorCandidate] {
  let candidates : Array[@interactable2d.AnchorCandidate] = []
  for i = 0; i < world.dungeon.rooms.length(); i = i + 1 {
    let room = world.dungeon.rooms[i]
    let center = room.rect.center()
    candidates.push(
      @interactable2d.AnchorCandidate::new(
        center.x.to_double() * tile_size + tile_size / 2.0,
        center.y.to_double() * tile_size + tile_size / 2.0,
        room.rect.w * room.rect.h,
        i == 0,
      ),
    )
  }
  candidates
}

///|
fn generated_prop_anchor_center_world(
  world : @game.GameWorld,
  anchor : GeneratedPropAnchor,
) -> (Double, Double) {
  @interactable2d.resolve_anchor_position(
    generated_prop_anchor_candidates(world),
    anchor,
    world.dungeon.start_x,
    world.dungeon.start_y,
  )
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
fn generated_prop_floor_interactables(
  world : @game.GameWorld,
  props : Array[GeneratedPropState],
) -> Array[@interactable2d.CircularInteractable] {
  let interactables : Array[@interactable2d.CircularInteractable] = []
  for prop in props {
    if prop.placement.floor != world.floor {
      continue
    }
    let (prop_x, prop_y) = generated_prop_world_xy(world, prop.placement)
    interactables.push(
      generated_prop_interactable(prop_x, prop_y, prop.placement),
    )
  }
  interactables
}

///|
fn GameState::build_generated_prop_enemy_ai_grid(
  self : GameState,
) -> @terrain.Grid2D? {
  let floor_interactables = generated_prop_floor_interactables(
    self.world,
    self.generated_props,
  )
  let mut has_blocker = false
  for interactable in floor_interactables {
    if @interactable2d.interactable_role_is_solid(interactable.role) {
      has_blocker = true
      break
    }
  }
  if not(has_blocker) {
    return None
  }
  let grid = clone_generated_prop_collision_grid(self.world.dungeon.grid)
  @interactable2d.append_circular_interactable_blockers_to_grid(
    grid,
    floor_interactables,
    tile_size,
  )
  Some(grid)
}

///|
fn generated_prop_interactable(
  prop_x : Double,
  prop_y : Double,
  placement : GeneratedPropPlacement,
) -> @interactable2d.CircularInteractable {
  @interactable2d.CircularInteractable::new(
    prop_x,
    prop_y,
    generated_prop_blocking_radius(placement),
    placement.role,
  )
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
  @interactable2d.resolve_circular_interactable_block(
    actor_x,
    actor_y,
    actor_size,
    prop_x,
    prop_y,
    prop_radius,
  )
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
  let pickup_rewards = @gameplay2d.PickupRewardConfig::new(
    score_amount=5,
    heal_amount=2,
  )
  let player_size = self.world.player.size
  let player_half = player_size / 2.0
  let mut player_x = self.world.player.x
  let mut player_y = self.world.player.y
  let floor_interactables = generated_prop_floor_interactables(
    self.world,
    self.generated_props,
  )
  let player_frame = @interactable2d.resolve_circular_interactable_frame(
    floor_interactables,
    player_x,
    player_y,
    player_size,
    pickup_radius_sq,
    fn(next_x, next_y, size) {
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
      next_x == clamped_x &&
      next_y == clamped_y &&
      not(@game.check_wall_collision(self.world.dungeon.grid, clamped_x, clamped_y, size))
    },
  )
  player_x = player_frame.actor_x
  player_y = player_frame.actor_y
  for enemy in self.world.enemies {
    if not(enemy.alive) {
      continue
    }
    let (resolved_enemy_x, resolved_enemy_y) = @interactable2d.resolve_circular_blockers_for_actor(
      floor_interactables,
      enemy.x,
      enemy.y,
      enemy.size,
      fn(next_x, next_y, size) {
        not(@game.check_wall_collision(self.world.dungeon.grid, next_x, next_y, size))
      },
    )
    enemy.x = resolved_enemy_x
    enemy.y = resolved_enemy_y
  }
  let mut floor_index = 0
  for prop in self.generated_props {
    if prop.placement.floor != self.world.floor {
      retained.push(prop)
      continue
    }
    let prop_floor_index = floor_index
    floor_index = floor_index + 1
    if generated_prop_role_is_solid(prop.placement.role) {
      retained.push(prop)
      continue
    }
    let (prop_x, prop_y) = generated_prop_world_xy(self.world, prop.placement)
    let interacted = match player_frame.pickup_contact_index {
      Some(contact_index) => contact_index == prop_floor_index
      None => false
    }
    if generated_prop_role_is_pickup(prop.placement.role) && interacted {
      match @gameplay2d.apply_builtin_pickup_effect(
        prop.placement.pickup_effect,
        self.world.player.hp,
        self.world.player_stats.max_hp,
        pickup_rewards,
      ) {
        Some((next_hp, score_delta, heal_feedback)) => {
          self.world.player.hp = next_hp
          self.world.score = self.world.score + score_delta
          spawn_item_pickup(self.particle_manager, prop_x, prop_y, heal_feedback)
        }
        None => {
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
