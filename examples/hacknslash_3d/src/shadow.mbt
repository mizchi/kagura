// Shadow mapping: dungeon mesh batching + shadow pass rendering

// Merge multiple positioned meshes into a single combined mesh.
// Each source mesh is offset by (ox, oy, oz).
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
    dst_verts.push(src_verts[off] + ox) // position x
    dst_verts.push(src_verts[off + 1] + oy) // position y
    dst_verts.push(src_verts[off + 2] + oz) // position z
    dst_verts.push(src_verts[off + 3]) // normal x
    dst_verts.push(src_verts[off + 4]) // normal y
    dst_verts.push(src_verts[off + 5]) // normal z
    dst_verts.push(src_verts[off + 6]) // u
    dst_verts.push(src_verts[off + 7]) // v
  }
  for idx in src.indices {
    dst_indices.push(idx + base_vert)
  }
}

// Build combined meshes grouped by tile type + color variant.
// Returns (mesh_groups_for_lit_pass, wall_mesh_for_depth_pass).
fn build_dungeon_mesh_groups(
  dungeon : DungeonData,
  meshes : Meshes3D,
) -> (Array[DungeonMeshGroup], @mesh3d.Mesh3D) {
  // Groups: floor_a, floor_b, corridor_a, corridor_b, door, wall_a, wall_b
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
  let wall_a_v : Array[Double] = []
  let wall_a_i : Array[Int] = []
  let wall_b_v : Array[Double] = []
  let wall_b_i : Array[Int] = []
  // Combined wall mesh for shadow caster (all walls)
  let wall_all_v : Array[Double] = []
  let wall_all_i : Array[Int] = []
  for row = 0; row < dungeon.grid.height; row = row + 1 {
    for col = 0; col < dungeon.grid.width; col = col + 1 {
      let tile = dungeon.grid.get(col, row)
      let x = col.to_double()
      let z = row.to_double()
      match tile {
        Floor => {
          let checker = (col + row) % 2
          if checker == 0 {
            merge_mesh_at(floor_a_v, floor_a_i, meshes.floor_tile, x, 0.0, z)
          } else {
            merge_mesh_at(floor_b_v, floor_b_i, meshes.floor_tile, x, 0.0, z)
          }
        }
        Corridor => {
          let stripe = (col + row) % 3
          if stripe == 0 {
            merge_mesh_at(
              corridor_a_v, corridor_a_i, meshes.floor_tile, x, 0.0, z,
            )
          } else {
            merge_mesh_at(
              corridor_b_v, corridor_b_i, meshes.floor_tile, x, 0.0, z,
            )
          }
        }
        Door => merge_mesh_at(door_v, door_i, meshes.floor_tile, x, 0.0, z)
        Wall => {
          let brick_offset = if row % 2 == 0 { 0 } else { 2 }
          let brick_pos = (col + brick_offset) % 4
          if brick_pos == 0 {
            merge_mesh_at(wall_a_v, wall_a_i, meshes.wall, x, 0.5, z)
          } else {
            merge_mesh_at(wall_b_v, wall_b_i, meshes.wall, x, 0.5, z)
          }
          // All walls go into shadow caster mesh
          merge_mesh_at(wall_all_v, wall_all_i, meshes.wall, x, 0.5, z)
        }
        _ => ()
      }
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  // Helper to add non-empty groups
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
  add_group(wall_a_v, wall_a_i, color_wall, groups)
  add_group(wall_b_v, wall_b_i, color_wall_alt, groups)
  let wall_mesh = @mesh3d.Mesh3D::new(wall_all_v, wall_all_i)
  (groups, wall_mesh)
}
