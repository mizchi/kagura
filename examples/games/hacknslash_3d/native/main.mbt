///|
fn main {
  // Touch the package so init installs wgpu readback hooks.
  let _ready = @native_hooks.is_ready()
  @app.run_native_app()
}
