///|
/// Immutable footprint; arbitrary occupied cells support rectangular and shaped items.
pub struct GridFootprint {
  priv width : Int
  priv height : Int
  priv cells : Array[(Int, Int)]
}

///|
pub fn GridFootprint::new(cells : Array[(Int, Int)]) -> GridFootprint? {
  if cells.is_empty() {
    return None
  }
  let mut width = 0
  let mut height = 0
  let copied : Array[(Int, Int)] = []
  for cell in cells {
    let (x, y) = cell
    if x < 0 || y < 0 || x >= 128 || y >= 128 || copied.contains(cell) {
      return None
    }
    copied.push(cell)
    width = width.max(x + 1)
    height = height.max(y + 1)
  }
  Some({ width, height, cells: copied, })
}

///|
pub fn GridFootprint::rectangle(width : Int, height : Int) -> GridFootprint? {
  if width <= 0 || height <= 0 || width > 128 || height > 128 {
    return None
  }
  let cells : Array[(Int, Int)] = []
  for y in 0..<height {
    for x in 0..<width {
      cells.push((x, y))
    }
  }
  GridFootprint::new(cells)
}

///|
pub fn GridFootprint::size(
  self : GridFootprint,
  rotated? : Bool = false,
) -> (Int, Int) {
  if rotated {
    (self.height, self.width)
  } else {
    (self.width, self.height)
  }
}

///|
pub fn GridFootprint::cells(
  self : GridFootprint,
  rotated? : Bool = false,
) -> Array[(Int, Int)] {
  if rotated {
    self.cells.map(cell => (self.height - 1 - cell.1, cell.0))
  } else {
    self.cells.copy()
  }
}

///|
pub(all) struct GridPlacement {
  id : Int
  footprint : GridFootprint
  x : Int
  y : Int
  rotated : Bool
}

///|
/// Item IDs and payloads belong to the caller; rejected placements never mutate the grid.
pub(all) struct ItemGrid {
  width : Int
  height : Int
  priv mut entries : Array[GridPlacement]
}

///|
pub fn ItemGrid::new(width : Int, height : Int) -> ItemGrid {
  { width: width.max(0), height: height.max(0), entries: [], }
}

///|
pub fn ItemGrid::clone(self : ItemGrid) -> ItemGrid {
  { width: self.width, height: self.height, entries: self.entries.copy(), }
}

///|
pub fn ItemGrid::placement(self : ItemGrid, id : Int) -> GridPlacement? {
  for entry in self.entries {
    if entry.id == id {
      return Some(entry)
    }
  }
  None
}

///|
pub fn ItemGrid::remove(self : ItemGrid, id : Int) -> Unit {
  self.entries = self.entries.filter(entry => entry.id != id)
}

///|
pub fn ItemGrid::clear(self : ItemGrid) -> Unit {
  self.entries.clear()
}

///|
pub fn ItemGrid::occupied_by(
  self : ItemGrid,
  x : Int,
  y : Int,
  ignore_id? : Int = -1,
) -> Int? {
  for entry in self.entries {
    if entry.id == ignore_id {
      continue
    }
    for cell in entry.footprint.cells(rotated=entry.rotated) {
      if entry.x + cell.0 == x && entry.y + cell.1 == y {
        return Some(entry.id)
      }
    }
  }
  None
}

///|
pub fn ItemGrid::overlaps(
  self : ItemGrid,
  footprint : GridFootprint,
  x : Int,
  y : Int,
  rotated? : Bool = false,
  ignore_id? : Int = -1,
) -> Array[Int]? {
  let (width, height) = footprint.size(rotated~)
  if x < 0 ||
    y < 0 ||
    width > self.width ||
    height > self.height ||
    x > self.width - width ||
    y > self.height - height {
    return None
  }
  let ids : Array[Int] = []
  for cell in footprint.cells(rotated~) {
    if self.occupied_by(x + cell.0, y + cell.1, ignore_id~) is Some(id) {
      if !ids.contains(id) {
        ids.push(id)
      }
    }
  }
  Some(ids)
}

///|
pub fn ItemGrid::place(
  self : ItemGrid,
  id : Int,
  footprint : GridFootprint,
  x : Int,
  y : Int,
  rotated? : Bool = false,
) -> Bool {
  if id < 0 {
    return false
  }
  match self.overlaps(footprint, x, y, rotated~, ignore_id=id) {
    Some(ids) => if !ids.is_empty() { return false }
    None => return false
  }
  self.remove(id)
  self.entries.push({ id, footprint, x, y, rotated, })
  true
}

///|
pub fn ItemGrid::find_space(
  self : ItemGrid,
  footprint : GridFootprint,
  rotated? : Bool = false,
  ignore_id? : Int = -1,
) -> (Int, Int)? {
  for y in 0..<self.height {
    for x in 0..<self.width {
      if self.overlaps(footprint, x, y, rotated~, ignore_id~) is Some(ids) {
        if ids.is_empty() {
          return Some((x, y))
        }
      }
    }
  }
  None
}

///|
pub fn ItemGrid::used_cells(self : ItemGrid) -> Int {
  let mut used = 0
  for entry in self.entries {
    used += entry.footprint.cells.length()
  }
  used
}
