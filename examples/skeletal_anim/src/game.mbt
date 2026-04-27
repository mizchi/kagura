// ============================================================
// Skeletal Animation Demo - Swaying Tentacles
// ============================================================

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
let num_bones : Int = 6

///|
let bone_length : Double = 0.5

///|
let tentacle_radius : Double = 0.12

///|
let anim_duration : Double = 4.0

///|
let num_keyframes : Int = 32

// ============================================================
// Tentacle data structure
// ============================================================

///|
struct Tentacle {
  skeleton : @skeleton3d.Skeleton
  bind_mesh : @mesh3d.Mesh3D
  skin_data : @skeleton3d.SkinData
  packed_vertex_data : Array[Double]
  player : @animation3d.AnimationPlayer
  base_position : @math3d.Vec3
  color : @math3d.Vec4
  // Per-bone local poses (mutated each frame)
  local_poses : Array[@transform3d.Transform3D]
}

// ============================================================
// Build skeleton: linear chain from root upward
// ============================================================

///|
fn build_tentacle_skeleton() -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = []
  let ibms : Array[@math3d.Mat4] = []
  // Bone 0: root at origin
  bones.push({
    name: "root",
    parent: -1,
    local_transform: @transform3d.Transform3D::new(),
  })
  // Bones 1..N-1: each translated up by bone_length from parent
  for i in 1..<num_bones {
    bones.push({
      name: "bone_" + i.to_string(),
      parent: i - 1,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, bone_length, 0.0),
      ),
    })
  }
  // Compute inverse bind matrices from rest-pose world transforms
  let rest_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<num_bones {
    rest_poses.push(bones[i].local_transform)
  }
  // Build world transforms manually for rest pose
  let world_mats : Array[@math3d.Mat4] = Array::make(
    num_bones,
    @math3d.Mat4::identity(),
  )
  for i in 0..<num_bones {
    let local_mat = rest_poses[i].to_mat4()
    let parent = bones[i].parent
    if parent < 0 {
      world_mats[i] = local_mat
    } else {
      world_mats[i] = world_mats[parent].multiply(local_mat)
    }
  }
  for i in 0..<num_bones {
    ibms.push(world_mats[i].inverse())
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

// ============================================================
// Build mesh: box-approximation cylinder segments per bone
// ============================================================

///|
fn build_tentacle_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let stride = @mesh3d.vertex3d_stride // 8: px py pz nx ny nz u v
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let joint_indices : Array[Int] = []
  let weights : Array[Double] = []
  let mut vertex_count = 0
  // For each bone segment (skip root bone 0 - it has no length)
  for bone_i in 1..<num_bones {
    let y_bottom = (bone_i - 1).to_double() * bone_length
    let y_top = bone_i.to_double() * bone_length
    // Taper: radius decreases toward tip
    let taper = 1.0 - bone_i.to_double() / num_bones.to_double() * 0.6
    let r = tentacle_radius * taper
    let base_idx = vertex_count
    // 4 sides of a box segment: front, right, back, left
    // Each face has 4 vertices and 2 triangles
    let dirs : Array[(Double, Double, Double, Double)] = [
      (r, r, 0.0, 0.0),
      (0.0, 0.0, r, r),
      (-r, -r, 0.0, 0.0),
      (0.0, 0.0, -r, -r),
    ] // (x0, x1, z0, z1) - but we define 4 faces with normals
    let normals : Array[(Double, Double, Double)] = [
      (0.0, 0.0, 1.0),
      (1.0, 0.0, 0.0),
      (0.0, 0.0, -1.0),
      (-1.0, 0.0, 0.0),
    ]
    for face in 0..<4 {
      let (nx, ny, nz) = normals[face]
      // 4 corners of this face
      let corners : Array[(Double, Double, Double)] = match face {
        0 =>
          [(-r, y_bottom, r), (r, y_bottom, r), (r, y_top, r), (-r, y_top, r)]
        1 =>
          [(r, y_bottom, r), (r, y_bottom, -r), (r, y_top, -r), (r, y_top, r)]
        2 =>
          [
            (r, y_bottom, -r),
            (-r, y_bottom, -r),
            (-r, y_top, -r),
            (r, y_top, -r),
          ]
        _ =>
          [
            (-r, y_bottom, -r),
            (-r, y_bottom, r),
            (-r, y_top, r),
            (-r, y_top, -r),
          ]
      }
      let _ = ny
      let _ = dirs
      for ci in 0..<4 {
        let (px, py, pz) = corners[ci]
        // vertex data: px py pz nx ny nz u v
        verts.push(px)
        verts.push(py)
        verts.push(pz)
        verts.push(nx)
        verts.push(0.0)
        verts.push(nz)
        verts.push(if ci == 0 || ci == 3 { 0.0 } else { 1.0 })
        verts.push(if ci < 2 { 0.0 } else { 1.0 })
        // Skinning: bottom verts -> parent bone, top verts -> current bone
        let assigned_bone = if ci < 2 {
          if bone_i - 1 > 0 {
            bone_i - 1
          } else {
            0
          }
        } else {
          bone_i
        }
        joint_indices.push(assigned_bone)
        joint_indices.push(0)
        joint_indices.push(0)
        joint_indices.push(0)
        weights.push(1.0)
        weights.push(0.0)
        weights.push(0.0)
        weights.push(0.0)
        vertex_count = vertex_count + 1
      }
      // Two triangles per face
      let fi = base_idx + face * 4
      indices.push(fi)
      indices.push(fi + 1)
      indices.push(fi + 2)
      indices.push(fi)
      indices.push(fi + 2)
      indices.push(fi + 3)
    }
  }
  // Top cap
  let y_top = (num_bones - 1).to_double() * bone_length
  let taper_top = 1.0 -
    (num_bones - 1).to_double() / num_bones.to_double() * 0.6
  let r_top = tentacle_radius * taper_top
  let cap_base = vertex_count
  let cap_corners : Array[(Double, Double, Double)] = [
    (-r_top, y_top, -r_top),
    (r_top, y_top, -r_top),
    (r_top, y_top, r_top),
    (-r_top, y_top, r_top),
  ]
  for ci in 0..<4 {
    let (px, py, pz) = cap_corners[ci]
    verts.push(px)
    verts.push(py)
    verts.push(pz)
    verts.push(0.0)
    verts.push(1.0)
    verts.push(0.0) // normal up
    verts.push(if ci == 0 || ci == 3 { 0.0 } else { 1.0 })
    verts.push(if ci < 2 { 0.0 } else { 1.0 })
    joint_indices.push(num_bones - 1)
    joint_indices.push(0)
    joint_indices.push(0)
    joint_indices.push(0)
    weights.push(1.0)
    weights.push(0.0)
    weights.push(0.0)
    weights.push(0.0)
    vertex_count = vertex_count + 1
  }
  indices.push(cap_base)
  indices.push(cap_base + 1)
  indices.push(cap_base + 2)
  indices.push(cap_base)
  indices.push(cap_base + 2)
  indices.push(cap_base + 3)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  let skin : @skeleton3d.SkinData = { joint_indices, weights, vertex_count }
  (mesh, skin)
}

