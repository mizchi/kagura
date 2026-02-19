///|
/// UI contracts.
///
/// Reference:
/// - mizchi/layout

///|
pub struct UINodeId {
  value : Int
} derive(Show)

///|
pub struct LayoutConstraint {
  min_width : Double
  min_height : Double
  max_width : Double
  max_height : Double
} derive(Show)

///|
pub struct LayoutRect {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Show)

///|
pub struct LayoutResult {
  node_id : UINodeId
  rect : LayoutRect
} derive(Show)

///|
pub enum UIEvent {
  PointerDown(Double, Double)
  PointerUp(Double, Double)
  PointerMove(Double, Double)
  Scroll(Double, Double)
  KeyDown(Int)
  KeyUp(Int)
} derive(Show)

///|
pub trait LayoutEngine {
  compute_layout(Self, root : UINodeId, constraint : LayoutConstraint) -> Array[
    LayoutResult,
  ] raise
}

///|
pub trait UIInputAdapter {
  from_input_snapshot(Self, snapshot : @core.InputSnapshot) -> Array[UIEvent]
}

///|
pub trait UIRenderAdapter {
  build_draw_commands(
    Self,
    frame : @core.FrameBudget,
    layouts : Array[LayoutResult],
    target : @gfx.ImageHandle,
  ) -> Array[@gfx.DrawTrianglesCommand] raise
}

///|
pub fn default_layout_constraint(
  width : Double,
  height : Double,
) -> LayoutConstraint {
  { min_width: 0.0, min_height: 0.0, max_width: width, max_height: height }
}
