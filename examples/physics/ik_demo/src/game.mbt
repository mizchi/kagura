// ============================================================
// IK & Animation State Machine Demo
// ============================================================
// 1. Two-Bone IK: 3-bone arm tracking a circling target
// 2. FABRIK: 6-bone tentacle tracking a separate target
// 3. AnimationStateMachine3D: idle↔walk with crossfade

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
let arm_bone_length : Double = 0.8

///|
let tentacle_bones : Int = 6

///|
let tentacle_bone_len : Double = 0.5

///|
let tentacle_radius : Double = 0.08

// ============================================================
// Build 3-bone arm skeleton (shoulder → elbow → hand along +Y)
// ============================================================

///|
fn build_arm_skeleton() -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = [
    {
      name: "shoulder",
      parent: -1,
      local_transform: @transform3d.Transform3D::new(),
    },
    {
      name: "elbow",
      parent: 0,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, arm_bone_length, 0.0),
      ),
    },
    {
      name: "hand",
      parent: 1,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, arm_bone_length, 0.0),
      ),
    },
  ]
  let rest_poses : Array[@transform3d.Transform3D] = []
  for b in bones {
    rest_poses.push(b.local_transform)
  }
  let world : Array[@math3d.Mat4] = Array::make(3, @math3d.Mat4::identity())
  for i in 0..<3 {
    let local_mat = rest_poses[i].to_mat4()
    let parent = bones[i].parent
    if parent < 0 {
      world[i] = local_mat
    } else {
      world[i] = world[parent].multiply(local_mat)
    }
  }
  let ibms : Array[@math3d.Mat4] = []
  for i in 0..<3 {
    ibms.push(world[i].inverse())
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

///|
fn build_arm_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let r = 0.15
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let joint_indices : Array[Int] = []
  let weights : Array[Double] = []
  let mut vc = 0
  for bone_i in 1..<3 {
    let y_bottom = (bone_i - 1).to_double() * arm_bone_length
    let y_top = bone_i.to_double() * arm_bone_length
    let base_idx = vc
    let normals : Array[(Double, Double, Double)] = [
      (0.0, 0.0, 1.0),
      (1.0, 0.0, 0.0),
      (0.0, 0.0, -1.0),
      (-1.0, 0.0, 0.0),
    ]
    for face in 0..<4 {
      let (nx, _, nz) = normals[face]
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
      for ci in 0..<4 {
        let (px, py, pz) = corners[ci]
        verts.push(px)
        verts.push(py)
        verts.push(pz)
        verts.push(nx)
        verts.push(0.0)
        verts.push(nz)
        verts.push(0.0)
        verts.push(0.0)
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
        vc = vc + 1
      }
      let fi = base_idx + face * 4
      indices.push(fi)
      indices.push(fi + 1)
      indices.push(fi + 2)
      indices.push(fi)
      indices.push(fi + 2)
      indices.push(fi + 3)
    }
  }
  // Top cap (hand tip)
  let y_top = 2.0 * arm_bone_length
  let cap_base = vc
  let cap_corners : Array[(Double, Double, Double)] = [
    (-r, y_top, -r),
    (r, y_top, -r),
    (r, y_top, r),
    (-r, y_top, r),
  ]
  for ci in 0..<4 {
    let (px, py, pz) = cap_corners[ci]
    verts.push(px)
    verts.push(py)
    verts.push(pz)
    verts.push(0.0)
    verts.push(1.0)
    verts.push(0.0)
    verts.push(0.0)
    verts.push(0.0)
    joint_indices.push(2)
    joint_indices.push(0)
    joint_indices.push(0)
    joint_indices.push(0)
    weights.push(1.0)
    weights.push(0.0)
    weights.push(0.0)
    weights.push(0.0)
    vc = vc + 1
  }
  indices.push(cap_base)
  indices.push(cap_base + 1)
  indices.push(cap_base + 2)
  indices.push(cap_base)
  indices.push(cap_base + 2)
  indices.push(cap_base + 3)
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  let skin : @skeleton3d.SkinData = { joint_indices, weights, vertex_count: vc }
  (mesh, skin)
}

