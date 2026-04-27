///|
pub fn render_scene(
  node : SceneNode,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Double,
  screen_h : Double,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let frame = @renderer2d.RenderFrame2D::new(
    dst~,
    shader~,
    screen_w=screen_w.to_int(),
    screen_h=screen_h.to_int(),
  )
  render_node(cmds, node, frame, 0.0, 0.0)
  cmds
}

///|
fn render_node(
  cmds : Array[@gfx.DrawTrianglesCommand],
  node : SceneNode,
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  match node {
    Element(el) => render_element(cmds, el, frame, offset_x, offset_y)
    Fragment(children) =>
      for child in children {
        render_node(cmds, child, frame, offset_x, offset_y)
      }
    Show(condition~, child~) =>
      if condition() {
        render_node(cmds, child(), frame, offset_x, offset_y)
      }
    For(render~) => {
      let items = render()
      for item in items {
        render_node(cmds, item, frame, offset_x, offset_y)
      }
    }
    Component(render~) => render_node(cmds, render(), frame, offset_x, offset_y)
    Switch(sw) => {
      for c in sw.cases {
        if (c.when)() {
          render_node(cmds, (c.render)(), frame, offset_x, offset_y)
          return
        }
      }
      match sw.fallback {
        Some(fb) => render_node(cmds, fb(), frame, offset_x, offset_y)
        None => ()
      }
    }
    Text(_) | DynamicText(_) | Async(_) | ErrorBoundary(_) | RawHtml(_) => ()
  }
}

///|
fn render_element(
  cmds : Array[@gfx.DrawTrianglesCommand],
  el : @ui.VElement[Unit, SceneAttrValue],
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  match el.tag {
    "rect" => render_rect(cmds, el, frame, offset_x, offset_y)
    "label" => render_label(cmds, el, frame, offset_x, offset_y)
    "group" => render_group(cmds, el, frame, offset_x, offset_y)
    "line" => render_line(cmds, el, frame, offset_x, offset_y)
    "rect_outline" => render_rect_outline(cmds, el, frame, offset_x, offset_y)
    _ => ()
  }
}

// ============================================================
// Index-based attribute access (O(1) instead of O(n) linear search)
// Elements are built with fixed attribute order in elements.mbt,
// so we can access by index directly.
// ============================================================

///|
fn resolve_attr(attr : @ui.Attr[Unit, SceneAttrValue]) -> SceneAttrValue {
  match attr {
    VStatic(value) => value
    VDynamic(f) => f()
    VHandler(_) => SceneDouble(0.0)
  }
}

///|
fn attr_double(
  attr : @ui.Attr[Unit, SceneAttrValue],
  default_ : Double,
) -> Double {
  match resolve_attr(attr) {
    SceneDouble(v) => v
    SceneInt(v) => v.to_double()
    _ => default_
  }
}

///|
fn attr_int(attr : @ui.Attr[Unit, SceneAttrValue], default_ : Int) -> Int {
  match resolve_attr(attr) {
    SceneInt(v) => v
    SceneDouble(v) => v.to_int()
    _ => default_
  }
}

///|
fn attr_string(
  attr : @ui.Attr[Unit, SceneAttrValue],
  default_ : String,
) -> String {
  match resolve_attr(attr) {
    SceneText(v) => v
    _ => default_
  }
}

///|
// rect attrs order: x(0), y(1), w(2), h(3), fill(4), alpha(5)
fn render_rect(
  cmds : Array[@gfx.DrawTrianglesCommand],
  el : @ui.VElement[Unit, SceneAttrValue],
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let attrs = el.attrs
  let x = (if attrs.length() > 0 { attr_double(attrs[0].1, 0.0) } else { 0.0 }) +
    offset_x
  let y = (if attrs.length() > 1 { attr_double(attrs[1].1, 0.0) } else { 0.0 }) +
    offset_y
  let w = if attrs.length() > 2 { attr_double(attrs[2].1, 0.0) } else { 0.0 }
  let h = if attrs.length() > 3 { attr_double(attrs[3].1, 0.0) } else { 0.0 }
  let fill = if attrs.length() > 4 {
    attr_int(attrs[4].1, 0xFFFFFF)
  } else {
    0xFFFFFF
  }
  let alpha = if attrs.length() > 5 {
    attr_double(attrs[5].1, 1.0)
  } else {
    1.0
  }
  let color = @renderer2d.color_from_hex_alpha(fill, alpha)
  @renderer2d.append_rect_fill(
    cmds,
    frame,
    @renderer2d.RectFill2D::new(x~, y~, w~, h~, color~),
  )
  for child in el.children {
    render_node(cmds, child, frame, x, y)
  }
}

