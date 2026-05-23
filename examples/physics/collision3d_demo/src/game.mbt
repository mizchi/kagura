// ============================================================
// Collision3D Demo - Ray/AABB/Sphere + SpatialHashGrid
// ============================================================
// WASD + mouse look to navigate, camera center raycast hits objects.
// Green = hit by ray, default color = not hit.
// Uses SpatialHashGrid for broadphase candidate selection.

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
let move_speed : Double = 0.1

///|
let mouse_sensitivity : Double = 0.005

///|
let eye_height : Double = 1.7

///|
let ray_max_dist : Double = 50.0

///|
let arena_half : Double = 12.0

///|
let obj_count : Int = 12

// ============================================================
// Collider types
// ============================================================

///|
enum ColliderKind {
  Box
  Ball
}

///|
struct ColliderObj {
  id : Int
  kind : ColliderKind
  position : @math3d.Vec3
  size : Double // half-extent for box, radius for sphere
}

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  mut camera : @camera3d.FPSCamera
  input : @inpututil.InputHelper
  lighting : @light3d.LightingEnvironment
  cube_mesh : @mesh3d.Mesh3D
  sphere_mesh : @mesh3d.Mesh3D
  ground_mesh : @mesh3d.Mesh3D
  objects : Array[ColliderObj]
  shader3d : @gfx.ShaderHandle
  mut hit_id : Int // -1 = no hit
  mut hit_point : @math3d.Vec3
  mut frame : Int
  mut prev_cursor_x : Double
  mut prev_cursor_y : Double
}

// ============================================================
// Pseudo-random
// ============================================================

///|
fn pseudo_random(seed : Int) -> Double {
  let n = (seed * 1103515245 + 12345).land(0x7FFFFFFF)
  n.to_double() / 2147483647.0
}

// ============================================================
// Constructor
// ============================================================

///|
fn DemoState::new() -> DemoState {
  let objects : Array[ColliderObj] = []
  for i in 0..<obj_count {
    let seed = i * 137 + 42
    let limit = arena_half - 2.0
    let x = pseudo_random(seed) * limit * 2.0 - limit
    let z = pseudo_random(seed + 7) * limit * 2.0 - limit
    let kind : ColliderKind = if i % 2 == 0 { Box } else { Ball }
    let size = 0.5 + pseudo_random(seed + 13) * 0.5
    let y = match kind {
      Box => size // half-extent, center at size
      Ball => size // radius, center at size
    }
    objects.push({ id: i, kind, position: @math3d.Vec3::new(x, y, z), size })
  }
  // Place a box directly in front of camera for easy hit testing
  objects.push({
    id: obj_count,
    kind: Box,
    position: @math3d.Vec3::new(0.0, 1.0, 4.0),
    size: 1.0,
  })

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
    cube_mesh: @mesh3d.Mesh3D::cube(1.0),
    sphere_mesh: @mesh3d.Mesh3D::sphere(1.0, 10, 8),
    ground_mesh: @mesh3d.Mesh3D::plane(
      arena_half * 2.0,
      arena_half * 2.0,
      subdivisions=16,
    ),
    objects,
    shader3d: @gfx.new_shader_handle(10, @draw3d.shader3d_lit_untextured_wgsl()),
    hit_id: -1,
    hit_point: @math3d.Vec3::zero(),
    frame: 0,
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
  }
}

// ============================================================
// Update
// ============================================================

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  self.frame = self.frame + 1
  @inpututil.update_input_helper(self.input, input)

  // Mouse look (delta-based)
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

  // WASD movement
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
  let fwd = self.camera.forward()
  let fwd_xz = @math3d.Vec3::new(fwd.x, 0.0, fwd.z).normalize()
  let right = self.camera.right()
  let right_xz = @math3d.Vec3::new(right.x, 0.0, right.z).normalize()
  let move_delta = fwd_xz.scale(move_fwd).add(right_xz.scale(move_right))
  let new_x = self.camera.position.x + move_delta.x
  let new_z = self.camera.position.z + move_delta.z
  let limit = arena_half - 0.5
  let clamped_x = clamp(new_x, -limit, limit)
  let clamped_z = clamp(new_z, -limit, limit)
  self.camera = @camera3d.FPSCamera::new(
    @math3d.Vec3::new(clamped_x, eye_height, clamped_z),
    self.camera.yaw,
    self.camera.pitch,
    self.camera.fov_y_rad,
    self.camera.aspect,
    self.camera.near,
    self.camera.far,
  )

  // Raycast from camera center
  let ray = @collision3d.Ray::new(self.camera.position, self.camera.forward())

  // Build SpatialHashGrid for broadphase
  let grid = @collision3d.SpatialHashGrid::new(3.0)
  for obj in self.objects {
    let aabb = match obj.kind {
      Box =>
        @collision3d.AABB::from_center_extents(
          obj.position,
          @math3d.Vec3::new(obj.size, obj.size, obj.size),
        )
      Ball =>
        @collision3d.AABB::from_center_extents(
          obj.position,
          @math3d.Vec3::new(obj.size, obj.size, obj.size),
        )
    }
    grid.insert(obj.id, aabb)
  }

  // Query broadphase candidates along ray
  let candidates = grid.query_ray(ray, ray_max_dist)

  // Narrowphase: find closest hit
  self.hit_id = -1
  let mut closest_dist = ray_max_dist
  for idx in candidates {
    let obj = self.objects[idx]
    let result = match obj.kind {
      Box => {
        let aabb = @collision3d.AABB::from_center_extents(
          obj.position,
          @math3d.Vec3::new(obj.size, obj.size, obj.size),
        )
        ray.intersects_aabb(aabb)
      }
      Ball => {
        let sphere = @collision3d.Sphere::new(obj.position, obj.size)
        ray.intersects_sphere(sphere)
      }
    }
    if result.hit && result.distance < closest_dist && result.distance > 0.0 {
      closest_dist = result.distance
      self.hit_id = obj.id
      self.hit_point = result.point
    }
  }
}

