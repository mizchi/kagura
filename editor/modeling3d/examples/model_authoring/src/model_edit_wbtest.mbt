///|
fn approx(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
test "camera ray from screen center points at orbit target" {
  let orbit = @camera3d.OrbitCamera::new(
    @math3d.Vec3::zero(),
    4.0,
    0.0,
    0.0,
    @math.PI / 4.0,
    640.0 / 480.0,
    0.1,
    20.0,
  )
  let camera = orbit.to_camera3d()
  let ray = @modeling3d.camera_ray_from_cursor(camera, 640, 480, 320.0, 240.0)
  let expected = camera.target.sub(ray.origin).normalize()
  assert_true(ray.direction.approx_eq(expected, 1.0e-6))
}

///|
test "horizontal plane intersection returns the ray origin when already on plane" {
  let ray : @modeling3d.WorldRay = {
    origin: @math3d.Vec3::new(1.0, 0.0, 2.0),
    direction: @math3d.Vec3::new(0.0, 0.0, -1.0),
  }
  match @modeling3d.intersect_horizontal_plane(ray, 0.0) {
    Some(hit) => assert_true(hit.approx_eq(ray.origin, 1.0e-9))
    None => fail("expected parallel ray on plane to produce a hit")
  }
}

///|
test "append sculpt stamp adds a new layer-local edit operation" {
  let doc = default_model_document()
  let center = @math3d.Vec3::new(0.25, 0.85, 0.1)
  let next = @modeling3d.append_sculpt_stamp(
    doc,
    0,
    @modeling3d.SculptMode::Add,
    center,
    0.22,
  )
  let prev_layer = doc.sculpt_layers[0]
  let next_layer = next.sculpt_layers[0]

  assert_eq(next_layer.stamps.length(), prev_layer.stamps.length() + 1)
  let stamp = next_layer.stamps[next_layer.stamps.length() - 1]
  assert_true(stamp.center.approx_eq(center, 1.0e-9))
  assert_true(approx(stamp.radius, 0.22))
  match stamp.mode {
    @modeling3d.SculptMode::Add => ()
    Subtract => fail("expected appended stamp to keep add mode")
  }
  assert_true(stamp.id.contains("add"))
}

///|
test "append sculpt stamp with symmetry adds a mirrored partner on the x axis" {
  let doc = default_model_document()
  let center = @math3d.Vec3::new(0.25, 0.85, 0.1)
  let next = @modeling3d.append_sculpt_stamp_with_symmetry(
    doc,
    0,
    @modeling3d.SculptMode::Add,
    center,
    0.22,
    true,
  )
  let prev_layer = doc.sculpt_layers[0]
  let next_layer = next.sculpt_layers[0]

  assert_eq(next_layer.stamps.length(), prev_layer.stamps.length() + 2)
  let primary = next_layer.stamps[next_layer.stamps.length() - 2]
  let mirror = next_layer.stamps[next_layer.stamps.length() - 1]
  assert_true(primary.center.approx_eq(center, 1.0e-9))
  assert_true(
    mirror.center.approx_eq(@math3d.Vec3::new(-0.25, 0.85, 0.1), 1.0e-9),
  )
  assert_true(mirror.id.contains("mirror"))
}

///|
test "append sculpt stamp with symmetry does not duplicate centerline edits" {
  let doc = default_model_document()
  let center = @math3d.Vec3::new(0.0, 0.85, 0.1)
  let next = @modeling3d.append_sculpt_stamp_with_symmetry(
    doc,
    0,
    @modeling3d.SculptMode::Add,
    center,
    0.22,
    true,
  )
  let prev_layer = doc.sculpt_layers[0]
  let next_layer = next.sculpt_layers[0]

  assert_eq(next_layer.stamps.length(), prev_layer.stamps.length() + 1)
}

///|
test "clamp_point_to_layer_bounds keeps edits inside voxel volume" {
  let layer = default_model_document().sculpt_layers[0]
  let clamped = @modeling3d.clamp_point_to_layer_bounds(
    layer,
    @math3d.Vec3::new(99.0, -99.0, 99.0),
  )
  let max_axis = layer.voxel_size * layer.half_extent.to_double()
  let focus_y = @modeling3d.layer_focus_y(layer)

  assert_true(clamped.x <= max_axis)
  assert_true(clamped.y >= focus_y - max_axis)
  assert_true(clamped.z <= max_axis)
}
