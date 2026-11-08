///|
#derive(Debug, Eq)
pub(all) enum RunStage {
  Backend
  Options
  Platform
  Surface
  Graphics
  Image
  Shader
  Frame
  Input
  Resize
  Update
  Draw
  Render
  Audio
}

///|
#derive(Debug)
pub struct RunFailure {
  stage : RunStage
  message : String
}

///|
#derive(Debug)
pub enum RunStatus {
  Starting
  Running
  Stopped
  Failed(RunFailure)
}

///|
#derive(Debug)
pub(all) enum StartupReadiness {
  Pending
  Ready
  Unavailable(String)
}

///|
pub struct RunSession {
  mut state : RunStatus
  clock : () -> Double
  report : (RunFailure) -> Unit
  disposers : Array[() -> Unit]
  mut cancel_frame : (() -> Unit)?
  mut frame : (() -> Unit)?
  mut frame_generation : Int32
}

///|
pub extend RunFailure with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RunStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StartupReadiness with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub impl Show for RunStage with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub extend RunStage with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RunStage with Eq::{equal, not_equal}

///|
pub extend RunStage with Show::{output, to_string}
