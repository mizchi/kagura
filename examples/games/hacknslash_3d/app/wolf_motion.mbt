///|
let wolf_clips : Array[@animation3d.AnimationClip] = [
  build_wolf_clip(0),
  build_wolf_clip(1),
  build_wolf_clip(2),
]

///|
let wolf_baked_clips : Array[@scene3d.BakedSkinningClip] = Array::makei(3, i => {
  @scene3d.BakedSkinningClip::new(
    wolf_skeleton,
    wolf_clips[i],
    if i == 2 {
      65
    } else {
      33
    },
  )
})

///|
let wolf_rest_skinning : Array[@math3d.Mat4] = Array::makei(15, _ => {
  @math3d.Mat4::identity()
})

///|
// Gaits are in-place. Actual displacement controls playback in the game.
fn wolf_pose(kind : Int, t : Double) -> Array[@transform3d.Transform3D] {
  let poses = wolf_skeleton.bones.map(b => b.local_transform)
  fn rotate(joint : Int, x : Double, y : Double, z : Double) -> Unit {
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), y)
      .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), x))
      .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), z))
    poses[joint] = poses[joint].with_rotation(q)
  }
  if kind == 2 {
    let profile = @game.Bite.melee_profile().unwrap()
    let contact = profile.windup.to_double() /
      (profile.windup + profile.recovery).to_double()
    let phase = if t <= contact {
      t / contact * 0.5
    } else {
      0.5 + (t - contact) / (1.0 - contact) * 0.5
    }
    let open = if phase < 0.35 {
      phase / 0.35
    } else if phase < 0.5 {
      (0.5 - phase) / 0.15
    } else {
      0.0
    }
    let snap = if phase < 0.35 {
      -phase / 0.35 * 0.065
    } else if phase < 0.5 {
      -0.065 + (phase - 0.35) / 0.15 * 0.30
    } else if phase < 0.7 {
      0.235 * (0.7 - phase) / 0.2
    } else {
      0.0
    }
    poses[0] = poses[0].with_position(
      @math3d.Vec3::new(0.0, 0.025 * open, snap),
    )
    rotate(2, -0.28 * open + snap * 0.8, 0.0, 0.0)
    rotate(3, -0.22 * open + snap * 0.35, 0.0, 0.0)
    rotate(4, open * 0.78, 0.0, 0.0)
    rotate(5, -0.16 * open, 0.0, 0.0)
    for joint in [7, 9] {
      rotate(joint, -snap * 0.8, 0.0, 0.0)
    }
    for joint in [11, 13] {
      rotate(joint, snap * 0.7, 0.0, 0.0)
    }
    return poses
  }
  let running = kind == 1
  let phase = t * @math.PI * 2.0
  let wave = @math.sin(phase)
  let lift = if running {
    0.075 + wave * 0.025
  } else {
    0.02 + wave * wave * 0.015
  }
  poses[0] = poses[0].with_position(@math3d.Vec3::new(0.0, lift, 0.0))
  rotate(
    1,
    if running {
      wave * 0.06
    } else {
      0.0
    },
    0.0,
    if running {
      0.0
    } else {
      wave * 0.025
    },
  )
  rotate(2, if running { -wave * 0.08 } else { wave * 0.025 }, 0.0, 0.0)
  rotate(3, if running { wave * 0.05 } else { -wave * 0.025 }, 0.0, 0.0)
  rotate(5, if running { -0.15 + wave * 0.08 } else { 0.0 }, wave * 0.15, 0.0)
  rotate(6, 0.0, @math.sin(phase - 0.4) * 0.16, 0.0)
  for i, joint in [7, 9, 11, 13] {
    let offset = if running {
      [0.0, 0.3, @math.PI, @math.PI + 0.3][i]
    } else {
      [0.0, @math.PI, @math.PI * 1.5, @math.PI * 0.5][i]
    }
    let stride = @math.sin(phase + offset)
    rotate(joint, stride * (if running { 0.70 } else { 0.36 }), 0.0, 0.0)
    rotate(
      joint + 1,
      stride.max(0.0) * (if running { 0.55 } else { 0.28 }),
      0.0,
      0.0,
    )
  }
  poses
}

///|
fn build_wolf_clip(kind : Int) -> @animation3d.AnimationClip {
  let profile = @game.Bite.melee_profile().unwrap()
  let frames = if kind == 2 {
    profile.windup + profile.recovery
  } else if kind == 1 {
    30
  } else {
    54
  }
  let duration = frames.to_double() / 60.0
  let times = Array::makei(frames + 1, i => i.to_double() / 60.0)
  let samples = Array::makei(frames + 1, i => {
    wolf_pose(kind, i.to_double() / frames.to_double())
  })
  let channels : Array[@animation3d.AnimChannel] = []
  for joint in 0..<15 {
    let rotations : Array[Double] = []
    for sample in samples {
      let q = sample[joint].rotation
      rotations.append([q.x, q.y, q.z, q.w])
    }
    channels.push({
      node_index: joint,
      target: @animation3d.Rotation,
      interpolation: @animation3d.Linear,
      times,
      values: rotations,
    })
  }
  let translations : Array[Double] = []
  for sample in samples {
    let p = sample[0].position
    translations.append([p.x, p.y, p.z])
  }
  channels.push({
    node_index: 0,
    target: @animation3d.Translation,
    interpolation: @animation3d.Linear,
    times,
    values: translations,
  })
  { name: ["wolf_walk", "wolf_run", "wolf_bite"][kind], channels, duration, }
}

///|
let wolf_pose_stride : Int = 65

///|
fn wolf_pose_key(enemy : @game.Enemy) -> Int {
  if enemy.attack_motion == @game.Bite {
    return 2 * wolf_pose_stride +
      wolf_baked_clips[2].frame_index(
        enemy.attack_frame.to_double() /
        (enemy.attack_windup + enemy.attack_recovery).to_double(),
      )
  }
  if enemy.move_speed < 0.01 || enemy.stagger_frames > 0 {
    return 3 * wolf_pose_stride
  }
  let running = enemy.move_speed > enemy.speed * 0.55
  let kind = if running { 1 } else { 0 }
  let cycles = enemy.travel_distance / (if running { 28.0 } else { 16.0 })
  kind * wolf_pose_stride +
  wolf_baked_clips[kind].frame_index(cycles - cycles.floor())
}

///|
fn wolf_skinning_for_key(key : Int) -> Array[@math3d.Mat4] {
  if key >= 3 * wolf_pose_stride {
    wolf_rest_skinning
  } else {
    wolf_baked_clips[key / wolf_pose_stride].matrices(key % wolf_pose_stride)
  }
}
