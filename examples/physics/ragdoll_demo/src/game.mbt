// ============================================================
// Ragdoll Demo
// ============================================================
// A ragdoll figure made of 10 body parts connected by 9 revolute joints.
// Click and drag to grab and move body parts with a spring force.

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
let px_per_unit : Double = 40.0

///|
let circle_segments : Int = 16

///|
let spring_strength : Double = 200.0

///|
let grab_distance : Double = 2.0

// ============================================================
// Body part IDs
// ============================================================

///|
let id_ground : Int = 0

///|
let id_head : Int = 1

///|
let id_torso : Int = 2

///|
let id_l_arm : Int = 3

///|
let id_r_arm : Int = 4

///|
let id_l_fore : Int = 5

///|
let id_r_fore : Int = 6

///|
let id_l_thigh : Int = 7

///|
let id_r_thigh : Int = 8

///|
let id_l_shin : Int = 9

///|
let id_r_shin : Int = 10

// ============================================================
// Colors
// ============================================================

///|
let color_skin : Int = 0xF0C8A0

///|
let color_torso : Int = 0x4080C0

///|
let color_arm : Int = 0x5090D0

///|
let color_forearm : Int = 0x60A0E0

///|
let color_thigh : Int = 0x406080

///|
let color_shin : Int = 0x507090

///|
let color_highlight : Int = 0xFFFF00

///|
let color_bg : Int = 0x1A1A2E

///|
let color_ground_hex : Int = 0x444444

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  world : @physics2d.PhysicsWorld2D
  input : @inpututil.InputHelper
  mut frame : Int
  mut grabbed_id : Int // -1 = none
  mut mouse_phys_x : Double
  mut mouse_phys_y : Double
}

// ============================================================
// Coordinate conversion
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
fn physics_to_screen_x(px : Double) -> Double {
  screen_w.to_double() / 2.0 + px * px_per_unit
}

///|
fn physics_to_screen_y(py : Double) -> Double {
  screen_h.to_double() / 2.0 - py * px_per_unit
}

// ============================================================
// Body creation helpers
// ============================================================

///|
fn make_ragdoll_circle(
  id : Int,
  x : Double,
  y : Double,
  radius : Double,
  mass : Double,
) -> @physics2d.RigidBody2D {
  @physics2d.RigidBody2D::new_dynamic(
    id,
    @vector.Vec2::new(x, y),
    mass,
    @physics2d.CircleShape(@vector.Vec2::zero(), radius),
  )
  .with_restitution(0.2)
  .with_friction(0.5)
  .with_damping(0.1)
}

///|
fn make_ragdoll_box(
  id : Int,
  x : Double,
  y : Double,
  hx : Double,
  hy : Double,
  mass : Double,
) -> @physics2d.RigidBody2D {
  @physics2d.RigidBody2D::new_dynamic(
    id,
    @vector.Vec2::new(x, y),
    mass,
    @physics2d.OBBShape2D(@vector.Vec2::new(hx, hy), @vector.Vec2::zero()),
  )
  .with_restitution(0.2)
  .with_friction(0.5)
  .with_damping(0.1)
}

///|
fn make_revolute(
  a_id : Int,
  b_id : Int,
  anchor_a : @vector.Vec2,
  anchor_b : @vector.Vec2,
) -> @physics2d.RevoluteJoint2D {
  {
    body_a_id: a_id,
    body_b_id: b_id,
    local_anchor_a: anchor_a,
    local_anchor_b: anchor_b,
    hertz: 8.0,
    damping_ratio: 0.5,
  }
}

// ============================================================
// Build ragdoll
// ============================================================

