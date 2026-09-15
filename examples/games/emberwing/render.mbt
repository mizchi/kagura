///|
priv struct Batch {
  instances : @draw3d.InstancedMeshBatch
}

///|
fn batch(mesh : @mesh3d.Mesh3D) -> Batch {
  { instances: @draw3d.InstancedMeshBatch::new(mesh), }
}

///|
fn Batch::push(
  self : Batch,
  matrix : @math3d.Mat4,
  hex? : Int = 0xffffff,
) -> Unit {
  self.instances.push(matrix, color=color(hex))
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
  let crowns = batch(a.crown)
  let fire = batch(a.glow)
  let rocks = batch(a.rock)
  for enemy in g.enemies {
    let p = enemy.position.add(
      @sim.vec(0, @math.sin(t * 4 + enemy.phase) * 0.15, 0),
    )
    let scale = if enemy.boss { 5.5 } else if enemy.elite { 1.4 } else { 1.0 }
    let root = transform(
      p,
      @sim.vec(scale, scale, scale),
      yaw=if enemy.boss { 0.0 } else { @math.sin(t + enemy.phase) * 0.12 },
    )
    let tint = if enemy.flash > 0 {
      0xffbe75
    } else if enemy.boss && enemy.hp < @sim.boss_max_hp() * 0.5 {
      0xffbdb7
    } else if enemy.elite {
      0xffd9bc
    } else {
      0xffffff
    }
    duck[0].push(root, hex=tint)
    if enemy.boss {
      crowns.push(
        root
        .multiply(@math3d.Mat4::translation(0, 2.58, 0.45))
        .multiply(@math3d.Mat4::scaling(0.55, 0.55, 0.55)),
      )
    } else if enemy.shot_clock > 0 &&
      enemy.shot_clock < 0.6 &&
      (if g.wave >= 4 { enemy.id % 2 == 0 } else { enemy.id % 3 == 0 }) {
      let size = (0.6 - enemy.shot_clock) * 0.55 + 0.07
      fire.put(
        @sim.enemy_center(enemy).add(@sim.vec(0, 0, 0.7)),
        @sim.vec(size, size, size),
        hex=0xffa9ce,
      )
    }
    for i = 0; i < 2; i = i + 1 {
      let side = if i == 0 { -1.0 } else { 1.0 }
      duck[i + 1].push(
        root
        .multiply(@math3d.Mat4::translation(side * 0.5015, 0.9945, -0.1275))
        .multiply(
          @math3d.Mat4::rotation_z(
            side *
            @math.sin(t * (if enemy.boss { 3.5 } else { 9.0 }) + enemy.phase) *
            0.65,
          ),
        ),
        hex=tint,
      )
    }
  }
  let dishes = batch(a.bowl)
  for bowl in g.bowls {
    let scale = (1.6 + @math.exp(-bowl.age * 6) * 0.65) * bowl.scale
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
    let direction = shot.velocity.normalize()
    fire.segment(
      shot.position.sub(direction.scale(0.65)),
      shot.position.add(direction.scale(0.25)),
      0.26,
      0xe54c9a,
    )
    fire.put(
      shot.position.add(direction.scale(0.25)),
      @sim.vec(0.14, 0.14, 0.14),
      hex=0xfff3e3,
    )
  }
  for rock in g.rocks {
    rocks.push(
      transform(
        rock.position,
        @sim.vec(rock.radius, rock.radius, rock.radius),
        yaw=rock.phase + t * 1.8,
      ).multiply(@math3d.Mat4::rotation_x(t * 1.3)),
    )
    let direction = rock.velocity.normalize()
    for i = 1; i < 5; i = i + 1 {
      let size = rock.radius * (0.22 - i.to_double() * 0.025)
      fire.put(
        rock.position.sub(direction.scale(i.to_double() * 0.7)),
        @sim.vec(size, size, size),
        hex=if i < 3 { 0xd6a880 } else { 0x999289 },
      )
    }
  }
  for beam in g.beams {
    if beam.age < beam.path.delay {
      let charge = beam.path.charge_progress(beam.age)
      for i = 0; i < 20; i = i + 1 {
        let start = beam.path.origin.lerp(beam.path.aim, i.to_double() / 20)
        let end = beam.path.origin.lerp(
          beam.path.aim,
          (i.to_double() + 0.48) / 20,
        )
        fire.segment(start, end, 0.035 + charge * 0.035, 0xdf69bd)
      }
      fire.put(
        beam.path.origin,
        @sim.vec(
          0.25 + charge * 0.65,
          0.25 + charge * 0.65,
          0.25 + charge * 0.65,
        ),
        hex=0xffa7eb,
      )
    } else if beam.path.segment_at(beam.age) is Some(segment) {
      fire.segment(segment.start, segment.end, beam.radius, 0xe669ec)
      fire.segment(segment.start, segment.end, beam.radius * 0.4, 0xfff4ff)
    }
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
      rocks,
      crowns,
      body,
      wing[0],
      wing[1],
      fire,
    ] {
    b.instances.append_draw_commands(
      ctx.dst,
      a.shader,
      ctx.screen_w,
      ctx.screen_h,
      vp,
      a.lighting,
      commands,
    )
    a.triangles += b.instances.triangle_count()
  }
  a.draws = commands.length()
  publish(hud(a, vp))
  commands
}

///|
fn Batch::segment(
  self : Batch,
  start : @math3d.Vec3,
  end : @math3d.Vec3,
  radius : Double,
  hex : Int,
) -> Unit {
  ignore(self.instances.push_segment(start, end, radius, color=color(hex)))
}
