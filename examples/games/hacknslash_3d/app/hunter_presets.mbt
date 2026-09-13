///|
// Web adapters already resolve physical slots to action commands. Native input
// reaches the app directly and needs the same preset lookup before edge tracking.
fn GameState::resolve_hunter_hotbar(
  self : GameState,
  input : @core.InputSnapshot,
) -> @core.InputSnapshot {
  if hunter_web_enabled() ||
    !self.world.hunting_grounds ||
    self.world.mode != @game.Playing ||
    self.paused ||
    self.world.ui_mode != @game.UIMode::None {
    return input
  }
  let slots = self.world.hunter_preset.profile().keys
  @core.new_input_snapshot_full(
    input.cursor_x,
    input.cursor_y,
    input.wheel_x,
    input.wheel_y,
    input.pressed_keys.map(key => {
      if key >= 49 && key <= 52 {
        slots[key - 49]
      } else {
        key
      }
    }),
    input.pressed_mouse_buttons,
    input.touches,
    input.gamepads,
  )
}

///|
fn GameState::hunter_preset_skills(self : GameState) -> Array[HunterSkillView] {
  let w = self.world
  w.hunter_preset.profile().keys.map(key => {
    if key == 84 {
      return HunterSkillView::{
        key,
        glyph: "lightning",
        hold: "",
        name: "星落とし",
        level: 1,
        description: "位置を指定し、円の中に落雷を起こす。決定で発動、取消で照準を戻す。",
        remaining: w.arts.ground_cooldown,
        total: @game.ground_strike_cooldown,
      }
    }
    let (id, remaining, total, description) = match key {
      50 =>
        (
          @game.Whirlwind,
          w.attack_timer,
          @game.whirlwind_recovery_frames,
          "長押しで回転しながら移動。全武器対応、離すと停止。",
        )
      51 =>
        (
          @game.SplittingFireball,
          w.splitting_fireball_cooldown_timer,
          w.params.splitting_fireball_cooldown_frames(),
          "前方の敵を緩く追う火弾。命中後に分裂した弾も追尾する。",
        )
      52 =>
        (
          @game.IceNova,
          w.ice_nova_cooldown_timer,
          w.params.ice_nova_cooldown_frames(),
          "自分を中心に冷気を放つ範囲攻撃。",
        )
      53 =>
        (
          @game.ChainLightning,
          w.chain_lightning_cooldown_timer,
          w.params.chain_lightning_cooldown_frames(),
          "チェインライトニング。近くの敵から次の敵へ雷を連鎖させる。",
        )
      54 =>
        (
          @game.HomingMissile,
          w.homing_missile_cooldown_timer,
          w.params.homing_missile_cooldown_frames(),
          "敵を追い続ける呪弾を放つ。",
        )
      _ =>
        (
          @game.PowerStrike,
          w.attack_timer,
          w.params.attack_cooldown.to_int(),
          "周囲を強く斬る。通常攻撃と待ち時間を共有。",
        )
    }
    {
      key,
      glyph: hunter_skill_glyph(id),
      hold: if key == 50 {
        "whirlwind"
      } else {
        ""
      },
      name: hunter_skill_name(id),
      description,
      level: w.skills.get_level(id),
      remaining: remaining.max(0),
      total,
    }
  })
}

///|
fn GameState::handle_hunter_preset_input(self : GameState) -> Bool {
  if !self.paused ||
    self.world.ui_mode != @game.UIMode::None ||
    self.camera_settings.editing ||
    self.terrain_lab.editing ||
    !@inpututil.is_key_just_pressed(self.input.key_state, 76) {
    return false
  }
  let index = hunter_web_selection()
  if index >= 0 && index < @game.hunter_presets.length() {
    let preset = @game.hunter_preset_from_id(@game.hunter_presets[index].id).unwrap()
    if self.world.apply_hunter_preset(preset) {
      self.sync_character_equipment()
      self.save_game()
    }
  }
  true
}
