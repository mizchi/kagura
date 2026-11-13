///|
/// One pose contract shared by Scene rendering and the browser's labels/hit marks.
pub(all) struct EnemyPose {
  x : Double
  baseline : Double
  scale_x : Double
  scale_y : Double
  center_x : Double
  center_y : Double
  label_y : Double
}

///|
pub fn enemy_pose(
  kind : Int32,
  count : Int32,
  index : Int32,
  width : Double,
  height : Double,
) -> EnemyPose {
  let w = width.max(1)
  let h = height.max(1)
  let aspect = w / h
  let short = h <= 600 && w >= 621
  let baseline = if short { 340.0 } else { 280.0 }
  let rows = if kind == 4 { 20.0 } else { 18.0 }
  let desired = if short {
    5.5
  } else if aspect < 1 {
    if kind == 4 {
      19.0
    } else {
      15.0
    }
  } else if kind == 4 {
    10.0
  } else {
    9.0
  }
  let available = (baseline / 600 * h - 130).max(48)
  let scale = desired.min(available * 960 / (w * rows))
  let x = 480.0 + (index.to_double() - (count.to_double() - 1) / 2) * 230
  let pixels = scale * rows * w / 960
  let top = baseline / 600 * h - pixels
  {
    x,
    baseline,
    scale_x: scale,
    scale_y: scale * aspect / 1.6,
    center_x: x / 960 * w,
    center_y: top + pixels / 2,
    label_y: if short {
      (top - 43).max(82)
    } else {
      h * 0.48
    },
  }
}

///|
test "enemy captions stay outside their bodies on portrait, landscape and short screens" {
  for
    (w, h) in [
      (1280.0, 800.0),
      (621.0, 480.0),
      (844.0, 390.0),
      (390.0, 844.0),
      (1662.0, 480.0),
    ] {
    for kind in [1, 4] {
      let p = enemy_pose(kind, 3, 1, w, h)
      let rows = if kind == 4 { 20.0 } else { 18.0 }
      let top = p.baseline / 600 * h - p.scale_x * rows * w / 960
      assert_true(top >= 129)
      assert_true(p.center_x > 0 && p.center_x < w)
      if h <= 600 && w >= 621 {
        assert_true(p.label_y + 35 <= top)
      } else {
        assert_true(p.label_y >= p.baseline / 600 * h)
      }
    }
  }
}
