///|
test "render_scene3d generates commands for visible objects" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[
      object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)),
    ],
    camera=camera,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
}

///|
test "render_scene3d returns empty for empty scene" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(objects=[], camera=camera)
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "render_scene3d culls objects behind camera" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  // Camera looks toward -Z, object is behind camera at +Z=20
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let scene = scene3d(
    objects=[
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(0.0, 0.0, 20.0),
        color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      ),
    ],
    camera=camera,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "render_scene3d per-face lighting produces multiple commands" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(0.0, -1.0, 0.0),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      1.0,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.1),
  )
  let scene = scene3d(
    objects=[
      object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0)),
    ],
    camera=camera,
    lighting=lighting,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  // With per-face lighting, a cube should produce multiple batches
  // (faces pointing up vs front vs sides have different NdotL)
  assert_true(cmds.length() > 1)
}

///|
test "render_scene3d UV passthrough" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  // Use a cube which has UVs and is visible from an angled camera
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 5.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(0.0, -1.0, 0.0),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      0.5,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.5),
  )
  let scene = scene3d(
    objects=[
      object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)),
    ],
    camera=camera,
    lighting=lighting,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
  // Check that UV values are present in at least one command (not all zeros)
  let mut has_nonzero_uv = false
  for cmd in cmds {
    let vdata = cmd.vertex_data
    let vert_count = vdata.length() / 4
    for i in 0..<vert_count {
      let u = vdata[i * 4 + 2]
      let v = vdata[i * 4 + 3]
      if u != 0.0 || v != 0.0 {
        has_nonzero_uv = true
        break
      }
    }
    if has_nonzero_uv {
      break
    }
  }
  assert_true(has_nonzero_uv)
}
