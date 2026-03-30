// Shadow mapping: dungeon mesh batching + shadow pass rendering
// Spatial chunking: split dungeon into chunks for frustum culling

///|
let chunk_size : Int = 24 // tiles per chunk side

// Merge multiple positioned meshes into a single combined mesh.

///|
fn merge_mesh_at(
  dst_verts : Array[Double],
  dst_indices : Array[Int],
  src : @mesh3d.Mesh3D,
  ox : Double,
  oy : Double,
  oz : Double,
) -> Unit {
  let stride = 8
  let base_vert = dst_verts.length() / stride
  let src_verts = src.vertex_data
  let vert_count = src_verts.length() / stride
  for i in 0..<vert_count {
    let off = i * stride
    dst_verts.push(src_verts[off] + ox)
    dst_verts.push(src_verts[off + 1] + oy)
    dst_verts.push(src_verts[off + 2] + oz)
    dst_verts.push(src_verts[off + 3])
    dst_verts.push(src_verts[off + 4])
    dst_verts.push(src_verts[off + 5])
    dst_verts.push(src_verts[off + 6])
    dst_verts.push(src_verts[off + 7])
  }
  for idx in src.indices {
    dst_indices.push(idx + base_vert)
  }
}

// A spatial chunk: pre-built mesh groups for a region of the map

///|
struct DungeonChunk {
  cx : Int // chunk column index
  cz : Int // chunk row index
  groups : Array[DungeonMeshGroup]
  wall_mesh : @mesh3d.Mesh3D
  all_mesh : @mesh3d.Mesh3D // all geometry merged for shadow depth pass
}

// Build chunked dungeon mesh groups.
// Returns array of chunks, each with its own mesh groups.

///|
fn build_dungeon_chunks(
  dungeon : @game.DungeonData,
  meshes : Meshes3D,
) -> Array[DungeonChunk] {
  let w = dungeon.grid.width
  let h = dungeon.grid.height
  let cols_chunks = (w + chunk_size - 1) / chunk_size
  let rows_chunks = (h + chunk_size - 1) / chunk_size
  let chunks : Array[DungeonChunk] = []
  for cz = 0; cz < rows_chunks; cz = cz + 1 {
    for cx = 0; cx < cols_chunks; cx = cx + 1 {
      let chunk = build_single_chunk(dungeon, meshes, cx, cz, w, h)
      chunks.push(chunk)
    }
  }
  chunks
}

