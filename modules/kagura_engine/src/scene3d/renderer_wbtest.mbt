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
test "transform_aabb handles translated negative scale" {
  let model = @math3d.Mat4::translation(10.0, -2.0, 3.0).multiply(
    @math3d.Mat4::scaling(-2.0, 3.0, 4.0),
  )
  let (min_x, min_y, min_z, max_x, max_y, max_z) = transform_aabb(
    -1.0, -2.0, -3.0, 1.0, 2.0, 3.0, model,
  )
  assert_eq(min_x, 8.0)
  assert_eq(max_x, 12.0)
  assert_eq(min_y, -8.0)
  assert_eq(max_y, 4.0)
  assert_eq(min_z, -9.0)
  assert_eq(max_z, 15.0)
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

///|
test "push_object3d_gpu_commands emits one command for visible object" {
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
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_object3d_gpu_commands(
    object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)),
    camera,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
}

///|
test "push_object3d_gpu_commands culls invisible object" {
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
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_object3d_gpu_commands(
    object3d(
      mesh=cube,
      position=@math3d.Vec3::new(0.0, 0.0, 20.0),
      color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    ),
    camera,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 0)
}

///|
test "push_scene3d_gpu_commands reuses single camera/frustum setup for object list" {
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
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_scene3d_gpu_commands(
    [
      object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)),
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(2.0, 0.0, 0.0),
        color=@math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
      ),
    ],
    camera,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 2)
}

///|
test "push_skinned_mesh_gpu_commands uses packed vertices and culls per instance" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(11, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(12, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let packed = Array::make(3 * 16, 0.0)
  packed[0] = 123.0
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands(
    mesh,
    [
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
      @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(1000.0, 0.0, 0.0),
      ),
    ],
    [
      @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ],
    packed,
    [@math3d.Mat4::identity()],
    camera,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned.id)
  assert_eq(cmds[0].vertex_data[0], 123.0)
  assert_eq(cmds[0].instance_count, 1)
  assert_eq(cmds[0].uniform_dwords.length(), 56 + 4 + 64 * 16)
}

///|
test "push_skinned_mesh_gpu_commands uses instanced shader for multiple visible instances" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(13, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(14, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let packed = Array::make(3 * 16, 0.0)
  packed[0] = 321.0
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands(
    mesh,
    [
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
    ],
    [
      @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ],
    packed,
    [@math3d.Mat4::identity()],
    camera,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned_instanced.id)
  assert_eq(cmds[0].vertex_data[0], 321.0)
  assert_eq(cmds[0].instance_count, 2)
  assert_eq(
    cmds[0].uniform_dwords.length(),
    16 + 12 + 4 + 64 * 16 + 4 + 64 * 20,
  )
}

///|
test "push_skinned_mesh_gpu_commands_from_matrices_with_uniform_color uses monochrome shader" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(15, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(16, "")
  let shader3d_skinned_instanced_monochrome = @gfx.new_shader_handle(17, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let packed = Array::make(3 * 16, 0.0)
  packed[0] = 456.0
  let view_projection = @math3d.Mat4::identity()
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands_from_matrices_with_uniform_color_and_view_projection(
    mesh,
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    @math3d.Vec4::new(0.8, 0.7, 0.6, 1.0),
    packed,
    [@math3d.Mat4::identity()],
    view_projection,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    shader3d_skinned_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned_instanced_monochrome.id)
  assert_eq(cmds[0].instance_count, 2)
  assert_eq(
    cmds[0].uniform_dwords.length(),
    16 + 12 + 4 + 64 * 16 + 4 + 4 + 64 * 16,
  )
}

///|
test "push_instanced_mesh_gpu_commands_from_matrices_with_uniform_color uses monochrome shader" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_colored = @gfx.new_shader_handle(18, "")
  let shader3d_instanced_monochrome = @gfx.new_shader_handle(19, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_instanced_mesh_gpu_commands_from_matrices_with_uniform_color_and_view_projection(
    mesh,
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    @math3d.Vec4::new(0.6, 0.7, 0.8, 1.0),
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_colored,
    shader3d_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_instanced_monochrome.id)
  assert_eq(cmds[0].instance_count, 2)
  assert_eq(cmds[0].uniform_dwords.length(), 16 + 12 + 4 + 4 + 64 * 16)
}

///|
test "uniform_instance_color returns None for mixed colors" {
  let result = uniform_instance_color([
    @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
  ])
  assert_true(result is None)
}

///|
test "push_instanced_mesh_gpu_commands_with_color_optimization uses monochrome shader for uniform colors" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_colored = @gfx.new_shader_handle(20, "")
  let shader3d_instanced = @gfx.new_shader_handle(21, "")
  let shader3d_instanced_monochrome = @gfx.new_shader_handle(22, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
    mesh,
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    [
      @math3d.Vec4::new(0.6, 0.7, 0.8, 1.0),
      @math3d.Vec4::new(0.6, 0.7, 0.8, 1.0),
    ],
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_colored,
    shader3d_instanced,
    shader3d_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_instanced_monochrome.id)
}

///|
test "push_instanced_mesh_gpu_commands_with_color_optimization uses colored instanced shader for mixed colors" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_colored = @gfx.new_shader_handle(23, "")
  let shader3d_instanced = @gfx.new_shader_handle(24, "")
  let shader3d_instanced_monochrome = @gfx.new_shader_handle(25, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
    mesh,
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    [
      @math3d.Vec4::new(0.6, 0.7, 0.8, 1.0),
      @math3d.Vec4::new(0.8, 0.2, 0.1, 1.0),
    ],
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_colored,
    shader3d_instanced,
    shader3d_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_instanced.id)
}

