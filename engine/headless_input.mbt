///|
#derive(FromJson)
struct HeadlessGamepadStep {
  id : Int32
  axes : Array[Double]
  buttons : Array[Int32]
}

///|
pub extend HeadlessGamepadStep with @moonbitlang/core/json.FromJson::{from_json}

///|
#derive(FromJson)
struct HeadlessInputStep {
  cursor_x : Double
  cursor_y : Double
  keys : Array[Int32]
  mouse_buttons : Array[Int32]
  gamepads : Array[HeadlessGamepadStep]
}

///|
pub extend HeadlessInputStep with @moonbitlang/core/json.FromJson::{from_json}

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
