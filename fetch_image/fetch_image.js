const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $f32_reinterpret_i32(a) {
  $reinterpret_view.setInt32(0, a, true);
  return $reinterpret_view.getFloat32(0, true);
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function _M0TP36mizchi6kagura6engine14LifecycleHooks(param0, param1) {
  this.on_start = param0;
  this.on_stop = param1;
}
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB13SourceLocRepr(param0, param1, param2, param3, param4, param5) {
  this.pkg = param0;
  this.filename = param1;
  this.start_line = param2;
  this.start_column = param3;
  this.end_line = param4;
  this.end_column = param5;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $makebytes(a, b) {
  const arr = new Uint8Array(a);
  if (b !== 0) {
    arr.fill(b);
  }
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function _M0TPB7MyInt64(param0, param1) {
  this.hi = param0;
  this.lo = param1;
}
const $bytes_literal$0 = new Uint8Array();
const _M0MPB7MyInt6419reinterpret__double = function f(a) {
  let view = f._view;
  if (view === undefined) {
    view = f._view = new DataView(new ArrayBuffer(8));
  }
  view.setFloat64(0, a);
  const hi = view.getInt32(0);
  const lo = view.getInt32(4);
  return { hi, lo };
};
function _M0TPC13ref3RefGiE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGdE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGORP36mizchi6kagura6engine14LifecycleHooksE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGbE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGsE(param0) {
  this.val = param0;
}
function $i32_reinterpret_f32(a) {
  $reinterpret_view.setFloat32(0, a, true);
  return $reinterpret_view.getInt32(0, true);
}
function _M0TPC13ref3RefGjE(param0) {
  this.val = param0;
}
function _M0TPB9ArrayViewGyE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok.prototype.$tag = 1;
function _M0DTPC15error5Error47mizchi_2fimage_2eDecodeError_2eInvalidSignature(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error47mizchi_2fimage_2eDecodeError_2eInvalidSignature.prototype.$tag = 5;
function _M0DTPC15error5Error46mizchi_2fimage_2eDecodeError_2eInvalidChunkCrc(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error46mizchi_2fimage_2eDecodeError_2eInvalidChunkCrc.prototype.$tag = 4;
function _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk.prototype.$tag = 3;
function _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature.prototype.$tag = 2;
function _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData.prototype.$tag = 1;
function _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData.prototype.$tag = 0;
function _M0TP26mizchi4zlib11HuffmanTree(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9) {
  this.left = param0;
  this.right = param1;
  this.symbol = param2;
  this.table_bits = param3;
  this.table_symbol = param4;
  this.table_len = param5;
  this.table_sub = param6;
  this.sub_bits = param7;
  this.sub_symbol = param8;
  this.sub_len = param9;
}
function _M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok.prototype.$tag = 1;
const $1L = { hi: 0, lo: 1 };
function _M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE2Ok.prototype.$tag = 1;
const $0L = { hi: 0, lo: 0 };
function _M0TP26mizchi4zlib9BitReader(param0, param1, param2, param3) {
  this.data = param0;
  this.byte_pos = param1;
  this.bit_buf = param2;
  this.bit_count = param3;
}
function _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGzRP26mizchi4zlib9ZlibErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGzRP26mizchi4zlib9ZlibErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGzRP26mizchi4zlib9ZlibErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGzRP26mizchi4zlib9ZlibErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TP26mizchi5image13BmpDecodeInfo(param0, param1, param2, param3, param4, param5, param6) {
  this.width = param0;
  this.height = param1;
  this.bpp = param2;
  this.bytes_per_px = param3;
  this.pixel_offset = param4;
  this.padded_row_size = param5;
  this.top_down = param6;
}
function _M0TPC13ref3RefGOzE(param0) {
  this.val = param0;
}
function _M0DTPC16result6ResultGURPB5ArrayGzEOzERP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGURPB5ArrayGzEOzERP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGURPB5ArrayGzEOzERP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGURPB5ArrayGzEOzERP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TPC13ref3RefGzE(param0) {
  this.val = param0;
}
function _M0TPB9ArrayViewGcE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TP26mizchi5image8PngChunk(param0, param1) {
  this.chunk_type = param0;
  this.data = param1;
}
function _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TP26mizchi5image8IhdrData(param0, param1, param2, param3, param4, param5, param6) {
  this.width = param0;
  this.height = param1;
  this.bit_depth = param2;
  this.color_type = param3;
  this.compression = param4;
  this.filter = param5;
  this.interlace = param6;
}
function _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TP26mizchi5image9ImageData(param0, param1, param2) {
  this.width = param0;
  this.height = param1;
  this.data = param2;
}
function _M0TP26mizchi5image13JpegBitReader(param0, param1, param2, param3) {
  this.data = param0;
  this.pos = param1;
  this.bit_buf = param2;
  this.bits_left = param3;
}
function _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TP26mizchi5image12HuffmanTable(param0, param1, param2, param3) {
  this.min_code = param0;
  this.max_code = param1;
  this.val_ptr = param2;
  this.values = param3;
}
function _M0TPC13ref3RefGORP26mizchi5image13JpegFrameInfoE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGRPB5ArrayGRP26mizchi5image17JpegScanComponentEE(param0) {
  this.val = param0;
}
function _M0TP26mizchi5image13JpegComponent(param0, param1, param2, param3) {
  this.id = param0;
  this.h_sample = param1;
  this.v_sample = param2;
  this.quant_id = param3;
}
function _M0TP26mizchi5image13JpegFrameInfo(param0, param1, param2, param3, param4) {
  this.width = param0;
  this.height = param1;
  this.components = param2;
  this.max_h = param3;
  this.max_v = param4;
}
function _M0TP26mizchi5image17JpegScanComponent(param0, param1, param2) {
  this.comp_idx = param0;
  this.dc_table_id = param1;
  this.ac_table_id = param2;
}
function _M0TP36mizchi6kagura4core11OutsideSize(param0, param1) {
  this.width = param0;
  this.height = param1;
}
function _M0TP36mizchi6kagura4core10TouchPoint(param0, param1, param2, param3) {
  this.id = param0;
  this.x = param1;
  this.y = param2;
  this.source = param3;
}
function _M0TP36mizchi6kagura4core15GamepadSnapshot(param0, param1, param2) {
  this.id = param0;
  this.axes = param1;
  this.pressed_buttons = param2;
}
function _M0TP36mizchi6kagura4core13InputSnapshot(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.cursor_x = param0;
  this.cursor_y = param1;
  this.wheel_x = param2;
  this.wheel_y = param3;
  this.pressed_keys = param4;
  this.pressed_mouse_buttons = param5;
  this.touches = param6;
  this.gamepads = param7;
}
function _M0TP36mizchi6kagura8platform14WebCanvasHooks(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16, param17, param18, param19) {
  this.try_initialize = param0;
  this.poll = param1;
  this.should_close = param2;
  this.outside_size = param3;
  this.current_surface = param4;
  this.capture_input = param5;
  this.set_fullscreen = param6;
  this.is_fullscreen = param7;
  this.set_cursor_mode = param8;
  this.cursor_mode = param9;
  this.set_device_scale_factor = param10;
  this.device_scale_factor = param11;
  this.set_vsync_enabled = param12;
  this.is_vsync_enabled = param13;
  this.close_window = param14;
  this.request_attention = param15;
  this.set_mouse_touch_fallback = param16;
  this.mouse_touch_fallback_enabled = param17;
  this.fullscreen_request_status = param18;
  this.cursor_mode_request_status = param19;
}
function _M0TP36mizchi6kagura8platform12SurfaceToken(param0, param1, param2, param3, param4) {
  this.kind = param0;
  this.opaque_id = param1;
  this.width = param2;
  this.height = param3;
  this.device_scale_factor = param4;
}
function _M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0TP36mizchi6kagura8platform13WindowOptions(param0, param1, param2, param3, param4, param5) {
  this.title = param0;
  this.width = param1;
  this.height = param2;
  this.transparent = param3;
  this.resizable = param4;
  this.focused = param5;
}
function _M0TP36mizchi6kagura8platform17WebCanvasPlatform(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15) {
  this.canvas_selector = param0;
  this.initialized = param1;
  this.poll_count = param2;
  this.close_after_polls = param3;
  this.web_active = param4;
  this.options = param5;
  this.current_input = param6;
  this.fullscreen = param7;
  this.cursor_mode = param8;
  this.device_scale_factor = param9;
  this.vsync_enabled = param10;
  this.close_requested = param11;
  this.attention_requests = param12;
  this.mouse_touch_fallback = param13;
  this.fullscreen_request_status = param14;
  this.cursor_mode_request_status = param15;
}
function _M0DTPC16result6ResultGuRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC15error5ErrorE2Ok.prototype.$tag = 1;
const $2047L = { hi: 0, lo: 2047 };
const $4503599627370495L = { hi: 1048575, lo: -1 };
function _M0TP36mizchi6kagura3gfx16BuiltinShaderKey(param0, param1, param2) {
  this.filter = param0;
  this.address = param1;
  this.use_color_m = param2;
}
function _M0TP36mizchi6kagura3gfx9DstRegion(param0, param1, param2, param3, param4) {
  this.x = param0;
  this.y = param1;
  this.width = param2;
  this.height = param3;
  this.index_count = param4;
}
function _M0TP36mizchi6kagura3gfx5Color(param0, param1, param2, param3) {
  this.r = param0;
  this.g = param1;
  this.b = param2;
  this.a = param3;
}
function _M0TP36mizchi6kagura3gfx14RenderPassDesc(param0, param1, param2) {
  this.clear_color = param0;
  this.clear_enabled = param1;
  this.present = param2;
}
function _M0DTP36mizchi6kagura3gfx9BlendMode4Copy() {}
_M0DTP36mizchi6kagura3gfx9BlendMode4Copy.prototype.$tag = 0;
const _M0DTP36mizchi6kagura3gfx9BlendMode4Copy__ = new _M0DTP36mizchi6kagura3gfx9BlendMode4Copy();
function _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha() {}
_M0DTP36mizchi6kagura3gfx9BlendMode5Alpha.prototype.$tag = 1;
const _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha__ = new _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha();
function _M0DTP36mizchi6kagura3gfx9BlendMode3Add() {}
_M0DTP36mizchi6kagura3gfx9BlendMode3Add.prototype.$tag = 2;
const _M0DTP36mizchi6kagura3gfx9BlendMode3Add__ = new _M0DTP36mizchi6kagura3gfx9BlendMode3Add();
function _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply() {}
_M0DTP36mizchi6kagura3gfx9BlendMode8Multiply.prototype.$tag = 3;
const _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply__ = new _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply();
function _M0DTP36mizchi6kagura3gfx9BlendMode6Custom(param0) {
  this._0 = param0;
}
_M0DTP36mizchi6kagura3gfx9BlendMode6Custom.prototype.$tag = 4;
function _M0TP36mizchi6kagura3gfx11ImageHandle(param0, param1, param2) {
  this.id = param0;
  this.width = param1;
  this.height = param2;
}
function _M0TP36mizchi6kagura3gfx12ShaderHandle(param0, param1) {
  this.id = param0;
  this.source = param1;
}
function _M0TP36mizchi6kagura3gfx20DrawTrianglesCommand(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12) {
  this.dst = param0;
  this.shader = param1;
  this.dst_regions = param2;
  this.index_offset = param3;
  this.pipeline_id = param4;
  this.uniform_hash = param5;
  this.blend = param6;
  this.vertex_data = param7;
  this.indices = param8;
  this.src_image_ids = param9;
  this.uniform_dwords = param10;
  this.instance_count = param11;
  this.resource_cache_key = param12;
}
function _M0DTPC16option6OptionGRPB5ArrayGiEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGiEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGiEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGiEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGiEE4Some.prototype.$tag = 1;
function _M0TP36mizchi6kagura3gfx16WebGraphicsHooks(param0, param1, param2, param3, param4, param5) {
  this.try_initialize = param0;
  this.on_begin = param1;
  this.on_end = param2;
  this.on_draw = param3;
  this.on_resize = param4;
  this.on_read_pixels = param5;
}
function _M0TP36mizchi6kagura3gfx19NativeGraphicsHooks(param0, param1, param2, param3, param4, param5, param6) {
  this.try_initialize = param0;
  this.on_begin = param1;
  this.on_end = param2;
  this.on_draw = param3;
  this.on_resize = param4;
  this.on_read_pixels = param5;
  this.on_new_image = param6;
}
function _M0TP36mizchi6kagura3gfx22GraphicsBackendOptions(param0, param1, param2) {
  this.enable_validation = param0;
  this.prefer_low_power = param1;
  this.enable_vsync = param2;
}
function _M0TP36mizchi6kagura3gfx18StubGraphicsDriver(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13) {
  this.backend = param0;
  this.width = param1;
  this.height = param2;
  this.initialized = param3;
  this.native_active = param4;
  this.web_active = param5;
  this.next_id = param6;
  this.begin_count = param7;
  this.end_count = param8;
  this.draw_count = param9;
  this.resize_count = param10;
  this.resize_suppressed_count = param11;
  this.last_resize_duration_ms = param12;
  this.total_resize_duration_ms = param13;
}
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0TP36mizchi6kagura14image__palette4Rgba(param0, param1, param2, param3) {
  this.r = param0;
  this.g = param1;
  this.b = param2;
  this.a = param3;
}
function _M0TP36mizchi6kagura14image__palette15ImagePalette2x2(param0, param1, param2, param3) {
  this.p00 = param0;
  this.p10 = param1;
  this.p01 = param2;
  this.p11 = param3;
}
function _M0TP36mizchi6kagura5asset9ImageSpec(param0, param1, param2, param3, param4) {
  this.width = param0;
  this.height = param1;
  this.format = param2;
  this.palette = param3;
  this.pixels_rgba8 = param4;
}
function _M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGORP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGORP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok.prototype.$tag = 1;
function _M0TP36mizchi6kagura5asset20SourceImageDirtyRect(param0, param1, param2, param3) {
  this.x = param0;
  this.y = param1;
  this.width = param2;
  this.height = param3;
}
function _M0TP36mizchi6kagura5asset11AtlasRegion(param0, param1, param2, param3, param4) {
  this.x = param0;
  this.y = param1;
  this.width = param2;
  this.height = param3;
  this.atlas_id = param4;
}
function _M0TP36mizchi6kagura5asset21SimpleAtlasImageEntry(param0, param1, param2, param3, param4) {
  this.key = param0;
  this.handle = param1;
  this.region = param2;
  this.palette = param3;
  this.pixels_rgba8 = param4;
}
const _M0FP36mizchi6kagura5asset14js__fetch__url = (url, id, onDone) => {
   if (!globalThis.__kagura_fetch) globalThis.__kagura_fetch = {};
   fetch(url)
     .then(r => r.arrayBuffer())
     .then(buf => {
       globalThis.__kagura_fetch[id] = new Uint8Array(buf);
       onDone(id, globalThis.__kagura_fetch[id].length);
     })
     .catch(() => { onDone(id, -1); });
 };
const _M0FP36mizchi6kagura5asset20js__fetch__buf__byte = (id, i) => globalThis.__kagura_fetch[id][i];
const _M0FP36mizchi6kagura5asset21js__fetch__buf__clear = (id) => { delete globalThis.__kagura_fetch[id]; };
function _M0TP36mizchi6kagura5asset8AssetKey(param0) {
  this.value = param0;
}
function _M0TP36mizchi6kagura5asset20SimpleAtlasAllocator(param0, param1, param2, param3, param4, param5, param6) {
  this.atlas_width = param0;
  this.atlas_height = param1;
  this.atlas_id = param2;
  this.cursor_x = param3;
  this.cursor_y = param4;
  this.row_height = param5;
  this.allocated = param6;
}
function _M0TP36mizchi6kagura5asset15AtlasDrawSource(param0, param1, param2, param3, param4, param5) {
  this.page_image_id = param0;
  this.region = param1;
  this.u0 = param2;
  this.v0 = param3;
  this.u1 = param4;
  this.v1 = param5;
}
function _M0TP36mizchi6kagura5asset26SimpleAtlasImageRepository(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.atlas_width = param0;
  this.atlas_height = param1;
  this.atlas_id = param2;
  this.next_image_id = param3;
  this.allocator = param4;
  this.images = param5;
  this.page_generation = param6;
  this.page_dirty_rect = param7;
}
function _M0TPC13ref3RefGORP36mizchi6kagura5asset15AtlasDrawSourceE(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura5asset18SourceImageBinding(param0, param1, param2, param3, param4, param5, param6) {
  this.image_id = param0;
  this.width = param1;
  this.height = param2;
  this.generation = param3;
  this.dirty_rect = param4;
  this.palette = param5;
  this.pixels_rgba8 = param6;
}
function _M0TPC13ref3RefGfE(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura5audio11AudioFormat(param0, param1, param2) {
  this.sample_rate = param0;
  this.channels = param1;
  this.bits_per_sample = param2;
}
function _M0TP36mizchi6kagura5audio16AudioOutputHooks(param0, param1, param2, param3, param4, param5) {
  this.try_initialize = param0;
  this.write_frames = param1;
  this.suspend = param2;
  this.resume_playback = param3;
  this.close = param4;
  this.output_latency = param5;
}
const _M0FP36mizchi6kagura6engine29js__request__animation__frame = (f) => { requestAnimationFrame(() => f()); };
const _M0FP36mizchi6kagura6engine20js__on__beforeunload = (f) => { window.addEventListener("beforeunload", () => f()); };
const _M0FP36mizchi6kagura6engine20js__performance__now = () => (globalThis.performance?.now?.() ?? Date.now());
function _M0TP36mizchi6kagura6engine13EngineContext(param0, param1, param2, param3) {
  this.dst = param0;
  this.shader = param1;
  this.screen_w = param2;
  this.screen_h = param3;
}
function _M0TP36mizchi6kagura4text13FontLoadHooks(param0) {
  this.load_font_data = param0;
}
function _M0TP26mizchi19web__runtime__hooks22SyncedSourceGeneration(param0, param1) {
  this.image_id = param0;
  this.generation = param1;
}
function _M0TPC13ref3RefGORP26mizchi19web__runtime__hooks21SourceImageCacheEntryE(param0) {
  this.val = param0;
}
const _M0FP26mizchi19web__runtime__hooks20js__prepare__surface = (selector, fallbackWidth, fallbackHeight) => {
   const root = globalThis;
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {
     nextSurfaceId: 100,
     selector: "#app",
     canvas: null,
     surfaceId: 0,
     width: fallbackWidth,
     height: fallbackHeight,
     dpr: 1,
     webgpu: {
       context: null,
       device: null,
       format: "bgra8unorm",
       pending: null,
       _pipeline: null,
       _pipelineFormat: "",
       _uniformBGL: null,
       _texBGL: null,
       _defaultTexture: null,
       _defaultTexView: null,
       _defaultSampler: null,
       _drawResourceCache: null,
       _currentDraw: null,
       _pendingTexture: null,
       presentScheduled: false,
       clear: [0, 0, 0, 1],
       commands: [],
       textures: null,
       lastError: "",
     },
   });
   state.selector = selector;
   const doc = typeof document === "undefined" ? null : document;
   if (doc == null || typeof doc.querySelector !== "function") {
     state.canvas = null;
     state.width = fallbackWidth;
     state.height = fallbackHeight;
     state.dpr = 1;
     state.surfaceId = 1;
     return true;
   }
   const canvas = doc.querySelector(selector);
   if (canvas == null || typeof canvas.getContext !== "function") {
     return false;
   }
   const CanvasType = typeof HTMLCanvasElement === "undefined" ? null : HTMLCanvasElement;
   if (CanvasType != null && !(canvas instanceof CanvasType)) {
     return false;
   }
   const dpr = Number(root.devicePixelRatio ?? 1) || 1;
   const rect = typeof canvas.getBoundingClientRect === "function"
     ? canvas.getBoundingClientRect()
     : { width: fallbackWidth, height: fallbackHeight };
   const cssWidth = rect.width > 0 ? rect.width : fallbackWidth;
   const cssHeight = rect.height > 0 ? rect.height : fallbackHeight;
   const pixelWidth = Math.max(1, Math.round(cssWidth * dpr));
   const pixelHeight = Math.max(1, Math.round(cssHeight * dpr));
   if (canvas.width !== pixelWidth) {
     canvas.width = pixelWidth;
   }
   if (canvas.height !== pixelHeight) {
     canvas.height = pixelHeight;
   }
   if (canvas.__kaguraSurfaceId == null) {
     canvas.__kaguraSurfaceId = state.nextSurfaceId++;
   }
   if ((Number(canvas.tabIndex ?? -1) | 0) < 0) {
     canvas.tabIndex = 0;
   }
   state.canvas = canvas;
   state.surfaceId = Number(canvas.__kaguraSurfaceId) | 0;
   state.width = pixelWidth;
   state.height = pixelHeight;
   state.dpr = dpr;
   return true;
 };
const _M0FP26mizchi19web__runtime__hooks15js__surface__id = () => {
   const state = globalThis.__kaguraWebRuntime;
   return state == null ? 1 : (Number(state.surfaceId ?? 1) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks18js__surface__width = (fallbackWidth) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return fallbackWidth;
   return Math.max(1, Number(state.width ?? fallbackWidth) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks19js__surface__height = (fallbackHeight) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return fallbackHeight;
   return Math.max(1, Number(state.height ?? fallbackHeight) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks16js__surface__dpr = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return 1;
   return Number(state.dpr ?? 1) || 1;
 };
const _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state = (selector) => {
   const root = globalThis;
   const ensureState = root.__kaguraEnsureWindowState ?? (root.__kaguraEnsureWindowState = (nextSelector) => {
     const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {
       nextSurfaceId: 100,
       selector: "#app",
       canvas: null,
       surfaceId: 0,
       width: 1,
       height: 1,
       dpr: 1,
       shouldClose: false,
       fullscreen: false,
       cursorMode: 0,
       deviceScaleOverride: 0,
       vsyncEnabled: true,
       attentionRequests: 0,
       interactionHooksInstalled: false,
       webgpu: { context: null, device: null, format: "bgra8unorm", pending: null, _pipeline: null, _pipelineFormat: "", _configuredFormat: "", _uniformBGL: null, _texBGL: null, _defaultTexture: null, _defaultTexView: null, _defaultSampler: null, _drawResourceCache: null, _currentDraw: null, _pendingTexture: null, presentScheduled: false, clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "" },
     });
     if (typeof nextSelector === "string" && nextSelector.length > 0) {
       state.selector = nextSelector;
     }
     if (state.shouldClose == null) state.shouldClose = false;
     if (state.fullscreen == null) state.fullscreen = false;
     if (state.cursorMode == null) state.cursorMode = 0;
     if (state.deviceScaleOverride == null) state.deviceScaleOverride = 0;
     if (state.vsyncEnabled == null) state.vsyncEnabled = true;
     if (state.attentionRequests == null) state.attentionRequests = 0;
     if (typeof state.cursorX !== "number") state.cursorX = 0;
     if (typeof state.cursorY !== "number") state.cursorY = 0;
     if (typeof state.wheelX !== "number") state.wheelX = 0;
     if (typeof state.wheelY !== "number") state.wheelY = 0;
     if (!Array.isArray(state.pressedKeys)) state.pressedKeys = [];
     if (!Array.isArray(state.pressedMouseButtons)) state.pressedMouseButtons = [];
     if (!Array.isArray(state.touches)) state.touches = [];
     if (!Array.isArray(state.testGamepads)) state.testGamepads = [];
     if (state.inputHooksInstalled == null) state.inputHooksInstalled = false;
     if (state.webgpu == null) {
       state.webgpu = { context: null, device: null, format: "bgra8unorm", pending: null, _pipeline: null, _pipelineFormat: "", _configuredFormat: "", _uniformBGL: null, _texBGL: null, _defaultTexture: null, _defaultTexView: null, _defaultSampler: null, _drawResourceCache: null, _currentDraw: null, _pendingTexture: null, presentScheduled: false, clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "" };
     } else {
       if (!Array.isArray(state.webgpu.clear)) state.webgpu.clear = [0, 0, 0, 1];
       if (!Array.isArray(state.webgpu.commands)) state.webgpu.commands = [];
       if (state.webgpu._pipeline == null) state.webgpu._pipeline = null;
       if (typeof state.webgpu._pipelineFormat !== "string") state.webgpu._pipelineFormat = "";
       if (typeof state.webgpu._configuredFormat !== "string") state.webgpu._configuredFormat = "";
       if (state.webgpu._uniformBGL == null) state.webgpu._uniformBGL = null;
       if (state.webgpu._texBGL == null) state.webgpu._texBGL = null;
       if (state.webgpu._defaultTexture == null) state.webgpu._defaultTexture = null;
       if (state.webgpu._defaultTexView == null) state.webgpu._defaultTexView = null;
       if (state.webgpu._defaultSampler == null) state.webgpu._defaultSampler = null;
       if (state.webgpu._drawResourceCache == null) state.webgpu._drawResourceCache = null;
       if (state.webgpu._currentDraw == null) state.webgpu._currentDraw = null;
       if (state.webgpu._pendingTexture == null) state.webgpu._pendingTexture = null;
       if (state.webgpu.presentScheduled == null) state.webgpu.presentScheduled = false;
       if (state.webgpu.lastError == null) state.webgpu.lastError = "";
     }
     const doc = typeof document === "undefined" ? null : document;
     if (doc != null && typeof doc.querySelector === "function") {
       const canvas = doc.querySelector(state.selector);
       if (canvas != null) {
         state.canvas = canvas;
         const dpr = Number(root.devicePixelRatio ?? state.dpr ?? 1) || 1;
         state.dpr = dpr > 0 ? dpr : 1;
         state.fullscreen = doc.fullscreenElement === canvas;
         let mode = Number(state.cursorMode ?? 0) | 0;
         if (doc.pointerLockElement === canvas) {
           mode = 2;
         } else if (mode === 2) {
           mode = canvas.style != null && canvas.style.cursor === "none" ? 1 : 0;
         }
         if (mode !== 1 && mode !== 2) mode = 0;
         state.cursorMode = mode;
         if (canvas.style != null) {
           canvas.style.cursor = mode === 0 ? "" : "none";
         }
       }
       if (!state.interactionHooksInstalled && typeof doc.addEventListener === "function") {
         doc.addEventListener("fullscreenchange", () => {
           const current = root.__kaguraWebRuntime;
           if (current == null || current.canvas == null) return;
           current.fullscreen = doc.fullscreenElement === current.canvas;
         });
         doc.addEventListener("pointerlockchange", () => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           const canvas = current.canvas;
           let mode = Number(current.cursorMode ?? 0) | 0;
           if (canvas != null && doc.pointerLockElement === canvas) {
             mode = 2;
           } else if (mode === 2) {
             mode = canvas != null && canvas.style != null && canvas.style.cursor === "none" ? 1 : 0;
           }
           if (mode !== 1 && mode !== 2) mode = 0;
           current.cursorMode = mode;
           if (canvas != null && canvas.style != null) {
             canvas.style.cursor = mode === 0 ? "" : "none";
           }
         });
         const normalizeKeyCode = (event) => {
           if (event == null) return 0;
           const raw = Number(event.keyCode ?? event.which ?? 0) | 0;
           return raw > 0 ? raw : 0;
         };
         const eventTargetsCanvas = (current, event) => {
           const canvas = current?.canvas;
           const target = event?.target;
           if (canvas == null || target == null) return false;
           return target === canvas || (typeof canvas.contains === "function" && canvas.contains(target));
         };
         const focusCanvas = (current) => {
           const canvas = current?.canvas;
           if (canvas == null || typeof canvas.focus !== "function") return;
           if ((Number(canvas.tabIndex ?? -1) | 0) < 0) {
             canvas.tabIndex = 0;
           }
           try {
             canvas.focus({ preventScroll: true });
           } catch (_) {
             try { canvas.focus(); } catch (_focusError) {}
           }
         };
         const isCanvasFocused = (current, documentRef) => {
           return current?.canvas != null && documentRef?.activeElement === current.canvas;
         };
         const shouldPreventCanvasScroll = (current, documentRef, event) => {
           const key = normalizeKeyCode(event);
           return isCanvasFocused(current, documentRef) &&
             (key === 32 || key === 33 || key === 34 || key === 35 || key === 36 || key === 37 || key === 38 || key === 39 || key === 40);
         };
         const addPressedKey = (current, key) => {
           if (key <= 0) return;
           if (!Array.isArray(current.pressedKeys)) current.pressedKeys = [];
           for (let i = 0; i < current.pressedKeys.length; i++) {
             if ((Number(current.pressedKeys[i]) | 0) === key) return;
           }
           current.pressedKeys.push(key);
         };
         const removePressedKey = (current, key) => {
           if (key <= 0) return;
           if (!Array.isArray(current.pressedKeys)) {
             current.pressedKeys = [];
             return;
           }
           const next = [];
           for (let i = 0; i < current.pressedKeys.length; i++) {
             const value = Number(current.pressedKeys[i]) | 0;
             if (value !== key) next.push(value);
           }
           current.pressedKeys = next;
         };
         const normalizeMouseButton = (event) => {
           if (event == null) return -1;
           const raw = Number(event.button ?? -1) | 0;
           return raw >= 0 ? raw : -1;
         };
         const addPressedMouseButton = (current, button) => {
           if (button < 0) return;
           if (!Array.isArray(current.pressedMouseButtons)) current.pressedMouseButtons = [];
           for (let i = 0; i < current.pressedMouseButtons.length; i++) {
             if ((Number(current.pressedMouseButtons[i]) | 0) === button) return;
           }
           current.pressedMouseButtons.push(button);
         };
         const removePressedMouseButton = (current, button) => {
           if (button < 0) return;
           if (!Array.isArray(current.pressedMouseButtons)) {
             current.pressedMouseButtons = [];
             return;
           }
           const next = [];
           for (let i = 0; i < current.pressedMouseButtons.length; i++) {
             const value = Number(current.pressedMouseButtons[i]) | 0;
             if (value !== button) next.push(value);
           }
           current.pressedMouseButtons = next;
         };
         const syncTouches = (current, event) => {
           if (current == null) return;
           const list = event?.touches;
           if (list == null || typeof list.length !== "number") {
             current.touches = [];
             return;
           }
           const next = [];
           for (let i = 0; i < list.length; i++) {
             const touch = list[i];
             if (touch == null) continue;
             let x = Number(touch.clientX ?? 0);
             let y = Number(touch.clientY ?? 0);
             if (current.canvas != null && typeof current.canvas.getBoundingClientRect === "function") {
               const rect = current.canvas.getBoundingClientRect();
               x = x - Number(rect.left ?? 0);
               y = y - Number(rect.top ?? 0);
             }
             next.push({
               id: Number(touch.identifier ?? 0) | 0,
               x: Number.isFinite(x) ? x : 0,
               y: Number.isFinite(y) ? y : 0,
             });
           }
           current.touches = next;
         };
         const updateCursor = (current, event) => {
           if (current == null || event == null) return;
           let x = Number(event.clientX ?? 0);
           let y = Number(event.clientY ?? 0);
           if (current.canvas != null && typeof current.canvas.getBoundingClientRect === "function") {
             const rect = current.canvas.getBoundingClientRect();
             x = x - Number(rect.left ?? 0);
             y = y - Number(rect.top ?? 0);
           }
           current.cursorX = Number.isFinite(x) ? x : 0;
           current.cursorY = Number.isFinite(y) ? y : 0;
         };
         doc.addEventListener("mousemove", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           updateCursor(current, event);
         });
         doc.addEventListener("mousedown", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           if (eventTargetsCanvas(current, event)) {
             focusCanvas(current);
           }
           updateCursor(current, event);
           addPressedMouseButton(current, normalizeMouseButton(event));
         });
         doc.addEventListener("mouseup", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           updateCursor(current, event);
           removePressedMouseButton(current, normalizeMouseButton(event));
         });
         doc.addEventListener("wheel", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           const dx = Number(event?.deltaX ?? 0);
           const dy = Number(event?.deltaY ?? 0);
           current.wheelX = Number(current.wheelX ?? 0) + (Number.isFinite(dx) ? dx : 0);
           current.wheelY = Number(current.wheelY ?? 0) + (Number.isFinite(dy) ? dy : 0);
         }, { passive: true });
         doc.addEventListener("touchstart", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           if (eventTargetsCanvas(current, event)) {
             focusCanvas(current);
           }
           syncTouches(current, event);
         }, { passive: true });
         doc.addEventListener("touchmove", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           syncTouches(current, event);
         }, { passive: true });
         doc.addEventListener("touchend", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           syncTouches(current, event);
         }, { passive: true });
         doc.addEventListener("touchcancel", (event) => {
           const current = root.__kaguraWebRuntime;
           if (current == null) return;
           syncTouches(current, event);
         }, { passive: true });
         const targetWindow = typeof window === "undefined" ? null : window;
         if (targetWindow != null && typeof targetWindow.addEventListener === "function") {
           targetWindow.addEventListener("keydown", (event) => {
             const current = root.__kaguraWebRuntime;
             if (current == null) return;
             if (shouldPreventCanvasScroll(current, doc, event) && typeof event.preventDefault === "function") {
               event.preventDefault();
             }
             addPressedKey(current, normalizeKeyCode(event));
           });
           targetWindow.addEventListener("keyup", (event) => {
             const current = root.__kaguraWebRuntime;
             if (current == null) return;
             removePressedKey(current, normalizeKeyCode(event));
           });
           targetWindow.addEventListener("blur", () => {
             const current = root.__kaguraWebRuntime;
             if (current == null) return;
             current.pressedKeys = [];
             current.pressedMouseButtons = [];
             current.touches = [];
             current.wheelX = 0;
             current.wheelY = 0;
           });
         }
         state.interactionHooksInstalled = true;
         state.inputHooksInstalled = true;
       }
     }
     return state;
   });
   ensureState(selector);
 };
const _M0FP26mizchi19web__runtime__hooks22js__set__should__close = (value) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState("#app");
   }
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   state.shouldClose = !!value;
 };
const _M0FP26mizchi19web__runtime__hooks24js__should__close__state = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return false;
   return !!state.shouldClose;
 };
const _M0FP26mizchi19web__runtime__hooks19js__set__fullscreen = (selector, enabled) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState(selector);
   }
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   const doc = typeof document === "undefined" ? null : document;
   if (doc == null || typeof doc.querySelector !== "function") {
     state.fullscreen = !!enabled;
     return !!state.fullscreen;
   }
   const target = doc.querySelector(selector);
   if (target == null) {
     state.fullscreen = !!enabled;
     return !!state.fullscreen;
   }
   if (enabled) {
     if (doc.fullscreenElement === target) {
       state.fullscreen = true;
       return true;
     }
     if (typeof target.requestFullscreen === "function") {
       Promise.resolve(target.requestFullscreen()).catch(() => {
         const current = root.__kaguraWebRuntime;
         if (current != null) current.fullscreen = doc.fullscreenElement === target;
       });
       state.fullscreen = true;
       return true;
     }
     state.fullscreen = doc.fullscreenElement === target;
     return !!state.fullscreen;
   }
   if (doc.fullscreenElement != null && typeof doc.exitFullscreen === "function") {
     Promise.resolve(doc.exitFullscreen()).catch(() => {
       const current = root.__kaguraWebRuntime;
       if (current != null) current.fullscreen = doc.fullscreenElement === target;
     });
   }
   state.fullscreen = false;
   return false;
 };
const _M0FP26mizchi19web__runtime__hooks18js__is__fullscreen = (selector, fallback) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState(selector);
   }
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   const doc = typeof document === "undefined" ? null : document;
   if (doc == null || typeof doc.querySelector !== "function") {
     if (state.fullscreen == null) state.fullscreen = !!fallback;
     return !!state.fullscreen;
   }
   const target = doc.querySelector(selector);
   if (target == null) {
     if (state.fullscreen == null) state.fullscreen = !!fallback;
     return !!state.fullscreen;
   }
   state.fullscreen = doc.fullscreenElement === target;
   return !!state.fullscreen;
 };
const _M0FP26mizchi19web__runtime__hooks21js__set__cursor__mode = (selector, mode) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState(selector);
   }
   const doc = typeof document === "undefined" ? null : document;
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   let nextMode = Number(mode) | 0;
   if (nextMode !== 1 && nextMode !== 2) nextMode = 0;
   if (doc != null && typeof doc.querySelector === "function") {
     const canvas = doc.querySelector(selector);
     if (canvas != null) {
       if (nextMode === 0) {
         if (canvas.style != null) canvas.style.cursor = "";
         if (doc.pointerLockElement === canvas && typeof doc.exitPointerLock === "function") {
           doc.exitPointerLock();
         }
       } else if (nextMode === 1) {
         if (canvas.style != null) canvas.style.cursor = "none";
       } else {
         if (canvas.style != null) canvas.style.cursor = "none";
         if (doc.pointerLockElement !== canvas && typeof canvas.requestPointerLock === "function") {
           try {
             canvas.requestPointerLock();
           } catch (_) {}
         }
       }
     }
   }
   state.cursorMode = nextMode;
   return nextMode;
 };
const _M0FP26mizchi19web__runtime__hooks16js__cursor__mode = (selector, fallback) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState(selector);
   }
   const state = root.__kaguraWebRuntime;
   const doc = typeof document === "undefined" ? null : document;
   if (doc != null && typeof doc.querySelector === "function") {
     const canvas = doc.querySelector(selector);
     if (canvas != null && doc.pointerLockElement === canvas) {
       state.cursorMode = 2;
       return 2;
     }
     if (canvas != null && Number(state?.cursorMode ?? fallback) === 2) {
       state.cursorMode = canvas.style != null && canvas.style.cursor === "none" ? 1 : 0;
     }
   }
   if (state == null) return (Number(fallback) | 0);
   const mode = Number(state.cursorMode ?? fallback) | 0;
   if (mode !== 1 && mode !== 2) return 0;
   return mode;
 };
const _M0FP26mizchi19web__runtime__hooks30js__set__device__scale__factor = (scale) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState("#app");
   }
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   const normalized = Number(scale) > 0 ? Number(scale) : 1;
   state.deviceScaleOverride = normalized;
   return normalized;
 };
const _M0FP26mizchi19web__runtime__hooks25js__device__scale__factor = (fallback) => {
   const state = globalThis.__kaguraWebRuntime;
   const safeFallback = Number(fallback) > 0 ? Number(fallback) : 1;
   if (state == null) return safeFallback;
   const override = Number(state.deviceScaleOverride ?? 0);
   if (override > 0) return override;
   const dpr = Number(state.dpr ?? safeFallback);
   return dpr > 0 ? dpr : safeFallback;
 };
const _M0FP26mizchi19web__runtime__hooks23js__set__vsync__enabled = (enabled) => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState("#app");
   }
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   state.vsyncEnabled = !!enabled;
   return !!enabled;
 };
const _M0FP26mizchi19web__runtime__hooks22js__is__vsync__enabled = (fallback) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || state.vsyncEnabled == null) return !!fallback;
   return !!state.vsyncEnabled;
 };
const _M0FP26mizchi19web__runtime__hooks20js__input__cursor__x = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return 0;
   return Number(state.cursorX ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks20js__input__cursor__y = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return 0;
   return Number(state.cursorY ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks19js__input__wheel__x = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return 0;
   return Number(state.wheelX ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks19js__input__wheel__y = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return 0;
   return Number(state.wheelY ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks23js__clear__input__wheel = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   state.wheelX = 0;
   state.wheelY = 0;
 };
const _M0FP26mizchi19web__runtime__hooks30js__input__pressed__key__count = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.pressedKeys)) return 0;
   return Math.max(0, Number(state.pressedKeys.length) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks27js__input__pressed__key__at = (index) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.pressedKeys)) return 0;
   const i = Number(index) | 0;
   if (i < 0 || i >= state.pressedKeys.length) return 0;
   return Number(state.pressedKeys[i] ?? 0) | 0;
 };
const _M0FP26mizchi19web__runtime__hooks40js__input__pressed__mouse__button__count = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.pressedMouseButtons)) return 0;
   return Math.max(0, Number(state.pressedMouseButtons.length) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks37js__input__pressed__mouse__button__at = (index) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.pressedMouseButtons)) return -1;
   const i = Number(index) | 0;
   if (i < 0 || i >= state.pressedMouseButtons.length) return -1;
   return Number(state.pressedMouseButtons[i] ?? -1) | 0;
 };
const _M0FP26mizchi19web__runtime__hooks23js__input__touch__count = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.touches)) return 0;
   return Math.max(0, Number(state.touches.length) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks24js__input__touch__id__at = (index) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.touches)) return 0;
   const i = Number(index) | 0;
   if (i < 0 || i >= state.touches.length) return 0;
   const touch = state.touches[i];
   return Number(touch?.id ?? 0) | 0;
 };
const _M0FP26mizchi19web__runtime__hooks23js__input__touch__x__at = (index) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.touches)) return 0;
   const i = Number(index) | 0;
   if (i < 0 || i >= state.touches.length) return 0;
   const touch = state.touches[i];
   return Number(touch?.x ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks23js__input__touch__y__at = (index) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null || !Array.isArray(state.touches)) return 0;
   const i = Number(index) | 0;
   if (i < 0 || i >= state.touches.length) return 0;
   const touch = state.touches[i];
   return Number(touch?.y ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks25js__input__gamepad__count = () => {
   const root = globalThis;
   const state = root.__kaguraWebRuntime;
   if (state != null && Array.isArray(state.testGamepads) && state.testGamepads.length > 0) {
     return Math.max(0, Number(state.testGamepads.length) | 0);
   }
   const nav = root.navigator;
   if (nav == null || typeof nav.getGamepads !== "function") return 0;
   const pads = nav.getGamepads();
   if (pads == null || typeof pads.length !== "number") return 0;
   let count = 0;
   for (let i = 0; i < pads.length; i++) {
     if (pads[i] != null) count++;
   }
   return count | 0;
 };
const _M0FP26mizchi19web__runtime__hooks26js__input__gamepad__id__at = (index) => {
   const root = globalThis;
   const i = Number(index) | 0;
   if (i < 0) return -1;
   const state = root.__kaguraWebRuntime;
   const testPads = state != null && Array.isArray(state.testGamepads) ? state.testGamepads : null;
   if (testPads != null && testPads.length > 0) {
     if (i >= testPads.length || testPads[i] == null) return -1;
     return Number(testPads[i].id ?? i) | 0;
   }
   const nav = root.navigator;
   if (nav == null || typeof nav.getGamepads !== "function") return -1;
   const pads = nav.getGamepads();
   if (pads == null || typeof pads.length !== "number") return -1;
   let found = 0;
   for (let padIndex = 0; padIndex < pads.length; padIndex++) {
     const pad = pads[padIndex];
     if (pad == null) continue;
     if (found === i) {
       return Number(pad.index ?? padIndex) | 0;
     }
     found++;
   }
   return -1;
 };
const _M0FP26mizchi19web__runtime__hooks42js__input__gamepad__pressed__button__count = (gamepadIndex) => {
   const root = globalThis;
   const gpIndex = Number(gamepadIndex) | 0;
   if (gpIndex < 0) return 0;
   const state = root.__kaguraWebRuntime;
   const testPads = state != null && Array.isArray(state.testGamepads) ? state.testGamepads : null;
   const target = testPads != null && testPads.length > 0 ? testPads[gpIndex] : null;
   if (target != null && Array.isArray(target.pressedButtons)) {
     return Math.max(0, Number(target.pressedButtons.length) | 0);
   }
   const nav = root.navigator;
   if (nav == null || typeof nav.getGamepads !== "function") return 0;
   const pads = nav.getGamepads();
   if (pads == null) return 0;
   let found = 0;
   let pad = null;
   for (let i = 0; i < pads.length; i++) {
     if (pads[i] == null) continue;
     if (found === gpIndex) {
       pad = pads[i];
       break;
     }
     found++;
   }
   if (pad == null || !Array.isArray(pad.buttons)) return 0;
   let count = 0;
   for (let i = 0; i < pad.buttons.length; i++) {
     const button = pad.buttons[i];
     if (button != null && !!button.pressed) count++;
   }
   return count | 0;
 };
const _M0FP26mizchi19web__runtime__hooks39js__input__gamepad__pressed__button__at = (gamepadIndex, buttonIndex) => {
   const root = globalThis;
   const gpIndex = Number(gamepadIndex) | 0;
   const btnIndex = Number(buttonIndex) | 0;
   if (gpIndex < 0 || btnIndex < 0) return -1;
   const state = root.__kaguraWebRuntime;
   const testPads = state != null && Array.isArray(state.testGamepads) ? state.testGamepads : null;
   const target = testPads != null && testPads.length > 0 ? testPads[gpIndex] : null;
   if (target != null && Array.isArray(target.pressedButtons)) {
     if (btnIndex >= target.pressedButtons.length) return -1;
     return Number(target.pressedButtons[btnIndex] ?? -1) | 0;
   }
   const nav = root.navigator;
   if (nav == null || typeof nav.getGamepads !== "function") return -1;
   const pads = nav.getGamepads();
   if (pads == null) return -1;
   let foundPad = null;
   let found = 0;
   for (let i = 0; i < pads.length; i++) {
     if (pads[i] == null) continue;
     if (found === gpIndex) {
       foundPad = pads[i];
       break;
     }
     found++;
   }
   const pad = foundPad;
   if (pad == null || !Array.isArray(pad.buttons)) return -1;
   let pressedFound = 0;
   for (let i = 0; i < pad.buttons.length; i++) {
     const button = pad.buttons[i];
     if (button != null && !!button.pressed) {
       if (pressedFound === btnIndex) return i;
       pressedFound++;
     }
   }
   return -1;
 };
const _M0FP26mizchi19web__runtime__hooks31js__input__gamepad__axis__count = (gamepadIndex) => {
   const root = globalThis;
   const gpIndex = Number(gamepadIndex) | 0;
   if (gpIndex < 0) return 0;
   const state = root.__kaguraWebRuntime;
   const testPads = state != null && Array.isArray(state.testGamepads) ? state.testGamepads : null;
   const target = testPads != null && testPads.length > 0 ? testPads[gpIndex] : null;
   if (target != null && Array.isArray(target.axes)) {
     return Math.max(0, Number(target.axes.length) | 0);
   }
   const nav = root.navigator;
   if (nav == null || typeof nav.getGamepads !== "function") return 0;
   const pads = nav.getGamepads();
   if (pads == null) return 0;
   let found = 0;
   let pad = null;
   for (let i = 0; i < pads.length; i++) {
     if (pads[i] == null) continue;
     if (found === gpIndex) {
       pad = pads[i];
       break;
     }
     found++;
   }
   if (pad == null || !Array.isArray(pad.axes)) return 0;
   return Math.max(0, Number(pad.axes.length) | 0);
 };
const _M0FP26mizchi19web__runtime__hooks28js__input__gamepad__axis__at = (gamepadIndex, axisIndex) => {
   const root = globalThis;
   const gpIndex = Number(gamepadIndex) | 0;
   const axIndex = Number(axisIndex) | 0;
   if (gpIndex < 0 || axIndex < 0) return 0;
   const state = root.__kaguraWebRuntime;
   const testPads = state != null && Array.isArray(state.testGamepads) ? state.testGamepads : null;
   const target = testPads != null && testPads.length > 0 ? testPads[gpIndex] : null;
   if (target != null && Array.isArray(target.axes)) {
     if (axIndex >= target.axes.length) return 0;
     return Number(target.axes[axIndex] ?? 0) || 0;
   }
   const nav = root.navigator;
   if (nav == null || typeof nav.getGamepads !== "function") return 0;
   const pads = nav.getGamepads();
   if (pads == null) return 0;
   let found = 0;
   let pad = null;
   for (let i = 0; i < pads.length; i++) {
     if (pads[i] == null) continue;
     if (found === gpIndex) {
       pad = pads[i];
       break;
     }
     found++;
   }
   if (pad == null || !Array.isArray(pad.axes)) return 0;
   if (axIndex >= pad.axes.length) return 0;
   return Number(pad.axes[axIndex] ?? 0) || 0;
 };
const _M0FP26mizchi19web__runtime__hooks22js__request__attention = () => {
   const root = globalThis;
   if (typeof root.__kaguraEnsureWindowState === "function") {
     root.__kaguraEnsureWindowState("#app");
   }
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
   state.attentionRequests = (Number(state.attentionRequests ?? 0) | 0) + 1;
   const doc = typeof document === "undefined" ? null : document;
   if (doc != null && typeof doc.hasFocus === "function" && !doc.hasFocus()) {
     const title = typeof doc.title === "string" ? doc.title : "";
     if (title.length > 0 && !title.startsWith("(*) ")) {
       doc.title = "(*) " + title;
     }
   }
 };
const _M0FP26mizchi19web__runtime__hooks27js__try__initialize__webgpu = (selector, fallbackWidth, fallbackHeight) => {
   const root = globalThis;
   const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {
     nextSurfaceId: 100,
     selector: "#app",
     canvas: null,
     surfaceId: 0,
     width: fallbackWidth,
     height: fallbackHeight,
     dpr: 1,
     webgpu: { context: null, device: null, format: "bgra8unorm", pending: null, _pipeline: null, _pipelineFormat: "", _configuredFormat: "", _uniformBGL: null, _texBGL: null, _defaultTexture: null, _defaultTexView: null, _defaultSampler: null, _drawResourceCache: null, _currentDraw: null, _pendingTexture: null, presentScheduled: false, clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "" },
   });
   state.selector = selector;
   const doc = typeof document === "undefined" ? null : document;
   if (doc != null && typeof doc.querySelector === "function") {
     const canvas = doc.querySelector(selector);
     if (canvas == null || typeof canvas.getContext !== "function") return false;
     const CanvasType = typeof HTMLCanvasElement === "undefined" ? null : HTMLCanvasElement;
     if (CanvasType != null && !(canvas instanceof CanvasType)) return false;
     const dpr = Number(root.devicePixelRatio ?? 1) || 1;
     const rect = typeof canvas.getBoundingClientRect === "function"
       ? canvas.getBoundingClientRect()
       : { width: fallbackWidth, height: fallbackHeight };
     const cssWidth = rect.width > 0 ? rect.width : fallbackWidth;
     const cssHeight = rect.height > 0 ? rect.height : fallbackHeight;
     const pixelWidth = Math.max(1, Math.round(cssWidth * dpr));
     const pixelHeight = Math.max(1, Math.round(cssHeight * dpr));
     if (canvas.width !== pixelWidth) canvas.width = pixelWidth;
     if (canvas.height !== pixelHeight) canvas.height = pixelHeight;
     if (canvas.__kaguraSurfaceId == null) {
       canvas.__kaguraSurfaceId = state.nextSurfaceId++;
     }
     state.canvas = canvas;
     state.surfaceId = Number(canvas.__kaguraSurfaceId) | 0;
     state.width = pixelWidth;
     state.height = pixelHeight;
     state.dpr = dpr;
   } else {
     state.canvas = null;
     state.surfaceId = 1;
     state.width = fallbackWidth;
     state.height = fallbackHeight;
     state.dpr = 1;
   }
   if (state == null || state.canvas == null) {
     return true;
   }
   const nav = typeof navigator === "undefined" ? null : navigator;
   if (nav == null || nav.gpu == null) {
     return false;
   }
   const context = state.canvas.getContext("webgpu");
   if (context == null) {
     return false;
   }
   state.webgpu.context = context;
   if (state.webgpu.device != null) {
     return true;
   }
   if (state.webgpu.pending == null) {
     state.webgpu.pending = nav.gpu.requestAdapter()
       .then((adapter) => {
         if (adapter == null) return null;
         const supportsTimestampQuery = adapter.features != null &&
           typeof adapter.features.has === "function" &&
           adapter.features.has("timestamp-query");
         const requestOptions = supportsTimestampQuery
           ? { requiredFeatures: ["timestamp-query"] }
           : undefined;
         return adapter.requestDevice(requestOptions).then((device) => {
           if (device != null) {
             device.__kaguraTimestampQueryEnabled = supportsTimestampQuery;
           }
           return device;
         });
       })
       .then((device) => {
         if (device == null) return;
         const format = typeof nav.gpu.getPreferredCanvasFormat === "function"
           ? nav.gpu.getPreferredCanvasFormat()
           : "bgra8unorm";
         state.webgpu.format = format;
         state.webgpu.device = device;
         state.webgpu._pipeline = null;
         state.webgpu._pipelineFormat = "";
         state.webgpu._configuredFormat = "";
         if (state.webgpu.context != null) {
           state.webgpu.context.configure({
             device,
             format,
             alphaMode: "opaque",
           });
           state.webgpu._configuredFormat = format;
         }
       })
       .catch((error) => {
         state.webgpu.lastError = String(error);
         state.webgpu.device = null;
         state.webgpu._pipeline = null;
         state.webgpu._pipelineFormat = "";
         state.webgpu._configuredFormat = "";
       })
       .finally(() => {
         state.webgpu.pending = null;
       });
   }
   return false;
 };
const _M0FP26mizchi19web__runtime__hooks30js__release__webgpu__resources = () => {
   const state = globalThis.__kaguraWebRuntime;
   const gpu = state == null ? null : state.webgpu;
   if (gpu == null) return;
   const gfx = globalThis.__kaguraGfx;
   if (gfx != null) { gfx.release(gpu); gpu.presentScheduled = false; return; }
   const releaseBufferEntries = (entries) => {
     if (!Array.isArray(entries)) return;
     for (let i = 0; i < entries.length; i += 1) {
       const entry = entries[i];
       const buffer = entry == null ? null : entry.buffer;
       if (buffer != null && typeof buffer.destroy === "function") {
         try { buffer.destroy(); } catch (_) {}
       }
     }
   };
   const cache = gpu._drawResourceCache;
   if (cache != null) {
     releaseBufferEntries(cache.vertexBuffers);
     releaseBufferEntries(cache.indexBuffers);
     releaseBufferEntries(cache.uniformBuffers);
   }
   const textures = gpu.textures;
   if (textures != null && typeof textures.values === "function") {
     for (const entry of textures.values()) {
       const texture = entry == null ? null : entry.texture;
       if (texture != null && typeof texture.destroy === "function") {
         try { texture.destroy(); } catch (_) {}
       }
     }
   }
   if (textures != null && typeof textures.clear === "function") {
     textures.clear();
   }
   if (gpu._defaultTexture != null && typeof gpu._defaultTexture.destroy === "function") {
     try { gpu._defaultTexture.destroy(); } catch (_) {}
   }
   if (gpu.context != null && typeof gpu.context.unconfigure === "function") {
     try { gpu.context.unconfigure(); } catch (_) {}
   }
   gpu._pipeline = null;
   gpu._pipelineFormat = "";
   gpu._configuredFormat = "";
   gpu._uniformBGL = null;
   gpu._texBGL = null;
   gpu._defaultTexture = null;
   gpu._defaultTexView = null;
   gpu._defaultSampler = null;
   gpu._drawResourceCache = null;
   gpu._pendingTexture = null;
   gpu._currentDraw = null;
   gpu.commands = [];
   gpu.textures = new Map();
   gpu.presentScheduled = false;
 };
const _M0FP26mizchi19web__runtime__hooks17js__webgpu__begin = (r, g, b, a) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null) return;
   gpu.clear = [r, g, b, a];
   gpu.commands = [];
   gpu._currentDraw = null;
 };
const _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__begin = (vertexCount, indexCount, srcImageId, uniformR, uniformG, uniformB, uniformA, dstId, dstW, dstH) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null) return;
   gpu._currentDraw = {
     vertexData: new Float32Array((vertexCount | 0) * 4),
     indices: new Uint32Array(indexCount | 0),
     srcImageId: srcImageId | 0,
     uniformR: (uniformR & 0xff) / 255.0,
     uniformG: (uniformG & 0xff) / 255.0,
     uniformB: (uniformB & 0xff) / 255.0,
     uniformA: (uniformA & 0xff) / 255.0,
     dstImageId: dstId | 0,
     dstWidth: Math.max(1, dstW | 0),
     dstHeight: Math.max(1, dstH | 0),
   };
 };
const _M0FP26mizchi19web__runtime__hooks21js__gfx__draw__vertex = (offset, x, y, u, v) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._currentDraw == null) return;
   const base = (offset | 0) * 4;
   gpu._currentDraw.vertexData[base] = x;
   gpu._currentDraw.vertexData[base + 1] = y;
   gpu._currentDraw.vertexData[base + 2] = u;
   gpu._currentDraw.vertexData[base + 3] = v;
 };
const _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index = (offset, value) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._currentDraw == null) return;
   gpu._currentDraw.indices[offset | 0] = value | 0;
 };
const _M0FP26mizchi19web__runtime__hooks18js__gfx__draw__end = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._currentDraw == null) return;
   if (!Array.isArray(gpu.commands)) gpu.commands = [];
   gpu.commands.push(gpu._currentDraw);
   gpu._currentDraw = null;
 };
const _M0FP26mizchi19web__runtime__hooks28js__gfx__custom__draw__begin = (shaderId, shaderSource, vfCount, iCount, uCount, srcCount, dstId, dstW, dstH, blendMode, instanceCount) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null) return;
   gpu._currentDraw = {
     isCustom: true,
     shaderId: shaderId | 0,
     shaderSource: shaderSource,
     vertexData: new Float32Array(vfCount | 0),
     indices: new Uint32Array(iCount | 0),
     uniformDwords: new Int32Array(uCount | 0),
     srcImageIds: new Int32Array(srcCount | 0),
     dstImageId: dstId | 0,
     dstWidth: Math.max(1, dstW | 0),
     dstHeight: Math.max(1, dstH | 0),
     blendMode: blendMode | 0,
     instanceCount: instanceCount | 0,
   };
 };
const _M0FP26mizchi19web__runtime__hooks36js__gfx__custom__draw__vertex__float = (index, value) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._currentDraw == null) return;
   gpu._currentDraw.vertexData[index | 0] = value;
 };
const _M0FP26mizchi19web__runtime__hooks30js__gfx__custom__draw__uniform = (index, value) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._currentDraw == null) return;
   gpu._currentDraw.uniformDwords[index | 0] = value | 0;
 };
const _M0FP26mizchi19web__runtime__hooks33js__gfx__custom__draw__src__image = (index, imageId) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._currentDraw == null) return;
   gpu._currentDraw.srcImageIds[index | 0] = imageId | 0;
 };
const _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__begin = (imageId, width, height) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null) return;
   gpu._pendingTexture = {
     imageId: imageId | 0,
     width: Math.max(1, width | 0),
     height: Math.max(1, height | 0),
     pixels: new Uint8Array(Math.max(1, width | 0) * Math.max(1, height | 0) * 4),
   };
 };
const _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__pixel = (offset, r, g, b, a) => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._pendingTexture == null) return;
   const base = (offset | 0) * 4;
   gpu._pendingTexture.pixels[base] = r & 0xff;
   gpu._pendingTexture.pixels[base + 1] = g & 0xff;
   gpu._pendingTexture.pixels[base + 2] = b & 0xff;
   gpu._pendingTexture.pixels[base + 3] = a & 0xff;
 };
const _M0FP26mizchi19web__runtime__hooks29js__gfx__upload__texture__end = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return;
   const gpu = state.webgpu;
   if (gpu == null || gpu._pendingTexture == null || gpu.device == null) return;
   const gfx = globalThis.__kaguraGfx;
   if (gfx != null) { gfx.finalizeTexture(gpu); return; }
   const { imageId, width, height, pixels } = gpu._pendingTexture;
   gpu._pendingTexture = null;
   if (width <= 0 || height <= 0) return;
   if (gpu.textures == null) gpu.textures = new Map();
   const existing = gpu.textures.get(imageId);
   if (existing != null && (existing.width !== width || existing.height !== height)) {
     if (existing.texture != null && typeof existing.texture.destroy === "function") {
       existing.texture.destroy();
     }
     gpu.textures.delete(imageId);
   }
   let entry = gpu.textures.get(imageId);
   if (entry == null) {
     const nextRevision = existing != null && Number.isFinite(existing.revision)
       ? ((existing.revision | 0) + 1)
       : 1;
     const texture = gpu.device.createTexture({
       size: { width, height },
       format: "rgba8unorm",
       usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST,
     });
     const view = texture.createView();
     const sampler = gpu.device.createSampler({
       magFilter: "nearest",
       minFilter: "nearest",
       addressModeU: "clamp-to-edge",
       addressModeV: "clamp-to-edge",
     });
     entry = { texture, view, sampler, width, height, revision: nextRevision };
     gpu.textures.set(imageId, entry);
   } else if (!Number.isFinite(entry.revision)) {
     entry.revision = 1;
   }
   gpu.device.queue.writeTexture(
     { texture: entry.texture },
     pixels,
     { bytesPerRow: width * 4 },
     { width, height },
   );
 };
const _M0FP26mizchi19web__runtime__hooks19js__webgpu__present = () => {
   const state = globalThis.__kaguraWebRuntime;
   if (state == null) return false;
   const gpu = state.webgpu;
   const device = gpu == null ? null : gpu.device;
   const context = gpu == null ? null : gpu.context;
   if (gpu == null || device == null || context == null) return false;
   const presentNow = (currentState) => {
     const canvas = currentState.canvas;
     if (canvas != null && typeof canvas.getBoundingClientRect === "function") {
       const dpr = Number(globalThis.devicePixelRatio ?? 1) || 1;
       const rect = canvas.getBoundingClientRect();
       const cssWidth = rect.width > 0 ? rect.width : currentState.width;
       const cssHeight = rect.height > 0 ? rect.height : currentState.height;
       const pixelWidth = Math.max(1, Math.round(cssWidth * dpr));
       const pixelHeight = Math.max(1, Math.round(cssHeight * dpr));
       if (canvas.width !== pixelWidth) canvas.width = pixelWidth;
       if (canvas.height !== pixelHeight) canvas.height = pixelHeight;
       currentState.width = pixelWidth;
       currentState.height = pixelHeight;
       currentState.dpr = dpr;
     }
     const currentGpu = currentState.webgpu;
     const currentDevice = currentGpu == null ? null : currentGpu.device;
     const currentContext = currentGpu == null ? null : currentGpu.context;
     if (currentGpu == null || currentDevice == null || currentContext == null) return false;
     const format = typeof currentGpu.format === "string" ? currentGpu.format : "bgra8unorm";
     const gfx = globalThis.__kaguraGfx;
     if (gfx != null) {
       return gfx.render(currentGpu, currentDevice, currentContext, currentGpu.clear, format);
     }
     if (currentGpu._configuredFormat !== format) {
       currentContext.configure({ device: currentDevice, format, alphaMode: "opaque" });
       currentGpu._configuredFormat = format;
     }
     if (currentGpu._pipeline == null || currentGpu._pipelineFormat !== format) {
       const shaderCode = `
 struct Uniforms { color: vec4f }
 @group(0) @binding(0) var<uniform> uniforms: Uniforms;
 @group(1) @binding(0) var tex: texture_2d<f32>;
 @group(1) @binding(1) var tex_sampler: sampler;
 struct VertexOutput {
   @builtin(position) position: vec4f,
   @location(0) uv: vec2f,
 }
 @vertex fn vs_main(@location(0) pos: vec2f, @location(1) uv: vec2f) -> VertexOutput {
   var out: VertexOutput;
   out.position = vec4f(pos, 0.0, 1.0);
   out.uv = uv;
   return out;
 }
 @fragment fn fs_main(input: VertexOutput) -> @location(0) vec4f {
   let tex_color = textureSample(tex, tex_sampler, input.uv);
   return tex_color * uniforms.color;
 }`;
       const shaderModule = currentDevice.createShaderModule({ code: shaderCode });
       const texBGL = currentDevice.createBindGroupLayout({
         entries: [
           { binding: 0, visibility: GPUShaderStage.FRAGMENT, texture: { sampleType: "float" } },
           { binding: 1, visibility: GPUShaderStage.FRAGMENT, sampler: {} },
         ],
       });
       const uniformBGL = currentDevice.createBindGroupLayout({
         entries: [
           { binding: 0, visibility: GPUShaderStage.FRAGMENT | GPUShaderStage.VERTEX, buffer: { type: "uniform" } },
         ],
       });
       const pipelineLayout = currentDevice.createPipelineLayout({ bindGroupLayouts: [uniformBGL, texBGL] });
       currentGpu._pipeline = currentDevice.createRenderPipeline({
         layout: pipelineLayout,
         vertex: {
           module: shaderModule,
           entryPoint: "vs_main",
           buffers: [{
             arrayStride: 16,
             attributes: [
               { shaderLocation: 0, offset: 0, format: "float32x2" },
               { shaderLocation: 1, offset: 8, format: "float32x2" },
             ],
           }],
         },
         fragment: {
           module: shaderModule,
           entryPoint: "fs_main",
           targets: [{
             format,
             blend: {
               color: { srcFactor: "src-alpha", dstFactor: "one-minus-src-alpha", operation: "add" },
               alpha: { srcFactor: "one", dstFactor: "one-minus-src-alpha", operation: "add" },
             },
           }],
         },
         primitive: { topology: "triangle-list", cullMode: "none" },
       });
       currentGpu._pipelineFormat = format;
       currentGpu._uniformBGL = uniformBGL;
       currentGpu._texBGL = texBGL;
       currentGpu._drawResourceCache = null;
       const defaultTex = currentDevice.createTexture({
         size: { width: 1, height: 1 },
         format: "rgba8unorm",
         usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST,
       });
       currentDevice.queue.writeTexture(
         { texture: defaultTex },
         new Uint8Array([255, 255, 255, 255]),
         { bytesPerRow: 4 },
         { width: 1, height: 1 },
       );
       currentGpu._defaultTexture = defaultTex;
       currentGpu._defaultTexView = defaultTex.createView();
       currentGpu._defaultSampler = currentDevice.createSampler({ magFilter: "nearest", minFilter: "nearest" });
     }
     const [r, g, b, a] = currentGpu.clear;
     const texture = currentContext.getCurrentTexture();
     const view = texture.createView();
     const encoder = currentDevice.createCommandEncoder();
     const pass = encoder.beginRenderPass({
       colorAttachments: [{ view, clearValue: { r, g, b, a }, loadOp: "clear", storeOp: "store" }],
     });
     const drawCommands = Array.isArray(currentGpu.commands) ? currentGpu.commands : [];
     if (currentGpu._drawResourceCache == null) {
       currentGpu._drawResourceCache = {
         vertexBuffers: [],
         indexBuffers: [],
         uniformBuffers: [],
         uniformBindGroups: [],
         uniformBindBuffers: [],
         textureBindGroups: [],
         textureBindImageIds: [],
         textureBindRevisions: [],
       };
     }
     const cache = currentGpu._drawResourceCache;
     const ensureBufferEntry = (slots, slotIndex, minSize, usage) => {
       const requiredSize = Math.max(16, Number(minSize) | 0);
       let entry = slots[slotIndex];
       const currentSize = entry == null ? 0 : (Number(entry.size ?? 0) | 0);
       if (entry == null || currentSize < requiredSize) {
         if (entry != null && entry.buffer != null && typeof entry.buffer.destroy === "function") {
           try { entry.buffer.destroy(); } catch (_) {}
         }
         entry = {
           size: requiredSize,
           buffer: currentDevice.createBuffer({ size: requiredSize, usage }),
         };
         slots[slotIndex] = entry;
       }
       return entry;
     };
     for (let drawIndex = 0; drawIndex < drawCommands.length; drawIndex += 1) {
       const cmd = drawCommands[drawIndex];
       if (cmd.vertexData == null || cmd.vertexData.length === 0) continue;
       if (cmd.indices == null || cmd.indices.length === 0) continue;
       const vbEntry = ensureBufferEntry(
         cache.vertexBuffers,
         drawIndex,
         cmd.vertexData.byteLength,
         GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
       );
       currentDevice.queue.writeBuffer(vbEntry.buffer, 0, cmd.vertexData);
       const ibEntry = ensureBufferEntry(
         cache.indexBuffers,
         drawIndex,
         cmd.indices.byteLength,
         GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
       );
       currentDevice.queue.writeBuffer(ibEntry.buffer, 0, cmd.indices);
       const ubEntry = ensureBufferEntry(
         cache.uniformBuffers,
         drawIndex,
         16,
         GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
       );
       currentDevice.queue.writeBuffer(
         ubEntry.buffer,
         0,
         new Float32Array([cmd.uniformR, cmd.uniformG, cmd.uniformB, cmd.uniformA]),
       );
       let uniformBG = cache.uniformBindGroups[drawIndex];
       if (uniformBG == null || cache.uniformBindBuffers[drawIndex] !== ubEntry.buffer) {
         uniformBG = currentDevice.createBindGroup({
           layout: currentGpu._uniformBGL,
           entries: [{ binding: 0, resource: { buffer: ubEntry.buffer } }],
         });
         cache.uniformBindGroups[drawIndex] = uniformBG;
         cache.uniformBindBuffers[drawIndex] = ubEntry.buffer;
       }
       let texView = currentGpu._defaultTexView;
       let texSampler = currentGpu._defaultSampler;
       let resolvedImageId = 0;
       let resolvedRevision = -1;
       if (currentGpu.textures != null && cmd.srcImageId > 0) {
         const texEntry = currentGpu.textures.get(cmd.srcImageId);
         if (texEntry != null) {
           texView = texEntry.view;
           texSampler = texEntry.sampler;
           resolvedImageId = cmd.srcImageId | 0;
           resolvedRevision = Number.isFinite(texEntry.revision)
             ? (texEntry.revision | 0)
             : 0;
         }
       }
       let texBG = cache.textureBindGroups[drawIndex];
       if (
         texBG == null ||
         cache.textureBindImageIds[drawIndex] !== resolvedImageId ||
         cache.textureBindRevisions[drawIndex] !== resolvedRevision
       ) {
         texBG = currentDevice.createBindGroup({
           layout: currentGpu._texBGL,
           entries: [{ binding: 0, resource: texView }, { binding: 1, resource: texSampler }],
         });
         cache.textureBindGroups[drawIndex] = texBG;
         cache.textureBindImageIds[drawIndex] = resolvedImageId;
         cache.textureBindRevisions[drawIndex] = resolvedRevision;
       }
       pass.setPipeline(currentGpu._pipeline);
       pass.setBindGroup(0, uniformBG);
       pass.setBindGroup(1, texBG);
       pass.setVertexBuffer(0, vbEntry.buffer);
       pass.setIndexBuffer(ibEntry.buffer, "uint32");
       const instanceCount = Number.isFinite(cmd.instanceCount ?? cmd.instance_count)
         ? Math.max(1, (cmd.instanceCount ?? cmd.instance_count) | 0)
         : 1;
       pass.drawIndexed(cmd.indices.length, instanceCount);
     }
     pass.end();
     currentDevice.queue.submit([encoder.finish()]);
     currentGpu.commands = [];
     return true;
   };
   const scheduleVsync = !!state.vsyncEnabled && typeof globalThis.requestAnimationFrame === "function";
   if (scheduleVsync) {
     if (gpu.presentScheduled) return true;
     gpu.presentScheduled = true;
     globalThis.requestAnimationFrame(() => {
       const current = globalThis.__kaguraWebRuntime;
       if (current == null) return;
       if (current.webgpu != null) current.webgpu.presentScheduled = false;
       try { presentNow(current); } catch (error) {
         if (current.webgpu != null) current.webgpu.lastError = String(error);
       }
     });
     return true;
   }
   try { return presentNow(state); } catch (error) { gpu.lastError = String(error); return false; }
 };
const _M0FP26mizchi19web__runtime__hooks16js__audio__close = () => {
   const state = globalThis.__kaguraWebRuntime;
   const a = state?.audio;
   if (a) {
     const helper = globalThis.__kaguraAudio;
     if (helper) { helper.close(a); } else {
       if (a.workletNode) { a.workletNode.disconnect(); }
       if (a.node) { a.node.disconnect(); }
       if (a.ctx) { a.ctx.close(); }
     }
     state.audio = null;
   }
 };
const _M0FP26mizchi19web__runtime__hooks17js__audio__resume = () => {
   const a = globalThis.__kaguraWebRuntime?.audio;
   if (a?.ctx) a.ctx.resume();
 };
const _M0FP26mizchi19web__runtime__hooks18js__audio__suspend = () => {
   const a = globalThis.__kaguraWebRuntime?.audio;
   if (a?.ctx) a.ctx.suspend();
 };
const _M0FP26mizchi19web__runtime__hooks26js__audio__try__initialize = (sampleRate, channels) => {
   try {
     const root = globalThis;
     const state = root.__kaguraWebRuntime ?? (root.__kaguraWebRuntime = {});
     if (state.audio && state.audio.ctx) return true;
     const helper = root.__kaguraAudio;
     if (!helper) return false;
     const audio = helper.create(sampleRate, channels);
     if (!audio) return false;
     state.audio = audio;
     return true;
   } catch(e) { return false; }
 };
const _M0FP26mizchi19web__runtime__hooks25js__audio__advance__write = (frames) => {
   const a = globalThis.__kaguraWebRuntime?.audio;
   if (!a) return;
   const helper = globalThis.__kaguraAudio;
   if (helper) { helper.advance(a, frames); return; }
   a.writePos = (a.writePos + frames) % a.ringSize;
 };
const _M0FP26mizchi19web__runtime__hooks26js__audio__get__write__pos = () => {
   const root = globalThis;
   const a = root.__kaguraWebRuntime?.audio;
   return a ? a.writePos : 0;
 };
const _M0FP26mizchi19web__runtime__hooks24js__audio__write__frames = (frames) => {
   const root = globalThis;
   const a = root.__kaguraWebRuntime?.audio;
   if (!a) return 0;
   return frames;
 };
const _M0FP26mizchi19web__runtime__hooks24js__audio__write__sample = (pos, channel, value) => {
   const root = globalThis;
   const a = root.__kaguraWebRuntime?.audio;
   if (!a) return;
   const idx = (pos % a.ringSize) * a.channels + channel;
   a.ring[idx] = value;
 };
const _M0FP26mizchi19web__runtime__hooks20js__load__font__data = (name) => {
   const root = globalThis;
   const state = root.__kaguraWebRuntime;
   if (!state || !state.fonts || !state.fonts[name]) return -1;
   const data = state.fonts[name];
   if (!(data instanceof Uint8Array)) return -1;
   state._fontLoadBuffer = data;
   return data.length;
 };
const _M0FP26mizchi19web__runtime__hooks26js__load__font__data__byte = (offset) => {
   const root = globalThis;
   const state = root.__kaguraWebRuntime;
   if (!state || !state._fontLoadBuffer) return 0;
   if (offset < 0 || offset >= state._fontLoadBuffer.length) return 0;
   return state._fontLoadBuffer[offset];
 };
const _M0FP26mizchi19web__runtime__hooks26js__audio__output__latency = () => {
   const a = globalThis.__kaguraWebRuntime?.audio;
   if (a?.ctx) return a.ctx.outputLatency || 0;
   return 0;
 };
function _M0TPC13ref3RefGRPB5ArrayGiEE(param0) {
  this.val = param0;
}
function _M0TP26mizchi19web__runtime__hooks21SourceImageCacheEntry(param0, param1, param2, param3) {
  this.image_id = param0;
  this.width = param1;
  this.height = param2;
  this.pixels_rgba8 = param3;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char };
function _M0FP15Error10to__string(_e) {
  switch (_e.$tag) {
    case 5: {
      return _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image11DecodeErrorE(_e);
    }
    case 4: {
      return _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image11DecodeErrorE(_e);
    }
    case 2: {
      return _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image11DecodeErrorE(_e);
    }
    case 3: {
      return _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image11DecodeErrorE(_e);
    }
    case 0: {
      return _M0IP016_24default__implPB4Show10to__stringGRP26mizchi4zlib9ZlibErrorE(_e);
    }
    default: {
      return _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image11DecodeErrorE(_e);
    }
  }
}
const _M0FPC15float10min__value = $f32_reinterpret_i32(-8388609);
const _M0FPC15float10max__value = $f32_reinterpret_i32(2139095039);
const _M0FPC15float14not__a__number = $f32_reinterpret_i32(2143289344);
const _M0FP26mizchi4zlib10adler__mod = 65521;
const _M0FP26mizchi4zlib11adler__nmax = 5552;
const _M0FP26mizchi4zlib11crc32__poly = 237 << 24 | 184 << 16 | 131 << 8 | 32;
const _M0FP26mizchi4zlib10dist__base = [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577];
const _M0FP26mizchi4zlib11dist__extra = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13];
const _M0FP26mizchi4zlib12length__base = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258];
const _M0FP26mizchi4zlib13length__extra = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0];
const _M0FP26mizchi5image14png__signature = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]);
const c = $make_array_len_and_init(8, 1);
$bound_check(c, 0);
c[0] = 1 / Math.sqrt(2);
undefined;
const _M0FP26mizchi5image7idct__c = c;
const _M0FP26mizchi5image12jpeg__zigzag = [0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12, 19, 26, 33, 40, 48, 41, 34, 27, 20, 13, 6, 7, 14, 21, 28, 35, 42, 49, 56, 57, 50, 43, 36, 29, 22, 15, 23, 30, 37, 44, 51, 58, 59, 52, 45, 38, 31, 39, 46, 53, 60, 61, 54, 47, 55, 62, 63];
const _M0FP26mizchi12fetch__image9screen__w = 320;
const _M0FP26mizchi12fetch__image9screen__h = 240;
const _M0FP26mizchi12fetch__image15atlas__page__id = 100;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP26mizchi19web__runtime__hooks21web__canvas__selector = _M0MPC13ref3Ref3newGsE("#app");
const _M0FP26mizchi19web__runtime__hooks21web__hooks__installed = _M0MPC13ref3Ref3newGbE(false);
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FPB33brute__force__find_2econstr_2f244 = 0;
const _M0FPB43boyer__moore__horspool__find_2econstr_2f230 = 0;
const _M0FP26mizchi19web__runtime__hooks20source__image__cache = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE([]);
const _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE([]);
const _M0FP36mizchi6kagura3gfx20web__graphics__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx29default__web__graphics__hooks());
const _M0FP26mizchi19web__runtime__hooks27synced__source__generations = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE([]);
const _M0FP36mizchi6kagura4text17font__load__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura4text26default__font__load__hooks());
const _M0FP36mizchi6kagura8platform18web__canvas__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura8platform27default__web__canvas__hooks());
(() => {
  _M0FP36mizchi6kagura6engine21set__lifecycle__hooks(new _M0TP36mizchi6kagura6engine14LifecycleHooks((canvas, _title) => {
    _M0FP26mizchi19web__runtime__hooks7install(canvas);
  }, () => {
    _M0FP26mizchi19web__runtime__hooks8shutdown();
  }));
})();
const _M0FPC14math34trig__reduce_2etwo__over__pi_2f580 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
const _M0FP26mizchi4zlib12crc32__table = _M0FP26mizchi4zlib19build__crc32__table();
const t = $make_array_len_and_init(64, 0);
const _bind = 0;
const _bind$2 = 8;
let _tmp = _bind;
while (true) {
  const n = _tmp;
  if (n < _bind$2) {
    const _bind$3 = 0;
    const _bind$4 = 8;
    let _tmp$2 = _bind$3;
    while (true) {
      const k = _tmp$2;
      if (k < _bind$4) {
        const _tmp$3 = (Math.imul(n, 8) | 0) + k | 0;
        $bound_check(t, _tmp$3);
        t[_tmp$3] = _M0FPC14math3cos((2 * (n + 0) + 1) * (k + 0) * 3.14159265358979312 / 16);
        _tmp$2 = k + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _tmp = n + 1 | 0;
    continue;
  } else {
    break;
  }
}
const _M0FP26mizchi5image16idct__cos__table = t;
const _M0FP36mizchi6kagura5asset18fetch__id__counter = _M0MPC13ref3Ref3newGiE(0);
function _M0FPC15abort5abortGyE(msg) {
  return $panic();
}
function _M0FPC15abort5abortGRPC16string10StringViewE(msg) {
  return $panic();
}
function _M0MPB6Logger13write__objectGsE(self, obj) {
  _M0IPC16string6StringPB4Show6output(obj, self);
}
function _M0FPB5abortGyE(string, loc) {
  return _M0FPC15abort5abortGyE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0FPB5abortGRPC16string10StringViewE(string, loc) {
  return _M0FPC15abort5abortGRPC16string10StringViewE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0MPC15array10FixedArray12unsafe__blitGyE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp$2 = 0;
    while (true) {
      const i = _tmp$2;
      if (i < len) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        $bound_check(src, _tmp$4);
        $bound_check(dst, _tmp$3);
        dst[_tmp$3] = src[_tmp$4];
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp$2 = len - 1 | 0;
    while (true) {
      const i = _tmp$2;
      if (i >= 0) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        $bound_check(src, _tmp$4);
        $bound_check(dst, _tmp$3);
        dst[_tmp$3] = src[_tmp$4];
        _tmp$2 = i - 1 | 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC14byte4Byte8to__char(self) {
  return self;
}
function _M0MPB13StringBuilder11new_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0MPC16uint166UInt1616unsafe__to__char(self) {
  return self;
}
function _M0MPC15array5Array2atGiE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGyE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPB13SourceLocRepr5parse(repr) {
  const _bind$3 = new _M0TPC16string10StringView(repr, 0, repr.length);
  const _data = _M0MPC16string10StringView4data(_bind$3);
  const _start = _M0MPC16string10StringView13start__offset(_bind$3);
  const _end = _start + _M0MPC16string10StringView6length(_bind$3) | 0;
  let _cursor = _start;
  let accept_state = -1;
  let match_end = -1;
  let match_tag_saver_0 = -1;
  let match_tag_saver_1 = -1;
  let match_tag_saver_2 = -1;
  let match_tag_saver_3 = -1;
  let match_tag_saver_4 = -1;
  let tag_0 = -1;
  let tag_1 = -1;
  let tag_1_1 = -1;
  let tag_1_2 = -1;
  let tag_3 = -1;
  let tag_2 = -1;
  let tag_2_1 = -1;
  let tag_4 = -1;
  _L: {
    if (_cursor < _end) {
      if (_M0MPC16string6String20unsafe__charcode__at(_data, _cursor) === 64) {
        _cursor = _cursor + 1 | 0;
        _L$2: while (true) {
          tag_0 = _cursor;
          if (_cursor < _end) {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char === 58) {
              if (_cursor < _end) {
                _cursor = _cursor + 1 | 0;
                let _tmp$2 = 0;
                _L$3: while (true) {
                  const dispatch_15 = _tmp$2;
                  _L$4: {
                    _L$5: {
                      switch (dispatch_15) {
                        case 3: {
                          tag_1_2 = tag_1_1;
                          tag_1_1 = tag_1;
                          tag_1 = _cursor;
                          if (_cursor < _end) {
                            _L$6: {
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  tag_1 = _cursor;
                                  tag_2_1 = tag_2;
                                  tag_2 = _cursor;
                                  tag_3 = _cursor;
                                  if (_cursor < _end) {
                                    _L$7: {
                                      const next_char$3 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                                      _cursor = _cursor + 1 | 0;
                                      if (next_char$3 < 48) {
                                        if (next_char$3 === 45) {
                                          break _L$4;
                                        } else {
                                          break _L$7;
                                        }
                                      } else {
                                        if (next_char$3 > 57) {
                                          if (next_char$3 < 59) {
                                            _tmp$2 = 3;
                                            continue _L$3;
                                          } else {
                                            break _L$7;
                                          }
                                        } else {
                                          _tmp$2 = 6;
                                          continue _L$3;
                                        }
                                      }
                                    }
                                    _tmp$2 = 0;
                                    continue _L$3;
                                  } else {
                                    break _L;
                                  }
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 1;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp$2 = 0;
                            continue _L$3;
                          } else {
                            break _L;
                          }
                        }
                        case 2: {
                          tag_1 = _cursor;
                          tag_2 = _cursor;
                          if (_cursor < _end) {
                            _L$6: {
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 3;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp$2 = 0;
                            continue _L$3;
                          } else {
                            break _L;
                          }
                        }
                        case 0: {
                          tag_1 = _cursor;
                          if (_cursor < _end) {
                            const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                            _cursor = _cursor + 1 | 0;
                            if (next_char$2 === 58) {
                              _tmp$2 = 1;
                              continue _L$3;
                            } else {
                              _tmp$2 = 0;
                              continue _L$3;
                            }
                          } else {
                            break _L;
                          }
                        }
                        case 4: {
                          tag_1 = _cursor;
                          tag_4 = _cursor;
                          if (_cursor < _end) {
                            _L$6: {
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 4;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  tag_1_2 = tag_1_1;
                                  tag_1_1 = tag_1;
                                  tag_1 = _cursor;
                                  if (_cursor < _end) {
                                    _L$7: {
                                      const next_char$3 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                                      _cursor = _cursor + 1 | 0;
                                      if (next_char$3 < 58) {
                                        if (next_char$3 < 48) {
                                          break _L$7;
                                        } else {
                                          tag_1 = _cursor;
                                          tag_2_1 = tag_2;
                                          tag_2 = _cursor;
                                          if (_cursor < _end) {
                                            _L$8: {
                                              const next_char$4 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                                              _cursor = _cursor + 1 | 0;
                                              if (next_char$4 < 58) {
                                                if (next_char$4 < 48) {
                                                  break _L$8;
                                                } else {
                                                  _tmp$2 = 5;
                                                  continue _L$3;
                                                }
                                              } else {
                                                if (next_char$4 > 58) {
                                                  break _L$8;
                                                } else {
                                                  _tmp$2 = 3;
                                                  continue _L$3;
                                                }
                                              }
                                            }
                                            _tmp$2 = 0;
                                            continue _L$3;
                                          } else {
                                            break _L$5;
                                          }
                                        }
                                      } else {
                                        if (next_char$3 > 58) {
                                          break _L$7;
                                        } else {
                                          _tmp$2 = 1;
                                          continue _L$3;
                                        }
                                      }
                                    }
                                    _tmp$2 = 0;
                                    continue _L$3;
                                  } else {
                                    break _L;
                                  }
                                }
                              }
                            }
                            _tmp$2 = 0;
                            continue _L$3;
                          } else {
                            break _L;
                          }
                        }
                        case 5: {
                          tag_1 = _cursor;
                          tag_2 = _cursor;
                          if (_cursor < _end) {
                            _L$6: {
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 5;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 3;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp$2 = 0;
                            continue _L$3;
                          } else {
                            break _L$5;
                          }
                        }
                        case 6: {
                          tag_1 = _cursor;
                          tag_2 = _cursor;
                          tag_3 = _cursor;
                          if (_cursor < _end) {
                            _L$6: {
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 48) {
                                if (next_char$2 === 45) {
                                  break _L$4;
                                } else {
                                  break _L$6;
                                }
                              } else {
                                if (next_char$2 > 57) {
                                  if (next_char$2 < 59) {
                                    _tmp$2 = 3;
                                    continue _L$3;
                                  } else {
                                    break _L$6;
                                  }
                                } else {
                                  _tmp$2 = 6;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp$2 = 0;
                            continue _L$3;
                          } else {
                            break _L;
                          }
                        }
                        case 1: {
                          tag_1_1 = tag_1;
                          tag_1 = _cursor;
                          if (_cursor < _end) {
                            _L$6: {
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp$2 = 1;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp$2 = 0;
                            continue _L$3;
                          } else {
                            break _L;
                          }
                        }
                        default: {
                          break _L;
                        }
                      }
                    }
                    tag_1 = tag_1_2;
                    tag_2 = tag_2_1;
                    match_tag_saver_0 = tag_0;
                    match_tag_saver_1 = tag_1;
                    match_tag_saver_2 = tag_2;
                    match_tag_saver_3 = tag_3;
                    match_tag_saver_4 = tag_4;
                    accept_state = 0;
                    match_end = _cursor;
                    break _L;
                  }
                  tag_1_1 = tag_1_2;
                  tag_1 = _cursor;
                  tag_2 = tag_2_1;
                  if (_cursor < _end) {
                    _L$5: {
                      const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                      _cursor = _cursor + 1 | 0;
                      if (next_char$2 < 58) {
                        if (next_char$2 < 48) {
                          break _L$5;
                        } else {
                          _tmp$2 = 4;
                          continue;
                        }
                      } else {
                        if (next_char$2 > 58) {
                          break _L$5;
                        } else {
                          _tmp$2 = 1;
                          continue;
                        }
                      }
                    }
                    _tmp$2 = 0;
                    continue;
                  } else {
                    break _L;
                  }
                }
              } else {
                break _L;
              }
            } else {
              continue;
            }
          } else {
            break _L;
          }
        }
      } else {
        break _L;
      }
    } else {
      break _L;
    }
  }
  if (accept_state === 0) {
    const start_line = _M0MPC16string6String4view(_data, match_tag_saver_1 + 1 | 0, match_tag_saver_2);
    const start_column = _M0MPC16string6String4view(_data, match_tag_saver_2 + 1 | 0, match_tag_saver_3);
    const pkg = _M0MPC16string6String4view(_data, _start + 1 | 0, match_tag_saver_0);
    const filename = _M0MPC16string6String4view(_data, match_tag_saver_0 + 1 | 0, match_tag_saver_1);
    const end_line = _M0MPC16string6String4view(_data, match_tag_saver_3 + 1 | 0, match_tag_saver_4);
    const end_column = _M0MPC16string6String4view(_data, match_tag_saver_4 + 1 | 0, match_end);
    return new _M0TPB13SourceLocRepr(pkg, filename, start_line, start_column, end_line, end_column);
  } else {
    return $panic();
  }
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0MPB7MyInt647to__int(self) {
  return self.lo;
}
function _M0MPC16uint646UInt647to__int(self) {
  return _M0MPB7MyInt647to__int(self);
}
function _M0IPC16uint166UInt16PB2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implPB2Eq10not__equalGsE(x, y) {
  return !(x === y);
}
function _M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(x, y) {
  return !_M0IP26mizchi5audio10VoiceStatePB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB2Eq10not__equalGlE(x, y) {
  return !_M0IPC15int645Int64PB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB7Compare6op__ltGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) < 0;
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) >= 0;
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    const _end = _Some;
    end$2 = _end < 0 ? len + _end | 0 : _end;
  }
  const start$2 = start < 0 ? len + start | 0 : start;
  if (start$2 >= 0 && (start$2 <= end$2 && end$2 <= len)) {
    if (start$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start$2))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start$2, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0MPC16string10StringView4data(self) {
  return self.str;
}
function _M0MPC16string10StringView6length(self) {
  return self.end - self.start | 0;
}
function _M0MPC16string10StringView13start__offset(self) {
  return self.start;
}
function _M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC15error5ErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGiE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC13int3IntPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPB9SourceLocPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image9ColorTypeE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IP26mizchi5image9ColorTypePB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGRP26mizchi4zlib9ZlibErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IP26mizchi4zlib9ZlibErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image11DecodeErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IP26mizchi5image11DecodeErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
}
function _M0IPC14byte4BytePB3Add3add(self, that) {
  return (self + that | 0) & 255;
}
function _M0IPC14byte4BytePB3Div3div(self, that) {
  if (that === 0) {
    $panic();
  }
  return (self / that | 0) & 255;
}
function _M0IPC14byte4BytePB3Mod3mod(self, that) {
  if (that === 0) {
    $panic();
  }
  return (self % that | 0) & 255;
}
function _M0IPC14byte4BytePB3Sub3sub(self, that) {
  return (self - that | 0) & 255;
}
function _M0MPC14byte4Byte7to__hexN14to__hex__digitS3394(i) {
  return i < 10 ? _M0MPC14byte4Byte8to__char(_M0IPC14byte4BytePB3Add3add(i, 48)) : _M0MPC14byte4Byte8to__char(_M0IPC14byte4BytePB3Sub3sub(_M0IPC14byte4BytePB3Add3add(i, 97), 10));
}
function _M0MPC14byte4Byte7to__hex(b) {
  const _self = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPB13StringBuilderPB6Logger11write__char(_self, _M0MPC14byte4Byte7to__hexN14to__hex__digitS3394(_M0IPC14byte4BytePB3Div3div(b, 16)));
  _M0IPB13StringBuilderPB6Logger11write__char(_self, _M0MPC14byte4Byte7to__hexN14to__hex__digitS3394(_M0IPC14byte4BytePB3Mod3mod(b, 16)));
  return _M0MPB13StringBuilder10to__string(_self);
}
function _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i) {
  const logger = _env._1;
  const self = _env._0;
  if (i > seg) {
    logger.method_table.method_1(logger.self, self, seg, i - seg | 0);
    return;
  } else {
    return;
  }
}
function _M0IPC16string6StringPB4Show6output(self, logger) {
  logger.method_table.method_3(logger.self, 34);
  const _env = { _0: self, _1: logger };
  const len = self.length;
  let _tmp$2 = 0;
  let _tmp$3 = 0;
  _L: while (true) {
    const i = _tmp$2;
    const seg = _tmp$3;
    if (i >= len) {
      _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
      break;
    }
    const code = self.charCodeAt(i);
    let c$2;
    _L$2: {
      switch (code) {
        case 34: {
          c$2 = code;
          break _L$2;
        }
        case 92: {
          c$2 = code;
          break _L$2;
        }
        case 10: {
          _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
          logger.method_table.method_0(logger.self, "\\n");
          _tmp$2 = i + 1 | 0;
          _tmp$3 = i + 1 | 0;
          continue _L;
        }
        case 13: {
          _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
          logger.method_table.method_0(logger.self, "\\r");
          _tmp$2 = i + 1 | 0;
          _tmp$3 = i + 1 | 0;
          continue _L;
        }
        case 8: {
          _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
          logger.method_table.method_0(logger.self, "\\b");
          _tmp$2 = i + 1 | 0;
          _tmp$3 = i + 1 | 0;
          continue _L;
        }
        case 9: {
          _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
          logger.method_table.method_0(logger.self, "\\t");
          _tmp$2 = i + 1 | 0;
          _tmp$3 = i + 1 | 0;
          continue _L;
        }
        default: {
          if (_M0IP016_24default__implPB7Compare6op__ltGkE(code, 32)) {
            _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
            logger.method_table.method_0(logger.self, "\\u{");
            logger.method_table.method_0(logger.self, _M0MPC14byte4Byte7to__hex(code & 255));
            logger.method_table.method_3(logger.self, 125);
            _tmp$2 = i + 1 | 0;
            _tmp$3 = i + 1 | 0;
            continue _L;
          } else {
            _tmp$2 = i + 1 | 0;
            continue _L;
          }
        }
      }
    }
    _M0IPC16string6StringPB4Show6outputN14flush__segmentS3384(_env, seg, i);
    logger.method_table.method_3(logger.self, 92);
    logger.method_table.method_3(logger.self, _M0MPC16uint166UInt1616unsafe__to__char(c$2));
    _tmp$2 = i + 1 | 0;
    _tmp$3 = i + 1 | 0;
    continue;
  }
  logger.method_table.method_3(logger.self, 34);
}
function _M0IPC16string10StringViewPB4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? new _M0TPC16string10StringView(self, start_offset, end_offset$2) : _M0FPB5abortGRPC16string10StringViewE("Invalid index for View", "@moonbitlang/core/builtin:stringview.mbt:399:5-399:36");
}
function _M0MPC16string6String4view(self, start_offset$46$opt, end_offset) {
  let start_offset;
  if (start_offset$46$opt === undefined) {
    start_offset = 0;
  } else {
    const _Some = start_offset$46$opt;
    start_offset = _Some;
  }
  return _M0MPC16string6String12view_2einner(self, start_offset, end_offset);
}
function _M0MPC15array9ArrayView6lengthGyE(self) {
  return self.end - self.start | 0;
}
function _M0MPC15array9ArrayView6lengthGcE(self) {
  return self.end - self.start | 0;
}
function _M0MPC16string6String11from__array(chars) {
  const buf = _M0MPB13StringBuilder11new_2einner(Math.imul(_M0MPC15array9ArrayView6lengthGcE(chars), 4) | 0);
  const _bind$3 = chars.end - chars.start | 0;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const c$2 = chars.buf[chars.start + _ | 0];
      _M0IPB13StringBuilderPB6Logger11write__char(buf, c$2);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPB13StringBuilder10to__string(buf);
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0IPC16string10StringViewPB4Show10to__string(str)}`;
}
function _M0FPB28boyer__moore__horspool__find(haystack, needle) {
  const haystack_len = _M0MPC16string10StringView6length(haystack);
  const needle_len = _M0MPC16string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      const _bind$3 = needle_len - 1 | 0;
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i < _bind$3) {
          const _tmp$3 = _M0MPC16string10StringView11unsafe__get(needle, i) & 255;
          $bound_check(skip_table, _tmp$3);
          skip_table[_tmp$3] = (needle_len - 1 | 0) - i | 0;
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$3 = 0;
      while (true) {
        const i = _tmp$3;
        if (i <= (haystack_len - needle_len | 0)) {
          const _bind$4 = needle_len - 1 | 0;
          let _tmp$4 = 0;
          while (true) {
            const j = _tmp$4;
            if (j <= _bind$4) {
              if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                break;
              }
              _tmp$4 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$5 = _M0MPC16string10StringView11unsafe__get(haystack, (i + needle_len | 0) - 1 | 0) & 255;
          $bound_check(skip_table, _tmp$5);
          _tmp$3 = i + skip_table[_tmp$5] | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB43boyer__moore__horspool__find_2econstr_2f230;
  }
}
function _M0FPB18brute__force__find(haystack, needle) {
  const haystack_len = _M0MPC16string10StringView6length(haystack);
  const needle_len = _M0MPC16string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = _M0MPC16string10StringView11unsafe__get(needle, 0);
      const forward_len = haystack_len - needle_len | 0;
      let i = 0;
      while (true) {
        if (i <= forward_len) {
          while (true) {
            if (i <= forward_len && _M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i), needle_first)) {
              i = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          if (i <= forward_len) {
            let _tmp$2 = 1;
            while (true) {
              const j = _tmp$2;
              if (j < needle_len) {
                if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                  break;
                }
                _tmp$2 = j + 1 | 0;
                continue;
              } else {
                return i;
              }
            }
            i = i + 1 | 0;
          }
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB33brute__force__find_2econstr_2f244;
  }
}
function _M0MPC16string10StringView4find(self, str) {
  return _M0MPC16string10StringView6length(str) <= 4 ? _M0FPB18brute__force__find(self, str) : _M0FPB28boyer__moore__horspool__find(self, str);
}
function _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGdE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGyE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16string10StringView8contains(self, str) {
  const _bind$3 = _M0MPC16string10StringView4find(self, str);
  return !(_bind$3 === undefined);
}
function _M0MPC16string6String8contains(self, str) {
  return _M0MPC16string10StringView8contains(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0IPC13int3IntPB4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0MPC13int3Int18to__string_2einner(self, 10));
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC15array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC15array10FixedArray5makeiGjE(length, value) {
  if (length <= 0) {
    return [];
  } else {
    const array = $make_array_len_and_init(length, value(0));
    let _tmp$2 = 1;
    while (true) {
      const i = _tmp$2;
      if (i < length) {
        $bound_check(array, i);
        array[i] = value(i);
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return array;
  }
}
function _M0MPC15array10FixedArray5makeiGyE(length, value) {
  if (length <= 0) {
    return new Uint8Array([]);
  } else {
    const array = $makebytes(length, value(0));
    let _tmp$2 = 1;
    while (true) {
      const i = _tmp$2;
      if (i < length) {
        $bound_check(array, i);
        array[i] = value(i);
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return array;
  }
}
function _M0MPC15array9ArrayView2atGyE(self, index) {
  if (index >= 0 && index < (self.end - self.start | 0)) {
    const _tmp$2 = self.buf;
    const _tmp$3 = self.start + index | 0;
    $bound_check(_tmp$2, _tmp$3);
    return _tmp$2[_tmp$3];
  } else {
    return _M0FPB5abortGyE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implPB4Show10to__stringGiE(self.end - self.start | 0)} but the index is ${_M0IP016_24default__implPB4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:arrayview.mbt:135:5-137:6");
  }
}
function _M0MPC15array5Array4makeGiE(len, elem) {
  const arr = new Array(len);
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < len) {
      arr[i] = elem;
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array4makeGyE(len, elem) {
  const arr = new Array(len);
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < len) {
      arr[i] = elem;
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array3setGiE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGyE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array10FixedArray12fill_2einnerGfE(self, value, start, end) {
  const array_length = self.length;
  if (array_length > 0) {
    if (start >= 0 && start < array_length) {
      let length;
      if (end === undefined) {
        length = array_length - start | 0;
      } else {
        const _Some = end;
        const _e = _Some;
        length = _e >= start && _e <= array_length ? _e - start | 0 : $panic();
      }
      self.fill(value, start, start + length);
      return;
    } else {
      $panic();
      return;
    }
  } else {
    return;
  }
}
function _M0MPB7MyInt6414extend__i32__u(value) {
  return new _M0TPB7MyInt64(0, value);
}
function _M0MPC16uint646UInt6412extend__uint(value) {
  return _M0MPB7MyInt6414extend__i32__u(value);
}
function _M0MPC14uint4UInt10to__uint64(self) {
  return _M0MPC16uint646UInt6412extend__uint(self);
}
function _M0MPC15bytes5Bytes4make(len, init) {
  if (len < 0) {
    return $bytes_literal$0;
  }
  return $makebytes(len, init);
}
function _M0MPC15bytes5Bytes3new(len) {
  return _M0MPC15bytes5Bytes4make(len, 0);
}
function _M0MPC16string6String20unsafe__charcode__at(self, idx) {
  return self.charCodeAt(idx);
}
function _M0MPB7MyInt6411add__hi__lo(self, bhi, blo) {
  const _ahi = self.hi;
  const _alo = self.lo;
  const lo = _alo + blo | 0;
  const s = lo >> 31;
  const as_ = _alo >> 31;
  const bs = blo >> 31;
  const c$2 = (as_ & bs | ~s & (as_ ^ bs)) & 1;
  const hi = (_ahi + bhi | 0) + c$2 | 0;
  return new _M0TPB7MyInt64(hi, lo);
}
function _M0IPB7MyInt64PB3Sub3sub(self, other) {
  return other.lo === 0 ? new _M0TPB7MyInt64(self.hi - other.hi | 0, self.lo) : _M0MPB7MyInt6411add__hi__lo(self, ~other.hi, ~other.lo + 1 | 0);
}
function _M0IPB7MyInt64PB3Mul3mul(self, other) {
  const _ahi = self.hi;
  const _alo = self.lo;
  const _bhi = other.hi;
  const _blo = other.lo;
  const ahi = _ahi;
  const alo = _alo;
  const bhi = _bhi;
  const blo = _blo;
  const a48 = ahi >>> 16 | 0;
  const a32 = ahi & 65535;
  const a16 = alo >>> 16 | 0;
  const a00 = alo & 65535;
  const b48 = bhi >>> 16 | 0;
  const b32 = bhi & 65535;
  const b16 = blo >>> 16 | 0;
  const b00 = blo & 65535;
  const c00 = Math.imul(a00, b00) | 0;
  const c16 = c00 >>> 16 | 0;
  const c00$2 = c00 & 65535;
  const c16$2 = (c16 >>> 0) + ((Math.imul(a16, b00) | 0) >>> 0) | 0;
  const c32 = c16$2 >>> 16 | 0;
  const c16$3 = c16$2 & 65535;
  const c16$4 = (c16$3 >>> 0) + ((Math.imul(a00, b16) | 0) >>> 0) | 0;
  const c32$2 = (c32 >>> 0) + ((c16$4 >>> 16 | 0) >>> 0) | 0;
  const c16$5 = c16$4 & 65535;
  const c32$3 = (c32$2 >>> 0) + ((Math.imul(a32, b00) | 0) >>> 0) | 0;
  const c48 = c32$3 >>> 16 | 0;
  const c32$4 = c32$3 & 65535;
  const c32$5 = (c32$4 >>> 0) + ((Math.imul(a16, b16) | 0) >>> 0) | 0;
  const c48$2 = (c48 >>> 0) + ((c32$5 >>> 16 | 0) >>> 0) | 0;
  const c32$6 = c32$5 & 65535;
  const c32$7 = (c32$6 >>> 0) + ((Math.imul(a00, b32) | 0) >>> 0) | 0;
  const c48$3 = (c48$2 >>> 0) + ((c32$7 >>> 16 | 0) >>> 0) | 0;
  const c32$8 = c32$7 & 65535;
  const c48$4 = (((((((c48$3 >>> 0) + ((Math.imul(a48, b00) | 0) >>> 0) | 0) >>> 0) + ((Math.imul(a32, b16) | 0) >>> 0) | 0) >>> 0) + ((Math.imul(a16, b32) | 0) >>> 0) | 0) >>> 0) + ((Math.imul(a00, b48) | 0) >>> 0) | 0;
  const c48$5 = c48$4 & 65535;
  return new _M0TPB7MyInt64(c48$5 << 16 | c32$8, c16$5 << 16 | c00$2);
}
function _M0MPB7MyInt644land(self, other) {
  return new _M0TPB7MyInt64(self.hi & other.hi, self.lo & other.lo);
}
function _M0MPB7MyInt643lor(self, other) {
  return new _M0TPB7MyInt64(self.hi | other.hi, self.lo | other.lo);
}
function _M0MPB7MyInt643lsl(self, shift) {
  const shift$2 = shift & 63;
  if (shift$2 === 0) {
    return self;
  } else {
    if (shift$2 < 32) {
      const _hi = self.hi;
      const _lo = self.lo;
      const hi = _hi;
      const lo = _lo;
      const hi$2 = hi << shift$2 | (lo >>> (32 - shift$2 | 0) | 0);
      const lo$2 = lo << shift$2;
      return new _M0TPB7MyInt64(hi$2, lo$2);
    } else {
      return new _M0TPB7MyInt64(self.lo << (shift$2 - 32 | 0), 0);
    }
  }
}
function _M0MPB7MyInt643lsr(self, shift) {
  const shift$2 = shift & 63;
  return shift$2 === 0 ? self : shift$2 < 32 ? new _M0TPB7MyInt64(self.hi >>> shift$2 | 0, self.lo >>> shift$2 | 0 | self.hi << (32 - shift$2 | 0)) : new _M0TPB7MyInt64(0, self.hi >>> (shift$2 - 32 | 0) | 0);
}
function _M0IPB7MyInt64PB2Eq5equal(self, other) {
  return self.hi === other.hi && self.lo === other.lo;
}
function _M0MPB7MyInt648to__uint(self) {
  return self.lo;
}
function _M0IPC15int645Int64PB6BitAnd4land(self, other) {
  return _M0MPB7MyInt644land(self, other);
}
function _M0IPC15int645Int64PB2Eq5equal(self, other) {
  return _M0IPB7MyInt64PB2Eq5equal(self, other);
}
function _M0MPC15int645Int647to__int(self) {
  return _M0MPB7MyInt647to__int(self);
}
function _M0MPC16double6Double22reinterpret__as__int64(self) {
  return _M0MPB7MyInt6419reinterpret__double(self);
}
function _M0IPC16uint646UInt64PB3Sub3sub(self, other) {
  return _M0IPB7MyInt64PB3Sub3sub(self, other);
}
function _M0IPC16uint646UInt64PB3Mul3mul(self, other) {
  return _M0IPB7MyInt64PB3Mul3mul(self, other);
}
function _M0MPC16uint646UInt648to__uint(self) {
  return _M0MPB7MyInt648to__uint(self);
}
function _M0IPC16uint646UInt64PB6BitAnd4land(self, other) {
  return _M0MPB7MyInt644land(self, other);
}
function _M0IPC16uint646UInt64PB5BitOr3lor(self, other) {
  return _M0MPB7MyInt643lor(self, other);
}
function _M0IPC16uint646UInt64PB3Shl3shl(self, shift) {
  return _M0MPB7MyInt643lsl(self, shift);
}
function _M0IPC16uint646UInt64PB3Shr3shr(self, shift) {
  return _M0MPB7MyInt643lsr(self, shift);
}
function _M0MPC14byte4Byte8to__uint(self) {
  return self;
}
function _M0MPC16double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0MPC15bytes5Bytes5makei(length, value) {
  if (length <= 0) {
    return $bytes_literal$0;
  }
  const arr = $makebytes(length, value(0));
  let _tmp$2 = 1;
  while (true) {
    const i = _tmp$2;
    if (i < length) {
      $bound_check(arr, i);
      arr[i] = value(i);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0FPB7printlnGsE(input) {
  console.log(_M0IPC16string6StringPB4Show10to__string(input));
}
function _M0MPC15array10FixedArray17blit__from__bytes(self, bytes_offset, src, src_offset, length) {
  const e1 = (bytes_offset + length | 0) - 1 | 0;
  const e2 = (src_offset + length | 0) - 1 | 0;
  const len1 = self.length;
  const len2 = src.length;
  if (length >= 0 && (bytes_offset >= 0 && (e1 < len1 && (src_offset >= 0 && e2 < len2)))) {
    _M0MPC15array10FixedArray12unsafe__blitGyE(self, bytes_offset, src, src_offset, length);
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC14byte4Byte10to__uint64(self) {
  return _M0MPC14uint4UInt10to__uint64(_M0MPC14byte4Byte8to__uint(self));
}
function _M0MPC15bytes5Bytes11from__array(arr) {
  return _M0MPC15bytes5Bytes5makei(_M0MPC15array9ArrayView6lengthGyE(arr), (i) => _M0MPC15array9ArrayView2atGyE(arr, i));
}
function _M0MPC15bytes5Bytes9to__array(self) {
  const len = self.length;
  const rv = _M0MPC15array5Array4makeGyE(len, 48);
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < len) {
      $bound_check(self, i);
      _M0MPC15array5Array3setGyE(rv, i, self[i]);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return rv;
}
function _M0IPB13SourceLocReprPB4Show6output(self, logger) {
  const pkg = self.pkg;
  const _data = _M0MPC16string10StringView4data(pkg);
  const _start = _M0MPC16string10StringView13start__offset(pkg);
  const _end = _start + _M0MPC16string10StringView6length(pkg) | 0;
  let _cursor = _start;
  let accept_state = -1;
  let match_end = -1;
  let match_tag_saver_0 = -1;
  let tag_0 = -1;
  let _bind$3;
  _L: {
    _L$2: {
      _L$3: while (true) {
        if (_cursor < _end) {
          const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
          _cursor = _cursor + 1 | 0;
          if (next_char === 47) {
            _L$4: while (true) {
              tag_0 = _cursor;
              if (_cursor < _end) {
                const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                _cursor = _cursor + 1 | 0;
                if (next_char$2 === 47) {
                  while (true) {
                    if (_cursor < _end) {
                      _cursor = _cursor + 1 | 0;
                      continue;
                    } else {
                      match_tag_saver_0 = tag_0;
                      accept_state = 0;
                      match_end = _cursor;
                      break _L$2;
                    }
                  }
                } else {
                  continue;
                }
              } else {
                break _L$2;
              }
            }
          } else {
            continue;
          }
        } else {
          break _L$2;
        }
      }
      break _L;
    }
    if (accept_state === 0) {
      const package_name = _M0MPC16string6String4view(_data, match_tag_saver_0 + 1 | 0, match_end);
      const module_name = _M0MPC16string6String4view(_data, _start, match_tag_saver_0);
      _bind$3 = { _0: module_name, _1: package_name };
    } else {
      _bind$3 = { _0: pkg, _1: undefined };
    }
  }
  const _module_name = _bind$3._0;
  const _package_name = _bind$3._1;
  if (_package_name === undefined) {
  } else {
    const _Some = _package_name;
    const _pkg_name = _Some;
    logger.method_table.method_2(logger.self, _pkg_name);
    logger.method_table.method_3(logger.self, 47);
  }
  logger.method_table.method_2(logger.self, self.filename);
  logger.method_table.method_3(logger.self, 58);
  logger.method_table.method_2(logger.self, self.start_line);
  logger.method_table.method_3(logger.self, 58);
  logger.method_table.method_2(logger.self, self.start_column);
  logger.method_table.method_3(logger.self, 45);
  logger.method_table.method_2(logger.self, self.end_line);
  logger.method_table.method_3(logger.self, 58);
  logger.method_table.method_2(logger.self, self.end_column);
  logger.method_table.method_3(logger.self, 64);
  logger.method_table.method_2(logger.self, _module_name);
}
function _M0IPB9SourceLocPB4Show6output(self, logger) {
  _M0IPB13SourceLocReprPB4Show6output(_M0MPB13SourceLocRepr5parse(self), logger);
}
function _M0MPC15array5Array4foldGziE(self, init, f) {
  let _tmp$2 = 0;
  let _tmp$3 = init;
  while (true) {
    const i = _tmp$2;
    const acc = _tmp$3;
    if (i < self.length) {
      _tmp$2 = i + 1 | 0;
      _tmp$3 = f(acc, _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(self, i));
      continue;
    } else {
      return acc;
    }
  }
}
function _M0MPC15array5Array6filterGRP26mizchi5audio5VoiceE(self, f) {
  const arr = [];
  const _bind$3 = self.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const v = self[_];
      if (f(v)) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(arr, v);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, f) {
  const arr = [];
  const _bind$3 = self.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const v = self[_];
      if (f(v)) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(arr, v);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array9is__emptyGRP26mizchi5image8PngChunkE(self) {
  return self.length === 0;
}
function _M0MPC15float5Float7to__int(self) {
  return Math.fround(self !== self) ? 0 : Math.fround(self >= Math.fround(2147483647)) ? 2147483647 : Math.fround(self <= Math.fround(-2147483648)) ? -2147483648 : self | 0;
}
function _M0MPC15float5Float12is__neg__inf(self) {
  return Math.fround(self < _M0FPC15float10min__value);
}
function _M0MPC15float5Float12is__pos__inf(self) {
  return Math.fround(self > _M0FPC15float10max__value);
}
function _M0MPC15float5Float7is__inf(self) {
  return _M0MPC15float5Float12is__pos__inf(self) || _M0MPC15float5Float12is__neg__inf(self);
}
function _M0MPC15float5Float7is__nan(self) {
  return Math.fround(self !== self);
}
function _M0MPC13ref3Ref3newGiE(x) {
  return new _M0TPC13ref3RefGiE(x);
}
function _M0MPC13ref3Ref3newGdE(x) {
  return new _M0TPC13ref3RefGdE(x);
}
function _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(x) {
  return new _M0TPC13ref3RefGORP36mizchi6kagura6engine14LifecycleHooksE(x);
}
function _M0MPC13ref3Ref3newGbE(x) {
  return new _M0TPC13ref3RefGbE(x);
}
function _M0MPC13ref3Ref3newGsE(x) {
  return new _M0TPC13ref3RefGsE(x);
}
function _M0IPC15error5ErrorPB4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0FP15Error10to__string(self));
}
function _M0FPC14math3cos(_tmp$2) {
  return Math.cos(_tmp$2);
}
function _M0FPC14math4mulh(a, b) {
  const a$2 = _M0MPC14uint4UInt10to__uint64(a);
  const b$2 = _M0MPC14uint4UInt10to__uint64(b);
  const res = _M0IPC16uint646UInt64PB3Mul3mul(a$2, b$2);
  return _M0MPC16uint646UInt648to__uint(_M0IPC16uint646UInt64PB3Shr3shr(res, 32));
}
function _M0FPC14math3mul(a, b) {
  const a$2 = _M0MPC14uint4UInt10to__uint64(a);
  const b$2 = _M0MPC14uint4UInt10to__uint64(b);
  const res = _M0IPC16uint646UInt64PB3Mul3mul(a$2, b$2);
  return { _0: _M0MPC16uint646UInt648to__uint(_M0IPC16uint646UInt64PB3Shr3shr(res, 32)), _1: _M0MPC16uint646UInt648to__uint(res) };
}
function _M0FPC14math12trig__reduce(x, switch_over) {
  if (Math.fround(Math.fround(Math.abs(x)) <= switch_over)) {
    let j = Math.fround(0);
    let r = Math.fround(0);
    j = Math.fround(Math.fround(x * $f32_reinterpret_i32(1059256707)) + $f32_reinterpret_i32(1262485504));
    j = Math.fround($i32_reinterpret_f32(j) - 1262485504 | 0);
    r = Math.fround(x - Math.fround(j * $f32_reinterpret_i32(1070141312)));
    r = Math.fround(r - Math.fround(j * $f32_reinterpret_i32(926237760)));
    r = Math.fround(r - Math.fround(j * $f32_reinterpret_i32(741630234)));
    return { _0: r, _1: _M0MPC15float5Float7to__int(j) };
  }
  const xispos = Math.fround(x > Math.fround(0));
  let exp = ($i32_reinterpret_f32(x) >> 23 & 255) - 126 | 0;
  const ix = ($i32_reinterpret_f32(x) & 8388607) << 8 | -2147483648;
  const ind = exp >> 5;
  exp = exp & 31;
  let hi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f580, ind);
  let mi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f580, ind + 1 | 0);
  let lo = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f580, ind + 2 | 0);
  const tp = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f580, ind + 3 | 0);
  if (exp > 0) {
    hi = hi << exp | (mi >>> (32 - exp | 0) | 0);
    mi = mi << exp | (lo >>> (32 - exp | 0) | 0);
    lo = lo << exp | (tp >>> (32 - exp | 0) | 0);
  }
  const _bind$3 = _M0FPC14math3mul(ix, lo);
  const _h = _bind$3._0;
  const _l = _bind$3._1;
  const phi = (_h >>> 0) + ((_l >>> 0 < _l >>> 0 ? 1 : 0) >>> 0) | 0;
  const _bind$4 = _M0FPC14math3mul(ix, mi);
  const _h$2 = _bind$4._0;
  const _l$2 = _bind$4._1;
  let plo = (phi >>> 0) + (_l$2 >>> 0) | 0;
  const phi$2 = (_h$2 >>> 0) + ((plo >>> 0 < _l$2 >>> 0 ? 1 : 0) >>> 0) | 0;
  const l = Math.imul(ix, hi) | 0;
  let phi$3 = (phi$2 >>> 0) + (l >>> 0) | 0;
  let q = phi$3 >>> 30 | 0;
  phi$3 = phi$3 & 1073741823;
  if ((phi$3 & 536870912) !== 0) {
    phi$3 = (phi$3 >>> 0) - (1073741824 >>> 0) | 0;
    q = q + 1 | 0;
  }
  const s = phi$3 & -2147483648;
  if (phi$3 >>> 0 >= -2147483648 >>> 0) {
    phi$3 = ~phi$3;
    plo = (0 >>> 0) - (plo >>> 0) | 0;
    phi$3 = (phi$3 >>> 0) + ((plo === 0 ? 1 : 0) >>> 0) | 0;
  }
  exp = 0;
  while (true) {
    if (phi$3 >>> 0 < -2147483648 >>> 0) {
      phi$3 = phi$3 << 1 | (plo >>> 31 | 0);
      plo = plo << 1;
      exp = exp - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  phi$3 = _M0FPC14math4mulh(phi$3, -921707870);
  if (phi$3 >>> 0 < -2147483648 >>> 0) {
    phi$3 = phi$3 << 1;
    exp = exp - 1 | 0;
  }
  let r = (((((s >>> 0) + ((exp + 128 | 0) << 23 >>> 0) | 0) >>> 0) + ((phi$3 >>> 8 | 0) >>> 0) | 0) >>> 0) + (((phi$3 & 255) >>> 0 > 126 >>> 0 ? 1 : 0) >>> 0) | 0;
  if (!xispos) {
    r = r ^ -2147483648;
    q = -q | 0;
  }
  const r$2 = $f32_reinterpret_i32(r);
  return { _0: r$2, _1: q };
}
function _M0FPC14math10sinf__poly(x) {
  const s = Math.fround(x * x);
  let r = $f32_reinterpret_i32(910184448);
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(961557638));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1007192257));
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(1042983595));
  const t$2 = Math.fround(x * s);
  r = Math.fround(Math.fround(r * t$2) + x);
  return r;
}
function _M0FPC14math10cosf__poly(x) {
  const s = Math.fround(x * x);
  let r = $f32_reinterpret_i32(936198144);
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(985007997));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1026206376));
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(1056964608));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1065353216));
  return r;
}
function _M0FPC14math14sin__cos__core(x, q) {
  let r = (q & 1) !== 0 ? _M0FPC14math10cosf__poly(x) : _M0FPC14math10sinf__poly(x);
  if ((q & 2) !== 0) {
    r = -r;
  }
  return r;
}
function _M0FPC14math4sinf(x) {
  if (_M0MPC15float5Float7is__nan(x) || _M0MPC15float5Float7is__inf(x)) {
    return _M0FPC15float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return x;
  }
  const _bind$3 = _M0FPC14math12trig__reduce(x, Math.fround(201.15625));
  const _x = _bind$3._0;
  const _q = _bind$3._1;
  return _M0FPC14math14sin__cos__core(_x, _q);
}
function _M0FPC14math4cosf(x) {
  if (_M0MPC15float5Float7is__nan(x) || _M0MPC15float5Float7is__inf(x)) {
    return _M0FPC15float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return Math.fround(1);
  }
  const _bind$3 = _M0FPC14math12trig__reduce(x, Math.fround(142.90625));
  const _x = _bind$3._0;
  const _q = _bind$3._1;
  return _M0FPC14math14sin__cos__core(_x, _q + 1 | 0);
}
function _M0IP26mizchi4zlib9ZlibErrorPB4Show6output(_x_516, _x_517) {
  let _arg_518;
  _L: {
    const _InvalidData = _x_516;
    const _$42$arg_518 = _InvalidData._0;
    _arg_518 = _$42$arg_518;
    break _L;
  }
  _x_517.method_table.method_0(_x_517.self, "InvalidData(");
  _M0MPB6Logger13write__objectGsE(_x_517, _arg_518);
  _x_517.method_table.method_0(_x_517.self, ")");
}
function _M0FP26mizchi4zlib14adler32__bytes(data) {
  const s1 = new _M0TPC13ref3RefGjE(1);
  const s2 = new _M0TPC13ref3RefGjE(0);
  const i = new _M0TPC13ref3RefGiE(0);
  const len = data.length;
  while (true) {
    if (i.val < len) {
      const remaining = len - i.val | 0;
      const chunk = remaining > _M0FP26mizchi4zlib11adler__nmax ? _M0FP26mizchi4zlib11adler__nmax : remaining;
      const _bind$3 = 0;
      let _tmp$2 = _bind$3;
      while (true) {
        const j = _tmp$2;
        if (j < chunk) {
          const _tmp$3 = i.val + j | 0;
          $bound_check(data, _tmp$3);
          const byte_val = _M0MPC14byte4Byte8to__uint(data[_tmp$3]);
          s1.val = (s1.val >>> 0) + (byte_val >>> 0) | 0;
          s2.val = (s2.val >>> 0) + (s1.val >>> 0) | 0;
          _tmp$2 = j + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      if (_M0FP26mizchi4zlib10adler__mod === 0) {
        $panic();
      }
      s1.val = (s1.val >>> 0) % (_M0FP26mizchi4zlib10adler__mod >>> 0) | 0;
      if (_M0FP26mizchi4zlib10adler__mod === 0) {
        $panic();
      }
      s2.val = (s2.val >>> 0) % (_M0FP26mizchi4zlib10adler__mod >>> 0) | 0;
      i.val = i.val + chunk | 0;
      continue;
    } else {
      break;
    }
  }
  return s2.val << 16 | s1.val;
}
function _M0FP26mizchi4zlib7adler32(data) {
  return _M0FP26mizchi4zlib14adler32__bytes(data);
}
function _M0FP26mizchi4zlib19build__crc32__table() {
  return _M0MPC15array10FixedArray5makeiGjE(256, (i) => {
    const c$2 = new _M0TPC13ref3RefGjE(i);
    const _bind$3 = 0;
    const _bind$4 = 8;
    let _tmp$2 = _bind$3;
    while (true) {
      const _ = _tmp$2;
      if (_ < _bind$4) {
        if ((c$2.val & 1) === 1) {
          c$2.val = (c$2.val >>> 1 | 0) ^ _M0FP26mizchi4zlib11crc32__poly;
        } else {
          c$2.val = c$2.val >>> 1 | 0;
        }
        _tmp$2 = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return c$2.val;
  });
}
function _M0FP26mizchi4zlib5crc32(data) {
  const crc = new _M0TPC13ref3RefGjE(-1);
  const _bind$3 = data.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const b = data[_];
      const idx = (crc.val ^ b) & 255;
      const _tmp$3 = crc.val >>> 8 | 0;
      $bound_check(_M0FP26mizchi4zlib12crc32__table, idx);
      crc.val = _tmp$3 ^ _M0FP26mizchi4zlib12crc32__table[idx];
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return crc.val ^ -1;
}
function _M0FP26mizchi4zlib18bytes__from__array(arr) {
  const _bind$3 = _M0MPC15array10FixedArray5makeiGyE(arr.length, (i) => _M0MPC15array5Array2atGyE(arr, i));
  return _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(_bind$3, 0, _bind$3.length));
}
function _M0FP26mizchi4zlib18all__zero__lengths(lengths) {
  const _bind$3 = lengths.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const len = lengths[_];
      if (len !== 0) {
        return false;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return true;
}
function _M0FP26mizchi4zlib13reverse__bits(code, len) {
  const result = new _M0TPC13ref3RefGiE(0);
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < len) {
      const bit = code >> i & 1;
      result.val = result.val << 1 | bit;
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return result.val;
}
function _M0MP26mizchi4zlib11HuffmanTree9add__node(self) {
  _M0MPC15array5Array4pushGiE(self.left, -1);
  _M0MPC15array5Array4pushGiE(self.right, -1);
  _M0MPC15array5Array4pushGiE(self.symbol, -1);
  return self.left.length - 1 | 0;
}
function _M0MP26mizchi4zlib11HuffmanTree6insert(self, code, len, sym) {
  if (len === 0) {
    return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(undefined);
  }
  const node = new _M0TPC13ref3RefGiE(0);
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < len) {
      const bit = code >> i & 1;
      const next = bit === 0 ? _M0MPC15array5Array2atGiE(self.left, node.val) : _M0MPC15array5Array2atGiE(self.right, node.val);
      let child;
      if (next === -1) {
        const idx = _M0MP26mizchi4zlib11HuffmanTree9add__node(self);
        if (bit === 0) {
          _M0MPC15array5Array3setGiE(self.left, node.val, idx);
        } else {
          _M0MPC15array5Array3setGiE(self.right, node.val, idx);
        }
        child = idx;
      } else {
        child = next;
      }
      node.val = child;
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (_M0MPC15array5Array2atGiE(self.symbol, node.val) !== -1) {
    return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid Huffman code"));
  }
  return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(_M0MPC15array5Array3setGiE(self.symbol, node.val, sym));
}
function _M0MP26mizchi4zlib11HuffmanTree3new(table_bits) {
  const size = table_bits <= 0 ? 0 : 1 << table_bits;
  return new _M0TP26mizchi4zlib11HuffmanTree([-1], [-1], [-1], table_bits, $make_array_len_and_init(size, -1), $make_array_len_and_init(size, 0), $make_array_len_and_init(size, -1), [], [], []);
}
function _M0FP26mizchi4zlib20build__huffman__tree(lengths, max_bits) {
  const bl_count = $make_array_len_and_init(max_bits + 1 | 0, 0);
  const _bind$3 = lengths.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const len = lengths[_];
      if (len > 0) {
        $bound_check(bl_count, len);
        $bound_check(bl_count, len);
        bl_count[len] = bl_count[len] + 1 | 0;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_code = $make_array_len_and_init(max_bits + 1 | 0, 0);
  const code = new _M0TPC13ref3RefGiE(0);
  let _tmp$3 = 1;
  while (true) {
    const bits = _tmp$3;
    if (bits <= max_bits) {
      const _tmp$4 = code.val;
      const _tmp$5 = bits - 1 | 0;
      $bound_check(bl_count, _tmp$5);
      code.val = (_tmp$4 + bl_count[_tmp$5] | 0) << 1;
      $bound_check(next_code, bits);
      next_code[bits] = code.val;
      _tmp$3 = bits + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const table_bits = max_bits > 9 ? 9 : max_bits;
  const tree = _M0MP26mizchi4zlib11HuffmanTree3new(table_bits);
  const rev_codes = [];
  const _bind$4 = 0;
  const _bind$5 = lengths.length;
  let _tmp$4 = _bind$4;
  while (true) {
    const _ = _tmp$4;
    if (_ < _bind$5) {
      _M0MPC15array5Array4pushGiE(rev_codes, 0);
      _tmp$4 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_code_work = $make_array_len_and_init(max_bits + 1 | 0, 0);
  const _bind$6 = 0;
  let _tmp$5 = _bind$6;
  while (true) {
    const i = _tmp$5;
    if (i <= max_bits) {
      $bound_check(next_code, i);
      $bound_check(next_code_work, i);
      next_code_work[i] = next_code[i];
      _tmp$5 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$6 = 0;
  while (true) {
    const i = _tmp$6;
    if (i < lengths.length) {
      const len = _M0MPC15array5Array2atGiE(lengths, i);
      if (len > 0) {
        $bound_check(next_code_work, len);
        const c$2 = next_code_work[len];
        $bound_check(next_code_work, len);
        $bound_check(next_code_work, len);
        next_code_work[len] = next_code_work[len] + 1 | 0;
        _M0MPC15array5Array3setGiE(rev_codes, i, _M0FP26mizchi4zlib13reverse__bits(c$2, len));
      }
      _tmp$6 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (table_bits > 0) {
    const prefix_max = $make_array_len_and_init(1 << table_bits, 0);
    let _tmp$7 = 0;
    while (true) {
      const i = _tmp$7;
      if (i < lengths.length) {
        const len = _M0MPC15array5Array2atGiE(lengths, i);
        if (len > table_bits) {
          const rev = _M0MPC15array5Array2atGiE(rev_codes, i);
          const prefix = rev & ((1 << table_bits) - 1 | 0);
          $bound_check(prefix_max, prefix);
          if (len > prefix_max[prefix]) {
            $bound_check(prefix_max, prefix);
            prefix_max[prefix] = len;
          }
        }
        _tmp$7 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const _bind$7 = 0;
    const _bind$8 = prefix_max.length;
    let _tmp$8 = _bind$7;
    while (true) {
      const prefix = _tmp$8;
      if (prefix < _bind$8) {
        $bound_check(prefix_max, prefix);
        const max_len = prefix_max[prefix];
        if (max_len > table_bits) {
          const sub_bits = max_len - table_bits | 0;
          const size = 1 << sub_bits;
          const sub_idx = tree.sub_bits.length;
          _M0MPC15array5Array4pushGiE(tree.sub_bits, sub_bits);
          _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(tree.sub_symbol, $make_array_len_and_init(size, -1));
          _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(tree.sub_len, $make_array_len_and_init(size, 0));
          const _tmp$9 = tree.table_sub;
          $bound_check(_tmp$9, prefix);
          _tmp$9[prefix] = sub_idx;
        }
        _tmp$8 = prefix + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  let _tmp$7 = 0;
  while (true) {
    const i = _tmp$7;
    if (i < lengths.length) {
      const len = _M0MPC15array5Array2atGiE(lengths, i);
      if (len > 0) {
        const rev = _M0MPC15array5Array2atGiE(rev_codes, i);
        const _bind$7 = _M0MP26mizchi4zlib11HuffmanTree6insert(tree, rev, len, i);
        if (_bind$7.$tag === 1) {
          const _ok = _bind$7;
          _ok._0;
        } else {
          return _bind$7;
        }
        if (len <= table_bits) {
          const fill = 1 << (table_bits - len | 0);
          const _bind$8 = 0;
          let _tmp$8 = _bind$8;
          while (true) {
            const j = _tmp$8;
            if (j < fill) {
              const idx = rev | j << len;
              const _tmp$9 = tree.table_symbol;
              $bound_check(_tmp$9, idx);
              _tmp$9[idx] = i;
              const _tmp$10 = tree.table_len;
              $bound_check(_tmp$10, idx);
              _tmp$10[idx] = len;
              _tmp$8 = j + 1 | 0;
              continue;
            } else {
              break;
            }
          }
        } else {
          if (table_bits > 0) {
            const prefix = rev & ((1 << table_bits) - 1 | 0);
            const _tmp$8 = tree.table_sub;
            $bound_check(_tmp$8, prefix);
            const sub_idx = _tmp$8[prefix];
            if (sub_idx === -1) {
              return new _M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid Huffman subtable"));
            }
            const sub_bits = _M0MPC15array5Array2atGiE(tree.sub_bits, sub_idx);
            const sub_len = len - table_bits | 0;
            if (sub_len > sub_bits) {
              return new _M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid Huffman subtable width"));
            }
            const sub_code = rev >> table_bits;
            const fill = 1 << (sub_bits - sub_len | 0);
            const _bind$8 = 0;
            let _tmp$9 = _bind$8;
            while (true) {
              const j = _tmp$9;
              if (j < fill) {
                const idx = sub_code | j << sub_len;
                const _tmp$10 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(tree.sub_symbol, sub_idx);
                $bound_check(_tmp$10, idx);
                if (_tmp$10[idx] !== -1) {
                  return new _M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid Huffman code"));
                }
                const _tmp$11 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(tree.sub_symbol, sub_idx);
                $bound_check(_tmp$11, idx);
                _tmp$11[idx] = i;
                const _tmp$12 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(tree.sub_len, sub_idx);
                $bound_check(_tmp$12, idx);
                _tmp$12[idx] = len;
                _tmp$9 = j + 1 | 0;
                continue;
              } else {
                break;
              }
            }
          }
        }
      }
      _tmp$7 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib9ZlibErrorE2Ok(tree);
}
function _M0MP26mizchi4zlib9BitReader10drop__bits(self, n) {
  if (n === 0) {
    return undefined;
  }
  self.bit_buf = _M0IPC16uint646UInt64PB3Shr3shr(self.bit_buf, n);
  self.bit_count = self.bit_count - n | 0;
}
function _M0MP26mizchi4zlib9BitReader12ensure__bits(self, n) {
  while (true) {
    if (self.bit_count < n) {
      const remaining = self.data.length - self.byte_pos | 0;
      if (remaining <= 0) {
        return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Unexpected end of deflate stream"));
      }
      if (remaining >= 4 && self.bit_count <= 32) {
        const _tmp$2 = self.data;
        const _tmp$3 = self.byte_pos;
        $bound_check(_tmp$2, _tmp$3);
        const b0 = _M0MPC14byte4Byte10to__uint64(_tmp$2[_tmp$3]);
        const _tmp$4 = self.data;
        const _tmp$5 = self.byte_pos + 1 | 0;
        $bound_check(_tmp$4, _tmp$5);
        const b1 = _M0MPC14byte4Byte10to__uint64(_tmp$4[_tmp$5]);
        const _tmp$6 = self.data;
        const _tmp$7 = self.byte_pos + 2 | 0;
        $bound_check(_tmp$6, _tmp$7);
        const b2 = _M0MPC14byte4Byte10to__uint64(_tmp$6[_tmp$7]);
        const _tmp$8 = self.data;
        const _tmp$9 = self.byte_pos + 3 | 0;
        $bound_check(_tmp$8, _tmp$9);
        const b3 = _M0MPC14byte4Byte10to__uint64(_tmp$8[_tmp$9]);
        self.byte_pos = self.byte_pos + 4 | 0;
        self.bit_buf = _M0IPC16uint646UInt64PB5BitOr3lor(_M0IPC16uint646UInt64PB5BitOr3lor(_M0IPC16uint646UInt64PB5BitOr3lor(_M0IPC16uint646UInt64PB5BitOr3lor(self.bit_buf, _M0IPC16uint646UInt64PB3Shl3shl(b0, self.bit_count)), _M0IPC16uint646UInt64PB3Shl3shl(b1, self.bit_count + 8 | 0)), _M0IPC16uint646UInt64PB3Shl3shl(b2, self.bit_count + 16 | 0)), _M0IPC16uint646UInt64PB3Shl3shl(b3, self.bit_count + 24 | 0));
        self.bit_count = self.bit_count + 32 | 0;
      } else {
        if (remaining >= 2 && self.bit_count <= 48) {
          const _tmp$2 = self.data;
          const _tmp$3 = self.byte_pos;
          $bound_check(_tmp$2, _tmp$3);
          const b0 = _M0MPC14byte4Byte10to__uint64(_tmp$2[_tmp$3]);
          const _tmp$4 = self.data;
          const _tmp$5 = self.byte_pos + 1 | 0;
          $bound_check(_tmp$4, _tmp$5);
          const b1 = _M0MPC14byte4Byte10to__uint64(_tmp$4[_tmp$5]);
          self.byte_pos = self.byte_pos + 2 | 0;
          self.bit_buf = _M0IPC16uint646UInt64PB5BitOr3lor(_M0IPC16uint646UInt64PB5BitOr3lor(self.bit_buf, _M0IPC16uint646UInt64PB3Shl3shl(b0, self.bit_count)), _M0IPC16uint646UInt64PB3Shl3shl(b1, self.bit_count + 8 | 0));
          self.bit_count = self.bit_count + 16 | 0;
        } else {
          const _tmp$2 = self.data;
          const _tmp$3 = self.byte_pos;
          $bound_check(_tmp$2, _tmp$3);
          const b = _M0MPC14byte4Byte10to__uint64(_tmp$2[_tmp$3]);
          self.byte_pos = self.byte_pos + 1 | 0;
          self.bit_buf = _M0IPC16uint646UInt64PB5BitOr3lor(self.bit_buf, _M0IPC16uint646UInt64PB3Shl3shl(b, self.bit_count));
          self.bit_count = self.bit_count + 8 | 0;
        }
      }
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(undefined);
}
function _M0MP26mizchi4zlib9BitReader10peek__bits(self, n) {
  if (n === 0) {
    return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(0);
  }
  const _bind$3 = _M0MP26mizchi4zlib9BitReader12ensure__bits(self, n);
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _ok._0;
  } else {
    return _bind$3;
  }
  const one = $1L;
  const mask = _M0IPC16uint646UInt64PB3Sub3sub(_M0IPC16uint646UInt64PB3Shl3shl(one, n), $1L);
  return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(_M0MPC16uint646UInt647to__int(_M0IPC16uint646UInt64PB6BitAnd4land(self.bit_buf, mask)));
}
function _M0MP26mizchi4zlib9BitReader10read__bits(self, n) {
  const _bind$3 = _M0MP26mizchi4zlib9BitReader10peek__bits(self, n);
  let result;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    result = _ok._0;
  } else {
    return _bind$3;
  }
  _M0MP26mizchi4zlib9BitReader10drop__bits(self, n);
  return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(result);
}
function _M0MP26mizchi4zlib11HuffmanTree6decode(self, reader) {
  if (self.table_bits > 0) {
    const _bind$3 = _M0MP26mizchi4zlib9BitReader10peek__bits(reader, self.table_bits);
    let bits;
    if (_bind$3.$tag === 1) {
      const _ok = _bind$3;
      bits = _ok._0;
    } else {
      return _bind$3;
    }
    const _tmp$2 = self.table_symbol;
    $bound_check(_tmp$2, bits);
    const sym = _tmp$2[bits];
    if (sym !== -1) {
      const _tmp$3 = self.table_len;
      $bound_check(_tmp$3, bits);
      const len = _tmp$3[bits];
      _M0MP26mizchi4zlib9BitReader10drop__bits(reader, len);
      return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(sym);
    }
    const _tmp$3 = self.table_sub;
    $bound_check(_tmp$3, bits);
    const sub_idx = _tmp$3[bits];
    if (sub_idx !== -1) {
      const sub_bits = _M0MPC15array5Array2atGiE(self.sub_bits, sub_idx);
      const _bind$4 = _M0MP26mizchi4zlib9BitReader10peek__bits(reader, self.table_bits + sub_bits | 0);
      let bits2;
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        bits2 = _ok._0;
      } else {
        return _bind$4;
      }
      const sub_index = bits2 >> self.table_bits;
      const _tmp$4 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(self.sub_symbol, sub_idx);
      $bound_check(_tmp$4, sub_index);
      const sym2 = _tmp$4[sub_index];
      if (sym2 !== -1) {
        const _tmp$5 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(self.sub_len, sub_idx);
        $bound_check(_tmp$5, sub_index);
        const len2 = _tmp$5[sub_index];
        _M0MP26mizchi4zlib9BitReader10drop__bits(reader, len2);
        return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(sym2);
      }
    }
  }
  const node = new _M0TPC13ref3RefGiE(0);
  while (true) {
    const _bind$3 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 1);
    let bit;
    if (_bind$3.$tag === 1) {
      const _ok = _bind$3;
      bit = _ok._0;
    } else {
      return _bind$3;
    }
    node.val = bit === 0 ? _M0MPC15array5Array2atGiE(self.left, node.val) : _M0MPC15array5Array2atGiE(self.right, node.val);
    if (node.val === -1) {
      return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid Huffman code"));
    }
    if (_M0MPC15array5Array2atGiE(self.symbol, node.val) !== -1) {
      return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(_M0MPC15array5Array2atGiE(self.symbol, node.val));
    }
    continue;
  }
}
function _M0FP26mizchi4zlib21build__dynamic__trees(reader) {
  const _bind$3 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 5);
  let _tmp$2;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _tmp$2 = _ok._0;
  } else {
    return _bind$3;
  }
  const hlit = _tmp$2 + 257 | 0;
  const _bind$4 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 5);
  let _tmp$3;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    _tmp$3 = _ok._0;
  } else {
    return _bind$4;
  }
  const hdist = _tmp$3 + 1 | 0;
  const _bind$5 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 4);
  let _tmp$4;
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    _tmp$4 = _ok._0;
  } else {
    return _bind$5;
  }
  const hclen = _tmp$4 + 4 | 0;
  const order = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];
  const code_len_lengths = [];
  const _bind$6 = 0;
  const _bind$7 = 19;
  let _tmp$5 = _bind$6;
  while (true) {
    const _ = _tmp$5;
    if (_ < _bind$7) {
      _M0MPC15array5Array4pushGiE(code_len_lengths, 0);
      _tmp$5 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$8 = 0;
  let _tmp$6 = _bind$8;
  while (true) {
    const i = _tmp$6;
    if (i < hclen) {
      $bound_check(order, i);
      const _tmp$7 = order[i];
      const _bind$9 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 3);
      let _tmp$8;
      if (_bind$9.$tag === 1) {
        const _ok = _bind$9;
        _tmp$8 = _ok._0;
      } else {
        return _bind$9;
      }
      _M0MPC15array5Array3setGiE(code_len_lengths, _tmp$7, _tmp$8);
      _tmp$6 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$9 = _M0FP26mizchi4zlib20build__huffman__tree(code_len_lengths, 7);
  let code_len_tree;
  if (_bind$9.$tag === 1) {
    const _ok = _bind$9;
    code_len_tree = _ok._0;
  } else {
    return _bind$9;
  }
  const total = hlit + hdist | 0;
  const lengths = [];
  const prev = new _M0TPC13ref3RefGiE(0);
  while (true) {
    if (lengths.length < total) {
      const _bind$10 = _M0MP26mizchi4zlib11HuffmanTree6decode(code_len_tree, reader);
      let sym;
      if (_bind$10.$tag === 1) {
        const _ok = _bind$10;
        sym = _ok._0;
      } else {
        return _bind$10;
      }
      if (sym <= 15) {
        _M0MPC15array5Array4pushGiE(lengths, sym);
        prev.val = sym;
      } else {
        if (sym === 16) {
          const _bind$11 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 2);
          let _tmp$7;
          if (_bind$11.$tag === 1) {
            const _ok = _bind$11;
            _tmp$7 = _ok._0;
          } else {
            return _bind$11;
          }
          const repeat = _tmp$7 + 3 | 0;
          const _bind$12 = 0;
          let _tmp$8 = _bind$12;
          while (true) {
            const _ = _tmp$8;
            if (_ < repeat) {
              _M0MPC15array5Array4pushGiE(lengths, prev.val);
              _tmp$8 = _ + 1 | 0;
              continue;
            } else {
              break;
            }
          }
        } else {
          if (sym === 17) {
            const _bind$11 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 3);
            let _tmp$7;
            if (_bind$11.$tag === 1) {
              const _ok = _bind$11;
              _tmp$7 = _ok._0;
            } else {
              return _bind$11;
            }
            const repeat = _tmp$7 + 3 | 0;
            const _bind$12 = 0;
            let _tmp$8 = _bind$12;
            while (true) {
              const _ = _tmp$8;
              if (_ < repeat) {
                _M0MPC15array5Array4pushGiE(lengths, 0);
                _tmp$8 = _ + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            prev.val = 0;
          } else {
            if (sym === 18) {
              const _bind$11 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 7);
              let _tmp$7;
              if (_bind$11.$tag === 1) {
                const _ok = _bind$11;
                _tmp$7 = _ok._0;
              } else {
                return _bind$11;
              }
              const repeat = _tmp$7 + 11 | 0;
              const _bind$12 = 0;
              let _tmp$8 = _bind$12;
              while (true) {
                const _ = _tmp$8;
                if (_ < repeat) {
                  _M0MPC15array5Array4pushGiE(lengths, 0);
                  _tmp$8 = _ + 1 | 0;
                  continue;
                } else {
                  break;
                }
              }
              prev.val = 0;
            } else {
              return new _M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid code length symbol"));
            }
          }
        }
      }
      continue;
    } else {
      break;
    }
  }
  const lit_lengths = [];
  const _bind$10 = 0;
  let _tmp$7 = _bind$10;
  while (true) {
    const i = _tmp$7;
    if (i < hlit) {
      _M0MPC15array5Array4pushGiE(lit_lengths, _M0MPC15array5Array2atGiE(lengths, i));
      _tmp$7 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const dist_lengths = [];
  const _bind$11 = 0;
  let _tmp$8 = _bind$11;
  while (true) {
    const i = _tmp$8;
    if (i < hdist) {
      _M0MPC15array5Array4pushGiE(dist_lengths, _M0MPC15array5Array2atGiE(lengths, hlit + i | 0));
      _tmp$8 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$12 = _M0FP26mizchi4zlib20build__huffman__tree(lit_lengths, 15);
  let lit_tree;
  if (_bind$12.$tag === 1) {
    const _ok = _bind$12;
    lit_tree = _ok._0;
  } else {
    return _bind$12;
  }
  let dist_tree;
  if (_M0FP26mizchi4zlib18all__zero__lengths(dist_lengths)) {
    const _bind$13 = _M0FP26mizchi4zlib20build__huffman__tree([1], 1);
    if (_bind$13.$tag === 1) {
      const _ok = _bind$13;
      dist_tree = _ok._0;
    } else {
      return _bind$13;
    }
  } else {
    const _bind$13 = _M0FP26mizchi4zlib20build__huffman__tree(dist_lengths, 15);
    if (_bind$13.$tag === 1) {
      const _ok = _bind$13;
      dist_tree = _ok._0;
    } else {
      return _bind$13;
    }
  }
  return new _M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE2Ok({ _0: lit_tree, _1: dist_tree });
}
function _M0FP26mizchi4zlib19build__fixed__trees() {
  const lit_lengths = [];
  const _bind$3 = 0;
  const _bind$4 = 288;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < _bind$4) {
      const len = i <= 143 ? 8 : i <= 255 ? 9 : i <= 279 ? 7 : 8;
      _M0MPC15array5Array4pushGiE(lit_lengths, len);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const dist_lengths = [];
  const _bind$5 = 0;
  const _bind$6 = 32;
  let _tmp$3 = _bind$5;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$6) {
      _M0MPC15array5Array4pushGiE(dist_lengths, 5);
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$7 = _M0FP26mizchi4zlib20build__huffman__tree(lit_lengths, 15);
  let lit_tree;
  if (_bind$7.$tag === 1) {
    const _ok = _bind$7;
    lit_tree = _ok._0;
  } else {
    return _bind$7;
  }
  const _bind$8 = _M0FP26mizchi4zlib20build__huffman__tree(dist_lengths, 15);
  let dist_tree;
  if (_bind$8.$tag === 1) {
    const _ok = _bind$8;
    dist_tree = _ok._0;
  } else {
    return _bind$8;
  }
  return new _M0DTPC16result6ResultGURP26mizchi4zlib11HuffmanTreeRP26mizchi4zlib11HuffmanTreeERP26mizchi4zlib9ZlibErrorE2Ok({ _0: lit_tree, _1: dist_tree });
}
function _M0FP26mizchi4zlib23inflate__huffman__block(reader, output, lit_tree, dist_tree) {
  while (true) {
    const _bind$3 = _M0MP26mizchi4zlib11HuffmanTree6decode(lit_tree, reader);
    let sym;
    if (_bind$3.$tag === 1) {
      const _ok = _bind$3;
      sym = _ok._0;
    } else {
      return _bind$3;
    }
    if (sym < 256) {
      _M0MPC15array5Array4pushGyE(output, sym & 255);
      continue;
    }
    if (sym === 256) {
      break;
    }
    if (sym < 257 || sym > 285) {
      return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData(`Invalid length symbol: ${_M0IP016_24default__implPB4Show10to__stringGiE(sym)}`));
    }
    const len_index = sym - 257 | 0;
    $bound_check(_M0FP26mizchi4zlib12length__base, len_index);
    const base_len = _M0FP26mizchi4zlib12length__base[len_index];
    $bound_check(_M0FP26mizchi4zlib13length__extra, len_index);
    const extra_bits = _M0FP26mizchi4zlib13length__extra[len_index];
    let extra;
    if (extra_bits === 0) {
      extra = 0;
    } else {
      const _bind$4 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, extra_bits);
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        extra = _ok._0;
      } else {
        return _bind$4;
      }
    }
    const length = base_len + extra | 0;
    const _bind$4 = _M0MP26mizchi4zlib11HuffmanTree6decode(dist_tree, reader);
    let dist_sym;
    if (_bind$4.$tag === 1) {
      const _ok = _bind$4;
      dist_sym = _ok._0;
    } else {
      return _bind$4;
    }
    if (dist_sym < 0 || dist_sym >= _M0FP26mizchi4zlib10dist__base.length) {
      return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData(`Invalid distance symbol: ${_M0IP016_24default__implPB4Show10to__stringGiE(dist_sym)}`));
    }
    $bound_check(_M0FP26mizchi4zlib10dist__base, dist_sym);
    const base_dist = _M0FP26mizchi4zlib10dist__base[dist_sym];
    $bound_check(_M0FP26mizchi4zlib11dist__extra, dist_sym);
    const dist_extra_bits = _M0FP26mizchi4zlib11dist__extra[dist_sym];
    let dist_extra_val;
    if (dist_extra_bits === 0) {
      dist_extra_val = 0;
    } else {
      const _bind$5 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, dist_extra_bits);
      if (_bind$5.$tag === 1) {
        const _ok = _bind$5;
        dist_extra_val = _ok._0;
      } else {
        return _bind$5;
      }
    }
    const distance = base_dist + dist_extra_val | 0;
    if (distance <= 0 || distance > output.length) {
      return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid distance"));
    }
    const start = output.length - distance | 0;
    const remaining = new _M0TPC13ref3RefGiE(length);
    while (true) {
      if (remaining.val > 0) {
        const chunk = remaining.val > distance ? distance : remaining.val;
        const _bind$5 = 0;
        let _tmp$2 = _bind$5;
        while (true) {
          const i = _tmp$2;
          if (i < chunk) {
            _M0MPC15array5Array4pushGyE(output, _M0MPC15array5Array2atGyE(output, start + i | 0));
            _tmp$2 = i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        remaining.val = remaining.val - chunk | 0;
        continue;
      } else {
        break;
      }
    }
    continue;
  }
  return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(undefined);
}
function _M0MP26mizchi4zlib9BitReader11align__byte(self) {
  if (8 === 0) {
    $panic();
  }
  const full_bytes = self.bit_count / 8 | 0;
  if (full_bytes > 0) {
    self.byte_pos = self.byte_pos - full_bytes | 0;
  }
  self.bit_buf = $0L;
  self.bit_count = 0;
}
function _M0MP26mizchi4zlib9BitReader20read__bytes__aligned(self, output, len) {
  if (self.bit_count !== 0) {
    _M0MP26mizchi4zlib9BitReader11align__byte(self);
  }
  if ((self.byte_pos + len | 0) > self.data.length) {
    return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Unexpected end of deflate stream"));
  }
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < len) {
      const _tmp$3 = self.data;
      const _tmp$4 = self.byte_pos + i | 0;
      $bound_check(_tmp$3, _tmp$4);
      _M0MPC15array5Array4pushGyE(output, _tmp$3[_tmp$4]);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  self.byte_pos = self.byte_pos + len | 0;
  return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(undefined);
}
function _M0MP26mizchi4zlib9BitReader22read__u16__le__aligned(self) {
  if (self.bit_count !== 0) {
    _M0MP26mizchi4zlib9BitReader11align__byte(self);
  }
  if ((self.byte_pos + 2 | 0) > self.data.length) {
    return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Unexpected end of deflate stream"));
  }
  const _tmp$2 = self.data;
  const _tmp$3 = self.byte_pos;
  $bound_check(_tmp$2, _tmp$3);
  const b0 = _tmp$2[_tmp$3];
  const _tmp$4 = self.data;
  const _tmp$5 = self.byte_pos + 1 | 0;
  $bound_check(_tmp$4, _tmp$5);
  const b1 = _tmp$4[_tmp$5];
  self.byte_pos = self.byte_pos + 2 | 0;
  return new _M0DTPC16result6ResultGiRP26mizchi4zlib9ZlibErrorE2Ok(b0 | b1 << 8);
}
function _M0FP26mizchi4zlib22inflate__stored__block(reader, output) {
  _M0MP26mizchi4zlib9BitReader11align__byte(reader);
  const _bind$3 = _M0MP26mizchi4zlib9BitReader22read__u16__le__aligned(reader);
  let len;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    len = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0MP26mizchi4zlib9BitReader22read__u16__le__aligned(reader);
  let nlen;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    nlen = _ok._0;
  } else {
    return _bind$4;
  }
  if ((len ^ nlen) !== 65535) {
    return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid stored block length"));
  }
  return _M0MP26mizchi4zlib9BitReader20read__bytes__aligned(reader, output, len);
}
function _M0FP26mizchi4zlib15inflate__blocks(reader, output) {
  const is_final = new _M0TPC13ref3RefGbE(false);
  while (true) {
    if (!is_final.val) {
      const _bind$3 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 1);
      let bfinal;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        bfinal = _ok._0;
      } else {
        return _bind$3;
      }
      const _bind$4 = _M0MP26mizchi4zlib9BitReader10read__bits(reader, 2);
      let btype;
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        btype = _ok._0;
      } else {
        return _bind$4;
      }
      if (btype === 0) {
        const _bind$5 = _M0FP26mizchi4zlib22inflate__stored__block(reader, output);
        if (_bind$5.$tag === 1) {
          const _ok = _bind$5;
          _ok._0;
        } else {
          return _bind$5;
        }
      } else {
        if (btype === 1) {
          let lit_tree;
          let dist_tree;
          _L: {
            const _bind$5 = _M0FP26mizchi4zlib19build__fixed__trees();
            let _bind$6;
            if (_bind$5.$tag === 1) {
              const _ok = _bind$5;
              _bind$6 = _ok._0;
            } else {
              return _bind$5;
            }
            const _lit_tree = _bind$6._0;
            const _dist_tree = _bind$6._1;
            lit_tree = _lit_tree;
            dist_tree = _dist_tree;
            break _L;
          }
          const _bind$5 = _M0FP26mizchi4zlib23inflate__huffman__block(reader, output, lit_tree, dist_tree);
          if (_bind$5.$tag === 1) {
            const _ok = _bind$5;
            _ok._0;
          } else {
            return _bind$5;
          }
        } else {
          if (btype === 2) {
            let lit_tree;
            let dist_tree;
            _L: {
              const _bind$5 = _M0FP26mizchi4zlib21build__dynamic__trees(reader);
              let _bind$6;
              if (_bind$5.$tag === 1) {
                const _ok = _bind$5;
                _bind$6 = _ok._0;
              } else {
                return _bind$5;
              }
              const _lit_tree = _bind$6._0;
              const _dist_tree = _bind$6._1;
              lit_tree = _lit_tree;
              dist_tree = _dist_tree;
              break _L;
            }
            const _bind$5 = _M0FP26mizchi4zlib23inflate__huffman__block(reader, output, lit_tree, dist_tree);
            if (_bind$5.$tag === 1) {
              const _ok = _bind$5;
              _ok._0;
            } else {
              return _bind$5;
            }
          } else {
            return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid deflate block type"));
          }
        }
      }
      if (bfinal === 1) {
        is_final.val = true;
      }
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGuRP26mizchi4zlib9ZlibErrorE2Ok(undefined);
}
function _M0MP26mizchi4zlib9BitReader3new(data, start) {
  return new _M0TP26mizchi4zlib9BitReader(data, start, $0L, 0);
}
function _M0MP26mizchi4zlib9BitReader6offset(self) {
  return self.byte_pos;
}
function _M0FP26mizchi4zlib24inflate__deflate__stream(data, start) {
  const reader = _M0MP26mizchi4zlib9BitReader3new(data, start);
  const output = [];
  const _bind$3 = _M0FP26mizchi4zlib15inflate__blocks(reader, output);
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _ok._0;
  } else {
    return _bind$3;
  }
  _M0MP26mizchi4zlib9BitReader11align__byte(reader);
  return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE2Ok({ _0: _M0FP26mizchi4zlib18bytes__from__array(output), _1: _M0MP26mizchi4zlib9BitReader6offset(reader) });
}
function _M0FP26mizchi4zlib20zlib__decompress__at(data, start) {
  if (start < 0 || (start + 2 | 0) > data.length) {
    return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Zlib data too short"));
  }
  $bound_check(data, start);
  const cmf = data[start];
  const _tmp$2 = start + 1 | 0;
  $bound_check(data, _tmp$2);
  const flg = data[_tmp$2];
  if ((cmf & 15) !== 8) {
    return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Unsupported compression method"));
  }
  if (31 === 0) {
    $panic();
  }
  if ((((Math.imul(cmf, 256) | 0) + flg | 0) % 31 | 0) !== 0) {
    return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Invalid zlib FLG checksum"));
  }
  const fdict = flg >> 5 & 1;
  if (fdict === 1) {
    return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Preset dictionary not supported"));
  }
  const deflate_start = start + 2 | 0;
  let result;
  let offset;
  _L: {
    const _bind$3 = _M0FP26mizchi4zlib24inflate__deflate__stream(data, deflate_start);
    let _bind$4;
    if (_bind$3.$tag === 1) {
      const _ok = _bind$3;
      _bind$4 = _ok._0;
    } else {
      return _bind$3;
    }
    const _result = _bind$4._0;
    const _offset = _bind$4._1;
    result = _result;
    offset = _offset;
    break _L;
  }
  if ((offset + 4 | 0) > data.length) {
    return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Missing Adler-32 checksum"));
  }
  $bound_check(data, offset);
  const _tmp$3 = data[offset] << 24;
  const _tmp$4 = offset + 1 | 0;
  $bound_check(data, _tmp$4);
  const _tmp$5 = _tmp$3 | data[_tmp$4] << 16;
  const _tmp$6 = offset + 2 | 0;
  $bound_check(data, _tmp$6);
  const _tmp$7 = _tmp$5 | data[_tmp$6] << 8;
  const _tmp$8 = offset + 3 | 0;
  $bound_check(data, _tmp$8);
  const stored_checksum = _tmp$7 | data[_tmp$8];
  const computed_checksum = _M0FP26mizchi4zlib7adler32(result);
  if (stored_checksum !== computed_checksum) {
    return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData(`Adler-32 mismatch: stored=${_M0IP016_24default__implPB4Show10to__stringGiE(stored_checksum)}, computed=${_M0IP016_24default__implPB4Show10to__stringGiE(computed_checksum)}`));
  }
  return new _M0DTPC16result6ResultGUziERP26mizchi4zlib9ZlibErrorE2Ok({ _0: result, _1: offset + 4 | 0 });
}
function _M0FP26mizchi4zlib16zlib__decompress(data) {
  let result;
  let offset;
  _L: {
    const _bind$3 = _M0FP26mizchi4zlib20zlib__decompress__at(data, 0);
    let _bind$4;
    if (_bind$3.$tag === 1) {
      const _ok = _bind$3;
      _bind$4 = _ok._0;
    } else {
      return _bind$3;
    }
    const _result = _bind$4._0;
    const _offset = _bind$4._1;
    result = _result;
    offset = _offset;
    break _L;
  }
  if (offset !== data.length) {
    return new _M0DTPC16result6ResultGzRP26mizchi4zlib9ZlibErrorE3Err(new _M0DTPC15error5Error39mizchi_2fzlib_2eZlibError_2eInvalidData("Trailing data after zlib stream"));
  }
  return new _M0DTPC16result6ResultGzRP26mizchi4zlib9ZlibErrorE2Ok(result);
}
function _M0FP26mizchi4zlib12crc32__fixed(data) {
  return _M0FP26mizchi4zlib5crc32(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(data, 0, data.length)));
}
function _M0IP26mizchi5image9ColorTypePB4Show6output(_x_858, _x_859) {
  switch (_x_858) {
    case 0: {
      _x_859.method_table.method_0(_x_859.self, "Grayscale");
      return;
    }
    case 1: {
      _x_859.method_table.method_0(_x_859.self, "Rgb");
      return;
    }
    case 2: {
      _x_859.method_table.method_0(_x_859.self, "Indexed");
      return;
    }
    case 3: {
      _x_859.method_table.method_0(_x_859.self, "GrayscaleAlpha");
      return;
    }
    default: {
      _x_859.method_table.method_0(_x_859.self, "Rgba");
      return;
    }
  }
}
function _M0IP26mizchi5image11DecodeErrorPB4Show6output(self, logger) {
  let s;
  _L: {
    let s$2;
    _L$2: {
      let s$3;
      _L$3: {
        let s$4;
        _L$4: {
          let s$5;
          _L$5: {
            switch (self.$tag) {
              case 5: {
                const _InvalidSignature = self;
                const _s = _InvalidSignature._0;
                s$5 = _s;
                break _L$5;
              }
              case 4: {
                const _InvalidChunkCrc = self;
                const _s$2 = _InvalidChunkCrc._0;
                s$4 = _s$2;
                break _L$4;
              }
              case 3: {
                const _MissingChunk = self;
                const _s$3 = _MissingChunk._0;
                s$3 = _s$3;
                break _L$3;
              }
              case 2: {
                const _UnsupportedFeature = self;
                const _s$4 = _UnsupportedFeature._0;
                s$2 = _s$4;
                break _L$2;
              }
              default: {
                const _CorruptData = self;
                const _s$5 = _CorruptData._0;
                s = _s$5;
                break _L;
              }
            }
          }
          logger.method_table.method_0(logger.self, `InvalidSignature: ${s$5}`);
          return;
        }
        logger.method_table.method_0(logger.self, `InvalidChunkCrc: ${s$4}`);
        return;
      }
      logger.method_table.method_0(logger.self, `MissingChunk: ${s$3}`);
      return;
    }
    logger.method_table.method_0(logger.self, `UnsupportedFeature: ${s$2}`);
    return;
  }
  logger.method_table.method_0(logger.self, `CorruptData: ${s}`);
}
function _M0FP26mizchi5image22color__type__from__png(value) {
  switch (value) {
    case 0: {
      return new _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok(0);
    }
    case 2: {
      return new _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok(1);
    }
    case 3: {
      return new _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok(2);
    }
    case 4: {
      return new _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok(3);
    }
    case 6: {
      return new _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE2Ok(4);
    }
    default: {
      return new _M0DTPC16result6ResultGRP26mizchi5image9ColorTypeRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`unknown color type: ${_M0MPC13int3Int18to__string_2einner(value, 10)}`));
    }
  }
}
function _M0FP26mizchi5image17bytes__per__pixel(ct, bit_depth) {
  let channels;
  switch (ct) {
    case 0: {
      channels = 1;
      break;
    }
    case 1: {
      channels = 3;
      break;
    }
    case 2: {
      channels = 1;
      break;
    }
    case 3: {
      channels = 2;
      break;
    }
    default: {
      channels = 4;
    }
  }
  const bits = Math.imul(channels, bit_depth) | 0;
  if (bits < 8) {
    return 1;
  } else {
    if (8 === 0) {
      $panic();
    }
    return bits / 8 | 0;
  }
}
function _M0FP26mizchi5image17decode__bmp__rows(raw, info, on_row) {
  const _bind$3 = 0;
  const _bind$4 = info.height;
  let _tmp$2 = _bind$3;
  while (true) {
    const y = _tmp$2;
    if (y < _bind$4) {
      const src_y = info.top_down ? y : (info.height - 1 | 0) - y | 0;
      const src_row_offset = info.pixel_offset + (Math.imul(src_y, info.padded_row_size) | 0) | 0;
      const row_buf = $makebytes(Math.imul(info.width, 4) | 0, 0);
      const _bind$5 = 0;
      const _bind$6 = info.width;
      let _tmp$3 = _bind$5;
      while (true) {
        const x = _tmp$3;
        if (x < _bind$6) {
          const src_idx = src_row_offset + (Math.imul(x, info.bytes_per_px) | 0) | 0;
          const dst_idx = Math.imul(x, 4) | 0;
          $bound_check(raw, src_idx);
          const b_val = raw[src_idx];
          const _tmp$4 = src_idx + 1 | 0;
          $bound_check(raw, _tmp$4);
          const g_val = raw[_tmp$4];
          const _tmp$5 = src_idx + 2 | 0;
          $bound_check(raw, _tmp$5);
          const r_val = raw[_tmp$5];
          let a_val;
          if (info.bpp === 32) {
            const _tmp$6 = src_idx + 3 | 0;
            $bound_check(raw, _tmp$6);
            a_val = raw[_tmp$6];
          } else {
            a_val = 255;
          }
          $bound_check(row_buf, dst_idx);
          row_buf[dst_idx] = r_val;
          const _tmp$6 = dst_idx + 1 | 0;
          $bound_check(row_buf, _tmp$6);
          row_buf[_tmp$6] = g_val;
          const _tmp$7 = dst_idx + 2 | 0;
          $bound_check(row_buf, _tmp$7);
          row_buf[_tmp$7] = b_val;
          const _tmp$8 = dst_idx + 3 | 0;
          $bound_check(row_buf, _tmp$8);
          row_buf[_tmp$8] = a_val;
          _tmp$3 = x + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      on_row(y, _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(row_buf, 0, row_buf.length)));
      _tmp$2 = y + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP26mizchi5image11read__i32le(data, offset) {
  $bound_check(data, offset);
  const b0 = data[offset] & 255;
  const _tmp$2 = offset + 1 | 0;
  $bound_check(data, _tmp$2);
  const b1 = data[_tmp$2] & 255;
  const _tmp$3 = offset + 2 | 0;
  $bound_check(data, _tmp$3);
  const b2 = data[_tmp$3] & 255;
  const _tmp$4 = offset + 3 | 0;
  $bound_check(data, _tmp$4);
  const b3 = data[_tmp$4] & 255;
  return b0 | b1 << 8 | b2 << 16 | b3 << 24;
}
function _M0FP26mizchi5image11read__u16le(data, offset) {
  $bound_check(data, offset);
  const b0 = data[offset] & 255;
  const _tmp$2 = offset + 1 | 0;
  $bound_check(data, _tmp$2);
  const b1 = data[_tmp$2] & 255;
  return b1 << 8 | b0;
}
function _M0FP26mizchi5image11read__u32le(data, offset) {
  $bound_check(data, offset);
  const b0 = data[offset] & 255;
  const _tmp$2 = offset + 1 | 0;
  $bound_check(data, _tmp$2);
  const b1 = data[_tmp$2] & 255;
  const _tmp$3 = offset + 2 | 0;
  $bound_check(data, _tmp$3);
  const b2 = data[_tmp$3] & 255;
  const _tmp$4 = offset + 3 | 0;
  $bound_check(data, _tmp$4);
  const b3 = data[_tmp$4] & 255;
  return b3 << 24 | b2 << 16 | b1 << 8 | b0;
}
function _M0FP26mizchi5image16parse__bmp__info(raw) {
  if (raw.length < 54) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("BMP file too short"));
  }
  let _tmp$2;
  $bound_check(raw, 0);
  if (raw[0] !== 66) {
    _tmp$2 = true;
  } else {
    $bound_check(raw, 1);
    _tmp$2 = raw[1] !== 77;
  }
  if (_tmp$2) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error47mizchi_2fimage_2eDecodeError_2eInvalidSignature("not a BMP file"));
  }
  const pixel_offset = _M0FP26mizchi5image11read__u32le(raw, 10);
  const dib_size = _M0FP26mizchi5image11read__u32le(raw, 14);
  if (dib_size < 40) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`unsupported DIB header size: ${_M0MPC13int3Int18to__string_2einner(dib_size, 10)}`));
  }
  const width = _M0FP26mizchi5image11read__i32le(raw, 18);
  const raw_height = _M0FP26mizchi5image11read__i32le(raw, 22);
  const top_down = raw_height < 0;
  const height = top_down ? 0 - raw_height | 0 : raw_height;
  if (width <= 0 || height <= 0) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("invalid BMP dimensions"));
  }
  const bpp = _M0FP26mizchi5image11read__u16le(raw, 28);
  const compression = _M0FP26mizchi5image11read__u32le(raw, 30);
  if (compression !== 0) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`compressed BMP not supported (compression=${_M0MPC13int3Int18to__string_2einner(compression, 10)})`));
  }
  if (bpp !== 24 && bpp !== 32) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`unsupported BMP bits per pixel: ${_M0MPC13int3Int18to__string_2einner(bpp, 10)}`));
  }
  if (8 === 0) {
    $panic();
  }
  const bytes_per_px = bpp / 8 | 0;
  const row_size = Math.imul(width, bytes_per_px) | 0;
  if (4 === 0) {
    $panic();
  }
  const padded_row_size = Math.imul((row_size + 3 | 0) / 4 | 0, 4) | 0;
  const required_size = pixel_offset + (Math.imul(padded_row_size, height) | 0) | 0;
  if (raw.length < required_size) {
    return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("BMP file too short for pixel data"));
  }
  return new _M0DTPC16result6ResultGRP26mizchi5image13BmpDecodeInfoRP26mizchi5image11DecodeErrorE2Ok(new _M0TP26mizchi5image13BmpDecodeInfo(width, height, bpp, bytes_per_px, pixel_offset, padded_row_size, top_down));
}
function _M0FP26mizchi5image25collect__png__image__data(chunks) {
  const idat_parts = [];
  const palette = new _M0TPC13ref3RefGOzE(undefined);
  const _bind$3 = chunks.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const chunk = chunks[_];
      const _bind$4 = chunk.chunk_type;
      switch (_bind$4) {
        case "IDAT": {
          _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(idat_parts, chunk.data);
          break;
        }
        case "PLTE": {
          palette.val = chunk.data;
          break;
        }
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (_M0MPC15array5Array9is__emptyGRP26mizchi5image8PngChunkE(idat_parts)) {
    return new _M0DTPC16result6ResultGURPB5ArrayGzEOzERP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("IDAT"));
  }
  return new _M0DTPC16result6ResultGURPB5ArrayGzEOzERP26mizchi5image11DecodeErrorE2Ok({ _0: idat_parts, _1: palette.val });
}
function _M0FP26mizchi5image16paeth__predictor(a, b, c$2) {
  const p = (a + b | 0) - c$2 | 0;
  const pa = p > a ? p - a | 0 : a - p | 0;
  const pb = p > b ? p - b | 0 : b - p | 0;
  const pc = p > c$2 ? p - c$2 | 0 : c$2 - p | 0;
  return pa <= pb && pa <= pc ? a : pb <= pc ? b : c$2;
}
function _M0FP26mizchi5image16reconstruct__row(filter_type, row, prev, bpp) {
  const len = row.length;
  const buf = $makebytes(len, 0);
  switch (filter_type) {
    case 0: {
      _M0MPC15array10FixedArray17blit__from__bytes(buf, 0, row, 0, len);
      break;
    }
    case 1: {
      const _bind$3 = 0;
      let _tmp$2 = _bind$3;
      while (true) {
        const i = _tmp$2;
        if (i < len) {
          let a;
          if (i >= bpp) {
            const _tmp$3 = i - bpp | 0;
            $bound_check(buf, _tmp$3);
            a = buf[_tmp$3];
          } else {
            a = 0;
          }
          $bound_check(row, i);
          if (256 === 0) {
            $panic();
          }
          $bound_check(buf, i);
          buf[i] = ((row[i] + a | 0) % 256 | 0) & 255;
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    case 2: {
      const _bind$4 = 0;
      let _tmp$3 = _bind$4;
      while (true) {
        const i = _tmp$3;
        if (i < len) {
          $bound_check(prev, i);
          const b = prev[i];
          $bound_check(row, i);
          if (256 === 0) {
            $panic();
          }
          $bound_check(buf, i);
          buf[i] = ((row[i] + b | 0) % 256 | 0) & 255;
          _tmp$3 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    case 3: {
      const _bind$5 = 0;
      let _tmp$4 = _bind$5;
      while (true) {
        const i = _tmp$4;
        if (i < len) {
          let a;
          if (i >= bpp) {
            const _tmp$5 = i - bpp | 0;
            $bound_check(buf, _tmp$5);
            a = buf[_tmp$5];
          } else {
            a = 0;
          }
          $bound_check(prev, i);
          const b = prev[i];
          $bound_check(row, i);
          const _tmp$5 = row[i];
          if (2 === 0) {
            $panic();
          }
          if (256 === 0) {
            $panic();
          }
          $bound_check(buf, i);
          buf[i] = ((_tmp$5 + ((a + b | 0) / 2 | 0) | 0) % 256 | 0) & 255;
          _tmp$4 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    case 4: {
      const _bind$6 = 0;
      let _tmp$5 = _bind$6;
      while (true) {
        const i = _tmp$5;
        if (i < len) {
          let a;
          if (i >= bpp) {
            const _tmp$6 = i - bpp | 0;
            $bound_check(buf, _tmp$6);
            a = buf[_tmp$6];
          } else {
            a = 0;
          }
          $bound_check(prev, i);
          const b = prev[i];
          let c$2;
          if (i >= bpp) {
            const _tmp$6 = i - bpp | 0;
            $bound_check(prev, _tmp$6);
            c$2 = prev[_tmp$6];
          } else {
            c$2 = 0;
          }
          $bound_check(row, i);
          if (256 === 0) {
            $panic();
          }
          $bound_check(buf, i);
          buf[i] = ((row[i] + _M0FP26mizchi5image16paeth__predictor(a, b, c$2) | 0) % 256 | 0) & 255;
          _tmp$5 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    default: {
      return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData(`unknown filter type: ${_M0MPC13int3Int18to__string_2einner(filter_type, 10)}`));
    }
  }
  return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(buf, 0, buf.length)));
}
function _M0FP26mizchi5image18scanline__to__rgba(row, color_type, bit_depth, palette) {
  _L: {
    switch (color_type) {
      case 4: {
        if (bit_depth === 8) {
          return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(row);
        } else {
          break _L;
        }
      }
      case 1: {
        if (bit_depth === 8) {
          if (3 === 0) {
            $panic();
          }
          const pixel_count = row.length / 3 | 0;
          const buf = $makebytes(Math.imul(pixel_count, 4) | 0, 0);
          const _bind$3 = 0;
          let _tmp$2 = _bind$3;
          while (true) {
            const i = _tmp$2;
            if (i < pixel_count) {
              const _tmp$3 = Math.imul(i, 4) | 0;
              const _tmp$4 = Math.imul(i, 3) | 0;
              $bound_check(row, _tmp$4);
              $bound_check(buf, _tmp$3);
              buf[_tmp$3] = row[_tmp$4];
              const _tmp$5 = (Math.imul(i, 4) | 0) + 1 | 0;
              const _tmp$6 = (Math.imul(i, 3) | 0) + 1 | 0;
              $bound_check(row, _tmp$6);
              $bound_check(buf, _tmp$5);
              buf[_tmp$5] = row[_tmp$6];
              const _tmp$7 = (Math.imul(i, 4) | 0) + 2 | 0;
              const _tmp$8 = (Math.imul(i, 3) | 0) + 2 | 0;
              $bound_check(row, _tmp$8);
              $bound_check(buf, _tmp$7);
              buf[_tmp$7] = row[_tmp$8];
              const _tmp$9 = (Math.imul(i, 4) | 0) + 3 | 0;
              $bound_check(buf, _tmp$9);
              buf[_tmp$9] = 255;
              _tmp$2 = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(buf, 0, buf.length)));
        } else {
          break _L;
        }
      }
      case 0: {
        if (bit_depth === 8) {
          const pixel_count = row.length;
          const buf = $makebytes(Math.imul(pixel_count, 4) | 0, 0);
          const _bind$3 = 0;
          let _tmp$2 = _bind$3;
          while (true) {
            const i = _tmp$2;
            if (i < pixel_count) {
              $bound_check(row, i);
              const v = row[i];
              const _tmp$3 = Math.imul(i, 4) | 0;
              $bound_check(buf, _tmp$3);
              buf[_tmp$3] = v;
              const _tmp$4 = (Math.imul(i, 4) | 0) + 1 | 0;
              $bound_check(buf, _tmp$4);
              buf[_tmp$4] = v;
              const _tmp$5 = (Math.imul(i, 4) | 0) + 2 | 0;
              $bound_check(buf, _tmp$5);
              buf[_tmp$5] = v;
              const _tmp$6 = (Math.imul(i, 4) | 0) + 3 | 0;
              $bound_check(buf, _tmp$6);
              buf[_tmp$6] = 255;
              _tmp$2 = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(buf, 0, buf.length)));
        } else {
          break _L;
        }
      }
      case 3: {
        if (bit_depth === 8) {
          if (2 === 0) {
            $panic();
          }
          const pixel_count = row.length / 2 | 0;
          const buf = $makebytes(Math.imul(pixel_count, 4) | 0, 0);
          const _bind$3 = 0;
          let _tmp$2 = _bind$3;
          while (true) {
            const i = _tmp$2;
            if (i < pixel_count) {
              const _tmp$3 = Math.imul(i, 2) | 0;
              $bound_check(row, _tmp$3);
              const v = row[_tmp$3];
              const _tmp$4 = (Math.imul(i, 2) | 0) + 1 | 0;
              $bound_check(row, _tmp$4);
              const a = row[_tmp$4];
              const _tmp$5 = Math.imul(i, 4) | 0;
              $bound_check(buf, _tmp$5);
              buf[_tmp$5] = v;
              const _tmp$6 = (Math.imul(i, 4) | 0) + 1 | 0;
              $bound_check(buf, _tmp$6);
              buf[_tmp$6] = v;
              const _tmp$7 = (Math.imul(i, 4) | 0) + 2 | 0;
              $bound_check(buf, _tmp$7);
              buf[_tmp$7] = v;
              const _tmp$8 = (Math.imul(i, 4) | 0) + 3 | 0;
              $bound_check(buf, _tmp$8);
              buf[_tmp$8] = a;
              _tmp$2 = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(buf, 0, buf.length)));
        } else {
          break _L;
        }
      }
      default: {
        if (bit_depth === 8) {
          let plte;
          _L$2: {
            if (palette === undefined) {
              return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("PLTE"));
            } else {
              const _Some = palette;
              const _plte = _Some;
              plte = _plte;
              break _L$2;
            }
          }
          const pixel_count = row.length;
          const buf = $makebytes(Math.imul(pixel_count, 4) | 0, 0);
          if (3 === 0) {
            $panic();
          }
          const plte_entries = plte.length / 3 | 0;
          const _bind$3 = 0;
          let _tmp$2 = _bind$3;
          while (true) {
            const i = _tmp$2;
            if (i < pixel_count) {
              $bound_check(row, i);
              const idx = row[i];
              if (idx >= plte_entries) {
                return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData(`palette index out of range: ${_M0MPC13int3Int18to__string_2einner(idx, 10)}`));
              }
              const _tmp$3 = Math.imul(i, 4) | 0;
              const _tmp$4 = Math.imul(idx, 3) | 0;
              $bound_check(plte, _tmp$4);
              $bound_check(buf, _tmp$3);
              buf[_tmp$3] = plte[_tmp$4];
              const _tmp$5 = (Math.imul(i, 4) | 0) + 1 | 0;
              const _tmp$6 = (Math.imul(idx, 3) | 0) + 1 | 0;
              $bound_check(plte, _tmp$6);
              $bound_check(buf, _tmp$5);
              buf[_tmp$5] = plte[_tmp$6];
              const _tmp$7 = (Math.imul(i, 4) | 0) + 2 | 0;
              const _tmp$8 = (Math.imul(idx, 3) | 0) + 2 | 0;
              $bound_check(plte, _tmp$8);
              $bound_check(buf, _tmp$7);
              buf[_tmp$7] = plte[_tmp$8];
              const _tmp$9 = (Math.imul(i, 4) | 0) + 3 | 0;
              $bound_check(buf, _tmp$9);
              buf[_tmp$9] = 255;
              _tmp$2 = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE2Ok(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(buf, 0, buf.length)));
        } else {
          break _L;
        }
      }
    }
  }
  return new _M0DTPC16result6ResultGzRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`unsupported color type/bit depth: ${_M0IP016_24default__implPB4Show10to__stringGRP26mizchi5image9ColorTypeE(color_type)}/${_M0MPC13int3Int18to__string_2einner(bit_depth, 10)}`));
}
function _M0FP26mizchi5image22decode__png__scanlines(ihdr, idat_parts, palette, on_row) {
  const total_idat_len = _M0MPC15array5Array4foldGziE(idat_parts, 0, (acc, b) => acc + b.length | 0);
  const idat_buf = $makebytes(total_idat_len, 0);
  const offset = new _M0TPC13ref3RefGiE(0);
  const _bind$3 = idat_parts.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const part = idat_parts[_];
      _M0MPC15array10FixedArray17blit__from__bytes(idat_buf, offset.val, part, 0, part.length);
      offset.val = offset.val + part.length | 0;
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const compressed = _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(idat_buf, 0, idat_buf.length));
  let decompressed;
  let _try_err;
  _L: {
    _L$2: {
      const _bind$4 = _M0FP26mizchi4zlib16zlib__decompress(compressed);
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        decompressed = _ok._0;
      } else {
        const _err = _bind$4;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("zlib decompression failed"));
  }
  const bpp = _M0FP26mizchi5image17bytes__per__pixel(ihdr.color_type, ihdr.bit_depth);
  const stride = Math.imul(ihdr.width, bpp) | 0;
  const expected_len = Math.imul(ihdr.height, 1 + stride | 0) | 0;
  if (decompressed.length !== expected_len) {
    return new _M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData(`decompressed size mismatch: expected ${_M0MPC13int3Int18to__string_2einner(expected_len, 10)} got ${_M0MPC13int3Int18to__string_2einner(decompressed.length, 10)}`));
  }
  const prev_row = new _M0TPC13ref3RefGzE(_M0MPC15bytes5Bytes3new(stride));
  const _bind$4 = 0;
  const _bind$5 = ihdr.height;
  let _tmp$3 = _bind$4;
  while (true) {
    const y = _tmp$3;
    if (y < _bind$5) {
      const row_offset = Math.imul(y, 1 + stride | 0) | 0;
      $bound_check(decompressed, row_offset);
      const filter_type = decompressed[row_offset];
      const filtered = $makebytes(stride, 0);
      _M0MPC15array10FixedArray17blit__from__bytes(filtered, 0, decompressed, row_offset + 1 | 0, stride);
      const filtered_bytes = _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(filtered, 0, filtered.length));
      const _bind$6 = _M0FP26mizchi5image16reconstruct__row(filter_type, filtered_bytes, prev_row.val, bpp);
      let reconstructed;
      if (_bind$6.$tag === 1) {
        const _ok = _bind$6;
        reconstructed = _ok._0;
      } else {
        return _bind$6;
      }
      const _bind$7 = _M0FP26mizchi5image18scanline__to__rgba(reconstructed, ihdr.color_type, ihdr.bit_depth, palette);
      let rgba_row;
      if (_bind$7.$tag === 1) {
        const _ok = _bind$7;
        rgba_row = _ok._0;
      } else {
        return _bind$7;
      }
      on_row(y, rgba_row);
      prev_row.val = reconstructed;
      _tmp$3 = y + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGuRP26mizchi5image11DecodeErrorE2Ok(undefined);
}
function _M0FP26mizchi5image16chunk__type__str(data, offset) {
  $bound_check(data, offset);
  const _tmp$2 = data[offset];
  const _tmp$3 = offset + 1 | 0;
  $bound_check(data, _tmp$3);
  const _tmp$4 = data[_tmp$3];
  const _tmp$5 = offset + 2 | 0;
  $bound_check(data, _tmp$5);
  const _tmp$6 = data[_tmp$5];
  const _tmp$7 = offset + 3 | 0;
  $bound_check(data, _tmp$7);
  const _bind$3 = [_tmp$2, _tmp$4, _tmp$6, data[_tmp$7]];
  return _M0MPC16string6String11from__array(new _M0TPB9ArrayViewGcE(_bind$3, 0, 4));
}
function _M0FP26mizchi5image11read__u32be(data, offset) {
  $bound_check(data, offset);
  const b0 = data[offset] & 255;
  const _tmp$2 = offset + 1 | 0;
  $bound_check(data, _tmp$2);
  const b1 = data[_tmp$2] & 255;
  const _tmp$3 = offset + 2 | 0;
  $bound_check(data, _tmp$3);
  const b2 = data[_tmp$3] & 255;
  const _tmp$4 = offset + 3 | 0;
  $bound_check(data, _tmp$4);
  const b3 = data[_tmp$4] & 255;
  return b0 << 24 | b1 << 16 | b2 << 8 | b3;
}
function _M0FP26mizchi5image13parse__chunks(raw) {
  if (raw.length < 8) {
    return new _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error47mizchi_2fimage_2eDecodeError_2eInvalidSignature("not a PNG file"));
  }
  const _bind$3 = 0;
  const _bind$4 = 8;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < _bind$4) {
      $bound_check(raw, i);
      const _tmp$3 = raw[i];
      $bound_check(_M0FP26mizchi5image14png__signature, i);
      if (_tmp$3 !== _M0FP26mizchi5image14png__signature[i]) {
        return new _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error47mizchi_2fimage_2eDecodeError_2eInvalidSignature("not a PNG file"));
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const chunks = [];
  const pos = new _M0TPC13ref3RefGiE(8);
  while (true) {
    if ((pos.val + 12 | 0) <= raw.length) {
      const length = _M0FP26mizchi5image11read__u32be(raw, pos.val);
      const ct = _M0FP26mizchi5image16chunk__type__str(raw, pos.val + 4 | 0);
      if (((pos.val + 12 | 0) + length | 0) > raw.length) {
        return new _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("chunk extends beyond file"));
      }
      const crc_data_len = 4 + length | 0;
      const crc_buf = $makebytes(crc_data_len, 0);
      _M0MPC15array10FixedArray17blit__from__bytes(crc_buf, 0, raw, pos.val + 4 | 0, crc_data_len);
      const computed_crc = _M0FP26mizchi4zlib12crc32__fixed(crc_buf);
      const stored_crc = _M0FP26mizchi5image11read__u32be(raw, (pos.val + 8 | 0) + length | 0);
      if (computed_crc !== stored_crc) {
        return new _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error46mizchi_2fimage_2eDecodeError_2eInvalidChunkCrc(ct));
      }
      let chunk_data;
      if (length > 0) {
        const buf = $makebytes(length, 0);
        _M0MPC15array10FixedArray17blit__from__bytes(buf, 0, raw, pos.val + 8 | 0, length);
        chunk_data = _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(buf, 0, buf.length));
      } else {
        chunk_data = _M0MPC15bytes5Bytes3new(0);
      }
      _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(chunks, new _M0TP26mizchi5image8PngChunk(ct, chunk_data));
      pos.val = (pos.val + 12 | 0) + length | 0;
      if (ct === "IEND") {
        break;
      }
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRPB5ArrayGRP26mizchi5image8PngChunkERP26mizchi5image11DecodeErrorE2Ok(chunks);
}
function _M0FP26mizchi5image11read__i32be(data, offset) {
  $bound_check(data, offset);
  const b0 = data[offset] & 255;
  const _tmp$2 = offset + 1 | 0;
  $bound_check(data, _tmp$2);
  const b1 = data[_tmp$2] & 255;
  const _tmp$3 = offset + 2 | 0;
  $bound_check(data, _tmp$3);
  const b2 = data[_tmp$3] & 255;
  const _tmp$4 = offset + 3 | 0;
  $bound_check(data, _tmp$4);
  const b3 = data[_tmp$4] & 255;
  return b0 << 24 | b1 << 16 | b2 << 8 | b3;
}
function _M0FP26mizchi5image11parse__ihdr(data) {
  if (data.length < 13) {
    return new _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("IHDR too short"));
  }
  const width = _M0FP26mizchi5image11read__i32be(data, 0);
  const height = _M0FP26mizchi5image11read__i32be(data, 4);
  $bound_check(data, 8);
  const bit_depth = data[8];
  $bound_check(data, 9);
  const _bind$3 = _M0FP26mizchi5image22color__type__from__png(data[9]);
  let ct;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    ct = _ok._0;
  } else {
    return _bind$3;
  }
  $bound_check(data, 10);
  const compression = data[10];
  $bound_check(data, 11);
  const filter = data[11];
  $bound_check(data, 12);
  const interlace = data[12];
  if (width <= 0 || height <= 0) {
    return new _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("invalid dimensions"));
  }
  if (interlace !== 0) {
    return new _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature("interlaced PNG not supported"));
  }
  return new _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE2Ok(new _M0TP26mizchi5image8IhdrData(width, height, bit_depth, ct, compression, filter, interlace));
}
function _M0FP26mizchi5image16parse__png__ihdr(chunks) {
  if (_M0MPC15array5Array9is__emptyGRP26mizchi5image8PngChunkE(chunks)) {
    return new _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("IHDR"));
  }
  let data;
  _L: {
    const _bind$3 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(chunks, 0);
    const _x = _bind$3.chunk_type;
    if (_x === "IHDR") {
      const _data = _bind$3.data;
      data = _data;
      break _L;
    } else {
      return new _M0DTPC16result6ResultGRP26mizchi5image8IhdrDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("IHDR must be first chunk"));
    }
  }
  return _M0FP26mizchi5image11parse__ihdr(data);
}
function _M0FP26mizchi5image11decode__png(raw) {
  const _bind$3 = _M0FP26mizchi5image13parse__chunks(raw);
  let chunks;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    chunks = _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = _M0FP26mizchi5image16parse__png__ihdr(chunks);
  let ihdr;
  if (_bind$4.$tag === 1) {
    const _ok = _bind$4;
    ihdr = _ok._0;
  } else {
    return _bind$4;
  }
  let idat_parts;
  let palette;
  _L: {
    const _bind$5 = _M0FP26mizchi5image25collect__png__image__data(chunks);
    let _bind$6;
    if (_bind$5.$tag === 1) {
      const _ok = _bind$5;
      _bind$6 = _ok._0;
    } else {
      return _bind$5;
    }
    const _idat_parts = _bind$6._0;
    const _palette = _bind$6._1;
    idat_parts = _idat_parts;
    palette = _palette;
    break _L;
  }
  const rgba_buf = $makebytes(Math.imul(Math.imul(ihdr.width, ihdr.height) | 0, 4) | 0, 0);
  const _bind$5 = _M0FP26mizchi5image22decode__png__scanlines(ihdr, idat_parts, palette, (y, row) => {
    const dst_offset = Math.imul(Math.imul(y, ihdr.width) | 0, 4) | 0;
    _M0MPC15array10FixedArray17blit__from__bytes(rgba_buf, dst_offset, row, 0, Math.imul(ihdr.width, 4) | 0);
  });
  if (_bind$5.$tag === 1) {
    const _ok = _bind$5;
    _ok._0;
  } else {
    return _bind$5;
  }
  return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE2Ok(new _M0TP26mizchi5image9ImageData(ihdr.width, ihdr.height, _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(rgba_buf, 0, rgba_buf.length))));
}
function _M0MP26mizchi5image13JpegBitReader3new(data, pos) {
  return new _M0TP26mizchi5image13JpegBitReader(data, pos, 0, 0);
}
function _M0MP26mizchi5image13JpegBitReader10next__byte(self) {
  if (self.pos >= self.data.length) {
    return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("unexpected end of JPEG data"));
  }
  const _tmp$2 = self.data;
  const _tmp$3 = self.pos;
  $bound_check(_tmp$2, _tmp$3);
  const b = _tmp$2[_tmp$3];
  self.pos = self.pos + 1 | 0;
  if (b === 255) {
    if (self.pos >= self.data.length) {
      return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("unexpected end of JPEG data after 0xFF"));
    }
    const _tmp$4 = self.data;
    const _tmp$5 = self.pos;
    $bound_check(_tmp$4, _tmp$5);
    const next = _tmp$4[_tmp$5];
    if (next === 0) {
      self.pos = self.pos + 1 | 0;
      return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok(255);
    }
    return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData(`unexpected marker in scan data: 0xFF${_M0MPC13int3Int18to__string_2einner(next, 10)}`));
  }
  return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok(b);
}
function _M0MP26mizchi5image13JpegBitReader10read__bits(self, count) {
  while (true) {
    if (self.bits_left < count) {
      const _bind$3 = _M0MP26mizchi5image13JpegBitReader10next__byte(self);
      let b;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        b = _ok._0;
      } else {
        return _bind$3;
      }
      self.bit_buf = self.bit_buf << 8 | b;
      self.bits_left = self.bits_left + 8 | 0;
      continue;
    } else {
      break;
    }
  }
  self.bits_left = self.bits_left - count | 0;
  return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok((self.bit_buf >>> self.bits_left | 0) & ((1 << count) - 1 | 0));
}
function _M0MP26mizchi5image13JpegBitReader9read__bit(self) {
  return _M0MP26mizchi5image13JpegBitReader10read__bits(self, 1);
}
function _M0FP26mizchi5image21build__huffman__table(bits, values) {
  const min_code = $make_array_len_and_init(17, 0);
  const max_code = $make_array_len_and_init(17, -1);
  const val_ptr = $make_array_len_and_init(17, 0);
  const code = new _M0TPC13ref3RefGiE(0);
  const vi = new _M0TPC13ref3RefGiE(0);
  const _bind$3 = 1;
  const _bind$4 = 16;
  let _tmp$2 = _bind$3;
  while (true) {
    const length = _tmp$2;
    if (length <= _bind$4) {
      $bound_check(val_ptr, length);
      val_ptr[length] = vi.val;
      $bound_check(bits, length);
      if (bits[length] > 0) {
        $bound_check(min_code, length);
        min_code[length] = code.val;
        const _tmp$3 = code.val;
        $bound_check(bits, length);
        code.val = _tmp$3 + bits[length] | 0;
        $bound_check(max_code, length);
        max_code[length] = code.val - 1 | 0;
        const _tmp$4 = vi.val;
        $bound_check(bits, length);
        vi.val = _tmp$4 + bits[length] | 0;
      }
      code.val = code.val << 1;
      _tmp$2 = length + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP26mizchi5image12HuffmanTable(min_code, max_code, val_ptr, values);
}
function _M0FP26mizchi5image15decode__huffman(br, table) {
  const code = new _M0TPC13ref3RefGiE(0);
  const _bind$3 = 1;
  const _bind$4 = 16;
  let _tmp$2 = _bind$3;
  while (true) {
    const length = _tmp$2;
    if (length <= _bind$4) {
      const _tmp$3 = code.val << 1;
      const _bind$5 = _M0MP26mizchi5image13JpegBitReader9read__bit(br);
      let _tmp$4;
      if (_bind$5.$tag === 1) {
        const _ok = _bind$5;
        _tmp$4 = _ok._0;
      } else {
        return _bind$5;
      }
      code.val = _tmp$3 | _tmp$4;
      let _tmp$5;
      const _tmp$6 = table.max_code;
      $bound_check(_tmp$6, length);
      if (_tmp$6[length] >= 0) {
        const _tmp$7 = code.val;
        const _tmp$8 = table.max_code;
        $bound_check(_tmp$8, length);
        _tmp$5 = _tmp$7 <= _tmp$8[length];
      } else {
        _tmp$5 = false;
      }
      if (_tmp$5) {
        const _tmp$7 = table.val_ptr;
        $bound_check(_tmp$7, length);
        const _tmp$8 = _tmp$7[length] + code.val | 0;
        const _tmp$9 = table.min_code;
        $bound_check(_tmp$9, length);
        const idx = _tmp$8 - _tmp$9[length] | 0;
        return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok(_M0MPC15array5Array2atGiE(table.values, idx));
      }
      _tmp$2 = length + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error42mizchi_2fimage_2eDecodeError_2eCorruptData("invalid Huffman code"));
}
function _M0FP26mizchi5image15receive__extend(br, nbits) {
  if (nbits === 0) {
    return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok(0);
  }
  const _bind$3 = _M0MP26mizchi5image13JpegBitReader10read__bits(br, nbits);
  let value;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    value = _ok._0;
  } else {
    return _bind$3;
  }
  return new _M0DTPC16result6ResultGiRP26mizchi5image11DecodeErrorE2Ok(value < 1 << (nbits - 1 | 0) ? (value - (1 << nbits) | 0) + 1 | 0 : value);
}
function _M0FP26mizchi5image11idct__block(coeff, output) {
  const tmp = $make_array_len_and_init(64, 0);
  const _bind$3 = 0;
  const _bind$4 = 8;
  let _tmp$2 = _bind$3;
  while (true) {
    const x = _tmp$2;
    if (x < _bind$4) {
      const _bind$5 = 0;
      const _bind$6 = 8;
      let _tmp$3 = _bind$5;
      while (true) {
        const y = _tmp$3;
        if (y < _bind$6) {
          const sum = new _M0TPC13ref3RefGdE(0);
          const _bind$7 = 0;
          const _bind$8 = 8;
          let _tmp$4 = _bind$7;
          while (true) {
            const u = _tmp$4;
            if (u < _bind$8) {
              const _tmp$5 = sum.val;
              $bound_check(_M0FP26mizchi5image7idct__c, u);
              const _tmp$6 = _M0FP26mizchi5image7idct__c[u];
              const _tmp$7 = (Math.imul(u, 8) | 0) + x | 0;
              $bound_check(coeff, _tmp$7);
              const _tmp$8 = _tmp$6 * (coeff[_tmp$7] + 0);
              const _tmp$9 = (Math.imul(y, 8) | 0) + u | 0;
              $bound_check(_M0FP26mizchi5image16idct__cos__table, _tmp$9);
              sum.val = _tmp$5 + _tmp$8 * _M0FP26mizchi5image16idct__cos__table[_tmp$9];
              _tmp$4 = u + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          const _tmp$5 = (Math.imul(y, 8) | 0) + x | 0;
          $bound_check(tmp, _tmp$5);
          tmp[_tmp$5] = sum.val;
          _tmp$3 = y + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$2 = x + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$5 = 0;
  const _bind$6 = 8;
  let _tmp$3 = _bind$5;
  while (true) {
    const y = _tmp$3;
    if (y < _bind$6) {
      const _bind$7 = 0;
      const _bind$8 = 8;
      let _tmp$4 = _bind$7;
      while (true) {
        const x = _tmp$4;
        if (x < _bind$8) {
          const sum = new _M0TPC13ref3RefGdE(0);
          const _bind$9 = 0;
          const _bind$10 = 8;
          let _tmp$5 = _bind$9;
          while (true) {
            const v = _tmp$5;
            if (v < _bind$10) {
              const _tmp$6 = sum.val;
              $bound_check(_M0FP26mizchi5image7idct__c, v);
              const _tmp$7 = _M0FP26mizchi5image7idct__c[v];
              const _tmp$8 = (Math.imul(y, 8) | 0) + v | 0;
              $bound_check(tmp, _tmp$8);
              const _tmp$9 = _tmp$7 * tmp[_tmp$8];
              const _tmp$10 = (Math.imul(x, 8) | 0) + v | 0;
              $bound_check(_M0FP26mizchi5image16idct__cos__table, _tmp$10);
              sum.val = _tmp$6 + _tmp$9 * _M0FP26mizchi5image16idct__cos__table[_tmp$10];
              _tmp$5 = v + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          const val = _M0MPC16double6Double7to__int(sum.val / 4 + 128);
          const _tmp$6 = (Math.imul(y, 8) | 0) + x | 0;
          $bound_check(output, _tmp$6);
          output[_tmp$6] = val < 0 ? 0 : val > 255 ? 255 : val;
          _tmp$4 = x + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$3 = y + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP26mizchi5image15read__u16be__at(data, pos) {
  $bound_check(data, pos);
  const _tmp$2 = (data[pos] & 255) << 8;
  const _tmp$3 = pos + 1 | 0;
  $bound_check(data, _tmp$3);
  return _tmp$2 | data[_tmp$3] & 255;
}
function _M0FP26mizchi5image11clamp__byte(v) {
  return v < 0 ? 0 : v > 255 ? 255 : v & 255;
}
function _M0FP26mizchi5image12decode__jpeg(data) {
  let _tmp$2;
  if (data.length < 2) {
    _tmp$2 = true;
  } else {
    let _tmp$3;
    $bound_check(data, 0);
    if (data[0] !== 255) {
      _tmp$3 = true;
    } else {
      $bound_check(data, 1);
      _tmp$3 = data[1] !== 216;
    }
    _tmp$2 = _tmp$3;
  }
  if (_tmp$2) {
    return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error47mizchi_2fimage_2eDecodeError_2eInvalidSignature("not a JPEG file"));
  }
  const pos = new _M0TPC13ref3RefGiE(2);
  const quant_tables = $make_array_len_and_init(4, undefined);
  const dc_tables = $make_array_len_and_init(4, undefined);
  const ac_tables = $make_array_len_and_init(4, undefined);
  const frame_info = new _M0TPC13ref3RefGORP26mizchi5image13JpegFrameInfoE(undefined);
  const scan_components = new _M0TPC13ref3RefGRPB5ArrayGRP26mizchi5image17JpegScanComponentEE([]);
  const scan_start = new _M0TPC13ref3RefGiE(0);
  while (true) {
    if ((pos.val + 1 | 0) < data.length) {
      const _tmp$3 = pos.val;
      $bound_check(data, _tmp$3);
      if (data[_tmp$3] !== 255) {
        pos.val = pos.val + 1 | 0;
        continue;
      }
      const _tmp$4 = pos.val + 1 | 0;
      $bound_check(data, _tmp$4);
      const marker = data[_tmp$4];
      pos.val = pos.val + 2 | 0;
      if (marker === 217) {
        break;
      }
      if (marker === 0 || marker === 255) {
        continue;
      }
      if (marker >= 208 && marker <= 215) {
        continue;
      }
      if ((pos.val + 1 | 0) >= data.length) {
        break;
      }
      const seg_len = _M0FP26mizchi5image15read__u16be__at(data, pos.val);
      if (marker === 219) {
        const qpos = new _M0TPC13ref3RefGiE(pos.val + 2 | 0);
        const qend = pos.val + seg_len | 0;
        while (true) {
          if (qpos.val < qend) {
            const _tmp$5 = qpos.val;
            $bound_check(data, _tmp$5);
            const pq_tq = data[_tmp$5];
            const tq = pq_tq & 15;
            const pq = pq_tq >>> 4 | 0;
            qpos.val = qpos.val + 1 | 0;
            const qt = $make_array_len_and_init(64, 0);
            if (pq === 0) {
              const _bind$3 = 0;
              const _bind$4 = 64;
              let _tmp$6 = _bind$3;
              while (true) {
                const i = _tmp$6;
                if (i < _bind$4) {
                  $bound_check(_M0FP26mizchi5image12jpeg__zigzag, i);
                  const _tmp$7 = _M0FP26mizchi5image12jpeg__zigzag[i];
                  const _tmp$8 = qpos.val + i | 0;
                  $bound_check(data, _tmp$8);
                  $bound_check(qt, _tmp$7);
                  qt[_tmp$7] = data[_tmp$8];
                  _tmp$6 = i + 1 | 0;
                  continue;
                } else {
                  break;
                }
              }
              qpos.val = qpos.val + 64 | 0;
            } else {
              const _bind$3 = 0;
              const _bind$4 = 64;
              let _tmp$6 = _bind$3;
              while (true) {
                const i = _tmp$6;
                if (i < _bind$4) {
                  $bound_check(_M0FP26mizchi5image12jpeg__zigzag, i);
                  const _tmp$7 = _M0FP26mizchi5image12jpeg__zigzag[i];
                  $bound_check(qt, _tmp$7);
                  qt[_tmp$7] = _M0FP26mizchi5image15read__u16be__at(data, qpos.val + (Math.imul(i, 2) | 0) | 0);
                  _tmp$6 = i + 1 | 0;
                  continue;
                } else {
                  break;
                }
              }
              qpos.val = qpos.val + 128 | 0;
            }
            $bound_check(quant_tables, tq);
            quant_tables[tq] = qt;
            continue;
          } else {
            break;
          }
        }
      } else {
        if (marker === 192) {
          const _tmp$5 = pos.val + 2 | 0;
          $bound_check(data, _tmp$5);
          const precision = data[_tmp$5];
          if (precision !== 8) {
            return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`unsupported bit depth: ${_M0MPC13int3Int18to__string_2einner(precision, 10)}`));
          }
          const height = _M0FP26mizchi5image15read__u16be__at(data, pos.val + 3 | 0);
          const width = _M0FP26mizchi5image15read__u16be__at(data, pos.val + 5 | 0);
          const _tmp$6 = pos.val + 7 | 0;
          $bound_check(data, _tmp$6);
          const ncomp = data[_tmp$6];
          if (ncomp !== 3 && ncomp !== 1) {
            return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error49mizchi_2fimage_2eDecodeError_2eUnsupportedFeature(`unsupported component count: ${_M0MPC13int3Int18to__string_2einner(ncomp, 10)}`));
          }
          const components = [];
          const max_h = new _M0TPC13ref3RefGiE(1);
          const max_v = new _M0TPC13ref3RefGiE(1);
          const _bind$3 = 0;
          let _tmp$7 = _bind$3;
          while (true) {
            const i = _tmp$7;
            if (i < ncomp) {
              const coff = (pos.val + 8 | 0) + (Math.imul(i, 3) | 0) | 0;
              $bound_check(data, coff);
              const id = data[coff];
              const _tmp$8 = coff + 1 | 0;
              $bound_check(data, _tmp$8);
              const sampling = data[_tmp$8];
              const h = sampling >>> 4 | 0;
              const v = sampling & 15;
              const _tmp$9 = coff + 2 | 0;
              $bound_check(data, _tmp$9);
              const qid = data[_tmp$9];
              if (h > max_h.val) {
                max_h.val = h;
              }
              if (v > max_v.val) {
                max_v.val = v;
              }
              _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(components, new _M0TP26mizchi5image13JpegComponent(id, h, v, qid));
              _tmp$7 = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          frame_info.val = new _M0TP26mizchi5image13JpegFrameInfo(width, height, components, max_h.val, max_v.val);
        } else {
          if (marker === 196) {
            const hpos = new _M0TPC13ref3RefGiE(pos.val + 2 | 0);
            const hend = pos.val + seg_len | 0;
            while (true) {
              if (hpos.val < hend) {
                const _tmp$5 = hpos.val;
                $bound_check(data, _tmp$5);
                const tc_th = data[_tmp$5];
                const tc = tc_th >>> 4 | 0;
                const th = tc_th & 15;
                hpos.val = hpos.val + 1 | 0;
                const bits = $make_array_len_and_init(17, 0);
                const total = new _M0TPC13ref3RefGiE(0);
                const _bind$3 = 1;
                const _bind$4 = 16;
                let _tmp$6 = _bind$3;
                while (true) {
                  const i = _tmp$6;
                  if (i <= _bind$4) {
                    const _tmp$7 = (hpos.val + i | 0) - 1 | 0;
                    $bound_check(data, _tmp$7);
                    $bound_check(bits, i);
                    bits[i] = data[_tmp$7];
                    const _tmp$8 = total.val;
                    $bound_check(bits, i);
                    total.val = _tmp$8 + bits[i] | 0;
                    _tmp$6 = i + 1 | 0;
                    continue;
                  } else {
                    break;
                  }
                }
                hpos.val = hpos.val + 16 | 0;
                const values = [];
                const _bind$5 = 0;
                const _bind$6 = total.val;
                let _tmp$7 = _bind$5;
                while (true) {
                  const i = _tmp$7;
                  if (i < _bind$6) {
                    const _tmp$8 = hpos.val + i | 0;
                    $bound_check(data, _tmp$8);
                    _M0MPC15array5Array4pushGiE(values, data[_tmp$8]);
                    _tmp$7 = i + 1 | 0;
                    continue;
                  } else {
                    break;
                  }
                }
                hpos.val = hpos.val + total.val | 0;
                const table = _M0FP26mizchi5image21build__huffman__table(bits, values);
                if (tc === 0) {
                  $bound_check(dc_tables, th);
                  dc_tables[th] = table;
                } else {
                  $bound_check(ac_tables, th);
                  ac_tables[th] = table;
                }
                continue;
              } else {
                break;
              }
            }
          } else {
            if (marker === 218) {
              const _tmp$5 = pos.val + 2 | 0;
              $bound_check(data, _tmp$5);
              const ns = data[_tmp$5];
              scan_components.val = [];
              const _bind$3 = 0;
              let _tmp$6 = _bind$3;
              while (true) {
                const i = _tmp$6;
                if (i < ns) {
                  const soff = (pos.val + 3 | 0) + (Math.imul(i, 2) | 0) | 0;
                  $bound_check(data, soff);
                  const cs = data[soff];
                  const _tmp$7 = soff + 1 | 0;
                  $bound_check(data, _tmp$7);
                  const td_ta = data[_tmp$7];
                  let fi;
                  const _bind$4 = frame_info.val;
                  if (_bind$4 === undefined) {
                    return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("SOF0 must precede SOS"));
                  } else {
                    const _Some = _bind$4;
                    const _fi = _Some;
                    fi = _fi;
                  }
                  const comp_idx = new _M0TPC13ref3RefGiE(0);
                  const _bind$5 = 0;
                  const _bind$6 = fi.components.length;
                  let _tmp$8 = _bind$5;
                  while (true) {
                    const j = _tmp$8;
                    if (j < _bind$6) {
                      if (_M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, j).id === cs) {
                        comp_idx.val = j;
                      }
                      _tmp$8 = j + 1 | 0;
                      continue;
                    } else {
                      break;
                    }
                  }
                  _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(scan_components.val, new _M0TP26mizchi5image17JpegScanComponent(comp_idx.val, td_ta >>> 4 | 0, td_ta & 15));
                  _tmp$6 = i + 1 | 0;
                  continue;
                } else {
                  break;
                }
              }
              scan_start.val = pos.val + seg_len | 0;
              break;
            }
          }
        }
      }
      pos.val = pos.val + seg_len | 0;
      continue;
    } else {
      break;
    }
  }
  let fi;
  const _bind$3 = frame_info.val;
  if (_bind$3 === undefined) {
    return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("SOF0"));
  } else {
    const _Some = _bind$3;
    const _fi = _Some;
    fi = _fi;
  }
  if (scan_start.val === 0) {
    return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk("SOS"));
  }
  const br = _M0MP26mizchi5image13JpegBitReader3new(data, scan_start.val);
  const mcu_w = Math.imul(fi.max_h, 8) | 0;
  const mcu_h = Math.imul(fi.max_v, 8) | 0;
  if (mcu_w === 0) {
    $panic();
  }
  const mcu_cols = ((fi.width + mcu_w | 0) - 1 | 0) / mcu_w | 0;
  if (mcu_h === 0) {
    $panic();
  }
  const mcu_rows = ((fi.height + mcu_h | 0) - 1 | 0) / mcu_h | 0;
  const ncomp = fi.components.length;
  const comp_bufs = [];
  const _bind$4 = 0;
  let _tmp$3 = _bind$4;
  while (true) {
    const i = _tmp$3;
    if (i < ncomp) {
      const c$2 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, i);
      const cw = Math.imul(Math.imul(mcu_cols, c$2.h_sample) | 0, 8) | 0;
      const ch = Math.imul(Math.imul(mcu_rows, c$2.v_sample) | 0, 8) | 0;
      _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(comp_bufs, $make_array_len_and_init(Math.imul(cw, ch) | 0, 128));
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const prev_dc = $make_array_len_and_init(ncomp, 0);
  const block = $make_array_len_and_init(64, 0);
  const idct_out = $make_array_len_and_init(64, 0);
  const _bind$5 = 0;
  let _tmp$4 = _bind$5;
  while (true) {
    const mcu_y = _tmp$4;
    if (mcu_y < mcu_rows) {
      const _bind$6 = 0;
      let _tmp$5 = _bind$6;
      while (true) {
        const mcu_x = _tmp$5;
        if (mcu_x < mcu_cols) {
          const _bind$7 = 0;
          const _bind$8 = scan_components.val.length;
          let _tmp$6 = _bind$7;
          while (true) {
            const si = _tmp$6;
            if (si < _bind$8) {
              const sc = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(scan_components.val, si);
              const ci = sc.comp_idx;
              const c$2 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, ci);
              let dc_tab;
              const _tmp$7 = sc.dc_table_id;
              $bound_check(dc_tables, _tmp$7);
              const _bind$9 = dc_tables[_tmp$7];
              if (_bind$9 === undefined) {
                return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk(`DC Huffman table ${_M0MPC13int3Int18to__string_2einner(sc.dc_table_id, 10)}`));
              } else {
                const _Some = _bind$9;
                const _t = _Some;
                dc_tab = _t;
              }
              let ac_tab;
              const _tmp$8 = sc.ac_table_id;
              $bound_check(ac_tables, _tmp$8);
              const _bind$10 = ac_tables[_tmp$8];
              if (_bind$10 === undefined) {
                return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk(`AC Huffman table ${_M0MPC13int3Int18to__string_2einner(sc.ac_table_id, 10)}`));
              } else {
                const _Some = _bind$10;
                const _t = _Some;
                ac_tab = _t;
              }
              let qt;
              const _tmp$9 = c$2.quant_id;
              $bound_check(quant_tables, _tmp$9);
              const _bind$11 = quant_tables[_tmp$9];
              if (_bind$11 === undefined) {
                return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE3Err(new _M0DTPC15error5Error43mizchi_2fimage_2eDecodeError_2eMissingChunk(`quantization table ${_M0MPC13int3Int18to__string_2einner(c$2.quant_id, 10)}`));
              } else {
                const _Some = _bind$11;
                const _t = _Some;
                qt = _t;
              }
              const _bind$12 = 0;
              const _bind$13 = c$2.v_sample;
              let _tmp$10 = _bind$12;
              while (true) {
                const bv = _tmp$10;
                if (bv < _bind$13) {
                  const _bind$14 = 0;
                  const _bind$15 = c$2.h_sample;
                  let _tmp$11 = _bind$14;
                  while (true) {
                    const bh = _tmp$11;
                    if (bh < _bind$15) {
                      const _bind$16 = _M0FP26mizchi5image15decode__huffman(br, dc_tab);
                      let dc_cat;
                      if (_bind$16.$tag === 1) {
                        const _ok = _bind$16;
                        dc_cat = _ok._0;
                      } else {
                        return _bind$16;
                      }
                      const _bind$17 = _M0FP26mizchi5image15receive__extend(br, dc_cat);
                      let dc_diff;
                      if (_bind$17.$tag === 1) {
                        const _ok = _bind$17;
                        dc_diff = _ok._0;
                      } else {
                        return _bind$17;
                      }
                      const _array_1 = prev_dc;
                      const _index_2 = ci;
                      $bound_check(_array_1, _index_2);
                      $bound_check(_array_1, _index_2);
                      _array_1[_index_2] = _array_1[_index_2] + dc_diff | 0;
                      const _bind$18 = 0;
                      const _bind$19 = 64;
                      let _tmp$12 = _bind$18;
                      while (true) {
                        const i = _tmp$12;
                        if (i < _bind$19) {
                          $bound_check(block, i);
                          block[i] = 0;
                          _tmp$12 = i + 1 | 0;
                          continue;
                        } else {
                          break;
                        }
                      }
                      $bound_check(prev_dc, ci);
                      const _tmp$13 = prev_dc[ci];
                      $bound_check(qt, 0);
                      $bound_check(block, 0);
                      block[0] = Math.imul(_tmp$13, qt[0]) | 0;
                      const k = new _M0TPC13ref3RefGiE(1);
                      while (true) {
                        if (k.val < 64) {
                          const _bind$20 = _M0FP26mizchi5image15decode__huffman(br, ac_tab);
                          let rs;
                          if (_bind$20.$tag === 1) {
                            const _ok = _bind$20;
                            rs = _ok._0;
                          } else {
                            return _bind$20;
                          }
                          const run = rs >>> 4 | 0;
                          const size = rs & 15;
                          if (size === 0) {
                            if (run === 0) {
                              break;
                            }
                            if (run === 15) {
                              k.val = k.val + 16 | 0;
                              continue;
                            }
                            break;
                          }
                          k.val = k.val + run | 0;
                          if (k.val >= 64) {
                            break;
                          }
                          const _bind$21 = _M0FP26mizchi5image15receive__extend(br, size);
                          let ac_val;
                          if (_bind$21.$tag === 1) {
                            const _ok = _bind$21;
                            ac_val = _ok._0;
                          } else {
                            return _bind$21;
                          }
                          const _tmp$14 = k.val;
                          $bound_check(_M0FP26mizchi5image12jpeg__zigzag, _tmp$14);
                          const _tmp$15 = _M0FP26mizchi5image12jpeg__zigzag[_tmp$14];
                          const _tmp$16 = k.val;
                          $bound_check(_M0FP26mizchi5image12jpeg__zigzag, _tmp$16);
                          const _tmp$17 = _M0FP26mizchi5image12jpeg__zigzag[_tmp$16];
                          $bound_check(qt, _tmp$17);
                          $bound_check(block, _tmp$15);
                          block[_tmp$15] = Math.imul(ac_val, qt[_tmp$17]) | 0;
                          k.val = k.val + 1 | 0;
                          continue;
                        } else {
                          break;
                        }
                      }
                      _M0FP26mizchi5image11idct__block(block, idct_out);
                      const comp_stride = Math.imul(Math.imul(mcu_cols, c$2.h_sample) | 0, 8) | 0;
                      const bx = Math.imul((Math.imul(mcu_x, c$2.h_sample) | 0) + bh | 0, 8) | 0;
                      const by = Math.imul((Math.imul(mcu_y, c$2.v_sample) | 0) + bv | 0, 8) | 0;
                      const _bind$20 = 0;
                      const _bind$21 = 8;
                      let _tmp$14 = _bind$20;
                      while (true) {
                        const yy = _tmp$14;
                        if (yy < _bind$21) {
                          const _bind$22 = 0;
                          const _bind$23 = 8;
                          let _tmp$15 = _bind$22;
                          while (true) {
                            const xx = _tmp$15;
                            if (xx < _bind$23) {
                              const _tmp$16 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(comp_bufs, ci);
                              const _tmp$17 = ((Math.imul(by + yy | 0, comp_stride) | 0) + bx | 0) + xx | 0;
                              const _tmp$18 = (Math.imul(yy, 8) | 0) + xx | 0;
                              $bound_check(idct_out, _tmp$18);
                              $bound_check(_tmp$16, _tmp$17);
                              _tmp$16[_tmp$17] = idct_out[_tmp$18];
                              _tmp$15 = xx + 1 | 0;
                              continue;
                            } else {
                              break;
                            }
                          }
                          _tmp$14 = yy + 1 | 0;
                          continue;
                        } else {
                          break;
                        }
                      }
                      _tmp$11 = bh + 1 | 0;
                      continue;
                    } else {
                      break;
                    }
                  }
                  _tmp$10 = bv + 1 | 0;
                  continue;
                } else {
                  break;
                }
              }
              _tmp$6 = si + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _tmp$5 = mcu_x + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$4 = mcu_y + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const out_buf = $makebytes(Math.imul(Math.imul(fi.width, fi.height) | 0, 4) | 0, 0);
  if (ncomp === 1) {
    const _bind$6 = 0;
    const _bind$7 = fi.height;
    let _tmp$5 = _bind$6;
    while (true) {
      const y = _tmp$5;
      if (y < _bind$7) {
        const _bind$8 = 0;
        const _bind$9 = fi.width;
        let _tmp$6 = _bind$8;
        while (true) {
          const x = _tmp$6;
          if (x < _bind$9) {
            const comp_stride = Math.imul(Math.imul(mcu_cols, _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, 0).h_sample) | 0, 8) | 0;
            const _tmp$7 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(comp_bufs, 0);
            const _tmp$8 = (Math.imul(y, comp_stride) | 0) + x | 0;
            $bound_check(_tmp$7, _tmp$8);
            const v = _tmp$7[_tmp$8];
            const val = _M0FP26mizchi5image11clamp__byte(v);
            const idx = Math.imul((Math.imul(y, fi.width) | 0) + x | 0, 4) | 0;
            $bound_check(out_buf, idx);
            out_buf[idx] = val;
            const _tmp$9 = idx + 1 | 0;
            $bound_check(out_buf, _tmp$9);
            out_buf[_tmp$9] = val;
            const _tmp$10 = idx + 2 | 0;
            $bound_check(out_buf, _tmp$10);
            out_buf[_tmp$10] = val;
            const _tmp$11 = idx + 3 | 0;
            $bound_check(out_buf, _tmp$11);
            out_buf[_tmp$11] = 255;
            _tmp$6 = x + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _tmp$5 = y + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  } else {
    const c0 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, 0);
    const c1 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, 1);
    const c2 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(fi.components, 2);
    const stride_y = Math.imul(Math.imul(mcu_cols, c0.h_sample) | 0, 8) | 0;
    const stride_cb = Math.imul(Math.imul(mcu_cols, c1.h_sample) | 0, 8) | 0;
    const stride_cr = Math.imul(Math.imul(mcu_cols, c2.h_sample) | 0, 8) | 0;
    const _bind$6 = 0;
    const _bind$7 = fi.height;
    let _tmp$5 = _bind$6;
    while (true) {
      const py = _tmp$5;
      if (py < _bind$7) {
        const _bind$8 = 0;
        const _bind$9 = fi.width;
        let _tmp$6 = _bind$8;
        while (true) {
          const px = _tmp$6;
          if (px < _bind$9) {
            const _tmp$7 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(comp_bufs, 0);
            const _tmp$8 = (Math.imul(py, stride_y) | 0) + px | 0;
            $bound_check(_tmp$7, _tmp$8);
            const yy = _tmp$7[_tmp$8];
            if (fi.max_h === 0) {
              $panic();
            }
            const cb_x = (Math.imul(px, c1.h_sample) | 0) / fi.max_h | 0;
            if (fi.max_v === 0) {
              $panic();
            }
            const cb_y = (Math.imul(py, c1.v_sample) | 0) / fi.max_v | 0;
            if (fi.max_h === 0) {
              $panic();
            }
            const cr_x = (Math.imul(px, c2.h_sample) | 0) / fi.max_h | 0;
            if (fi.max_v === 0) {
              $panic();
            }
            const cr_y = (Math.imul(py, c2.v_sample) | 0) / fi.max_v | 0;
            const _tmp$9 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(comp_bufs, 1);
            const _tmp$10 = (Math.imul(cb_y, stride_cb) | 0) + cb_x | 0;
            $bound_check(_tmp$9, _tmp$10);
            const cb = _tmp$9[_tmp$10];
            const _tmp$11 = _M0MPC15array5Array2atGRP26mizchi5image13JpegComponentE(comp_bufs, 2);
            const _tmp$12 = (Math.imul(cr_y, stride_cr) | 0) + cr_x | 0;
            $bound_check(_tmp$11, _tmp$12);
            const cr = _tmp$11[_tmp$12];
            const y_val = yy + 0;
            const cb_val = (cb - 128 | 0) + 0;
            const cr_val = (cr - 128 | 0) + 0;
            const r = _M0MPC16double6Double7to__int(y_val + 1.402 * cr_val);
            const g = _M0MPC16double6Double7to__int(y_val - 0.344136 * cb_val - 0.714136 * cr_val);
            const b = _M0MPC16double6Double7to__int(y_val + 1.772 * cb_val);
            const idx = Math.imul((Math.imul(py, fi.width) | 0) + px | 0, 4) | 0;
            $bound_check(out_buf, idx);
            out_buf[idx] = _M0FP26mizchi5image11clamp__byte(r);
            const _tmp$13 = idx + 1 | 0;
            $bound_check(out_buf, _tmp$13);
            out_buf[_tmp$13] = _M0FP26mizchi5image11clamp__byte(g);
            const _tmp$14 = idx + 2 | 0;
            $bound_check(out_buf, _tmp$14);
            out_buf[_tmp$14] = _M0FP26mizchi5image11clamp__byte(b);
            const _tmp$15 = idx + 3 | 0;
            $bound_check(out_buf, _tmp$15);
            out_buf[_tmp$15] = 255;
            _tmp$6 = px + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _tmp$5 = py + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE2Ok(new _M0TP26mizchi5image9ImageData(fi.width, fi.height, _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(out_buf, 0, out_buf.length))));
}
function _M0FP26mizchi5image11decode__bmp(raw) {
  const _bind$3 = _M0FP26mizchi5image16parse__bmp__info(raw);
  let info;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    info = _ok._0;
  } else {
    return _bind$3;
  }
  const rgba_buf = $makebytes(Math.imul(Math.imul(info.width, info.height) | 0, 4) | 0, 0);
  _M0FP26mizchi5image17decode__bmp__rows(raw, info, (y, row) => {
    const dst_offset = Math.imul(Math.imul(y, info.width) | 0, 4) | 0;
    _M0MPC15array10FixedArray17blit__from__bytes(rgba_buf, dst_offset, row, 0, Math.imul(info.width, 4) | 0);
  });
  return new _M0DTPC16result6ResultGRP26mizchi5image9ImageDataRP26mizchi5image11DecodeErrorE2Ok(new _M0TP26mizchi5image9ImageData(info.width, info.height, _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(rgba_buf, 0, rgba_buf.length))));
}
function _M0FP36mizchi6kagura4core18new__outside__size(width, height) {
  return new _M0TP36mizchi6kagura4core11OutsideSize(width, height);
}
function _M0FP36mizchi6kagura4core17new__touch__point(id, x, y) {
  return new _M0TP36mizchi6kagura4core10TouchPoint(id, x, y, 3);
}
function _M0FP36mizchi6kagura4core22new__gamepad__snapshot(id, axes, pressed_buttons) {
  return new _M0TP36mizchi6kagura4core15GamepadSnapshot(id, axes, pressed_buttons);
}
function _M0FP36mizchi6kagura4core26new__input__snapshot__full(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, pressed_mouse_buttons, touches, gamepads) {
  return new _M0TP36mizchi6kagura4core13InputSnapshot(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, pressed_mouse_buttons, touches, gamepads);
}
function _M0FP36mizchi6kagura4core20new__input__snapshot(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys) {
  return _M0FP36mizchi6kagura4core26new__input__snapshot__full(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, [], [], []);
}
function _M0FP36mizchi6kagura4core22empty__input__snapshot() {
  return _M0FP36mizchi6kagura4core20new__input__snapshot(0, 0, 0, 0, []);
}
function _M0FP36mizchi6kagura8platform23new__web__canvas__hooks(try_initialize, poll, should_close, outside_size, current_surface, capture_input, set_fullscreen, is_fullscreen, set_cursor_mode, cursor_mode, set_device_scale_factor, device_scale_factor, set_vsync_enabled, is_vsync_enabled, close_window, request_attention, set_mouse_touch_fallback, mouse_touch_fallback_enabled, fullscreen_request_status, cursor_mode_request_status) {
  return new _M0TP36mizchi6kagura8platform14WebCanvasHooks(try_initialize, poll, should_close, outside_size, current_surface, capture_input, set_fullscreen, is_fullscreen, set_cursor_mode, cursor_mode, set_device_scale_factor, device_scale_factor, set_vsync_enabled, is_vsync_enabled, close_window, request_attention, set_mouse_touch_fallback, mouse_touch_fallback_enabled, fullscreen_request_status, cursor_mode_request_status);
}
function _M0FP36mizchi6kagura8platform29default__web__try__initialize(_canvas_selector, _options) {
  return false;
}
function _M0FP36mizchi6kagura8platform18default__web__poll(_active) {}
function _M0FP36mizchi6kagura8platform27default__web__should__close() {
  return false;
}
function _M0FP36mizchi6kagura8platform27default__web__outside__size(width, height) {
  return _M0FP36mizchi6kagura4core18new__outside__size(width + 0, height + 0);
}
function _M0FP36mizchi6kagura8platform30default__web__current__surface(_canvas_selector, options) {
  return new _M0TP36mizchi6kagura8platform12SurfaceToken(1, 2, options.width, options.height, 1);
}
function _M0FP36mizchi6kagura8platform28default__web__capture__input(_active, _tick) {
  return _M0FP36mizchi6kagura4core22empty__input__snapshot();
}
function _M0FP36mizchi6kagura8platform29default__web__set__fullscreen(_canvas_selector, _active, enabled) {
  return enabled;
}
function _M0FP36mizchi6kagura8platform28default__web__is__fullscreen(_canvas_selector, _active, current) {
  return current;
}
function _M0FP36mizchi6kagura8platform31default__web__set__cursor__mode(_canvas_selector, _active, mode) {
  return mode;
}
function _M0FP36mizchi6kagura8platform26default__web__cursor__mode(_canvas_selector, _active, current) {
  return current;
}
function _M0FP36mizchi6kagura8platform40default__web__set__device__scale__factor(_canvas_selector, _active, scale) {
  return scale <= 0 ? 1 : scale;
}
function _M0FP36mizchi6kagura8platform35default__web__device__scale__factor(_canvas_selector, _active, current) {
  return current <= 0 ? 1 : current;
}
function _M0FP36mizchi6kagura8platform33default__web__set__vsync__enabled(_canvas_selector, _active, enabled) {
  return enabled;
}
function _M0FP36mizchi6kagura8platform32default__web__is__vsync__enabled(_canvas_selector, _active, current) {
  return current;
}
function _M0FP36mizchi6kagura8platform27default__web__close__window(_canvas_selector, _active) {}
function _M0FP36mizchi6kagura8platform32default__web__request__attention(_canvas_selector, _active) {}
function _M0FP36mizchi6kagura8platform41default__web__set__mouse__touch__fallback(_canvas_selector, _active, _enabled) {}
function _M0FP36mizchi6kagura8platform45default__web__mouse__touch__fallback__enabled(_canvas_selector, _active) {
  return false;
}
function _M0FP36mizchi6kagura8platform41default__web__fullscreen__request__status(_canvas_selector, _active, current) {
  return current;
}
function _M0FP36mizchi6kagura8platform43default__web__cursor__mode__request__status(_canvas_selector, _active, current) {
  return current;
}
function _M0FP36mizchi6kagura8platform27default__web__canvas__hooks() {
  return _M0FP36mizchi6kagura8platform23new__web__canvas__hooks(_M0FP36mizchi6kagura8platform29default__web__try__initialize, _M0FP36mizchi6kagura8platform18default__web__poll, _M0FP36mizchi6kagura8platform27default__web__should__close, _M0FP36mizchi6kagura8platform27default__web__outside__size, _M0FP36mizchi6kagura8platform30default__web__current__surface, _M0FP36mizchi6kagura8platform28default__web__capture__input, _M0FP36mizchi6kagura8platform29default__web__set__fullscreen, _M0FP36mizchi6kagura8platform28default__web__is__fullscreen, _M0FP36mizchi6kagura8platform31default__web__set__cursor__mode, _M0FP36mizchi6kagura8platform26default__web__cursor__mode, _M0FP36mizchi6kagura8platform40default__web__set__device__scale__factor, _M0FP36mizchi6kagura8platform35default__web__device__scale__factor, _M0FP36mizchi6kagura8platform33default__web__set__vsync__enabled, _M0FP36mizchi6kagura8platform32default__web__is__vsync__enabled, _M0FP36mizchi6kagura8platform27default__web__close__window, _M0FP36mizchi6kagura8platform32default__web__request__attention, _M0FP36mizchi6kagura8platform41default__web__set__mouse__touch__fallback, _M0FP36mizchi6kagura8platform45default__web__mouse__touch__fallback__enabled, _M0FP36mizchi6kagura8platform41default__web__fullscreen__request__status, _M0FP36mizchi6kagura8platform43default__web__cursor__mode__request__status);
}
function _M0FP36mizchi6kagura8platform23set__web__canvas__hooks(hooks) {
  _M0FP36mizchi6kagura8platform18web__canvas__hooks.val = hooks;
}
function _M0FP36mizchi6kagura8platform25reset__web__canvas__hooks() {
  _M0FP36mizchi6kagura8platform18web__canvas__hooks.val = _M0FP36mizchi6kagura8platform27default__web__canvas__hooks();
}
function _M0FP36mizchi6kagura8platform20web__try__initialize(canvas_selector, options) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.try_initialize;
  return _func(canvas_selector, options);
}
function _M0FP36mizchi6kagura8platform9web__poll(active) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.poll;
  _func(active);
}
function _M0FP36mizchi6kagura8platform18web__outside__size(width, height) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.outside_size;
  return _func(width, height);
}
function _M0FP36mizchi6kagura8platform21web__current__surface(canvas_selector, options) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.current_surface;
  return _func(canvas_selector, options);
}
function _M0FP36mizchi6kagura8platform19web__capture__input(active, tick) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.capture_input;
  return _func(active, tick);
}
function _M0FP36mizchi6kagura8platform19web__is__fullscreen(canvas_selector, active, current) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.is_fullscreen;
  return _func(canvas_selector, active, current);
}
function _M0FP36mizchi6kagura8platform17web__cursor__mode(canvas_selector, active, current) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.cursor_mode;
  return _func(canvas_selector, active, current);
}
function _M0FP36mizchi6kagura8platform26web__device__scale__factor(canvas_selector, active, current) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.device_scale_factor;
  return _func(canvas_selector, active, current);
}
function _M0FP36mizchi6kagura8platform23web__is__vsync__enabled(canvas_selector, active, current) {
  const _func = _M0FP36mizchi6kagura8platform18web__canvas__hooks.val.is_vsync_enabled;
  return _func(canvas_selector, active, current);
}
function _M0FP36mizchi6kagura8platform33create__offscreen__surface__token(width, height) {
  return new _M0TP36mizchi6kagura8platform12SurfaceToken(3, 0, width, height, 1);
}
function _M0FP36mizchi6kagura8platform30create__webgpu__surface__token(opaque_id, width, height, device_scale_factor) {
  return new _M0TP36mizchi6kagura8platform12SurfaceToken(1, opaque_id, width, height, device_scale_factor);
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform15SurfaceProvider16current__surface(self) {
  return new _M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE2Ok(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : new _M0TP36mizchi6kagura8platform12SurfaceToken(1, 2, self.options.width, self.options.height, 1));
}
function _M0FP36mizchi6kagura8platform21cursor__mode__to__int(mode) {
  switch (mode) {
    case 0: {
      return 0;
    }
    case 1: {
      return 1;
    }
    default: {
      return 2;
    }
  }
}
function _M0FP36mizchi6kagura8platform23cursor__mode__from__int(mode) {
  switch (mode) {
    case 1: {
      return 1;
    }
    case 2: {
      return 2;
    }
    default: {
      return 0;
    }
  }
}
function _M0FP36mizchi6kagura8platform28new__window__options_2einner(title, width, height, transparent, resizable, focused) {
  return new _M0TP36mizchi6kagura8platform13WindowOptions(title, width, height, transparent, resizable, focused);
}
function _M0FP36mizchi6kagura8platform29create__web__canvas__platform(canvas_selector) {
  return new _M0TP36mizchi6kagura8platform17WebCanvasPlatform(canvas_selector, false, 0, 2, false, new _M0TP36mizchi6kagura8platform13WindowOptions("kagura-web", 800, 600, true, true, true), _M0FP36mizchi6kagura4core22empty__input__snapshot(), false, 0, 1, true, false, 0, false, 0, 0);
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver10initialize(self, options) {
  self.options = options;
  self.web_active = _M0FP36mizchi6kagura8platform20web__try__initialize(self.canvas_selector, options);
  self.initialized = true;
  self.poll_count = 0;
  self.close_requested = false;
  self.attention_requests = 0;
  self.fullscreen = _M0FP36mizchi6kagura8platform19web__is__fullscreen(self.canvas_selector, self.web_active, self.fullscreen);
  self.cursor_mode = _M0FP36mizchi6kagura8platform17web__cursor__mode(self.canvas_selector, self.web_active, self.cursor_mode);
  self.device_scale_factor = _M0FP36mizchi6kagura8platform26web__device__scale__factor(self.canvas_selector, self.web_active, self.device_scale_factor);
  self.vsync_enabled = _M0FP36mizchi6kagura8platform23web__is__vsync__enabled(self.canvas_selector, self.web_active, self.vsync_enabled);
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver12poll__events(self) {
  if (self.initialized) {
    _M0FP36mizchi6kagura8platform9web__poll(self.web_active);
    self.poll_count = self.poll_count + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver13outside__size(self) {
  return self.web_active ? _M0FP36mizchi6kagura8platform18web__outside__size(self.options.width, self.options.height) : _M0FP36mizchi6kagura4core18new__outside__size(self.options.width + 0, self.options.height + 0);
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver14capture__input(self, tick) {
  self.current_input = _M0FP36mizchi6kagura8platform19web__capture__input(self.web_active, tick);
  return self.current_input;
}
function _M0FP36mizchi6kagura3gfx21double__to__f32__bits(v) {
  const bits = _M0MPC16double6Double22reinterpret__as__int64(v);
  const ubits = bits;
  const sign = _M0MPC15int645Int647to__int(_M0IPC16uint646UInt64PB6BitAnd4land(_M0IPC16uint646UInt64PB3Shr3shr(ubits, 63), $1L));
  const exp = _M0MPC15int645Int647to__int(_M0IPC16uint646UInt64PB6BitAnd4land(_M0IPC16uint646UInt64PB3Shr3shr(ubits, 52), $2047L));
  const mantissa = _M0IPC15int645Int64PB6BitAnd4land(bits, $4503599627370495L);
  if (exp === 2047) {
    return _M0IP016_24default__implPB2Eq10not__equalGlE(mantissa, $0L) ? sign << 31 | 2143289344 : sign << 31 | 2139095040;
  } else {
    if (exp === 0) {
      return sign << 31;
    } else {
      const f32_exp = (exp - 1023 | 0) + 127 | 0;
      if (f32_exp >= 255) {
        return sign << 31 | 2139095040;
      } else {
        if (f32_exp <= 0) {
          return sign << 31;
        } else {
          const f32_mantissa = _M0MPC15int645Int647to__int(_M0IPC16uint646UInt64PB3Shr3shr(mantissa, 29));
          return sign << 31 | f32_exp << 23 | f32_mantissa;
        }
      }
    }
  }
}
function _M0FP36mizchi6kagura3gfx20builtin__filter__tag(filter) {
  switch (filter) {
    case 0: {
      return "nearest";
    }
    case 1: {
      return "linear";
    }
    default: {
      return "pixelated";
    }
  }
}
function _M0FP36mizchi6kagura3gfx21builtin__address__tag(address) {
  switch (address) {
    case 0: {
      return "unsafe";
    }
    case 1: {
      return "clamp_to_zero";
    }
    case 2: {
      return "clamp_to_edge";
    }
    case 3: {
      return "repeat";
    }
    default: {
      return "mirror_repeat";
    }
  }
}
function _M0FP36mizchi6kagura3gfx25builtin__address__snippet(address) {
  switch (address) {
    case 0: {
      return "// address: unsafe\n  let sample_uv = uv;";
    }
    case 1: {
      return "if uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0 {\n    return vec4f(0.0, 0.0, 0.0, 0.0);\n  }\n  let sample_uv = uv;";
    }
    case 2: {
      return "let sample_uv = clamp(uv, vec2f(0.0), vec2f(1.0));";
    }
    case 3: {
      return "// address: repeat\n  let sample_uv = fract(uv);";
    }
    default: {
      return "// address: mirror_repeat\n  let sample_uv = abs(fract(uv * 0.5) * 2.0 - 1.0);";
    }
  }
}
function _M0FP36mizchi6kagura3gfx24builtin__sample__snippet(filter) {
  switch (filter) {
    case 0: {
      return "textureSampleLevel(tex, nearest_sampler, sample_uv, 0.0)";
    }
    case 1: {
      return "textureSample(tex, linear_sampler, sample_uv)";
    }
    default: {
      return "textureSampleLevel(tex, nearest_sampler, floor(sample_uv * vec2f(256.0, 256.0)) / vec2f(256.0, 256.0), 0.0)";
    }
  }
}
function _M0FP36mizchi6kagura3gfx26builtin__color__m__snippet(use_color_m) {
  return use_color_m ? "let color_m = mat4x4f(\n    vec4f(1.0, 0.0, 0.0, 0.0),\n    vec4f(0.0, 1.0, 0.0, 0.0),\n    vec4f(0.0, 0.0, 1.0, 0.0),\n    vec4f(0.0, 0.0, 0.0, 1.0),\n  );\n  color = color_m * color;" : "// color matrix disabled";
}
function _M0FP36mizchi6kagura3gfx30build__builtin__shader__source(key) {
  const address_snippet = _M0FP36mizchi6kagura3gfx25builtin__address__snippet(key.address);
  const sample_snippet = _M0FP36mizchi6kagura3gfx24builtin__sample__snippet(key.filter);
  const color_m_snippet = _M0FP36mizchi6kagura3gfx26builtin__color__m__snippet(key.use_color_m);
  const color_m_tag = key.use_color_m ? "on" : "off";
  const header = `// kagura builtin shader\n// filter:${_M0IPC16string6StringPB4Show10to__string(_M0FP36mizchi6kagura3gfx20builtin__filter__tag(key.filter))}\n// address:${_M0IPC16string6StringPB4Show10to__string(_M0FP36mizchi6kagura3gfx21builtin__address__tag(key.address))}\n// color_m:${_M0IPC16string6StringPB4Show10to__string(color_m_tag)}\n`;
  const bindings = "@group(0) @binding(0) var tex: texture_2d<f32>;\n@group(0) @binding(1) var nearest_sampler: sampler;\n@group(0) @binding(2) var linear_sampler: sampler;\n\n";
  const structs = "struct VertexOutput {\n  @builtin(position) pos: vec4f,\n  @location(0) uv: vec2f,\n};\n\n";
  const body = `@fragment\nfn fs_main(in: VertexOutput) -> @location(0) vec4f {\n  let uv = in.uv;\n  ${_M0IPC16string6StringPB4Show10to__string(address_snippet)}\n  var color = ${_M0IPC16string6StringPB4Show10to__string(sample_snippet)};\n  ${_M0IPC16string6StringPB4Show10to__string(color_m_snippet)}\n  return color;\n}\n`;
  return `${header}${bindings}${structs}${body}`;
}
function _M0FP36mizchi6kagura3gfx32default__builtin__shader__source() {
  return _M0FP36mizchi6kagura3gfx30build__builtin__shader__source(new _M0TP36mizchi6kagura3gfx16BuiltinShaderKey(0, 0, false));
}
function _M0FP36mizchi6kagura3gfx16new__dst__region(x, y, width, height, index_count) {
  return new _M0TP36mizchi6kagura3gfx9DstRegion(x, y, width, height, index_count);
}
function _M0FP36mizchi6kagura3gfx10new__color(r, g, b, a) {
  return new _M0TP36mizchi6kagura3gfx5Color(r, g, b, a);
}
function _M0FP36mizchi6kagura3gfx31new__render__pass__desc_2einner(clear_color, clear_enabled, present) {
  return new _M0TP36mizchi6kagura3gfx14RenderPassDesc(clear_color, clear_enabled, present);
}
function _M0FP36mizchi6kagura3gfx20blend__mode__to__int(mode) {
  switch (mode.$tag) {
    case 0: {
      return 0;
    }
    case 1: {
      return 1;
    }
    case 2: {
      return 2;
    }
    case 3: {
      return 3;
    }
    default: {
      return 4;
    }
  }
}
function _M0FP36mizchi6kagura3gfx22blend__mode__from__int(mode) {
  switch (mode) {
    case 0: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode4Copy__;
    }
    case 1: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha__;
    }
    case 2: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode3Add__;
    }
    case 3: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply__;
    }
    default: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha__;
    }
  }
}
function _M0FP36mizchi6kagura3gfx18new__image__handle(id, width, height) {
  return new _M0TP36mizchi6kagura3gfx11ImageHandle(id, width, height);
}
function _M0FP36mizchi6kagura3gfx19new__shader__handle(id, source) {
  return new _M0TP36mizchi6kagura3gfx12ShaderHandle(id, source);
}
function _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, dst_regions, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, uniform_dwords, instance_count, resource_cache_key) {
  return new _M0TP36mizchi6kagura3gfx20DrawTrianglesCommand(dst, shader, dst_regions, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, uniform_dwords, instance_count, resource_cache_key);
}
function _M0FP36mizchi6kagura3gfx25mix__resource__cache__key(seed, value) {
  return ((Math.imul(seed, 16777619) | 0) + value | 0) + 31 | 0;
}
function _M0FP36mizchi6kagura3gfx27build__resource__cache__key(seed, values) {
  const hash = new _M0TPC13ref3RefGiE(seed === 0 ? 146959810 : seed);
  const _bind$3 = values.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const value = values[_];
      hash.val = _M0FP36mizchi6kagura3gfx25mix__resource__cache__key(hash.val, value);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return hash.val === 0 ? 1 : hash.val;
}
function _M0FP36mizchi6kagura3gfx30default__web__on__read__pixels(_active, _kind, _x, _y, _width, _height) {
  return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
}
function _M0FP36mizchi6kagura3gfx25new__web__graphics__hooks(try_initialize, on_begin, on_end, on_draw, on_resize) {
  return new _M0TP36mizchi6kagura3gfx16WebGraphicsHooks(try_initialize, on_begin, on_end, on_draw, on_resize, _M0FP36mizchi6kagura3gfx30default__web__on__read__pixels);
}
function _M0FP36mizchi6kagura3gfx29default__web__try__initialize(_kind, _width, _height) {
  return false;
}
function _M0FP36mizchi6kagura3gfx23default__web__on__begin(_active, _kind, _pass) {}
function _M0FP36mizchi6kagura3gfx21default__web__on__end(_active, _kind, _present) {}
function _M0FP36mizchi6kagura3gfx22default__web__on__draw(_active, _kind, _command) {}
function _M0FP36mizchi6kagura3gfx24default__web__on__resize(_active, _kind, _width, _height) {}
function _M0FP36mizchi6kagura3gfx29default__web__graphics__hooks() {
  return _M0FP36mizchi6kagura3gfx25new__web__graphics__hooks(_M0FP36mizchi6kagura3gfx29default__web__try__initialize, _M0FP36mizchi6kagura3gfx23default__web__on__begin, _M0FP36mizchi6kagura3gfx21default__web__on__end, _M0FP36mizchi6kagura3gfx22default__web__on__draw, _M0FP36mizchi6kagura3gfx24default__web__on__resize);
}
function _M0FP36mizchi6kagura3gfx25set__web__graphics__hooks(hooks) {
  _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val = hooks;
}
function _M0FP36mizchi6kagura3gfx27reset__web__graphics__hooks() {
  _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val = _M0FP36mizchi6kagura3gfx29default__web__graphics__hooks();
}
function _M0FP36mizchi6kagura3gfx30web__graphics__try__initialize(kind, width, height) {
  const _func = _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val.try_initialize;
  return _func(kind, width, height);
}
function _M0FP36mizchi6kagura3gfx24web__graphics__on__begin(active, kind, pass) {
  const _func = _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val.on_begin;
  _func(active, kind, pass);
}
function _M0FP36mizchi6kagura3gfx22web__graphics__on__end(active, kind, present) {
  const _func = _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val.on_end;
  _func(active, kind, present);
}
function _M0FP36mizchi6kagura3gfx23web__graphics__on__draw(active, kind, command) {
  const _func = _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val.on_draw;
  _func(active, kind, command);
}
function _M0FP36mizchi6kagura3gfx25web__graphics__on__resize(active, kind, width, height) {
  const _func = _M0FP36mizchi6kagura3gfx20web__graphics__hooks.val.on_resize;
  _func(active, kind, width, height);
}
function _M0FP36mizchi6kagura3gfx31default__native__on__new__image(_active, _image_id, _width, _height) {}
function _M0FP36mizchi6kagura3gfx33default__native__on__read__pixels(_active, _x, _y, _width, _height) {
  return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
}
function _M0FP36mizchi6kagura3gfx28new__native__graphics__hooks(try_initialize, on_begin, on_end, on_draw, on_resize) {
  return new _M0TP36mizchi6kagura3gfx19NativeGraphicsHooks(try_initialize, on_begin, on_end, on_draw, on_resize, _M0FP36mizchi6kagura3gfx33default__native__on__read__pixels, _M0FP36mizchi6kagura3gfx31default__native__on__new__image);
}
function _M0FP36mizchi6kagura3gfx32default__native__try__initialize(_width, _height) {
  return false;
}
function _M0FP36mizchi6kagura3gfx26default__native__on__begin(_active, _pass) {}
function _M0FP36mizchi6kagura3gfx24default__native__on__end(_active, _present) {}
function _M0FP36mizchi6kagura3gfx25default__native__on__draw(_active, _command) {}
function _M0FP36mizchi6kagura3gfx27default__native__on__resize(_active, _width, _height) {}
function _M0FP36mizchi6kagura3gfx32default__native__graphics__hooks() {
  return _M0FP36mizchi6kagura3gfx28new__native__graphics__hooks(_M0FP36mizchi6kagura3gfx32default__native__try__initialize, _M0FP36mizchi6kagura3gfx26default__native__on__begin, _M0FP36mizchi6kagura3gfx24default__native__on__end, _M0FP36mizchi6kagura3gfx25default__native__on__draw, _M0FP36mizchi6kagura3gfx27default__native__on__resize);
}
function _M0FP36mizchi6kagura3gfx23native__try__initialize(width, height) {
  const _func = _M0FP36mizchi6kagura3gfx23native__graphics__hooks.val.try_initialize;
  return _func(width, height);
}
function _M0FP36mizchi6kagura3gfx17native__on__begin(active, pass) {
  const _func = _M0FP36mizchi6kagura3gfx23native__graphics__hooks.val.on_begin;
  _func(active, pass);
}
function _M0FP36mizchi6kagura3gfx15native__on__end(active, present) {
  const _func = _M0FP36mizchi6kagura3gfx23native__graphics__hooks.val.on_end;
  _func(active, present);
}
function _M0FP36mizchi6kagura3gfx16native__on__draw(active, command) {
  const _func = _M0FP36mizchi6kagura3gfx23native__graphics__hooks.val.on_draw;
  _func(active, command);
}
function _M0FP36mizchi6kagura3gfx18native__on__resize(active, width, height) {
  const _func = _M0FP36mizchi6kagura3gfx23native__graphics__hooks.val.on_resize;
  _func(active, width, height);
}
function _M0FP36mizchi6kagura3gfx22native__on__new__image(active, image_id, width, height) {
  const _func = _M0FP36mizchi6kagura3gfx23native__graphics__hooks.val.on_new_image;
  _func(active, image_id, width, height);
}
function _M0FP36mizchi6kagura3gfx35default__graphics__backend__options() {
  return new _M0TP36mizchi6kagura3gfx22GraphicsBackendOptions(true, false, true);
}
function _M0FP36mizchi6kagura3gfx23default__clock__now__ms() {
  return 0;
}
function _M0FP36mizchi6kagura3gfx24create__webgpu__graphics(surface, options) {
  return new _M0TP36mizchi6kagura3gfx18StubGraphicsDriver(1, surface.width, surface.height, false, false, false, 0, 0, 0, 0, 0, 0, 0, 0);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10initialize(self) {
  if (self.initialized) {
    return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
  }
  _L: {
    _L$2: {
      const _bind$3 = self.backend;
      switch (_bind$3) {
        case 0: {
          self.native_active = _M0FP36mizchi6kagura3gfx23native__try__initialize(self.width, self.height);
          break;
        }
        case 1: {
          break _L$2;
        }
        case 2: {
          break _L$2;
        }
      }
      break _L;
    }
    self.web_active = _M0FP36mizchi6kagura3gfx30web__graphics__try__initialize(self.backend, self.width, self.height);
  }
  self.initialized = true;
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver5begin(self, pass) {
  self.backend;
  if (self.initialized) {
    if (!self.web_active) {
      _L: {
        _L$2: {
          const _bind$3 = self.backend;
          switch (_bind$3) {
            case 1: {
              break _L$2;
            }
            case 2: {
              break _L$2;
            }
          }
          break _L;
        }
        self.web_active = _M0FP36mizchi6kagura3gfx30web__graphics__try__initialize(self.backend, self.width, self.height);
      }
    }
    self.begin_count = self.begin_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx17native__on__begin(self.native_active, pass);
    _M0FP36mizchi6kagura3gfx24web__graphics__on__begin(self.web_active, self.backend, pass);
  }
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(self, present) {
  if (self.initialized) {
    self.end_count = self.end_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx15native__on__end(self.native_active, present);
    _M0FP36mizchi6kagura3gfx22web__graphics__on__end(self.web_active, self.backend, present);
  }
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(self, width, height) {
  const next_width = width <= 0 ? 1 : width;
  const next_height = height <= 0 ? 1 : height;
  if (self.width === next_width && self.height === next_height) {
    self.resize_suppressed_count = self.resize_suppressed_count + 1 | 0;
    return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
  }
  const _func = _M0FP36mizchi6kagura3gfx25graphics__clock__provider.val;
  const t0 = _func();
  self.resize_count = self.resize_count + 1 | 0;
  self.width = next_width;
  self.height = next_height;
  if (self.initialized) {
    _M0FP36mizchi6kagura3gfx18native__on__resize(self.native_active, next_width, next_height);
    _M0FP36mizchi6kagura3gfx25web__graphics__on__resize(self.web_active, self.backend, next_width, next_height);
  }
  const _func$2 = _M0FP36mizchi6kagura3gfx25graphics__clock__provider.val;
  const t1 = _func$2();
  const duration = t1 - t0;
  self.last_resize_duration_ms = duration;
  self.total_resize_duration_ms = self.total_resize_duration_ms + duration;
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(self, width, height) {
  self.next_id = self.next_id + 1 | 0;
  _M0FP36mizchi6kagura3gfx22native__on__new__image(self.native_active, self.next_id, width, height);
  return new _M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE2Ok(new _M0TP36mizchi6kagura3gfx11ImageHandle(self.next_id, width, height));
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver11new__shader(self, source) {
  self.next_id = self.next_id + 1 | 0;
  return new _M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE2Ok(new _M0TP36mizchi6kagura3gfx12ShaderHandle(self.next_id, source));
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(self, command) {
  if (self.initialized) {
    self.draw_count = self.draw_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx16native__on__draw(self.native_active, command);
    _M0FP36mizchi6kagura3gfx23web__graphics__on__draw(self.web_active, self.backend, command);
  }
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0FP36mizchi6kagura14image__palette14clamp__channel(channel) {
  return channel < 0 ? 0 : channel > 255 ? 255 : channel;
}
function _M0FP36mizchi6kagura14image__palette9new__rgba(r, g, b, a) {
  return new _M0TP36mizchi6kagura14image__palette4Rgba(_M0FP36mizchi6kagura14image__palette14clamp__channel(r), _M0FP36mizchi6kagura14image__palette14clamp__channel(g), _M0FP36mizchi6kagura14image__palette14clamp__channel(b), _M0FP36mizchi6kagura14image__palette14clamp__channel(a));
}
function _M0FP36mizchi6kagura14image__palette24new__image__palette__2x2(p00, p10, p01, p11) {
  return new _M0TP36mizchi6kagura14image__palette15ImagePalette2x2(p00, p10, p01, p11);
}
function _M0FP36mizchi6kagura14image__palette19channel__from__rgba(color, channel_index) {
  switch (channel_index) {
    case 0: {
      return color.r;
    }
    case 1: {
      return color.g;
    }
    case 2: {
      return color.b;
    }
    case 3: {
      return color.a;
    }
    default: {
      return -1;
    }
  }
}
function _M0FP36mizchi6kagura14image__palette16palette__channel(palette, pixel_index, channel_index) {
  let color;
  switch (pixel_index) {
    case 0: {
      color = palette.p00;
      break;
    }
    case 1: {
      color = palette.p10;
      break;
    }
    case 2: {
      color = palette.p01;
      break;
    }
    case 3: {
      color = palette.p11;
      break;
    }
    default: {
      color = undefined;
    }
  }
  let rgba;
  _L: {
    if (color === undefined) {
      return -1;
    } else {
      const _Some = color;
      const _rgba = _Some;
      rgba = _rgba;
      break _L;
    }
  }
  return _M0FP36mizchi6kagura14image__palette19channel__from__rgba(rgba, channel_index);
}
function _M0FP36mizchi6kagura14image__palette28checker__palette__from__seed(seed) {
  const normalized_seed = seed < 0 ? 0 : seed;
  const seed0 = ((Math.imul(normalized_seed, 53) | 0) + 17 | 0) & 255;
  const seed1 = ((Math.imul(normalized_seed, 97) | 0) + 73 | 0) & 255;
  const seed2 = ((Math.imul(normalized_seed, 193) | 0) + 151 | 0) & 255;
  const inv0 = 255 - seed0 | 0;
  const inv1 = 255 - seed1 | 0;
  const inv2 = 255 - seed2 | 0;
  return new _M0TP36mizchi6kagura14image__palette15ImagePalette2x2(_M0FP36mizchi6kagura14image__palette9new__rgba(seed0, seed1, seed2, 255), _M0FP36mizchi6kagura14image__palette9new__rgba(inv0, inv1, inv2, 255), _M0FP36mizchi6kagura14image__palette9new__rgba(inv0, seed1, seed2, 255), _M0FP36mizchi6kagura14image__palette9new__rgba(seed0, inv1, inv2, 255));
}
function _M0FP36mizchi6kagura5asset26bytes__to__rgba8__channels(data) {
  const channels = [];
  const _bind$3 = _M0MPC15bytes5Bytes9to__array(data);
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const byte = _bind$3[_];
      _M0MPC15array5Array4pushGiE(channels, byte);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return channels;
}
function _M0FP36mizchi6kagura5asset18clamp__u8__channel(channel) {
  return channel < 0 ? 0 : channel > 255 ? 255 : channel;
}
function _M0FP36mizchi6kagura5asset27normalized__rgba8__channels(pixels_rgba8, width, height) {
  const safe_width = width <= 0 ? 1 : width;
  const safe_height = height <= 0 ? 1 : height;
  const expected = Math.imul(Math.imul(safe_width, safe_height) | 0, 4) | 0;
  const normalized = [];
  if (expected <= 0 || pixels_rgba8.length < expected) {
    return normalized;
  } else {
    const _bind$3 = 0;
    let _tmp$2 = _bind$3;
    while (true) {
      const i = _tmp$2;
      if (i < expected) {
        _M0MPC15array5Array4pushGiE(normalized, _M0FP36mizchi6kagura5asset18clamp__u8__channel(_M0MPC15array5Array2atGiE(pixels_rgba8, i)));
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return normalized;
  }
}
function _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, width, x, y, channel_index) {
  const base = (Math.imul((Math.imul(y, width) | 0) + x | 0, 4) | 0) + channel_index | 0;
  return base < 0 || base >= pixels_rgba8.length ? 0 : _M0FP36mizchi6kagura5asset18clamp__u8__channel(_M0MPC15array5Array2atGiE(pixels_rgba8, base));
}
function _M0FP36mizchi6kagura5asset30palette__from__rgba8__channels(width, height, pixels_rgba8) {
  const safe_width = width <= 0 ? 1 : width;
  const safe_height = height <= 0 ? 1 : height;
  const expected = Math.imul(Math.imul(safe_width, safe_height) | 0, 4) | 0;
  if (expected <= 0 || pixels_rgba8.length < expected) {
    return _M0FP36mizchi6kagura14image__palette28checker__palette__from__seed((Math.imul(safe_width, 65537) | 0) + safe_height | 0);
  } else {
    const x1 = safe_width - 1 | 0;
    const y1 = safe_height - 1 | 0;
    return _M0FP36mizchi6kagura14image__palette24new__image__palette__2x2(_M0FP36mizchi6kagura14image__palette9new__rgba(_M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, 0, 0), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, 0, 1), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, 0, 2), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, 0, 3)), _M0FP36mizchi6kagura14image__palette9new__rgba(_M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, 0, 0), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, 0, 1), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, 0, 2), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, 0, 3)), _M0FP36mizchi6kagura14image__palette9new__rgba(_M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, y1, 0), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, y1, 1), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, y1, 2), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, 0, y1, 3)), _M0FP36mizchi6kagura14image__palette9new__rgba(_M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, y1, 0), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, y1, 1), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, y1, 2), _M0FP36mizchi6kagura5asset22sample__rgba8__channel(pixels_rgba8, safe_width, x1, y1, 3)));
  }
}
function _M0FP36mizchi6kagura5asset24image__spec__with__rgba8(width, height, pixels_rgba8) {
  const normalized = _M0FP36mizchi6kagura5asset27normalized__rgba8__channels(pixels_rgba8, width, height);
  return new _M0TP36mizchi6kagura5asset9ImageSpec(width, height, "rgba8unorm", _M0FP36mizchi6kagura5asset30palette__from__rgba8__channels(width, height, normalized), normalized);
}
function _M0FP36mizchi6kagura5asset28image__data__to__image__spec(image_data) {
  return _M0FP36mizchi6kagura5asset24image__spec__with__rgba8(image_data.width, image_data.height, _M0FP36mizchi6kagura5asset26bytes__to__rgba8__channels(image_data.data));
}
function _M0FP36mizchi6kagura5asset31expected__rgba8__channel__count(width, height) {
  const safe_width = width <= 0 ? 1 : width;
  const safe_height = height <= 0 ? 1 : height;
  return Math.imul(Math.imul(safe_width, safe_height) | 0, 4) | 0;
}
function _M0FP36mizchi6kagura5asset18bytes__has__prefix(bytes, prefix) {
  if (bytes.length < prefix.length) {
    return false;
  }
  const _bind$3 = 0;
  const _bind$4 = prefix.length;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < _bind$4) {
      $bound_check(bytes, i);
      if (bytes[i] !== _M0MPC15array5Array2atGiE(prefix, i)) {
        return false;
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return true;
}
function _M0FP36mizchi6kagura5asset29detect__raster__image__format(bytes) {
  if (_M0FP36mizchi6kagura5asset18bytes__has__prefix(bytes, [137, 80, 78, 71, 13, 10, 26, 10])) {
    return 0;
  }
  if (_M0FP36mizchi6kagura5asset18bytes__has__prefix(bytes, [255, 216, 255])) {
    return 1;
  }
  if (_M0FP36mizchi6kagura5asset18bytes__has__prefix(bytes, [66, 77])) {
    return 2;
  }
  return undefined;
}
function _M0FP36mizchi6kagura5asset24decode__png__image__spec(bytes) {
  const _bind$3 = _M0FP26mizchi5image11decode__png(bytes);
  let _tmp$2;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _tmp$2 = _ok._0;
  } else {
    return _bind$3;
  }
  return new _M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(_M0FP36mizchi6kagura5asset28image__data__to__image__spec(_tmp$2));
}
function _M0FP36mizchi6kagura5asset25decode__jpeg__image__spec(bytes) {
  const _bind$3 = _M0FP26mizchi5image12decode__jpeg(bytes);
  let _tmp$2;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _tmp$2 = _ok._0;
  } else {
    return _bind$3;
  }
  return new _M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(_M0FP36mizchi6kagura5asset28image__data__to__image__spec(_tmp$2));
}
function _M0FP36mizchi6kagura5asset24decode__bmp__image__spec(bytes) {
  const _bind$3 = _M0FP26mizchi5image11decode__bmp(bytes);
  let _tmp$2;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _tmp$2 = _ok._0;
  } else {
    return _bind$3;
  }
  return new _M0DTPC16result6ResultGRP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(_M0FP36mizchi6kagura5asset28image__data__to__image__spec(_tmp$2));
}
function _M0FP36mizchi6kagura5asset19decode__image__spec(bytes, format) {
  switch (format) {
    case 0: {
      return _M0FP36mizchi6kagura5asset24decode__png__image__spec(bytes);
    }
    case 1: {
      return _M0FP36mizchi6kagura5asset25decode__jpeg__image__spec(bytes);
    }
    default: {
      return _M0FP36mizchi6kagura5asset24decode__bmp__image__spec(bytes);
    }
  }
}
function _M0FP36mizchi6kagura5asset25decode__image__spec__auto(bytes) {
  let format;
  _L: {
    const _bind$3 = _M0FP36mizchi6kagura5asset29detect__raster__image__format(bytes);
    if (_bind$3 === undefined) {
      return new _M0DTPC16result6ResultGORP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(undefined);
    } else {
      const _Some = _bind$3;
      const _format = _Some;
      format = _format;
      break _L;
    }
  }
  const _bind$3 = _M0FP36mizchi6kagura5asset19decode__image__spec(bytes, format);
  let _tmp$2;
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _tmp$2 = _ok._0;
  } else {
    return _bind$3;
  }
  return new _M0DTPC16result6ResultGORP36mizchi6kagura5asset9ImageSpecRP26mizchi5image11DecodeErrorE2Ok(_tmp$2);
}
function _M0FP36mizchi6kagura5asset14asset__key__eq(lhs, rhs) {
  return lhs.value === rhs.value;
}
function _M0FP36mizchi6kagura5asset26has__valid__rgba8__payload(pixels_rgba8, width, height) {
  const expected = _M0FP36mizchi6kagura5asset31expected__rgba8__channel__count(width, height);
  return expected > 0 && pixels_rgba8.length >= expected;
}
function _M0FP36mizchi6kagura5asset19merge__dirty__rects(lhs, rhs) {
  let a;
  _L: {
    if (lhs === undefined) {
      return rhs;
    } else {
      const _Some = lhs;
      const _a = _Some;
      a = _a;
      break _L;
    }
  }
  let b;
  _L$2: {
    if (rhs === undefined) {
      return a;
    } else {
      const _Some = rhs;
      const _b = _Some;
      b = _b;
      break _L$2;
    }
  }
  const x0 = a.x < b.x ? a.x : b.x;
  const y0 = a.y < b.y ? a.y : b.y;
  const ax1 = a.x + a.width | 0;
  const bx1 = b.x + b.width | 0;
  const ay1 = a.y + a.height | 0;
  const by1 = b.y + b.height | 0;
  const x1 = ax1 > bx1 ? ax1 : bx1;
  const y1 = ay1 > by1 ? ay1 : by1;
  return new _M0TP36mizchi6kagura5asset20SourceImageDirtyRect(x0, y0, x1 - x0 | 0, y1 - y0 | 0);
}
function _M0FP36mizchi6kagura5asset23next__image__generation(current) {
  return current <= 0 ? 1 : current + 1 | 0;
}
function _M0FP36mizchi6kagura5asset30atlas__region__to__dirty__rect(region) {
  return new _M0TP36mizchi6kagura5asset20SourceImageDirtyRect(region.x, region.y, region.width, region.height);
}
function _M0FP36mizchi6kagura5asset24mark__atlas__page__dirty(repo, dirty_rect) {
  let rect;
  _L: {
    if (dirty_rect === undefined) {
      return;
    } else {
      const _Some = dirty_rect;
      const _rect = _Some;
      rect = _rect;
      break _L;
    }
  }
  repo.page_dirty_rect = _M0FP36mizchi6kagura5asset19merge__dirty__rects(repo.page_dirty_rect, rect);
  repo.page_generation = _M0FP36mizchi6kagura5asset23next__image__generation(repo.page_generation);
}
function _M0IP36mizchi6kagura5asset20SimpleAtlasAllocatorP36mizchi6kagura5asset14AtlasAllocator8allocate(self, width, height) {
  if (width <= 0 || height <= 0) {
    return undefined;
  } else {
    if (width > self.atlas_width || height > self.atlas_height) {
      return undefined;
    } else {
      if ((self.cursor_x + width | 0) > self.atlas_width) {
        self.cursor_x = 0;
        self.cursor_y = self.cursor_y + self.row_height | 0;
        self.row_height = 0;
      }
      if ((self.cursor_y + height | 0) > self.atlas_height) {
        return undefined;
      } else {
        const region = new _M0TP36mizchi6kagura5asset11AtlasRegion(self.cursor_x, self.cursor_y, width, height, self.atlas_id);
        self.cursor_x = self.cursor_x + width | 0;
        if (height > self.row_height) {
          self.row_height = height;
        }
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(self.allocated, region);
        return region;
      }
    }
  }
}
function _M0FP36mizchi6kagura5asset20create__atlas__image(repo, key, spec) {
  const _bind$3 = repo.images;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (_M0FP36mizchi6kagura5asset14asset__key__eq(entry.key, key)) {
        return entry.handle;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const width = spec.width <= 0 ? 1 : spec.width;
  const height = spec.height <= 0 ? 1 : spec.height;
  const pixels_rgba8 = _M0FP36mizchi6kagura5asset27normalized__rgba8__channels(spec.pixels_rgba8, width, height);
  let region;
  _L: {
    const _bind$5 = _M0IP36mizchi6kagura5asset20SimpleAtlasAllocatorP36mizchi6kagura5asset14AtlasAllocator8allocate(repo.allocator, width, height);
    if (_bind$5 === undefined) {
      return undefined;
    } else {
      const _Some = _bind$5;
      const _region = _Some;
      region = _region;
      break _L;
    }
  }
  const handle = _M0FP36mizchi6kagura3gfx18new__image__handle(repo.next_image_id, width, height);
  repo.next_image_id = repo.next_image_id + 1 | 0;
  _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(repo.images, new _M0TP36mizchi6kagura5asset21SimpleAtlasImageEntry(key, handle, region, spec.palette, pixels_rgba8));
  _M0FP36mizchi6kagura5asset24mark__atlas__page__dirty(repo, _M0FP36mizchi6kagura5asset30atlas__region__to__dirty__rect(region));
  return handle;
}
function _M0FP36mizchi6kagura5asset12fetch__bytes(url, callback) {
  const id = _M0FP36mizchi6kagura5asset18fetch__id__counter.val;
  _M0FP36mizchi6kagura5asset18fetch__id__counter.val = id + 1 | 0;
  _M0FP36mizchi6kagura5asset14js__fetch__url(url, id, (fid, len) => {
    if (len < 0) {
      callback(undefined);
      return undefined;
    }
    const arr = _M0MPC15array5Array4makeGyE(len, 0);
    const _bind$3 = 0;
    let _tmp$2 = _bind$3;
    while (true) {
      const i = _tmp$2;
      if (i < len) {
        _M0MPC15array5Array3setGyE(arr, i, _M0FP36mizchi6kagura5asset20js__fetch__buf__byte(fid, i) & 255);
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0FP36mizchi6kagura5asset21js__fetch__buf__clear(fid);
    callback(_M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(arr, 0, arr.length)));
  });
}
function _M0FP36mizchi6kagura5asset12fetch__image(url, callback) {
  _M0FP36mizchi6kagura5asset12fetch__bytes(url, (bytes_opt) => {
    let bytes;
    _L: {
      if (bytes_opt === undefined) {
        callback(undefined);
        return;
      } else {
        const _Some = bytes_opt;
        const _bytes = _Some;
        bytes = _bytes;
        break _L;
      }
    }
    let _try_err;
    _L$2: {
      const _bind$3 = _M0FP36mizchi6kagura5asset25decode__image__spec__auto(bytes);
      let _tmp$2;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _tmp$2 = _ok._0;
      } else {
        const _err = _bind$3;
        _try_err = _err._0;
        break _L$2;
      }
      callback(_tmp$2);
      return;
    }
    callback(undefined);
  });
}
function _M0FP36mizchi6kagura5asset15new__asset__key(value) {
  return new _M0TP36mizchi6kagura5asset8AssetKey(value);
}
function _M0FP36mizchi6kagura5asset29new__simple__atlas__allocator(atlas_width, atlas_height, atlas_id) {
  return new _M0TP36mizchi6kagura5asset20SimpleAtlasAllocator(atlas_width <= 0 ? 1 : atlas_width, atlas_height <= 0 ? 1 : atlas_height, atlas_id, 0, 0, 0, []);
}
function _M0FP36mizchi6kagura5asset19clamp__atlas__coord(value, bound) {
  return value < 0 ? 0 : value > bound ? bound : value;
}
function _M0FP36mizchi6kagura5asset23atlas__uv__from__region(region, atlas_width, atlas_height) {
  const safe_width = atlas_width <= 0 ? 1 : atlas_width;
  const safe_height = atlas_height <= 0 ? 1 : atlas_height;
  const x0 = _M0FP36mizchi6kagura5asset19clamp__atlas__coord(region.x, safe_width);
  const y0 = _M0FP36mizchi6kagura5asset19clamp__atlas__coord(region.y, safe_height);
  const x1 = _M0FP36mizchi6kagura5asset19clamp__atlas__coord(region.x + region.width | 0, safe_width);
  const y1 = _M0FP36mizchi6kagura5asset19clamp__atlas__coord(region.y + region.height | 0, safe_height);
  return new _M0TP36mizchi6kagura5asset15AtlasDrawSource(region.atlas_id, region, (x0 + 0) / (safe_width + 0), (y0 + 0) / (safe_height + 0), (x1 + 0) / (safe_width + 0), (y1 + 0) / (safe_height + 0));
}
function _M0FP36mizchi6kagura5asset37new__simple__atlas__image__repository(atlas_width, atlas_height, atlas_id) {
  const safe_width = atlas_width <= 0 ? 1 : atlas_width;
  const safe_height = atlas_height <= 0 ? 1 : atlas_height;
  return new _M0TP36mizchi6kagura5asset26SimpleAtlasImageRepository(safe_width, safe_height, atlas_id, 1, _M0FP36mizchi6kagura5asset29new__simple__atlas__allocator(safe_width, safe_height, atlas_id), [], 0, undefined);
}
function _M0FP36mizchi6kagura5asset24get__atlas__draw__source(repo, key) {
  const out = new _M0TPC13ref3RefGORP36mizchi6kagura5asset15AtlasDrawSourceE(undefined);
  const _bind$3 = repo.images;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (_M0FP36mizchi6kagura5asset14asset__key__eq(entry.key, key)) {
        out.val = _M0FP36mizchi6kagura5asset23atlas__uv__from__region(entry.region, repo.atlas_width, repo.atlas_height);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura5asset27new__blank__rgba8__channels(width, height) {
  const safe_width = width <= 0 ? 1 : width;
  const safe_height = height <= 0 ? 1 : height;
  const out = [];
  const _bind$3 = 0;
  const _bind$4 = Math.imul(Math.imul(safe_width, safe_height) | 0, 4) | 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      _M0MPC15array5Array4pushGiE(out, 0);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura5asset38fill__atlas__page__pixels__from__entry(pixels_rgba8, atlas_width, atlas_height, entry) {
  const image_width = entry.handle.width <= 0 ? 1 : entry.handle.width;
  const image_height = entry.handle.height <= 0 ? 1 : entry.handle.height;
  const has_pixels = _M0FP36mizchi6kagura5asset26has__valid__rgba8__payload(entry.pixels_rgba8, image_width, image_height);
  const fallback_r = _M0FP36mizchi6kagura14image__palette16palette__channel(entry.palette, 0, 0);
  const fallback_g = _M0FP36mizchi6kagura14image__palette16palette__channel(entry.palette, 0, 1);
  const fallback_b = _M0FP36mizchi6kagura14image__palette16palette__channel(entry.palette, 0, 2);
  const fallback_a = _M0FP36mizchi6kagura14image__palette16palette__channel(entry.palette, 0, 3);
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const local_y = _tmp$2;
    if (local_y < image_height) {
      _L: {
        const atlas_y = entry.region.y + local_y | 0;
        if (atlas_y < 0 || atlas_y >= atlas_height) {
          break _L;
        }
        const _bind$4 = 0;
        let _tmp$3 = _bind$4;
        while (true) {
          const local_x = _tmp$3;
          if (local_x < image_width) {
            _L$2: {
              const atlas_x = entry.region.x + local_x | 0;
              if (atlas_x < 0 || atlas_x >= atlas_width) {
                break _L$2;
              }
              const dst_base = Math.imul((Math.imul(atlas_y, atlas_width) | 0) + atlas_x | 0, 4) | 0;
              if (has_pixels) {
                const src_base = Math.imul((Math.imul(local_y, image_width) | 0) + local_x | 0, 4) | 0;
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base, _M0MPC15array5Array2atGiE(entry.pixels_rgba8, src_base));
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base + 1 | 0, _M0MPC15array5Array2atGiE(entry.pixels_rgba8, src_base + 1 | 0));
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base + 2 | 0, _M0MPC15array5Array2atGiE(entry.pixels_rgba8, src_base + 2 | 0));
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base + 3 | 0, _M0MPC15array5Array2atGiE(entry.pixels_rgba8, src_base + 3 | 0));
              } else {
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base, fallback_r);
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base + 1 | 0, fallback_g);
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base + 2 | 0, fallback_b);
                _M0MPC15array5Array3setGiE(pixels_rgba8, dst_base + 3 | 0, fallback_a);
              }
              break _L$2;
            }
            _tmp$3 = local_x + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break _L;
      }
      _tmp$2 = local_y + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura5asset27compose__atlas__page__rgba8(repo) {
  const pixels_rgba8 = _M0FP36mizchi6kagura5asset27new__blank__rgba8__channels(repo.atlas_width, repo.atlas_height);
  const _bind$3 = repo.images;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      _M0FP36mizchi6kagura5asset38fill__atlas__page__pixels__from__entry(pixels_rgba8, repo.atlas_width, repo.atlas_height, entry);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return pixels_rgba8;
}
function _M0FP36mizchi6kagura5asset34list__dirty__atlas__page__bindings(repo) {
  const bindings = [];
  let rect;
  _L: {
    _L$2: {
      const _bind$3 = repo.page_dirty_rect;
      if (_bind$3 === undefined) {
      } else {
        const _Some = _bind$3;
        const _rect = _Some;
        rect = _rect;
        break _L$2;
      }
      break _L;
    }
    const page_pixels_rgba8 = _M0FP36mizchi6kagura5asset27compose__atlas__page__rgba8(repo);
    _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(bindings, new _M0TP36mizchi6kagura5asset18SourceImageBinding(repo.atlas_id, repo.atlas_width, repo.atlas_height, repo.page_generation <= 0 ? 1 : repo.page_generation, rect, _M0FP36mizchi6kagura5asset30palette__from__rgba8__channels(repo.atlas_width, repo.atlas_height, page_pixels_rgba8), page_pixels_rgba8));
  }
  return bindings;
}
function _M0FP36mizchi6kagura5asset32clear__dirty__atlas__page__flags(repo) {
  const _bind$3 = repo.page_dirty_rect;
  if (_bind$3 === undefined) {
    return 0;
  } else {
    repo.page_dirty_rect = undefined;
    return 1;
  }
}
function _M0IP26mizchi5audio13EnvelopePhasePB2Eq5equal(_x_1064, _x_1065) {
  switch (_x_1064) {
    case 0: {
      if (_x_1065 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_1065 === 1) {
        return true;
      } else {
        return false;
      }
    }
    case 2: {
      if (_x_1065 === 2) {
        return true;
      } else {
        return false;
      }
    }
    case 3: {
      if (_x_1065 === 3) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_1065 === 4) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0IP26mizchi5audio10VoiceStatePB2Eq5equal(_x_1032, _x_1033) {
  switch (_x_1032) {
    case 0: {
      if (_x_1033 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_1033 === 1) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_1033 === 2) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0IP26mizchi5audio7VoiceIdPB2Eq5equal(_x_950, _x_951) {
  return _x_950 === _x_951;
}
function _M0FP26mizchi5audio11find__voice(mixer, id) {
  const _bind$3 = mixer.voices;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const voice = _bind$3[_];
      if (_M0IP26mizchi5audio7VoiceIdPB2Eq5equal(voice.id, id)) {
        return voice;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return undefined;
}
function _M0FP26mizchi5audio11stop__voice(mixer, id) {
  let voice;
  _L: {
    const _bind$3 = _M0FP26mizchi5audio11find__voice(mixer, id);
    if (_bind$3 === undefined) {
      return false;
    } else {
      const _Some = _bind$3;
      const _voice = _Some;
      voice = _voice;
      break _L;
    }
  }
  voice.state = 2;
  return true;
}
function _M0FP26mizchi5audio10ring__peek(rb, frame_offset, channel) {
  if (frame_offset < 0 || frame_offset >= rb.frames_available) {
    return Math.fround(0);
  }
  if (rb.capacity === 0) {
    $panic();
  }
  const idx = (Math.imul((rb.read_pos + frame_offset | 0) % rb.capacity | 0, rb.channels) | 0) + channel | 0;
  const _tmp$2 = rb.data;
  $bound_check(_tmp$2, idx);
  return _tmp$2[idx];
}
function _M0FP26mizchi5audio15resample__ratio(source_rate, output_rate) {
  return Math.fround(Math.fround(source_rate) / Math.fround(output_rate));
}
function _M0FP26mizchi5audio12clamp__frame(frame, frame_count) {
  return frame < 0 ? 0 : frame >= frame_count ? frame_count - 1 | 0 : frame;
}
function _M0FP26mizchi5audio12frame__count(buf) {
  if (buf.channels === 0) {
    $panic();
  }
  return buf.data.length / buf.channels | 0;
}
function _M0FP26mizchi5audio11get__sample(buf, frame, channel) {
  const _tmp$2 = buf.data;
  const _tmp$3 = (Math.imul(frame, buf.channels) | 0) + channel | 0;
  $bound_check(_tmp$2, _tmp$3);
  return _tmp$2[_tmp$3];
}
function _M0FP26mizchi5audio20read__source__sample(source, frame, channel) {
  let s;
  _L: {
    let buf;
    _L$2: {
      if (source.$tag === 0) {
        const _Buffer = source;
        const _buf = _Buffer._0;
        buf = _buf;
        break _L$2;
      } else {
        const _Stream = source;
        const _s = _Stream._0;
        s = _s;
        break _L;
      }
    }
    const fc = _M0FP26mizchi5audio12frame__count(buf);
    if (frame < 0 || frame >= fc) {
      return Math.fround(0);
    }
    return _M0FP26mizchi5audio11get__sample(buf, frame, channel);
  }
  return _M0FP26mizchi5audio10ring__peek(s.ring, frame, channel);
}
function _M0FP26mizchi5audio15resample__cubic(source, position, channel, frame_count) {
  const floor_pos = _M0MPC15float5Float7to__int(position);
  const frac = Math.fround(position - Math.fround(floor_pos));
  const i0 = _M0FP26mizchi5audio12clamp__frame(floor_pos - 1 | 0, frame_count);
  const i1 = _M0FP26mizchi5audio12clamp__frame(floor_pos, frame_count);
  const i2 = _M0FP26mizchi5audio12clamp__frame(floor_pos + 1 | 0, frame_count);
  const i3 = _M0FP26mizchi5audio12clamp__frame(floor_pos + 2 | 0, frame_count);
  const s0 = _M0FP26mizchi5audio20read__source__sample(source, i0, channel);
  const s1 = _M0FP26mizchi5audio20read__source__sample(source, i1, channel);
  const s2 = _M0FP26mizchi5audio20read__source__sample(source, i2, channel);
  const s3 = _M0FP26mizchi5audio20read__source__sample(source, i3, channel);
  const c0 = s1;
  const c1 = Math.fround(Math.fround(s2 - s0) * Math.fround(0.5));
  const c2 = Math.fround(Math.fround(Math.fround(s0 - Math.fround(s1 * Math.fround(2.5))) + Math.fround(s2 * Math.fround(2))) - Math.fround(s3 * Math.fround(0.5)));
  const c3 = Math.fround(Math.fround(Math.fround(s3 - s0) * Math.fround(0.5)) + Math.fround(Math.fround(s1 - s2) * Math.fround(1.5)));
  return Math.fround(Math.fround(Math.fround(Math.fround(Math.fround(Math.fround(c3 * frac) + c2) * frac) + c1) * frac) + c0);
}
function _M0FP26mizchi5audio16resample__linear(source, position, channel, frame_count) {
  const floor_pos = _M0MPC15float5Float7to__int(position);
  const frac = Math.fround(position - Math.fround(floor_pos));
  const i0 = _M0FP26mizchi5audio12clamp__frame(floor_pos, frame_count);
  const i1 = _M0FP26mizchi5audio12clamp__frame(floor_pos + 1 | 0, frame_count);
  const s0 = _M0FP26mizchi5audio20read__source__sample(source, i0, channel);
  const s1 = _M0FP26mizchi5audio20read__source__sample(source, i1, channel);
  return Math.fround(s0 + Math.fround(Math.fround(s1 - s0) * frac));
}
function _M0FP26mizchi5audio17resample__nearest(source, position, channel, frame_count) {
  const frame = _M0FP26mizchi5audio12clamp__frame(_M0MPC15float5Float7to__int(Math.fround(position + Math.fround(0.5))), frame_count);
  return _M0FP26mizchi5audio20read__source__sample(source, frame, channel);
}
function _M0FP26mizchi5audio15resample__frame(quality, source, position, channel, frame_count) {
  switch (quality) {
    case 0: {
      return _M0FP26mizchi5audio17resample__nearest(source, position, channel, frame_count);
    }
    case 1: {
      return _M0FP26mizchi5audio16resample__linear(source, position, channel, frame_count);
    }
    default: {
      return _M0FP26mizchi5audio15resample__cubic(source, position, channel, frame_count);
    }
  }
}
function _M0FP26mizchi5audio10pan__gains(pan) {
  const half_pi = Math.fround(1.57079632679489656);
  const angle = Math.fround(Math.fround(Math.fround(pan + Math.fround(1)) * Math.fround(0.5)) * half_pi);
  const left = _M0FPC14math4cosf(angle);
  const right = _M0FPC14math4sinf(angle);
  return { _0: left, _1: right };
}
function _M0FP26mizchi5audio15biquad__process(state, input) {
  const output = Math.fround(Math.fround(state.b0 * input) + state.z1);
  state.z1 = Math.fround(Math.fround(Math.fround(state.b1 * input) - Math.fround(state.a1 * output)) + state.z2);
  state.z2 = Math.fround(Math.fround(state.b2 * input) - Math.fround(state.a2 * output));
  return output;
}
function _M0FP26mizchi5audio14delay__process(state, input) {
  const _tmp$2 = state.buffer;
  const _tmp$3 = state.write_pos;
  $bound_check(_tmp$2, _tmp$3);
  const delayed = _tmp$2[_tmp$3];
  const _tmp$4 = state.buffer;
  const _tmp$5 = state.write_pos;
  $bound_check(_tmp$4, _tmp$5);
  _tmp$4[_tmp$5] = Math.fround(input + Math.fround(delayed * state.feedback));
  if (state.delay_samples === 0) {
    $panic();
  }
  state.write_pos = (state.write_pos + 1 | 0) % state.delay_samples | 0;
  const one = Math.fround(1);
  return Math.fround(Math.fround(input * Math.fround(one - state.mix)) + Math.fround(delayed * state.mix));
}
function _M0FP26mizchi5audio15effect__process(node, sample) {
  let state;
  _L: {
    let state$2;
    _L$2: {
      let state$3;
      _L$3: {
        switch (node.$tag) {
          case 0: {
            const _Lowpass = node;
            const _state = _Lowpass._0;
            state$3 = _state;
            break _L$3;
          }
          case 1: {
            const _Highpass = node;
            const _state$2 = _Highpass._0;
            state$2 = _state$2;
            break _L$2;
          }
          default: {
            const _Delay = node;
            const _state$3 = _Delay._0;
            state = _state$3;
            break _L;
          }
        }
      }
      return _M0FP26mizchi5audio15biquad__process(state$3, sample);
    }
    return _M0FP26mizchi5audio15biquad__process(state$2, sample);
  }
  return _M0FP26mizchi5audio14delay__process(state, sample);
}
function _M0FP26mizchi5audio23effects__chain__process(effects, sample) {
  const result = new _M0TPC13ref3RefGfE(sample);
  const _bind$3 = effects.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const effect = effects[_];
      result.val = _M0FP26mizchi5audio15effect__process(effect, result.val);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return result.val;
}
function _M0FP26mizchi5audio14envelope__tick(env) {
  const _bind$3 = env.phase;
  switch (_bind$3) {
    case 0: {
      const attack_samples = _M0MPC15float5Float7to__int(Math.fround(env.config.attack * Math.fround(env.sample_rate)));
      if (attack_samples <= 0) {
        env.level = Math.fround(1);
        env.phase = 1;
        env.phase_position = 0;
        return env.level;
      }
      env.level = Math.fround(Math.fround(env.phase_position) / Math.fround(attack_samples));
      env.phase_position = env.phase_position + 1 | 0;
      if (env.phase_position >= attack_samples) {
        env.level = Math.fround(1);
        env.phase = 1;
        env.phase_position = 0;
      }
      return env.level;
    }
    case 1: {
      const decay_samples = _M0MPC15float5Float7to__int(Math.fround(env.config.decay * Math.fround(env.sample_rate)));
      if (decay_samples <= 0) {
        env.level = env.config.sustain;
        env.phase = 2;
        env.phase_position = 0;
        return env.level;
      }
      const t$2 = Math.fround(Math.fround(env.phase_position) / Math.fround(decay_samples));
      env.level = Math.fround(Math.fround(1) + Math.fround(Math.fround(env.config.sustain - Math.fround(1)) * t$2));
      env.phase_position = env.phase_position + 1 | 0;
      if (env.phase_position >= decay_samples) {
        env.level = env.config.sustain;
        env.phase = 2;
        env.phase_position = 0;
      }
      return env.level;
    }
    case 2: {
      env.level = env.config.sustain;
      return env.level;
    }
    case 3: {
      const release_samples = _M0MPC15float5Float7to__int(Math.fround(env.config.release_time * Math.fround(env.sample_rate)));
      if (release_samples <= 0) {
        env.level = Math.fround(0);
        env.phase = 4;
        return env.level;
      }
      const t$3 = Math.fround(Math.fround(env.phase_position) / Math.fround(release_samples));
      env.level = Math.fround(env.release_start_level * Math.fround(Math.fround(1) - t$3));
      env.phase_position = env.phase_position + 1 | 0;
      if (env.phase_position >= release_samples) {
        env.level = Math.fround(0);
        env.phase = 4;
      }
      if (Math.fround(env.level < Math.fround(0))) {
        env.level = Math.fround(0);
      }
      return env.level;
    }
    default: {
      return Math.fround(0);
    }
  }
}
function _M0FP26mizchi5audio16source__channels(source) {
  let s;
  _L: {
    let buf;
    _L$2: {
      if (source.$tag === 0) {
        const _Buffer = source;
        const _buf = _Buffer._0;
        buf = _buf;
        break _L$2;
      } else {
        const _Stream = source;
        const _s = _Stream._0;
        s = _s;
        break _L;
      }
    }
    return buf.channels;
  }
  return s.channels;
}
function _M0FP26mizchi5audio20source__frame__count(source) {
  let s;
  _L: {
    let buf;
    _L$2: {
      if (source.$tag === 0) {
        const _Buffer = source;
        const _buf = _Buffer._0;
        buf = _buf;
        break _L$2;
      } else {
        const _Stream = source;
        const _s = _Stream._0;
        s = _s;
        break _L;
      }
    }
    return _M0FP26mizchi5audio12frame__count(buf);
  }
  return s.ring.frames_available;
}
function _M0FP26mizchi5audio4tick(mixer, frames, output) {
  _M0MPC15array10FixedArray12fill_2einnerGfE(output, Math.fround(0), 0, Math.imul(frames, 2) | 0);
  const _bind$3 = mixer.voices;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const voice = _bind$3[_];
      _L: {
        if (_M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(voice.state, 0)) {
          break _L;
        }
        const src = voice.source;
        const src_channels = _M0FP26mizchi5audio16source__channels(src);
        const src_frames = _M0FP26mizchi5audio20source__frame__count(src);
        let pan_l;
        let pan_r;
        _L$2: {
          const _bind$5 = _M0FP26mizchi5audio10pan__gains(voice.pan);
          const _pan_l = _bind$5._0;
          const _pan_r = _bind$5._1;
          pan_l = _pan_l;
          pan_r = _pan_r;
          break _L$2;
        }
        const voice_gain = voice.gain;
        const ratio = _M0FP26mizchi5audio15resample__ratio(voice.sample_rate, mixer.sample_rate);
        const _bind$5 = 0;
        let _tmp$3 = _bind$5;
        while (true) {
          const f = _tmp$3;
          if (f < frames) {
            const int_pos = _M0MPC15float5Float7to__int(voice.position);
            const end_frame = voice.loop_end > 0 ? voice.loop_end : src_frames;
            if (int_pos >= end_frame) {
              if (voice.looping) {
                voice.position = Math.fround(voice.loop_start);
              } else {
                voice.state = 2;
                break;
              }
            }
            let env_gain;
            let env;
            _L$3: {
              _L$4: {
                const _bind$6 = voice.envelope;
                if (_bind$6 === undefined) {
                  env_gain = Math.fround(1);
                } else {
                  const _Some = _bind$6;
                  const _env = _Some;
                  env = _env;
                  break _L$4;
                }
                break _L$3;
              }
              const g = _M0FP26mizchi5audio14envelope__tick(env);
              if (_M0IP26mizchi5audio13EnvelopePhasePB2Eq5equal(env.phase, 4)) {
                voice.state = 2;
                break;
              }
              env_gain = g;
            }
            const combined_gain = Math.fround(voice_gain * env_gain);
            const raw_l = _M0FP26mizchi5audio15resample__frame(mixer.resample_quality, src, voice.position, 0, src_frames);
            const proc_l = _M0FP26mizchi5audio23effects__chain__process(voice.effects, raw_l);
            const sample_l = Math.fround(Math.fround(proc_l * combined_gain) * pan_l);
            const sample_r = src_channels >= 2 ? Math.fround(Math.fround(_M0FP26mizchi5audio15resample__frame(mixer.resample_quality, src, voice.position, 1, src_frames) * combined_gain) * pan_r) : Math.fround(Math.fround(proc_l * combined_gain) * pan_r);
            const out_idx = Math.imul(f, 2) | 0;
            $bound_check(output, out_idx);
            $bound_check(output, out_idx);
            output[out_idx] = Math.fround(output[out_idx] + sample_l);
            const _tmp$4 = out_idx + 1 | 0;
            const _tmp$5 = out_idx + 1 | 0;
            $bound_check(output, _tmp$5);
            $bound_check(output, _tmp$4);
            output[_tmp$4] = Math.fround(output[_tmp$5] + sample_r);
            voice.position = Math.fround(voice.position + ratio);
            _tmp$3 = f + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break _L;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (Math.fround(mixer.master_gain !== Math.fround(1))) {
    const _bind$5 = 0;
    const _bind$6 = Math.imul(frames, 2) | 0;
    let _tmp$3 = _bind$5;
    while (true) {
      const i = _tmp$3;
      if (i < _bind$6) {
        $bound_check(output, i);
        $bound_check(output, i);
        output[i] = Math.fround(output[i] * mixer.master_gain);
        _tmp$3 = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    return;
  }
}
function _M0FP26mizchi5audio16collect__stopped(mixer) {
  mixer.voices = _M0MPC15array5Array6filterGRP26mizchi5audio5VoiceE(mixer.voices, (v) => _M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(v.state, 2));
}
function _M0FP36mizchi6kagura5audio22default__audio__format() {
  return new _M0TP36mizchi6kagura5audio11AudioFormat(44100, 2, 16);
}
function _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id) {
  const _bind$3 = self.player_map;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const pair = _bind$3[_];
      let pid;
      let vid;
      _L: {
        const _pid = pair._0;
        const _vid = pair._1;
        pid = _pid;
        vid = _vid;
        break _L;
      }
      if (pid.value === id.value) {
        return vid;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return undefined;
}
function _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext4stop(self, id) {
  let vid;
  _L: {
    const _bind$3 = _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id);
    if (_bind$3 === undefined) {
      return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
    } else {
      const _Some = _bind$3;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  _M0FP26mizchi5audio11stop__voice(self.mixer, vid);
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext11set__volume(self, id, volume) {
  let vid;
  _L: {
    const _bind$3 = _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id);
    if (_bind$3 === undefined) {
      return;
    } else {
      const _Some = _bind$3;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  let voice;
  _L$2: {
    const _bind$3 = _M0FP26mizchi5audio11find__voice(self.mixer, vid);
    if (_bind$3 === undefined) {
      return;
    } else {
      const _Some = _bind$3;
      const _voice = _Some;
      voice = _voice;
      break _L$2;
    }
  }
  const clamped = volume < 0 ? 0 : volume > 1 ? 1 : volume;
  voice.gain = Math.fround(clamped);
}
function _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext7dispose(self, id) {
  let vid;
  _L: {
    const _bind$3 = _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id);
    if (_bind$3 === undefined) {
      return;
    } else {
      const _Some = _bind$3;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  _M0FP26mizchi5audio11stop__voice(self.mixer, vid);
  self.player_map = _M0MPC15array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self.player_map, (pair) => {
    let pid;
    _L$2: {
      const _pid = pair._0;
      pid = _pid;
      break _L$2;
    }
    return pid.value !== id.value;
  });
}
function _M0MP36mizchi6kagura5audio17MixerAudioContext6render(self, frames, output) {
  _M0FP26mizchi5audio4tick(self.mixer, frames, output);
  const _bind$3 = self.player_map;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const pair = _bind$3[_];
      let vid;
      _L: {
        const _vid = pair._1;
        vid = _vid;
        break _L;
      }
      let voice;
      _L$2: {
        _L$3: {
          const _bind$5 = _M0FP26mizchi5audio11find__voice(self.mixer, vid);
          if (_bind$5 === undefined) {
          } else {
            const _Some = _bind$5;
            const _voice = _Some;
            voice = _voice;
            break _L$3;
          }
          break _L$2;
        }
        if (_M0IP26mizchi5audio10VoiceStatePB2Eq5equal(voice.state, 2)) {
          voice.state = 1;
        }
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP26mizchi5audio16collect__stopped(self.mixer);
}
function _M0MP36mizchi6kagura5audio17MixerAudioContext22dispose__outgoing__bgm(self) {
  let id;
  _L: {
    const _bind$3 = self.bgm_outgoing_id;
    if (_bind$3 === undefined) {
      return;
    } else {
      const _Some = _bind$3;
      const _id = _Some;
      id = _id;
      break _L;
    }
  }
  let _try_err;
  _L$2: {
    _L$3: {
      const _bind$3 = _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext4stop(self, id);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _ok._0;
      } else {
        const _err = _bind$3;
        _try_err = _err._0;
        break _L$3;
      }
      break _L$2;
    }
  }
  _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext7dispose(self, id);
  self.bgm_outgoing_id = undefined;
  self.bgm_outgoing_volume = 0;
  self.bgm_outgoing_fade_speed = 0;
}
function _M0MP36mizchi6kagura5audio17MixerAudioContext9tick__bgm(self, frames) {
  const sample_rate = self.mixer.sample_rate;
  const dt = (frames + 0) / (sample_rate + 0);
  if (self.bgm_fade_speed > 0) {
    let id;
    _L: {
      _L$2: {
        const _bind$3 = self.bgm_player_id;
        if (_bind$3 === undefined) {
          self.bgm_fade_speed = 0;
        } else {
          const _Some = _bind$3;
          const _id = _Some;
          id = _id;
          break _L$2;
        }
        break _L;
      }
      const delta = self.bgm_fade_speed * dt;
      const current = self.bgm_current_volume;
      const target = self.bgm_fade_target;
      let new_vol;
      if (current < target) {
        const v = current + delta;
        new_vol = v >= target ? target : v;
      } else {
        const v = current - delta;
        new_vol = v <= target ? target : v;
      }
      self.bgm_current_volume = new_vol;
      _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext11set__volume(self, id, new_vol);
      if (Math.abs(new_vol - target) < 0.0001) {
        self.bgm_current_volume = target;
        self.bgm_fade_speed = 0;
      }
    }
  }
  if (self.bgm_outgoing_fade_speed > 0) {
    let id;
    _L: {
      const _bind$3 = self.bgm_outgoing_id;
      if (_bind$3 === undefined) {
        self.bgm_outgoing_fade_speed = 0;
        return;
      } else {
        const _Some = _bind$3;
        const _id = _Some;
        id = _id;
        break _L;
      }
    }
    const delta = self.bgm_outgoing_fade_speed * dt;
    const new_vol = self.bgm_outgoing_volume - delta;
    if (new_vol <= 0) {
      _M0MP36mizchi6kagura5audio17MixerAudioContext22dispose__outgoing__bgm(self);
      return;
    } else {
      self.bgm_outgoing_volume = new_vol;
      _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext11set__volume(self, id, new_vol);
      return;
    }
  } else {
    return;
  }
}
function _M0FP36mizchi6kagura5audio31default__audio__output__latency() {
  return 0;
}
function _M0FP36mizchi6kagura5audio25new__audio__output__hooks(try_initialize, write_frames, suspend, resume_playback, close) {
  return new _M0TP36mizchi6kagura5audio16AudioOutputHooks(try_initialize, write_frames, suspend, resume_playback, close, _M0FP36mizchi6kagura5audio31default__audio__output__latency);
}
function _M0FP36mizchi6kagura5audio31new__audio__output__hooks__full(try_initialize, write_frames, suspend, resume_playback, close, output_latency) {
  return new _M0TP36mizchi6kagura5audio16AudioOutputHooks(try_initialize, write_frames, suspend, resume_playback, close, output_latency);
}
function _M0FP36mizchi6kagura5audio31default__audio__try__initialize(_format) {
  return false;
}
function _M0FP36mizchi6kagura5audio29default__audio__write__frames(_output, _frames) {
  return 0;
}
function _M0FP36mizchi6kagura5audio23default__audio__suspend() {}
function _M0FP36mizchi6kagura5audio22default__audio__resume() {}
function _M0FP36mizchi6kagura5audio21default__audio__close() {}
function _M0FP36mizchi6kagura5audio29default__audio__output__hooks() {
  return _M0FP36mizchi6kagura5audio25new__audio__output__hooks(_M0FP36mizchi6kagura5audio31default__audio__try__initialize, _M0FP36mizchi6kagura5audio29default__audio__write__frames, _M0FP36mizchi6kagura5audio23default__audio__suspend, _M0FP36mizchi6kagura5audio22default__audio__resume, _M0FP36mizchi6kagura5audio21default__audio__close);
}
function _M0FP36mizchi6kagura5audio25set__audio__output__hooks(hooks) {
  _M0FP36mizchi6kagura5audio20audio__output__hooks.val = hooks;
}
function _M0FP36mizchi6kagura5audio27reset__audio__output__hooks() {
  _M0FP36mizchi6kagura5audio20audio__output__hooks.val = _M0FP36mizchi6kagura5audio29default__audio__output__hooks();
}
function _M0FP36mizchi6kagura5audio22audio__try__initialize(format) {
  const _func = _M0FP36mizchi6kagura5audio20audio__output__hooks.val.try_initialize;
  return _func(format);
}
function _M0FP36mizchi6kagura5audio20audio__write__frames(output, frames) {
  const _func = _M0FP36mizchi6kagura5audio20audio__output__hooks.val.write_frames;
  return _func(output, frames);
}
function _M0FP36mizchi6kagura5audio13audio__resume() {
  const _func = _M0FP36mizchi6kagura5audio20audio__output__hooks.val.resume_playback;
  _func();
}
function _M0FP36mizchi6kagura5audio25audio__render__and__write(mixer, frames) {
  const channels = 2;
  const buf = $make_array_len_and_init(Math.imul(frames, channels) | 0, Math.fround(0));
  _M0MP36mizchi6kagura5audio17MixerAudioContext6render(mixer, frames, buf);
  return _M0FP36mizchi6kagura5audio20audio__write__frames(buf, frames);
}
function _M0FP36mizchi6kagura9debugutil16render__commandsGRP36mizchi6kagura3gfx18StubGraphicsDriverE(graphics, cmds, clear_color, clear_enabled) {
  let color;
  if (clear_color === undefined) {
    color = _M0FP36mizchi6kagura3gfx10new__color(0, 0, 0, 1);
  } else {
    const _Some = clear_color;
    const _c = _Some;
    color = _c;
  }
  let clear;
  if (clear_enabled === -1) {
    clear = true;
  } else {
    const _Some = clear_enabled;
    const _c = _Some;
    clear = _c;
  }
  const pass = _M0FP36mizchi6kagura3gfx31new__render__pass__desc_2einner(color, clear, true);
  const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver5begin(graphics, pass);
  if (_bind$3.$tag === 1) {
    const _ok = _bind$3;
    _ok._0;
  } else {
    return _bind$3;
  }
  const _bind$4 = cmds.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const cmd = cmds[_];
      const _bind$5 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(graphics, cmd);
      if (_bind$5.$tag === 1) {
        const _ok = _bind$5;
        _ok._0;
      } else {
        return _bind$5;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(graphics, true);
}
function _M0FP36mizchi6kagura6engine17invoke__on__start(canvas, title) {
  let hooks;
  _L: {
    const _bind$3 = _M0FP36mizchi6kagura6engine16lifecycle__hooks.val;
    if (_bind$3 === undefined) {
      return;
    } else {
      const _Some = _bind$3;
      const _hooks = _Some;
      hooks = _hooks;
      break _L;
    }
  }
  const _func = hooks.on_start;
  _func(canvas, title);
}
function _M0FP36mizchi6kagura6engine16invoke__on__stop() {
  let hooks;
  _L: {
    const _bind$3 = _M0FP36mizchi6kagura6engine16lifecycle__hooks.val;
    if (_bind$3 === undefined) {
      return;
    } else {
      const _Some = _bind$3;
      const _hooks = _Some;
      hooks = _hooks;
      break _L;
    }
  }
  const _func = hooks.on_stop;
  _func();
}
function _M0FP36mizchi6kagura6engine11run_2einner(update, draw, on_frame, after_render, audio_ctx, audio_frames_per_tick, width, height, title, canvas) {
  _M0FP36mizchi6kagura6engine17invoke__on__start(canvas, title);
  const platform = _M0FP36mizchi6kagura8platform29create__web__canvas__platform(canvas);
  let surface;
  let _try_err;
  _L: {
    _L$2: {
      const _bind$3 = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform15SurfaceProvider16current__surface(platform);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        surface = _ok._0;
      } else {
        const _err = _bind$3;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    surface = _M0FP36mizchi6kagura8platform33create__offscreen__surface__token(width, height);
  }
  const graphics = _M0FP36mizchi6kagura3gfx24create__webgpu__graphics(surface, _M0FP36mizchi6kagura3gfx35default__graphics__backend__options());
  let _try_err$2;
  _L$2: {
    _L$3: {
      const _bind$3 = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver10initialize(platform, _M0FP36mizchi6kagura8platform28new__window__options_2einner(title, width, height, false, true, true));
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _ok._0;
      } else {
        const _err = _bind$3;
        _try_err$2 = _err._0;
        break _L$3;
      }
      break _L$2;
    }
    const e = _try_err$2;
    _M0FPB7printlnGsE(`[engine] platform.initialize failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
  }
  let _try_err$3;
  _L$3: {
    _L$4: {
      const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10initialize(graphics);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _ok._0;
      } else {
        const _err = _bind$3;
        _try_err$3 = _err._0;
        break _L$4;
      }
      break _L$3;
    }
    const e = _try_err$3;
    _M0FPB7printlnGsE(`[engine] graphics.initialize failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
  }
  const shader_source = _M0FP36mizchi6kagura3gfx32default__builtin__shader__source();
  let dst;
  let _try_err$4;
  _L$4: {
    _L$5: {
      const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(graphics, width, height);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        dst = _ok._0;
      } else {
        const _err = _bind$3;
        _try_err$4 = _err._0;
        break _L$5;
      }
      break _L$4;
    }
    const e = _try_err$4;
    _M0FPB7printlnGsE(`[engine] graphics.new_image failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
    dst = _M0FP36mizchi6kagura3gfx18new__image__handle(1, width, height);
  }
  let shader;
  let _try_err$5;
  _L$5: {
    _L$6: {
      const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver11new__shader(graphics, shader_source);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        shader = _ok._0;
      } else {
        const _err = _bind$3;
        _try_err$5 = _err._0;
        break _L$6;
      }
      break _L$5;
    }
    const e = _try_err$5;
    _M0FPB7printlnGsE(`[engine] graphics.new_shader failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
    shader = _M0FP36mizchi6kagura3gfx19new__shader__handle(1, shader_source);
  }
  const ctx = new _M0TP36mizchi6kagura6engine13EngineContext(dst, shader, width, height);
  const tick = _M0MPC13ref3Ref3newGiE(0);
  if (audio_ctx === undefined) {
  } else {
    _M0FP36mizchi6kagura5audio22audio__try__initialize(_M0FP36mizchi6kagura5audio22default__audio__format());
  }
  const audio_tick_ms = (audio_frames_per_tick + 0) / 44100 * 1000;
  const audio_accum = _M0MPC13ref3Ref3newGdE(0);
  const prev_time = _M0MPC13ref3Ref3newGdE(_M0FP36mizchi6kagura6engine20js__performance__now());
  const frame = () => {
    _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver12poll__events(platform);
    const outside = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver13outside__size(platform);
    const new_w = _M0MPC16double6Double7to__int(outside.width);
    const new_h = _M0MPC16double6Double7to__int(outside.height);
    if (new_w > 0 && (new_h > 0 && (new_w !== ctx.screen_w || new_h !== ctx.screen_h))) {
      let _try_err$6;
      _L$6: {
        _L$7: {
          const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(graphics, new_w, new_h);
          if (_bind$3.$tag === 1) {
            const _ok = _bind$3;
            _ok._0;
          } else {
            const _err = _bind$3;
            _try_err$6 = _err._0;
            break _L$7;
          }
          break _L$6;
        }
        const e = _try_err$6;
        _M0FPB7printlnGsE(`[engine] graphics.resize failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
      }
      ctx.screen_w = new_w;
      ctx.screen_h = new_h;
      let _tmp$2;
      let _try_err$7;
      _L$7: {
        _L$8: {
          const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(graphics, new_w, new_h);
          if (_bind$3.$tag === 1) {
            const _ok = _bind$3;
            _tmp$2 = _ok._0;
          } else {
            const _err = _bind$3;
            _try_err$7 = _err._0;
            break _L$8;
          }
          break _L$7;
        }
        const e = _try_err$7;
        _M0FPB7printlnGsE(`[engine] graphics.new_image (resize) failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
        _tmp$2 = _M0FP36mizchi6kagura3gfx18new__image__handle(ctx.dst.id, new_w, new_h);
      }
      ctx.dst = _tmp$2;
    }
    const input = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver14capture__input(platform, tick.val);
    tick.val = tick.val + 1 | 0;
    update(input);
    let f;
    _L$6: {
      _L$7: {
        if (on_frame === undefined) {
        } else {
          const _Some = on_frame;
          const _f = _Some;
          f = _f;
          break _L$7;
        }
        break _L$6;
      }
      f();
    }
    const draw_callback_start = _M0FP36mizchi6kagura6engine20js__performance__now();
    const cmds = draw(ctx);
    const draw_callback_end = _M0FP36mizchi6kagura6engine20js__performance__now();
    const render_start = _M0FP36mizchi6kagura6engine20js__performance__now();
    let _try_err$6;
    _L$7: {
      _L$8: {
        const _bind$3 = _M0FP36mizchi6kagura9debugutil16render__commandsGRP36mizchi6kagura3gfx18StubGraphicsDriverE(graphics, cmds, undefined, -1);
        if (_bind$3.$tag === 1) {
          const _ok = _bind$3;
          _ok._0;
        } else {
          const _err = _bind$3;
          _try_err$6 = _err._0;
          break _L$8;
        }
        break _L$7;
      }
      const e = _try_err$6;
      _M0FPB7printlnGsE(`[engine] render_commands failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
    }
    const render_end = _M0FP36mizchi6kagura6engine20js__performance__now();
    let f$2;
    _L$8: {
      _L$9: {
        if (after_render === undefined) {
        } else {
          const _Some = after_render;
          const _f = _Some;
          f$2 = _f;
          break _L$9;
        }
        break _L$8;
      }
      f$2(draw_callback_end - draw_callback_start, render_end - render_start);
    }
    const now = _M0FP36mizchi6kagura6engine20js__performance__now();
    const elapsed = now - prev_time.val;
    prev_time.val = now;
    let actx;
    _L$9: {
      _L$10: {
        if (audio_ctx === undefined) {
        } else {
          const _Some = audio_ctx;
          const _actx = _Some;
          actx = _actx;
          break _L$10;
        }
        break _L$9;
      }
      _M0FP36mizchi6kagura5audio13audio__resume();
      audio_accum.val = audio_accum.val + elapsed;
      while (true) {
        if (audio_accum.val >= audio_tick_ms) {
          _M0FP36mizchi6kagura5audio25audio__render__and__write(actx, audio_frames_per_tick);
          _M0MP36mizchi6kagura5audio17MixerAudioContext9tick__bgm(actx, audio_frames_per_tick);
          audio_accum.val = audio_accum.val - audio_tick_ms;
          continue;
        } else {
          break;
        }
      }
    }
    _M0FP36mizchi6kagura6engine29js__request__animation__frame(frame);
  };
  _M0FP36mizchi6kagura6engine20js__on__beforeunload(() => {
    _M0FP36mizchi6kagura6engine16invoke__on__stop();
  });
  _M0FP36mizchi6kagura6engine29js__request__animation__frame(frame);
}
function _M0FP36mizchi6kagura6engine21set__lifecycle__hooks(hooks) {
  _M0FP36mizchi6kagura6engine16lifecycle__hooks.val = hooks;
}
function _M0FP36mizchi6kagura6draw2d20atlas__quad__indices() {
  return [0, 1, 2, 2, 3, 0];
}
function _M0FP36mizchi6kagura6draw2d25atlas__quad__vertex__data(source, left, top, right, bottom) {
  return [left, top, source.u0, source.v0, right, top, source.u1, source.v0, right, bottom, source.u1, source.v1, left, bottom, source.u0, source.v1];
}
function _M0FP36mizchi6kagura6draw2d33atlas__quad__resource__cache__key(dst, shader, dst_region, blend, source, left, top, right, bottom, uniform_dwords) {
  const values = [dst.id, dst.width, dst.height, shader.id, dst_region.x, dst_region.y, dst_region.width, dst_region.height, dst_region.index_count, _M0FP36mizchi6kagura3gfx20blend__mode__to__int(blend), source.page_image_id, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(source.u0), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(source.v0), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(source.u1), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(source.v1), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(left), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(top), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(right), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(bottom), uniform_dwords.length];
  const _bind$3 = uniform_dwords.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const dword = uniform_dwords[_];
      _M0MPC15array5Array4pushGiE(values, dword);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi6kagura3gfx27build__resource__cache__key(1096043603, values);
}
function _M0FP36mizchi6kagura6draw2d31new__atlas__quad__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, source, left, top, right, bottom, uniform_dwords) {
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, _M0FP36mizchi6kagura6draw2d25atlas__quad__vertex__data(source, left, top, right, bottom), _M0FP36mizchi6kagura6draw2d20atlas__quad__indices(), [source.page_image_id], uniform_dwords, 1, _M0FP36mizchi6kagura6draw2d33atlas__quad__resource__cache__key(dst, shader, dst_region, blend, source, left, top, right, bottom, uniform_dwords));
}
function _M0FP36mizchi6kagura8sprite2d33new__atlas__sprite__draw__command(atlas_repository, atlas_key, dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, left, top, right, bottom, uniform_dwords) {
  let source;
  _L: {
    const _bind$3 = _M0FP36mizchi6kagura5asset24get__atlas__draw__source(atlas_repository, atlas_key);
    if (_bind$3 === undefined) {
      return undefined;
    } else {
      const _Some = _bind$3;
      const _source = _Some;
      source = _source;
      break _L;
    }
  }
  return _M0FP36mizchi6kagura6draw2d31new__atlas__quad__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, source, left, top, right, bottom, uniform_dwords);
}
function _M0FP36mizchi6kagura8sprite2d36append__atlas__sprite__draw__command(commands, atlas_repository, atlas_key, dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, left, top, right, bottom, uniform_dwords) {
  let command;
  _L: {
    const _bind$3 = _M0FP36mizchi6kagura8sprite2d33new__atlas__sprite__draw__command(atlas_repository, atlas_key, dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, left, top, right, bottom, uniform_dwords);
    if (_bind$3 === undefined) {
      return false;
    } else {
      const _Some = _bind$3;
      const _command = _Some;
      command = _command;
      break _L;
    }
  }
  _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(commands, command);
  return true;
}
function _M0FP36mizchi6kagura4text22new__font__load__hooks(load_font_data) {
  return new _M0TP36mizchi6kagura4text13FontLoadHooks(load_font_data);
}
function _M0FP36mizchi6kagura4text25default__load__font__data(_name) {
  return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
}
function _M0FP36mizchi6kagura4text26default__font__load__hooks() {
  return new _M0TP36mizchi6kagura4text13FontLoadHooks(_M0FP36mizchi6kagura4text25default__load__font__data);
}
function _M0FP36mizchi6kagura4text22set__font__load__hooks(hooks) {
  _M0FP36mizchi6kagura4text17font__load__hooks.val = hooks;
}
function _M0FP36mizchi6kagura4text24reset__font__load__hooks() {
  _M0FP36mizchi6kagura4text17font__load__hooks.val = _M0FP36mizchi6kagura4text26default__font__load__hooks();
}
function _M0FP26mizchi19web__runtime__hooks25mark__gpu__texture__dirty(image_id) {
  const _bind$3 = _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty.val;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const id = _bind$3[_];
      if (id === image_id) {
        return undefined;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MPC15array5Array4pushGiE(_M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty.val, image_id);
}
function _M0FP26mizchi19web__runtime__hooks26clear__gpu__texture__dirty() {
  _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty.val = [];
}
function _M0FP26mizchi19web__runtime__hooks16normalized__size(value) {
  return value <= 0 ? 1 : value;
}
function _M0FP26mizchi19web__runtime__hooks30normalized__source__generation(generation) {
  return generation <= 0 ? 1 : generation;
}
function _M0FP26mizchi19web__runtime__hooks30synced__source__generation__at(image_id) {
  const generation = new _M0TPC13ref3RefGiE(0);
  const _bind$3 = _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (entry.image_id === image_id) {
        generation.val = entry.generation;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return generation.val;
}
function _M0FP26mizchi19web__runtime__hooks31set__synced__source__generation(image_id, generation) {
  const next = [];
  const replaced = new _M0TPC13ref3RefGbE(false);
  const safe_generation = _M0FP26mizchi19web__runtime__hooks30normalized__source__generation(generation);
  const _bind$3 = _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (entry.image_id === image_id) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, new _M0TP26mizchi19web__runtime__hooks22SyncedSourceGeneration(image_id, safe_generation));
        replaced.val = true;
      } else {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, entry);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (!replaced.val) {
    _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, new _M0TP26mizchi19web__runtime__hooks22SyncedSourceGeneration(image_id, safe_generation));
  }
  _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val = next;
}
function _M0FP26mizchi19web__runtime__hooks34clear__synced__source__generations() {
  _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val = [];
}
function _M0FP26mizchi19web__runtime__hooks32drop__synced__source__generation(image_id) {
  const next = [];
  const _bind$3 = _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (entry.image_id !== image_id) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, entry);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val = next;
}
function _M0FP26mizchi19web__runtime__hooks31expected__rgba8__channel__count(width, height) {
  return Math.imul(Math.imul(_M0FP26mizchi19web__runtime__hooks16normalized__size(width), _M0FP26mizchi19web__runtime__hooks16normalized__size(height)) | 0, 4) | 0;
}
function _M0FP26mizchi19web__runtime__hooks26has__valid__rgba8__payload(rgba8_channels, width, height) {
  const expected = _M0FP26mizchi19web__runtime__hooks31expected__rgba8__channel__count(width, height);
  return expected > 0 && rgba8_channels.length >= expected;
}
function _M0FP26mizchi19web__runtime__hooks18clamp__u8__channel(value) {
  return value < 0 ? 0 : value > 255 ? 255 : value;
}
function _M0FP26mizchi19web__runtime__hooks27normalized__rgba8__channels(rgba8_channels, width, height) {
  const expected = _M0FP26mizchi19web__runtime__hooks31expected__rgba8__channel__count(width, height);
  const out = [];
  if (expected <= 0 || rgba8_channels.length < expected) {
    return out;
  } else {
    const _bind$3 = 0;
    let _tmp$2 = _bind$3;
    while (true) {
      const i = _tmp$2;
      if (i < expected) {
        _M0MPC15array5Array4pushGiE(out, _M0FP26mizchi19web__runtime__hooks18clamp__u8__channel(_M0MPC15array5Array2atGiE(rgba8_channels, i)));
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return out;
  }
}
function _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(image_id) {
  const out = new _M0TPC13ref3RefGORP26mizchi19web__runtime__hooks21SourceImageCacheEntryE(undefined);
  const _bind$3 = _M0FP26mizchi19web__runtime__hooks20source__image__cache.val;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (entry.image_id === image_id) {
        out.val = entry;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP26mizchi19web__runtime__hooks32set__source__image__cache__entry(next_entry) {
  const next = [];
  const replaced = new _M0TPC13ref3RefGbE(false);
  const _bind$3 = _M0FP26mizchi19web__runtime__hooks20source__image__cache.val;
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const entry = _bind$3[_];
      if (entry.image_id === next_entry.image_id) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, next_entry);
        replaced.val = true;
      } else {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, entry);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (!replaced.val) {
    _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(next, next_entry);
  }
  _M0FP26mizchi19web__runtime__hooks20source__image__cache.val = next;
}
function _M0FP26mizchi19web__runtime__hooks27clear__source__image__cache() {
  _M0FP26mizchi19web__runtime__hooks20source__image__cache.val = [];
}
function _M0FP26mizchi19web__runtime__hooks20bridge__audio__close() {
  _M0FP26mizchi19web__runtime__hooks16js__audio__close();
}
function _M0FP26mizchi19web__runtime__hooks21bridge__audio__resume() {
  _M0FP26mizchi19web__runtime__hooks17js__audio__resume();
}
function _M0FP26mizchi19web__runtime__hooks22bridge__audio__suspend() {
  _M0FP26mizchi19web__runtime__hooks18js__audio__suspend();
}
function _M0FP26mizchi19web__runtime__hooks30bridge__audio__try__initialize(format) {
  return _M0FP26mizchi19web__runtime__hooks26js__audio__try__initialize(format.sample_rate, format.channels);
}
function _M0FP26mizchi19web__runtime__hooks28bridge__audio__write__frames(output, frames) {
  const channels = 2;
  const write_pos = _M0FP26mizchi19web__runtime__hooks26js__audio__get__write__pos();
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < frames) {
      const _bind$4 = 0;
      let _tmp$3 = _bind$4;
      while (true) {
        const ch = _tmp$3;
        if (ch < channels) {
          const idx = (Math.imul(i, channels) | 0) + ch | 0;
          let value;
          if (idx < output.length) {
            $bound_check(output, idx);
            value = output[idx];
          } else {
            value = 0;
          }
          _M0FP26mizchi19web__runtime__hooks24js__audio__write__sample(write_pos + i | 0, ch, value);
          _tmp$3 = ch + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP26mizchi19web__runtime__hooks25js__audio__advance__write(frames);
  _M0FP26mizchi19web__runtime__hooks24js__audio__write__frames(frames);
  return frames;
}
function _M0FP26mizchi19web__runtime__hooks24bridge__load__font__data(name) {
  const size = _M0FP26mizchi19web__runtime__hooks20js__load__font__data(name);
  if (size <= 0) {
    return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
  }
  const data = _M0MPC15array5Array4makeGiE(size, 0);
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < size) {
      _M0MPC15array5Array3setGiE(data, i, _M0FP26mizchi19web__runtime__hooks26js__load__font__data__byte(i));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(data);
}
function _M0FP26mizchi19web__runtime__hooks27bridge__web__capture__input(active, _tick) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    const pressed_keys = [];
    const key_count = _M0FP26mizchi19web__runtime__hooks30js__input__pressed__key__count();
    const _bind$3 = 0;
    let _tmp$2 = _bind$3;
    while (true) {
      const i = _tmp$2;
      if (i < key_count) {
        _M0MPC15array5Array4pushGiE(pressed_keys, _M0FP26mizchi19web__runtime__hooks27js__input__pressed__key__at(i));
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const pressed_mouse_buttons = [];
    const mouse_button_count = _M0FP26mizchi19web__runtime__hooks40js__input__pressed__mouse__button__count();
    const _bind$4 = 0;
    let _tmp$3 = _bind$4;
    while (true) {
      const i = _tmp$3;
      if (i < mouse_button_count) {
        const button = _M0FP26mizchi19web__runtime__hooks37js__input__pressed__mouse__button__at(i);
        if (button >= 0) {
          _M0MPC15array5Array4pushGiE(pressed_mouse_buttons, button);
        }
        _tmp$3 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const touches = [];
    const touch_count = _M0FP26mizchi19web__runtime__hooks23js__input__touch__count();
    const _bind$5 = 0;
    let _tmp$4 = _bind$5;
    while (true) {
      const i = _tmp$4;
      if (i < touch_count) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(touches, _M0FP36mizchi6kagura4core17new__touch__point(_M0FP26mizchi19web__runtime__hooks24js__input__touch__id__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__x__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__y__at(i)));
        _tmp$4 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const gamepads = [];
    const gamepad_count = _M0FP26mizchi19web__runtime__hooks25js__input__gamepad__count();
    const _bind$6 = 0;
    let _tmp$5 = _bind$6;
    while (true) {
      const i = _tmp$5;
      if (i < gamepad_count) {
        const axes = [];
        const axis_count = _M0FP26mizchi19web__runtime__hooks31js__input__gamepad__axis__count(i);
        const _bind$7 = 0;
        let _tmp$6 = _bind$7;
        while (true) {
          const j = _tmp$6;
          if (j < axis_count) {
            _M0MPC15array5Array4pushGdE(axes, _M0FP26mizchi19web__runtime__hooks28js__input__gamepad__axis__at(i, j));
            _tmp$6 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        const pressed_buttons = [];
        const button_count = _M0FP26mizchi19web__runtime__hooks42js__input__gamepad__pressed__button__count(i);
        const _bind$8 = 0;
        let _tmp$7 = _bind$8;
        while (true) {
          const j = _tmp$7;
          if (j < button_count) {
            const button_id = _M0FP26mizchi19web__runtime__hooks39js__input__gamepad__pressed__button__at(i, j);
            if (button_id >= 0) {
              _M0MPC15array5Array4pushGiE(pressed_buttons, button_id);
            }
            _tmp$7 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0MPC15array5Array4pushGRP36mizchi6kagura5asset21SimpleAtlasImageEntryE(gamepads, _M0FP36mizchi6kagura4core22new__gamepad__snapshot(_M0FP26mizchi19web__runtime__hooks26js__input__gamepad__id__at(i), axes, pressed_buttons));
        _tmp$5 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const snapshot = _M0FP36mizchi6kagura4core26new__input__snapshot__full(_M0FP26mizchi19web__runtime__hooks20js__input__cursor__x(), _M0FP26mizchi19web__runtime__hooks20js__input__cursor__y(), _M0FP26mizchi19web__runtime__hooks19js__input__wheel__x(), _M0FP26mizchi19web__runtime__hooks19js__input__wheel__y(), pressed_keys, pressed_mouse_buttons, touches, gamepads);
    _M0FP26mizchi19web__runtime__hooks23js__clear__input__wheel();
    return snapshot;
  } else {
    return _M0FP36mizchi6kagura4core22empty__input__snapshot();
  }
}
function _M0FP26mizchi19web__runtime__hooks26bridge__web__close__window(_canvas_selector, active) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    _M0FP26mizchi19web__runtime__hooks22js__set__should__close(true);
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks19sync__surface__info(fallback_width, fallback_height) {
  return _M0FP26mizchi19web__runtime__hooks20js__prepare__surface(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, fallback_width, fallback_height);
}
function _M0FP26mizchi19web__runtime__hooks29bridge__web__current__surface(_canvas_selector, options) {
  _M0FP26mizchi19web__runtime__hooks19sync__surface__info(options.width, options.height);
  const width = _M0FP26mizchi19web__runtime__hooks18js__surface__width(options.width);
  const height = _M0FP26mizchi19web__runtime__hooks19js__surface__height(options.height);
  const dpr = _M0FP26mizchi19web__runtime__hooks16js__surface__dpr();
  const id = _M0FP26mizchi19web__runtime__hooks15js__surface__id();
  return _M0FP36mizchi6kagura8platform30create__webgpu__surface__token(id, width, height, dpr);
}
function _M0FP26mizchi19web__runtime__hooks25bridge__web__cursor__mode(_canvas_selector, active, current) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP36mizchi6kagura8platform23cursor__mode__from__int(_M0FP26mizchi19web__runtime__hooks16js__cursor__mode(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, _M0FP36mizchi6kagura8platform21cursor__mode__to__int(current)));
  } else {
    return current;
  }
}
function _M0FP26mizchi19web__runtime__hooks34bridge__web__device__scale__factor(_canvas_selector, active, current) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP26mizchi19web__runtime__hooks25js__device__scale__factor(current);
  } else {
    return current <= 0 ? 1 : current;
  }
}
function _M0FP26mizchi19web__runtime__hooks27bridge__web__gfx__on__begin(active, _kind, pass) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks17js__webgpu__begin(pass.clear_color.r, pass.clear_color.g, pass.clear_color.b, pass.clear_color.a);
    const dirty = _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty.val;
    const _bind$3 = dirty.length;
    let _tmp$2 = 0;
    while (true) {
      const _ = _tmp$2;
      if (_ < _bind$3) {
        const image_id = dirty[_];
        let entry;
        _L: {
          _L$2: {
            const _bind$4 = _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(image_id);
            if (_bind$4 === undefined) {
            } else {
              const _Some = _bind$4;
              const _entry = _Some;
              entry = _entry;
              break _L$2;
            }
            break _L;
          }
          const w = entry.width;
          const h = entry.height;
          const px = entry.pixels_rgba8;
          const pixel_count = Math.imul(w, h) | 0;
          if (px.length >= (Math.imul(pixel_count, 4) | 0)) {
            _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__begin(image_id, w, h);
            let _tmp$3 = 0;
            while (true) {
              const i = _tmp$3;
              if (i < pixel_count) {
                const base = Math.imul(i, 4) | 0;
                _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__pixel(i, _M0MPC15array5Array2atGiE(px, base), _M0MPC15array5Array2atGiE(px, base + 1 | 0), _M0MPC15array5Array2atGiE(px, base + 2 | 0), _M0MPC15array5Array2atGiE(px, base + 3 | 0));
                _tmp$3 = i + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            _M0FP26mizchi19web__runtime__hooks29js__gfx__upload__texture__end();
          }
        }
        _tmp$2 = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty.val = [];
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks26bridge__web__gfx__on__draw(active, _kind, command) {
  if (active) {
    const _tmp$2 = command.shader.source;
    const _bind$3 = "@vertex";
    if (_M0MPC16string6String8contains(_tmp$2, new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length))) {
      const vf_count = command.vertex_data.length;
      const ic = command.indices.length;
      const u_count = command.uniform_dwords.length;
      const src_count = command.src_image_ids.length;
      const blend = _M0FP36mizchi6kagura3gfx20blend__mode__to__int(command.blend);
      _M0FP26mizchi19web__runtime__hooks28js__gfx__custom__draw__begin(command.shader.id, command.shader.source, vf_count, ic, u_count, src_count, command.dst.id, command.dst.width, command.dst.height, blend, command.instance_count);
      let _tmp$3 = 0;
      while (true) {
        const i = _tmp$3;
        if (i < vf_count) {
          _M0FP26mizchi19web__runtime__hooks36js__gfx__custom__draw__vertex__float(i, _M0MPC15array5Array2atGdE(command.vertex_data, i));
          _tmp$3 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$4 = 0;
      while (true) {
        const i = _tmp$4;
        if (i < ic) {
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MPC15array5Array2atGiE(command.indices, i));
          _tmp$4 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$5 = 0;
      while (true) {
        const i = _tmp$5;
        if (i < u_count) {
          _M0FP26mizchi19web__runtime__hooks30js__gfx__custom__draw__uniform(i, _M0MPC15array5Array2atGiE(command.uniform_dwords, i));
          _tmp$5 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$6 = 0;
      while (true) {
        const i = _tmp$6;
        if (i < src_count) {
          _M0FP26mizchi19web__runtime__hooks33js__gfx__custom__draw__src__image(i, _M0MPC15array5Array2atGiE(command.src_image_ids, i));
          _tmp$6 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0FP26mizchi19web__runtime__hooks18js__gfx__draw__end();
      return;
    } else {
      const src_id = command.src_image_ids.length > 0 ? _M0MPC15array5Array2atGiE(command.src_image_ids, 0) : 0;
      const ur = command.uniform_dwords.length > 0 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 0) : 255;
      const ug = command.uniform_dwords.length > 1 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 1) : 255;
      const ub = command.uniform_dwords.length > 2 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 2) : 255;
      const ua = command.uniform_dwords.length > 3 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 3) : 255;
      if (4 === 0) {
        $panic();
      }
      const vc = command.vertex_data.length / 4 | 0;
      const ic = command.indices.length;
      _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__begin(vc, ic, src_id, ur, ug, ub, ua, command.dst.id, command.dst.width, command.dst.height);
      let _tmp$3 = 0;
      while (true) {
        const i = _tmp$3;
        if (i < vc) {
          const base = Math.imul(i, 4) | 0;
          _M0FP26mizchi19web__runtime__hooks21js__gfx__draw__vertex(i, _M0MPC15array5Array2atGdE(command.vertex_data, base), _M0MPC15array5Array2atGdE(command.vertex_data, base + 1 | 0), _M0MPC15array5Array2atGdE(command.vertex_data, base + 2 | 0), _M0MPC15array5Array2atGdE(command.vertex_data, base + 3 | 0));
          _tmp$3 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$4 = 0;
      while (true) {
        const i = _tmp$4;
        if (i < ic) {
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MPC15array5Array2atGiE(command.indices, i));
          _tmp$4 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0FP26mizchi19web__runtime__hooks18js__gfx__draw__end();
      return;
    }
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks25bridge__web__gfx__on__end(active, _kind, present) {
  if (active && present) {
    _M0FP26mizchi19web__runtime__hooks19js__webgpu__present();
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks28bridge__web__gfx__on__resize(active, _kind, width, height) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks20js__prepare__surface(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, width, height);
    _M0FP26mizchi19web__runtime__hooks27js__try__initialize__webgpu(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, width, height);
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks33bridge__web__gfx__try__initialize(kind, width, height) {
  if (kind === 1) {
    return _M0FP26mizchi19web__runtime__hooks27js__try__initialize__webgpu(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, width, height);
  } else {
    return false;
  }
}
function _M0FP26mizchi19web__runtime__hooks27bridge__web__is__fullscreen(_canvas_selector, active, current) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP26mizchi19web__runtime__hooks18js__is__fullscreen(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, current);
  } else {
    return current;
  }
}
function _M0FP26mizchi19web__runtime__hooks31bridge__web__is__vsync__enabled(_canvas_selector, active, current) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP26mizchi19web__runtime__hooks22js__is__vsync__enabled(current);
  } else {
    return current;
  }
}
function _M0FP26mizchi19web__runtime__hooks26bridge__web__outside__size(width, height) {
  _M0FP26mizchi19web__runtime__hooks19sync__surface__info(width, height);
  return _M0FP36mizchi6kagura4core18new__outside__size(_M0FP26mizchi19web__runtime__hooks18js__surface__width(width) + 0, _M0FP26mizchi19web__runtime__hooks19js__surface__height(height) + 0);
}
function _M0FP26mizchi19web__runtime__hooks17bridge__web__poll(active) {
  if (active && _M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks31bridge__web__request__attention(_canvas_selector, active) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    _M0FP26mizchi19web__runtime__hooks22js__request__attention();
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi19web__runtime__hooks30bridge__web__set__cursor__mode(_canvas_selector, active, mode) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP36mizchi6kagura8platform23cursor__mode__from__int(_M0FP26mizchi19web__runtime__hooks21js__set__cursor__mode(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, _M0FP36mizchi6kagura8platform21cursor__mode__to__int(mode)));
  } else {
    return mode;
  }
}
function _M0FP26mizchi19web__runtime__hooks39bridge__web__set__device__scale__factor(_canvas_selector, active, scale) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP26mizchi19web__runtime__hooks30js__set__device__scale__factor(scale);
  } else {
    return scale <= 0 ? 1 : scale;
  }
}
function _M0FP26mizchi19web__runtime__hooks28bridge__web__set__fullscreen(_canvas_selector, active, enabled) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP26mizchi19web__runtime__hooks19js__set__fullscreen(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val, enabled);
  } else {
    return enabled;
  }
}
function _M0FP26mizchi19web__runtime__hooks32bridge__web__set__vsync__enabled(_canvas_selector, active, enabled) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    return _M0FP26mizchi19web__runtime__hooks23js__set__vsync__enabled(enabled);
  } else {
    return enabled;
  }
}
function _M0FP26mizchi19web__runtime__hooks26bridge__web__should__close() {
  return _M0FP26mizchi19web__runtime__hooks24js__should__close__state();
}
function _M0FP26mizchi19web__runtime__hooks28bridge__web__try__initialize(canvas_selector, options) {
  if (!_M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val || _M0IP016_24default__implPB2Eq10not__equalGsE(canvas_selector, _M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val)) {
    return false;
  } else {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(canvas_selector);
    return _M0FP26mizchi19web__runtime__hooks19sync__surface__info(options.width, options.height);
  }
}
function _M0FP26mizchi19web__runtime__hooks7install(canvas_selector) {
  const already_installed = _M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val;
  _M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val = canvas_selector;
  _M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val = true;
  if (!already_installed) {
    _M0FP26mizchi19web__runtime__hooks27clear__source__image__cache();
    _M0FP26mizchi19web__runtime__hooks34clear__synced__source__generations();
    _M0FP26mizchi19web__runtime__hooks26clear__gpu__texture__dirty();
    _M0FP26mizchi19web__runtime__hooks30js__release__webgpu__resources();
  }
  _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(canvas_selector);
  _M0FP26mizchi19web__runtime__hooks22js__set__should__close(false);
  _M0FP26mizchi19web__runtime__hooks23js__set__vsync__enabled(true);
  _M0FP36mizchi6kagura8platform23set__web__canvas__hooks(_M0FP36mizchi6kagura8platform23new__web__canvas__hooks(_M0FP26mizchi19web__runtime__hooks28bridge__web__try__initialize, _M0FP26mizchi19web__runtime__hooks17bridge__web__poll, _M0FP26mizchi19web__runtime__hooks26bridge__web__should__close, _M0FP26mizchi19web__runtime__hooks26bridge__web__outside__size, _M0FP26mizchi19web__runtime__hooks29bridge__web__current__surface, _M0FP26mizchi19web__runtime__hooks27bridge__web__capture__input, _M0FP26mizchi19web__runtime__hooks28bridge__web__set__fullscreen, _M0FP26mizchi19web__runtime__hooks27bridge__web__is__fullscreen, _M0FP26mizchi19web__runtime__hooks30bridge__web__set__cursor__mode, _M0FP26mizchi19web__runtime__hooks25bridge__web__cursor__mode, _M0FP26mizchi19web__runtime__hooks39bridge__web__set__device__scale__factor, _M0FP26mizchi19web__runtime__hooks34bridge__web__device__scale__factor, _M0FP26mizchi19web__runtime__hooks32bridge__web__set__vsync__enabled, _M0FP26mizchi19web__runtime__hooks31bridge__web__is__vsync__enabled, _M0FP26mizchi19web__runtime__hooks26bridge__web__close__window, _M0FP26mizchi19web__runtime__hooks31bridge__web__request__attention, (_s, _a, _e) => {
  }, (_s, _a) => false, (_s, _a, c$2) => c$2, (_s, _a, c$2) => c$2));
  _M0FP36mizchi6kagura3gfx25set__web__graphics__hooks(_M0FP36mizchi6kagura3gfx25new__web__graphics__hooks(_M0FP26mizchi19web__runtime__hooks33bridge__web__gfx__try__initialize, _M0FP26mizchi19web__runtime__hooks27bridge__web__gfx__on__begin, _M0FP26mizchi19web__runtime__hooks25bridge__web__gfx__on__end, _M0FP26mizchi19web__runtime__hooks26bridge__web__gfx__on__draw, _M0FP26mizchi19web__runtime__hooks28bridge__web__gfx__on__resize));
  _M0FP36mizchi6kagura4text22set__font__load__hooks(_M0FP36mizchi6kagura4text22new__font__load__hooks(_M0FP26mizchi19web__runtime__hooks24bridge__load__font__data));
  _M0FP36mizchi6kagura5audio25set__audio__output__hooks(_M0FP36mizchi6kagura5audio31new__audio__output__hooks__full(_M0FP26mizchi19web__runtime__hooks30bridge__audio__try__initialize, _M0FP26mizchi19web__runtime__hooks28bridge__audio__write__frames, _M0FP26mizchi19web__runtime__hooks22bridge__audio__suspend, _M0FP26mizchi19web__runtime__hooks21bridge__audio__resume, _M0FP26mizchi19web__runtime__hooks20bridge__audio__close, _M0FP26mizchi19web__runtime__hooks26js__audio__output__latency));
}
function _M0FP26mizchi19web__runtime__hooks9uninstall() {
  _M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val = false;
  _M0FP26mizchi19web__runtime__hooks27clear__source__image__cache();
  _M0FP26mizchi19web__runtime__hooks34clear__synced__source__generations();
  _M0FP26mizchi19web__runtime__hooks26clear__gpu__texture__dirty();
  _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
  _M0FP26mizchi19web__runtime__hooks30js__release__webgpu__resources();
  _M0FP26mizchi19web__runtime__hooks22js__set__should__close(false);
  _M0FP36mizchi6kagura3gfx27reset__web__graphics__hooks();
  _M0FP36mizchi6kagura8platform25reset__web__canvas__hooks();
  _M0FP36mizchi6kagura4text24reset__font__load__hooks();
  _M0FP36mizchi6kagura5audio27reset__audio__output__hooks();
}
function _M0FP26mizchi19web__runtime__hooks8shutdown() {
  _M0FP26mizchi19web__runtime__hooks9uninstall();
}
function _M0FP26mizchi19web__runtime__hooks32register__source__image__palette(source_image_id, _palette) {
  if (source_image_id < 0) {
    return undefined;
  }
  const width = new _M0TPC13ref3RefGiE(1);
  const height = new _M0TPC13ref3RefGiE(1);
  const pixels_rgba8 = new _M0TPC13ref3RefGRPB5ArrayGiEE([]);
  let entry;
  _L: {
    _L$2: {
      const _bind$3 = _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(source_image_id);
      if (_bind$3 === undefined) {
      } else {
        const _Some = _bind$3;
        const _entry = _Some;
        entry = _entry;
        break _L$2;
      }
      break _L;
    }
    width.val = entry.width;
    height.val = entry.height;
    pixels_rgba8.val = entry.pixels_rgba8;
  }
  _M0FP26mizchi19web__runtime__hooks32set__source__image__cache__entry(new _M0TP26mizchi19web__runtime__hooks21SourceImageCacheEntry(source_image_id, width.val, height.val, pixels_rgba8.val));
  _M0FP26mizchi19web__runtime__hooks32drop__synced__source__generation(source_image_id);
}
function _M0FP26mizchi19web__runtime__hooks30register__source__image__rgba8(source_image_id, width, height, rgba8_channels) {
  if (source_image_id < 0) {
    return undefined;
  }
  const safe_width = _M0FP26mizchi19web__runtime__hooks16normalized__size(width);
  const safe_height = _M0FP26mizchi19web__runtime__hooks16normalized__size(height);
  const pixels_rgba8 = _M0FP26mizchi19web__runtime__hooks27normalized__rgba8__channels(rgba8_channels, safe_width, safe_height);
  if (pixels_rgba8.length === 0) {
    return undefined;
  }
  _M0FP26mizchi19web__runtime__hooks32set__source__image__cache__entry(new _M0TP26mizchi19web__runtime__hooks21SourceImageCacheEntry(source_image_id, safe_width, safe_height, pixels_rgba8));
  _M0FP26mizchi19web__runtime__hooks32drop__synced__source__generation(source_image_id);
  _M0FP26mizchi19web__runtime__hooks25mark__gpu__texture__dirty(source_image_id);
}
function _M0FP26mizchi19web__runtime__hooks27patch__source__image__rgba8(source_image_id, width, height, dirty_x, dirty_y, dirty_width, dirty_height, rgba8_channels) {
  if (source_image_id < 0) {
    return false;
  }
  const safe_width = _M0FP26mizchi19web__runtime__hooks16normalized__size(width);
  const safe_height = _M0FP26mizchi19web__runtime__hooks16normalized__size(height);
  if (!_M0FP26mizchi19web__runtime__hooks26has__valid__rgba8__payload(rgba8_channels, safe_width, safe_height)) {
    return false;
  }
  let entry;
  _L: {
    const _bind$3 = _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(source_image_id);
    if (_bind$3 === undefined) {
      return false;
    } else {
      const _Some = _bind$3;
      const _entry = _Some;
      entry = _entry;
      break _L;
    }
  }
  if (entry.width !== safe_width || (entry.height !== safe_height || !_M0FP26mizchi19web__runtime__hooks26has__valid__rgba8__payload(entry.pixels_rgba8, safe_width, safe_height))) {
    return false;
  } else {
    const x0 = dirty_x < 0 ? 0 : dirty_x > safe_width ? safe_width : dirty_x;
    const y0 = dirty_y < 0 ? 0 : dirty_y > safe_height ? safe_height : dirty_y;
    const x1_raw = dirty_x + dirty_width | 0;
    const y1_raw = dirty_y + dirty_height | 0;
    const x1 = x1_raw < 0 ? 0 : x1_raw > safe_width ? safe_width : x1_raw;
    const y1 = y1_raw < 0 ? 0 : y1_raw > safe_height ? safe_height : y1_raw;
    if (x1 <= x0 || y1 <= y0) {
      return false;
    } else {
      const next_pixels = entry.pixels_rgba8;
      let _tmp$2 = y0;
      while (true) {
        const y = _tmp$2;
        if (y < y1) {
          let _tmp$3 = x0;
          while (true) {
            const x = _tmp$3;
            if (x < x1) {
              const base = Math.imul((Math.imul(y, safe_width) | 0) + x | 0, 4) | 0;
              _M0MPC15array5Array3setGiE(next_pixels, base, _M0FP26mizchi19web__runtime__hooks18clamp__u8__channel(_M0MPC15array5Array2atGiE(rgba8_channels, base)));
              _M0MPC15array5Array3setGiE(next_pixels, base + 1 | 0, _M0FP26mizchi19web__runtime__hooks18clamp__u8__channel(_M0MPC15array5Array2atGiE(rgba8_channels, base + 1 | 0)));
              _M0MPC15array5Array3setGiE(next_pixels, base + 2 | 0, _M0FP26mizchi19web__runtime__hooks18clamp__u8__channel(_M0MPC15array5Array2atGiE(rgba8_channels, base + 2 | 0)));
              _M0MPC15array5Array3setGiE(next_pixels, base + 3 | 0, _M0FP26mizchi19web__runtime__hooks18clamp__u8__channel(_M0MPC15array5Array2atGiE(rgba8_channels, base + 3 | 0)));
              _tmp$3 = x + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _tmp$2 = y + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0FP26mizchi19web__runtime__hooks32set__source__image__cache__entry(new _M0TP26mizchi19web__runtime__hooks21SourceImageCacheEntry(source_image_id, safe_width, safe_height, next_pixels));
      _M0FP26mizchi19web__runtime__hooks32drop__synced__source__generation(source_image_id);
      _M0FP26mizchi19web__runtime__hooks25mark__gpu__texture__dirty(source_image_id);
      return true;
    }
  }
}
function _M0FP26mizchi19web__runtime__hooks20sync__source__images(bindings) {
  const count = new _M0TPC13ref3RefGiE(0);
  const _bind$3 = bindings.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const binding = bindings[_];
      _L: {
        if (binding.image_id < 0) {
          break _L;
        }
        const generation = _M0FP26mizchi19web__runtime__hooks30normalized__source__generation(binding.generation);
        if (_M0FP26mizchi19web__runtime__hooks30synced__source__generation__at(binding.image_id) === generation) {
          break _L;
        }
        const required_channels = _M0FP26mizchi19web__runtime__hooks31expected__rgba8__channel__count(binding.width, binding.height);
        if (required_channels > 0 && binding.pixels_rgba8.length >= required_channels) {
          const patched = new _M0TPC13ref3RefGbE(false);
          let rect;
          _L$2: {
            _L$3: {
              const _bind$4 = binding.dirty_rect;
              if (_bind$4 === undefined) {
              } else {
                const _Some = _bind$4;
                const _rect = _Some;
                rect = _rect;
                break _L$3;
              }
              break _L$2;
            }
            const full_rect = rect.x <= 0 && (rect.y <= 0 && (rect.width >= _M0FP26mizchi19web__runtime__hooks16normalized__size(binding.width) && rect.height >= _M0FP26mizchi19web__runtime__hooks16normalized__size(binding.height)));
            if (!full_rect) {
              patched.val = _M0FP26mizchi19web__runtime__hooks27patch__source__image__rgba8(binding.image_id, binding.width, binding.height, rect.x, rect.y, rect.width, rect.height, binding.pixels_rgba8);
            }
          }
          if (!patched.val) {
            _M0FP26mizchi19web__runtime__hooks30register__source__image__rgba8(binding.image_id, binding.width, binding.height, binding.pixels_rgba8);
          }
        } else {
          _M0FP26mizchi19web__runtime__hooks32register__source__image__palette(binding.image_id, binding.palette);
        }
        _M0FP26mizchi19web__runtime__hooks31set__synced__source__generation(binding.image_id, generation);
        count.val = count.val + 1 | 0;
        break _L;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return count.val;
}
function _M0FP26mizchi19web__runtime__hooks43sync__dirty__atlas__pages__from__repository(repository) {
  const count = _M0FP26mizchi19web__runtime__hooks20sync__source__images(_M0FP36mizchi6kagura5asset34list__dirty__atlas__page__bindings(repository));
  _M0FP36mizchi6kagura5asset32clear__dirty__atlas__page__flags(repository);
  return count;
}
(() => {
  _M0FP26mizchi19web__runtime__hooks7install("#app");
  _M0FP36mizchi6kagura5asset12fetch__image("./assets/sample.png", (image_opt) => {
    let spec;
    _L: {
      if (image_opt === undefined) {
        _M0FPB7printlnGsE("Failed to load image");
        return;
      } else {
        const _Some = image_opt;
        const _spec = _Some;
        spec = _spec;
        break _L;
      }
    }
    const atlas = _M0FP36mizchi6kagura5asset37new__simple__atlas__image__repository(spec.width, spec.height, _M0FP26mizchi12fetch__image15atlas__page__id);
    const key = _M0FP36mizchi6kagura5asset15new__asset__key("sample");
    _M0FP36mizchi6kagura5asset20create__atlas__image(atlas, key, spec);
    _M0FP26mizchi19web__runtime__hooks43sync__dirty__atlas__pages__from__repository(atlas);
    _M0FP36mizchi6kagura6engine11run_2einner((_input) => {
    }, (ctx) => {
      const commands = [];
      _M0FP36mizchi6kagura8sprite2d36append__atlas__sprite__draw__command(commands, atlas, key, ctx.dst, ctx.shader, _M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, _M0FP26mizchi12fetch__image9screen__w, _M0FP26mizchi12fetch__image9screen__h, 6), 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), -1, -1, 1, 1, []);
      return commands;
    }, undefined, undefined, undefined, 735, _M0FP26mizchi12fetch__image9screen__w, _M0FP26mizchi12fetch__image9screen__h, "Fetch Image Demo", "#app");
  });
})();
//# sourceMappingURL=fetch_image.js.map
