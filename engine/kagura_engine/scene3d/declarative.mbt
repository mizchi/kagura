///|
/// Declarative view values borrow meshes/materials owned by the game.
pub(all) enum View {
  Element(String, String, SceneNode, Array[View])
  Fragment(Array[View])
  Dynamic(() -> Array[View])
  Component(() -> View)
}

///|
pub fn group(
  key~ : String,
  name? : String = key,
  position? : @math3d.Vec3 = @math3d.Vec3::zero(),
  rotation? : @math3d.Quaternion = @math3d.Quaternion::identity(),
  scale? : @math3d.Vec3 = @math3d.Vec3::one(),
  children~ : Array[View],
) -> View {
  Element(key, name, scene_node(position~, rotation~, scale~), children)
}

///|
pub fn mesh(
  key~ : String,
  name? : String = key,
  mesh~ : @mesh3d.Mesh3D,
  position? : @math3d.Vec3 = @math3d.Vec3::zero(),
  rotation? : @math3d.Quaternion = @math3d.Quaternion::identity(),
  scale? : @math3d.Vec3 = @math3d.Vec3::one(),
  color? : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
  material? : Material? = None,
  skinning? : SkinningState? = None,
  children? : Array[View] = [],
) -> View {
  Element(
    key,
    name,
    scene_node(
      mesh=Some(mesh),
      position~,
      rotation~,
      scale~,
      color~,
      material~,
      skinning~,
    ),
    children,
  )
}

///|
pub fn fragment(children : Array[View]) -> View {
  Fragment(children)
}

///|
/// A pure generator, evaluated once per render. No subscriptions or extra graph nodes.
pub fn for_each(render : () -> Array[View]) -> View {
  Dynamic(render)
}

///|
pub fn show(when : () -> Bool, render : () -> View) -> View {
  Dynamic(fn() { if when() { [render()] } else { [] } })
}

///|
pub fn component(render : () -> View) -> View {
  Component(render)
}

///|
/// Stable keyed IDs; a failed render leaves the previous graph and hierarchy intact.
pub struct SceneRoot {
  mut current : SceneGraph
  mut ids : Map[String, Int]
  mut outline : Array[@hierarchy.Node]
}

///|
pub fn SceneRoot::new() -> SceneRoot {
  { current: SceneGraph::new(), ids: Map([]), outline: [], }
}

///|
pub fn SceneRoot::graph(self : SceneRoot) -> SceneGraph {
  self.current
}

///|
pub fn SceneRoot::node_id(self : SceneRoot, path : String) -> Int? {
  self.ids.get(path)
}

///|
pub fn SceneRoot::hierarchy(self : SceneRoot) -> Array[@hierarchy.Node] {
  fn copy(nodes : Array[@hierarchy.Node]) -> Array[@hierarchy.Node] {
    nodes.map(n => { ..n, children: copy(n.children), })
  }
  copy(self.outline)
}

///|
pub fn SceneRoot::render(self : SceneRoot, view : View) -> Unit raise {
  let graph = SceneGraph::new()
  graph.next_id = self.current.next_id
  let ids : Map[String, Int] = Map([])
  let mut count = 0
  fn visit(
    view : View,
    parent : String,
    children : Array[Int],
    generated : Bool,
    depth : Int,
  ) -> Array[@hierarchy.Node] raise {
    count += 1
    if count > 10000 || depth > 128 {
      fail("Scene view exceeds traversal limit")
    }
    match view {
      Component(render) =>
        visit(render(), parent, children, generated, depth + 1)
      Fragment(items) => {
        let result = []
        for item in items {
          result.append(visit(item, parent, children, generated, depth + 1))
        }
        result
      }
      Dynamic(render) => {
        let result = []
        for item in render() {
          result.append(visit(item, parent, children, true, depth + 1))
        }
        result
      }
      Element(key, name, node, nested) => {
        if name.length() > 256 || !@hierarchy.valid_key(key) {
          fail("Invalid scene key")
        }
        let path = if parent == "" { key } else { parent + "/" + key }
        if path.length() > 4096 {
          fail("Scene path exceeds hierarchy limit")
        }
        if ids.contains(path) {
          fail("Duplicate sibling scene key: " + path)
        }
        let id = match self.ids.get(path) {
          Some(id) => id
          None => {
            let id = graph.next_id
            graph.next_id += 1
            id
          }
        }
        ids[path] = id
        let child_ids = []
        let outline = []
        for child in nested {
          outline.append(visit(child, path, child_ids, generated, depth + 1))
        }
        graph.nodes[id] = { ..node, children: child_ids, }
        children.push(id)
        [
          {
            id: path,
            name,
            kind: if node.mesh is Some(_) {
              "mesh"
            } else {
              "group"
            },
            generated,
            children: outline,
          },
        ]
      }
    }
  }
  let outline = visit(view, "", graph.roots, false, 0)
  self.current = graph
  self.ids = ids
  self.outline = outline
}

///|
/// Whole-scene declaration. Camera/lighting use Kagura's existing typed contracts.
pub(all) struct SceneView {
  root : View
  camera : @camera3d.Camera3D
  lighting : @light3d.LightingEnvironment
}

///|
pub fn scene(
  root~ : View,
  camera~ : @camera3d.Camera3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
) -> SceneView {
  { root, camera, lighting, }
}
