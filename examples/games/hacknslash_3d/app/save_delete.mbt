///|
struct SaveDeletion {
  slot : Int
  data : String
}

///|
fn GameState::request_save_deletion(self : GameState, slot : Int) -> Unit {
  if self.world.mode != @game.Title || slot < 0 || slot >= save_slot_count {
    return
  }
  let data = js_storage_get(save_slot_key(slot))
  self.save_slots = read_save_slots()
  if data == "" {
    return
  }
  self.pending_save_deletion = Some({ slot, data, })
  self.world.select_cursor = slot
  self.save_notice = ""
}

///|
fn GameState::confirm_save_deletion(self : GameState) -> Unit {
  if self.world.mode != @game.Title {
    return
  }
  guard self.pending_save_deletion is Some(pending) else { return }
  let key = save_slot_key(pending.slot)
  // Another tab may have saved while this confirmation was open.
  if js_storage_get(key) != pending.data {
    self.pending_save_deletion = None
    self.save_slots = read_save_slots()
    self.save_notice = "データが更新されました。内容を確認して、もう一度削除してください。"
    return
  }
  if !js_storage_remove(key) {
    self.save_notice = "削除できませんでした。ブラウザーの保存領域を確認して、もう一度お試しください。"
    return
  }
  self.pending_save_deletion = None
  self.save_slots = read_save_slots()
  self.world.select_cursor = pending.slot
  self.save_notice = "セーブ " +
    (pending.slot + 1).to_string() +
    " を削除しました。"
}

///|
fn GameState::handle_save_delete_input(self : GameState) -> Bool {
  if self.pending_save_deletion is Some(_) {
    if @inpututil.is_key_just_pressed(self.input.key_state, key_escape) {
      self.pending_save_deletion = None
      self.save_notice = ""
    } else if @inpututil.is_confirm_just_pressed(self.input) {
      self.confirm_save_deletion()
    }
    return true
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 46) {
    self.request_save_deletion(self.world.select_cursor)
    return true
  }
  false
}
