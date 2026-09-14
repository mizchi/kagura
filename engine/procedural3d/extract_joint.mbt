///|
/// Append whole triangles rigidly owned by source_joint, assigning target_joint.
/// Positions, normals and UVs remain in bind space; no retarget transform is applied.
/// Blended or cross-joint triangles are excluded. Source buffers are never mutated.
pub fn RigidGeometry::append_joint(
  self : RigidGeometry,
  mesh : @mesh3d.Mesh3D,
  skin : @skeleton3d.SkinData,
  source_joint : Int,
  target_joint : Int,
) -> Unit {
  fn belongs(vertex : Int) -> Bool {
    let base = vertex * 4
    let mut weight = 0.0
    for i in 0..<4 {
      if skin.weights[base + i] != 0.0 {
        if skin.joint_indices[base + i] != source_joint {
          return false
        }
        weight += skin.weights[base + i]
      }
    }
    (weight - 1.0).abs() < 0.000001
  }
  let remap : Map[Int, Int] = Map::new()
  for triangle in 0..<(mesh.indices.length() / 3) {
    let a = mesh.indices[triangle * 3]
    let b = mesh.indices[triangle * 3 + 1]
    let c = mesh.indices[triangle * 3 + 2]
    if !belongs(a) || !belongs(b) || !belongs(c) {
      continue
    }
    for vertex in [a, b, c] {
      let next = match remap.get(vertex) {
        Some(index) => index
        None => {
          let index = self.vertices.length() / 8
          for i in 0..<8 {
            self.vertices.push(mesh.vertex_data[vertex * 8 + i])
          }
          self.joints.append([target_joint, 0, 0, 0])
          self.weights.append([1.0, 0.0, 0.0, 0.0])
          remap[vertex] = index
          index
        }
      }
      self.indices.push(next)
    }
  }
}
