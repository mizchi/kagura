// ============================================================
// GPU path (render_scene3d_gpu) tests
// ============================================================

///|
test "render_scene3d_gpu generates commands for visible objects" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_true(cmds.length() > 0)
}

///|
test "render_scene3d_gpu returns empty for empty scene" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(objects=[], camera~)
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "render_scene3d_gpu culls objects behind camera" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(0.0, 0.0, 20.0),
        color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      ),
    ],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "render_scene3d_gpu culls objects far to the side" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(100.0, 0.0, 0.0),
        color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      ),
    ],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "render_scene3d_gpu: 1 object = 1 command (no batching)" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[
      object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)),
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(2.0, 0.0, 0.0),
        color=@math3d.Vec4::new(0.0, 0.0, 1.0, 1.0),
      ),
    ],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  // GPU path: exactly 1 command per visible object, no color batching
  assert_eq(cmds.length(), 2)
}

///|
test "render_scene3d_gpu material with texture sets src_image_ids" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let mat = Material::new(
    color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
    src_image_id=42,
  )
  let scene = scene3d(
    objects=[object3d(mesh=cube, material=Some(mat))],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].src_image_ids.length(), 1)
  assert_eq(cmds[0].src_image_ids[0], 42)
}

///|
test "render_scene3d_gpu skinned object uses skinned shader path" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let shader3d_skinned = @gfx.new_shader_handle(11, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let skin = @skeleton3d.SkinData::{
    joint_indices: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
    vertex_count: 3,
  }
  let skinning = SkinningState::new(skin, [@math3d.Mat4::identity()])
  let scene = scene3d(
    objects=[object3d(mesh~, skinning=Some(skinning))],
    camera~,
  )
  let cmds = render_scene3d_gpu(
    scene,
    dst,
    shader3d,
    640,
    480,
    shader3d_skinned=Some(shader3d_skinned),
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned.id)
  assert_eq(cmds[0].vertex_data.length(), 3 * 16)
  assert_eq(cmds[0].uniform_dwords.length(), 56 + 4 + 64 * 16)
}

///|
test "render_scene3d_gpu skinned object falls back without skinned shader" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let skin = @skeleton3d.SkinData::{
    joint_indices: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
    vertex_count: 3,
  }
  let skinning = SkinningState::new(skin, [@math3d.Mat4::identity()])
  let scene = scene3d(
    objects=[object3d(mesh~, skinning=Some(skinning))],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d.id)
  assert_eq(cmds[0].vertex_data.length(), mesh.vertex_data.length())
  assert_eq(cmds[0].uniform_dwords.length(), 56)
}

///|
test "render_scene3d_gpu skinned object uses prepacked vertex data when provided" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let shader3d_skinned = @gfx.new_shader_handle(11, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let skin = @skeleton3d.SkinData::{
    joint_indices: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
    vertex_count: 3,
  }
  let prepacked = Array::make(3 * 16, 0.0)
  prepacked[0] = 123.0
  prepacked[3] = 9.0
  let skinning = SkinningState::new_with_packed(
    skin,
    [@math3d.Mat4::identity()],
    prepacked,
  )
  let scene = scene3d(
    objects=[object3d(mesh~, skinning=Some(skinning))],
    camera~,
  )
  let cmds = render_scene3d_gpu(
    scene,
    dst,
    shader3d,
    640,
    480,
    shader3d_skinned=Some(shader3d_skinned),
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned.id)
  assert_eq(cmds[0].vertex_data.length(), prepacked.length())
  assert_eq(cmds[0].vertex_data[0], 123.0)
  assert_eq(cmds[0].vertex_data[3], 9.0)
}

///|
test "render_scene3d_gpu respects sort_bias draw ordering" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let near_mat = Material::new(src_image_id=1)
  let far_mat = Material::new(src_image_id=2)
  let scene = scene3d(
    objects=[
      object3d(mesh=cube, material=Some(near_mat), sort_bias=0.0),
      object3d(mesh=cube, material=Some(far_mat), sort_bias=100.0),
    ],
    camera~,
  )
  let cmds = render_scene3d_gpu(scene, dst, shader3d, 640, 480)
  assert_eq(cmds.length(), 2)
  assert_eq(cmds[0].src_image_ids[0], 2)
  assert_eq(cmds[1].src_image_ids[0], 1)
}

// ============================================================
// Instanced rendering tests
// ============================================================

///|
test "render_instanced_gpu creates single command with instance_count" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let instances = [
    InstanceData::new(
      transform=@transform3d.Transform3D::new(),
      color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    ),
    InstanceData::new(
      transform=@transform3d.Transform3D::new().translate(
        @math3d.Vec3::new(2.0, 0.0, 0.0),
      ),
      color=@math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ),
    InstanceData::new(
      transform=@transform3d.Transform3D::new().translate(
        @math3d.Vec3::new(-2.0, 0.0, 0.0),
      ),
      color=@math3d.Vec4::new(0.0, 0.0, 1.0, 1.0),
    ),
  ]
  let cmd = render_instanced_gpu(
    cube, instances, camera, dst, shader3d, 640, 480,
  )
  // Should be a single command with instance_count=3
  assert_eq(cmd.instance_count, 3)
  // Mesh data should be the cube data
  assert_eq(cmd.vertex_data.length(), 24 * @mesh3d.vertex3d_stride)
  assert_eq(cmd.indices.length(), 36)
}

///|
test "render_instanced_gpu with 1 instance" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d = @gfx.new_shader_handle(10, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let instances = [
    InstanceData::new(color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)),
  ]
  let cmd = render_instanced_gpu(
    cube, instances, camera, dst, shader3d, 640, 480,
  )
  assert_eq(cmd.instance_count, 1)
}
