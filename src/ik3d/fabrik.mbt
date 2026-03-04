///|
pub(all) struct FABRIKRequest {
  skeleton : @skeleton3d.Skeleton
  local_poses : Array[@transform3d.Transform3D]
  chain : Array[Int]
  target : @math3d.Vec3
  tolerance : Double
  max_iterations : Int
}

///|
pub(all) struct FABRIKResult {
  success : Bool
  iterations : Int
  local_poses : Array[@transform3d.Transform3D]
}

///|
/// FABRIK (Forward And Backward Reaching Inverse Kinematics) solver.
/// Works with N-bone chains (tentacles, tails, spines).
pub fn solve_fabrik(request : FABRIKRequest) -> FABRIKResult {
  let skeleton = request.skeleton
  let local_poses = request.local_poses
  let chain = request.chain
  let target = request.target
  let tolerance = request.tolerance
  let max_iter = request.max_iterations
  let n = chain.length()
  if n < 2 {
    return { success: true, iterations: 0, local_poses }
  }
  // Clone local_poses
  let result_poses : Array[@transform3d.Transform3D] = []
  for p in local_poses {
    result_poses.push(p)
  }
  // Compute initial world transforms
  let world = skeleton.compute_world_transforms(result_poses)
  // Extract world positions of chain joints
  let positions : Array[@math3d.Vec3] = []
  for i in 0..<n {
    let idx = chain[i]
    positions.push(world_pos(world[idx]))
  }
  // Compute segment lengths
  let lengths : Array[Double] = []
  for i in 0..<(n - 1) {
    lengths.push(positions[i].distance(positions[i + 1]))
  }
  // Total chain length
  let mut total_length = 0.0
  for l in lengths {
    total_length = total_length + l
  }
  // Distance to target
  let dist_to_target = positions[0].distance(target)
  // Check reachability
  let success = dist_to_target <= total_length
  // Save root position (fixed)
  let root_pos = positions[0]
  // FABRIK iterations
  let mut iterations = 0
  for iter in 0..<max_iter {
    iterations = iter + 1
    // Check convergence
    let end_error = positions[n - 1].distance(target)
    if end_error < tolerance {
      break
    }
    // Forward pass: end → root (set end to target, work backward to joint 0)
    positions[n - 1] = target
    for ii in 0..<(n - 1) {
      let i = n - 2 - ii
      let dir = positions[i].sub(positions[i + 1]).normalize()
      positions[i] = positions[i + 1].add(dir.scale(lengths[i]))
    }
    // Backward pass: root → end (pin root, work forward)
    positions[0] = root_pos
    for i in 0..<(n - 1) {
      let dir = positions[i + 1].sub(positions[i]).normalize()
      positions[i + 1] = positions[i].add(dir.scale(lengths[i]))
    }
  } nobreak {
    iterations = max_iter
  }
  // Convert solved world positions to local rotations
  // using accumulated parent rotation (no from_mat4 needed)

  // Get the parent world rotation for the chain root
  let root_bone = chain[0]
  let root_parent = skeleton.bones[root_bone].parent
  let mut accumulated_rot = if root_parent >= 0 {
    compute_bone_world_rotation(skeleton, result_poses, root_parent)
  } else {
    @math3d.Quaternion::identity()
  }
  for i in 0..<(n - 1) {
    let bone_idx = chain[i]
    let child_idx = chain[i + 1]
    // Rest-pose child offset direction
    let child_offset = result_poses[child_idx].position
    let child_offset_dir = child_offset.normalize()
    if child_offset.length() < 1.0e-8 {
      accumulated_rot = accumulated_rot
        .multiply(result_poses[bone_idx].rotation)
        .normalize()
      continue
    }
    // Desired world direction from this joint to next
    let desired_dir = positions[i + 1].sub(positions[i]).normalize()
    // Transform desired direction to parent's local space
    let target_local = accumulated_rot.inverse().rotate_vec3(desired_dir)
    // Compute local rotation
    let new_local_rot = rotation_between_vectors(child_offset_dir, target_local)
    result_poses[bone_idx] = result_poses[bone_idx].with_rotation(new_local_rot)
    // Update accumulated rotation for next bone
    accumulated_rot = accumulated_rot.multiply(new_local_rot).normalize()
  }
  { success, iterations, local_poses: result_poses }
}
