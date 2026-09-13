// Browser storage is kept separate from the portable save codec.
///|
extern "js" fn js_storage_set(key : String, value : String) -> Bool =
  #| (key, value) => { try { localStorage.setItem(key, value); return true; } catch { return false; } }

///|
extern "js" fn js_storage_get(key : String) -> String =
  #| key => { try { return localStorage.getItem(key) ?? ""; } catch { return ""; } }

///|
extern "js" fn js_storage_remove(key : String) -> Bool =
  #| key => { try { localStorage.removeItem(key); return localStorage.getItem(key) === null; } catch { return false; } }

///|
extern "js" fn js_encode_world_progress(value : String) -> String =
  #| value => encodeURIComponent(value)

///|
extern "js" fn js_decode_world_progress(value : String) -> String =
  #| value => { try { return decodeURIComponent(value); } catch { return ""; } }
