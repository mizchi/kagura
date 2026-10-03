///|
/// GLFW uses different indices for Back, Start, Guide, thumb and D-pad
/// buttons. Convert at the host boundary; update() takes standard UI indices.
/// Axes 0/1 are the left stick in both contracts.
pub fn navigation_input_from_glfw(
  snapshot : @core.InputSnapshot,
) -> @core.InputSnapshot {
  let pads = snapshot.gamepads.map(pad => {
    let buttons : Array[Int] = []
    for button in pad.pressed_buttons {
      let standard = match button {
        0..=5 => button
        6 => 8 // Back
        7 => 9 // Start
        8 => 16 // Guide
        9 => 10 // Left thumb
        10 => 11 // Right thumb
        11 => 12 // Up
        12 => 15 // Right
        13 => 13 // Down
        14 => 14 // Left
        _ => -1
      }
      if standard >= 0 {
        buttons.push(standard)
      }
    }
    @core.new_gamepad_snapshot(pad.id, pad.axes.copy(), buttons)
  })
  @core.new_input_snapshot_full(
    snapshot.cursor_x,
    snapshot.cursor_y,
    snapshot.wheel_x,
    snapshot.wheel_y,
    snapshot.pressed_keys,
    snapshot.pressed_mouse_buttons,
    snapshot.touches,
    pads,
  )
}
