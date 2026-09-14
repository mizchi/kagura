///|
test "declarative hierarchy preserves keyed graph identity across reorder" {
  let root = SceneRoot::new()
  let cube = @mesh3d.Mesh3D::cube(1.0)
  fn item(key : String, x : Double) -> View {
    mesh(key~, mesh=cube, position=@math3d.Vec3::new(x, 0.0, 0.0))
  }
  root.render(group(key="world", children=[item("a", 1.0), item("b", 2.0)]))
  let a = root.node_id("world/a").unwrap()
  let b = root.node_id("world/b").unwrap()
  root.render(group(key="world", children=[item("b", 5.0), item("a", 4.0)]))
  assert_eq(root.node_id("world/a"), Some(a))
  assert_eq(
    root.graph().get_node(root.node_id("world").unwrap()).unwrap().children,
    [b, a],
  )
  assert_eq(root.hierarchy()[0].children[0].id, "world/b")
  let rejected = try {
    root.render(group(key="world", children=[item("a", 0.0), item("a", 9.0)]))
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
  assert_eq(root.hierarchy()[0].children[0].id, "world/b")
  root.render(group(key="world", children=[item("a", 4.0)]))
  assert_true(root.graph().get_node(b) is None)
}

///|
test "dynamic scene branches evaluate once and remain transparent in hierarchy" {
  let root = SceneRoot::new()
  let mut calls = 0
  root.render(
    group(key="world", children=[
      for_each(fn() {
        calls += 1
        [group(key="generated", children=[])]
      }),
    ]),
  )
  assert_eq(calls, 1)
  assert_eq(root.hierarchy()[0].children[0].id, "world/generated")
  assert_true(root.hierarchy()[0].children[0].generated)
}

///|
test "nested declarative transforms produce the same GPU uniforms as world transforms" {
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let root = SceneRoot::new()
  root.render(
    group(
      key="parent",
      position=@math3d.Vec3::new(2.0, 0.0, 0.0),
      scale=@math3d.Vec3::new(2.0, 2.0, 2.0),
      children=[
        mesh(key="child", mesh=cube, position=@math3d.Vec3::new(1.0, 0.0, 0.0)),
      ],
    ),
  )
  let flat = SceneGraph::new()
  flat.add_node(
    scene_node(
      mesh=Some(cube),
      position=@math3d.Vec3::new(4.0, 0.0, 0.0),
      scale=@math3d.Vec3::new(2.0, 2.0, 2.0),
    ),
  )
  |> ignore
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 15.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 3.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(10, "")
  let nested_commands = render_scene3d_graph_gpu(
    root.graph(),
    camera,
    dst,
    shader,
    640,
    480,
  )
  let flat_commands = render_scene3d_graph_gpu(
    flat, camera, dst, shader, 640, 480,
  )
  assert_eq(nested_commands.length(), 1)
  assert_eq(nested_commands[0].uniform_dwords, flat_commands[0].uniform_dwords)
}

///|
test "logical subject survives hierarchy reparenting without changing its identity" {
  let root = SceneRoot::new()
  root.render(
    group(key="world", children=[
      subject("enemy:42", group(key="body", children=[])),
    ]),
  )
  assert_eq(root.hierarchy()[0].children[0].subject, Some("enemy:42"))
  root.render(
    group(key="other", children=[
      subject("enemy:42", group(key="body", children=[])),
    ]),
  )
  assert_eq(root.hierarchy()[0].children[0].id, "other/body")
  assert_eq(root.hierarchy()[0].children[0].subject, Some("enemy:42"))
}
