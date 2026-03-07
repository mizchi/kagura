///|
test "SceneGraph add_node and get_node" {
  let graph = SceneGraph::new()
  let node = scene_node(
    mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
    position=@math3d.Vec3::new(1.0, 2.0, 3.0),
  )
  let id = graph.add_node(node)
  assert_eq(id, 0)
  assert_true(graph.get_node(id) is Some(_))
  assert_eq(graph.roots.length(), 1)
  assert_eq(graph.roots[0], id)
}

///|
test "SceneGraph add_child" {
  let graph = SceneGraph::new()
  let parent = scene_node(position=@math3d.Vec3::new(1.0, 0.0, 0.0))
  let pid = graph.add_node(parent)
  let child = scene_node(
    mesh=Some(@mesh3d.Mesh3D::cube(0.5)),
    position=@math3d.Vec3::new(0.0, 2.0, 0.0),
  )
  let cid = graph.add_child(pid, child)
  assert_eq(cid, 1)
  assert_eq(graph.roots.length(), 1)
  let p = graph.get_node(pid).unwrap()
  assert_eq(p.children.length(), 1)
  assert_eq(p.children[0], cid)
}

///|
test "SceneGraph set_node updates node" {
  let graph = SceneGraph::new()
  let node = scene_node(color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))
  let id = graph.add_node(node)
  let updated = scene_node(color=@math3d.Vec4::new(0.0, 1.0, 0.0, 1.0))
  graph.set_node(id, updated)
  let n = graph.get_node(id).unwrap()
  assert_eq(n.color.y, 1.0)
}

///|
test "SceneGraph get_node returns None for missing id" {
  let graph = SceneGraph::new()
  assert_true(graph.get_node(999) is None)
}
