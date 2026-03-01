///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-4
}

///|
fn decode(bits : Int) -> Double {
  @gfx.f32_bits_to_double(bits)
}

// ============================================================
// ShadowConfig
// ============================================================

///|
test "ShadowConfig::new computes pcf_texel_size" {
  let config = ShadowConfig::new(
    1024, 10.0, 0.1, 100.0, 50.0, @math3d.Vec3::zero(), 0.005,
  )
  assert_eq(config.map_size, 1024)
  assert_true(approx(config.pcf_texel_size, 1.0 / 1024.0))
  assert_true(approx(config.bias, 0.005))
  assert_true(approx(config.half_extent, 10.0))
}

///|
test "ShadowConfig::new with different map_size" {
  let config = ShadowConfig::new(
    512, 20.0, 0.5, 200.0, 100.0, @math3d.Vec3::new(1.0, 0.0, 0.0), 0.001,
  )
  assert_true(approx(config.pcf_texel_size, 1.0 / 512.0))
  assert_true(approx(config.center.x, 1.0))
}

// ============================================================
// Light Space Matrices
// ============================================================

///|
test "light_view_matrix with downward light" {
  let dir = @math3d.Vec3::new(0.0, -1.0, 0.0)
  let center = @math3d.Vec3::zero()
  let m = light_view_matrix(dir, center, 10.0)
  // eye should be at (0, 10, 0), looking at (0, 0, 0)
  // Should use unit_x as up since dir is close to unit_y
  // Verify center maps to near origin in x,y view space
  let cx = m.elements[0] * 0.0 + m.elements[4] * 0.0 + m.elements[8] * 0.0 +
    m.elements[12]
  let cy = m.elements[1] * 0.0 + m.elements[5] * 0.0 + m.elements[9] * 0.0 +
    m.elements[13]
  assert_true(cx.abs() < 1.0e-4)
  assert_true(cy.abs() < 1.0e-4)
  // Should not be identity (translation component is non-zero)
  assert_true(m.elements[14].abs() > 1.0e-4)
}

///|
test "light_view_matrix with diagonal light" {
  let dir = @math3d.Vec3::new(1.0, -1.0, 0.0).normalize()
  let center = @math3d.Vec3::new(0.0, 0.0, 0.0)
  let m = light_view_matrix(dir, center, 10.0)
  // Should use unit_y as up since dot(dir, unit_y) is not close to 1.0
  // Transform center point: should map to (0, 0, -distance) roughly
  let cx = m.elements[0] * 0.0 + m.elements[4] * 0.0 + m.elements[8] * 0.0 +
    m.elements[12]
  let cy = m.elements[1] * 0.0 + m.elements[5] * 0.0 + m.elements[9] * 0.0 +
    m.elements[13]
  // Center in view space should be near origin in x,y
  assert_true(cx.abs() < 1.0e-4)
  assert_true(cy.abs() < 1.0e-4)
}

///|
test "light_view_matrix with zero direction returns identity" {
  let dir = @math3d.Vec3::zero()
  let center = @math3d.Vec3::zero()
  let m = light_view_matrix(dir, center, 10.0)
  // Should return identity for degenerate input
  assert_true(approx(m.elements[0], 1.0))
  assert_true(approx(m.elements[5], 1.0))
  assert_true(approx(m.elements[10], 1.0))
  assert_true(approx(m.elements[15], 1.0))
}

///|
test "light_projection_matrix basic properties" {
  let p = light_projection_matrix(10.0, 0.1, 100.0)
  // Orthographic projection: [0,0] = 1/half_extent, [1,1] = 1/half_extent
  assert_true(approx(p.elements[0], 1.0 / 10.0))
  assert_true(approx(p.elements[5], 1.0 / 10.0))
}

///|
test "light_space_matrix is projection * view" {
  let dir = @math3d.Vec3::new(1.0, -1.0, 1.0).normalize()
  let center = @math3d.Vec3::zero()
  let m = light_space_matrix(dir, center, 20.0, 15.0, 0.1, 50.0)
  // Verify it's equivalent to manual computation
  let view = light_view_matrix(dir, center, 20.0)
  let proj = light_projection_matrix(15.0, 0.1, 50.0)
  let expected = proj.multiply(view)
  for i in 0..<16 {
    assert_true(approx(m.elements[i], expected.elements[i]))
  }
}

// ============================================================
// Depth Shader
// ============================================================

///|
test "shader_shadow_depth_wgsl contains required elements" {
  let src = shader_shadow_depth_wgsl()
  assert_true(src.contains("light_mvp"))
  assert_true(src.contains("depth"))
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  assert_true(src.contains("@binding(0)"))
}

///|
test "shadow_depth_uniform_dwords is 16 dwords" {
  let model = @math3d.Mat4::identity()
  let light_vp = @math3d.Mat4::identity()
  let dwords = shadow_depth_uniform_dwords(model, light_vp)
  assert_eq(dwords.length(), 16)
  // Identity * Identity = Identity
  assert_eq(dwords[0], 0x3F800000) // 1.0
  assert_eq(dwords[5], 0x3F800000)
  assert_eq(dwords[10], 0x3F800000)
  assert_eq(dwords[15], 0x3F800000)
  assert_eq(dwords[1], 0) // off-diagonal
}

///|
test "shadow_depth_uniform_dwords with translation" {
  let model = @math3d.Mat4::translation(3.0, 0.0, 0.0)
  let light_vp = @math3d.Mat4::identity()
  let dwords = shadow_depth_uniform_dwords(model, light_vp)
  let tx = decode(dwords[12])
  assert_true(approx(tx, 3.0))
}