///|
fn build_ragdoll(world : @physics2d.PhysicsWorld2D) -> Unit {
  // Spawn position: centered, torso at y=3
  let cx = 0.0
  let torso_y = 3.0
  // Head (circle r=0.3)
  let head_y = torso_y + 0.7 + 0.3 // torso half_h + head radius
  world.add_body(make_ragdoll_circle(id_head, cx, head_y, 0.3, 2.0))
  // Torso (box 0.4x0.7 half extents)
  world.add_body(make_ragdoll_box(id_torso, cx, torso_y, 0.4, 0.7, 5.0))
  // Left upper arm
  let l_arm_x = cx - 0.4 - 0.15
  let l_arm_y = torso_y + 0.5 - 0.4
  world.add_body(make_ragdoll_box(id_l_arm, l_arm_x, l_arm_y, 0.15, 0.4, 1.5))
  // Right upper arm
  let r_arm_x = cx + 0.4 + 0.15
  let r_arm_y = torso_y + 0.5 - 0.4
  world.add_body(make_ragdoll_box(id_r_arm, r_arm_x, r_arm_y, 0.15, 0.4, 1.5))
  // Left forearm
  let l_fore_x = l_arm_x
  let l_fore_y = l_arm_y - 0.4 - 0.35
  world.add_body(
    make_ragdoll_box(id_l_fore, l_fore_x, l_fore_y, 0.12, 0.35, 1.0),
  )
  // Right forearm
  let r_fore_x = r_arm_x
  let r_fore_y = r_arm_y - 0.4 - 0.35
  world.add_body(
    make_ragdoll_box(id_r_fore, r_fore_x, r_fore_y, 0.12, 0.35, 1.0),
  )
  // Left thigh
  let l_thigh_x = cx - 0.2
  let l_thigh_y = torso_y - 0.7 - 0.45
  world.add_body(
    make_ragdoll_box(id_l_thigh, l_thigh_x, l_thigh_y, 0.18, 0.45, 2.0),
  )
  // Right thigh
  let r_thigh_x = cx + 0.2
  let r_thigh_y = torso_y - 0.7 - 0.45
  world.add_body(
    make_ragdoll_box(id_r_thigh, r_thigh_x, r_thigh_y, 0.18, 0.45, 2.0),
  )
  // Left shin
  let l_shin_x = l_thigh_x
  let l_shin_y = l_thigh_y - 0.45 - 0.4
  world.add_body(
    make_ragdoll_box(id_l_shin, l_shin_x, l_shin_y, 0.15, 0.4, 1.5),
  )
  // Right shin
  let r_shin_x = r_thigh_x
  let r_shin_y = r_thigh_y - 0.45 - 0.4
  world.add_body(
    make_ragdoll_box(id_r_shin, r_shin_x, r_shin_y, 0.15, 0.4, 1.5),
  )
  // === Revolute joints ===
  // Neck: head(0, -0.3) <-> torso(0, 0.7)
  world.add_revolute_joint(
    make_revolute(
      id_head,
      id_torso,
      @vector.Vec2::new(0.0, -0.3),
      @vector.Vec2::new(0.0, 0.7),
    ),
  )
  // L shoulder: torso(-0.4, 0.5) <-> L arm(0, 0.4)
  world.add_revolute_joint(
    make_revolute(
      id_torso,
      id_l_arm,
      @vector.Vec2::new(-0.4, 0.5),
      @vector.Vec2::new(0.0, 0.4),
    ),
  )
  // R shoulder: torso(0.4, 0.5) <-> R arm(0, 0.4)
  world.add_revolute_joint(
    make_revolute(
      id_torso,
      id_r_arm,
      @vector.Vec2::new(0.4, 0.5),
      @vector.Vec2::new(0.0, 0.4),
    ),
  )
  // L elbow: L arm(0, -0.4) <-> L fore(0, 0.35)
  world.add_revolute_joint(
    make_revolute(
      id_l_arm,
      id_l_fore,
      @vector.Vec2::new(0.0, -0.4),
      @vector.Vec2::new(0.0, 0.35),
    ),
  )
  // R elbow: R arm(0, -0.4) <-> R fore(0, 0.35)
  world.add_revolute_joint(
    make_revolute(
      id_r_arm,
      id_r_fore,
      @vector.Vec2::new(0.0, -0.4),
      @vector.Vec2::new(0.0, 0.35),
    ),
  )
  // L hip: torso(-0.2, -0.7) <-> L thigh(0, 0.45)
  world.add_revolute_joint(
    make_revolute(
      id_torso,
      id_l_thigh,
      @vector.Vec2::new(-0.2, -0.7),
      @vector.Vec2::new(0.0, 0.45),
    ),
  )
  // R hip: torso(0.2, -0.7) <-> R thigh(0, 0.45)
  world.add_revolute_joint(
    make_revolute(
      id_torso,
      id_r_thigh,
      @vector.Vec2::new(0.2, -0.7),
      @vector.Vec2::new(0.0, 0.45),
    ),
  )
  // L knee: L thigh(0, -0.45) <-> L shin(0, 0.4)
  world.add_revolute_joint(
    make_revolute(
      id_l_thigh,
      id_l_shin,
      @vector.Vec2::new(0.0, -0.45),
      @vector.Vec2::new(0.0, 0.4),
    ),
  )
  // R knee: R thigh(0, -0.45) <-> R shin(0, 0.4)
  world.add_revolute_joint(
    make_revolute(
      id_r_thigh,
      id_r_shin,
      @vector.Vec2::new(0.0, -0.45),
      @vector.Vec2::new(0.0, 0.4),
    ),
  )
}

