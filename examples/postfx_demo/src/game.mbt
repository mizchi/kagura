// ============================================================
// Post-Processing Effects Demo
// ============================================================
// scene3d renders to intermediate RT, then bloom + tonemap + FXAA.

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  // Meshes
  cube_mesh : @mesh3d.Mesh3D
  sphere_mesh : @mesh3d.Mesh3D
  ground_mesh : @mesh3d.Mesh3D
  // Shaders
  shader3d : @gfx.ShaderHandle
  // PostFX pipeline
  pipeline : @render_pipeline3d.RenderPipeline3D
  // Scene
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  input : @inpututil.InputHelper
  mut frame : Int
}

///|
fn DemoState::new() -> DemoState {
  // 3D lit shader
  let shader3d = @gfx.new_shader_handle(
    10, @draw3d.shader3d_lit_untextured_wgsl(),
  )
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    10.0,
    0.3,
    0.5,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    100.0,
  )
  // Bright lighting to show bloom
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.3, -1.0, -0.5),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      1.2,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.3),
  )
  {
    cube_mesh: @mesh3d.Mesh3D::cube(1.0),
    sphere_mesh: @mesh3d.Mesh3D::sphere(0.7, 8, 6),
    ground_mesh: @mesh3d.Mesh3D::plane(16.0, 16.0),
    shader3d,
    pipeline: @render_pipeline3d.RenderPipeline3D::new(
      100,
      screen_w,
      screen_h,
      @render_pipeline3d.PostFXConfig::{
        fxaa_enabled: true,
        ssao_config: @render_pipeline3d.SSAOConfig::disabled_default(),
        bloom_threshold: 0.4,
        bloom_intensity: 2.0,
      },
    ),
    camera,
    lighting,
    input: @inpututil.new_input_helper(),
    frame: 0,
  }
}

// ============================================================
// Scene construction
// ============================================================

///|
fn DemoState::build_scene(self : DemoState) -> @scene3d.Scene3D {
  let objects : Array[@scene3d.Object3D] = []
  // Ground
  objects.push(
    @scene3d.object3d(
      mesh=self.ground_mesh,
      color=@math3d.Vec4::new(0.3, 0.35, 0.3, 1.0),
      sort_bias=100.0,
    ),
  )
  // Bright red cube (will bloom)
  objects.push(
    @scene3d.object3d(
      mesh=self.cube_mesh,
      position=@math3d.Vec3::new(-2.0, 0.5, 0.0),
      color=@math3d.Vec4::new(1.0, 0.2, 0.1, 1.0),
    ),
  )
  // Bright yellow sphere (will bloom)
  objects.push(
    @scene3d.object3d(
      mesh=self.sphere_mesh,
      position=@math3d.Vec3::new(1.5, 0.7, 1.0),
      color=@math3d.Vec4::new(1.0, 0.95, 0.3, 1.0),
    ),
  )
  // Bright cyan cube, rotating
  let angle = self.frame.to_double() * 0.015
  objects.push(
    @scene3d.object3d(
      mesh=self.cube_mesh,
      position=@math3d.Vec3::new(0.0, 0.5, -2.0),
      rotation=@math3d.Quaternion::from_axis_angle(
        @math3d.Vec3::unit_y(), angle,
      ),
      color=@math3d.Vec4::new(0.2, 0.9, 1.0, 1.0),
    ),
  )
  // White sphere (bright, strong bloom candidate)
  objects.push(
    @scene3d.object3d(
      mesh=self.sphere_mesh,
      position=@math3d.Vec3::new(2.5, 0.7, -1.5),
      color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
    ),
  )
  let camera = self.camera.to_camera3d()
  @scene3d.scene3d(objects=objects, camera=camera, lighting=self.lighting)
}

// ============================================================
// Update
// ============================================================

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  self.camera = self.camera.orbit(0.004, 0.0)
}

// ============================================================
// Draw
// ============================================================

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let all_cmds : Array[@gfx.DrawTrianglesCommand] = []
  // 1. Render scene to pipeline's scene target
  let scene = self.build_scene()
  let scene_cmds = @scene3d.render_scene3d_gpu(
    scene, self.pipeline.scene_target, self.shader3d, ctx.screen_w, ctx.screen_h,
  )
  for cmd in scene_cmds {
    all_cmds.push(cmd)
  }
  // 2. PostFX: bloom → tonemap → FXAA
  let view_projection = self.camera.to_camera3d().view_projection_matrix()
  let postfx_cmds = self.pipeline.compose_postfx(
    ctx.dst,
    [], // no depth casters
    view_projection,
    ctx.screen_w,
    ctx.screen_h,
  )
  for cmd in postfx_cmds {
    all_cmds.push(cmd)
  }
  all_cmds
}
