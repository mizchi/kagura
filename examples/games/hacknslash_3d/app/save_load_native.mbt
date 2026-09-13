// Native has no persistent storage backend yet.
///|
fn js_storage_set(_key : String, _value : String) -> Bool { false }

///|
fn js_storage_get(_key : String) -> String { "" }

///|
fn js_storage_remove(_key : String) -> Bool { false }

///|
fn js_encode_world_progress(value : String) -> String { value }

///|
fn js_decode_world_progress(value : String) -> String { value }
