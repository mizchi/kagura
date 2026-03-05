///|
test "compute_attenuation inverse model - at ref distance" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(1.0, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
  let gain = compute_attenuation(source, listener)
  // At ref_distance, gain = 1 / (1 + 0) = 1.0
  assert_true((gain - 1.0).abs() < 0.001)
}

///|
test "compute_attenuation inverse model - at double ref distance" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(2.0, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
  let gain = compute_attenuation(source, listener)
  // d=2, ref=1: gain = 1 / (1 + (2-1)/1 * 1) = 1/2 = 0.5
  assert_true((gain - 0.5).abs() < 0.001)
}

///|
test "compute_attenuation linear model" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(5.5, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 10.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Linear,
    base_volume: 1.0,
  }
  let gain = compute_attenuation(source, listener)
  // d=5.5, ref=1, max=10: gain = 1 - 1 * (5.5-1)/(10-1) = 1 - 4.5/9 = 0.5
  assert_true((gain - 0.5).abs() < 0.001)
}

///|
test "compute_attenuation linear model - at max distance" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(10.0, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 10.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Linear,
    base_volume: 1.0,
  }
  let gain = compute_attenuation(source, listener)
  // At max_distance: gain = 1 - 1*(10-1)/(10-1) = 0.0
  assert_true((gain - 0.0).abs() < 0.001)
}

///|
test "compute_attenuation exponential model" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(2.0, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Exponential,
    base_volume: 1.0,
  }
  let gain = compute_attenuation(source, listener)
  // (2/1)^(-1) = 0.5
  assert_true((gain - 0.5).abs() < 0.001)
}

///|
test "compute_pan - source on the right" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(5.0, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
  let pan = compute_pan(source, listener)
  // Source is on the right side (positive x)
  // forward = (0,0,-1), up = (0,1,0), right = forward x up = (-1,0,0) x ...
  // Actually: right = (0,0,-1) x (0,1,0) = (0*0 - (-1)*1, (-1)*0 - 0*0, 0*1 - 0*0) = (1, 0, 0)
  // direction to source = (1,0,0), dot with right (1,0,0) = 1.0
  assert_true((pan - 1.0).abs() < 0.01)
}

///|
test "compute_pan - source on the left" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(-5.0, 0.0, 0.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
  let pan = compute_pan(source, listener)
  // Source on the left, pan should be -1.0
  assert_true((pan - -1.0).abs() < 0.01)
}

///|
test "compute_pan - source directly in front" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::new(0.0, 0.0, -5.0),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
  let pan = compute_pan(source, listener)
  // Source directly in front, pan should be 0.0
  assert_true(pan.abs() < 0.01)
}

///|
test "compute_pan - source at same position" {
  let listener = AudioListener3D::from_camera(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
    @math3d.Vec3::unit_y(),
  )
  let source : AudioSource3D = {
    position: @math3d.Vec3::zero(),
    player_id: { value: 1 },
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
  let pan = compute_pan(source, listener)
  // Same position -> pan = 0
  assert_true(pan.abs() < 0.01)
}
