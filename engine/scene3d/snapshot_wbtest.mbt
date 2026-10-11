///|
fn near3(a : @math3d.Vec3, b : @math3d.Vec3) -> Bool {
  a.distance(b) < 1.0e-6
}

///|
/// A cube of edge 1 at x = -3 and a group turned a quarter about +Y at
/// x = 3 holding a cube one unit along its local +X, so the child ends up at
/// world (3, 0, -1).
fn sample_root() -> SceneRoot raise {
  let root = SceneRoot::new()
  let cube = @mesh3d.Mesh3D::cube(1.0)
  root.render(
    group(key="world", children=[
      subject(
        "crate",
        mesh(key="crate", mesh=cube, position=@math3d.Vec3::new(-3.0, 0.0, 0.0)),
      ),
      subject(
        "robot",
        group(
          key="robot",
          position=@math3d.Vec3::new(3.0, 0.0, 0.0),
          rotation=@math3d.Quaternion::from_axis_angle(
            @math3d.Vec3::unit_y(),
            3.141592653589793 / 2.0,
          ),
          children=[
            mesh(
              key="arm",
              mesh=cube,
              position=@math3d.Vec3::new(1.0, 0.0, 0.0),
            ),
          ],
        ),
      ),
    ]),
  )
  root
}

///|
fn sample_camera() -> @camera3d.Camera3D {
  @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 10.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    3.141592653589793 / 3.0,
    1.0,
    0.1,
    100.0,
  )
}

///|
test "snapshot records world transforms and oriented boxes" {
  let snap = sample_root().snapshot(camera=sample_camera())
  assert_eq(snap.nodes.map(n => n.path), [
    "world", "world/crate", "world/robot", "world/robot/arm",
  ])
  let arm = snap.nodes[3]
  assert_eq(arm.kind, "mesh")
  assert_true(near3(arm.position, @math3d.Vec3::new(3.0, 0.0, -1.0)))
  let b = arm.box.unwrap()
  assert_true(near3(b.center, @math3d.Vec3::new(3.0, 0.0, -1.0)))
  assert_true(near3(b.half_extents, @math3d.Vec3::new(0.5, 0.5, 0.5)))
  assert_eq(snap.nodes[2].kind, "group")
  assert_eq(snap.nodes[2].subject, Some("robot"))
  assert_true(snap.nodes[2].box is None)
}

///|
test "snapshot survives a JSON round trip" {
  let snap = sample_root().snapshot(camera=sample_camera())
  let text = snap.to_json().stringify()
  let back = Scene3DSnapshot::from_json(@json.parse(text))
  assert_eq(back.to_json().stringify(), text)
  assert_true(back.camera is Some(_))
}

///|
test "from_json names the field it cannot read" {
  let bad : Json = {
    "schema": scene3d_snapshot_schema.to_json(),
    "version": 1,
    "camera": Json::null(),
    "nodes": [
      {
        "path": "a",
        "position": [0, 0],
        "rotation": [0, 0, 0, 1],
        "scale": [1, 1, 1],
      },
    ],
  }
  let message = try {
    Scene3DSnapshot::from_json(bad) |> ignore
    ""
  } catch {
    Scene3DSnapshotError(m) => m
    _ => "other"
  }
  assert_true(message.contains("node a.position"))
}

///|
test "a clean scene has no findings" {
  let snap = sample_root().snapshot(camera=sample_camera())
  assert_eq(snap.check().length(), 0)
}

