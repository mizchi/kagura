// Retained geometry makes skill footprints visible without dense particle clouds.

///|
enum CombatVisualKind {
  Impact(@game.CombatImpactKind)
  Bolt
  Block(Bool)
}

///|
struct CombatVisual {
  kind : CombatVisualKind
  x : Double
  y : Double
  end_x : Double
  end_y : Double
  radius : Double
  angle : Double
  hits : Int
  mut age : Int
}

///|
fn GameState::queue_combat_visual(
  self : GameState,
  event : @game.GameEvent,
) -> Unit {
  let visual = match event {
    @game.CombatImpact(kind, x, y, radius, hits) =>
      Some({
        kind: Impact(kind),
        x,
        y,
        end_x: x,
        end_y: y,
        radius,
        hits,
        angle: self.world.player.facing_angle,
        age: 0,
      })
    @game.ChainLightningArc(x, y, end_x, end_y) =>
      Some({
        kind: Bolt,
        x,
        y,
        end_x,
        end_y,
        radius: 0.0,
        hits: 0,
        angle: self.world.player.facing_angle,
        age: 0,
      })
    @game.GuardBlocked(x, y, perfect) =>
      Some({
        kind: Block(perfect),
        x,
        y,
        end_x: x,
        end_y: y,
        radius: 0.0,
        hits: 1,
        angle: self.world.player.facing_angle,
        age: 0,
      })
    _ => None
  }
  if visual is Some(visual) {
    self.combat_visuals.push(visual)
  }
}

///|
fn GameState::tick_combat_visuals(self : GameState) -> Unit {
  for v in self.combat_visuals {
    v.age += 1
  }
  self.combat_visuals = self.combat_visuals.filter(v => {
    v.age <
    (match v.kind {
      Bolt => 18
      Block(_) => 16
      Impact(_) => 30
    })
  })
}

///|
fn combat_ring_geometry(inner : Double, arc : Double) -> @mesh3d.Mesh3D {
  let g = @procedural3d.RigidGeometry::new()
  fn point(a : Double, r : Double) -> @math3d.Vec3 {
    @math3d.Vec3::new(@math.sin(a) * r, 0.0, @math.cos(a) * r)
  }
  for i in 0..<64 {
    let a = -arc / 2.0 + i.to_double() / 64.0 * arc
    let b = -arc / 2.0 + (i + 1).to_double() / 64.0 * arc
    g.quad(point(a, inner), point(a, 1.0), point(b, 1.0), point(b, inner), 0)
  }
  g.build_mesh()
}

///|
let combat_ring : @mesh3d.Mesh3D = combat_ring_geometry(0.94, @math.PI * 2.0)

///|
let combat_disk : @mesh3d.Mesh3D = combat_ring_geometry(0.0, @math.PI * 2.0)

///|
let combat_arc : @mesh3d.Mesh3D = combat_ring_geometry(0.82, @math.PI * 1.12)

///|
let combat_core : @mesh3d.Mesh3D = @mesh3d.Mesh3D::box(1.0, 1.0, 1.0)

///|
fn combat_bolt_geometry(width : Double) -> @mesh3d.Mesh3D {
  let g = @procedural3d.RigidGeometry::new()
  let points = [0.0, 0.16, -0.22, 0.11, -0.12, 0.25, -0.17, 0.0]
  for i in 0..<7 {
    let z0 = i.to_double() / 7.0
    let z1 = (i + 1).to_double() / 7.0
    g.quad(
      @math3d.Vec3::new(points[i] - width, 0.0, z0),
      @math3d.Vec3::new(points[i + 1] - width, 0.0, z1),
      @math3d.Vec3::new(points[i + 1] + width, 0.0, z1),
      @math3d.Vec3::new(points[i] + width, 0.0, z0),
      0,
    )
  }
  g.build_mesh()
}

///|
let combat_bolt_outer : @mesh3d.Mesh3D = combat_bolt_geometry(0.07)

///|
let combat_bolt_inner : @mesh3d.Mesh3D = combat_bolt_geometry(0.025)

///|
fn GameState::push_combat_mesh(
  self : GameState,
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  color : @math3d.Vec4,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  @web_hooks.register_static_geometry(mesh.vertex_data, mesh.indices)
  cmds.push(
    @draw3d.new_lit_colored_mesh_draw_command(
      dst,
      self.shader3d_colored,
      @gfx.new_dst_region(0, 0, screen_w, screen_h, mesh.indices.length()),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(0),
      mesh,
      model,
      vp,
      self.lighting,
      color,
      [],
    ),
  )
}

