///|
pub struct OutsideSize {
  width : Double
  height : Double
} derive(Debug)

///|
pub impl Show for OutsideSize with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct LogicalSize {
  width : Int
  height : Int
} derive(Debug)

///|
pub fn new_logical_size(width : Int, height : Int) -> LogicalSize {
  { width, height, }
}

///|
pub impl Show for LogicalSize with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct FrameBudget {
  updates : Int
  alpha : Double
  tick : Int
} derive(Debug)

///|
pub impl Show for FrameBudget with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct InputSnapshot {
  cursor_x : Double
  cursor_y : Double
  wheel_x : Double
  wheel_y : Double
  pressed_keys : Array[Int]
  pressed_mouse_buttons : Array[Int]
  touches : Array[TouchPoint]
  gamepads : Array[GamepadSnapshot]
} derive(Debug)

///|
pub impl Show for InputSnapshot with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub enum TouchSource {
  Direct
  Indirect
  Mouse
  Unknown
} derive(Debug)

///|
pub impl Show for TouchSource with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn touch_source_to_int(source : TouchSource) -> Int {
  match source {
    TouchSource::Direct => 0
    TouchSource::Indirect => 1
    TouchSource::Mouse => 2
    TouchSource::Unknown => 3
  }
}

///|
pub fn touch_source_from_int(source : Int) -> TouchSource {
  match source {
    0 => TouchSource::Direct
    1 => TouchSource::Indirect
    2 => TouchSource::Mouse
    _ => TouchSource::Unknown
  }
}

///|
pub struct TouchPoint {
  id : Int
  x : Double
  y : Double
  source : TouchSource
} derive(Debug)

///|
pub impl Show for TouchPoint with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct GamepadSnapshot {
  id : Int
  axes : Array[Double]
  pressed_buttons : Array[Int]
} derive(Debug)

///|
pub impl Show for GamepadSnapshot with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn new_outside_size(width : Double, height : Double) -> OutsideSize {
  { width, height, }
}

///|
pub fn new_frame_budget(
  updates : Int,
  alpha : Double,
  tick : Int,
) -> FrameBudget {
  { updates, alpha, tick, }
}

///|
pub fn new_touch_point(id : Int, x : Double, y : Double) -> TouchPoint {
  { id, x, y, source: TouchSource::Unknown, }
}

///|
pub fn new_touch_point_with_source(
  id : Int,
  x : Double,
  y : Double,
  source : TouchSource,
) -> TouchPoint {
  { id, x, y, source, }
}

///|
pub fn new_gamepad_snapshot(
  id : Int,
  axes : Array[Double],
  pressed_buttons : Array[Int],
) -> GamepadSnapshot {
  { id, axes, pressed_buttons, }
}

///|
pub fn new_input_snapshot_full(
  cursor_x : Double,
  cursor_y : Double,
  wheel_x : Double,
  wheel_y : Double,
  pressed_keys : Array[Int],
  pressed_mouse_buttons : Array[Int],
  touches : Array[TouchPoint],
  gamepads : Array[GamepadSnapshot],
) -> InputSnapshot {
  {
    cursor_x,
    cursor_y,
    wheel_x,
    wheel_y,
    pressed_keys,
    pressed_mouse_buttons,
    touches,
    gamepads,
  }
}

///|
pub fn new_input_snapshot(
  cursor_x : Double,
  cursor_y : Double,
  wheel_x : Double,
  wheel_y : Double,
  pressed_keys : Array[Int],
) -> InputSnapshot {
  new_input_snapshot_full(
    cursor_x,
    cursor_y,
    wheel_x,
    wheel_y,
    pressed_keys,
    [],
    [],
    [],
  )
}

///|
pub fn empty_input_snapshot() -> InputSnapshot {
  new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
}

///|
pub enum TouchPhase {
  Began
  Moved
  Stationary
  Ended
  Cancelled
} derive(Debug)

///|
pub impl Show for TouchPhase with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn touch_phase_to_int(phase : TouchPhase) -> Int {
  match phase {
    TouchPhase::Began => 0
    TouchPhase::Moved => 1
    TouchPhase::Stationary => 2
    TouchPhase::Ended => 3
    TouchPhase::Cancelled => 4
  }
}

///|
pub fn touch_phase_from_int(phase : Int) -> TouchPhase {
  match phase {
    0 => TouchPhase::Began
    1 => TouchPhase::Moved
    2 => TouchPhase::Stationary
    3 => TouchPhase::Ended
    4 => TouchPhase::Cancelled
    _ => TouchPhase::Began
  }
}

///|
pub struct TouchPointEx {
  id : Int
  x : Double
  y : Double
  phase : TouchPhase
  pressure : Double
  delta_x : Double
  delta_y : Double
} derive(Debug)

///|
pub impl Show for TouchPointEx with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn new_touch_point_ex(
  id : Int,
  x : Double,
  y : Double,
  phase : TouchPhase,
) -> TouchPointEx {
  { id, x, y, phase, pressure: 1.0, delta_x: 0.0, delta_y: 0.0, }
}

///|
pub fn new_touch_point_ex_full(
  id : Int,
  x : Double,
  y : Double,
  phase : TouchPhase,
  pressure : Double,
  delta_x : Double,
  delta_y : Double,
) -> TouchPointEx {
  { id, x, y, phase, pressure, delta_x, delta_y, }
}

///|
pub fn touch_point_from_ex(ex : TouchPointEx) -> TouchPoint {
  { id: ex.id, x: ex.x, y: ex.y, source: TouchSource::Unknown, }
}

///|
pub extend OutsideSize with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend OutsideSize with Show::{to_string, output}

///|
pub extend LogicalSize with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LogicalSize with Show::{to_string, output}

///|
pub extend FrameBudget with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FrameBudget with Show::{to_string, output}

///|
pub extend InputSnapshot with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend InputSnapshot with Show::{to_string, output}

///|
pub extend TouchSource with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TouchSource with Show::{to_string, output}

///|
pub extend TouchPoint with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TouchPoint with Show::{to_string, output}

///|
pub extend GamepadSnapshot with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GamepadSnapshot with Show::{to_string, output}

///|
pub extend TouchPhase with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TouchPhase with Show::{to_string, output}

///|
pub extend TouchPointEx with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TouchPointEx with Show::{to_string, output}
