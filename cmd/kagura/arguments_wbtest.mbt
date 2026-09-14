///|
test "commands retain project paths and validated server options" {
  assert_eq(parse_args(["dev"]), Ok(Dev(None, None, "127.0.0.1")))
  assert_eq(
    parse_args([
      "dev", "a game/日本語", "--port", "8181", "--host", "localhost",
    ]),
    Ok(Dev(Some("a game/日本語"), Some(8181), "localhost")),
  )
  assert_eq(
    parse_args(["build", "--out-dir", "a build", "ui_demo"]),
    Ok(Build(Some("ui_demo"), Some("a build"))),
  )
  assert_eq(parse_args(["studio"]), Ok(Studio(None, "127.0.0.1")))
  assert_eq(
    parse_args(["dev", "--", "-game"]),
    Ok(Dev(Some("-game"), None, "127.0.0.1")),
  )
}

///|
test "invalid requests fail before starting a build or a server" {
  for
    args in [
      ["deploy"],
      ["dev", "a", "b"],
      ["studio", "a"],
      ["build", "--port", "8080"],
      ["dev", "--out-dir", "out"],
      ["studio", "--port"],
      ["dev", "--port", "0"],
      ["dev", "--port", "65536"],
      ["dev", "--port", "8080x"],
      ["dev", "--port", "-1"],
      ["dev", "--port", "99999999999999"],
      ["dev", "--host", ""],
      ["build", "--out-dir", ""],
      ["dev", "--port", "8080", "--port", "8081"],
      ["dev", "--unknown"],
    ] {
    assert_true(parse_args(args) is Err(_), msg="invalid arguments succeeded")
  }
}

///|
test "help never requires a project" {
  assert_eq(parse_args([]), Ok(Help(None)))
  assert_eq(parse_args(["--help"]), Ok(Help(None)))
  assert_eq(parse_args(["dev", "--help"]), Ok(Help(Some("dev"))))
  assert_eq(parse_args(["help", "build"]), Ok(Help(Some("build"))))
  assert_true(parse_args(["help", "unknown"]) is Err(_))
}

///|
test "web scaffolding is explicit and rejects conflicting options" {
  assert_eq(parse_args(["new", "--web"]), Ok(NewWeb(".")))
  assert_eq(parse_args(["new", "my-game", "--web"]), Ok(NewWeb("my-game")))
  assert_eq(
    parse_args(["new", "--web", "../my game"]),
    Ok(NewWeb("../my game")),
  )
  for
    args in [
      ["new"],
      ["new", "--web", "--web"],
      ["new", "--web", "a", "b"],
      ["new", "--web", "--port", "8080"],
      ["dev", "--web"],
    ] {
    assert_true(parse_args(args) is Err(_))
  }
  assert_eq(project_slug("my-game"), "my_game")
  assert_eq(project_slug("123 game"), "game_123_game")
  assert_eq(project_slug("日本語"), "game")
}

///|
test "project names resolve current and parent directory segments" {
  assert_eq(project_name(".", "/work/my-game"), "my_game")
  assert_eq(project_name("./", "/work/my-game"), "my_game")
  assert_eq(project_name("../other-game/", "/work/current"), "other_game")
  assert_eq(project_name("sub/..", "/work/my-game"), "my_game")
  assert_eq(project_name("/games/hello/", "/work/current"), "hello")
  assert_eq(project_name("C:\\games\\hello\\", "C:\\work"), "hello")
}
