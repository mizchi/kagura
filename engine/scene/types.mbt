///|
pub enum SceneAttrValue {
  SceneInt(Int)
  SceneDouble(Double)
  SceneText(String)
} derive(Debug)

///|
pub impl Show for SceneAttrValue with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub type SceneNode = @ui.Node[Unit, SceneAttrValue]

///|
pub extend SceneAttrValue with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SceneAttrValue with Show::{to_string, output}
