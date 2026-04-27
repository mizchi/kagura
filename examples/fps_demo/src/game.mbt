// ============================================================
// FPS Demo - First Person Shooter with procedural arena
// ============================================================

// Screen

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// Arena

///|
let arena_half : Double = 10.0

///|
let wall_height : Double = 3.0

///|
let wall_thickness : Double = 0.5

// Player

///|
let move_speed : Double = 0.1

///|
let mouse_sensitivity : Double = 0.005

///|
let gravity : Double = 0.015

///|
let jump_velocity : Double = 0.25

///|
let eye_height : Double = 1.7

// Bullet

///|
let bullet_speed : Double = 0.5

///|
let bullet_max_life : Int = 120

///|
let bullet_radius : Double = 0.15

// Target

///|
let target_count : Int = 5

///|
let target_radius : Double = 0.4

///|
let hit_distance : Double = 0.6

// Pillar / box counts

///|
let pillar_count : Int = 8

///|
let box_count : Int = 6

// ============================================================
// Data structures
// ============================================================

///|
struct Bullet {
  mut position : @math3d.Vec3
  direction : @math3d.Vec3
  mut life : Int
}

///|
struct Target {
  mut position : @math3d.Vec3
  mut active : Bool
}

///|
struct Obstacle {
  position : @math3d.Vec3
  scale : @math3d.Vec3
}

///|
struct Meshes {
  ground : @mesh3d.Mesh3D
  wall : @mesh3d.Mesh3D
  pillar : @mesh3d.Mesh3D
  box_mesh : @mesh3d.Mesh3D
  target : @mesh3d.Mesh3D
  bullet : @mesh3d.Mesh3D
}

///|
struct GameState {
  mut camera : @camera3d.FPSCamera
  input : @inpututil.InputHelper
  lighting : @light3d.LightingEnvironment
  meshes : Meshes
  shader3d : @gfx.ShaderHandle
  bullets : Array[Bullet]
  targets : Array[Target]
  pillars : Array[Obstacle]
  boxes : Array[Obstacle]
  mut score : Int
  mut frame : Int
  mut prev_cursor_x : Double
  mut prev_cursor_y : Double
  mut velocity_y : Double
  mut on_ground : Bool
}

// ============================================================
// Pseudo-random (deterministic from seed)
// ============================================================

///|
fn pseudo_random(seed : Int) -> Double {
  let n = (seed * 1103515245 + 12345).land(0x7FFFFFFF)
  n.to_double() / 2147483647.0
}

// ============================================================
// Target spawn positions
// ============================================================

///|
fn spawn_target_position(index : Int, frame : Int) -> @math3d.Vec3 {
  let seed = index * 137 + frame * 31
  let limit = arena_half - 2.0
  let x = pseudo_random(seed) * limit * 2.0 - limit
  let z = pseudo_random(seed + 7) * limit * 2.0 - limit
  @math3d.Vec3::new(x, 1.0, z)
}

// ============================================================
// Constructor
// ============================================================

///|
fn GameState::new() -> GameState {
  // Create targets
  let targets : Array[Target] = []
  for i in 0..<target_count {
    targets.push({ position: spawn_target_position(i, 0), active: true })
  }
  // Create pillars (deterministic positions)
  let pillars : Array[Obstacle] = []
  for i in 0..<pillar_count {
    let angle = i.to_double() / pillar_count.to_double() * 2.0 * @math.PI
    let r = 5.0 + pseudo_random(i * 53) * 3.0
    let x = r * @math.cos(angle)
    let z = r * @math.sin(angle)
    pillars.push({
      position: @math3d.Vec3::new(x, wall_height / 2.0, z),
      scale: @math3d.Vec3::new(0.6, wall_height, 0.6),
    })
  }
  // Create boxes
  let boxes : Array[Obstacle] = []
  for i in 0..<box_count {
    let seed = i * 97 + 42
    let limit = arena_half - 2.0
    let x = pseudo_random(seed) * limit * 2.0 - limit
    let z = pseudo_random(seed + 13) * limit * 2.0 - limit
    let size = 0.8 + pseudo_random(seed + 29) * 0.6
    boxes.push({
      position: @math3d.Vec3::new(x, size / 2.0, z),
      scale: @math3d.Vec3::new(size, size, size),
    })
  }
  let camera = @camera3d.FPSCamera::new(
    @math3d.Vec3::new(0.0, eye_height, 8.0),
    0.0,
    0.0,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.5,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.3, -1.0, -0.5),
      @math3d.Vec3::one(),
      0.8,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::one(), 0.3),
  )
  {
    camera,
    input: @inpututil.new_input_helper(),
    lighting,
    meshes: {
      ground: @mesh3d.Mesh3D::plane(
        arena_half * 2.0,
        arena_half * 2.0,
        subdivisions=16,
      ),
      wall: @mesh3d.Mesh3D::cube(1.0),
      pillar: @mesh3d.Mesh3D::cube(1.0),
      box_mesh: @mesh3d.Mesh3D::cube(1.0),
      target: @mesh3d.Mesh3D::sphere(target_radius, 8, 6),
      bullet: @mesh3d.Mesh3D::sphere(bullet_radius, 4, 3),
    },
    shader3d: @gfx.new_shader_handle(10, @draw3d.shader3d_lit_untextured_wgsl()),
    bullets: [],
    targets,
    pillars,
    boxes,
    score: 0,
    frame: 0,
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
    velocity_y: 0.0,
    on_ground: true,
  }
}

