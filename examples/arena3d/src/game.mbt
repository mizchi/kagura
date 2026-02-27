// ============================================================
// 3D Arena Collector
// ============================================================

// Game modes

///|
let mode_title : Int = 0

///|
let mode_playing : Int = 1

///|
let mode_gameover : Int = 2

// Arena dimensions

///|
let arena_half : Double = 9.0

///|
let wall_height : Double = 1.0

///|
let wall_thickness : Double = 0.5

// Gameplay

///|
let player_speed : Double = 0.08

///|
let enemy_speed : Double = 0.03

///|
let item_collect_dist : Double = 0.8

///|
let enemy_hit_dist : Double = 1.0

///|
let item_count : Int = 5

///|
let enemy_count : Int = 3

// Rendering

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// ============================================================
// Colored Lit Shader WGSL (for future WebGPU backend)
// ============================================================

///|
fn shader3d_colored_lit_wgsl() -> String {
  "struct Uniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "  model: mat4x4<f32>,\n" +
  "  normal_col0: vec4<f32>,\n" +
  "  normal_col1: vec4<f32>,\n" +
  "  normal_col2: vec4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  material_color: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  "  let normal_mat = mat3x3<f32>(\n" +
  "    uniforms.normal_col0.xyz,\n" +
  "    uniforms.normal_col1.xyz,\n" +
  "    uniforms.normal_col2.xyz,\n" +
  "  );\n" +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let normal = normalize(in.world_normal);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let diffuse = uniforms.light_color.xyz * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz;\n" +
  "  let lit_color = uniforms.material_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, uniforms.material_color.a);\n" +
  "}\n"
}

// ============================================================
// Entity types
// ============================================================

///|
struct PlayerState {
  mut position : @math3d.Vec3
}

///|
struct ItemState {
  mut position : @math3d.Vec3
  mut active : Bool
}

///|
struct EnemyState {
  mut position : @math3d.Vec3
  waypoints : Array[@math3d.Vec3]
  mut waypoint_idx : Int
}

///|
struct Meshes {
  player : @mesh3d.Mesh3D
  item : @mesh3d.Mesh3D
  enemy : @mesh3d.Mesh3D
  ground : @mesh3d.Mesh3D
  wall : @mesh3d.Mesh3D
}

// ============================================================
// GameState
// ============================================================

///|
struct GameState {
  mut mode : Int
  mut score : Int
  mut frame_count : Int
  player : PlayerState
  items : Array[ItemState]
  enemies : Array[EnemyState]
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  input : @inpututil.InputHelper
  meshes : Meshes
}

///|
fn GameState::new() -> GameState {
  let items : Array[ItemState] = []
  for i in 0..<item_count {
    items.push(make_item(i))
  }
  let enemies : Array[EnemyState] = []
  let wp0 : Array[@math3d.Vec3] = [
    @math3d.Vec3::new(-6.0, 0.5, -6.0),
    @math3d.Vec3::new(6.0, 0.5, -6.0),
    @math3d.Vec3::new(6.0, 0.5, 6.0),
    @math3d.Vec3::new(-6.0, 0.5, 6.0),
  ]
  let wp1 : Array[@math3d.Vec3] = [
    @math3d.Vec3::new(0.0, 0.5, -7.0),
    @math3d.Vec3::new(7.0, 0.5, 0.0),
    @math3d.Vec3::new(0.0, 0.5, 7.0),
    @math3d.Vec3::new(-7.0, 0.5, 0.0),
  ]
  let wp2 : Array[@math3d.Vec3] = [
    @math3d.Vec3::new(-4.0, 0.5, 0.0),
    @math3d.Vec3::new(4.0, 0.5, 0.0),
  ]
  enemies.push({ position: wp0[0], waypoints: wp0, waypoint_idx: 0 })
  enemies.push({ position: wp1[0], waypoints: wp1, waypoint_idx: 0 })
  enemies.push({ position: wp2[0], waypoints: wp2, waypoint_idx: 0 })
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    12.0,
    0.0,
    0.6,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
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
    mode: mode_playing,
    score: 0,
    frame_count: 0,
    player: { position: @math3d.Vec3::new(0.0, 0.5, 0.0) },
    items,
    enemies,
    camera,
    lighting,
    input: @inpututil.new_input_helper(),
    meshes: {
      player: @mesh3d.Mesh3D::sphere(0.5, 6, 4),
      item: @mesh3d.Mesh3D::sphere(0.3, 4, 3),
      enemy: @mesh3d.Mesh3D::cube(0.8),
      ground: @mesh3d.Mesh3D::plane(20.0, 20.0),
      wall: @mesh3d.Mesh3D::cube(1.0),
    },
  }
}

