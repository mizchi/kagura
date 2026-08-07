///|
/// UI snapshot: a serializable description of a laid-out UI tree.
///
/// This is the introspection surface the verification tooling consumes.
/// A canvas-rendered UI has no DOM, so nothing outside the engine can see
/// where the nodes are; publishing this snapshot alongside a captured frame
/// is what lets the deterministic gates (text overflow, clipping, offscreen,
/// overlap, hit-box drift) and vlmkit's `diff png --elements-json` reason
/// about individual UI nodes instead of one opaque canvas.
///
/// Consumers:
/// - `scripts/ui-snapshot-to-vlmkit-elements.mjs` (vlmkit elements-json)
/// - `scripts/ui-integrity-gate.mjs` (deterministic UI defect gate)

///|
pub(all) struct UISnapshotRect {
  left : Double
  top : Double
  width : Double
  height : Double
} derive(Debug)

///|
pub impl Show for UISnapshotRect with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct UISafeArea {
  top : Double
  right : Double
  bottom : Double
  left : Double
} derive(Debug)

///|
pub impl Show for UISafeArea with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Measured extent of a node's text, as reported by `@text.TextRenderer::measure`.
/// Compared against the node rect to detect overflow the renderer will clip.
pub(all) struct UITextMetrics {
  width : Double
  height : Double
} derive(Debug)

///|
pub impl Show for UITextMetrics with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// One node of a UI snapshot.
///
/// `path` is a stable structural address (`hud[0]>bar[1]`); `id` and `classes`
/// are the author-supplied names the tooling reports defects against. `clip` is
/// the effective scissor rect at draw time, `hit` the rect the pointer is
/// actually tested against (they diverge when a widget's hit box drifts from
/// what is drawn).
pub(all) struct UISnapshotNode {
  path : String
  id : String
  role : String
  classes : String
  left : Double
  top : Double
  width : Double
  height : Double
  z : Int
  visible : Bool
  clip : UISnapshotRect?
  text : String?
  text_measured : UITextMetrics?
  focusable : Bool
  focus_index : Int
  focused : Bool
  hit : UISnapshotRect?
} derive(Debug)

///|
pub impl Show for UISnapshotNode with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// A node with every optional field cleared. Fill in with struct update syntax:
/// `{ ..default_ui_snapshot_node(), path: "hud[0]", id: "hud", width: 640.0 }`
pub fn default_ui_snapshot_node() -> UISnapshotNode {
  {
    path: "",
    id: "",
    role: "node",
    classes: "",
    left: 0.0,
    top: 0.0,
    width: 0.0,
    height: 0.0,
    z: 0,
    visible: true,
    clip: None,
    text: None,
    text_measured: None,
    focusable: false,
    focus_index: -1,
    focused: false,
    hit: None,
  }
}

///|
pub(all) struct UISnapshot {
  screen_width : Double
  screen_height : Double
  dpr : Double
  safe_area : UISafeArea
  frame : Int
  state : String
  nodes : Array[UISnapshotNode]
  focus_order : Array[String]
} derive(Debug)

///|
pub impl Show for UISnapshot with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn default_ui_snapshot(
  screen_width~ : Double,
  screen_height~ : Double,
) -> UISnapshot {
  {
    screen_width,
    screen_height,
    dpr: 1.0,
    safe_area: { top: 0.0, right: 0.0, bottom: 0.0, left: 0.0 },
    frame: 0,
    state: "",
    nodes: [],
    focus_order: [],
  }
}

///|
/// Derive snapshot nodes straight from layout results.
///
/// This is the zero-effort path: it carries geometry only, which is enough for
/// offscreen / zero-size / overlap detection and for `--elements-json`
/// attribution. Text and focus metadata have to come from the caller, which is
/// the only place that knows a node's role.
pub fn ui_snapshot_nodes_from_layouts(
  layouts : Array[LayoutResult],
) -> Array[UISnapshotNode] {
  let nodes : Array[UISnapshotNode] = []
  for i, layout in layouts {
    let r = layout.rect
    nodes.push({
      ..default_ui_snapshot_node(),
      path: "node[" + i.to_string() + "]",
      id: "node_" + layout.node_id.value.to_string(),
      left: r.x,
      top: r.y,
      width: r.width,
      height: r.height,
      z: i,
    })
  }
  nodes
}

///|
/// Serialize a Double as JSON. NaN / infinity are not representable in JSON and
/// would produce a document no consumer can parse, so they collapse to 0.
fn json_double(value : Double) -> String {
  if value.is_nan() || value.is_inf() {
    return "0"
  }
  value.to_string()
}

