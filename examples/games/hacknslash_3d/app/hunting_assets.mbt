// Reusable, original low-poly woodland assets. Geometry stays local to its origin;
// the map decides placement and collision independently of these material batches.

///|
struct HuntingAssetPart {
  mesh : @mesh3d.Mesh3D
  material : Int
}

///|
struct HuntingAsset {
  name : String
  parts : Array[HuntingAssetPart]
}

///|
fn hunting_asset_variant(mesh : @mesh3d.Mesh3D, hash : Int) -> @mesh3d.Mesh3D {
  let angle = (hash % 4).to_double() * @math.PI / 2.0
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  let height = 0.8 + (hash % 9).to_double() * 0.04
  let data = mesh.vertex_data.copy()
  for i in 0..<(data.length() / 8) {
    let offset = i * 8
    let x = data[offset]
    let z = data[offset + 2]
    data[offset] = c * x - s * z
    data[offset + 1] *= height
    data[offset + 2] = s * x + c * z
    let normal = @math3d.Vec3::new(
      c * data[offset + 3] - s * data[offset + 5],
      data[offset + 4] / height,
      s * data[offset + 3] + c * data[offset + 5],
    ).normalize()
    data[offset + 3] = normal.x
    data[offset + 4] = normal.y
    data[offset + 5] = normal.z
  }
  @mesh3d.Mesh3D::new(data, mesh.indices)
}

///|
let hunting_palette : Array[@math3d.Vec4] = [
  hex_to_vec4(0x1B2C21),
  hex_to_vec4(0x1D3022),
  hex_to_vec4(0x403B2C),
  hex_to_vec4(0x403228),
  hex_to_vec4(0x1A3A31),
  hex_to_vec4(0x355F49),
  hex_to_vec4(0x58615C),
  hex_to_vec4(0x4C6040),
  @math3d.Vec4::new(2.3, 1.05, 0.26, 1.0),
  hex_to_vec4(0x9D957C),
  hex_to_vec4(0x4F6844),
  hex_to_vec4(0x28464A),
  hex_to_vec4(0x14271B),
]

///|
fn hunting_ground_shadow(
  g : @procedural3d.RigidGeometry,
  x : Double,
  z : Double,
  rx : Double,
  rz : Double,
) -> Unit {
  for side in 0..<12 {
    fn p(index : Int) -> @math3d.Vec3 {
      let angle = index.to_double() * @math.PI * 2.0 / 12.0
      @math3d.Vec3::new(
        x + @math.cos(angle) * rx,
        0.008,
        z + @math.sin(angle) * rz,
      )
    }
    g.triangle(@math3d.Vec3::new(x, 0.008, z), p(side + 1), p(side), 0)
  }
}

///|
fn hunting_part(
  g : @procedural3d.RigidGeometry,
  material : Int,
) -> HuntingAssetPart {
  { mesh: @mesh3d.Mesh3D::new(g.vertices, g.indices), material, }
}

///|
fn make_hunting_pine() -> HuntingAsset {
  let bark = @procedural3d.RigidGeometry::new()
  bark.loft(
    0.0,
    0.0,
    [
      (0.0, 0.46, 0.46),
      (0.15, 0.27, 0.28),
      (1.8, 0.12, 0.12),
      (2.7, 0.04, 0.04),
    ],
    7,
    0,
  )
  let lower = @procedural3d.RigidGeometry::new()
  lower.loft(
    0.0,
    0.0,
    [(0.9, 0.18, 0.18), (1.02, 0.9, 0.82), (2.08, 0.05, 0.05)],
    7,
    0,
  )
  lower.loft(
    0.04,
    0.02,
    [(1.55, 0.17, 0.17), (1.6, 0.72, 0.67), (2.62, 0.01, 0.01)],
    7,
    0,
  )
  let upper = @procedural3d.RigidGeometry::new()
  upper.loft(
    -0.02,
    0.0,
    [(2.08, 0.08, 0.08), (2.12, 0.45, 0.42), (3.12, 0.005, 0.005)],
    7,
    0,
  )
  {
    name: "ashwood-pine",
    parts: [
      hunting_part(bark, 3),
      hunting_part(lower, 4),
      hunting_part(upper, 5),
    ],
  }
}

///|
fn hunting_branch(
  g : @procedural3d.RigidGeometry,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  radius : Double,
) -> Unit {
  let axis = b.sub(a).normalize()
  let right = axis.cross(@math3d.Vec3::unit_z()).normalize().scale(radius)
  let front = axis.cross(right).normalize().scale(radius)
  for side in 0..<5 {
    fn ring(
      center : @math3d.Vec3,
      index : Int,
      scale : Double,
    ) -> @math3d.Vec3 {
      let angle = index.to_double() * @math.PI * 2.0 / 5.0
      center
      .add(right.scale(@math.cos(angle) * scale))
      .add(front.scale(@math.sin(angle) * scale))
    }
    g.quad(
      ring(a, side, 1.0),
      ring(a, side + 1, 1.0),
      ring(b, side + 1, 0.24),
      ring(b, side, 0.24),
      0,
    )
  }
}

