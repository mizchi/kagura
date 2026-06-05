///|
/// JS BytesFetcher using ReadableStream + AbortController.

///|
extern "js" fn js_stream_fetch(
  url : String,
  fetch_id : Int,
  on_progress : (Int, Int, Int) -> Unit,
  on_done : (Int, Int) -> Unit,
) -> Unit =
  #| (url, id, onProgress, onDone) => {
  #|   if (!globalThis.__kagura_fetch) globalThis.__kagura_fetch = {};
  #|   const ctrl = new AbortController();
  #|   if (!globalThis.__kagura_fetch_ctrl) globalThis.__kagura_fetch_ctrl = {};
  #|   globalThis.__kagura_fetch_ctrl[id] = ctrl;
  #|   fetch(url, { signal: ctrl.signal })
  #|     .then(r => {
  #|       const total = parseInt(r.headers.get('content-length') || '-1', 10);
  #|       const reader = r.body.getReader();
  #|       const chunks = [];
  #|       let loaded = 0;
  #|       function pump() {
  #|         return reader.read().then(({ done, value }) => {
  #|           if (done) {
  #|             let size = 0;
  #|             for (const c of chunks) size += c.length;
  #|             const buf = new Uint8Array(size);
  #|             let off = 0;
  #|             for (const c of chunks) { buf.set(c, off); off += c.length; }
  #|             globalThis.__kagura_fetch[id] = buf;
  #|             onDone(id, size);
  #|             return;
  #|           }
  #|           chunks.push(value);
  #|           loaded += value.length;
  #|           onProgress(id, loaded, total);
  #|           return pump();
  #|         });
  #|       }
  #|       return pump();
  #|     })
  #|     .catch(() => { onDone(id, -1); });
  #| }

///|
extern "js" fn js_stream_fetch_cancel(fetch_id : Int) -> Unit =
  #| (id) => {
  #|   if (globalThis.__kagura_fetch_ctrl && globalThis.__kagura_fetch_ctrl[id]) {
  #|     globalThis.__kagura_fetch_ctrl[id].abort();
  #|     delete globalThis.__kagura_fetch_ctrl[id];
  #|   }
  #|   if (globalThis.__kagura_fetch && globalThis.__kagura_fetch[id]) {
  #|     delete globalThis.__kagura_fetch[id];
  #|   }
  #| }

///|
extern "js" fn js_fetch_buf_copy(
  fetch_id : Int,
  dst : FixedArray[Byte],
  len : Int,
) -> Unit =
  #| (id, dst, len) => {
  #|   const src = globalThis.__kagura_fetch[id];
  #|   for (let i = 0; i < len; i++) dst[i] = src[i];
  #|   delete globalThis.__kagura_fetch[id];
  #| }

///|
pub struct JsFetcher {
  mut next_id : Int
}

///|
pub fn new_js_fetcher() -> JsFetcher {
  { next_id: 1 }
}

///|
pub impl BytesFetcher for JsFetcher with fn fetch(
  self,
  url,
  on_progress,
  on_complete,
) {
  let id = self.next_id
  self.next_id = self.next_id + 1
  js_stream_fetch(
    url,
    id,
    fn(_, loaded, total) { on_progress({ loaded, total }) },
    fn(fid, len) {
      if len < 0 {
        on_complete(None)
        return
      }
      let buf = FixedArray::make(len, b'\x00')
      js_fetch_buf_copy(fid, buf, len)
      on_complete(Some(Bytes::from_array(buf)))
    },
  )
  { id, }
}

///|
pub impl BytesFetcher for JsFetcher with fn cancel(_, handle) {
  js_stream_fetch_cancel(handle.id)
}

///|
pub impl BytesFetcher for JsFetcher with fn poll(_) {
  // no-op on JS — callbacks fire via microtask queue
}
