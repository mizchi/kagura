///|
/// Bone in a skeleton hierarchy.
pub(all) struct Bone {
  name : String
  parent : Int // -1 = root
  local_transform : @transform3d.Transform3D
}

///|
/// Skeleton with bone hierarchy and inverse bind matrices.
pub(all) struct Skeleton {
  bones : Array[Bone]
  inverse_bind_matrices : Array[@math3d.Mat4]
}

///|
/// Per-vertex skinning data (4 joints + 4 weights per vertex).
pub(all) struct SkinData {
  joint_indices : Array[Int] // flat, 4 per vertex
  weights : Array[Double] // flat, 4 per vertex
  vertex_count : Int
}
