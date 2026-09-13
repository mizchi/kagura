///|
pub(all) struct TreasureChest {
  id : Int
  site : Int
  x : Double
  y : Double
  mut opened : Bool
  mut opened_frame : Int
}

///|
pub fn hunting_chests() -> Array[TreasureChest] {
  hunting_sites.map(site => {
    id: site.id,
    site: site.id,
    x: (site.x.to_double() + 2.5) * tile_size,
    y: (site.z.to_double() - 0.5) * tile_size,
    opened: false,
    opened_frame: -60,
  })
}

///|
pub fn GameWorld::nearby_chest(self : GameWorld) -> TreasureChest? {
  let mut nearest : TreasureChest? = None
  let mut best = tile_size * tile_size * 3.0
  for chest in self.chests {
    if chest.opened {
      continue
    }
    let dx = chest.x - self.player.x
    let dy = chest.y + tile_size - self.player.y
    let dist = dx * dx + dy * dy
    if dist < best &&
      !enemy_direct_chase_path_blocked(
        self.dungeon.grid,
        self.player.x,
        self.player.y,
        chest.x,
        chest.y + tile_size,
        1.0,
      ) {
      nearest = Some(chest)
      best = dist
    }
  }
  nearest
}

///|
pub fn GameWorld::open_nearby_chest(self : GameWorld) -> Bool {
  if self.mode != Playing ||
    self.ui_mode != UIMode::None ||
    self.hunter_action_locked() ||
    self.weapon_attack is Some(_) ||
    self.player.dash_timer > 0 ||
    self.player_charge is Some(_) {
    return false
  }
  guard self.nearby_chest() is Some(chest) else { return false }
  chest.opened = true
  chest.opened_frame = self.frame_count
  for i in 0..<2 {
    let seed = hunting_hash(chest.id * 37 + i, self.floor * 97, self.seed)
    let rarity = if hunting_sites[chest.site].kind == Ruins {
      Rare
    } else {
      Uncommon
    }
    let base = generate_item_with_profile_and_drop_config(
      seed,
      self.floor + 1,
      self.params.get_affix_profile(),
      self.params.drop_table_config(),
      rarity~,
    )
    let item = hunter_drop_variant(base, seed)
    spawn_scatter_item(
      self,
      chest.x,
      chest.y + 10.0,
      Equipment(item),
      if i == 0 {
        0.4
      } else {
        @math.PI - 0.4
      },
      0.8,
    )
  }
  spawn_scatter_item(self, chest.x, chest.y + 10.0, Health, @math.PI / 2.0, 0.6)
  self.events.push(ChestOpened(chest.x, chest.y))
  self.push_item_log("宝箱を開けた", 0xE2BF75)
  true
}

///|
fn stamp_hunting_chests(grid : @terrain.Grid2D) -> Unit {
  for chest in hunting_chests() {
    grid.set(
      (chest.x / tile_size).to_int(),
      (chest.y / tile_size).to_int(),
      @terrain.Wall,
    )
  }
}
