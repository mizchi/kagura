// Procedural enemy models with skeletal animation
// Shared 3-bone skeleton: root(0) -> body(1) -> head(2)
// Each enemy kind gets a different mesh with unique proportions and decorations.

let enemy_bone_count : Int = 3

let enemy_idle_duration : Double = 1.5

let enemy_idle_keyframes : Int = 12

// Per-kind mesh data (pre-built, shared across instances)
struct EnemyMeshData {
  bind_mesh : @mesh3d.Mesh3D
  skin_data : @skeleton3d.SkinData
  packed_vertex_data : Array[Double]
}

// All enemy models
struct EnemyModels {
  skeleton : @skeleton3d.Skeleton
  idle_player : @animation3d.AnimationPlayer
  local_poses : Array[@transform3d.Transform3D]
  basic : EnemyMeshData
  fast : EnemyMeshData
  tank : EnemyMeshData
  ranged : EnemyMeshData
  boss : EnemyMeshData
}

// Build shared enemy skeleton parameterized by body height
fn build_enemy_skeleton(body_h : Double, head_offset : Double) -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = []
  // root
  bones.push({
    name: "root",
    parent: -1,
    local_transform: @transform3d.Transform3D::new(),
  })
  // body
  bones.push({
    name: "body",
    parent: 0,
    local_transform: @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, body_h, 0.0),
    ),
  })
  // head
  bones.push({
    name: "head",
    parent: 1,
    local_transform: @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, head_offset, 0.0),
    ),
  })
  let rest_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<enemy_bone_count {
    rest_poses.push(bones[i].local_transform)
  }
  let world_mats : Array[@math3d.Mat4] = Array::make(
    enemy_bone_count,
    @math3d.Mat4::identity(),
  )
  for i in 0..<enemy_bone_count {
    let local_mat = rest_poses[i].to_mat4()
    let parent = bones[i].parent
    if parent < 0 {
      world_mats[i] = local_mat
    } else {
      world_mats[i] = world_mats[parent].multiply(local_mat)
    }
  }
  let ibms : Array[@math3d.Mat4] = []
  for i in 0..<enemy_bone_count {
    ibms.push(world_mats[i].inverse())
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

// Build enemy mesh with parameterized dimensions
fn build_enemy_body_mesh(
  body_w : Double,
  body_h : Double,
  body_d : Double,
  head_size : Double,
  head_y : Double,
) -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let joint_indices : Array[Int] = []
  let weights_arr : Array[Double] = []
  let vc = Ref::new(0)
  // Body box
  add_box_segment(
    verts, indices, joint_indices, weights_arr, vc,
    -body_w, 0.0, -body_d, body_w, body_h, body_d,
    0, 1,
  )
  // Head box
  let hs = head_size
  add_box_segment(
    verts, indices, joint_indices, weights_arr, vc,
    -hs, head_y, -hs, hs, head_y + head_size * 1.2, hs,
    2, 2,
  )
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  let skin : @skeleton3d.SkinData = {
    joint_indices,
    weights: weights_arr,
    vertex_count: vc.val,
  }
  (mesh, skin)
}

// Specialized mesh builders per enemy kind

fn build_basic_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let ji : Array[Int] = []
  let wa : Array[Double] = []
  let vc = Ref::new(0)
  // Body
  add_box_segment(verts, indices, ji, wa, vc,
    -0.12, 0.0, -0.1, 0.12, 0.35, 0.1, 0, 1)
  // Head
  add_box_segment(verts, indices, ji, wa, vc,
    -0.07, 0.35, -0.07, 0.07, 0.48, 0.07, 2, 2)
  // Arms (static, both sides)
  add_box_segment(verts, indices, ji, wa, vc,
    -0.18, 0.15, -0.04, -0.12, 0.32, 0.04, 1, 1)
  add_box_segment(verts, indices, ji, wa, vc,
    0.12, 0.15, -0.04, 0.18, 0.32, 0.04, 1, 1)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  (mesh, { joint_indices: ji, weights: wa, vertex_count: vc.val })
}

