///|
/// Blend two Transform3D pose arrays with the given weight.
/// weight=0.0 → poses_a, weight=1.0 → poses_b.
pub fn blend_poses(
  poses_a : Array[@transform3d.Transform3D],
  poses_b : Array[@transform3d.Transform3D],
  weight : Double,
) -> Array[@transform3d.Transform3D] {
  let len = poses_a.length()
  let result : Array[@transform3d.Transform3D] = []
  for i in 0..<len {
    if i < poses_b.length() {
      let a = poses_a[i]
      let b = poses_b[i]
      let pos = a.position.lerp(b.position, weight)
      let rot = a.rotation.slerp(b.rotation, weight)
      let sc = a.scale.lerp(b.scale, weight)
      result.push(@transform3d.Transform3D::from_components(pos, rot, sc))
    } else {
      result.push(poses_a[i])
    }
  }
  result
}

///|
/// Blend two sparse NodePose arrays with the given weight.
/// Merges by node_index; if only one side has a node, that side is used.
pub fn blend_node_poses(
  poses_a : Array[NodePose],
  poses_b : Array[NodePose],
  weight : Double,
) -> Array[NodePose] {
  // Build lookup for poses_b
  let b_map : Map[Int, NodePose] = Map([])
  for p in poses_b {
    b_map[p.node_index] = p
  }
  let result : Array[NodePose] = []
  let visited : Map[Int, Bool] = Map([])
  // Process all nodes from poses_a
  for a in poses_a {
    visited[a.node_index] = true
    match b_map.get(a.node_index) {
      Some(b) => {
        // Blend
        let translation = match (a.translation, b.translation) {
          (Some(va), Some(vb)) => Some(va.lerp(vb, weight))
          (Some(va), None) => Some(va)
          (None, Some(vb)) => Some(vb)
          (None, None) => None
        }
        let rotation = match (a.rotation, b.rotation) {
          (Some(qa), Some(qb)) => Some(qa.slerp(qb, weight))
          (Some(qa), None) => Some(qa)
          (None, Some(qb)) => Some(qb)
          (None, None) => None
        }
        let scale = match (a.scale, b.scale) {
          (Some(sa), Some(sb)) => Some(sa.lerp(sb, weight))
          (Some(sa), None) => Some(sa)
          (None, Some(sb)) => Some(sb)
          (None, None) => None
        }
        result.push({ node_index: a.node_index, translation, rotation, scale })
      }
      None => result.push(a)
    }
  }
  // Add nodes only in poses_b
  for b in poses_b {
    match visited.get(b.node_index) {
      Some(true) => ()
      _ => result.push(b)
    }
  }
  result
}
