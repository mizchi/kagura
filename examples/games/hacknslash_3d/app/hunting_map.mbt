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
  let props = (if dungeon.landscape is Some(_) {
    @game.landscape_props(seed)
  } else {
    @game.hunting_site_props(seed)
  }).filter(p => @game.hunting_prop_present(p, dungeon.grid))
  let occupied : Map[Int, Bool] = Map([])
  for prop in props {
    for z in prop.z..<(prop.z + prop.depth) {
      for x in prop.x..<(prop.x + prop.width) {
        occupied[z * dungeon.grid.width + x] = true
      }
    }
  }
  for chest in @game.hunting_chests() {
    occupied[(chest.y / tile_size).to_int() * dungeon.grid.width +
    (chest.x / tile_size).to_int()] = true
  }
  let w = dungeon.grid.width
  let h = dungeon.grid.height
  let palette = world_region_palette(region)
  let landscape = dungeon.landscape
  let accum = Array::makei(hunting_palette.length(), fn(_) {
    @procedural3d.RigidGeometry::new()
  })
  let grass : Array[(Int, Int, Int)] = []
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
      let hash = (@terrain3d.coordinate_random(x, z, seed + 277) * 1000000.0).to_int()
      let tile = dungeon.grid.get(x, z)
      let px = x.to_double()
      let pz = z.to_double()
      let mut site_material = -1
      for site in @game.hunting_sites {
        let dx = (x - site.x).to_double()
        let dz = (z - site.z).to_double()
        if site.kind == @game.Ruins && dx.abs() <= 5.0 && dz.abs() <= 4.0 {
          site_material = 13
        } else if site.kind == @game.Encampment &&
          dx * dx / 49.0 + dz * dz / 36.0 < 1.0 {
          site_material = 14
        }
      }
      let rocky = match dungeon.terrain_surface {
        Some(field) => field.at(x, z) > 5.0 && field.cell_slope(x, z) > 0.3
        None => false
      }
      let nature = landscape.map(l => l.kind(x, z)).or(@game.Land)
      let material = if nature == @game.CaveFloor {
        22
      } else if landscape is Some(_) &&
        (nature == @game.Sea || nature == @game.River) {
        21
      } else if nature == @game.Mountain {
        6
      } else if site_material >= 0 {
        14
      } else if tile == @terrain.Corridor {
        2
      } else if rocky {
        6
      } else if hash % 7 < 2 {
        1
      } else {
        0
      }
      // Surface triangles share their diagonal with HeightField.sample/raycast.
      fn ground_corner(gx : Int, gz : Int) -> @math3d.Vec3 {
        if landscape is Some(land) {
          return @math3d.Vec3::new(
            gx.to_double(),
            land.bed.at(gx, gz),
            gz.to_double(),
          )
        }
        if dungeon.terrain_surface is Some(surface) {
          return @math3d.Vec3::new(
            gx.to_double(),
            surface.at(gx, gz),
            gz.to_double(),
          )
        }
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
      if landscape is Some(land) {
        if land.bed
          .at(x, z)
          .min(land.bed.at(x + 1, z))
          .min(land.bed.at(x, z + 1))
          .min(land.bed.at(x + 1, z + 1)) <
          -1.35 {
          accum[19].quad(
            @math3d.Vec3::new(px, -1.35, pz),
            @math3d.Vec3::new(px, -1.35, pz + 1.0),
            @math3d.Vec3::new(px + 1.0, -1.35, pz + 1.0),
            @math3d.Vec3::new(px + 1.0, -1.35, pz),
            0,
          )
          if hash % 13 == 0 && land.bed.sample(px + 0.5, pz + 0.5) < -2.0 {
            accum[20].quad(
              @math3d.Vec3::new(px + 0.2, -1.345, pz + 0.3),
              @math3d.Vec3::new(px + 0.24, -1.345, pz + 0.35),
              @math3d.Vec3::new(px + 0.8, -1.345, pz + 0.6),
              @math3d.Vec3::new(px + 0.76, -1.345, pz + 0.55),
              0,
            )
          }
        }
        if nature != @game.Land {
          continue
        }
        if x >= 14 && x <= 17 && z >= 54 && z <= 57 {
          continue
        }
      }
      if site_material == 13 && hash % 8 != 0 {
        let paving = accum[if hash % 3 == 0 { 6 } else { 13 }]
        let start = paving.vertices.length()
        hunting_broken_paving(
          accum[if hash % 3 == 0 { 6 } else { 13 }],
          px,
          pz,
          hash,
        )
        drape_hunting_vertices(paving, start, dungeon)
      }
      if occupied.contains(z * w + x) {
        continue
      }
      if tile == @terrain.Wall {
        let border = x < 2 || z < 2 || x >= w - 2 || z >= h - 2
        let vegetation_region = if region >= 0 {
          biome_species(
            px + @game.world_regions[region].x.to_double() * 98.0,
            pz + @game.world_regions[region].z.to_double() * 78.0,
            hash / 31,
          )
        } else {
          0
        }
        let kind = if @game.hunting_landmark(x, z) {
          3
        } else if border {
          2
        } else {
          woodland_asset_kind(vegetation_region, hash)
        }
        let tree_x = px +
          0.5 +
          (@terrain3d.coordinate_random(x, z, seed + 13) - 0.5) * 0.12
        let tree_z = pz +
          0.5 +
          (@terrain3d.coordinate_random(x, z, seed + 29) - 0.5) * 0.12
        hunting_surface_shadow(
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
          dungeon,
        )
        for part in hunting_assets[kind].parts {
          let start = accum[part.material].vertices.length()
          let mesh = if kind == 3 {
            part.mesh
          } else {
            hunting_asset_variant(part.mesh, hash)
          }
          merge_mesh_at(
            accum[part.material].vertices,
            accum[part.material].indices,
            hunting_grounded_asset(mesh, dungeon, tree_x, tree_z),
            tree_x,
            @game.get_tile_height(
              dungeon,
              tree_x * tile_size,
              tree_z * tile_size,
            ),
            tree_z,
          )
          tag_scenery_geometry(accum[part.material], start, 2.0)
        }
      } else if site_material < 0 &&
        woodland_grass_allowed(dungeon, x, z) &&
        @terrain3d.coordinate_random(x, z, seed + 71) <
        0.08 + @game.woodland_density(px, pz, seed + 41) * 0.40 {
        grass.push((x, z, hash))
      } else if tile == @terrain.Corridor && hash % 9 == 0 {
        let start = accum[6].vertices.length()
        accum[6].loft(
          px + 0.5,
          pz + 0.5,
          [(0.0, 0.16, 0.2), (0.07, 0.12, 0.16), (0.1, 0.02, 0.03)],
          5,
          0,
        )
        drape_hunting_vertices(accum[6], start, dungeon)
      }
    }
  }
  // Select by priority, not row order, so the budget does not create a straight edge.
  grass.sort_by((a, b) => a.2.compare(b.2))
  for i in 0..<grass.length().min(80) {
    let (x, z, hash) = grass[i]
    hunting_surface_grass(
      accum[10],
      x.to_double() + 0.2 + (hash % 61).to_double() / 100.0,
      z.to_double() + 0.2 + (hash / 61 % 61).to_double() / 100.0,
      hash,
      dungeon,
    )
  }
  for prop in props {
    if prop.x / chunk_size != cx || prop.z / chunk_size != cz {
      continue
    }
    let px = prop.x.to_double() + prop.width.to_double() / 2.0
    let pz = prop.z.to_double() + prop.depth.to_double() / 2.0
    hunting_surface_shadow(
      accum[12],
      px + 0.10,
      pz + 0.12,
      prop.width.to_double() / 2.0,
      prop.depth.to_double() / 2.0,
      dungeon,
    )
    for part in hunting_prop_asset(prop).parts {
      let start = accum[part.material].vertices.length()
      merge_mesh_at(
        accum[part.material].vertices,
        accum[part.material].indices,
        part.mesh,
        px,
        @game.get_tile_height(dungeon, px * tile_size, pz * tile_size),
        pz,
      )
      tag_scenery_geometry(accum[part.material], start, 2.0)
    }
  }
  if landscape is Some(land) {
    let starts = accum.map(g => g.vertices.length())
    for bridge in land.bridges {
      if bridge.ax.to_int() / chunk_size == cx &&
        bridge.az.to_int() / chunk_size == cz {
        append_landscape_bridge(accum, dungeon, bridge)
      }
    }
    if 61 / chunk_size == cx && 18 / chunk_size == cz {
      append_landscape_cave(accum, dungeon, land.cave)
    }
    if 15 / chunk_size == cx && 55 / chunk_size == cz {
      append_landscape_beacon(accum, dungeon)
    }
    for i in 0..<accum.length() {
      tag_scenery_geometry(accum[i], starts[i], 2.0)
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  let all_v : Array[Double] = []
  let all_i : Array[Int] = []
  for i in 0..<accum.length() {
    for vertex in 0..<(accum[i].vertices.length() / 8) {
      accum[i].vertices[vertex * 8 + 6] = i.to_double()
      accum[i].vertices[vertex * 8 + 7] = accum[i].vertices[vertex * 8 + 7].max(
        1.0,
      )
    }
    let mesh = @mesh3d.Mesh3D::new(accum[i].vertices, accum[i].indices)
    groups.push({
      mesh,
      color: palette[i],
      surface_kind: if i == 23 {
        Pillar
      } else {
        Floor
      },
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
  combined? : Bool = true,
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
    if combined {
      merge_mesh_at(all.vertices, all.indices, chunk.all_mesh, 0.0, 0.0, 0.0)
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  for i in 0..<accum.length() {
    if accum[i].indices.is_empty() {
      continue
    }
    groups.push({
      mesh: @mesh3d.Mesh3D::new(accum[i].vertices, accum[i].indices),
      color: palette[i],
      surface_kind: if i == 23 {
        Pillar
      } else {
        Floor
      },
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
    if group.surface_kind == Pillar && self.cave_roof_hidden() {
      continue
    }
    cmds.push(
      self.scenery_draw(
        dst,
        group.dst_region,
        group.mesh,
        @math3d.Mat4::identity(),
        vp,
      ),
    )
  }
  let player = self.world.player
  let shadow = if self.world.dungeon.terrain_surface is Some(surface) {
    terrain_shadow_mesh(
      surface,
      player.x / tile_size,
      player.y / tile_size,
      0.31,
      0.23,
    )
  } else {
    hunter_contact_shadow
  }
  cmds.push(
    @draw3d.new_lit_colored_mesh_draw_command(
      dst,
      self.shader3d_colored,
      @gfx.new_dst_region(0, 0, screen_w, screen_h, shadow.indices.length()),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(0),
      shadow,
      if self.world.dungeon.terrain_surface is Some(_) {
        @math3d.Mat4::identity()
      } else {
        @transform3d.Transform3D::from_position(
          @math3d.Vec3::new(player.x / tile_size, 0.002, player.y / tile_size),
        ).to_mat4()
      },
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

///|
// Shallow, broken paving shares the terrain plane; it never changes walking height.
fn hunting_broken_paving(
  g : @procedural3d.RigidGeometry,
  x : Double,
  z : Double,
  hash : Int,
) -> Unit {
  for
    i, rect in [
      (0.04, 0.04, 0.47, 0.96),
      (0.53, 0.04, 0.96, 0.47),
      (0.53, 0.53, 0.96, 0.96),
    ] {
    if (hash + i * 3) % 11 == 0 {
      continue
    }
    let (a, b, c, d) = rect
    fn p(px : Double, pz : Double) -> @math3d.Vec3 {
      if hash % 2 == 0 {
        @math3d.Vec3::new(x + px, 0.004, z + pz)
      } else {
        @math3d.Vec3::new(x + 1.0 - pz, 0.004, z + px)
      }
    }
    g.quad(p(a, b), p(a, d), p(c, d), p(c, b), 0)
  }
}
