///|
pub fn read_native_capture_text(
  path : String,
  config? : Bool = false,
) -> String? {
  @services.read_file(
    path,
    override_env=if config { Some("KAGURA_CAPTURE_CONFIG") } else { None },
  ).map(fn(data) {
    @utf8.decode(data) catch {
      _ => abort("Invalid UTF-8 capture file: " + path)
    }
  })
}

///|
pub fn write_native_capture_bytes(path : String, data : Bytes) -> Unit {
  if !@services.write_file(path, data) {
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
