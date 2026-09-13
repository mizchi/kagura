///|
let save_slot_count : Int = 3

///|
struct SaveSlotView {
  slot : Int
  status : String
  level : Int
  score : Int
  archetype : String
  region : String
} derive(ToJson)

///|
fn save_slot_key(slot : Int) -> String {
  // Keep the existing save in slot 1 without copying or deleting it.
  if slot == 0 { "hacknslash3d_save" } else { "hacknslash3d_save_slot_" + (slot + 1).to_string() }
}

///|
fn valid_save_data(data : String) -> Bool {
  let parts = split_string(data, '|')
  parts.length() >= 8 && parse_int(parts[0]) >= 1
}

///|
fn save_region_name(parts : Array[String]) -> String {
  if parts.length() > 18 {
    try {
      let json = @json.parse(js_decode_world_progress(parts[18]))
      if json is Object(fields) {
        if fields.get("current") is Some(Number(value, ..)) {
          let id = value.to_int()
          if id >= 0 && id < @game.world_regions.length() {
            return @game.world_regions[id].name
          }
        }
      }
    } catch { _ => () }
  }
  "灰の森"
}

///|
fn read_save_slots() -> Array[SaveSlotView] {
  Array::makei(save_slot_count, slot => {
    let data = js_storage_get(save_slot_key(slot))
    let parts = split_string(data, '|')
    let ready = valid_save_data(data)
    {
      slot,
      status: if data == "" { "empty" } else if ready { "ready" } else { "invalid" },
      level: if ready && parts.length() > 8 { parse_int(parts[8]).max(1) } else { 1 },
      score: if ready { parse_int(parts[1]) } else { 0 },
      archetype: if parts.length() > 19 { parts[19] } else { "melee" },
      region: save_region_name(parts),
    }
  })
}

///|
fn GameState::persist_save(self : GameState) -> Bool {
  let ok = js_storage_set(save_slot_key(self.active_save_slot), self.serialize_save())
  self.save_notice = if ok { "" } else { "保存できませんでした。ブラウザーの保存領域を確認して、もう一度お試しください。" }
  ok
}

///|
fn GameState::clear_session_presentation(self : GameState) -> Unit {
  self.pending_save_deletion = None
  self.set_paused(false)
  self.camera_settings.editing = false
  self.terrain_lab.editing = false
  self.pause_return_ui = @game.UIMode::None
  self.pause_return_cursor = 0
  self.ground_targeting = false
  self.motion_preview = false
  self.active_effects.clear()
  self.combat_visuals.clear()
  self.damage_popups.clear()
  self.particle_manager.emitters.clear()
  self.aim.pointer = None
  self.aim.stick = None
  self.aim.native_cursor = None
  self.combat_feedback.hitstop = 0
  self.combat_feedback.look_x = 0.0
  self.combat_feedback.look_y = 0.0
  self.character.set_moving(false)
  self.character.anim_state = Idle
  self.character.action_time = 0.0
  self.character.skinning_cache_dirty = true
}

///|
fn GameState::select_save_slot(self : GameState, slot : Int) -> Bool {
  if slot < 0 || slot >= save_slot_count { return false }
  let data = js_storage_get(save_slot_key(slot))
  if data != "" && !valid_save_data(data) {
    self.save_notice = "このセーブデータは読み込めません。別の枠を選んでください。"
    return false
  }
  self.clear_session_presentation()
  let previous = self.world
  self.world = @game.GameWorld::new(
    seed=self.random_seed(), params=previous.params,
    hunting_grounds=previous.hunting_grounds, build_policy=previous.build_policy,
  )
  self.world.manual_combat = true
  self.active_save_slot = slot
  self.save_notice = ""
  if data == "" {
    self.world.mode = @game.CharacterSelect
    self.rebuild_dungeon_rendering()
  } else if self.load_game() {
    self.world.ensure_hunter_loadout()
    self.world.mode = @game.Playing
    self.world.open_levelup_ui_if_needed()
  } else {
    self.world = previous
    self.save_notice = "このセーブデータは読み込めません。別の枠を選んでください。"
    return false
  }
  self.sync_character_equipment()
  true
}

///|
fn GameState::return_to_save_select(self : GameState) -> Unit {
  if !self.persist_save() { return }
  self.clear_session_presentation()
  self.world.cancel_hunter_action()
  if self.world.atlas is Some(atlas) { atlas.travel_target = None }
  self.world.ui_mode = @game.UIMode::None
  self.world.mode = @game.Title
  self.world.select_cursor = self.active_save_slot
  self.save_slots = read_save_slots()
}

///|
fn GameState::respawn_player(self : GameState) -> Unit {
  if self.world.respawn_at_waypoint() {
    self.clear_session_presentation()
    self.rebuild_dungeon_rendering()
    self.save_game()
  }
}
