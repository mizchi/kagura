///|
fn test_camera() -> @camera3d.Camera3D {
  @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
}

///|
fn test_scene() -> @scene3d.Scene3D {
  @scene3d.scene3d(
    objects=[
      @scene3d.object3d(
        mesh=@mesh3d.Mesh3D::cube(1.0),
        color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      ),
    ],
    camera=test_camera(),
  )
}

///|
test "render_scene3d emits scene commands through a frame facade" {
  let frame = RenderFrame3D::new(
    dst=@gfx.new_image_handle(1, 640, 480),
    shader3d=@gfx.new_shader_handle(10, "base3d"),
    screen_w=640,
    screen_h=480,
  )
  let cmds = render_scene3d(test_scene(), frame)
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].dst.id, 1)
  assert_eq(cmds[0].shader.id, 10)
}

///|
test "render_scene3d_to_pipeline targets scene pass then appends postfx" {
  let final_dst = @gfx.new_image_handle(99, 640, 480)
  let frame = RenderFrame3D::new(
    dst=final_dst,
    shader3d=@gfx.new_shader_handle(10, "base3d"),
    screen_w=640,
    screen_h=480,
  )
  let pipeline = @render_pipeline3d.RenderPipeline3D::new(
    200,
    640,
    480,
    @render_pipeline3d.PostFXConfig::default(),
  )
  let cmds = render_scene3d_to_pipeline(test_scene(), pipeline, frame)
  assert_true(cmds.length() > 1)
  assert_eq(cmds[0].dst.id, pipeline.scene_target.id)
  assert_eq(cmds[cmds.length() - 1].dst.id, final_dst.id)
}

///|
test "render_scene3d_graph uses graph renderer behind the same frame contract" {
  let graph = @scene3d.SceneGraph::new()
  let _id = graph.add_node(
    @scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(1.0))),
  )
  let frame = RenderFrame3D::new(
    dst=@gfx.new_image_handle(7, 640, 480),
    shader3d=@gfx.new_shader_handle(11, "graph3d"),
    screen_w=640,
    screen_h=480,
  )
  let cmds = render_scene3d_graph(graph, test_camera(), frame)
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].dst.id, 7)
  assert_eq(cmds[0].shader.id, 11)
}
