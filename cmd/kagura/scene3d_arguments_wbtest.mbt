///|
test "scene3d operations parse into a request for the analysis" {
  assert_eq(
    parse_args([
      "scene3d", "check", "out.scene3d.json", "--allow", "overlap@world/door", "--json",
    ]),
    Ok(
      Scene3D({
        operation: "check",
        snapshot: "out.scene3d.json",
        paths: [],
        from: None,
        direction: None,
        allow: ["overlap@world/door"],
        tolerance: None,
        json: true,
      }),
    ),
  )
  assert_eq(
    parse_args(["scene3d", "distance", "s.json", "world/a", "world/b"]),
    Ok(
      Scene3D({
        operation: "distance",
        snapshot: "s.json",
        paths: ["world/a", "world/b"],
        from: None,
        direction: None,
        allow: [],
        tolerance: None,
        json: false,
      }),
    ),
  )
  assert_eq(
    parse_args([
      "scene3d", "raycast", "s.json", "--from", "0,1.5,-2", "--direction", "0,0,-1",
    ]),
    Ok(
      Scene3D({
        operation: "raycast",
        snapshot: "s.json",
        paths: [],
        from: Some([0.0, 1.5, -2.0]),
        direction: Some([0.0, 0.0, -1.0]),
        allow: [],
        tolerance: None,
        json: false,
      }),
    ),
  )
  assert_true(
    parse_args(["scene3d", "overlaps", "s.json", "--tolerance", "0.05"])
    is Ok(Scene3D({ tolerance: Some(0.05), .. })),
  )
  assert_eq(parse_args(["scene3d", "--help"]), Ok(Help(Some("scene3d"))))
}

///|
test "scene3d rejects incomplete or mismatched arguments" {
  for
    args in [
      ["scene3d"],
      ["scene3d", "inspect", "s.json"],
      ["scene3d", "check"],
      ["scene3d", "distance", "s.json", "world/a"],
      ["scene3d", "overlaps", "s.json", "extra"],
      ["scene3d", "raycast", "s.json", "--from", "0,0,0"],
      ["scene3d", "raycast", "s.json", "--from", "0,0", "--direction", "1,0,0"],
      [
        "scene3d", "raycast", "s.json", "--from", "a,b,c", "--direction", "1,0,0",
      ],
      ["scene3d", "check", "s.json", "--from", "0,0,0"],
      ["scene3d", "distance", "s.json", "a", "b", "--allow", "overlap"],
      ["scene3d", "check", "s.json", "--allow"],
      ["scene3d", "check", "s.json", "--verbose"],
      ["scene3d", "check", "s.json", "--tolerance", "-1"],
      ["scene3d", "check", "s.json", "--tolerance", "deep"],
      ["scene3d", "raycast", "s.json", "--tolerance", "0.1"],
    ] {
    assert_true(parse_args(args) is Err(_), msg=args.join(" "))
  }
}
