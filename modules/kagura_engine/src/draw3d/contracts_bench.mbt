///|
/// Micro-benchmarks for uniform-dword builders. These dominate
/// CPU-side cost in 3D rendering because they call double_to_f32_bits
/// (an IEEE 754 unpack via int64 ops) hundreds-to-thousands of times
/// per draw call on the JS target.

///|
fn bench_mat4_translation(i : Int) -> @math3d.Mat4 {
  @math3d.Mat4::translation(i.to_double(), 0.0, 0.0)
}

///|
fn bench_skin_matrices(count : Int) -> Array[@math3d.Mat4] {
  let out : Array[@math3d.Mat4] = []
  for i in 0..<count {
    out.push(bench_mat4_translation(i))
  }
  out
}

///|
fn bench_instance_matrices(count : Int) -> Array[@math3d.Mat4] {
  let out : Array[@math3d.Mat4] = []
  for i in 0..<count {
    out.push(bench_mat4_translation(i * 2))
  }
  out
}

///|
fn bench_instance_colors(count : Int) -> Array[@math3d.Vec4] {
  let out : Array[@math3d.Vec4] = []
  for i in 0..<count {
    let f = (i % 256).to_double() / 256.0
    out.push(@math3d.Vec4::new(f, f, f, 1.0))
  }
  out
}

///|
test "bench mat4_to_uniform_dwords 1000" (b : @bench.T) {
  let m = @math3d.Mat4::translation(1.0, 2.0, 3.0)
  b.bench(name="draw3d/mat4_to_uniform_dwords_1000", fn() {
    let mut acc = 0
    for _i in 0..<1000 {
      let dw = mat4_to_uniform_dwords(m)
      acc = acc + dw.length()
    }
    b.keep(acc)
  })
}

///|
test "bench lit_uniform_dwords 1000" (b : @bench.T) {
  let model = @math3d.Mat4::translation(1.0, 0.0, 0.0)
  let view_projection = @math3d.Mat4::translation(0.0, 1.0, 0.0)
  let lighting = @light3d.LightingEnvironment::default()
  b.bench(name="draw3d/lit_uniform_dwords_1000", fn() {
    let mut acc = 0
    for _i in 0..<1000 {
      let dw = lit_uniform_dwords(model, view_projection, lighting)
      acc = acc + dw.length()
    }
    b.keep(acc)
  })
}

///|
test "bench pbr_uniform_dwords 1000" (b : @bench.T) {
  let model = @math3d.Mat4::translation(1.0, 0.0, 0.0)
  let view_projection = @math3d.Mat4::translation(0.0, 1.0, 0.0)
  let lighting = @light3d.LightingEnvironment::default()
  let base_color = @math3d.Vec4::new(0.8, 0.7, 0.6, 1.0)
  let emissive = @math3d.Vec3::new(0.1, 0.1, 0.0)
  let camera_pos = @math3d.Vec3::new(0.0, 5.0, 10.0)
  b.bench(name="draw3d/pbr_uniform_dwords_1000", fn() {
    let mut acc = 0
    for _i in 0..<1000 {
      let dw = pbr_uniform_dwords(
        model, view_projection, lighting, 0.5, 0.5, base_color, emissive, camera_pos,
      )
      acc = acc + dw.length()
    }
    b.keep(acc)
  })
}

///|
test "bench skinned_instanced_lit_uniform_dwords 32bones_16inst x100" (b : @bench.T) {
  let view_projection = @math3d.Mat4::translation(0.0, 0.0, 0.0)
  let lighting = @light3d.LightingEnvironment::default()
  let bones = bench_skin_matrices(32)
  let inst_m = bench_instance_matrices(16)
  let inst_c = bench_instance_colors(16)
  b.bench(name="draw3d/skinned_instanced_lit_uniform_dwords_100", fn() {
    let mut acc = 0
    for _i in 0..<100 {
      let dw = skinned_instanced_lit_uniform_dwords(
        view_projection, lighting, bones, inst_m, inst_c,
      )
      acc = acc + dw.length()
    }
    b.keep(acc)
  })
}

///|
test "bench instanced_lit_uniform_dwords 64inst x100" (b : @bench.T) {
  let view_projection = @math3d.Mat4::translation(0.0, 0.0, 0.0)
  let lighting = @light3d.LightingEnvironment::default()
  let inst_m = bench_instance_matrices(64)
  let inst_c = bench_instance_colors(64)
  b.bench(name="draw3d/instanced_lit_uniform_dwords_100", fn() {
    let mut acc = 0
    for _i in 0..<100 {
      let dw = instanced_lit_uniform_dwords(view_projection, lighting, inst_m, inst_c)
      acc = acc + dw.length()
    }
    b.keep(acc)
  })
}
