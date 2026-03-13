// Snapshot testing support via URL parameters
// Usage: ?snapshot=playing&frames=60&tick=5

///|
extern "js" fn js_get_query_param(key : String) -> String =
  #| (key) => new URLSearchParams(location.search).get(key) ?? ""

///|
extern "js" fn js_get_query_param_int(key : String, default_val : Int) -> Int =
  #| (key, defaultVal) => { const v = new URLSearchParams(location.search).get(key); return v ? parseInt(v, 10) : defaultVal; }

///|
extern "js" fn js_get_query_param_double(
  key : String,
  default_val : Double,
) -> Double =
  #| (key, defaultVal) => {
  #|   const v = new URLSearchParams(location.search).get(key)
  #|   return v == null ? defaultVal : Number.parseFloat(v)
  #| }

///|
extern "js" fn js_get_query_param_bool(
  key : String,
  default_val : Bool,
) -> Bool =
  #| (key, defaultVal) => {
  #|   const v = new URLSearchParams(location.search).get(key)
  #|   if (v == null) return defaultVal
  #|   return v === "1" || v === "true" || v === "on"
  #| }

///|
extern "js" fn js_set_snapshot_tick(count : Int) -> Unit =
  #| (count) => { globalThis.__kaguraSnapshotTick = count; }

///|
fn get_snapshot_mode() -> String {
  js_get_query_param("snapshot")
}

///|
fn get_snapshot_frames() -> Int {
  js_get_query_param_int("frames", 60)
}

///|
fn get_snapshot_tick() -> Int {
  js_get_query_param_int("tick", 0)
}

///|
fn get_initial_profiler_enabled() -> Bool {
  js_get_query_param_bool("profiler", false)
}

///|
fn get_initial_perf_capture_enabled() -> Bool {
  js_get_query_param_bool("perf", false)
}

///|
fn get_initial_autoplay_enabled() -> Bool {
  js_get_query_param_bool("autoplay", false)
}

///|
fn get_initial_balance_preset_name() -> String {
  js_get_query_param("balance_preset")
}

///|
fn get_initial_fxaa_enabled() -> Bool {
  js_get_query_param_bool("fxaa", false)
}

///|
fn get_initial_shadows_enabled() -> Bool {
  js_get_query_param_bool("shadows", false)
}

///|
fn get_initial_ssao_enabled() -> Bool {
  js_get_query_param_bool("ssao", false)
}

///|
fn get_initial_stress_enemy_count() -> Int {
  js_get_query_param_int("stress_enemies", 0)
}

///|
fn get_initial_generated_prop_path() -> String {
  js_get_query_param("generated_prop")
}

///|
fn get_initial_generated_prop_anchor_name() -> String {
  js_get_query_param("generated_prop_anchor")
}

///|
fn get_initial_generated_prop_role_name() -> String {
  js_get_query_param("generated_prop_role")
}

///|
fn get_initial_generated_prop_pickup_effect_name() -> String {
  js_get_query_param("generated_prop_pickup")
}

///|
fn get_initial_generated_prop_pickup_rarity_name() -> String {
  js_get_query_param("generated_prop_pickup_rarity")
}

///|
fn get_initial_generated_prop_pickup_slot_name() -> String {
  js_get_query_param("generated_prop_pickup_slot")
}

///|
fn get_initial_generated_prop_scale() -> Double {
  js_get_query_param_double("generated_prop_scale", 1.0)
}

///|
fn get_initial_generated_prop_yaw_degrees() -> Double {
  js_get_query_param_double("generated_prop_yaw", 0.0)
}

///|
fn get_initial_generated_prop_x_offset_tiles() -> Double {
  js_get_query_param_double("generated_prop_x_offset", 2.0)
}

///|
fn get_initial_generated_prop_z_offset_tiles() -> Double {
  js_get_query_param_double("generated_prop_z_offset", 0.0)
}
