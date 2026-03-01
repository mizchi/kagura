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
  let blend = @gfx.blend_mode_from_int(0)
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
test "new_lit_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "test_lit")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let blend = @gfx.blend_mode_from_int(0)
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
  let blend = @gfx.blend_mode_from_int(0)
  let cmd = new_lit_normalmap_mesh_draw_command(
    dst, shader, dst_region, 0, 0, 0, blend,
    mesh, model, vp, lighting, 10, 20,
  )
  assert_eq(cmd.src_image_ids.length(), 2)
  assert_eq(cmd.src_image_ids[0], 10)
  assert_eq(cmd.src_image_ids[1], 20)
  assert_eq(cmd.uniform_dwords.length(), 56)
}