fn build_fast_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let ji : Array[Int] = []
  let wa : Array[Double] = []
  let vc = Ref::new(0)
  // Lean body
  add_box_segment(verts, indices, ji, wa, vc,
    -0.08, 0.0, -0.06, 0.08, 0.28, 0.06, 0, 1)
  // Small head
  add_box_segment(verts, indices, ji, wa, vc,
    -0.05, 0.28, -0.05, 0.05, 0.38, 0.05, 2, 2)
  // Blades on sides (speed fins)
  add_box_segment(verts, indices, ji, wa, vc,
    -0.16, 0.12, -0.01, -0.08, 0.25, 0.01, 1, 1)
  add_box_segment(verts, indices, ji, wa, vc,
    0.08, 0.12, -0.01, 0.16, 0.25, 0.01, 1, 1)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  (mesh, { joint_indices: ji, weights: wa, vertex_count: vc.val })
}

fn build_tank_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let ji : Array[Int] = []
  let wa : Array[Double] = []
  let vc = Ref::new(0)
  // Wide heavy body
  add_box_segment(verts, indices, ji, wa, vc,
    -0.2, 0.0, -0.15, 0.2, 0.45, 0.15, 0, 1)
  // Head (small relative to body)
  add_box_segment(verts, indices, ji, wa, vc,
    -0.08, 0.45, -0.08, 0.08, 0.55, 0.08, 2, 2)
  // Shoulder plates
  add_box_segment(verts, indices, ji, wa, vc,
    -0.28, 0.32, -0.1, -0.2, 0.45, 0.1, 1, 1)
  add_box_segment(verts, indices, ji, wa, vc,
    0.2, 0.32, -0.1, 0.28, 0.45, 0.1, 1, 1)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  (mesh, { joint_indices: ji, weights: wa, vertex_count: vc.val })
}

fn build_ranged_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let ji : Array[Int] = []
  let wa : Array[Double] = []
  let vc = Ref::new(0)
  // Robed body (slightly wider at bottom)
  add_box_segment(verts, indices, ji, wa, vc,
    -0.1, 0.0, -0.08, 0.1, 0.3, 0.08, 0, 1)
  // Head (hooded)
  add_box_segment(verts, indices, ji, wa, vc,
    -0.07, 0.3, -0.07, 0.07, 0.42, 0.07, 2, 2)
  // Hood peak
  add_box_segment(verts, indices, ji, wa, vc,
    -0.04, 0.42, -0.04, 0.04, 0.48, 0.04, 2, 2)
  // Staff (right side)
  add_box_segment(verts, indices, ji, wa, vc,
    0.12, 0.0, -0.015, 0.15, 0.5, 0.015, 1, 1)
  // Staff orb
  add_box_segment(verts, indices, ji, wa, vc,
    0.1, 0.48, -0.03, 0.17, 0.55, 0.03, 1, 1)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  (mesh, { joint_indices: ji, weights: wa, vertex_count: vc.val })
}

fn build_boss_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let ji : Array[Int] = []
  let wa : Array[Double] = []
  let vc = Ref::new(0)
  // Massive body
  add_box_segment(verts, indices, ji, wa, vc,
    -0.3, 0.0, -0.2, 0.3, 0.6, 0.2, 0, 1)
  // Head with horns
  add_box_segment(verts, indices, ji, wa, vc,
    -0.12, 0.6, -0.1, 0.12, 0.78, 0.1, 2, 2)
  // Left horn
  add_box_segment(verts, indices, ji, wa, vc,
    -0.18, 0.72, -0.03, -0.12, 0.9, 0.03, 2, 2)
  // Right horn
  add_box_segment(verts, indices, ji, wa, vc,
    0.12, 0.72, -0.03, 0.18, 0.9, 0.03, 2, 2)
  // Arms
  add_box_segment(verts, indices, ji, wa, vc,
    -0.42, 0.2, -0.08, -0.3, 0.55, 0.08, 1, 1)
  add_box_segment(verts, indices, ji, wa, vc,
    0.3, 0.2, -0.08, 0.42, 0.55, 0.08, 1, 1)
  // Weapon (great sword, right side)
  add_box_segment(verts, indices, ji, wa, vc,
    0.35, 0.0, -0.02, 0.4, 0.7, 0.02, 1, 1)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  (mesh, { joint_indices: ji, weights: wa, vertex_count: vc.val })
}

