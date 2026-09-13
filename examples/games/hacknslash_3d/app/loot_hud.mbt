// Projected, read-only ground loot. Keep the web overlay bounded independently of world size.

///|
struct HunterLootView {
  id : Int
  reachable : Bool
  nearest : Bool
  x : Double
  y : Double
  name : String
  rarity : String
  blocked : Bool
} derive(ToJson)

///|
fn rarity_name(rarity : @game.ItemRarity) -> String {
  match rarity {
    Common => "common"
    Uncommon => "uncommon"
    Rare => "rare"
    Epic => "epic"
  }
}

///|
fn GameState::hunter_loot_view(self : GameState) -> Array[HunterLootView] {
  let labels : Array[HunterLootView] = []
  if self.world.mode != @game.Playing {
    return labels
  }
  let nearest = self.world.nearest_pickup_id()
  let camera = self.camera.to_camera3d()
  for item in self.world.items {
    if !item.alive {
      continue
    }
    let position = @math3d.Vec3::new(
      item.x / tile_size,
      @game.get_tile_height(self.world.dungeon, item.x, item.y) + 1.05,
      item.y / tile_size,
    )
    if project_world_label_position(camera, position, 100.0, 100.0)
      is Some((x, y)) {
      labels.push({
        id: item.pickup_id.or(0),
        reachable: self.world.loot_in_reach(item),
        nearest: item.pickup_id is Some(_) && item.pickup_id == nearest,
        x,
        y,
        name: item_drop_label_text(item.kind),
        rarity: match item.kind {
          Equipment(data) => rarity_name(data.rarity)
          Health => "health"
          Score => "gold"
        },
        blocked: item.pickup_blocked.or(false),
      })
      if labels.length() >= 32 {
        break
      }
    }
  }
  labels
}

///|
let key_pickup_item : Int = 204

///|
fn GameState::apply_loot_pickup(self : GameState, id : Int) -> Bool {
  if self.paused ||
    self.ground_targeting ||
    self.camera_settings.editing ||
    self.terrain_lab.editing ||
    self.motion_preview {
    return false
  }
  if !self.world.pickup_item(id) {
    return false
  }
  self.sync_character_equipment()
  self.save_game()
  true
}
