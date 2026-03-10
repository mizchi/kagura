// Procedural skeletal character: humanoid body + sword with attack animation
// Bones: root(0) -> torso(1) -> r_upper_arm(2) -> r_forearm(3) -> sword(4)
// Designed to be replaceable with a glTF model later.

///|
let char_num_bones : Int = 5

// Bone dimensions

///|
let torso_height : Double = 0.3

///|
let upper_arm_len : Double = 0.15

///|
let forearm_len : Double = 0.15

///|
let sword_len : Double = 0.35

// Animation

///|
let idle_anim_duration : Double = 2.0

///|
let attack_anim_duration : Double = 0.3

///|
let run_anim_duration : Double = 0.5

///|
let hurt_anim_duration : Double = 0.25

///|
let idle_num_keyframes : Int = 16

///|
let attack_num_keyframes : Int = 8

///|
let run_num_keyframes : Int = 12

///|
let hurt_num_keyframes : Int = 6

///|
enum CharAnimState {
  Idle
  Attacking
  Running
  Hurt
} derive(Eq)

///|
struct PlayerCharacter {
  skeleton : @skeleton3d.Skeleton
  bind_mesh : @mesh3d.Mesh3D
  skin_data : @skeleton3d.SkinData
  packed_vertex_data : Array[Double]
  mut anim_state : CharAnimState
  idle_player : @animation3d.AnimationPlayer
  attack_player : @animation3d.AnimationPlayer
  run_player : @animation3d.AnimationPlayer
  hurt_player : @animation3d.AnimationPlayer
  local_poses : Array[@transform3d.Transform3D]
}

// Build skeleton

