///|
#borrow(path)
extern "C" fn load_capture_file(path : Bytes, size : Int, config : Int) -> Int = "kgr_capture_load"

///|
extern "C" fn capture_file_byte(index : Int) -> Int = "kgr_capture_byte"

///|
extern "C" fn release_capture_file() -> Unit = "kgr_capture_release"

///|
#borrow(path, data)
extern "C" fn write_capture_file(
  path : Bytes,
  size : Int,
  data : Bytes,
  length : Int,
) -> Int = "kgr_capture_write"

///|
/// Native-only IO, using UTF-8 without initializing a window or GPU.
/// An explicit but unreadable config is an error, never an interactive fallback.
pub fn read_native_capture_text(
  path : String,
  config? : Bool = false,
) -> String? {
  let bytes = @utf8.encode(path)
  let size = load_capture_file(
    bytes,
    bytes.length(),
    if config {
      1
    } else {
      0
    },
  )
  if size == -1 {
    return None
  }
  if size < 0 {
    abort("Unable to read capture file: " + path)
  }
  let data : Array[Byte] = Array::make(size, b'\x00')
  for i in 0..<size {
    data[i] = capture_file_byte(i).to_byte()
  }
  release_capture_file()
  Some(
    @utf8.decode(Bytes::from_array(data)) catch {
      _ => abort("Invalid UTF-8 capture file: " + path)
    },
  )
}

///|
pub fn write_native_capture_bytes(path : String, data : Bytes) -> Unit {
  let bytes = @utf8.encode(path)
  if write_capture_file(bytes, bytes.length(), data, data.length()) != 1 {
    abort("Unable to write capture file: " + path)
  }
}

///|
pub fn write_native_capture_text(path : String, text : String) -> Unit {
  write_native_capture_bytes(path, @utf8.encode(text))
}

///|
pub fn capture_request_path(text : String) -> String? {
  parse_config_entries(text).get("request_path")
}