///|
fn combat_transform(
  x : Double,
  y : Double,
  z : Double,
  sx : Double,
  sy : Double,
  sz : Double,
  yaw? : Double = 0.0,
) -> @math3d.Mat4 {
  @transform3d.Transform3D::from_position_rotation(
    @math3d.Vec3::new(x, y, z),
    @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), yaw),
  )
  .with_scale(@math3d.Vec3::new(sx, sy, sz))
  .to_mat4()
}

///|
fn GameState::draw_skill_circle(
  self : GameState,
  x : Double,
  y : Double,
  radius : Double,
  progress : Double,
  valid : Bool,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let r = radius / tile_size
  let color = if valid {
    @math3d.Vec4::new(0.20, 0.70, 0.95, 1.0)
  } else {
    @math3d.Vec4::new(1.5, 0.25, 0.22, 1.0)
  }
  self.push_combat_mesh(
    combat_ring,
    combat_transform(x / tile_size, 0.055, y / tile_size, r, 1.0, r),
    color,
    vp,
    dst,
    cmds,
  )
  let inner = r * (0.18 + 0.74 * progress)
  self.push_combat_mesh(
    combat_ring,
    combat_transform(x / tile_size, 0.065, y / tile_size, inner, 1.0, inner),
    color,
    vp,
    dst,
    cmds,
  )
  for i in 0..<8 {
    let a = i.to_double() * @math.PI / 4.0
    self.push_combat_mesh(
      combat_core,
      combat_transform(
        x / tile_size + @math.sin(a) * r,
        0.07,
        y / tile_size + @math.cos(a) * r,
        0.08,
        0.04,
        0.3,
        yaw=a,
      ),
      color,
      vp,
      dst,
      cmds,
    )
  }
}

///|
fn GameState::push_combat_visuals(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  self.push_whirlwind_trail(vp, dst, cmds)
  if self.ground_targeting && self.world.ui_mode == @game.UIMode::None {
    self.draw_skill_circle(
      self.ground_target_x,
      self.ground_target_y,
      @game.effective_aoe_radius(
        self.world.player_stats,
        @game.AoEMastery,
        @game.ground_strike_radius,
      ),
      0.0,
      self.world.ground_strike_target_valid(
        self.ground_target_x,
        self.ground_target_y,
      ),
      vp,
      dst,
      cmds,
    )
  }
  if self.world.arts.strike is Some(s) {
    self.draw_skill_circle(
      s.x,
      s.y,
      s.radius,
      s.frame.to_double() / @game.ground_strike_delay.to_double(),
      true,
      vp,
      dst,
      cmds,
    )
  }
  for v in self.combat_visuals {
    let x = v.x / tile_size
    let z = v.y / tile_size
    let t = v.age.to_double() / 30.0
    match v.kind {
      Impact(@game.WhirlwindCut) => () // The channel owns its moving footprint.
      Impact(kind) => {
        let r = v.radius / tile_size
        let color = match kind {
          FlameBlast =>
            @math3d.Vec4::new(2.0, 0.75 * (1.0 - t) + 0.2, 0.08, 1.0)
          AstralBlast => @math3d.Vec4::new(0.9, 1.5, 2.0, 1.0)
          WhirlwindCut | DashCut => @math3d.Vec4::new(1.65, 1.55, 1.15, 1.0)
        }
        if kind == @game.DashCut {
          self.push_combat_mesh(
            combat_arc,
            combat_transform(
              x,
              0.5,
              z,
              r * (0.6 + t * 0.4),
              1.0,
              r,
              yaw=@math.PI / 2.0 - v.angle,
            ),
            color,
            vp,
            dst,
            cmds,
          )
        } else {
          self.push_combat_mesh(
            combat_ring,
            combat_transform(x, 0.08, z, r, 1.0, r),
            color,
            vp,
            dst,
            cmds,
          )
          if v.age < 12 {
            let size = r * (0.25 + t * 1.6)
            self.push_combat_mesh(
              combat_disk,
              combat_transform(x, 0.09, z, size, 1.0, size),
              @math3d.Vec4::new(2.0, 1.9, 1.5, 1.0),
              vp,
              dst,
              cmds,
            )
          }
          if kind == @game.AstralBlast && v.age < 10 {
            self.push_combat_mesh(
              combat_core,
              combat_transform(x, 2.5, z, 0.18, 5.0, 0.18),
              @math3d.Vec4::new(1.8, 2.0, 2.3, 1.0),
              vp,
              dst,
              cmds,
            )
          }
          // Hit confirmation is a brief cross above the impact, absent for an empty explosion.
          if v.hits > 0 && v.age < 10 {
            for yaw in [-0.65, 0.65] {
              self.push_combat_mesh(
                combat_core,
                combat_transform(x, 0.9, z, 0.07, 0.07, 0.9, yaw~),
                @math3d.Vec4::new(2.0, 2.0, 1.7, 1.0),
                vp,
                dst,
                cmds,
              )
            }
          }
        }
      }
      Bolt => {
        let dx = (v.end_x - v.x) / tile_size
        let dz = (v.end_y - v.y) / tile_size
        let length = (dx * dx + dz * dz).sqrt()
        let yaw = @math.atan2(dx, dz)
        self.push_combat_mesh(
          combat_bolt_outer,
          combat_transform(x, 0.72, z, 1.0, 1.0, length, yaw~),
          @math3d.Vec4::new(0.25, 0.9, 2.0, 1.0),
          vp,
          dst,
          cmds,
        )
        self.push_combat_mesh(
          combat_bolt_inner,
          combat_transform(x, 0.73, z, 1.0, 1.0, length, yaw~),
          @math3d.Vec4::new(2.0, 2.0, 2.0, 1.0),
          vp,
          dst,
          cmds,
        )
        self.push_combat_mesh(
          combat_ring,
          combat_transform(
            v.end_x / tile_size,
            0.1,
            v.end_y / tile_size,
            0.4 + t,
            1.0,
            0.4 + t,
          ),
          @math3d.Vec4::new(0.7, 1.5, 2.0, 1.0),
          vp,
          dst,
          cmds,
        )
      }
      Block(perfect) =>
        self.push_combat_mesh(
          combat_arc,
          combat_transform(
            x,
            0.6,
            z,
            0.8 + t,
            1.0,
            0.8 + t,
            yaw=@math.PI / 2.0 - v.angle,
          ),
          if perfect {
            @math3d.Vec4::new(2.0, 1.9, 1.1, 1.0)
          } else {
            @math3d.Vec4::new(0.65, 1.3, 1.8, 1.0)
          },
          vp,
          dst,
          cmds,
        )
    }
  }
  for p in self.world.projectiles {
    if p.alive && p.is_player && p.kind is @game.Fireball(_) {
      let x = p.x / tile_size
      let z = p.y / tile_size
      let yaw = @math.atan2(p.vx, p.vy)
      self.push_combat_mesh(
        combat_core,
        combat_transform(x, 0.4, z, 0.17, 0.17, 0.42, yaw~),
        @math3d.Vec4::new(2.5, 2.0, 0.95, 1.0),
        vp,
        dst,
        cmds,
      )
      let speed = (p.vx * p.vx + p.vy * p.vy).sqrt().max(0.01)
      for i in 1..<4 {
        let distance = i.to_double() * 0.28
        let size = 0.18 - i.to_double() * 0.035
        self.push_combat_mesh(
          combat_core,
          combat_transform(
            x - p.vx / speed * distance,
            0.4,
            z - p.vy / speed * distance,
            size,
            size,
            0.3,
            yaw~,
          ),
          @math3d.Vec4::new(2.0, 0.7, 0.08, 1.0),
          vp,
          dst,
          cmds,
        )
      }
    }
  }
}

