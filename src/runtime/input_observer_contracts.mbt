///|
pub struct InputEdgeSummary {
  tick : Int
  just_pressed_key_count : Int
  just_released_key_count : Int
  just_pressed_mouse_button_count : Int
  just_released_mouse_button_count : Int
  just_pressed_touch_count : Int
  just_released_touch_count : Int
  just_connected_gamepad_count : Int
  just_disconnected_gamepad_count : Int
  just_pressed_gamepad_button_count : Int
  just_released_gamepad_button_count : Int
} derive(Show)

///|
pub struct InputEdgeObserverState {
  key_state : @inpututil.KeyInputState
  mouse_state : @inpututil.MouseButtonInputState
  touch_state : @inpututil.TouchInputState
  gamepad_state : @inpututil.GamepadInputState
  mut history : Array[InputEdgeSummary]
  history_limit : Int
}

///|
fn clamp_history_limit(limit : Int) -> Int {
  if limit <= 0 {
    1
  } else {
    limit
  }
}

///|
fn bounded_history_push(
  history : Array[InputEdgeSummary],
  history_limit : Int,
  summary : InputEdgeSummary,
) -> Array[InputEdgeSummary] {
  let limit = clamp_history_limit(history_limit)
  let out : Array[InputEdgeSummary] = []
  let start = if history.length() >= limit {
    history.length() - limit + 1
  } else {
    0
  }
  for i in start..<history.length() {
    out.push(history[i])
  }
  out.push(summary)
  out
}

///|
pub fn new_input_edge_observer_state(
  history_limit : Int,
) -> InputEdgeObserverState {
  {
    key_state: @inpututil.new_key_input_state(),
    mouse_state: @inpututil.new_mouse_input_state(),
    touch_state: @inpututil.new_touch_input_state(),
    gamepad_state: @inpututil.new_gamepad_input_state(),
    history: [],
    history_limit: clamp_history_limit(history_limit),
  }
}

///|
pub fn observe_input_edge(
  state : InputEdgeObserverState,
  tick : Int,
  snapshot : @core.InputSnapshot,
) -> InputEdgeSummary {
  @inpututil.update_key_input_state(state.key_state, snapshot)
  @inpututil.update_mouse_input_state(state.mouse_state, snapshot)
  @inpututil.update_touch_input_state(state.touch_state, snapshot)
  @inpututil.update_gamepad_input_state(state.gamepad_state, snapshot)

  let just_pressed_keys = @inpututil.append_just_pressed_keys(state.key_state, [])
  let just_released_keys = @inpututil.append_just_released_keys(
    state.key_state,
    [],
  )
  let just_pressed_mouse_buttons = @inpututil.append_just_pressed_mouse_buttons(
    state.mouse_state,
    [],
  )
  let just_released_mouse_buttons = @inpututil.append_just_released_mouse_buttons(
    state.mouse_state,
    [],
  )
  let just_pressed_touch_ids = @inpututil.append_just_pressed_touch_ids(
    state.touch_state,
    [],
  )
  let just_released_touch_ids = @inpututil.append_just_released_touch_ids(
    state.touch_state,
    [],
  )
  let just_connected_gamepad_ids = @inpututil.append_just_connected_gamepad_ids(
    state.gamepad_state,
    [],
  )
  let just_disconnected_gamepad_ids = @inpututil.append_just_disconnected_gamepad_ids(
    state.gamepad_state,
    [],
  )

  let summary : InputEdgeSummary = {
    tick,
    just_pressed_key_count: just_pressed_keys.length(),
    just_released_key_count: just_released_keys.length(),
    just_pressed_mouse_button_count: just_pressed_mouse_buttons.length(),
    just_released_mouse_button_count: just_released_mouse_buttons.length(),
    just_pressed_touch_count: just_pressed_touch_ids.length(),
    just_released_touch_count: just_released_touch_ids.length(),
    just_connected_gamepad_count: just_connected_gamepad_ids.length(),
    just_disconnected_gamepad_count: just_disconnected_gamepad_ids.length(),
    just_pressed_gamepad_button_count: @inpututil.gamepad_just_pressed_button_count(
      state.gamepad_state,
    ),
    just_released_gamepad_button_count: @inpututil.gamepad_just_released_button_count(
      state.gamepad_state,
    ),
  }
  state.history = bounded_history_push(
    state.history,
    state.history_limit,
    summary,
  )
  summary
}

///|
pub fn append_input_edge_history(
  state : InputEdgeObserverState,
  dst : Array[InputEdgeSummary],
) -> Array[InputEdgeSummary] {
  let out = dst
  for summary in state.history {
    out.push(summary)
  }
  out
}

///|
pub fn clear_input_edge_history(state : InputEdgeObserverState) -> Unit {
  state.history = []
}

///|
pub fn new_input_edge_runtime_hooks(
  observer_state : InputEdgeObserverState,
) -> RuntimeHooks {
  new_runtime_hooks(fn(tick, input) {
    let _ = observe_input_edge(observer_state, tick, input)
  })
}
