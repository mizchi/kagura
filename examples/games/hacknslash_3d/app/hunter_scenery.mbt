// Static geometry is built once. Decorations sit on existing wall/door tiles.

///|
fn make_hunter_pavers() -> @mesh3d.Mesh3D {
  let g = HunterGeometry::new()
  g.box(-0.251, -0.035, 0.0, 0.486, 0.07, 0.976, 0)
  g.box(0.251, -0.035, -0.251, 0.486, 0.07, 0.474, 0)
  g.box(0.251, -0.035, 0.251, 0.486, 0.07, 0.474, 0)
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}

///|
fn make_hunter_fence(height : Double) -> @mesh3d.Mesh3D {
  let g = HunterGeometry::new()
  g.box(0.0, height / 2.0, 0.0, 0.97, height, 0.97, 0)
  g.box(0.0, height + 0.04, 0.0, 1.0, 0.08, 1.0, 0)
  for x in [-0.36, -0.12, 0.12, 0.36] {
    g.loft(
      x,
      0.0,
      [
        (height + 0.08, 0.021, 0.021),
        (height + 0.64, 0.021, 0.021),
        (height + 0.74, 0.001, 0.001),
      ],
      4,
      0,
    )
  }
  g.box(0.0, height + 0.44, 0.0, 1.0, 0.035, 0.035, 0)
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}

///|
fn make_hunter_pillar() -> @mesh3d.Mesh3D {
  let g = HunterGeometry::new()
  g.loft(
    0.0,
    0.0,
    [
      (0.0, 0.20, 0.20),
      (0.16, 0.20, 0.20),
      (0.24, 0.14, 0.14),
      (1.2, 0.12, 0.12),
      (1.3, 0.18, 0.18),
      (1.42, 0.18, 0.18),
      (1.68, 0.015, 0.015),
    ],
    4,
    0,
  )
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}

///|
let hunter_lantern_mesh : @mesh3d.Mesh3D = {
  let g = HunterGeometry::new()
  g.loft(
    0.0,
    0.0,
    [
      (0.0, 0.16, 0.16),
      (0.12, 0.11, 0.11),
      (1.35, 0.035, 0.035),
      (1.43, 0.17, 0.17),
    ],
    6,
    0,
  )
  for x in [-0.12, 0.12] {
    for z in [-0.12, 0.12] {
      g.box(x, 1.62, z, 0.025, 0.4, 0.025, 0)
    }
  }
  g.loft(
    0.0,
    0.0,
    [(1.83, 0.22, 0.22), (1.89, 0.17, 0.17), (2.02, 0.01, 0.01)],
    4,
    0,
  )
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}

///|
let hunter_lantern_glow : @mesh3d.Mesh3D = @mesh3d.Mesh3D::box(0.19, 0.28, 0.19)

///|
fn GameState::push_hunter_lanterns(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if self.world.hunting_grounds && self.world.authored_scene is None {
    return
  }
  let posts : Array[@scene3d.InstanceData] = []
  let lights : Array[@scene3d.InstanceData] = []
  let px = self.world.player.x / tile_size
  let pz = self.world.player.y / tile_size
  for room in self.world.dungeon.rooms {
    let r = room.rect
    for side in [0, 1] {
      let col = if side == 0 { r.x - 1 } else { r.x + r.w }
      let row = r.y + r.h / 2
      if self.world.dungeon.grid.get(col, row) != @terrain.Wall {
        continue
      }
      let x = col.to_double() + 0.5
      let z = row.to_double() + 0.5
      if (x - px).abs() > 22.0 || (z - pz).abs() > 22.0 {
        continue
      }
      let y = height_at_tile(self.world.dungeon, x.to_int(), z.to_int())
      posts.push(
        @scene3d.InstanceData::new(
          transform=@transform3d.Transform3D::from_position(
            @math3d.Vec3::new(x, y, z),
          ),
          color=hex_to_vec4(0x716250),
        ),
      )
      lights.push(
        @scene3d.InstanceData::new(
          transform=@transform3d.Transform3D::from_position(
            @math3d.Vec3::new(x, y + 1.63, z),
          ),
          color=@math3d.Vec4::new(2.2, 1.0, 0.30, 1.0),
        ),
      )
    }
  }
  if posts.length() == 0 {
    return
  }
  fn push_group(
    mesh : @mesh3d.Mesh3D,
    instances : Array[@scene3d.InstanceData],
    lighting : @light3d.LightingEnvironment,
  ) -> Unit {
    @scene3d.push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
      mesh,
      instances.map(fn(i) { i.transform.to_mat4() }),
      instances.map(fn(i) { i.color }),
      vp,
      lighting,
      dst,
      self.shader3d_colored,
      self.shader3d_instanced,
      self.shader3d_instanced_monochrome,
      screen_w,
      screen_h,
      cmds,
    )
  }
  push_group(hunter_lantern_mesh, posts, self.lighting)
  let glow_lighting = @light3d.LightingEnvironment::new(
    self.lighting.directional,
    @light3d.AmbientLight::new(@math3d.Vec3::one(), 1.0),
  )
  push_group(hunter_lantern_glow, lights, glow_lighting)
}

///|
let hunter_slash_mesh : @mesh3d.Mesh3D = {
  let g = HunterGeometry::new()
  for i in 0..<18 {
    let t = i.to_double() / 18.0
    let next = (i + 1).to_double() / 18.0
    fn p(t : Double, outer : Bool) -> @math3d.Vec3 {
      let a = (t - 0.5) * 2.5
      let r = if outer { 1.62 } else { 1.62 - 0.24 * @math.sin(t * @math.PI) }
      @math3d.Vec3::new(@math.sin(a) * r, 0.52, @math.cos(a) * r)
    }
    g.quad(p(t, false), p(t, true), p(next, true), p(next, false), 0)
  }
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}

///|
fn GameState::push_hunter_slash(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if self.character.anim_state != Attacking {
    return
  }
  let t = self.character.action_time / attack_anim_duration
  if t < 0.16 || t > 0.86 {
    return
  }
  let p = self.world.player
  let model = @transform3d.Transform3D::from_position_rotation(
    @math3d.Vec3::new(
      p.x / tile_size,
      @game.get_tile_height(self.world.dungeon, p.x, p.y),
      p.y / tile_size,
    ),
    @math3d.Quaternion::from_axis_angle(
      @math3d.Vec3::unit_y(),
      -p.facing_angle +
      @math.PI / 2.0 +
      (t - 0.5) * self.character.attack_side * 2.0,
    ),
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
        hunter_slash_mesh.indices.length(),
      ),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(1),
      hunter_slash_mesh,
      model.to_mat4(),
      vp,
      self.lighting,
      @math3d.Vec4::new(1.65, 1.28, 0.75, (1.0 - t) * 0.85),
      [],
    ),
  )
}
