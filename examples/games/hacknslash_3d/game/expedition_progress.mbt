///|
pub fn GameWorld::near_expedition_anchor(self : GameWorld) -> Bool {
  if self.near_waypoint() {
    return true
  }
  guard self.atlas is Some(atlas) else { return false }
  if atlas.generator_version < 2 {
    return false
  }
  self.chests.any(c => {
    c.opened &&
    ({
      let dx = c.x - self.player.x
      let dy = c.y + tile_size - self.player.y
      dx * dx + dy * dy <= tile_size * tile_size * 9.0
    })
  })
}

///|
pub fn GameWorld::travel_to_expedition_site(self : GameWorld, id : Int) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if atlas.generator_version < 2 ||
    self.mode != Playing ||
    self.ui_mode != Waypoints ||
    !self.near_expedition_anchor() ||
    self.hunter_action_locked() ||
    self.weapon_attack is Some(_) ||
    self.player_charge is Some(_) ||
    self.player.dash_timer > 0 ||
    id < -1 ||
    id >= self.chests.length() {
    return false
  }
  let (tx, ty) = if id == -1 {
    world_waypoint_position(atlas.current)
  } else {
    let chest = self.chests[id]
    if !chest.opened {
      return false
    }
    (chest.x, chest.y + tile_size * 1.5)
  }
  let (x, y) = hunting_safe_position(self.dungeon, tx, ty, self.player.size)
  self.player.x = x
  self.player.y = y
  self.player.iframe_timer = self.player.iframe_timer.max(60)
  self.cancel_hunter_action()
  self.projectiles.clear()
  self.telegraph_markers = []
  self.summons.clear()
  self.auto_nav_target = None
  self.auto_nav_path = []
  self.ui_mode = UIMode::None
  atlas.revision += 1
  true
}
