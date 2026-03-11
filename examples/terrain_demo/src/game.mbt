// ============================================================
// Terrain Demo — BSP dungeon + Instanced enemies + Scene transitions
// ============================================================

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// ============================================================
// Menu Scene
// ============================================================

///|
struct MenuScene {
  mut frame : Int
}

///|
fn MenuScene::new() -> MenuScene {
  { frame: 0 }
}

///|
impl @scene_manager.Scene for MenuScene with update(self, _input) {
  self.frame = self.frame + 1
}

///|
impl @scene_manager.Scene for MenuScene with draw(self, ctx) {
  let _ = self
  // Draw a simple colored background quad as menu placeholder
  let vdata : Array[Double] = []
  let indices : Array[Int] = []
  // Full-screen quad using 3D lit shader (flat plane)
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(0.0, -1.0, 0.0),
      @math3d.Vec3::new(0.3, 0.3, 0.8),
      1.0,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(0.2, 0.2, 0.5), 0.5),
  )
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 2.0, 5.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    100.0,
  )
  let shader3d = @gfx.new_shader_handle(
    10,
    @draw3d.shader3d_lit_untextured_wgsl(),
  )
  let scene = @scene3d.scene3d(
    objects=[
      @scene3d.object3d(mesh~, color=@math3d.Vec4::new(0.3, 0.3, 0.8, 1.0)),
    ],
    camera~,
    lighting~,
  )
  let _ = vdata
  let _ = indices
  @scene3d.render_scene3d_gpu(scene, ctx.dst, shader3d, ctx.screen_w, ctx.screen_h)
}

// ============================================================
// Dungeon Scene (main gameplay)
// ============================================================

///|
struct DungeonScene {
  graph : @scene3d.SceneGraph
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  shader3d : @gfx.ShaderHandle
  shader3d_instanced : @gfx.ShaderHandle
  shader3d_instanced_monochrome : @gfx.ShaderHandle
  enemy_mesh : @mesh3d.Mesh3D
  enemy_instances : Array[@scene3d.InstanceData]
  mut prev_cursor_x : Double
  mut prev_cursor_y : Double
  mut time : Double
}

///|
fn DungeonScene::new() -> DungeonScene {
  let rng = @terrain.make_rng(42)
  let config = @bsp.BspConfig::{
    width: 40,
    height: 30,
    min_room_size: 4,
    max_depth: 5,
  }
  let result = @bsp.generate(config, rng)
  let grid = result.grid
  let dungeon_mesh = @terrain3d.grid_to_mesh3d(grid)
  let graph = @scene3d.SceneGraph::new()
  let dungeon_node = @scene3d.scene_node(
    mesh=Some(dungeon_mesh),
    color=@math3d.Vec4::new(0.6, 0.55, 0.45, 1.0),
  )
  let _ = graph.add_node(dungeon_node)
  // Pathfinding
  let mut start : @terrain.Point = { x: 0, y: 0 }
  let mut goal : @terrain.Point = { x: 0, y: 0 }
  let mut found_start = false
  let mut found_goal = false
  if result.rooms.length() >= 2 {
    let first_room = result.rooms[0]
    let last_room = result.rooms[result.rooms.length() - 1]
    start = first_room.rect.center()
    goal = last_room.rect.center()
    found_start = true
    found_goal = true
  }
  if not(found_start) || not(found_goal) {
    for y in 0..<grid.height {
      for x in 0..<grid.width {
        let tile = grid.get(x, y)
        if tile == @terrain.Tile::Floor || tile == @terrain.Tile::Corridor {
          if not(found_start) {
            start = { x, y }
            found_start = true
          } else {
            goal = { x, y }
            found_goal = true
          }
        }
      }
    }
  }
  match @pathfind.find_path(grid, start, goal) {
    Some(path) => {
      let path_mesh = build_path_mesh(path)
      let path_node = @scene3d.scene_node(
        mesh=Some(path_mesh),
        color=@math3d.Vec4::new(0.2, 0.8, 0.3, 1.0),
      )
      let _ = graph.add_node(path_node)
    }
    None => ()
  }
  // Generate enemy instances on room floors
  let enemy_mesh = @mesh3d.Mesh3D::cube(0.3)
  let enemy_instances : Array[@scene3d.InstanceData] = []
  let mut enemy_count = 0
  for room in result.rooms {
    if enemy_count >= 100 {
      break
    }
    let cx = room.rect.center().x.to_double() + 0.5
    let cz = room.rect.center().y.to_double() + 0.5
    // Place a grid of enemies in each room
    let room_w = room.rect.w
    let room_h = room.rect.h
    let step = 2
    for dy = 1; dy < room_h - 1; dy = dy + step {
      for dx = 1; dx < room_w - 1; dx = dx + step {
        if enemy_count >= 100 {
          break
        }
        let ex = room.rect.x.to_double() + dx.to_double() + 0.5
        let ez = room.rect.y.to_double() + dy.to_double() + 0.5
        let _ = cx
        let _ = cz
        let t = @transform3d.Transform3D::new().translate(
          @math3d.Vec3::new(ex, 0.3, ez),
        )
        // Vary color based on position
        let r = (ex * 0.1).abs() % 1.0
        let g = 0.2
        let b = (ez * 0.1).abs() % 1.0
        enemy_instances.push(
          @scene3d.InstanceData::new(
            transform=t,
            color=@math3d.Vec4::new(r, g, b, 1.0),
          ),
        )
        enemy_count = enemy_count + 1
      }
    }
  }
  // Camera
  let center_x = grid.width.to_double() * 0.5
  let center_z = grid.height.to_double() * 0.5
  let w_d = grid.width.to_double()
  let h_d = grid.height.to_double()
  let distance = (if w_d > h_d { w_d } else { h_d }) * 0.8
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(center_x, 0.0, center_z),
    distance,
    0.8,
    0.9,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    200.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.5, -1.0, -0.8),
      @math3d.Vec3::new(1.0, 0.98, 0.9),
      0.8,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(0.9, 0.85, 0.8), 0.3),
  )
  let shader3d = @gfx.new_shader_handle(
    10,
    @draw3d.shader3d_lit_untextured_wgsl(),
  )
  let shader3d_instanced = @gfx.new_shader_handle(
    11,
    @draw3d.shader3d_lit_instanced_wgsl(),
  )
  let shader3d_instanced_monochrome = @gfx.new_shader_handle(
    12,
    @draw3d.shader3d_lit_instanced_monochrome_wgsl(),
  )
  {
    graph,
    camera,
    lighting,
    shader3d,
    shader3d_instanced,
    shader3d_instanced_monochrome,
    enemy_mesh,
    enemy_instances,
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
    time: 0.0,
  }
}

