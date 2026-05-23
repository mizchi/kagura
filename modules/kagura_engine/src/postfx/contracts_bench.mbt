///|
/// Micro-benchmarks for postfx command builders. A typical frame issues
/// these once per pass (Tonemap, FXAA, Bloom) so the per-call cost
/// matters for tight render loops on the JS target.

///|
fn bench_postfx_dst() -> @gfx.ImageHandle {
  @gfx.new_image_handle(91, 1920, 1080)
}

///|
fn bench_postfx_shader(id : Int) -> @gfx.ShaderHandle {
  @gfx.new_shader_handle(id, "postfx_bench")
}

///|
test "bench new_fullscreen_quad_command 1000" (b : @bench.T) {
  let dst = bench_postfx_dst()
  let shader = bench_postfx_shader(1)
  let src_image_ids = [101]
  let uniform_dwords = [1, 2, 3, 4]
  let blend = @gfx.BlendMode::from_int(0)
  b.bench(name="postfx/new_fullscreen_quad_command_1000", fn() {
    let mut acc = 0
    for _i in 0..<1000 {
      let cmd = new_fullscreen_quad_command(
        dst, shader, src_image_ids, uniform_dwords, blend,
      )
      acc = acc + cmd.resource_cache_key
    }
    b.keep(acc)
  })
}

///|
test "bench new_tonemap_command 1000" (b : @bench.T) {
  let dst = bench_postfx_dst()
  let shader = bench_postfx_shader(2)
  b.bench(name="postfx/new_tonemap_command_1000", fn() {
    let mut acc = 0
    for i in 0..<1000 {
      let exposure = 1.0 + (i % 16).to_double() * 0.01
      let cmd = new_tonemap_command(dst, shader, 201, exposure)
      acc = acc + cmd.resource_cache_key
    }
    b.keep(acc)
  })
}

///|
test "bench new_fxaa_command 1000" (b : @bench.T) {
  let dst = bench_postfx_dst()
  let shader = bench_postfx_shader(3)
  b.bench(name="postfx/new_fxaa_command_1000", fn() {
    let mut acc = 0
    for _i in 0..<1000 {
      let cmd = new_fxaa_command(dst, shader, 301, 1920, 1080)
      acc = acc + cmd.resource_cache_key
    }
    b.keep(acc)
  })
}
