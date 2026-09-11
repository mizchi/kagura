///|
/// Host log import: (level, utf8_ptr, utf8_len) -> unit.
extern "wasm" fn host_log_i32_utf8(level : Int, ptr : Int, len : Int) -> Unit = "kagura_host" "log_i32_utf8"

///|
/// Host asset imports for synchronous shared-memory reads.
extern "wasm" fn host_read_asset_len_i32_utf8(ptr : Int, len : Int) -> Int = "kagura_host" "read_asset_len_i32_utf8"

///|
extern "wasm" fn host_read_asset_copy_i32_utf8(
  path_ptr : Int,
  path_len : Int,
  dst_ptr : Int,
) -> Int = "kagura_host" "read_asset_copy_i32_utf8"

///|
fn write_utf8_to_heap(s : String) -> Utf8Slice {
  let bytes = s.to_array()
  let ptr = bump_alloc(bytes.length())
  for i = 0; i < bytes.length(); i = i + 1 {
    mem_store8(ptr + i, bytes[i].to_int())
  }
  { ptr, len: bytes.length() }
}

///|
fn host_log(level : Int, message : String) -> Unit {
  let utf8 = write_utf8_to_heap(message)
  host_log_i32_utf8(level, utf8.ptr, utf8.len)
}

///|
fn host_log_info(message : String) -> Unit {
  host_log(2, message)
}

///|
fn host_read_asset_utf8(path : String) -> Utf8Slice? {
  let encoded_path = write_utf8_to_heap(path)
  let asset_len = host_read_asset_len_i32_utf8(
    encoded_path.ptr,
    encoded_path.len,
  )
  if asset_len < 0 {
    None
  } else {
    let asset_ptr = bump_alloc(asset_len)
    let copied_len = host_read_asset_copy_i32_utf8(
      encoded_path.ptr,
      encoded_path.len,
      asset_ptr,
    )
    if copied_len < 0 {
      None
    } else {
      Some({ ptr: asset_ptr, len: copied_len })
    }
  }
}
