///|
/// SimpleLayoutEngine computes layout for UI node trees.

///|
pub struct SimpleLayoutEngine {
  tree : UITree
}

///|
pub fn SimpleLayoutEngine::new(tree : UITree) -> SimpleLayoutEngine {
  { tree, }
}

///|
fn resolve_size(sizing : UISizing, available : Double) -> Double {
  match sizing {
    UISizing::Fixed(v) => v
    UISizing::Percent(p) => available * p / 100.0
    UISizing::Auto => available
  }
}

///|
/// A measured child subtree: temp layout results at (0,0) plus its size.
struct ChildMeasure {
  temp_results : Array[LayoutResult]
  width : Double
  height : Double
}

///|
/// A flex line: a group of children that fit on one row/column.
struct FlexLine {
  items : Array[(Int, Double, Double)]
  main_size : Double
  cross_size : Double
}

///|
/// Organize measured children into flex lines.
fn build_flex_lines(
  measures : Array[ChildMeasure],
  is_row : Bool,
  container_main : Double,
  gap : Double,
  flex_wrap : UIFlexWrap,
) -> Array[FlexLine] {
  let lines : Array[FlexLine] = []
  if measures.length() == 0 {
    return lines
  }
  let mut current_items : Array[(Int, Double, Double)] = []
  let mut current_main = 0.0
  let mut current_cross = 0.0
  for i, m in measures {
    let item_main = if is_row { m.width } else { m.height }
    let item_cross = if is_row { m.height } else { m.width }
    let would_be = if current_items.length() > 0 {
      current_main + gap + item_main
    } else {
      item_main
    }
    // Wrap to new line if needed
    if current_items.length() > 0 &&
      flex_wrap is UIFlexWrap::Wrap &&
      would_be > container_main &&
      container_main > 0.0 {
      lines.push({
        items: current_items,
        main_size: current_main,
        cross_size: current_cross,
      })
      current_items = []
      current_main = 0.0
      current_cross = 0.0
    }
    current_items.push((i, item_main, item_cross))
    current_main = if current_items.length() == 1 {
      item_main
    } else {
      current_main + gap + item_main
    }
    if item_cross > current_cross {
      current_cross = item_cross
    }
  }
  if current_items.length() > 0 {
    lines.push({
      items: current_items,
      main_size: current_main,
      cross_size: current_cross,
    })
  }
  lines
}

///|
fn layout_node(
  tree : UITree,
  node_id : UINodeId,
  constraint : LayoutConstraint,
  results : Array[LayoutResult],
  offset_x : Double,
  offset_y : Double,
) -> (Double, Double) {
  let node = match tree.get_node(node_id) {
    Some(n) => n
    None => return (0.0, 0.0)
  }
  let style = node.style
  let avail_w = constraint.max_width
  let avail_h = constraint.max_height
  let content_w = resolve_size(style.width, avail_w)
  let content_h = resolve_size(style.height, avail_h)
  let inner_w = content_w - style.padding_left - style.padding_right
  let inner_h = content_h - style.padding_top - style.padding_bottom
  let clamped_w = @layout.clamp_value(
    inner_w,
    0.0,
    avail_w - style.padding_left - style.padding_right,
  )
  let clamped_h = @layout.clamp_value(
    inner_h,
    0.0,
    avail_h - style.padding_top - style.padding_bottom,
  )
  let is_row = match style.direction {
    UIDirection::Row => true
    UIDirection::Column => false
  }
  // Leaf node: no children
  if node.children.length() == 0 {
    let final_w = match style.width {
      UISizing::Auto => 0.0
      _ => content_w
    }
    let final_h = match style.height {
      UISizing::Auto => 0.0
      _ => content_h
    }
    results.push({
      node_id,
      rect: { x: offset_x, y: offset_y, width: final_w, height: final_h },
    })
    return (final_w, final_h)
  }
  // Phase 1: Measure each child at (0, 0)
  let measures : Array[ChildMeasure] = []
  for child_id in node.children {
    let child_constraint : LayoutConstraint = {
      min_width: 0.0,
      min_height: 0.0,
      max_width: if clamped_w > 0.0 {
        clamped_w
      } else {
        0.0
      },
      max_height: if clamped_h > 0.0 {
        clamped_h
      } else {
        0.0
      },
    }
    let temp : Array[LayoutResult] = []
    let (cw, ch) = layout_node(tree, child_id, child_constraint, temp, 0.0, 0.0)
    measures.push({ temp_results: temp, width: cw, height: ch })
  }
  // Phase 2: Organize into flex lines
  let container_main = if is_row { clamped_w } else { clamped_h }
  let lines = build_flex_lines(
    measures,
    is_row,
    container_main,
    style.gap,
    style.flex_wrap,
  )
  // Phase 3: Compute total content size for auto sizing
  let mut total_cross = 0.0
  let mut max_line_main = 0.0
  for i, line in lines {
    if line.main_size > max_line_main {
      max_line_main = line.main_size
    }
    total_cross = total_cross + line.cross_size
    if i > 0 {
      total_cross = total_cross + style.gap
    }
  }
  let final_w = match style.width {
    UISizing::Auto =>
      if is_row {
        style.padding_left + max_line_main + style.padding_right
      } else {
        style.padding_left + total_cross + style.padding_right
      }
    _ => content_w
  }
  let final_h = match style.height {
    UISizing::Auto =>
      if is_row {
        style.padding_top + total_cross + style.padding_bottom
      } else {
        style.padding_top + max_line_main + style.padding_bottom
      }
    _ => content_h
  }
  // The actual main-axis space for justify (only when fixed/percent sized)
  let actual_main = if is_row {
    final_w - style.padding_left - style.padding_right
  } else {
    final_h - style.padding_top - style.padding_bottom
  }
  // Phase 4: Position children with justify-content and align-items
  let base_x = offset_x + style.padding_left
  let base_y = offset_y + style.padding_top
  let mut cross_offset = 0.0
  for i, line in lines {
    if i > 0 {
      cross_offset = cross_offset + style.gap
    }
    let free_main = actual_main - line.main_size
    let (main_start, main_extra_gap) = @layout.compute_justify(
      style.justify_content,
      if free_main > 0.0 {
        free_main
      } else {
        0.0
      },
      line.items.length(),
    )
    let mut main_pos = main_start
    for _, item in line.items {
      let (child_idx, item_main, item_cross) = item
      let free_cross = line.cross_size - item_cross
      let cross_align = @layout.compute_align_offset(
        style.align,
        if free_cross > 0.0 {
          free_cross
        } else {
          0.0
        },
      )
      // Compute final position delta
      let dx = if is_row { main_pos } else { cross_offset + cross_align }
      let dy = if is_row { cross_offset + cross_align } else { main_pos }
      // Emit shifted child results
      let m = measures[child_idx]
      for r in m.temp_results {
        results.push({
          node_id: r.node_id,
          rect: {
            x: r.rect.x + base_x + dx,
            y: r.rect.y + base_y + dy,
            width: r.rect.width,
            height: r.rect.height,
          },
        })
      }
      main_pos = main_pos + item_main + style.gap + main_extra_gap
    }
    cross_offset = cross_offset + line.cross_size
  }
  // Add container result
  results.push({
    node_id,
    rect: { x: offset_x, y: offset_y, width: final_w, height: final_h },
  })
  (final_w, final_h)
}

///|
pub impl LayoutEngine for SimpleLayoutEngine with compute_layout(
  self,
  root,
  constraint,
) {
  let results : Array[LayoutResult] = []
  let _ = layout_node(self.tree, root, constraint, results, 0.0, 0.0)
  results
}
