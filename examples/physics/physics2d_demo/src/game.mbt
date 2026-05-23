// ============================================================
// Physics 2D Demo
// ============================================================
// Circles and boxes falling onto a ground with walls.
// Click to spawn new objects at cursor position.
// Uses physics2d for simulation and renderer2d for rendering.
// Y-down screen coordinates: physics Y mapped to screen Y inverted.

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// Physics space: centered at screen center, 1 physics unit = 40 pixels

///|
let px_per_unit : Double = 40.0

///|
let circle_segments : Int = 16

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  world : @physics2d.PhysicsWorld2D
  input : @inpututil.InputHelper
  mut frame : Int
  mut next_id : Int
}

// Palette for dynamic body colors (cycled)

///|
let dynamic_colors : Array[Int] = [
  0xE04040, 0x40A0E0, 0xE0C040, 0x40E070, 0xC060D0, 0xE08040, 0x60D0D0, 0xD06080,
  0x80D060, 0xA0A0E0,
]

///|
fn make_static_body(
  id : Int,
  x : Double,
  y : Double,
  hx : Double,
  hy : Double,
) -> @physics2d.RigidBody2D {
  {
    id,
    body_type: @physics2d.Static,
    position: @vector.Vec2::new(x, y),
    velocity: @vector.Vec2::zero(),
    force: @vector.Vec2::zero(),
    angle: 0.0,
    angular_velocity: 0.0,
    torque: 0.0,
    mass: 0.0,
    inv_mass: 0.0,
    restitution: 0.3,
    friction: 0.8,
    inv_inertia: 0.0,
    angular_damping: 0.0,
    linear_damping: 0.0,
    collider: @physics2d.AABBShape2D(
      @vector.Vec2::new(hx, hy),
      @vector.Vec2::zero(),
    ),
    is_sleeping: false,
    sleep_timer: 0.0,
    is_bullet: false,
  }
}

///|
fn make_dynamic_circle(
  id : Int,
  x : Double,
  y : Double,
  radius : Double,
) -> @physics2d.RigidBody2D {
  @physics2d.RigidBody2D::new_dynamic(
    id,
    @vector.Vec2::new(x, y),
    radius * radius * 3.14,
    @physics2d.CircleShape(@vector.Vec2::zero(), radius),
  )
  .with_restitution(0.3)
  .with_friction(0.5)
  .with_damping(0.05)
}

///|
fn make_dynamic_box(
  id : Int,
  x : Double,
  y : Double,
  hx : Double,
  hy : Double,
) -> @physics2d.RigidBody2D {
  let angular_vel = id.to_double() * 1.7 % 2.0 - 1.0
  {
    ..@physics2d.RigidBody2D::new_dynamic(
      id,
      @vector.Vec2::new(x, y),
      hx * hy * 4.0,
      @physics2d.OBBShape2D(@vector.Vec2::new(hx, hy), @vector.Vec2::zero()),
    )
    .with_restitution(0.3)
    .with_friction(0.5)
    .with_damping(0.05),
    angular_velocity: angular_vel,
  }
}

///|
fn DemoState::new() -> DemoState {
  let world = @physics2d.PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  // Static boundaries
  world.add_body(make_static_body(0, 0.0, -6.5, 10.0, 2.0)) // ground
  world.add_body(make_static_body(1, -9.0, 0.0, 2.0, 10.0)) // left wall
  world.add_body(make_static_body(2, 9.0, 0.0, 2.0, 10.0)) // right wall
  // Dynamic bodies: varied sizes
  // (x, y, is_circle, size)
  let spawn_data : Array[(Double, Double, Bool, Double)] = [
    (-2.0, 1.0, true, 0.5),
    (1.0, 1.5, false, 0.4),
    (0.0, 2.5, true, 0.35),
    (-1.5, 3.0, false, 0.55),
    (2.0, 2.0, true, 0.6),
    (-0.5, 3.5, false, 0.3),
    (1.5, 4.0, true, 0.45),
    (-2.5, 4.5, false, 0.5),
    (0.5, 5.0, true, 0.3),
    (2.5, 5.5, false, 0.35),
    (0.0, 6.0, true, 0.7),
    (-1.0, 6.5, false, 0.45),
  ]
  let mut next_id = 3
  for i = 0; i < spawn_data.length(); i = i + 1 {
    let (x, y, is_circle, size) = spawn_data[i]
    if is_circle {
      world.add_body(make_dynamic_circle(next_id, x, y, size))
    } else {
      world.add_body(make_dynamic_box(next_id, x, y, size, size))
    }
    next_id = next_id + 1
  }
  { world, input: @inpututil.new_input_helper(), frame: 0, next_id }
}

// ============================================================
// Update
// ============================================================

///|
fn screen_to_physics_x(sx : Double) -> Double {
  (sx - screen_w.to_double() / 2.0) / px_per_unit
}

///|
fn screen_to_physics_y(sy : Double) -> Double {
  (screen_h.to_double() / 2.0 - sy) / px_per_unit
}

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  // Click to spawn
  if @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) {
    let px = screen_to_physics_x(snapshot.cursor_x)
    let py = screen_to_physics_y(snapshot.cursor_y)
    let is_circle = self.next_id % 2 == 0
    if is_circle {
      self.world.add_body(make_dynamic_circle(self.next_id, px, py, 0.4))
    } else {
      self.world.add_body(make_dynamic_box(self.next_id, px, py, 0.4, 0.4))
    }
    self.next_id = self.next_id + 1
  }
  let sub_steps = 8
  let dt = 1.0 / 60.0 / sub_steps.to_double()
  for _s = 0; _s < sub_steps; _s = _s + 1 {
    self.world.step(dt)
  }
}

