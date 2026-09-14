///|
/// Decode at the boundary; geometry, placement and comparison use typed APIs.
fn shape(item : @core.Any) -> @inventory.GridFootprint {
  @inventory.GridFootprint::new(
    array_values(item._get("cells")).map(fn(cell) {
      (cell._get_by_index(0).cast(), cell._get_by_index(1).cast())
    }),
  ).unwrap_or_else(fn() {
    @core.throw_error("Invalid inventory footprint")
    abort("unreachable")
  })
}

///|
fn footprint(item : @core.Any, rotated : Bool) -> Array[(Int, Int)] {
  shape(item).cells(rotated~)
}

///|
fn cells_to_js(cells : Array[(Int, Int)]) -> @core.Any {
  @core.any(cells.map(fn(cell) { [cell.0, cell.1] }))
}

///|
fn preview_item(item : @core.Any) -> @inventory.PreviewItem {
  {
    source: item._get("source").cast(),
    slot: item._get("slot").cast(),
    footprint: shape(item),
    x: item._get("x").cast(),
    y: item._get("y").cast(),
    rotated: truthy(item._get("rotated")),
  }
}

///|
pub fn rotated_cells(item : @core.Any, rotated : @core.Any) -> @core.Any {
  cells_to_js(footprint(item, truthy(argument(rotated, item._get("rotated")))))
}

///|
pub fn dimensions(item : @core.Any, rotated : @core.Any) -> @core.Any {
  let (width, height) = shape(item).size(
    rotated=truthy(argument(rotated, item._get("rotated"))),
  )
  @core.any([width, height])
}

///|
pub fn preview_placement(
  view : @core.Any,
  item : @core.Any,
  x : Int,
  y : Int,
  rotated : @core.Any,
) -> @core.Any {
  let result = @inventory.preview_placement(
    view._get("width").cast(),
    view._get("height").cast(),
    array_values(view._get("items")).map(preview_item),
    preview_item(item),
    x,
    y,
    truthy(argument(rotated, item._get("rotated"))),
  )
  @core.from_entries([
    ("cells", cells_to_js(result.cells)),
    ("valid", @core.any(result.valid)),
    ("swap", @core.any(result.swap)),
  ])
}

///|
fn rect(value : @core.Any) -> @inventory.DropRect? {
  if !truthy(value) {
    return None
  }
  Some({
    left: number(value._get("left")),
    top: number(value._get("top")),
    right: number(value._get("right")),
    bottom: number(value._get("bottom")),
  })
}

///|
pub fn is_inventory_ground_drop(
  x : Double,
  y : Double,
  dialog : @core.Any,
  surface : @core.Any,
) -> Bool {
  @inventory.is_ground_drop(x, y, rect(dialog), rect(surface))
}

///|
fn stats(item : @core.Any) -> Array[(String, Double)] {
  array_values(field(item, "stats")).map(fn(stat) {
    (stat._get_by_index(0).cast(), number(stat._get_by_index(1)))
  })
}

///|
pub fn comparison_rows(view : @core.Any, item : @core.Any) -> @core.Any {
  let mut previous : Array[(String, Double)] = []
  for slot in array_values(view._get("equipment")) {
    if @core.equal(slot._get("id"), item._get("slot")) {
      previous = stats(slot._get("item"))
      break
    }
  }
  @core.any(
    @inventory.compare_stats(stats(item), previous).map(fn(row) {
      @core.from_entries([
        ("label", @core.any(row.label)),
        ("value", @core.any(row.value)),
        ("before", @core.any(row.before)),
        ("delta", @core.any(row.delta)),
      ])
    }),
  )
}
