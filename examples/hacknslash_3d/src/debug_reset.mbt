///|
let key_r : Int = 82

///|
fn debug_reset_button_rect(
  mode : @game.GameMode,
  screen_w : Double,
  screen_h : Double,
) -> (Double, Double, Double, Double)? {
  let width = 184.0
  let height = 28.0
  let x = screen_w / 2.0 - width / 2.0
  let y = match mode {
    @game.Title => screen_h / 2.0 + 84.0
    @game.GameOver => screen_h / 2.0 + 116.0
    _ => return None
  }
  Some((x, y, width, height))
}

///|
fn point_in_rect(
  x : Double,
  y : Double,
  rect_x : Double,
  rect_y : Double,
  rect_w : Double,
  rect_h : Double,
) -> Bool {
  x >= rect_x && x <= rect_x + rect_w && y >= rect_y && y <= rect_y + rect_h
}

///|
fn input_snapshot_requests_debug_reset(
  input : @core.InputSnapshot,
  mode : @game.GameMode,
) -> Bool {
  match mode {
    @game.Title | @game.GameOver => ()
    _ => return false
  }
  for key in input.pressed_keys {
    if key == key_r {
      return true
    }
  }
  let mut left_mouse_pressed = false
  for button in input.pressed_mouse_buttons {
    if button == 0 {
      left_mouse_pressed = true
      break
    }
  }
  if not(left_mouse_pressed) {
    return false
  }
  match
    debug_reset_button_rect(mode, screen_w.to_double(), screen_h.to_double()) {
    Some((x, y, w, h)) =>
      point_in_rect(input.cursor_x, input.cursor_y, x, y, w, h)
    None => false
  }
}

///|
fn GameState::draw_debug_reset_button(
  self : GameState,
  ctx : @hud.HudContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
  mode : @game.GameMode,
) -> Unit {
  match debug_reset_button_rect(mode, ctx.screen_w, ctx.screen_h) {
    Some((x, y, w, h)) => {
      ctx.draw_rect(cmds, x, y, w, h, @hud.hex_color(0x101014, alpha=0.78))
      ctx.draw_rect(
        cmds,
        x + 2.0,
        y + 2.0,
        w - 4.0,
        h - 4.0,
        @hud.hex_color(0x662222, alpha=0.92),
      )
      ctx.draw_text_centered(
        cmds,
        "RESET SAVE (R)",
        14.0,
        x + w / 2.0,
        y + h / 2.0,
        0xFFF0F0,
      )
    }
    None => ()
  }
}

///|
fn GameState::reset_save_and_restart(self : GameState) -> Unit {
  let auto_play = self.world.auto_play
  self.delete_save()
  self.world.mode = @game.Playing
  self.world.frame_count = 0
  self.world.floor = 1
  self.world.score = 0
  self.world.seed = 42
  self.world.apply_dungeon(self.world.seed, 1)
  self.world.attack_timer = 0
  self.world.screen_flash = 0
  self.world.floor_announce_timer = 0
  self.world.chain_lightning_cooldown_timer = 0
  self.world.homing_missile_cooldown_timer = 0
  self.world.splitting_fireball_cooldown_timer = 0
  self.world.ice_nova_cooldown_timer = 0
  self.world.player.damage_timer = 0
  self.world.player.iframe_timer = 0
  self.world.player.facing_angle = @math.PI / 2.0
  self.world.player.dash_timer = 0
  self.world.player.dash_cooldown_timer = 0
  self.world.player.dash_vx = 0.0
  self.world.player.dash_vy = 0.0
  self.world.ui_mode = @game.UIMode::None
  self.world.ui_cursor = 0
  for i in 0..<self.world.inventory.capacity {
    self.world.inventory.items[i] = None
  }
  self.world.equipment.weapon = None
  self.world.equipment.armor = None
  self.world.equipment.accessory = None
  for node in self.world.skills.nodes {
    node.level = 0
  }
  self.world.skills.skill_points = 0
  self.world.level_progress = @game.LevelProgression::new(
    config=self.world.params.levelup_config(),
  )
  self.world.player_stats = @game.compute_player_stats(
    self.world.equipment,
    self.world.skills,
    base_hp=self.world.params.player_base_hp.to_int(),
  )
  self.world.player.hp = self.world.player_stats.max_hp
  self.world.events = []
  self.active_effects.clear()
  self.particle_manager.emitters.clear()
  self.particle_manager.vertex_scratch.clear()
  self.particle_manager.index_scratch.clear()
  self.entity_instance_scratch.item_instances.clear()
  self.entity_instance_scratch.enemy_projectile_instances.clear()
  self.entity_instance_scratch.arrow_instances.clear()
  self.entity_instance_scratch.fireball_instances.clear()
  self.entity_instance_scratch.homing_missile_instances.clear()
  self.audio_last_played_cue = ""
  self.audio_last_played_state = ""
  self.profile = @debugutil.default_frame_profile()
  self.world.auto_play = auto_play
  self.invalidate_hud_static_cache()
  self.rebuild_dungeon_rendering()
}
