///|
fn rgb(hex : Int) -> @math3d.Vec3 {
  @sim.vec(
    ((hex >> 16) & 255).to_double() / 255,
    ((hex >> 8) & 255).to_double() / 255,
    (hex & 255).to_double() / 255,
  )
}

///|
fn color(hex : Int) -> @math3d.Vec4 {
  @math3d.Vec4::from_vec3(rgb(hex), 1)
}

///|
fn transform(
  p : @math3d.Vec3,
  scale : @math3d.Vec3,
  yaw? : Double = 0,
) -> @math3d.Mat4 {
  @math3d.Mat4::translation(p.x, p.y, p.z)
  .multiply(@math3d.Mat4::rotation_y(yaw))
  .multiply(@math3d.Mat4::scaling(scale.x, scale.y, scale.z))
}

///|
priv struct Builder {
  vertices : Array[Double]
  indices : Array[Int]
}

///|
fn builder() -> Builder {
  { vertices: [], indices: [], }
}

///|
fn Builder::triangle(
  self : Builder,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  c : @math3d.Vec3,
  hex : Int,
  glow? : Double = 0,
) -> Unit {
  let n = b.sub(a).cross(c.sub(a)).normalize()
  let index = self.vertices.length() / 8
  for p in [a, b, c] {
    @mesh3d.push_vertex(
      self.vertices,
      p.x,
      p.y,
      p.z,
      n.x,
      n.y,
      n.z,
      hex.to_double(),
      glow,
    )
  }
  self.indices.push(index)
  self.indices.push(index + 1)
  self.indices.push(index + 2)
}

///|
fn Builder::add(
  self : Builder,
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  hex : Int,
  glow? : Double = 0,
) -> Unit {
  fn point(i : Int) -> @math3d.Vec3 {
    let v = mesh.vertex_data
    let p = model.mul_vec4(
      @math3d.Vec4::new(v[i * 8], v[i * 8 + 1], v[i * 8 + 2], 1),
    )
    @sim.vec(p.x, p.y, p.z)
  }
  for i = 0; i < mesh.indices.length(); i = i + 3 {
    self.triangle(
      point(mesh.indices[i]),
      point(mesh.indices[i + 1]),
      point(mesh.indices[i + 2]),
      hex,
      glow~,
    )
  }
}

///|
fn Builder::ellipsoid(
  self : Builder,
  p : @math3d.Vec3,
  scale : @math3d.Vec3,
  hex : Int,
) -> Unit {
  self.add(@mesh3d.Mesh3D::sphere(1, 8, 5), transform(p, scale), hex)
}

///|
fn Builder::box(
  self : Builder,
  p : @math3d.Vec3,
  scale : @math3d.Vec3,
  hex : Int,
  yaw? : Double = 0,
) -> Unit {
  self.add(@mesh3d.Mesh3D::cube(1), transform(p, scale, yaw~), hex)
}

///|
fn Builder::cone(
  self : Builder,
  base : @math3d.Vec3,
  tip : @math3d.Vec3,
  radius : Double,
  hex : Int,
) -> Unit {
  for i = 0; i < 8; i = i + 1 {
    let a = i.to_double() * @math.PI / 4
    let b = (i + 1).to_double() * @math.PI / 4
    let p = base.add(@sim.vec(@math.cos(a) * radius, 0, @math.sin(a) * radius))
    let q = base.add(@sim.vec(@math.cos(b) * radius, 0, @math.sin(b) * radius))
    self.triangle(p, tip, q, hex)
    self.triangle(base, p, q, hex)
  }
}

///|
fn Builder::bone(
  self : Builder,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  radius : Double,
  hex : Int,
) -> Unit {
  let axis = b.sub(a).normalize()
  let u = axis.cross(@sim.vec(0, 1, 0)).normalize().scale(radius)
  let v = axis.cross(u).normalize().scale(radius)
  for i = 0; i < 6; i = i + 1 {
    let t = i.to_double() * @math.PI / 3
    let s = (i + 1).to_double() * @math.PI / 3
    let p = u.scale(@math.cos(t)).add(v.scale(@math.sin(t)))
    let q = u.scale(@math.cos(s)).add(v.scale(@math.sin(s)))
    self.triangle(a.add(p), b.add(p), a.add(q), hex)
    self.triangle(a.add(q), b.add(p), b.add(q), hex)
  }
}

