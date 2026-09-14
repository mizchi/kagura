///|
test "timeline handles reverse loops, completion and pause independently of sampling" {
  let clock = Timeline::new(playing=true)
  clock.advance(2.25, 1)
  assert_eq(clock.time, 0.25)
  clock.speed = -1
  clock.advance(0.5, 1)
  assert_eq(clock.time, 0.75)
  clock.looping = false
  clock.advance(2, 1)
  assert_eq(clock.time, 0)
  assert_false(clock.playing)
  clock.advance(1, 1)
  assert_eq(clock.time, 0)
  clock.seek(10, 1)
  assert_eq(clock.time, 1)
  clock.play(1)
  assert_eq(clock.time, 0)
}

///|
test "pose players can keep sampling a clamped endpoint" {
  let clock = Timeline::new(playing=true)
  clock.looping = false
  clock.advance(2, 1, stop_at_end=false)
  assert_eq(clock.time, 1)
  assert_true(clock.playing)
}
