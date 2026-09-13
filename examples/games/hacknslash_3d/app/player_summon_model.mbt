///|
/// Static low-poly pieces, shared by every spirit. Animation only changes instance transforms.
let flaming_skull_mesh : EnemyMeshData = {
  let bone = @procedural3d.RigidGeometry::new()
  let dark = @procedural3d.RigidGeometry::new()
  let fire = @procedural3d.RigidGeometry::new()
  bone.loft(
    0.0,
    0.0,
    [
      (-0.16, 0.17, 0.16),
      (0.0, 0.25, 0.21),
      (0.20, 0.23, 0.18),
      (0.30, 0.12, 0.10),
    ],
    7,
    0,
  )
  bone.box(0.0, -0.19, 0.09, 0.30, 0.11, 0.24, 0)
  dark.box(0.0, -0.115, 0.20, 0.26, 0.07, 0.05, 0)
  for side in [-1.0, 1.0] {
    dark.box(side * 0.115, 0.085, 0.192, 0.145, 0.13, 0.045, 0)
    fire.box(side * 0.115, 0.085, 0.221, 0.055, 0.042, 0.015, 0)
  }
  dark.triangle(
    @math3d.Vec3::new(-0.04, -0.065, 0.23),
    @math3d.Vec3::new(0.04, -0.065, 0.23),
    @math3d.Vec3::new(0.0, 0.018, 0.24),
    0,
  )
  for i in 0..<4 {
    bone.box(
      (i.to_double() - 1.5) * 0.062,
      -0.12,
      0.232,
      0.042,
      0.075,
      0.035,
      0,
    )
  }
  // Flames lean behind the skull so its bright face stays legible from above.
  for i in 0..<5 {
    let x = (i.to_double() - 2.0) * 0.11
    fire.segment(
      @math3d.Vec3::new(x, 0.0, -0.08),
      @math3d.Vec3::new(x * 1.1, 0.45 + (i % 2).to_double() * 0.12, -0.32),
      0.12,
      0.006,
      5,
      0,
    )
  }
  combine_enemy_parts([
    monster_material("ivory_skull", bone, 0xFFF0C9),
    monster_material("charred_sockets", dark, 0x261913),
    monster_material("living_flame", fire, 0xFF751E),
  ])
}

///|
let summon_ring_mesh : @mesh3d.Mesh3D = {
  let geometry = @procedural3d.RigidGeometry::new()
  for i in 0..<24 {
    let a = i.to_double() * @math.PI / 12.0
    let b = (i + 1).to_double() * @math.PI / 12.0
    let inner_a = @math3d.Vec3::new(
      @math.cos(a) * 0.40,
      0.0,
      @math.sin(a) * 0.40,
    )
    let outer_a = @math3d.Vec3::new(
      @math.cos(a) * 0.47,
      0.0,
      @math.sin(a) * 0.47,
    )
    let inner_b = @math3d.Vec3::new(
      @math.cos(b) * 0.40,
      0.0,
      @math.sin(b) * 0.40,
    )
    let outer_b = @math3d.Vec3::new(
      @math.cos(b) * 0.47,
      0.0,
      @math.sin(b) * 0.47,
    )
    geometry.triangle(inner_a, inner_b, outer_a, 0)
    geometry.triangle(outer_a, inner_b, outer_b, 0)
  }
  geometry.build_mesh()
}

///|
fn GameState::push_player_summon_commands(
  self : GameState,
  region : VisibleRegion,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let rings : Array[@scene3d.InstanceData] = []
  for zombie in self.world.summons.zombies {
    let body = zombie.body
    if body.alive && is_entity_visible(region, body.x, body.y) {
      rings.push(
        @scene3d.InstanceData::new(
          transform=@transform3d.Transform3D::from_position(
            @math3d.Vec3::new(
              body.x / tile_size,
              @game.get_tile_height(self.world.dungeon, body.x, body.y) + 0.035,
              body.y / tile_size,
            ),
          ),
          color=@math3d.Vec4::new(0.35, 1.8, 1.3, 1.0),
        ),
      )
    }
  }
  push_entity_instances_if_any(
    summon_ring_mesh,
    rings,
    view_projection,
    self.lighting,
    dst,
    self.shader3d_colored,
    self.shader3d_instanced,
    self.shader3d_instanced_monochrome,
    screen_w,
    screen_h,
    cmds,
  )
  for part in flaming_skull_mesh.parts {
    let instances : Array[@scene3d.InstanceData] = []
    for index, skull in self.world.summons.skulls {
      if !is_entity_visible(region, skull.x, skull.y) {
        continue
      }
      let t = skull.age.to_double()
      let fade = ((@game.flaming_skull_lifetime - skull.age).to_double() / 24.0).min(
        1.0,
      )
      let rise = (t / 10.0).min(1.0)
      let is_fire = part.name == "living_flame"
      let pulse = if is_fire { 1.0 + @math.sin(t * 0.45) * 0.12 } else { 1.0 }
      let height = @game.get_tile_height(self.world.dungeon, skull.x, skull.y) +
        0.85 +
        @math.sin(t * 0.14 + index.to_double()) * 0.08
      let attack = if skull.attack_cooldown > 28 { 1.18 } else { 1.0 }
      instances.push(
        @scene3d.InstanceData::new(
          transform=@transform3d.Transform3D::from_position(
              @math3d.Vec3::new(
                skull.x / tile_size,
                height,
                skull.y / tile_size,
              ),
            )
            .with_rotation(
              @math3d.Quaternion::from_axis_angle(
                @math3d.Vec3::new(0.0, 1.0, 0.0),
                @math.PI / 2.0 - skull.angle,
              ),
            )
            .with_scale(
              @math3d.Vec3::new(
                fade * rise * attack,
                fade * rise * pulse,
                fade * rise * attack,
              ),
            ),
          color=@math3d.Vec4::new(
            part.color.x * (if is_fire { 2.0 } else { 1.35 }),
            part.color.y * (if is_fire { 1.6 } else { 1.35 }),
            part.color.z * 1.35,
            1.0,
          ),
        ),
      )
    }
    push_entity_instances_if_any(
      part.geometry.bind_mesh,
      instances,
      view_projection,
      self.lighting,
      dst,
      self.shader3d_colored,
      self.shader3d_instanced,
      self.shader3d_instanced_monochrome,
      screen_w,
      screen_h,
      cmds,
    )
  }
}
