///|
/// Input utility helpers (edge detection per tick).
///
/// Ebiten refs:
/// - inpututil/inpututil.go
/// - internal/inputstate/inputstate.go

///|
#derive(Debug)
struct KeyDurationEntry {
  key : Int32
  duration : Int32
}

///|
pub impl Show for KeyDurationEntry with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
struct MouseButtonDurationEntry {
  button : Int32
  duration : Int32
}

///|
pub impl Show for MouseButtonDurationEntry with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct KeyInputState {
  mut prev_pressed_keys : Array[Int32]
  mut pressed_keys : Array[Int32]
  mut just_pressed_keys : Array[Int32]
  mut just_released_keys : Array[Int32]
  mut durations : Array[KeyDurationEntry]
}

///|
pub struct MouseButtonInputState {
  mut prev_pressed_buttons : Array[Int32]
  mut pressed_buttons : Array[Int32]
  mut just_pressed_buttons : Array[Int32]
  mut just_released_buttons : Array[Int32]
  mut durations : Array[MouseButtonDurationEntry]
}

///|
fn contains_key(keys : Array[Int32], key : Int32) -> Bool {
  let mut found = false
  for current in keys {
    if current == key {
      found = true
    }
  }
  found
}

///|
fn normalize_pressed_keys(keys : Array[Int32]) -> Array[Int32] {
  let out : Array[Int32] = []
  for key in keys {
    if !contains_key(out, key) {
      out.push(key)
    }
  }
  out
}

///|
fn duration_for_key(entries : Array[KeyDurationEntry], key : Int32) -> Int32 {
  let mut out = 0
  for entry in entries {
    if entry.key == key {
      out = entry.duration
    }
  }
  out
}

///|
pub fn new_key_input_state() -> KeyInputState {
  {
    prev_pressed_keys: [],
    pressed_keys: [],
    just_pressed_keys: [],
    just_released_keys: [],
    durations: [],
  }
}

///|
fn duration_for_mouse_button(
  entries : Array[MouseButtonDurationEntry],
  button : Int32,
) -> Int32 {
  let mut out = 0
  for entry in entries {
    if entry.button == button {
      out = entry.duration
    }
  }
  out
}

///|
pub fn new_mouse_input_state() -> MouseButtonInputState {
  {
    prev_pressed_buttons: [],
    pressed_buttons: [],
    just_pressed_buttons: [],
    just_released_buttons: [],
    durations: [],
  }
}

///|
pub fn update_key_input_state(
  state : KeyInputState,
  snapshot : @core.InputSnapshot,
) -> Unit {
  let prev_pressed = state.pressed_keys
  let next_pressed = normalize_pressed_keys(snapshot.pressed_keys)
  let just_pressed : Array[Int32] = []
  for key in next_pressed {
    if !contains_key(prev_pressed, key) {
      just_pressed.push(key)
    }
  }
  let just_released : Array[Int32] = []
  for key in prev_pressed {
    if !contains_key(next_pressed, key) {
      just_released.push(key)
    }
  }
  let next_durations : Array[KeyDurationEntry] = []
  for key in next_pressed {
    let duration = if contains_key(prev_pressed, key) {
      duration_for_key(state.durations, key) + 1
    } else {
      1
    }
    next_durations.push({ key, duration, })
  }
  state.prev_pressed_keys = prev_pressed
  state.pressed_keys = next_pressed
  state.just_pressed_keys = just_pressed
  state.just_released_keys = just_released
  state.durations = next_durations
}

///|
pub fn update_mouse_input_state(
  state : MouseButtonInputState,
  snapshot : @core.InputSnapshot,
) -> Unit {
  let prev_pressed = state.pressed_buttons
  let next_pressed = normalize_pressed_keys(snapshot.pressed_mouse_buttons)
  let just_pressed : Array[Int32] = []
  for button in next_pressed {
    if !contains_key(prev_pressed, button) {
      just_pressed.push(button)
    }
  }
  let just_released : Array[Int32] = []
  for button in prev_pressed {
    if !contains_key(next_pressed, button) {
      just_released.push(button)
    }
  }
  let next_durations : Array[MouseButtonDurationEntry] = []
  for button in next_pressed {
    let duration = if contains_key(prev_pressed, button) {
      duration_for_mouse_button(state.durations, button) + 1
    } else {
      1
    }
    next_durations.push({ button, duration, })
  }
  state.prev_pressed_buttons = prev_pressed
  state.pressed_buttons = next_pressed
  state.just_pressed_buttons = just_pressed
  state.just_released_buttons = just_released
  state.durations = next_durations
}

///|
pub fn is_key_pressed(state : KeyInputState, key : Int32) -> Bool {
  contains_key(state.pressed_keys, key)
}

///|
pub fn is_key_just_pressed(state : KeyInputState, key : Int32) -> Bool {
  contains_key(state.just_pressed_keys, key)
}

///|
pub fn is_key_just_released(state : KeyInputState, key : Int32) -> Bool {
  contains_key(state.just_released_keys, key)
}

///|
pub fn key_press_duration(state : KeyInputState, key : Int32) -> Int32 {
  duration_for_key(state.durations, key)
}

///|
pub fn is_mouse_button_pressed(
  state : MouseButtonInputState,
  button : Int32,
) -> Bool {
  contains_key(state.pressed_buttons, button)
}

///|
pub fn is_mouse_button_just_pressed(
  state : MouseButtonInputState,
  button : Int32,
) -> Bool {
  contains_key(state.just_pressed_buttons, button)
}

///|
pub fn is_mouse_button_just_released(
  state : MouseButtonInputState,
  button : Int32,
) -> Bool {
  contains_key(state.just_released_buttons, button)
}

///|
pub fn mouse_button_press_duration(
  state : MouseButtonInputState,
  button : Int32,
) -> Int32 {
  duration_for_mouse_button(state.durations, button)
}

///|
pub fn append_pressed_keys(
  state : KeyInputState,
  dst : Array[Int32],
) -> Array[Int32] {
  let out = dst
  for key in state.pressed_keys {
    out.push(key)
  }
  out
}

///|
pub fn append_just_pressed_keys(
  state : KeyInputState,
  dst : Array[Int32],
) -> Array[Int32] {
  let out = dst
  for key in state.just_pressed_keys {
    out.push(key)
  }
  out
}

///|
pub fn append_just_released_keys(
  state : KeyInputState,
  dst : Array[Int32],
) -> Array[Int32] {
  let out = dst
  for key in state.just_released_keys {
    out.push(key)
  }
  out
}

///|
pub fn append_pressed_mouse_buttons(
  state : MouseButtonInputState,
  dst : Array[Int32],
) -> Array[Int32] {
  let out = dst
  for button in state.pressed_buttons {
    out.push(button)
  }
  out
}

///|
pub fn append_just_pressed_mouse_buttons(
  state : MouseButtonInputState,
  dst : Array[Int32],
) -> Array[Int32] {
  let out = dst
  for button in state.just_pressed_buttons {
    out.push(button)
  }
  out
}

///|
pub fn append_just_released_mouse_buttons(
  state : MouseButtonInputState,
  dst : Array[Int32],
) -> Array[Int32] {
  let out = dst
  for button in state.just_released_buttons {
    out.push(button)
  }
  out
}

///|
pub extend KeyDurationEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend KeyDurationEntry with Show::{to_string, output}

///|
pub extend MouseButtonDurationEntry with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend MouseButtonDurationEntry with Show::{to_string, output}
