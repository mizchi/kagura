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
  mut frame_count : Int
  mut fps_timer : Double
  mut last_fps : Double
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
  // Create multiple emitters for stress test
  let emitters : Array[@particle3d.ParticleEmitter] = []
  let emitter_count = 50
  for i = 0; i < emitter_count; i = i + 1 {
    let angle = i.to_double() / emitter_count.to_double() * @math.PI * 2.0
    let radius = 2.0 + (i % 3).to_double()
    let x = @math.cos(angle) * radius
    let z = @math.sin(angle) * radius
    let config : @particle3d.EmitterConfig = {
      position: @math3d.Vec3::new(x, 0.0, z),
      spawn_rate: 500.0,
      initial_velocity_min: @math3d.Vec3::new(-0.5, 2.0, -0.5),
      initial_velocity_max: @math3d.Vec3::new(0.5, 5.0, 0.5),
      lifetime_min: 0.5,
      lifetime_max: 2.0,
      size_min: 0.03,
      size_max: 0.15,
      color_start: @math3d.Vec4::new(1.0, 0.9, 0.3, 1.0),
      color_end: @math3d.Vec4::new(1.0, 0.1, 0.0, 0.0),
      gravity: @math3d.Vec3::new(0.0, -3.0, 0.0),
      max_particles: 2048,
    }
    emitters.push(@particle3d.ParticleEmitter::new(config))
  }
  let particle_shader = @gfx.new_shader_handle(
    20,
    @draw3d.shader3d_particle_wgsl(),
  )
  {
    camera,
    emitters,
    particle_shader,
    time: 0.0,
    frame_count: 0,
    fps_timer: 0.0,
    last_fps: 0.0,
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
  }
}

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  let dt = 1.0 / 60.0
  self.time = self.time + dt
  self.frame_count = self.frame_count + 1
  self.fps_timer = self.fps_timer + dt
  // Report FPS every second
  if self.fps_timer >= 1.0 {
    self.last_fps = self.frame_count.to_double() / self.fps_timer
    let mut total_particles = 0
    for emitter in self.emitters {
      total_particles = total_particles + emitter.particle_count()
    }
    println(
      "[particle_bench] fps=" +
      self.last_fps.to_int().to_string() +
      " particles=" +
      total_particles.to_string() +
      " emitters=" +
      self.emitters.length().to_string(),
    )
    self.frame_count = 0
    self.fps_timer = 0.0
  }
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
