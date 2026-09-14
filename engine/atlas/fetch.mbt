///|
pub fn fetch_bytes(url : String, callback : (Bytes?) -> Unit) -> Unit {
  @fetch.fetch_bytes(url, callback)
}

///|
pub fn fetch_image(url : String, callback : (ImageSpec?) -> Unit) -> Unit {
  fetch_bytes(url, fn(bytes_opt) {
    match bytes_opt {
      None => callback(None)
      Some(bytes) =>
        callback(decode_image_spec_auto(bytes)) catch {
          _ => callback(None)
        }
    }
  })
}
