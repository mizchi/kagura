///|
pub(all) struct AssetStreamerConfig {
  max_concurrent : Int
  max_cached : Int
  eviction_interval : Int
} derive(Debug)

///|
pub impl Show for AssetStreamerConfig with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn AssetStreamerConfig::default() -> AssetStreamerConfig {
  { max_concurrent: 4, max_cached: 128, eviction_interval: 60 }
}

///|
pub(all) struct DistanceThresholds {
  critical : Double
  high : Double
  normal : Double
} derive(Debug)

///|
pub impl Show for DistanceThresholds with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn DistanceThresholds::default() -> DistanceThresholds {
  { critical: 10.0, high: 30.0, normal: 60.0 }
}

///|
fn distance_to_priority(
  distance : Double,
  thresholds : DistanceThresholds,
) -> AssetPriority {
  if distance <= thresholds.critical {
    Critical
  } else if distance <= thresholds.high {
    High
  } else if distance <= thresholds.normal {
    Normal
  } else {
    Low
  }
}

///|
struct AssetEntry {
  key : @atlas.AssetKey
  mut last_touched : Int
  mut lod_level : Int
  mut stream_id : Int
  mut callbacks : Array[(Bytes?) -> Unit]
  mut completion : AssetCompletion
}

///|
priv enum AssetCompletion {
  Pending
  Completed(Bytes?)
  /// Payload delivered to all callbacks; bytes released to save memory.
  /// New duplicate requests will receive None (callers should re-request if needed).
  Delivered
}

///|
pub struct AssetStreamer {
  manager : AssetStreamManager
  config : AssetStreamerConfig
  mut frame_count : Int
  handles : Map[String, AssetEntry]
  on_evict : (@atlas.AssetKey) -> Unit
}

///|
pub fn AssetStreamer::new(
  fetcher : &@atlas.BytesFetcher,
  config? : AssetStreamerConfig = AssetStreamerConfig::default(),
  on_evict? : (@atlas.AssetKey) -> Unit = fn(_) {  },
) -> AssetStreamer {
  {
    manager: AssetStreamManager::new(
      fetcher,
      max_concurrent=config.max_concurrent,
    ),
    config,
    frame_count: 0,
    handles: Map([]),
    on_evict,
  }
}

///|
pub fn AssetStreamer::request(
  self : AssetStreamer,
  url : String,
  key : @atlas.AssetKey,
  priority : AssetPriority,
  on_complete : (Bytes?) -> Unit,
) -> Int {
  match self.handles.get(key.value) {
    Some(entry) => {
      entry.last_touched = self.frame_count
      match entry.completion {
        Pending => entry.callbacks.push(on_complete)
        Completed(data) => on_complete(data)
        Delivered => on_complete(None)
      }
      return entry.stream_id
    }
    None => ()
  }
  let callbacks : Array[(Bytes?) -> Unit] = [on_complete]
  let id = self.manager.enqueue(url, priority, fn(data) {
    match self.handles.get(key.value) {
      Some(entry) => {
        let pending = entry.callbacks
        entry.callbacks = []
        for callback in pending {
          callback(data)
        }
        // Release Bytes after all callbacks have been notified
        entry.completion = Delivered
      }
      None => ()
    }
  })
  self.handles.set(key.value, {
    key,
    last_touched: self.frame_count,
    lod_level: 0,
    stream_id: id,
    callbacks,
    completion: Pending,
  })
  id
}

///|
pub fn AssetStreamer::request_by_distance(
  self : AssetStreamer,
  url : String,
  key : @atlas.AssetKey,
  distance : Double,
  thresholds? : DistanceThresholds = DistanceThresholds::default(),
  on_complete~ : (Bytes?) -> Unit,
) -> Int {
  let priority = distance_to_priority(distance, thresholds)
  self.request(url, key, priority, on_complete)
}

///|
pub fn AssetStreamer::request_lod(
  self : AssetStreamer,
  url : String,
  key : @atlas.AssetKey,
  lod_level : Int,
  priority : AssetPriority,
  on_complete : (Bytes?) -> Unit,
) -> Int {
  match self.handles.get(key.value) {
    Some(entry) => {
      entry.last_touched = self.frame_count
      if entry.lod_level >= lod_level {
        match entry.completion {
          Pending => entry.callbacks.push(on_complete)
          Completed(data) => on_complete(data)
          Delivered => on_complete(None)
        }
        return entry.stream_id
      }
      self.manager.cancel(entry.stream_id)
      let callbacks : Array[(Bytes?) -> Unit] = [on_complete]
      let id = self.manager.enqueue(url, priority, fn(data) {
        match self.handles.get(key.value) {
          Some(active_entry) => {
            let pending = active_entry.callbacks
            active_entry.callbacks = []
            for callback in pending {
              callback(data)
            }
            active_entry.completion = Delivered
          }
          None => ()
        }
      })
      entry.stream_id = id
      entry.lod_level = lod_level
      entry.callbacks = callbacks
      entry.completion = Pending
      id
    }
    None => {
      let callbacks : Array[(Bytes?) -> Unit] = [on_complete]
      let id = self.manager.enqueue(url, priority, fn(data) {
        match self.handles.get(key.value) {
          Some(entry) => {
            let pending = entry.callbacks
            entry.callbacks = []
            for callback in pending {
              callback(data)
            }
            entry.completion = Delivered
          }
          None => ()
        }
      })
      self.handles.set(key.value, {
        key,
        last_touched: self.frame_count,
        lod_level,
        stream_id: id,
        callbacks,
        completion: Pending,
      })
      id
    }
  }
}

///|
pub fn AssetStreamer::update(self : AssetStreamer) -> Unit {
  self.manager.update()
  self.frame_count = self.frame_count + 1
  // Eviction sweep
  if self.config.eviction_interval > 0 &&
    self.frame_count % self.config.eviction_interval == 0 &&
    self.handles.length() > self.config.max_cached {
    // Collect entries and sort by last_touched
    let entries : Array[(String, Int)] = []
    self.handles.each(fn(k, entry) { entries.push((k, entry.last_touched)) })
    entries.sort_by(fn(a, b) { a.1.compare(b.1) })
    // Evict oldest until under threshold
    let to_evict = self.handles.length() - self.config.max_cached
    for i in 0..<to_evict {
      let (k, _) = entries[i]
      match self.handles.get(k) {
        Some(entry) => {
          self.manager.cancel(entry.stream_id)
          (self.on_evict)(entry.key)
          self.handles.remove(k)
        }
        None => ()
      }
    }
  }
}

///|
pub fn AssetStreamer::touch(
  self : AssetStreamer,
  key : @atlas.AssetKey,
) -> Unit {
  match self.handles.get(key.value) {
    Some(entry) => entry.last_touched = self.frame_count
    None => ()
  }
}

///|
pub fn AssetStreamer::evict(
  self : AssetStreamer,
  key : @atlas.AssetKey,
) -> Unit {
  match self.handles.get(key.value) {
    Some(entry) => {
      self.manager.cancel(entry.stream_id)
      (self.on_evict)(entry.key)
      self.handles.remove(key.value)
    }
    None => ()
  }
}

///|
pub fn AssetStreamer::progress(self : AssetStreamer) -> StreamProgress {
  self.manager.progress()
}

///|
pub fn AssetStreamer::stream_manager(
  self : AssetStreamer,
) -> AssetStreamManager {
  self.manager
}

///|
pub extend AssetStreamerConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AssetStreamerConfig with Show::{to_string, output}

///|
pub extend DistanceThresholds with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DistanceThresholds with Show::{to_string, output}
