///|
extern "C" fn now_ms() -> Double = "kagura_runtime_now_ms"

///|
/// Install early: capture configuration is read before a window is created.
pub fn install() -> Unit {
  @fetch.set_bytes_loader(fn(path, complete) { complete(read_file(path, None)) })
  @host.set_clock(now_ms)
  @host.set_file_access({ read: read_file, write: write_file, })
}
