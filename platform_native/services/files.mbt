///|
#borrow(path, env)
extern "C" fn load_capture_file(
  path : Bytes,
  size : Int,
  env : Bytes,
  env_length : Int,
) -> Int = "kgr_capture_load"

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
fn read_file(path : String, override_env : String?) -> Bytes? {
  let name = @utf8.encode(path)
  let env = @utf8.encode(override_env.unwrap_or(""))
  let size = load_capture_file(name, name.length(), env, env.length())
  if size == -1 {
    return None
  }
  if size < 0 {
    abort("Unable to read capture file: " + path)
  }
  let data = Array::make(size, b'\x00')
  for i in 0..<size {
    data[i] = capture_file_byte(i).to_byte()
  }
  release_capture_file()
  Some(Bytes::from_array(data))
}

///|
fn write_file(path : String, data : Bytes) -> Bool {
  let name = @utf8.encode(path)
  write_capture_file(name, name.length(), data, data.length()) == 1
}