///|
let hunter_guard_parts : Array[HunterPart] = {
  let rim = @procedural3d.RigidGeometry::new()
  let face = @procedural3d.RigidGeometry::new()
  rim.loft(-0.30, 0.02, [(0.38, 0.32, 0.40), (0.46, 0.32, 0.40)], 8, 7)
  face.loft(-0.30, 0.02, [(0.365, 0.265, 0.34), (0.375, 0.265, 0.34)], 8, 7)
  rim.box(-0.30, 0.35, 0.02, 0.055, 0.045, 0.43, 7)
  rim.box(-0.30, 0.35, 0.04, 0.3, 0.045, 0.055, 7)
  [
    finish_hunter_part(rim, "shield_rim", 0xC1AA77),
    finish_hunter_part(face, "shield_iron", 0x334953),
  ]
}

///|
fn GameState::push_hunter_guard(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if !self.world.arts.guarding {
    return
  }
  let p = self.world.player
  let skin = self.character.compute_skinning()
  let rotation = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    @math.PI / 2.0 - p.facing_angle,
  )
  let transform = @transform3d.Transform3D::from_position_rotation(
    @math3d.Vec3::new(p.x / tile_size, 0.0, p.y / tile_size),
    rotation,
  )
  for part in hunter_guard_parts {
    @web_hooks.register_static_geometry(part.packed, part.mesh.indices)
    @scene3d.push_single_skinned_mesh_gpu_command_with_view_projection(
      part.mesh,
      transform,
      part.color,
      part.packed,
      skin,
      vp,
      self.lighting,
      dst,
      self.shader3d_skinned,
      screen_w,
      screen_h,
      cmds,
    )
  }
}