///|
fn Builder::finish(self : Builder) -> @mesh3d.Mesh3D {
  let m = @mesh3d.Mesh3D::new(self.vertices, self.indices)
  @hooks.register_static_geometry(m.vertex_data, m.indices)
  m
}

///|
fn dragon_body() -> @mesh3d.Mesh3D {
  let b = builder()
  b.ellipsoid(@sim.vec(0, 0, 0), @sim.vec(0.7, 0.65, 1.8), 0x267b76)
  b.ellipsoid(@sim.vec(0, -0.22, -0.4), @sim.vec(0.56, 0.55, 1.3), 0xe8b864)
  b.ellipsoid(@sim.vec(0, 0.4, -1.7), @sim.vec(0.44, 0.62, 0.78), 0x398f83)
  b.ellipsoid(@sim.vec(0, 0.73, -2.3), @sim.vec(0.62, 0.52, 0.77), 0x499e8f)
  b.ellipsoid(@sim.vec(0, 0.5, -2.95), @sim.vec(0.48, 0.28, 0.52), 0x246b68)
  b.ellipsoid(@sim.vec(0, 0.3, -2.97), @sim.vec(0.42, 0.12, 0.49), 0xd9b675)
  for side in [-1.0, 1.0] {
    b.ellipsoid(
      @sim.vec(side * 0.53, 0.85, -2.47),
      @sim.vec(0.14, 0.16, 0.22),
      0xffdd70,
    )
    b.ellipsoid(
      @sim.vec(side * 0.62, 0.87, -2.53),
      @sim.vec(0.045, 0.11, 0.085),
      0x153f40,
    )
    b.cone(
      @sim.vec(side * 0.43, 1.02, -1.98),
      @sim.vec(side * 0.67, 1.95, -1.45),
      0.19,
      0xf5d99a,
    )
    b.ellipsoid(
      @sim.vec(side * 0.66, -0.5, 0.6),
      @sim.vec(0.31, 0.48, 0.6),
      0x205e61,
    )
    b.ellipsoid(
      @sim.vec(side * 0.66, -0.77, 1.01),
      @sim.vec(0.23, 0.2, 0.52),
      0x4b9c89,
    )
    for k = 0; k < 3; k = k + 1 {
      b.cone(
        @sim.vec(side * 0.66 + (k - 1).to_double() * 0.13, -0.87, 1.28),
        @sim.vec(side * 0.66 + (k - 1).to_double() * 0.13, -0.94, 1.61),
        0.07,
        0xf2d395,
      )
    }
  }
  for i = 0; i < 6; i = i + 1 {
    let z = i.to_double() * 0.6 - 1
    b.cone(
      @sim.vec(0, 0.55, z),
      @sim.vec(0, 1.1 - i.to_double() * 0.07, z + 0.3),
      0.19,
      0xe9ac62,
    )
  }
  for i = 0; i < 7; i = i + 1 {
    let t = i.to_double()
    b.ellipsoid(
      @sim.vec(@math.sin(t * 0.42) * 0.4, -0.06 - t * 0.08, 1.3 + t * 0.43),
      @sim.vec(0.33 - t * 0.038, 0.3 - t * 0.032, 0.49),
      0x2c7b75,
    )
  }
  b.finish()
}

///|
fn dragon_wing(side : Double) -> @mesh3d.Mesh3D {
  let b = builder()
  let root = @sim.vec(0, 0, 0)
  let elbow = @sim.vec(side * 1.65, 0.23, -1.1)
  let tip = @sim.vec(side * 4.7, 0.12, -1.55)
  let edge = [
    tip,
    @sim.vec(side * 3.65, -0.12, 0.18),
    @sim.vec(side * 3.1, 0, 1.58),
    @sim.vec(side * 1.62, -0.1, 0.83),
    @sim.vec(side * 0.72, 0, 1.35),
    root,
  ]
  for i = 0; i < edge.length() - 1; i = i + 1 {
    let hex = if i % 2 == 0 { 0xb65d48 } else { 0xd48050 }
    b.triangle(elbow, edge[i], edge[i + 1], hex)
    b.triangle(elbow, edge[i + 1], edge[i], hex)
  }
  b.triangle(root, elbow, tip, 0xe3a163)
  b.triangle(root, tip, elbow, 0xe3a163)
  // The leading edge and fingers give the membrane a readable silhouette.
  for target in [root, tip, edge[2], edge[4]] {
    b.bone(elbow, target, 0.075, 0xe9bd78)
  }
  b.cone(elbow, @sim.vec(side * 1.9, 0.8, -1.35), 0.12, 0xffe2a0)
  b.finish()
}

