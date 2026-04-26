///|
pub enum SceneAttrValue {
  SceneInt(Int)
  SceneDouble(Double)
  SceneText(String)
} derive(Debug)

///|
pub impl Show for SceneAttrValue with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub type SceneNode = @ui.Node[Unit, SceneAttrValue]