///|
fn build_single_chunk(
  dungeon : @game.DungeonData,
  meshes : Meshes3D,
  cx : Int,
  cz : Int,
  w : Int,
  h : Int,
) -> DungeonChunk {
  let floor_v : Array[Double] = []
  let floor_i : Array[Int] = []
  let corridor_v : Array[Double] = []
  let corridor_i : Array[Int] = []
  let door_v : Array[Double] = []
  let door_i : Array[Int] = []
  let wall_v : Array[Double] = []
  let wall_i : Array[Int] = []
  let pillar_v : Array[Double] = []
  let pillar_i : Array[Int] = []
  // Exterior ground for Empty/out-of-bounds tiles
  let exterior_v : Array[Double] = []
  let exterior_i : Array[Int] = []
  // Decorative objects (debris, crates in rooms)
  let decor_v : Array[Double] = []
  let decor_i : Array[Int] = []
  // Combined mesh for shadow depth (all geometry merged)
  let all_v : Array[Double] = []
  let all_i : Array[Int] = []
  let start_col = cx * chunk_size
  let start_row = cz * chunk_size
  let end_col = @cmp.minimum(start_col + chunk_size, w)
  let end_row = @cmp.minimum(start_row + chunk_size, h)
  for row = start_row; row < end_row; row = row + 1 {
    for col = start_col; col < end_col; col = col + 1 {
      let tile = dungeon.grid.get(col, row)
      let x = col.to_double()
      let z = row.to_double()
      let y = dungeon.height_map[row * w + col]
      match tile {
        Floor | Start | Goal => {
          merge_mesh_at(floor_v, floor_i, meshes.floor_tile, x, y, z)
          merge_mesh_at(all_v, all_i, meshes.floor_tile, x, y, z)
          // Scatter debris in rooms (deterministic hash)
          let hash = (col * 7919 + row * 104729 + 31) % 100
          if hash < 8 {
            let dx = (hash * 37 % 80).to_double() / 100.0 - 0.4
            let dz = (hash * 53 % 80).to_double() / 100.0 - 0.4
            merge_mesh_at(decor_v, decor_i, meshes.debris, x + dx, y, z + dz)
          } else if hash < 12 {
            let dx = (hash * 41 % 60).to_double() / 100.0 - 0.3
            let dz = (hash * 67 % 60).to_double() / 100.0 - 0.3
            merge_mesh_at(decor_v, decor_i, meshes.crate, x + dx, y, z + dz)
            merge_mesh_at(all_v, all_i, meshes.crate, x + dx, y, z + dz)
          }
        }
        Corridor => {
          merge_mesh_at(corridor_v, corridor_i, meshes.floor_tile, x, y, z)
          merge_mesh_at(all_v, all_i, meshes.floor_tile, x, y, z)
        }
        Door => {
          merge_mesh_at(door_v, door_i, meshes.floor_tile, x, y, z)
          merge_mesh_at(pillar_v, pillar_i, meshes.pillar, x - 0.4, y, z)
          merge_mesh_at(pillar_v, pillar_i, meshes.pillar, x + 0.4, y, z)
          merge_mesh_at(all_v, all_i, meshes.floor_tile, x, y, z)
          merge_mesh_at(all_v, all_i, meshes.pillar, x - 0.4, y, z)
          merge_mesh_at(all_v, all_i, meshes.pillar, x + 0.4, y, z)
        }
        Wall =>
          if has_adjacent_walkable(dungeon.grid, col, row) {
            // Wall height variation by position hash
            let wall_hash = (col * 2971 + row * 6173) % 100
            let wall_mesh = if wall_hash < 25 {
              meshes.wall_low
            } else if wall_hash < 85 {
              meshes.wall
            } else {
              meshes.wall_tall
            }
            merge_mesh_at(wall_v, wall_i, wall_mesh, x, y, z)
            merge_mesh_at(all_v, all_i, wall_mesh, x, y, z)
          }
        Empty =>
          // Exterior ground: dark plane at y=-0.1 for void areas
          merge_mesh_at(exterior_v, exterior_i, meshes.floor_tile, x, -0.1, z)
        _ => ()
      }
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  fn add_group(
    verts : Array[Double],
    indices : Array[Int],
    color : @math3d.Vec4,
    surface_kind : DungeonSurfaceKind,
    groups : Array[DungeonMeshGroup],
  ) -> Unit {
    if indices.length() > 0 {
      groups.push({
        mesh: @mesh3d.Mesh3D::new(verts, indices),
        color,
        surface_kind,
        dst_region: @gfx.new_dst_region(
          0,
          0,
          screen_w,
          screen_h,
          indices.length(),
        ),
      })
    }
  }

  add_group(exterior_v, exterior_i, color_exterior, Floor, groups)
  add_group(floor_v, floor_i, color_floor, Floor, groups)
  add_group(corridor_v, corridor_i, color_corridor, Corridor, groups)
  add_group(door_v, door_i, color_door, Door, groups)
  add_group(wall_v, wall_i, color_wall, Wall, groups)
  add_group(pillar_v, pillar_i, color_pillar, Pillar, groups)
  add_group(decor_v, decor_i, color_debris, Floor, groups)
  let wall_mesh = @mesh3d.Mesh3D::new(wall_v, wall_i)
  let all_mesh = @mesh3d.Mesh3D::new(all_v, all_i)
  { cx, cz, groups, wall_mesh, all_mesh }
}

// Get visible chunks near player position (in tile coords)

///|
fn get_visible_chunks(
  chunks : Array[DungeonChunk],
  player_tile_x : Int,
  player_tile_z : Int,
  radius : Int, // in chunks
) -> Array[DungeonChunk] {
  let pcx = player_tile_x / chunk_size
  let pcz = player_tile_z / chunk_size
  let result : Array[DungeonChunk] = []
  for chunk in chunks {
    let dx = chunk.cx - pcx
    let dz = chunk.cz - pcz
    if dx >= -radius && dx <= radius && dz >= -radius && dz <= radius {
      result.push(chunk)
    }
  }
  result
}

// Check if a wall tile has at least one adjacent walkable tile

///|
fn has_adjacent_walkable(grid : @terrain.Grid2D, col : Int, row : Int) -> Bool {
  let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  for pair in dirs {
    let nx = col + pair.0
    let ny = row + pair.1
    if nx >= 0 && nx < grid.width && ny >= 0 && ny < grid.height {
      let t = grid.get(nx, ny)
      match t {
        Floor | Corridor | Door | Start | Goal => return true
        _ => ()
      }
    }
  }
  false
}
