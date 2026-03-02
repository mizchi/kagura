// ============================================================
// Shadow Mapping Demo
// ============================================================
// Ground + cubes + sphere with directional light shadows.
// Two-pass rendering: depth pass (shadow map) + lit pass.

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
  // Shadow resources
  shadow_map : @gfx.ImageHandle
  depth_shader : @gfx.ShaderHandle
  lit_shader : @gfx.ShaderHandle
  shadow_config : @shadow3d.ShadowConfig
  // Scene
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  input : @inpututil.InputHelper
  mut frame : Int
}

///|
fn DemoState::new() -> DemoState {
  let shadow_config = @shadow3d.ShadowConfig::new(
    1024, 8.0, 0.1, 50.0, 20.0, @math3d.Vec3::zero(), 0.005,
  )
  let shadow_map = @gfx.new_image_handle(100, 1024, 1024)
  let depth_shader = @gfx.new_shader_handle(
    100, @shadow3d.shader_shadow_depth_wgsl(),
  )
  let lit_shader = @gfx.new_shader_handle(
    101, @shadow3d.shader3d_shadow_lit_untextured_wgsl(),
  )
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    12.0,
    0.5,
    0.6,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.4, -1.0, -0.6),
      @math3d.Vec3::new(1.0, 1.0, 0.95),
      0.9,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.25),
  )
  {
    cube_mesh: @mesh3d.Mesh3D::cube(1.0),
    sphere_mesh: @mesh3d.Mesh3D::sphere(0.6, 8, 6),
    ground_mesh: @mesh3d.Mesh3D::plane(20.0, 20.0),
    shadow_map,
    depth_shader,
    lit_shader,
    shadow_config,
    camera,
    lighting,
    input: @inpututil.new_input_helper(),
    frame: 0,
  }
}

// ============================================================
// Object placement
// ============================================================

///|
struct SceneObject {
  mesh : @mesh3d.Mesh3D
  model_matrix : @math3d.Mat4
}

///|
fn DemoState::build_objects(self : DemoState) -> Array[SceneObject] {
  let objects : Array[SceneObject] = []
  // Ground plane (slightly below origin)
  let ground_model = @math3d.Mat4::translation(0.0, -0.01, 0.0)
  objects.push({ mesh: self.ground_mesh, model_matrix: ground_model })
  // Cube 1: center-left
  let cube1_model = @math3d.Mat4::translation(-2.0, 0.5, 0.0)
  objects.push({ mesh: self.cube_mesh, model_matrix: cube1_model })
  // Cube 2: back-right, rotated
  let angle = self.frame.to_double() * 0.01
  let cube2_model = @math3d.Mat4::translation(2.5, 0.5, -1.5).multiply(
    @math3d.Mat4::rotation_y(angle),
  )
  objects.push({ mesh: self.cube_mesh, model_matrix: cube2_model })
  // Cube 3: small elevated
  let cube3_model = @math3d.Mat4::translation(0.0, 1.2, 2.0).multiply(
    @math3d.Mat4::scaling(0.6, 0.6, 0.6),
  )
  objects.push({ mesh: self.cube_mesh, model_matrix: cube3_model })
  // Sphere
  let sphere_model = @math3d.Mat4::translation(1.0, 0.6, 1.5)
  objects.push({ mesh: self.sphere_mesh, model_matrix: sphere_model })
  objects
}

// ============================================================
// Update
// ============================================================

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  // Slowly orbit camera
  self.camera = self.camera.orbit(0.005, 0.0)
}

// ============================================================
// Draw
// ============================================================

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let objects = self.build_objects()
  let config = self.shadow_config
  let lighting = self.lighting
  // Compute light-space matrix
  let light_vp = @shadow3d.light_space_matrix(
    lighting.directional.direction,
    config.center,
    config.distance,
    config.half_extent,
    config.near,
    config.far,
  )
  // Build ShadowCasters
  let casters : Array[@shadow3d.ShadowCaster] = []
  for i in 0..<objects.length() {
    casters.push(
      @shadow3d.ShadowCaster::new(objects[i].mesh, objects[i].model_matrix),
    )
  }
  // --- Pass 1: Depth pass ---
  let depth_cmds = @shadow3d.shadow_depth_pass_commands(
    self.shadow_map, self.depth_shader, casters, lighting, config,
  )
  // --- Pass 2: Lit pass ---
  let camera = self.camera.to_camera3d()
  let view_projection = camera.view_projection_matrix()
  let lit_cmds : Array[@gfx.DrawTrianglesCommand] = []
  for i in 0..<objects.length() {
    let obj = objects[i]
    let dst_region = @gfx.new_dst_region(
      0, 0, ctx.screen_w, ctx.screen_h, obj.mesh.indices.length(),
    )
    let cmd = @shadow3d.new_shadow_lit_mesh_draw_command(
      ctx.dst,
      self.lit_shader,
      dst_region,
      0,
      0,
      i,
      @gfx.blend_mode_from_int(0),
      obj.mesh,
      obj.model_matrix,
      view_projection,
      lighting,
      light_vp,
      config,
      self.shadow_map.id,
      self.shadow_map.id,
    )
    lit_cmds.push(cmd)
  }
  // Combine: depth pass first, then lit pass
  let all_cmds : Array[@gfx.DrawTrianglesCommand] = []
  for cmd in depth_cmds {
    all_cmds.push(cmd)
  }
  for cmd in lit_cmds {
    all_cmds.push(cmd)
  }
  all_cmds
}
