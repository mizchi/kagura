///|
extern "js" fn read_lazy_snapshot_frame() -> Int =
  #| () => globalThis.__kaguraUISnapshot.parsed.frame

///|
test "lazy snapshot builds once when read and refreshes after the next publication" {
  let mut builds = 0
  publish_ui_snapshot_lazy(fn() {
    builds += 1
    {
      ..default_ui_snapshot(screen_width=640.0, screen_height=480.0),
      frame: 4,
    }
  })
  assert_eq(builds, 0)
  assert_eq(read_lazy_snapshot_frame(), 4)
  assert_eq(read_lazy_snapshot_frame(), 4)
  assert_eq(builds, 1)
  publish_ui_snapshot_lazy(fn() {
    builds += 1
    {
      ..default_ui_snapshot(screen_width=640.0, screen_height=480.0),
      frame: 5,
    }
  })
  assert_eq(builds, 1)
  assert_eq(read_lazy_snapshot_frame(), 5)
  assert_eq(builds, 2)
  publish_ui_snapshot({
    ..default_ui_snapshot(screen_width=640.0, screen_height=480.0),
    frame: 6,
  })
  assert_eq(read_lazy_snapshot_frame(), 6)
}
