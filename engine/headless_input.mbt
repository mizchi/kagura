///|
struct HeadlessGamepadStep {
  id : Int
  axes : Array[Double]
  buttons : Array[Int]
} derive(FromJson)

///|
pub extend HeadlessGamepadStep with @moonbitlang/core/json.FromJson::{from_json}

///|
struct HeadlessInputStep {
  cursor_x : Double
  cursor_y : Double
  keys : Array[Int]
  mouse_buttons : Array[Int]
  gamepads : Array[HeadlessGamepadStep]
} derive(FromJson)

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