///|
test "push_instanced_instance_data_gpu_commands_with_color_optimization uses monochrome shader for uniform colors" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_colored = @gfx.new_shader_handle(123, "")
  let shader3d_instanced = @gfx.new_shader_handle(124, "")
  let shader3d_instanced_monochrome = @gfx.new_shader_handle(125, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_instanced_instance_data_gpu_commands_with_color_optimization_and_view_projection(
    mesh,
    [
      InstanceData::new(
        transform=@transform3d.Transform3D::new(),
        color=@math3d.Vec4::new(0.2, 0.4, 0.6, 1.0),
      ),
      InstanceData::new(
        transform=@transform3d.Transform3D::new().translate(
          @math3d.Vec3::new(1.0, 0.0, 0.0),
        ),
        color=@math3d.Vec4::new(0.2, 0.4, 0.6, 1.0),
      ),
    ],
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_colored,
    shader3d_instanced,
    shader3d_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_instanced_monochrome.id)
}

///|
test "push_instanced_instance_data_gpu_commands_with_color_optimization uses colored shader for mixed colors" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_colored = @gfx.new_shader_handle(126, "")
  let shader3d_instanced = @gfx.new_shader_handle(127, "")
  let shader3d_instanced_monochrome = @gfx.new_shader_handle(128, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_instanced_instance_data_gpu_commands_with_color_optimization_and_view_projection(
    mesh,
    [
      InstanceData::new(
        transform=@transform3d.Transform3D::new(),
        color=@math3d.Vec4::new(0.2, 0.4, 0.6, 1.0),
      ),
      InstanceData::new(
        transform=@transform3d.Transform3D::new().translate(
          @math3d.Vec3::new(1.0, 0.0, 0.0),
        ),
        color=@math3d.Vec4::new(0.8, 0.1, 0.2, 1.0),
      ),
    ],
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_colored,
    shader3d_instanced,
    shader3d_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_instanced.id)
}

///|
test "push_skinned_mesh_gpu_commands_with_color_optimization uses monochrome shader for uniform colors" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(26, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(27, "")
  let shader3d_skinned_instanced_monochrome = @gfx.new_shader_handle(28, "")
  let mesh = @mesh3d.Mesh3D::new(
    [
      -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 1.0,
    ],
    [0, 1, 2],
  )
  let packed = Array::make(3 * 16, 0.0)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(
    mesh,
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    [
      @math3d.Vec4::new(0.8, 0.7, 0.6, 1.0),
      @math3d.Vec4::new(0.8, 0.7, 0.6, 1.0),
    ],
    packed,
    [@math3d.Mat4::identity()],
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    shader3d_skinned_instanced_monochrome,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned_instanced_monochrome.id)
}

///|
test "push_single_skinned_mesh_gpu_command emits one command for visible mesh" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(12, "")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let packed = Array::make(24 * 16, 0.0)
  packed[0] = 456.0
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_single_skinned_mesh_gpu_command(
    mesh,
    @transform3d.Transform3D::new(),
    @math3d.Vec4::new(0.0, 1.0, 0.8, 1.0),
    packed,
    [@math3d.Mat4::identity()],
    camera,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned.id)
  assert_eq(cmds[0].vertex_data[0], 456.0)
}

///|
test "push_single_skinned_mesh_gpu_command_with_view_projection emits one command for visible mesh" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(17, "")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let packed = Array::make(24 * 16, 0.0)
  packed[0] = 987.0
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_single_skinned_mesh_gpu_command_with_view_projection(
    mesh,
    @transform3d.Transform3D::new(),
    @math3d.Vec4::new(0.2, 0.7, 0.9, 1.0),
    packed,
    [@math3d.Mat4::identity()],
    camera.view_projection_matrix(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned.id)
  assert_eq(cmds[0].vertex_data[0], 987.0)
}

///|
test "push_skinned_mesh_gpu_commands_with_view_projection reuses precomputed frustum" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(15, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(16, "")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let vp = camera.view_projection_matrix()
  let packed = Array::make(24 * 16, 0.0)
  packed[0] = 654.0
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands_with_view_projection(
    mesh,
    [
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
    ],
    [
      @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ],
    packed,
    [@math3d.Mat4::identity()],
    vp,
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned_instanced.id)
  assert_eq(cmds[0].vertex_data[0], 654.0)
  assert_eq(cmds[0].instance_count, 2)
}