///|
test "new_shadow_depth_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let light_vp = @math3d.Mat4::identity()
  let shadow_map = @gfx.new_image_handle(1, 1024, 1024)
  let shader = @gfx.new_shader_handle(1, "depth")
  let cmd = new_shadow_depth_command(shadow_map, shader, mesh, model, light_vp)
  assert_eq(cmd.vertex_data.length(), 24 * @mesh3d.vertex3d_stride)
  assert_eq(cmd.indices.length(), 36)
  assert_eq(cmd.uniform_dwords.length(), 16)
  assert_eq(cmd.src_image_ids.length(), 0)
}

// ============================================================
// Shadow Depth Pass Commands
// ============================================================

///|
test "shadow_depth_pass_commands generates per-caster commands" {
  let shadow_map = @gfx.new_image_handle(1, 1024, 1024)
  let shader = @gfx.new_shader_handle(1, "depth")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let casters = [
    ShadowCaster::new(cube, @math3d.Mat4::identity()),
    ShadowCaster::new(cube, @math3d.Mat4::translation(5.0, 0.0, 0.0)),
    ShadowCaster::new(cube, @math3d.Mat4::translation(0.0, 0.0, -3.0)),
  ]
  let lighting = @light3d.LightingEnvironment::default()
  let config = ShadowConfig::new(
    1024, 10.0, 0.1, 100.0, 50.0, @math3d.Vec3::zero(), 0.005,
  )
  let cmds = shadow_depth_pass_commands(
    shadow_map, shader, casters, lighting, config,
  )
  assert_eq(cmds.length(), 3)
  // Each command should have 16 dwords uniform and no src images
  for i in 0..<cmds.length() {
    assert_eq(cmds[i].uniform_dwords.length(), 16)
    assert_eq(cmds[i].src_image_ids.length(), 0)
  }
}

// ============================================================
// Shadow Lit Shader
// ============================================================

///|
test "shader3d_shadow_lit_wgsl contains shadow map and PCF" {
  let src = shader3d_shadow_lit_wgsl()
  assert_true(src.contains("shadow_map"))
  assert_true(src.contains("calc_shadow"))
  assert_true(src.contains("bias"))
  assert_true(src.contains("@binding(3)"))
  assert_true(src.contains("@binding(4)"))
  assert_true(src.contains("9.0"))
  assert_true(src.contains("vs_main"))
  assert_true(src.contains("fs_main"))
  assert_true(src.contains("textureSample"))
  assert_true(src.contains("world_position"))
}

///|
test "shader3d_shadow_lit_untextured_wgsl differs from textured" {
  let textured = shader3d_shadow_lit_wgsl()
  let untextured = shader3d_shadow_lit_untextured_wgsl()
  assert_true(textured != untextured)
  // Untextured should not have tex_sampler binding
  assert_true(untextured.contains("shadow_map"))
  assert_true(untextured.contains("calc_shadow"))
  assert_true(untextured.contains("vs_main"))
  assert_true(untextured.contains("fs_main"))
  // Untextured should not sample from tex
  assert_false(untextured.contains("tex_sampler"))
}

// ============================================================
// Shadow Lit Uniforms
// ============================================================

///|
test "shadow_lit_uniform_dwords is 76 dwords" {
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let light_vp = @math3d.Mat4::identity()
  let config = ShadowConfig::new(
    1024, 10.0, 0.1, 100.0, 50.0, @math3d.Vec3::zero(), 0.005,
  )
  let dwords = shadow_lit_uniform_dwords(model, vp, lighting, light_vp, config)
  assert_eq(dwords.length(), 76)
  // First 16: MVP (identity)
  assert_eq(dwords[0], 0x3F800000)
  assert_eq(dwords[5], 0x3F800000)
  // Model at offset 16 (identity)
  assert_eq(dwords[16], 0x3F800000)
  assert_eq(dwords[21], 0x3F800000)
  // Light VP at offset 56 (identity)
  assert_eq(dwords[56], 0x3F800000)
  assert_eq(dwords[61], 0x3F800000)
  // Shadow params at offset 72: bias
  let bias_val = decode(dwords[72])
  assert_true(approx(bias_val, 0.005))
  // texel_size
  let texel_val = decode(dwords[73])
  assert_true(approx(texel_val, 1.0 / 1024.0))
}

// ============================================================
// Shadow Lit Draw Command
// ============================================================

///|
test "new_shadow_lit_mesh_draw_command creates valid command" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let model = @math3d.Mat4::identity()
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let light_vp = @math3d.Mat4::identity()
  let config = ShadowConfig::new(
    1024, 10.0, 0.1, 100.0, 50.0, @math3d.Vec3::zero(), 0.005,
  )
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "shadow_lit")
  let dst_region = @gfx.new_dst_region(0, 0, 800, 600, 36)
  let blend = @gfx.blend_mode_from_int(0)
  let cmd = new_shadow_lit_mesh_draw_command(
    dst, shader, dst_region, 0, 0, 0, blend, mesh, model, vp, lighting,
    light_vp, config, 10, 20,
  )
  assert_eq(cmd.src_image_ids.length(), 2)
  assert_eq(cmd.src_image_ids[0], 10)
  assert_eq(cmd.src_image_ids[1], 20)
  assert_eq(cmd.uniform_dwords.length(), 76)
  assert_eq(cmd.vertex_data.length(), 24 * @mesh3d.vertex3d_stride)
  assert_eq(cmd.indices.length(), 36)
}
