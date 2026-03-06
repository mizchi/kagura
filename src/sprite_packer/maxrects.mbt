///|
/// Internal rectangle type for MaxRects algorithm.
struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Show, Eq)

///|
/// MaxRects bin packing allocator.
/// Uses BestShortSideFit heuristic.
priv struct MaxRectsAllocator {
  free_rects : Array[Rect]
}

///|
fn new_maxrects_allocator(width : Int, height : Int) -> MaxRectsAllocator {
  { free_rects: [{ x: 0, y: 0, width, height }] }
}

///|
/// Result of a single allocation attempt.
struct AllocResult {
  x : Int
  y : Int
} derive(Show)

///|
/// Try to allocate a rectangle of the given size.
/// Returns the position if successful, None if no space.
fn MaxRectsAllocator::insert(
  self : MaxRectsAllocator,
  w : Int,
  h : Int,
) -> AllocResult? {
  // Find best rect using BestShortSideFit
  let mut best_idx = -1
  let mut best_short_side = 2147483647
  let mut best_long_side = 2147483647
  let mut best_x = 0
  let mut best_y = 0
  for i, rect in self.free_rects {
    if rect.width >= w && rect.height >= h {
      let leftover_x = rect.width - w
      let leftover_y = rect.height - h
      let short_side = if leftover_x < leftover_y {
        leftover_x
      } else {
        leftover_y
      }
      let long_side = if leftover_x > leftover_y {
        leftover_x
      } else {
        leftover_y
      }
      if short_side < best_short_side ||
        (short_side == best_short_side && long_side < best_long_side) {
        best_idx = i
        best_short_side = short_side
        best_long_side = long_side
        best_x = rect.x
        best_y = rect.y
      }
    }
  }
  if best_idx < 0 {
    return None
  }
  let placed = { x: best_x, y: best_y, width: w, height: h }
  // Split free rects
  split_free_rects(self, placed)
  // Remove contained rects
  prune_contained(self)
  Some({ x: best_x, y: best_y })
}

///|
/// Split all free rects that overlap with the placed rect.
fn split_free_rects(alloc : MaxRectsAllocator, placed : Rect) -> Unit {
  let new_rects : Array[Rect] = []
  let mut i = 0
  while i < alloc.free_rects.length() {
    let fr = alloc.free_rects[i]
    if overlaps(fr, placed) {
      // Remove this rect
      let _ = alloc.free_rects.remove(i)
      // Generate up to 4 splits
      // Left
      if placed.x > fr.x {
        new_rects.push({
          x: fr.x,
          y: fr.y,
          width: placed.x - fr.x,
          height: fr.height,
        })
      }
      // Right
      let placed_right = placed.x + placed.width
      let fr_right = fr.x + fr.width
      if placed_right < fr_right {
        new_rects.push({
          x: placed_right,
          y: fr.y,
          width: fr_right - placed_right,
          height: fr.height,
        })
      }
      // Top
      if placed.y > fr.y {
        new_rects.push({
          x: fr.x,
          y: fr.y,
          width: fr.width,
          height: placed.y - fr.y,
        })
      }
      // Bottom
      let placed_bottom = placed.y + placed.height
      let fr_bottom = fr.y + fr.height
      if placed_bottom < fr_bottom {
        new_rects.push({
          x: fr.x,
          y: placed_bottom,
          width: fr.width,
          height: fr_bottom - placed_bottom,
        })
      }
    } else {
      i += 1
    }
  }
  for r in new_rects {
    alloc.free_rects.push(r)
  }
}

///|
/// Remove free rects that are fully contained by another free rect.
fn prune_contained(alloc : MaxRectsAllocator) -> Unit {
  let mut i = 0
  while i < alloc.free_rects.length() {
    let mut contained = false
    let mut j = 0
    while j < alloc.free_rects.length() {
      if i != j && contains(alloc.free_rects[j], alloc.free_rects[i]) {
        contained = true
        break
      }
      j += 1
    }
    if contained {
      let _ = alloc.free_rects.remove(i)
    } else {
      i += 1
    }
  }
}

///|
/// Check if two rects overlap (non-touching).
fn overlaps(a : Rect, b : Rect) -> Bool {
  a.x < b.x + b.width &&
  a.x + a.width > b.x &&
  a.y < b.y + b.height &&
  a.y + a.height > b.y
}

///|
/// Check if rect `outer` fully contains rect `inner`.
fn contains(outer : Rect, inner : Rect) -> Bool {
  outer.x <= inner.x &&
  outer.y <= inner.y &&
  outer.x + outer.width >= inner.x + inner.width &&
  outer.y + outer.height >= inner.y + inner.height
}
