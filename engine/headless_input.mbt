///|
struct HeadlessGamepadStep {
  id : Int
  axes : Array[Double]
  buttons : Array[Int]
} derive(FromJson)

///|
struct HeadlessInputStep {
  cursor_x : Double
  cursor_y : Double
  keys : Array[Int]
  mouse_buttons : Array[Int]
  gamepads : Array[HeadlessGamepadStep]
} derive(FromJson)

///|
fn HeadlessInputStep::to_input(self : HeadlessInputStep) -> @core.InputSnapshot {
  @core.new_input_snapshot_full(
    self.cursor_x,
    self.cursor_y,
    0.0,
    0.0,
    self.keys,
    self.mouse_buttons,
    [],
    self.gamepads.map(pad => {
      @core.new_gamepad_snapshot(pad.id, pad.axes, pad.buttons)
    }),
  )
}
