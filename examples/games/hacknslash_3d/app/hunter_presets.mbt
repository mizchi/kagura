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
  let slots = self.world.hunter_slots
  let keys = input.pressed_keys.map(key => {
    if key >= 49 && key <= 52 {
      slots[key - 49]
    } else {
      key
    }
  })
  for button in input.pressed_mouse_buttons {
    let slot = match button {
      0 => 0
      2 => 1
      _ => -1
    }
    if !self.ground_targeting && slot >= 0 && !keys.contains(slots[slot]) {
      keys.push(slots[slot])
    }
  }
  @core.new_input_snapshot_full(
    input.cursor_x,
    input.cursor_y,
    input.wheel_x,
    input.wheel_y,
    keys,
    input.pressed_mouse_buttons,
    input.touches,
    input.gamepads,
  )
}

///|
fn GameState::hunter_preset_skills(self : GameState) -> Array[HunterSkillView] {
  self.world.hunter_slots.map(key => self.hunter_action_view(key))
}

///|
fn GameState::hunter_action_view(
  self : GameState,
  key : Int,
) -> HunterSkillView {
  let w = self.world
  if key == 74 || key == 70 || key == 86 {
    let (name, glyph, hold, description, remaining, total) = match key {
      74 =>
        (
          "通常攻撃",
          "blade",
          "attack",
          "装備中の武器で攻撃。長押しで連続攻撃。鉈は3連撃。",
          w.attack_timer,
          w.params.attack_cooldown.to_int(),
        )
      70 =>
        (
          "盾ガード",
          "shield",
          "guard",
          "長押しで盾を構える。正面の攻撃を軽減し、構え始めは完全防御。",
          w.arts.guard_recovery,
          90,
        )
      _ =>
        (
          "突進斬り",
          "dodge",
          "",
          "前方へ突進し、敵の手前で止まって斬る。壁で停止、回避で中断。全武器対応。",
          w.arts.dash_cooldown,
          @game.dash_strike_cooldown,
        )
    }
    return {
      key,
      name,
      glyph,
      hold,
      description,
      remaining: remaining.max(0),
      total,
      level: 1,
    }
  }
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
    48 =>
      (
        @game.RaiseZombie,
        w.summons.zombie_cooldown,
        @game.summoned_zombie_cooldown,
        "敵を引きつける味方ゾンビを召喚。最大2体。倒れるまで同行、上限時は古い1体を再召喚。",
      )
    57 =>
      (
        @game.SummonFlamingSkull,
        w.summons.skull_cooldown,
        @game.flaming_skull_cooldown,
        "6秒間、敵と地形をすり抜けて追尾・攻撃する炎の頭蓋。最大8体。長押しで連続召喚。",
      )
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
        @game.Counter,
        w.player.counter_cooldown_timer,
        @game.counter_cooldown_for_level(w.skills.get_level(@game.Counter)),
        "短時間、無敵の構えを取り、敵の弾を反射する。",
      )
  }
  {
    key,
    glyph: hunter_skill_glyph(id),
    hold: if key == 57 {
      "skull"
    } else if key == 50 {
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

///|
fn GameState::handle_hunter_slot_input(self : GameState) -> Bool {
  for slot in 0..<4 {
    if @inpututil.is_key_just_pressed(self.input.key_state, 200 + slot) {
      if self.world.assign_hunter_slot(slot, hunter_web_selection()) {
        self.save_game()
      }
      return true
    }
  }
  false
}
