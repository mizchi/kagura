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
// Audio: Tone generation
// ============================================================

///|
fn generate_tone_clip(
  freq : Double,
  duration : Double,
  sample_rate : Int,
) -> @audio.AudioClip {
  let fmt = @audio.default_audio_format()
  let num_frames = (duration * sample_rate.to_double()).to_int()
  let bytes_arr : Array[Byte] = []
  for i in 0..<num_frames {
    let t = i.to_double() / sample_rate.to_double()
    let envelope = 1.0 - t / duration
    let value = @math.sin(2.0 * @math.PI * freq * t) * envelope
    let i16_val = (value * 32767.0).to_int()
    let lo = (i16_val & 0xFF).to_byte()
    let hi = ((i16_val >> 8) & 0xFF).to_byte()
    // left channel
    bytes_arr.push(lo)
    bytes_arr.push(hi)
    // right channel (same)
    bytes_arr.push(lo)
    bytes_arr.push(hi)
  }
  @audio.new_audio_clip(fmt, Bytes::from_array(bytes_arr), false)
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
  audio_ctx : @audio.MixerAudioContext
  sfx_collect : @audio.PlayerId
  sfx_hit : @audio.PlayerId
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
  let audio_ctx = @audio.MixerAudioContext::new(44100)
  let clip_collect = generate_tone_clip(880.0, 0.15, 44100)
  let clip_hit = generate_tone_clip(220.0, 0.2, 44100)
  let sfx_collect = audio_ctx.create_player(clip_collect) catch {
    _ => panic()
  }
  let sfx_hit = audio_ctx.create_player(clip_hit) catch {
    _ => panic()
  }
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
    audio_ctx,
    sfx_collect,
    sfx_hit,
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
      self.audio_ctx.seek(self.sfx_collect, 0.0) catch { _ => () }
      self.audio_ctx.play(self.sfx_collect) catch { _ => () }
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
      self.audio_ctx.seek(self.sfx_hit, 0.0) catch { _ => () }
      self.audio_ctx.play(self.sfx_hit) catch { _ => () }
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
fn GameState::build_scene3d(self : GameState) -> @scene3d.Scene3D {
  let objects : Array[@scene3d.Object3D] = []
  // Ground
  objects.push(
    @scene3d.object3d(mesh=self.meshes.ground, color=color_ground),
  )
  // Walls
  let h = arena_half
  let wh = wall_height / 2.0
  let wt = wall_thickness
  // North wall
  objects.push(
    @scene3d.object3d(
      mesh=self.meshes.wall,
      position=@math3d.Vec3::new(0.0, wh, -(h + wt / 2.0)),
      scale=@math3d.Vec3::new(h * 2.0 + wt * 2.0, wall_height, wt),
      color=color_wall,
    ),
  )
  // South wall
  objects.push(
    @scene3d.object3d(
      mesh=self.meshes.wall,
      position=@math3d.Vec3::new(0.0, wh, h + wt / 2.0),
      scale=@math3d.Vec3::new(h * 2.0 + wt * 2.0, wall_height, wt),
      color=color_wall,
    ),
  )
  // West wall
  objects.push(
    @scene3d.object3d(
      mesh=self.meshes.wall,
      position=@math3d.Vec3::new(-(h + wt / 2.0), wh, 0.0),
      scale=@math3d.Vec3::new(wt, wall_height, h * 2.0),
      color=color_wall,
    ),
  )
  // East wall
  objects.push(
    @scene3d.object3d(
      mesh=self.meshes.wall,
      position=@math3d.Vec3::new(h + wt / 2.0, wh, 0.0),
      scale=@math3d.Vec3::new(wt, wall_height, h * 2.0),
      color=color_wall,
    ),
  )
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
  @scene3d.scene3d(
    objects~,
    camera=self.camera.to_camera3d(),
    lighting=self.lighting,
  )
}

///|
fn GameState::draw(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let scene = self.build_scene3d()
  @scene3d.render_scene3d(scene, ctx.dst, ctx.shader, ctx.screen_w, ctx.screen_h)
}
