///|
/// InputSnapshot carries CSS pixels on web; the controller accepts logical pixels.
fn scale_pointer_input(
  input : @core.InputSnapshot,
  logical_w : Double,
  logical_h : Double,
  surface_w : Double,
  surface_h : Double,
) -> @core.InputSnapshot {
  let sx = if surface_w > 0.0 { logical_w / surface_w } else { 1.0 }
  let sy = if surface_h > 0.0 { logical_h / surface_h } else { 1.0 }
  let touches = input.touches.map(t => {
    @core.new_touch_point_with_source(t.id, t.x * sx, t.y * sy, t.source)
  })
  @core.new_input_snapshot_full(
    input.cursor_x * sx,
    input.cursor_y * sy,
    input.wheel_x,
    input.wheel_y,
    input.pressed_keys,
    input.pressed_mouse_buttons,
    touches,
    input.gamepads,
  )
}