///|
test "check reports overlapping subjects, off-screen meshes and bad rotations" {
  let root = SceneRoot::new()
  let cube = @mesh3d.Mesh3D::cube(1.0)
  root.render(
    group(key="world", children=[
      subject("player", mesh(key="player", mesh=cube)),
      subject(
        "enemy",
        mesh(key="enemy", mesh=cube, position=@math3d.Vec3::new(0.5, 0.0, 0.0)),
      ),
      // Scenery without a subject may overlap freely.
      mesh(key="floor", mesh=cube, scale=@math3d.Vec3::new(10.0, 0.1, 10.0)),
      mesh(key="behind", mesh=cube, position=@math3d.Vec3::new(0.0, 0.0, 30.0)),
    ]),
  )
  let snap = root.snapshot(camera=sample_camera())
  let kinds = snap.check().map(f => (f.kind, f.paths))
  assert_eq(kinds, [
    ("outside_view", ["world/behind"]),
    ("overlap", ["world/player", "world/enemy"]),
  ])
  // A hand-edited snapshot with a non-unit rotation is caught on read.
  let edited = {
    ..snap.nodes[1],
    rotation: @math3d.Quaternion::new(0.0, 0.0, 0.0, 2.0),
  }
  let broken = { ..snap, nodes: [edited], }
  assert_eq(broken.check().map(f => f.kind), ["unnormalized_rotation"])
}

///|
test "distance treats a group as the union of its meshes" {
  let snap = sample_root().snapshot()
  // Crate spans x in [-3.5, -2.5]; the arm spans x in [2.5, 3.5].
  let d = snap.distance("world/crate", "world/robot")
  assert_true((d.distance - 5.0).abs() < 1.0e-9)
  let missing = try {
    snap.distance("world/crate", "world/nothing") |> ignore
    false
  } catch {
    _ => true
  }
  assert_true(missing)
}

///|
test "raycast returns hits nearest first" {
  let snap = sample_root().snapshot()
  let hits = snap.raycast(
    @math3d.Vec3::new(-10.0, 0.0, -1.0),
    @math3d.Vec3::unit_x(),
  )
  // Along z = -1 only the arm (z in [-1.5, -0.5]) is crossed.
  assert_eq(hits.length(), 1)
  assert_eq(hits[0].0, "world/robot/arm")
  assert_true((hits[0].1 - 12.5).abs() < 1.0e-9)
  // Starting inside the crate and aiming at the arm: the crate is hit at 0.
  let both = snap.raycast(
    @math3d.Vec3::new(-3.0, 0.0, 0.0),
    @math3d.Vec3::new(6.0, 0.0, -1.0),
  )
  assert_eq(both.map(h => h.0), ["world/crate", "world/robot/arm"])
  assert_eq(both[0].1, 0.0)
}

///|
test "query entry point: check with allow rules, distance, overlaps, raycast" {
  let root = SceneRoot::new()
  let cube = @mesh3d.Mesh3D::cube(1.0)
  root.render(
    group(key="world", children=[
      subject("player", mesh(key="player", mesh=cube)),
      subject(
        "enemy",
        mesh(key="enemy", mesh=cube, position=@math3d.Vec3::new(0.5, 0.0, 0.0)),
      ),
    ]),
  )
  let doc = root.snapshot().to_json()
  let check = (allow : Array[String]) => {
    query_scene3d_snapshot(
      { "operation": "check", "allow": allow.to_json() },
      doc,
    )
  }
  assert_true(check([]) is Object({ "failed": True, .. }))
  assert_true(check(["overlap@world/enemy"]) is Object({ "failed": False, .. }))
  // A rule that matches nothing fails the check: stale exemptions are defects.
  assert_true(
    check(["overlap@world/enemy", "zero_scale"])
    is Object({ "failed": True, .. }),
  )
  let unknown = try {
    check(["typo"]) |> ignore
    false
  } catch {
    _ => true
  }
  assert_true(unknown)
  let distance = query_scene3d_snapshot(
    { "operation": "distance", "paths": ["world/player", "world/enemy"] },
    doc,
  )
  assert_true(distance is Object({ "intersecting": True, .. }))
  let overlaps = query_scene3d_snapshot({ "operation": "overlaps" }, doc)
  assert_eq(
    overlaps.stringify(),
    ({ "pairs": [["world/player", "world/enemy"]] } : Json).stringify(),
  )
  let hits = query_scene3d_snapshot(
    { "operation": "raycast", "from": [-5, 0, 0], "direction": [1, 0, 0] },
    doc,
  )
  guard hits is Object({ "hits": Array(list), .. }) else { fail("no hits") }
  assert_eq(list.length(), 2)
}

