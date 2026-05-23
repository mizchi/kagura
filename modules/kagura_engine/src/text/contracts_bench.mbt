///|
fn make_bench_glyphs(count : Int) -> Array[@font.GlyphQuad] {
  let glyphs : Array[@font.GlyphQuad] = []
  for i in 0..<count {
    let x = (i % 64).to_double() * 12.0
    let y = (i / 64).to_double() * 12.0
    glyphs.push({
      glyph_id: i + 1,
      atlas_x: 0.0,
      atlas_y: 0.0,
      atlas_w: 10.0,
      atlas_h: 10.0,
      dst_x: x,
      dst_y: y,
      dst_w: 10.0,
      dst_h: 10.0,
    })
  }
  glyphs
}

///|
fn pipeline_dispatch_checksum(
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
      @gfx.dispatch_checksum(@gfx.build_draw_command_dispatch(command))
  }
  checksum
}

///|
test "bench build_draw_commands warm cache 512" (b : @bench.T) {
  let cache = @font.GlyphCache::new(4096.0, 4096.0, 1)
  let builder = SimpleTextBatchBuilder::new(cache, 0)
  let glyphs = make_bench_glyphs(512)
  let target = @gfx.new_image_handle(1, 1024, 1024)
  let shader = @gfx.new_shader_handle(1, "text_shader")
  let _ = builder.build_draw_commands(target, glyphs, shader) catch { _ => [] }
  b.bench(name="build_draw_commands/warm_cache_512", fn() {
    let commands = builder.build_draw_commands(target, glyphs, shader) catch {
      _ => []
    }
    b.keep(commands.length())
  })
}

///|
test "bench build_draw_commands cold cache 512" (b : @bench.T) {
  let glyphs = make_bench_glyphs(512)
  let target = @gfx.new_image_handle(1, 1024, 1024)
  let shader = @gfx.new_shader_handle(1, "text_shader")
  b.bench(name="build_draw_commands/cold_cache_512", fn() {
    let cache = @font.GlyphCache::new(4096.0, 4096.0, 1)
    let builder = SimpleTextBatchBuilder::new(cache, 0)
    let commands = builder.build_draw_commands(target, glyphs, shader) catch {
      _ => []
    }
    b.keep(commands.length())
  })
}

///|
test "bench draw pipeline warm cache 512" (b : @bench.T) {
  let cache = @font.GlyphCache::new(4096.0, 4096.0, 1)
  let builder = SimpleTextBatchBuilder::new(cache, 0)
  let glyphs = make_bench_glyphs(512)
  let target = @gfx.new_image_handle(1, 1024, 1024)
  let shader = @gfx.new_shader_handle(1, "text_shader")
  let _ = builder.build_draw_commands(target, glyphs, shader) catch { _ => [] }
  b.bench(name="draw_pipeline/warm_cache_512", fn() {
    let commands = builder.build_draw_commands(target, glyphs, shader) catch {
      _ => []
    }
    b.keep(pipeline_dispatch_checksum(commands))
  })
}

///|
test "bench draw pipeline cold cache 512" (b : @bench.T) {
  let glyphs = make_bench_glyphs(512)
  let target = @gfx.new_image_handle(1, 1024, 1024)
  let shader = @gfx.new_shader_handle(1, "text_shader")
  b.bench(name="draw_pipeline/cold_cache_512", fn() {
    let cache = @font.GlyphCache::new(4096.0, 4096.0, 1)
    let builder = SimpleTextBatchBuilder::new(cache, 0)
    let commands = builder.build_draw_commands(target, glyphs, shader) catch {
      _ => []
    }
    b.keep(pipeline_dispatch_checksum(commands))
  })
}
