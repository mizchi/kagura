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
