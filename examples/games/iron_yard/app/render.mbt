///|
extern "js" fn instance_shader(source : String, dwords : Int) -> String =
  #| (source, dwords) => globalThis.__kaguraGfx?.instanceUniformShader?.(source, dwords) ?? source

///|
#external
priv type GeometryArray

///|
fn geometry_vertices(values : Array[Double]) -> GeometryArray = "%identity"

///|
fn geometry_indices(values : Array[Int]) -> GeometryArray = "%identity"

///|
extern "js" fn register_static_geometry(
  vertices : GeometryArray,
  indices : GeometryArray,
) -> Unit =
  #| (vertices, indices) => {
  #|   const gpu = globalThis.__kaguraWebRuntime?.webgpu;
  #|   if (gpu) globalThis.__kaguraGfx?.registerStaticGeometry(gpu, vertices, indices);
  #| }

///|
fn retain_mesh(mesh : @mesh3d.Mesh3D) -> Unit {
  register_static_geometry(
    geometry_vertices(mesh.vertex_data),
    geometry_indices(mesh.indices),
  )
}

///|
fn next_uniforms(a : App) -> Array[Int] {
  let i = a.uniform_cursor
  a.uniform_cursor += 1
  if i == a.uniforms.length() {
    a.uniforms.push(Array::make(104, 0))
  }
  a.uniforms[i]
}

///|
// HEX colors are sRGB, while glTF baseColorFactor is already linear.
fn srgb_channel(value : Double) -> Double {
  if value <= 0.04045 {
    value / 12.92
  } else {
    @math.pow((value + 0.055) / 1.055, 2.4)
  }
}

///|
fn rgb(hex : Int) -> @math3d.Vec3 {
  let c = color(hex)
  @sim.vec(c.x, c.y, c.z)
}

///|
fn color(hex : Int, alpha? : Double = 1.0) -> @math3d.Vec4 {
  @math3d.Vec4::new(
    srgb_channel(((hex >> 16) & 255).to_double() / 255.0),
    srgb_channel(((hex >> 8) & 255).to_double() / 255.0),
    srgb_channel((hex & 255).to_double() / 255.0),
    alpha,
  )
}

///|
fn material(
  hex : Int,
  glow? : Bool = false,
  alpha? : Double = 1.0,
) -> @rig.Material {
  let c = color(hex, alpha~)
  {
    color: c,
    metallic: 0.15,
    roughness: 0.78,
    texture: -1,
    emissive: if glow {
      @sim.vec(c.x, c.y, c.z)
    } else {
      @sim.vec(0.0, 0.0, 0.0)
    },
    transparent: alpha < 1.0,
    unlit: glow,
  }
}

///|
fn trs(
  p : @math3d.Vec3,
  scale : @math3d.Vec3,
  rotation? : @math3d.Quaternion = @math3d.Quaternion::identity(),
) -> @math3d.Mat4 {
  @transform3d.Transform3D::from_components(p, rotation, scale).to_mat4()
}

///|
fn submit(
  a : App,
  ctx : @engine.EngineContext,
  commands : Array[@gfx.DrawTrianglesCommand],
  mesh : @mesh3d.Mesh3D,
  matrix : @math3d.Mat4,
  m : @rig.Material,
  vp : @math3d.Mat4,
  sky? : Bool = false,
  receive_shadow? : Bool = true,
  tonemapped? : Bool = false,
) -> Unit {
  retain_mesh(mesh)
  let region : @gfx.DstRegion = {
    x: 0,
    y: 0,
    width: ctx.screen_w,
    height: ctx.screen_h,
    index_count: mesh.indices.length(),
  }
  let textures = if m.texture >= 0 { [1000 + m.texture] } else { [0] }
  if !m.unlit {
    textures.push(2000)
    textures.push(901)
  }
  let shader = if sky {
    a.sky_shader
  } else if m.unlit {
    if m.texture >= 0 || tonemapped {
      a.textured_unlit
    } else {
      a.unlit
    }
  } else if m.texture >= 0 {
    a.textured
  } else {
    a.pbr
  }
  commands.push(
    @draw3d.new_pbr_mesh_draw_command(
      ctx.dst,
      shader,
      region,
      0,
      0,
      0,
      if m.transparent {
        Alpha
      } else {
        Copy
      },
      mesh,
      matrix,
      vp,
      a.lighting,
      m.metallic,
      m.roughness,
      m.color,
      if m.unlit {
        @sim.vec(m.color.x, m.color.y, m.color.z)
      } else {
        m.emissive
      },
      a.eye,
      textures,
      environment=Some(a.environment),
      shadow=Some(a.shadow),
      viewport_height=ctx.screen_h.to_double(),
      receive_shadow~,
      storage=Some(next_uniforms(a)),
    ),
  )
}

