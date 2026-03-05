///|
fn default_walkable(tile : @terrain.Tile) -> Bool {
  match tile {
    Floor | Corridor | Door | Start | Goal => true
    _ => false
  }
}

///|
/// A* pathfinding on Grid2D from mizchi/terrain.
/// Returns an array of points from start to goal (inclusive), or None if unreachable.
pub fn find_path(
  grid : @terrain.Grid2D,
  start : @terrain.Point,
  goal : @terrain.Point,
  walkable? : (@terrain.Tile) -> Bool = default_walkable,
) -> Array[@terrain.Point]? {
  // Validate start and goal
  if not(grid.in_bounds(start.x, start.y)) ||
    not(grid.in_bounds(goal.x, goal.y)) {
    return None
  }
  if not(walkable(grid.get(start.x, start.y))) ||
    not(walkable(grid.get(goal.x, goal.y))) {
    return None
  }
  // Early out: start == goal
  if start.x == goal.x && start.y == goal.y {
    return Some([start])
  }
  let w = grid.width
  let h = grid.height
  let size = w * h
  // g_score[i] = cost from start to node i (-1.0 = unvisited)
  let g_score = Array::make(size, -1.0)
  // came_from[i] = index of predecessor (-1 = none)
  let came_from = Array::make(size, -1)
  let start_idx = start.y * w + start.x
  let goal_idx = goal.y * w + goal.x
  g_score[start_idx] = 0.0
  let open = PriorityQueue::new()
  open.push(start, manhattan(start, goal))
  // 4-directional movement
  let dx : Array[Int] = [-1, 1, 0, 0]
  let dy : Array[Int] = [0, 0, -1, 1]
  while true {
    match open.pop() {
      None => return None
      Some(current) => {
        let ci = current.y * w + current.x
        if ci == goal_idx {
          // Reconstruct path
          return Some(reconstruct_path(came_from, w, goal_idx))
        }
        let cg = g_score[ci]
        for d in 0..<4 {
          let nx = current.x + dx[d]
          let ny = current.y + dy[d]
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let ni = ny * w + nx
            if walkable(grid.get(nx, ny)) {
              let ng = cg + 1.0
              if g_score[ni] < 0.0 || ng < g_score[ni] {
                g_score[ni] = ng
                came_from[ni] = ci
                let f = ng + manhattan({ x: nx, y: ny }, goal)
                open.push({ x: nx, y: ny }, f)
              }
            }
          }
        }
      }
    }
  }
  None
}

///|
fn manhattan(a : @terrain.Point, b : @terrain.Point) -> Double {
  let dx = if a.x > b.x { a.x - b.x } else { b.x - a.x }
  let dy = if a.y > b.y { a.y - b.y } else { b.y - a.y }
  (dx + dy).to_double()
}

///|
fn reconstruct_path(
  came_from : Array[Int],
  width : Int,
  goal_idx : Int,
) -> Array[@terrain.Point] {
  let path : Array[@terrain.Point] = []
  let mut idx = goal_idx
  while idx >= 0 {
    let x = idx % width
    let y = idx / width
    path.push({ x, y })
    idx = came_from[idx]
  }
  // Reverse path (goal -> start => start -> goal)
  let n = path.length()
  for i in 0..<(n / 2) {
    let tmp = path[i]
    path[i] = path[n - 1 - i]
    path[n - 1 - i] = tmp
  }
  path
}