///|
// label attrs order: x(0), y(1), content(2), color(3), scale(4)
fn render_label(
  cmds : Array[@gfx.DrawTrianglesCommand],
  el : @ui.VElement[Unit, SceneAttrValue],
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let attrs = el.attrs
  let x = (if attrs.length() > 0 { attr_double(attrs[0].1, 0.0) } else { 0.0 }) +
    offset_x
  let y = (if attrs.length() > 1 { attr_double(attrs[1].1, 0.0) } else { 0.0 }) +
    offset_y
  let content = if attrs.length() > 2 {
    attr_string(attrs[2].1, "")
  } else {
    ""
  }
  let color_hex = if attrs.length() > 3 {
    attr_int(attrs[3].1, 0xFFFFFF)
  } else {
    0xFFFFFF
  }
  let scale = if attrs.length() > 4 {
    attr_double(attrs[4].1, 1.0)
  } else {
    1.0
  }
  let color = @renderer2d.color_from_hex(color_hex)
  let chars = string_to_char_codes(content)
  @renderer2d.append_dot_text(
    cmds,
    frame,
    @renderer2d.DotText2D::new(chars~, cx=x, cy=y, color~, scale~),
  )
}

///|
// group attrs order: x(0), y(1)
fn render_group(
  cmds : Array[@gfx.DrawTrianglesCommand],
  el : @ui.VElement[Unit, SceneAttrValue],
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let attrs = el.attrs
  let x = (if attrs.length() > 0 { attr_double(attrs[0].1, 0.0) } else { 0.0 }) +
    offset_x
  let y = (if attrs.length() > 1 { attr_double(attrs[1].1, 0.0) } else { 0.0 }) +
    offset_y
  for child in el.children {
    render_node(cmds, child, frame, x, y)
  }
}

///|
// line attrs order: x0(0), y0(1), x1(2), y1(3), width(4), color(5)
fn render_line(
  cmds : Array[@gfx.DrawTrianglesCommand],
  el : @ui.VElement[Unit, SceneAttrValue],
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let attrs = el.attrs
  let x0 = (if attrs.length() > 0 { attr_double(attrs[0].1, 0.0) } else { 0.0 }) +
    offset_x
  let y0 = (if attrs.length() > 1 { attr_double(attrs[1].1, 0.0) } else { 0.0 }) +
    offset_y
  let x1 = (if attrs.length() > 2 { attr_double(attrs[2].1, 0.0) } else { 0.0 }) +
    offset_x
  let y1 = (if attrs.length() > 3 { attr_double(attrs[3].1, 0.0) } else { 0.0 }) +
    offset_y
  let width = if attrs.length() > 4 {
    attr_double(attrs[4].1, 1.0)
  } else {
    1.0
  }
  let color_hex = if attrs.length() > 5 {
    attr_int(attrs[5].1, 0xFFFFFF)
  } else {
    0xFFFFFF
  }
  @renderer2d.append_line(
    cmds,
    frame,
    @renderer2d.Line2D::new(
      x0~,
      y0~,
      x1~,
      y1~,
      width~,
      color=@renderer2d.color_from_hex(color_hex),
    ),
  )
}

///|
// rect_outline attrs order: x(0), y(1), w(2), h(3), line_width(4), color(5)
fn render_rect_outline(
  cmds : Array[@gfx.DrawTrianglesCommand],
  el : @ui.VElement[Unit, SceneAttrValue],
  frame : @renderer2d.RenderFrame2D,
  offset_x : Double,
  offset_y : Double,
) -> Unit {
  let attrs = el.attrs
  let x = (if attrs.length() > 0 { attr_double(attrs[0].1, 0.0) } else { 0.0 }) +
    offset_x
  let y = (if attrs.length() > 1 { attr_double(attrs[1].1, 0.0) } else { 0.0 }) +
    offset_y
  let w = if attrs.length() > 2 { attr_double(attrs[2].1, 0.0) } else { 0.0 }
  let h = if attrs.length() > 3 { attr_double(attrs[3].1, 0.0) } else { 0.0 }
  let line_width = if attrs.length() > 4 {
    attr_double(attrs[4].1, 1.0)
  } else {
    1.0
  }
  let color_hex = if attrs.length() > 5 {
    attr_int(attrs[5].1, 0xFFFFFF)
  } else {
    0xFFFFFF
  }
  @renderer2d.append_rect_outline(
    cmds,
    frame,
    @renderer2d.RectOutline2D::new(
      x~,
      y~,
      w~,
      h~,
      line_width~,
      color=@renderer2d.color_from_hex(color_hex),
    ),
  )
}

///|
fn string_to_char_codes(s : String) -> Array[Int] {
  let codes : Array[Int] = []
  for ch in s {
    let code = ch.to_int()
    // glyph_pattern uses 0-9 for digits, but ASCII for letters
    if code >= 48 && code <= 57 {
      codes.push(code - 48)
    } else {
      codes.push(code)
    }
  }
  codes
}
