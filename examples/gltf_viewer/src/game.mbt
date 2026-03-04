///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
struct ViewerState {
  graph : @scene3d.SceneGraph
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  shader3d : @gfx.ShaderHandle
  shader3d_textured : @gfx.ShaderHandle
  node_count : Int
  mesh_node_count : Int
}

///|
fn ViewerState::new(graph : @scene3d.SceneGraph) -> ViewerState {
  // Count nodes and mesh nodes
  let node_count = graph.nodes.length()
  let mut mesh_count = 0
  graph.nodes.each(fn(_id, node) {
    if node.mesh is Some(_) {
      mesh_count = mesh_count + 1
    }
  })
  // Add ground plane
  let ground = @scene3d.scene_node(
    mesh=Some(@mesh3d.Mesh3D::plane(8.0, 8.0, subdivisions=16)),
    position=@math3d.Vec3::new(0.0, -0.02, 0.0),
    color=@math3d.Vec4::new(0.35, 0.35, 0.4, 1.0),
  )
  let _ = graph.add_node(ground)
  {
    graph,
    camera: @camera3d.OrbitCamera::new(
      @math3d.Vec3::new(0.0, 0.5, 0.0),
      6.0,
      0.5,
      0.4,
      @math.PI / 4.0,
      screen_w.to_double() / screen_h.to_double(),
      0.01,
      50.0,
    ),
    lighting: @light3d.LightingEnvironment::new(
      @light3d.DirectionalLight::new(
        @math3d.Vec3::new(-0.5, 1.0, 0.8),
        @math3d.Vec3::new(1.0, 1.0, 1.0),
        0.8,
      ),
      @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.3),
    ),
    shader3d: @gfx.new_shader_handle(
      100,
      @draw3d.shader3d_lit_untextured_wgsl(),
    ),
    shader3d_textured: @gfx.new_shader_handle(
      101,
      @draw3d.shader3d_lit_wgsl(),
    ),
    node_count,
    mesh_node_count: mesh_count,
  }
}

///|
fn ViewerState::update(self : ViewerState, input : @core.InputSnapshot, prev_x : Ref[Double], prev_y : Ref[Double]) -> Unit {
  let cx = input.cursor_x
  let cy = input.cursor_y
  let dx = cx - prev_x.val
  let dy = cy - prev_y.val
  prev_x.val = cx
  prev_y.val = cy
  // Left mouse button drag → orbit
  let mut lmb = false
  for b in input.pressed_mouse_buttons {
    if b == 0 {
      lmb = true
      break
    }
  }
  if lmb {
    self.camera = self.camera.orbit(dx * -0.005, dy * -0.005)
  }
  // Scroll wheel → zoom
  if input.wheel_y != 0.0 {
    self.camera = self.camera.zoom(input.wheel_y * 0.05)
  }
}

///|
fn ViewerState::draw(self : ViewerState, ctx : @engine.EngineContext) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds = @scene3d.render_scene3d_graph_gpu(
    self.graph,
    self.camera.to_camera3d(),
    lighting=self.lighting,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
    shader3d_textured=Some(self.shader3d_textured),
  )
  // HUD: node count
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  let white = @debugutil.color_from_hex(0xFFFFFF)
  // "N:" label + node count
  @debugutil.draw_dot_text(
    cmds, ctx.dst, ctx.shader,
    [78], // 'N'
    4.0, 4.0, sw, sh, white, 1.0,
  )
  @debugutil.draw_number(
    cmds, ctx.dst, ctx.shader,
    self.node_count,
    12.0, 4.0, sw, sh, white, 1.0,
  )
  // "M:" label + mesh node count
  @debugutil.draw_dot_text(
    cmds, ctx.dst, ctx.shader,
    [77], // 'M'
    4.0, 12.0, sw, sh, white, 1.0,
  )
  @debugutil.draw_number(
    cmds, ctx.dst, ctx.shader,
    self.mesh_node_count,
    12.0, 12.0, sw, sh, white, 1.0,
  )
  cmds
}
