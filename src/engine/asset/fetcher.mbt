///|
pub(all) struct FetchProgress {
  loaded : Int
  total : Int // -1 if unknown
} derive(Show)

///|
pub(all) struct FetchHandle {
  id : Int
} derive(Show)

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
