///|
priv struct SceneryPart {
  mesh : @mesh3d.Mesh3D
  model : @math3d.Mat4
  material : @rig.Material
  receives_shadow : Bool
  casts_shadow : Bool
}

///|
// Decorative geometry from modeling-playground/game/Stage.tsx. Collision boxes
// remain in sim.Stage; draw and shadow passes share these exact cached parts.
fn scenery(stage : @sim.Stage) -> Array[SceneryPart] {
  let parts : Array[SceneryPart] = []
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let pipe = cylinder_mesh()
  let box = fn(p, size, hex, casts_shadow) {
    parts.push({
      mesh: cube,
      model: trs(p, size),
      material: material(hex),
      receives_shadow: true,
      casts_shadow,
    })
  }
  for s in stage.solids {
    let w = s.size.x
    let h = s.size.y
    let d = s.size.z
    let at = fn(x, y, z) { s.center.add(@sim.vec(x, y, z)) }
    box(s.center, s.size, s.color, true)
    if s.id.has_prefix("hangar-") {
      box(
        at(0.0, h / 2.0 + 0.22, 0.0),
        @sim.vec(w + 0.8, 0.44, d + 0.8),
        0x35434a,
        true,
      )
      box(
        at(0.0, -h * 0.15, d / 2.0 + 0.035),
        @sim.vec(w * 0.55, h * 0.60, 0.07),
        0x293a43,
        true,
      )
      for i in 0..<7 {
        box(
          at(0.0, -h * 0.43 + i.to_double() * h * 0.09, d / 2.0 + 0.09),
          @sim.vec(w * 0.56, 0.055, 0.06),
          0x617077,
          true,
        )
      }
      for side in [-1.0, 1.0] {
        box(
          at(side * w * 0.30, -h * 0.15, d / 2.0 + 0.15),
          @sim.vec(0.3, h * 0.64, 0.3),
          0xd1a54d,
          true,
        )
        parts.push({
          mesh: pipe,
          model: trs(
            at(side * w * 0.35, h / 2.0 + 0.55, 0.0),
            @sim.vec(0.4, 0.4, d * 0.9),
          ),
          material: { ..material(0x9ca8ac), metallic: 0.6, roughness: 0.55 },
          receives_shadow: false,
          casts_shadow: true,
        })
      }
      box(
        at(0.0, h * 0.22, d / 2.0 + 0.16),
        @sim.vec(w * 0.7, 0.16, 0.2),
        0xcfb773,
        true,
      )
    } else if s.id.has_prefix("container-") {
      for i in 0..<12 {
        box(
          at(0.0, 0.0, -d / 2.0 + 0.3 + i.to_double() * (d - 0.6) / 11.0),
          @sim.vec(w + 0.12, h + 0.08, 0.09),
          s.color,
          true,
        )
      }
      box(
        at(0.0, h / 2.0 + 0.02, 0.0),
        @sim.vec(w + 0.1, 0.12, d + 0.15),
        0x303d41,
        true,
      )
      box(at(0.0, 0.0, d / 2.0 + 0.08), @sim.vec(0.06, h, 0.09), 0xc2b695, true)
    } else if s.id == "central-cover" {
      for i in 0..<8 {
        box(
          at(
            -w / 2.0 + 0.6 + i.to_double() * (w - 1.2) / 7.0,
            h * 0.24,
            -d / 2.0 - 0.04,
          ),
          @sim.vec(0.65, 0.55, 0.08),
          if i % 2 == 0 {
            0xd4ae58
          } else {
            0x252e32
          },
          true,
        )
      }
    } else if s.id.has_prefix("cooling-") {
      box(
        at(0.0, h / 2.0 + 0.3, 0.0),
        @sim.vec(w + 1.0, 0.6, d + 1.0),
        0x31454c,
        true,
      )
      for i in 0..<4 {
        box(
          at(0.0, -h * 0.3 + i.to_double() * h * 0.18, d / 2.0 + 0.07),
          @sim.vec(w * 0.75, 0.65, 0.15),
          0x34464e,
          true,
        )
      }
      parts.push({
        mesh: @mesh3d.Mesh3D::sphere(0.22, 8, 8),
        model: trs(at(0.0, h / 2.0 + 0.8, 0.0), @sim.vec(1.0, 1.0, 1.0)),
        material: material(0xee7849, glow=true),
        receives_shadow: false,
        casts_shadow: false,
      })
    } else {
      box(
        at(0.0, h / 2.0 + 0.15, 0.0),
        @sim.vec(w + 0.2, 0.3, d + 0.2),
        0x35494f,
        true,
      )
    }
  }
  let width = stage.max_x - stage.min_x
  let depth = stage.max_z - stage.min_z
  let center = (stage.min_z + stage.max_z) / 2.0
  for i in 0..<11 {
    box(
      @sim.vec(stage.min_x + i.to_double() * width / 10.0, 0.015, center),
      @sim.vec(0.055, 0.015, depth),
      0x435158,
      true,
    )
    box(
      @sim.vec(0.0, 0.015, stage.min_z + i.to_double() * depth / 10.0),
      @sim.vec(width, 0.015, 0.055),
      0x435158,
      true,
    )
  }
  for x in [-6.5, 6.5] {
    for i in 0..<20 {
      box(
        @sim.vec(x, 0.025, -46.0 + i.to_double() * 5.0),
        @sim.vec(0.13, 0.025, 2.2),
        0xbfa064,
        true,
      )
    }
  }
  parts.push({
    mesh: ring_mesh(),
    model: trs(
      @sim.vec(stage.spawn.x, 0.04, stage.spawn.z),
      @sim.vec(1.0, 1.0, 1.0),
    ),
    material: { ..material(0xd5b570), metallic: 0.0, roughness: 1.0 },
    receives_shadow: false,
    casts_shadow: false,
  })
  box(@sim.vec(0.0, 0.035, -42.0), @sim.vec(10.0, 0.035, 0.18), 0xd5b570, true)
  for i in 0..<10 {
    box(
      @sim.vec(
        -100.0 + i.to_double() * 22.0,
        18.0 + (i % 3).to_double() * 8.0,
        95.0 + (i % 2).to_double() * 15.0,
      ),
      @sim.vec(12.0, 36.0 + (i % 3).to_double() * 16.0, 16.0),
      0x73858e,
      true,
    )
  }
  for side in [-1.0, 1.0] {
    for z in [-32.0, 12.0, 42.0] {
      box(
        @sim.vec(side * 43.0, 4.0, z),
        @sim.vec(0.18, 8.0, 0.18),
        0x283940,
        true,
      )
      box(
        @sim.vec(side * 42.1, 8.0, z),
        @sim.vec(2.0, 0.13, 0.4),
        0xaabdc2,
        true,
      )
      parts.push({
        mesh: cube,
        model: trs(@sim.vec(side * 41.5, 7.9, z), @sim.vec(0.7, 0.06, 0.25)),
        material: material(0xc6f2f5, glow=true),
        receives_shadow: false,
        casts_shadow: false,
      })
    }
  }
  parts
}

