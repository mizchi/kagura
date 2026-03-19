///|
struct TouchDurationEntry {
  id : Int
  duration : Int
} derive(Show)

///|
pub struct TouchInputState {
  mut prev_touch_ids : Array[Int]
  mut touch_ids : Array[Int]
  mut just_pressed_touch_ids : Array[Int]
  mut just_released_touch_ids : Array[Int]
  mut durations : Array[TouchDurationEntry]
}

///|
fn normalize_touch_ids(snapshot : @core.InputSnapshot) -> Array[Int] {
  let out : Array[Int] = []
  for touch in snapshot.touches {
    if !contains_key(out, touch.id) {
      out.push(touch.id)
    }
  }
  out
}

///|
fn duration_for_touch(entries : Array[TouchDurationEntry], id : Int) -> Int {
  let mut out = 0
  for entry in entries {
    if entry.id == id {
      out = entry.duration
    }
  }
  out
}

///|
pub fn new_touch_input_state() -> TouchInputState {
  {
    prev_touch_ids: [],
    touch_ids: [],
    just_pressed_touch_ids: [],
    just_released_touch_ids: [],
    durations: [],
  }
}

///|
pub fn update_touch_input_state(
  state : TouchInputState,
  snapshot : @core.InputSnapshot,
) -> Unit {
  let prev_ids = state.touch_ids
  let next_ids = normalize_touch_ids(snapshot)
  let just_pressed : Array[Int] = []
  for id in next_ids {
    if !contains_key(prev_ids, id) {
      just_pressed.push(id)
    }
  }
  let just_released : Array[Int] = []
  for id in prev_ids {
    if !contains_key(next_ids, id) {
      just_released.push(id)
    }
  }
  let next_durations : Array[TouchDurationEntry] = []
  for id in next_ids {
    let duration = if contains_key(prev_ids, id) {
      duration_for_touch(state.durations, id) + 1
    } else {
      1
    }
    next_durations.push({ id, duration })
  }
  state.prev_touch_ids = prev_ids
  state.touch_ids = next_ids
  state.just_pressed_touch_ids = just_pressed
  state.just_released_touch_ids = just_released
  state.durations = next_durations
}

///|
pub fn is_touch_pressed(state : TouchInputState, id : Int) -> Bool {
  contains_key(state.touch_ids, id)
}

///|
pub fn is_touch_just_pressed(state : TouchInputState, id : Int) -> Bool {
  contains_key(state.just_pressed_touch_ids, id)
}

///|
pub fn is_touch_just_released(state : TouchInputState, id : Int) -> Bool {
  contains_key(state.just_released_touch_ids, id)
}

///|
pub fn touch_press_duration(state : TouchInputState, id : Int) -> Int {
  duration_for_touch(state.durations, id)
}

///|
pub fn append_touch_ids(
  state : TouchInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for id in state.touch_ids {
    out.push(id)
  }
  out
}

///|
pub fn append_just_pressed_touch_ids(
  state : TouchInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for id in state.just_pressed_touch_ids {
    out.push(id)
  }
  out
}

///|
pub fn append_just_released_touch_ids(
  state : TouchInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for id in state.just_released_touch_ids {
    out.push(id)
  }
  out
}

///|
struct GamepadDurationEntry {
  id : Int
  duration : Int
} derive(Show)

///|
struct GamepadButtonKey {
  gamepad_id : Int
  button_id : Int
} derive(Show)

///|
struct GamepadButtonDurationEntry {
  gamepad_id : Int
  button_id : Int
  duration : Int
} derive(Show)

///|
pub struct GamepadInputState {
  mut prev_gamepad_ids : Array[Int]
  mut gamepad_ids : Array[Int]
  mut just_connected_gamepad_ids : Array[Int]
  mut just_disconnected_gamepad_ids : Array[Int]
  mut durations : Array[GamepadDurationEntry]
  mut prev_pressed_buttons : Array[GamepadButtonKey]
  mut pressed_buttons : Array[GamepadButtonKey]
  mut just_pressed_buttons : Array[GamepadButtonKey]
  mut just_released_buttons : Array[GamepadButtonKey]
  mut button_durations : Array[GamepadButtonDurationEntry]
}

///|
fn normalize_gamepad_ids(snapshot : @core.InputSnapshot) -> Array[Int] {
  let out : Array[Int] = []
  for gamepad in snapshot.gamepads {
    if !contains_key(out, gamepad.id) {
      out.push(gamepad.id)
    }
  }
  out
}

///|
fn contains_gamepad_button(
  entries : Array[GamepadButtonKey],
  gamepad_id : Int,
  button_id : Int,
) -> Bool {
  let mut found = false
  for entry in entries {
    if entry.gamepad_id == gamepad_id && entry.button_id == button_id {
      found = true
    }
  }
  found
}

///|
fn normalize_gamepad_buttons(
  snapshot : @core.InputSnapshot,
) -> Array[GamepadButtonKey] {
  let out : Array[GamepadButtonKey] = []
  for gamepad in snapshot.gamepads {
    for button_id in gamepad.pressed_buttons {
      if !contains_gamepad_button(out, gamepad.id, button_id) {
        out.push({ gamepad_id: gamepad.id, button_id })
      }
    }
  }
  out
}

///|
fn duration_for_gamepad(entries : Array[GamepadDurationEntry], id : Int) -> Int {
  let mut out = 0
  for entry in entries {
    if entry.id == id {
      out = entry.duration
    }
  }
  out
}

///|
fn duration_for_gamepad_button(
  entries : Array[GamepadButtonDurationEntry],
  gamepad_id : Int,
  button_id : Int,
) -> Int {
  let mut out = 0
  for entry in entries {
    if entry.gamepad_id == gamepad_id && entry.button_id == button_id {
      out = entry.duration
    }
  }
  out
}