// ============================================================
// Build 6-bone tentacle skeleton (along +Y)
// ============================================================

///|
fn build_tentacle_skeleton() -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = []
  for i in 0..<tentacle_bones {
    let parent = if i == 0 { -1 } else { i - 1 }
    let lt = if i == 0 {
      @transform3d.Transform3D::new()
    } else {
      @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, tentacle_bone_len, 0.0),
      )
    }
    bones.push({ name: "t_" + i.to_string(), parent, local_transform: lt })
  }
  let rest : Array[@transform3d.Transform3D] = []
  for b in bones {
    rest.push(b.local_transform)
  }
  let world : Array[@math3d.Mat4] = Array::make(
    tentacle_bones,
    @math3d.Mat4::identity(),
  )
  for i in 0..<tentacle_bones {
    let lm = rest[i].to_mat4()
    let p = bones[i].parent
    if p < 0 {
      world[i] = lm
    } else {
      world[i] = world[p].multiply(lm)
    }
  }
  let ibms : Array[@math3d.Mat4] = []
  for i in 0..<tentacle_bones {
    ibms.push(world[i].inverse())
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

///|
fn build_tentacle_mesh() -> (@mesh3d.Mesh3D, @skeleton3d.SkinData) {
  let verts : Array[Double] = []
  let indices : Array[Int] = []
  let joint_indices : Array[Int] = []
  let wts : Array[Double] = []
  let mut vc = 0
  for seg in 1..<tentacle_bones {
    let y0 = (seg - 1).to_double() * tentacle_bone_len
    let y1 = seg.to_double() * tentacle_bone_len
    let taper = 1.0 - seg.to_double() / tentacle_bones.to_double() * 0.6
    let r = tentacle_radius * taper
    let base = vc
    let normals : Array[(Double, Double, Double)] = [
      (0.0, 0.0, 1.0),
      (1.0, 0.0, 0.0),
      (0.0, 0.0, -1.0),
      (-1.0, 0.0, 0.0),
    ]
    for face in 0..<4 {
      let (nx, _, nz) = normals[face]
      let corners : Array[(Double, Double, Double)] = match face {
        0 => [(-r, y0, r), (r, y0, r), (r, y1, r), (-r, y1, r)]
        1 => [(r, y0, r), (r, y0, -r), (r, y1, -r), (r, y1, r)]
        2 => [(r, y0, -r), (-r, y0, -r), (-r, y1, -r), (r, y1, -r)]
        _ => [(-r, y0, -r), (-r, y0, r), (-r, y1, r), (-r, y1, -r)]
      }
      for ci in 0..<4 {
        let (px, py, pz) = corners[ci]
        verts.push(px)
        verts.push(py)
        verts.push(pz)
        verts.push(nx)
        verts.push(0.0)
        verts.push(nz)
        verts.push(0.0)
        verts.push(0.0)
        let bone = if ci < 2 { seg - 1 } else { seg }
        joint_indices.push(bone)
        joint_indices.push(0)
        joint_indices.push(0)
        joint_indices.push(0)
        wts.push(1.0)
        wts.push(0.0)
        wts.push(0.0)
        wts.push(0.0)
        vc = vc + 1
      }
      let fi = base + face * 4
      indices.push(fi)
      indices.push(fi + 1)
      indices.push(fi + 2)
      indices.push(fi)
      indices.push(fi + 2)
      indices.push(fi + 3)
    }
  }
  let mesh = @mesh3d.Mesh3D::new(verts, indices)
  let skin : @skeleton3d.SkinData = {
    joint_indices,
    weights: wts,
    vertex_count: vc,
  }
  (mesh, skin)
}

// ============================================================
// Build idle/walk animation clips
// ============================================================

///|
fn build_idle_clip() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = [
    {
      node_index: 0,
      target: @animation3d.Translation,
      interpolation: @animation3d.Linear,
      times: [0.0, 1.0, 2.0],
      values: [0.0, 0.0, 0.0, 0.0, 0.05, 0.0, 0.0, 0.0, 0.0],
    },
  ]
  { name: "idle", channels, duration: 2.0 }
}