///|
test "resting contact is not an overlap; deeper penetration is" {
  let cube = @mesh3d.Mesh3D::cube(1.0)
  let pair = (gap : Double) => {
    let root = SceneRoot::new()
    root.render(
      group(key="w", children=[
        subject("a", mesh(key="a", mesh=cube)),
        subject(
          "b",
          mesh(
            key="b",
            mesh=cube,
            position=@math3d.Vec3::new(0.0, 1.0 - gap, 0.0),
          ),
        ),
      ]),
    )
    root.snapshot().check().map(f => f.kind)
  }
  // A physics stack settles a few millimetres into its support.
  assert_eq(pair(0.006), [])
  assert_eq(pair(0.03), ["overlap"])
  // The tolerance is the caller's to choose.
  let root = SceneRoot::new()
  root.render(
    group(key="w", children=[
      subject("a", mesh(key="a", mesh=cube)),
      subject(
        "b",
        mesh(key="b", mesh=cube, position=@math3d.Vec3::new(0.0, 0.97, 0.0)),
      ),
    ]),
  )
  assert_eq(root.snapshot().check(contact_tolerance=0.05).length(), 0)
}

///|
test "balls are judged by their bounding ball, not their box" {
  let ball = @mesh3d.Mesh3D::sphere(0.5, 24, 16)
  let root = SceneRoot::new()
  // Diagonal neighbours 1.004 apart: the balls miss, their boxes overlap.
  root.render(
    group(key="w", children=[
      subject("a", mesh(key="a", mesh=ball)),
      subject(
        "b",
        mesh(key="b", mesh=ball, position=@math3d.Vec3::new(0.71, 0.0, 0.71)),
      ),
    ]),
  )
  let snap = root.snapshot()
  let sphere = snap.nodes[1].sphere.unwrap()
  assert_true((sphere.radius - 0.5).abs() < 1.0e-6)
  assert_eq(snap.check().length(), 0)
  let d = snap.distance("w/a", "w/b")
  assert_true((d.distance - (0.71 * 2.0.sqrt() - 1.0)).abs() < 1.0e-6)
  // A ray past the box corner but outside the ball misses.
  let corner = snap.raycast(
    @math3d.Vec3::new(-5.0, 0.45, 0.45),
    @math3d.Vec3::unit_x(),
  )
  assert_false(corner.iter().any(h => h.0 == "w/a"))
  let centre = snap.raycast(
    @math3d.Vec3::new(-5.0, 0.0, 0.0),
    @math3d.Vec3::unit_x(),
  )
  assert_eq(centre[0].0, "w/a")
  assert_true((centre[0].1 - 4.5).abs() < 1.0e-9)
}

///|
test "snapshots without bounding balls still read" {
  let doc : Json = {
    "schema": scene3d_snapshot_schema.to_json(),
    "version": 1,
    "camera": Json::null(),
    "nodes": [
      {
        "path": "a",
        "position": [0, 0, 0],
        "rotation": [0, 0, 0, 1],
        "scale": [1, 1, 1],
        "box": {
          "center": [0, 0, 0],
          "half_extents": [1, 1, 1],
          "rotation": [0, 0, 0, 1],
        },
      },
    ],
  }
  let snap = Scene3DSnapshot::from_json(doc)
  assert_true(snap.nodes[0].sphere is None)
  assert_eq(
    snap
    .raycast(@math3d.Vec3::new(-5.0, 0.9, 0.9), @math3d.Vec3::unit_x())
    .length(),
    1,
  )
}
