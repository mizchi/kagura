///|
test "sky uses a closed inward cube with twelve triangles" {
  let mesh = sky_mesh()
  assert_eq(mesh.triangle_count(), 12)
  for i = 0; i < mesh.indices.length(); i = i + 3 {
    fn p(j : Int) -> @math3d.Vec3 {
      let k = mesh.indices[j] * 8
      @math3d.Vec3::new(
        mesh.vertex_data[k],
        mesh.vertex_data[k + 1],
        mesh.vertex_data[k + 2],
      )
    }
    let a = p(i)
    let b = p(i + 1)
    let c = p(i + 2)
    assert_true(b.sub(a).cross(c.sub(a)).dot(a) < 0.0)
  }
}

///|
test "sky view is unchanged by moving camera and uses no textures" {
  let mesh = sky_mesh()
  let shader = @gfx.new_shader_handle(1, shader3d_sky_wgsl())
  let dst = @gfx.new_image_handle(1, 1280, 900)
  let projection = @math3d.Mat4::perspective(0.7, 1.4, 0.1, 700.0)
  fn command(eye : @math3d.Vec3) -> @gfx.DrawTrianglesCommand {
    let view = @math3d.Mat4::look_at(
      eye,
      eye.add(@math3d.Vec3::new(0.3, 0.2, -1.0)),
      @math3d.Vec3::new(0.0, 1.0, 0.0),
    )
    new_sky_draw_command(
      dst,
      shader,
      mesh,
      projection.multiply(view),
      eye,
      SkySettings::default(),
    )
  }
  let a = command(@math3d.Vec3::new(0.0, 0.0, 0.0))
  let b = command(@math3d.Vec3::new(500.0, 90.0, -700.0))
  assert_eq(a.indices.length(), 36)
  assert_eq(a.vertex_stride_hint, 8)
  assert_eq(a.uniform_dwords.length(), 40)
  assert_eq(a.src_image_ids.length(), 0)
  for i in 0..<40 {
    assert_true(
      approx(
        @gfx.f32_bits_to_double(a.uniform_dwords[i]),
        @gfx.f32_bits_to_double(b.uniform_dwords[i]),
      ),
    )
  }
}