///|
test "push_skinned_mesh_gpu_commands_from_matrices_with_view_projection emits instanced command" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(21, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(22, "")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let packed = Array::make(24 * 16, 0.0)
  packed[0] = 321.0
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands_from_matrices_with_view_projection(
    mesh,
    [
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)).to_mat4(),
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)).to_mat4(),
    ],
    [
      @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ],
    packed,
    [@math3d.Mat4::identity()],
    camera.view_projection_matrix(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].shader.id, shader3d_skinned_instanced.id)
  assert_eq(cmds[0].vertex_data[0], 321.0)
  assert_eq(cmds[0].instance_count, 2)
}

///|
test "push_skinned_mesh_gpu_commands_from_matrices_with_view_projection splits large instanced batches" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader3d_skinned = @gfx.new_shader_handle(23, "")
  let shader3d_skinned_instanced = @gfx.new_shader_handle(24, "")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 6.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let packed = Array::make(24 * 16, 0.0)
  let matrices : Array[@math3d.Mat4] = []
  let colors : Array[@math3d.Vec4] = []
  for i in 0..<65 {
    matrices.push(
      @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(
          (i % 8).to_double() * 0.25,
          0.0,
          (i / 8).to_double() * 0.25,
        ),
      ).to_mat4(),
    )
    colors.push(@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))
  }
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  push_skinned_mesh_gpu_commands_from_matrices_with_view_projection(
    mesh,
    matrices,
    colors,
    packed,
    [@math3d.Mat4::identity()],
    camera.view_projection_matrix(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d_skinned,
    shader3d_skinned_instanced,
    640,
    480,
    cmds,
  )
  assert_eq(cmds.length(), 2)
  assert_eq(cmds[0].shader.id, shader3d_skinned_instanced.id)
  assert_eq(cmds[1].shader.id, shader3d_skinned.id)
  assert_eq(cmds[0].instance_count, 64)
  assert_eq(cmds[1].instance_count, 1)
}

///|
test "has_nonzero_sort_bias_gpu detects when sorting can be skipped" {
  let cube = @mesh3d.Mesh3D::cube(1.0)
  assert_false(
    has_nonzero_sort_bias_gpu([
      object3d(mesh=cube),
      object3d(mesh=cube, position=@math3d.Vec3::new(2.0, 0.0, 0.0)),
    ]),
  )
  assert_true(
    has_nonzero_sort_bias_gpu([
      object3d(mesh=cube),
      object3d(mesh=cube, sort_bias=1.0),
    ]),
  )
}

///|
test "sort_object_indices_for_gpu keeps stable order for equal biases" {
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let indices = sort_object_indices_for_gpu([
    object3d(mesh=cube, sort_bias=0.0),
    object3d(mesh=cube, sort_bias=2.0),
    object3d(mesh=cube, sort_bias=2.0),
    object3d(mesh=cube, sort_bias=-1.0),
  ])
  assert_eq(indices.length(), 4)
  assert_eq(indices[0], 1)
  assert_eq(indices[1], 2)
  assert_eq(indices[2], 0)
  assert_eq(indices[3], 3)
}

///|
test "tint_lighting_for_object reuses base lighting for white tint" {
  let lighting = @light3d.LightingEnvironment::default()
  let tinted = tint_lighting_for_object(
    lighting,
    @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
  )
  assert_eq(tinted.directional.color.x, lighting.directional.color.x)
  assert_eq(tinted.directional.color.y, lighting.directional.color.y)
  assert_eq(tinted.directional.color.z, lighting.directional.color.z)
  assert_eq(tinted.ambient.color.x, lighting.ambient.color.x)
  assert_eq(tinted.ambient.color.y, lighting.ambient.color.y)
  assert_eq(tinted.ambient.color.z, lighting.ambient.color.z)
}

///|
test "can_use_simple_untextured_gpu_path only accepts plain unskinned objects" {
  assert_true(can_use_simple_untextured_gpu_path(None, None))
  assert_false(can_use_simple_untextured_gpu_path(Some(Material::new()), None))
  let skinning = SkinningState::new(
    @skeleton3d.SkinData::{ joint_indices: [], weights: [], vertex_count: 0 },
    [],
  )
  assert_false(can_use_simple_untextured_gpu_path(None, Some(skinning)))
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

///|
test "render_instanced_gpu_with_view_projection reuses precomputed vp" {
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
    InstanceData::new(color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)),
    InstanceData::new(
      transform=@transform3d.Transform3D::new().translate(
        @math3d.Vec3::new(1.0, 0.0, 0.0),
      ),
      color=@math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ),
  ]
  let cmd = render_instanced_gpu_with_view_projection(
    cube,
    instances,
    camera.view_projection_matrix(),
    @light3d.LightingEnvironment::default(),
    dst,
    shader3d,
    640,
    480,
  )
  assert_eq(cmd.instance_count, 2)
  assert_eq(cmd.dst_regions.length(), 1)
  assert_eq(cmd.dst_regions[0].index_count, cube.indices.length())
}
