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

///|
test "SceneGraph apply_root_transform updates root transforms only" {
  let graph = SceneGraph::new()
  let root_id = graph.add_node(
    scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(1.0)),
      position=@math3d.Vec3::new(1.0, 0.0, 0.0),
    ),
  )
  let child_id = graph.add_child(
    root_id,
    scene_node(position=@math3d.Vec3::new(0.0, 2.0, 0.0)),
  )
  graph.apply_root_transform(
    @transform3d.Transform3D::from_components(
      @math3d.Vec3::new(2.0, 0.5, -1.0),
      @math3d.Quaternion::from_axis_angle(
        @math3d.Vec3::unit_y(),
        @math.PI / 2.0,
      ),
      @math3d.Vec3::new(2.0, 2.0, 2.0),
    ),
  )
  let root = graph.get_node(root_id).unwrap()
  let child = graph.get_node(child_id).unwrap()
  assert_true(root.transform.position.x != 1.0)
  assert_true(root.transform.scale.x > 1.0)
  assert_eq(child.transform.position.y, 2.0)
}

///|
test "SceneGraph clone_graph deep copies node children" {
  let graph = SceneGraph::new()
  let root_id = graph.add_node(
    scene_node(position=@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  ignore(
    graph.add_child(
      root_id,
      scene_node(position=@math3d.Vec3::new(0.0, 2.0, 0.0)),
    ),
  )

  let cloned = graph.clone_graph()
  let cloned_root = cloned.get_node(root_id).unwrap()
  cloned_root.children.push(99)

  let original_root = graph.get_node(root_id).unwrap()
  assert_eq(original_root.children.length(), 1)
  assert_eq(cloned_root.children.length(), 2)
}
