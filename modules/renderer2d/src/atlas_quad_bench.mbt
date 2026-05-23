///|
/// Micro-benchmarks for the atlas quad hot path. These isolate the cost of
/// individual builders so regressions in cache-key hashing or vertex packing
/// do not get swallowed by full-pipeline benches in kagura_engine.

///|
fn bench_atlas_draw_source(page_image_id : Int) -> @atlas.AtlasDrawSource {
  let repo = @atlas.new_simple_atlas_image_repository(8, 8, page_image_id)
  let key = @atlas.new_asset_key("renderer2d/bench/source")
  let _ = @atlas.create_atlas_image(repo, key, @atlas.default_image_spec(2, 2))
  match @atlas.get_atlas_draw_source(repo, key) {
    Some(value) => value
    None => panic()
  }
}

///|
test "bench atlas_quad_resource_cache_key 10000" (b : @bench.T) {
  let source = bench_atlas_draw_source(820)
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "atlas_quad_bench")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let uniform_dwords = [1, 2, 3, 4]
  b.bench(name="atlas_quad/resource_cache_key_10000", fn() {
    let mut acc = 0
    for i in 0..<10000 {
      let left = (i % 256).to_double() * 2.0
      let top = (i / 256).to_double() * 2.0
      acc = acc +
        atlas_quad_resource_cache_key(
          dst,
          shader,
          dst_region,
          blend,
          source,
          left,
          top,
          left + 2.0,
          top + 2.0,
          uniform_dwords,
        )
    }
    b.keep(acc)
  })
}

///|
test "bench atlas_quad_vertex_data 10000" (b : @bench.T) {
  let source = bench_atlas_draw_source(821)
  b.bench(name="atlas_quad/vertex_data_10000", fn() {
    let mut acc = 0.0
    for i in 0..<10000 {
      let left = (i % 256).to_double() * 2.0
      let top = (i / 256).to_double() * 2.0
      let v = atlas_quad_vertex_data(source, left, top, left + 2.0, top + 2.0)
      acc = acc + v[0] + v[15]
    }
    b.keep(acc)
  })
}

///|
test "bench new_atlas_quad_draw_command 10000" (b : @bench.T) {
  let source = bench_atlas_draw_source(822)
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "atlas_quad_bench")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let uniform_dwords = [1, 2, 3, 4]
  b.bench(name="atlas_quad/new_draw_command_10000", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<10000 {
      let left = (i % 256).to_double() * 2.0
      let top = (i / 256).to_double() * 2.0
      commands.push(
        new_atlas_quad_draw_command(
          dst,
          shader,
          dst_region,
          0,
          7,
          11,
          blend,
          source,
          left,
          top,
          left + 2.0,
          top + 2.0,
          uniform_dwords,
        ),
      )
    }
    b.keep(commands.length())
  })
}