// ============================================================
// Coordinate conversion: physics (Y-up) -> screen (Y-down)
// ============================================================

///|
fn physics_to_screen_x(px : Double) -> Double {
  screen_w.to_double() / 2.0 + px * px_per_unit
}

///|
fn physics_to_screen_y(py : Double) -> Double {
  screen_h.to_double() / 2.0 - py * px_per_unit
}

// ============================================================
// Draw
// ============================================================

///|
fn hex_to_color(hex : Int) -> @gfx.Color {
  @renderer2d.color_from_hex(hex)
}

///|
fn get_body_color(id : Int) -> @gfx.Color {
  let hex = if id < 3 {
    0x666666 // static bodies: gray
  } else {
    dynamic_colors[(id - 3) % dynamic_colors.length()]
  }
  hex_to_color(hex)
}

///|
fn draw_filled_circle(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  cx : Double,
  cy : Double,
  radius : Double,
  color : @gfx.Color,
  sw : Double,
  sh : Double,
) -> Unit {
  let n = circle_segments
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  // Center vertex in NDC
  let ndc_cx = cx / sw * 2.0 - 1.0
  let ndc_cy = 1.0 - cy / sh * 2.0
  vertices.push(ndc_cx)
  vertices.push(ndc_cy)
  vertices.push(0.5)
  vertices.push(0.5)
  // Perimeter vertices
  for i = 0; i <= n; i = i + 1 {
    let angle = i.to_double() / n.to_double() * 2.0 * @math.PI
    let px = cx + radius * @math.cos(angle)
    let py = cy + radius * @math.sin(angle)
    let ndc_x = px / sw * 2.0 - 1.0
    let ndc_y = 1.0 - py / sh * 2.0
    vertices.push(ndc_x)
    vertices.push(ndc_y)
    vertices.push(0.5)
    vertices.push(0.5)
  }
  // Triangle fan indices
  for i = 1; i <= n; i = i + 1 {
    indices.push(0)
    indices.push(i)
    indices.push(i + 1)
  }
  @renderer2d.append_primitive_batch(cmds, frame, vertices, indices, color)
}

///|
fn draw_rotated_box(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  cx : Double,
  cy : Double,
  hw : Double,
  hh : Double,
  angle : Double,
  color : @gfx.Color,
  sw : Double,
  sh : Double,
) -> Unit {
  // 4 local corners, rotated by angle (note: screen Y is inverted)
  let corners : Array[(Double, Double)] = [
    (-hw, -hh),
    (hw, -hh),
    (hw, hh),
    (-hw, hh),
  ]
  let cos_a = @math.cos(-angle) // negate for screen-space Y-down
  let sin_a = @math.sin(-angle)
  let vertices : Array[Double] = []
  for i = 0; i < 4; i = i + 1 {
    let (lx, ly) = corners[i]
    let rx = lx * cos_a - ly * sin_a
    let ry = lx * sin_a + ly * cos_a
    let px = cx + rx
    let py = cy + ry
    let ndc_x = px / sw * 2.0 - 1.0
    let ndc_y = 1.0 - py / sh * 2.0
    vertices.push(ndc_x)
    vertices.push(ndc_y)
    vertices.push(0.5)
    vertices.push(0.5)
  }
  let indices : Array[Int] = [0, 1, 2, 0, 2, 3]
  @renderer2d.append_primitive_batch(cmds, frame, vertices, indices, color)
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let frame = @renderer2d.RenderFrame2D::new(
    dst=ctx.dst,
    shader=ctx.shader,
    screen_w~,
    screen_h~,
  )
  // Background
  @renderer2d.append_rect_fill(
    cmds,
    frame,
    @renderer2d.RectFill2D::new(
      x=0.0,
      y=0.0,
      w=sw,
      h=sh,
      color=@renderer2d.color_from_hex(0x1A1A2E),
    ),
  )
  // Draw bodies
  for i = 0; i < self.world.bodies.length(); i = i + 1 {
    let body = self.world.bodies[i]
    let color = get_body_color(body.id)
    match body.collider {
      @physics2d.CircleShape(offset, radius) => {
        let cx = physics_to_screen_x(body.position.x + offset.x)
        let cy = physics_to_screen_y(body.position.y + offset.y)
        let screen_r = radius * px_per_unit
        draw_filled_circle(cmds, frame, cx, cy, screen_r, color, sw, sh)
      }
      @physics2d.AABBShape2D(half_extents, offset) => {
        let cx = body.position.x + offset.x
        let cy = body.position.y + offset.y
        let screen_x = physics_to_screen_x(cx - half_extents.x)
        let screen_y = physics_to_screen_y(cy + half_extents.y)
        let screen_w2 = half_extents.x * 2.0 * px_per_unit
        let screen_h2 = half_extents.y * 2.0 * px_per_unit
        @renderer2d.append_rect_fill(
          cmds,
          frame,
          @renderer2d.RectFill2D::new(
            x=screen_x,
            y=screen_y,
            w=screen_w2,
            h=screen_h2,
            color~,
          ),
        )
      }
      @physics2d.OBBShape2D(half_extents, offset) => {
        let phys_cx = body.position.x + offset.x
        let phys_cy = body.position.y + offset.y
        let scx = physics_to_screen_x(phys_cx)
        let scy = physics_to_screen_y(phys_cy)
        let shw = half_extents.x * px_per_unit
        let shh = half_extents.y * px_per_unit
        draw_rotated_box(
          cmds,
          frame,
          scx,
          scy,
          shw,
          shh,
          body.angle,
          color,
          sw,
          sh,
        )
      }
    }
  }
  cmds
}
