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
test "SceneGraph group node (no mesh) does not render" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let graph = SceneGraph::new()
  let _ = graph.add_node(scene_node(position=@math3d.Vec3::new(1.0, 0.0, 0.0)))
  let cmds = render_scene3d_graph(graph, camera, dst, shader, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "SceneGraph parent-child transform composition" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let graph = SceneGraph::new()
  let pid = graph.add_node(
    scene_node(position=@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  let _ = graph.add_child(
    pid,
    scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(0.5)),
      position=@math3d.Vec3::new(0.0, 2.0, 0.0),
      color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    ),
  )
  let cmds = render_scene3d_graph(graph, camera, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
}

///|
test "SceneGraph deep nesting (3 levels)" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let graph = SceneGraph::new()
  let root = graph.add_node(
    scene_node(position=@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  let mid = graph.add_child(
    root,
    scene_node(position=@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  let _ = graph.add_child(
    mid,
    scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(0.3)),
      position=@math3d.Vec3::new(0.0, 1.0, 0.0),
      color=@math3d.Vec4::new(0.0, 0.0, 1.0, 1.0),
    ),
  )
  let cmds = render_scene3d_graph(graph, camera, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
}

///|
test "SceneGraph multiple roots" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let graph = SceneGraph::new()
  let _ = graph.add_node(
    scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(0.5)),
      position=@math3d.Vec3::new(-2.0, 0.0, 0.0),
      color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    ),
  )
  let _ = graph.add_node(
    scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(0.5)),
      position=@math3d.Vec3::new(2.0, 0.0, 0.0),
      color=@math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ),
  )
  assert_eq(graph.roots.length(), 2)
  let cmds = render_scene3d_graph(graph, camera, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
}

///|
test "render_scene3d still works after refactor" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
}
