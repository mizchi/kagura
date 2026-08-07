// ============================================================
// UI snapshot — introspection for verification tooling
// ============================================================
//
// Publishes where every UI node ended up, what text it carries and how wide
// that text actually renders. A canvas UI has no DOM, so this is the only way
// `scripts/ui-integrity-gate.mjs` and `vlmkit diff png --elements-json` can
// name a node instead of seeing one opaque canvas.

///|
fn role_name(role : NodeRole) -> String {
  match role {
    Background => "background"
    Header => "header"
    Footer => "footer"
    Panel => "panel"
    Button => "button"
    Label => "label"
  }
}

///|
/// Decode the glyph codes `ascii()` produced back into a readable string.
/// Digits were remapped to 0-9 for `glyph_pattern`; everything else is ASCII.
fn decode_glyphs(chars : Array[Int]) -> String {
  let buf = StringBuilder::new()
  for code in chars {
    let c = if code >= 0 && code <= 9 { code + 48 } else { code }
    buf.write_char(c.unsafe_to_char())
  }
  buf.to_string()
}

///|
/// Walk the tree once and record each node's structural path.
///
/// The tooling reads ancestry off these paths — a label inside its own panel is
/// not a collision, a child poking out of its parent is a defect — so the
/// segments have to mirror the real tree, not the flat layout order.
fn build_node_paths(
  tree : @ui.UITree,
  root : @ui.UINodeId,
  node_roles : Map[Int, NodeRole],
) -> Map[Int, String] {
  let paths : Map[Int, String] = Map([])
  fn segment(id : @ui.UINodeId, index : Int) -> String {
    let role = match node_roles.get(id.value) {
      Some(value) => role_name(value)
      None => "node"
    }
    role + "[" + index.to_string() + "]"
  }

  fn walk(id : @ui.UINodeId, prefix : String, index : Int) -> Unit {
    let path = if prefix == "" {
      segment(id, index)
    } else {
      prefix + ">" + segment(id, index)
    }
    paths[id.value] = path
    match tree.get_node(id) {
      Some(node) =>
        for child_index, child in node.children {
          walk(child, path, child_index)
        }
      None => ()
    }
  }

  walk(root, "", 0)
  paths
}

///|
fn DemoState::ui_snapshot(self : DemoState) -> @ui.UISnapshot {
  let focused_id = self.focus_mgr.current_focus()
  let nodes : Array[@ui.UISnapshotNode] = []
  let focus_order : Array[String] = []
  // Draw order is parents-first from the tail of `layouts`, so z ascends the
  // same way: a later-drawn node sits on top.
  let n = self.layouts.length()
  for idx in 0..<n {
    let layout = self.layouts[idx]
    let nid = layout.node_id.value
    let r = layout.rect
    let role = match self.node_roles.get(nid) {
      Some(value) => role_name(value)
      None => "node"
    }
    let id = role + "_" + nid.to_string()
    let is_focused = match focused_id {
      Some(fid) => fid.value == nid
      None => false
    }
    let text = match self.button_labels.get(nid) {
      Some(chars) => Some(decode_glyphs(chars))
      None => None
    }
    // Button labels are dot text at scale 1.0, centred in the node.
    let measured : @ui.UITextMetrics? = match self.button_labels.get(nid) {
      Some(chars) => {
        let (w, h) = @renderer2d.dot_text_size(chars.length())
        let metrics : @ui.UITextMetrics = { width: w, height: h }
        Some(metrics)
      }
      None => None
    }
    let hit : @ui.UISnapshotRect = {
      left: r.x,
      top: r.y,
      width: r.width,
      height: r.height,
    }
    let focusable = self.button_labels.get(nid) is Some(_)
    if focusable {
      focus_order.push(id)
    }
    let path = match self.node_paths.get(nid) {
      Some(value) => value
      None => role + "[" + idx.to_string() + "]"
    }
    nodes.push({
      ..@ui.default_ui_snapshot_node(),
      path,
      id,
      role,
      classes: role,
      left: r.x,
      top: r.y,
      width: r.width,
      height: r.height,
      z: n - 1 - idx,
      text,
      text_measured: measured,
      focusable,
      focus_index: if focusable {
        focus_order.length() - 1
      } else {
        -1
      },
      focused: is_focused,
      // The demo hit-tests the laid-out rect itself, so the two agree by
      // construction; publishing it keeps the gate's check meaningful if that
      // ever stops being true.
      hit: Some(hit),
    })
  }
  {
    ..@ui.default_ui_snapshot(
      screen_width=screen_w.to_double(),
      screen_height=screen_h.to_double(),
    ),
    frame: self.frame,
    state: "demo",
    nodes,
    focus_order,
  }
}