///|
/// Write `"key": "value"`.
///
/// The value goes through `Json::string(..).stringify()` rather than a
/// hand-rolled escape: that also quotes the string and covers control
/// characters and escapes beyond the obvious five, so a label carrying one
/// cannot produce a document the gate then fails to parse.
fn append_json_string(
  buf : StringBuilder,
  key : String,
  value : String,
) -> Unit {
  buf.write_string("\"")
  buf.write_string(key)
  buf.write_string("\":")
  buf.write_string(Json::string(value).stringify())
}

///|
fn append_json_double(
  buf : StringBuilder,
  key : String,
  value : Double,
) -> Unit {
  buf.write_string("\"")
  buf.write_string(key)
  buf.write_string("\":")
  buf.write_string(json_double(value))
}

///|
fn append_rect_fields(buf : StringBuilder, rect : UISnapshotRect) -> Unit {
  append_json_double(buf, "left", rect.left)
  buf.write_string(",")
  append_json_double(buf, "top", rect.top)
  buf.write_string(",")
  append_json_double(buf, "width", rect.width)
  buf.write_string(",")
  append_json_double(buf, "height", rect.height)
}

///|
fn append_node_json(buf : StringBuilder, node : UISnapshotNode) -> Unit {
  buf.write_string("{")
  append_json_string(buf, "path", node.path)
  buf.write_string(",")
  append_json_string(buf, "id", node.id)
  buf.write_string(",")
  append_json_string(buf, "tag", node.role)
  buf.write_string(",")
  append_json_string(buf, "role", node.role)
  buf.write_string(",")
  append_json_string(buf, "classes", node.classes)
  buf.write_string(",")
  append_json_double(buf, "left", node.left)
  buf.write_string(",")
  append_json_double(buf, "top", node.top)
  buf.write_string(",")
  append_json_double(buf, "width", node.width)
  buf.write_string(",")
  append_json_double(buf, "height", node.height)
  buf.write_string(",\"z\":")
  buf.write_string(node.z.to_string())
  buf.write_string(",\"visible\":")
  buf.write_string(if node.visible { "true" } else { "false" })
  match node.clip {
    Some(clip) => {
      buf.write_string(",\"clip\":{")
      append_rect_fields(buf, clip)
      buf.write_string("}")
    }
    None => ()
  }
  match node.text {
    Some(text) => {
      buf.write_string(",")
      append_json_string(buf, "text", text)
    }
    None => ()
  }
  match node.text_measured {
    Some(metrics) => {
      buf.write_string(",\"text_measured\":{")
      append_json_double(buf, "width", metrics.width)
      buf.write_string(",")
      append_json_double(buf, "height", metrics.height)
      buf.write_string("}")
    }
    None => ()
  }
  buf.write_string(",\"focusable\":")
  buf.write_string(if node.focusable { "true" } else { "false" })
  buf.write_string(",\"focus_index\":")
  buf.write_string(node.focus_index.to_string())
  buf.write_string(",\"focused\":")
  buf.write_string(if node.focused { "true" } else { "false" })
  match node.hit {
    Some(hit) => {
      buf.write_string(",\"hit\":{")
      append_rect_fields(buf, hit)
      buf.write_string("}")
    }
    None => ()
  }
  buf.write_string("}")
}

///|
/// Serialize the snapshot to the introspection JSON.
///
/// Each node carries both `role` and a `tag` alias holding the same value, so
/// the document is directly consumable as a vlmkit `--elements-json` payload
/// (which requires `tag`) without a conversion step.
pub fn UISnapshot::to_json(self : UISnapshot) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"screen\":{")
  append_json_double(buf, "width", self.screen_width)
  buf.write_string(",")
  append_json_double(buf, "height", self.screen_height)
  buf.write_string(",")
  append_json_double(buf, "dpr", self.dpr)
  buf.write_string(",\"safe_area\":{")
  append_json_double(buf, "top", self.safe_area.top)
  buf.write_string(",")
  append_json_double(buf, "right", self.safe_area.right)
  buf.write_string(",")
  append_json_double(buf, "bottom", self.safe_area.bottom)
  buf.write_string(",")
  append_json_double(buf, "left", self.safe_area.left)
  buf.write_string("}},\"frame\":")
  buf.write_string(self.frame.to_string())
  buf.write_string(",")
  append_json_string(buf, "state", self.state)
  buf.write_string(",\"nodes\":[")
  for i, node in self.nodes {
    if i > 0 {
      buf.write_string(",")
    }
    append_node_json(buf, node)
  }
  buf.write_string("],\"focus_order\":[")
  for i, id in self.focus_order {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(Json::string(id).stringify())
  }
  buf.write_string("]}")
  buf.to_string()
}