///|
fn build_character_skeleton() -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = []
  let ibms : Array[@math3d.Mat4] = []
  // Bone 0: root at origin
  bones.push({
    name: "root",
    parent: -1,
    local_transform: @transform3d.Transform3D::new(),
  })
  // Bone 1: torso, up from root
  bones.push({
    name: "torso",
    parent: 0,
    local_transform: @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, torso_height, 0.0),
    ),
  })
  // Bone 2: right upper arm, offset to right and slightly down from torso top
  bones.push({
    name: "r_upper_arm",
    parent: 1,
    local_transform: @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.15, 0.0, 0.0),
    ),
  })
  // Bone 3: right forearm
  bones.push({
    name: "r_forearm",
    parent: 2,
    local_transform: @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, -upper_arm_len, 0.0),
    ),
  })
  // Bone 4: sword, extends from forearm
  bones.push({
    name: "sword",
    parent: 3,
    local_transform: @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, -forearm_len, 0.0),
    ),
  })
  // Compute inverse bind matrices
  let rest_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<char_num_bones {
    rest_poses.push(bones[i].local_transform)
  }
  let world_mats : Array[@math3d.Mat4] = Array::make(
    char_num_bones,
    @math3d.Mat4::identity(),
  )
  for i in 0..<char_num_bones {
    let local_mat = rest_poses[i].to_mat4()
    let parent = bones[i].parent
    if parent < 0 {
      world_mats[i] = local_mat
    } else {
      world_mats[i] = world_mats[parent].multiply(local_mat)
    }
  }
  for i in 0..<char_num_bones {
    ibms.push(world_mats[i].inverse())
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

// Helper: add a box segment to mesh data

///|
fn add_box_segment(
  verts : Array[Double],
  indices : Array[Int],
  joint_indices : Array[Int],
  weights : Array[Double],
  vertex_count : Ref[Int],
  x0 : Double,
  y0 : Double,
  z0 : Double,
  x1 : Double,
  y1 : Double,
  z1 : Double,
  bone_bottom : Int,
  bone_top : Int,
) -> Unit {
  // 8 corners of box
  let corners : Array[(Double, Double, Double)] = [
    (x0, y0, z1),
    (x1, y0, z1),
    (x1, y1, z1),
    (x0, y1, z1), // front
    (x0, y0, z0),
    (x1, y0, z0),
    (x1, y1, z0),
    (x0, y1, z0), // back
  ]
  // 6 faces: front, back, right, left, top, bottom
  let faces : Array[(Int, Int, Int, Int, Double, Double, Double)] = [
    (0, 1, 2, 3, 0.0, 0.0, 1.0), // front
    (5, 4, 7, 6, 0.0, 0.0, -1.0), // back
    (1, 5, 6, 2, 1.0, 0.0, 0.0), // right
    (4, 0, 3, 7, -1.0, 0.0, 0.0), // left
    (3, 2, 6, 7, 0.0, 1.0, 0.0), // top
    (4, 5, 1, 0, 0.0, -1.0, 0.0), // bottom
  ]
  let y_mid = (y0 + y1) / 2.0
  for face in faces {
    let (i0, i1, i2, i3, nx, ny, nz) = face
    let base = vertex_count.val
    let face_corners = [corners[i0], corners[i1], corners[i2], corners[i3]]
    for ci in 0..<4 {
      let (px, py, pz) = face_corners[ci]
      verts.push(px)
      verts.push(py)
      verts.push(pz)
      verts.push(nx)
      verts.push(ny)
      verts.push(nz)
      verts.push(if ci == 0 || ci == 3 { 0.0 } else { 1.0 })
      verts.push(if ci < 2 { 0.0 } else { 1.0 })
      // Skinning: assign based on y position
      let bone = if py < y_mid { bone_bottom } else { bone_top }
      joint_indices.push(bone)
      joint_indices.push(0)
      joint_indices.push(0)
      joint_indices.push(0)
      weights.push(1.0)
      weights.push(0.0)
      weights.push(0.0)
      weights.push(0.0)
      vertex_count.val = vertex_count.val + 1
    }
    indices.push(base)
    indices.push(base + 1)
    indices.push(base + 2)
    indices.push(base)
    indices.push(base + 2)
    indices.push(base + 3)
  }
}

///|
fn build_character_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let joint_indices : Array[Int] = []
  let weights_arr : Array[Double] = []
  let vc = Ref::new(0)
  // Body/torso: box from y=0 to y=torso_height+0.1
  let bw = 0.12 // half width
  let bd = 0.08 // half depth
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    -bw,
    0.0,
    -bd,
    bw,
    torso_height + 0.1,
    bd,
    0,
    1, // root to torso
  )
  // Head: small box on top
  let hw = 0.07
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    -hw,
    torso_height + 0.1,
    -hw,
    hw,
    torso_height + 0.22,
    hw,
    1,
    1, // all torso bone
  )
  // Left arm (static, attached to torso)
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    -bw - 0.06,
    torso_height - 0.05,
    -0.03,
    -bw,
    torso_height + 0.05,
    0.03,
    1,
    1, // torso bone
  )
  // Right upper arm
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    bw,
    torso_height,
    -0.03,
    bw + 0.06,
    torso_height - upper_arm_len,
    0.03,
    2,
    2, // r_upper_arm
  )
  // Right forearm
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    bw,
    torso_height - upper_arm_len,
    -0.025,
    bw + 0.05,
    torso_height - upper_arm_len - forearm_len,
    0.025,
    3,
    3, // r_forearm
  )
  // Sword blade (from forearm tip downward)
  let sy_top = torso_height - upper_arm_len - forearm_len
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    bw + 0.01,
    sy_top,
    -0.01,
    bw + 0.04,
    sy_top - sword_len,
    0.01,
    4,
    4, // sword bone
  )
  // Sword guard (crossguard)
  add_box_segment(
    verts,
    indices,
    joint_indices,
    weights_arr,
    vc,
    bw - 0.02,
    sy_top,
    -0.025,
    bw + 0.07,
    sy_top - 0.02,
    0.025,
    4,
    4, // sword bone
  )
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  let skin : @skeleton3d.SkinData = {
    joint_indices,
    weights: weights_arr,
    vertex_count: vc.val,
  }
  (mesh, skin)
}

// Idle animation: subtle torso sway

///|
fn build_idle_animation() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  // Torso gentle Y-axis rotation
  let times : Array[Double] = []
  let values : Array[Double] = []
  for k in 0..<idle_num_keyframes {
    let t = k.to_double() /
      (idle_num_keyframes - 1).to_double() *
      idle_anim_duration
    times.push(t)
    let angle = 0.05 * @math.sin(t * 2.0 * @math.PI / idle_anim_duration)
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), angle)
    values.push(q.x)
    values.push(q.y)
    values.push(q.z)
    values.push(q.w)
  }
  channels.push({
    node_index: 1, // torso
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times,
    values,
  })
  { name: "idle", channels, duration: idle_anim_duration }
}

// Attack animation: arm swings forward with sword

