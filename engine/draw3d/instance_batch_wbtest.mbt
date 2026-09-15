///|
test "mesh batches split at the shader limit and preserve every matrix and color" {
  let mesh = @mesh3d.Mesh3D::cube(1)
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  let dst = @gfx.new_image_handle(1, 800, 600)
  let shader = @gfx.new_shader_handle(1, "instanced")
  for count in [0, 1, 255, 256, 257, 513] {
    let batch = InstancedMeshBatch::new(mesh)
    let matrices = Array::makei(count, i => {
      @math3d.Mat4::translation(i.to_double(), 2, 3)
    })
    let colors = Array::makei(count, i => {
      @math3d.Vec4::new((i % 7).to_double() / 7, 0.4, 0.8, 1)
    })
    for i in 0..<count {
      batch.push(matrices[i], color=colors[i])
    }
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    batch.append_draw_commands(dst, shader, 800, 600, vp, lighting, commands)
    assert_eq(commands.length(), (count + 255) / 256)
    assert_eq(batch.triangle_count(), mesh.indices.length() / 3 * count)
    for chunk, cmd in commands {
      let start = chunk * 256
      let end = (start + 256).min(count)
      assert_eq(cmd.instance_count, end - start)
      assert_eq(
        cmd.uniform_dwords,
        instanced_lit_uniform_dwords(
          vp,
          lighting,
          matrices[start:end].to_array(),
          colors[start:end].to_array(),
        ),
      )
      assert_eq(cmd.vertex_data, mesh.vertex_data)
      assert_eq(cmd.indices, mesh.indices)
    }
    let words = commands.map(c => c.uniform_dwords.copy())
    batch.clear()
    batch.push(@math3d.Mat4::identity())
    assert_eq(batch.length(), 1)
    for i, cmd in commands {
      assert_eq(cmd.uniform_dwords, words[i])
    }
  }
}

///|
test "segment instances align the unit Z endpoints and skip degenerate geometry" {
  let batch = InstancedMeshBatch::new(@mesh3d.Mesh3D::sphere(1, 6, 4))
  let start = @math3d.Vec3::new(1, 2, 3)
  assert_false(batch.push_segment(start, start, 0.5))
  for
    end in [
      @math3d.Vec3::new(6, 9, -5),
      @math3d.Vec3::new(1, 12, 3),
      @math3d.Vec3::new(1, -8, 3),
    ] {
    assert_true(batch.push_segment(start, end, 0.5))
    let matrix = batch.matrices[batch.length() - 1]
    let a = matrix.mul_vec4(@math3d.Vec4::new(0, 0, -1, 1))
    let b = matrix.mul_vec4(@math3d.Vec4::new(0, 0, 1, 1))
    assert_true(@math3d.Vec3::new(a.x, a.y, a.z).approx_eq(start, 0.00001))
    assert_true(@math3d.Vec3::new(b.x, b.y, b.z).approx_eq(end, 0.00001))
  }
}
