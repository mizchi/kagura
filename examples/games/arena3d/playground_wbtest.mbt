///|
test "view toggle preserves player, score, aim and simulated bodies" {
  let state = GameState::new()
  let control = GameState::new()
  control.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
  let position = control.player.position
  let direction = state.aim_direction()
  let bodies = state.physics.body_count()
  state.score = 20
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [86]))
  assert_true(state.first_person)
  assert_true(state.player.position.sub(position).length() < 0.001)
  assert_true(state.aim_direction().sub(direction).length() < 0.001)
  assert_eq(state.physics.body_count(), bodies)
  assert_eq(state.score, 20)
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [86]))
  assert_true(state.first_person)
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [86]))
  assert_false(state.first_person)
}

///|
test "jump lands and diagonal acceleration is normalized in both views" {
  for fps in [false, true] {
    let state = GameState::new()
    let straight = GameState::new()
    state.first_person = fps
    state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87, 68, 32]))
    straight.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87, 32]))
    assert_true(state.player.position.y > 0.5)
    let diagonal_distance = distance_xz(
      state.player.position,
      @math3d.Vec3::zero(),
    )
    assert_true(diagonal_distance > 0.0)
    assert_true(
      (diagonal_distance -
      distance_xz(straight.player.position, @math3d.Vec3::zero())).abs() <
      0.0001,
    )
    for _ in 0..<120 {
      state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
    }
    assert_true((state.player.position.y - 0.5).abs() < 0.015)
    assert_true(state.on_ground)
  }
}

///|
test "physics sandbox falls, bounces and rests above the actual floor" {
  let state = GameState::new()
  let ball = state.physics.bodies.filter(body => {
      body.is_dynamic() && body.collider is SphereShape(_, _)
    })[0]
  let start_y = ball.position.y
  let mut bounced = false
  for _ in 0..<180 {
    state.physics.step(1.0 / 60.0)
    if state.physics.get_body(ball.id).unwrap().velocity.y > 0.5 {
      bounced = true
    }
  }
  let settled = state.physics.get_body(ball.id).unwrap()
  assert_true(settled.position.y < start_y)
  assert_true(settled.position.y >= 0.35)
  assert_true(bounced)
}

///|
test "shooting pushes the nearest body and walls stop the shot" {
  let state = GameState::new()
  state.enemies.clear()
  state.physics = test_shooting_world(false)
  state.fire_shot(
    @math3d.Vec3::new(0.0, 1.0, 5.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
  )
  for _ in 0..<30 {
    state.update_shots()
  }
  assert_true(state.physics.get_body(1).unwrap().velocity.z < -1.0)
  assert_eq(state.physics.get_body(2).unwrap().velocity.z, 0.0)
  state.physics = test_shooting_world(true)
  state.shots.clear()
  state.fire_shot(
    @math3d.Vec3::new(0.0, 1.0, 5.0),
    @math3d.Vec3::new(0.0, 0.0, -1.0),
  )
  for _ in 0..<30 {
    state.update_shots()
  }
  assert_eq(state.physics.get_body(1).unwrap().velocity.z, 0.0)
}

///|
fn test_shooting_world(wall : Bool) -> @physics3d.PhysicsWorld {
  let world = @physics3d.PhysicsWorld::new(@math3d.Vec3::zero(), 2.0)
  for id in 1..<3 {
    world.add_body(
      @physics3d.RigidBody::new_dynamic(
        id,
        @math3d.Vec3::new(0.0, 1.0, 2.0 - id.to_double() * 2.0),
        1.0,
        AABBShape(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::zero()),
      ),
    )
  }
  if wall {
    world.add_body(
      @physics3d.RigidBody::new_static(
        3,
        @math3d.Vec3::new(0.0, 1.0, 3.0),
        AABBShape(@math3d.Vec3::one(), @math3d.Vec3::zero()),
      ),
    )
  }
  world
}

///|
test "physical player walks on the outer area of a floor resized in Studio" {
  let project = @scenes.project()
  for scene in project.scenes {
    for entity in scene.data.entities {
      if entity.kind == "floor" {
        entity.scale[0] = 30.0
      }
    }
  }
  let state = GameState::new()
  state.apply_scene_project(project.to_json().stringify())
  state.transition_scene("second")
  state.teleport_player(@math3d.Vec3::new(10.0, 0.5, 5.0))
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [68]))
  assert_true(state.player.position.x > 10.0)
  state.teleport_player(@math3d.Vec3::new(13.0, 0.5, 5.0))
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [68]))
  for _ in 0..<15 {
    state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [68]))
  }
  assert_true(state.player.position.x > 13.5)
  assert_true(state.player.position.y >= 0.48)
}
