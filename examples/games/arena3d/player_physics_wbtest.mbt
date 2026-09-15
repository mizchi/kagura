///|
test "the player is a dynamic body in the same world as props" {
  let game = GameState::new()
  game.load_default_scene()
  let player = game.physics.bodies.filter(body => body.id == 20000)
  assert_eq(player.length(), 1)
  assert_true(player[0].is_dynamic())
  assert_true(player[0].position.sub(game.player.position).length() < 0.0001)
  assert_eq(player[0].inv_inertia, 0.0)
}

///|
fn player_test_game() -> GameState {
  let game = GameState::new()
  game.load_default_scene()
  game.emitters.clear()
  for enemy in game.enemies {
    enemy.active = false
  }
  game
}

///|
fn strike_player(game : GameState) -> Unit {
  game.physics.add_body({
    ..@physics3d.RigidBody::new_dynamic(
      30000,
      @math3d.Vec3::new(-1.6, 0.5, 5.0),
      2.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    )
    .with_restitution(0.0)
    .with_friction(0.0),
    velocity: @math3d.Vec3::new(8.0, 0.0, 0.0),
  })
  for _ in 0..<12 {
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
  }
}

///|
test "a colliding ball pushes the player and counter input recovers sooner than idle" {
  let idle = player_test_game()
  let counter = player_test_game()
  strike_player(idle)
  strike_player(counter)
  let hit = counter.physics.get_body(player_body_id).unwrap()
  assert_true(hit.velocity.x > 1.0)
  assert_true(hit.position.x > 0.1)
  counter.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [65]))
  let resisted = counter.physics.get_body(player_body_id).unwrap()
  assert_true(resisted.velocity.x > 0.0)
  for _ in 0..<18 {
    idle.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
    counter.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [65]))
  }
  assert_true(counter.player.position.x < idle.player.position.x - 0.3)
  assert_true(
    counter.physics.get_body(player_body_id).unwrap().velocity.x < 0.0,
  )
  assert_true(
    counter.player.position
    .sub(counter.physics.get_body(player_body_id).unwrap().position)
    .length() <
    0.0001,
  )
}

///|
test "walking pushes a crate through rigid body contact" {
  let game = player_test_game()
  game.physics.add_body(
    @physics3d.RigidBody::new_dynamic(
      30000,
      @math3d.Vec3::new(1.3, 0.5, 5.0),
      1.0,
      AABBShape(@math3d.Vec3::new(0.5, 0.5, 0.5), @math3d.Vec3::zero()),
    ).with_restitution(0.0),
  )
  for _ in 0..<50 {
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [68]))
  }
  assert_true(game.physics.get_body(30000).unwrap().position.x > 2.0)
  assert_true(game.player.position.x > 1.0)
}

///|
test "airborne counter steering preserves launch momentum and cannot jump again" {
  let game = player_test_game()
  game.physics.apply_impulse(player_body_id, @math3d.Vec3::new(8.0, 6.0, 0.0))
  game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [65, 32]))
  let body = game.physics.get_body(player_body_id).unwrap()
  assert_true(body.velocity.x > 3.8)
  assert_true(body.velocity.y > 2.7 && body.velocity.y < 3.0)
  assert_false(game.on_ground)
  assert_true(body.angular_velocity.length() < 0.0001)
}

///|
test "view camera excludes its own body and reset clears player momentum" {
  let game = player_test_game()
  let camera = game.view_camera()
  assert_true(camera.position.sub(game.eye()).length() > 1.0)
  game.physics.apply_impulse(player_body_id, @math3d.Vec3::new(8.0, 4.0, 0.0))
  game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
  game.reset()
  let body = game.physics.get_body(player_body_id).unwrap()
  assert_true(body.velocity.length() < 0.0001)
  assert_true(
    body.position.sub(@math3d.Vec3::new(0.0, 0.5, 5.0)).length() < 0.0001,
  )
  assert_eq(
    game.physics.bodies.filter(body => body.id == player_body_id).length(),
    1,
  )
}

///|
test "idle feet hold on a slope and falling outside an open scene returns to spawn" {
  let game = player_test_game()
  game.teleport_player(@math3d.Vec3::new(-4.8, 2.17, -4.0))
  for _ in 0..<600 {
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
  }
  assert_true((game.player.position.z + 4.0).abs() < 0.15)
  assert_true(game.on_ground)
  game.teleport_player(@math3d.Vec3::new(12.0, -14.9, 5.0))
  game.physics.apply_impulse(player_body_id, @math3d.Vec3::new(0.0, -20.0, 0.0))
  for _ in 0..<10 {
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, []))
  }
  assert_true(game.player.position.sub(game.player_spawn).length() < 0.02)
}

///|
test "a ball near the player's head does not collapse the third person camera" {
  let game = player_test_game()
  game.physics.add_body(
    @physics3d.RigidBody::new_dynamic(
      30000,
      game.eye().add(@math3d.Vec3::new(0.0, 0.0, 0.2)),
      1.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    ),
  )
  assert_true(game.view_camera().position.sub(game.eye()).length() > 1.0)
}

///|
test "scene geometry remains visible while a physical player is pushed and recovers" {
  let game = GameState::new()
  let source : Json = {
    "entry": "preview",
    "scenes": [
      {
        "id": "preview",
        "data": {
          "version": 1,
          "entities": [
            {
              "id": "floor",
              "kind": "floor",
              "position": [0, -0.125, 0],
              "scale": [18, 0.25, 18],
              "color": 6649958,
              "target": "",
            },
            {
              "id": "spawn",
              "kind": "spawn",
              "position": [0, 0.5, 5],
              "scale": [1, 1, 1],
              "color": 4508774,
              "target": "",
            },
            {
              "id": "ball",
              "kind": "ball",
              "position": [0.65, 4, 5],
              "scale": [1, 1, 1],
              "color": 5490648,
              "target": "",
            },
          ],
        },
      },
    ],
  }
  game.apply_scene_project(source.stringify())
  let dst = @gfx.new_image_handle(1, screen_w, screen_h)
  for frame in 0..<120 {
    let keys = if frame >= 60 && frame < 80 { [68] } else { [] }
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, keys))
    let commands = @renderer3d.render_scene3d_graph_to_dst(
      game.build_scene_graph(),
      game.view_camera(),
      lighting=game.lighting,
      dst,
      game.shader3d,
      screen_w,
      screen_h,
    )
    if frame >= 45 {
      assert_eq(commands.length(), 3, msg="frame=\{frame}")
    }
  }
}
