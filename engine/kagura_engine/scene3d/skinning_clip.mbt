///|
/// Immutable finite palette of skinning matrices. Bake at asset initialization;
/// actors with equal frame_index can share one instanced GPU draw. Sample zero
/// and the final sample are both included; matrices are borrowed, never mutate.
pub struct BakedSkinningClip {
  frame_count : Int
  priv frames : Array[Array[@math3d.Mat4]]
}

///|
pub fn BakedSkinningClip::new(
  skeleton : @skeleton3d.Skeleton,
  clip : @animation3d.AnimationClip,
  frame_count : Int,
) -> BakedSkinningClip {
  let count = frame_count.max(2)
  let player = @animation3d.AnimationPlayer::new(clip)
  player.set_looping(false)
  BakedSkinningClip::from_pose_sampler(skeleton, count, index => {
    player.set_time(index.to_double() / (count - 1).to_double() * clip.duration)
    let poses = skeleton.bones.map(bone => bone.local_transform)
    @animation3d.apply_node_poses(poses, player.sample())
    poses
  })
}

///|
/// Bake procedural local poses once, retaining the skeleton hierarchy and
/// inverse bind matrices. The sampler is called exactly max(frame_count, 1)
/// times, in index order, and must return one local transform per bone. It may
/// reuse its scratch array: matrices are computed before the next invocation.
/// Playback only selects cached matrices and never invokes the sampler again.
pub fn BakedSkinningClip::from_pose_sampler(
  skeleton : @skeleton3d.Skeleton,
  frame_count : Int,
  sample : (Int) -> Array[@transform3d.Transform3D],
) -> BakedSkinningClip {
  let count = frame_count.max(1)
  let frames = Array::makei(count, index => {
    skeleton.compute_skinning_matrices(
      skeleton.compute_world_transforms(sample(index)),
    )
  })
  { frame_count: count, frames, }
}

///|
/// Clamp normalized playback phase and round to the nearest shared pose.
pub fn BakedSkinningClip::frame_index(
  self : BakedSkinningClip,
  phase : Double,
) -> Int {
  (phase.max(0.0).min(1.0) * (self.frame_count - 1).to_double() + 0.5).to_int()
}

///|
pub fn BakedSkinningClip::matrices(
  self : BakedSkinningClip,
  frame : Int,
) -> Array[@math3d.Mat4] {
  self.frames[frame.max(0).min(self.frame_count - 1)]
}
