///|
test "offset muzzle aims at the reticle without spawning through a side wall" {
  for blocked in [false, true] {
    let state = GameState::new()
    state.enemies.clear()
    state.physics = @physics3d.PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
    if blocked {
      state.physics.add_body(
        @physics3d.RigidBody::new_static(
          -3,
          state.eye().add(@math3d.Vec3::new(0.3, 0.0, 0.0)),
          AABBShape(@math3d.Vec3::new(0.03, 2.0, 2.0), @math3d.Vec3::zero()),
        ),
      )
    }
    state.fire_aimed_shot()
    let shot = state.shots[0]
    assert_true(
      (shot.position.x - state.eye().x - (if blocked { 0.0 } else { 0.55 })).abs() <
      1.0e-9,
    )
    let target = state.eye().add(state.aim_direction().scale(shot_range))
    assert_true(
      target.sub(shot.position).normalize().sub(shot.direction).length() <
      1.0e-9,
    )
  }
}

///|
test "a shot must travel before it pushes a distant crate" {
  let state = GameState::new()
  state.enemies.clear()
  state.physics = test_shooting_world(false)
  state.fire_shot(
    @math3d.Vec3::new(0.0, 1.0, 5.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
  )
  assert_eq(state.physics.get_body(1).unwrap().velocity.z, 0.0)
  for _ in 0..<12 {
    state.update_shots()
  }
  assert_eq(state.physics.get_body(1).unwrap().velocity.z, 0.0)
  assert_true(state.shots[0].active)
  assert_true(
    state.shots[0].position.z > 0.5 && state.shots[0].position.z < 3.0,
  )
  for _ in 0..<6 {
    state.update_shots()
  }
  assert_true(state.physics.get_body(1).unwrap().velocity.z < -1.0)
  assert_eq(state.physics.get_body(2).unwrap().velocity.z, 0.0)
  assert_true(state.shots[0].impact_frames > 0)
  let velocity = state.physics.get_body(1).unwrap().velocity
  for _ in 0..<20 {
    state.update_shots()
  }
  assert_true(
    state.physics.get_body(1).unwrap().velocity.sub(velocity).length() < 1.0e-9,
  )
  assert_false(state.shots[0].active)
}

///|
test "shots sweep thin walls and test moving targets at arrival" {
  let state = GameState::new()
  state.enemies.clear()
  state.physics = test_shooting_world(false)
  state.physics.add_body(
    @physics3d.RigidBody::new_static(
      -42,
      @math3d.Vec3::new(0.0, 1.0, 4.9),
      AABBShape(@math3d.Vec3::new(1.0, 1.0, 0.01), @math3d.Vec3::zero()),
    ),
  )
  state.fire_shot(
    @math3d.Vec3::new(0.0, 1.0, 5.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
  )
  state.update_shots()
  assert_true(state.shots[0].impact_frames > 0)
  for _ in 0..<30 {
    state.update_shots()
  }
  assert_eq(state.physics.get_body(1).unwrap().velocity.z, 0.0)
  state.physics = test_shooting_world(false)
  state.fire_shot(
    @math3d.Vec3::new(0.0, 1.0, 5.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
  )
  for _ in 0..<6 {
    state.update_shots()
  }
  state.physics.bodies[0] = {
    ..state.physics.bodies[0],
    position: @math3d.Vec3::new(3.0, 1.0, 0.0),
  }
  for _ in 0..<24 {
    state.update_shots()
  }
  assert_eq(state.physics.get_body(1).unwrap().velocity.z, 0.0)
  assert_true(state.physics.get_body(2).unwrap().velocity.z < -1.0)
}

///|
test "enemy score waits for arrival and a closer crate shields the enemy" {
  for shield in [false, true] {
    let state = GameState::new()
    state.enemies.clear()
    state.enemies.push({
      active: true,
      position: @math3d.Vec3::new(0.0, 1.0, 0.0),
      waypoints: [@math3d.Vec3::new(0.0, 1.0, 0.0)],
      waypoint_idx: 0,
    })
    state.physics = @physics3d.PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
    if shield {
      state.physics.add_body(
        @physics3d.RigidBody::new_dynamic(
          1,
          @math3d.Vec3::new(0.0, 1.0, 2.0),
          1.0,
          SphereShape(@math3d.Vec3::zero(), 0.5),
        ),
      )
    }
    state.fire_shot(
      @math3d.Vec3::new(0.0, 1.0, 5.0),
      @math3d.Vec3::new(0.0, 0.0, -1.0),
    )
    assert_eq(state.score, 0)
    for _ in 0..<45 {
      state.update_shots()
    }
    assert_eq(state.score, if shield { 0 } else { 25 })
    assert_eq(state.enemies[0].active, shield)
  }
}

///|
test "repeated shots remain bounded, expire and clear on reset" {
  let state = GameState::new()
  state.enemies.clear()
  state.physics = @physics3d.PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
  for _ in 0..<80 {
    state.fire_shot(@math3d.Vec3::zero(), @math3d.Vec3::unit_x())
  }
  assert_eq(state.shots.length(), shot_capacity)
  assert_eq(state.physics.bodies.length(), 0)
  let nodes = []
  state.append_shot_nodes(nodes)
  assert_true(nodes.length() <= shot_capacity * 5)
  for _ in 0..<151 {
    state.update_shots()
  }
  assert_true(state.shots.all(shot => !shot.active))
  state.fire_shot(@math3d.Vec3::zero(), @math3d.Vec3::unit_x())
  assert_true(state.shots[0].active)
  assert_eq(state.shots.length(), shot_capacity)
  state.reset()
  assert_eq(state.shots.length(), 0)
}