///|
fn make_item(index : Int) -> ItemState {
  let positions : Array[@math3d.Vec3] = [
    @math3d.Vec3::new(5.0, 0.3, 5.0),
    @math3d.Vec3::new(-5.0, 0.3, 3.0),
    @math3d.Vec3::new(3.0, 0.3, -6.0),
    @math3d.Vec3::new(-7.0, 0.3, -4.0),
    @math3d.Vec3::new(0.0, 0.3, 7.0),
  ]
  let pos = positions[index % positions.length()]
  { position: pos, active: true }
}

///|
fn respawn_item(item : ItemState, frame : Int) -> Unit {
  let angle = (frame % 360).to_double() * @math.PI / 180.0
  let r = 3.0 + (frame % 5).to_double()
  item.position = @math3d.Vec3::new(
    r * @math.cos(angle),
    0.3,
    r * @math.sin(angle),
  )
  item.position = @math3d.Vec3::new(
    clamp_arena(item.position.x),
    0.3,
    clamp_arena(item.position.z),
  )
  item.active = true
}

///|
fn clamp_arena(v : Double) -> Double {
  let limit = arena_half - 1.0
  if v < -limit {
    -limit
  } else if v > limit {
    limit
  } else {
    v
  }
}

///|
fn distance_xz(a : @math3d.Vec3, b : @math3d.Vec3) -> Double {
  let dx = a.x - b.x
  let dz = a.z - b.z
  (dx * dx + dz * dz).sqrt()
}

// ============================================================
// Update
// ============================================================

///|
fn GameState::update(self : GameState, input : @core.InputSnapshot) -> Unit {
  self.frame_count = self.frame_count + 1
  @inpututil.update_input_helper(self.input, input)
  match self.mode {
    m if m == mode_title => self.update_title()
    m if m == mode_playing => self.update_playing()
    m if m == mode_gameover => self.update_gameover()
    _ => ()
  }
}

///|
fn GameState::update_title(self : GameState) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.reset()
    self.mode = mode_playing
  }
}

///|
fn GameState::update_gameover(self : GameState) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.reset()
    self.mode = mode_title
  }
}

///|
fn GameState::reset(self : GameState) -> Unit {
  self.score = 0
  self.frame_count = 0
  self.player.position = @math3d.Vec3::new(0.0, 0.5, 0.0)
  for i in 0..<self.items.length() {
    let item = self.items[i]
    let fresh = make_item(i)
    item.position = fresh.position
    item.active = true
  }
  for i in 0..<self.enemies.length() {
    let e = self.enemies[i]
    e.waypoint_idx = 0
    e.position = e.waypoints[0]
  }
}

///|
fn GameState::update_playing(self : GameState) -> Unit {
  let mut dx = 0.0
  let mut dz = 0.0
  if @inpututil.is_move_up(self.input.key_state) {
    dz = dz - player_speed
  }
  if @inpututil.is_move_down(self.input.key_state) {
    dz = dz + player_speed
  }
  if @inpututil.is_move_left(self.input.key_state) {
    dx = dx - player_speed
  }
  if @inpututil.is_move_right(self.input.key_state) {
    dx = dx + player_speed
  }
  self.player.position = @math3d.Vec3::new(
    clamp_arena(self.player.position.x + dx),
    self.player.position.y,
    clamp_arena(self.player.position.z + dz),
  )
  for i in 0..<self.items.length() {
    let item = self.items[i]
    if item.active &&
      distance_xz(self.player.position, item.position) < item_collect_dist {
      item.active = false
      self.score = self.score + 10
      respawn_item(item, self.frame_count + i * 97)
    }
  }
  for i in 0..<self.enemies.length() {
    let e = self.enemies[i]
    let target = e.waypoints[e.waypoint_idx]
    let ex_dx = target.x - e.position.x
    let ex_dz = target.z - e.position.z
    let dist = (ex_dx * ex_dx + ex_dz * ex_dz).sqrt()
    if dist < 0.2 {
      e.waypoint_idx = (e.waypoint_idx + 1) % e.waypoints.length()
    } else {
      let inv = enemy_speed / dist
      e.position = @math3d.Vec3::new(
        e.position.x + ex_dx * inv,
        e.position.y,
        e.position.z + ex_dz * inv,
      )
    }
    if distance_xz(self.player.position, e.position) < enemy_hit_dist {
      self.mode = mode_gameover
    }
  }
  self.camera = self.camera.with_target(self.player.position)
}

