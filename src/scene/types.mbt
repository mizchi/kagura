///|
pub enum SceneAttrValue {
  SceneInt(Int)
  SceneDouble(Double)
  SceneText(String)
} derive(Show)

///|
pub type SceneNode = @ui.Node[Unit, SceneAttrValue]
