///|
test "decode_triangle_payload returns defaults without enough vertices" {
  let payload = decode_triangle_payload([0.1, 0.2], [], [], [])
  assert_true(!payload.has_payload)
  assert_eq(payload.texture_seed, 0)
  assert_true(payload.uniform_r > 0.9)
}

///|
test "decode_triangle_payload decodes xyuv and color seed" {
  let payload = decode_triangle_payload(
    [
      -0.5, -0.5, 0.0, 0.0, 0.5, -0.5, 1.0, 0.0, 0.5, 0.5, 1.0, 1.0, -0.5, 0.5, 0.0,
      1.0,
    ],
    [0, 1, 2, 2, 3, 0],
    [64, 128, 255, 255],
    [9],
  )

  assert_true(payload.has_payload)
  assert_true(payload.ax < -0.4)
  assert_true(payload.bx > 0.4)
  assert_true(payload.cx > 0.4)
  assert_true(payload.au < 0.1)
  assert_true(payload.bu > 0.9)
  assert_true(payload.cu > 0.9)
  assert_true(payload.uniform_r > 0.2)
  assert_true(payload.uniform_g > 0.4)
  assert_true(payload.uniform_b > 0.9)
  assert_true(payload.uniform_a > 0.9)
  assert_eq(payload.texture_seed, 9)
}

///|
test "clamp_unit clamps to 0-1 range" {
  assert_eq(clamp_unit(-0.5), 0.0)
  assert_eq(clamp_unit(0.0), 0.0)
  assert_eq(clamp_unit(0.5), 0.5)
  assert_eq(clamp_unit(1.0), 1.0)
  assert_eq(clamp_unit(2.0), 1.0)
}

///|
test "decode_triangle_payload empty arrays returns default" {
  let payload = decode_triangle_payload([], [], [], [])
  assert_true(!payload.has_payload)
  assert_eq(payload.texture_seed, 0)
}

///|
test "decode_triangle_payload negative src_image_id clamps to 0" {
  let payload = decode_triangle_payload(
    [-0.5, -0.5, 0.0, 0.0, 0.5, -0.5, 1.0, 0.0, 0.5, 0.5, 1.0, 1.0],
    [],
    [],
    [-5],
  )
  assert_true(payload.has_payload)
  assert_eq(payload.texture_seed, 0)
}

///|
test "decode_triangle_payload uniform out of range uses fallback" {
  let payload = decode_triangle_payload(
    [-0.5, -0.5, 0.0, 0.0, 0.5, -0.5, 1.0, 0.0, 0.5, 0.5, 1.0, 1.0],
    [],
    [300, -10],
    [],
  )
  assert_true(payload.has_payload)
  // 300 > 255 → fallback 1.0, -10 < 0 → fallback 1.0
  assert_true(payload.uniform_r > 0.9)
  assert_true(payload.uniform_g > 0.9)
}

///|
test "default_triangle_payload has expected shape" {
  let p = default_triangle_payload()
  assert_true(!p.has_payload)
  assert_eq(p.ax, 0.0)
  assert_eq(p.ay, 0.5)
  assert_eq(p.bx, -0.5)
  assert_eq(p.by, -0.5)
  assert_eq(p.cx, 0.5)
  assert_eq(p.cy, -0.5)
  assert_eq(p.texture_seed, 0)
}

///|
test "decode_triangle_payload xyuv with explicit indices" {
  // 4 vertices (xyuv), indices select 1,2,3
  let payload = decode_triangle_payload(
    [
      0.0, 0.0, 0.0, 0.0, // vertex 0
       1.0, 0.0, 1.0, 0.0, // vertex 1
       1.0, 1.0, 1.0, 1.0, // vertex 2
       0.0, 1.0, 0.0, 1.0, // vertex 3
    ],
    [1, 2, 3],
    [],
    [],
  )
  assert_true(payload.has_payload)
  assert_eq(payload.ax, 1.0)
  assert_eq(payload.ay, 0.0)
  assert_eq(payload.bx, 1.0)
  assert_eq(payload.by, 1.0)
  assert_eq(payload.cx, 0.0)
  assert_eq(payload.cy, 1.0)
}

///|
test "decode_triangle_payload all indices point to same vertex" {
  let payload = decode_triangle_payload(
    [5.0, 7.0, 0.5, 0.5, 10.0, 20.0, 0.0, 1.0],
    [0, 0, 0],
    [],
    [],
  )
  assert_true(payload.has_payload)
  // All three triangle vertices should be the same
  assert_eq(payload.ax, 5.0)
  assert_eq(payload.bx, 5.0)
  assert_eq(payload.cx, 5.0)
}

///|
test "decode_triangle_payload xy-only with indices" {
  // 4 xy-only vertices (8 doubles), indices select 3,0,1
  let payload = decode_triangle_payload(
    [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0],
    [3, 0, 1],
    [],
    [],
  )
  assert_true(payload.has_payload)
  assert_eq(payload.ax, 70.0)
  assert_eq(payload.ay, 80.0)
  assert_eq(payload.bx, 10.0)
  assert_eq(payload.by, 20.0)
  assert_eq(payload.cx, 30.0)
  assert_eq(payload.cy, 40.0)
}

///|
test "decode_triangle_payload multiple src_image_ids uses first" {
  let payload = decode_triangle_payload(
    [-0.5, -0.5, 0.0, 0.0, 0.5, -0.5, 1.0, 0.0, 0.5, 0.5, 1.0, 1.0],
    [],
    [],
    [42, 99, 7],
  )
  assert_eq(payload.texture_seed, 42)
}

///|
test "decode_triangle_payload uniform channels precise" {
  let payload = decode_triangle_payload(
    [-0.5, -0.5, 0.0, 0.0, 0.5, -0.5, 1.0, 0.0, 0.5, 0.5, 1.0, 1.0],
    [],
    [0, 128, 255, 0],
    [],
  )
  assert_true(payload.has_payload)
  assert_eq(payload.uniform_r, 0.0)
  assert_true((payload.uniform_g - 128.0 / 255.0).abs() < 0.01)
  assert_eq(payload.uniform_b, 1.0)
  assert_eq(payload.uniform_a, 0.0)
}

///|
test "clamp_unit extreme values" {
  assert_eq(clamp_unit(-1000.0), 0.0)
  assert_eq(clamp_unit(1000.0), 1.0)
  assert_eq(clamp_unit(0.5), 0.5)
  assert_eq(clamp_unit(0.0), 0.0)
  assert_eq(clamp_unit(1.0), 1.0)
  assert_eq(clamp_unit(0.999), 0.999)
}

///|
test "decode_triangle_payload decodes xy-only vertices" {
  let payload = decode_triangle_payload(
    [-0.9, 0.7, -0.4, -0.6, 0.8, -0.3],
    [],
    [],
    [],
  )
  assert_true(payload.has_payload)
  assert_true(payload.ax < -0.8)
  assert_true(payload.ay > 0.6)
  assert_true(payload.bx < -0.3)
  assert_true(payload.by < -0.5)
  assert_true(payload.cx > 0.7)
  assert_true(payload.cy < -0.2)
  assert_true(payload.uniform_r > 0.9)
}
