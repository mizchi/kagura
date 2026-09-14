///|
/// Forty-eight shared palettes cover standing, seated breathing and getting up.
/// Quantized poses retain instancing; only the upper body breathes while idle.
fn enemy_rest_key(enemy : @game.Enemy, frame : Int) -> Int {
  let camp = enemy.camp
  let resting = camp.map(c => c.awareness != @game.Alert).or(false)
  let seated = resting && camp.unwrap().pose == @game.Sitting
  let phase = match camp {
    Some({ awareness: @game.Waking(n), .. }) =>
      8 + ((36 - n) * 15 / 35).clamp(min=0, max=15)
    _ => (frame / 20 + camp.map(c => c.pack_id % 2 * 4).or(0)) % 8
  }
  -1 - (if seated { 24 } else { 0 }) - phase
}

///|
fn rest_pose_parameters(index : Int) -> (Double, Double) {
  let phase = index % 24
  let seated = if index >= 24 {
    if phase < 8 {
      1.0
    } else {
      let t = (phase - 8).to_double() / 15.0
      1.0 - t * t * (3.0 - 2.0 * t)
    }
  } else {
    0.0
  }
  let breath = if phase < 8 {
    @math.sin(phase.to_double() * @math.PI / 4.0)
  } else {
    0.0
  }
  (seated, breath)
}

///|
fn biped_rest_pose(
  index : Int,
  zombie : Bool,
) -> Array[@transform3d.Transform3D] {
  let poses = shared_enemy_skeleton.bones.map(b => b.local_transform)
  let (sit, breath) = rest_pose_parameters(index)
  fn rotate(joint : Int, x : Double, y : Double, z : Double) -> Unit {
    poses[joint] = poses[joint].with_rotation(
      @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), y)
      .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), x))
      .multiply(@math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), z)),
    )
  }
  poses[0] = poses[0].with_position(@math3d.Vec3::new(0.0, -0.14 * sit, 0.0))
  rotate(
    1,
    (if zombie { 0.32 } else { 0.025 }) + sit * 0.20 + breath * 0.012,
    breath * 0.008,
    0.0,
  )
  rotate(
    2,
    (if zombie { 0.40 } else { 0.02 }) + sit * 0.12,
    -breath * 0.025,
    0.0,
  )
  rotate(3, -0.07 - sit * 0.64, 0.0, -0.06)
  rotate(4, -0.10 - sit * 0.55, 0.0, 0.0)
  rotate(5, -0.07 - sit * 0.64, 0.0, 0.06)
  rotate(6, -0.10 - sit * 0.55, 0.0, 0.0)
  for joint in [7, 9] {
    rotate(joint, -1.25 * sit, 0.0, 0.0)
  }
  for joint in [8, 10] {
    rotate(joint, 1.25 * sit, 0.0, 0.0)
  }
  poses[15] = poses[15].with_scale(@math3d.Vec3::zero())
  poses
}

///|
fn wolf_camp_pose(index : Int) -> Array[@transform3d.Transform3D] {
  let poses = wolf_skeleton.bones.map(b => b.local_transform)
  let (lie, breath) = rest_pose_parameters(index)
  fn rotate(joint : Int, x : Double, z : Double) -> Unit {
    poses[joint] = poses[joint].with_rotation(
      @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), x).multiply(
        @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), z),
      ),
    )
  }
  poses[0] = poses[0].with_position(
    @math3d.Vec3::new(0.0, -0.32 * lie * lie, 0.0),
  )
  rotate(1, breath * 0.012, 0.0)
  rotate(2, 0.12 * lie + breath * 0.008, 0.0)
  rotate(3, 0.25 * lie, 0.0)
  rotate(5, 0.32 * lie, 0.0)
  for i, joint in [7, 9, 11, 13] {
    rotate(
      joint,
      (if i < 2 { -1.50 } else { 0.70 }) * lie,
      lie * (if i % 2 == 0 { -0.12 } else { 0.12 }),
    )
    rotate(joint + 1, (if i < 2 { 2.80 } else { -1.40 }) * lie, 0.0)
  }
  poses
}

///|
let biped_rest_clip : @scene3d.BakedSkinningClip = @scene3d.BakedSkinningClip::from_pose_sampler(
  shared_enemy_skeleton,
  48,
  i => biped_rest_pose(i, false),
)

///|
let zombie_rest_clip : @scene3d.BakedSkinningClip = @scene3d.BakedSkinningClip::from_pose_sampler(
  shared_enemy_skeleton,
  48,
  i => biped_rest_pose(i, true),
)

///|
let wolf_camp_clip : @scene3d.BakedSkinningClip = @scene3d.BakedSkinningClip::from_pose_sampler(
  wolf_skeleton, 48, wolf_camp_pose,
)
