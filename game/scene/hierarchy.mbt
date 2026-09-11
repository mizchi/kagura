///|
/// A frame's resolved view. Rendering and inspection share the evaluated branches.
pub(all) struct ResolvedScene {
  node : SceneNode
  hierarchy : Array[@hierarchy.Node]
}

///|
pub fn component(render : () -> SceneNode) -> SceneNode {
  @ui.component(render)
}

///|
pub fn resolve(view : SceneNode) -> ResolvedScene raise {
  let ids : Map[String, Bool] = Map([])
  let mut count = 0
  fn walk(
    node : SceneNode,
    parent : String,
    generated : Bool,
    depth : Int,
    outline : Array[@hierarchy.Node],
  ) -> SceneNode raise {
    count += 1
    if count > 10000 || depth > 128 {
      fail("Scene view exceeds traversal limit")
    }
    match node {
      Element(el) => {
        if !["rect", "label", "group", "line", "rect_outline"].contains(el.tag) {
          fail("Unsupported 2D scene element")
        }
        let attrs = el.attrs.map(fn(pair) {
          let (key, attr) = pair
          (
            key,
            match attr {
              VDynamic(get) => @ui.attr_static(get())
              _ => attr
            },
          )
        })
        let mut key = ""
        let mut name = ""
        for pair in attrs {
          let (slot, attr) = pair
          if slot == "key" || slot == "name" {
            guard attr is VStatic(SceneText(value)) else {
              fail("Invalid scene metadata")
            }
            if slot == "key" {
              key = value
            } else {
              name = value
            }
          }
        }
        if name.length() > 256 || (key != "" && !@hierarchy.valid_key(key)) {
          fail("Invalid scene key")
        }
        if key == "" {
          key = "@" + outline.length().to_string()
        }
        if name == "" {
          name = el.tag
        }
        let path = if parent == "" { key } else { parent + "/" + key }
        if path.length() > 4096 { fail("Scene path exceeds hierarchy limit") }
        if ids.contains(path) {
          fail("Duplicate sibling scene key: " + path)
        }
        ids[path] = true
        let nested = []
        let children = el.children.map(child => {
          walk(child, path, generated, depth + 1, nested)
        })
        outline.push({
          id: path,
          name,
          kind: el.tag,
          generated,
          children: nested,
        })
        @ui.h(el.tag, attrs, children)
      }
      Fragment(children) =>
        Fragment(
          children.map(child => {
            walk(child, parent, generated, depth + 1, outline)
          }),
        )
      Show(condition~, child~) =>
        if condition() {
          walk(child(), parent, true, depth + 1, outline)
        } else {
          Fragment([])
        }
      For(render~) =>
        Fragment(
          render().map(child => walk(child, parent, true, depth + 1, outline)),
        )
      Component(render~) =>
        walk(render(), parent, generated, depth + 1, outline)
      Switch(sw) => {
        for c in sw.cases {
          if (c.when)() {
            return walk((c.render)(), parent, true, depth + 1, outline)
          }
        }
        match sw.fallback {
          Some(render) => walk(render(), parent, true, depth + 1, outline)
          None => Fragment([])
        }
      }
      _ => fail("Unsupported 2D scene node")
    }
  }
  let hierarchy = []
  let node = walk(view, "", false, 0, hierarchy)
  { node, hierarchy, }
}
