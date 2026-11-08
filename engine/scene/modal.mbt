///|
/// Paint the background and dimmer without exposing them to UI observation.
/// The dialog must have an element root, with its own stable ui_key. Pair this
/// rendering component with UIModalLayer for input scoping and focus restoration.
pub fn modal_overlay(
  background : SceneNode,
  dialog : SceneNode,
  width~ : Double,
  height~ : Double,
  color~ : Int32 = 0x071319,
  alpha~ : Double = 0.78,
) -> SceneNode {
  let dialog = match dialog {
    Element(el) =>
      @ui.h(
        el.tag,
        [
          ..el.attrs.filter(pair => pair.0 != "role"),
          ("role", @ui.attr_static(SceneText("dialog"))),
        ],
        el.children,
      )
    _ => abort("modal_overlay() expects an element dialog root")
  }
  fragment([
    group(ui_hidden=true, children=[background]),
    group(ui_hidden=true, children=[rect(w=width, h=height, fill=color, alpha~)]),
    dialog,
  ])
}
