///|
/// Benchmarks for the gfx command queue (enqueue + flush + merging).
/// Lives here so we have a stable place to track queue overhead from
/// kagura's perspective without touching the mizchi/gfx package.

///|
fn bench_queue_command(i : Int, alt_state : Bool) -> @gfx.DrawTrianglesCommand {
  let dst = @gfx.new_image_handle(1, 1920, 1080)
  let shader_id = if alt_state { 2 + (i % 4) } else { 2 }
  let shader = @gfx.new_shader_handle(shader_id, "queue_bench")
  let dst_region = @gfx.new_dst_region(0, 0, 1920, 1080, 6)
  let blend = @gfx.BlendMode::from_int(1)
  let left = (i % 256).to_double() * 2.0
  let top = (i / 256).to_double() * 2.0
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    0,
    7,
    11,
    blend,
    [left, top, 0.0, 0.0, left + 2.0, top, 1.0, 0.0, left + 2.0, top + 2.0, 1.0, 1.0,
     left, top + 2.0, 0.0, 1.0],
    [0, 1, 2, 2, 3, 0],
    [42],
    [1, 2, 3, 4],
    resource_cache_key=i + 1,
  )
}

///|
test "bench gfx queue enqueue+flush 10000 same state" (b : @bench.T) {
  // 10000 commands all sharing pipeline/blend/uniform_hash - exercises the
  // merge fast path.
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  for i in 0..<10000 {
    commands.push(bench_queue_command(i, false))
  }
  b.bench(name="gfx_queue/flush_same_state_10000", fn() {
    let queue = @gfx.new_simple_command_queue()
    for cmd in commands {
      queue.enqueue_draw_triangles(cmd)
    }
    let flushed = queue.flush()
    b.keep(flushed.length())
  })
}

///|
test "bench gfx queue enqueue+flush 10000 alternating state" (b : @bench.T) {
  // 10000 commands cycling through 4 distinct shader ids - merge mostly
  // misses, forcing per-command output.
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  for i in 0..<10000 {
    commands.push(bench_queue_command(i, true))
  }
  b.bench(name="gfx_queue/flush_alt_state_10000", fn() {
    let queue = @gfx.new_simple_command_queue()
    for cmd in commands {
      queue.enqueue_draw_triangles(cmd)
    }
    let flushed = queue.flush()
    b.keep(flushed.length())
  })
}
