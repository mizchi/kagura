///|
/// Graphics backend contracts.
/// Ebiten refs:
/// - internal/graphicsdriver/graphics.go
/// - internal/graphicscommand/commandqueue.go
/// - internal/atlas/image.go

///|
pub struct DstRegion {
  x : Int
  y : Int
  width : Int
  height : Int
  index_count : Int
} derive(Show)

///|
pub struct Color {
  r : Double
  g : Double
  b : Double
  a : Double
} derive(Show)

///|
pub struct RenderPassDesc {
  clear_color : Color
  present : Bool
} derive(Show)

///|
pub fn new_color(r : Double, g : Double, b : Double, a : Double) -> Color {
  { r, g, b, a }
}

///|
pub fn new_render_pass_desc(
  clear_color : Color,
  present : Bool,
) -> RenderPassDesc {
  { clear_color, present }
}

///|
pub enum BlendMode {
  Copy
  Alpha
  Add
  Multiply
} derive(Show)

///|
pub enum FilterMode {
  Nearest
  Linear
  Pixelated
} derive(Show)

///|
pub struct ImageHandle {
  id : Int
  width : Int
  height : Int
} derive(Show)

///|
pub struct ShaderHandle {
  id : Int
  source : String
} derive(Show)

///|
pub struct PipelineHandle {
  id : Int
} derive(Show)

///|
pub fn new_pipeline_handle(id : Int) -> PipelineHandle {
  { id, }
}

///|
pub struct DrawTrianglesCommand {
  dst : ImageHandle
  shader : ShaderHandle
  dst_regions : Array[DstRegion]
  index_offset : Int
  blend : BlendMode
}

///|
pub trait GraphicsDriver {
  /// Ebiten ref: Graphics.Initialize/Begin/End
  initialize(Self) -> Unit raise
  begin(Self, pass : RenderPassDesc) -> Unit raise
  end(Self, present : Bool) -> Unit raise

  /// Ebiten ref: Graphics.NewImage/NewShader
  new_image(Self, width : Int, height : Int) -> ImageHandle raise
  new_shader(Self, source : String) -> ShaderHandle raise

  /// Ebiten ref: Graphics.DrawTriangles
  draw_triangles(Self, command : DrawTrianglesCommand) -> Unit raise
}

///|
pub trait CommandQueue {
  /// Ebiten ref: commandQueue.EnqueueDrawTrianglesCommand
  enqueue_draw_triangles(Self, command : DrawTrianglesCommand) -> Unit

  /// Ebiten ref: commandQueue.Flush / FlushCommands
  flush(Self) -> Array[DrawTrianglesCommand]
}

///|
pub struct SimpleCommandQueue {
  mut commands : Array[DrawTrianglesCommand]
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
  let out = self.commands
  self.commands = []
  out
}

///|
pub fn new_simple_command_queue() -> SimpleCommandQueue {
  { commands: [] }
}

///|
pub fn[T : CommandQueue] new_command_queue() -> T {
  panic()
}

///|
pub fn[T : GraphicsDriver, Q : CommandQueue] flush_commands(
  driver : T,
  queue : Q,
  present : Bool,
) -> Unit raise {
  let commands = queue.flush()
  if commands.length() == 0 && !present {
    ()
  } else {
    driver.begin({ clear_color: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 }, present })
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
  driver.begin({ clear_color: color, present: false })
  driver.end(false)
}
