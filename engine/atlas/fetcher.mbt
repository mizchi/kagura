///|
pub(all) struct FetchProgress {
  loaded : Int
  total : Int // -1 if unknown
} derive(Debug)

///|
pub impl Show for FetchProgress with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(all) struct FetchHandle {
  id : Int
} derive(Debug)

///|
pub impl Show for FetchHandle with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub(open) trait BytesFetcher {
  fn fetch(
    Self,
    url : String,
    on_progress : (FetchProgress) -> Unit,
    on_complete : (Bytes?) -> Unit,
  ) -> FetchHandle
  fn cancel(Self, handle : FetchHandle) -> Unit
  fn poll(Self) -> Unit
}

///|
pub extend FetchProgress with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FetchProgress with Show::{to_string, output}

///|
pub extend FetchHandle with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FetchHandle with Show::{to_string, output}
