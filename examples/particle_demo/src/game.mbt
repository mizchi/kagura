///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
struct DemoState {
  mut camera : @camera3d.OrbitCamera
  emitters : Array[@particle3d.ParticleEmitter]
  particle_shader : @gfx.ShaderHandle
  mut time : Double
  mut prev_cursor_x : Double
  mut prev_cursor_y : Double
}

///|
fn DemoState::new() -> DemoState {
  let aspect = screen_w.to_double() / screen_h.to_double()
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    6.0,
    0.0,
    0.3,
    @math.PI / 4.0,
    aspect,
    0.1,
    100.0,
  )
  // Fire pillar emitter
  let fire_config : @particle3d.EmitterConfig = {
    position: @math3d.Vec3::new(0.0, 0.0, 0.0),
    spawn_rate: 80.0,
    initial_velocity_min: @math3d.Vec3::new(-0.3, 2.0, -0.3),
    initial_velocity_max: @math3d.Vec3::new(0.3, 4.0, 0.3),
    lifetime_min: 0.5,
    lifetime_max: 1.5,
    size_min: 0.05,
    size_max: 0.2,
    color_start: @math3d.Vec4::new(1.0, 0.9, 0.3, 1.0),
    color_end: @math3d.Vec4::new(1.0, 0.1, 0.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.0, 0.0),
    max_particles: 256,
  }
  let emitter = @particle3d.ParticleEmitter::new(fire_config)
  let particle_shader = @gfx.new_shader_handle(
    20, @draw3d.shader3d_particle_wgsl(),
  )
  {
    camera,
    emitters: [emitter],
    particle_shader,
    time: 0.0,
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
  }
}

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  let dt = 1.0 / 60.0
  self.time = self.time + dt
  // Camera orbit with left mouse drag
  let dx = input.cursor_x - self.prev_cursor_x
  let dy = input.cursor_y - self.prev_cursor_y
  self.prev_cursor_x = input.cursor_x
  self.prev_cursor_y = input.cursor_y
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
  if input.wheel_y != 0.0 {
    self.camera = self.camera.zoom(input.wheel_y * 0.05)
  }
  // Update all emitters
  for emitter in self.emitters {
    emitter.update(dt)
  }
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cam = self.camera.to_camera3d()
  let vp = cam.view_projection_matrix()
  let view = cam.view_matrix()
  // Extract camera right and up from view matrix for billboarding
  let cam_right = @math3d.Vec3::new(
    view.elements[0],
    view.elements[4],
    view.elements[8],
  )
  let cam_up = @math3d.Vec3::new(
    view.elements[1],
    view.elements[5],
    view.elements[9],
  )
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  for emitter in self.emitters {
    let (vertex_data, indices) = emitter.build_billboard_vertices(
      cam_right, cam_up,
    )
    if indices.length() > 0 {
      let region = @gfx.new_dst_region(
        0,
        0,
        ctx.screen_w,
        ctx.screen_h,
        indices.length(),
      )
      let cmd = @draw3d.new_particle_draw_command(
        ctx.dst,
        self.particle_shader,
        region,
        0,
        200,
        self.time.to_int(),
        @gfx.blend_mode_from_int(2), // Add
        vertex_data,
        indices,
        vp,
        [],
      )
      commands.push(cmd)
    }
  }
  commands
}
