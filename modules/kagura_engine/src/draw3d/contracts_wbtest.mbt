///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-4
}

///|
test "mat4_to_uniform_dwords identity" {
  let m = @math3d.Mat4::identity()
  let dwords = mat4_to_uniform_dwords(m)
  assert_eq(dwords.length(), 16)
  // Diagonal should be f32 bits for 1.0 = 0x3F800000
  assert_eq(dwords[0], 0x3F800000)
  assert_eq(dwords[5], 0x3F800000)
  assert_eq(dwords[10], 0x3F800000)
  assert_eq(dwords[15], 0x3F800000)
  // Off-diagonal should be 0
  assert_eq(dwords[1], 0)
  assert_eq(dwords[4], 0)
}

///|
test "mat4_to_uniform_dwords roundtrip" {
  let m = @math3d.Mat4::translation(1.0, 2.0, 3.0)
  let dwords = mat4_to_uniform_dwords(m)
  // Column 3 should contain translation values
  let tx = @gfx.f32_bits_to_double(dwords[12])
  let ty = @gfx.f32_bits_to_double(dwords[13])
  let tz = @gfx.f32_bits_to_double(dwords[14])
  assert_true(approx(tx, 1.0))
  assert_true(approx(ty, 2.0))
  assert_true(approx(tz, 3.0))
}

///|
test "mvp_uniform_dwords" {
  let model = @math3d.Mat4::translation(5.0, 0.0, 0.0)
  let vp = @math3d.Mat4::identity()
  let dwords = mvp_uniform_dwords(model, vp)
  assert_eq(dwords.length(), 16)
  // MVP = I * T = T, so column 3 element 0 should be f32(5.0)
  let tx = @gfx.f32_bits_to_double(dwords[12])
  assert_true(approx(tx, 5.0))
}

///|
test "new_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "test")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let blend = @gfx.BlendMode::from_int(0)
  let cmd = new_mesh_draw_command(
    dst,
    shader,
    dst_region,
    0,
    0,
    0,
    blend,
    mesh,
    model,
    vp,
    [],
  )
  // Verify command has the mesh data
  assert_eq(cmd.vertex_data.length(), 24 * @mesh3d.vertex3d_stride)
  assert_eq(cmd.indices.length(), 36)
  assert_eq(cmd.uniform_dwords.length(), 16)
}

// ============================================================
// Lit shader and uniform tests
// ============================================================

///|
test "shader3d_lit_wgsl returns non-empty string" {
  let src = shader3d_lit_wgsl()
  assert_true(src.length() > 100)
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  assert_true(src.contains("textureSample"))
}

///|
test "shader3d_lit_untextured_wgsl returns non-empty string" {
  let src = shader3d_lit_untextured_wgsl()
  assert_true(src.length() > 100)
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  // Should not have textureSample
  assert_false(src.contains("textureSample"))
}

///|
test "shader3d_lit_colored_wgsl returns non-empty string" {
  let src = shader3d_lit_colored_wgsl()
  assert_true(src.length() > 100)
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  assert_true(src.contains("base_color"))
}

///|
test "lit_uniform_dwords layout 56 dwords" {
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dwords = lit_uniform_dwords(model, vp, lighting)
  assert_eq(dwords.length(), 56)
  // First 16: MVP (identity)
  assert_eq(dwords[0], 0x3F800000) // 1.0
  assert_eq(dwords[5], 0x3F800000)
  assert_eq(dwords[10], 0x3F800000)
  assert_eq(dwords[15], 0x3F800000)
  // Next 16: Model (identity)
  assert_eq(dwords[16], 0x3F800000)
  assert_eq(dwords[21], 0x3F800000)
  assert_eq(dwords[26], 0x3F800000)
  assert_eq(dwords[31], 0x3F800000)
  // Next 12: Normal matrix (identity columns)
  assert_eq(dwords[32], 0x3F800000) // col0.x
  assert_eq(dwords[37], 0x3F800000) // col1.y
  assert_eq(dwords[42], 0x3F800000) // col2.z
  // Last 12: Light data
  // direction.y = -1.0
  let dir_y = @gfx.f32_bits_to_double(dwords[45])
  assert_true(approx(dir_y, -1.0))
}