///|
fn build_walk_clip() -> @animation3d.AnimationClip {
  let channels : Array[@animation3d.AnimChannel] = [
    {
      node_index: 0,
      target: @animation3d.Translation,
      interpolation: @animation3d.Linear,
      times: [0.0, 0.5, 1.0],
      values: [0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    },
  ]
  { name: "walk", channels, duration: 1.0 }
}

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  // Two-bone IK arm
  arm_skeleton : @skeleton3d.Skeleton
  arm_bind_mesh : @mesh3d.Mesh3D
  arm_skin : @skeleton3d.SkinData
  arm_poses : Array[@transform3d.Transform3D]
  // FABRIK tentacle
  fab_skeleton : @skeleton3d.Skeleton
  fab_bind_mesh : @mesh3d.Mesh3D
  fab_skin : @skeleton3d.SkinData
  fab_poses : Array[@transform3d.Transform3D]
  // Animation state machine
  state_machine : @animation3d.AnimationStateMachine3D
  sm_poses : Array[@transform3d.Transform3D]
  // Rendering
  ground_mesh : @mesh3d.Mesh3D
  mut camera : @camera3d.OrbitCamera
  lighting : @light3d.LightingEnvironment
  input : @inpututil.InputHelper
  shader3d : @gfx.ShaderHandle
  mut frame : Int
  mut time : Double
}

///|
fn DemoState::new() -> DemoState {
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    5.0,
    0.4,
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
  // Two-bone arm
  let arm_skeleton = build_arm_skeleton()
  let (arm_bind_mesh, arm_skin) = build_arm_mesh()
  let arm_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<3 {
    arm_poses.push(arm_skeleton.bones[i].local_transform)
  }
  // FABRIK tentacle
  let fab_skeleton = build_tentacle_skeleton()
  let (fab_bind_mesh, fab_skin) = build_tentacle_mesh()
  let fab_poses : Array[@transform3d.Transform3D] = []
  for i in 0..<tentacle_bones {
    fab_poses.push(fab_skeleton.bones[i].local_transform)
  }
  // Animation state machine
  let clips : Map[String, @animation3d.AnimationClip] = Map([])
  clips["idle"] = build_idle_clip()
  clips["walk"] = build_walk_clip()
  let transitions : Array[@animation3d.AnimTransition3D] = [
    {
      from_state: "idle",
      to_state: "walk",
      trigger: "move",
      blend_duration: 0.5,
    },
    {
      from_state: "walk",
      to_state: "idle",
      trigger: "stop",
      blend_duration: 0.5,
    },
  ]
  let state_machine = @animation3d.AnimationStateMachine3D::new(
    clips, transitions, "idle",
  )
  let sm_poses : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::new(),
  ]
  {
    arm_skeleton,
    arm_bind_mesh,
    arm_skin,
    arm_poses,
    fab_skeleton,
    fab_bind_mesh,
    fab_skin,
    fab_poses,
    state_machine,
    sm_poses,
    ground_mesh: @mesh3d.Mesh3D::plane(16.0, 16.0),
    camera,
    lighting,
    input: @inpututil.new_input_helper(),
    shader3d: @gfx.new_shader_handle(10, @draw3d.shader3d_lit_untextured_wgsl()),
    frame: 0,
    time: 0.0,
  }
}

