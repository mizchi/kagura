///|
let zombie_clips : Array[@animation3d.AnimationClip] = Array::makei(
  3, build_zombie_clip,
)

///|
let zombie_baked_clips : Array[@scene3d.BakedSkinningClip] = zombie_clips.map(clip => {
  @scene3d.BakedSkinningClip::new(
    shared_enemy_skeleton,
    clip,
    (clip.duration * 60.0).to_int() + 1,
  )
})

///|
let zombie_pose_stride : Int = (@game.zombie_pounce_anticipation +
  @game.zombie_pounce_flight +
  @game.zombie_pounce_recovery).max(72) +
  1

///|
/// In-place poses: simulation owns horizontal movement and contact timing.
fn zombie_pose(kind : Int, t : Double) -> Array[@transform3d.Transform3D] {
  let poses = shared_enemy_skeleton.bones.map(b => b.local_transform)
  fn rotate(joint : Int, x : Double, y : Double, z : Double) -> Unit {
    poses[joint] = poses[joint].with_rotation(
      @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), y)
      .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), x))
      .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), z)),
    )
  }
  let wave = @math.sin(t * @math.PI * 2.0)
  let walking = kind == 1
  let sway = if walking { wave } else if kind == 0 { wave * 0.15 } else { 0.0 }
  let mut arm_lift = 0.0
  let mut leap = 0.0
  let mut impact = 0.0
  if kind == 2 {
    let profile = @game.Pounce.melee_profile().unwrap()
    let frame = t * (profile.windup + profile.recovery).to_double()
    let anticipation = @game.zombie_pounce_anticipation.to_double()
    if frame <= anticipation {
      let u = (frame / (anticipation * 0.8)).min(1.0)
      arm_lift = u * u * (3.0 - 2.0 * u)
    } else if frame <= profile.windup.to_double() {
      let u = (frame - anticipation) / @game.zombie_pounce_flight.to_double()
      leap = 4.0 * u * (1.0 - u) * 0.62
      arm_lift = 1.0 - u * 0.38
      impact = u
    } else {
      let u = (frame - profile.windup.to_double()) /
        profile.recovery.to_double()
      let recovery = 1.0 - u * u * (3.0 - 2.0 * u)
      arm_lift = 0.62 * recovery
      impact = recovery
    }
  }
  poses[0] = poses[0].with_position(
    @math3d.Vec3::new(
      0.0,
      leap + (if walking { 0.012 * wave * wave } else { 0.0 }),
      0.0,
    ),
  )
  rotate(
    1,
    0.30 - arm_lift * 0.18 + impact * 0.20,
    sway * 0.04,
    -0.06 + sway * 0.035,
  )
  rotate(2, 0.42 - arm_lift * 0.35, 0.06, 0.11 - arm_lift * 0.07)
  for joint in [3, 5] {
    let p = poses[joint].position
    poses[joint] = poses[joint].with_position(
      @math3d.Vec3::new(
        p.x,
        p.y - 0.045 * (1.0 - arm_lift) + arm_lift * 0.04,
        p.z + 0.025,
      ),
    )
  }
  rotate(3, -0.20 - arm_lift * 2.60 + sway * 0.11, 0.0, -0.16 - arm_lift * 0.13)
  rotate(4, -0.14 - arm_lift * 0.20, 0.0, -0.07)
  rotate(5, -0.08 - arm_lift * 2.72 - sway * 0.08, 0.0, 0.10 + arm_lift * 0.19)
  rotate(6, -0.08 - arm_lift * 0.20, 0.0, 0.04)
  // Left leg takes a step; the nearly straight right leg trails along the floor.
  rotate(7, if walking { wave * 0.38 } else { -leap * 0.65 }, 0.0, -0.025)
  rotate(8, if walking { wave.max(0.0) * 0.36 } else { leap * 0.75 }, 0.0, 0.0)
  rotate(
    9,
    0.08 + (if walking { -wave * 0.09 } else { leap * 0.22 }),
    0.0,
    0.025,
  )
  rotate(
    10,
    0.02 + (if walking { (-wave).max(0.0) * 0.025 } else { leap * 0.40 }),
    0.0,
    0.0,
  )
  poses
}

///|
fn build_zombie_clip(kind : Int) -> @animation3d.AnimationClip {
  let frames = if kind == 2 {
    @game.zombie_pounce_anticipation +
    @game.zombie_pounce_flight +
    @game.zombie_pounce_recovery
  } else {
    72
  }
  let times = Array::makei(frames + 1, i => i.to_double() / 60.0)
  let samples = Array::makei(frames + 1, i => {
    zombie_pose(kind, i.to_double() / frames.to_double())
  })
  let channels : Array[@animation3d.AnimChannel] = []
  for joint in 0..<enemy_bone_count {
    let rotations : Array[Double] = []
    let translations : Array[Double] = []
    for pose in samples {
      let q = pose[joint].rotation
      let p = pose[joint].position
      rotations.append([q.x, q.y, q.z, q.w])
      translations.append([p.x, p.y, p.z])
    }
    channels.push({
      node_index: joint,
      target: @animation3d.Rotation,
      interpolation: @animation3d.Linear,
      times,
      values: rotations,
    })
    if joint == 0 || joint == 3 || joint == 5 {
      channels.push({
        node_index: joint,
        target: @animation3d.Translation,
        interpolation: @animation3d.Linear,
        times,
        values: translations,
      })
    }
  }
  {
    name: ["zombie_idle", "zombie_shamble", "zombie_pounce"][kind],
    channels,
    duration: frames.to_double() / 60.0,
  }
}

///|
fn zombie_pose_key(enemy : @game.Enemy) -> Int {
  if enemy.attack_motion == @game.Pounce {
    return 2 * zombie_pose_stride +
      zombie_baked_clips[2].frame_index(
        enemy.attack_frame.to_double() /
        (enemy.attack_windup + enemy.attack_recovery).to_double(),
      )
  }
  if enemy.move_speed < 0.01 || enemy.stagger_frames > 0 {
    return 0
  }
  let cycles = enemy.travel_distance / @game.zombie_stride_distance
  zombie_pose_stride +
  zombie_baked_clips[1].frame_index(cycles - cycles.floor())
}

///|
fn zombie_skinning_for_key(key : Int) -> Array[@math3d.Mat4] {
  zombie_baked_clips[key / zombie_pose_stride].matrices(
    key % zombie_pose_stride,
  )
}