///|
test "lit_uniform_dwords with translation" {
  let model = @math3d.Mat4::translation(1.0, 2.0, 3.0)
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dwords = lit_uniform_dwords(model, vp, lighting)
  assert_eq(dwords.length(), 56)
  // MVP column 3 should have translation
  let tx = @gfx.f32_bits_to_double(dwords[12])
  assert_true(approx(tx, 1.0))
  // Model column 3 should have same translation
  let model_tx = @gfx.f32_bits_to_double(dwords[28])
  assert_true(approx(model_tx, 1.0))
}

///|
test "lit_uniform_dwords_with_light_dwords matches default packing" {
  let model = @math3d.Mat4::translation(1.0, 2.0, 3.0)
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let light_dwords = @light3d.light_uniform_dwords(lighting)
  let dwords = lit_uniform_dwords(model, vp, lighting)
  let packed = lit_uniform_dwords_with_light_dwords(model, vp, light_dwords)
  assert_eq(packed, dwords)
}

///|
test "new_lit_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "test_lit")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let blend = @gfx.BlendMode::from_int(0)
  let cmd = new_lit_mesh_draw_command(
    dst,
    shader,
    dst_region,
    0,
    0,
    0,
    blend,
    mesh,
    model,
    vp,
    lighting,
    [],
  )
  assert_eq(cmd.vertex_data.length(), 24 * @mesh3d.vertex3d_stride)
  assert_eq(cmd.indices.length(), 36)
  assert_eq(cmd.uniform_dwords.length(), 56)
}

///|
test "new_lit_colored_mesh_draw_command packs base color uniform" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let base_color = @math3d.Vec4::new(0.25, 0.5, 0.75, 1.0)
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(12, "test_lit_colored")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let blend = @gfx.BlendMode::from_int(0)
  let cmd = new_lit_colored_mesh_draw_command(
    dst,
    shader,
    dst_region,
    0,
    0,
    0,
    blend,
    mesh,
    model,
    vp,
    lighting,
    base_color,
    [],
  )
  assert_eq(cmd.uniform_dwords.length(), 60)
  assert_true(approx(@gfx.f32_bits_to_double(cmd.uniform_dwords[56]), 0.25))
  assert_true(approx(@gfx.f32_bits_to_double(cmd.uniform_dwords[57]), 0.5))
  assert_true(approx(@gfx.f32_bits_to_double(cmd.uniform_dwords[58]), 0.75))
  assert_true(approx(@gfx.f32_bits_to_double(cmd.uniform_dwords[59]), 1.0))
}

///|
test "new_skinned_lit_mesh_draw_command_from_skin packs stride16 vertex data" {
  let mesh = @mesh3d.Mesh3D::new(
    [
      0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0,
    ],
    [0, 1],
  )
  let skin : @skeleton3d.SkinData = {
    joint_indices: [0, 1, 2, 3, 4, 5, 6, 7],
    weights: [1.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0],
    vertex_count: 2,
  }
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(11, "test_skinned")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 2)
  let cmd = new_skinned_lit_mesh_draw_command_from_skin(
    dst,
    shader,
    dst_region,
    0,
    0,
    0,
    @gfx.BlendMode::from_int(1),
    mesh,
    skin,
    model,
    vp,
    lighting,
    [@math3d.Mat4::identity()],
    [],
  )
  assert_eq(cmd.vertex_data.length(), 2 * 16)
  assert_eq(cmd.indices.length(), 2)
  // Base lit(56) + num_bones(4) + max_bones(64) * mat4(16)
  assert_eq(cmd.uniform_dwords.length(), 56 + 4 + 64 * 16)
  // First vertex joint0 and weight0 payload offsets
  assert_eq(cmd.vertex_data[8], 0.0)
  assert_eq(cmd.vertex_data[12], 1.0)
}

///|
test "shader3d_lit_skinned_wgsl supports pre-skinned bypass flag" {
  let src = shader3d_lit_skinned_wgsl()
  assert_true(src.contains("pre_skinned"))
  assert_true(src.contains("uniforms.num_bones.y > 0.5"))
  assert_true(src.contains("if (!pre_skinned)"))
}

