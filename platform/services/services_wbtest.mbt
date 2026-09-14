///|
test "host services can be replaced without initializing a surface" {
  let files : Map[String, Bytes] = Map([])
  let environment : Ref[String?] = Ref(None)
  set_file_access({
    read: fn(path, override_env) {
      environment.val = override_env
      files.get(path)
    },
    write: fn(path, bytes) {
      files[path] = bytes
      true
    },
  })
  assert_true(write_file("capture", b"frame"))
  assert_eq(
    read_file("capture", override_env=Some("TEST_CONFIG")),
    Some(b"frame"),
  )
  assert_eq(environment.val, Some("TEST_CONFIG"))
  set_clock(fn() { 12.5 })
  assert_eq(now_ms(), 12.5)
  reset_file_access()
  reset_clock()
}

///|
test "frame scheduling passes callbacks to the installed host" {
  let scheduled : Array[() -> Unit] = []
  let exits : Array[() -> Unit] = []
  let phases : Array[(Double, Double, Double)] = []
  set_frame_host({
    request_frame: fn(callback) { scheduled.push(callback) },
    on_exit: fn(callback) { exits.push(callback) },
    publish_phases: fn(a, b, c) { phases.push((a, b, c)) },
  })
  let count = Ref(0)
  request_frame(fn() { count.val += 1 })
  on_exit(fn() { count.val += 10 })
  assert_eq(count.val, 0)
  scheduled[0]()
  exits[0]()
  publish_frame_phases(1, 2, 3)
  assert_eq(count.val, 11)
  assert_eq(phases, [(1, 2, 3)])
  reset_frame_host()
}