// ============================================================
// Build animation: sine wave Z-rotation per bone
// ============================================================

///|
fn build_tentacle_animation(
  phase_offset : Double,
) -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = []
  for bone_i in 1..<num_bones {
    let times : Array[Double] = []
    let values : Array[Double] = []
    let amplitude = 0.3 * bone_i.to_double() / (num_bones - 1).to_double()
    let freq = 2.0 * @math.PI / anim_duration
    for k in 0..<num_keyframes {
      let t = k.to_double() / (num_keyframes - 1).to_double() * anim_duration
      times.push(t)
      let angle = amplitude *
        @math.sin(t * freq + phase_offset + bone_i.to_double() * 0.5)
      // Z-axis rotation quaternion: (0, 0, sin(a/2), cos(a/2))
      let half = angle / 2.0
      let sx = @math.sin(half)
      let cx = @math.cos(half)
      values.push(0.0) // x
      values.push(0.0) // y
      values.push(sx) // z
      values.push(cx) // w
    }
    channels.push({
      node_index: bone_i,
      target: @animation3d.Rotation,
      interpolation: @animation3d.Linear,
      times,
      values,
    })
  }
  { name: "tentacle_wave", channels, duration: anim_duration }
}

// ============================================================
// Create a Tentacle
// ============================================================

///|
fn create_tentacle(
  position : @math3d.Vec3,
  color : @math3d.Vec4,
  phase : Double,
) -> Tentacle {
  let skeleton = build_tentacle_skeleton()
  let (bind_mesh, skin_data) = build_tentacle_mesh()
  let packed_vertex_data = @skeleton3d.build_skinned_vertex_data(
    bind_mesh, skin_data,
  )
  let clip = build_tentacle_animation(phase)
  let player = @animation3d.AnimationPlayer::new(clip)
  // Initialize local poses from bone rest transforms
  let local_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<num_bones {
    local_poses.push(skeleton.bones[i].local_transform)
  }
  {
    skeleton,
    bind_mesh,
    skin_data,
    packed_vertex_data,
    player,
    base_position: position,
    color,
    local_poses,
  }
}