// ============================================================
// Update
// ============================================================

///|
fn GameState::update(self : GameState, input : @core.InputSnapshot) -> Unit {
  self.frame = self.frame + 1
  @inpututil.update_input_helper(self.input, input)

  // Mouse look: delta-based (move mouse = rotate camera)
  if self.frame > 1 {
    let dx = input.cursor_x - self.prev_cursor_x
    let dy = input.cursor_y - self.prev_cursor_y
    self.camera = self.camera.look(
      dx * -mouse_sensitivity,
      dy * -mouse_sensitivity,
    )
  }
  self.prev_cursor_x = input.cursor_x
  self.prev_cursor_y = input.cursor_y

  // WASD movement (XZ plane only, camera-relative)
  let mut move_fwd = 0.0
  let mut move_right = 0.0
  if @inpututil.is_move_up(self.input.key_state) {
    move_fwd = move_fwd + move_speed
  }
  if @inpututil.is_move_down(self.input.key_state) {
    move_fwd = move_fwd - move_speed
  }
  if @inpututil.is_move_right(self.input.key_state) {
    move_right = move_right + move_speed
  }
  if @inpututil.is_move_left(self.input.key_state) {
    move_right = move_right - move_speed
  }
  // Get camera forward/right projected onto XZ plane
  let fwd = self.camera.forward()
  let fwd_xz = @math3d.Vec3::new(fwd.x, 0.0, fwd.z).normalize()
  let right = self.camera.right()
  let right_xz = @math3d.Vec3::new(right.x, 0.0, right.z).normalize()
  let move_delta = fwd_xz.scale(move_fwd).add(right_xz.scale(move_right))
  let new_x = self.camera.position.x + move_delta.x
  let new_z = self.camera.position.z + move_delta.z
  // Clamp to arena
  let limit = arena_half - 0.5
  let clamped_x = clamp(new_x, -limit, limit)
  let clamped_z = clamp(new_z, -limit, limit)

  // Gravity / Jump
  if @inpututil.is_key_just_pressed(self.input.key_state, @inpututil.key_space) &&
    self.on_ground {
    self.velocity_y = jump_velocity
    self.on_ground = false
  }
  self.velocity_y = self.velocity_y - gravity
  let mut new_y = self.camera.position.y + self.velocity_y
  if new_y <= eye_height {
    new_y = eye_height
    self.velocity_y = 0.0
    self.on_ground = true
  }
  self.camera = @camera3d.FPSCamera::new(
    @math3d.Vec3::new(clamped_x, new_y, clamped_z),
    self.camera.yaw,
    self.camera.pitch,
    self.camera.fov_y_rad,
    self.camera.aspect,
    self.camera.near,
    self.camera.far,
  )

  // Shoot (left click)
  if @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) {
    let dir = self.camera.forward()
    self.bullets.push({
      position: self.camera.position,
      direction: dir,
      life: bullet_max_life,
    })
  }

  // Update bullets
  let active_bullets : Array[Bullet] = []
  for b in self.bullets {
    b.position = b.position.add(b.direction.scale(bullet_speed))
    b.life = b.life - 1
    // Hit detection with targets
    let mut hit = false
    for t in self.targets {
      if t.active {
        let dist = b.position.sub(t.position).length()
        if dist < hit_distance {
          hit = true
          t.active = false
          self.score = self.score + 1
          // Respawn target
          t.position = spawn_target_position(self.frame, self.score * 7 + 3)
          t.active = true
          break
        }
      }
    }
    if !hit && b.life > 0 {
      active_bullets.push(b)
    }
  }
  // Replace bullets array contents
  self.bullets.clear()
  for b in active_bullets {
    self.bullets.push(b)
  }
}

// ============================================================
// Draw
// ============================================================

