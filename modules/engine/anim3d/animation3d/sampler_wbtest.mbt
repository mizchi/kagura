///|
test "sampler: step interpolation vec3" {
  let channel : AnimChannel = {
    node_index: 0,
    target: Translation,
    interpolation: Step,
    times: [0.0, 1.0, 2.0],
    values: [
      0.0, 0.0, 0.0, // t=0
       1.0, 2.0, 3.0, // t=1
       4.0, 5.0, 6.0,
    ],
  } // t=2
  // At t=0.5, step should return the value at t=0
  let v = sample_vec3(channel, 0.5)
  assert_true(v.approx_eq(@math3d.Vec3::new(0.0, 0.0, 0.0), 1.0e-6))
  // At t=1.5, step should return the value at t=1
  let v2 = sample_vec3(channel, 1.5)
  assert_true(v2.approx_eq(@math3d.Vec3::new(1.0, 2.0, 3.0), 1.0e-6))
}

///|
test "sampler: linear interpolation vec3" {
  let channel : AnimChannel = {
    node_index: 0,
    target: Translation,
    interpolation: Linear,
    times: [0.0, 1.0],
    values: [
      0.0, 0.0, 0.0, // t=0
       2.0, 4.0, 6.0,
    ],
  } // t=1
  // At t=0.5, linear lerp should give midpoint
  let v = sample_vec3(channel, 0.5)
  assert_true(v.approx_eq(@math3d.Vec3::new(1.0, 2.0, 3.0), 1.0e-6))
}

///|
test "sampler: slerp quaternion interpolation" {
  // Identity -> 90-degree rotation around Y
  let q0 = @math3d.Quaternion::identity() // (0,0,0,1)
  let angle = @math.PI / 2.0
  let half = angle / 2.0
  let q1 = @math3d.Quaternion::new(0.0, @math.sin(half), 0.0, @math.cos(half))
  let channel : AnimChannel = {
    node_index: 0,
    target: Rotation,
    interpolation: Linear,
    times: [0.0, 1.0],
    values: [q0.x, q0.y, q0.z, q0.w, q1.x, q1.y, q1.z, q1.w],
  }
  // At t=0.5, slerp should give 45-degree rotation around Y
  let result = sample_quat(channel, 0.5)
  let expected_angle = @math.PI / 4.0
  let expected_half = expected_angle / 2.0
  let expected = @math3d.Quaternion::new(
    0.0,
    @math.sin(expected_half),
    0.0,
    @math.cos(expected_half),
  )
  assert_true(result.approx_eq(expected, 1.0e-4))
}

///|
test "sampler: time=0 returns first keyframe" {
  let channel : AnimChannel = {
    node_index: 0,
    target: Translation,
    interpolation: Linear,
    times: [0.5, 1.0],
    values: [
      10.0, 20.0, 30.0, // t=0.5
       40.0, 50.0, 60.0,
    ],
  } // t=1.0
  // time=0 is before first keyframe, should return first value
  let v = sample_vec3(channel, 0.0)
  assert_true(v.approx_eq(@math3d.Vec3::new(10.0, 20.0, 30.0), 1.0e-6))
}

///|
test "sampler: time>=duration returns last keyframe" {
  let channel : AnimChannel = {
    node_index: 0,
    target: Translation,
    interpolation: Linear,
    times: [0.0, 1.0],
    values: [
      0.0, 0.0, 0.0, // t=0
       5.0, 10.0, 15.0,
    ],
  } // t=1
  // time=2.0 is past last keyframe, should return last value
  let v = sample_vec3(channel, 2.0)
  assert_true(v.approx_eq(@math3d.Vec3::new(5.0, 10.0, 15.0), 1.0e-6))
}
