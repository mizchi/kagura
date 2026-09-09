///|
/// Benchmarks for shadow depth and camera depth command builders. These
/// hash the full mesh vertex data per call for the resource_cache_key,
/// so even small meshes can dominate frame setup when many casters are
/// rendered.

///|
test "bench new_shadow_depth_command cube x100" (b : @bench.T) {
  let shadow_map = @gfx.new_image_handle(50, 2048, 2048)
  let shader = @gfx.new_shader_handle(51, "shadow_depth_bench")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let light_vp = @math3d.Mat4::translation(0.0, 0.0, -5.0)
  b.bench(name="shadow3d/new_shadow_depth_command_cube_100", fn() {
    let mut acc = 0
    for i in 0..<100 {
      let model = @math3d.Mat4::translation(i.to_double(), 0.0, 0.0)
      let cmd = new_shadow_depth_command(
        shadow_map, shader, mesh, model, light_vp,
      )
      acc = acc + cmd.resource_cache_key
    }
    b.keep(acc)
  })
}

///|
test "bench new_camera_depth_command cube x100" (b : @bench.T) {
  let depth_target = @gfx.new_image_handle(60, 1920, 1080)
  let shader = @gfx.new_shader_handle(61, "camera_depth_bench")
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  b.bench(name="shadow3d/new_camera_depth_command_cube_100", fn() {
    let mut acc = 0
    for i in 0..<100 {
      let camera_vp = @math3d.Mat4::translation(i.to_double(), 0.0, -5.0)
      let cmd = new_camera_depth_command(depth_target, shader, mesh, camera_vp)
      acc = acc + cmd.resource_cache_key
    }
    b.keep(acc)
  })
}
