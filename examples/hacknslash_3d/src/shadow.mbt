// Shadow mapping: dungeon mesh batching + shadow pass rendering
// Spatial chunking: split dungeon into chunks for frustum culling

let chunk_size : Int = 12 // tiles per chunk side

// Merge multiple positioned meshes into a single combined mesh.
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
struct DungeonChunk {
  cx : Int // chunk column index
  cz : Int // chunk row index
  groups : Array[DungeonMeshGroup]
  wall_mesh : @mesh3d.Mesh3D
}

// Build chunked dungeon mesh groups.
// Returns array of chunks, each with its own mesh groups.
fn build_dungeon_chunks(
  dungeon : DungeonData,
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

fn build_single_chunk(
  dungeon : DungeonData,
  meshes : Meshes3D,
  cx : Int,
  cz : Int,
  w : Int,
  h : Int,
) -> DungeonChunk {
  let floor_a_v : Array[Double] = []
  let floor_a_i : Array[Int] = []
  let floor_b_v : Array[Double] = []
  let floor_b_i : Array[Int] = []
  let corridor_a_v : Array[Double] = []
  let corridor_a_i : Array[Int] = []
  let corridor_b_v : Array[Double] = []
  let corridor_b_i : Array[Int] = []
  let door_v : Array[Double] = []
  let door_i : Array[Int] = []
  let wall_v : Array[Double] = []
  let wall_i : Array[Int] = []
  let pillar_v : Array[Double] = []
  let pillar_i : Array[Int] = []
  let wall_all_v : Array[Double] = []
  let wall_all_i : Array[Int] = []
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
          let checker = (col + row) % 2
          if checker == 0 {
            merge_mesh_at(floor_a_v, floor_a_i, meshes.floor_tile, x, y, z)
          } else {
            merge_mesh_at(floor_b_v, floor_b_i, meshes.floor_tile, x, y, z)
          }
        }
        Corridor => {
          let stripe = (col + row) % 3
          if stripe == 0 {
            merge_mesh_at(
              corridor_a_v, corridor_a_i, meshes.floor_tile, x, y, z,
            )
          } else {
            merge_mesh_at(
              corridor_b_v, corridor_b_i, meshes.floor_tile, x, y, z,
            )
          }
        }
        Door => {
          merge_mesh_at(door_v, door_i, meshes.floor_tile, x, y, z)
          merge_mesh_at(pillar_v, pillar_i, meshes.pillar, x - 0.4, y, z)
          merge_mesh_at(pillar_v, pillar_i, meshes.pillar, x + 0.4, y, z)
        }
        Wall => {
          if has_adjacent_walkable(dungeon.grid, col, row) {
            merge_mesh_at(wall_v, wall_i, meshes.wall, x, y, z)
            merge_mesh_at(wall_all_v, wall_all_i, meshes.wall, x, y, z)
          }
        }
        _ => ()
      }
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  fn add_group(
    verts : Array[Double],
    indices : Array[Int],
    color : @math3d.Vec4,
    groups : Array[DungeonMeshGroup],
  ) -> Unit {
    if indices.length() > 0 {
      groups.push({
        mesh: @mesh3d.Mesh3D::new(verts, indices),
        color,
      })
    }
  }

  add_group(floor_a_v, floor_a_i, color_floor, groups)
  add_group(floor_b_v, floor_b_i, color_floor_alt, groups)
  add_group(corridor_a_v, corridor_a_i, color_corridor, groups)
  add_group(corridor_b_v, corridor_b_i, color_corridor_alt, groups)
  add_group(door_v, door_i, color_door, groups)
  add_group(wall_v, wall_i, color_wall, groups)
  add_group(pillar_v, pillar_i, color_pillar, groups)
  let wall_mesh = @mesh3d.Mesh3D::new(wall_all_v, wall_all_i)
  { cx, cz, groups, wall_mesh }
}

// Get visible chunks near player position (in tile coords)
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
fn has_adjacent_walkable(
  grid : @terrain.Grid2D,
  col : Int,
  row : Int,
) -> Bool {
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
