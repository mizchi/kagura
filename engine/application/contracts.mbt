///|
/// Execution callbacks and presentation options, separate from portable data.
/// Ebiten refs:
/// - run.go (Game, Layout, Draw, Update)
/// - gameforui.go (final screen customization)

///|
pub enum EngineTermination {
  RegularTermination
  Fatal(String)
} derive(Debug)

///|
pub impl Show for EngineTermination with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct RunOptions {
  init_unfocused : Bool
  screen_transparent : Bool
  screen_cleared_every_frame : Bool
} derive(Debug)

///|
pub impl Show for RunOptions with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(open) trait Game {
  /// Ebiten ref: Game.Layout in run.go
  fn layout(Self, outside : @core.OutsideSize) -> @core.LogicalSize

  /// Ebiten ref: Game.Update in run.go
  fn update(Self, input : @core.InputSnapshot) -> EngineTermination?

  /// Ebiten ref: Game.Draw in run.go
  fn draw(Self, frame : @core.FrameBudget) -> Unit
}

///|
pub(open) trait FinalScreenDrawer {
  /// Ebiten ref: FinalScreenDrawer.DrawFinalScreen in run.go/gameforui.go
  fn draw_final_screen(Self, frame : @core.FrameBudget) -> Unit
}

///|
pub struct NoopGame {
  logical_width : Int
  logical_height : Int
}

///|
pub fn new_noop_game(width : Int, height : Int) -> NoopGame {
  { logical_width: width, logical_height: height, }
}

///|
pub impl Game for NoopGame with fn layout(self, _outside) {
  @core.new_logical_size(self.logical_width, self.logical_height)
}

///|
pub impl Game for NoopGame with fn update(_self, _input) {
  None
}

///|
pub impl Game for NoopGame with fn draw(_self, _frame) {
  ()
}

///|
pub fn default_run_options() -> RunOptions {
  new_run_options()
}

///|
pub fn new_run_options(
  init_unfocused? : Bool = false,
  screen_transparent? : Bool = false,
  screen_cleared_every_frame? : Bool = true,
) -> RunOptions {
  { init_unfocused, screen_transparent, screen_cleared_every_frame, }
}

///|
pub fn[T : Game] run_game(game : T, options : RunOptions) -> Unit {
  let _ = options
  let outside = @core.new_outside_size(640.0, 480.0)
  let logical = game.layout(outside)
  let _ = logical
  let _ = game.update(@core.empty_input_snapshot())
  game.draw(@core.new_frame_budget(0, 0.0, 0))
}

///|
pub extend EngineTermination with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EngineTermination with Show::{to_string, output}

///|
pub extend RunOptions with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RunOptions with Show::{to_string, output}

///|
pub extend NoopGame with Game::{draw, update, layout}
