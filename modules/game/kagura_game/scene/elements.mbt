///|
pub fn rect(
  x? : Double = 0.0,
  y? : Double = 0.0,
  w~ : Double,
  h~ : Double,
  fill? : Int = 0xFFFFFF,
  alpha? : Double = 1.0,
  children? : Array[SceneNode] = [],
) -> SceneNode {
  @ui.h(
    "rect",
    [
      ("x", @ui.attr_static(SceneDouble(x))),
      ("y", @ui.attr_static(SceneDouble(y))),
      ("w", @ui.attr_static(SceneDouble(w))),
      ("h", @ui.attr_static(SceneDouble(h))),
      ("fill", @ui.attr_static(SceneInt(fill))),
      ("alpha", @ui.attr_static(SceneDouble(alpha))),
    ],
    children,
  )
}

///|
pub fn label(
  x? : Double = 0.0,
  y? : Double = 0.0,
  content~ : String,
  color? : Int = 0xFFFFFF,
  scale? : Double = 1.0,
) -> SceneNode {
  @ui.h(
    "label",
    [
      ("x", @ui.attr_static(SceneDouble(x))),
      ("y", @ui.attr_static(SceneDouble(y))),
      ("content", @ui.attr_static(SceneText(content))),
      ("color", @ui.attr_static(SceneInt(color))),
      ("scale", @ui.attr_static(SceneDouble(scale))),
    ],
    [],
  )
}

///|
pub fn group(
  x? : Double = 0.0,
  y? : Double = 0.0,
  children~ : Array[SceneNode],
) -> SceneNode {
  @ui.h(
    "group",
    [
      ("x", @ui.attr_static(SceneDouble(x))),
      ("y", @ui.attr_static(SceneDouble(y))),
    ],
    children,
  )
}

///|
pub fn line(
  x0~ : Double,
  y0~ : Double,
  x1~ : Double,
  y1~ : Double,
  width? : Double = 1.0,
  color? : Int = 0xFFFFFF,
) -> SceneNode {
  @ui.h(
    "line",
    [
      ("x0", @ui.attr_static(SceneDouble(x0))),
      ("y0", @ui.attr_static(SceneDouble(y0))),
      ("x1", @ui.attr_static(SceneDouble(x1))),
      ("y1", @ui.attr_static(SceneDouble(y1))),
      ("width", @ui.attr_static(SceneDouble(width))),
      ("color", @ui.attr_static(SceneInt(color))),
    ],
    [],
  )
}

///|
pub fn rect_outline(
  x~ : Double,
  y~ : Double,
  w~ : Double,
  h~ : Double,
  line_width? : Double = 1.0,
  color? : Int = 0xFFFFFF,
) -> SceneNode {
  @ui.h(
    "rect_outline",
    [
      ("x", @ui.attr_static(SceneDouble(x))),
      ("y", @ui.attr_static(SceneDouble(y))),
      ("w", @ui.attr_static(SceneDouble(w))),
      ("h", @ui.attr_static(SceneDouble(h))),
      ("line_width", @ui.attr_static(SceneDouble(line_width))),
      ("color", @ui.attr_static(SceneInt(color))),
    ],
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
