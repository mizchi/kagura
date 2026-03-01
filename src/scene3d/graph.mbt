///|
pub(all) struct SceneNode {
  transform : @transform3d.Transform3D
  mesh : @mesh3d.Mesh3D?
  color : @math3d.Vec4
  material : Material?
  children : Array[Int]
}

///|
pub struct SceneGraph {
  nodes : Map[Int, SceneNode]
  roots : Array[Int]
  mut next_id : Int
}

///|
pub fn SceneGraph::new() -> SceneGraph {
  { nodes: {}, roots: [], next_id: 0 }
}

///|
pub fn SceneGraph::add_node(self : SceneGraph, node : SceneNode) -> Int {
  let id = self.next_id
  self.next_id = self.next_id + 1
  self.nodes[id] = node
  self.roots.push(id)
  id
}

///|
pub fn SceneGraph::add_child(
  self : SceneGraph,
  parent_id : Int,
  node : SceneNode,
) -> Int {
  let id = self.next_id
  self.next_id = self.next_id + 1
  self.nodes[id] = node
  match self.nodes.get(parent_id) {
    Some(parent) => parent.children.push(id)
    None => ()
  }
  id
}

///|
pub fn SceneGraph::get_node(self : SceneGraph, id : Int) -> SceneNode? {
  self.nodes.get(id)
}

///|
pub fn SceneGraph::set_node(self : SceneGraph, id : Int, node : SceneNode) -> Unit {
  self.nodes[id] = node
}

///|
pub fn scene_node(
  mesh? : @mesh3d.Mesh3D? = None,
  position? : @math3d.Vec3 = @math3d.Vec3::zero(),
  rotation? : @math3d.Quaternion = @math3d.Quaternion::identity(),
  scale? : @math3d.Vec3 = @math3d.Vec3::one(),
  color? : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
  material? : Material? = None,
) -> SceneNode {
  {
    transform: @transform3d.Transform3D::from_components(position, rotation, scale),
    mesh,
    color,
    material,
    children: [],
  }
}
