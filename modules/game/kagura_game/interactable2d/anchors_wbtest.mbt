///|
test "pick_anchor_position returns start point for StartRoomCenter" {
  let anchors = [
    AnchorCandidate::new(16.0, 16.0, 100, true),
    AnchorCandidate::new(64.0, 16.0, 80, false),
  ]
  assert_eq(
    pick_anchor_position(anchors, StartRoomCenter, 16.0, 16.0),
    (16.0, 16.0),
  )
}

///|
test "pick_anchor_position picks largest non start room" {
  let anchors = [
    AnchorCandidate::new(16.0, 16.0, 100, true),
    AnchorCandidate::new(64.0, 16.0, 80, false),
    AnchorCandidate::new(96.0, 16.0, 120, false),
  ]
  assert_eq(
    pick_anchor_position(anchors, LargestNonStartRoomCenter, 16.0, 16.0),
    (96.0, 16.0),
  )
  assert_eq(
    pick_anchor_position(anchors, BossRoomCenter, 16.0, 16.0),
    (96.0, 16.0),
  )
}

///|
test "pick_anchor_position picks farthest non start room for treasure" {
  let anchors = [
    AnchorCandidate::new(16.0, 16.0, 100, true),
    AnchorCandidate::new(64.0, 16.0, 120, false),
    AnchorCandidate::new(16.0, 96.0, 80, false),
  ]
  assert_eq(
    pick_anchor_position(anchors, TreasureRoomCenter, 16.0, 16.0),
    (16.0, 96.0),
  )
}

///|
test "pick_anchor_position falls back to start point when only start exists" {
  let anchors = [AnchorCandidate::new(16.0, 16.0, 100, true)]
  assert_eq(
    pick_anchor_position(anchors, LargestNonStartRoomCenter, 16.0, 16.0),
    (16.0, 16.0),
  )
  assert_eq(
    pick_anchor_position(anchors, TreasureRoomCenter, 16.0, 16.0),
    (16.0, 16.0),
  )
}