///|
fn build_attack_animation() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  // Upper arm rotation: swing forward (X-axis rotation)
  let arm_times : Array[Double] = []
  let arm_values : Array[Double] = []
  for k in 0..<attack_num_keyframes {
    let t = k.to_double() /
      (attack_num_keyframes - 1).to_double() *
      attack_anim_duration
    arm_times.push(t)
    // Wind up then swing: starts at 0.3rad back, swings to -1.2rad forward
    let progress = t / attack_anim_duration
    let angle = if progress < 0.2 {
      // Wind up
      0.3 * (progress / 0.2)
    } else {
      // Swing forward
      let swing_t = (progress - 0.2) / 0.8
      0.3 - 1.5 * swing_t
    }
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), angle)
    arm_values.push(q.x)
    arm_values.push(q.y)
    arm_values.push(q.z)
    arm_values.push(q.w)
  }
  channels.push({
    node_index: 2, // r_upper_arm
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times: arm_times,
    values: arm_values,
  })
  // Forearm: additional forward swing
  let fa_times : Array[Double] = []
  let fa_values : Array[Double] = []
  for k in 0..<attack_num_keyframes {
    let t = k.to_double() /
      (attack_num_keyframes - 1).to_double() *
      attack_anim_duration
    fa_times.push(t)
    let progress = t / attack_anim_duration
    let angle = if progress < 0.3 {
      0.0
    } else {
      let swing_t = (progress - 0.3) / 0.7
      -0.8 * swing_t
    }
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), angle)
    fa_values.push(q.x)
    fa_values.push(q.y)
    fa_values.push(q.z)
    fa_values.push(q.w)
  }
  channels.push({
    node_index: 3, // r_forearm
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times: fa_times,
    values: fa_values,
  })
  // Torso: slight forward lean during attack
  let torso_times : Array[Double] = []
  let torso_values : Array[Double] = []
  for k in 0..<attack_num_keyframes {
    let t = k.to_double() /
      (attack_num_keyframes - 1).to_double() *
      attack_anim_duration
    torso_times.push(t)
    let progress = t / attack_anim_duration
    let angle = if progress < 0.3 {
      0.0
    } else {
      -0.15 * ((progress - 0.3) / 0.7)
    }
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), angle)
    torso_values.push(q.x)
    torso_values.push(q.y)
    torso_values.push(q.z)
    torso_values.push(q.w)
  }
  channels.push({
    node_index: 1, // torso
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times: torso_times,
    values: torso_values,
  })
  { name: "attack", channels, duration: attack_anim_duration }
}

// Run animation: torso bob + arm swing

///|
fn build_run_animation() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  // Root: vertical bob (up/down while running)
  let root_times : Array[Double] = []
  let root_values : Array[Double] = []
  for k in 0..<run_num_keyframes {
    let t = k.to_double() /
      (run_num_keyframes - 1).to_double() *
      run_anim_duration
    root_times.push(t)
    let phase = t * 2.0 * @math.PI / run_anim_duration * 2.0 // 2 bobs per cycle
    let y_offset = @math.sin(phase).abs() * 0.03
    root_values.push(0.0)
    root_values.push(y_offset)
    root_values.push(0.0)
  }
  channels.push({
    node_index: 0, // root
    target: @animation3d.Translation,
    interpolation: @animation3d.Linear,
    times: root_times,
    values: root_values,
  })
  // Torso: slight forward lean + side-to-side sway
  let torso_times : Array[Double] = []
  let torso_values : Array[Double] = []
  for k in 0..<run_num_keyframes {
    let t = k.to_double() /
      (run_num_keyframes - 1).to_double() *
      run_anim_duration
    torso_times.push(t)
    let phase = t * 2.0 * @math.PI / run_anim_duration
    let lean = -0.12 // constant forward lean
    let sway = 0.06 * @math.sin(phase * 2.0) // side sway
    let qx = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), lean)
    let qz = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), sway)
    let q = qx.multiply(qz)
    torso_values.push(q.x)
    torso_values.push(q.y)
    torso_values.push(q.z)
    torso_values.push(q.w)
  }
  channels.push({
    node_index: 1, // torso
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times: torso_times,
    values: torso_values,
  })
  // Right arm: swing back and forth
  let arm_times : Array[Double] = []
  let arm_values : Array[Double] = []
  for k in 0..<run_num_keyframes {
    let t = k.to_double() /
      (run_num_keyframes - 1).to_double() *
      run_anim_duration
    arm_times.push(t)
    let phase = t * 2.0 * @math.PI / run_anim_duration
    let angle = 0.4 * @math.sin(phase) // arm swing
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_z(), angle)
    arm_values.push(q.x)
    arm_values.push(q.y)
    arm_values.push(q.z)
    arm_values.push(q.w)
  }
  channels.push({
    node_index: 2, // r_upper_arm
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times: arm_times,
    values: arm_values,
  })
  { name: "run", channels, duration: run_anim_duration }
}

// Hurt animation: torso jerks back then recovers

