///|
/// Host capabilities are installed before application state is constructed.
/// File access and clocks must not require a window, graphics device or audio.
pub(all) struct FileAccess {
  read : (String, String?) -> Bytes?
  write : (String, Bytes) -> Bool
}

///|
pub(all) struct FrameHost {
  request_frame : (() -> Unit) -> Unit
  on_exit : (() -> Unit) -> Unit
  publish_phases : (Double, Double, Double) -> Unit
}

///|
let file_access : Ref[FileAccess?] = Ref(None)

///|
let clock : Ref[() -> Double] = Ref(fn() { 0.0 })

///|
let frame_host : Ref[FrameHost?] = Ref(None)

///|
pub fn set_file_access(access : FileAccess) -> Unit {
  file_access.val = Some(access)
}

///|
pub fn reset_file_access() -> Unit {
  file_access.val = None
}

///|
pub fn read_file(path : String, override_env? : String? = None) -> Bytes? {
  match file_access.val {
    Some(access) => (access.read)(path, override_env)
    None => None
  }
}

///|
pub fn write_file(path : String, bytes : Bytes) -> Bool {
  match file_access.val {
    Some(access) => (access.write)(path, bytes)
    None => false
  }
}

///|
pub fn set_clock(provider : () -> Double) -> Unit {
  clock.val = provider
}

///|
pub fn reset_clock() -> Unit {
  clock.val = fn() { 0.0 }
}

///|
pub fn now_ms() -> Double {
  (clock.val)()
}

///|
pub fn set_frame_host(host : FrameHost) -> Unit {
  frame_host.val = Some(host)
}

///|
pub fn reset_frame_host() -> Unit {
  frame_host.val = None
}

///|
pub fn request_frame(callback : () -> Unit) -> Unit {
  match frame_host.val {
    Some(host) => (host.request_frame)(callback)
    None => abort("Frame host is not installed")
  }
}

///|
pub fn on_exit(callback : () -> Unit) -> Unit {
  match frame_host.val {
    Some(host) => (host.on_exit)(callback)
    None => ()
  }
}

///|
pub fn publish_frame_phases(
  update_ms : Double,
  draw_ms : Double,
  render_ms : Double,
) -> Unit {
  match frame_host.val {
    Some(host) => (host.publish_phases)(update_ms, draw_ms, render_ms)
    None => ()
  }
}
