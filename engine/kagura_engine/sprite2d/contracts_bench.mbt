///|
/// Particle-like benchmark fixtures for sprite command build and dispatch.
///
/// `entries` is the number of images in the atlas, and it is load-bearing:
/// every `append_atlas_sprite_draw_command` calls `@atlas.get_atlas_draw_source`,
/// which scans `repo.images` comparing asset keys as strings with no early exit.
/// A one-entry repository makes that scan free and hides its cost, so these
/// fixtures size it after the only atlas in the repo that is drawn from every
/// frame: `hacknslash_3d`'s icon atlas, at 6 patterns x 4 rarities + 6 skills
/// = 30 entries. The looked-up key is registered last, which is also the
/// average case -- with no early exit the scan always visits all of them.
fn bench_particle_repo(
  atlas_id : Int,
  key_name : String,
  entries? : Int = 30,
) -> (@atlas.SimpleAtlasImageRepository, @atlas.AssetKey) {
  let repo = @atlas.new_simple_atlas_image_repository(64, 64, atlas_id)
  for i in 0..<(entries - 1) {
    let _ = @atlas.create_atlas_image(
      repo,
      @atlas.new_asset_key(key_name + "/filler_" + i.to_string()),
      @atlas.default_image_spec(2, 2),
    )
  }
  let key = @atlas.new_asset_key(key_name)
  let _ = @atlas.create_atlas_image(repo, key, @atlas.default_image_spec(2, 2))
  (repo, key)
}

///|
/// Size sweep over the asset-key scan in `@atlas.get_atlas_draw_source`, which
/// is what a per-quad atlas draw pays before it builds anything. Isolated from
/// the command builders so the slope against `entries` is readable; compare
/// against `particles/pipeline_same_state_10000`, which pays it 10,000 times.
fn bench_atlas_lookup(
  b : @bench.T,
  name : String,
  atlas_id : Int,
  entries : Int,
) -> Unit {
  let (repo, key) = bench_particle_repo(atlas_id, "particle/lookup", entries~)
  b.bench(name~, fn() {
    let mut acc = 0
    for _ in 0..<1000 {
      match @atlas.get_atlas_draw_source(repo, key) {
        Some(source) => acc = acc + source.page_image_id
        None => panic()
      }
    }
    b.keep(acc)
  })
}

///|
test "bench atlas draw source lookup 1 entry" (b : @bench.T) {
  bench_atlas_lookup(b, "particles/atlas_lookup_1x1000", 730, 1)
}

///|
test "bench atlas draw source lookup 8 entries" (b : @bench.T) {
  bench_atlas_lookup(b, "particles/atlas_lookup_8x1000", 731, 8)
}

///|
test "bench atlas draw source lookup 30 entries" (b : @bench.T) {
  bench_atlas_lookup(b, "particles/atlas_lookup_30x1000", 732, 30)
}

///|
test "bench atlas draw source lookup 128 entries" (b : @bench.T) {
  bench_atlas_lookup(b, "particles/atlas_lookup_128x1000", 733, 128)
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
      @gfx.DrawCommandDispatch::checksum(
        @gfx.DrawTrianglesCommand::build_dispatch(command),
      )
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
/// Paired with `particles/pipeline_same_state_10000`, differing only in the
/// atlas entry count. The difference is what the asset-key scan in
/// `@atlas.get_atlas_draw_source` costs inside the real per-quad path, rather
/// than in isolation -- which is the number to quote when deciding whether that
/// scan is worth indexing.
test "bench particle pipeline same state 10000 one entry atlas" (b : @bench.T) {
  let (repo, key) = bench_particle_repo(702, "particle/a", entries=1)
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader = @gfx.new_shader_handle(2, "particle_shader")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let uniform_dwords = [1, 2, 3, 4]
  b.bench(name="particles/pipeline_same_state_10000_atlas1", fn() {
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
