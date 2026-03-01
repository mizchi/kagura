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
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
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
  let scene = scene3d(objects=[], camera~)
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
    camera~,
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
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
    lighting~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  // With per-face lighting, a cube should produce multiple batches
  // (faces pointing up vs front vs sides have different NdotL)
  assert_true(cmds.length() > 1)
}

///|
test "render_scene3d material None uses color and no src_image_ids" {
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
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
  // All commands should have empty src_image_ids
  for cmd in cmds {
    assert_eq(cmd.src_image_ids.length(), 0)
  }
}

///|
test "render_scene3d material with texture sets src_image_ids" {
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
  let mat : Material = {
    color: @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0),
    src_image_id: 42,
  }
  let scene = scene3d(
    objects=[object3d(mesh=cube, material=Some(mat))],
    camera~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
  // All commands should have src_image_ids=[42]
  for cmd in cmds {
    assert_eq(cmd.src_image_ids.length(), 1)
    assert_eq(cmd.src_image_ids[0], 42)
  }
}

///|
test "frustum culling: object far to the side is culled" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  // Place object way off to the side (x=100)
  let scene = scene3d(
    objects=[
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(100.0, 0.0, 0.0),
        color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      ),
    ],
    camera~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_eq(cmds.length(), 0)
}

///|
test "frustum culling: object in view is not culled" {
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
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_true(cmds.length() > 0)
}

///|
test "frustum culling: object behind far plane is culled" {
  let dst = @gfx.new_image_handle(0, 640, 480)
  let shader = @gfx.new_shader_handle(0, "")
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 0.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::new(0.0, 1.0, 0.0),
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    50.0,
  )
  // Place object beyond far plane
  let scene = scene3d(
    objects=[
      object3d(
        mesh=cube,
        position=@math3d.Vec3::new(0.0, 0.0, -200.0),
        color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0),
      ),
    ],
    camera~,
  )
  let cmds = render_scene3d(scene, dst, shader, 640, 480)
  assert_eq(cmds.length(), 0)
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
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0))],
    camera~,
    lighting~,
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

///|
test "empty point/spot lights produces same output as no lights" {
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
  let dir = @light3d.DirectionalLight::new(
    @math3d.Vec3::new(0.0, -1.0, 0.0),
    @math3d.Vec3::one(),
    1.0,
  )
  let amb = @light3d.AmbientLight::new(@math3d.Vec3::one(), 0.1)
  let lighting_no_extra = @light3d.LightingEnvironment::new(dir, amb)
  let lighting_empty = @light3d.LightingEnvironment::new(
    dir, amb, point_lights=[], spot_lights=[],
  )
  let scene1 = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
    lighting=lighting_no_extra,
  )
  let scene2 = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
    lighting=lighting_empty,
  )
  let cmds1 = render_scene3d(scene1, dst, shader, 640, 480)
  let cmds2 = render_scene3d(scene2, dst, shader, 640, 480)
  assert_eq(cmds1.length(), cmds2.length())
}

///|
test "PointLight changes bucket distribution" {
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
  // Dim directional light pointing sideways (x-axis), so top/front faces get ~0 ndotl
  let dir = @light3d.DirectionalLight::new(
    @math3d.Vec3::new(-1.0, 0.0, 0.0),
    @math3d.Vec3::one(),
    0.3,
  )
  let amb = @light3d.AmbientLight::new(@math3d.Vec3::one(), 0.05)
  // Without point light: most faces are dark (low ndotl from x-direction)
  let lighting_no = @light3d.LightingEnvironment::new(dir, amb)
  // With point light in front of cube: illuminates the front face (z+ normal)
  let pl = @light3d.PointLight::new(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::one(),
    3.0,
    10.0,
  )
  let lighting_with = @light3d.LightingEnvironment::new(
    dir, amb, point_lights=[pl],
  )
  let scene_no = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0))],
    camera~,
    lighting=lighting_no,
  )
  let scene_with = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0))],
    camera~,
    lighting=lighting_with,
  )
  let cmds_no = render_scene3d(scene_no, dst, shader, 640, 480)
  let cmds_with = render_scene3d(scene_with, dst, shader, 640, 480)
  assert_true(cmds_no.length() > 0)
  assert_true(cmds_with.length() > 0)
  // The point light should change the distribution: different number of commands
  // or different triangle counts per command
  let mut differ = cmds_no.length() != cmds_with.length()
  if not(differ) {
    for i in 0..<cmds_no.length() {
      if cmds_no[i].vertex_data.length() != cmds_with[i].vertex_data.length() {
        differ = true
        break
      }
    }
  }
  assert_true(differ)
}

///|
test "PointLight outside radius has no effect" {
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
  let dir = @light3d.DirectionalLight::new(
    @math3d.Vec3::new(0.0, -1.0, 0.0),
    @math3d.Vec3::one(),
    1.0,
  )
  let amb = @light3d.AmbientLight::new(@math3d.Vec3::one(), 0.1)
  // Point light very far away with small radius
  let pl = @light3d.PointLight::new(
    @math3d.Vec3::new(1000.0, 1000.0, 1000.0),
    @math3d.Vec3::one(),
    1.0,
    2.0,
  )
  let lighting_no = @light3d.LightingEnvironment::new(dir, amb)
  let lighting_far = @light3d.LightingEnvironment::new(
    dir, amb, point_lights=[pl],
  )
  let scene_no = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
    lighting=lighting_no,
  )
  let scene_far = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 0.0, 0.0, 1.0))],
    camera~,
    lighting=lighting_far,
  )
  let cmds_no = render_scene3d(scene_no, dst, shader, 640, 480)
  let cmds_far = render_scene3d(scene_far, dst, shader, 640, 480)
  assert_eq(cmds_no.length(), cmds_far.length())
}

///|
test "SpotLight cone illumination" {
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
  // Dim directional pointing sideways
  let dir = @light3d.DirectionalLight::new(
    @math3d.Vec3::new(-1.0, 0.0, 0.0),
    @math3d.Vec3::one(),
    0.2,
  )
  let amb = @light3d.AmbientLight::new(@math3d.Vec3::one(), 0.05)
  // SpotLight pointing at front face from z+, wide cone
  let sl = @light3d.SpotLight::new(
    @math3d.Vec3::new(0.0, 0.0, 5.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::one(),
    3.0,
    20.0,
    0.5,
    1.0,
  )
  let lighting_no = @light3d.LightingEnvironment::new(dir, amb)
  let lighting_spot = @light3d.LightingEnvironment::new(
    dir, amb, spot_lights=[sl],
  )
  let scene_no = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0))],
    camera~,
    lighting=lighting_no,
  )
  let scene_spot = scene3d(
    objects=[object3d(mesh=cube, color=@math3d.Vec4::new(1.0, 1.0, 1.0, 1.0))],
    camera~,
    lighting=lighting_spot,
  )
  let cmds_no = render_scene3d(scene_no, dst, shader, 640, 480)
  let cmds_spot = render_scene3d(scene_spot, dst, shader, 640, 480)
  assert_true(cmds_no.length() > 0)
  assert_true(cmds_spot.length() > 0)
  // SpotLight should change bucket distribution
  let mut differ = cmds_no.length() != cmds_spot.length()
  if not(differ) {
    for i in 0..<cmds_no.length() {
      if cmds_no[i].vertex_data.length() != cmds_spot[i].vertex_data.length() {
        differ = true
        break
      }
    }
  }
  assert_true(differ)
}
