///|
/// Keep the former game-side loop as a benchmark reference, not production code.
fn bench_batch_setup() -> (
  InstancedMeshBatch,
  Array[@math3d.Mat4],
  Array[@math3d.Vec4],
) {
  let batch = InstancedMeshBatch::new(@mesh3d.Mesh3D::sphere(1, 6, 4))
  let matrices = Array::makei(600, i => {
    @math3d.Mat4::translation(i.to_double() * 0.1, 2, -30)
  })
  let colors = Array::makei(600, i => {
    @math3d.Vec4::new((i % 7).to_double() / 7, 0.4, 0.8, 1)
  })
  for i in 0..<600 {
    batch.push(matrices[i], color=colors[i])
  }
  (batch, matrices, colors)
}

///|
test "600 instances former game loop" (b : @bench.T) {
  let (batch, matrices, colors) = bench_batch_setup()
  let dst = @gfx.new_image_handle(1, 1440, 900)
  let shader = @gfx.new_shader_handle(1, "instanced")
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  b.bench(fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    for start = 0; start < matrices.length(); start = start + 256 {
      let count = (matrices.length() - start).min(256)
      commands.push(
        new_instanced_lit_mesh_draw_command(
          dst,
          shader,
          @gfx.new_dst_region(0, 0, 1440, 900, batch.mesh.indices.length()),
          @gfx.BlendMode::from_int(0),
          batch.mesh,
          vp,
          lighting,
          Array::makei(count, i => matrices[start + i]),
          Array::makei(count, i => colors[start + i]),
        ),
      )
    }
    b.keep(commands)
  })
}

///|
test "600 instances shared mesh batch" (b : @bench.T) {
  let (batch, _, _) = bench_batch_setup()
  let dst = @gfx.new_image_handle(1, 1440, 900)
  let shader = @gfx.new_shader_handle(1, "instanced")
  let vp = @math3d.Mat4::identity()
  let lighting = @light3d.LightingEnvironment::default()
  b.bench(fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    batch.append_draw_commands(dst, shader, 1440, 900, vp, lighting, commands)
    b.keep(commands)
  })
}
