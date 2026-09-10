///|
test "rifle swept hits destroy once and stop colliding with dead targets" {
  let g = new_game(ai=false)
  g.phase = "playing"
  let target = g.units[0]
  let muzzle = vec(target.position.x, 3.8, target.position.z - 10.0)
  let frame = {
    eye: muzzle,
    aim: target.position.add(vec(0.0, 3.8, 0.0)),
    rifle: muzzle,
    left: muzzle,
    right: muzzle,
  }
  for _ in 0..<150 {
    advance_combat(g, input(fire=true), frame, 1.0 / 60.0)
  }
  assert_eq(target.hp, 0.0)
  assert_eq(g.kills, 1)
  assert_true(g.shots >= 20)
}

///|
test "lock requires dwell, releases paired missiles, and pause cancels reservations" {
  let g = new_game(ai=false)
  let t = g.units[0]
  let eye = t.position.add(vec(0.0, 3.8, -10.0))
  let frame = {
    eye,
    aim: t.position.add(vec(0.0, 3.8, 0.0)),
    rifle: eye,
    left: eye,
    right: eye,
  }
  for _ in 0..<45 {
    advance_combat(g, input(lock=true), frame, 1.0 / 60.0)
  }
  assert_eq(t.lock, 1.0)
  advance_combat(g, input(), frame, 1.0 / 60.0)
  assert_eq(g.missiles, 1)
  cancel_combat(g)
  for _ in 0..<30 {
    advance_combat(g, input(), frame, 1.0 / 60.0)
  }
  assert_eq(g.missiles, 1)
}

///|
test "combat results agree at 30 and 120 Hz" {
  let a = new_game(ai=false)
  let b = new_game(ai=false)
  let frame = {
    eye: vec(0.0, 30.0, -36.0),
    aim: vec(0.0, 30.0, 50.0),
    rifle: vec(0.0, 30.0, -36.0),
    left: vec(0.0, 30.0, -36.0),
    right: vec(0.0, 30.0, -36.0),
  }
  for _ in 0..<30 {
    advance_combat(a, input(fire=true), frame, 1.0 / 30.0)
  }
  for _ in 0..<120 {
    advance_combat(b, input(fire=true), frame, 1.0 / 120.0)
  }
  assert_eq(a.shots, b.shots)
  assert_eq(a.shots, 8)
}
