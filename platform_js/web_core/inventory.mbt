///|
/// Read-only footprint preview. The simulation still validates/commits moves.
fn footprint(item : @core.Any, rotated : Bool) -> Array[(Int, Int)] {
  let height : Int = item._get("height").cast()
  array_values(item._get("cells")).map(fn(cell) {
    let x : Int = cell._get_by_index(0).cast()
    let y : Int = cell._get_by_index(1).cast()
    if rotated {
      (height - 1 - y, x)
    } else {
      (x, y)
    }
  })
}

///|
fn cells_to_js(cells : Array[(Int, Int)]) -> @core.Any {
  @core.any(cells.map(fn(cell) { [cell.0, cell.1] }))
}

///|
pub fn rotated_cells(item : @core.Any, rotated : @core.Any) -> @core.Any {
  cells_to_js(footprint(item, truthy(argument(rotated, item._get("rotated")))))
}

///|
pub fn dimensions(item : @core.Any, rotated : @core.Any) -> @core.Any {
  let width = item._get("width")
  let height = item._get("height")
  @core.any(
    if truthy(argument(rotated, item._get("rotated"))) {
      [height, width]
    } else {
      [width, height]
    },
  )
}

///|
pub fn preview_placement(
  view : @core.Any,
  item : @core.Any,
  x : Int,
  y : Int,
  rotated : @core.Any,
) -> @core.Any {
  let cells = footprint(item, truthy(argument(rotated, item._get("rotated")))).map(fn(
      cell,
    ) {
      (x + cell.0, y + cell.1)
    },
  )
  let width : Int = view._get("width").cast()
  let height : Int = view._get("height").cast()
  let mut inside = true
  for (cx, cy) in cells {
    if cx < 0 || cy < 0 || cx >= width || cy >= height {
      inside = false
    }
  }
  let mut overlaps = 0
  let mut matching_slots = true
  for other in array_values(view._get("items")) {
    let ox : Int = other._get("x").cast()
    if @core.equal(other._get("source"), item._get("source")) || ox < 0 {
      continue
    }
    let oy : Int = other._get("y").cast()
    for (cx, cy) in footprint(other, truthy(other._get("rotated"))) {
      if cells.contains((ox + cx, oy + cy)) {
        overlaps = overlaps + 1
        if !@core.equal(other._get("slot"), item._get("slot")) {
          matching_slots = false
        }
        break
      }
    }
  }
  @core.from_entries([
    ("cells", cells_to_js(cells)),
    (
      "valid",
      @core.any(
        inside &&
        overlaps <= 1 &&
        (number(item._get("source")) >= 0 || matching_slots),
      ),
    ),
    ("swap", @core.any(overlaps == 1)),
  ])
}

///|
fn inside_rect(x : Double, y : Double, rect : @core.Any) -> Bool {
  x >= number(rect._get("left")) &&
  y >= number(rect._get("top")) &&
  x < number(rect._get("right")) &&
  y < number(rect._get("bottom"))
}

///|
/// Only the visible surface outside the dialog counts as a discard target.
pub fn is_inventory_ground_drop(
  x : Double,
  y : Double,
  dialog : @core.Any,
  surface : @core.Any,
) -> Bool {
  truthy(dialog) &&
  truthy(surface) &&
  inside_rect(x, y, surface) &&
  !inside_rect(x, y, dialog)
}

///|
pub fn comparison_rows(view : @core.Any, item : @core.Any) -> @core.Any {
  let previous : Map[String, Double] = Map([])
  for slot in array_values(view._get("equipment")) {
    if @core.equal(slot._get("id"), item._get("slot")) {
      for stat in array_values(field(slot._get("item"), "stats")) {
        previous[stat._get_by_index(0).cast()] = number(stat._get_by_index(1))
      }
      break
    }
  }
  let rows : Array[@core.Any] = []
  for stat in array_values(item._get("stats")) {
    let label : String = stat._get_by_index(0).cast()
    let value = number(stat._get_by_index(1))
    let before = previous.get(label).unwrap_or(0)
    if value != 0 || before != 0 {
      rows.push(
        @core.from_entries([
          ("label", @core.any(label)),
          ("value", @core.any(value)),
          ("before", @core.any(before)),
          ("delta", @core.any(value - before)),
        ]),
      )
    }
  }
  @core.any(rows)
}
