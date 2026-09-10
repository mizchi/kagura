///|
test "walk boost substeps and diagonal normalization preserve source speeds" {
  let stage = default_stage()
  let mut walk = new_pilot(stage)
  let mut boost = new_pilot(stage)
  for _ in 0..<60 {
    walk = advance_pilot(walk, input(forward=1.0), 1.0 / 60.0, stage, [])
    boost = advance_pilot(
      boost,
      input(forward=1.0, boost=true),
      1.0 / 60.0,
      stage,
      [],
    )
  }
  assert_true(walk.position.z > -34.0 && walk.position.z < -32.5)
  assert_true(boost.position.z > -24.0)
  let diagonal = advance_pilot(
    new_pilot(stage),
    input(forward=1.0, strafe=1.0),
    0.1,
    stage,
    [],
  )
  let straight = advance_pilot(
    new_pilot(stage),
    input(forward=1.0),
    0.1,
    stage,
    [],
  )
  assert_true(
    (diagonal.velocity.length() - straight.velocity.length()).abs() < 0.000001,
  )
}

///|
test "jump edge, ascent, ceiling and release return to ground" {
  let stage = default_stage()
  let mut pilot = new_pilot(stage)
  for _ in 0..<480 {
    pilot = advance_pilot(pilot, input(jump=true), 1.0 / 60.0, stage, [])
  }
  assert_true(pilot.position.y <= 40.0 && pilot.position.y > 39.0)
  for _ in 0..<240 {
    pilot = advance_pilot(pilot, input(), 1.0 / 60.0, stage, [])
  }
  assert_true(pilot.grounded)
  assert_eq(pilot.position.y, 0.0)
}

///|
test "swept segments and cylindrical wall contact prevent tunneling" {
  let wall = solid("wall", vec(0.0, 5.0, 0.0), vec(1.0, 10.0, 20.0), 0)
  assert_eq(
    box_intersection(vec(-10.0, 1.0, 0.0), vec(20.0, 0.0, 0.0), wall),
    Some(0.475),
  )
  let stage = { ..default_stage(), spawn: vec(-10.0, 0.0, 0.0), solids: [wall] }
  let mut p = new_pilot(stage)
  for _ in 0..<180 {
    p = advance_pilot(p, input(strafe=-1.0, boost=true), 1.0 / 60.0, stage, [])
  }
  assert_true(p.position.x <= -3.5)
}
