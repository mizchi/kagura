///|
/// Build a UI snapshot from a scene tree.
///
/// Labels become snapshot nodes with the same measured size `append_dot_text`
/// uses. Keyed rects / outlines publish the drawn box as a hit rect so HUD
/// chrome (HP bars, End Turn) is inspectable. Unlabeled world rects stay
/// omitted so pipes / tiles / sprites do not show up as HUD defects. Keyed
/// groups contribute path segments only.
pub fn ui_snapshot_from_scene(
  node : SceneNode,
  screen_width~ : Double,
  screen_height~ : Double,
  frame? : Int = 0,
  state? : String = "scene",
) -> @kagura_ui.UISnapshot {
  let nodes : Array[@kagura_ui.UISnapshotNode] = []
  let mut label_seq = 0
  fn walk(
    node : SceneNode,
    offset_x : Double,
    offset_y : Double,
    parent_path : String,
  ) -> Unit {
    match node {
      Element(el) =>
        match el.tag {
          "label" => {
            let content = scene_attr_string(el.attrs, "content", "")
            if content == "" {
              return
            }
            let x = scene_attr_double(el.attrs, "x", 0.0) + offset_x
            let y = scene_attr_double(el.attrs, "y", 0.0) + offset_y
            let scale = scene_attr_double(el.attrs, "scale", 1.0)
            let key = scene_attr_string(el.attrs, "key", "")
            let (id, segment) = if key == "" {
              let n = label_seq
              label_seq += 1
              ("label_" + n.to_string(), "label[" + n.to_string() + "]")
            } else {
              (key, key)
            }
            let path = join_snapshot_path(parent_path, segment)
            let chars = string_to_char_codes(content)
            let (tw, th) = @renderer2d.dot_text_size(chars.length(), scale~)
            let left = x - tw / 2.0
            let top = y - th / 2.0
            let hit : @kagura_ui.UISnapshotRect = {
              left,
              top,
              width: tw,
              height: th,
            }
            let metrics : @kagura_ui.UITextMetrics = { width: tw, height: th, }
            nodes.push({
              ..@kagura_ui.default_ui_snapshot_node(),
              path,
              id,
              role: "label",
              classes: if key == "" {
                "label"
              } else {
                key
              },
              left,
              top,
              width: tw,
              height: th,
              z: nodes.length(),
              text: Some(content),
              text_measured: Some(metrics),
              hit: Some(hit),
            })
          }
          "group" => {
            let x = scene_attr_double(el.attrs, "x", 0.0)
            let y = scene_attr_double(el.attrs, "y", 0.0)
            let key = scene_attr_string(el.attrs, "key", "")
            let path = join_snapshot_path(parent_path, key)
            for child in el.children {
              walk(child, offset_x + x, offset_y + y, path)
            }
          }
          "rect" => {
            let child_path = push_keyed_box(
              nodes, el, offset_x, offset_y, parent_path, "rect",
            )
            let x = scene_attr_double(el.attrs, "x", 0.0)
            let y = scene_attr_double(el.attrs, "y", 0.0)
            for child in el.children {
              walk(child, offset_x + x, offset_y + y, child_path)
            }
          }
          "rect_outline" => {
            let _ = push_keyed_box(
              nodes, el, offset_x, offset_y, parent_path, "outline",
            )
          }
          _ =>
            for child in el.children {
              walk(child, offset_x, offset_y, parent_path)
            }
        }
      Fragment(children) =>
        for child in children {
          walk(child, offset_x, offset_y, parent_path)
        }
      Show(condition~, child~) =>
        if condition() {
          walk(child(), offset_x, offset_y, parent_path)
        }
      For(render~) => {
        let items = render()
        for item in items {
          walk(item, offset_x, offset_y, parent_path)
        }
      }
      Component(render~) => walk(render(), offset_x, offset_y, parent_path)
      Switch(sw) => {
        for c in sw.cases {
          if (c.when)() {
            walk((c.render)(), offset_x, offset_y, parent_path)
            return
          }
        }
        match sw.fallback {
          Some(fb) => walk(fb(), offset_x, offset_y, parent_path)
          None => ()
        }
      }
      Text(_) | DynamicText(_) | Async(_) | ErrorBoundary(_) | RawHtml(_) => ()
    }
  }

  walk(node, 0.0, 0.0, "")
  {
    ..@kagura_ui.default_ui_snapshot(screen_width~, screen_height~),
    frame,
    state,
    nodes,
  }
}

///|
fn push_keyed_box(
  nodes : Array[@kagura_ui.UISnapshotNode],
  el : @ui.VElement[Unit, SceneAttrValue],
  offset_x : Double,
  offset_y : Double,
  parent_path : String,
  role : String,
) -> String {
  let key = scene_attr_string(el.attrs, "key", "")
  if key == "" {
    return parent_path
  }
  let left = scene_attr_double(el.attrs, "x", 0.0) + offset_x
  let top = scene_attr_double(el.attrs, "y", 0.0) + offset_y
  let width = scene_attr_double(el.attrs, "w", 0.0)
  let height = scene_attr_double(el.attrs, "h", 0.0)
  let path = join_snapshot_path(parent_path, key)
  let hit : @kagura_ui.UISnapshotRect = { left, top, width, height, }
  nodes.push({
    ..@kagura_ui.default_ui_snapshot_node(),
    path,
    id: key,
    role,
    classes: key,
    left,
    top,
    width,
    height,
    z: nodes.length(),
    hit: Some(hit),
  })
  path
}

///|
fn join_snapshot_path(parent : String, segment : String) -> String {
  if segment == "" {
    parent
  } else if parent == "" {
    segment
  } else {
    parent + ">" + segment
  }
}

///|
fn scene_attr_value(
  attrs : Array[(String, @ui.Attr[Unit, SceneAttrValue])],
  key : String,
) -> SceneAttrValue? {
  for pair in attrs {
    let (attr_key, attr) = pair
    if attr_key == key {
      match attr {
        VStatic(value) => return Some(value)
        VDynamic(getter) => return Some(getter())
        VHandler(_) => ()
      }
    }
  }
  None
}

///|
fn scene_attr_double(
  attrs : Array[(String, @ui.Attr[Unit, SceneAttrValue])],
  key : String,
  default_ : Double,
) -> Double {
  match scene_attr_value(attrs, key) {
    Some(SceneDouble(v)) => v
    Some(SceneInt(v)) => v.to_double()
    _ => default_
  }
}

///|
fn scene_attr_string(
  attrs : Array[(String, @ui.Attr[Unit, SceneAttrValue])],
  key : String,
  default_ : String,
) -> String {
  match scene_attr_value(attrs, key) {
    Some(SceneText(v)) => v
    _ => default_
  }
}