///|
fn beam(
  a : App,
  ctx : @engine.EngineContext,
  commands : Array[@gfx.DrawTrianglesCommand],
  start : @math3d.Vec3,
  end : @math3d.Vec3,
  width : Double,
  hex : Int,
  vp : @math3d.Mat4,
) -> Unit {
  let d = end.sub(start)
  let length = d.length()
  if length < 0.00001 {
    return
  }
  let yaw = @math.atan2(d.x, d.z)
  let pitch = -@math.atan2(d.y, (d.x * d.x + d.z * d.z).sqrt())
  let q = @math3d.Quaternion::from_axis_angle(@sim.vec(0.0, 1.0, 0.0), yaw).multiply(
    @math3d.Quaternion::from_axis_angle(@sim.vec(1.0, 0.0, 0.0), pitch),
  )
  submit(
    a,
    ctx,
    commands,
    a.cube,
    trs(start.lerp(end, 0.5), @sim.vec(width, width, length), rotation=q),
    material(hex, glow=true),
    vp,
  )
}

///|
fn draw(
  a : App,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  if a.editing && !a.edit_active {
    return []
  }
  a.uniform_cursor = 0
  let destination = ctx.dst
  let ctx = {
    ..ctx,
    dst: @gfx.new_image_handle(900, ctx.screen_w, ctx.screen_h),
  }
  a.aspect = ctx.screen_w.to_double() / ctx.screen_h.to_double()
  let vp = camera(a).view_projection_matrix()
  let commands = if a.edit_action {
    [
      @shadow3d.new_shadow_clear_command(
        @gfx.new_image_handle(901, 2048, 2048),
        a.shadow_clear,
      ),
    ]
  } else {
    shadows(a)
  }
  submit(
    a,
    ctx,
    commands,
    a.sky,
    trs(a.eye, @sim.vec(450.0, 450.0, 450.0)),
    material(
      if a.game.scene is Some(scene) {
        scene.sky
      } else {
        0xa4b3bd
      },
      glow=true,
    ),
    vp,
    sky=true,
  )
  draw_ground(a, ctx, commands, vp)
  if a.edit_action {
    draw_attack(a, ctx, commands, vp)
  } else {
    for part in a.scenery {
      submit(
        a,
        ctx,
        commands,
        part.mesh,
        part.model,
        part.material,
        vp,
        receive_shadow=part.receives_shadow,
        tonemapped=true,
      )
    }
    let enemies = a.game.units
      .filter(fn(e) { e.hp > 0.0 })
      .map(fn(e) { (e, enemy_matrix(e)) })
    for b in a.bastion.batches {
      if !b.material.transparent {
        for pair in enemies {
          submit(
            a,
            ctx,
            commands,
            b.mesh,
            pair.1,
            b.material,
            vp,
            tonemapped=true,
          )
        }
      }
    }
    for pair in enemies {
      let (e, root) = pair
      for b in a.bastion.batches {
        if b.material.transparent {
          submit(
            a,
            ctx,
            commands,
            b.mesh,
            root,
            b.material,
            vp,
            tonemapped=true,
          )
        }
      }
      if e.warning > 0.0 {
        beam(a, ctx, commands, @sim.enemy_muzzle(e), e.aim, 0.04, 0xff6644, vp)
      }
    }
    for transparent in [false, true] {
      for b in a.strix.batches {
        if b.material.transparent == transparent {
          submit(
            a,
            ctx,
            commands,
            b.mesh,
            a.animator.world[b.bone],
            b.material,
            vp,
            tonemapped=true,
          )
        }
      }
    }
    if a.game.attack_age < @sim.rifle_action(a.game).flashDuration {
      for i in 0..<a.strix.bones.length() {
        if a.strix.bones[i].name == "RightHand" {
          let point = @rig.transform_point(
            a.animator.world[i],
            @sim.vec(0.0, -0.08, 2.18),
          )
          submit(
            a,
            ctx,
            commands,
            a.sphere,
            trs(point, @sim.vec(0.22, 0.22, 0.22)),
            material(@sim.rifle_action(a.game).flashColor, glow=true),
            vp,
          )
        }
      }
    }
    if a.editing {
      draw_selection(a, ctx, commands, vp)
    }
  }
  for p in a.game.projectiles {
    let hex = if p.kind == 0 {
      0xfff1b3
    } else if p.kind == 1 {
      0xffb352
    } else {
      0xff523e
    }
    let end = p.position.add(
      p.velocity.normalize().scale(if p.kind == 1 { 0.8 } else { 1.4 }),
    )
    beam(
      a,
      ctx,
      commands,
      p.position,
      end,
      if p.kind == 1 {
        0.22
      } else {
        0.13
      },
      hex,
      vp,
    )
    if p.kind == 1 {
      for i in 1..<p.trail.length() {
        beam(a, ctx, commands, p.trail[i - 1], p.trail[i], 0.09, 0x94a8b0, vp)
      }
    }
  }
  for e in a.game.effects {
    let size = if e.kind == 2 { 1.0 + e.age * 6.0 } else { 0.15 + e.age * 2.5 }
    let alpha = @sim.max(
      0.0,
      1.0 - e.age / (if e.kind == 2 { 1.2 } else { 0.45 }),
    )
    submit(
      a,
      ctx,
      commands,
      a.sphere,
      trs(e.position, @sim.vec(size, size, size)),
      material(if e.kind == 2 { 0xff6633 } else { 0xffcf73 }, glow=true, alpha~),
      vp,
    )
  }
  commands.push(
    @postfx.new_fullscreen_quad_command(
      destination,
      a.present,
      [900],
      [
        Float::from_double(1.0).reinterpret_as_int(),
        Float::from_double(1.0).reinterpret_as_int(),
        0,
        0,
      ],
      Copy,
    ),
  )
  commands
}

