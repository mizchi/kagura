///|
pub(all) struct PreviewItem {
  source : Int
  slot : Int
  footprint : GridFootprint
  x : Int
  y : Int
  rotated : Bool
}

///|
pub(all) struct PlacementPreview {
  cells : Array[(Int, Int)]
  valid : Bool
  swap : Bool
}

///|
/// Preview a single-item exchange. The caller still commits game-specific
/// equipment effects and the displaced item's destination atomically.
pub fn preview_placement(
  width : Int,
  height : Int,
  items : Array[PreviewItem],
  item : PreviewItem,
  x : Int,
  y : Int,
  rotated : Bool,
) -> PlacementPreview {
  let grid = ItemGrid::new(width, height)
  for other in items {
    if other.x >= 0 && other.source >= 0 {
      grid.entries.push({
        id: other.source,
        footprint: other.footprint,
        x: other.x,
        y: other.y,
        rotated: other.rotated,
      })
    }
  }
  let cells = item.footprint
    .cells(rotated~)
    .map(cell => (x + cell.0, y + cell.1))
  let overlaps = grid.overlaps(
    item.footprint,
    x,
    y,
    rotated~,
    ignore_id=item.source,
  )
  let ids = overlaps.unwrap_or([])
  let mut matching = true
  if item.source < 0 {
    for other in items {
      if ids.contains(other.source) && other.slot != item.slot {
        matching = false
      }
    }
  }
  {
    cells,
    valid: overlaps is Some(_) && ids.length() <= 1 && matching,
    swap: ids.length() == 1,
  }
}

///|
pub(all) struct StatComparison {
  label : String
  value : Double
  before : Double
  delta : Double
}

///|
pub fn compare_stats(
  current : Array[(String, Double)],
  previous : Array[(String, Double)],
) -> Array[StatComparison] {
  let old : Map[String, Double] = Map([])
  for (label, value) in previous {
    old[label] = value
  }
  let rows : Array[StatComparison] = []
  for (label, value) in current {
    let before = old.get(label).unwrap_or(0)
    if value != 0 || before != 0 {
      rows.push({ label, value, before, delta: value - before, })
    }
  }
  rows
}

///|
pub(all) struct DropRect {
  left : Double
  top : Double
  right : Double
  bottom : Double
}

///|
fn DropRect::contains(self : DropRect, x : Double, y : Double) -> Bool {
  x >= self.left && y >= self.top && x < self.right && y < self.bottom
}

///|
pub fn is_ground_drop(
  x : Double,
  y : Double,
  dialog : DropRect?,
  surface : DropRect?,
) -> Bool {
  match (dialog, surface) {
    (Some(dialog), Some(surface)) =>
      surface.contains(x, y) && !dialog.contains(x, y)
    _ => false
  }
}