// ============================================================
// DemoState::new
// ============================================================

///|
fn DemoState::new() -> DemoState {
  let world = @physics2d.PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 4.0)
  // Ground
  world.add_body(
    @physics2d.RigidBody2D::new_static(
      id_ground,
      @vector.Vec2::new(0.0, -5.5),
      @physics2d.AABBShape2D(@vector.Vec2::new(10.0, 1.0), @vector.Vec2::zero()),
    ),
  )
  build_ragdoll(world)
  {
    world,
    input: @inpututil.new_input_helper(),
    frame: 0,
    grabbed_id: -1,
    mouse_phys_x: 0.0,
    mouse_phys_y: 0.0,
  }
}

// ============================================================
// Update
// ============================================================

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  let mx = screen_to_physics_x(snapshot.cursor_x)
  let my = screen_to_physics_y(snapshot.cursor_y)
  self.mouse_phys_x = mx
  self.mouse_phys_y = my
  // Grab on press
  if @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) {
    self.grabbed_id = find_closest_dynamic(self.world, mx, my)
  }
  // Release
  if @inpututil.is_mouse_button_just_released(self.input.mouse_state, 0) {
    self.grabbed_id = -1
  }
  // Apply spring force while dragging
  if self.grabbed_id >= 0 {
    match self.world.get_body(self.grabbed_id) {
      Some(body) => {
        let dx = mx - body.position.x
        let dy = my - body.position.y
        let fx = dx * spring_strength
        let fy = dy * spring_strength
        self.world.apply_force(self.grabbed_id, @vector.Vec2::new(fx, fy))
      }
      None => self.grabbed_id = -1
    }
  }
  // Physics step
  let sub_steps = 8
  let dt = 1.0 / 60.0 / sub_steps.to_double()
  for _s = 0; _s < sub_steps; _s = _s + 1 {
    self.world.step(dt)
  }
}

///|
fn find_closest_dynamic(
  world : @physics2d.PhysicsWorld2D,
  mx : Double,
  my : Double,
) -> Int {
  let mut best_id = -1
  let mut best_dist = grab_distance
  for i = 0; i < world.bodies.length(); i = i + 1 {
    let body = world.bodies[i]
    if !body.is_dynamic() {
      continue i + 1
    }
    let dx = body.position.x - mx
    let dy = body.position.y - my
    let dist = (dx * dx + dy * dy).sqrt()
    if dist < best_dist {
      best_dist = dist
      best_id = body.id
    }
  }
  best_id
}