///|
fn sky_mesh() -> @mesh3d.Mesh3D {
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let indices = cube.indices.copy()
  for i in 0..<(indices.length() / 3) {
    let n = i * 3
    let old = indices[n]
    indices[n] = indices[n + 2]
    indices[n + 2] = old
  }
  @mesh3d.Mesh3D::new(cube.vertex_data, indices)
}

///|
fn shadow_config() -> @shadow3d.ShadowConfig {
  @shadow3d.ShadowConfig::new(
    2048,
    65.0,
    0.5,
    180.0,
    (35.0 * 35.0 + 65.0 * 65.0 + 25.0 * 25.0).sqrt(),
    @sim.vec(0.0, 0.0, 0.0),
    0.0,
  )
}

///|
fn shadows(a : App) -> Array[@gfx.DrawTrianglesCommand] {
  let casters : Array[@shadow3d.ShadowCaster] = []
  for part in a.scenery {
    retain_mesh(part.mesh)
  }
  for b in a.strix.batches {
    retain_mesh(b.mesh)
  }
  for b in a.bastion.batches {
    retain_mesh(b.mesh)
  }
  for part in a.scenery {
    if part.casts_shadow {
      casters.push(@shadow3d.ShadowCaster::new(part.mesh, part.model))
    }
  }
  for b in a.strix.batches {
    if !b.material.transparent {
      casters.push(
        @shadow3d.ShadowCaster::new(b.mesh, a.animator.world[b.bone]),
      )
    }
  }
  let roots = a.game.units.filter(fn(e) { e.hp > 0.0 }).map(enemy_matrix)
  for b in a.bastion.batches {
    for root in roots {
      casters.push(@shadow3d.ShadowCaster::new(b.mesh, root))
    }
  }
  let commands = [
    @shadow3d.new_shadow_clear_command(
      @gfx.new_image_handle(901, 2048, 2048),
      a.shadow_clear,
    ),
  ]
  for
    command in @shadow3d.shadow_depth_pass_commands(
      @gfx.new_image_handle(901, 2048, 2048),
      a.depth_shader,
      casters,
      a.lighting,
      shadow_config(),
      cache_resources=false,
    ) {
    commands.push(command)
  }
  commands
}

///|
fn draw_ground(
  a : App,
  ctx : @engine.EngineContext,
  commands : Array[@gfx.DrawTrianglesCommand],
  vp : @math3d.Mat4,
) -> Unit {
  let stage = a.game.stage
  for
    part in [
      (@sim.vec(0.0, 0.0, 0.0), @sim.vec(650.0, 1.0, 650.0), 0x46555c),
      (
        @sim.vec(0.0, 0.008, (stage.min_z + stage.max_z) / 2.0),
        @sim.vec(stage.max_x - stage.min_x, 1.0, stage.max_z - stage.min_z),
        0x566269,
      ),
    ] {
    let (position, size, hex) = part
    submit(
      a,
      ctx,
      commands,
      a.plane,
      trs(position, size),
      { ..material(hex), metallic: 0.0, roughness: 0.95, },
      vp,
    )
  }
}

///|
fn pbr_environment() -> @draw3d.PbrEnvironment {
  {
    ground: rgb(0x465154).scale(1.3),
    intensity: 0.55,
    fog_color: rgb(0xa4b3bd),
    fog_near: 65.0,
    fog_far: 180.0,
  }
}

///|
fn pbr_shadow(lighting : @light3d.LightingEnvironment) -> @draw3d.PbrShadow {
  let c = shadow_config()
  {
    light_vp: @shadow3d.light_space_matrix(
      lighting.directional.direction,
      c.center,
      c.distance,
      c.half_extent,
      c.near,
      c.far,
    ),
    bias: c.bias,
    texel_size: 1.0 / c.map_size.to_double(),
  }
}

///|
fn enemy_matrix(e : @sim.Enemy) -> @math3d.Mat4 {
  trs(
    e.position.add(
      @sim.vec(0.0, @sim.min(1.0, e.velocity.length() / 2.4) * 0.18, 0.0),
    ),
    @sim.vec(1.0, 1.0, 1.0),
    rotation=@math3d.Quaternion::from_axis_angle(@sim.vec(0.0, 1.0, 0.0), e.yaw),
  )
}
