///|
fn atlas_region_eq(lhs : AtlasRegion, rhs : AtlasRegion) -> Bool {
  lhs.x == rhs.x &&
  lhs.y == rhs.y &&
  lhs.width == rhs.width &&
  lhs.height == rhs.height &&
  lhs.atlas_id == rhs.atlas_id
}

///|
pub fn new_simple_atlas_allocator(
  atlas_width : Int32,
  atlas_height : Int32,
  atlas_id : Int32,
) -> SimpleAtlasAllocator {
  {
    atlas_width: if atlas_width <= 0 {
      1
    } else {
      atlas_width
    },
    atlas_height: if atlas_height <= 0 {
      1
    } else {
      atlas_height
    },
    atlas_id,
    cursor_x: 0,
    cursor_y: 0,
    row_height: 0,
    allocated: [],
  }
}

///|
pub impl AtlasAllocator for SimpleAtlasAllocator with fn allocate(
  self,
  width,
  height,
) {
  if width <= 0 || height <= 0 {
    None
  } else if width > self.atlas_width || height > self.atlas_height {
    None
  } else {
    if self.cursor_x + width > self.atlas_width {
      self.cursor_x = 0
      self.cursor_y = self.cursor_y + self.row_height
      self.row_height = 0
    }
    if self.cursor_y + height > self.atlas_height {
      None
    } else {
      let region : AtlasRegion = {
        x: self.cursor_x,
        y: self.cursor_y,
        width,
        height,
        atlas_id: self.atlas_id,
      }
      self.cursor_x = self.cursor_x + width
      if height > self.row_height {
        self.row_height = height
      }
      self.allocated.push(region)
      Some(region)
    }
  }
}

///|
pub impl AtlasAllocator for SimpleAtlasAllocator with fn release(self, region) {
  let next : Array[AtlasRegion] = []
  for current in self.allocated {
    if !atlas_region_eq(current, region) {
      next.push(current)
    }
  }
  self.allocated = next
}

///|
pub fn atlas_allocator_is_empty(allocator : SimpleAtlasAllocator) -> Bool {
  allocator.allocated.length() == 0
}

///|
pub fn atlas_allocator_reset_if_empty(allocator : SimpleAtlasAllocator) -> Bool {
  if allocator.allocated.length() == 0 {
    allocator.cursor_x = 0
    allocator.cursor_y = 0
    allocator.row_height = 0
    true
  } else {
    false
  }
}
