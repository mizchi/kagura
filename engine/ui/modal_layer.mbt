///|
/// Modal input and focus integration, independent of any renderer or game clock.
pub struct UIModalLayer {
  priv controller : UIModalController
  priv drag : UIDragController
  priv focus_manager : UIFocusManager
  priv saved_focusable : Array[Array[UINodeId]]
  priv backdrops : Array[UINodeId?]
  priv pending_events : Array[UIEvent]
}

///|
pub fn UIModalLayer::new(
  drag~ : UIDragController,
  focus~ : UIFocusManager = UIFocusManager::new(),
) -> UIModalLayer {
  {
    controller: UIModalController::new(),
    drag,
    focus_manager: focus,
    saved_focusable: [],
    backdrops: [],
    pending_events: [],
  }
}

///|
pub fn UIModalLayer::open(
  self : UIModalLayer,
  id : UINodeId,
  opener~ : UINodeId? = None,
  focusable~ : Array[UINodeId] = [],
  backdrop~ : UINodeId? = None,
) -> Bool {
  let opener = if opener is Some(_) {
    opener
  } else {
    self.focus_manager.current_focus()
  }
  if !self.controller.open(id, opener~, focusable~) {
    return false
  }
  for event in self.drag.cancel() {
    self.pending_events.push(event)
  }
  self.saved_focusable.push(self.focus_manager.focusable_ids.copy())
  self.backdrops.push(backdrop)
  self.sync_focus()
  true
}

///|
pub fn UIModalLayer::current(self : UIModalLayer) -> UIModalSnapshot? {
  self.controller.current()
}

///|
pub fn UIModalLayer::accepts(self : UIModalLayer, id : UINodeId) -> Bool {
  match self.current() {
    None => true
    Some(modal) =>
      modal.id == id ||
      modal.focusable.contains(id) ||
      self.backdrops.last().bind(id => id) == Some(id)
  }
}

///|
pub fn UIModalLayer::interaction(
  self : UIModalLayer,
  id : UINodeId,
  state : UIInteractionState,
) -> UIInteractionState {
  if self.current() is None {
    state
  } else if self.accepts(id) {
    UIInteractionState::new(
      available=state.available,
      selected=state.selected,
      disabled_reason=state.disabled_reason,
    )
  } else {
    UIInteractionState::new(
      available=false,
      disabled_reason=Some("Modal is open"),
    )
  }
}

///|
fn UIModalLayer::sync_focus(self : UIModalLayer) -> Unit {
  if self.current() is Some(modal) {
    self.focus_manager.set_focusable(modal.focusable.copy())
    let _ = self.focus_manager.focus(modal.focused)
  }
}

///|
pub fn UIModalLayer::focus(self : UIModalLayer, id : UINodeId) -> Bool {
  if self.current() is None {
    let _ = self.focus_manager.focus(id)
    return true
  }
  let accepted = self.controller.focus(id)
  if accepted {
    self.sync_focus()
  }
  accepted
}

///|
pub fn UIModalLayer::current_focus(self : UIModalLayer) -> UINodeId? {
  self.focus_manager.current_focus()
}

///|
pub fn UIModalLayer::cycle(self : UIModalLayer, direction : Int32) -> Unit {
  self.controller.cycle(direction)
  self.sync_focus()
}

///|
pub fn UIModalLayer::close(
  self : UIModalLayer,
  reason : UIModalCloseReason,
) -> UIModalClosed? {
  guard self.controller.close(reason) is Some(closed) else { return None }
  for event in self.drag.cancel() {
    self.pending_events.push(event)
  }
  let _ = self.backdrops.pop()
  self.focus_manager.set_focusable(self.saved_focusable.pop().unwrap_or([]))
  match closed.restore_focus {
    Some(id) => {
      let _ = self.focus_manager.focus(id)
    }
    None => {
      let _ = self.focus_manager.blur()
    }
  }
  Some(closed)
}

///|
pub fn UIModalLayer::handle_pointer(
  self : UIModalLayer,
  frame : UIPointerFrame,
  source_at~ : (Double, Double) -> UINodeId?,
  target_at~ : (UINodeId, Double, Double) -> UINodeId?,
) -> Array[UIEvent] {
  let events = self.drain_events()
  for
    event in self.drag.handle_pointer(
      frame,
      source_at=(x, y) => source_at(x, y).filter(id => self.accepts(id)),
      target_at=(source, x, y) => {
        if self.current() is None {
          target_at(source, x, y)
        } else {
          None
        }
      },
    ) {
    events.push(event)
  }
  events
}

///|
pub fn UIModalLayer::update(
  self : UIModalLayer,
  input : @core.InputSnapshot,
  source_at~ : (Double, Double) -> UINodeId?,
  target_at~ : (UINodeId, Double, Double) -> UINodeId?,
) -> Array[UIEvent] {
  let events = self.drain_events()
  for
    event in self.drag.update(
      input,
      source_at=(x, y) => source_at(x, y).filter(id => self.accepts(id)),
      target_at=(source, x, y) => {
        if self.current() is None {
          target_at(source, x, y)
        } else {
          None
        }
      },
    ) {
    events.push(event)
  }
  events
}

///|
/// Opening / closing a modal defers drag cancellation events to the next input
/// update, or callers can consume them immediately. Each event is returned once.
pub fn UIModalLayer::drain_events(self : UIModalLayer) -> Array[UIEvent] {
  let events = self.pending_events.copy()
  self.pending_events.clear()
  events
}
