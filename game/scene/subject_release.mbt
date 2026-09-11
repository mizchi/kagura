///|
#inline
pub fn subject(_id : String, node : SceneNode) -> SceneNode {
  node
}

///|
#inline
fn with_metadata(
  _key : String,
  _name : String,
  attrs : Array[(String, @ui.Attr[Unit, SceneAttrValue])],
) -> Array[(String, @ui.Attr[Unit, SceneAttrValue])] {
  attrs
}
