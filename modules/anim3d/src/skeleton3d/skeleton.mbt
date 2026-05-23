///|
pub fn Skeleton::new(
  bones : Array[Bone],
  inverse_bind_matrices : Array[@math3d.Mat4],
) -> Skeleton {
  { bones, inverse_bind_matrices }
}

///|
pub fn Skeleton::bone_count(self : Skeleton) -> Int {
  self.bones.length()
}

///|
/// Compute world transforms from local poses, propagating parent-to-child.
/// `local_poses` should have one Transform3D per bone.
pub fn Skeleton::compute_world_transforms(
  self : Skeleton,
  local_poses : Array[@transform3d.Transform3D],
) -> Array[@math3d.Mat4] {
  let count = self.bones.length()
  let world : Array[@math3d.Mat4] = Array::make(count, @math3d.Mat4::identity())
  for i in 0..<count {
    let local_mat = local_poses[i].to_mat4()
    let parent = self.bones[i].parent
    if parent < 0 {
      world[i] = local_mat
    } else {
      world[i] = world[parent].multiply(local_mat)
    }
  }
  world
}

///|
/// Compute skinning matrices: world_transform[i] * inverse_bind_matrix[i].
pub fn Skeleton::compute_skinning_matrices(
  self : Skeleton,
  world_transforms : Array[@math3d.Mat4],
) -> Array[@math3d.Mat4] {
  let count = self.bones.length()
  let result : Array[@math3d.Mat4] = Array::make(
    count,
    @math3d.Mat4::identity(),
  )
  for i in 0..<count {
    result[i] = world_transforms[i].multiply(self.inverse_bind_matrices[i])
  }
  result
}