// ============================================================
// Draw commands (CPU-side 3D→2D projection)
// ============================================================

// Colors (RGBA, 0-1 range)

///|
let color_player : @math3d.Vec4 = @math3d.Vec4::new(0.2, 0.8, 0.3, 1.0)

///|
let color_item : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.9, 0.2, 1.0)

///|
let color_enemy : @math3d.Vec4 = @math3d.Vec4::new(0.9, 0.2, 0.2, 1.0)

///|
let color_ground : @math3d.Vec4 = @math3d.Vec4::new(0.4, 0.5, 0.4, 1.0)

///|
let color_wall : @math3d.Vec4 = @math3d.Vec4::new(0.3, 0.3, 0.35, 1.0)

///|
fn GameState::build_draw_commands(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
) -> Array[@gfx.DrawTrianglesCommand] {
  let objects : Array[@scene3d.Object3D] = []
  // Ground
  objects.push(
    @scene3d.object3d(mesh=self.meshes.ground, color=color_ground),
  )
  // Walls
  build_wall_objects(self.meshes.wall, objects)
  // Items
  for i in 0..<self.items.length() {
    let item = self.items[i]
    if item.active {
      objects.push(
        @scene3d.object3d(
          mesh=self.meshes.item,
          position=item.position,
          color=color_item,
        ),
      )
    }
  }
  // Enemies
  for i in 0..<self.enemies.length() {
    let e = self.enemies[i]
    objects.push(
      @scene3d.object3d(
        mesh=self.meshes.enemy,
        position=e.position,
        color=color_enemy,
      ),
    )
  }
  // Player
  objects.push(
    @scene3d.object3d(
      mesh=self.meshes.player,
      position=self.player.position,
      color=color_player,
    ),
  )
  let scene = @scene3d.scene3d(
    objects=objects,
    camera=self.camera.to_camera3d(),
    lighting=self.lighting,
  )
  @scene3d.render_scene3d(scene, dst, shader, screen_w, screen_h)
}

///|
fn build_wall_objects(
  wall_mesh : @mesh3d.Mesh3D,
  objects : Array[@scene3d.Object3D],
) -> Unit {
  let h = arena_half
  let wh = wall_height / 2.0
  let wt = wall_thickness
  // Front wall (-Z)
  objects.push(
    @scene3d.object3d(
      mesh=wall_mesh,
      position=@math3d.Vec3::new(0.0, wh, -(h + wt / 2.0)),
      scale=@math3d.Vec3::new(h * 2.0 + wt * 2.0, wall_height, wt),
      color=color_wall,
    ),
  )
  // Back wall (+Z)
  objects.push(
    @scene3d.object3d(
      mesh=wall_mesh,
      position=@math3d.Vec3::new(0.0, wh, h + wt / 2.0),
      scale=@math3d.Vec3::new(h * 2.0 + wt * 2.0, wall_height, wt),
      color=color_wall,
    ),
  )
  // Left wall (-X)
  objects.push(
    @scene3d.object3d(
      mesh=wall_mesh,
      position=@math3d.Vec3::new(-(h + wt / 2.0), wh, 0.0),
      scale=@math3d.Vec3::new(wt, wall_height, h * 2.0),
      color=color_wall,
    ),
  )
  // Right wall (+X)
  objects.push(
    @scene3d.object3d(
      mesh=wall_mesh,
      position=@math3d.Vec3::new(h + wt / 2.0, wh, 0.0),
      scale=@math3d.Vec3::new(wt, wall_height, h * 2.0),
      color=color_wall,
    ),
  )
}
