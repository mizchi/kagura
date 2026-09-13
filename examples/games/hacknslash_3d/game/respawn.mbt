///|
/// Restore the hunter at the checkpoint while keeping all durable world progress.
pub fn GameWorld::respawn_at_waypoint(self : GameWorld) -> Bool {
  if self.mode != GameOver {
    return false
  }
  if self.atlas is Some(atlas) {
    let id = atlas.last_waypoint
    let (x, y) = world_waypoint_position(id)
    if !self.prepare_region(id) || !self.enter_region(id, x, y) {
      return false
    }
  } else {
    self.player.x = self.dungeon.start_x
    self.player.y = self.dungeon.start_y
  }
  self.cancel_hunter_action()
  self.arts.strike = None
  self.arts.guard_energy = 100.0
  self.arts.guard_recovery = 0
  self.arts.ground_cooldown = 0
  self.arts.dash_cooldown = 0
  self.weapon_attack = None
  self.player_charge = None
  self.reset_cleaver_combo()
  self.attack_timer = 0
  self.charge_cooldown = 0
  self.chain_lightning_cooldown_timer = 0
  self.homing_missile_cooldown_timer = 0
  self.splitting_fireball_cooldown_timer = 0
  self.ice_nova_cooldown_timer = 0
  self.player.damage_timer = 0
  self.player.dash_timer = 0
  self.player.dash_cooldown_timer = 0
  self.player.dash_vx = 0.0
  self.player.dash_vy = 0.0
  self.player.counter_timer = 0
  self.player.counter_cooldown_timer = 0
  self.refresh_player_stats()
  self.player.hp = self.player_stats.max_hp
  self.player.iframe_timer = 120
  self.projectiles = []
  self.telegraph_markers = []
  self.events = []
  self.screen_flash = 0.0
  self.ui_mode = UIMode::None
  self.mode = Playing
  self.open_levelup_ui_if_needed()
  true
}
