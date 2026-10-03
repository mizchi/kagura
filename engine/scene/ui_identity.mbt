///|
/// Give a UI element a stable identity in both debug and release snapshots.
/// Unlike inspector key/name/subject metadata, this is part of the runtime UI
/// contract used for modal focus, accessibility and automated input.
pub fn ui_key(id : String, node : SceneNode) -> SceneNode {
  match node {
    Element(el) => {
      let attrs = el.attrs.filter(pair => pair.0 != "ui_key")
      attrs.push(("ui_key", @ui.attr_static(SceneText(id))))
      @ui.h(el.tag, attrs, el.children)
    }
    _ => abort("ui_key() expects an element")
  }
}