///|
fn bowl_mesh() -> @mesh3d.Mesh3D {
  let b = builder()
  // Open bowl: sloping red exterior, porcelain lip and visible broth.
  for i = 0; i < 16; i = i + 1 {
    let a = i.to_double() * @math.PI / 8
    let c = (i + 1).to_double() * @math.PI / 8
    let p = @sim.vec(@math.cos(a) * 0.85, 0.35, @math.sin(a) * 0.85)
    let q = @sim.vec(@math.cos(c) * 0.85, 0.35, @math.sin(c) * 0.85)
    let r = @sim.vec(@math.cos(a) * 0.4, -0.3, @math.sin(a) * 0.4)
    let s = @sim.vec(@math.cos(c) * 0.4, -0.3, @math.sin(c) * 0.4)
    b.triangle(p, r, q, 0xbc433e)
    b.triangle(q, r, s, 0xa83234)
    b.triangle(@sim.vec(0, 0.27, 0), q.scale(0.91), p.scale(0.91), 0x77402b)
    b.ellipsoid(p, @sim.vec(0.16, 0.075, 0.16), 0xffecc2)
  }
  b.ellipsoid(@sim.vec(0, -0.32, 0), @sim.vec(0.42, 0.1, 0.42), 0xf6d9aa)
  for i = 0; i < 7; i = i + 1 {
    let x = (i - 3).to_double() * 0.13
    b.box(
      @sim.vec(x, 0.34, -0.03 + @math.sin(i.to_double()) * 0.13),
      @sim.vec(0.06, 0.055, 0.87),
      0xdabd79,
      yaw=0.15,
    )
  }
  for i = 0; i < 3; i = i + 1 {
    b.ellipsoid(
      @sim.vec(-0.36 + i.to_double() * 0.34, 0.39, -0.28),
      @sim.vec(0.2, 0.08, 0.14),
      0xe7a787,
    )
    b.box(
      @sim.vec(-0.24 + i.to_double() * 0.23, 0.41, 0.28),
      @sim.vec(0.13, 0.13, 0.35),
      0x86ab58,
      yaw=-0.6,
    )
  }
  b.finish()
}

///|
fn island_mesh() -> @mesh3d.Mesh3D {
  let b = builder()
  b.ellipsoid(@sim.vec(0, -3, 0), @sim.vec(8, 7, 6), 0x455c67)
  b.ellipsoid(@sim.vec(0, 0, 0), @sim.vec(8.3, 2, 6.2), 0x64947c)
  b.ellipsoid(@sim.vec(-1, 1, 0), @sim.vec(6, 1, 4.8), 0x92ad79)
  for side in [-1.0, 1.0] {
    b.box(@sim.vec(side * 2.4, 3.3, 0), @sim.vec(1.4, 5.3, 1.4), 0xc9bba2)
    b.box(@sim.vec(side * 2.4, 1.3, 0), @sim.vec(2, 0.6, 2), 0xe7d0a3)
    b.box(@sim.vec(side * 2.4, 6, 0), @sim.vec(1.9, 0.7, 1.9), 0xe7d0a3)
  }
  b.box(@sim.vec(0, 6.6, 0), @sim.vec(6.8, 0.8, 1.6), 0xb3ab99)
  for i = 0; i < 4; i = i + 1 {
    let x = (i - 2).to_double() * 2.1
    b.cone(
      @sim.vec(x, 1, -2),
      @sim.vec(x + 0.3, 5 + i.to_double() * 0.4, -2),
      0.6,
      0x285f62,
    )
  }
  b.finish()
}

///|
fn palette_mesh(
  base : @mesh3d.Mesh3D,
  hex : Int,
  glow? : Double = 0,
) -> @mesh3d.Mesh3D {
  let b = builder()
  b.add(base, @math3d.Mat4::identity(), hex, glow~)
  b.finish()
}

///|
fn kawaiiko_meshes() -> Array[@mesh3d.Mesh3D] {
  let parts : Array[Array[Double]] = @json.from_json(
    @json.parse(kawaiiko_source),
  ) catch {
    _ => panic()
  }
  parts.map(fn(v) {
    let mesh = @mesh3d.Mesh3D::new(v, Array::makei(v.length() / 8, fn(i) { i }))
    @hooks.register_static_geometry(mesh.vertex_data, mesh.indices)
    mesh
  })
}
