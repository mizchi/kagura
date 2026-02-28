///|
/// fetch → Bytes bridge for JS target.
/// Uses globalThis.__kagura_fetch[id] to support concurrent fetches.

///|
extern "js" fn js_fetch_url(
  url : String,
  fetch_id : Int,
  on_done : (Int, Int) -> Unit,
) -> Unit =
  #| (url, id, onDone) => {
  #|   if (!globalThis.__kagura_fetch) globalThis.__kagura_fetch = {};
  #|   fetch(url)
  #|     .then(r => r.arrayBuffer())
  #|     .then(buf => {
  #|       globalThis.__kagura_fetch[id] = new Uint8Array(buf);
  #|       onDone(id, globalThis.__kagura_fetch[id].length);
  #|     })
  #|     .catch(() => { onDone(id, -1); });
  #| }

///|
extern "js" fn js_fetch_buf_byte(fetch_id : Int, index : Int) -> Int =
  #| (id, i) => globalThis.__kagura_fetch[id][i]

///|
extern "js" fn js_fetch_buf_clear(fetch_id : Int) -> Unit =
  #| (id) => { delete globalThis.__kagura_fetch[id]; }

///|
let fetch_id_counter : Ref[Int] = Ref::new(0)

///|
pub fn fetch_bytes(url : String, callback : (Bytes?) -> Unit) -> Unit {
  let id = fetch_id_counter.val
  fetch_id_counter.val = id + 1
  js_fetch_url(url, id, fn(fid, len) {
    if len < 0 {
      callback(None)
      return
    }
    let arr : Array[Byte] = Array::make(len, b'\x00')
    for i in 0..<len {
      arr[i] = js_fetch_buf_byte(fid, i).to_byte()
    }
    js_fetch_buf_clear(fid)
    callback(Some(Bytes::from_array(arr)))
  })
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
