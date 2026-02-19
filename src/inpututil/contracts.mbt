///|
/// Input utility helpers (edge detection per tick).
///
/// Ebiten refs:
/// - inpututil/inpututil.go
/// - internal/inputstate/inputstate.go

///|
struct KeyDurationEntry {
  key : Int
  duration : Int
} derive(Show)

///|
pub struct KeyInputState {
  mut prev_pressed_keys : Array[Int]
  mut pressed_keys : Array[Int]
  mut just_pressed_keys : Array[Int]
  mut just_released_keys : Array[Int]
  mut durations : Array[KeyDurationEntry]
}

///|
fn contains_key(keys : Array[Int], key : Int) -> Bool {
  let mut found = false
  for current in keys {
    if current == key {
      found = true
    }
  }
  found
}

///|
fn normalize_pressed_keys(keys : Array[Int]) -> Array[Int] {
  let out : Array[Int] = []
  for key in keys {
    if !contains_key(out, key) {
      out.push(key)
    }
  }
  out
}

///|
fn duration_for_key(entries : Array[KeyDurationEntry], key : Int) -> Int {
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
pub fn update_key_input_state(
  state : KeyInputState,
  snapshot : @core.InputSnapshot,
) -> Unit {
  let prev_pressed = state.pressed_keys
  let next_pressed = normalize_pressed_keys(snapshot.pressed_keys)
  let just_pressed : Array[Int] = []
  for key in next_pressed {
    if !contains_key(prev_pressed, key) {
      just_pressed.push(key)
    }
  }
  let just_released : Array[Int] = []
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
    next_durations.push({ key, duration })
  }
  state.prev_pressed_keys = prev_pressed
  state.pressed_keys = next_pressed
  state.just_pressed_keys = just_pressed
  state.just_released_keys = just_released
  state.durations = next_durations
}

///|
pub fn is_key_pressed(state : KeyInputState, key : Int) -> Bool {
  contains_key(state.pressed_keys, key)
}

///|
pub fn is_key_just_pressed(state : KeyInputState, key : Int) -> Bool {
  contains_key(state.just_pressed_keys, key)
}

///|
pub fn is_key_just_released(state : KeyInputState, key : Int) -> Bool {
  contains_key(state.just_released_keys, key)
}

///|
pub fn key_press_duration(state : KeyInputState, key : Int) -> Int {
  duration_for_key(state.durations, key)
}

///|
pub fn append_pressed_keys(
  state : KeyInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for key in state.pressed_keys {
    out.push(key)
  }
  out
}

///|
pub fn append_just_pressed_keys(
  state : KeyInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for key in state.just_pressed_keys {
    out.push(key)
  }
  out
}

///|
pub fn append_just_released_keys(
  state : KeyInputState,
  dst : Array[Int],
) -> Array[Int] {
  let out = dst
  for key in state.just_released_keys {
    out.push(key)
  }
  out
}
