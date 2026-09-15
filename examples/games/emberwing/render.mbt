///|
priv struct Batch {
  mesh : @mesh3d.Mesh3D
  matrices : Array[@math3d.Mat4]
  colors : Array[@math3d.Vec4]
}

///|
fn batch(mesh : @mesh3d.Mesh3D) -> Batch {
  { mesh, matrices: [], colors: [], }
}

///|
fn Batch::push(
  self : Batch,
  matrix : @math3d.Mat4,
  hex? : Int = 0xffffff,
) -> Unit {
  self.matrices.push(matrix)
  self.colors.push(color(hex))
}

///|
fn Batch::put(
  self : Batch,
  p : @math3d.Vec3,
  scale : @math3d.Vec3,
  hex? : Int = 0xffffff,
  yaw? : Double = 0,
) -> Unit {
  self.push(transform(p, scale, yaw~), hex~)
}

///|
fn draw(
  a : App,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  a.aspect = ctx.screen_w.to_double() / ctx.screen_h.to_double()
  let camera = @sim.camera(a.aspect)
  let vp = camera.view_projection_matrix()
  let g = a.game
  let t = a.clock
  let commands = [
    @draw3d.new_sky_draw_command(
      ctx.dst,
      a.sky_shader,
      a.sky,
      vp,
      camera.position,
      {
        horizon: rgb(0xdde7c7),
        zenith: rgb(0x4087a3),
        ground: rgb(0x679e9b),
        sun_direction: @sim.vec(-0.5, 0.24, -0.82),
        sun_color: rgb(0xffe6ab),
        cloud_color: rgb(0xf8e9cd),
        cloud_cover: 0.27,
      },
    ),
  ]
  let sea = batch(a.plane)
  sea.put(@sim.vec(0, -17, -140), @sim.vec(750, 1, 650), hex=0x478e90)
  let stones = batch(a.island)
  for i = 0; i < 18; i = i + 1 {
    let n = i.to_double()
    let side = if i % 2 == 0 { -1.0 } else { 1.0 }
    let z = (n * 29 + t * 9) % 300 - 270
    let scale = 0.85 + (i % 4).to_double() * 0.36
    stones.put(
      @sim.vec(
        side * (25 + @math.sin(n * 7.3) * 10),
        -12 + @math.sin(n * 2.7) * 3,
        z,
      ),
      @sim.vec(scale, scale, scale),
      yaw=n * 1.7,
    )
  }
  let clouds = batch(a.glow)
  let foam = batch(a.glow)
  for i = 0; i < 60; i = i + 1 {
    let n = i.to_double()
    let x = @math.sin(n * 24.13) * 160
    let z = (n * 19 + t * 9) % 330 - 300
    if i < 24 {
      clouds.put(
        @sim.vec(x, 26 + @math.sin(n * 4.2) * 9, z - 90),
        @sim.vec(10 + (i % 3).to_double() * 4, 2.7, 5),
        hex=0xe6ecda,
      )
    }
    foam.put(
      @sim.vec(@math.cos(n * 37.1) * 100, -16.94, z),
      @sim.vec(1.4, 0.025, 0.08),
      hex=0xb7cec1,
    )
  }
  foam.put(@sim.vec(-66, 30, -210), @sim.vec(7, 7, 2), hex=0xffe5a8)
  let duck = [batch(a.duck[0]), batch(a.duck[1]), batch(a.duck[2])]
  for enemy in g.enemies {
    let p = enemy.position.add(
      @sim.vec(0, @math.sin(t * 4 + enemy.phase) * 0.15, 0),
    )
    let scale = if enemy.elite { 1.4 } else { 1.0 }
    let root = transform(
      p,
      @sim.vec(scale, scale, scale),
      yaw=@math.sin(t + enemy.phase) * 0.12,
    )
    let tint = if enemy.flash > 0 {
      0xffbe75
    } else if enemy.elite {
      0xffd9bc
    } else {
      0xffffff
    }
    duck[0].push(root, hex=tint)
    for i = 0; i < 2; i = i + 1 {
      let side = if i == 0 { -1.0 } else { 1.0 }
      duck[i + 1].push(
        root
        .multiply(@math3d.Mat4::translation(side * 0.5015, 0.9945, -0.1275))
        .multiply(
          @math3d.Mat4::rotation_z(side * @math.sin(t * 9 + enemy.phase) * 0.65),
        ),
        hex=tint,
      )
    }
  }
  let dishes = batch(a.bowl)
  let fire = batch(a.glow)
  for bowl in g.bowls {
    let scale = 1.6 + @math.exp(-bowl.age * 6) * 0.65
    dishes.push(
      transform(
        bowl.position,
        @sim.vec(scale, scale, scale),
        yaw=bowl.age * 0.8,
      ).multiply(
        @math3d.Mat4::rotation_x(0.32 + @math.sin(bowl.age * 2) * 0.12),
      ),
    )
    for k = 0; k < 3; k = k + 1 {
      let age = (bowl.age + k.to_double() * 0.3) % 1.1
      let size = 0.1 + age * 0.19
      fire.put(
        bowl.position.add(
          @sim.vec(
            @math.sin(bowl.age * 4 + k.to_double()) * 0.3,
            0.7 + age * 1.8,
            0,
          ),
        ),
        @sim.vec(size, size * 1.5, size),
        hex=0xf7edca,
      )
    }
    if bowl.age < 0.3 {
      for k = 0; k < 8; k = k + 1 {
        let angle = k.to_double() * @math.PI / 4
        fire.put(
          bowl.position.add(
            @sim.vec(
              @math.cos(angle) * bowl.age * 8,
              @math.sin(angle) * bowl.age * 8,
              0,
            ),
          ),
          @sim.vec(0.12, 0.12, 0.12),
          hex=0xffdc7e,
        )
      }
    }
  }
  for ball in g.balls {
    fire.put(ball.position, @sim.vec(0.28, 0.28, 0.45), hex=0xfff2b5)
    for i = 0; i < ball.trail.length(); i = i + 2 {
      let size = 0.07 + i.to_double() * 0.023
      fire.put(
        ball.trail[i],
        @sim.vec(size, size, size * 1.2),
        hex=if i < 4 { 0xe87546 } else { 0xffb34b },
      )
    }
  }
  for shot in g.shots {
    fire.put(shot.position, @sim.vec(0.35, 0.35, 0.35), hex=0xe95782)
    fire.put(
      shot.position.add(@sim.vec(0, 0, 0.2)),
      @sim.vec(0.15, 0.15, 0.15),
      hex=0xffe5c3,
    )
  }
  if g.breathing {
    let origin = @sim.mouth(g)
    let direction = g.aim.sub(origin).normalize()
    for i = 0; i < 65; i = i + 1 {
      let d = i.to_double() * 0.85
      let radius = 0.16 + d * 0.013
      let p = origin
        .add(direction.scale(d))
        .add(
          @sim.vec(
            @math.sin(d * 3 - t * 31) * radius * 0.5,
            @math.cos(d * 2 + t * 27) * radius * 0.5,
            0,
          ),
        )
      fire.put(
        p,
        @sim.vec(radius, radius, 0.7),
        hex=if i % 3 == 0 { 0xffedaf } else { 0xff973d },
      )
    }
  }
  let body = batch(a.dragon)
  let wing = [batch(a.wings[0]), batch(a.wings[1])]
  let position = g.player.add(@sim.vec(0, @math.sin(t * 4) * 0.12, 0))
  let root = transform(position, @sim.vec(1, 1, 1)).multiply(
    @math3d.Mat4::rotation_z(-a.input.aim_x * 0.16),
  )
  let tint = if g.hit_timer > 0 && (t * 12).to_int() % 2 == 0 {
    0xff9c80
  } else {
    0xffffff
  }
  body.push(root, hex=tint)
  for i = 0; i < 2; i = i + 1 {
    let side = if i == 0 { -1.0 } else { 1.0 }
    wing[i].push(
      root
      .multiply(@math3d.Mat4::translation(side * 0.5, 0.4, -0.3))
      .multiply(
        @math3d.Mat4::rotation_z(side * (0.15 + @math.sin(t * 4) * 0.28)),
      ),
      hex=tint,
    )
  }
  a.triangles = a.sky.indices.length() / 3
  for
    b in [
      sea,
      stones,
      clouds,
      foam,
      duck[0],
      duck[1],
      duck[2],
      dishes,
      body,
      wing[0],
      wing[1],
      fire,
    ] {
    // Uniform-array instancing: at most 256 instances per GPU draw.
    for start = 0; start < b.matrices.length(); start = start + 256 {
      let count = @sim.clamp((b.matrices.length() - start).to_double(), 0, 256).to_int()
      let matrices = Array::makei(count, i => b.matrices[start + i])
      let colors = Array::makei(count, i => b.colors[start + i])
      commands.push(
        @draw3d.new_instanced_lit_mesh_draw_command(
          ctx.dst,
          a.shader,
          @gfx.new_dst_region(
            0,
            0,
            ctx.screen_w,
            ctx.screen_h,
            b.mesh.indices.length(),
          ),
          @gfx.BlendMode::from_int(0),
          b.mesh,
          vp,
          a.lighting,
          matrices,
          colors,
        ),
      )
      a.triangles += b.mesh.indices.length() / 3 * count
    }
  }
  a.draws = commands.length()
  publish(hud(a, vp))
  commands
}
