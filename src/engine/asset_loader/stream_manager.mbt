///|
pub enum AssetPriority {
  Critical
  High
  Normal
  Low
} derive(Show, Eq)

///|
fn priority_to_int(p : AssetPriority) -> Int {
  match p {
    Critical => 0
    High => 1
    Normal => 2
    Low => 3
  }
}

///|
pub(all) struct StreamProgress {
  total : Int
  pending : Int
  active : Int
  completed : Int
  failed : Int
} derive(Show)

///|
struct StreamRequest {
  id : Int
  url : String
  priority : AssetPriority
  on_complete : (Bytes?) -> Unit
  mut handle : @asset.FetchHandle?
  mut done : Bool
}

///|
pub struct AssetStreamManager {
  fetcher : &@asset.BytesFetcher
  max_concurrent : Int
  mut next_id : Int
  pending : Array[StreamRequest]
  active : Map[Int, StreamRequest]
  mut completed_count : Int
  mut failed_count : Int
}

///|
pub fn AssetStreamManager::new(
  fetcher : &@asset.BytesFetcher,
  max_concurrent? : Int = 4,
) -> AssetStreamManager {
  {
    fetcher,
    max_concurrent,
    next_id: 1,
    pending: [],
    active: {},
    completed_count: 0,
    failed_count: 0,
  }
}

///|
pub fn AssetStreamManager::enqueue(
  self : AssetStreamManager,
  url : String,
  priority : AssetPriority,
  on_complete : (Bytes?) -> Unit,
) -> Int {
  let id = self.next_id
  self.next_id = self.next_id + 1
  let req : StreamRequest = {
    id,
    url,
    priority,
    on_complete,
    handle: None,
    done: false,
  }
  // Insert sorted by priority (lower int = higher priority)
  let p = priority_to_int(priority)
  let mut inserted = false
  for i in 0..<self.pending.length() {
    if priority_to_int(self.pending[i].priority) > p {
      self.pending.insert(i, req)
      inserted = true
      break
    }
  }
  if !(inserted) {
    self.pending.push(req)
  }
  id
}

///|
pub fn AssetStreamManager::cancel(self : AssetStreamManager, id : Int) -> Unit {
  // Remove from pending
  for i = self.pending.length() - 1; i >= 0; i = i - 1 {
    if self.pending[i].id == id {
      ignore(self.pending.remove(i))
      return
    }
  }
  // Cancel from active
  match self.active.get(id) {
    Some(req) => {
      match req.handle {
        Some(h) => self.fetcher.cancel(h)
        None => ()
      }
      req.done = true
      self.active.remove(id)
    }
    None => ()
  }
}

///|
pub fn AssetStreamManager::update(self : AssetStreamManager) -> Unit {
  self.fetcher.poll()
  // Remove completed active requests
  let done_ids : Array[Int] = []
  self.active.each(fn(id, req) { if req.done { done_ids.push(id) } })
  for id in done_ids {
    self.active.remove(id)
  }
  // Promote pending to active
  while self.active.length() < self.max_concurrent && self.pending.length() > 0 {
    let req = self.pending.remove(0)
    let id = req.id
    let handle = self.fetcher.fetch(req.url, fn(_progress) {  }, fn(data) {
      match self.active.get(id) {
        Some(r) => {
          r.done = true
          match data {
            Some(_) => self.completed_count = self.completed_count + 1
            None => self.failed_count = self.failed_count + 1
          }
          (r.on_complete)(data)
        }
        None => ()
      }
    })
    req.handle = Some(handle)
    self.active.set(id, req)
  }
}

///|
/// Creates an AsyncImageLoader-compatible fetch_image_fn from this stream manager.
pub fn AssetStreamManager::image_fetch_fn(
  self : AssetStreamManager,
  priority? : AssetPriority = Normal,
) -> (String, (@asset.ImageSpec?) -> Unit) -> Unit {
  fn(url, callback) {
    ignore(
      self.enqueue(url, priority, fn(bytes_opt) {
        match bytes_opt {
          None => callback(None)
          Some(bytes) =>
            callback(@asset.decode_image_spec_auto(bytes)) catch {
              _ => callback(None)
            }
        }
      }),
    )
  }
}

///|
pub fn AssetStreamManager::reprioritize(
  self : AssetStreamManager,
  id : Int,
  new_priority : AssetPriority,
) -> Bool {
  for i in 0..<self.pending.length() {
    if self.pending[i].id == id {
      let req = self.pending.remove(i)
      let req : StreamRequest = {
        id: req.id,
        url: req.url,
        priority: new_priority,
        on_complete: req.on_complete,
        handle: req.handle,
        done: req.done,
      }
      let p = priority_to_int(new_priority)
      let mut inserted = false
      for j in 0..<self.pending.length() {
        if priority_to_int(self.pending[j].priority) > p {
          self.pending.insert(j, req)
          inserted = true
          break
        }
      }
      if !(inserted) {
        self.pending.push(req)
      }
      return true
    }
  }
  false
}

///|
pub fn AssetStreamManager::progress(
  self : AssetStreamManager,
) -> StreamProgress {
  {
    total: self.pending.length() +
    self.active.length() +
    self.completed_count +
    self.failed_count,
    pending: self.pending.length(),
    active: self.active.length(),
    completed: self.completed_count,
    failed: self.failed_count,
  }
}