///|
fn make_hunting_deadwood() -> HuntingAsset {
  let g = @procedural3d.RigidGeometry::new()
  g.loft(
    0.0,
    0.0,
    [
      (0.0, 0.47, 0.44),
      (0.2, 0.22, 0.23),
      (1.2, 0.18, 0.14),
      (2.7, 0.045, 0.035),
    ],
    6,
    0,
  )
  hunting_branch(
    g,
    @math3d.Vec3::new(0.0, 1.3, 0.0),
    @math3d.Vec3::new(-0.72, 2.0, 0.18),
    0.12,
  )
  hunting_branch(
    g,
    @math3d.Vec3::new(-0.72, 2.0, 0.18),
    @math3d.Vec3::new(-0.82, 2.5, 0.24),
    0.055,
  )
  hunting_branch(
    g,
    @math3d.Vec3::new(0.0, 1.65, 0.0),
    @math3d.Vec3::new(0.62, 2.25, -0.24),
    0.09,
  )
  hunting_branch(
    g,
    @math3d.Vec3::new(0.0, 2.2, 0.0),
    @math3d.Vec3::new(-0.26, 2.9, -0.28),
    0.06,
  )
  { name: "split-deadwood", parts: [hunting_part(g, 3)], }
}

///|
fn make_hunting_boulder() -> HuntingAsset {
  let rock = @procedural3d.RigidGeometry::new()
  rock.loft(
    0.0,
    0.0,
    [
      (0.0, 0.49, 0.49),
      (0.22, 0.47, 0.43),
      (0.72, 0.31, 0.35),
      (0.87, 0.12, 0.21),
    ],
    7,
    0,
  )
  let moss = @procedural3d.RigidGeometry::new()
  moss.loft(
    -0.05,
    0.01,
    [(0.7, 0.28, 0.31), (0.82, 0.25, 0.27), (0.9, 0.09, 0.17)],
    7,
    0,
  )
  { name: "moss-shale", parts: [hunting_part(rock, 6), hunting_part(moss, 7)], }
}

///|
fn make_hunting_shrine() -> HuntingAsset {
  let stone = @procedural3d.RigidGeometry::new()
  stone.box(0.0, 0.13, 0.0, 0.98, 0.26, 0.98, 0)
  stone.loft(
    0.0,
    0.0,
    [(0.26, 0.38, 0.38), (0.4, 0.27, 0.27), (1.1, 0.23, 0.23), (1.25, 0.4, 0.4)],
    6,
    0,
  )
  let iron = @procedural3d.RigidGeometry::new()
  for x in [-0.37, 0.37] {
    iron.box(x, 1.7, 0.0, 0.1, 2.7, 0.12, 0)
  }
  iron.loft(
    0.0,
    0.0,
    [(3.0, 0.58, 0.32), (3.14, 0.46, 0.24), (3.45, 0.0, 0.0)],
    4,
    0,
  )
  // Suspended votive bell above the fire bowl.
  iron.loft(
    0.0,
    0.0,
    [(2.33, 0.25, 0.25), (2.45, 0.21, 0.21), (2.7, 0.11, 0.11)],
    7,
    0,
  )
  let flame = @procedural3d.RigidGeometry::new()
  flame.loft(
    0.0,
    0.0,
    [(1.25, 0.2, 0.2), (1.5, 0.23, 0.18), (1.93, 0.01, 0.01)],
    5,
    0,
  )
  {
    name: "pilgrim-bell-and-votive",
    parts: [
      hunting_part(stone, 6),
      hunting_part(iron, 9),
      hunting_part(flame, 8),
    ],
  }
}

///|
let hunting_assets : Array[HuntingAsset] = [
  make_hunting_pine(),
  make_hunting_deadwood(),
  make_hunting_boulder(),
  make_hunting_shrine(),
]

///|
fn hunting_grass(
  g : @procedural3d.RigidGeometry,
  x : Double,
  z : Double,
  seed : Int,
) -> Unit {
  let h = 0.13 + (seed % 5).to_double() * 0.03
  for d in [-0.12, 0.0, 0.12] {
    g.triangle(
      @math3d.Vec3::new(x + d - 0.025, 0.005, z),
      @math3d.Vec3::new(x + d + 0.025, 0.005, z),
      @math3d.Vec3::new(x + d + 0.04, h, z + 0.04),
      0,
    )
    g.triangle(
      @math3d.Vec3::new(x, 0.005, z + d - 0.025),
      @math3d.Vec3::new(x, 0.005, z + d + 0.025),
      @math3d.Vec3::new(x + 0.04, h, z + d + 0.04),
      0,
    )
  }
}