///|
// Unit radius, unit length, Z-axis pipe, with side normals and closed caps.
fn cylinder_mesh() -> @mesh3d.Mesh3D {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  let push = fn(x, y, z, nx, ny, nz) {
    for v in [x, y, z, nx, ny, nz, 0.0, 0.0] {
      vertices.push(v)
    }
  }
  for i in 0..<12 {
    let a = i.to_double() * @math.PI / 6.0
    let b = (i + 1).to_double() * @math.PI / 6.0
    let x = @math.cos(a)
    let y = @math.sin(a)
    let xx = @math.cos(b)
    let yy = @math.sin(b)
    let base = vertices.length() / 8
    push(x, y, -0.5, x, y, 0.0)
    push(xx, yy, -0.5, xx, yy, 0.0)
    push(xx, yy, 0.5, xx, yy, 0.0)
    push(x, y, 0.5, x, y, 0.0)
    for n in [0, 1, 2, 0, 2, 3] {
      indices.push(base + n)
    }
    for z in [-0.5, 0.5] {
      let start = vertices.length() / 8
      push(0.0, 0.0, z, 0.0, 0.0, z * 2.0)
      push(x, y, z, 0.0, 0.0, z * 2.0)
      push(xx, yy, z, 0.0, 0.0, z * 2.0)
      for n in (if z > 0.0 { [0, 1, 2] } else { [0, 2, 1] }) {
        indices.push(start + n)
      }
    }
  }
  @mesh3d.Mesh3D::new(vertices, indices)
}

///|
// Three RingGeometry(5.4, 5.58, 64), rotated -PI/2 around X.
fn ring_mesh() -> @mesh3d.Mesh3D {
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  for radius in [5.4, 5.58] {
    for i in 0..<65 {
      let angle = i.to_double() * 2.0 * @math.PI / 64.0
      let x = radius * @math.cos(angle)
      let z = -radius * @math.sin(angle)
      for
        v in [
          x,
          0.0,
          z,
          0.0,
          1.0,
          0.0,
          (x / 5.58 + 1.0) / 2.0,
          (-z / 5.58 + 1.0) / 2.0,
        ] {
        vertices.push(v)
      }
    }
  }
  for i in 0..<64 {
    for n in [i, i + 65, i + 1, i + 65, i + 66, i + 1] {
      indices.push(n)
    }
  }
  @mesh3d.Mesh3D::new(vertices, indices)
}