// ============================================================
// Draw
// ============================================================

///|
let color_box : @math3d.Vec4 = @math3d.Vec4::new(0.5, 0.5, 0.6, 1.0)

///|
let color_ball : @math3d.Vec4 = @math3d.Vec4::new(0.6, 0.5, 0.5, 1.0)

///|
let color_hit : @math3d.Vec4 = @math3d.Vec4::new(0.2, 1.0, 0.3, 1.0)

///|
let color_ground : @math3d.Vec4 = @math3d.Vec4::new(0.3, 0.35, 0.3, 1.0)

///|
let color_hit_marker : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 0.0, 1.0)

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let objects : Array[@scene3d.Object3D] = []

  // Ground
  objects.push(
    @scene3d.object3d(mesh=self.ground_mesh, color=color_ground, sort_bias=1.0),
  )

  // Objects
  for obj in self.objects {
    let is_hit = obj.id == self.hit_id
    let color = if is_hit {
      color_hit
    } else {
      match obj.kind {
        Box => color_box
        Ball => color_ball
      }
    }
    match obj.kind {
      Box =>
        objects.push(
          @scene3d.object3d(
            mesh=self.cube_mesh,
            position=obj.position,
            scale=@math3d.Vec3::new(
              obj.size * 2.0,
              obj.size * 2.0,
              obj.size * 2.0,
            ),
            color~,
          ),
        )
      Ball =>
        objects.push(
          @scene3d.object3d(
            mesh=self.sphere_mesh,
            position=obj.position,
            scale=@math3d.Vec3::new(obj.size, obj.size, obj.size),
            color~,
          ),
        )
    }
  }

  // Hit marker (small yellow sphere at hit point)
  if self.hit_id >= 0 {
    objects.push(
      @scene3d.object3d(
        mesh=self.sphere_mesh,
        position=self.hit_point,
        scale=@math3d.Vec3::new(0.08, 0.08, 0.08),
        color=color_hit_marker,
      ),
    )
  }

  let scene = @scene3d.scene3d(
    objects~,
    camera=self.camera.to_camera3d(),
    lighting=self.lighting,
  )
  let cmds = @renderer3d.render_scene3d_to_dst(
    scene,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
  )

  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let frame2d = @renderer2d.RenderFrame2D::new(
    dst=ctx.dst,
    shader=ctx.shader,
    screen_w=ctx.screen_w,
    screen_h=ctx.screen_h,
  )

  // Crosshair
  let ch_color = @renderer2d.color_from_hex_alpha(0x00FF00, 0.8)
  let cx = sw / 2.0
  let cy = sh / 2.0
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

  // HUD: hit info
  if self.hit_id >= 0 {
    let obj = self.objects[self.hit_id]
    let kind_chars = match obj.kind {
      Box => ascii("HIT: BOX")
      Ball => ascii("HIT: BALL")
    }
    @renderer2d.append_dot_text(
      cmds,
      frame2d,
      @renderer2d.DotText2D::new(
        chars=kind_chars,
        cx=70.0,
        cy=15.0,
        color=@renderer2d.color_from_hex(0x00FF00),
      ),
    )
    @renderer2d.append_number(
      cmds,
      frame2d,
      @renderer2d.Number2D::new(
        number=self.hit_id,
        cx=70.0,
        cy=30.0,
        color=@renderer2d.color_from_hex(0x00FF00),
      ),
    )
  } else {
    @renderer2d.append_dot_text(
      cmds,
      frame2d,
      @renderer2d.DotText2D::new(
        chars=ascii("NO HIT"),
        cx=60.0,
        cy=15.0,
        color=@renderer2d.color_from_hex(0x888888),
      ),
    )
  }

  // Instructions
  @renderer2d.append_dot_text(
    cmds,
    frame2d,
    @renderer2d.DotText2D::new(
      chars=ascii("WASD:MOVE MOUSE:LOOK"),
      cx=150.0,
      cy=sh - 15.0,
      color=@renderer2d.color_from_hex(0x666666),
      scale=0.8,
    ),
  )

  cmds
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

///|
fn ascii(s : String) -> Array[Int] {
  let result : Array[Int] = []
  for i = 0; i < s.length(); i = i + 1 {
    let c = s[i].to_int()
    // glyph_pattern expects 0-9 for digits, ASCII for letters/symbols
    if c >= 48 && c <= 57 {
      result.push(c - 48)
    } else {
      result.push(c)
    }
  }
  result
}