///|
test "shader3d_lit_skinned_instanced_wgsl supports instance_index and bone matrices" {
  let src = shader3d_lit_skinned_instanced_wgsl()
  assert_true(src.contains("instance_index"))
  assert_true(src.contains("bone_matrices"))
  assert_true(src.contains("instances"))
  assert_true(src.contains("input.weights"))
}

///|
test "shader3d_lit_skinned_instanced_monochrome_wgsl uses base_color" {
  let src = shader3d_lit_skinned_instanced_monochrome_wgsl()
  assert_true(src.contains("instance_index"))
  assert_true(src.contains("base_color"))
  assert_true(src.contains("instance_models"))
  assert_true(src.contains("input.weights"))
}

///|
test "new_skinned_instanced_lit_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::new(
    [
      0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0,
    ],
    [0, 1],
  )
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(13, "test_skinned_instanced")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 2)
  let cmd = new_skinned_instanced_lit_mesh_draw_command(
    dst,
    shader,
    dst_region,
    @gfx.BlendMode::from_int(1),
    mesh.vertex_data,
    mesh.indices,
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    [@math3d.Mat4::identity()],
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    [
      @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
    ],
  )
  assert_eq(cmd.instance_count, 2)
  assert_eq(cmd.vertex_data.length(), mesh.vertex_data.length())
  assert_eq(cmd.indices.length(), mesh.indices.length())
  assert_eq(cmd.uniform_dwords.length(), 16 + 12 + 4 + 64 * 16 + 4 + 64 * 20)
}

///|
test "new_skinned_instanced_monochrome_lit_mesh_draw_command shrinks uniform payload" {
  let mesh = @mesh3d.Mesh3D::new(
    [
      0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0,
      0.0,
    ],
    [0, 1],
  )
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(15, "test_skinned_instanced_monochrome")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 2)
  let cmd = new_skinned_instanced_monochrome_lit_mesh_draw_command(
    dst,
    shader,
    dst_region,
    @gfx.BlendMode::from_int(1),
    mesh.vertex_data,
    mesh.indices,
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    [@math3d.Mat4::identity()],
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(1.0, 0.0, 0.0)],
    @math3d.Vec4::new(0.75, 0.5, 0.25, 1.0),
  )
  assert_eq(cmd.instance_count, 2)
  assert_eq(cmd.vertex_data.length(), mesh.vertex_data.length())
  assert_eq(cmd.indices.length(), mesh.indices.length())
  assert_eq(
    cmd.uniform_dwords.length(),
    16 + 12 + 4 + 64 * 16 + 4 + 4 + 64 * 16,
  )
}

// ============================================================
// Normal map shader tests
// ============================================================

///|
test "shader3d_lit_normalmap_wgsl contains dpdx and normal_map" {
  let src = shader3d_lit_normalmap_wgsl()
  assert_true(src.contains("dpdx"))
  assert_true(src.contains("normal_map"))
  assert_true(src.contains("world_position"))
  assert_true(src.contains("@binding(3)"))
  assert_true(src.contains("@binding(4)"))
}

///|
test "shader3d_lit_normalmap_wgsl has vs_main and fs_main" {
  let src = shader3d_lit_normalmap_wgsl()
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  assert_true(src.contains("textureSample"))
}

///|
test "new_lit_normalmap_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "test_normalmap")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let blend = @gfx.BlendMode::from_int(0)
  let cmd = new_lit_normalmap_mesh_draw_command(
    dst, shader, dst_region, 0, 0, 0, blend, mesh, model, vp, lighting, 10, 20,
  )
  assert_eq(cmd.src_image_ids.length(), 2)
  assert_eq(cmd.src_image_ids[0], 10)
  assert_eq(cmd.src_image_ids[1], 20)
  assert_eq(cmd.uniform_dwords.length(), 56)
}

// ============================================================
// Instanced shader and uniform tests
// ============================================================

///|
test "shader3d_lit_instanced_wgsl contains instance_index" {
  let src = shader3d_lit_instanced_wgsl()
  assert_true(src.length() > 100)
  assert_true(src.contains("instance_index"))
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  assert_true(src.contains("InstanceData"))
  assert_true(src.contains("MAX_INSTANCES"))
}

