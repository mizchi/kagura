///|
pub(all) struct FetchProgress {
  loaded : Int
  total : Int // -1 if unknown
} derive(Debug)

///|
pub impl Show for FetchProgress with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) struct FetchHandle {
  id : Int
} derive(Debug)

///|
pub impl Show for FetchHandle with output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(open) trait BytesFetcher {
  fetch(
    Self,
    url : String,
    on_progress : (FetchProgress) -> Unit,
    on_complete : (Bytes?) -> Unit,
  ) -> FetchHandle
  cancel(Self, handle : FetchHandle) -> Unit
  poll(Self) -> Unit
}