///|
fn GameState::draw(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let scene = self.build_scene3d()
  let cmds = @renderer3d.render_scene3d_to_dst(
    scene,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
  )
  // Score overlay (top-left area)
  let sw = screen_w.to_double()
  let frame2d = @renderer2d.RenderFrame2D::new(
    dst=ctx.dst,
    shader=ctx.shader,
    screen_w=ctx.screen_w,
    screen_h=ctx.screen_h,
  )
  let score_color = @renderer2d.color_white()
  // Draw "SCORE" label
  let label_chars = [83, 67, 79, 82, 69] // S C O R E
  @renderer2d.append_dot_text(
    cmds,
    frame2d,
    @renderer2d.DotText2D::new(
      chars=label_chars,
      cx=50.0,
      cy=15.0,
      color=score_color,
    ),
  )
  // Draw score number
  @renderer2d.append_number(
    cmds,
    frame2d,
    @renderer2d.Number2D::new(
      number=self.score,
      cx=50.0,
      cy=35.0,
      color=score_color,
      scale=1.2,
    ),
  )
  // Crosshair (center of screen)
  let ch_color = @renderer2d.color_from_hex_alpha(0x00FF00, 0.8)
  let cx = sw / 2.0
  let cy = screen_h.to_double() / 2.0
  @renderer2d.append_rect_fill(
    cmds,
    frame2d,
    @renderer2d.RectFill2D::new(
      x=cx - 8.0,
      y=cy - 1.0,
      w=16.0,
      h=2.0,
      color=ch_color,
    ),
  )
  @renderer2d.append_rect_fill(
    cmds,
    frame2d,
    @renderer2d.RectFill2D::new(
      x=cx - 1.0,
      y=cy - 8.0,
      w=2.0,
      h=16.0,
      color=ch_color,
    ),
  )
  cmds
}

// ============================================================
// Scene building
// ============================================================

// Colors

///|
let color_ground : @math3d.Vec4 = @math3d.Vec4::new(0.35, 0.45, 0.35, 1.0)

///|
let color_wall : @math3d.Vec4 = @math3d.Vec4::new(0.5, 0.5, 0.55, 1.0)

///|
let color_pillar : @math3d.Vec4 = @math3d.Vec4::new(0.6, 0.55, 0.45, 1.0)

///|
let color_box : @math3d.Vec4 = @math3d.Vec4::new(0.45, 0.35, 0.25, 1.0)

///|
let color_target : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.15, 0.15, 1.0)

///|
let color_bullet : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 0.3, 1.0)

///|
fn GameState::build_scene3d(self : GameState) -> @scene3d.Scene3D {
  let objects : Array[@scene3d.Object3D] = []

  // Ground
  objects.push(
    @scene3d.object3d(
      mesh=self.meshes.ground,
      color=color_ground,
      sort_bias=1.0,
    ),
  )

  // Walls (split into segments for better depth sorting)
  let h = arena_half
  let wh = wall_height / 2.0
  let wt = wall_thickness
  let wall_segments = 4
  let seg_len = h * 2.0 / wall_segments.to_double()
  for i in 0..<wall_segments {
    let offset = -h + seg_len / 2.0 + i.to_double() * seg_len
    // North wall segment
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.wall,
        position=@math3d.Vec3::new(offset, wh, -(h + wt / 2.0)),
        scale=@math3d.Vec3::new(seg_len, wall_height, wt),
        color=color_wall,
      ),
    )
    // South wall segment
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.wall,
        position=@math3d.Vec3::new(offset, wh, h + wt / 2.0),
        scale=@math3d.Vec3::new(seg_len, wall_height, wt),
        color=color_wall,
      ),
    )
    // West wall segment
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.wall,
        position=@math3d.Vec3::new(-(h + wt / 2.0), wh, offset),
        scale=@math3d.Vec3::new(wt, wall_height, seg_len),
        color=color_wall,
      ),
    )
    // East wall segment
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.wall,
        position=@math3d.Vec3::new(h + wt / 2.0, wh, offset),
        scale=@math3d.Vec3::new(wt, wall_height, seg_len),
        color=color_wall,
      ),
    )
  }

  // Pillars
  for p in self.pillars {
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.pillar,
        position=p.position,
        scale=p.scale,
        color=color_pillar,
      ),
    )
  }

  // Boxes
  for b in self.boxes {
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.box_mesh,
        position=b.position,
        scale=b.scale,
        color=color_box,
      ),
    )
  }

  // Targets
  for t in self.targets {
    if t.active {
      objects.push(
        @scene3d.object3d(
          mesh=self.meshes.target,
          position=t.position,
          color=color_target,
        ),
      )
    }
  }

  // Bullets
  for b in self.bullets {
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.bullet,
        position=b.position,
        color=color_bullet,
      ),
    )
  }

  @scene3d.scene3d(
    objects~,
    camera=self.camera.to_camera3d(),
    lighting=self.lighting,
  )
}

// ============================================================
// Utility
// ============================================================

///|
fn clamp(v : Double, lo : Double, hi : Double) -> Double {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}
