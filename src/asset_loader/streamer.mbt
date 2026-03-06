///|
pub(all) struct AssetStreamerConfig {
  max_concurrent : Int
  max_cached : Int
  eviction_interval : Int
} derive(Show)

///|
pub fn default_streamer_config() -> AssetStreamerConfig {
  { max_concurrent: 4, max_cached: 128, eviction_interval: 60 }
}

///|
pub(all) struct DistanceThresholds {
  critical : Double
  high : Double
  normal : Double
} derive(Show)

///|
pub fn default_distance_thresholds() -> DistanceThresholds {
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
  key : @asset.AssetKey
  mut last_touched : Int
  mut lod_level : Int
  mut stream_id : Int
}

///|
pub struct AssetStreamer {
  manager : AssetStreamManager
  config : AssetStreamerConfig
  mut frame_count : Int
  handles : Map[String, AssetEntry]
  on_evict : (@asset.AssetKey) -> Unit
}

///|
pub fn new_asset_streamer(
  fetcher : &@asset.BytesFetcher,
  config~ : AssetStreamerConfig = default_streamer_config(),
  on_evict~ : (@asset.AssetKey) -> Unit = fn(_) {},
) -> AssetStreamer {
  {
    manager: new_asset_stream_manager(fetcher, max_concurrent=config.max_concurrent),
    config,
    frame_count: 0,
    handles: {},
    on_evict,
  }
}

///|
pub fn AssetStreamer::request(
  self : AssetStreamer,
  url : String,
  key : @asset.AssetKey,
  priority : AssetPriority,
  on_complete : (Bytes?) -> Unit,
) -> Int {
  // Duplicate check
  match self.handles.get(key.value) {
    Some(entry) => {
      entry.last_touched = self.frame_count
      return entry.stream_id
    }
    None => ()
  }
  let id = self.manager.enqueue(url, priority, on_complete)
  self.handles.set(key.value, {
    key,
    last_touched: self.frame_count,
    lod_level: 0,
    stream_id: id,
  })
  id
}

///|
pub fn AssetStreamer::request_by_distance(
  self : AssetStreamer,
  url : String,
  key : @asset.AssetKey,
  distance : Double,
  thresholds~ : DistanceThresholds = default_distance_thresholds(),
  on_complete~ : (Bytes?) -> Unit,
) -> Int {
  let priority = distance_to_priority(distance, thresholds)
  self.request(url, key, priority, on_complete)
}

///|
pub fn AssetStreamer::request_lod(
  self : AssetStreamer,
  url : String,
  key : @asset.AssetKey,
  lod_level : Int,
  priority : AssetPriority,
  on_complete : (Bytes?) -> Unit,
) -> Int {
  match self.handles.get(key.value) {
    Some(entry) => {
      entry.last_touched = self.frame_count
      if entry.lod_level >= lod_level {
        // Already have same or better LOD
        return entry.stream_id
      }
      // Upgrade LOD: cancel old, request new
      self.manager.cancel(entry.stream_id)
      let id = self.manager.enqueue(url, priority, on_complete)
      entry.stream_id = id // Note: cannot reassign struct field on immutable
      entry.lod_level = lod_level
      id
    }
    None => {
      let id = self.manager.enqueue(url, priority, on_complete)
      self.handles.set(key.value, {
        key,
        last_touched: self.frame_count,
        lod_level,
        stream_id: id,
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
pub fn AssetStreamer::touch(self : AssetStreamer, key : @asset.AssetKey) -> Unit {
  match self.handles.get(key.value) {
    Some(entry) => entry.last_touched = self.frame_count
    None => ()
  }
}

///|
pub fn AssetStreamer::evict(self : AssetStreamer, key : @asset.AssetKey) -> Unit {
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
pub fn AssetStreamer::get_manager(self : AssetStreamer) -> AssetStreamManager {
  self.manager
}
