///|
/// Manual interaction reaches two tiles; walking still collects at the smaller pickup radius.
pub let manual_pickup_radius : Double = 32.0

///|
fn GameWorld::allocate_pickup_id(self : GameWorld) -> Int {
  let id = self.next_pickup_id
  self.next_pickup_id += 1
  id
}

///|
pub fn GameWorld::loot_in_reach(self : GameWorld, item : ItemDrop) -> Bool {
  let dx = item.x - self.player.x
  let dy = item.y - self.player.y
  item.alive &&
  dx * dx + dy * dy <= manual_pickup_radius * manual_pickup_radius &&
  !enemy_direct_chase_path_blocked(
    self.dungeon.grid,
    self.player.x,
    self.player.y,
    item.x,
    item.y,
    2.0,
  )
}

///|
pub fn GameWorld::nearest_pickup_id(self : GameWorld) -> Int? {
  let mut nearest : Int? = None
  let mut distance = manual_pickup_radius * manual_pickup_radius + 1.0
  for item in self.items {
    if item.pickup_id is Some(id) {
      let dx = item.x - self.player.x
      let dy = item.y - self.player.y
      let d = dx * dx + dy * dy
      if d < distance && self.loot_in_reach(item) {
        nearest = Some(id)
        distance = d
      }
    }
  }
  nearest
}

///|
/// Zero selects the nearest reachable item; positive IDs select exactly that drop.
pub fn GameWorld::pickup_item(self : GameWorld, id : Int) -> Bool {
  if self.mode != Playing ||
    self.ui_mode != UIMode::None ||
    self.player.hp <= 0 ||
    id < 0 {
    return false
  }
  let id = if id == 0 { self.nearest_pickup_id().or(-1) } else { id }
  for item in self.items {
    if item.pickup_id == Some(id) && self.loot_in_reach(item) {
      // Explicit intent overrides the automatic pickup block on a freshly discarded item.
      return self.collect_ground_drop(item)
    }
  }
  false
}

///|
fn GameWorld::collect_ground_drop(self : GameWorld, item : ItemDrop) -> Bool {
  if !item.alive {
    return false
  }
  match item.kind {
    Health => {
      let rewards = @gameplay2d.PickupRewardConfig::new(
        score_amount=5,
        heal_amount=2,
      )
      match
        @gameplay2d.apply_builtin_pickup(
          HealthPickup,
          self.player.hp,
          self.player_stats.max_hp,
          self.score,
          rewards,
        ) {
        Some(application) => {
          item.alive = false
          self.events.push(
            ItemPickup(item.x, item.y, application.heal_feedback),
          )
          self.player.hp = application.next_hp
          self.score = application.next_score
          self.push_item_log("+Health", 0x44DD44)
        }
        None => abort("health pickup should always resolve")
      }
    }
    Score => {
      let rewards = @gameplay2d.PickupRewardConfig::new(
        score_amount=5,
        heal_amount=2,
      )
      match
        @gameplay2d.apply_builtin_pickup(
          ScorePickup,
          self.player.hp,
          self.player_stats.max_hp,
          self.score,
          rewards,
        ) {
        Some(application) => {
          item.alive = false
          self.events.push(
            ItemPickup(item.x, item.y, application.heal_feedback),
          )
          self.player.hp = application.next_hp
          self.score = application.next_score
          self.push_item_log("+Score", 0xDDDD44)
        }
        None => abort("score pickup should always resolve")
      }
    }
    Equipment(data) =>
      if self.collect_equipment_pickup(data) {
        item.alive = false
        self.events.push(ItemPickup(item.x, item.y, false))
        self.push_item_log(data.name, data.rarity.color())
      }
  }
  !item.alive
}
