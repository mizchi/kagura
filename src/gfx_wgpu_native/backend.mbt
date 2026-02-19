///|
/// Native WGPU backend bootstrap (Milestone 2: clear + triangle).
///
/// Ebiten refs:
/// - internal/graphicsdriver/* (backend abstraction)
/// - internal/ui/context.go (frame loop responsibility split)

///|
pub struct TriangleContext {
  window : GLFWwindow
  instance : WGPUInstance
  surface : WGPUSurface
  adapter : WGPUAdapter
  device : WGPUDevice
  queue : WGPUQueue
  shader : WGPUShaderModule
  pipeline : WGPURenderPipeline
}

///|
fn triangle_wgsl() -> String {
  "@vertex\nfn vs_main(@builtin(vertex_index) idx: u32) -> @builtin(position) vec4f {\n  var pos = array<vec2f, 3>(vec2f(0.0, 0.5), vec2f(-0.5, -0.5), vec2f(0.5, -0.5));\n  return vec4f(pos[idx], 0.0, 1.0);\n}\n\n@fragment\nfn fs_main() -> @location(0) vec4f {\n  return vec4f(1.0, 0.0, 0.0, 1.0);\n}"
}

///|
fn assert_true_or_panic(condition : Bool, message : String) -> Unit {
  let _ = message
  if !condition {
    panic()
  }
}

///|
pub fn try_init_triangle_context(
  width : Int,
  height : Int,
  title : String,
) -> TriangleContext? {
  if !glfw_init() {
    None
  } else {
    let window = create_window(width, height, title)
    let instance = create_instance()
    let surface = create_surface_from_glfw(instance, window)
    let adapter = request_adapter(instance, surface)
    let device = request_device(adapter)
    let queue = device_get_queue(device)

    configure_surface(surface, device, adapter, width, height)
    let shader = create_shader_module(device, triangle_wgsl())
    // BGRA8Unorm (same assumption as ~/Downloads/wgpu sample)
    let pipeline = create_render_pipeline(device, shader, 24)

    Some({ window, instance, surface, adapter, device, queue, shader, pipeline })
  }
}

///|
pub fn init_triangle_context(
  width : Int,
  height : Int,
  title : String,
) -> TriangleContext {
  match try_init_triangle_context(width, height, title) {
    Some(ctx) => ctx
    None => {
      assert_true_or_panic(false, "glfw_init failed")
      panic()
    }
  }
}

///|
pub fn render_triangle_frame(ctx : TriangleContext) -> Unit {
  render_frame(ctx.surface, ctx.device, ctx.queue, ctx.pipeline)
}

///|
pub fn should_continue(ctx : TriangleContext) -> Bool {
  !window_should_close(ctx.window)
}

///|
pub fn poll(ctx : TriangleContext) -> Unit {
  let _ = ctx
  poll_events()
}

///|
pub fn shutdown_triangle_context(ctx : TriangleContext) -> Unit {
  render_pipeline_release(ctx.pipeline)
  shader_module_release(ctx.shader)
  queue_release(ctx.queue)
  device_release(ctx.device)
  adapter_release(ctx.adapter)
  surface_release(ctx.surface)
  instance_release(ctx.instance)
  destroy_window(ctx.window)
  terminate()
}

///|
pub fn run_triangle_demo() -> Unit {
  let ctx = init_triangle_context(800, 600, "game_engine: triangle")
  while should_continue(ctx) {
    poll(ctx)
    render_triangle_frame(ctx)
  }
  shutdown_triangle_context(ctx)
}