///|
impl @scene_manager.Scene for DungeonScene with update(self, input) {
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
  self.time = self.time + 1.0 / 60.0
  // Animate enemy Y positions (bobbing)
  for i in 0..<self.enemy_instances.length() {
    let inst = self.enemy_instances[i]
    let pos = inst.transform.position
    let bob = @math.sin(self.time * 2.0 + i.to_double() * 0.5) * 0.1
    self.enemy_instances[i] = @scene3d.InstanceData::new(
      transform=inst.transform.with_position(
        @math3d.Vec3::new(pos.x, 0.3 + bob, pos.z),
      ),
      color=inst.color,
    )
  }
}

///|
impl @scene_manager.Scene for DungeonScene with draw(self, ctx) {
  // Render dungeon scene graph
  let camera = self.camera.to_camera3d()
  let view_projection = camera.view_projection_matrix()
  let cmds = @scene3d.render_scene3d_graph_gpu(
    self.graph,
    camera,
    lighting=self.lighting,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
  )
  // Add instanced enemy draw call
  if self.enemy_instances.length() > 0 {
    @scene3d.push_instanced_instance_data_gpu_commands_with_color_optimization_and_view_projection(
      self.enemy_mesh,
      self.enemy_instances,
      view_projection,
      self.lighting,
      ctx.dst,
      self.shader3d,
      self.shader3d_instanced,
      self.shader3d_instanced_monochrome,
      ctx.screen_w,
      ctx.screen_h,
      cmds,
    )
  }
  cmds
}

// ============================================================
// Path mesh builder (unchanged)
// ============================================================

///|
fn build_path_mesh(path : Array[@terrain.Point]) -> @mesh3d.Mesh3D {
  let vdata : Array[Double] = []
  let indices : Array[Int] = []
  let mut vi = 0
  let y = 0.05
  let pad = 0.15
  for p in path {
    let fx = p.x.to_double() + pad
    let fz = p.y.to_double() + pad
    let s = 1.0 - pad * 2.0
    let x1 = fx + s
    let z1 = fz + s
    vdata.push(fx)
    vdata.push(y)
    vdata.push(fz)
    vdata.push(0.0)
    vdata.push(1.0)
    vdata.push(0.0)
    vdata.push(0.0)
    vdata.push(0.0)
    vdata.push(x1)
    vdata.push(y)
    vdata.push(fz)
    vdata.push(0.0)
    vdata.push(1.0)
    vdata.push(0.0)
    vdata.push(1.0)
    vdata.push(0.0)
    vdata.push(x1)
    vdata.push(y)
    vdata.push(z1)
    vdata.push(0.0)
    vdata.push(1.0)
    vdata.push(0.0)
    vdata.push(1.0)
    vdata.push(1.0)
    vdata.push(fx)
    vdata.push(y)
    vdata.push(z1)
    vdata.push(0.0)
    vdata.push(1.0)
    vdata.push(0.0)
    vdata.push(0.0)
    vdata.push(1.0)
    indices.push(vi)
    indices.push(vi + 1)
    indices.push(vi + 2)
    indices.push(vi)
    indices.push(vi + 2)
    indices.push(vi + 3)
    vi = vi + 4
  }
  @mesh3d.Mesh3D::new(vdata, indices)
}

// ============================================================
// App State with SceneManager
// ============================================================

///|
struct AppState {
  manager : @scene_manager.SceneManager
  dungeon : DungeonScene
  mut scene_switch_timer : Double
}

///|
fn AppState::new() -> AppState {
  let menu = MenuScene::new()
  let dungeon = DungeonScene::new()
  let manager = @scene_manager.SceneManager::new(menu)
  { manager, dungeon, scene_switch_timer: 0.0 }
}

///|
fn AppState::update(self : AppState, input : @core.InputSnapshot) -> Unit {
  self.manager.update(input)
  // Auto-transition from menu to dungeon after 2 seconds
  if not(self.manager.is_transitioning()) {
    self.scene_switch_timer = self.scene_switch_timer + 1.0 / 60.0
    if self.scene_switch_timer > 2.0 && self.scene_switch_timer < 2.1 {
      self.manager.transition_to(self.dungeon, duration=0.5)
    }
  }
}

///|
fn AppState::draw(
  self : AppState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  self.manager.draw(ctx)
}
