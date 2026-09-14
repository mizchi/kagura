///|
pub struct InputHelper {
  key_state : @inputstate.KeyInputState
  mouse_state : @inputstate.MouseButtonInputState
  touch_state : @inputstate.TouchInputState
}

///|
pub fn new_input_helper() -> InputHelper {
  {
    key_state: @inputstate.new_key_input_state(),
    mouse_state: @inputstate.new_mouse_input_state(),
    touch_state: @inputstate.new_touch_input_state(),
  }
}

///|
pub fn update_input_helper(
  helper : InputHelper,
  snapshot : @core.InputSnapshot,
) -> Unit {
  @inputstate.update_key_input_state(helper.key_state, snapshot)
  @inputstate.update_mouse_input_state(helper.mouse_state, snapshot)
  @inputstate.update_touch_input_state(helper.touch_state, snapshot)
}

///|
pub fn is_any_action_just_pressed(
  helper : InputHelper,
  _input : @core.InputSnapshot,
) -> Bool {
  helper.key_state.just_pressed_keys.length() > 0 ||
  helper.mouse_state.just_pressed_buttons.length() > 0 ||
  helper.touch_state.just_pressed_touch_ids.length() > 0
}

// ============================================================
// Physical key constants. Web hooks normalize KeyboardEvent.code into this
// numeric contract; helpers must not add character/layout-specific aliases.
// ============================================================

///|
pub let key_w : Int = 87

///|
pub let key_a : Int = 65

///|
pub let key_s : Int = 83

///|
pub let key_d : Int = 68

///|
pub let key_up_web : Int = 38

///|
pub let key_down_web : Int = 40

///|
pub let key_left_web : Int = 37

///|
pub let key_right_web : Int = 39

///|
pub let key_up_glfw : Int = 265

///|
pub let key_down_glfw : Int = 264

///|
pub let key_left_glfw : Int = 263

///|
pub let key_right_glfw : Int = 262

// Additional physical keys, available for application-specific bindings.

///|
pub let key_comma : Int = 188

///|
pub let key_o : Int = 79

///|
pub let key_e : Int = 69

///|
pub let key_space : Int = 32

///|
pub let key_enter_web : Int = 13

///|
pub let key_enter_glfw : Int = 257

// ============================================================
// Direction helpers (WASD + Arrow keys for web + GLFW)
// ============================================================

///|
pub fn is_move_up(key_state : @inputstate.KeyInputState) -> Bool {
  @inputstate.is_key_pressed(key_state, key_w) ||
  @inputstate.is_key_pressed(key_state, key_up_web) ||
  @inputstate.is_key_pressed(key_state, key_up_glfw)
}

///|
pub fn is_move_down(key_state : @inputstate.KeyInputState) -> Bool {
  @inputstate.is_key_pressed(key_state, key_s) ||
  @inputstate.is_key_pressed(key_state, key_down_web) ||
  @inputstate.is_key_pressed(key_state, key_down_glfw)
}

///|
pub fn is_move_left(key_state : @inputstate.KeyInputState) -> Bool {
  @inputstate.is_key_pressed(key_state, key_a) ||
  @inputstate.is_key_pressed(key_state, key_left_web) ||
  @inputstate.is_key_pressed(key_state, key_left_glfw)
}

///|
pub fn is_move_right(key_state : @inputstate.KeyInputState) -> Bool {
  @inputstate.is_key_pressed(key_state, key_d) ||
  @inputstate.is_key_pressed(key_state, key_right_web) ||
  @inputstate.is_key_pressed(key_state, key_right_glfw)
}

///|
pub fn is_confirm_just_pressed(helper : InputHelper) -> Bool {
  @inputstate.is_key_just_pressed(helper.key_state, key_space) ||
  @inputstate.is_key_just_pressed(helper.key_state, key_enter_web) ||
  @inputstate.is_key_just_pressed(helper.key_state, key_enter_glfw)
}

///|
pub fn is_up_just_pressed(helper : InputHelper) -> Bool {
  @inputstate.is_key_just_pressed(helper.key_state, key_w) ||
  @inputstate.is_key_just_pressed(helper.key_state, key_up_web) ||
  @inputstate.is_key_just_pressed(helper.key_state, key_up_glfw)
}

///|
pub fn is_down_just_pressed(helper : InputHelper) -> Bool {
  @inputstate.is_key_just_pressed(helper.key_state, key_s) ||
  @inputstate.is_key_just_pressed(helper.key_state, key_down_web) ||
  @inputstate.is_key_just_pressed(helper.key_state, key_down_glfw)
}
