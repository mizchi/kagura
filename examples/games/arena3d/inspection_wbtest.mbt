///|
test "inspection pause freezes simulation and resumes from the same state" {
  let game = GameState::new()
  game.apply_scene_project(@scenes.project().to_json().stringify())
  game.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87]))
  game.set_inspection_paused(true)
  let before = game.scene_snapshot()
  let frame = game.frame_count
  for _ in 0..<12 {
    game.update(@core.new_input_snapshot(100.0, 50.0, 0.0, 0.0, [87, 32]))
  }
  assert_eq(game.scene_snapshot(), before)
  assert_eq(game.frame_count, frame)
  assert_true(game.inspection_paused)
  game.set_inspection_paused(false)
  game.update(@core.empty_input_snapshot())
  assert_eq(game.frame_count, frame + 1)
  assert_false(game.inspection_paused)
}

///|
test "runtime observation declares scoped read-only player fields" {
  let game = GameState::new()
  game.apply_scene_project(authored_fixture())
  game.teleport_player(@math3d.Vec3::new(3.0, 4.0, 5.0))
  let data = @json.parse(game.runtime_observation())
  guard data
    is {
      "inspection": { "scope": String(scope), "subjects": Array(subjects), .. },
      "state": { "player": Array(position), .. },
      ..
    } else {
    fail("Missing observation inspection")
  }
  assert_eq(scope, "training")
  assert_eq(position, [Json(3.0), Json(4.0), Json(5.0)])
  let player = subjects
    .iter()
    .find_first(subject => subject is { "id": "player", .. })
  guard player is Some({ "fields": Array(fields), .. }) else {
    fail("Missing player fields")
  }
  let expected : Json = {
    "id": "position.x",
    "label": "Position X",
    "kind": "number",
    "value": 3.0,
    "unit": "m",
    "access": "readonly",
  }
  assert_true(fields.contains(expected))
  for field in fields {
    guard field is { "access": "readonly", .. } else {
      fail("Observed fields must be read only")
    }
  }
}

///|
test "paused player edits preserve velocity and other bodies, and update the camera" {
  let game = GameState::new()
  game.apply_scene_project(authored_fixture())
  game.set_inspection_paused(true)
  let index = game.player_body_index
  game.physics.bodies[index] = {
    ..game.physics.bodies[index],
    velocity: @math3d.Vec3::new(1.0, 2.0, 3.0),
  }
  let other = game.physics.get_body(game.props[0].id).unwrap()
  let frame = game.frame_count
  game.edit_runtime_field(
    "player",
    "position.y",
    4.0,
    game.inspection_revision,
    "training",
  )
  assert_eq(game.player.position.y, 4.0)
  assert_eq(game.physics.bodies[index].position.y, 4.0)
  assert_eq(game.physics.bodies[index].velocity.y, 2.0)
  assert_eq(game.camera.target.y, 4.0)
  assert_false(game.on_ground)
  game.edit_runtime_field(
    "player",
    "velocity.y",
    6.0,
    game.inspection_revision,
    "training",
  )
  assert_eq(game.physics.bodies[index].velocity.x, 1.0)
  assert_eq(game.physics.bodies[index].velocity.y, 6.0)
  assert_eq(game.physics.bodies[index].velocity.z, 3.0)
  assert_eq(
    game.physics.get_body(other.id).unwrap().position.x,
    other.position.x,
  )
  assert_eq(game.frame_count, frame)
  game.set_inspection_paused(false)
  game.update(@core.empty_input_snapshot())
  assert_true(game.player.position.y > 4.0)
}

