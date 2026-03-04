///|
pub(all) struct TwoBoneIKRequest {
  skeleton : @skeleton3d.Skeleton
  local_poses : Array[@transform3d.Transform3D]
  upper_bone : Int
  lower_bone : Int
  end_bone : Int
  target : @math3d.Vec3
  pole_target : @math3d.Vec3?
}

///|
pub(all) struct TwoBoneIKResult {
  success : Bool
  local_poses : Array[@transform3d.Transform3D]
}

///|
/// Compute shortest-arc rotation between two unit vectors.
pub fn rotation_between_vectors(
  from : @math3d.Vec3,
  to : @math3d.Vec3,
) -> @math3d.Quaternion {
  let dot = from.dot(to)
  if dot > 0.99999 {
    return @math3d.Quaternion::identity()
  }
  if dot < -0.99999 {
    let mut perp = @math3d.Vec3::new(1.0, 0.0, 0.0).cross(from)
    if perp.length_squared() < 1.0e-6 {
      perp = @math3d.Vec3::new(0.0, 1.0, 0.0).cross(from)
    }
    perp = perp.normalize()
    return @math3d.Quaternion::new(perp.x, perp.y, perp.z, 0.0)
  }
  let axis = from.cross(to)
  let w = 1.0 + dot
  @math3d.Quaternion::new(axis.x, axis.y, axis.z, w).normalize()
}

///|
/// Extract world position from a Mat4 column 3.
fn world_pos(m : @math3d.Mat4) -> @math3d.Vec3 {
  @math3d.Vec3::new(m.elements[12], m.elements[13], m.elements[14])
}

///|
/// Compute the accumulated world rotation for a bone by walking the parent chain.
/// Only uses local_poses rotations (no from_mat4 extraction).
fn compute_bone_world_rotation(
  skeleton : @skeleton3d.Skeleton,
  local_poses : Array[@transform3d.Transform3D],
  bone_index : Int,
) -> @math3d.Quaternion {
  // Collect ancestor chain
  let chain : Array[Int] = []
  let mut idx = bone_index
  while idx >= 0 {
    chain.push(idx)
    idx = skeleton.bones[idx].parent
  }
  // Walk from root to bone, accumulating rotation
  let mut world_rot = @math3d.Quaternion::identity()
  let mut i = chain.length() - 1
  while i >= 0 {
    world_rot = world_rot.multiply(local_poses[chain[i]].rotation).normalize()
    i = i - 1
  }
  world_rot
}

///|
/// Two-bone analytical IK solver (arm/leg).
/// Uses law of cosines for closed-form solution.
pub fn solve_two_bone_ik(request : TwoBoneIKRequest) -> TwoBoneIKResult {
  let skeleton = request.skeleton
  let local_poses = request.local_poses
  let target = request.target
  // Clone local_poses
  let result_poses : Array[@transform3d.Transform3D] = []
  for p in local_poses {
    result_poses.push(p)
  }
  // Compute world transforms to get joint positions
  let world = skeleton.compute_world_transforms(local_poses)
  let pos_a = world_pos(world[request.upper_bone])
  let pos_b = world_pos(world[request.lower_bone])
  let pos_c = world_pos(world[request.end_bone])
  let len_ab = pos_a.distance(pos_b)
  let len_bc = pos_b.distance(pos_c)
  let len_at = pos_a.distance(target)
  let total_length = len_ab + len_bc
  let success = len_at <= total_length
  // Clamp target distance to reachable range
  let clamped_len = if len_at > total_length - 1.0e-6 {
    total_length - 1.0e-6
  } else if len_at < (len_ab - len_bc).abs() + 1.0e-6 {
    (len_ab - len_bc).abs() + 1.0e-6
  } else {
    len_at
  }
  // Direction from A to target
  let dir_at = target.sub(pos_a).normalize()
  // Law of cosines: angle at A
  let cos_a = (len_ab * len_ab + clamped_len * clamped_len - len_bc * len_bc) /
    (2.0 * len_ab * clamped_len)
  let cos_a_clamped = if cos_a > 1.0 {
    1.0
  } else if cos_a < -1.0 {
    -1.0
  } else {
    cos_a
  }
  let angle_a = @math.acos(cos_a_clamped)
  // Determine the bend plane normal
  let bend_normal = match request.pole_target {
    Some(pole) => {
      let to_pole = pole.sub(pos_a).normalize()
      let n = dir_at.cross(to_pole)
      if n.length_squared() < 1.0e-6 {
        let chain_dir = pos_c.sub(pos_a).normalize()
        let mid_dir = pos_b.sub(pos_a).normalize()
        let n2 = chain_dir.cross(mid_dir)
        if n2.length_squared() < 1.0e-6 {
          @math3d.Vec3::unit_z()
        } else {
          n2.normalize()
        }
      } else {
        n.normalize()
      }
    }
    None => {
      let chain_dir = pos_c.sub(pos_a).normalize()
      let mid_dir = pos_b.sub(pos_a).normalize()
      let n = chain_dir.cross(mid_dir)
      if n.length_squared() < 1.0e-6 {
        @math3d.Vec3::unit_z()
      } else {
        n.normalize()
      }
    }
  }
  // Compute desired elbow position using angle_a and bend plane
  let bend_rot = @math3d.Quaternion::from_axis_angle(bend_normal, angle_a)
  let desired_ab_dir = bend_rot.rotate_vec3(dir_at).normalize()
  let desired_b = pos_a.add(desired_ab_dir.scale(len_ab))
  let desired_bc_dir = target.sub(desired_b).normalize()
  // -- Compute local rotations with twist control --
  // Get the parent's world rotation for the upper bone
  let parent_upper = skeleton.bones[request.upper_bone].parent
  let parent_world_rot = if parent_upper >= 0 {
    compute_bone_world_rotation(skeleton, local_poses, parent_upper)
  } else {
    @math3d.Quaternion::identity()
  }
  // Upper bone: child offset direction (rest pose direction to lower bone)
  let upper_child_offset = local_poses[request.lower_bone].position.normalize()
  // Transform desired world direction to parent's local space
  let inv_parent = parent_world_rot.inverse()
  let target_local_upper = inv_parent.rotate_vec3(desired_ab_dir)
  let new_local_rot_upper = rotation_between_vectors(
    upper_child_offset,
    target_local_upper,
  )
  result_poses[request.upper_bone] = result_poses[request.upper_bone].with_rotation(
    new_local_rot_upper,
  )
  // Upper bone's world rotation
  let upper_world_rot = parent_world_rot.multiply(new_local_rot_upper).normalize()
  // Lower bone: child offset direction (rest pose direction to end bone)
  let lower_child_offset = local_poses[request.end_bone].position.normalize()
  let inv_upper = upper_world_rot.inverse()
  let target_local_lower = inv_upper.rotate_vec3(desired_bc_dir)
  let new_local_rot_lower = rotation_between_vectors(
    lower_child_offset,
    target_local_lower,
  )
  result_poses[request.lower_bone] = result_poses[request.lower_bone].with_rotation(
    new_local_rot_lower,
  )
  { success, local_poses: result_poses }
}
