// ============================================================
// Physics 3D Demo
// ============================================================
// Cubes and spheres falling onto a ground plane with bouncing.
// Uses physics3d for simulation and scene3d for rendering.

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  cube_mesh : @mesh3d.Mesh3D
  sphere_mesh : @mesh3d.Mesh3D
  ground_mesh : @mesh3d.Mesh3D
  world : @physics3d.PhysicsWorld
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  input : @inpututil.InputHelper
  shader3d : @gfx.ShaderHandle
  mut frame : Int
}

// Body colors: index -> hex color
///|
let body_colors : Array[Int] = [
  0x888888, // 0: ground (gray)
  0xE04040, // 1: red cube
  0x40A0E0, // 2: blue sphere
  0xE0C040, // 3: yellow cube
  0x40E070, // 4: green sphere
  0xC060D0, // 5: purple cube
  0xE08040, // 6: orange sphere
  0x60D0D0, // 7: cyan cube
  0xD06080, // 8: pink sphere
  0x80D060, // 9: lime cube
  0xA0A0E0, // 10: lavender sphere
  0xD0A060, // 11: tan cube
  0x60A0A0, // 12: teal sphere
]

///|
fn DemoState::new() -> DemoState {
  let world = @physics3d.PhysicsWorld::new(
    @math3d.Vec3::new(0.0, -9.8, 0.0),
    4.0,
  )
  // Ground: static AABB
  world.add_body({
    id: 0,
    body_type: @physics3d.Static,
    position: @math3d.Vec3::new(0.0, -0.5, 0.0),
    velocity: @math3d.Vec3::zero(),
    force: @math3d.Vec3::zero(),
    rotation: @math3d.Quaternion::identity(),
    angular_velocity: @math3d.Vec3::zero(),
    torque: @math3d.Vec3::zero(),
    mass: 0.0,
    inv_mass: 0.0,
    inv_inertia: 0.0,
    restitution: 0.5,
    friction: 0.6,
    collider: @physics3d.AABBShape(
      @math3d.Vec3::new(10.0, 0.5, 10.0),
      @math3d.Vec3::zero(),
    ),
    linear_damping: 0.0,
    angular_damping: 0.0,
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
  })
  // Dynamic bodies: cubes and spheres at various heights
  let spawn_data : Array[(Double, Double, Double, Bool)] = [
    // (x, y, z, is_sphere) - spread out to avoid overlap
    (-3.0, 2.0, -2.0, false),
    (2.5, 2.5, -2.5, true),
    (3.0, 3.0, 1.5, false),
    (-2.5, 3.5, 2.0, true),
    (0.0, 4.0, -3.0, false),
    (-1.0, 4.5, 3.0, true),
    (3.5, 5.0, 0.0, false),
    (-3.5, 5.5, -1.0, true),
    (1.5, 3.0, 2.5, false),
    (-1.5, 3.5, -3.5, true),
    (0.0, 4.0, 3.5, false),
    (2.0, 4.5, -1.0, true),
  ]
  for i = 0; i < spawn_data.length(); i = i + 1 {
    let (x, y, z, is_sphere) = spawn_data[i]
    let id = i + 1
    let collider = if is_sphere {
      @physics3d.SphereShape(@math3d.Vec3::zero(), 0.4)
    } else {
      @physics3d.AABBShape(
        @math3d.Vec3::new(0.4, 0.4, 0.4),
        @math3d.Vec3::zero(),
      )
    }
    let mass = 1.0
    // Correct moment of inertia: cube I = m/6 * s^2, sphere I = 2/5 * m * r^2
    let inv_inertia = if is_sphere {
      1.0 / (0.4 * mass * 0.4 * 0.4) // 2/5 * m * r^2
    } else {
      6.0 / (mass * 0.8 * 0.8) // 1 / (m/6 * s^2)
    }
    world.add_body({
      id,
      body_type: @physics3d.Dynamic,
      position: @math3d.Vec3::new(x, y, z),
      velocity: @math3d.Vec3::zero(),
      force: @math3d.Vec3::zero(),
      rotation: @math3d.Quaternion::identity(),
      angular_velocity: @math3d.Vec3::zero(),
      torque: @math3d.Vec3::zero(),
      mass,
      inv_mass: 1.0 / mass,
      inv_inertia,
      restitution: 0.3,
      friction: 0.6,
      collider,
      linear_damping: 0.05,
      angular_damping: 0.15,
      is_sleeping: false,
      sleep_timer: 0.0,
      is_bullet: false,
    })
  }
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    10.0,
    0.4,
    0.5,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.4, -1.0, -0.6),
      @math3d.Vec3::new(1.0, 1.0, 0.95),
      0.85,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.3),
  )
  {
    cube_mesh: @mesh3d.Mesh3D::cube(0.8),
    sphere_mesh: @mesh3d.Mesh3D::sphere(0.4, 8, 6),
    ground_mesh: @mesh3d.Mesh3D::plane(20.0, 20.0),
    world,
    camera,
    lighting,
    input: @inpututil.new_input_helper(),
    shader3d: @gfx.new_shader_handle(10, @draw3d.shader3d_lit_untextured_wgsl()),
    frame: 0,
  }
}

// ============================================================
// Update
// ============================================================

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  // Step physics at fixed dt
  let sub_steps = 2
  let dt = 1.0 / 60.0 / sub_steps.to_double()
  for _s = 0; _s < sub_steps; _s = _s + 1 {
    self.world.step(dt)
  }
  // Slowly orbit camera
  self.camera = self.camera.orbit(0.004, 0.0)
}

// ============================================================
// Draw
// ============================================================

///|
fn body_color(id : Int) -> @math3d.Vec4 {
  let hex = if id < body_colors.length() {
    body_colors[id]
  } else {
    0xAAAAAA
  }
  let r = ((hex >> 16) & 0xFF).to_double() / 255.0
  let g = ((hex >> 8) & 0xFF).to_double() / 255.0
  let b = (hex & 0xFF).to_double() / 255.0
  @math3d.Vec4::new(r, g, b, 1.0)
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let objects : Array[@scene3d.Object3D] = []
  for i = 0; i < self.world.bodies.length(); i = i + 1 {
    let body = self.world.bodies[i]
    let color = body_color(body.id)
    let is_ground = body.id == 0
    let mesh = if is_ground {
      self.ground_mesh
    } else {
      match body.collider {
        @physics3d.SphereShape(_, _) => self.sphere_mesh
        @physics3d.AABBShape(_, _) => self.cube_mesh
      }
    }
    let transform = @transform3d.Transform3D::from_position_rotation(
      body.position,
      body.rotation,
    )
    objects.push({
      mesh,
      transform,
      color,
      material: None,
      sort_bias: if is_ground { 100.0 } else { 0.0 },
    })
  }
  let camera = self.camera.to_camera3d()
  let scene = @scene3d.scene3d(
    objects~,
    camera~,
    lighting=self.lighting,
  )
  @scene3d.render_scene3d_gpu(scene, ctx.dst, self.shader3d, ctx.screen_w, ctx.screen_h)
}
