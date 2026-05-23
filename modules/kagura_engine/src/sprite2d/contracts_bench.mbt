///|
/// Particle-like benchmark fixtures for sprite command build and dispatch.
fn bench_particle_repo(
  atlas_id : Int,
  key_name : String,
) -> (@atlas.SimpleAtlasImageRepository, @atlas.AssetKey) {
  let repo = @atlas.new_simple_atlas_image_repository(8, 8, atlas_id)
  let key = @atlas.new_asset_key(key_name)
  let _ = @atlas.create_atlas_image(repo, key, @atlas.default_image_spec(2, 2))
  (repo, key)
}

///|
fn particle_pipeline_checksum(
  commands : Array[@gfx.DrawTrianglesCommand],
) -> Int {
  let queue = @gfx.new_simple_command_queue()
  for command in commands {
    queue.enqueue_draw_triangles(command)
  }
  let flushed = queue.flush()
  let mut checksum = flushed.length()
  for command in flushed {
    checksum = checksum +
      @gfx.DrawCommandDispatch::checksum(@gfx.DrawTrianglesCommand::build_dispatch(command))
  }
  checksum
}

///|
fn append_particle_command(
  commands : Array[@gfx.DrawTrianglesCommand],
  repo : @atlas.SimpleAtlasImageRepository,
  key : @atlas.AssetKey,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  i : Int,
  uniform_dwords : Array[Int],
) -> Unit {
  let left = (i % 256).to_double() * 2.0
  let top = (i / 256).to_double() * 2.0
  let appended = append_atlas_sprite_draw_command(
    commands,
    repo,
    key,
    dst,
    shader,
    dst_region,
    0,
    pipeline_id,
    uniform_hash,
    blend,
    left,
    top,
    left + 2.0,
    top + 2.0,
    uniform_dwords,
  )
  if !appended {
    panic()
  }
}

///|
test "bench particle pipeline same state 10000" (b : @bench.T) {
  let (repo, key) = bench_particle_repo(700, "particle/a")
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "particle_shader")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let uniform_dwords = [1, 2, 3, 4]
  b.bench(name="particles/pipeline_same_state_10000", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<10000 {
      append_particle_command(
        commands, repo, key, dst, shader, dst_region, 7, 11, blend, i, uniform_dwords,
      )
    }
    b.keep(particle_pipeline_checksum(commands))
  })
}

///|
test "bench particle pipeline varying uniform 10000" (b : @bench.T) {
  let (repo, key) = bench_particle_repo(701, "particle/a")
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "particle_shader")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  b.bench(name="particles/pipeline_varying_uniform_10000", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<10000 {
      append_particle_command(
        commands,
        repo,
        key,
        dst,
        shader,
        dst_region,
        7,
        11,
        blend,
        i,
        [i % 64],
      )
    }
    b.keep(particle_pipeline_checksum(commands))
  })
}

///|
test "bench particle pipeline alternating texture pages 10000" (b : @bench.T) {
  let (repo_a, key_a) = bench_particle_repo(710, "particle/a")
  let (repo_b, key_b) = bench_particle_repo(711, "particle/b")
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "particle_shader")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let uniform_dwords = [1, 2, 3, 4]
  b.bench(name="particles/pipeline_alternating_texture_pages_10000", fn() {
    let commands : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<10000 {
      if i % 2 == 0 {
        append_particle_command(
          commands, repo_a, key_a, dst, shader, dst_region, 7, 11, blend, i, uniform_dwords,
        )
      } else {
        append_particle_command(
          commands, repo_b, key_b, dst, shader, dst_region, 7, 11, blend, i, uniform_dwords,
        )
      }
    }
    b.keep(particle_pipeline_checksum(commands))
  })
}

///|
test "bench particle pipeline batched 10000" (b : @bench.T) {
  // Counterpart to particles/pipeline_same_state_10000 using the batched
  // atlas_quad API: one DrawTrianglesCommand for all 10000 quads instead
  // of 10000 individual commands. The rect buffer is rebuilt every
  // iteration so we're measuring the same per-frame work.
  let (repo, key) = bench_particle_repo(720, "particle/batch")
  let source = match @atlas.get_atlas_draw_source(repo, key) {
    Some(s) => s
    None => panic()
  }
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "particle_shader_batch")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let uniform_dwords = [1, 2, 3, 4]
  let rects : Array[Double] = Array::make(10000 * 4, 0.0)
  b.bench(name="particles/pipeline_batched_10000", fn() {
    for i in 0..<10000 {
      let left = (i % 256).to_double() * 2.0
      let top = (i / 256).to_double() * 2.0
      rects[i * 4] = left
      rects[i * 4 + 1] = top
      rects[i * 4 + 2] = left + 2.0
      rects[i * 4 + 3] = top + 2.0
    }
    let cmd = @renderer2d.new_atlas_quad_batch_draw_command(
      dst, shader, dst_region, 7, 11, blend, source, rects, uniform_dwords,
    )
    let queue = @gfx.new_simple_command_queue()
    queue.enqueue_draw_triangles(cmd)
    let flushed = queue.flush()
    b.keep(flushed.length() + cmd.resource_cache_key)
  })
}
