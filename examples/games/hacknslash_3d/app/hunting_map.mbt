///|
fn build_hunting_chunks(
  dungeon : @game.DungeonData,
  seed : Int,
  region? : Int = -1,
) -> Array[DungeonChunk] {
  let chunks : Array[DungeonChunk] = []
  for cz in 0..<((dungeon.grid.height + chunk_size - 1) / chunk_size) {
    for cx in 0..<((dungeon.grid.width + chunk_size - 1) / chunk_size) {
      chunks.push(build_hunting_chunk(dungeon, seed, cx, cz, region~))
    }
  }
  chunks
}

///|
fn build_hunting_chunk(
  dungeon : @game.DungeonData,
  seed : Int,
  cx : Int,
  cz : Int,
  region? : Int = -1,
) -> DungeonChunk {
  let w = dungeon.grid.width
  let h = dungeon.grid.height
  let palette = world_region_palette(region)
  let accum = Array::makei(hunting_palette.length(), fn(_) {
    @procedural3d.RigidGeometry::new()
  })
  for z in (cz * chunk_size)..<@cmp.minimum(h, (cz + 1) * chunk_size) {
    for x in (cx * chunk_size)..<@cmp.minimum(w, (cx + 1) * chunk_size) {
      if region >= 0 &&
        (
          (x == 0 && @game.region_neighbor(region, -1, 0) is Some(_)) ||
          (x == w - 1 && @game.region_neighbor(region, 1, 0) is Some(_)) ||
          (z == 0 && @game.region_neighbor(region, 0, -1) is Some(_)) ||
          (z == h - 1 && @game.region_neighbor(region, 0, 1) is Some(_))
        ) {
        continue
      }
      let hash = @game.hunting_hash(x, z, seed)
      let tile = dungeon.grid.get(x, z)
      let px = x.to_double()
      let pz = z.to_double()
      let material = if tile == @terrain.Corridor {
        2
      } else if hash % 7 < 2 {
        1
      } else {
        0
      }
      // Coplanar ground facets; small stones and grass are visibly step-over detail.
      fn ground_corner(gx : Int, gz : Int) -> @math3d.Vec3 {
        if gx <= 1 || gx >= w - 1 || gz <= 1 || gz >= h - 1 {
          return @math3d.Vec3::new(gx.to_double(), 0.0, gz.to_double())
        }
        let jitter = @game.hunting_hash(gx, gz, seed)
        @math3d.Vec3::new(
          gx.to_double() + (jitter % 23).to_double() / 50.0 - 0.22,
          0.0,
          gz.to_double() + (jitter / 23 % 23).to_double() / 50.0 - 0.22,
        )
      }
      accum[material].quad(
        ground_corner(x, z),
        ground_corner(x, z + 1),
        ground_corner(x + 1, z + 1),
        ground_corner(x + 1, z),
        0,
      )
      if tile == @terrain.Wall {
        let border = x < 2 || z < 2 || x >= w - 2 || z >= h - 2
        let kind = if @game.hunting_landmark(x, z) {
          3
        } else if border {
          2
        } else if region == 1 {
          1 + hash % 2
        } else if region == 3 && hash % 4 == 0 {
          3
        } else {
          hash % 3
        }
        hunting_ground_shadow(
          accum[12],
          px + 0.64,
          pz + 0.75,
          if kind < 2 {
            0.67
          } else {
            0.56
          },
          if kind < 2 {
            1.0
          } else {
            0.61
          },
        )
        for part in hunting_assets[kind].parts {
          let mesh = if kind == 3 {
            part.mesh
          } else {
            hunting_asset_variant(part.mesh, hash)
          }
          merge_mesh_at(
            accum[part.material].vertices,
            accum[part.material].indices,
            mesh,
            px + 0.5,
            0.0,
            pz + 0.5,
          )
        }
      } else if tile != @terrain.Corridor && hash % 4 == 0 {
        hunting_grass(accum[10], px + 0.5, pz + 0.5, hash)
      } else if tile == @terrain.Corridor && hash % 9 == 0 {
        accum[6].loft(
          px + 0.5,
          pz + 0.5,
          [(0.0, 0.16, 0.2), (0.07, 0.12, 0.16), (0.1, 0.02, 0.03)],
          5,
          0,
        )
      }
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  let all_v : Array[Double] = []
  let all_i : Array[Int] = []
  for i in 0..<accum.length() {
    let mesh = @mesh3d.Mesh3D::new(accum[i].vertices, accum[i].indices)
    groups.push({
      mesh,
      color: palette[i],
      surface_kind: Floor,
      dst_region: @gfx.new_dst_region(
        0,
        0,
        screen_w,
        screen_h,
        mesh.indices.length(),
      ),
    })
    merge_mesh_at(all_v, all_i, mesh, 0.0, 0.0, 0.0)
  }
  {
    cx,
    cz,
    groups,
    wall_mesh: @mesh3d.Mesh3D::new([], []),
    all_mesh: @mesh3d.Mesh3D::new(all_v, all_i),
  }
}

///|
fn build_visible_hunting_mesh_cache(
  chunks : Array[DungeonChunk],
) -> VisibleDungeonMeshCache {
  let palette = if chunks.is_empty() {
    hunting_palette
  } else {
    chunks[0].groups.map(group => group.color)
  }
  let accum = Array::makei(hunting_palette.length(), fn(_) {
    new_mesh_accumulator()
  })
  let all = new_mesh_accumulator()
  for chunk in chunks {
    for i in 0..<chunk.groups.length() {
      let mesh = chunk.groups[i].mesh
      merge_mesh_at(accum[i].vertices, accum[i].indices, mesh, 0.0, 0.0, 0.0)
    }
    merge_mesh_at(all.vertices, all.indices, chunk.all_mesh, 0.0, 0.0, 0.0)
  }
  let groups : Array[DungeonMeshGroup] = []
  for i in 0..<accum.length() {
    if accum[i].indices.is_empty() {
      continue
    }
    groups.push({
      mesh: @mesh3d.Mesh3D::new(accum[i].vertices, accum[i].indices),
      color: palette[i],
      surface_kind: Floor,
      dst_region: @gfx.new_dst_region(
        0,
        0,
        screen_w,
        screen_h,
        accum[i].indices.length(),
      ),
    })
  }
  { groups, all_mesh: @mesh3d.Mesh3D::new(all.vertices, all.indices), }
}

///|
fn GameState::push_hunting_ground_commands(
  self : GameState,
  groups : Array[DungeonMeshGroup],
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  for group in groups {
    cmds.push(
      @draw3d.new_lit_colored_mesh_draw_command(
        dst,
        self.shader3d_colored,
        group.dst_region,
        0,
        0,
        0,
        @gfx.BlendMode::from_int(0),
        group.mesh,
        @math3d.Mat4::identity(),
        vp,
        self.lighting,
        group.color,
        [],
      ),
    )
  }
  let player = self.world.player
  cmds.push(
    @draw3d.new_lit_colored_mesh_draw_command(
      dst,
      self.shader3d_colored,
      @gfx.new_dst_region(
        0,
        0,
        screen_w,
        screen_h,
        hunter_contact_shadow.indices.length(),
      ),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(0),
      hunter_contact_shadow,
      @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(player.x / tile_size, 0.002, player.y / tile_size),
      ).to_mat4(),
      vp,
      self.lighting,
      hunting_palette[12],
      [],
    ),
  )
}

///|
let hunter_contact_shadow : @mesh3d.Mesh3D = {
  let g = @procedural3d.RigidGeometry::new()
  hunting_ground_shadow(g, 0.0, 0.0, 0.31, 0.23)
  @mesh3d.Mesh3D::new(g.vertices, g.indices)
}
