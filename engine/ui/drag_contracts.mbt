///|
pub(all) enum UIPointerId {
  Mouse
  Touch(Int)
} derive(Debug, Eq)

///|
/// One normalized primary pointer, in the caller's logical coordinate space.
/// Touch release retains the owned finger's final sampled position.
pub struct UIPointerFrame {
  pointer : UIPointerId
  x : Double
  y : Double
  pressed : Bool
  released : Bool
  down : Bool
  cancelled : Bool
}

///|
/// Host adapters may supply normalized pointer frames directly.
pub fn UIPointerFrame::new(
  pointer : UIPointerId,
  x : Double,
  y : Double,
  pressed? : Bool = false,
  released? : Bool = false,
  down? : Bool = false,
  cancelled? : Bool = false,
) -> UIPointerFrame {
  { pointer, x, y, pressed, released, down, cancelled, }
}

///|
pub(all) enum UIDragCancelReason {
  Explicit
  InputCancelled
  Disabled
  NoTarget
} derive(Debug, Eq)

///|
pub(all) enum UIDragPhase {
  Start
  Move
  Enter
  Leave
  Drop
  Cancel(UIDragCancelReason)
  End(Bool) // true only after an accepted Drop
} derive(Debug, Eq)

///|
/// Immutable event data. Enter/Leave name the entered/left target respectively.
pub struct UIDragEvent {
  phase : UIDragPhase
  source : UINodeId
  target : UINodeId?
  pointer : UIPointerId
  start_x : Double
  start_y : Double
  x : Double
  y : Double
} derive(Debug)

///|
/// Read-only presentation state; the controller owns the mutable gesture.
pub struct UIDragSnapshot {
  source : UINodeId
  target : UINodeId?
  pointer : UIPointerId
  start_x : Double
  start_y : Double
  x : Double
  y : Double
  dragging : Bool
}

///|
pub impl Show for UIPointerId with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub impl Show for UIDragPhase with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub impl Show for UIDragCancelReason with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub extend UIPointerId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIPointerId with Eq::{not_equal, equal}

///|
pub extend UIPointerId with Show::{to_string, output}

///|
pub extend UIDragPhase with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIDragPhase with Eq::{not_equal, equal}

///|
pub extend UIDragPhase with Show::{to_string, output}

///|
pub extend UIDragCancelReason with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIDragCancelReason with Eq::{not_equal, equal}

///|
pub extend UIDragCancelReason with Show::{to_string, output}

///|
pub extend UIDragEvent with @moonbitlang/core/debug.Debug::{to_repr}
