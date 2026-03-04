///|
/// Min-heap priority queue for A* pathfinding.
priv struct PQEntry {
  point : @terrain.Point
  priority : Double
}

///|
priv struct PriorityQueue {
  data : Array[PQEntry]
}

///|
fn PriorityQueue::new() -> PriorityQueue {
  { data: [] }
}

///|
fn PriorityQueue::is_empty(self : PriorityQueue) -> Bool {
  self.data.length() == 0
}

///|
fn PriorityQueue::push(
  self : PriorityQueue,
  point : @terrain.Point,
  priority : Double,
) -> Unit {
  self.data.push({ point, priority })
  self.sift_up(self.data.length() - 1)
}

///|
fn PriorityQueue::pop(self : PriorityQueue) -> @terrain.Point? {
  if self.data.length() == 0 {
    return None
  }
  let result = self.data[0].point
  let last = self.data.length() - 1
  self.data[0] = self.data[last]
  let _ = self.data.pop()
  if self.data.length() > 0 {
    self.sift_down(0)
  }
  Some(result)
}

///|
fn PriorityQueue::sift_up(self : PriorityQueue, idx : Int) -> Unit {
  let mut i = idx
  while i > 0 {
    let parent = (i - 1) / 2
    if self.data[i].priority < self.data[parent].priority {
      let tmp = self.data[i]
      self.data[i] = self.data[parent]
      self.data[parent] = tmp
      i = parent
    } else {
      break
    }
  }
}

///|
fn PriorityQueue::sift_down(self : PriorityQueue, idx : Int) -> Unit {
  let n = self.data.length()
  let mut i = idx
  while true {
    let left = 2 * i + 1
    let right = 2 * i + 2
    let mut smallest = i
    if left < n && self.data[left].priority < self.data[smallest].priority {
      smallest = left
    }
    if right < n && self.data[right].priority < self.data[smallest].priority {
      smallest = right
    }
    if smallest == i {
      break
    }
    let tmp = self.data[i]
    self.data[i] = self.data[smallest]
    self.data[smallest] = tmp
    i = smallest
  }
}