fn build_mesh_data(
  skeleton : @skeleton3d.Skeleton,
  mesh : @mesh3d.Mesh3D,
  skin : @skeleton3d.SkinData,
) -> EnemyMeshData {
  // Recompute packed data with *this* skeleton's IBM (all share same structure)
  let _ = skeleton
  let packed = @skeleton3d.build_skinned_vertex_data(mesh, skin)
  { bind_mesh: mesh, skin_data: skin, packed_vertex_data: packed }
}

// Shared idle animation for enemies (body sway)
fn build_enemy_idle_animation() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  // Body Y-axis sway
  let times : Array[Double] = []
  let values : Array[Double] = []
  for k in 0..<enemy_idle_keyframes {
    let t = k.to_double() / (enemy_idle_keyframes - 1).to_double() * enemy_idle_duration
    times.push(t)
    let angle = 0.08 * @math.sin(t * 2.0 * @math.PI / enemy_idle_duration)
    let q = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), angle)
    values.push(q.x)
    values.push(q.y)
    values.push(q.z)
    values.push(q.w)
  }
  channels.push({
    node_index: 1,
    target: @animation3d.Rotation,
    interpolation: @animation3d.Linear,
    times,
    values,
  })
  { name: "enemy_idle", channels, duration: enemy_idle_duration }
}

fn EnemyModels::new() -> EnemyModels {
  // Use default skeleton proportions (body_h=0.35, head_offset=0.0)
  let skeleton = build_enemy_skeleton(0.35, 0.0)
  let idle_clip = build_enemy_idle_animation()
  let idle_player = @animation3d.AnimationPlayer::new(idle_clip)
  idle_player.set_looping(true)
  idle_player.play()
  let local_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<enemy_bone_count {
    local_poses.push(skeleton.bones[i].local_transform)
  }
  let (basic_mesh, basic_skin) = build_basic_mesh()
  let (fast_mesh, fast_skin) = build_fast_mesh()
  let (tank_mesh, tank_skin) = build_tank_mesh()
  let (ranged_mesh, ranged_skin) = build_ranged_mesh()
  let (boss_mesh, boss_skin) = build_boss_mesh()
  {
    skeleton,
    idle_player,
    local_poses,
    basic: build_mesh_data(skeleton, basic_mesh, basic_skin),
    fast: build_mesh_data(skeleton, fast_mesh, fast_skin),
    tank: build_mesh_data(skeleton, tank_mesh, tank_skin),
    ranged: build_mesh_data(skeleton, ranged_mesh, ranged_skin),
    boss: build_mesh_data(skeleton, boss_mesh, boss_skin),
  }
}

fn EnemyModels::update(self : EnemyModels, dt : Double) -> Unit {
  self.idle_player.update(dt)
}

fn EnemyModels::get_mesh_data(self : EnemyModels, kind : EnemyKind) -> EnemyMeshData {
  match kind {
    Fast => self.fast
    Tank => self.tank
    Ranged => self.ranged
    Boss => self.boss
    Basic => self.basic
  }
}

fn EnemyModels::compute_skinning(self : EnemyModels) -> Array[@math3d.Mat4] {
  for i in 0..<enemy_bone_count {
    self.local_poses[i] = self.skeleton.bones[i].local_transform
  }
  let poses = self.idle_player.sample()
  for pose in poses {
    let idx = pose.node_index
    if idx >= 0 && idx < enemy_bone_count {
      match pose.rotation {
        Some(q) => self.local_poses[idx] = self.local_poses[idx].with_rotation(q)
        None => ()
      }
      match pose.translation {
        Some(v) => self.local_poses[idx] = self.local_poses[idx].with_position(v)
        None => ()
      }
    }
  }
  let world_transforms = self.skeleton.compute_world_transforms(self.local_poses)
  self.skeleton.compute_skinning_matrices(world_transforms)
}
