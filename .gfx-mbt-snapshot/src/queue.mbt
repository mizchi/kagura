///|
/// Command queue + batch-merge layer.
///
/// `CommandQueue` is the trait a renderer enqueues `DrawTrianglesCommand`
/// onto; `SimpleCommandQueue` is the reference implementation that merges
/// adjacent compatible commands within a vertex budget.
///
/// `flush_commands` drives a `GraphicsDriver` from a queue, and
/// `clear_screen` performs the minimum begin/end pair without any draws.
///
/// Ebiten refs:
/// - internal/graphicscommand/commandqueue.go (EnqueueDrawTrianglesCommand, Flush)

///|
/// A renderer-facing buffer of pending `DrawTrianglesCommand`s.
///
/// Renderers `enqueue_draw_triangles` during their `draw` pass and the
/// frame driver later calls `flush` to consume them. The flush phase is
/// where an implementation may merge adjacent compatible commands (same
/// pipeline / shader / blend / images / uniforms) to reduce the number
/// of backend draw calls.
///
/// `SimpleCommandQueue` is the reference implementation; bring your own
/// if you need a different merge policy.
pub(open) trait CommandQueue {
  /// Append one command to the back of the queue.
  /// Ebiten ref: commandQueue.EnqueueDrawTrianglesCommand.
  enqueue_draw_triangles(Self, command : DrawTrianglesCommand) -> Unit

  /// Drain the queue and return the (possibly merged) commands in
  /// submission order. The queue is empty after this call.
  /// Ebiten ref: commandQueue.Flush / FlushCommands.
  flush(Self) -> Array[DrawTrianglesCommand]
}

///|
pub struct SimpleCommandQueue {
  mut commands : Array[DrawTrianglesCommand]
} derive(Debug)

///|
fn blend_factor_eq(lhs : BlendFactor, rhs : BlendFactor) -> Bool {
  blend_factor_to_int(lhs) == blend_factor_to_int(rhs)
}

///|
fn blend_operation_eq(lhs : BlendOperation, rhs : BlendOperation) -> Bool {
  blend_operation_to_int(lhs) == blend_operation_to_int(rhs)
}

///|
fn blend_equation_eq(lhs : BlendEquation, rhs : BlendEquation) -> Bool {
  blend_factor_eq(lhs.src_factor_rgb, rhs.src_factor_rgb) &&
  blend_factor_eq(lhs.dst_factor_rgb, rhs.dst_factor_rgb) &&
  blend_operation_eq(lhs.op_rgb, rhs.op_rgb) &&
  blend_factor_eq(lhs.src_factor_alpha, rhs.src_factor_alpha) &&
  blend_factor_eq(lhs.dst_factor_alpha, rhs.dst_factor_alpha) &&
  blend_operation_eq(lhs.op_alpha, rhs.op_alpha)
}

///|
fn blend_mode_eq(lhs : BlendMode, rhs : BlendMode) -> Bool {
  match lhs {
    BlendMode::Copy =>
      match rhs {
        BlendMode::Copy => true
        _ => false
      }
    BlendMode::Alpha =>
      match rhs {
        BlendMode::Alpha => true
        _ => false
      }
    BlendMode::Add =>
      match rhs {
        BlendMode::Add => true
        _ => false
      }
    BlendMode::Multiply =>
      match rhs {
        BlendMode::Multiply => true
        _ => false
      }
    BlendMode::Custom(eq_l) =>
      match rhs {
        BlendMode::Custom(eq_r) => blend_equation_eq(eq_l, eq_r)
        _ => false
      }
  }
}

///|
fn int_array_eq(lhs : Array[Int], rhs : Array[Int]) -> Bool {
  if lhs.length() != rhs.length() {
    return false
  }
  for i in 0..<lhs.length() {
    if lhs[i] != rhs[i] {
      return false
    }
  }
  true
}

///|
let vertex_stride : Int = 4

///|
let max_merge_vertex_floats : Int = 16384

///|
fn can_merge_draw_triangles(
  lhs : DrawTrianglesCommand,
  rhs : DrawTrianglesCommand,
) -> Bool {
  // Instanced commands cannot be merged
  if lhs.instance_count != 1 || rhs.instance_count != 1 {
    return false
  }
  let lhs_explicit = lhs.vertex_data.length() > 0 || lhs.indices.length() > 0
  let rhs_explicit = rhs.vertex_data.length() > 0 || rhs.indices.length() > 0
  lhs_explicit == rhs_explicit &&
  lhs.vertex_data.length() + rhs.vertex_data.length() <= max_merge_vertex_floats &&
  lhs.dst.id == rhs.dst.id &&
  lhs.shader.id == rhs.shader.id &&
  blend_mode_eq(lhs.blend, rhs.blend) &&
  lhs.pipeline_id == rhs.pipeline_id &&
  lhs.uniform_hash == rhs.uniform_hash &&
  lhs.index_offset == rhs.index_offset &&
  int_array_eq(lhs.src_image_ids, rhs.src_image_ids) &&
  int_array_eq(lhs.uniform_dwords, rhs.uniform_dwords)
}

