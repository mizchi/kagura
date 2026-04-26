// ============================================================
// PBR Material Demo
// ============================================================
// 5x5 grid of spheres with varying metallic (columns) and roughness (rows).

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
let grid_size : Int = 5

///|
let sphere_spacing : Double = 2.5

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  graph : @scene3d.SceneGraph
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  pbr_shader : @gfx.ShaderHandle
  pbr_textured_shader : @gfx.ShaderHandle
  lit_shader : @gfx.ShaderHandle
  lit_textured_shader : @gfx.ShaderHandle
  mut prev_cursor_x : Double
  mut prev_cursor_y : Double
}

///|
fn DemoState::new() -> DemoState {
  let graph = @scene3d.SceneGraph::new()
  let sphere_mesh = @mesh3d.Mesh3D::sphere(1.0, 32, 16)
  // Build 5x5 grid: metallic varies by column, roughness varies by row
  let offset = (grid_size.to_double() - 1.0) * sphere_spacing / 2.0
  for row in 0..<grid_size {
    let roughness = (row.to_double() + 0.5) / grid_size.to_double()
    for col in 0..<grid_size {
      let metallic = col.to_double() / (grid_size.to_double() - 1.0)
      let x = col.to_double() * sphere_spacing - offset
      let y = row.to_double() * sphere_spacing - offset
      let r = 0.9
      let g = 0.3 + metallic * 0.4
      let b = 0.2 + roughness * 0.3
      let material = @scene3d.Material::new(
        color=@math3d.Vec4::new(r, g, b, 1.0),
        metallic~,
        roughness~,
      )
      let node = @scene3d.scene_node(
        mesh=Some(sphere_mesh),
        position=@math3d.Vec3::new(x, y, 0.0),
        material=Some(material),
      )
      let _ = graph.add_node(node)
    }
  }
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    18.0,
    0.0,
    0.3,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.5, -0.7, -1.0),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      1.0,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.1),
  )
  let pbr_shader = @gfx.new_shader_handle(
    10,
    @draw3d.shader3d_pbr_untextured_wgsl(),
  )
  let pbr_textured_shader = @gfx.new_shader_handle(
    11,
    @draw3d.shader3d_pbr_wgsl(),
  )
  let lit_shader = @gfx.new_shader_handle(
    12,
    @draw3d.shader3d_lit_untextured_wgsl(),
  )
  let lit_textured_shader = @gfx.new_shader_handle(
    13,
    @draw3d.shader3d_lit_wgsl(),
  )
  {
    graph,
    camera,
    lighting,
    pbr_shader,
    pbr_textured_shader,
    lit_shader,
    lit_textured_shader,
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
  }
}

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  let dx = input.cursor_x - self.prev_cursor_x
  let dy = input.cursor_y - self.prev_cursor_y
  self.prev_cursor_x = input.cursor_x
  self.prev_cursor_y = input.cursor_y
  // Left mouse button drag -> orbit
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
  // Scroll wheel -> zoom
  if input.wheel_y != 0.0 {
    self.camera = self.camera.zoom(input.wheel_y * 0.05)
  }
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  @scene3d.render_scene3d_graph_gpu(
    self.graph,
    self.camera.to_camera3d(),
    lighting=self.lighting,
    ctx.dst,
    self.lit_shader,
    shader3d_textured=Some(self.lit_textured_shader),
    shader3d_pbr=Some(self.pbr_shader),
    shader3d_pbr_textured=Some(self.pbr_textured_shader),
    ctx.screen_w,
    ctx.screen_h,
  )
}