///|
test "instanced_lit_uniform_dwords layout" {
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let matrices = [@math3d.Mat4::identity()]
  let colors = [@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)]
  let dwords = instanced_lit_uniform_dwords(vp, lighting, matrices, colors)
  // VP(16) + Light(12) + instance_count(4) + 256 instances * 20 = 5152
  assert_eq(dwords.length(), 16 + 12 + 4 + 256 * 20)
}

///|
test "instanced_lit_uniform_dwords with 2 instances" {
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let matrices = [
    @math3d.Mat4::translation(1.0, 0.0, 0.0),
    @math3d.Mat4::translation(0.0, 2.0, 0.0),
  ]
  let colors = [
    @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
  ]
  let dwords = instanced_lit_uniform_dwords(vp, lighting, matrices, colors)
  // Header: VP(16) + Light(12) = 28, then instance_count at 28
  let count_val = @gfx.f32_bits_to_double(dwords[28])
  assert_true(approx(count_val, 2.0))
  // Per-instance data starts at 32 (28 + 4 for instance_count vec4)
  // First instance model: translation(1,0,0)
  // column 3 element 0 (index 32 + 12 = 44)
  let tx1 = @gfx.f32_bits_to_double(dwords[32 + 12])
  assert_true(approx(tx1, 1.0))
  // First instance color at offset 32 + 16 = 48
  let cr = @gfx.f32_bits_to_double(dwords[48])
  assert_true(approx(cr, 1.0))
}

///|
test "new_instanced_lit_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "test_instanced")
  let matrices = [
    @math3d.Mat4::identity(),
    @math3d.Mat4::translation(2.0, 0.0, 0.0),
  ]
  let colors = [
    @math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
    @math3d.Vec4::new(0.0, 1.0, 0.0, 1.0),
  ]
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let cmd = new_instanced_lit_mesh_draw_command(
    dst,
    shader,
    dst_region,
    @gfx.BlendMode::from_int(1),
    mesh,
    vp,
    lighting,
    matrices,
    colors,
  )
  assert_eq(cmd.instance_count, 2)
  assert_eq(cmd.vertex_data.length(), 24 * @mesh3d.vertex3d_stride)
  assert_eq(cmd.indices.length(), 36)
}

///|
test "instance_count=1 produces same data size as non-instanced" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "test_instanced")
  let matrices = [@math3d.Mat4::identity()]
  let colors = [@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)]
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let cmd = new_instanced_lit_mesh_draw_command(
    dst,
    shader,
    dst_region,
    @gfx.BlendMode::from_int(1),
    mesh,
    vp,
    lighting,
    matrices,
    colors,
  )
  assert_eq(cmd.instance_count, 1)
  // Uniform size is always padded to MAX_INSTANCES
  assert_eq(cmd.uniform_dwords.length(), 16 + 12 + 4 + 256 * 20)
}

///|
test "shader3d_lit_instanced_monochrome_wgsl uses small instance cap" {
  let src = shader3d_lit_instanced_monochrome_wgsl()
  assert_true(src.contains("MAX_INSTANCES: u32 = 64u"))
  assert_true(src.contains("base_color"))
  assert_true(src.contains("instance_models"))
}

///|
test "instanced_monochrome_lit_uniform_dwords layout uses 64 instance cap" {
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let matrices = [@math3d.Mat4::identity()]
  let dwords = instanced_monochrome_lit_uniform_dwords(
    vp,
    lighting,
    matrices,
    @math3d.Vec4::new(0.5, 0.6, 0.7, 1.0),
  )
  assert_eq(dwords.length(), 16 + 12 + 4 + 4 + 64 * 16)
  assert_true(approx(@gfx.f32_bits_to_double(dwords[32]), 0.5))
  assert_true(approx(@gfx.f32_bits_to_double(dwords[33]), 0.6))
  assert_true(approx(@gfx.f32_bits_to_double(dwords[34]), 0.7))
  assert_true(approx(@gfx.f32_bits_to_double(dwords[35]), 1.0))
}