///|
test "rejected player edits and stale scene tokens leave state unchanged" {
  let game = GameState::new()
  // This test intentionally revisits the same scene. Declare that return edge.
  let project = @scenes.project()
  let portal = project.scenes[0].data.entities.filter(e => e.kind == "portal")[0]
  project.scenes[1].data.entities.push({ ..portal, id: "return", target: "training" })
  game.apply_scene_project(project.to_json().stringify())
  game.set_inspection_paused(true)
  for
    trial in [
      ("player", "position.x", 10001.0),
      ("player", "velocity.y", 1001.0),
      ("player", "position.y", 0.0 / 0.0),
      ("player", "grounded", 1.0),
      ("prop:999999", "position.x", 1.0),
      ("prop:0", "position.x", 1.0),
    ] {
    let (subject, field, value) = trial
    let before = game.scene_snapshot()
    let revision = game.inspection_revision
    assert_true(
      try {
        game.edit_runtime_field(subject, field, value, revision, "training")
        false
      } catch {
        _ => true
      },
    )
    assert_eq(game.scene_snapshot(), before)
    assert_eq(game.inspection_revision, revision)
  }
  let old = game.inspection_revision
  game.transition_scene("second")
  game.transition_scene("training")
  let before = game.scene_snapshot()
  assert_true(
    try {
      game.edit_runtime_field("player", "position.x", 3.0, old, "training")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(game.scene_snapshot(), before)
  game.set_inspection_paused(false)
  let running = game.scene_snapshot()
  assert_true(
    try {
      game.edit_runtime_field(
        "player",
        "position.x",
        3.0,
        game.inspection_revision,
        "training",
      )
      false
    } catch {
      _ => true
    },
  )
  assert_eq(game.scene_snapshot(), running)
}

///|
test "field inspection exposes dynamic props while observations remain read only" {
  let game = GameState::new()
  game.load_default_scene()
  game.set_inspection_paused(true)
  guard @json.parse(game.runtime_fields())
    is { "subjects": Array(subjects), .. } else {
    fail("Missing runtime subjects")
  }
  for prop in game.props {
    let subject = subjects
      .iter()
      .find_first(s => s is { "id": String(id), .. } && id == "prop:\{prop.id}")
    guard subject is Some({ "fields": Array(fields), .. }) else {
      fail("Missing prop fields")
    }
    assert_eq(fields.filter(f => f is { "access": "runtime", .. }).length(), 6)
    assert_true(
      fields.any(f => f is { "id": "sleeping", "access": "readonly", .. }),
    )
  }
  guard @json.parse(game.runtime_observation())
    is { "inspection": { "subjects": Array(observed), .. }, .. } else {
    fail("Missing observation subjects")
  }
  for subject in observed {
    guard subject is { "fields": Array(fields), .. } else {
      fail("Missing fields")
    }
    assert_true(fields.all(f => f is { "access": "readonly", .. }))
  }
}

///|
test "paused prop edits preserve other motion and camera and continue on resume" {
  let game = GameState::new()
  game.load_default_scene()
  game.set_inspection_paused(true)
  let prop = game.props[0]
  let subject = "prop:\{prop.id}"
  let body = game.physics.get_body(prop.id).unwrap()
  let other = game.physics.get_body(game.props[1].id).unwrap()
  let player = game.player.position
  let target = game.camera.target
  let frame = game.frame_count
  let revision = game.inspection_revision
  game.edit_runtime_field(subject, "position.y", 4.0, revision, "training")
  let moved = game.physics.get_body(prop.id).unwrap()
  assert_eq(moved.position.y, 4.0)
  assert_eq(moved.position.x, body.position.x)
  assert_eq(moved.position.z, body.position.z)
  assert_eq(moved.velocity.sub(body.velocity).length_squared(), 0.0)
  assert_eq(game.player.position.sub(player).length_squared(), 0.0)
  assert_eq(game.camera.target.sub(target).length_squared(), 0.0)
  assert_eq(
    game.physics.get_body(other.id).unwrap().position
    .sub(other.position)
    .length_squared(),
    0.0,
  )
  assert_eq(
    game.physics.get_body(other.id).unwrap().velocity
    .sub(other.velocity)
    .length_squared(),
    0.0,
  )
  assert_eq(game.frame_count, frame)
  assert_eq(game.inspection_revision, revision + 1)
  game.edit_runtime_field(
    subject,
    "velocity.y",
    6.0,
    game.inspection_revision,
    "training",
  )
  assert_eq(game.physics.get_body(prop.id).unwrap().velocity.y, 6.0)
  game.set_inspection_paused(false)
  game.update(@core.empty_input_snapshot())
  assert_true(game.physics.get_body(prop.id).unwrap().position.y > 4.0)
}

///|
test "moving a support updates grounding and wakes sleeping bodies without advancing motion" {
  let game = GameState::new()
  game.load_default_scene()
  game.set_inspection_paused(true)
  let support = game.props[0]
  let upper = game.props[1]
  for i, body in game.physics.bodies {
    if body.id == support.id || body.id == upper.id {
      game.physics.bodies[i] = {
        ..body,
        position: @math3d.Vec3::new(
          0.0,
          if body.id == support.id {
            0.5
          } else {
            1.5
          },
          -7.0,
        ),
        velocity: @math3d.Vec3::zero(),
        is_sleeping: true,
        sleep_timer: 1.0,
      }
    }
  }
  game.teleport_player(@math3d.Vec3::new(0.0, 2.5, -7.0))
  assert_true(game.on_ground)
  let position = game.physics.get_body(upper.id).unwrap().position
  game.edit_runtime_field(
    "prop:\{upper.id}",
    "position.x",
    3.0,
    game.inspection_revision,
    "training",
  )
  assert_false(game.on_ground)
  assert_false(game.physics.get_body(upper.id).unwrap().is_sleeping)
  assert_false(game.physics.get_body(support.id).unwrap().is_sleeping)
  assert_eq(game.physics.get_body(support.id).unwrap().position.y, 0.5)
  assert_eq(game.physics.get_body(upper.id).unwrap().position.y, position.y)
  // Removing the lower box must let a sleeping upper box fall on resume.
  game.edit_runtime_field(
    "prop:\{upper.id}",
    "position.x",
    0.0,
    game.inspection_revision,
    "training",
  )
  for i, body in game.physics.bodies {
    if body.id == upper.id || body.id == support.id {
      game.physics.bodies[i] = { ..body, is_sleeping: true, sleep_timer: 1.0, }
    }
  }
  game.edit_runtime_field(
    "prop:\{support.id}",
    "position.x",
    3.0,
    game.inspection_revision,
    "training",
  )
  assert_false(game.physics.get_body(upper.id).unwrap().is_sleeping)
  let height = game.physics.get_body(upper.id).unwrap().position.y
  game.set_inspection_paused(false)
  game.update(@core.empty_input_snapshot())
  assert_true(game.physics.get_body(upper.id).unwrap().position.y < height)
}

///|
test "prop validation rejects invalid fields and values and undeclared or static bodies atomically" {
  let game = GameState::new()
  game.load_default_scene()
  game.set_inspection_paused(true)
  let prop = "prop:\{game.props[0].id}"
  for
    trial in [
      (prop, "position.y", 10001.0),
      (prop, "velocity.x", 1001.0),
      (prop, "position.z", 0.0 / 0.0),
      (prop, "velocity.z", 1.0 / 0.0),
      (prop, "sleeping", 1.0),
      ("game", "score", 1.0),
      ("prop:0", "position.y", 1.0),
      ("prop:999999", "position.y", 1.0),
      ("prop:08", "position.y", 1.0),
    ] {
    let before = game.scene_snapshot()
    let revision = game.inspection_revision
    let (subject, field, value) = trial
    assert_true(
      try {
        game.edit_runtime_field(subject, field, value, revision, "training")
        false
      } catch {
        _ => true
      },
    )
    assert_eq(game.scene_snapshot(), before)
    assert_eq(game.inspection_revision, revision)
  }
  // Metadata cannot grant writes to a body that has become static.
  for i, body in game.physics.bodies {
    if body.id == game.props[0].id {
      game.physics.bodies[i] = @physics3d.RigidBody::new_static(
        body.id,
        body.position,
        body.collider,
      )
    }
  }
  let before = game.scene_snapshot()
  assert_true(
    try {
      game.edit_runtime_field(
        prop,
        "position.y",
        2.0,
        game.inspection_revision,
        "training",
      )
      false
    } catch {
      _ => true
    },
  )
  assert_eq(game.scene_snapshot(), before)
  guard @json.parse(game.runtime_fields())
    is { "subjects": Array(subjects), .. } else {
    fail("Missing subjects")
  }
  guard subjects
    .iter()
    .find_first(s => s is { "id": String(id), .. } && id == prop)
    is Some({ "fields": Array(fields), .. }) else {
    fail("Missing static prop")
  }
  assert_true(fields.all(f => f is { "access": "readonly", .. }))
}

///|
test "generated rain bodies use the same field edits without changing spawn progress" {
  let game = GameState::new()
  game.load_default_scene()
  game.drop_ball()
  game.set_inspection_paused(true)
  let rain_count = game.rain_count
  let rain_ticks = game.rain_ticks
  let prop_count = game.props.length()
  let body_count = game.physics.bodies.length()
  game.edit_runtime_field(
    "prop:10000",
    "position.z",
    1.0,
    game.inspection_revision,
    "training",
  )
  game.edit_runtime_field(
    "prop:10000",
    "velocity.y",
    3.0,
    game.inspection_revision,
    "training",
  )
  let body = game.physics.get_body(10000).unwrap()
  assert_eq(body.position.z, 1.0)
  assert_eq(body.velocity.y, 3.0)
  assert_eq(game.rain_count, rain_count)
  assert_eq(game.rain_ticks, rain_ticks)
  assert_eq(game.props.length(), prop_count)
  assert_eq(game.physics.bodies.length(), body_count)
}
