///|
fn make_test_clip() -> SpriteAnimationClip {
  let keys = sprite_sheet_keys("walk", 4)
  SpriteAnimationClip::uniform("walk", keys, 0.1)
}

///|
test "player starts at frame 0" {
  let clip = make_test_clip()
  let player = SpriteAnimationPlayer::new(clip)
  assert_eq(player.current_frame_index(), 0)
  assert_eq(player.current_key().value, "walk_0")
}

///|
test "player advances frames" {
  let clip = make_test_clip()
  let player = SpriteAnimationPlayer::new(clip)
  player.update(0.15) // past first frame (0.1)
  assert_eq(player.current_frame_index(), 1)
  assert_eq(player.current_key().value, "walk_1")
}

///|
test "player loops" {
  let clip = make_test_clip()
  let player = SpriteAnimationPlayer::new(clip)
  player.update(0.45) // past total_duration (0.4), should wrap
  assert_eq(player.current_frame_index(), 0)
}

///|
test "player non-looping stops at end" {
  let clip = make_test_clip()
  let player = SpriteAnimationPlayer::new(clip)
  player.set_looping(false)
  player.update(0.5) // past total_duration
  assert_eq(player.current_frame_index(), 3) // last frame
  assert_eq(player.playing, false)
}

///|
test "player pause and play" {
  let clip = make_test_clip()
  let player = SpriteAnimationPlayer::new(clip)
  player.pause()
  player.update(0.5)
  assert_eq(player.current_frame_index(), 0) // didn't advance
  player.play()
  player.update(0.15)
  assert_eq(player.current_frame_index(), 1)
}

///|
test "player set_clip resets" {
  let clip1 = make_test_clip()
  let clip2 = SpriteAnimationClip::uniform(
    "run",
    sprite_sheet_keys("run", 3),
    0.2,
  )
  let player = SpriteAnimationPlayer::new(clip1)
  player.update(0.15)
  assert_eq(player.current_frame_index(), 1)
  player.set_clip(clip2)
  assert_eq(player.current_frame_index(), 0)
  assert_eq(player.current_key().value, "run_0")
}

///|
test "player speed" {
  let clip = make_test_clip()
  let player = SpriteAnimationPlayer::new(clip)
  player.set_speed(2.0)
  player.update(0.05) // effective dt = 0.1
  assert_eq(player.current_frame_index(), 1)
}