// ============================================================
// Compute skinning matrices for the current frame
// ============================================================

///|
fn compute_tentacle_skinning_matrices(t : Tentacle) -> Array[@math3d.Mat4] {
  // Reset local poses to rest
  for i in 0..<num_bones {
    t.local_poses[i] = t.skeleton.bones[i].local_transform
  }
  // Apply animation poses
  let poses = t.player.sample()
  for pose in poses {
    let idx = pose.node_index
    if idx >= 0 && idx < num_bones {
      match pose.rotation {
        Some(q) => t.local_poses[idx] = t.local_poses[idx].with_rotation(q)
        None => ()
      }
      match pose.translation {
        Some(v) => t.local_poses[idx] = t.local_poses[idx].with_position(v)
        None => ()
      }
      match pose.scale {
        Some(v) => t.local_poses[idx] = t.local_poses[idx].with_scale(v)
        None => ()
      }
    }
  }
  // Compute world transforms and skinning matrices
  let world_transforms = t.skeleton.compute_world_transforms(t.local_poses)
  t.skeleton.compute_skinning_matrices(world_transforms)
}

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  tentacles : Array[Tentacle]
  ground_mesh : @mesh3d.Mesh3D
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  input : @inpututil.InputHelper
  shader3d : @gfx.ShaderHandle
  shader3d_skinned : @gfx.ShaderHandle
  mut frame : Int
}

///|
fn DemoState::new() -> DemoState {
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    6.0,
    0.3,
    0.5,
    @math.PI / 4.0,
    screen_w.to_double() / screen_h.to_double(),
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.5, -1.0, -0.3),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      1.0,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.3),
  )
  let tentacles : Array[Tentacle] = [
    create_tentacle(
      @math3d.Vec3::new(0.0, 0.0, 0.0),
      @math3d.Vec4::new(0.2, 0.8, 0.3, 1.0),
      0.0,
    ),
    create_tentacle(
      @math3d.Vec3::new(-1.5, 0.0, -0.5),
      @math3d.Vec4::new(0.8, 0.3, 0.2, 1.0),
      2.0,
    ),
    create_tentacle(
      @math3d.Vec3::new(1.5, 0.0, 0.5),
      @math3d.Vec4::new(0.3, 0.4, 0.9, 1.0),
      4.0,
    ),
  ]
  {
    tentacles,
    ground_mesh: @mesh3d.Mesh3D::plane(12.0, 12.0),
    camera,
    lighting,
    input: @inpututil.new_input_helper(),
    shader3d: @gfx.new_shader_handle(10, @draw3d.shader3d_lit_untextured_wgsl()),
    shader3d_skinned: @gfx.new_shader_handle(
      11,
      @draw3d.shader3d_lit_skinned_wgsl(),
    ),
    frame: 0,
  }
}

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  self.camera = self.camera.orbit(0.003, 0.0)
  let dt = 1.0 / 60.0
  for t in self.tentacles {
    t.player.update(dt)
  }
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let objects : Array[@scene3d.Object3D] = []
  // Render each tentacle
  for t in self.tentacles {
    let skinning_matrices = compute_tentacle_skinning_matrices(t)
    objects.push(
      @scene3d.object3d(
        mesh=t.bind_mesh,
        position=t.base_position,
        color=t.color,
        skinning=Some(
          @scene3d.SkinningState::new_with_packed(
            t.skin_data,
            skinning_matrices,
            t.packed_vertex_data,
          ),
        ),
      ),
    )
  }
  // Ground plane
  objects.push(
    @scene3d.object3d(
      mesh=self.ground_mesh,
      position=@math3d.Vec3::new(0.0, -0.05, 0.0),
      color=@math3d.Vec4::new(0.4, 0.5, 0.35, 1.0),
      sort_bias=100.0,
    ),
  )
  let camera = self.camera.to_camera3d()
  let scene = @scene3d.scene3d(objects~, camera~, lighting=self.lighting)
  @renderer3d.render_scene3d_to_dst(
    scene,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
    shader3d_skinned=Some(self.shader3d_skinned),
  )
}
