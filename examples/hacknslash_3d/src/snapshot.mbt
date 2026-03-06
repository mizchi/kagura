// Snapshot testing support via URL parameters
// Usage: ?snapshot=playing&frames=60&tick=5

extern "js" fn js_get_query_param(key : String) -> String =
  #| (key) => new URLSearchParams(location.search).get(key) ?? ""

extern "js" fn js_get_query_param_int(key : String, default_val : Int) -> Int =
  #| (key, defaultVal) => { const v = new URLSearchParams(location.search).get(key); return v ? parseInt(v, 10) : defaultVal; }

extern "js" fn js_set_snapshot_tick(count : Int) -> Unit =
  #| (count) => { globalThis.__kaguraSnapshotTick = count; }

fn get_snapshot_mode() -> String {
  js_get_query_param("snapshot")
}

fn get_snapshot_frames() -> Int {
  js_get_query_param_int("frames", 60)
}

fn get_snapshot_tick() -> Int {
  js_get_query_param_int("tick", 0)
}
