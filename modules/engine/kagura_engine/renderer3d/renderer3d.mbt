///|
pub(all) struct RenderShaders3D {
  shader3d : @gfx.ShaderHandle
  shader3d_textured : @gfx.ShaderHandle?
  shader3d_pbr : @gfx.ShaderHandle?
  shader3d_pbr_textured : @gfx.ShaderHandle?
  shader3d_skinned : @gfx.ShaderHandle?
}

///|
pub fn RenderShaders3D::new(
  shader3d~ : @gfx.ShaderHandle,
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
) -> RenderShaders3D {
  {
    shader3d,
    shader3d_textured,
    shader3d_pbr,
    shader3d_pbr_textured,
    shader3d_skinned,
  }
}

///|
pub(all) struct RenderFrame3D {
  dst : @gfx.ImageHandle
  screen_w : Int
  screen_h : Int
  shaders : RenderShaders3D
}

///|
pub fn RenderFrame3D::new(
  dst~ : @gfx.ImageHandle,
  shader3d~ : @gfx.ShaderHandle,
  screen_w~ : Int,
  screen_h~ : Int,
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
) -> RenderFrame3D {
  {
    dst,
    screen_w,
    screen_h,
    shaders: RenderShaders3D::new(
      shader3d~,
      shader3d_textured~,
      shader3d_pbr~,
      shader3d_pbr_textured~,
      shader3d_skinned~,
    ),
  }
}

///|
pub fn RenderFrame3D::with_dst(
  self : RenderFrame3D,
  dst : @gfx.ImageHandle,
) -> RenderFrame3D {
  { ..self, dst, }
}

///|
fn append_all(
  dst : Array[@gfx.DrawTrianglesCommand],
  src : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  for cmd in src {
    dst.push(cmd)
  }
}

///|
pub fn render_scene3d(
  scene : @scene3d.Scene3D,
  frame : RenderFrame3D,
) -> Array[@gfx.DrawTrianglesCommand] {
  @scene3d.render_scene3d_gpu(
    scene,
    frame.dst,
    frame.shaders.shader3d,
    frame.screen_w,
    frame.screen_h,
    shader3d_textured=frame.shaders.shader3d_textured,
    shader3d_pbr=frame.shaders.shader3d_pbr,
    shader3d_pbr_textured=frame.shaders.shader3d_pbr_textured,
    shader3d_skinned=frame.shaders.shader3d_skinned,
  )
}

///|
pub fn append_scene3d_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  scene : @scene3d.Scene3D,
  frame : RenderFrame3D,
) -> Unit {
  append_all(commands, render_scene3d(scene, frame))
}

///|
pub fn render_scene3d_to_dst(
  scene : @scene3d.Scene3D,
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
) -> Array[@gfx.DrawTrianglesCommand] {
  render_scene3d(
    scene,
    RenderFrame3D::new(
      dst~,
      shader3d~,
      screen_w~,
      screen_h~,
      shader3d_textured~,
      shader3d_pbr~,
      shader3d_pbr_textured~,
      shader3d_skinned~,
    ),
  )
}

///|
pub fn render_scene3d_graph(
  graph : @scene3d.SceneGraph,
  camera : @camera3d.Camera3D,
  frame : RenderFrame3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
) -> Array[@gfx.DrawTrianglesCommand] {
  @scene3d.render_scene3d_graph_gpu(
    graph,
    camera,
    lighting~,
    frame.dst,
    frame.shaders.shader3d,
    frame.screen_w,
    frame.screen_h,
    shader3d_textured=frame.shaders.shader3d_textured,
    shader3d_pbr=frame.shaders.shader3d_pbr,
    shader3d_pbr_textured=frame.shaders.shader3d_pbr_textured,
    shader3d_skinned=frame.shaders.shader3d_skinned,
  )
}

///|
pub fn append_scene3d_graph_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  graph : @scene3d.SceneGraph,
  camera : @camera3d.Camera3D,
  frame : RenderFrame3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
) -> Unit {
  append_all(commands, render_scene3d_graph(graph, camera, frame, lighting~))
}

///|
pub fn render_scene3d_graph_to_dst(
  graph : @scene3d.SceneGraph,
  camera : @camera3d.Camera3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  shader3d_textured? : @gfx.ShaderHandle? = None,
  shader3d_pbr? : @gfx.ShaderHandle? = None,
  shader3d_pbr_textured? : @gfx.ShaderHandle? = None,
  shader3d_skinned? : @gfx.ShaderHandle? = None,
) -> Array[@gfx.DrawTrianglesCommand] {
  render_scene3d_graph(
    graph,
    camera,
    RenderFrame3D::new(
      dst~,
      shader3d~,
      screen_w~,
      screen_h~,
      shader3d_textured~,
      shader3d_pbr~,
      shader3d_pbr_textured~,
      shader3d_skinned~,
    ),
    lighting~,
  )
}

///|
pub fn render_scene3d_to_pipeline(
  scene : @scene3d.Scene3D,
  pipeline : @render_pipeline3d.RenderPipeline3D,
  frame : RenderFrame3D,
  depth_casters? : Array[@shadow3d.ShadowCaster] = [],
  hit_flash? : Double = 0.0,
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  append_scene3d_commands(
    commands,
    scene,
    frame.with_dst(pipeline.scene_target),
  )
  append_all(
    commands,
    pipeline.compose_postfx(
      frame.dst,
      depth_casters,
      scene.camera.view_projection_matrix(),
      frame.screen_w,
      frame.screen_h,
      hit_flash~,
    ),
  )
  commands
}

///|
pub fn render_scene3d_graph_to_pipeline(
  graph : @scene3d.SceneGraph,
  camera : @camera3d.Camera3D,
  pipeline : @render_pipeline3d.RenderPipeline3D,
  frame : RenderFrame3D,
  lighting? : @light3d.LightingEnvironment = @light3d.LightingEnvironment::default(),
  depth_casters? : Array[@shadow3d.ShadowCaster] = [],
  hit_flash? : Double = 0.0,
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  append_scene3d_graph_commands(
    commands,
    graph,
    camera,
    frame.with_dst(pipeline.scene_target),
    lighting~,
  )
  append_all(
    commands,
    pipeline.compose_postfx(
      frame.dst,
      depth_casters,
      camera.view_projection_matrix(),
      frame.screen_w,
      frame.screen_h,
      hit_flash~,
    ),
  )
  commands
}