///|
pub fn new_gamepad_input_state() -> GamepadInputState {
  {
    prev_gamepad_ids: [],
    gamepad_ids: [],
    just_connected_gamepad_ids: [],
    just_disconnected_gamepad_ids: [],
    durations: [],
    prev_pressed_buttons: [],
    pressed_buttons: [],
    just_pressed_buttons: [],
    just_released_buttons: [],
    button_durations: [],
  }
}

///|
pub fn update_gamepad_input_state(
  state : GamepadInputState,
  snapshot : @core.InputSnapshot,
) -> Unit {
  let prev_gamepad_ids = state.gamepad_ids
  let next_gamepad_ids = normalize_gamepad_ids(snapshot)
  let just_connected : Array[Int] = []
  for id in next_gamepad_ids {
    if !contains_key(prev_gamepad_ids, id) {
      just_connected.push(id)
    }
  }
  let just_disconnected : Array[Int] = []
  for id in prev_gamepad_ids {
    if !contains_key(next_gamepad_ids, id) {
      just_disconnected.push(id)
    }
  }
  let next_durations : Array[GamepadDurationEntry] = []
  for id in next_gamepad_ids {
    let duration = if contains_key(prev_gamepad_ids, id) {
      duration_for_gamepad(state.durations, id) + 1
    } else {
      1
    }
    next_durations.push({ id, duration })
  }

  let prev_buttons = state.pressed_buttons
  let next_buttons = normalize_gamepad_buttons(snapshot)
  let just_pressed_buttons : Array[GamepadButtonKey] = []
  for entry in next_buttons {
    if !contains_gamepad_button(prev_buttons, entry.gamepad_id, entry.button_id) {
      just_pressed_buttons.push({
        gamepad_id: entry.gamepad_id,
        button_id: entry.button_id,
      })
    }
  }
  let just_released_buttons : Array[GamepadButtonKey] = []
  for entry in prev_buttons {
    if !contains_gamepad_button(next_buttons, entry.gamepad_id, entry.button_id) {
      just_released_buttons.push({
        gamepad_id: entry.gamepad_id,
        button_id: entry.button_id,
      })
    }
  }
  let next_button_durations : Array[GamepadButtonDurationEntry] = []
  for entry in next_buttons {
    let duration = if contains_gamepad_button(
        prev_buttons,
        entry.gamepad_id,
        entry.button_id,
      ) {
      duration_for_gamepad_button(
        state.button_durations,
        entry.gamepad_id,
        entry.button_id,
      ) +
      1
    } else {
      1
    }
    next_button_durations.push({
      gamepad_id: entry.gamepad_id,
      button_id: entry.button_id,
      duration,
    })
  }

  state.prev_gamepad_ids = prev_gamepad_ids
  state.gamepad_ids = next_gamepad_ids
  state.just_connected_gamepad_ids = just_connected
  state.just_disconnected_gamepad_ids = just_disconnected
  state.durations = next_durations
  state.prev_pressed_buttons = prev_buttons
  state.pressed_buttons = next_buttons
  state.just_pressed_buttons = just_pressed_buttons
  state.just_released_buttons = just_released_buttons
  state.button_durations = next_button_durations
}

///|
pub fn is_gamepad_connected(state : GamepadInputState, id : Int) -> Bool {
  contains_key(state.gamepad_ids, id)
}

///|
pub fn is_gamepad_just_connected(state : GamepadInputState, id : Int) -> Bool {
  contains_key(state.just_connected_gamepad_ids, id)
}

///|
pub fn is_gamepad_just_disconnected(
  state : GamepadInputState,
  id : Int,
) -> Bool {
  contains_key(state.just_disconnected_gamepad_ids, id)
}

///|
pub fn gamepad_connection_duration(state : GamepadInputState, id : Int) -> Int {
  duration_for_gamepad(state.durations, id)
}

///|
pub fn is_gamepad_button_pressed(
  state : GamepadInputState,
  gamepad_id : Int,
  button_id : Int,
) -> Bool {
  contains_gamepad_button(state.pressed_buttons, gamepad_id, button_id)
}

///|
pub fn is_gamepad_button_just_pressed(
  state : GamepadInputState,
  gamepad_id : Int,
  button_id : Int,
) -> Bool {
  contains_gamepad_button(state.just_pressed_buttons, gamepad_id, button_id)
}

///|
pub fn is_gamepad_button_just_released(
  state : GamepadInputState,
  gamepad_id : Int,
  button_id : Int,
) -> Bool {
  contains_gamepad_button(state.just_released_buttons, gamepad_id, button_id)
}

///|
pub fn gamepad_pressed_button_count(state : GamepadInputState) -> Int {
  state.pressed_buttons.length()
}

///|
pub fn gamepad_just_pressed_button_count(state : GamepadInputState) -> Int {
  state.just_pressed_buttons.length()
}

///|
pub fn gamepad_just_released_button_count(state : GamepadInputState) -> Int {
  state.just_released_buttons.length()
}

///|
pub fn gamepad_button_press_duration(
  state : GamepadInputState,
  gamepad_id : Int,
  button_id : Int,
) -> Int {
  duration_for_gamepad_button(state.button_durations, gamepad_id, button_id)
}

///|
pub fn append_connected_gamepad_ids(
  state : GamepadInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for id in state.gamepad_ids {
    out.push(id)
  }
  out
}

///|
pub fn append_just_connected_gamepad_ids(
  state : GamepadInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for id in state.just_connected_gamepad_ids {
    out.push(id)
  }
  out
}

///|
pub fn append_just_disconnected_gamepad_ids(
  state : GamepadInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for id in state.just_disconnected_gamepad_ids {
    out.push(id)
  }
  out
}
