///|
/// Scissor rectangle for clipping (pixel coordinates).
pub(all) struct ScissorRect {
  x : Int
  y : Int
  width : Int
  height : Int
}

///|
pub fn ScissorRect::new(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> ScissorRect {
  { x, y, width, height }
}

///|
pub fn ScissorRect::from_screen(screen_w : Int, screen_h : Int) -> ScissorRect {
  { x: 0, y: 0, width: screen_w, height: screen_h }
}

///|
/// Intersect two scissor rects. Returns None if they don't overlap.
pub fn ScissorRect::intersect(
  self : ScissorRect,
  other : ScissorRect,
) -> ScissorRect? {
  let x0 = Int::max(self.x, other.x)
  let y0 = Int::max(self.y, other.y)
  let x1 = Int::min(self.x + self.width, other.x + other.width)
  let y1 = Int::min(self.y + self.height, other.y + other.height)
  if x1 <= x0 || y1 <= y0 {
    None
  } else {
    Some({ x: x0, y: y0, width: x1 - x0, height: y1 - y0 })
  }
}

///|
/// Convert to a DstRegion with the given index count.
pub fn ScissorRect::to_dst_region(
  self : ScissorRect,
  index_count : Int,
) -> @gfx.DstRegion {
  @gfx.new_dst_region(self.x, self.y, self.width, self.height, index_count)
}

///|
/// Stack of scissor rects for nested overflow:hidden.
/// Push narrows the clip region, pop restores.
pub struct ScissorStack {
  stack : Array[ScissorRect]
}

///|
pub fn ScissorStack::new(screen_w : Int, screen_h : Int) -> ScissorStack {
  { stack: [ScissorRect::from_screen(screen_w, screen_h)] }
}

///|
/// Current active scissor rect.
pub fn ScissorStack::current(self : ScissorStack) -> ScissorRect {
  self.stack[self.stack.length() - 1]
}

///|
/// Push a child scissor rect. The effective clip is the intersection
/// of the current clip and the new rect. Returns false if fully clipped.
pub fn ScissorStack::push(self : ScissorStack, rect : ScissorRect) -> Bool {
  let current = self.current()
  match current.intersect(rect) {
    Some(clipped) => {
      self.stack.push(clipped)
      true
    }
    None => {
      // Push a zero-area rect so pop() still works
      self.stack.push({ x: 0, y: 0, width: 0, height: 0 })
      false
    }
  }
}

///|
/// Pop the last pushed scissor rect.
pub fn ScissorStack::pop(self : ScissorStack) -> Unit {
  if self.stack.length() > 1 {
    let _ = self.stack.pop()
  }
}

///|
/// Whether the current scissor rect has any area.
pub fn ScissorStack::is_visible(self : ScissorStack) -> Bool {
  let c = self.current()
  c.width > 0 && c.height > 0
}

///|
/// Depth of the scissor stack (1 = root screen, >1 = nested clips).
pub fn ScissorStack::depth(self : ScissorStack) -> Int {
  self.stack.length()
}
