///|
/// Role/focus annotate logical UI state for snapshots; callers dispatch keys.
/// A focused rectangle is also focusable. Rendering geometry is unchanged.
pub fn rect(
  key? : String = "",
  name? : String = key,
  x? : Double = 0.0,
  y? : Double = 0.0,
  w~ : Double,
  h~ : Double,
  fill? : Int = 0xFFFFFF,
  alpha? : Double = 1.0,
  role? : String = "",
  focusable? : Bool = false,
  focused? : Bool = false,
  focus_index? : Int = 0,
  children? : Array[SceneNode] = [],
) -> SceneNode {
  let attrs = [
    ("x", @ui.attr_static(SceneDouble(x))),
    ("y", @ui.attr_static(SceneDouble(y))),
    ("w", @ui.attr_static(SceneDouble(w))),
    ("h", @ui.attr_static(SceneDouble(h))),
    ("fill", @ui.attr_static(SceneInt(fill))),
    ("alpha", @ui.attr_static(SceneDouble(alpha))),
  ]
  if role != "" {
    attrs.push(("role", @ui.attr_static(SceneText(role))))
  }
  if focusable || focused {
    attrs.push(("focusable", @ui.attr_static(SceneInt(1))))
    attrs.push(("focus_index", @ui.attr_static(SceneInt(focus_index))))
  }
  if focused {
    attrs.push(("focused", @ui.attr_static(SceneInt(1))))
  }
  @ui.h("rect", with_metadata(key, name, attrs), children)
}

///|
pub fn label(
  key? : String = "",
  name? : String = key,
  x? : Double = 0.0,
  y? : Double = 0.0,
  content~ : String,
  color? : Int = 0xFFFFFF,
  scale? : Double = 1.0,
) -> SceneNode {
  @ui.h(
    "label",
    with_metadata(key, name, [
      ("x", @ui.attr_static(SceneDouble(x))),
      ("y", @ui.attr_static(SceneDouble(y))),
      ("content", @ui.attr_static(SceneText(content))),
      ("color", @ui.attr_static(SceneInt(color))),
      ("scale", @ui.attr_static(SceneDouble(scale))),
    ]),
    [],
  )
}

///|
pub fn group(
  key? : String = "",
  name? : String = key,
  x? : Double = 0.0,
  y? : Double = 0.0,
  ui_hidden? : Bool = false,
  children~ : Array[SceneNode],
) -> SceneNode {
  let attrs = [
    ("x", @ui.attr_static(SceneDouble(x))),
    ("y", @ui.attr_static(SceneDouble(y))),
  ]
  // An active modal may hide its painted backdrop from the logical UI tree.
  if ui_hidden {
    attrs.push(("ui_hidden", @ui.attr_static(SceneInt(1))))
  }
  @ui.h("group", with_metadata(key, name, attrs), children)
}

///|
pub fn line(
  key? : String = "",
  name? : String = key,
  x0~ : Double,
  y0~ : Double,
  x1~ : Double,
  y1~ : Double,
  width? : Double = 1.0,
  color? : Int = 0xFFFFFF,
) -> SceneNode {
  @ui.h(
    "line",
    with_metadata(key, name, [
      ("x0", @ui.attr_static(SceneDouble(x0))),
      ("y0", @ui.attr_static(SceneDouble(y0))),
      ("x1", @ui.attr_static(SceneDouble(x1))),
      ("y1", @ui.attr_static(SceneDouble(y1))),
      ("width", @ui.attr_static(SceneDouble(width))),
      ("color", @ui.attr_static(SceneInt(color))),
    ]),
    [],
  )
}

///|
pub fn rect_outline(
  key? : String = "",
  name? : String = key,
  x~ : Double,
  y~ : Double,
  w~ : Double,
  h~ : Double,
  line_width? : Double = 1.0,
  color? : Int = 0xFFFFFF,
) -> SceneNode {
  @ui.h(
    "rect_outline",
    with_metadata(key, name, [
      ("x", @ui.attr_static(SceneDouble(x))),
      ("y", @ui.attr_static(SceneDouble(y))),
      ("w", @ui.attr_static(SceneDouble(w))),
      ("h", @ui.attr_static(SceneDouble(h))),
      ("line_width", @ui.attr_static(SceneDouble(line_width))),
      ("color", @ui.attr_static(SceneInt(color))),
    ]),
    [],
  )
}

///|
pub fn show(when : () -> Bool, child : () -> SceneNode) -> SceneNode {
  @ui.show(when, child)
}

///|
pub fn for_each(items : () -> Array[SceneNode]) -> SceneNode {
  @ui.for_each(items)
}

///|
pub fn fragment(children : Array[SceneNode]) -> SceneNode {
  @ui.fragment(children)
}

///|
pub fn switch_(
  cases~ : Array[@ui.MatchCase[Unit, SceneAttrValue]],
  fallback? : (() -> SceneNode)?,
) -> SceneNode {
  @ui.switch_(cases~, fallback?)
}

///|
pub fn match_case(
  when~ : () -> Bool,
  render~ : () -> SceneNode,
) -> @ui.MatchCase[Unit, SceneAttrValue] {
  @ui.match_case(when~, render~)
}
