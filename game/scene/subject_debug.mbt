///|
/// Annotate one visual element with a game-owned logical subject. No extra hierarchy node.
/// Match bind_subject's ID, not the element's key or resolved render path.
/// Multiple visuals may reference one subject. Children do not inherit it.
/// Without a current matching binding the Inspector shows no fields for this node.
/// Release returns the element unchanged and adds no subject metadata.
#inline
pub fn subject(id : String, node : SceneNode) -> SceneNode {
  match node {
    Element(el) => {
      let attrs = el.attrs.filter(pair => pair.0 != "subject")
      attrs.push(("subject", @ui.attr_static(SceneText(id))))
      @ui.h(el.tag, attrs, el.children)
    }
    _ =>
      abort(
        "subject() expects an element; annotate each generated element inside its generator",
      )
  }
}

///|
fn with_metadata(
  key : String,
  name : String,
  attrs : Array[(String, @ui.Attr[Unit, SceneAttrValue])],
) -> Array[(String, @ui.Attr[Unit, SceneAttrValue])] {
  attrs.push(("key", @ui.attr_static(SceneText(key))))
  attrs.push(("name", @ui.attr_static(SceneText(name))))
  attrs
}
