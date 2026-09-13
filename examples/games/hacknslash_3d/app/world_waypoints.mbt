///|
struct HunterRegionView {
  id : Int
  name : String
  subtitle : String
  x : Int
  z : Int
  tier : Int
  unlocked : Bool
  visited : Bool
  ready : Bool
  progress : Int
} derive(ToJson)

///|
struct HunterAtlasView {
  current : Int
  name : String
  subtitle : String
  near_waypoint : Bool
  regions : Array[HunterRegionView]
  travel_target : Int?
  waypoint_x : Double
  waypoint_z : Double
  global_x : Double
  global_z : Double
  chunks_built : Int
} derive(ToJson)

///|
fn GameState::hunter_atlas_view(self : GameState) -> HunterAtlasView? {
  guard self.world.atlas is Some(atlas) else { return None }
  if self.motion_preview || self.world.authored_scene is Some(_) {
    return None
  }
  let current = @game.world_regions[atlas.current]
  let (wx, wz) = @game.world_waypoint_position(atlas.current)
  Some({
    waypoint_x: wx / tile_size,
    waypoint_z: wz / tile_size,
    current: atlas.current,
    name: current.name,
    subtitle: current.subtitle,
    near_waypoint: self.world.near_waypoint(),
    travel_target: atlas.travel_target,
    global_x: self.world.player.x / tile_size +
    current.x.to_double() * (@game.map_cols - 2).to_double(),
    global_z: self.world.player.y / tile_size +
    current.z.to_double() * (@game.map_rows - 2).to_double(),
    chunks_built: self.region_chunks_built,
    regions: @game.world_regions.map(region => {
      let progress = match self.region_meshes[region.id] {
        Some(cache) => cache.chunks.length() * 100 / cache.total.max(1)
        None => 0
      }
      {
        id: region.id,
        name: region.name,
        subtitle: region.subtitle,
        x: region.x,
        z: region.z,
        tier: region.tier,
        unlocked: atlas.unlocked[region.id],
        visited: atlas.visited[region.id],
        ready: progress == 100,
        progress,
      }
    }),
  })
}

///|
fn GameState::update_waypoints_ui(self : GameState) -> Unit {
  if is_up_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor + 3) % 4
  }
  if is_down_just_pressed(self.input) {
    self.world.ui_cursor = (self.world.ui_cursor + 1) % 4
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 13) {
    ignore(self.world.request_waypoint(self.world.ui_cursor))
  }
}

///|
fn GameState::render_waypoints_ui(
  self : GameState,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let ctx = self.make_hud_ctx(dst, shader)
  ctx.draw_rect(
    cmds,
    0.0,
    0.0,
    screen_w.to_double(),
    screen_h.to_double(),
    @hud.hex_color(0x101E1B, alpha=0.95),
  )
  ctx.draw_text(cmds, "WAYPOINTS / G : CLOSE", 18.0, 35.0, 35.0, 0xDDC58A)
  guard self.world.atlas is Some(atlas) else { return }
  for region in @game.world_regions {
    let y = 95.0 + region.id.to_double() * 64.0
    let selected = self.world.ui_cursor == region.id
    ctx.draw_rect(
      cmds,
      35.0,
      y,
      570.0,
      52.0,
      @hud.hex_color(if selected { 0x33483B } else { 0x192B25 }),
    )
    ctx.draw_text(
      cmds,
      region.name +
      (if atlas.unlocked[region.id] { " / ACTIVE" } else { " / LOCKED" }),
      14.0,
      48.0,
      y + 14.0,
      0xD6CDB2,
    )
  }
  ctx.draw_text(
    cmds,
    if self.world.near_waypoint() {
      "W/S: SELECT   ENTER: TRAVEL"
    } else {
      "APPROACH A WAYPOINT TO TRAVEL"
    },
    12.0,
    35.0,
    394.0,
    0xAFC1A8,
  )
}

///|
let world_waypoint_ring : @mesh3d.Mesh3D = {
  let g = @procedural3d.RigidGeometry::new()
  for i in 0..<32 {
    fn p(index : Int, radius : Double) -> @math3d.Vec3 {
      let angle = index.to_double() * @math.PI * 2.0 / 32.0
      @math3d.Vec3::new(
        @math.cos(angle) * radius,
        0.025,
        @math.sin(angle) * radius,
      )
    }
    g.quad(p(i, 1.65), p(i + 1, 1.65), p(i + 1, 1.8), p(i, 1.8), 0)
    if i % 4 == 0 {
      g.quad(p(i, 1.15), p(i + 1, 1.15), p(i + 1, 1.5), p(i, 1.5), 0)
    }
  }
  g.loft(0.0, 0.0, [(1.9, 0.0, 0.0), (2.25, 0.22, 0.22), (2.6, 0.0, 0.0)], 4, 0)
  g.build_mesh()
}

///|
fn GameState::push_world_waypoint(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  guard self.world.atlas is Some(atlas) else { return }
  if self.motion_preview || self.world.authored_scene is Some(_) {
    return
  }
  let (x, y) = @game.world_waypoint_position(atlas.current)
  if (x - self.world.player.x).abs() > tile_size * 28.0 ||
    (y - self.world.player.y).abs() > tile_size * 28.0 {
    return
  }
  let model = @transform3d.Transform3D::from_position(
    @math3d.Vec3::new(x / tile_size, 0.0, y / tile_size),
  ).to_mat4()
  let color = if atlas.unlocked[atlas.current] {
    @math3d.Vec4::new(1.3, 1.65, 1.3, 1.0)
  } else {
    hex_to_vec4(0x738477)
  }
  @web_hooks.register_static_geometry(
    world_waypoint_ring.vertex_data,
    world_waypoint_ring.indices,
  )
  cmds.push(
    @draw3d.new_lit_colored_mesh_draw_command(
      dst,
      self.shader3d_colored,
      @gfx.new_dst_region(
        0,
        0,
        screen_w,
        screen_h,
        world_waypoint_ring.indices.length(),
      ),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(0),
      world_waypoint_ring,
      model,
      vp,
      self.lighting,
      color,
      [],
    ),
  )
}
