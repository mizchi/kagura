///|
pub(all) enum UINavigationDirection {
  Left
  Right
  Up
  Down
} derive(Debug, Eq)

///|
/// Standard gamepad mapping: A confirms, B cancels; X/Y/LB/RB/Start remain
/// application-owned auxiliary actions. Arrow keys use the same contract.
pub(all) enum UINavigationEvent {
  Move(UINavigationDirection)
  Confirm
  Cancel
  Auxiliary(Int)
} derive(Debug, Eq)

///|
pub struct UINavigationInputAdapter {
  priv mut direction : UINavigationDirection?
  priv mut held_ms : Double
  priv mut next_repeat_ms : Double
  priv mut held_actions : Array[Int]
}

///|
pub fn UINavigationInputAdapter::new() -> UINavigationInputAdapter {
  { direction: None, held_ms: 0.0, next_repeat_ms: 350.0, held_actions: [], }
}

///|
/// Held directions repeat after 350 ms, then every 120 ms. At most one repeat
/// per update prevents delayed/background frames from skipping many controls.
pub fn UINavigationInputAdapter::update(
  self : UINavigationInputAdapter,
  snapshot : @core.InputSnapshot,
  elapsed_ms? : Double = 1000.0 / 60.0,
) -> Array[UINavigationEvent] {
  let keys = snapshot.pressed_keys
  let buttons = snapshot.gamepads
    .get(0)
    .map(p => p.pressed_buttons)
    .unwrap_or([])
  let axes = snapshot.gamepads.get(0).map(p => p.axes).unwrap_or([])
  let x = if axes.length() > 0 { axes[0] } else { 0.0 }
  let y = if axes.length() > 1 { axes[1] } else { 0.0 }
  let threshold = if self.direction is Some(_) { 0.35 } else { 0.55 }
  let direction = if keys.contains(37) ||
    keys.contains(263) ||
    buttons.contains(14) {
    Some(Left)
  } else if keys.contains(39) || keys.contains(262) || buttons.contains(15) {
    Some(Right)
  } else if keys.contains(38) || keys.contains(265) || buttons.contains(12) {
    Some(Up)
  } else if keys.contains(40) || keys.contains(264) || buttons.contains(13) {
    Some(Down)
  } else if x.abs() >= threshold && x.abs() >= y.abs() {
    Some(if x < 0.0 { Left } else { Right })
  } else if y.abs() >= threshold {
    Some(if y < 0.0 { Up } else { Down })
  } else {
    None
  }
  let events : Array[UINavigationEvent] = []
  if direction != self.direction {
    self.direction = direction
    self.held_ms = 0.0
    self.next_repeat_ms = 350.0
    if direction is Some(d) {
      events.push(Move(d))
    }
  } else if direction is Some(d) {
    self.held_ms += if elapsed_ms > 0.0 { elapsed_ms } else { 0.0 }
    if self.held_ms >= self.next_repeat_ms {
      events.push(Move(d))
      self.next_repeat_ms = self.held_ms + 120.0
    }
  }
  let actions : Array[Int] = []
  if buttons.contains(0) ||
    keys.contains(13) ||
    keys.contains(257) ||
    keys.contains(32) {
    actions.push(0)
  }
  if buttons.contains(1) || keys.contains(27) || keys.contains(256) {
    actions.push(1)
  }
  for button in [2, 3, 4, 5, 9] {
    if buttons.contains(button) {
      actions.push(button)
    }
  }
  for action in actions {
    if !self.held_actions.contains(action) {
      events.push(
        match action {
          0 => Confirm
          1 => Cancel
          _ => Auxiliary(action)
        },
      )
    }
  }
  self.held_actions = actions
  events
}

///|
pub extend UINavigationDirection with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UINavigationDirection with Eq::{not_equal, equal}

///|
pub extend UINavigationEvent with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UINavigationEvent with Eq::{not_equal, equal}