///|
fn build_hurt_animation() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  let times : Array[Double] = []
  let values : Array[Double] = []
  for k in 0..<hurt_num_keyframes {
    let t = k.to_double() /
      (hurt_num_keyframes - 1).to_double() *
      hurt_anim_duration
    times.push(t)
    let progress = t / hurt_anim_duration
    // Quick jerk back then recovery
    let angle = if progress < 0.2 {
      -0.3 * (progress / 0.2) // fast lean back
    } else {
      -0.3 * (1.0 - (progress - 0.2) / 0.8) // slow recovery
    }
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_x(), angle)
    values.push(q.x)
    values.push(q.y)
    values.push(q.z)
    values.push(q.w)
  }
  channels.push({
    node_index: 1, // torso
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times,
    values,
  })
  { name: "hurt", channels, duration: hurt_anim_duration }
}

///|
fn PlayerCharacter::new() -> PlayerCharacter {
  let skeleton = build_character_skeleton()
  let (bind_mesh, skin_data) = build_character_mesh()
  let packed_vertex_data = @skeleton3d.build_skinned_vertex_data(
    bind_mesh, skin_data,
  )
  let idle_clip = build_idle_animation()
  let attack_clip = build_attack_animation()
  let run_clip = build_run_animation()
  let hurt_clip = build_hurt_animation()
  let idle_player = @animation3d.AnimationPlayer::new(idle_clip)
  idle_player.set_looping(true)
  idle_player.play()
  let attack_player = @animation3d.AnimationPlayer::new(attack_clip)
  attack_player.set_looping(false)
  let run_player = @animation3d.AnimationPlayer::new(run_clip)
  run_player.set_looping(true)
  run_player.play()
  let hurt_player = @animation3d.AnimationPlayer::new(hurt_clip)
  hurt_player.set_looping(false)
  let local_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<char_num_bones {
    local_poses.push(skeleton.bones[i].local_transform)
  }
  {
    skeleton,
    bind_mesh,
    skin_data,
    packed_vertex_data,
    anim_state: Idle,
    idle_player,
    attack_player,
    run_player,
    hurt_player,
    local_poses,
  }
}

///|
fn PlayerCharacter::trigger_attack(self : PlayerCharacter) -> Unit {
  self.anim_state = Attacking
  self.attack_player.set_time(0.0)
  self.attack_player.play()
}

///|
fn PlayerCharacter::trigger_hurt(self : PlayerCharacter) -> Unit {
  if self.anim_state != Attacking {
    self.anim_state = Hurt
    self.hurt_player.set_time(0.0)
    self.hurt_player.play()
  }
}

///|
fn PlayerCharacter::set_moving(self : PlayerCharacter, moving : Bool) -> Unit {
  if self.anim_state == Attacking || self.anim_state == Hurt {
    return
  }
  if moving && self.anim_state != Running {
    self.anim_state = Running
  } else if not(moving) && self.anim_state == Running {
    self.anim_state = Idle
  }
}

///|
fn PlayerCharacter::update(self : PlayerCharacter, dt : Double) -> Unit {
  match self.anim_state {
    Attacking => {
      self.attack_player.update(dt)
      if not(self.attack_player.playing) {
        self.anim_state = Idle
      }
    }
    Hurt => {
      self.hurt_player.update(dt)
      if not(self.hurt_player.playing) {
        self.anim_state = Idle
      }
    }
    Running => self.run_player.update(dt)
    Idle => self.idle_player.update(dt)
  }
}

///|
fn PlayerCharacter::compute_skinning(
  self : PlayerCharacter,
) -> Array[@math3d.Mat4] {
  // Reset to rest pose
  for i in 0..<char_num_bones {
    self.local_poses[i] = self.skeleton.bones[i].local_transform
  }
  // Apply current animation
  let poses = match self.anim_state {
    Attacking => self.attack_player.sample()
    Hurt => self.hurt_player.sample()
    Running => self.run_player.sample()
    Idle => self.idle_player.sample()
  }
  for pose in poses {
    let idx = pose.node_index
    if idx >= 0 && idx < char_num_bones {
      match pose.rotation {
        Some(q) =>
          self.local_poses[idx] = self.local_poses[idx].with_rotation(q)
        None => ()
      }
      match pose.translation {
        Some(v) =>
          self.local_poses[idx] = self.local_poses[idx].with_position(v)
        None => ()
      }
    }
  }
  let world_transforms = self.skeleton.compute_world_transforms(
    self.local_poses,
  )
  self.skeleton.compute_skinning_matrices(world_transforms)
}