///|
fn DemoState::update(self : DemoState, snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, snapshot)
  self.frame = self.frame + 1
  self.time = self.time + 1.0 / 60.0
  self.camera = self.camera.orbit(0.003, 0.0)
  let dt = 1.0 / 60.0
  // -- Two-Bone IK: target circles at close range to force visible bending --
  // arm total length = 2 * 0.8 = 1.6, target at ~0.8 to force ~90° bend
  let ik_target = @math3d.Vec3::new(
    @math.cos(self.time * 0.8) * 0.6,
    0.6 + @math.sin(self.time * 0.5) * 0.3,
    @math.sin(self.time * 0.6) * 0.4,
  )
  // Reset arm poses each frame
  for i in 0..<3 {
    self.arm_poses[i] = self.arm_skeleton.bones[i].local_transform
  }
  let ik_result = @ik3d.solve_two_bone_ik({
    skeleton: self.arm_skeleton,
    local_poses: self.arm_poses,
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target: ik_target,
    pole_target: None,
  })
  for i in 0..<3 {
    self.arm_poses[i] = ik_result.local_poses[i]
  }
  // -- FABRIK: tentacle target moves in skeleton-local space --
  // Total tentacle length = 5 * 0.5 = 2.5
  let fab_target = @math3d.Vec3::new(
    @math.sin(self.time * 0.8) * 1.0,
    1.5 + @math.cos(self.time * 1.2) * 0.8,
    @math.sin(self.time * 0.5) * 0.5,
  )
  // Reset tentacle poses
  for i in 0..<tentacle_bones {
    self.fab_poses[i] = self.fab_skeleton.bones[i].local_transform
  }
  let chain : Array[Int] = []
  for i in 0..<tentacle_bones {
    chain.push(i)
  }
  let fab_result = @ik3d.solve_fabrik({
    skeleton: self.fab_skeleton,
    local_poses: self.fab_poses,
    chain,
    target: fab_target,
    tolerance: 0.01,
    max_iterations: 10,
  })
  for i in 0..<tentacle_bones {
    self.fab_poses[i] = fab_result.local_poses[i]
  }
  // -- Animation State Machine: toggle idle/walk every 3 seconds --
  let cycle = (self.time / 3.0).to_int() % 2
  if cycle == 0 && self.state_machine.current_state_name() == "walk" {
    let _ = self.state_machine.trigger("stop")
  } else if cycle == 1 && self.state_machine.current_state_name() == "idle" {
    let _ = self.state_machine.trigger("move")
  }
  self.state_machine.update(dt)
  let sm_node_poses = self.state_machine.sample()
  self.sm_poses[0] = @transform3d.Transform3D::new()
  @animation3d.apply_node_poses(self.sm_poses, sm_node_poses)
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let objects : Array[@scene3d.Object3D] = []
  // -- Two-Bone IK arm (left) --
  let arm_world = self.arm_skeleton.compute_world_transforms(self.arm_poses)
  let arm_skin_mats = self.arm_skeleton.compute_skinning_matrices(arm_world)
  let skinned_arm = @skeleton3d.apply_skin(
    self.arm_bind_mesh,
    self.arm_skin,
    arm_skin_mats,
  )
  objects.push(
    @scene3d.object3d(
      mesh=skinned_arm,
      position=@math3d.Vec3::new(-1.5, 0.0, 0.0),
      color=@math3d.Vec4::new(0.3, 0.5, 0.9, 1.0),
    ),
  )
  // -- FABRIK tentacle (right) --
  let fab_world = self.fab_skeleton.compute_world_transforms(self.fab_poses)
  let fab_skin_mats = self.fab_skeleton.compute_skinning_matrices(fab_world)
  let skinned_fab = @skeleton3d.apply_skin(
    self.fab_bind_mesh,
    self.fab_skin,
    fab_skin_mats,
  )
  objects.push(
    @scene3d.object3d(
      mesh=skinned_fab,
      position=@math3d.Vec3::new(1.5, 0.0, 0.0),
      color=@math3d.Vec4::new(0.2, 0.8, 0.4, 1.0),
    ),
  )
  // -- Animated cube (State Machine, center) --
  let sm_pos = self.sm_poses[0].position
  let cube = @mesh3d.Mesh3D::cube(0.5)
  objects.push(
    @scene3d.object3d(
      mesh=cube,
      position=@math3d.Vec3::new(sm_pos.x, 0.25 + sm_pos.y, sm_pos.z - 3.0),
      color=@math3d.Vec4::new(0.8, 0.3, 0.6, 1.0),
    ),
  )
  // -- Ground plane --
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
  )
}
