///|
/// UI node tree and style definitions.

///|
#derive(Debug)
pub(all) enum UIDirection {
  Row
  Column
}

///|
pub impl Show for UIDirection with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub(all) enum UISizing {
  Fixed(Double)
  Percent(Double)
  Auto
}

///|
pub impl Show for UISizing with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub(all) enum UIFlexWrap {
  NoWrap
  Wrap
}

///|
pub impl Show for UIFlexWrap with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug, Eq)
pub(all) enum UIAlignment {
  Start
  End
  FlexStart
  FlexEnd
  Center
  SpaceBetween
  SpaceAround
  SpaceEvenly
  Stretch
  Baseline
}

///|
pub impl Show for UIAlignment with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
#derive(Debug)
pub(all) struct UINodeStyle {
  direction : UIDirection
  width : UISizing
  height : UISizing
  padding_left : Double
  padding_right : Double
  padding_top : Double
  padding_bottom : Double
  gap : Double
  align : UIAlignment
  justify_content : UIAlignment
  flex_wrap : UIFlexWrap
}

///|
pub impl Show for UINodeStyle with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn default_node_style() -> UINodeStyle {
  {
    direction: UIDirection::Row,
    width: UISizing::Auto,
    height: UISizing::Auto,
    padding_left: 0.0,
    padding_right: 0.0,
    padding_top: 0.0,
    padding_bottom: 0.0,
    gap: 0.0,
    align: UIAlignment::Start,
    justify_content: UIAlignment::Start,
    flex_wrap: UIFlexWrap::NoWrap,
  }
}

///|
#derive(Debug)
pub struct UINode {
  id : UINodeId
  style : UINodeStyle
  children : Array[UINodeId]
}

///|
pub impl Show for UINode with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct UITree {
  nodes : Map[Int32, UINode]
  mut next_id : Int32
}

///|
pub fn UITree::new() -> UITree {
  { nodes: Map([]), next_id: 1, }
}

///|
pub fn UITree::add_node(
  self : UITree,
  style : UINodeStyle,
  children : Array[UINodeId],
) -> UINodeId {
  let id : UINodeId = { value: self.next_id, }
  self.next_id = self.next_id + 1
  let node : UINode = { id, style, children, }
  self.nodes.set(id.value, node)
  id
}

///|
pub fn UITree::get_node(self : UITree, id : UINodeId) -> UINode? {
  self.nodes.get(id.value)
}

///|
pub fn UITree::node_count(self : UITree) -> Int32 {
  self.nodes.length()
}

///|
fn ui_clamp(value : Double, min_val : Double, max_val : Double) -> Double {
  let clamped = if value > max_val { max_val } else { value }
  if clamped < min_val {
    min_val
  } else {
    clamped
  }
}

///|
fn ui_compute_justify(
  justify : UIAlignment,
  free_space : Double,
  item_count : Int32,
) -> (Double, Double) {
  if item_count == 0 {
    return (0.0, 0.0)
  }
  if free_space < 0.0 {
    match justify {
      SpaceBetween | SpaceAround | SpaceEvenly => return (0.0, 0.0)
      _ => ()
    }
  }
  match justify {
    Start | FlexStart => (0.0, 0.0)
    End | FlexEnd => (free_space, 0.0)
    Center => (free_space / 2.0, 0.0)
    SpaceBetween =>
      if item_count == 1 {
        (0.0, 0.0)
      } else {
        (0.0, free_space / (item_count - 1).to_double())
      }
    SpaceAround => {
      let gap = free_space / item_count.to_double()
      (gap / 2.0, gap)
    }
    SpaceEvenly => {
      let gap = free_space / (item_count + 1).to_double()
      (gap, gap)
    }
    Stretch | Baseline => (0.0, 0.0)
  }
}

///|
fn ui_compute_align_offset(align : UIAlignment, free_space : Double) -> Double {
  if free_space <= 0.0 {
    return 0.0
  }
  match align {
    Start | FlexStart => 0.0
    End | FlexEnd => free_space
    Center | SpaceAround | SpaceEvenly => free_space / 2.0
    SpaceBetween | Stretch | Baseline => 0.0
  }
}

///|
pub extend UIDirection with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIDirection with Show::{to_string, output}

///|
pub extend UISizing with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UISizing with Show::{to_string, output}

///|
pub extend UIFlexWrap with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIFlexWrap with Show::{to_string, output}

///|
pub extend UIAlignment with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UIAlignment with Eq::{not_equal, equal}

///|
pub extend UIAlignment with Show::{to_string, output}

///|
pub extend UINodeStyle with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UINodeStyle with Show::{to_string, output}

///|
pub extend UINode with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend UINode with Show::{to_string, output}
