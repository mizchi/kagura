///|
/// Rendering and payloads belong to the caller. This controller owns the modal
/// stack, input scope, focus trap and the focus to restore on dismissal.
pub(all) enum UIModalCloseReason {
  Explicit
  Cancel
  Backdrop
} derive(Debug, Eq)

///|
pub struct UIModalSnapshot {
  id : UINodeId
  focused : UINodeId
  focusable : Array[UINodeId]
}

///|
pub struct UIModalClosed {
  id : UINodeId
  reason : UIModalCloseReason
  restore_focus : UINodeId?
}

///|
priv struct UIModalFrame {
  id : UINodeId
  opener : UINodeId?
  focusable : Array[UINodeId]
  mut focused : UINodeId
}

///|
pub struct UIModalController {
  priv stack : Array[UIModalFrame]
}

///|
pub fn UIModalController::new() -> UIModalController {
  { stack: [], }
}

///|
/// Duplicate modal identities are rejected. Empty dialogs focus their root.
pub fn UIModalController::open(
  self : UIModalController,
  id : UINodeId,
  opener? : UINodeId? = None,
  focusable? : Array[UINodeId] = [],
) -> Bool {
  if self.stack.any(frame => frame.id == id) {
    return false
  }
  let ids = if focusable.is_empty() { [id] } else { focusable.copy() }
  self.stack.push({ id, opener, focusable: ids, focused: ids[0], })
  true
}

///|
pub fn UIModalController::current(self : UIModalController) -> UIModalSnapshot? {
  self.stack
  .last()
  .map(frame => {
    id: frame.id,
    focused: frame.focused,
    focusable: frame.focusable.copy(),
  })
}

///|
/// Only the top modal may receive input; background and parent dialogs are inert.
pub fn UIModalController::accepts(
  self : UIModalController,
  id : UINodeId,
) -> Bool {
  match self.stack.last() {
    Some(frame) => frame.id == id
    None => true
  }
}

///|
pub fn UIModalController::focus(
  self : UIModalController,
  id : UINodeId,
) -> Bool {
  guard self.stack.last() is Some(frame) else { return false }
  if !frame.focusable.contains(id) {
    return false
  }
  frame.focused = id
  true
}

///|
pub fn UIModalController::cycle(
  self : UIModalController,
  direction : Int,
) -> Unit {
  guard self.stack.last() is Some(frame) else { return }
  let n = frame.focusable.length()
  let mut current = 0
  for i, id in frame.focusable {
    if id == frame.focused {
      current = i
    }
  }
  let offset = if direction < 0 { n - 1 } else { 1 }
  frame.focused = frame.focusable[(current + offset) % n]
}

///|
pub fn UIModalController::close(
  self : UIModalController,
  reason : UIModalCloseReason,
) -> UIModalClosed? {
  guard self.stack.pop() is Some(frame) else { return None }
  let restore = match self.stack.last() {
    Some(parent) => {
      if frame.opener is Some(id) && parent.focusable.contains(id) {
        parent.focused = id
      }
      Some(parent.focused)
    }
    None => frame.opener
  }
  Some({ id: frame.id, reason, restore_focus: restore, })
}

///|
pub extend UIModalCloseReason with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIModalCloseReason with Eq::{not_equal, equal}
