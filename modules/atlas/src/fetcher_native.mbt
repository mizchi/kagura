///|
/// Native BytesFetcher using function injection.
/// Reads files synchronously and delivers callbacks via deferred queue.

///|
struct DeferredResult {
  id : Int
  data : Bytes?
  on_progress : (FetchProgress) -> Unit
  on_complete : (Bytes?) -> Unit
  mut cancelled : Bool
}

///|
pub struct NativeFetcher {
  read_file_fn : (String) -> Bytes?
  mut next_id : Int
  deferred : Array[DeferredResult]
}

///|
pub fn new_native_fetcher(read_file_fn : (String) -> Bytes?) -> NativeFetcher {
  { read_file_fn, next_id: 1, deferred: [] }
}

///|
pub impl BytesFetcher for NativeFetcher with fn fetch(
  self,
  url,
  on_progress,
  on_complete,
) {
  let id = self.next_id
  self.next_id = self.next_id + 1
  let data = (self.read_file_fn)(url)
  self.deferred.push({ id, data, on_progress, on_complete, cancelled: false })
  { id, }
}

///|
pub impl BytesFetcher for NativeFetcher with fn cancel(self, handle) {
  for entry in self.deferred {
    if entry.id == handle.id {
      entry.cancelled = true
    }
  }
}

///|
pub impl BytesFetcher for NativeFetcher with fn poll(self) {
  let pending = self.deferred.drain(0, self.deferred.length())
  for entry in pending {
    if entry.cancelled {
      continue
    }
    match entry.data {
      Some(bytes) => {
        let total = bytes.length()
        (entry.on_progress)({ loaded: total, total })
        (entry.on_complete)(Some(bytes))
      }
      None => (entry.on_complete)(None)
    }
  }
}

///|
pub extend NativeFetcher with BytesFetcher::{fetch, poll, cancel}
