///|
fn test_beam(delay? : Double = 1.0) -> BeamPath {
  BeamPath::new(
    @math3d.Vec3::zero(),
    @math3d.Vec3::new(0, 0, 40),
    delay~,
    speed=220,
    length=22,
    range=200,
  ).unwrap()
}

///|
test "a beam is harmless during charge and its sweep includes a fast head and tail" {
  let beam = test_beam()
  assert_true(beam.segment_at(0.9) is None)
  assert_true(beam.swept_segment(0.8, 0.9) is None)
  assert_eq(beam.charge_progress(0.5), 0.5)
  assert_true(beam.just_fired(0.95, 1.05))
  assert_false(beam.just_fired(1.05, 1.1))
  let visible = beam.segment_at(1.2).unwrap()
  assert_true(visible.start.approx_eq(@math3d.Vec3::new(0, 0, 22), 0.00001))
  assert_true(visible.end.approx_eq(@math3d.Vec3::new(0, 0, 44), 0.00001))
  let sweep = beam.swept_segment(1.1, 1.2).unwrap()
  assert_true(sweep.distance_squared(@math3d.Vec3::new(0, 0, 10)) < 0.00001)
  assert_true(visible.distance_squared(@math3d.Vec3::new(0, 0, 10)) > 100)
  assert_true(
    beam.swept_segment(0.8, 1.2).unwrap().start.approx_eq(beam.origin, 0.00001),
  )
}

///|
test "beam range, reverse time and zero-delay boundaries are explicit" {
  let beam = test_beam()
  assert_true(
    BeamPath::new(
      @math3d.Vec3::zero(),
      @math3d.Vec3::new(0, 0, 1.0e-13),
      delay=1,
      speed=220,
      length=22,
      range=200,
    )
    is None,
  )
  assert_eq(beam.segment_at(1.95).unwrap().end.z, 200.0)
  assert_true(beam.segment_at(2.1) is None)
  assert_true(beam.swept_segment(1.2, 1.1) is None)
  assert_true(test_beam(delay=0).just_fired(0, 0.05))
  assert_eq(test_beam(delay=0).charge_progress(0), 1.0)
  assert_true(
    BeamPath::new(
      @math3d.Vec3::zero(),
      @math3d.Vec3::zero(),
      delay=1,
      speed=220,
      length=22,
      range=200,
    )
    is None,
  )
  assert_true(
    BeamPath::new(
      @math3d.Vec3::zero(),
      @math3d.Vec3::unit_z(),
      delay=1,
      speed=0,
      length=22,
      range=200,
    )
    is None,
  )
}
