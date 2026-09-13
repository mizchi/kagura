///|
/// Pause keeps the underlying screen (including a pending level-up choice).
fn GameState::set_paused(self : GameState, paused : Bool) -> Unit {
  if self.paused == paused {
    return
  }
  self.paused = paused
  if paused {
    self.world.stop_whirlwind()
    self.ground_targeting = false
    self.pause_return_ui = self.world.ui_mode
    self.pause_return_cursor = self.world.ui_cursor
    self.world.ui_mode = @game.UIMode::None
  } else {
    self.camera_settings.editing = false
    self.terrain_lab.editing = false
    self.world.ui_mode = self.pause_return_ui
    self.world.ui_cursor = self.pause_return_cursor
    self.pause_return_ui = @game.UIMode::None
    self.pause_return_cursor = 0
  }
  self.audio_bank.set_paused(paused)
}

///|
/// Handle navigation before clocks, cameras or gameplay can advance.
fn GameState::handle_pause_input(self : GameState) -> Bool {
  if self.world.mode != @game.Playing {
    return false
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 78) &&
    self.world.atlas is Some(_) &&
    self.world.authored_scene is None {
    if !self.paused {
      self.set_paused(true)
    }
    self.world.ui_mode = @game.UIMode::None
    self.camera_settings.editing = false
    self.terrain_lab.editing = !self.terrain_lab.editing
    return true
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 79) {
    if !self.paused {
      self.set_paused(true)
    }
    self.world.ui_mode = @game.UIMode::None
    self.terrain_lab.editing = false
    self.camera_settings.editing = !self.camera_settings.editing
    return true
  }
  let escape = @inpututil.is_key_just_pressed(self.input.key_state, key_escape)
  if escape && self.ground_targeting {
    self.ground_targeting = false
    return true
  }
  let legacy = @inpututil.is_key_just_pressed(self.input.key_state, key_p)
  if escape && self.terrain_lab.editing {
    self.terrain_lab.editing = false
    return true
  }
  if escape && self.camera_settings.editing {
    self.camera_settings.editing = false
    return true
  }
  let confirm = self.paused &&
    self.world.ui_mode == @game.UIMode::None &&
    !hunter_web_enabled() &&
    @inpututil.is_key_just_pressed(self.input.key_state, 13)
  if (escape || legacy) && self.world.atlas is Some(atlas) {
    atlas.travel_target = None
  }
  if !escape && !legacy && !confirm {
    return false
  }
  if legacy && self.motion_preview && !self.paused {
    self.motion_preview = false
  } else if self.paused {
    if escape && self.world.ui_mode != @game.UIMode::None {
      self.world.ui_mode = @game.UIMode::None
    } else {
      self.set_paused(false)
    }
  } else if escape &&
    (
      self.world.ui_mode == @game.Inventory ||
      self.world.ui_mode == @game.Skills ||
      self.world.ui_mode == @game.Waypoints
    ) {
    self.world.ui_mode = @game.UIMode::None
  } else {
    self.set_paused(true)
  }
  true
}

///|
/// Native rendering uses the same navigation and pause state as the web menu.
fn GameState::draw_pause_menu(
  self : GameState,
  ctx : @engine.EngineContext,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let hud = self.make_hud_ctx(ctx.dst, ctx.shader)
  let w = screen_w.to_double()
  let h = screen_h.to_double()
  hud.draw_rect(cmds, 0.0, 0.0, w, h, @hud.hex_color(0x05110D, alpha=0.78))
  hud.draw_rect(
    cmds,
    w / 2.0 - 170.0,
    h / 2.0 - 122.0,
    340.0,
    244.0,
    @hud.hex_color(0x15241C),
  )
  hud.draw_text_centered(
    cmds,
    "PAUSED",
    25.0,
    w / 2.0,
    h / 2.0 - 80.0,
    0xE6C999,
  )
  for
    i, line in [
      "ESC / ENTER   RESUME",
      "I   INVENTORY",
      "K   SKILLS",
      if self.audio_bank.is_muted() {
        "M   SOUND OFF"
      } else {
        "M   SOUND ON"
      },
    ] {
    hud.draw_text_centered(
      cmds,
      line,
      15.0,
      w / 2.0,
      h / 2.0 - 30.0 + i.to_double() * 32.0,
      0xDFDCCB,
    )
  }
}
