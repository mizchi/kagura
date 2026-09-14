///|
test "capture request validates bounds and replays complete input steps" {
  let text =
    #|{"initial_state":"dialog","width":360,"height":640,"frames":3,"inputs":[{"cursor_x":100,"cursor_y":74,"keys":[9],"mouse_buttons":[0],"gamepads":[{"id":0,"axes":[0.5],"buttons":[13]}]}]}
  let request = parse_capture_request(text)
  assert_eq(request.width, 360)
  assert_eq(request.initial_state, Some("dialog"))
  let input = request.input_at(0)
  assert_eq(input.pressed_keys, [9])
  assert_eq(input.pressed_mouse_buttons, [0])
  assert_eq(input.gamepads[0].pressed_buttons, [13])
  assert_eq(request.input_at(1).pressed_keys, [])
  assert_eq(request.input_at(2).cursor_x, -1.0)
}

///|
test "capture request rejects malformed input and excessive captures" {
  for
    text in [
      "{}", "{\"width\":0,\"height\":640,\"frames\":1,\"inputs\":[]}", "{\"width\":640,\"height\":480,\"frames\":601,\"inputs\":[]}",
      "{\"width\":640,\"height\":480,\"frames\":1,\"inputs\":[{}]}",
    ] {
    let rejected = try {
      let _ = parse_capture_request(text)
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
}
