///|
let bytes_loader : Ref[((String, (Bytes?) -> Unit) -> Unit)?] = Ref(None)

///|
pub fn set_bytes_loader(load : (String, (Bytes?) -> Unit) -> Unit) -> Unit {
  bytes_loader.val = Some(load)
}

///|
pub fn reset_bytes_loader() -> Unit {
  bytes_loader.val = None
}

///|
pub fn fetch_bytes(url : String, callback : (Bytes?) -> Unit) -> Unit {
  match bytes_loader.val {
    Some(load) => load(url, callback)
    None => callback(None)
  }
}
