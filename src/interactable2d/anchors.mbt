///|
pub(all) struct AnchorCandidate {
  center_x : Double
  center_y : Double
  area : Int
  is_start : Bool
}

///|
pub fn AnchorCandidate::new(
  center_x : Double,
  center_y : Double,
  area : Int,
  is_start : Bool,
) -> AnchorCandidate {
  { center_x, center_y, area, is_start }
}

///|
fn largest_non_start_anchor(
  anchors : Array[AnchorCandidate],
) -> AnchorCandidate? {
  let mut best : AnchorCandidate? = None
  for anchor in anchors {
    if anchor.is_start {
      continue
    }
    match best {
      Some(current) => {
        if anchor.area > current.area {
          best = Some(anchor)
        }
      }
      None => best = Some(anchor)
    }
  }
  best
}

///|
fn farthest_non_start_anchor(
  anchors : Array[AnchorCandidate],
  start_x : Double,
  start_y : Double,
) -> AnchorCandidate? {
  let mut best : AnchorCandidate? = None
  let mut best_dist_sq = -1.0
  for anchor in anchors {
    if anchor.is_start {
      continue
    }
    let dx = anchor.center_x - start_x
    let dy = anchor.center_y - start_y
    let dist_sq = dx * dx + dy * dy
    if dist_sq > best_dist_sq {
      best = Some(anchor)
      best_dist_sq = dist_sq
    }
  }
  best
}

///|
pub fn resolve_anchor_position(
  anchors : Array[AnchorCandidate],
  anchor : InteractableAnchor,
  start_x : Double,
  start_y : Double,
) -> (Double, Double) {
  match anchor {
    StartRoomCenter => (start_x, start_y)
    LargestNonStartRoomCenter | BossRoomCenter => {
      match largest_non_start_anchor(anchors) {
        Some(room) => (room.center_x, room.center_y)
        None => (start_x, start_y)
      }
    }
    TreasureRoomCenter => {
      match farthest_non_start_anchor(anchors, start_x, start_y) {
        Some(room) => (room.center_x, room.center_y)
        None => (start_x, start_y)
      }
    }
  }
}
