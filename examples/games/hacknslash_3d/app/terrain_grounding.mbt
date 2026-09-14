///|
fn drape_hunting_vertices(
  g : @procedural3d.RigidGeometry,
  start : Int,
  dungeon : @game.DungeonData,
) -> Unit {
  guard dungeon.terrain_surface is Some(surface) else { return }
  for i = start; i < g.vertices.length(); i = i + 8 {
    g.vertices[i + 1] += surface.sample(g.vertices[i], g.vertices[i + 2])
  }
}

///|
fn hunting_surface_shadow(
  g : @procedural3d.RigidGeometry,
  x : Double,
  z : Double,
  rx : Double,
  rz : Double,
  dungeon : @game.DungeonData,
) -> Unit {
  if dungeon.terrain_surface is Some(surface) {
    let mesh = terrain_shadow_mesh(surface, x, z, rx, rz)
    for i = 0; i < mesh.indices.length(); i = i + 3 {
      fn point(j : Int) -> @math3d.Vec3 {
        let k = mesh.indices[j] * 8
        @math3d.Vec3::new(
          mesh.vertex_data[k],
          mesh.vertex_data[k + 1],
          mesh.vertex_data[k + 2],
        )
      }
      g.triangle(point(i), point(i + 1), point(i + 2), 0)
    }
  } else {
    hunting_ground_shadow(g, x, z, rx, rz)
  }
}

///|
fn hunting_surface_grass(
  g : @procedural3d.RigidGeometry,
  x : Double,
  z : Double,
  hash : Int,
  dungeon : @game.DungeonData,
) -> Unit {
  let start = g.vertices.length()
  hunting_grass(g, x, z, hash)
  drape_hunting_vertices(g, start, dungeon)
  tag_scenery_geometry(g, start, 3.0)
}

///|
fn terrain_shadow_mesh(
  surface : @terrain3d.HeightField,
  x : Double,
  z : Double,
  rx : Double,
  rz : Double,
) -> @mesh3d.Mesh3D {
  surface.project_polygon(
    Array::makei(12, i => {
      let angle = i.to_double() * @math.PI * 2.0 / 12.0
      (x + @math.cos(angle) * rx, z + @math.sin(angle) * rz)
    }),
  )
}

///|
// Only transient surface effects are deformed per frame. Terrain and decoration
// geometry stay cached in the existing region/chunk meshes.
fn surface_effect_mesh(
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  dungeon : @game.DungeonData,
) -> @mesh3d.Mesh3D {
  let vertices = mesh.vertex_data.copy()
  for i = 0; i < vertices.length(); i = i + 8 {
    let point = model.mul_vec4(
      @math3d.Vec4::new(vertices[i], vertices[i + 1], vertices[i + 2], 1.0),
    )
    let normal = model.mul_vec4(
      @math3d.Vec4::new(vertices[i + 3], vertices[i + 4], vertices[i + 5], 0.0),
    )
    vertices[i] = point.x
    vertices[i + 1] = point.y +
      @game.get_tile_height(dungeon, point.x * tile_size, point.z * tile_size)
    vertices[i + 2] = point.z
    let length = (normal.x * normal.x +
      normal.y * normal.y +
      normal.z * normal.z)
      .sqrt()
      .max(0.0001)
    vertices[i + 3] = normal.x / length
    vertices[i + 4] = normal.y / length
    vertices[i + 5] = normal.z / length
  }
  @mesh3d.Mesh3D::new(vertices, mesh.indices)
}

///|
fn GameState::push_surface_combat_mesh(
  self : GameState,
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  color : @math3d.Vec4,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  self.push_combat_mesh(
    mesh,
    model,
    color,
    vp,
    dst,
    cmds,
    terrain_relative=true,
  )
}

///|
// Bend only roots / the bottom of rocks into the slope; trunks remain upright.
// Placement is baked once with the rest of a static chunk.
fn hunting_grounded_asset(
  mesh : @mesh3d.Mesh3D,
  dungeon : @game.DungeonData,
  x : Double,
  z : Double,
) -> @mesh3d.Mesh3D {
  guard dungeon.terrain_surface is Some(surface) else { return mesh }
  let base = surface.sample(x, z)
  let vertices = mesh.vertex_data.copy()
  for i = 0; i < vertices.length(); i = i + 8 {
    let weight = (1.0 - vertices[i + 1] / 0.6).clamp(min=0.0, max=1.0)
    if weight > 0.0 {
      vertices[i + 1] += (
          surface.sample(x + vertices[i], z + vertices[i + 2]) - base
        ) *
        weight
    }
  }
  @mesh3d.Mesh3D::new(vertices, mesh.indices)
}