///|
fn can_merge_draw_triangles_with_vertex_budget(
  lhs : DrawTrianglesCommand,
  rhs : DrawTrianglesCommand,
  lhs_vertex_float_count : Int,
) -> Bool {
  can_merge_draw_triangles(lhs, rhs) &&
  lhs_vertex_float_count + rhs.vertex_data.length() <= max_merge_vertex_floats
}

///|
fn merge_draw_triangles_range(
  commands : Array[DrawTrianglesCommand],
  start : Int,
  end : Int,
) -> DrawTrianglesCommand {
  let base = commands[start]
  let explicit = base.vertex_data.length() > 0 || base.indices.length() > 0
  let merged_regions : Array[DstRegion] = []
  for i in start..<end {
    let command = commands[i]
    for region in command.dst_regions {
      merged_regions.push(region)
    }
  }
  if !explicit {
    {
      dst: base.dst,
      shader: base.shader,
      dst_regions: merged_regions,
      index_offset: base.index_offset,
      pipeline_id: base.pipeline_id,
      uniform_hash: base.uniform_hash,
      blend: base.blend,
      vertex_data: [],
      indices: [],
      src_image_ids: base.src_image_ids,
      uniform_dwords: base.uniform_dwords,
      instance_count: base.instance_count,
      resource_cache_key: base.resource_cache_key,
      vertex_stride_hint: base.vertex_stride_hint,
    }
  } else {
    let mut merged_vertex_float_count = 0
    let mut merged_index_count = 0
    for i in start..<end {
      merged_vertex_float_count = merged_vertex_float_count +
        commands[i].vertex_data.length()
      merged_index_count = merged_index_count + commands[i].indices.length()
    }
    let merged_vertex_data : Array[Double] = Array::make(
      merged_vertex_float_count, 0.0,
    )
    let merged_indices : Array[Int] = Array::make(merged_index_count, 0)
    let mut vertex_offset = 0
    let mut index_offset = 0
    let mut vertex_base = 0
    for i in start..<end {
      let command = commands[i]
      for v in command.vertex_data {
        merged_vertex_data[vertex_offset] = v
        vertex_offset = vertex_offset + 1
      }
      for idx in command.indices {
        merged_indices[index_offset] = idx + vertex_base
        index_offset = index_offset + 1
      }
      vertex_base = vertex_base + command.vertex_data.length() / vertex_stride
    }
    {
      dst: base.dst,
      shader: base.shader,
      dst_regions: merged_regions,
      index_offset: base.index_offset,
      pipeline_id: base.pipeline_id,
      uniform_hash: base.uniform_hash,
      blend: base.blend,
      vertex_data: merged_vertex_data,
      indices: merged_indices,
      src_image_ids: base.src_image_ids,
      uniform_dwords: base.uniform_dwords,
      instance_count: base.instance_count,
      resource_cache_key: base.resource_cache_key,
      vertex_stride_hint: base.vertex_stride_hint,
    }
  }
}

///|
pub impl CommandQueue for SimpleCommandQueue with enqueue_draw_triangles(
  self,
  command,
) {
  self.commands.push(command)
}

///|
pub impl CommandQueue for SimpleCommandQueue with flush(self) {
  let buffered = self.commands
  self.commands = []
  if buffered.length() <= 1 {
    return buffered
  }
  let out : Array[DrawTrianglesCommand] = []
  let mut start = 0
  while start < buffered.length() {
    let base = buffered[start]
    let mut end = start + 1
    let mut vertex_budget = base.vertex_data.length()
    while end < buffered.length() {
      let command = buffered[end]
      if can_merge_draw_triangles_with_vertex_budget(
          base, command, vertex_budget,
        ) {
        vertex_budget = vertex_budget + command.vertex_data.length()
        end = end + 1
      } else {
        break
      }
    }
    if end - start == 1 {
      out.push(base)
    } else {
      out.push(merge_draw_triangles_range(buffered, start, end))
    }
    start = end
  }
  out
}

///|
pub fn new_simple_command_queue() -> SimpleCommandQueue {
  { commands: [] }
}

///|
pub fn[T : GraphicsDriver, Q : CommandQueue] flush_commands(
  driver : T,
  queue : Q,
  present : Bool,
  clear_color? : Color,
) -> Unit raise {
  let commands = queue.flush()
  if commands.length() == 0 && !present {
    ()
  } else {
    let color = match clear_color {
      Some(c) => c
      None => { r: 0.0, g: 0.0, b: 0.0, a: 1.0 }
    }
    driver.begin({ clear_color: color, clear_enabled: true, present })
    for command in commands {
      driver.draw_triangles(command)
    }
    driver.end(present)
  }
}

///|
pub fn[T : GraphicsDriver] clear_screen(
  driver : T,
  color : Color,
) -> Unit raise {
  driver.begin({ clear_color: color, clear_enabled: true, present: false })
  driver.end(false)
}
