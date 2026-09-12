// Original hunter design. Ring lofts and named rigid parts follow the vocabulary
// of mizchi/modeling-playground/modeling/{lowpoly,primitives}.ts (aa7ab3e).
// No traveler geometry, facial features, textures or runtime dependencies.

///|
struct HunterPart {
  name : String
  mesh : @mesh3d.Mesh3D
  skin : @skeleton3d.SkinData
  packed : Array[Double]
  color : @math3d.Vec4
}

///|
fn finish_hunter_part(
  geometry : @procedural3d.RigidGeometry,
  name : String,
  color : Int,
) -> HunterPart {
  let mesh = geometry.build_mesh()
  let skin = geometry.build_skin()
  {
    name,
    mesh,
    skin,
    packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
    color: hex_to_vec4(color),
  }
}

///|
fn build_hunter_parts() -> Array[HunterPart] {
  let coat = @procedural3d.RigidGeometry::new()
  let leather = @procedural3d.RigidGeometry::new()
  let hat = @procedural3d.RigidGeometry::new()
  let trim = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  let shadow = @procedural3d.RigidGeometry::new()
  let steel = @procedural3d.RigidGeometry::new()
  // Short tailored torso and separately animated split coat tails.
  coat.loft(
    0.0,
    0.0,
    [
      (0.35, 0.19, 0.13),
      (0.48, 0.17, 0.115),
      (0.64, 0.25, 0.15),
      (0.70, 0.16, 0.12),
    ],
    8,
    1,
  )
  for side in [-1.0, 1.0] {
    let tail = if side < 0.0 { 12 } else { 13 }
    coat.loft(
      side * 0.13,
      -0.13,
      [(0.13, 0.145, 0.075), (0.27, 0.13, 0.085), (0.47, 0.10, 0.045)],
      5,
      tail,
    )
    cloth.box(side * 0.13, 0.20, -0.21, 0.20, 0.12, 0.012, tail)
    let arm = if side < 0.0 { 6 } else { 2 }
    let forearm = if side < 0.0 { 7 } else { 3 }
    coat.loft(
      side * 0.25,
      0.0,
      [(0.46, 0.07, 0.075), (0.62, 0.115, 0.11), (0.68, 0.085, 0.08)],
      6,
      arm,
    )
    leather.loft(
      side * 0.30,
      0.035,
      [(0.30, 0.065, 0.065), (0.40, 0.08, 0.075), (0.48, 0.075, 0.07)],
      6,
      forearm,
    )
    trim.box(side * 0.30, 0.405, 0.11, 0.10, 0.025, 0.025, forearm)
    let thigh = if side < 0.0 { 8 } else { 10 }
    let shin = if side < 0.0 { 9 } else { 11 }
    shadow.loft(
      side * 0.115,
      0.0,
      [(0.18, 0.073, 0.07), (0.39, 0.088, 0.085)],
      6,
      thigh,
    )
    leather.loft(
      side * 0.115,
      0.0,
      [(0.06, 0.095, 0.09), (0.23, 0.08, 0.075)],
      6,
      shin,
    )
    leather.box(side * 0.115, 0.055, 0.045, 0.19, 0.11, 0.29, shin)
    trim.box(side * 0.115, 0.15, 0.085, 0.095, 0.024, 0.02, shin)
  }
  // Wrapped face in the shadow of the brim. No modeled eyes, nose or mouth.
  shadow.loft(
    0.0,
    0.0,
    [
      (0.70, 0.17, 0.16),
      (0.83, 0.25, 0.21),
      (1.12, 0.28, 0.235),
      (1.25, 0.22, 0.19),
    ],
    10,
    5,
  )
  cloth.loft(
    0.0,
    0.025,
    [
      (0.70, 0.185, 0.17),
      (0.82, 0.265, 0.225),
      (0.94, 0.27, 0.245),
      (0.99, 0.235, 0.22),
    ],
    10,
    5,
  )
  coat.loft(
    0.0,
    -0.035,
    [(0.64, 0.19, 0.15), (0.81, 0.27, 0.19), (0.86, 0.26, 0.17)],
    8,
    1,
  )
  // Oversized tricorn: lobed brim with raised corners, thick edge and low crown.
  fn brim(i : Int, inner : Bool, underside : Bool) -> @math3d.Vec3 {
    let a = i.to_double() / 24.0 * @math.PI * 2.0
    let lobe = @math.cos(a * 3.0)
    let r = if inner { 0.245 } else { 0.54 + lobe * 0.13 }
    let y = if inner { 1.19 } else { 1.14 + @cmp.maximum(0.0, lobe) * 0.15 }
    @math3d.Vec3::new(
      @math.sin(a) * r,
      y - (if underside { 0.035 } else { 0.0 }),
      @math.cos(a) * r,
    )
  }
  for i in 0..<24 {
    hat.quad(
      brim(i, true, false),
      brim(i, false, false),
      brim(i + 1, false, false),
      brim(i + 1, true, false),
      5,
    )
    hat.quad(
      brim(i + 1, true, true),
      brim(i + 1, false, true),
      brim(i, false, true),
      brim(i, true, true),
      5,
    )
    trim.quad(
      brim(i, false, false),
      brim(i, false, true),
      brim(i + 1, false, true),
      brim(i + 1, false, false),
      5,
    )
  }
  hat.loft(
    0.0,
    0.0,
    [(1.17, 0.29, 0.25), (1.29, 0.27, 0.225), (1.40, 0.18, 0.15)],
    10,
    5,
  )
  leather.loft(0.0, 0.0, [(1.19, 0.294, 0.254), (1.24, 0.285, 0.246)], 10, 5)
  trim.box(0.0, 1.22, 0.255, 0.085, 0.06, 0.018, 5)
  // Chest straps, brass buckle and pale cravat read even from the gameplay camera.
  leather.box(0.0, 0.44, 0.135, 0.37, 0.055, 0.035, 1)
  trim.box(0.0, 0.44, 0.16, 0.075, 0.07, 0.02, 1)
  cloth.box(0.0, 0.63, 0.16, 0.08, 0.14, 0.026, 1)
  for y in [0.52, 0.58] {
    trim.box(0.10, y, 0.15, 0.026, 0.026, 0.02, 1)
  }
  // Right-hand cleaver: long steel silhouette, six saw teeth, bound handle.
  leather.box(0.33, 0.34, 0.15, 0.065, 0.075, 0.29, 4)
  trim.box(0.33, 0.34, 0.27, 0.19, 0.07, 0.04, 4)
  steel.loft(
    0.33,
    0.61,
    [(0.31, 0.085, 0.33), (0.36, 0.095, 0.33), (0.39, 0.065, 0.28)],
    4,
    4,
  )
  for i in 0..<6 {
    let z = 0.35 + i.to_double() * 0.10
    steel.triangle(
      @math3d.Vec3::new(0.25, 0.35, z),
      @math3d.Vec3::new(0.18, 0.35, z + 0.07),
      @math3d.Vec3::new(0.25, 0.35, z + 0.08),
      4,
    )
    steel.triangle(
      @math3d.Vec3::new(0.25, 0.35, z + 0.08),
      @math3d.Vec3::new(0.18, 0.35, z + 0.07),
      @math3d.Vec3::new(0.25, 0.35, z),
      4,
    )
  }
  // Off-hand flintlock, slightly oversized muzzle.
  leather.box(-0.32, 0.32, 0.13, 0.075, 0.14, 0.12, 7)
  steel.box(-0.32, 0.39, 0.26, 0.10, 0.085, 0.30, 7)
  trim.box(-0.32, 0.39, 0.40, 0.13, 0.105, 0.04, 7)
  return [
    finish_hunter_part(coat, "coat", 0x35414A),
    finish_hunter_part(leather, "leather", 0x443735),
    finish_hunter_part(hat, "hat", 0x3A414A),
    finish_hunter_part(trim, "brass", 0xB29462),
    finish_hunter_part(cloth, "cloth", 0x9B8170),
    finish_hunter_part(shadow, "shadow", 0x171C23),
    finish_hunter_part(steel, "weapon", 0xAFBCC2),
  ]
}

///|
fn combine_hunter_parts(
  parts : Array[HunterPart],
) -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let data = @procedural3d.RigidGeometry::new()
  for part in parts {
    let base = data.vertices.length() / 8
    data.vertices.append(part.mesh.vertex_data)
    for index in part.mesh.indices {
      data.indices.push(base + index)
    }
    data.joints.append(part.skin.joint_indices)
    data.weights.append(part.skin.weights)
  }
  let skin : @skeleton3d.SkinData = {
    joint_indices: data.joints,
    weights: data.weights,
    vertex_count: data.vertices.length() / 8,
  }
  (@mesh3d.Mesh3D::new(data.vertices, data.indices), skin)
}