// ============================================================
// Draw helpers
// ============================================================

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
  let ndc_cx = cx / sw * 2.0 - 1.0
  let ndc_cy = 1.0 - cy / sh * 2.0
  vertices.push(ndc_cx)
  vertices.push(ndc_cy)
  vertices.push(0.5)
  vertices.push(0.5)
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
  let corners : Array[(Double, Double)] = [
    (-hw, -hh),
    (hw, -hh),
    (hw, hh),
    (-hw, hh),
  ]
  let cos_a = @math.cos(-angle)
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

// ============================================================
// Get body part color
// ============================================================

///|
fn get_part_color(id : Int, grabbed_id : Int) -> @gfx.Color {
  if id == grabbed_id {
    return @renderer2d.color_from_hex(color_highlight)
  }
  let hex = match id {
    1 => color_skin // head
    2 => color_torso
    3 | 4 => color_arm
    5 | 6 => color_forearm
    7 | 8 => color_thigh
    9 | 10 => color_shin
    _ => color_ground_hex
  }
  @renderer2d.color_from_hex(hex)
}

// ============================================================
// Rotate local anchor to world
// ============================================================

///|
fn world_anchor(
  body : @physics2d.RigidBody2D,
  anchor : @vector.Vec2,
) -> @vector.Vec2 {
  let c = @math.cos(body.angle)
  let s = @math.sin(body.angle)
  let rx = anchor.x * c - anchor.y * s
  let ry = anchor.x * s + anchor.y * c
  @vector.Vec2::new(body.position.x + rx, body.position.y + ry)
}

// ============================================================
// Draw
// ============================================================

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
      color=@renderer2d.color_from_hex(color_bg),
    ),
  )
  // Draw bodies
  for i = 0; i < self.world.bodies.length(); i = i + 1 {
    let body = self.world.bodies[i]
    let color = get_part_color(body.id, self.grabbed_id)
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
  // Draw joint lines (white)
  let joint_color = @renderer2d.color_from_hex_alpha(0xFFFFFF, 0.6)
  for j = 0; j < self.world.joints_revolute.length(); j = j + 1 {
    let joint = self.world.joints_revolute[j]
    let body_a = self.world.get_body(joint.body_a_id)
    let body_b = self.world.get_body(joint.body_b_id)
    match (body_a, body_b) {
      (Some(a), Some(b)) => {
        let wa = world_anchor(a, joint.local_anchor_a)
        let wb = world_anchor(b, joint.local_anchor_b)
        let sx0 = physics_to_screen_x(wa.x)
        let sy0 = physics_to_screen_y(wa.y)
        let sx1 = physics_to_screen_x(wb.x)
        let sy1 = physics_to_screen_y(wb.y)
        @renderer2d.append_line(
          cmds,
          frame,
          @renderer2d.Line2D::new(
            x0=sx0,
            y0=sy0,
            x1=sx1,
            y1=sy1,
            width=2.0,
            color=joint_color,
          ),
        )
      }
      _ => ()
    }
  }
  // Draw grab line (red, from mouse to grabbed body)
  if self.grabbed_id >= 0 {
    match self.world.get_body(self.grabbed_id) {
      Some(body) => {
        let mx_screen = physics_to_screen_x(self.mouse_phys_x)
        let my_screen = physics_to_screen_y(self.mouse_phys_y)
        let bx_screen = physics_to_screen_x(body.position.x)
        let by_screen = physics_to_screen_y(body.position.y)
        @renderer2d.append_line(
          cmds,
          frame,
          @renderer2d.Line2D::new(
            x0=mx_screen,
            y0=my_screen,
            x1=bx_screen,
            y1=by_screen,
            width=2.0,
            color=@renderer2d.color_from_hex(0xFF4040),
          ),
        )
      }
      None => ()
    }
  }
  cmds
}
