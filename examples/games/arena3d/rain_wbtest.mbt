///|
test "balls drop periodically, recycle within a fixed budget, and reset their timer" {
  let game = GameState::new()
  game.load_default_scene()
  let initial = game.props.length()
  for _ in 0..<(rain_interval - 1) {
    game.update_physics()
  }
  assert_eq(game.props.length(), initial)
  game.update_physics()
  assert_eq(game.rain_count, 1)
  assert_eq(game.props.length(), initial + 1)
  for _ in 0..<(rain_interval * 35) {
    game.update_physics()
  }
  assert_eq(game.rain_slots.length(), rain_capacity)
  assert_eq(game.props.length(), initial + rain_capacity)
  let ids = game.physics.bodies.map(body => body.id)
  for id in ids {
    assert_eq(ids.filter(other => other == id).length(), 1)
  }
  game.reset()
  assert_eq(game.rain_count, 0)
  assert_eq(game.rain_ticks, 0)
  assert_eq(game.props.length(), initial)
}

///|
test "the training yard has four high walls and a physical slide" {
  let game = GameState::new()
  game.load_default_scene()
  let entities = game.authored.unwrap().scene().entities
  let rails = entities.filter(entity => entity.id.has_prefix("rail-"))
  assert_eq(rails.length(), 4)
  for rail in rails {
    assert_true(rail.scale[1] >= 3.0)
  }
  assert_eq(entities.filter(entity => entity.kind == "slide").length(), 1)
  assert_true(game.physics.bodies.any(body => body.collider is BoxShape(_, _)))
  game.transition_scene("second")
  for _ in 0..<(rain_interval * 2) {
    game.update_physics()
  }
  assert_eq(game.rain_count, 0)
}

///|
test "stacked crates stay above the floor through a minute of falling balls and shots" {
  let game = GameState::new()
  game.load_default_scene()
  let crates = game.props.filter(prop => !prop.sphere)
  for frame in 0..<3600 {
    if frame % 120 == 0 {
      for prop in crates {
        game.physics.apply_impulse(prop.id, @math3d.Vec3::new(0.2, -4.0, 0.1))
      }
    }
    game.update_physics()
    for prop in crates {
      let body = game.physics.get_body(prop.id).unwrap()
      assert_true(
        body.position.y >= 0.42,
        msg="\{prop.key} frame=\{frame}, y=\{body.position.y}",
      )
    }
  }
  assert_eq(game.props.length(), 9 + rain_capacity)
}

///|
test "player can walk up and down the slide without colliding with its broadphase bounds" {
  let game = GameState::new()
  game.load_default_scene()
  for enemy in game.enemies {
    enemy.active = false
  }
  game.emitters.clear()
  game.teleport_player(@math3d.Vec3::new(-4.8, 0.5, -0.6))
  game.camera = game.camera.orbit(-game.camera.yaw, 0.0)
  for _ in 0..<75 {
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87]))
  }
  assert_true(game.player.position.z < -4.5)
  assert_true(game.player.position.y > 2.0)
  for _ in 0..<100 {
    game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [83]))
  }
  assert_true(game.player.position.z > -0.5)
  assert_true((game.player.position.y - 0.5).abs() < 0.05)
}

///|
test "the first falling ball lands on the slide and rolls out into the yard" {
  let game = GameState::new()
  game.load_default_scene()
  for _ in 0..<rain_interval {
    game.update_physics()
  }
  let start = game.physics.get_body(10000).unwrap()
  let mut touched_deck = false
  for _ in 0..<360 {
    game.update_physics()
    let ball = game.physics.get_body(10000).unwrap()
    if ball.position.z < -2.0 && ball.position.y < 3.5 {
      touched_deck = true
    }
    assert_true(ball.position.y >= 0.32)
  }
  let end = game.physics.get_body(10000).unwrap()
  assert_true(touched_deck)
  assert_true(end.position.z > -1.0)
  assert_true(end.position.z > start.position.z + 5.0)
}
