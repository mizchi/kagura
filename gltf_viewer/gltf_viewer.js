function _M0DTPB4Json4Null() {}
_M0DTPB4Json4Null.prototype.$tag = 0;
const _M0DTPB4Json4Null__ = new _M0DTPB4Json4Null();
function _M0DTPB4Json4True() {}
_M0DTPB4Json4True.prototype.$tag = 1;
const _M0DTPB4Json4True__ = new _M0DTPB4Json4True();
function _M0DTPB4Json5False() {}
_M0DTPB4Json5False.prototype.$tag = 2;
const _M0DTPB4Json5False__ = new _M0DTPB4Json5False();
function _M0DTPB4Json6Number(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPB4Json6Number.prototype.$tag = 3;
function _M0DTPB4Json6String(param0) {
  this._0 = param0;
}
_M0DTPB4Json6String.prototype.$tag = 4;
function _M0DTPB4Json5Array(param0) {
  this._0 = param0;
}
_M0DTPB4Json5Array.prototype.$tag = 5;
function _M0DTPB4Json6Object(param0) {
  this._0 = param0;
}
_M0DTPB4Json6Object.prototype.$tag = 6;
function _M0TPB15WasmHelperCache(param0, param1) {
  this.tried = param0;
  this.exports = param1;
}
const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $f32_reinterpret_i32(a) {
  $reinterpret_view.setInt32(0, a, true);
  return $reinterpret_view.getFloat32(0, true);
}
const $_1L = { hi: -1, lo: -1 };
const $1000000000000000000L = { hi: 232830643, lo: -1486618624 };
const $0L = { hi: 0, lo: 0 };
function _M0TPC17strconv9FloatInfo(param0, param1, param2) {
  this.mantissa_bits = param0;
  this.exponent_bits = param1;
  this.bias = param2;
}
const $1L = { hi: 0, lo: 1 };
const $10L = { hi: 0, lo: 10 };
const $100L = { hi: 0, lo: 100 };
const $1000L = { hi: 0, lo: 1000 };
const $10000L = { hi: 0, lo: 10000 };
const $100000L = { hi: 0, lo: 100000 };
const $1000000L = { hi: 0, lo: 1000000 };
const $10000000L = { hi: 0, lo: 10000000 };
const $100000000L = { hi: 0, lo: 100000000 };
const $1000000000L = { hi: 0, lo: 1000000000 };
const $10000000000L = { hi: 2, lo: 1410065408 };
const $100000000000L = { hi: 23, lo: 1215752192 };
const $1000000000000L = { hi: 232, lo: -727379968 };
const $10000000000000L = { hi: 2328, lo: 1316134912 };
const $100000000000000L = { hi: 23283, lo: 276447232 };
const $1000000000000000L = { hi: 232830, lo: -1530494976 };
const $22L = { hi: 0, lo: 22 };
const $37L = { hi: 0, lo: 37 };
const $_22L = { hi: -1, lo: -22 };
function _M0TP36mizchi6kagura6engine14LifecycleHooks(param0, param1) {
  this.on_start = param0;
  this.on_stop = param1;
}
const $_4503599627370496L = { hi: -1048576, lo: 0 };
const $9221120237041090561L = { hi: 2146959360, lo: 1 };
const $9218868437227405312L = { hi: 2146435072, lo: 0 };
const $2L = { hi: 0, lo: 2 };
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
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
function _M0TPB7MyInt64(param0, param1) {
  this.hi = param0;
  this.lo = param1;
}
const _M0FPB12random__seed = () => {
  if (globalThis.crypto?.getRandomValues) {
    const array = new Uint32Array(1);
    globalThis.crypto.getRandomValues(array);
    return array[0] | 0; // Convert to signed 32
  } else {
    return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
  }
};
function _M0TPB6Hasher(param0) {
  this.acc = param0;
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
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function _M0TPB3MapGiRP36mizchi6kagura6mesh3d6Mesh3DE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGiRP36mizchi6kagura7scene3d9SceneNodeE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGsRPB4JsonE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGsiE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGiRP36mizchi6kagura7scene3d9SceneNodeE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGsiE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGsRPB4JsonE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
const _M0MPB7MyInt6422convert__to__double__u = (a) => (a.hi >>> 0) * 4294967296.0 + (a.lo >>> 0);
const _M0MPB7MyInt6423reinterpret__as__double = function f(a) {
  let view = f._view;
  if (view === undefined) {
    view = f._view = new DataView(new ArrayBuffer(8));
  }
  view.setUint32(0, a.hi);
  view.setUint32(4, a.lo);
  return view.getFloat64(0);
};
const _M0FPB23try__init__wasm__helper = function() {
  try {
    return new WebAssembly.Instance(new WebAssembly.Module(new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0, 1, 13, 2, 96, 0, 1, 127, 96, 4, 127, 127, 127, 127, 1, 127, 3, 7, 6, 0, 1, 1, 1, 1, 1, 6, 6, 1, 127, 1, 65, 0, 11, 7, 50, 6, 3, 109, 117, 108, 0, 1, 5, 100, 105, 118, 95, 115, 0, 2, 5, 100, 105, 118, 95, 117, 0, 3, 5, 114, 101, 109, 95, 115, 0, 4, 5, 114, 101, 109, 95, 117, 0, 5, 8, 103, 101, 116, 95, 104, 105, 103, 104, 0, 0, 10, 191, 1, 6, 4, 0, 35, 0, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 126, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 127, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 128, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 129, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 130, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11])), {}).exports;
  } catch (e) {
    return undefined;
  }
};
const _M0MPB7MyInt6411div__bigint = (a, b) => {
  const aVal = (BigInt(a.hi) << 32n) | BigInt(a.lo >>> 0);
  const bVal = (BigInt(b.hi) << 32n) | BigInt(b.lo >>> 0);
  const result = aVal / bVal;
  const lo = Number(result & 0xFFFFFFFFn);
  const hi = Number((result >> 32n) & 0xFFFFFFFFn);
  return { hi: hi | 0, lo: lo | 0 };
};
const _M0MPB7MyInt6414div__u__bigint = (a, b) => {
  const aVal = (BigInt(a.hi >>> 0) << 32n) | BigInt(a.lo >>> 0);
  const bVal = (BigInt(b.hi >>> 0) << 32n) | BigInt(b.lo >>> 0);
  const result = aVal / bVal;
  const lo = Number(result & 0xFFFFFFFFn);
  const hi = Number((result >> 32n) & 0xFFFFFFFFn);
  return { hi: hi | 0, lo: lo | 0 };
};
const _M0MPB7MyInt647compare = (a, b) => {
  const ahi = a.hi;
  const bhi = b.hi;
  if (ahi < bhi) {
    return -1;
  }
  if (ahi > bhi) {
    return 1;
  }
  const alo = a.lo >>> 0;
  const blo = b.lo >>> 0;
  if (alo < blo) {
    return -1;
  }
  if (alo > blo) {
    return 1;
  }
  return 0;
};
const _M0MPB7MyInt6410compare__u = (a, b) => {
  const ahi = a.hi >>> 0;
  const bhi = b.hi >>> 0;
  if (ahi < bhi) {
    return -1;
  }
  if (ahi > bhi) {
    return 1;
  }
  const alo = a.lo >>> 0;
  const blo = b.lo >>> 0;
  if (alo < blo) {
    return -1;
  }
  if (alo > blo) {
    return 1;
  }
  return 0;
};
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
const _M0MPB7MyInt6419convert__to__double = (a) => a.hi * 4294967296.0 + (a.lo >>> 0);
const $bytes_literal$0 = new Uint8Array();
function _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
function _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError.prototype.$tag = 12;
function _M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidAccessor(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidAccessor.prototype.$tag = 11;
function _M0DTPC15error5Error54mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidBufferView(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error54mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidBufferView.prototype.$tag = 10;
function _M0DTPC15error5Error61mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedComponentType(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error61mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedComponentType.prototype.$tag = 9;
function _M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedMode(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedMode.prototype.$tag = 8;
function _M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eBufferOutOfRange(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eBufferOutOfRange.prototype.$tag = 7;
function _M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eMissingAttribute(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eMissingAttribute.prototype.$tag = 6;
function _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError.prototype.$tag = 5;
function _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar.prototype.$tag = 4;
function _M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof() {}
_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof.prototype.$tag = 3;
const _M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__ = new _M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof();
function _M0DTPC15error5Error54moonbitlang_2fcore_2fjson_2eParseError_2eInvalidNumber(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC15error5Error54moonbitlang_2fcore_2fjson_2eParseError_2eInvalidNumber.prototype.$tag = 2;
function _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eInvalidIdentEscape(param0) {
  this._0 = param0;
}
_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eInvalidIdentEscape.prototype.$tag = 1;
function _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded() {}
_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded.prototype.$tag = 0;
const _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded__ = new _M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded();
function _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGuRPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGiRPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGiRPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
const $9223372036854775807L = { hi: 2147483647, lo: -1 };
const $16L = { hi: 0, lo: 16 };
const $_9223372036854775808L = { hi: -2147483648, lo: 0 };
function _M0TPC17strconv7Decimal(param0, param1, param2, param3, param4) {
  this.digits = param0;
  this.digits_num = param1;
  this.decimal_point = param2;
  this.negative = param3;
  this.truncated = param4;
}
function _M0DTPC16result6ResultGRPC17strconv7DecimalRPC17strconv12StrConvErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC17strconv7DecimalRPC17strconv12StrConvErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPC17strconv7DecimalRPC17strconv12StrConvErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC17strconv7DecimalRPC17strconv12StrConvErrorE2Ok.prototype.$tag = 1;
const $65536L = { hi: 0, lo: 65536 };
function _M0TPC17strconv6Number(param0, param1, param2, param3) {
  this.exponent = param0;
  this.mantissa = param1;
  this.negative = param2;
  this.many_digits = param3;
}
function _M0DTPC16option6OptionGdE4None() {}
_M0DTPC16option6OptionGdE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGdE4None__ = new _M0DTPC16option6OptionGdE4None();
function _M0DTPC16option6OptionGdE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGdE4Some.prototype.$tag = 1;
function _M0TPC14json8Position(param0, param1) {
  this.line = param0;
  this.column = param1;
}
function _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0TPC14json12ParseContext(param0, param1, param2, param3) {
  this.offset = param0;
  this.input = param1;
  this.end_offset = param2;
  this.remaining_available_depth = param3;
}
const $9007199254740991L = { hi: 2097151, lo: -1 };
const $_9007199254740991L = { hi: -2097152, lo: 1 };
function _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGiRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGiRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0TPC13ref3RefGiE(param0) {
  this.val = param0;
}
function _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok.prototype.$tag = 1;
function _M0DTPC14json5Token4Null() {}
_M0DTPC14json5Token4Null.prototype.$tag = 0;
const _M0DTPC14json5Token4Null__ = new _M0DTPC14json5Token4Null();
function _M0DTPC14json5Token4True() {}
_M0DTPC14json5Token4True.prototype.$tag = 1;
const _M0DTPC14json5Token4True__ = new _M0DTPC14json5Token4True();
function _M0DTPC14json5Token5False() {}
_M0DTPC14json5Token5False.prototype.$tag = 2;
const _M0DTPC14json5Token5False__ = new _M0DTPC14json5Token5False();
function _M0DTPC14json5Token6Number(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTPC14json5Token6Number.prototype.$tag = 3;
function _M0DTPC14json5Token6String(param0) {
  this._0 = param0;
}
_M0DTPC14json5Token6String.prototype.$tag = 4;
function _M0DTPC14json5Token6LBrace() {}
_M0DTPC14json5Token6LBrace.prototype.$tag = 5;
const _M0DTPC14json5Token6LBrace__ = new _M0DTPC14json5Token6LBrace();
function _M0DTPC14json5Token6RBrace() {}
_M0DTPC14json5Token6RBrace.prototype.$tag = 6;
const _M0DTPC14json5Token6RBrace__ = new _M0DTPC14json5Token6RBrace();
function _M0DTPC14json5Token8LBracket() {}
_M0DTPC14json5Token8LBracket.prototype.$tag = 7;
const _M0DTPC14json5Token8LBracket__ = new _M0DTPC14json5Token8LBracket();
function _M0DTPC14json5Token8RBracket() {}
_M0DTPC14json5Token8RBracket.prototype.$tag = 8;
const _M0DTPC14json5Token8RBracket__ = new _M0DTPC14json5Token8RBracket();
function _M0DTPC14json5Token5Comma() {}
_M0DTPC14json5Token5Comma.prototype.$tag = 9;
const _M0DTPC14json5Token5Comma__ = new _M0DTPC14json5Token5Comma();
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
function _M0TP36mizchi6kagura6math3d4Vec3(param0, param1, param2) {
  this.x = param0;
  this.y = param1;
  this.z = param2;
}
function _M0TP36mizchi6kagura6math3d4Vec4(param0, param1, param2, param3) {
  this.x = param0;
  this.y = param1;
  this.z = param2;
  this.w = param3;
}
function _M0TP36mizchi6kagura6math3d4Mat4(param0) {
  this.elements = param0;
}
function _M0TP36mizchi6kagura6math3d10Quaternion(param0, param1, param2, param3) {
  this.x = param0;
  this.y = param1;
  this.z = param2;
  this.w = param3;
}
function _M0TP36mizchi6kagura8camera3d8Camera3D(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.position = param0;
  this.target = param1;
  this.up = param2;
  this.fov_y_rad = param3;
  this.aspect = param4;
  this.near = param5;
  this.far = param6;
  this.projection_mode = param7;
}
function _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective() {}
_M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective.prototype.$tag = 0;
const _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective__ = new _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective();
function _M0DTP36mizchi6kagura8camera3d14ProjectionMode12Orthographic(param0, param1, param2, param3) {
  this._0 = param0;
  this._1 = param1;
  this._2 = param2;
  this._3 = param3;
}
_M0DTP36mizchi6kagura8camera3d14ProjectionMode12Orthographic.prototype.$tag = 1;
function _M0TP36mizchi6kagura8camera3d11OrbitCamera(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.target = param0;
  this.distance = param1;
  this.yaw = param2;
  this.pitch = param3;
  this.fov_y_rad = param4;
  this.aspect = param5;
  this.near = param6;
  this.far = param7;
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
function _M0TP36mizchi6kagura7light3d16DirectionalLight(param0, param1, param2) {
  this.direction = param0;
  this.color = param1;
  this.intensity = param2;
}
function _M0TP36mizchi6kagura7light3d12AmbientLight(param0, param1) {
  this.color = param0;
  this.intensity = param1;
}
function _M0TP36mizchi6kagura7light3d19LightingEnvironment(param0, param1, param2, param3) {
  this.directional = param0;
  this.ambient = param1;
  this.point_lights = param2;
  this.spot_lights = param3;
}
function _M0TP36mizchi6kagura6mesh3d12MeshBounds3D(param0, param1, param2, param3, param4, param5) {
  this.min_x = param0;
  this.min_y = param1;
  this.min_z = param2;
  this.max_x = param3;
  this.max_y = param4;
  this.max_z = param5;
}
function _M0TP36mizchi6kagura6mesh3d6Mesh3D(param0, param1, param2) {
  this.vertex_data = param0;
  this.indices = param1;
  this.bounds = param2;
}
function _M0TP36mizchi6kagura11transform3d11Transform3D(param0, param1, param2) {
  this.position = param0;
  this.rotation = param1;
  this.scale = param2;
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
function _M0TP36mizchi6kagura7scene3d8Material(param0, param1, param2, param3, param4) {
  this.color = param0;
  this.src_image_id = param1;
  this.metallic = param2;
  this.roughness = param3;
  this.emissive = param4;
}
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4Some.prototype.$tag = 1;
function _M0TP36mizchi6kagura7scene3d5Plane(param0, param1, param2, param3) {
  this.nx = param0;
  this.ny = param1;
  this.nz = param2;
  this.d = param3;
}
function _M0TP36mizchi6kagura7scene3d7Frustum(param0) {
  this.planes = param0;
}
function _M0TP36mizchi6kagura7scene3d10SceneGraph(param0, param1, param2) {
  this.nodes = param0;
  this.roots = param1;
  this.next_id = param2;
}
function _M0TPB9ArrayViewGUiRP36mizchi6kagura7scene3d9SceneNodeEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP36mizchi6kagura7scene3d9SceneNode(param0, param1, param2, param3, param4, param5) {
  this.transform = param0;
  this.mesh = param1;
  this.color = param2;
  this.material = param3;
  this.skinning = param4;
  this.children = param5;
}
function _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGuRP36mizchi6kagura4gltf9GltfErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP36mizchi6kagura4gltf9GltfErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRP36mizchi6kagura4gltf9GltfErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP36mizchi6kagura4gltf9GltfErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16option6OptionGORP36mizchi6kagura6mesh3d6Mesh3DE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura6mesh3d6Mesh3DE4None.prototype.$tag = 0;
function _M0DTPC16option6OptionGORP36mizchi6kagura6mesh3d6Mesh3DE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura6mesh3d6Mesh3DE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__ = new _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None();
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__ = new _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None();
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4Some.prototype.$tag = 1;
function _M0TPB9ArrayViewGUiRP36mizchi6kagura6mesh3d6Mesh3DEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE2Ok.prototype.$tag = 1;
function _M0TP36mizchi6kagura4gltf12GltfAccessor(param0, param1, param2, param3, param4) {
  this.buffer_view = param0;
  this.byte_offset = param1;
  this.component_type = param2;
  this.count = param3;
  this.type_ = param4;
}
function _M0TP36mizchi6kagura4gltf14GltfBufferView(param0, param1, param2) {
  this.buffer = param0;
  this.byte_offset = param1;
  this.byte_stride = param2;
}
function _M0TPB9ArrayViewGUsiEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP36mizchi6kagura4gltf13GltfPrimitive(param0, param1, param2, param3) {
  this.attributes = param0;
  this.indices = param1;
  this.material = param2;
  this.mode = param3;
}
function _M0TP36mizchi6kagura4gltf8GltfMesh(param0) {
  this.primitives = param0;
}
function _M0TP36mizchi6kagura4gltf8GltfNode(param0, param1, param2, param3, param4, param5) {
  this.mesh = param0;
  this.skin = param1;
  this.children = param2;
  this.translation = param3;
  this.rotation = param4;
  this.scale = param5;
}
function _M0TP36mizchi6kagura4gltf9GltfScene(param0) {
  this.nodes = param0;
}
function _M0TPC13ref3RefGRP36mizchi6kagura6math3d4Vec4E(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura4gltf12GltfMaterial(param0) {
  this.base_color_factor = param0;
}
function _M0TP36mizchi6kagura4gltf8GltfSkin(param0, param1) {
  this.joints = param0;
  this.inverse_bind_matrices = param1;
}
function _M0TP36mizchi6kagura4gltf15GltfAnimSampler(param0, param1, param2) {
  this.input = param0;
  this.output = param1;
  this.interpolation = param2;
}
function _M0TP36mizchi6kagura4gltf15GltfAnimChannel(param0, param1, param2) {
  this.sampler = param0;
  this.target_node = param1;
  this.target_path = param2;
}
function _M0TP36mizchi6kagura4gltf13GltfAnimation(param0, param1, param2) {
  this.name = param0;
  this.channels = param1;
  this.samplers = param2;
}
function _M0TP36mizchi6kagura4gltf12GltfDocument(param0, param1, param2, param3, param4, param5, param6, param7, param8) {
  this.accessors = param0;
  this.buffer_views = param1;
  this.meshes = param2;
  this.nodes = param3;
  this.scenes = param4;
  this.materials = param5;
  this.skins = param6;
  this.animations = param7;
  this.default_scene = param8;
}
function _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE2Ok.prototype.$tag = 1;
function _M0TPC13ref3RefGOsE(param0) {
  this.val = param0;
}
function _M0TPB9ArrayViewGcE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB9ArrayViewGyE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP36mizchi6kagura4text13FontLoadHooks(param0) {
  this.load_font_data = param0;
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
function _M0DTP26mizchi12gltf__viewer17SampleAssetSource10DefaultGlb(param0) {
  this._0 = param0;
}
_M0DTP26mizchi12gltf__viewer17SampleAssetSource10DefaultGlb.prototype.$tag = 0;
const _M0FP26mizchi12gltf__viewer16js__fetch__bytes = (url, cb) => { fetch(url).then(r=>r.arrayBuffer()).then(b=>cb(new Uint8Array(b))); };
const _M0FP26mizchi12gltf__viewer21js__get__query__param = (key) => new URLSearchParams(location.search).get(key) ?? "";
const _M0FP26mizchi12gltf__viewer27js__get__query__param__bool = (key, defaultVal) => {
   const v = new URLSearchParams(location.search).get(key)
   if (v == null) return defaultVal
   return v === "1" || v === "true" || v === "on"
 };
function _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__ = new _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None();
function _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4Some.prototype.$tag = 1;
function _M0TP26mizchi12gltf__viewer11ViewerState(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.graph = param0;
  this.camera = param1;
  this.lighting = param2;
  this.shader3d = param3;
  this.shader3d_textured = param4;
  this.node_count = param5;
  this.mesh_node_count = param6;
  this.show_hud = param7;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char };
function _M0FP15Error10to__string(_e) {
  switch (_e.$tag) {
    case 10: {
      return "mizchi/kagura/gltf.GltfError.InvalidBufferView";
    }
    case 11: {
      return "mizchi/kagura/gltf.GltfError.InvalidAccessor";
    }
    case 6: {
      return "mizchi/kagura/gltf.GltfError.MissingAttribute";
    }
    case 0: {
      return _M0IP016_24default__implPB4Show10to__stringGRPC14json10ParseErrorE(_e);
    }
    case 12: {
      return "mizchi/kagura/gltf.GltfError.ParseError";
    }
    case 2: {
      return _M0IP016_24default__implPB4Show10to__stringGRPC14json10ParseErrorE(_e);
    }
    case 8: {
      return "mizchi/kagura/gltf.GltfError.UnsupportedMode";
    }
    case 3: {
      return _M0IP016_24default__implPB4Show10to__stringGRPC14json10ParseErrorE(_e);
    }
    case 1: {
      return _M0IP016_24default__implPB4Show10to__stringGRPC14json10ParseErrorE(_e);
    }
    case 9: {
      return "mizchi/kagura/gltf.GltfError.UnsupportedComponentType";
    }
    case 7: {
      return "mizchi/kagura/gltf.GltfError.BufferOutOfRange";
    }
    case 4: {
      return _M0IP016_24default__implPB4Show10to__stringGRPC14json10ParseErrorE(_e);
    }
    default: {
      return _M0IP016_24default__implPB4Show10to__stringGRPC17strconv12StrConvErrorE(_e);
    }
  }
}
const _M0FPB4null = _M0DTPB4Json4Null__;
const _M0FPB19wasm__helper__cache = new _M0TPB15WasmHelperCache(false, undefined);
const _M0FPC15float10min__value = $f32_reinterpret_i32(-8388609);
const _M0FPC15float10max__value = $f32_reinterpret_i32(2139095039);
const _M0FPC15float14not__a__number = $f32_reinterpret_i32(2143289344);
const _M0FPC16uint6410max__value = $_1L;
const _M0FPC17strconv14base__err__str = "invalid base";
const _M0FPC17strconv15range__err__str = "value out of range";
const _M0FPC17strconv16syntax__err__str = "invalid syntax";
const _M0FPC17strconv20parse__int64_2einnerN7_2abindS543 = "";
const _M0FPC17strconv17min__19digit__int = $1000000000000000000L;
const _M0FPC17strconv17parse__scientificN8exp__numS241 = $0L;
const _M0FPC17strconv13parse__numberN11exp__numberS222 = $0L;
const _M0FPC17strconv12double__info = new _M0TPC17strconv9FloatInfo(52, 11, -1023);
const _M0FPC17strconv6powtab = [1, 3, 6, 9, 13, 16, 19, 23, 26, 29, 33, 36, 39, 43, 46, 49, 53, 56, 59];
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1070 = { _0: 0, _1: "" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1071 = { _0: 1, _1: "5" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1072 = { _0: 1, _1: "25" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1073 = { _0: 1, _1: "125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1074 = { _0: 2, _1: "625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1075 = { _0: 2, _1: "3125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1076 = { _0: 2, _1: "15625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1077 = { _0: 3, _1: "78125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1078 = { _0: 3, _1: "390625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1079 = { _0: 3, _1: "1953125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1080 = { _0: 4, _1: "9765625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1081 = { _0: 4, _1: "48828125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1082 = { _0: 4, _1: "244140625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1083 = { _0: 4, _1: "1220703125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1084 = { _0: 5, _1: "6103515625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1085 = { _0: 5, _1: "30517578125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1086 = { _0: 5, _1: "152587890625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1087 = { _0: 6, _1: "762939453125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1088 = { _0: 6, _1: "3814697265625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1089 = { _0: 6, _1: "19073486328125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1090 = { _0: 7, _1: "95367431640625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1091 = { _0: 7, _1: "476837158203125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1092 = { _0: 7, _1: "2384185791015625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1093 = { _0: 7, _1: "11920928955078125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1094 = { _0: 8, _1: "59604644775390625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1095 = { _0: 8, _1: "298023223876953125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1096 = { _0: 8, _1: "1490116119384765625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1097 = { _0: 9, _1: "7450580596923828125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1098 = { _0: 9, _1: "37252902984619140625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1099 = { _0: 9, _1: "186264514923095703125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1100 = { _0: 10, _1: "931322574615478515625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1101 = { _0: 10, _1: "4656612873077392578125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1102 = { _0: 10, _1: "23283064365386962890625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1103 = { _0: 10, _1: "116415321826934814453125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1104 = { _0: 11, _1: "582076609134674072265625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1105 = { _0: 11, _1: "2910383045673370361328125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1106 = { _0: 11, _1: "14551915228366851806640625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1107 = { _0: 12, _1: "72759576141834259033203125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1108 = { _0: 12, _1: "363797880709171295166015625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1109 = { _0: 12, _1: "1818989403545856475830078125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1110 = { _0: 13, _1: "9094947017729282379150390625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1111 = { _0: 13, _1: "45474735088646411895751953125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1112 = { _0: 13, _1: "227373675443232059478759765625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1113 = { _0: 13, _1: "1136868377216160297393798828125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1114 = { _0: 14, _1: "5684341886080801486968994140625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1115 = { _0: 14, _1: "28421709430404007434844970703125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1116 = { _0: 14, _1: "142108547152020037174224853515625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1117 = { _0: 15, _1: "710542735760100185871124267578125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1118 = { _0: 15, _1: "3552713678800500929355621337890625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1119 = { _0: 15, _1: "17763568394002504646778106689453125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1120 = { _0: 16, _1: "88817841970012523233890533447265625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1121 = { _0: 16, _1: "444089209850062616169452667236328125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1122 = { _0: 16, _1: "2220446049250313080847263336181640625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1123 = { _0: 16, _1: "11102230246251565404236316680908203125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1124 = { _0: 17, _1: "55511151231257827021181583404541015625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1125 = { _0: 17, _1: "277555756156289135105907917022705078125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1126 = { _0: 17, _1: "1387778780781445675529539585113525390625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1127 = { _0: 18, _1: "6938893903907228377647697925567626953125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1128 = { _0: 18, _1: "34694469519536141888238489627838134765625" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1129 = { _0: 18, _1: "173472347597680709441192448139190673828125" };
const _M0FPC17strconv34left__shift__cheats_2etuple_2f1130 = { _0: 19, _1: "867361737988403547205962240695953369140625" };
const _M0FPC17strconv19left__shift__cheats = [_M0FPC17strconv34left__shift__cheats_2etuple_2f1070, _M0FPC17strconv34left__shift__cheats_2etuple_2f1071, _M0FPC17strconv34left__shift__cheats_2etuple_2f1072, _M0FPC17strconv34left__shift__cheats_2etuple_2f1073, _M0FPC17strconv34left__shift__cheats_2etuple_2f1074, _M0FPC17strconv34left__shift__cheats_2etuple_2f1075, _M0FPC17strconv34left__shift__cheats_2etuple_2f1076, _M0FPC17strconv34left__shift__cheats_2etuple_2f1077, _M0FPC17strconv34left__shift__cheats_2etuple_2f1078, _M0FPC17strconv34left__shift__cheats_2etuple_2f1079, _M0FPC17strconv34left__shift__cheats_2etuple_2f1080, _M0FPC17strconv34left__shift__cheats_2etuple_2f1081, _M0FPC17strconv34left__shift__cheats_2etuple_2f1082, _M0FPC17strconv34left__shift__cheats_2etuple_2f1083, _M0FPC17strconv34left__shift__cheats_2etuple_2f1084, _M0FPC17strconv34left__shift__cheats_2etuple_2f1085, _M0FPC17strconv34left__shift__cheats_2etuple_2f1086, _M0FPC17strconv34left__shift__cheats_2etuple_2f1087, _M0FPC17strconv34left__shift__cheats_2etuple_2f1088, _M0FPC17strconv34left__shift__cheats_2etuple_2f1089, _M0FPC17strconv34left__shift__cheats_2etuple_2f1090, _M0FPC17strconv34left__shift__cheats_2etuple_2f1091, _M0FPC17strconv34left__shift__cheats_2etuple_2f1092, _M0FPC17strconv34left__shift__cheats_2etuple_2f1093, _M0FPC17strconv34left__shift__cheats_2etuple_2f1094, _M0FPC17strconv34left__shift__cheats_2etuple_2f1095, _M0FPC17strconv34left__shift__cheats_2etuple_2f1096, _M0FPC17strconv34left__shift__cheats_2etuple_2f1097, _M0FPC17strconv34left__shift__cheats_2etuple_2f1098, _M0FPC17strconv34left__shift__cheats_2etuple_2f1099, _M0FPC17strconv34left__shift__cheats_2etuple_2f1100, _M0FPC17strconv34left__shift__cheats_2etuple_2f1101, _M0FPC17strconv34left__shift__cheats_2etuple_2f1102, _M0FPC17strconv34left__shift__cheats_2etuple_2f1103, _M0FPC17strconv34left__shift__cheats_2etuple_2f1104, _M0FPC17strconv34left__shift__cheats_2etuple_2f1105, _M0FPC17strconv34left__shift__cheats_2etuple_2f1106, _M0FPC17strconv34left__shift__cheats_2etuple_2f1107, _M0FPC17strconv34left__shift__cheats_2etuple_2f1108, _M0FPC17strconv34left__shift__cheats_2etuple_2f1109, _M0FPC17strconv34left__shift__cheats_2etuple_2f1110, _M0FPC17strconv34left__shift__cheats_2etuple_2f1111, _M0FPC17strconv34left__shift__cheats_2etuple_2f1112, _M0FPC17strconv34left__shift__cheats_2etuple_2f1113, _M0FPC17strconv34left__shift__cheats_2etuple_2f1114, _M0FPC17strconv34left__shift__cheats_2etuple_2f1115, _M0FPC17strconv34left__shift__cheats_2etuple_2f1116, _M0FPC17strconv34left__shift__cheats_2etuple_2f1117, _M0FPC17strconv34left__shift__cheats_2etuple_2f1118, _M0FPC17strconv34left__shift__cheats_2etuple_2f1119, _M0FPC17strconv34left__shift__cheats_2etuple_2f1120, _M0FPC17strconv34left__shift__cheats_2etuple_2f1121, _M0FPC17strconv34left__shift__cheats_2etuple_2f1122, _M0FPC17strconv34left__shift__cheats_2etuple_2f1123, _M0FPC17strconv34left__shift__cheats_2etuple_2f1124, _M0FPC17strconv34left__shift__cheats_2etuple_2f1125, _M0FPC17strconv34left__shift__cheats_2etuple_2f1126, _M0FPC17strconv34left__shift__cheats_2etuple_2f1127, _M0FPC17strconv34left__shift__cheats_2etuple_2f1128, _M0FPC17strconv34left__shift__cheats_2etuple_2f1129, _M0FPC17strconv34left__shift__cheats_2etuple_2f1130];
const _M0FPC17strconv10int__pow10 = [$1L, $10L, $100L, $1000L, $10000L, $100000L, $1000000L, $10000000L, $100000000L, $1000000000L, $10000000000L, $100000000000L, $1000000000000L, $10000000000000L, $100000000000000L, $1000000000000000L];
const _M0FPC17strconv25max__exponent__fast__path = $22L;
const _M0FPC17strconv5table = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000, 100000000000, 1e+12, 1e+13, 1e+14, 1e+15, 1e+16, 1e+17, 1e+18, 1e+19, 1e+20, 1e+21, 1e+22, 0, 0, 0, 0, 0, 0, 0, 0, 0];
const _M0FPC17strconv36max__exponent__disguised__fast__path = $37L;
const _M0FPC17strconv25min__exponent__fast__path = $_22L;
const _M0MPC14json12ParseContext16lex__number__endN7_2abindS1058 = ".";
const _M0MPC14json12ParseContext16lex__number__endN7_2abindS1059 = "e";
const _M0MPC14json12ParseContext16lex__number__endN7_2abindS1060 = "E";
const _M0FP36mizchi6kagura6mesh3d16vertex3d__stride = 8;
const _M0FP36mizchi6kagura6draw3d10max__bones = 64;
const _M0FP26mizchi12gltf__viewer9screen__h = 480;
const _M0FP26mizchi12gltf__viewer9screen__w = 640;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP26mizchi19web__runtime__hooks21web__canvas__selector = _M0MPC13ref3Ref3newGsE("#app");
const _M0FP26mizchi19web__runtime__hooks21web__hooks__installed = _M0MPC13ref3Ref3newGbE(false);
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FPB33brute__force__find_2econstr_2f360 = 0;
const _M0FPB43boyer__moore__horspool__find_2econstr_2f346 = 0;
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
const _M0FPB4seed = _M0FPB12random__seed();
const _M0FPC14math35trig__reduce_2etwo__over__pi_2f1818 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
const _M0FPC16double13neg__infinity = _M0MPC15int645Int6423reinterpret__as__double($_4503599627370496L);
const _M0FPC16double14not__a__number = _M0MPC15int645Int6423reinterpret__as__double($9221120237041090561L);
const _M0FPC16double8infinity = _M0MPC15int645Int6423reinterpret__as__double($9218868437227405312L);
const _M0FPC17strconv25max__mantissa__fast__path = _M0IPC16uint646UInt64PB3Shl3shl($2L, 52);
const _M0FPC17strconv28checked__mul_2econstr_2f1547 = $0L;
function _M0FPC15abort5abortGyE(msg) {
  return $panic();
}
function _M0FPC15abort5abortGRPB4JsonE(msg) {
  return $panic();
}
function _M0FPC15abort5abortGuE(msg) {
  $panic();
}
function _M0FPC15abort5abortGOiE(msg) {
  return $panic();
}
function _M0MPB6Logger13write__objectGiE(self, obj) {
  _M0IPC13int3IntPB4Show6output(obj, self);
}
function _M0MPC14json4Json5array(array) {
  return new _M0DTPB4Json5Array(array);
}
function _M0FPB4rotl(x, r) {
  return x << r | (x >>> (32 - r | 0) | 0);
}
function _M0MPB6Hasher8consume4(self, input) {
  self.acc = Math.imul(_M0FPB4rotl((self.acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0, 17), 668265263) | 0;
}
function _M0MPB6Hasher13combine__uint(self, value) {
  self.acc = (self.acc >>> 0) + (4 >>> 0) | 0;
  _M0MPB6Hasher8consume4(self, value);
}
function _M0FPB5abortGyE(string, loc) {
  return _M0FPC15abort5abortGyE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0FPB5abortGRPB4JsonE(string, loc) {
  return _M0FPC15abort5abortGRPB4JsonE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0FPB5abortGuE(string, loc) {
  _M0FPC15abort5abortGuE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0FPB5abortGOiE(string, loc) {
  return _M0FPC15abort5abortGOiE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
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
function _M0MPC16uint166UInt1622is__leading__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 55296) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 56319);
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0FPB32code__point__of__surrogate__pair(leading, trailing) {
  return (((Math.imul(leading - 55296 | 0, 1024) | 0) + trailing | 0) - 56320 | 0) + 65536 | 0;
}
function _M0MPC16uint166UInt1616unsafe__to__char(self) {
  return self;
}
function _M0MPC16string6String16unsafe__char__at(self, index) {
  const c1 = self.charCodeAt(index);
  if (_M0MPC16uint166UInt1622is__leading__surrogate(c1)) {
    const c2 = self.charCodeAt(index + 1 | 0);
    return _M0FPB32code__point__of__surrogate__pair(c1, c2);
  } else {
    return _M0MPC16uint166UInt1616unsafe__to__char(c1);
  }
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
function _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPB13SourceLocRepr5parse(repr) {
  const _bind = new _M0TPC16string10StringView(repr, 0, repr.length);
  const _data = _M0MPC16string10StringView4data(_bind);
  const _start = _M0MPC16string10StringView13start__offset(_bind);
  const _end = _start + _M0MPC16string10StringView6length(_bind) | 0;
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
                let _tmp = 0;
                _L$3: while (true) {
                  const dispatch_15 = _tmp;
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
                                            _tmp = 3;
                                            continue _L$3;
                                          } else {
                                            break _L$7;
                                          }
                                        } else {
                                          _tmp = 6;
                                          continue _L$3;
                                        }
                                      }
                                    }
                                    _tmp = 0;
                                    continue _L$3;
                                  } else {
                                    break _L;
                                  }
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp = 1;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp = 0;
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
                                  _tmp = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp = 3;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp = 0;
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
                              _tmp = 1;
                              continue _L$3;
                            } else {
                              _tmp = 0;
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
                                  _tmp = 4;
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
                                                  _tmp = 5;
                                                  continue _L$3;
                                                }
                                              } else {
                                                if (next_char$4 > 58) {
                                                  break _L$8;
                                                } else {
                                                  _tmp = 3;
                                                  continue _L$3;
                                                }
                                              }
                                            }
                                            _tmp = 0;
                                            continue _L$3;
                                          } else {
                                            break _L$5;
                                          }
                                        }
                                      } else {
                                        if (next_char$3 > 58) {
                                          break _L$7;
                                        } else {
                                          _tmp = 1;
                                          continue _L$3;
                                        }
                                      }
                                    }
                                    _tmp = 0;
                                    continue _L$3;
                                  } else {
                                    break _L;
                                  }
                                }
                              }
                            }
                            _tmp = 0;
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
                                  _tmp = 5;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp = 3;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp = 0;
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
                                    _tmp = 3;
                                    continue _L$3;
                                  } else {
                                    break _L$6;
                                  }
                                } else {
                                  _tmp = 6;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp = 0;
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
                                  _tmp = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  _tmp = 1;
                                  continue _L$3;
                                }
                              }
                            }
                            _tmp = 0;
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
                          _tmp = 4;
                          continue;
                        }
                      } else {
                        if (next_char$2 > 58) {
                          break _L$5;
                        } else {
                          _tmp = 1;
                          continue;
                        }
                      }
                    }
                    _tmp = 0;
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
function _M0MPC16uint646UInt648to__byte(self) {
  return _M0MPC16uint646UInt647to__int(self) & 255;
}
function _M0IPC16uint166UInt16PB2Eq5equal(self, that) {
  return self === that;
}
function _M0IPC16uint166UInt16PB2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0MPB6Hasher12combine__int(self, value) {
  _M0MPB6Hasher13combine__uint(self, value);
}
function _M0MPC14json4Json6number(number, repr) {
  return new _M0DTPB4Json6Number(number, repr);
}
function _M0MPB7MyInt649from__int(value) {
  return new _M0TPB7MyInt64(value >> 31 & -1, value | 0);
}
function _M0MPC13int3Int9to__int64(self) {
  return _M0MPB7MyInt649from__int(self);
}
function _M0MPB6Hasher7combineGiE(self, value) {
  _M0IPC13int3IntPB4Hash13hash__combine(value, self);
}
function _M0MPB6Hasher7combineGsE(self, value) {
  _M0IPC16string6StringPB4Hash13hash__combine(value, self);
}
function _M0IP016_24default__implPB2Eq10not__equalGsE(x, y) {
  return !(x === y);
}
function _M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(x, y) {
  return !_M0IP26mizchi5audio10VoiceStatePB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB2Eq10not__equalGRPC16string10StringViewE(x, y) {
  return !_M0IPC16string10StringViewPB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB2Eq10not__equalGlE(x, y) {
  return !_M0IPC15int645Int64PB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB7Compare6op__ltGlE(x, y) {
  return _M0IPC15int645Int64PB7Compare7compare(x, y) < 0;
}
function _M0IP016_24default__implPB7Compare6op__ltGmE(x, y) {
  return _M0IPC16uint646UInt64PB7Compare7compare(x, y) < 0;
}
function _M0IP016_24default__implPB7Compare6op__gtGmE(x, y) {
  return _M0IPC16uint646UInt64PB7Compare7compare(x, y) > 0;
}
function _M0IP016_24default__implPB7Compare6op__gtGlE(x, y) {
  return _M0IPC15int645Int64PB7Compare7compare(x, y) > 0;
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__leGlE(x, y) {
  return _M0IPC15int645Int64PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__leGmE(x, y) {
  return _M0IPC16uint646UInt64PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) >= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGlE(x, y) {
  return _M0IPC15int645Int64PB7Compare7compare(x, y) >= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGmE(x, y) {
  return _M0IPC16uint646UInt64PB7Compare7compare(x, y) >= 0;
}
function _M0MPB6Hasher9avalanche(self) {
  let acc = self.acc;
  acc = acc ^ (acc >>> 15 | 0);
  acc = Math.imul(acc, -2048144777) | 0;
  acc = acc ^ (acc >>> 13 | 0);
  acc = Math.imul(acc, -1028477379) | 0;
  acc = acc ^ (acc >>> 16 | 0);
  return acc;
}
function _M0MPB6Hasher8finalize(self) {
  return _M0MPB6Hasher9avalanche(self);
}
function _M0MPB6Hasher11new_2einner(seed) {
  return new _M0TPB6Hasher((seed >>> 0) + (374761393 >>> 0) | 0);
}
function _M0MPB6Hasher3new(seed$46$opt) {
  let seed;
  if (seed$46$opt === undefined) {
    seed = _M0FPB4seed;
  } else {
    const _Some = seed$46$opt;
    seed = _Some;
  }
  return _M0MPB6Hasher11new_2einner(seed);
}
function _M0IP016_24default__implPB4Hash4hashGiE(self) {
  const h = _M0MPB6Hasher3new(undefined);
  _M0MPB6Hasher7combineGiE(h, self);
  return _M0MPB6Hasher8finalize(h);
}
function _M0IP016_24default__implPB4Hash4hashGsE(self) {
  const h = _M0MPB6Hasher3new(undefined);
  _M0MPB6Hasher7combineGsE(h, self);
  return _M0MPB6Hasher8finalize(h);
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
function _M0IP016_24default__implPB4Show10to__stringGRPC14json10ParseErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC14json10ParseErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGRPC17strconv12StrConvErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC17strconv12StrConvErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0FPB4reprGcE(t) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC14char4CharPB4Show6output(t, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
}
function _M0MPC16string10StringView12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = _M0MPC16string10StringView6length(self);
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= _M0MPC16string10StringView6length(self)) ? new _M0TPC16string10StringView(self.str, self.start + start_offset | 0, self.start + end_offset$2 | 0) : _M0FPB5abortGRPB4JsonE("Invalid index for View", "@moonbitlang/core/builtin:stringview.mbt:113:5-113:36");
}
function _M0IPC14byte4BytePB7Default7default() {
  return 0;
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
function _M0IPC16string10StringViewPB4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0IPC16string10StringViewPB2Eq5equal(self, other) {
  const len = _M0MPC16string10StringView6length(self);
  if (len === _M0MPC16string10StringView6length(other)) {
    if (self.str === other.str && self.start === other.start) {
      return true;
    }
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        if (_M0IPC16uint166UInt16PB2Eq5equal(self.str.charCodeAt(self.start + i | 0), other.str.charCodeAt(other.start + i | 0))) {
        } else {
          return false;
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return true;
  } else {
    return false;
  }
}
function _M0MPC16string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? new _M0TPC16string10StringView(self, start_offset, end_offset$2) : _M0FPB5abortGRPB4JsonE("Invalid index for View", "@moonbitlang/core/builtin:stringview.mbt:399:5-399:36");
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
function _M0MPC15array9ArrayView6lengthGcE(self) {
  return self.end - self.start | 0;
}
function _M0MPC15array9ArrayView6lengthGyE(self) {
  return self.end - self.start | 0;
}
function _M0MPC15array9ArrayView6lengthGUiRP36mizchi6kagura6mesh3d6Mesh3DEE(self) {
  return self.end - self.start | 0;
}
function _M0MPC16string6String11from__array(chars) {
  const buf = _M0MPB13StringBuilder11new_2einner(Math.imul(_M0MPC15array9ArrayView6lengthGcE(chars), 4) | 0);
  const _bind = chars.end - chars.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const c = chars.buf[chars.start + _ | 0];
      _M0IPB13StringBuilderPB6Logger11write__char(buf, c);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPB13StringBuilder10to__string(buf);
}
function _M0MPC16string10StringView11sub_2einner(self, start, end) {
  const str_len = self.str.length;
  let abs_end;
  if (end === undefined) {
    abs_end = self.end;
  } else {
    const _Some = end;
    const _end = _Some;
    abs_end = _end < 0 ? self.end + _end | 0 : self.start + _end | 0;
  }
  const abs_start = start < 0 ? self.end + start | 0 : self.start + start | 0;
  if (abs_start >= self.start && (abs_start <= abs_end && abs_end <= self.end)) {
    if (abs_start < str_len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.str.charCodeAt(abs_start))) {
      } else {
        $panic();
      }
    }
    if (abs_end < str_len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.str.charCodeAt(abs_end))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self.str, abs_start, abs_end);
  } else {
    return $panic();
  }
}
function _M0MPC16string6String24char__length__eq_2einner(self, len, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  let _tmp = start_offset;
  let _tmp$2 = 0;
  while (true) {
    const index = _tmp;
    const count = _tmp$2;
    if (index < end_offset$2 && count < len) {
      const c1 = self.charCodeAt(index);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index + 1 | 0) < end_offset$2) {
        const c2 = self.charCodeAt(index + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          _tmp = index + 2 | 0;
          _tmp$2 = count + 1 | 0;
          continue;
        } else {
          _M0FPB5abortGuE("invalid surrogate pair", "@moonbitlang/core/builtin:string.mbt:426:9-426:40");
        }
      }
      _tmp = index + 1 | 0;
      _tmp$2 = count + 1 | 0;
      continue;
    } else {
      return count === len && index === end_offset$2;
    }
  }
}
function _M0MPC16string6String24char__length__ge_2einner(self, len, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  let _tmp = start_offset;
  let _tmp$2 = 0;
  while (true) {
    const index = _tmp;
    const count = _tmp$2;
    if (index < end_offset$2 && count < len) {
      const c1 = self.charCodeAt(index);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index + 1 | 0) < end_offset$2) {
        const c2 = self.charCodeAt(index + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          _tmp = index + 2 | 0;
          _tmp$2 = count + 1 | 0;
          continue;
        } else {
          _M0FPB5abortGuE("invalid surrogate pair", "@moonbitlang/core/builtin:string.mbt:454:9-454:40");
        }
      }
      _tmp = index + 1 | 0;
      _tmp$2 = count + 1 | 0;
      continue;
    } else {
      return count >= len;
    }
  }
}
function _M0MPC16string6String31offset__of__nth__char__backward(self, n, start_offset, end_offset) {
  let char_count = 0;
  let utf16_offset = end_offset;
  while (true) {
    if ((utf16_offset - 1 | 0) >= start_offset && char_count < n) {
      const c = self.charCodeAt(utf16_offset - 1 | 0);
      if (_M0MPC16uint166UInt1623is__trailing__surrogate(c)) {
        utf16_offset = utf16_offset - 2 | 0;
      } else {
        utf16_offset = utf16_offset - 1 | 0;
      }
      char_count = char_count + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return char_count < n || utf16_offset < start_offset ? undefined : utf16_offset;
}
function _M0MPC16string6String30offset__of__nth__char__forward(self, n, start_offset, end_offset) {
  if (start_offset >= 0 && start_offset <= end_offset) {
    let utf16_offset = start_offset;
    let char_count = 0;
    while (true) {
      if (utf16_offset < end_offset && char_count < n) {
        const c = self.charCodeAt(utf16_offset);
        if (_M0MPC16uint166UInt1622is__leading__surrogate(c)) {
          utf16_offset = utf16_offset + 2 | 0;
        } else {
          utf16_offset = utf16_offset + 1 | 0;
        }
        char_count = char_count + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return char_count < n || utf16_offset >= end_offset ? undefined : utf16_offset;
  } else {
    return _M0FPB5abortGOiE("Invalid start index", "@moonbitlang/core/builtin:string.mbt:329:5-329:33");
  }
}
function _M0MPC16string6String29offset__of__nth__char_2einner(self, i, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return i >= 0 ? _M0MPC16string6String30offset__of__nth__char__forward(self, i, start_offset, end_offset$2) : _M0MPC16string6String31offset__of__nth__char__backward(self, -i | 0, start_offset, end_offset$2);
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
      const _bind = needle_len - 1 | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < _bind) {
          const _tmp$2 = _M0MPC16string10StringView11unsafe__get(needle, i) & 255;
          $bound_check(skip_table, _tmp$2);
          skip_table[_tmp$2] = (needle_len - 1 | 0) - i | 0;
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i <= (haystack_len - needle_len | 0)) {
          const _bind$2 = needle_len - 1 | 0;
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j <= _bind$2) {
              if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = _M0MPC16string10StringView11unsafe__get(haystack, (i + needle_len | 0) - 1 | 0) & 255;
          $bound_check(skip_table, _tmp$4);
          _tmp$2 = i + skip_table[_tmp$4] | 0;
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
    return _M0FPB43boyer__moore__horspool__find_2econstr_2f346;
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
            let _tmp = 1;
            while (true) {
              const j = _tmp;
              if (j < needle_len) {
                if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                  break;
                }
                _tmp = j + 1 | 0;
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
    return _M0FPB33brute__force__find_2econstr_2f360;
  }
}
function _M0MPC16string10StringView4find(self, str) {
  return _M0MPC16string10StringView6length(str) <= 4 ? _M0FPB18brute__force__find(self, str) : _M0FPB28boyer__moore__horspool__find(self, str);
}
function _M0MPC15array5Array4pushGcE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGyE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGzE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGdE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16string10StringView8contains(self, str) {
  const _bind = _M0MPC16string10StringView4find(self, str);
  return !(_bind === undefined);
}
function _M0MPC16string6String8contains(self, str) {
  return _M0MPC16string10StringView8contains(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0MPC16string10StringView9is__empty(self) {
  return _M0MPC16string10StringView6length(self) === 0;
}
function _M0MPC16string10StringView9get__char(self, idx) {
  if (idx >= 0 && idx < _M0MPC16string10StringView6length(self)) {
    const c = _M0MPC16string10StringView11unsafe__get(self, idx);
    if (_M0MPC16uint166UInt1622is__leading__surrogate(c)) {
      if ((idx + 1 | 0) < _M0MPC16string10StringView6length(self)) {
        const next = _M0MPC16string10StringView11unsafe__get(self, idx + 1 | 0);
        return _M0MPC16uint166UInt1623is__trailing__surrogate(next) ? _M0FPB32code__point__of__surrogate__pair(c, next) : -1;
      } else {
        return -1;
      }
    } else {
      return _M0MPC16uint166UInt1623is__trailing__surrogate(c) ? -1 : _M0MPC16uint166UInt1616unsafe__to__char(c);
    }
  } else {
    return -1;
  }
}
function _M0IPC13int3IntPB4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0MPC13int3Int18to__string_2einner(self, 10));
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC15array13ReadOnlyArray2atGmE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC15array13ReadOnlyArray2atGiE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC15array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC15array13ReadOnlyArray2atGdE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC15array13ReadOnlyArray6lengthGiE(self) {
  return self.length;
}
function _M0MPC15array9ArrayView2atGyE(self, index) {
  if (index >= 0 && index < (self.end - self.start | 0)) {
    const _tmp = self.buf;
    const _tmp$2 = self.start + index | 0;
    $bound_check(_tmp, _tmp$2);
    return _tmp[_tmp$2];
  } else {
    return _M0FPB5abortGyE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implPB4Show10to__stringGiE(self.end - self.start | 0)} but the index is ${_M0IP016_24default__implPB4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:arrayview.mbt:135:5-137:6");
  }
}
function _M0MPC16option6Option6unwrapGRPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0MPC16option6Option10unwrap__orGcE(self, default_) {
  return self === -1 ? default_ : self;
}
function _M0MPC16option6Option3mapGRPC16string10StringViewsE(self, f) {
  if (self === undefined) {
    return undefined;
  } else {
    const _Some = self;
    const _t = _Some;
    return f(_t);
  }
}
function _M0MPC15array5Array4makeGiE(len, elem) {
  const arr = new Array(len);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      arr[i] = elem;
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array4makeGdE(len, elem) {
  const arr = new Array(len);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      arr[i] = elem;
      _tmp = i + 1 | 0;
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
function _M0MPC15array5Array3setGdE(self, index, value) {
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
function _M0FPB21calc__grow__threshold(capacity) {
  if (16 === 0) {
    $panic();
  }
  return (Math.imul(capacity, 13) | 0) / 16 | 0;
}
function _M0MPC13int3Int20next__power__of__two(self) {
  if (self >= 0) {
    if (self <= 1) {
      return 1;
    }
    if (self > 1073741824) {
      return 1073741824;
    }
    return (2147483647 >> (Math.clz32(self - 1 | 0) - 1 | 0)) + 1 | 0;
  } else {
    return $panic();
  }
}
function _M0MPB3Map11new_2einnerGiRP36mizchi6kagura6mesh3d6Mesh3DE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGiRP36mizchi6kagura6mesh3d6Mesh3DE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map11new_2einnerGiRP36mizchi6kagura7scene3d9SceneNodeE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGiRP36mizchi6kagura7scene3d9SceneNodeE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map11new_2einnerGsRPB4JsonE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsRPB4JsonE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map11new_2einnerGsiE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsiE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map20add__entry__to__tailGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGiRP36mizchi6kagura7scene3d9SceneNodeE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGsiE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map10set__entryGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10set__entryGiRP36mizchi6kagura7scene3d9SceneNodeE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10set__entryGsiE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10set__entryGsRPB4JsonE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10push__awayGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map10push__awayGiRP36mizchi6kagura7scene3d9SceneNodeE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGiRP36mizchi6kagura7scene3d9SceneNodeE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGiRP36mizchi6kagura7scene3d9SceneNodeE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map10push__awayGsiE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsiE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsiE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map10push__awayGsRPB4JsonE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsRPB4JsonE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsRPB4JsonE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map15set__with__hashGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGiRP36mizchi6kagura6mesh3d6Mesh3DE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGiRP36mizchi6kagura6mesh3d6Mesh3DE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGiRP36mizchi6kagura6mesh3d6Mesh3DE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGiRP36mizchi6kagura7scene3d9SceneNodeE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGiRP36mizchi6kagura7scene3d9SceneNodeE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGiRP36mizchi6kagura7scene3d9SceneNodeE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGiRP36mizchi6kagura7scene3d9SceneNodeE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGiRP36mizchi6kagura7scene3d9SceneNodeE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGiRP36mizchi6kagura7scene3d9SceneNodeE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGiRP36mizchi6kagura7scene3d9SceneNodeE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGiRP36mizchi6kagura7scene3d9SceneNodeE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsiE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsiE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsiE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsiE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGsiE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsiE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsiE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsiE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsRPB4JsonE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsRPB4JsonE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsRPB4JsonE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGsRPB4JsonE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsRPB4JsonE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsRPB4JsonE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsRPB4JsonE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map4growGiRP36mizchi6kagura6mesh3d6Mesh3DE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const _param = _tmp;
    if (_param === undefined) {
      return;
    } else {
      const _Some = _param;
      const _x = _Some;
      const _next = _x.next;
      const _key = _x.key;
      const _value = _x.value;
      const _hash = _x.hash;
      _M0MPB3Map15set__with__hashGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4growGiRP36mizchi6kagura7scene3d9SceneNodeE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const _param = _tmp;
    if (_param === undefined) {
      return;
    } else {
      const _Some = _param;
      const _x = _Some;
      const _next = _x.next;
      const _key = _x.key;
      const _value = _x.value;
      const _hash = _x.hash;
      _M0MPB3Map15set__with__hashGiRP36mizchi6kagura7scene3d9SceneNodeE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4growGsiE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const _param = _tmp;
    if (_param === undefined) {
      return;
    } else {
      const _Some = _param;
      const _x = _Some;
      const _next = _x.next;
      const _key = _x.key;
      const _value = _x.value;
      const _hash = _x.hash;
      _M0MPB3Map15set__with__hashGsiE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4growGsRPB4JsonE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const _param = _tmp;
    if (_param === undefined) {
      return;
    } else {
      const _Some = _param;
      const _x = _Some;
      const _next = _x.next;
      const _key = _x.key;
      const _value = _x.value;
      const _hash = _x.hash;
      _M0MPB3Map15set__with__hashGsRPB4JsonE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map3setGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, key, value) {
  _M0MPB3Map15set__with__hashGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, key, value, _M0IP016_24default__implPB4Hash4hashGiE(key));
}
function _M0MPB3Map3setGiRP36mizchi6kagura7scene3d9SceneNodeE(self, key, value) {
  _M0MPB3Map15set__with__hashGiRP36mizchi6kagura7scene3d9SceneNodeE(self, key, value, _M0IP016_24default__implPB4Hash4hashGiE(key));
}
function _M0MPB3Map3setGsiE(self, key, value) {
  _M0MPB3Map15set__with__hashGsiE(self, key, value, _M0IP016_24default__implPB4Hash4hashGsE(key));
}
function _M0MPB3Map3setGsRPB4JsonE(self, key, value) {
  _M0MPB3Map15set__with__hashGsRPB4JsonE(self, key, value, _M0IP016_24default__implPB4Hash4hashGsE(key));
}
function _M0MPB3Map11from__arrayGiRP36mizchi6kagura6mesh3d6Mesh3DE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUiRP36mizchi6kagura6mesh3d6Mesh3DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGiRP36mizchi6kagura6mesh3d6Mesh3DE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGiRP36mizchi6kagura6mesh3d6Mesh3DE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map11from__arrayGiRP36mizchi6kagura7scene3d9SceneNodeE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUiRP36mizchi6kagura6mesh3d6Mesh3DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGiRP36mizchi6kagura7scene3d9SceneNodeE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGiRP36mizchi6kagura7scene3d9SceneNodeE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map11from__arrayGsiE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUiRP36mizchi6kagura6mesh3d6Mesh3DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGsiE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGsiE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map3getGiRP36mizchi6kagura6mesh3d6Mesh3DE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGiE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return undefined;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3getGsRPB4JsonE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGsE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return undefined;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3getGiRP36mizchi6kagura7scene3d9SceneNodeE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGiE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return undefined;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3getGsiE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGsE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return undefined;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map8containsGsiE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGsE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return false;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return true;
      }
      if (i > _entry.psl) {
        return false;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map6lengthGiRP36mizchi6kagura7scene3d9SceneNodeE(self) {
  return self.size;
}
function _M0MPB3Map4eachGiRP36mizchi6kagura7scene3d9SceneNodeE(self, f) {
  let _tmp = self.head;
  while (true) {
    const _param = _tmp;
    if (_param === undefined) {
      return;
    } else {
      const _Some = _param;
      const _x = _Some;
      const _key = _x.key;
      const _value = _x.value;
      const _next = _x.next;
      f(_key, _value);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4eachGsRPB4JsonE(self, f) {
  let _tmp = self.head;
  while (true) {
    const _param = _tmp;
    if (_param === undefined) {
      return;
    } else {
      const _Some = _param;
      const _x = _Some;
      const _key = _x.key;
      const _value = _x.value;
      const _next = _x.next;
      f(_key, _value);
      _tmp = _next;
      continue;
    }
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
function _M0IPC14byte4BytePB2Eq5equal(self, that) {
  return self === that;
}
function _M0MPC14json4Json6string(string) {
  return new _M0DTPB4Json6String(string);
}
function _M0MPC14json4Json7boolean(boolean) {
  return boolean ? _M0DTPB4Json4True__ : _M0DTPB4Json5False__;
}
function _M0MPC14json4Json6object(object) {
  return new _M0DTPB4Json6Object(object);
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
function _M0MPC16double6Double15convert__uint64(value) {
  return _M0MPB7MyInt6422convert__to__double__u(value);
}
function _M0MPC15int645Int6423reinterpret__as__double(self) {
  return _M0MPB7MyInt6423reinterpret__as__double(self);
}
function _M0MPC16string6String20unsafe__charcode__at(self, idx) {
  return self.charCodeAt(idx);
}
function _M0MPC14byte4Byte9to__int64(self) {
  return _M0MPC13int3Int9to__int64(self);
}
function _M0IPB7MyInt64PB3Neg3neg(self) {
  return self.lo === 0 ? new _M0TPB7MyInt64(~self.hi + 1 | 0, 0) : new _M0TPB7MyInt64(~self.hi, ~self.lo + 1 | 0);
}
function _M0MPB7MyInt6411add__hi__lo(self, bhi, blo) {
  const _ahi = self.hi;
  const _alo = self.lo;
  const lo = _alo + blo | 0;
  const s = lo >> 31;
  const as_ = _alo >> 31;
  const bs = blo >> 31;
  const c = (as_ & bs | ~s & (as_ ^ bs)) & 1;
  const hi = (_ahi + bhi | 0) + c | 0;
  return new _M0TPB7MyInt64(hi, lo);
}
function _M0IPB7MyInt64PB3Add3add(self, other) {
  return _M0MPB7MyInt6411add__hi__lo(self, other.hi, other.lo);
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
function _M0FPB29try__get__int64__wasm__helper() {
  if (_M0FPB19wasm__helper__cache.tried) {
    const _bind = _M0FPB19wasm__helper__cache.exports;
    return !(_bind === undefined);
  }
  _M0FPB19wasm__helper__cache.tried = true;
  _M0FPB19wasm__helper__cache.exports = _M0FPB23try__init__wasm__helper();
  const _bind = _M0FPB19wasm__helper__cache.exports;
  return !(_bind === undefined);
}
function _M0IPB7MyInt64PB3Div3div(self, other) {
  if (!(other.hi === 0 && other.lo === 0)) {
    if (!_M0FPB29try__get__int64__wasm__helper()) {
      return _M0MPB7MyInt6411div__bigint(self, other);
    }
    const _bind = _M0FPB19wasm__helper__cache.exports;
    if (_bind === undefined) {
      return $panic();
    } else {
      const _Some = _bind;
      const _exports = _Some;
      const _ahi = self.hi;
      const _alo = self.lo;
      const _bhi = other.hi;
      const _blo = other.lo;
      const _func = _exports.div_s;
      const lo = _func(_alo, _ahi, _blo, _bhi);
      const _func$2 = _exports.get_high;
      const hi = _func$2();
      return new _M0TPB7MyInt64(hi, lo);
    }
  } else {
    return $panic();
  }
}
function _M0MPB7MyInt646div__u(self, other) {
  if (!(other.hi === 0 && other.lo === 0)) {
    if (!_M0FPB29try__get__int64__wasm__helper()) {
      return _M0MPB7MyInt6414div__u__bigint(self, other);
    }
    const _bind = _M0FPB19wasm__helper__cache.exports;
    if (_bind === undefined) {
      return $panic();
    } else {
      const _Some = _bind;
      const _exports = _Some;
      const _ahi = self.hi;
      const _alo = self.lo;
      const _bhi = other.hi;
      const _blo = other.lo;
      const _func = _exports.div_u;
      const lo = _func(_alo, _ahi, _blo, _bhi);
      const _func$2 = _exports.get_high;
      const hi = _func$2();
      return new _M0TPB7MyInt64(hi, lo);
    }
  } else {
    return $panic();
  }
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
function _M0MPB7MyInt643asr(self, shift) {
  const shift$2 = shift & 63;
  return shift$2 === 0 ? self : shift$2 < 32 ? new _M0TPB7MyInt64(self.hi >> shift$2, self.lo >>> shift$2 | 0 | self.hi << (32 - shift$2 | 0)) : new _M0TPB7MyInt64(self.hi >> 31, self.hi >> (shift$2 - 32 | 0));
}
function _M0MPB7MyInt643clz(self) {
  return self.hi !== 0 ? Math.clz32(self.hi) : 32 + Math.clz32(self.lo) | 0;
}
function _M0IPB7MyInt64PB2Eq5equal(self, other) {
  return self.hi === other.hi && self.lo === other.lo;
}
function _M0MPB7MyInt648to__uint(self) {
  return self.lo;
}
function _M0IPC15int645Int64PB3Neg3neg(self) {
  return _M0IPB7MyInt64PB3Neg3neg(self);
}
function _M0IPC15int645Int64PB3Add3add(self, other) {
  return _M0IPB7MyInt64PB3Add3add(self, other);
}
function _M0IPC15int645Int64PB3Sub3sub(self, other) {
  return _M0IPB7MyInt64PB3Sub3sub(self, other);
}
function _M0IPC15int645Int64PB3Mul3mul(self, other) {
  return _M0IPB7MyInt64PB3Mul3mul(self, other);
}
function _M0IPC15int645Int64PB3Div3div(self, other) {
  return _M0IPB7MyInt64PB3Div3div(self, other);
}
function _M0IPC15int645Int64PB6BitAnd4land(self, other) {
  return _M0MPB7MyInt644land(self, other);
}
function _M0IPC15int645Int64PB5BitOr3lor(self, other) {
  return _M0MPB7MyInt643lor(self, other);
}
function _M0IPC15int645Int64PB3Shr3shr(self, other) {
  return _M0MPB7MyInt643asr(self, other);
}
function _M0IPC15int645Int64PB3Shl3shl(self, other) {
  return _M0MPB7MyInt643lsl(self, other);
}
function _M0IPC15int645Int64PB2Eq5equal(self, other) {
  return _M0IPB7MyInt64PB2Eq5equal(self, other);
}
function _M0IPC15int645Int64PB7Compare7compare(self, other) {
  return _M0MPB7MyInt647compare(self, other);
}
function _M0MPC15int645Int647to__int(self) {
  return _M0MPB7MyInt647to__int(self);
}
function _M0MPC16double6Double14convert__int64(value) {
  return _M0MPB7MyInt6419convert__to__double(value);
}
function _M0MPC15int645Int6410to__double(self) {
  return _M0MPC16double6Double14convert__int64(self);
}
function _M0MPC16double6Double22reinterpret__as__int64(self) {
  return _M0MPB7MyInt6419reinterpret__double(self);
}
function _M0IPC16uint646UInt64PB3Add3add(self, other) {
  return _M0IPB7MyInt64PB3Add3add(self, other);
}
function _M0IPC16uint646UInt64PB3Sub3sub(self, other) {
  return _M0IPB7MyInt64PB3Sub3sub(self, other);
}
function _M0IPC16uint646UInt64PB3Mul3mul(self, other) {
  return _M0IPB7MyInt64PB3Mul3mul(self, other);
}
function _M0IPC16uint646UInt64PB3Div3div(self, other) {
  return _M0MPB7MyInt646div__u(self, other);
}
function _M0MPC16uint646UInt648to__uint(self) {
  return _M0MPB7MyInt648to__uint(self);
}
function _M0IPC16uint646UInt64PB7Compare7compare(self, other) {
  return _M0MPB7MyInt6410compare__u(self, other);
}
function _M0IPC16uint646UInt64PB2Eq5equal(self, other) {
  return _M0IPB7MyInt64PB2Eq5equal(self, other);
}
function _M0IPC16uint646UInt64PB6BitAnd4land(self, other) {
  return _M0MPB7MyInt644land(self, other);
}
function _M0IPC16uint646UInt64PB3Shl3shl(self, shift) {
  return _M0MPB7MyInt643lsl(self, shift);
}
function _M0IPC16uint646UInt64PB3Shr3shr(self, shift) {
  return _M0MPB7MyInt643lsr(self, shift);
}
function _M0MPC16uint646UInt643clz(self) {
  return _M0MPB7MyInt643clz(self);
}
function _M0MPC13int3Int13is__surrogate(self) {
  return 55296 <= self && self <= 57343;
}
function _M0MPB6Hasher15combine__string(self, value) {
  const _bind = value.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      _M0MPB6Hasher13combine__uint(self, value.charCodeAt(i));
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0IPC16string6StringPB4Hash13hash__combine(self, hasher) {
  _M0MPB6Hasher15combine__string(hasher, self);
}
function _M0IPC13int3IntPB4Hash13hash__combine(self, hasher) {
  _M0MPB6Hasher12combine__int(hasher, self);
}
function _M0MPC16double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0MPC15bytes5Bytes5makei(length, value) {
  if (length <= 0) {
    return $bytes_literal$0;
  }
  const arr = $makebytes(length, value(0));
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < length) {
      $bound_check(arr, i);
      arr[i] = value(i);
      _tmp = i + 1 | 0;
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
function _M0MPC14char4Char7to__hex(char) {
  const code = char;
  return code >= 0 && code <= 255 ? _M0MPC14byte4Byte7to__hex(code & 255) : code <= 65535 ? `${_M0MPC14byte4Byte7to__hex(code >> 8 & 255)}${_M0MPC14byte4Byte7to__hex(code & 255)}` : `${_M0MPC14byte4Byte7to__hex(code >> 16 & 255)}${_M0MPC14byte4Byte7to__hex(code >> 8 & 255)}${_M0MPC14byte4Byte7to__hex(code & 255)}`;
}
function _M0MPC14char4Char11is__control(self) {
  return self >= 0 && self <= 31 ? true : self >= 127 && self <= 159;
}
function _M0MPC14char4Char13is__printable(self) {
  if (_M0MPC14char4Char11is__control(self)) {
    return false;
  }
  const self$2 = self;
  _L: {
    _L$2: {
      if (self$2 >= 57344 && self$2 <= 63743) {
        break _L$2;
      } else {
        if (self$2 >= 983040 && self$2 <= 1048573) {
          break _L$2;
        } else {
          if (self$2 >= 1048576 && self$2 <= 1114109) {
            break _L$2;
          }
        }
      }
      break _L;
    }
    return false;
  }
  _L$2: {
    _L$3: {
      if (self$2 === 173) {
        break _L$3;
      } else {
        if (self$2 >= 1536 && self$2 <= 1541) {
          break _L$3;
        } else {
          if (self$2 === 1564) {
            break _L$3;
          } else {
            if (self$2 === 1757) {
              break _L$3;
            } else {
              if (self$2 === 1807) {
                break _L$3;
              } else {
                if (self$2 >= 2192 && self$2 <= 2193) {
                  break _L$3;
                } else {
                  if (self$2 === 2274) {
                    break _L$3;
                  } else {
                    if (self$2 === 6158) {
                      break _L$3;
                    } else {
                      if (self$2 >= 8203 && self$2 <= 8207) {
                        break _L$3;
                      } else {
                        if (self$2 >= 8234 && self$2 <= 8238) {
                          break _L$3;
                        } else {
                          if (self$2 >= 8288 && self$2 <= 8292) {
                            break _L$3;
                          } else {
                            if (self$2 >= 8294 && self$2 <= 8303) {
                              break _L$3;
                            } else {
                              if (self$2 === 65279) {
                                break _L$3;
                              } else {
                                if (self$2 >= 65529 && self$2 <= 65531) {
                                  break _L$3;
                                } else {
                                  if (self$2 === 69821) {
                                    break _L$3;
                                  } else {
                                    if (self$2 === 69837) {
                                      break _L$3;
                                    } else {
                                      if (self$2 >= 78896 && self$2 <= 78911) {
                                        break _L$3;
                                      } else {
                                        if (self$2 >= 113824 && self$2 <= 113827) {
                                          break _L$3;
                                        } else {
                                          if (self$2 >= 119155 && self$2 <= 119162) {
                                            break _L$3;
                                          } else {
                                            if (self$2 === 917505) {
                                              break _L$3;
                                            } else {
                                              if (self$2 >= 917536 && self$2 <= 917631) {
                                                break _L$3;
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      break _L$2;
    }
    return false;
  }
  if (_M0MPC13int3Int13is__surrogate(self$2)) {
    return false;
  }
  if (self$2 === 8232 || self$2 === 8233) {
    return false;
  }
  _L$3: {
    _L$4: {
      if (self$2 >= 64976 && self$2 <= 65007) {
        break _L$4;
      } else {
        if (self$2 >= 65534 && self$2 <= 65535) {
          break _L$4;
        } else {
          if (self$2 >= 131070 && self$2 <= 131071) {
            break _L$4;
          } else {
            if (self$2 >= 196606 && self$2 <= 196607) {
              break _L$4;
            } else {
              if (self$2 >= 262142 && self$2 <= 262143) {
                break _L$4;
              } else {
                if (self$2 >= 327678 && self$2 <= 327679) {
                  break _L$4;
                } else {
                  if (self$2 >= 393214 && self$2 <= 393215) {
                    break _L$4;
                  } else {
                    if (self$2 >= 458750 && self$2 <= 458751) {
                      break _L$4;
                    } else {
                      if (self$2 >= 524286 && self$2 <= 524287) {
                        break _L$4;
                      } else {
                        if (self$2 >= 589822 && self$2 <= 589823) {
                          break _L$4;
                        } else {
                          if (self$2 >= 655358 && self$2 <= 655359) {
                            break _L$4;
                          } else {
                            if (self$2 >= 720894 && self$2 <= 720895) {
                              break _L$4;
                            } else {
                              if (self$2 >= 786430 && self$2 <= 786431) {
                                break _L$4;
                              } else {
                                if (self$2 >= 851966 && self$2 <= 851967) {
                                  break _L$4;
                                } else {
                                  if (self$2 >= 917502 && self$2 <= 917503) {
                                    break _L$4;
                                  } else {
                                    if (self$2 >= 983038 && self$2 <= 983039) {
                                      break _L$4;
                                    } else {
                                      if (self$2 >= 1048574 && self$2 <= 1048575) {
                                        break _L$4;
                                      } else {
                                        if (self$2 >= 1114110 && self$2 <= 1114111) {
                                          break _L$4;
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      break _L$3;
    }
    return false;
  }
  return true;
}
function _M0IPC14char4CharPB4Show6output(self, logger) {
  logger.method_table.method_3(logger.self, 39);
  _L: {
    _L$2: {
      if (self === 39) {
        break _L$2;
      } else {
        if (self === 92) {
          break _L$2;
        } else {
          if (self === 10) {
            logger.method_table.method_0(logger.self, "\\n");
          } else {
            if (self === 13) {
              logger.method_table.method_0(logger.self, "\\r");
            } else {
              if (self === 8) {
                logger.method_table.method_0(logger.self, "\\b");
              } else {
                if (self === 9) {
                  logger.method_table.method_0(logger.self, "\\t");
                } else {
                  if (self >= 32 && self <= 126) {
                    logger.method_table.method_3(logger.self, self);
                  } else {
                    if (!_M0MPC14char4Char13is__printable(self)) {
                      logger.method_table.method_0(logger.self, "\\u{");
                      logger.method_table.method_0(logger.self, _M0MPC14char4Char7to__hex(self));
                      logger.method_table.method_3(logger.self, 125);
                    } else {
                      logger.method_table.method_3(logger.self, self);
                    }
                  }
                }
              }
            }
          }
        }
      }
      break _L;
    }
    logger.method_table.method_3(logger.self, 92);
    logger.method_table.method_3(logger.self, self);
  }
  logger.method_table.method_3(logger.self, 39);
}
function _M0MPC14char4Char10utf16__len(self) {
  const code = self;
  return code <= 65535 ? 1 : 2;
}
function _M0MPC15bytes5Bytes11from__array(arr) {
  return _M0MPC15bytes5Bytes5makei(_M0MPC15array9ArrayView6lengthGyE(arr), (i) => _M0MPC15array9ArrayView2atGyE(arr, i));
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
  let _bind;
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
      _bind = { _0: module_name, _1: package_name };
    } else {
      _bind = { _0: pkg, _1: undefined };
    }
  }
  const _module_name = _bind._0;
  const _package_name = _bind._1;
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
function _M0MPC15array5Array6filterGRP26mizchi5audio5VoiceE(self, f) {
  const arr = [];
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
      if (f(v)) {
        _M0MPC15array5Array4pushGzE(arr, v);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, f) {
  const arr = [];
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
      if (f(v)) {
        _M0MPC15array5Array4pushGzE(arr, v);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
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
function _M0FPC17strconv9base__errGUiRPC16string10StringViewbEE() {
  return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv14base__err__str));
}
function _M0FPC17strconv25check__and__consume__base(view, base) {
  if (base === 0) {
    _L: {
      let rest;
      _L$2: {
        let rest$2;
        _L$3: {
          let rest$3;
          _L$4: {
            if (_M0MPC16string6String24char__length__ge_2einner(view.str, 2, view.start, view.end)) {
              const _x = _M0MPC16string6String16unsafe__char__at(view.str, _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 0, view.start, view.end));
              if (_x === 48) {
                const _x$2 = _M0MPC16string6String16unsafe__char__at(view.str, _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 1, view.start, view.end));
                switch (_x$2) {
                  case 120: {
                    const _tmp = view.str;
                    const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$2;
                    if (_bind === undefined) {
                      _tmp$2 = view.end;
                    } else {
                      const _Some = _bind;
                      _tmp$2 = _Some;
                    }
                    const _x$3 = new _M0TPC16string10StringView(_tmp, _tmp$2, view.end);
                    rest$3 = _x$3;
                    break _L$4;
                  }
                  case 88: {
                    const _tmp$3 = view.str;
                    const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$4;
                    if (_bind$2 === undefined) {
                      _tmp$4 = view.end;
                    } else {
                      const _Some = _bind$2;
                      _tmp$4 = _Some;
                    }
                    const _x$4 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, view.end);
                    rest$3 = _x$4;
                    break _L$4;
                  }
                  case 111: {
                    const _tmp$5 = view.str;
                    const _bind$3 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$6;
                    if (_bind$3 === undefined) {
                      _tmp$6 = view.end;
                    } else {
                      const _Some = _bind$3;
                      _tmp$6 = _Some;
                    }
                    const _x$5 = new _M0TPC16string10StringView(_tmp$5, _tmp$6, view.end);
                    rest$2 = _x$5;
                    break _L$3;
                  }
                  case 79: {
                    const _tmp$7 = view.str;
                    const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$8;
                    if (_bind$4 === undefined) {
                      _tmp$8 = view.end;
                    } else {
                      const _Some = _bind$4;
                      _tmp$8 = _Some;
                    }
                    const _x$6 = new _M0TPC16string10StringView(_tmp$7, _tmp$8, view.end);
                    rest$2 = _x$6;
                    break _L$3;
                  }
                  case 98: {
                    const _tmp$9 = view.str;
                    const _bind$5 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$10;
                    if (_bind$5 === undefined) {
                      _tmp$10 = view.end;
                    } else {
                      const _Some = _bind$5;
                      _tmp$10 = _Some;
                    }
                    const _x$7 = new _M0TPC16string10StringView(_tmp$9, _tmp$10, view.end);
                    rest = _x$7;
                    break _L$2;
                  }
                  case 66: {
                    const _tmp$11 = view.str;
                    const _bind$6 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$12;
                    if (_bind$6 === undefined) {
                      _tmp$12 = view.end;
                    } else {
                      const _Some = _bind$6;
                      _tmp$12 = _Some;
                    }
                    const _x$8 = new _M0TPC16string10StringView(_tmp$11, _tmp$12, view.end);
                    rest = _x$8;
                    break _L$2;
                  }
                  default: {
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
          return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 16, _1: rest$3, _2: true });
        }
        return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 8, _1: rest$2, _2: true });
      }
      return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 2, _1: rest, _2: true });
    }
    return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 10, _1: view, _2: false });
  } else {
    _L: {
      let rest;
      _L$2: {
        let rest$2;
        _L$3: {
          let rest$3;
          _L$4: {
            if (_M0MPC16string6String24char__length__ge_2einner(view.str, 2, view.start, view.end)) {
              const _x = _M0MPC16string6String16unsafe__char__at(view.str, _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 0, view.start, view.end));
              if (_x === 48) {
                const _x$2 = _M0MPC16string6String16unsafe__char__at(view.str, _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 1, view.start, view.end));
                switch (_x$2) {
                  case 120: {
                    const _tmp = view.str;
                    const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$2;
                    if (_bind === undefined) {
                      _tmp$2 = view.end;
                    } else {
                      const _Some = _bind;
                      _tmp$2 = _Some;
                    }
                    const _x$3 = new _M0TPC16string10StringView(_tmp, _tmp$2, view.end);
                    if (base === 16) {
                      rest$3 = _x$3;
                      break _L$4;
                    } else {
                      break _L;
                    }
                  }
                  case 88: {
                    const _tmp$3 = view.str;
                    const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$4;
                    if (_bind$2 === undefined) {
                      _tmp$4 = view.end;
                    } else {
                      const _Some = _bind$2;
                      _tmp$4 = _Some;
                    }
                    const _x$4 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, view.end);
                    if (base === 16) {
                      rest$3 = _x$4;
                      break _L$4;
                    } else {
                      break _L;
                    }
                  }
                  case 111: {
                    const _tmp$5 = view.str;
                    const _bind$3 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$6;
                    if (_bind$3 === undefined) {
                      _tmp$6 = view.end;
                    } else {
                      const _Some = _bind$3;
                      _tmp$6 = _Some;
                    }
                    const _x$5 = new _M0TPC16string10StringView(_tmp$5, _tmp$6, view.end);
                    if (base === 8) {
                      rest$2 = _x$5;
                      break _L$3;
                    } else {
                      break _L;
                    }
                  }
                  case 79: {
                    const _tmp$7 = view.str;
                    const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$8;
                    if (_bind$4 === undefined) {
                      _tmp$8 = view.end;
                    } else {
                      const _Some = _bind$4;
                      _tmp$8 = _Some;
                    }
                    const _x$6 = new _M0TPC16string10StringView(_tmp$7, _tmp$8, view.end);
                    if (base === 8) {
                      rest$2 = _x$6;
                      break _L$3;
                    } else {
                      break _L;
                    }
                  }
                  case 98: {
                    const _tmp$9 = view.str;
                    const _bind$5 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$10;
                    if (_bind$5 === undefined) {
                      _tmp$10 = view.end;
                    } else {
                      const _Some = _bind$5;
                      _tmp$10 = _Some;
                    }
                    const _x$7 = new _M0TPC16string10StringView(_tmp$9, _tmp$10, view.end);
                    if (base === 2) {
                      rest = _x$7;
                      break _L$2;
                    } else {
                      break _L;
                    }
                  }
                  case 66: {
                    const _tmp$11 = view.str;
                    const _bind$6 = _M0MPC16string6String29offset__of__nth__char_2einner(view.str, 2, view.start, view.end);
                    let _tmp$12;
                    if (_bind$6 === undefined) {
                      _tmp$12 = view.end;
                    } else {
                      const _Some = _bind$6;
                      _tmp$12 = _Some;
                    }
                    const _x$8 = new _M0TPC16string10StringView(_tmp$11, _tmp$12, view.end);
                    if (base === 2) {
                      rest = _x$8;
                      break _L$2;
                    } else {
                      break _L;
                    }
                  }
                  default: {
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
          return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 16, _1: rest$3, _2: true });
        }
        return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 8, _1: rest$2, _2: true });
      }
      return new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: 2, _1: rest, _2: true });
    }
    return base >= 2 && base <= 36 ? new _M0DTPC16result6ResultGUiRPC16string10StringViewbERPC17strconv12StrConvErrorE2Ok({ _0: base, _1: view, _2: false }) : _M0FPC17strconv9base__errGUiRPC16string10StringViewbEE();
  }
}
function _M0FPC17strconv10range__errGlE() {
  return new _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv15range__err__str));
}
function _M0FPC17strconv10range__errGuE() {
  return new _M0DTPC16result6ResultGuRPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv15range__err__str));
}
function _M0FPC17strconv11syntax__errGiE() {
  return new _M0DTPC16result6ResultGiRPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv16syntax__err__str));
}
function _M0FPC17strconv11syntax__errGlE() {
  return new _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv16syntax__err__str));
}
function _M0FPC17strconv11syntax__errGdE() {
  return new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv16syntax__err__str));
}
function _M0FPC17strconv11syntax__errGORPC17strconv6NumberE() {
  return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE3Err(new _M0DTPC15error5Error58moonbitlang_2fcore_2fstrconv_2eStrConvError_2eStrConvError(_M0FPC17strconv16syntax__err__str));
}
function _M0FPC17strconv19overflow__threshold(base, neg) {
  return !neg ? (base === 10 ? _M0IPC15int645Int64PB3Add3add(_M0IPC15int645Int64PB3Div3div($9223372036854775807L, $10L), $1L) : base === 16 ? _M0IPC15int645Int64PB3Add3add(_M0IPC15int645Int64PB3Div3div($9223372036854775807L, $16L), $1L) : _M0IPC15int645Int64PB3Add3add(_M0IPC15int645Int64PB3Div3div($9223372036854775807L, _M0MPC13int3Int9to__int64(base)), $1L)) : base === 10 ? _M0IPC15int645Int64PB3Div3div($_9223372036854775808L, $10L) : base === 16 ? _M0IPC15int645Int64PB3Div3div($_9223372036854775808L, $16L) : _M0IPC15int645Int64PB3Div3div($_9223372036854775808L, _M0MPC13int3Int9to__int64(base));
}
function _M0FPC17strconv20parse__int64_2einner(str, base) {
  if (_M0IP016_24default__implPB2Eq10not__equalGRPC16string10StringViewE(str, new _M0TPC16string10StringView(_M0FPC17strconv20parse__int64_2einnerN7_2abindS543, 0, _M0FPC17strconv20parse__int64_2einnerN7_2abindS543.length))) {
    let _bind;
    let rest;
    _L: {
      _L$2: {
        const _bind$2 = _M0MPC16string10StringView12view_2einner(str, 0, undefined);
        if (_M0MPC16string6String24char__length__ge_2einner(_bind$2.str, 1, _bind$2.start, _bind$2.end)) {
          const _x = _M0MPC16string6String16unsafe__char__at(_bind$2.str, _M0MPC16string6String29offset__of__nth__char_2einner(_bind$2.str, 0, _bind$2.start, _bind$2.end));
          switch (_x) {
            case 43: {
              const _tmp = _bind$2.str;
              const _bind$3 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind$2.str, 1, _bind$2.start, _bind$2.end);
              let _tmp$2;
              if (_bind$3 === undefined) {
                _tmp$2 = _bind$2.end;
              } else {
                const _Some = _bind$3;
                _tmp$2 = _Some;
              }
              const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, _bind$2.end);
              _bind = { _0: false, _1: _x$2 };
              break;
            }
            case 45: {
              const _tmp$3 = _bind$2.str;
              const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind$2.str, 1, _bind$2.start, _bind$2.end);
              let _tmp$4;
              if (_bind$4 === undefined) {
                _tmp$4 = _bind$2.end;
              } else {
                const _Some = _bind$4;
                _tmp$4 = _Some;
              }
              const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, _bind$2.end);
              _bind = { _0: true, _1: _x$3 };
              break;
            }
            default: {
              rest = _bind$2;
              break _L$2;
            }
          }
        } else {
          rest = _bind$2;
          break _L$2;
        }
        break _L;
      }
      _bind = { _0: false, _1: rest };
    }
    const _neg = _bind._0;
    const _rest = _bind._1;
    const _bind$2 = _M0FPC17strconv25check__and__consume__base(_rest, base);
    let _bind$3;
    if (_bind$2.$tag === 1) {
      const _ok = _bind$2;
      _bind$3 = _ok._0;
    } else {
      return _bind$2;
    }
    const _num_base = _bind$3._0;
    const _rest$2 = _bind$3._1;
    const _allow_underscore = _bind$3._2;
    const overflow_threshold = _M0FPC17strconv19overflow__threshold(_num_base, _neg);
    let has_digit;
    if (_M0MPC16string6String24char__length__ge_2einner(_rest$2.str, 1, _rest$2.start, _rest$2.end)) {
      const _x = _M0MPC16string6String16unsafe__char__at(_rest$2.str, _M0MPC16string6String29offset__of__nth__char_2einner(_rest$2.str, 0, _rest$2.start, _rest$2.end));
      if (_x >= 48 && _x <= 57) {
        has_digit = true;
      } else {
        if (_x >= 97 && _x <= 122) {
          has_digit = true;
        } else {
          if (_x >= 65 && _x <= 90) {
            has_digit = true;
          } else {
            if (_M0MPC16string6String24char__length__ge_2einner(_rest$2.str, 2, _rest$2.start, _rest$2.end)) {
              if (_x === 95) {
                const _x$2 = _M0MPC16string6String16unsafe__char__at(_rest$2.str, _M0MPC16string6String29offset__of__nth__char_2einner(_rest$2.str, 1, _rest$2.start, _rest$2.end));
                has_digit = _x$2 >= 48 && _x$2 <= 57 ? true : _x$2 >= 97 && _x$2 <= 122 ? true : _x$2 >= 65 && _x$2 <= 90;
              } else {
                has_digit = false;
              }
            } else {
              has_digit = false;
            }
          }
        }
      }
    } else {
      has_digit = false;
    }
    if (has_digit) {
      let _tmp;
      let _tmp$2 = _rest$2;
      let _tmp$3 = $0L;
      let _tmp$4 = _allow_underscore;
      while (true) {
        const _param_0 = _tmp$2;
        const _param_1 = _tmp$3;
        const _param_2 = _tmp$4;
        let acc;
        let rest$2;
        let c;
        _L$2: {
          if (_M0MPC16string6String24char__length__eq_2einner(_param_0.str, 1, _param_0.start, _param_0.end)) {
            const _x = _M0MPC16string6String16unsafe__char__at(_param_0.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 0, _param_0.start, _param_0.end));
            if (_x === 95) {
              const _bind$4 = _M0FPC17strconv11syntax__errGlE();
              if (_bind$4.$tag === 1) {
                const _ok = _bind$4;
                _tmp = _ok._0;
                break;
              } else {
                return _bind$4;
              }
            } else {
              const _tmp$5 = _param_0.str;
              const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 1, _param_0.start, _param_0.end);
              let _tmp$6;
              if (_bind$4 === undefined) {
                _tmp$6 = _param_0.end;
              } else {
                const _Some = _bind$4;
                _tmp$6 = _Some;
              }
              const _x$2 = new _M0TPC16string10StringView(_tmp$5, _tmp$6, _param_0.end);
              acc = _param_1;
              rest$2 = _x$2;
              c = _x;
              break _L$2;
            }
          } else {
            if (_M0MPC16string6String24char__length__ge_2einner(_param_0.str, 1, _param_0.start, _param_0.end)) {
              const _x = _M0MPC16string6String16unsafe__char__at(_param_0.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 0, _param_0.start, _param_0.end));
              if (_x === 95) {
                if (_param_2 === false) {
                  const _bind$4 = _M0FPC17strconv11syntax__errGlE();
                  if (_bind$4.$tag === 1) {
                    const _ok = _bind$4;
                    _tmp = _ok._0;
                    break;
                  } else {
                    return _bind$4;
                  }
                } else {
                  const _tmp$5 = _param_0.str;
                  const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 1, _param_0.start, _param_0.end);
                  let _tmp$6;
                  if (_bind$4 === undefined) {
                    _tmp$6 = _param_0.end;
                  } else {
                    const _Some = _bind$4;
                    _tmp$6 = _Some;
                  }
                  const _x$2 = new _M0TPC16string10StringView(_tmp$5, _tmp$6, _param_0.end);
                  _tmp$2 = _x$2;
                  _tmp$4 = false;
                  continue;
                }
              } else {
                const _tmp$5 = _param_0.str;
                const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 1, _param_0.start, _param_0.end);
                let _tmp$6;
                if (_bind$4 === undefined) {
                  _tmp$6 = _param_0.end;
                } else {
                  const _Some = _bind$4;
                  _tmp$6 = _Some;
                }
                const _x$2 = new _M0TPC16string10StringView(_tmp$5, _tmp$6, _param_0.end);
                acc = _param_1;
                rest$2 = _x$2;
                c = _x;
                break _L$2;
              }
            } else {
              _tmp = _param_1;
              break;
            }
          }
        }
        const c$2 = c;
        let d;
        if (c$2 >= 48 && c$2 <= 57) {
          d = c$2 - 48 | 0;
        } else {
          if (c$2 >= 97 && c$2 <= 122) {
            d = c$2 + -87 | 0;
          } else {
            if (c$2 >= 65 && c$2 <= 90) {
              d = c$2 + -55 | 0;
            } else {
              const _bind$4 = _M0FPC17strconv11syntax__errGiE();
              if (_bind$4.$tag === 1) {
                const _ok = _bind$4;
                d = _ok._0;
              } else {
                return _bind$4;
              }
            }
          }
        }
        if (d < _num_base) {
          if (_neg) {
            if (_M0IP016_24default__implPB7Compare6op__geGlE(acc, overflow_threshold)) {
              const next_acc = _M0IPC15int645Int64PB3Sub3sub(_M0IPC15int645Int64PB3Mul3mul(acc, _M0MPC13int3Int9to__int64(_num_base)), _M0MPC13int3Int9to__int64(d));
              if (_M0IP016_24default__implPB7Compare6op__leGlE(next_acc, acc)) {
                _tmp$2 = rest$2;
                _tmp$3 = next_acc;
                _tmp$4 = true;
                continue;
              } else {
                const _bind$4 = _M0FPC17strconv10range__errGlE();
                if (_bind$4.$tag === 1) {
                  const _ok = _bind$4;
                  _tmp = _ok._0;
                  break;
                } else {
                  return _bind$4;
                }
              }
            } else {
              const _bind$4 = _M0FPC17strconv10range__errGlE();
              if (_bind$4.$tag === 1) {
                const _ok = _bind$4;
                _tmp = _ok._0;
                break;
              } else {
                return _bind$4;
              }
            }
          } else {
            if (_M0IP016_24default__implPB7Compare6op__ltGlE(acc, overflow_threshold)) {
              const next_acc = _M0IPC15int645Int64PB3Add3add(_M0IPC15int645Int64PB3Mul3mul(acc, _M0MPC13int3Int9to__int64(_num_base)), _M0MPC13int3Int9to__int64(d));
              if (_M0IP016_24default__implPB7Compare6op__geGlE(next_acc, acc)) {
                _tmp$2 = rest$2;
                _tmp$3 = next_acc;
                _tmp$4 = true;
                continue;
              } else {
                const _bind$4 = _M0FPC17strconv10range__errGlE();
                if (_bind$4.$tag === 1) {
                  const _ok = _bind$4;
                  _tmp = _ok._0;
                  break;
                } else {
                  return _bind$4;
                }
              }
            } else {
              const _bind$4 = _M0FPC17strconv10range__errGlE();
              if (_bind$4.$tag === 1) {
                const _ok = _bind$4;
                _tmp = _ok._0;
                break;
              } else {
                return _bind$4;
              }
            }
          }
        } else {
          const _bind$4 = _M0FPC17strconv11syntax__errGlE();
          if (_bind$4.$tag === 1) {
            const _ok = _bind$4;
            _tmp = _ok._0;
            break;
          } else {
            return _bind$4;
          }
        }
      }
      return new _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE2Ok(_tmp);
    } else {
      return _M0FPC17strconv11syntax__errGlE();
    }
  } else {
    return _M0FPC17strconv11syntax__errGlE();
  }
}
function _M0FPC17strconv17check__underscore(str) {
  let rest;
  if (_M0MPC16string6String24char__length__ge_2einner(str.str, 1, str.start, str.end)) {
    const _x = _M0MPC16string6String16unsafe__char__at(str.str, _M0MPC16string6String29offset__of__nth__char_2einner(str.str, 0, str.start, str.end));
    switch (_x) {
      case 43: {
        const _tmp = str.str;
        const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(str.str, 1, str.start, str.end);
        let _tmp$2;
        if (_bind === undefined) {
          _tmp$2 = str.end;
        } else {
          const _Some = _bind;
          _tmp$2 = _Some;
        }
        const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, str.end);
        rest = _x$2;
        break;
      }
      case 45: {
        const _tmp$3 = str.str;
        const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(str.str, 1, str.start, str.end);
        let _tmp$4;
        if (_bind$2 === undefined) {
          _tmp$4 = str.end;
        } else {
          const _Some = _bind$2;
          _tmp$4 = _Some;
        }
        const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, str.end);
        rest = _x$3;
        break;
      }
      default: {
        rest = str;
      }
    }
  } else {
    rest = str;
  }
  const _data = _M0MPC16string10StringView4data(rest);
  const _start = _M0MPC16string10StringView13start__offset(rest);
  const _end = _start + _M0MPC16string10StringView6length(rest) | 0;
  let _cursor = _start;
  let accept_state = -1;
  let match_end = -1;
  let _bind;
  _L: {
    if ((_cursor + 1 | 0) < _end) {
      if (_M0MPC16string6String20unsafe__charcode__at(_data, _cursor) === 48) {
        _cursor = _cursor + 1 | 0;
        _L$2: {
          _L$3: {
            _L$4: {
              const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
              _cursor = _cursor + 1 | 0;
              if (next_char < 89) {
                if (next_char < 79) {
                  if (next_char === 66) {
                    break _L$2;
                  } else {
                    break _L;
                  }
                } else {
                  if (next_char > 79) {
                    if (next_char < 88) {
                      break _L;
                    } else {
                      break _L$4;
                    }
                  } else {
                    break _L$3;
                  }
                }
              } else {
                if (next_char > 97) {
                  if (next_char < 112) {
                    if (next_char < 99) {
                      break _L$2;
                    } else {
                      if (next_char > 110) {
                        break _L$3;
                      } else {
                        break _L;
                      }
                    }
                  } else {
                    if (next_char > 119) {
                      if (next_char < 121) {
                        break _L$4;
                      } else {
                        break _L;
                      }
                    } else {
                      break _L;
                    }
                  }
                } else {
                  break _L;
                }
              }
            }
            accept_state = 2;
            match_end = _cursor;
            break _L;
          }
          accept_state = 1;
          match_end = _cursor;
          break _L;
        }
        accept_state = 0;
        match_end = _cursor;
        break _L;
      } else {
        break _L;
      }
    } else {
      break _L;
    }
  }
  switch (accept_state) {
    case 2: {
      const rest$2 = _M0MPC16string6String4view(_data, match_end, _end);
      _bind = { _0: rest$2, _1: true, _2: true };
      break;
    }
    case 1: {
      const rest$3 = _M0MPC16string6String4view(_data, match_end, _end);
      _bind = { _0: rest$3, _1: true, _2: false };
      break;
    }
    case 0: {
      const rest$4 = _M0MPC16string6String4view(_data, match_end, _end);
      _bind = { _0: rest$4, _1: true, _2: false };
      break;
    }
    default: {
      _bind = { _0: rest, _1: false, _2: false };
    }
  }
  const _rest = _bind._0;
  const _allow_underscore = _bind._1;
  const _hex = _bind._2;
  let _tmp = _rest;
  let _tmp$2 = _allow_underscore;
  let _tmp$3 = false;
  while (true) {
    const _param_0 = _tmp;
    const _param_1 = _tmp$2;
    const _param_2 = _tmp$3;
    let rest$5;
    let c;
    let follow_underscore;
    _L$2: {
      if (_M0MPC16string6String24char__length__eq_2einner(_param_0.str, 0, _param_0.start, _param_0.end)) {
        return true;
      } else {
        if (_M0MPC16string6String24char__length__eq_2einner(_param_0.str, 1, _param_0.start, _param_0.end)) {
          const _x = _M0MPC16string6String16unsafe__char__at(_param_0.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 0, _param_0.start, _param_0.end));
          if (_x === 95) {
            return false;
          } else {
            const _tmp$4 = _param_0.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 1, _param_0.start, _param_0.end);
            let _tmp$5;
            if (_bind$2 === undefined) {
              _tmp$5 = _param_0.end;
            } else {
              const _Some = _bind$2;
              _tmp$5 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, _param_0.end);
            rest$5 = _x$2;
            c = _x;
            follow_underscore = _param_2;
            break _L$2;
          }
        } else {
          const _x = _M0MPC16string6String16unsafe__char__at(_param_0.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 0, _param_0.start, _param_0.end));
          if (_x === 95) {
            if (_param_1 === false) {
              return false;
            } else {
              const _tmp$4 = _param_0.str;
              const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 1, _param_0.start, _param_0.end);
              let _tmp$5;
              if (_bind$2 === undefined) {
                _tmp$5 = _param_0.end;
              } else {
                const _Some = _bind$2;
                _tmp$5 = _Some;
              }
              const _x$2 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, _param_0.end);
              _tmp = _x$2;
              _tmp$2 = false;
              _tmp$3 = true;
              continue;
            }
          } else {
            const _tmp$4 = _param_0.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_0.str, 1, _param_0.start, _param_0.end);
            let _tmp$5;
            if (_bind$2 === undefined) {
              _tmp$5 = _param_0.end;
            } else {
              const _Some = _bind$2;
              _tmp$5 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, _param_0.end);
            rest$5 = _x$2;
            c = _x;
            follow_underscore = _param_2;
            break _L$2;
          }
        }
      }
    }
    if (c >= 48 && c <= 57 ? true : _hex && (c >= 97 && c <= 102 ? true : c >= 65 && c <= 70)) {
      _tmp = rest$5;
      _tmp$2 = true;
      _tmp$3 = false;
      continue;
    } else {
      if (follow_underscore) {
        return false;
      } else {
        _tmp = rest$5;
        _tmp$2 = false;
        _tmp$3 = false;
        continue;
      }
    }
  }
}
function _M0MPC17strconv7Decimal9new__priv() {
  return new _M0TPC17strconv7Decimal($makebytes(800, _M0IPC14byte4BytePB7Default7default()), 0, 0, false, false);
}
function _M0MPC17strconv7Decimal4trim(self) {
  while (true) {
    let _tmp;
    if (self.digits_num > 0) {
      const _tmp$2 = self.digits;
      const _tmp$3 = self.digits_num - 1 | 0;
      $bound_check(_tmp$2, _tmp$3);
      _tmp = _M0IPC14byte4BytePB2Eq5equal(_tmp$2[_tmp$3], 0);
    } else {
      _tmp = false;
    }
    if (_tmp) {
      self.digits_num = self.digits_num - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (self.digits_num === 0) {
    self.decimal_point = 0;
    return;
  } else {
    return;
  }
}
function _M0FPC17strconv26parse__decimal__from__view(str) {
  const d = _M0MPC17strconv7Decimal9new__priv();
  let has_dp = false;
  let has_digits = false;
  let rest;
  _L: {
    _L$2: {
      if (_M0MPC16string6String24char__length__ge_2einner(str.str, 1, str.start, str.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(str.str, _M0MPC16string6String29offset__of__nth__char_2einner(str.str, 0, str.start, str.end));
        switch (_x) {
          case 45: {
            const _tmp = str.str;
            const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(str.str, 1, str.start, str.end);
            let _tmp$2;
            if (_bind === undefined) {
              _tmp$2 = str.end;
            } else {
              const _Some = _bind;
              _tmp$2 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, str.end);
            d.negative = true;
            rest = _x$2;
            break;
          }
          case 43: {
            const _tmp$3 = str.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(str.str, 1, str.start, str.end);
            let _tmp$4;
            if (_bind$2 === undefined) {
              _tmp$4 = str.end;
            } else {
              const _Some = _bind$2;
              _tmp$4 = _Some;
            }
            rest = new _M0TPC16string10StringView(_tmp$3, _tmp$4, str.end);
            break;
          }
          default: {
            break _L$2;
          }
        }
      } else {
        break _L$2;
      }
      break _L;
    }
    rest = str;
  }
  let rest$2;
  let _tmp = rest;
  while (true) {
    const _param = _tmp;
    if (_M0MPC16string6String24char__length__ge_2einner(_param.str, 1, _param.start, _param.end)) {
      const _x = _M0MPC16string6String16unsafe__char__at(_param.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 0, _param.start, _param.end));
      if (_x === 95) {
        const _tmp$2 = _param.str;
        const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
        let _tmp$3;
        if (_bind === undefined) {
          _tmp$3 = _param.end;
        } else {
          const _Some = _bind;
          _tmp$3 = _Some;
        }
        const _x$2 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, _param.end);
        _tmp = _x$2;
        continue;
      } else {
        if (_x === 46) {
          const _tmp$2 = _param.str;
          const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
          let _tmp$3;
          if (_bind === undefined) {
            _tmp$3 = _param.end;
          } else {
            const _Some = _bind;
            _tmp$3 = _Some;
          }
          const _x$2 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, _param.end);
          if (!has_dp) {
            has_dp = true;
            d.decimal_point = d.digits_num;
            _tmp = _x$2;
            continue;
          } else {
            const _bind$2 = _M0FPC17strconv11syntax__errGlE();
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              rest$2 = _ok._0;
              break;
            } else {
              return _bind$2;
            }
          }
        } else {
          if (_x >= 48 && _x <= 57) {
            const _tmp$2 = _param.str;
            const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
            let _tmp$3;
            if (_bind === undefined) {
              _tmp$3 = _param.end;
            } else {
              const _Some = _bind;
              _tmp$3 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, _param.end);
            has_digits = true;
            if (_x === 48 && d.digits_num === 0) {
              d.decimal_point = d.decimal_point - 1 | 0;
              _tmp = _x$2;
              continue;
            }
            if (d.digits_num < d.digits.length) {
              const _tmp$4 = d.digits;
              const _tmp$5 = d.digits_num;
              $bound_check(_tmp$4, _tmp$5);
              _tmp$4[_tmp$5] = (_x - 48 | 0) & 255;
              d.digits_num = d.digits_num + 1 | 0;
            } else {
              if (_x !== 48) {
                d.truncated = true;
              }
            }
            _tmp = _x$2;
            continue;
          } else {
            rest$2 = _param;
            break;
          }
        }
      }
    } else {
      rest$2 = _param;
      break;
    }
  }
  if (has_digits) {
    if (!has_dp) {
      d.decimal_point = d.digits_num;
    }
    let rest$3;
    let rest$4;
    _L$2: {
      _L$3: {
        if (_M0MPC16string6String24char__length__ge_2einner(rest$2.str, 1, rest$2.start, rest$2.end)) {
          const _x = _M0MPC16string6String16unsafe__char__at(rest$2.str, _M0MPC16string6String29offset__of__nth__char_2einner(rest$2.str, 0, rest$2.start, rest$2.end));
          switch (_x) {
            case 101: {
              const _tmp$2 = rest$2.str;
              const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(rest$2.str, 1, rest$2.start, rest$2.end);
              let _tmp$3;
              if (_bind === undefined) {
                _tmp$3 = rest$2.end;
              } else {
                const _Some = _bind;
                _tmp$3 = _Some;
              }
              const _x$2 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, rest$2.end);
              rest$4 = _x$2;
              break _L$3;
            }
            case 69: {
              const _tmp$4 = rest$2.str;
              const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(rest$2.str, 1, rest$2.start, rest$2.end);
              let _tmp$5;
              if (_bind$2 === undefined) {
                _tmp$5 = rest$2.end;
              } else {
                const _Some = _bind$2;
                _tmp$5 = _Some;
              }
              const _x$3 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, rest$2.end);
              rest$4 = _x$3;
              break _L$3;
            }
            default: {
              rest$3 = rest$2;
            }
          }
        } else {
          rest$3 = rest$2;
        }
        break _L$2;
      }
      let exp_sign = 1;
      let rest$5;
      if (_M0MPC16string6String24char__length__ge_2einner(rest$4.str, 1, rest$4.start, rest$4.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(rest$4.str, _M0MPC16string6String29offset__of__nth__char_2einner(rest$4.str, 0, rest$4.start, rest$4.end));
        switch (_x) {
          case 43: {
            const _tmp$2 = rest$4.str;
            const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(rest$4.str, 1, rest$4.start, rest$4.end);
            let _tmp$3;
            if (_bind === undefined) {
              _tmp$3 = rest$4.end;
            } else {
              const _Some = _bind;
              _tmp$3 = _Some;
            }
            rest$5 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, rest$4.end);
            break;
          }
          case 45: {
            const _tmp$4 = rest$4.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(rest$4.str, 1, rest$4.start, rest$4.end);
            let _tmp$5;
            if (_bind$2 === undefined) {
              _tmp$5 = rest$4.end;
            } else {
              const _Some = _bind$2;
              _tmp$5 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp$4, _tmp$5, rest$4.end);
            exp_sign = -1;
            rest$5 = _x$2;
            break;
          }
          default: {
            rest$5 = rest$4;
          }
        }
      } else {
        rest$5 = rest$4;
      }
      _L$4: {
        _L$5: {
          if (_M0MPC16string6String24char__length__ge_2einner(rest$5.str, 1, rest$5.start, rest$5.end)) {
            const _x = _M0MPC16string6String16unsafe__char__at(rest$5.str, _M0MPC16string6String29offset__of__nth__char_2einner(rest$5.str, 0, rest$5.start, rest$5.end));
            if (_x >= 48 && _x <= 57) {
              let exp = 0;
              let rest$6;
              let _tmp$2 = rest$5;
              while (true) {
                const _param = _tmp$2;
                if (_M0MPC16string6String24char__length__ge_2einner(_param.str, 1, _param.start, _param.end)) {
                  const _x$2 = _M0MPC16string6String16unsafe__char__at(_param.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 0, _param.start, _param.end));
                  if (_x$2 === 95) {
                    const _tmp$3 = _param.str;
                    const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
                    let _tmp$4;
                    if (_bind === undefined) {
                      _tmp$4 = _param.end;
                    } else {
                      const _Some = _bind;
                      _tmp$4 = _Some;
                    }
                    const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, _param.end);
                    _tmp$2 = _x$3;
                    continue;
                  } else {
                    if (_x$2 >= 48 && _x$2 <= 57) {
                      const _tmp$3 = _param.str;
                      const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
                      let _tmp$4;
                      if (_bind === undefined) {
                        _tmp$4 = _param.end;
                      } else {
                        const _Some = _bind;
                        _tmp$4 = _Some;
                      }
                      const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, _param.end);
                      exp = (Math.imul(exp, 10) | 0) + (_x$2 - 48 | 0) | 0;
                      _tmp$2 = _x$3;
                      continue;
                    } else {
                      rest$6 = _param;
                      break;
                    }
                  }
                } else {
                  rest$6 = _param;
                  break;
                }
              }
              d.decimal_point = d.decimal_point + (Math.imul(exp_sign, exp) | 0) | 0;
              rest$3 = rest$6;
            } else {
              break _L$5;
            }
          } else {
            break _L$5;
          }
          break _L$4;
        }
        const _bind = _M0FPC17strconv11syntax__errGlE();
        if (_bind.$tag === 1) {
          const _ok = _bind;
          rest$3 = _ok._0;
        } else {
          return _bind;
        }
      }
    }
    if (_M0MPC16string6String24char__length__eq_2einner(rest$3.str, 0, rest$3.start, rest$3.end)) {
      _M0MPC17strconv7Decimal4trim(d);
      return new _M0DTPC16result6ResultGRPC17strconv7DecimalRPC17strconv12StrConvErrorE2Ok(d);
    } else {
      return _M0FPC17strconv11syntax__errGlE();
    }
  } else {
    return _M0FPC17strconv11syntax__errGlE();
  }
}
function _M0FPC17strconv20parse__decimal__priv(str) {
  return _M0FPC17strconv26parse__decimal__from__view(str);
}
function _M0FPC17strconv15parse__inf__nan(rest) {
  let _bind;
  let rest$2;
  _L: {
    _L$2: {
      if (_M0MPC16string6String24char__length__ge_2einner(rest.str, 1, rest.start, rest.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(rest.str, _M0MPC16string6String29offset__of__nth__char_2einner(rest.str, 0, rest.start, rest.end));
        switch (_x) {
          case 45: {
            const _tmp = rest.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(rest.str, 1, rest.start, rest.end);
            let _tmp$2;
            if (_bind$2 === undefined) {
              _tmp$2 = rest.end;
            } else {
              const _Some = _bind$2;
              _tmp$2 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, rest.end);
            _bind = { _0: false, _1: _x$2 };
            break;
          }
          case 43: {
            const _tmp$3 = rest.str;
            const _bind$3 = _M0MPC16string6String29offset__of__nth__char_2einner(rest.str, 1, rest.start, rest.end);
            let _tmp$4;
            if (_bind$3 === undefined) {
              _tmp$4 = rest.end;
            } else {
              const _Some = _bind$3;
              _tmp$4 = _Some;
            }
            const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, rest.end);
            rest$2 = _x$3;
            break _L$2;
          }
          default: {
            rest$2 = rest;
            break _L$2;
          }
        }
      } else {
        rest$2 = rest;
        break _L$2;
      }
      break _L;
    }
    _bind = { _0: true, _1: rest$2 };
  }
  const _pos = _bind._0;
  const _rest = _bind._1;
  const _data = _M0MPC16string10StringView4data(_rest);
  const _start = _M0MPC16string10StringView13start__offset(_rest);
  const _end = _start + _M0MPC16string10StringView6length(_rest) | 0;
  let _cursor = _start;
  let accept_state = -1;
  let match_end = -1;
  _L$2: {
    _L$3: {
      if ((_cursor + 2 | 0) < _end) {
        _L$4: {
          _L$5: {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char < 79) {
              if (next_char < 74) {
                if (next_char < 73) {
                  break _L$2;
                } else {
                  break _L$4;
                }
              } else {
                if (next_char > 77) {
                  break _L$5;
                } else {
                  break _L$2;
                }
              }
            } else {
              if (next_char > 104) {
                if (next_char < 110) {
                  if (next_char < 106) {
                    break _L$4;
                  } else {
                    break _L$2;
                  }
                } else {
                  if (next_char > 110) {
                    break _L$2;
                  } else {
                    break _L$5;
                  }
                }
              } else {
                break _L$2;
              }
            }
          }
          _L$6: {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char < 66) {
              if (next_char < 65) {
                break _L$2;
              } else {
                break _L$6;
              }
            } else {
              if (next_char > 96) {
                if (next_char < 98) {
                  break _L$6;
                } else {
                  break _L$2;
                }
              } else {
                break _L$2;
              }
            }
          }
          _L$7: {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char < 79) {
              if (next_char < 78) {
                break _L$2;
              } else {
                break _L$7;
              }
            } else {
              if (next_char > 109) {
                if (next_char < 111) {
                  break _L$7;
                } else {
                  break _L$2;
                }
              } else {
                break _L$2;
              }
            }
          }
          if (_cursor < _end) {
            break _L$2;
          } else {
            accept_state = 0;
            match_end = _cursor;
            break _L$2;
          }
        }
        _L$5: {
          const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
          _cursor = _cursor + 1 | 0;
          if (next_char < 79) {
            if (next_char < 78) {
              break _L$2;
            } else {
              break _L$5;
            }
          } else {
            if (next_char > 109) {
              if (next_char < 111) {
                break _L$5;
              } else {
                break _L$2;
              }
            } else {
              break _L$2;
            }
          }
        }
        _L$6: {
          const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
          _cursor = _cursor + 1 | 0;
          if (next_char < 71) {
            if (next_char < 70) {
              break _L$2;
            } else {
              break _L$6;
            }
          } else {
            if (next_char > 101) {
              if (next_char < 103) {
                break _L$6;
              } else {
                break _L$2;
              }
            } else {
              break _L$2;
            }
          }
        }
        if (_cursor < _end) {
          _L$7: {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char < 74) {
              if (next_char < 73) {
                break _L$2;
              } else {
                break _L$7;
              }
            } else {
              if (next_char > 104) {
                if (next_char < 106) {
                  break _L$7;
                } else {
                  break _L$2;
                }
              } else {
                break _L$2;
              }
            }
          }
          if ((_cursor + 3 | 0) < _end) {
            _L$8: {
              const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
              _cursor = _cursor + 1 | 0;
              if (next_char < 79) {
                if (next_char < 78) {
                  break _L$2;
                } else {
                  break _L$8;
                }
              } else {
                if (next_char > 109) {
                  if (next_char < 111) {
                    break _L$8;
                  } else {
                    break _L$2;
                  }
                } else {
                  break _L$2;
                }
              }
            }
            _L$9: {
              const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
              _cursor = _cursor + 1 | 0;
              if (next_char < 74) {
                if (next_char < 73) {
                  break _L$2;
                } else {
                  break _L$9;
                }
              } else {
                if (next_char > 104) {
                  if (next_char < 106) {
                    break _L$9;
                  } else {
                    break _L$2;
                  }
                } else {
                  break _L$2;
                }
              }
            }
            _L$10: {
              const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
              _cursor = _cursor + 1 | 0;
              if (next_char < 85) {
                if (next_char < 84) {
                  break _L$2;
                } else {
                  break _L$10;
                }
              } else {
                if (next_char > 115) {
                  if (next_char < 117) {
                    break _L$10;
                  } else {
                    break _L$2;
                  }
                } else {
                  break _L$2;
                }
              }
            }
            _L$11: {
              const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
              _cursor = _cursor + 1 | 0;
              if (next_char < 90) {
                if (next_char < 89) {
                  break _L$2;
                } else {
                  break _L$11;
                }
              } else {
                if (next_char > 120) {
                  if (next_char < 122) {
                    break _L$11;
                  } else {
                    break _L$2;
                  }
                } else {
                  break _L$2;
                }
              }
            }
            if (_cursor < _end) {
              break _L$2;
            } else {
              break _L$3;
            }
          } else {
            break _L$2;
          }
        } else {
          break _L$3;
        }
      } else {
        break _L$2;
      }
    }
    accept_state = 1;
    match_end = _cursor;
    break _L$2;
  }
  switch (accept_state) {
    case 0: {
      return new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_M0FPC16double14not__a__number);
    }
    case 1: {
      return _pos ? new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_M0FPC16double8infinity) : new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_M0FPC16double13neg__infinity);
    }
    default: {
      return _M0FPC17strconv11syntax__errGdE();
    }
  }
}
function _M0EPC16string10StringViewPC17strconv12fold__digitsGmE(self, init, f) {
  let ret = init;
  let len = 0;
  let str = self;
  while (true) {
    const _bind = str;
    if (_M0MPC16string6String24char__length__ge_2einner(_bind.str, 1, _bind.start, _bind.end)) {
      const _ch = _M0MPC16string6String16unsafe__char__at(_bind.str, _M0MPC16string6String29offset__of__nth__char_2einner(_bind.str, 0, _bind.start, _bind.end));
      const _tmp = _bind.str;
      const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind.str, 1, _bind.start, _bind.end);
      let _tmp$2;
      if (_bind$2 === undefined) {
        _tmp$2 = _bind.end;
      } else {
        const _Some = _bind$2;
        _tmp$2 = _Some;
      }
      const _x = new _M0TPC16string10StringView(_tmp, _tmp$2, _bind.end);
      if (_ch >= 48 && _ch <= 57) {
        len = len + 1 | 0;
        ret = f(_ch - 48 | 0, ret);
      } else {
        if (_ch !== 95) {
          break;
        }
      }
      str = _x;
      continue;
    } else {
      break;
    }
  }
  return { _0: str, _1: ret, _2: len };
}
function _M0FPC17strconv13parse__digits(s, x) {
  return _M0EPC16string10StringViewPC17strconv12fold__digitsGmE(s, x, (digit, acc) => _M0IPC16uint646UInt64PB3Add3add(_M0IPC16uint646UInt64PB3Mul3mul(acc, $10L), _M0MPC16uint646UInt6412extend__uint(digit)));
}
function _M0FPC17strconv17parse__scientific(s) {
  let s$2 = s;
  let neg_exp = false;
  let rest;
  let ch;
  _L: {
    _L$2: {
      const _bind = s$2;
      if (_M0MPC16string6String24char__length__ge_2einner(_bind.str, 1, _bind.start, _bind.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(_bind.str, _M0MPC16string6String29offset__of__nth__char_2einner(_bind.str, 0, _bind.start, _bind.end));
        switch (_x) {
          case 43: {
            const _tmp = _bind.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind.str, 1, _bind.start, _bind.end);
            let _tmp$2;
            if (_bind$2 === undefined) {
              _tmp$2 = _bind.end;
            } else {
              const _Some = _bind$2;
              _tmp$2 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, _bind.end);
            rest = _x$2;
            ch = _x;
            break _L$2;
          }
          case 45: {
            const _tmp$3 = _bind.str;
            const _bind$3 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind.str, 1, _bind.start, _bind.end);
            let _tmp$4;
            if (_bind$3 === undefined) {
              _tmp$4 = _bind.end;
            } else {
              const _Some = _bind$3;
              _tmp$4 = _Some;
            }
            const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, _bind.end);
            rest = _x$3;
            ch = _x;
            break _L$2;
          }
        }
      }
      break _L;
    }
    neg_exp = ch === 45;
    s$2 = rest;
  }
  _L$2: {
    const _bind = s$2;
    if (_M0MPC16string6String24char__length__ge_2einner(_bind.str, 1, _bind.start, _bind.end)) {
      const _x = _M0MPC16string6String16unsafe__char__at(_bind.str, _M0MPC16string6String29offset__of__nth__char_2einner(_bind.str, 0, _bind.start, _bind.end));
      if (_x >= 48 && _x <= 57) {
        const _bind$2 = _M0EPC16string10StringViewPC17strconv12fold__digitsGmE(s$2, _M0FPC17strconv17parse__scientificN8exp__numS241, (digit, exp_num) => _M0IP016_24default__implPB7Compare6op__ltGlE(exp_num, $65536L) ? _M0IPC15int645Int64PB3Add3add(_M0IPC15int645Int64PB3Mul3mul($10L, exp_num), _M0MPC13int3Int9to__int64(digit)) : exp_num);
        const _s = _bind$2._0;
        const _exp_num = _bind$2._1;
        return neg_exp ? { _0: _s, _1: _M0IPC15int645Int64PB3Neg3neg(_exp_num) } : { _0: _s, _1: _exp_num };
      } else {
        break _L$2;
      }
    } else {
      break _L$2;
    }
  }
  return undefined;
}
function _M0FPC17strconv20try__parse__19digits(s, x) {
  let x$2 = x;
  let len = 0;
  let _tmp = s;
  while (true) {
    const _param = _tmp;
    let s$2;
    _L: {
      if (_M0MPC16string6String24char__length__ge_2einner(_param.str, 1, _param.start, _param.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(_param.str, _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 0, _param.start, _param.end));
        if (_x >= 48 && _x <= 57) {
          const _tmp$2 = _param.str;
          const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
          let _tmp$3;
          if (_bind === undefined) {
            _tmp$3 = _param.end;
          } else {
            const _Some = _bind;
            _tmp$3 = _Some;
          }
          const _x$2 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, _param.end);
          if (_M0IP016_24default__implPB7Compare6op__ltGmE(x$2, _M0FPC17strconv17min__19digit__int)) {
            len = len + 1 | 0;
            x$2 = _M0IPC16uint646UInt64PB3Add3add(_M0IPC16uint646UInt64PB3Mul3mul(x$2, $10L), _M0MPC16uint646UInt6412extend__uint(_x - 48 | 0));
            _tmp = _x$2;
            continue;
          } else {
            s$2 = _param;
            break _L;
          }
        } else {
          if (_x === 95) {
            const _tmp$2 = _param.str;
            const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(_param.str, 1, _param.start, _param.end);
            let _tmp$3;
            if (_bind === undefined) {
              _tmp$3 = _param.end;
            } else {
              const _Some = _bind;
              _tmp$3 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp$2, _tmp$3, _param.end);
            _tmp = _x$2;
            continue;
          } else {
            s$2 = _param;
            break _L;
          }
        }
      } else {
        s$2 = _param;
        break _L;
      }
    }
    return { _0: s$2, _1: x$2, _2: len };
  }
}
function _M0FPC17strconv13parse__number(s) {
  let _bind;
  let rest;
  _L: {
    _L$2: {
      if (_M0MPC16string6String24char__length__ge_2einner(s.str, 1, s.start, s.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(s.str, _M0MPC16string6String29offset__of__nth__char_2einner(s.str, 0, s.start, s.end));
        switch (_x) {
          case 45: {
            const _tmp = s.str;
            const _bind$2 = _M0MPC16string6String29offset__of__nth__char_2einner(s.str, 1, s.start, s.end);
            let _tmp$2;
            if (_bind$2 === undefined) {
              _tmp$2 = s.end;
            } else {
              const _Some = _bind$2;
              _tmp$2 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, s.end);
            _bind = { _0: _x$2, _1: true };
            break;
          }
          case 43: {
            const _tmp$3 = s.str;
            const _bind$3 = _M0MPC16string6String29offset__of__nth__char_2einner(s.str, 1, s.start, s.end);
            let _tmp$4;
            if (_bind$3 === undefined) {
              _tmp$4 = s.end;
            } else {
              const _Some = _bind$3;
              _tmp$4 = _Some;
            }
            const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, s.end);
            rest = _x$3;
            break _L$2;
          }
          default: {
            rest = s;
            break _L$2;
          }
        }
      } else {
        rest = s;
        break _L$2;
      }
      break _L;
    }
    _bind = { _0: rest, _1: false };
  }
  const _s = _bind._0;
  const _negative = _bind._1;
  if (_M0MPC16string10StringView9is__empty(_s)) {
    return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(undefined);
  }
  const _bind$2 = _M0FPC17strconv13parse__digits(_s, $0L);
  const _s$2 = _bind$2._0;
  const _mantissa = _bind$2._1;
  const _consumed = _bind$2._2;
  let mantissa = _mantissa;
  let s$2 = _s$2;
  let n_digits = _consumed;
  let n_after_dot = 0;
  let exponent = $0L;
  const _bind$3 = s$2;
  if (_M0MPC16string6String24char__length__ge_2einner(_bind$3.str, 1, _bind$3.start, _bind$3.end)) {
    const _x = _M0MPC16string6String16unsafe__char__at(_bind$3.str, _M0MPC16string6String29offset__of__nth__char_2einner(_bind$3.str, 0, _bind$3.start, _bind$3.end));
    if (_x === 46) {
      const _tmp = _bind$3.str;
      const _bind$4 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind$3.str, 1, _bind$3.start, _bind$3.end);
      let _tmp$2;
      if (_bind$4 === undefined) {
        _tmp$2 = _bind$3.end;
      } else {
        const _Some = _bind$4;
        _tmp$2 = _Some;
      }
      const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, _bind$3.end);
      s$2 = _x$2;
      const _bind$5 = _M0FPC17strconv13parse__digits(s$2, mantissa);
      const _new_s = _bind$5._0;
      const _new_mantissa = _bind$5._1;
      const _consumed_digit = _bind$5._2;
      s$2 = _new_s;
      mantissa = _new_mantissa;
      n_after_dot = _consumed_digit;
      exponent = _M0IPC15int645Int64PB3Neg3neg(_M0MPC13int3Int9to__int64(n_after_dot));
    }
  }
  n_digits = n_digits + n_after_dot | 0;
  if (n_digits === 0) {
    return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(undefined);
  }
  let rest$2;
  _L$2: {
    _L$3: {
      const _bind$4 = s$2;
      if (_M0MPC16string6String24char__length__ge_2einner(_bind$4.str, 1, _bind$4.start, _bind$4.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(_bind$4.str, _M0MPC16string6String29offset__of__nth__char_2einner(_bind$4.str, 0, _bind$4.start, _bind$4.end));
        switch (_x) {
          case 101: {
            const _tmp = _bind$4.str;
            const _bind$5 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind$4.str, 1, _bind$4.start, _bind$4.end);
            let _tmp$2;
            if (_bind$5 === undefined) {
              _tmp$2 = _bind$4.end;
            } else {
              const _Some = _bind$5;
              _tmp$2 = _Some;
            }
            const _x$2 = new _M0TPC16string10StringView(_tmp, _tmp$2, _bind$4.end);
            rest$2 = _x$2;
            break _L$3;
          }
          case 69: {
            const _tmp$3 = _bind$4.str;
            const _bind$6 = _M0MPC16string6String29offset__of__nth__char_2einner(_bind$4.str, 1, _bind$4.start, _bind$4.end);
            let _tmp$4;
            if (_bind$6 === undefined) {
              _tmp$4 = _bind$4.end;
            } else {
              const _Some = _bind$6;
              _tmp$4 = _Some;
            }
            const _x$3 = new _M0TPC16string10StringView(_tmp$3, _tmp$4, _bind$4.end);
            rest$2 = _x$3;
            break _L$3;
          }
        }
      }
      break _L$2;
    }
    const _bind$4 = _M0FPC17strconv17parse__scientific(rest$2);
    let _bind$5;
    if (_bind$4 === undefined) {
      return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(undefined);
    } else {
      const _Some = _bind$4;
      _bind$5 = _Some;
    }
    const _new_s = _bind$5._0;
    const _exp_number = _bind$5._1;
    s$2 = _new_s;
    exponent = _M0IPC15int645Int64PB3Add3add(exponent, _exp_number);
  }
  const _bind$4 = s$2;
  if (_M0MPC16string6String24char__length__eq_2einner(_bind$4.str, 0, _bind$4.start, _bind$4.end)) {
    if (n_digits <= 19) {
      return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(new _M0TPC17strconv6Number(exponent, mantissa, _negative, false));
    }
    n_digits = n_digits - 19 | 0;
    let many_digits = false;
    let _tmp = s.str;
    let _tmp$2 = s.start;
    let _tmp$3 = s.end;
    _L$3: while (true) {
      const _param_str = _tmp;
      const _param_start = _tmp$2;
      const _param_end = _tmp$3;
      let rest$3;
      let ch;
      _L$4: {
        if (_M0MPC16string6String24char__length__ge_2einner(_param_str, 1, _param_start, _param_end)) {
          const _x = _M0MPC16string6String16unsafe__char__at(_param_str, _M0MPC16string6String29offset__of__nth__char_2einner(_param_str, 0, _param_start, _param_end));
          switch (_x) {
            case 48: {
              const _bind$5 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_str, 1, _param_start, _param_end);
              let _tmp$4;
              if (_bind$5 === undefined) {
                _tmp$4 = _param_end;
              } else {
                const _Some = _bind$5;
                _tmp$4 = _Some;
              }
              const _x$2 = new _M0TPC16string10StringView(_param_str, _tmp$4, _param_end);
              rest$3 = _x$2;
              ch = _x;
              break _L$4;
            }
            case 46: {
              const _bind$6 = _M0MPC16string6String29offset__of__nth__char_2einner(_param_str, 1, _param_start, _param_end);
              let _tmp$5;
              if (_bind$6 === undefined) {
                _tmp$5 = _param_end;
              } else {
                const _Some = _bind$6;
                _tmp$5 = _Some;
              }
              const _x$3 = new _M0TPC16string10StringView(_param_str, _tmp$5, _param_end);
              rest$3 = _x$3;
              ch = _x;
              break _L$4;
            }
            default: {
              break _L$3;
            }
          }
        } else {
          break;
        }
      }
      const _tmp$4 = n_digits;
      if (2 === 0) {
        $panic();
      }
      n_digits = _tmp$4 - ((ch - 46 | 0) / 2 | 0) | 0;
      _tmp = rest$3.str;
      _tmp$2 = rest$3.start;
      _tmp$3 = rest$3.end;
      continue;
    }
    let mantissa$2 = mantissa;
    if (n_digits > 0) {
      many_digits = true;
      mantissa$2 = $0L;
      const _bind$5 = _M0FPC17strconv20try__parse__19digits(s, mantissa$2);
      const _s$3 = _bind$5._0;
      const _new_mantissa = _bind$5._1;
      const _consumed_digit = _bind$5._2;
      mantissa$2 = _new_mantissa;
      let _tmp$4;
      if (_M0IP016_24default__implPB7Compare6op__geGmE(mantissa$2, _M0FPC17strconv17min__19digit__int)) {
        _tmp$4 = _consumed_digit;
      } else {
        if (_M0MPC16string6String24char__length__ge_2einner(_s$3.str, 1, _s$3.start, _s$3.end)) {
          const _tmp$5 = _s$3.str;
          const _bind$6 = _M0MPC16string6String29offset__of__nth__char_2einner(_s$3.str, 1, _s$3.start, _s$3.end);
          let _tmp$6;
          if (_bind$6 === undefined) {
            _tmp$6 = _s$3.end;
          } else {
            const _Some = _bind$6;
            _tmp$6 = _Some;
          }
          const _x = new _M0TPC16string10StringView(_tmp$5, _tmp$6, _s$3.end);
          const _bind$7 = _M0FPC17strconv20try__parse__19digits(_x, mantissa$2);
          const _new_mantissa$2 = _bind$7._1;
          const _consumed_digit$2 = _bind$7._2;
          mantissa$2 = _new_mantissa$2;
          _tmp$4 = _consumed_digit$2;
        } else {
          return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(undefined);
        }
      }
      exponent = _M0MPC13int3Int9to__int64(_tmp$4);
      exponent = _M0IPC15int645Int64PB3Add3add(exponent, _M0FPC17strconv13parse__numberN11exp__numberS222);
    }
    return new _M0DTPC16result6ResultGORPC17strconv6NumberRPC17strconv12StrConvErrorE2Ok(new _M0TPC17strconv6Number(exponent, mantissa$2, _negative, many_digits));
  } else {
    return _M0FPC17strconv11syntax__errGORPC17strconv6NumberE();
  }
}
function _M0FPC17strconv14assemble__bits(mantissa, exponent, negative) {
  const biased_exp = exponent - _M0FPC17strconv12double__info.bias | 0;
  let bits = _M0IPC15int645Int64PB6BitAnd4land(mantissa, _M0IPC15int645Int64PB3Sub3sub(_M0IPC15int645Int64PB3Shl3shl($1L, _M0FPC17strconv12double__info.mantissa_bits), $1L));
  const exp_bits = _M0MPC13int3Int9to__int64(biased_exp & ((1 << _M0FPC17strconv12double__info.exponent_bits) - 1 | 0));
  bits = _M0IPC15int645Int64PB5BitOr3lor(bits, _M0IPC15int645Int64PB3Shl3shl(exp_bits, _M0FPC17strconv12double__info.mantissa_bits));
  if (negative) {
    bits = _M0IPC15int645Int64PB5BitOr3lor(bits, _M0IPC15int645Int64PB3Shl3shl(_M0IPC15int645Int64PB3Shl3shl($1L, _M0FPC17strconv12double__info.mantissa_bits), _M0FPC17strconv12double__info.exponent_bits));
  }
  return bits;
}
function _M0MPC17strconv7Decimal17should__round__up(self, d) {
  if (d < 0 || d >= self.digits_num) {
    return false;
  }
  let _tmp;
  const _tmp$2 = self.digits;
  $bound_check(_tmp$2, d);
  if (_tmp$2[d] === 5) {
    _tmp = (d + 1 | 0) === self.digits_num;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    if (self.truncated) {
      return true;
    }
    let _tmp$3;
    if (d > 0) {
      const _tmp$4 = self.digits;
      const _tmp$5 = d - 1 | 0;
      $bound_check(_tmp$4, _tmp$5);
      if (2 === 0) {
        $panic();
      }
      _tmp$3 = (_tmp$4[_tmp$5] % 2 | 0) !== 0;
    } else {
      _tmp$3 = false;
    }
    return _tmp$3;
  }
  const _tmp$3 = self.digits;
  $bound_check(_tmp$3, d);
  return _tmp$3[d] >= 5;
}
function _M0MPC17strconv7Decimal16rounded__integer(self) {
  if (self.decimal_point > 20) {
    return $_1L;
  }
  let n = $0L;
  let i = 0;
  while (true) {
    if (i < self.decimal_point && i < self.digits_num) {
      const _tmp = _M0IPC15int645Int64PB3Mul3mul(n, $10L);
      const _tmp$2 = self.digits;
      const _tmp$3 = i;
      $bound_check(_tmp$2, _tmp$3);
      n = _M0IPC15int645Int64PB3Add3add(_tmp, _M0MPC14byte4Byte9to__int64(_tmp$2[_tmp$3]));
      i = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    if (i < self.decimal_point) {
      n = _M0IPC15int645Int64PB3Mul3mul(n, $10L);
      i = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (_M0MPC17strconv7Decimal17should__round__up(self, self.decimal_point)) {
    n = _M0IPC15int645Int64PB3Add3add(n, $1L);
  }
  return n;
}
function _M0MPC17strconv7Decimal11new__digits(self, s) {
  const new_digits = _M0MPC15array13ReadOnlyArray2atGmE(_M0FPC17strconv19left__shift__cheats, s)._0;
  const cheat_num = _M0MPC15array13ReadOnlyArray2atGmE(_M0FPC17strconv19left__shift__cheats, s)._1;
  let less = false;
  const _bind = cheat_num.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      if (i >= self.digits_num) {
        less = true;
        break;
      }
      const d = cheat_num.charCodeAt(i) - 48 | 0;
      const _tmp$2 = self.digits;
      $bound_check(_tmp$2, i);
      if (_tmp$2[i] !== d) {
        const _tmp$3 = self.digits;
        $bound_check(_tmp$3, i);
        less = _tmp$3[i] < d;
        break;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return less ? new_digits - 1 | 0 : new_digits;
}
function _M0MPC17strconv7Decimal11left__shift(self, s) {
  const new_digits = _M0MPC17strconv7Decimal11new__digits(self, s);
  let read_index = self.digits_num;
  let write_index = self.digits_num + new_digits | 0;
  let acc = $0L;
  read_index = read_index - 1 | 0;
  while (true) {
    if (read_index >= 0) {
      const _tmp = self.digits;
      const _tmp$2 = read_index;
      $bound_check(_tmp, _tmp$2);
      const d = _M0MPC14byte4Byte9to__int64(_tmp[_tmp$2]);
      acc = _M0IPC15int645Int64PB3Add3add(acc, _M0IPC15int645Int64PB3Shl3shl(d, s));
      const quo = _M0IPC15int645Int64PB3Div3div(acc, $10L);
      const rem = _M0MPC15int645Int647to__int(_M0IPC15int645Int64PB3Sub3sub(acc, _M0IPC15int645Int64PB3Mul3mul(quo, $10L)));
      write_index = write_index - 1 | 0;
      if (write_index < self.digits.length) {
        const _tmp$3 = self.digits;
        const _tmp$4 = write_index;
        $bound_check(_tmp$3, _tmp$4);
        _tmp$3[_tmp$4] = rem & 255;
      } else {
        if (rem !== 0) {
          self.truncated = true;
        }
      }
      acc = quo;
      read_index = read_index - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    if (_M0IP016_24default__implPB7Compare6op__gtGlE(acc, $0L)) {
      const quo = _M0IPC15int645Int64PB3Div3div(acc, $10L);
      const rem = _M0MPC15int645Int647to__int(_M0IPC15int645Int64PB3Sub3sub(acc, _M0IPC15int645Int64PB3Mul3mul($10L, quo)));
      write_index = write_index - 1 | 0;
      if (write_index < self.digits.length) {
        const _tmp = self.digits;
        const _tmp$2 = write_index;
        $bound_check(_tmp, _tmp$2);
        _tmp[_tmp$2] = rem & 255;
      } else {
        if (rem !== 0) {
          self.truncated = true;
        }
      }
      acc = quo;
      continue;
    } else {
      break;
    }
  }
  self.digits_num = self.digits_num + new_digits | 0;
  if (self.digits_num > self.digits.length) {
    self.digits_num = self.digits.length;
  }
  self.decimal_point = self.decimal_point + new_digits | 0;
  _M0MPC17strconv7Decimal4trim(self);
}
function _M0MPC17strconv7Decimal12right__shift(self, s) {
  let read_index = 0;
  let write_index = 0;
  let acc = $0L;
  while (true) {
    if (_M0IPC16uint646UInt64PB2Eq5equal(_M0IPC16uint646UInt64PB3Shr3shr(acc, s), $0L)) {
      if (read_index >= self.digits_num) {
        while (true) {
          if (_M0IPC16uint646UInt64PB2Eq5equal(_M0IPC16uint646UInt64PB3Shr3shr(acc, s), $0L)) {
            acc = _M0IPC16uint646UInt64PB3Mul3mul(acc, $10L);
            read_index = read_index + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break;
      }
      const _tmp = self.digits;
      const _tmp$2 = read_index;
      $bound_check(_tmp, _tmp$2);
      const d = _tmp[_tmp$2];
      acc = _M0IPC16uint646UInt64PB3Add3add(_M0IPC16uint646UInt64PB3Mul3mul(acc, $10L), _M0MPC14byte4Byte9to__int64(d));
      read_index = read_index + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  self.decimal_point = self.decimal_point - (read_index - 1 | 0) | 0;
  const mask = _M0IPC16uint646UInt64PB3Sub3sub(_M0IPC16uint646UInt64PB3Shl3shl($1L, s), $1L);
  while (true) {
    if (read_index < self.digits_num) {
      const out = _M0IPC16uint646UInt64PB3Shr3shr(acc, s);
      const _tmp = self.digits;
      const _tmp$2 = write_index;
      $bound_check(_tmp, _tmp$2);
      _tmp[_tmp$2] = _M0MPC16uint646UInt648to__byte(out);
      write_index = write_index + 1 | 0;
      acc = _M0IPC16uint646UInt64PB6BitAnd4land(acc, mask);
      const _tmp$3 = self.digits;
      const _tmp$4 = read_index;
      $bound_check(_tmp$3, _tmp$4);
      const d = _tmp$3[_tmp$4];
      acc = _M0IPC16uint646UInt64PB3Add3add(_M0IPC16uint646UInt64PB3Mul3mul(acc, $10L), _M0MPC14byte4Byte9to__int64(d));
      read_index = read_index + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    if (_M0IP016_24default__implPB7Compare6op__gtGmE(acc, $0L)) {
      const out = _M0IPC16uint646UInt64PB3Shr3shr(acc, s);
      if (write_index < self.digits.length) {
        const _tmp = self.digits;
        const _tmp$2 = write_index;
        $bound_check(_tmp, _tmp$2);
        _tmp[_tmp$2] = _M0MPC16uint646UInt648to__byte(out);
        write_index = write_index + 1 | 0;
      } else {
        if (_M0IP016_24default__implPB7Compare6op__gtGmE(out, $0L)) {
          self.truncated = true;
        }
      }
      acc = _M0IPC16uint646UInt64PB6BitAnd4land(acc, mask);
      acc = _M0IPC16uint646UInt64PB3Mul3mul(acc, $10L);
      continue;
    } else {
      break;
    }
  }
  self.digits_num = write_index;
  _M0MPC17strconv7Decimal4trim(self);
}
function _M0MPC17strconv7Decimal11shift__priv(self, s) {
  if (self.digits_num === 0) {
    return undefined;
  }
  let s$2 = s;
  if (s$2 > 0) {
    while (true) {
      if (s$2 > 59) {
        _M0MPC17strconv7Decimal11left__shift(self, 59);
        s$2 = s$2 - 59 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0MPC17strconv7Decimal11left__shift(self, s$2);
  }
  if (s$2 < 0) {
    while (true) {
      if (s$2 < -59) {
        _M0MPC17strconv7Decimal12right__shift(self, 59);
        s$2 = s$2 + 59 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0MPC17strconv7Decimal12right__shift(self, -s$2 | 0);
    return;
  } else {
    return;
  }
}
function _M0MPC17strconv7Decimal16to__double__priv(self) {
  let exponent = 0;
  let mantissa = $0L;
  if (self.digits_num === 0 || self.decimal_point < -330) {
    mantissa = $0L;
    exponent = _M0FPC17strconv12double__info.bias;
    const bits = _M0FPC17strconv14assemble__bits(mantissa, exponent, self.negative);
    return new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_M0MPC15int645Int6423reinterpret__as__double(bits));
  }
  if (self.decimal_point > 310) {
    const _bind = _M0FPC17strconv10range__errGuE();
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _ok._0;
    } else {
      return _bind;
    }
  }
  while (true) {
    if (self.decimal_point > 0) {
      let n = 0;
      if (self.decimal_point >= _M0MPC15array13ReadOnlyArray6lengthGiE(_M0FPC17strconv6powtab)) {
        n = 60;
      } else {
        n = _M0MPC15array13ReadOnlyArray2atGiE(_M0FPC17strconv6powtab, self.decimal_point);
      }
      _M0MPC17strconv7Decimal11shift__priv(self, -n | 0);
      exponent = exponent + n | 0;
      continue;
    } else {
      break;
    }
  }
  while (true) {
    let _tmp;
    if (self.decimal_point < 0) {
      _tmp = true;
    } else {
      let _tmp$2;
      if (self.decimal_point === 0) {
        const _tmp$3 = self.digits;
        $bound_check(_tmp$3, 0);
        _tmp$2 = _tmp$3[0] < 5;
      } else {
        _tmp$2 = false;
      }
      _tmp = _tmp$2;
    }
    if (_tmp) {
      let n = 0;
      if ((-self.decimal_point | 0) >= _M0MPC15array13ReadOnlyArray6lengthGiE(_M0FPC17strconv6powtab)) {
        n = 60;
      } else {
        n = _M0MPC15array13ReadOnlyArray2atGiE(_M0FPC17strconv6powtab, -self.decimal_point | 0);
      }
      _M0MPC17strconv7Decimal11shift__priv(self, n);
      exponent = exponent - n | 0;
      continue;
    } else {
      break;
    }
  }
  exponent = exponent - 1 | 0;
  if (exponent < (_M0FPC17strconv12double__info.bias + 1 | 0)) {
    const n = (_M0FPC17strconv12double__info.bias + 1 | 0) - exponent | 0;
    _M0MPC17strconv7Decimal11shift__priv(self, -n | 0);
    exponent = exponent + n | 0;
  }
  if ((exponent - _M0FPC17strconv12double__info.bias | 0) >= ((1 << _M0FPC17strconv12double__info.exponent_bits) - 1 | 0)) {
    const _bind = _M0FPC17strconv10range__errGuE();
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _ok._0;
    } else {
      return _bind;
    }
  }
  _M0MPC17strconv7Decimal11shift__priv(self, _M0FPC17strconv12double__info.mantissa_bits + 1 | 0);
  mantissa = _M0MPC17strconv7Decimal16rounded__integer(self);
  if (_M0IPC15int645Int64PB2Eq5equal(mantissa, _M0IPC15int645Int64PB3Shl3shl($2L, _M0FPC17strconv12double__info.mantissa_bits))) {
    mantissa = _M0IPC15int645Int64PB3Shr3shr(mantissa, 1);
    exponent = exponent + 1 | 0;
    if ((exponent - _M0FPC17strconv12double__info.bias | 0) >= ((1 << _M0FPC17strconv12double__info.exponent_bits) - 1 | 0)) {
      const _bind = _M0FPC17strconv10range__errGuE();
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _ok._0;
      } else {
        return _bind;
      }
    }
  }
  if (_M0IPC15int645Int64PB2Eq5equal(_M0IPC15int645Int64PB6BitAnd4land(mantissa, _M0IPC15int645Int64PB3Shl3shl($1L, _M0FPC17strconv12double__info.mantissa_bits)), $0L)) {
    exponent = _M0FPC17strconv12double__info.bias;
  }
  const bits = _M0FPC17strconv14assemble__bits(mantissa, exponent, self.negative);
  return new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_M0MPC15int645Int6423reinterpret__as__double(bits));
}
function _M0FPC17strconv12checked__mul(a, b) {
  if (_M0IPC16uint646UInt64PB2Eq5equal(a, $0L) || _M0IPC16uint646UInt64PB2Eq5equal(b, $0L)) {
    return _M0FPC17strconv28checked__mul_2econstr_2f1547;
  }
  if (_M0IPC16uint646UInt64PB2Eq5equal(a, $1L)) {
    return b;
  }
  if (_M0IPC16uint646UInt64PB2Eq5equal(b, $1L)) {
    return a;
  }
  if (_M0MPC16uint646UInt643clz(b) === 0 || _M0MPC16uint646UInt643clz(a) === 0) {
    return undefined;
  }
  const quotient = _M0IPC16uint646UInt64PB3Div3div(_M0FPC16uint6410max__value, b);
  if (_M0IP016_24default__implPB7Compare6op__gtGmE(a, quotient)) {
    return undefined;
  }
  return _M0IPC16uint646UInt64PB3Mul3mul(a, b);
}
function _M0FPC17strconv17pow10__fast__path(exponent) {
  return _M0MPC15array13ReadOnlyArray2atGdE(_M0FPC17strconv5table, exponent & 31);
}
function _M0MPC17strconv6Number14is__fast__path(self) {
  return _M0IP016_24default__implPB7Compare6op__leGlE(_M0FPC17strconv25min__exponent__fast__path, self.exponent) && (_M0IP016_24default__implPB7Compare6op__leGlE(self.exponent, _M0FPC17strconv36max__exponent__disguised__fast__path) && (_M0IP016_24default__implPB7Compare6op__leGmE(self.mantissa, _M0FPC17strconv25max__mantissa__fast__path) && !self.many_digits));
}
function _M0MPC17strconv6Number15try__fast__path(self) {
  if (_M0MPC17strconv6Number14is__fast__path(self)) {
    let value;
    if (_M0IP016_24default__implPB7Compare6op__leGlE(self.exponent, _M0FPC17strconv25max__exponent__fast__path)) {
      const value$2 = _M0MPC16double6Double15convert__uint64(self.mantissa);
      value = _M0IP016_24default__implPB7Compare6op__ltGlE(self.exponent, $0L) ? value$2 / _M0FPC17strconv17pow10__fast__path(-_M0MPC15int645Int647to__int(self.exponent) | 0) : value$2 * _M0FPC17strconv17pow10__fast__path(_M0MPC15int645Int647to__int(self.exponent));
    } else {
      const shift = _M0IPC15int645Int64PB3Sub3sub(self.exponent, _M0FPC17strconv25max__exponent__fast__path);
      const _bind = _M0FPC17strconv12checked__mul(self.mantissa, _M0MPC15array13ReadOnlyArray2atGmE(_M0FPC17strconv10int__pow10, _M0MPC15int645Int647to__int(shift)));
      let mantissa;
      if (_bind === undefined) {
        return _M0DTPC16option6OptionGdE4None__;
      } else {
        const _Some = _bind;
        mantissa = _Some;
      }
      if (_M0IP016_24default__implPB7Compare6op__gtGmE(mantissa, _M0FPC17strconv25max__mantissa__fast__path)) {
        return _M0DTPC16option6OptionGdE4None__;
      }
      value = _M0MPC16double6Double15convert__uint64(mantissa) * _M0FPC17strconv17pow10__fast__path(_M0MPC15int645Int647to__int(_M0FPC17strconv25max__exponent__fast__path));
    }
    if (self.negative) {
      value = -value;
    }
    return new _M0DTPC16option6OptionGdE4Some(value);
  } else {
    return _M0DTPC16option6OptionGdE4None__;
  }
}
function _M0FPC17strconv13parse__double(str) {
  if (_M0MPC16string10StringView6length(str) > 0) {
    if (_M0FPC17strconv17check__underscore(str)) {
      const _bind = _M0FPC17strconv13parse__number(str);
      let _bind$2;
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _bind$2 = _ok._0;
      } else {
        return _bind;
      }
      if (_bind$2 === undefined) {
        return _M0FPC17strconv15parse__inf__nan(str);
      } else {
        const _Some = _bind$2;
        const _num = _Some;
        const _bind$3 = _M0MPC17strconv6Number15try__fast__path(_num);
        if (_bind$3.$tag === 1) {
          const _Some$2 = _bind$3;
          const _value = _Some$2._0;
          return new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_value);
        } else {
          const _bind$4 = _M0FPC17strconv20parse__decimal__priv(str);
          let _tmp;
          if (_bind$4.$tag === 1) {
            const _ok = _bind$4;
            _tmp = _ok._0;
          } else {
            return _bind$4;
          }
          return _M0MPC17strconv7Decimal16to__double__priv(_tmp);
        }
      }
    } else {
      return _M0FPC17strconv11syntax__errGdE();
    }
  } else {
    return _M0FPC17strconv11syntax__errGdE();
  }
}
function _M0IPC17strconv12StrConvErrorPB4Show6output(self, logger) {
  const _StrConvError = self;
  const _err = _StrConvError._0;
  logger.method_table.method_0(logger.self, _err);
}
function _M0FPC14json20offset__to__position(input, offset) {
  let line = 1;
  let column = 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < offset) {
      if (_M0IPC16uint166UInt16PB2Eq5equal(_M0MPC16string10StringView11unsafe__get(input, i), 10)) {
        line = line + 1 | 0;
        column = 0;
      } else {
        column = column + 1 | 0;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TPC14json8Position(line, column);
}
function _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, shift) {
  const offset = ctx.offset + shift | 0;
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(new _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(_M0FPC14json20offset__to__position(ctx.input, offset), _M0MPC16option6Option10unwrap__orGcE(_M0MPC16string10StringView9get__char(ctx.input, offset), 65533)));
}
function _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, shift) {
  const offset = ctx.offset + shift | 0;
  return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(new _M0DTPC15error5Error52moonbitlang_2fcore_2fjson_2eParseError_2eInvalidChar(_M0FPC14json20offset__to__position(ctx.input, offset), _M0MPC16option6Option10unwrap__orGcE(_M0MPC16string10StringView9get__char(ctx.input, offset), 65533)));
}
function _M0IPC14json10ParseErrorPB4Show6output(self, logger) {
  switch (self.$tag) {
    case 4: {
      const _InvalidChar = self;
      const _x = _InvalidChar._0;
      const _line = _x.line;
      const _column = _x.column;
      const _c = _InvalidChar._1;
      logger.method_table.method_0(logger.self, "Invalid character ");
      logger.method_table.method_0(logger.self, _M0FPB4reprGcE(_c));
      logger.method_table.method_0(logger.self, " at line ");
      _M0MPB6Logger13write__objectGiE(logger, _line);
      logger.method_table.method_0(logger.self, ", column ");
      _M0MPB6Logger13write__objectGiE(logger, _column);
      return;
    }
    case 3: {
      logger.method_table.method_0(logger.self, "Unexpected end of file");
      return;
    }
    case 2: {
      const _InvalidNumber = self;
      const _x$2 = _InvalidNumber._0;
      const _line$2 = _x$2.line;
      const _column$2 = _x$2.column;
      const _s = _InvalidNumber._1;
      logger.method_table.method_0(logger.self, "Invalid number ");
      logger.method_table.method_0(logger.self, _s);
      logger.method_table.method_0(logger.self, " at line ");
      _M0MPB6Logger13write__objectGiE(logger, _line$2);
      logger.method_table.method_0(logger.self, ", column ");
      _M0MPB6Logger13write__objectGiE(logger, _column$2);
      return;
    }
    case 1: {
      const _InvalidIdentEscape = self;
      const _x$3 = _InvalidIdentEscape._0;
      const _line$3 = _x$3.line;
      const _column$3 = _x$3.column;
      logger.method_table.method_0(logger.self, "Invalid escape sequence in identifier at line ");
      _M0MPB6Logger13write__objectGiE(logger, _line$3);
      logger.method_table.method_0(logger.self, ", column ");
      _M0MPB6Logger13write__objectGiE(logger, _column$3);
      return;
    }
    default: {
      logger.method_table.method_0(logger.self, "Depth limit exceeded, please increase the max_nesting_depth parameter");
      return;
    }
  }
}
function _M0MPC14json12ParseContext21lex__skip__whitespace(ctx) {
  const rest = _M0MPC16string10StringView12view_2einner(ctx.input, ctx.offset, ctx.end_offset);
  const _data = _M0MPC16string10StringView4data(rest);
  const _start = _M0MPC16string10StringView13start__offset(rest);
  const _end = _start + _M0MPC16string10StringView6length(rest) | 0;
  let _cursor = _start;
  let accept_state = -1;
  let match_end = -1;
  _L: {
    if (_cursor < _end) {
      _L$2: {
        const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
        _cursor = _cursor + 1 | 0;
        if (next_char < 13) {
          if (next_char >= 9 && next_char <= 10) {
            break _L$2;
          } else {
            break _L;
          }
        } else {
          if (next_char > 13) {
            if (next_char === 32) {
              break _L$2;
            } else {
              break _L;
            }
          } else {
            break _L$2;
          }
        }
      }
      while (true) {
        accept_state = 0;
        match_end = _cursor;
        if (_cursor < _end) {
          _L$3: {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char < 13) {
              if (next_char >= 9 && next_char <= 10) {
                break _L$3;
              } else {
                break _L;
              }
            } else {
              if (next_char > 13) {
                if (next_char === 32) {
                  break _L$3;
                } else {
                  break _L;
                }
              } else {
                break _L$3;
              }
            }
          }
          continue;
        } else {
          break _L;
        }
      }
    } else {
      break _L;
    }
  }
  if (accept_state === 0) {
    const next = _M0MPC16string6String4view(_data, match_end, _end);
    ctx.offset = ctx.end_offset - _M0MPC16string10StringView6length(next) | 0;
    return;
  } else {
    return;
  }
}
function _M0MPC14json12ParseContext4make(input, max_nesting_depth) {
  return new _M0TPC14json12ParseContext(0, input, _M0MPC16string10StringView6length(input), max_nesting_depth);
}
function _M0MPC14json12ParseContext19expect__ascii__char(ctx, c) {
  if (ctx.offset < ctx.end_offset) {
    const c1 = _M0MPC16string10StringView11unsafe__get(ctx.input, ctx.offset);
    ctx.offset = ctx.offset + 1 | 0;
    return c !== c1 ? _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1) : new _M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok(undefined);
  } else {
    return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  }
}
function _M0MPC14json12ParseContext16lex__number__end(ctx, start, end) {
  const s = _M0MPC16string10StringView12view_2einner(ctx.input, start, end);
  if (!_M0MPC16string10StringView8contains(s, new _M0TPC16string10StringView(_M0MPC14json12ParseContext16lex__number__endN7_2abindS1058, 0, _M0MPC14json12ParseContext16lex__number__endN7_2abindS1058.length)) && (!_M0MPC16string10StringView8contains(s, new _M0TPC16string10StringView(_M0MPC14json12ParseContext16lex__number__endN7_2abindS1059, 0, _M0MPC14json12ParseContext16lex__number__endN7_2abindS1059.length)) && !_M0MPC16string10StringView8contains(s, new _M0TPC16string10StringView(_M0MPC14json12ParseContext16lex__number__endN7_2abindS1060, 0, _M0MPC14json12ParseContext16lex__number__endN7_2abindS1060.length)))) {
    let parsed_int;
    let _try_err;
    _L: {
      _L$2: {
        const _bind = _M0FPC17strconv20parse__int64_2einner(s, 0);
        let _tmp;
        if (_bind.$tag === 1) {
          const _ok = _bind;
          _tmp = _ok._0;
        } else {
          const _err = _bind;
          _try_err = _err._0;
          break _L$2;
        }
        parsed_int = new _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE2Ok(_tmp);
        break _L;
      }
      parsed_int = new _M0DTPC16result6ResultGlRPC17strconv12StrConvErrorE3Err(_try_err);
    }
    _L$2: {
      if (parsed_int.$tag === 1) {
        const _Ok = parsed_int;
        const _i = _Ok._0;
        if (_M0IP016_24default__implPB7Compare6op__leGlE(_i, $9007199254740991L) && _M0IP016_24default__implPB7Compare6op__geGlE(_i, $_9007199254740991L)) {
          return { _0: _M0MPC15int645Int6410to__double(_i), _1: undefined };
        } else {
          break _L$2;
        }
      } else {
        break _L$2;
      }
    }
    _L$3: {
      if (_M0MPC16string6String24char__length__ge_2einner(s.str, 1, s.start, s.end)) {
        const _x = _M0MPC16string6String16unsafe__char__at(s.str, _M0MPC16string6String29offset__of__nth__char_2einner(s.str, 0, s.start, s.end));
        if (_x === 45) {
          return { _0: _M0FPC16double13neg__infinity, _1: s };
        } else {
          break _L$3;
        }
      } else {
        break _L$3;
      }
    }
    return { _0: _M0FPC16double8infinity, _1: s };
  } else {
    let parsed_double;
    let _try_err;
    _L: {
      _L$2: {
        const _bind = _M0FPC17strconv13parse__double(s);
        let _tmp;
        if (_bind.$tag === 1) {
          const _ok = _bind;
          _tmp = _ok._0;
        } else {
          const _err = _bind;
          _try_err = _err._0;
          break _L$2;
        }
        parsed_double = new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE2Ok(_tmp);
        break _L;
      }
      parsed_double = new _M0DTPC16result6ResultGdRPC17strconv12StrConvErrorE3Err(_try_err);
    }
    if (parsed_double.$tag === 1) {
      const _Ok = parsed_double;
      const _d = _Ok._0;
      return { _0: _d, _1: undefined };
    } else {
      _L$2: {
        if (_M0MPC16string6String24char__length__ge_2einner(s.str, 1, s.start, s.end)) {
          const _x = _M0MPC16string6String16unsafe__char__at(s.str, _M0MPC16string6String29offset__of__nth__char_2einner(s.str, 0, s.start, s.end));
          if (_x === 45) {
            return { _0: _M0FPC16double13neg__infinity, _1: s };
          } else {
            break _L$2;
          }
        } else {
          break _L$2;
        }
      }
      return { _0: _M0FPC16double8infinity, _1: s };
    }
  }
}
function _M0MPC14json12ParseContext10read__char(ctx) {
  if (ctx.offset < ctx.end_offset) {
    const c1 = _M0MPC16string10StringView11unsafe__get(ctx.input, ctx.offset);
    ctx.offset = ctx.offset + 1 | 0;
    if (c1 >= 55296 && c1 <= 56319) {
      if (ctx.offset < ctx.end_offset) {
        const c2 = _M0MPC16string10StringView11unsafe__get(ctx.input, ctx.offset);
        if (c2 >= 56320 && c2 <= 57343) {
          ctx.offset = ctx.offset + 1 | 0;
          const c3 = ((c1 << 10) + c2 | 0) - 56613888 | 0;
          return c3;
        }
      }
    }
    return c1;
  } else {
    return -1;
  }
}
function _M0MPC14json12ParseContext31lex__decimal__exponent__integer(ctx, start) {
  while (true) {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return _M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset);
    } else {
      const _Some = _bind;
      const _c = _Some;
      if (_c >= 48 && _c <= 57) {
        continue;
      }
      ctx.offset = ctx.offset - 1 | 0;
      return _M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset);
    }
  }
}
function _M0MPC14json12ParseContext28lex__decimal__exponent__sign(ctx, start) {
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _c = _Some;
    if (_c >= 48 && _c <= 57) {
      return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext31lex__decimal__exponent__integer(ctx, start));
    }
    ctx.offset = ctx.offset - 1 | 0;
    return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
  }
}
function _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start) {
  _L: {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
    } else {
      const _Some = _bind;
      const _x = _Some;
      switch (_x) {
        case 43: {
          break _L;
        }
        case 45: {
          break _L;
        }
        default: {
          if (_x >= 48 && _x <= 57) {
            return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext31lex__decimal__exponent__integer(ctx, start));
          }
          ctx.offset = ctx.offset - 1 | 0;
          return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
        }
      }
    }
  }
  const _bind = _M0MPC14json12ParseContext28lex__decimal__exponent__sign(ctx, start);
  let _tmp;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _tmp = _ok._0;
  } else {
    return _bind;
  }
  return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext22lex__decimal__fraction(ctx, start) {
  let _tmp;
  _L: while (true) {
    _L$2: {
      const _bind = _M0MPC14json12ParseContext10read__char(ctx);
      if (_bind === -1) {
        return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
      } else {
        const _Some = _bind;
        const _x = _Some;
        switch (_x) {
          case 101: {
            break _L$2;
          }
          case 69: {
            break _L$2;
          }
          default: {
            if (_x >= 48 && _x <= 57) {
              continue _L;
            }
            ctx.offset = ctx.offset - 1 | 0;
            return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
          }
        }
      }
    }
    const _bind = _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start);
    let _tmp$2;
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _tmp$2 = _ok._0;
    } else {
      return _bind;
    }
    return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_tmp$2);
  }
  return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext19lex__decimal__point(ctx, start) {
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _c = _Some;
    return _c >= 48 && _c <= 57 ? _M0MPC14json12ParseContext22lex__decimal__fraction(ctx, start) : _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
  }
}
function _M0MPC14json12ParseContext21lex__decimal__integer(ctx, start) {
  let _tmp;
  _L: while (true) {
    _L$2: {
      const _bind = _M0MPC14json12ParseContext10read__char(ctx);
      if (_bind === -1) {
        return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
      } else {
        const _Some = _bind;
        const _x = _Some;
        switch (_x) {
          case 46: {
            const _bind$2 = _M0MPC14json12ParseContext19lex__decimal__point(ctx, start);
            let _tmp$2;
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _tmp$2 = _ok._0;
            } else {
              return _bind$2;
            }
            return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_tmp$2);
          }
          case 101: {
            break _L$2;
          }
          case 69: {
            break _L$2;
          }
          default: {
            if (_x >= 48 && _x <= 57) {
              continue _L;
            }
            ctx.offset = ctx.offset - 1 | 0;
            return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
          }
        }
      }
    }
    const _bind = _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start);
    let _tmp$2;
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _tmp$2 = _ok._0;
    } else {
      return _bind;
    }
    return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_tmp$2);
  }
  return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext16lex__hex__digits(ctx, n) {
  let r = 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < n) {
      const _bind = _M0MPC14json12ParseContext10read__char(ctx);
      if (_bind === -1) {
        return new _M0DTPC16result6ResultGiRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
      } else {
        const _Some = _bind;
        const _c = _Some;
        if (_c >= 65) {
          const d = ((_c & ~32) - 65 | 0) + 10 | 0;
          if (d > 15) {
            const _bind$2 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _ok._0;
            } else {
              return _bind$2;
            }
          }
          r = r << 4 | d;
        } else {
          if (_c >= 48) {
            const d = _c - 48 | 0;
            if (d > 9) {
              const _bind$2 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
              if (_bind$2.$tag === 1) {
                const _ok = _bind$2;
                _ok._0;
              } else {
                return _bind$2;
              }
            }
            r = r << 4 | d;
          } else {
            const _bind$2 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _ok._0;
            } else {
              return _bind$2;
            }
          }
        }
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGiRPC14json10ParseErrorE2Ok(r);
}
function _M0MPC14json12ParseContext11lex__stringN5flushS273(_env, end) {
  const start = _env._2;
  const ctx = _env._1;
  const buf = _env._0;
  if (start.val > 0 && end > start.val) {
    _M0IPB13StringBuilderPB6Logger11write__view(buf, _M0MPC16string10StringView11sub_2einner(ctx.input, start.val, end));
    return;
  } else {
    return;
  }
}
function _M0MPC14json12ParseContext11lex__string(ctx) {
  const buf = _M0MPB13StringBuilder11new_2einner(0);
  const start = new _M0TPC13ref3RefGiE(ctx.offset);
  const _env = { _0: buf, _1: ctx, _2: start };
  _L: while (true) {
    _L$2: {
      _L$3: {
        const _bind = _M0MPC14json12ParseContext10read__char(ctx);
        if (_bind === -1) {
          return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
        } else {
          const _Some = _bind;
          const _x = _Some;
          switch (_x) {
            case 34: {
              _M0MPC14json12ParseContext11lex__stringN5flushS273(_env, ctx.offset - 1 | 0);
              break _L;
            }
            case 10: {
              break _L$3;
            }
            case 13: {
              break _L$3;
            }
            case 92: {
              _M0MPC14json12ParseContext11lex__stringN5flushS273(_env, ctx.offset - 1 | 0);
              const _bind$2 = _M0MPC14json12ParseContext10read__char(ctx);
              if (_bind$2 === -1) {
                return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
              } else {
                const _Some$2 = _bind$2;
                const _x$2 = _Some$2;
                switch (_x$2) {
                  case 98: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 8);
                    break;
                  }
                  case 102: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 12);
                    break;
                  }
                  case 110: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 10);
                    break;
                  }
                  case 114: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 13);
                    break;
                  }
                  case 116: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 9);
                    break;
                  }
                  case 34: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 34);
                    break;
                  }
                  case 92: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 92);
                    break;
                  }
                  case 47: {
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, 47);
                    break;
                  }
                  case 117: {
                    const _bind$3 = _M0MPC14json12ParseContext16lex__hex__digits(ctx, 4);
                    let c;
                    if (_bind$3.$tag === 1) {
                      const _ok = _bind$3;
                      c = _ok._0;
                    } else {
                      return _bind$3;
                    }
                    _M0IPB13StringBuilderPB6Logger11write__char(buf, c);
                    break;
                  }
                  default: {
                    const _bind$4 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
                    if (_bind$4.$tag === 1) {
                      const _ok = _bind$4;
                      _ok._0;
                    } else {
                      return _bind$4;
                    }
                  }
                }
              }
              start.val = ctx.offset;
              break;
            }
            default: {
              if (_x < 32) {
                const _bind$3 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
                if (_bind$3.$tag === 1) {
                  const _ok = _bind$3;
                  _ok._0;
                } else {
                  return _bind$3;
                }
              } else {
                continue _L;
              }
            }
          }
        }
        break _L$2;
      }
      const _bind = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _ok._0;
      } else {
        return _bind;
      }
    }
    continue;
  }
  return new _M0DTPC16result6ResultGsRPC14json10ParseErrorE2Ok(_M0MPB13StringBuilder10to__string(buf));
}
function _M0MPC14json12ParseContext9lex__zero(ctx, start) {
  _L: {
    const _bind = _M0MPC14json12ParseContext10read__char(ctx);
    if (_bind === -1) {
      return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
    } else {
      const _Some = _bind;
      const _x = _Some;
      switch (_x) {
        case 46: {
          return _M0MPC14json12ParseContext19lex__decimal__point(ctx, start);
        }
        case 101: {
          break _L;
        }
        case 69: {
          break _L;
        }
        default: {
          if (_x >= 48 && _x <= 57) {
            ctx.offset = ctx.offset - 1 | 0;
            const _bind$2 = _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, 0);
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _ok._0;
            } else {
              return _bind$2;
            }
          }
          ctx.offset = ctx.offset - 1 | 0;
          return new _M0DTPC16result6ResultGUdORPC16string10StringViewERPC14json10ParseErrorE2Ok(_M0MPC14json12ParseContext16lex__number__end(ctx, start, ctx.offset));
        }
      }
    }
  }
  return _M0MPC14json12ParseContext22lex__decimal__exponent(ctx, start);
}
function _M0MPC14json12ParseContext10lex__value(ctx, allow_rbracket) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x === 123) {
      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token6LBrace__);
    } else {
      if (_x === 91) {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token8LBracket__);
      } else {
        if (_x === 93) {
          if (allow_rbracket) {
            return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token8RBracket__);
          } else {
            return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
          }
        } else {
          if (_x === 110) {
            const _bind$2 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 117);
            if (_bind$2.$tag === 1) {
              const _ok = _bind$2;
              _ok._0;
            } else {
              return _bind$2;
            }
            const _bind$3 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 108);
            if (_bind$3.$tag === 1) {
              const _ok = _bind$3;
              _ok._0;
            } else {
              return _bind$3;
            }
            const _bind$4 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 108);
            if (_bind$4.$tag === 1) {
              const _ok = _bind$4;
              _ok._0;
            } else {
              return _bind$4;
            }
            return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token4Null__);
          } else {
            if (_x === 116) {
              const _bind$2 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 114);
              if (_bind$2.$tag === 1) {
                const _ok = _bind$2;
                _ok._0;
              } else {
                return _bind$2;
              }
              const _bind$3 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 117);
              if (_bind$3.$tag === 1) {
                const _ok = _bind$3;
                _ok._0;
              } else {
                return _bind$3;
              }
              const _bind$4 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 101);
              if (_bind$4.$tag === 1) {
                const _ok = _bind$4;
                _ok._0;
              } else {
                return _bind$4;
              }
              return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token4True__);
            } else {
              if (_x === 102) {
                const _bind$2 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 97);
                if (_bind$2.$tag === 1) {
                  const _ok = _bind$2;
                  _ok._0;
                } else {
                  return _bind$2;
                }
                const _bind$3 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 108);
                if (_bind$3.$tag === 1) {
                  const _ok = _bind$3;
                  _ok._0;
                } else {
                  return _bind$3;
                }
                const _bind$4 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 115);
                if (_bind$4.$tag === 1) {
                  const _ok = _bind$4;
                  _ok._0;
                } else {
                  return _bind$4;
                }
                const _bind$5 = _M0MPC14json12ParseContext19expect__ascii__char(ctx, 101);
                if (_bind$5.$tag === 1) {
                  const _ok = _bind$5;
                  _ok._0;
                } else {
                  return _bind$5;
                }
                return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token5False__);
              } else {
                if (_x === 45) {
                  const _bind$2 = _M0MPC14json12ParseContext10read__char(ctx);
                  if (_bind$2 === -1) {
                    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
                  } else {
                    const _Some$2 = _bind$2;
                    const _x$2 = _Some$2;
                    if (_x$2 === 48) {
                      const _bind$3 = _M0MPC14json12ParseContext9lex__zero(ctx, ctx.offset - 2 | 0);
                      let _bind$4;
                      if (_bind$3.$tag === 1) {
                        const _ok = _bind$3;
                        _bind$4 = _ok._0;
                      } else {
                        return _bind$3;
                      }
                      const _n = _bind$4._0;
                      const _repr = _bind$4._1;
                      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0IPC16string10StringViewPB4Show10to__string(repr))));
                    } else {
                      if (_x$2 >= 49 && _x$2 <= 57) {
                        const _bind$3 = _M0MPC14json12ParseContext21lex__decimal__integer(ctx, ctx.offset - 2 | 0);
                        let _bind$4;
                        if (_bind$3.$tag === 1) {
                          const _ok = _bind$3;
                          _bind$4 = _ok._0;
                        } else {
                          return _bind$3;
                        }
                        const _n = _bind$4._0;
                        const _repr = _bind$4._1;
                        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0IPC16string10StringViewPB4Show10to__string(repr))));
                      }
                      return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
                    }
                  }
                } else {
                  if (_x === 48) {
                    const _bind$2 = _M0MPC14json12ParseContext9lex__zero(ctx, ctx.offset - 1 | 0);
                    let _bind$3;
                    if (_bind$2.$tag === 1) {
                      const _ok = _bind$2;
                      _bind$3 = _ok._0;
                    } else {
                      return _bind$2;
                    }
                    const _n = _bind$3._0;
                    const _repr = _bind$3._1;
                    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0IPC16string10StringViewPB4Show10to__string(repr))));
                  } else {
                    if (_x >= 49 && _x <= 57) {
                      const _bind$2 = _M0MPC14json12ParseContext21lex__decimal__integer(ctx, ctx.offset - 1 | 0);
                      let _bind$3;
                      if (_bind$2.$tag === 1) {
                        const _ok = _bind$2;
                        _bind$3 = _ok._0;
                      } else {
                        return _bind$2;
                      }
                      const _n = _bind$3._0;
                      const _repr = _bind$3._1;
                      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6Number(_n, _M0MPC16option6Option3mapGRPC16string10StringViewsE(_repr, (repr) => _M0IPC16string10StringViewPB4Show10to__string(repr))));
                    } else {
                      if (_x === 34) {
                        const _bind$2 = _M0MPC14json12ParseContext11lex__string(ctx);
                        let s;
                        if (_bind$2.$tag === 1) {
                          const _ok = _bind$2;
                          s = _ok._0;
                        } else {
                          return _bind$2;
                        }
                        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6String(s));
                      } else {
                        const shift = -_M0MPC14char4Char10utf16__len(_x) | 0;
                        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, shift);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
function _M0MPC14json12ParseContext24lex__after__array__value(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    switch (_x) {
      case 93: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token8RBracket__);
      }
      case 44: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token5Comma__);
      }
      default: {
        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
      }
    }
  }
}
function _M0MPC14json12ParseContext25lex__after__object__value(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    switch (_x) {
      case 125: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token6RBrace__);
      }
      case 44: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token5Comma__);
      }
      default: {
        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
      }
    }
  }
}
function _M0MPC14json12ParseContext26lex__after__property__name(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x === 58) {
      return new _M0DTPC16result6ResultGuRPC14json10ParseErrorE2Ok(undefined);
    } else {
      return _M0MPC14json12ParseContext21invalid__char_2einnerGuE(ctx, -1);
    }
  }
}
function _M0MPC14json12ParseContext19lex__property__name(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    switch (_x) {
      case 125: {
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(_M0DTPC14json5Token6RBrace__);
      }
      case 34: {
        const _bind$2 = _M0MPC14json12ParseContext11lex__string(ctx);
        let s;
        if (_bind$2.$tag === 1) {
          const _ok = _bind$2;
          s = _ok._0;
        } else {
          return _bind$2;
        }
        return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6String(s));
      }
      default: {
        return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
      }
    }
  }
}
function _M0MPC14json12ParseContext20lex__property__name2(ctx) {
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  const _bind = _M0MPC14json12ParseContext10read__char(ctx);
  if (_bind === -1) {
    return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE3Err(_M0DTPC15error5Error51moonbitlang_2fcore_2fjson_2eParseError_2eInvalidEof__);
  } else {
    const _Some = _bind;
    const _x = _Some;
    if (_x === 34) {
      const _bind$2 = _M0MPC14json12ParseContext11lex__string(ctx);
      let s;
      if (_bind$2.$tag === 1) {
        const _ok = _bind$2;
        s = _ok._0;
      } else {
        return _bind$2;
      }
      return new _M0DTPC16result6ResultGRPC14json5TokenRPC14json10ParseErrorE2Ok(new _M0DTPC14json5Token6String(s));
    } else {
      return _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, -1);
    }
  }
}
function _M0MPC14json12ParseContext12parse__value(ctx) {
  const _bind = _M0MPC14json12ParseContext10lex__value(ctx, false);
  let tok;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    tok = _ok._0;
  } else {
    return _bind;
  }
  return _M0MPC14json12ParseContext13parse__value2(ctx, tok);
}
function _M0MPC14json12ParseContext13parse__value2(ctx, tok) {
  _L: {
    switch (tok.$tag) {
      case 0: {
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0FPB4null);
      }
      case 1: {
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0MPC14json4Json7boolean(true));
      }
      case 2: {
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0MPC14json4Json7boolean(false));
      }
      case 3: {
        const _Number = tok;
        const _n = _Number._0;
        const _repr = _Number._1;
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0MPC14json4Json6number(_n, _repr));
      }
      case 4: {
        const _String = tok;
        const _s = _String._0;
        return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0MPC14json4Json6string(_s));
      }
      case 5: {
        return _M0MPC14json12ParseContext13parse__object(ctx);
      }
      case 7: {
        return _M0MPC14json12ParseContext12parse__array(ctx);
      }
      case 8: {
        break _L;
      }
      case 6: {
        break _L;
      }
      default: {
        break _L;
      }
    }
  }
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_M0FPB5abortGRPB4JsonE("unreachable", "@moonbitlang/core/json:parse.mbt:62:34-62:54"));
}
function _M0MPC14json12ParseContext12parse__array(ctx) {
  if (ctx.remaining_available_depth <= 0) {
    return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded__);
  }
  ctx.remaining_available_depth = ctx.remaining_available_depth - 1 | 0;
  const vec = [];
  let _tmp;
  const _bind = _M0MPC14json12ParseContext10lex__value(ctx, true);
  let _tmp$2;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _tmp$2 = _ok._0;
  } else {
    return _bind;
  }
  let _tmp$3 = _tmp$2;
  _L: while (true) {
    const _param = _tmp$3;
    if (_param.$tag === 8) {
      ctx.remaining_available_depth = ctx.remaining_available_depth + 1 | 0;
      _tmp = _M0MPC14json4Json5array(vec);
      break;
    } else {
      const _bind$2 = _M0MPC14json12ParseContext13parse__value2(ctx, _param);
      let _tmp$4;
      if (_bind$2.$tag === 1) {
        const _ok = _bind$2;
        _tmp$4 = _ok._0;
      } else {
        return _bind$2;
      }
      _M0MPC15array5Array4pushGzE(vec, _tmp$4);
      const _bind$3 = _M0MPC14json12ParseContext24lex__after__array__value(ctx);
      let tok2;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        tok2 = _ok._0;
      } else {
        return _bind$3;
      }
      switch (tok2.$tag) {
        case 9: {
          const _bind$4 = _M0MPC14json12ParseContext10lex__value(ctx, false);
          if (_bind$4.$tag === 1) {
            const _ok = _bind$4;
            _tmp$3 = _ok._0;
          } else {
            return _bind$4;
          }
          continue _L;
        }
        case 8: {
          ctx.remaining_available_depth = ctx.remaining_available_depth + 1 | 0;
          _tmp = _M0MPC14json4Json5array(vec);
          break _L;
        }
        default: {
          _tmp = _M0FPB5abortGRPB4JsonE("unreachable", "@moonbitlang/core/json:parse.mbt:115:14-115:34");
          break _L;
        }
      }
    }
  }
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_tmp);
}
function _M0MPC14json12ParseContext13parse__object(ctx) {
  if (ctx.remaining_available_depth <= 0) {
    return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE3Err(_M0DTPC15error5Error59moonbitlang_2fcore_2fjson_2eParseError_2eDepthLimitExceeded__);
  }
  ctx.remaining_available_depth = ctx.remaining_available_depth - 1 | 0;
  const map = _M0MPB3Map11new_2einnerGsRPB4JsonE(8);
  let _tmp;
  const _bind = _M0MPC14json12ParseContext19lex__property__name(ctx);
  let _tmp$2;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _tmp$2 = _ok._0;
  } else {
    return _bind;
  }
  let _tmp$3 = _tmp$2;
  _L: while (true) {
    const _param = _tmp$3;
    switch (_param.$tag) {
      case 6: {
        ctx.remaining_available_depth = ctx.remaining_available_depth + 1 | 0;
        _tmp = _M0MPC14json4Json6object(map);
        break _L;
      }
      case 4: {
        const _String = _param;
        const _name = _String._0;
        const _bind$2 = _M0MPC14json12ParseContext26lex__after__property__name(ctx);
        if (_bind$2.$tag === 1) {
          const _ok = _bind$2;
          _ok._0;
        } else {
          return _bind$2;
        }
        const _bind$3 = _M0MPC14json12ParseContext12parse__value(ctx);
        let _tmp$4;
        if (_bind$3.$tag === 1) {
          const _ok = _bind$3;
          _tmp$4 = _ok._0;
        } else {
          return _bind$3;
        }
        _M0MPB3Map3setGsRPB4JsonE(map, _name, _tmp$4);
        const _bind$4 = _M0MPC14json12ParseContext25lex__after__object__value(ctx);
        let _bind$5;
        if (_bind$4.$tag === 1) {
          const _ok = _bind$4;
          _bind$5 = _ok._0;
        } else {
          return _bind$4;
        }
        switch (_bind$5.$tag) {
          case 9: {
            const _bind$6 = _M0MPC14json12ParseContext20lex__property__name2(ctx);
            if (_bind$6.$tag === 1) {
              const _ok = _bind$6;
              _tmp$3 = _ok._0;
            } else {
              return _bind$6;
            }
            continue _L;
          }
          case 6: {
            ctx.remaining_available_depth = ctx.remaining_available_depth + 1 | 0;
            _tmp = _M0MPC14json4Json6object(map);
            break _L;
          }
          default: {
            _tmp = _M0FPB5abortGRPB4JsonE("unreachable", "@moonbitlang/core/json:parse.mbt:87:14-87:34");
            break _L;
          }
        }
      }
      default: {
        _tmp = _M0FPB5abortGRPB4JsonE("unreachable", "@moonbitlang/core/json:parse.mbt:90:10-90:30");
        break _L;
      }
    }
  }
  return new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(_tmp);
}
function _M0FPC14json13parse_2einner(input, max_nesting_depth) {
  const ctx = _M0MPC14json12ParseContext4make(input, max_nesting_depth);
  const _bind = _M0MPC14json12ParseContext12parse__value(ctx);
  let val;
  if (_bind.$tag === 1) {
    const _ok = _bind;
    val = _ok._0;
  } else {
    return _bind;
  }
  _M0MPC14json12ParseContext21lex__skip__whitespace(ctx);
  return ctx.offset >= ctx.end_offset ? new _M0DTPC16result6ResultGRPB4JsonRPC14json10ParseErrorE2Ok(val) : _M0MPC14json12ParseContext21invalid__char_2einnerGRPB4JsonE(ctx, 0);
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
function _M0MPC13ref3Ref3newGiE(x) {
  return new _M0TPC13ref3RefGiE(x);
}
function _M0IPC15error5ErrorPB4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0FP15Error10to__string(self));
}
function _M0FPC14math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FPC14math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0FPC14math3tan(_tmp) {
  return Math.tan(_tmp);
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
  let hi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math35trig__reduce_2etwo__over__pi_2f1818, ind);
  let mi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math35trig__reduce_2etwo__over__pi_2f1818, ind + 1 | 0);
  let lo = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math35trig__reduce_2etwo__over__pi_2f1818, ind + 2 | 0);
  const tp = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math35trig__reduce_2etwo__over__pi_2f1818, ind + 3 | 0);
  if (exp > 0) {
    hi = hi << exp | (mi >>> (32 - exp | 0) | 0);
    mi = mi << exp | (lo >>> (32 - exp | 0) | 0);
    lo = lo << exp | (tp >>> (32 - exp | 0) | 0);
  }
  const _bind = _M0FPC14math3mul(ix, lo);
  const _h = _bind._0;
  const _l = _bind._1;
  const phi = (_h >>> 0) + ((_l >>> 0 < _l >>> 0 ? 1 : 0) >>> 0) | 0;
  const _bind$2 = _M0FPC14math3mul(ix, mi);
  const _h$2 = _bind$2._0;
  const _l$2 = _bind$2._1;
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
  const t = Math.fround(x * s);
  r = Math.fround(Math.fround(r * t) + x);
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
  const _bind = _M0FPC14math12trig__reduce(x, Math.fround(201.15625));
  const _x = _bind._0;
  const _q = _bind._1;
  return _M0FPC14math14sin__cos__core(_x, _q);
}
function _M0FPC14math4cosf(x) {
  if (_M0MPC15float5Float7is__nan(x) || _M0MPC15float5Float7is__inf(x)) {
    return _M0FPC15float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return Math.fround(1);
  }
  const _bind = _M0FPC14math12trig__reduce(x, Math.fround(142.90625));
  const _x = _bind._0;
  const _q = _bind._1;
  return _M0FPC14math14sin__cos__core(_x, _q + 1 | 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33new(x, y, z) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(x, y, z);
}
function _M0MP36mizchi6kagura6math3d4Vec34zero() {
  return new _M0TP36mizchi6kagura6math3d4Vec3(0, 0, 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33one() {
  return new _M0TP36mizchi6kagura6math3d4Vec3(1, 1, 1);
}
function _M0MP36mizchi6kagura6math3d4Vec37unit__y() {
  return new _M0TP36mizchi6kagura6math3d4Vec3(0, 1, 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33add(self, other) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.x + other.x, self.y + other.y, self.z + other.z);
}
function _M0MP36mizchi6kagura6math3d4Vec33sub(self, other) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.x - other.x, self.y - other.y, self.z - other.z);
}
function _M0MP36mizchi6kagura6math3d4Vec35scale(self, s) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.x * s, self.y * s, self.z * s);
}
function _M0MP36mizchi6kagura6math3d4Vec33dot(self, other) {
  return self.x * other.x + self.y * other.y + self.z * other.z;
}
function _M0MP36mizchi6kagura6math3d4Vec35cross(self, other) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.y * other.z - self.z * other.y, self.z * other.x - self.x * other.z, self.x * other.y - self.y * other.x);
}
function _M0MP36mizchi6kagura6math3d4Vec315length__squared(self) {
  return self.x * self.x + self.y * self.y + self.z * self.z;
}
function _M0MP36mizchi6kagura6math3d4Vec36length(self) {
  return Math.sqrt(_M0MP36mizchi6kagura6math3d4Vec315length__squared(self));
}
function _M0MP36mizchi6kagura6math3d4Vec39normalize(self) {
  const len = _M0MP36mizchi6kagura6math3d4Vec36length(self);
  return len < 1e-12 ? _M0MP36mizchi6kagura6math3d4Vec34zero() : _M0MP36mizchi6kagura6math3d4Vec35scale(self, 1 / len);
}
function _M0MP36mizchi6kagura6math3d4Vec43new(x, y, z, w) {
  return new _M0TP36mizchi6kagura6math3d4Vec4(x, y, z, w);
}
function _M0MP36mizchi6kagura6math3d4Mat48identity() {
  return new _M0TP36mizchi6kagura6math3d4Mat4([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
}
function _M0MP36mizchi6kagura6math3d4Mat44zero() {
  return new _M0TP36mizchi6kagura6math3d4Mat4([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
}
function _M0MP36mizchi6kagura6math3d4Mat42at(self, row, col) {
  const _tmp = self.elements;
  const _tmp$2 = (Math.imul(col, 4) | 0) + row | 0;
  $bound_check(_tmp, _tmp$2);
  return _tmp[_tmp$2];
}
function _M0MP36mizchi6kagura6math3d4Mat43set(self, row, col, value) {
  const _tmp = self.elements;
  const _tmp$2 = (Math.imul(col, 4) | 0) + row | 0;
  $bound_check(_tmp, _tmp$2);
  _tmp[_tmp$2] = value;
}
function _M0MP36mizchi6kagura6math3d4Mat48multiply(self, other) {
  const result = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _bind = 0;
  const _bind$2 = 4;
  let _tmp = _bind;
  while (true) {
    const col = _tmp;
    if (col < _bind$2) {
      const _bind$3 = 0;
      const _bind$4 = 4;
      let _tmp$2 = _bind$3;
      while (true) {
        const row = _tmp$2;
        if (row < _bind$4) {
          const sum = new _M0TPC13ref3RefGdE(0);
          const _bind$5 = 0;
          const _bind$6 = 4;
          let _tmp$3 = _bind$5;
          while (true) {
            const k = _tmp$3;
            if (k < _bind$6) {
              sum.val = sum.val + _M0MP36mizchi6kagura6math3d4Mat42at(self, row, k) * _M0MP36mizchi6kagura6math3d4Mat42at(other, k, col);
              _tmp$3 = k + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0MP36mizchi6kagura6math3d4Mat43set(result, row, col, sum.val);
          _tmp$2 = row + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = col + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return result;
}
function _M0MP36mizchi6kagura6math3d4Mat49transpose(self) {
  const result = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _bind = 0;
  const _bind$2 = 4;
  let _tmp = _bind;
  while (true) {
    const row = _tmp;
    if (row < _bind$2) {
      const _bind$3 = 0;
      const _bind$4 = 4;
      let _tmp$2 = _bind$3;
      while (true) {
        const col = _tmp$2;
        if (col < _bind$4) {
          _M0MP36mizchi6kagura6math3d4Mat43set(result, row, col, _M0MP36mizchi6kagura6math3d4Mat42at(self, col, row));
          _tmp$2 = col + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = row + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return result;
}
function _M0MP36mizchi6kagura6math3d4Mat47inverse(self) {
  const m = self.elements;
  $bound_check(m, 0);
  const a00 = m[0];
  $bound_check(m, 1);
  const a01 = m[1];
  $bound_check(m, 2);
  const a02 = m[2];
  $bound_check(m, 3);
  const a03 = m[3];
  $bound_check(m, 4);
  const a10 = m[4];
  $bound_check(m, 5);
  const a11 = m[5];
  $bound_check(m, 6);
  const a12 = m[6];
  $bound_check(m, 7);
  const a13 = m[7];
  $bound_check(m, 8);
  const a20 = m[8];
  $bound_check(m, 9);
  const a21 = m[9];
  $bound_check(m, 10);
  const a22 = m[10];
  $bound_check(m, 11);
  const a23 = m[11];
  $bound_check(m, 12);
  const a30 = m[12];
  $bound_check(m, 13);
  const a31 = m[13];
  $bound_check(m, 14);
  const a32 = m[14];
  $bound_check(m, 15);
  const a33 = m[15];
  const b00 = a00 * a11 - a01 * a10;
  const b01 = a00 * a12 - a02 * a10;
  const b02 = a00 * a13 - a03 * a10;
  const b03 = a01 * a12 - a02 * a11;
  const b04 = a01 * a13 - a03 * a11;
  const b05 = a02 * a13 - a03 * a12;
  const b06 = a20 * a31 - a21 * a30;
  const b07 = a20 * a32 - a22 * a30;
  const b08 = a20 * a33 - a23 * a30;
  const b09 = a21 * a32 - a22 * a31;
  const b10 = a21 * a33 - a23 * a31;
  const b11 = a22 * a33 - a23 * a32;
  const det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
  if (Math.abs(det) < 1e-12) {
    return _M0MP36mizchi6kagura6math3d4Mat48identity();
  }
  const inv_det = 1 / det;
  const result = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _tmp = result.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = (a11 * b11 - a12 * b10 + a13 * b09) * inv_det;
  const _tmp$2 = result.elements;
  $bound_check(_tmp$2, 1);
  _tmp$2[1] = (a02 * b10 - a01 * b11 - a03 * b09) * inv_det;
  const _tmp$3 = result.elements;
  $bound_check(_tmp$3, 2);
  _tmp$3[2] = (a31 * b05 - a32 * b04 + a33 * b03) * inv_det;
  const _tmp$4 = result.elements;
  $bound_check(_tmp$4, 3);
  _tmp$4[3] = (a22 * b04 - a21 * b05 - a23 * b03) * inv_det;
  const _tmp$5 = result.elements;
  $bound_check(_tmp$5, 4);
  _tmp$5[4] = (a12 * b08 - a10 * b11 - a13 * b07) * inv_det;
  const _tmp$6 = result.elements;
  $bound_check(_tmp$6, 5);
  _tmp$6[5] = (a00 * b11 - a02 * b08 + a03 * b07) * inv_det;
  const _tmp$7 = result.elements;
  $bound_check(_tmp$7, 6);
  _tmp$7[6] = (a32 * b02 - a30 * b05 - a33 * b01) * inv_det;
  const _tmp$8 = result.elements;
  $bound_check(_tmp$8, 7);
  _tmp$8[7] = (a20 * b05 - a22 * b02 + a23 * b01) * inv_det;
  const _tmp$9 = result.elements;
  $bound_check(_tmp$9, 8);
  _tmp$9[8] = (a10 * b10 - a11 * b08 + a13 * b06) * inv_det;
  const _tmp$10 = result.elements;
  $bound_check(_tmp$10, 9);
  _tmp$10[9] = (a01 * b08 - a00 * b10 - a03 * b06) * inv_det;
  const _tmp$11 = result.elements;
  $bound_check(_tmp$11, 10);
  _tmp$11[10] = (a30 * b04 - a31 * b02 + a33 * b00) * inv_det;
  const _tmp$12 = result.elements;
  $bound_check(_tmp$12, 11);
  _tmp$12[11] = (a21 * b02 - a20 * b04 - a23 * b00) * inv_det;
  const _tmp$13 = result.elements;
  $bound_check(_tmp$13, 12);
  _tmp$13[12] = (a11 * b07 - a10 * b09 - a12 * b06) * inv_det;
  const _tmp$14 = result.elements;
  $bound_check(_tmp$14, 13);
  _tmp$14[13] = (a00 * b09 - a01 * b07 + a02 * b06) * inv_det;
  const _tmp$15 = result.elements;
  $bound_check(_tmp$15, 14);
  _tmp$15[14] = (a31 * b01 - a30 * b03 - a32 * b00) * inv_det;
  const _tmp$16 = result.elements;
  $bound_check(_tmp$16, 15);
  _tmp$16[15] = (a20 * b03 - a21 * b01 + a22 * b00) * inv_det;
  return result;
}
function _M0MP36mizchi6kagura6math3d4Mat411translation(x, y, z) {
  const m = _M0MP36mizchi6kagura6math3d4Mat48identity();
  const _tmp = m.elements;
  $bound_check(_tmp, 12);
  _tmp[12] = x;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 13);
  _tmp$2[13] = y;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 14);
  _tmp$3[14] = z;
  return m;
}
function _M0MP36mizchi6kagura6math3d4Mat47scaling(x, y, z) {
  const m = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _tmp = m.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = x;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 5);
  _tmp$2[5] = y;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 10);
  _tmp$3[10] = z;
  const _tmp$4 = m.elements;
  $bound_check(_tmp$4, 15);
  _tmp$4[15] = 1;
  return m;
}
function _M0MP36mizchi6kagura6math3d4Mat411perspective(fov_y_rad, aspect, near, far) {
  const f = 1 / _M0FPC14math3tan(fov_y_rad / 2);
  const nf = 1 / (near - far);
  const m = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _tmp = m.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = f / aspect;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 5);
  _tmp$2[5] = f;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 10);
  _tmp$3[10] = far * nf;
  const _tmp$4 = m.elements;
  $bound_check(_tmp$4, 11);
  _tmp$4[11] = -1;
  const _tmp$5 = m.elements;
  $bound_check(_tmp$5, 14);
  _tmp$5[14] = near * far * nf;
  return m;
}
function _M0MP36mizchi6kagura6math3d4Mat412orthographic(left, right, bottom, top, near, far) {
  const lr = 1 / (left - right);
  const bt = 1 / (bottom - top);
  const nf = 1 / (near - far);
  const m = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _tmp = m.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = -2 * lr;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 5);
  _tmp$2[5] = -2 * bt;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 10);
  _tmp$3[10] = nf;
  const _tmp$4 = m.elements;
  $bound_check(_tmp$4, 12);
  _tmp$4[12] = (left + right) * lr;
  const _tmp$5 = m.elements;
  $bound_check(_tmp$5, 13);
  _tmp$5[13] = (top + bottom) * bt;
  const _tmp$6 = m.elements;
  $bound_check(_tmp$6, 14);
  _tmp$6[14] = near * nf;
  const _tmp$7 = m.elements;
  $bound_check(_tmp$7, 15);
  _tmp$7[15] = 1;
  return m;
}
function _M0MP36mizchi6kagura6math3d4Mat48look__at(eye, target, up) {
  const f = _M0MP36mizchi6kagura6math3d4Vec39normalize(_M0MP36mizchi6kagura6math3d4Vec33sub(target, eye));
  const s = _M0MP36mizchi6kagura6math3d4Vec39normalize(_M0MP36mizchi6kagura6math3d4Vec35cross(f, up));
  const u = _M0MP36mizchi6kagura6math3d4Vec35cross(s, f);
  const m = _M0MP36mizchi6kagura6math3d4Mat48identity();
  const _tmp = m.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = s.x;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 4);
  _tmp$2[4] = s.y;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 8);
  _tmp$3[8] = s.z;
  const _tmp$4 = m.elements;
  $bound_check(_tmp$4, 1);
  _tmp$4[1] = u.x;
  const _tmp$5 = m.elements;
  $bound_check(_tmp$5, 5);
  _tmp$5[5] = u.y;
  const _tmp$6 = m.elements;
  $bound_check(_tmp$6, 9);
  _tmp$6[9] = u.z;
  const _tmp$7 = m.elements;
  $bound_check(_tmp$7, 2);
  _tmp$7[2] = -f.x;
  const _tmp$8 = m.elements;
  $bound_check(_tmp$8, 6);
  _tmp$8[6] = -f.y;
  const _tmp$9 = m.elements;
  $bound_check(_tmp$9, 10);
  _tmp$9[10] = -f.z;
  const _tmp$10 = m.elements;
  $bound_check(_tmp$10, 12);
  _tmp$10[12] = -_M0MP36mizchi6kagura6math3d4Vec33dot(s, eye);
  const _tmp$11 = m.elements;
  $bound_check(_tmp$11, 13);
  _tmp$11[13] = -_M0MP36mizchi6kagura6math3d4Vec33dot(u, eye);
  const _tmp$12 = m.elements;
  $bound_check(_tmp$12, 14);
  _tmp$12[14] = _M0MP36mizchi6kagura6math3d4Vec33dot(f, eye);
  return m;
}
function _M0MP36mizchi6kagura6math3d10Quaternion8identity() {
  return new _M0TP36mizchi6kagura6math3d10Quaternion(0, 0, 0, 1);
}
function _M0MP36mizchi6kagura6math3d10Quaternion3new(x, y, z, w) {
  return new _M0TP36mizchi6kagura6math3d10Quaternion(x, y, z, w);
}
function _M0MP36mizchi6kagura6math3d10Quaternion8to__mat4(self) {
  const x = self.x;
  const y = self.y;
  const z = self.z;
  const w = self.w;
  const x2 = x + x;
  const y2 = y + y;
  const z2 = z + z;
  const xx = x * x2;
  const xy = x * y2;
  const xz = x * z2;
  const yy = y * y2;
  const yz = y * z2;
  const zz = z * z2;
  const wx = w * x2;
  const wy = w * y2;
  const wz = w * z2;
  const m = _M0MP36mizchi6kagura6math3d4Mat44zero();
  const _tmp = m.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = 1 - yy - zz;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 1);
  _tmp$2[1] = xy + wz;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 2);
  _tmp$3[2] = xz - wy;
  const _tmp$4 = m.elements;
  $bound_check(_tmp$4, 4);
  _tmp$4[4] = xy - wz;
  const _tmp$5 = m.elements;
  $bound_check(_tmp$5, 5);
  _tmp$5[5] = 1 - xx - zz;
  const _tmp$6 = m.elements;
  $bound_check(_tmp$6, 6);
  _tmp$6[6] = yz + wx;
  const _tmp$7 = m.elements;
  $bound_check(_tmp$7, 8);
  _tmp$7[8] = xz + wy;
  const _tmp$8 = m.elements;
  $bound_check(_tmp$8, 9);
  _tmp$8[9] = yz - wx;
  const _tmp$9 = m.elements;
  $bound_check(_tmp$9, 10);
  _tmp$9[10] = 1 - xx - yy;
  const _tmp$10 = m.elements;
  $bound_check(_tmp$10, 15);
  _tmp$10[15] = 1;
  return m;
}
function _M0MP36mizchi6kagura8camera3d8Camera3D16new__perspective(position, target, up, fov_y_rad, aspect, near, far) {
  return new _M0TP36mizchi6kagura8camera3d8Camera3D(position, target, up, fov_y_rad, aspect, near, far, _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective__);
}
function _M0FP36mizchi6kagura8camera3d12clamp__pitch(pitch) {
  const limit = 1.56079632679489655;
  return pitch > limit ? limit : pitch < -limit ? -limit : pitch;
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(target, distance, yaw, pitch, fov_y_rad, aspect, near, far) {
  return new _M0TP36mizchi6kagura8camera3d11OrbitCamera(target, distance, yaw, _M0FP36mizchi6kagura8camera3d12clamp__pitch(pitch), fov_y_rad, aspect, near, far);
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self, delta_yaw, delta_pitch) {
  return new _M0TP36mizchi6kagura8camera3d11OrbitCamera(self.target, self.distance, self.yaw + delta_yaw, _M0FP36mizchi6kagura8camera3d12clamp__pitch(self.pitch + delta_pitch), self.fov_y_rad, self.aspect, self.near, self.far);
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera4zoom(self, delta) {
  const d = self.distance + delta;
  const clamped = d < 0.1 ? 0.1 : d;
  return new _M0TP36mizchi6kagura8camera3d11OrbitCamera(self.target, clamped, self.yaw, self.pitch, self.fov_y_rad, self.aspect, self.near, self.far);
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera8position(self) {
  const cp = _M0FPC14math3cos(self.pitch);
  const sp = _M0FPC14math3sin(self.pitch);
  const cy = _M0FPC14math3cos(self.yaw);
  const sy = _M0FPC14math3sin(self.yaw);
  const offset = _M0MP36mizchi6kagura6math3d4Vec33new(self.distance * cp * sy, self.distance * sp, self.distance * cp * cy);
  return _M0MP36mizchi6kagura6math3d4Vec33add(self.target, offset);
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera12to__camera3d(self) {
  return _M0MP36mizchi6kagura8camera3d8Camera3D16new__perspective(_M0MP36mizchi6kagura8camera3d11OrbitCamera8position(self), self.target, _M0MP36mizchi6kagura6math3d4Vec37unit__y(), self.fov_y_rad, self.aspect, self.near, self.far);
}
function _M0MP36mizchi6kagura8camera3d8Camera3D12view__matrix(self) {
  return _M0MP36mizchi6kagura6math3d4Mat48look__at(self.position, self.target, self.up);
}
function _M0MP36mizchi6kagura8camera3d8Camera3D18projection__matrix(self) {
  let bottom;
  let left;
  let right;
  let top;
  _L: {
    const _bind = self.projection_mode;
    if (_bind.$tag === 0) {
      return _M0MP36mizchi6kagura6math3d4Mat411perspective(self.fov_y_rad, self.aspect, self.near, self.far);
    } else {
      const _Orthographic = _bind;
      const _left = _Orthographic._0;
      const _right = _Orthographic._1;
      const _bottom = _Orthographic._2;
      const _top = _Orthographic._3;
      bottom = _bottom;
      left = _left;
      right = _right;
      top = _top;
      break _L;
    }
  }
  return _M0MP36mizchi6kagura6math3d4Mat412orthographic(left, right, bottom, top, self.near, self.far);
}
function _M0MP36mizchi6kagura8camera3d8Camera3D24view__projection__matrix(self) {
  return _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP36mizchi6kagura8camera3d8Camera3D18projection__matrix(self), _M0MP36mizchi6kagura8camera3d8Camera3D12view__matrix(self));
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
      const _bind = self.backend;
      switch (_bind) {
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
          const _bind = self.backend;
          switch (_bind) {
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
function _M0FP36mizchi6kagura9debugutil14glyph__pattern(ch) {
  _L: {
    _L$2: {
      _L$3: {
        _L$4: {
          _L$5: {
            _L$6: {
              _L$7: {
                _L$8: {
                  _L$9: {
                    _L$10: {
                      switch (ch) {
                        case 0: {
                          break _L$10;
                        }
                        case 48: {
                          break _L$10;
                        }
                        case 1: {
                          break _L$9;
                        }
                        case 49: {
                          break _L$9;
                        }
                        case 2: {
                          break _L$8;
                        }
                        case 50: {
                          break _L$8;
                        }
                        case 3: {
                          break _L$7;
                        }
                        case 51: {
                          break _L$7;
                        }
                        case 4: {
                          break _L$6;
                        }
                        case 52: {
                          break _L$6;
                        }
                        case 5: {
                          break _L$5;
                        }
                        case 53: {
                          break _L$5;
                        }
                        case 6: {
                          break _L$4;
                        }
                        case 54: {
                          break _L$4;
                        }
                        case 7: {
                          break _L$3;
                        }
                        case 55: {
                          break _L$3;
                        }
                        case 8: {
                          break _L$2;
                        }
                        case 56: {
                          break _L$2;
                        }
                        case 9: {
                          break _L;
                        }
                        case 57: {
                          break _L;
                        }
                        case 65: {
                          return [0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1];
                        }
                        case 66: {
                          return [1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0];
                        }
                        case 67: {
                          return [1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1];
                        }
                        case 68: {
                          return [1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0];
                        }
                        case 69: {
                          return [1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1];
                        }
                        case 70: {
                          return [1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0];
                        }
                        case 71: {
                          return [1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1];
                        }
                        case 72: {
                          return [1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1];
                        }
                        case 73: {
                          return [1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1];
                        }
                        case 74: {
                          return [0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1];
                        }
                        case 75: {
                          return [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1];
                        }
                        case 76: {
                          return [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1];
                        }
                        case 77: {
                          return [1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1];
                        }
                        case 78: {
                          return [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1];
                        }
                        case 79: {
                          return [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1];
                        }
                        case 80: {
                          return [1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0];
                        }
                        case 81: {
                          return [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1];
                        }
                        case 82: {
                          return [1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1];
                        }
                        case 83: {
                          return [1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1];
                        }
                        case 84: {
                          return [1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0];
                        }
                        case 85: {
                          return [1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1];
                        }
                        case 86: {
                          return [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0];
                        }
                        case 87: {
                          return [1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1];
                        }
                        case 88: {
                          return [1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1];
                        }
                        case 89: {
                          return [1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0];
                        }
                        case 90: {
                          return [1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1];
                        }
                        case 58: {
                          return [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0];
                        }
                        case 32: {
                          return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                        }
                        case 62: {
                          return [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0];
                        }
                        case 43: {
                          return [0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0];
                        }
                        case 47: {
                          return [0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0];
                        }
                        case 45: {
                          return [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0];
                        }
                        case 37: {
                          return [1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1];
                        }
                        default: {
                          return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                        }
                      }
                    }
                    return [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1];
                  }
                  return [0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1];
                }
                return [1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1];
              }
              return [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1];
            }
            return [1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1];
          }
          return [1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1];
        }
        return [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1];
      }
      return [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1];
    }
    return [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1];
  }
  return [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1];
}
function _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color) {
  return [_M0MPC16double6Double7to__int(color.r * 255), _M0MPC16double6Double7to__int(color.g * 255), _M0MPC16double6Double7to__int(color.b * 255), _M0MPC16double6Double7to__int(color.a * 255)];
}
function _M0FP36mizchi6kagura9debugutil25ndc__rect__fill__vertices(px, py, pw, ph, screen_w, screen_h) {
  const x0 = px / screen_w * 2 - 1;
  const y0 = 1 - py / screen_h * 2;
  const x1 = (px + pw) / screen_w * 2 - 1;
  const y1 = 1 - (py + ph) / screen_h * 2;
  const vertices = [x0, y0, 0, 0, x1, y0, 1, 0, x1, y1, 1, 1, x0, y1, 0, 1];
  const indices = [0, 1, 2, 2, 3, 0];
  return { _0: vertices, _1: indices };
}
function _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(dst, shader, px, py, pw, ph, screen_w, screen_h, color, pipeline_id) {
  let vertices;
  let indices;
  _L: {
    const _bind = _M0FP36mizchi6kagura9debugutil25ndc__rect__fill__vertices(px, py, pw, ph, screen_w, screen_h);
    const _vertices = _bind._0;
    const _indices = _bind._1;
    vertices = _vertices;
    indices = _indices;
    break _L;
  }
  const uniform = _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, _M0MPC16double6Double7to__int(screen_w), _M0MPC16double6Double7to__int(screen_h), 6)], 0, pipeline_id, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), vertices, indices, [], uniform, 1, 0);
}
function _M0FP36mizchi6kagura9debugutil15draw__dot__text(cmds, dst, shader, chars, cx, cy, sw, sh, color, scale) {
  const px_size = 3 * scale;
  const char_w = 3 * px_size;
  const gap = px_size;
  const total_w = (chars.length + 0) * char_w + ((chars.length - 1 | 0) + 0) * gap;
  const char_h = 5 * px_size;
  const start_x = cx - total_w / 2;
  const start_y = cy - char_h / 2;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < chars.length) {
      const pattern = _M0FP36mizchi6kagura9debugutil14glyph__pattern(_M0MPC15array5Array2atGiE(chars, i));
      const ox = start_x + (i + 0) * (char_w + gap);
      let _tmp$2 = 0;
      while (true) {
        const row = _tmp$2;
        if (row < 5) {
          let _tmp$3 = 0;
          while (true) {
            const col = _tmp$3;
            if (col < 3) {
              if (_M0MPC15array5Array2atGiE(pattern, (Math.imul(row, 3) | 0) + col | 0) === 1) {
                const x = ox + (col + 0) * px_size;
                const y = start_y + (row + 0) * px_size;
                _M0MPC15array5Array4pushGzE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(dst, shader, x, y, px_size, px_size, sw, sh, color, 0));
              }
              _tmp$3 = col + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _tmp$2 = row + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura9debugutil12draw__number(cmds, dst, shader, number, ox, oy, sw, sh, color, scale) {
  const digits = [];
  if (number === 0) {
    _M0MPC15array5Array4pushGiE(digits, 0);
  } else {
    const n = new _M0TPC13ref3RefGiE(number);
    while (true) {
      if (n.val > 0) {
        if (10 === 0) {
          $panic();
        }
        _M0MPC15array5Array4pushGiE(digits, n.val % 10 | 0);
        if (10 === 0) {
          $panic();
        }
        n.val = n.val / 10 | 0;
        continue;
      } else {
        break;
      }
    }
    const len = digits.length;
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (2 === 0) {
        $panic();
      }
      if (i < (len / 2 | 0)) {
        const tmp = _M0MPC15array5Array2atGiE(digits, i);
        _M0MPC15array5Array3setGiE(digits, i, _M0MPC15array5Array2atGiE(digits, (len - 1 | 0) - i | 0));
        _M0MPC15array5Array3setGiE(digits, (len - 1 | 0) - i | 0, tmp);
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  _M0FP36mizchi6kagura9debugutil15draw__dot__text(cmds, dst, shader, digits, ox, oy, sw, sh, color, scale);
}
function _M0FP36mizchi6kagura9debugutil16color__from__hex(hex) {
  const r = ((hex >> 16 & 255) + 0) / 255;
  const g = ((hex >> 8 & 255) + 0) / 255;
  const b = ((hex & 255) + 0) / 255;
  return _M0FP36mizchi6kagura3gfx10new__color(r, g, b, 1);
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
  const _bind = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver5begin(graphics, pass);
  if (_bind.$tag === 1) {
    const _ok = _bind;
    _ok._0;
  } else {
    return _bind;
  }
  const _bind$2 = cmds.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const cmd = cmds[_];
      const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(graphics, cmd);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _ok._0;
      } else {
        return _bind$3;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(graphics, true);
}
function _M0MP36mizchi6kagura7light3d16DirectionalLight3new(direction, color, intensity) {
  return new _M0TP36mizchi6kagura7light3d16DirectionalLight(_M0MP36mizchi6kagura6math3d4Vec39normalize(direction), color, intensity);
}
function _M0MP36mizchi6kagura7light3d16DirectionalLight7default() {
  return new _M0TP36mizchi6kagura7light3d16DirectionalLight(_M0MP36mizchi6kagura6math3d4Vec33new(0, -1, 0), _M0MP36mizchi6kagura6math3d4Vec33one(), 1);
}
function _M0MP36mizchi6kagura7light3d12AmbientLight3new(color, intensity) {
  return new _M0TP36mizchi6kagura7light3d12AmbientLight(color, intensity);
}
function _M0MP36mizchi6kagura7light3d12AmbientLight7default() {
  return new _M0TP36mizchi6kagura7light3d12AmbientLight(_M0MP36mizchi6kagura6math3d4Vec33one(), 0.2);
}
function _M0MP36mizchi6kagura7light3d19LightingEnvironment11new_2einner(directional, ambient, point_lights, spot_lights) {
  return new _M0TP36mizchi6kagura7light3d19LightingEnvironment(directional, ambient, point_lights, spot_lights);
}
function _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(directional, ambient, point_lights$46$opt, spot_lights$46$opt) {
  let point_lights;
  if (point_lights$46$opt.$tag === 1) {
    const _Some = point_lights$46$opt;
    point_lights = _Some._0;
  } else {
    point_lights = [];
  }
  let spot_lights;
  if (spot_lights$46$opt.$tag === 1) {
    const _Some = spot_lights$46$opt;
    spot_lights = _Some._0;
  } else {
    spot_lights = [];
  }
  return _M0MP36mizchi6kagura7light3d19LightingEnvironment11new_2einner(directional, ambient, point_lights, spot_lights);
}
function _M0MP36mizchi6kagura7light3d19LightingEnvironment7default() {
  return new _M0TP36mizchi6kagura7light3d19LightingEnvironment(_M0MP36mizchi6kagura7light3d16DirectionalLight7default(), _M0MP36mizchi6kagura7light3d12AmbientLight7default(), [], []);
}
function _M0FP36mizchi6kagura7light3d3f32(v) {
  return _M0FP36mizchi6kagura3gfx21double__to__f32__bits(v);
}
function _M0FP36mizchi6kagura7light3d22light__uniform__dwords(env) {
  const d = env.directional;
  const a = env.ambient;
  return [_M0FP36mizchi6kagura7light3d3f32(d.direction.x), _M0FP36mizchi6kagura7light3d3f32(d.direction.y), _M0FP36mizchi6kagura7light3d3f32(d.direction.z), _M0FP36mizchi6kagura7light3d3f32(0), _M0FP36mizchi6kagura7light3d3f32(d.color.x * d.intensity), _M0FP36mizchi6kagura7light3d3f32(d.color.y * d.intensity), _M0FP36mizchi6kagura7light3d3f32(d.color.z * d.intensity), _M0FP36mizchi6kagura7light3d3f32(d.intensity), _M0FP36mizchi6kagura7light3d3f32(a.color.x * a.intensity), _M0FP36mizchi6kagura7light3d3f32(a.color.y * a.intensity), _M0FP36mizchi6kagura7light3d3f32(a.color.z * a.intensity), _M0FP36mizchi6kagura7light3d3f32(a.intensity)];
}
function _M0FP36mizchi6kagura7light3d31normal__matrix__uniform__dwords(model) {
  const inv = _M0MP36mizchi6kagura6math3d4Mat47inverse(model);
  const inv_t = _M0MP36mizchi6kagura6math3d4Mat49transpose(inv);
  const _tmp = inv_t.elements;
  $bound_check(_tmp, 0);
  const _tmp$2 = _M0FP36mizchi6kagura7light3d3f32(_tmp[0]);
  const _tmp$3 = inv_t.elements;
  $bound_check(_tmp$3, 1);
  const _tmp$4 = _M0FP36mizchi6kagura7light3d3f32(_tmp$3[1]);
  const _tmp$5 = inv_t.elements;
  $bound_check(_tmp$5, 2);
  const _tmp$6 = _M0FP36mizchi6kagura7light3d3f32(_tmp$5[2]);
  const _tmp$7 = _M0FP36mizchi6kagura7light3d3f32(0);
  const _tmp$8 = inv_t.elements;
  $bound_check(_tmp$8, 4);
  const _tmp$9 = _M0FP36mizchi6kagura7light3d3f32(_tmp$8[4]);
  const _tmp$10 = inv_t.elements;
  $bound_check(_tmp$10, 5);
  const _tmp$11 = _M0FP36mizchi6kagura7light3d3f32(_tmp$10[5]);
  const _tmp$12 = inv_t.elements;
  $bound_check(_tmp$12, 6);
  const _tmp$13 = _M0FP36mizchi6kagura7light3d3f32(_tmp$12[6]);
  const _tmp$14 = _M0FP36mizchi6kagura7light3d3f32(0);
  const _tmp$15 = inv_t.elements;
  $bound_check(_tmp$15, 8);
  const _tmp$16 = _M0FP36mizchi6kagura7light3d3f32(_tmp$15[8]);
  const _tmp$17 = inv_t.elements;
  $bound_check(_tmp$17, 9);
  const _tmp$18 = _M0FP36mizchi6kagura7light3d3f32(_tmp$17[9]);
  const _tmp$19 = inv_t.elements;
  $bound_check(_tmp$19, 10);
  return [_tmp$2, _tmp$4, _tmp$6, _tmp$7, _tmp$9, _tmp$11, _tmp$13, _tmp$14, _tmp$16, _tmp$18, _M0FP36mizchi6kagura7light3d3f32(_tmp$19[10]), _M0FP36mizchi6kagura7light3d3f32(0)];
}
function _M0FP36mizchi6kagura6mesh3d12push__vertex(data, px, py, pz, nx, ny, nz, u, v) {
  _M0MPC15array5Array4pushGdE(data, px);
  _M0MPC15array5Array4pushGdE(data, py);
  _M0MPC15array5Array4pushGdE(data, pz);
  _M0MPC15array5Array4pushGdE(data, nx);
  _M0MPC15array5Array4pushGdE(data, ny);
  _M0MPC15array5Array4pushGdE(data, nz);
  _M0MPC15array5Array4pushGdE(data, u);
  _M0MPC15array5Array4pushGdE(data, v);
}
function _M0FP36mizchi6kagura6mesh3d21compute__mesh__bounds(vertex_data) {
  if (_M0FP36mizchi6kagura6mesh3d16vertex3d__stride === 0) {
    $panic();
  }
  const vertex_count = vertex_data.length / _M0FP36mizchi6kagura6mesh3d16vertex3d__stride | 0;
  if (vertex_count === 0) {
    return new _M0TP36mizchi6kagura6mesh3d12MeshBounds3D(0, 0, 0, 0, 0, 0);
  }
  const min_x = new _M0TPC13ref3RefGdE(_M0MPC15array5Array2atGdE(vertex_data, 0));
  const min_y = new _M0TPC13ref3RefGdE(_M0MPC15array5Array2atGdE(vertex_data, 1));
  const min_z = new _M0TPC13ref3RefGdE(_M0MPC15array5Array2atGdE(vertex_data, 2));
  const max_x = new _M0TPC13ref3RefGdE(min_x.val);
  const max_y = new _M0TPC13ref3RefGdE(min_y.val);
  const max_z = new _M0TPC13ref3RefGdE(min_z.val);
  const _bind = 1;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < vertex_count) {
      const base = Math.imul(i, _M0FP36mizchi6kagura6mesh3d16vertex3d__stride) | 0;
      const x = _M0MPC15array5Array2atGdE(vertex_data, base);
      const y = _M0MPC15array5Array2atGdE(vertex_data, base + 1 | 0);
      const z = _M0MPC15array5Array2atGdE(vertex_data, base + 2 | 0);
      if (x < min_x.val) {
        min_x.val = x;
      }
      if (y < min_y.val) {
        min_y.val = y;
      }
      if (z < min_z.val) {
        min_z.val = z;
      }
      if (x > max_x.val) {
        max_x.val = x;
      }
      if (y > max_y.val) {
        max_y.val = y;
      }
      if (z > max_z.val) {
        max_z.val = z;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP36mizchi6kagura6mesh3d12MeshBounds3D(min_x.val, min_y.val, min_z.val, max_x.val, max_y.val, max_z.val);
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(vertex_data, indices) {
  return new _M0TP36mizchi6kagura6mesh3d6Mesh3D(vertex_data, indices, _M0FP36mizchi6kagura6mesh3d21compute__mesh__bounds(vertex_data));
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D13vertex__count(self) {
  if (_M0FP36mizchi6kagura6mesh3d16vertex3d__stride === 0) {
    $panic();
  }
  return self.vertex_data.length / _M0FP36mizchi6kagura6mesh3d16vertex3d__stride | 0;
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D6bounds(self) {
  return self.bounds;
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D13plane_2einner(width, depth, subdivisions) {
  const hw = width / 2;
  const hd = depth / 2;
  const n = subdivisions;
  const data = [];
  const indices = [];
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const row = _tmp;
    if (row <= n) {
      const t = (row + 0) / (n + 0);
      const z = -hd + t * depth;
      const v = t;
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const col = _tmp$2;
        if (col <= n) {
          const s = (col + 0) / (n + 0);
          const x = -hw + s * width;
          const u = s;
          _M0FP36mizchi6kagura6mesh3d12push__vertex(data, x, 0, z, 0, 1, 0, u, v);
          _tmp$2 = col + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = row + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const cols = n + 1 | 0;
  const _bind$2 = 0;
  let _tmp$2 = _bind$2;
  while (true) {
    const row = _tmp$2;
    if (row < n) {
      const _bind$3 = 0;
      let _tmp$3 = _bind$3;
      while (true) {
        const col = _tmp$3;
        if (col < n) {
          const tl = (Math.imul(row, cols) | 0) + col | 0;
          const tr = tl + 1 | 0;
          const bl = tl + cols | 0;
          const br = bl + 1 | 0;
          _M0MPC15array5Array4pushGiE(indices, tl);
          _M0MPC15array5Array4pushGiE(indices, bl);
          _M0MPC15array5Array4pushGiE(indices, tr);
          _M0MPC15array5Array4pushGiE(indices, tr);
          _M0MPC15array5Array4pushGiE(indices, bl);
          _M0MPC15array5Array4pushGiE(indices, br);
          _tmp$3 = col + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$2 = row + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(data, indices);
}
function _M0MP36mizchi6kagura11transform3d11Transform3D16from__components(pos, rot, scale) {
  return new _M0TP36mizchi6kagura11transform3d11Transform3D(pos, rot, scale);
}
function _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(self) {
  const t = _M0MP36mizchi6kagura6math3d4Mat411translation(self.position.x, self.position.y, self.position.z);
  const r = _M0MP36mizchi6kagura6math3d10Quaternion8to__mat4(self.rotation);
  const s = _M0MP36mizchi6kagura6math3d4Mat47scaling(self.scale.x, self.scale.y, self.scale.z);
  return _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP36mizchi6kagura6math3d4Mat48multiply(t, r), s);
}
function _M0FP36mizchi6kagura10skeleton3d28build__skinned__vertex__data(bind_mesh, skin) {
  const src_stride = _M0FP36mizchi6kagura6mesh3d16vertex3d__stride;
  const dst_stride = 16;
  const vertex_count = _M0MP36mizchi6kagura6mesh3d6Mesh3D13vertex__count(bind_mesh);
  const out = _M0MPC15array5Array4makeGdE(Math.imul(vertex_count, dst_stride) | 0, 0);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const v = _tmp;
    if (v < vertex_count) {
      const src_base = Math.imul(v, src_stride) | 0;
      const dst_base = Math.imul(v, dst_stride) | 0;
      _M0MPC15array5Array3setGdE(out, dst_base, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base));
      _M0MPC15array5Array3setGdE(out, dst_base + 1 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 1 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 2 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 2 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 3 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 3 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 4 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 4 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 5 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 5 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 6 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 6 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 7 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 7 | 0));
      const ji_base = Math.imul(v, 4) | 0;
      const has_skin = v < skin.vertex_count && ((ji_base + 3 | 0) < skin.joint_indices.length && (ji_base + 3 | 0) < skin.weights.length);
      if (has_skin) {
        _M0MPC15array5Array3setGdE(out, dst_base + 8 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 9 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 1 | 0) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 1 | 0) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 10 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 2 | 0) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 2 | 0) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 11 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 3 | 0) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 3 | 0) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 12 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base));
        _M0MPC15array5Array3setGdE(out, dst_base + 13 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base + 1 | 0));
        _M0MPC15array5Array3setGdE(out, dst_base + 14 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base + 2 | 0));
        _M0MPC15array5Array3setGdE(out, dst_base + 15 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base + 3 | 0));
      } else {
        _M0MPC15array5Array3setGdE(out, dst_base + 8 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 9 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 10 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 11 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 12 | 0, 1);
        _M0MPC15array5Array3setGdE(out, dst_base + 13 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 14 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 15 | 0, 0);
      }
      _tmp = v + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura6draw3d25mat4__to__uniform__dwords(m) {
  const dwords = [];
  const _bind = 0;
  const _bind$2 = 16;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const _tmp$2 = m.elements;
      $bound_check(_tmp$2, i);
      _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl() {
  return "struct Uniforms {\n  mvp: mat4x4<f32>,\n  model: mat4x4<f32>,\n  normal_col0: vec4<f32>,\n  normal_col1: vec4<f32>,\n  normal_col2: vec4<f32>,\n  light_dir: vec4<f32>,\n  light_color: vec4<f32>,\n  ambient_color: vec4<f32>,\n};\n\n";
}
function _M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl() {
  return "  let normal_mat = mat3x3<f32>(\n    uniforms.normal_col0.xyz,\n    uniforms.normal_col1.xyz,\n    uniforms.normal_col2.xyz,\n  );\n";
}
function _M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl() {
  return "  let normal = normalize(in.world_normal);\n  let light_dir = normalize(-uniforms.light_dir.xyz);\n  let ndotl = max(dot(normal, light_dir), 0.0);\n  let diffuse = uniforms.light_color.xyz * ndotl;\n  let ambient = uniforms.ambient_color.xyz;\n";
}
function _M0FP36mizchi6kagura6draw3d19shader3d__lit__wgsl() {
  return `${_M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl()}@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var tex: texture_2d<f32>;\n@group(0) @binding(2) var tex_sampler: sampler;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) world_normal: vec3<f32>,\n  @location(1) uv: vec2<f32>,\n};\n\n@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n${_M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl()}  out.world_normal = normalize(normal_mat * input.normal);\n  out.uv = input.uv;\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n${_M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl()}  let tex_color = textureSample(tex, tex_sampler, in.uv);\n  let lit_color = tex_color.rgb * (diffuse + ambient);\n  return vec4<f32>(lit_color, tex_color.a);\n}\n`;
}
function _M0FP36mizchi6kagura6draw3d31shader3d__lit__untextured__wgsl() {
  return `${_M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl()}@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) world_normal: vec3<f32>,\n};\n\n@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n${_M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl()}  out.world_normal = normalize(normal_mat * input.normal);\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n${_M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl()}  let lit_color = diffuse + ambient;\n  return vec4<f32>(lit_color, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model, view_projection, lighting) {
  const mvp = _M0MP36mizchi6kagura6math3d4Mat48multiply(view_projection, model);
  const dwords = _M0FP36mizchi6kagura6draw3d25mat4__to__uniform__dwords(mvp);
  const _bind = 0;
  const _bind$2 = 16;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const _tmp$2 = model.elements;
      $bound_check(_tmp$2, i);
      _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const normal_dw = _M0FP36mizchi6kagura7light3d31normal__matrix__uniform__dwords(model);
  const _bind$3 = 0;
  const _bind$4 = normal_dw.length;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < _bind$4) {
      _M0MPC15array5Array4pushGiE(dwords, _M0MPC15array5Array2atGiE(normal_dw, i));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const light_dw = _M0FP36mizchi6kagura7light3d22light__uniform__dwords(lighting);
  const _bind$5 = 0;
  const _bind$6 = light_dw.length;
  let _tmp$3 = _bind$5;
  while (true) {
    const i = _tmp$3;
    if (i < _bind$6) {
      _M0MPC15array5Array4pushGiE(dwords, _M0MPC15array5Array2atGiE(light_dw, i));
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d29new__lit__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh, model_matrix, view_projection, lighting, src_image_ids) {
  const uniform_dwords = _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model_matrix, view_projection, lighting);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, mesh.vertex_data, mesh.indices, src_image_ids, uniform_dwords, 1, 0);
}
function _M0FP36mizchi6kagura6draw3d38new__skinned__lit__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, model_matrix, view_projection, lighting, skinning_matrices, src_image_ids) {
  const dwords = _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model_matrix, view_projection, lighting);
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(skinning_matrices.length + 0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  const bone_count = skinning_matrices.length < _M0FP36mizchi6kagura6draw3d10max__bones ? skinning_matrices.length : _M0FP36mizchi6kagura6draw3d10max__bones;
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < bone_count) {
      const _bind$2 = 0;
      const _bind$3 = 16;
      let _tmp$2 = _bind$2;
      while (true) {
        const j = _tmp$2;
        if (j < _bind$3) {
          const _tmp$3 = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(skinning_matrices, i).elements;
          $bound_check(_tmp$3, j);
          _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$3[j]));
          _tmp$2 = j + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = bone_count;
  while (true) {
    const _i = _tmp$2;
    if (_i < _M0FP36mizchi6kagura6draw3d10max__bones) {
      const _bind$2 = 0;
      const _bind$3 = 16;
      let _tmp$3 = _bind$2;
      while (true) {
        const _j = _tmp$3;
        if (_j < _bind$3) {
          _M0MPC15array5Array4pushGiE(dwords, 0);
          _tmp$3 = _j + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, dwords, 1, 0);
}
function _M0FP36mizchi6kagura6draw3d50new__skinned__lit__mesh__draw__command__from__skin(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh, skin, model_matrix, view_projection, lighting, skinning_matrices, src_image_ids) {
  const packed_vertex_data = _M0FP36mizchi6kagura10skeleton3d28build__skinned__vertex__data(mesh, skin);
  return _M0FP36mizchi6kagura6draw3d38new__skinned__lit__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, packed_vertex_data, mesh.indices, model_matrix, view_projection, lighting, skinning_matrices, src_image_ids);
}
function _M0FP36mizchi6kagura6draw3d20pbr__uniform__dwords(model, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos) {
  const dwords = _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model, view_projection, lighting);
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.x));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.y));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.z));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.w));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(metallic));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(roughness));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.x));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.y));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.z));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.x));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.y));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.z));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d29new__pbr__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh, model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos, src_image_ids) {
  const uniform_dwords = _M0FP36mizchi6kagura6draw3d20pbr__uniform__dwords(model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, mesh.vertex_data, mesh.indices, src_image_ids, uniform_dwords, 1, 0);
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
  const _bind = mixer.voices;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const voice = _bind[_];
      if (_M0IP26mizchi5audio7VoiceIdPB2Eq5equal(voice.id, id)) {
        return voice;
      }
      _tmp = _ + 1 | 0;
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
    const _bind = _M0FP26mizchi5audio11find__voice(mixer, id);
    if (_bind === undefined) {
      return false;
    } else {
      const _Some = _bind;
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
  const _tmp = rb.data;
  $bound_check(_tmp, idx);
  return _tmp[idx];
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
  const _tmp = buf.data;
  const _tmp$2 = (Math.imul(frame, buf.channels) | 0) + channel | 0;
  $bound_check(_tmp, _tmp$2);
  return _tmp[_tmp$2];
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
  const _tmp = state.buffer;
  const _tmp$2 = state.write_pos;
  $bound_check(_tmp, _tmp$2);
  const delayed = _tmp[_tmp$2];
  const _tmp$3 = state.buffer;
  const _tmp$4 = state.write_pos;
  $bound_check(_tmp$3, _tmp$4);
  _tmp$3[_tmp$4] = Math.fround(input + Math.fround(delayed * state.feedback));
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
  const _bind = effects.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const effect = effects[_];
      result.val = _M0FP26mizchi5audio15effect__process(effect, result.val);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return result.val;
}
function _M0FP26mizchi5audio14envelope__tick(env) {
  const _bind = env.phase;
  switch (_bind) {
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
      const t = Math.fround(Math.fround(env.phase_position) / Math.fround(decay_samples));
      env.level = Math.fround(Math.fround(1) + Math.fround(Math.fround(env.config.sustain - Math.fround(1)) * t));
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
      const t$2 = Math.fround(Math.fround(env.phase_position) / Math.fround(release_samples));
      env.level = Math.fround(env.release_start_level * Math.fround(Math.fround(1) - t$2));
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
  const _bind = mixer.voices;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const voice = _bind[_];
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
          const _bind$3 = _M0FP26mizchi5audio10pan__gains(voice.pan);
          const _pan_l = _bind$3._0;
          const _pan_r = _bind$3._1;
          pan_l = _pan_l;
          pan_r = _pan_r;
          break _L$2;
        }
        const voice_gain = voice.gain;
        const ratio = _M0FP26mizchi5audio15resample__ratio(voice.sample_rate, mixer.sample_rate);
        const _bind$3 = 0;
        let _tmp$2 = _bind$3;
        while (true) {
          const f = _tmp$2;
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
                const _bind$4 = voice.envelope;
                if (_bind$4 === undefined) {
                  env_gain = Math.fround(1);
                } else {
                  const _Some = _bind$4;
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
            const _tmp$3 = out_idx + 1 | 0;
            const _tmp$4 = out_idx + 1 | 0;
            $bound_check(output, _tmp$4);
            $bound_check(output, _tmp$3);
            output[_tmp$3] = Math.fround(output[_tmp$4] + sample_r);
            voice.position = Math.fround(voice.position + ratio);
            _tmp$2 = f + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break _L;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (Math.fround(mixer.master_gain !== Math.fround(1))) {
    const _bind$3 = 0;
    const _bind$4 = Math.imul(frames, 2) | 0;
    let _tmp$2 = _bind$3;
    while (true) {
      const i = _tmp$2;
      if (i < _bind$4) {
        $bound_check(output, i);
        $bound_check(output, i);
        output[i] = Math.fround(output[i] * mixer.master_gain);
        _tmp$2 = i + 1 | 0;
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
  const _bind = self.player_map;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const pair = _bind[_];
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
      _tmp = _ + 1 | 0;
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
    const _bind = _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id);
    if (_bind === undefined) {
      return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
    } else {
      const _Some = _bind;
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
    const _bind = _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id);
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  let voice;
  _L$2: {
    const _bind = _M0FP26mizchi5audio11find__voice(self.mixer, vid);
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
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
    const _bind = _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id);
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
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
  const _bind = self.player_map;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const pair = _bind[_];
      let vid;
      _L: {
        const _vid = pair._1;
        vid = _vid;
        break _L;
      }
      let voice;
      _L$2: {
        _L$3: {
          const _bind$3 = _M0FP26mizchi5audio11find__voice(self.mixer, vid);
          if (_bind$3 === undefined) {
          } else {
            const _Some = _bind$3;
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
      _tmp = _ + 1 | 0;
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
    const _bind = self.bgm_outgoing_id;
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
      const _id = _Some;
      id = _id;
      break _L;
    }
  }
  let _try_err;
  _L$2: {
    _L$3: {
      const _bind = _M0IP36mizchi6kagura5audio17MixerAudioContextP36mizchi6kagura5audio12AudioContext4stop(self, id);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _ok._0;
      } else {
        const _err = _bind;
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
        const _bind = self.bgm_player_id;
        if (_bind === undefined) {
          self.bgm_fade_speed = 0;
        } else {
          const _Some = _bind;
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
      const _bind = self.bgm_outgoing_id;
      if (_bind === undefined) {
        self.bgm_outgoing_fade_speed = 0;
        return;
      } else {
        const _Some = _bind;
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
function _M0FP36mizchi6kagura6engine17invoke__on__start(canvas, title) {
  let hooks;
  _L: {
    const _bind = _M0FP36mizchi6kagura6engine16lifecycle__hooks.val;
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
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
    const _bind = _M0FP36mizchi6kagura6engine16lifecycle__hooks.val;
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
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
      const _bind = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform15SurfaceProvider16current__surface(platform);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        surface = _ok._0;
      } else {
        const _err = _bind;
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
      const _bind = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver10initialize(platform, _M0FP36mizchi6kagura8platform28new__window__options_2einner(title, width, height, false, true, true));
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _ok._0;
      } else {
        const _err = _bind;
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
      const _bind = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10initialize(graphics);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _ok._0;
      } else {
        const _err = _bind;
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
      const _bind = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(graphics, width, height);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        dst = _ok._0;
      } else {
        const _err = _bind;
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
      const _bind = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver11new__shader(graphics, shader_source);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        shader = _ok._0;
      } else {
        const _err = _bind;
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
          const _bind = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(graphics, new_w, new_h);
          if (_bind.$tag === 1) {
            const _ok = _bind;
            _ok._0;
          } else {
            const _err = _bind;
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
      let _tmp;
      let _try_err$7;
      _L$7: {
        _L$8: {
          const _bind = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(graphics, new_w, new_h);
          if (_bind.$tag === 1) {
            const _ok = _bind;
            _tmp = _ok._0;
          } else {
            const _err = _bind;
            _try_err$7 = _err._0;
            break _L$8;
          }
          break _L$7;
        }
        const e = _try_err$7;
        _M0FPB7printlnGsE(`[engine] graphics.new_image (resize) failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
        _tmp = _M0FP36mizchi6kagura3gfx18new__image__handle(ctx.dst.id, new_w, new_h);
      }
      ctx.dst = _tmp;
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
        const _bind = _M0FP36mizchi6kagura9debugutil16render__commandsGRP36mizchi6kagura3gfx18StubGraphicsDriverE(graphics, cmds, undefined, -1);
        if (_bind.$tag === 1) {
          const _ok = _bind;
          _ok._0;
        } else {
          const _err = _bind;
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
function _M0MP36mizchi6kagura7scene3d8Material11new_2einner(color, src_image_id, metallic, roughness, emissive) {
  return new _M0TP36mizchi6kagura7scene3d8Material(color, src_image_id, metallic, roughness, emissive);
}
function _M0MP36mizchi6kagura7scene3d8Material3new(color$46$opt, src_image_id$46$opt, metallic$46$opt, roughness$46$opt, emissive$46$opt) {
  let color;
  if (color$46$opt === undefined) {
    color = _M0MP36mizchi6kagura6math3d4Vec43new(1, 1, 1, 1);
  } else {
    const _Some = color$46$opt;
    color = _Some;
  }
  let src_image_id;
  if (src_image_id$46$opt === undefined) {
    src_image_id = -1;
  } else {
    const _Some = src_image_id$46$opt;
    src_image_id = _Some;
  }
  let metallic;
  if (metallic$46$opt.$tag === 1) {
    const _Some = metallic$46$opt;
    metallic = _Some._0;
  } else {
    metallic = 0;
  }
  let roughness;
  if (roughness$46$opt.$tag === 1) {
    const _Some = roughness$46$opt;
    roughness = _Some._0;
  } else {
    roughness = 0.5;
  }
  let emissive;
  if (emissive$46$opt === undefined) {
    emissive = _M0MP36mizchi6kagura6math3d4Vec33new(0, 0, 0);
  } else {
    const _Some = emissive$46$opt;
    emissive = _Some;
  }
  return _M0MP36mizchi6kagura7scene3d8Material11new_2einner(color, src_image_id, metallic, roughness, emissive);
}
function _M0FP36mizchi6kagura7scene3d19compute__mesh__aabb(mesh) {
  const bounds = _M0MP36mizchi6kagura6mesh3d6Mesh3D6bounds(mesh);
  return { _0: bounds.min_x, _1: bounds.min_y, _2: bounds.min_z, _3: bounds.max_x, _4: bounds.max_y, _5: bounds.max_z };
}
function _M0FP36mizchi6kagura7scene3d19frustum__cull__aabb(frustum, min_x, min_y, min_z, max_x, max_y, max_z) {
  const _bind = 0;
  const _bind$2 = 6;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const _tmp$2 = frustum.planes;
      $bound_check(_tmp$2, i);
      const p = _tmp$2[i];
      const px = p.nx >= 0 ? max_x : min_x;
      const py = p.ny >= 0 ? max_y : min_y;
      const pz = p.nz >= 0 ? max_z : min_z;
      if (p.nx * px + p.ny * py + p.nz * pz + p.d < 0) {
        return true;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP36mizchi6kagura7scene3d15transform__aabb(min_x, min_y, min_z, max_x, max_y, max_z, model) {
  const e = model.elements;
  $bound_check(e, 12);
  const wmin_x = new _M0TPC13ref3RefGdE(e[12]);
  $bound_check(e, 13);
  const wmin_y = new _M0TPC13ref3RefGdE(e[13]);
  $bound_check(e, 14);
  const wmin_z = new _M0TPC13ref3RefGdE(e[14]);
  const wmax_x = new _M0TPC13ref3RefGdE(wmin_x.val);
  const wmax_y = new _M0TPC13ref3RefGdE(wmin_y.val);
  const wmax_z = new _M0TPC13ref3RefGdE(wmin_z.val);
  const mins = [min_x, min_y, min_z];
  const maxs = [max_x, max_y, max_z];
  const _bind = 0;
  const _bind$2 = 3;
  let _tmp = _bind;
  while (true) {
    const j = _tmp;
    if (j < _bind$2) {
      const _tmp$2 = Math.imul(j, 4) | 0;
      $bound_check(e, _tmp$2);
      const a0 = e[_tmp$2] * _M0MPC15array5Array2atGdE(mins, j);
      const _tmp$3 = Math.imul(j, 4) | 0;
      $bound_check(e, _tmp$3);
      const b0 = e[_tmp$3] * _M0MPC15array5Array2atGdE(maxs, j);
      if (a0 < b0) {
        wmin_x.val = wmin_x.val + a0;
        wmax_x.val = wmax_x.val + b0;
      } else {
        wmin_x.val = wmin_x.val + b0;
        wmax_x.val = wmax_x.val + a0;
      }
      const _tmp$4 = (Math.imul(j, 4) | 0) + 1 | 0;
      $bound_check(e, _tmp$4);
      const a1 = e[_tmp$4] * _M0MPC15array5Array2atGdE(mins, j);
      const _tmp$5 = (Math.imul(j, 4) | 0) + 1 | 0;
      $bound_check(e, _tmp$5);
      const b1 = e[_tmp$5] * _M0MPC15array5Array2atGdE(maxs, j);
      if (a1 < b1) {
        wmin_y.val = wmin_y.val + a1;
        wmax_y.val = wmax_y.val + b1;
      } else {
        wmin_y.val = wmin_y.val + b1;
        wmax_y.val = wmax_y.val + a1;
      }
      const _tmp$6 = (Math.imul(j, 4) | 0) + 2 | 0;
      $bound_check(e, _tmp$6);
      const a2 = e[_tmp$6] * _M0MPC15array5Array2atGdE(mins, j);
      const _tmp$7 = (Math.imul(j, 4) | 0) + 2 | 0;
      $bound_check(e, _tmp$7);
      const b2 = e[_tmp$7] * _M0MPC15array5Array2atGdE(maxs, j);
      if (a2 < b2) {
        wmin_z.val = wmin_z.val + a2;
        wmax_z.val = wmax_z.val + b2;
      } else {
        wmin_z.val = wmin_z.val + b2;
        wmax_z.val = wmax_z.val + a2;
      }
      _tmp = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { _0: wmin_x.val, _1: wmin_y.val, _2: wmin_z.val, _3: wmax_x.val, _4: wmax_y.val, _5: wmax_z.val };
}
function _M0FP36mizchi6kagura7scene3d27render__object__gpu_2einner(mesh, model, color, material, skinning, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera_pos) {
  let omax_y;
  let omin_z;
  let omin_x;
  let omin_y;
  let omax_x;
  let omax_z;
  _L: {
    const _bind = _M0FP36mizchi6kagura7scene3d19compute__mesh__aabb(mesh);
    const _omin_x = _bind._0;
    const _omin_y = _bind._1;
    const _omin_z = _bind._2;
    const _omax_x = _bind._3;
    const _omax_y = _bind._4;
    const _omax_z = _bind._5;
    omax_y = _omax_y;
    omin_z = _omin_z;
    omin_x = _omin_x;
    omin_y = _omin_y;
    omax_x = _omax_x;
    omax_z = _omax_z;
    break _L;
  }
  let wmax_y;
  let wmin_z;
  let wmin_x;
  let wmin_y;
  let wmax_x;
  let wmax_z;
  _L$2: {
    const _bind = _M0FP36mizchi6kagura7scene3d15transform__aabb(omin_x, omin_y, omin_z, omax_x, omax_y, omax_z, model);
    const _wmin_x = _bind._0;
    const _wmin_y = _bind._1;
    const _wmin_z = _bind._2;
    const _wmax_x = _bind._3;
    const _wmax_y = _bind._4;
    const _wmax_z = _bind._5;
    wmax_y = _wmax_y;
    wmin_z = _wmin_z;
    wmin_x = _wmin_x;
    wmin_y = _wmin_y;
    wmax_x = _wmax_x;
    wmax_z = _wmax_z;
    break _L$2;
  }
  if (_M0FP36mizchi6kagura7scene3d19frustum__cull__aabb(frustum, wmin_x, wmin_y, wmin_z, wmax_x, wmax_y, wmax_z)) {
    return undefined;
  }
  let roughness;
  let src_image_id;
  let col;
  let metallic;
  let emissive;
  _L$3: {
    let _bind;
    let mat;
    _L$4: {
      _L$5: {
        if (material === undefined) {
          _bind = { _0: color, _1: -1, _2: 0, _3: 0.5, _4: _M0MP36mizchi6kagura6math3d4Vec33new(0, 0, 0) };
        } else {
          const _Some = material;
          const _mat = _Some;
          mat = _mat;
          break _L$5;
        }
        break _L$4;
      }
      _bind = { _0: mat.color, _1: mat.src_image_id, _2: mat.metallic, _3: mat.roughness, _4: mat.emissive };
    }
    const _col = _bind._0;
    const _src_image_id = _bind._1;
    const _metallic = _bind._2;
    const _roughness = _bind._3;
    const _emissive = _bind._4;
    roughness = _roughness;
    src_image_id = _src_image_id;
    col = _col;
    metallic = _metallic;
    emissive = _emissive;
    break _L$3;
  }
  const has_texture = src_image_id >= 0;
  const is_pbr = metallic > 0 || roughness !== 0.5;
  const tinted_lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(lighting.directional.direction, _M0MP36mizchi6kagura6math3d4Vec33new(lighting.directional.color.x * col.x, lighting.directional.color.y * col.y, lighting.directional.color.z * col.z), lighting.directional.intensity), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(lighting.ambient.color.x * col.x, lighting.ambient.color.y * col.y, lighting.ambient.color.z * col.z), lighting.ambient.intensity), _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None__, _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None__);
  const index_count = mesh.indices.length;
  const dst_region = _M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, screen_w, screen_h, index_count);
  const src_image_ids = has_texture ? [src_image_id] : [];
  if (is_pbr) {
    let shader;
    if (has_texture) {
      if (shader3d_pbr_textured === undefined) {
        if (shader3d_pbr === undefined) {
          shader = shader3d;
        } else {
          const _Some = shader3d_pbr;
          const _s = _Some;
          shader = _s;
        }
      } else {
        const _Some = shader3d_pbr_textured;
        const _s = _Some;
        shader = _s;
      }
    } else {
      if (shader3d_pbr === undefined) {
        shader = shader3d;
      } else {
        const _Some = shader3d_pbr;
        const _s = _Some;
        shader = _s;
      }
    }
    const cmd = _M0FP36mizchi6kagura6draw3d29new__pbr__mesh__draw__command(dst, shader, dst_region, 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), mesh, model, vp, tinted_lighting, metallic, roughness, col, emissive, camera_pos, src_image_ids);
    _M0MPC15array5Array4pushGzE(cmds, cmd);
    return;
  } else {
    _L$4: {
      let sk;
      let skinned_shader;
      _L$5: {
        if (skinning === undefined) {
          break _L$4;
        } else {
          const _Some = skinning;
          const _sk = _Some;
          if (shader3d_skinned === undefined) {
            break _L$4;
          } else {
            const _Some$2 = shader3d_skinned;
            const _skinned_shader = _Some$2;
            sk = _sk;
            skinned_shader = _skinned_shader;
            break _L$5;
          }
        }
      }
      let cmd;
      let packed_vertex_data;
      _L$6: {
        _L$7: {
          const _bind = sk.packed_vertex_data;
          if (_bind.$tag === 1) {
            const _Some = _bind;
            const _packed_vertex_data = _Some._0;
            packed_vertex_data = _packed_vertex_data;
            break _L$7;
          } else {
            cmd = _M0FP36mizchi6kagura6draw3d50new__skinned__lit__mesh__draw__command__from__skin(dst, skinned_shader, dst_region, 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), mesh, sk.skin, model, vp, tinted_lighting, sk.skinning_matrices, src_image_ids);
          }
          break _L$6;
        }
        cmd = _M0FP36mizchi6kagura6draw3d38new__skinned__lit__mesh__draw__command(dst, skinned_shader, dst_region, 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), packed_vertex_data, mesh.indices, model, vp, tinted_lighting, sk.skinning_matrices, src_image_ids);
      }
      _M0MPC15array5Array4pushGzE(cmds, cmd);
      return;
    }
    let shader;
    if (has_texture) {
      if (shader3d_textured === undefined) {
        shader = shader3d;
      } else {
        const _Some = shader3d_textured;
        const _s = _Some;
        shader = _s;
      }
    } else {
      shader = shader3d;
    }
    const cmd = _M0FP36mizchi6kagura6draw3d29new__lit__mesh__draw__command(dst, shader, dst_region, 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), mesh, model, vp, tinted_lighting, src_image_ids);
    _M0MPC15array5Array4pushGzE(cmds, cmd);
    return;
  }
}
function _M0FP36mizchi6kagura7scene3d27traverse__node__gpu_2einner(graph, node_id, parent_world, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera_pos) {
  let node;
  _L: {
    const _bind = _M0MPB3Map3getGiRP36mizchi6kagura7scene3d9SceneNodeE(graph.nodes, node_id);
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
      const _node = _Some;
      node = _node;
      break _L;
    }
  }
  const world = _M0MP36mizchi6kagura6math3d4Mat48multiply(parent_world, _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(node.transform));
  let mesh;
  _L$2: {
    _L$3: {
      const _bind = node.mesh;
      if (_bind === undefined) {
      } else {
        const _Some = _bind;
        const _mesh = _Some;
        mesh = _mesh;
        break _L$3;
      }
      break _L$2;
    }
    _M0FP36mizchi6kagura7scene3d27render__object__gpu_2einner(mesh, world, node.color, node.material, node.skinning, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera_pos);
  }
  const _bind = 0;
  const _bind$2 = node.children.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      _M0FP36mizchi6kagura7scene3d27traverse__node__gpu_2einner(graph, _M0MPC15array5Array2atGiE(node.children, i), world, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera_pos);
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura7scene3d16normalize__plane(a, b, c, d) {
  const len = Math.sqrt(a * a + b * b + c * c);
  if (len < 1e-10) {
    return new _M0TP36mizchi6kagura7scene3d5Plane(0, 0, 0, 0);
  } else {
    const inv = 1 / len;
    return new _M0TP36mizchi6kagura7scene3d5Plane(a * inv, b * inv, c * inv, d * inv);
  }
}
function _M0MP36mizchi6kagura7scene3d7Frustum8from__vp(vp) {
  const e = vp.elements;
  $bound_check(e, 0);
  const r0x = e[0];
  $bound_check(e, 4);
  const r0y = e[4];
  $bound_check(e, 8);
  const r0z = e[8];
  $bound_check(e, 12);
  const r0w = e[12];
  $bound_check(e, 1);
  const r1x = e[1];
  $bound_check(e, 5);
  const r1y = e[5];
  $bound_check(e, 9);
  const r1z = e[9];
  $bound_check(e, 13);
  const r1w = e[13];
  $bound_check(e, 2);
  const r2x = e[2];
  $bound_check(e, 6);
  const r2y = e[6];
  $bound_check(e, 10);
  const r2z = e[10];
  $bound_check(e, 14);
  const r2w = e[14];
  $bound_check(e, 3);
  const r3x = e[3];
  $bound_check(e, 7);
  const r3y = e[7];
  $bound_check(e, 11);
  const r3z = e[11];
  $bound_check(e, 15);
  const r3w = e[15];
  const planes = $make_array_len_and_init(6, new _M0TP36mizchi6kagura7scene3d5Plane(0, 0, 0, 0));
  $bound_check(planes, 0);
  planes[0] = _M0FP36mizchi6kagura7scene3d16normalize__plane(r3x + r0x, r3y + r0y, r3z + r0z, r3w + r0w);
  $bound_check(planes, 1);
  planes[1] = _M0FP36mizchi6kagura7scene3d16normalize__plane(r3x - r0x, r3y - r0y, r3z - r0z, r3w - r0w);
  $bound_check(planes, 2);
  planes[2] = _M0FP36mizchi6kagura7scene3d16normalize__plane(r3x + r1x, r3y + r1y, r3z + r1z, r3w + r1w);
  $bound_check(planes, 3);
  planes[3] = _M0FP36mizchi6kagura7scene3d16normalize__plane(r3x - r1x, r3y - r1y, r3z - r1z, r3w - r1w);
  $bound_check(planes, 4);
  planes[4] = _M0FP36mizchi6kagura7scene3d16normalize__plane(r3x + r2x, r3y + r2y, r3z + r2z, r3w + r2w);
  $bound_check(planes, 5);
  planes[5] = _M0FP36mizchi6kagura7scene3d16normalize__plane(r3x - r2x, r3y - r2y, r3z - r2z, r3w - r2w);
  return new _M0TP36mizchi6kagura7scene3d7Frustum(planes);
}
function _M0FP36mizchi6kagura7scene3d35render__scene3d__graph__gpu_2einner(graph, camera, lighting, dst, shader3d, screen_w, screen_h, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned) {
  const vp = _M0MP36mizchi6kagura8camera3d8Camera3D24view__projection__matrix(camera);
  const frustum = _M0MP36mizchi6kagura7scene3d7Frustum8from__vp(vp);
  const cmds = [];
  const identity = _M0MP36mizchi6kagura6math3d4Mat48identity();
  const _bind = 0;
  const _bind$2 = graph.roots.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      _M0FP36mizchi6kagura7scene3d27traverse__node__gpu_2einner(graph, _M0MPC15array5Array2atGiE(graph.roots, i), identity, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera.position);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return cmds;
}
function _M0FP36mizchi6kagura7scene3d27render__scene3d__graph__gpu(graph, camera, lighting$46$opt, dst, shader3d, screen_w, screen_h, shader3d_textured$46$opt, shader3d_pbr$46$opt, shader3d_pbr_textured$46$opt, shader3d_skinned$46$opt) {
  let lighting;
  if (lighting$46$opt === undefined) {
    lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment7default();
  } else {
    const _Some = lighting$46$opt;
    lighting = _Some;
  }
  let shader3d_textured;
  if (shader3d_textured$46$opt.$tag === 1) {
    const _Some = shader3d_textured$46$opt;
    shader3d_textured = _Some._0;
  } else {
    shader3d_textured = undefined;
  }
  let shader3d_pbr;
  if (shader3d_pbr$46$opt.$tag === 1) {
    const _Some = shader3d_pbr$46$opt;
    shader3d_pbr = _Some._0;
  } else {
    shader3d_pbr = undefined;
  }
  let shader3d_pbr_textured;
  if (shader3d_pbr_textured$46$opt.$tag === 1) {
    const _Some = shader3d_pbr_textured$46$opt;
    shader3d_pbr_textured = _Some._0;
  } else {
    shader3d_pbr_textured = undefined;
  }
  let shader3d_skinned;
  if (shader3d_skinned$46$opt.$tag === 1) {
    const _Some = shader3d_skinned$46$opt;
    shader3d_skinned = _Some._0;
  } else {
    shader3d_skinned = undefined;
  }
  return _M0FP36mizchi6kagura7scene3d35render__scene3d__graph__gpu_2einner(graph, camera, lighting, dst, shader3d, screen_w, screen_h, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned);
}
function _M0MP36mizchi6kagura7scene3d10SceneGraph3new() {
  const _bind = [];
  return new _M0TP36mizchi6kagura7scene3d10SceneGraph(_M0MPB3Map11from__arrayGiRP36mizchi6kagura7scene3d9SceneNodeE(new _M0TPB9ArrayViewGUiRP36mizchi6kagura7scene3d9SceneNodeEE(_bind, 0, 0)), [], 0);
}
function _M0MP36mizchi6kagura7scene3d10SceneGraph9add__node(self, node) {
  const id = self.next_id;
  self.next_id = self.next_id + 1 | 0;
  _M0MPB3Map3setGiRP36mizchi6kagura7scene3d9SceneNodeE(self.nodes, id, node);
  _M0MPC15array5Array4pushGiE(self.roots, id);
  return id;
}
function _M0MP36mizchi6kagura7scene3d10SceneGraph10add__child(self, parent_id, node) {
  const id = self.next_id;
  self.next_id = self.next_id + 1 | 0;
  _M0MPB3Map3setGiRP36mizchi6kagura7scene3d9SceneNodeE(self.nodes, id, node);
  let parent;
  _L: {
    _L$2: {
      const _bind = _M0MPB3Map3getGiRP36mizchi6kagura7scene3d9SceneNodeE(self.nodes, parent_id);
      if (_bind === undefined) {
      } else {
        const _Some = _bind;
        const _parent = _Some;
        parent = _parent;
        break _L$2;
      }
      break _L;
    }
    _M0MPC15array5Array4pushGiE(parent.children, id);
  }
  return id;
}
function _M0FP36mizchi6kagura7scene3d19scene__node_2einner(mesh, position, rotation, scale, color, material, skinning) {
  return new _M0TP36mizchi6kagura7scene3d9SceneNode(_M0MP36mizchi6kagura11transform3d11Transform3D16from__components(position, rotation, scale), mesh, color, material, skinning, []);
}
function _M0FP36mizchi6kagura7scene3d11scene__node(mesh$46$opt, position$46$opt, rotation$46$opt, scale$46$opt, color$46$opt, material$46$opt, skinning$46$opt) {
  let mesh;
  if (mesh$46$opt.$tag === 1) {
    const _Some = mesh$46$opt;
    mesh = _Some._0;
  } else {
    mesh = undefined;
  }
  let position;
  if (position$46$opt === undefined) {
    position = _M0MP36mizchi6kagura6math3d4Vec34zero();
  } else {
    const _Some = position$46$opt;
    position = _Some;
  }
  let rotation;
  if (rotation$46$opt === undefined) {
    rotation = _M0MP36mizchi6kagura6math3d10Quaternion8identity();
  } else {
    const _Some = rotation$46$opt;
    rotation = _Some;
  }
  let scale;
  if (scale$46$opt === undefined) {
    scale = _M0MP36mizchi6kagura6math3d4Vec33one();
  } else {
    const _Some = scale$46$opt;
    scale = _Some;
  }
  let color;
  if (color$46$opt === undefined) {
    color = _M0MP36mizchi6kagura6math3d4Vec43new(1, 1, 1, 1);
  } else {
    const _Some = color$46$opt;
    color = _Some;
  }
  let material;
  if (material$46$opt.$tag === 1) {
    const _Some = material$46$opt;
    material = _Some._0;
  } else {
    material = undefined;
  }
  let skinning;
  if (skinning$46$opt.$tag === 1) {
    const _Some = skinning$46$opt;
    skinning = _Some._0;
  } else {
    skinning = undefined;
  }
  return _M0FP36mizchi6kagura7scene3d19scene__node_2einner(mesh, position, rotation, scale, color, material, skinning);
}
function _M0FP36mizchi6kagura4gltf16component__count(type_) {
  switch (type_) {
    case "SCALAR": {
      return 1;
    }
    case "VEC2": {
      return 2;
    }
    case "VEC3": {
      return 3;
    }
    case "VEC4": {
      return 4;
    }
    default: {
      return 1;
    }
  }
}
function _M0FP36mizchi6kagura4gltf4pow2(exp) {
  if (exp >= 0) {
    const result = new _M0TPC13ref3RefGdE(1);
    const _bind = 0;
    let _tmp = _bind;
    while (true) {
      const _i = _tmp;
      if (_i < exp) {
        result.val = result.val * 2;
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return result.val;
  } else {
    const result = new _M0TPC13ref3RefGdE(1);
    const _bind = 0;
    const _bind$2 = -exp | 0;
    let _tmp = _bind;
    while (true) {
      const _i = _tmp;
      if (_i < _bind$2) {
        result.val = result.val / 2;
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return result.val;
  }
}
function _M0FP36mizchi6kagura4gltf13read__u32__le(buf, offset) {
  $bound_check(buf, offset);
  const _tmp = buf[offset];
  const _tmp$2 = offset + 1 | 0;
  $bound_check(buf, _tmp$2);
  const _tmp$3 = _tmp | buf[_tmp$2] << 8;
  const _tmp$4 = offset + 2 | 0;
  $bound_check(buf, _tmp$4);
  const _tmp$5 = _tmp$3 | buf[_tmp$4] << 16;
  const _tmp$6 = offset + 3 | 0;
  $bound_check(buf, _tmp$6);
  return _tmp$5 | buf[_tmp$6] << 24;
}
function _M0FP36mizchi6kagura4gltf13read__f32__le(buf, offset) {
  const bits = _M0FP36mizchi6kagura4gltf13read__u32__le(buf, offset);
  const sign = bits >> 31 !== 0 ? -1 : 1;
  const exponent = bits >> 23 & 255;
  const mantissa = bits & 8388607;
  if (exponent === 0 && mantissa === 0) {
    return sign * 0;
  }
  if (exponent === 255) {
    if (mantissa === 0) {
      return sign * (1 / 0);
    }
    return 0 / 0;
  }
  const e = exponent - 127 | 0;
  const m = 1 + (mantissa + 0) / 8388608;
  return sign * m * _M0FP36mizchi6kagura4gltf4pow2(e);
}
function _M0FP36mizchi6kagura4gltf22read__accessor__floats(doc, accessor_index, buffers) {
  if (accessor_index < 0 || accessor_index >= doc.accessors.length) {
    return new _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidAccessor(`index out of range: ${_M0MPC13int3Int18to__string_2einner(accessor_index, 10)}`));
  }
  const acc = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.accessors, accessor_index);
  if (acc.buffer_view < 0 || acc.buffer_view >= doc.buffer_views.length) {
    return new _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error54mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidBufferView(`index out of range: ${_M0MPC13int3Int18to__string_2einner(acc.buffer_view, 10)}`));
  }
  const bv = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.buffer_views, acc.buffer_view);
  if (bv.buffer < 0 || bv.buffer >= buffers.length) {
    return new _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eBufferOutOfRange(bv.buffer));
  }
  const buf = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(buffers, bv.buffer);
  const comp_count = _M0FP36mizchi6kagura4gltf16component__count(acc.type_);
  const total = Math.imul(acc.count, comp_count) | 0;
  const result = _M0MPC15array5Array4makeGdE(total, 0);
  const base_offset = bv.byte_offset + acc.byte_offset | 0;
  const default_stride = Math.imul(comp_count, 4) | 0;
  const stride = bv.byte_stride > 0 ? bv.byte_stride : default_stride;
  const _bind = acc.component_type;
  if (_bind === 5126) {
    const _bind$2 = 0;
    const _bind$3 = acc.count;
    let _tmp = _bind$2;
    while (true) {
      const i = _tmp;
      if (i < _bind$3) {
        const elem_offset = base_offset + (Math.imul(i, stride) | 0) | 0;
        const _bind$4 = 0;
        let _tmp$2 = _bind$4;
        while (true) {
          const j = _tmp$2;
          if (j < comp_count) {
            _M0MPC15array5Array3setGdE(result, (Math.imul(i, comp_count) | 0) + j | 0, _M0FP36mizchi6kagura4gltf13read__f32__le(buf, elem_offset + (Math.imul(j, 4) | 0) | 0));
            _tmp$2 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  } else {
    return new _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error61mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedComponentType(acc.component_type));
  }
  return new _M0DTPC16result6ResultGRPB5ArrayGdERP36mizchi6kagura4gltf9GltfErrorE2Ok(result);
}
function _M0FP36mizchi6kagura4gltf13read__u16__le(buf, offset) {
  $bound_check(buf, offset);
  const _tmp = buf[offset];
  const _tmp$2 = offset + 1 | 0;
  $bound_check(buf, _tmp$2);
  return _tmp | buf[_tmp$2] << 8;
}
function _M0FP36mizchi6kagura4gltf22compute__flat__normals(vertex_data, indices) {
  if (3 === 0) {
    $panic();
  }
  const tri_count = indices.length / 3 | 0;
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const t = _tmp;
    if (t < tri_count) {
      const i0 = _M0MPC15array5Array2atGiE(indices, Math.imul(t, 3) | 0);
      const i1 = _M0MPC15array5Array2atGiE(indices, (Math.imul(t, 3) | 0) + 1 | 0);
      const i2 = _M0MPC15array5Array2atGiE(indices, (Math.imul(t, 3) | 0) + 2 | 0);
      const p0x = _M0MPC15array5Array2atGdE(vertex_data, Math.imul(i0, 8) | 0);
      const p0y = _M0MPC15array5Array2atGdE(vertex_data, (Math.imul(i0, 8) | 0) + 1 | 0);
      const p0z = _M0MPC15array5Array2atGdE(vertex_data, (Math.imul(i0, 8) | 0) + 2 | 0);
      const p1x = _M0MPC15array5Array2atGdE(vertex_data, Math.imul(i1, 8) | 0);
      const p1y = _M0MPC15array5Array2atGdE(vertex_data, (Math.imul(i1, 8) | 0) + 1 | 0);
      const p1z = _M0MPC15array5Array2atGdE(vertex_data, (Math.imul(i1, 8) | 0) + 2 | 0);
      const p2x = _M0MPC15array5Array2atGdE(vertex_data, Math.imul(i2, 8) | 0);
      const p2y = _M0MPC15array5Array2atGdE(vertex_data, (Math.imul(i2, 8) | 0) + 1 | 0);
      const p2z = _M0MPC15array5Array2atGdE(vertex_data, (Math.imul(i2, 8) | 0) + 2 | 0);
      const e1x = p1x - p0x;
      const e1y = p1y - p0y;
      const e1z = p1z - p0z;
      const e2x = p2x - p0x;
      const e2y = p2y - p0y;
      const e2z = p2z - p0z;
      const nx = new _M0TPC13ref3RefGdE(e1y * e2z - e1z * e2y);
      const ny = new _M0TPC13ref3RefGdE(e1z * e2x - e1x * e2z);
      const nz = new _M0TPC13ref3RefGdE(e1x * e2y - e1y * e2x);
      const mag = Math.sqrt(nx.val * nx.val + ny.val * ny.val + nz.val * nz.val);
      if (mag > 1e-10) {
        nx.val = nx.val / mag;
        ny.val = ny.val / mag;
        nz.val = nz.val / mag;
      }
      const _bind$2 = 0;
      const _bind$3 = 3;
      let _tmp$2 = _bind$2;
      while (true) {
        const vi = _tmp$2;
        if (vi < _bind$3) {
          const idx = _M0MPC15array5Array2atGiE(indices, (Math.imul(t, 3) | 0) + vi | 0);
          _M0MPC15array5Array3setGdE(vertex_data, (Math.imul(idx, 8) | 0) + 3 | 0, nx.val);
          _M0MPC15array5Array3setGdE(vertex_data, (Math.imul(idx, 8) | 0) + 4 | 0, ny.val);
          _M0MPC15array5Array3setGdE(vertex_data, (Math.imul(idx, 8) | 0) + 5 | 0, nz.val);
          _tmp$2 = vi + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = t + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura4gltf23read__accessor__indices(doc, accessor_index, buffers) {
  if (accessor_index < 0 || accessor_index >= doc.accessors.length) {
    return new _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidAccessor(`index out of range: ${_M0MPC13int3Int18to__string_2einner(accessor_index, 10)}`));
  }
  const acc = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.accessors, accessor_index);
  if (acc.buffer_view < 0 || acc.buffer_view >= doc.buffer_views.length) {
    return new _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error54mizchi_2fkagura_2fgltf_2eGltfError_2eInvalidBufferView(`index out of range: ${_M0MPC13int3Int18to__string_2einner(acc.buffer_view, 10)}`));
  }
  const bv = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.buffer_views, acc.buffer_view);
  if (bv.buffer < 0 || bv.buffer >= buffers.length) {
    return new _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eBufferOutOfRange(bv.buffer));
  }
  const buf = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(buffers, bv.buffer);
  const result = _M0MPC15array5Array4makeGiE(acc.count, 0);
  const base_offset = bv.byte_offset + acc.byte_offset | 0;
  const _bind = acc.component_type;
  switch (_bind) {
    case 5123: {
      const stride = bv.byte_stride > 0 ? bv.byte_stride : 2;
      const _bind$2 = 0;
      const _bind$3 = acc.count;
      let _tmp = _bind$2;
      while (true) {
        const i = _tmp;
        if (i < _bind$3) {
          _M0MPC15array5Array3setGiE(result, i, _M0FP36mizchi6kagura4gltf13read__u16__le(buf, base_offset + (Math.imul(i, stride) | 0) | 0));
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    case 5125: {
      const stride$2 = bv.byte_stride > 0 ? bv.byte_stride : 4;
      const _bind$4 = 0;
      const _bind$5 = acc.count;
      let _tmp$2 = _bind$4;
      while (true) {
        const i = _tmp$2;
        if (i < _bind$5) {
          _M0MPC15array5Array3setGiE(result, i, _M0FP36mizchi6kagura4gltf13read__u32__le(buf, base_offset + (Math.imul(i, stride$2) | 0) | 0));
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    case 5121: {
      const stride$3 = bv.byte_stride > 0 ? bv.byte_stride : 1;
      const _bind$6 = 0;
      const _bind$7 = acc.count;
      let _tmp$3 = _bind$6;
      while (true) {
        const i = _tmp$3;
        if (i < _bind$7) {
          const _tmp$4 = base_offset + (Math.imul(i, stride$3) | 0) | 0;
          $bound_check(buf, _tmp$4);
          _M0MPC15array5Array3setGiE(result, i, buf[_tmp$4]);
          _tmp$3 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      break;
    }
    default: {
      return new _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error61mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedComponentType(acc.component_type));
    }
  }
  return new _M0DTPC16result6ResultGRPB5ArrayGiERP36mizchi6kagura4gltf9GltfErrorE2Ok(result);
}
function _M0FP36mizchi6kagura4gltf28build__mesh__from__primitive(doc, prim, buffers) {
  if (prim.mode !== 4) {
    return new _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error52mizchi_2fkagura_2fgltf_2eGltfError_2eUnsupportedMode(prim.mode));
  }
  let pos_idx;
  const _bind = _M0MPB3Map3getGsiE(prim.attributes, "POSITION");
  if (_bind === undefined) {
    return new _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error53mizchi_2fkagura_2fgltf_2eGltfError_2eMissingAttribute("POSITION"));
  } else {
    const _Some = _bind;
    const _i = _Some;
    pos_idx = _i;
  }
  const _bind$2 = _M0FP36mizchi6kagura4gltf22read__accessor__floats(doc, pos_idx, buffers);
  let positions;
  if (_bind$2.$tag === 1) {
    const _ok = _bind$2;
    positions = _ok._0;
  } else {
    return _bind$2;
  }
  const has_normals = _M0MPB3Map8containsGsiE(prim.attributes, "NORMAL");
  let normals;
  if (has_normals) {
    let i;
    _L: {
      _L$2: {
        const _bind$3 = _M0MPB3Map3getGsiE(prim.attributes, "NORMAL");
        if (_bind$3 === undefined) {
          normals = [];
        } else {
          const _Some = _bind$3;
          const _i = _Some;
          i = _i;
          break _L$2;
        }
        break _L;
      }
      const _bind$3 = _M0FP36mizchi6kagura4gltf22read__accessor__floats(doc, i, buffers);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        normals = _ok._0;
      } else {
        return _bind$3;
      }
    }
  } else {
    normals = [];
  }
  const has_texcoords = _M0MPB3Map8containsGsiE(prim.attributes, "TEXCOORD_0");
  let texcoords;
  if (has_texcoords) {
    let i;
    _L: {
      _L$2: {
        const _bind$3 = _M0MPB3Map3getGsiE(prim.attributes, "TEXCOORD_0");
        if (_bind$3 === undefined) {
          texcoords = [];
        } else {
          const _Some = _bind$3;
          const _i = _Some;
          i = _i;
          break _L$2;
        }
        break _L;
      }
      const _bind$3 = _M0FP36mizchi6kagura4gltf22read__accessor__floats(doc, i, buffers);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        texcoords = _ok._0;
      } else {
        return _bind$3;
      }
    }
  } else {
    texcoords = [];
  }
  if (3 === 0) {
    $panic();
  }
  const vertex_count = positions.length / 3 | 0;
  const vertex_data = [];
  const _bind$3 = 0;
  let _tmp = _bind$3;
  while (true) {
    const i = _tmp;
    if (i < vertex_count) {
      const px = _M0MPC15array5Array2atGdE(positions, Math.imul(i, 3) | 0);
      const py = _M0MPC15array5Array2atGdE(positions, (Math.imul(i, 3) | 0) + 1 | 0);
      const pz = _M0MPC15array5Array2atGdE(positions, (Math.imul(i, 3) | 0) + 2 | 0);
      const nx = has_normals && ((Math.imul(i, 3) | 0) + 2 | 0) < normals.length ? _M0MPC15array5Array2atGdE(normals, Math.imul(i, 3) | 0) : 0;
      const ny = has_normals && ((Math.imul(i, 3) | 0) + 2 | 0) < normals.length ? _M0MPC15array5Array2atGdE(normals, (Math.imul(i, 3) | 0) + 1 | 0) : 0;
      const nz = has_normals && ((Math.imul(i, 3) | 0) + 2 | 0) < normals.length ? _M0MPC15array5Array2atGdE(normals, (Math.imul(i, 3) | 0) + 2 | 0) : 0;
      const u = has_texcoords && ((Math.imul(i, 2) | 0) + 1 | 0) < texcoords.length ? _M0MPC15array5Array2atGdE(texcoords, Math.imul(i, 2) | 0) : 0;
      const v = has_texcoords && ((Math.imul(i, 2) | 0) + 1 | 0) < texcoords.length ? _M0MPC15array5Array2atGdE(texcoords, (Math.imul(i, 2) | 0) + 1 | 0) : 0;
      _M0MPC15array5Array4pushGdE(vertex_data, px);
      _M0MPC15array5Array4pushGdE(vertex_data, py);
      _M0MPC15array5Array4pushGdE(vertex_data, pz);
      _M0MPC15array5Array4pushGdE(vertex_data, nx);
      _M0MPC15array5Array4pushGdE(vertex_data, ny);
      _M0MPC15array5Array4pushGdE(vertex_data, nz);
      _M0MPC15array5Array4pushGdE(vertex_data, u);
      _M0MPC15array5Array4pushGdE(vertex_data, v);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let indices;
  let idx;
  _L: {
    _L$2: {
      const _bind$4 = prim.indices;
      if (_bind$4 === undefined) {
        const arr = [];
        const _bind$5 = 0;
        let _tmp$2 = _bind$5;
        while (true) {
          const i = _tmp$2;
          if (i < vertex_count) {
            _M0MPC15array5Array4pushGiE(arr, i);
            _tmp$2 = i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        indices = arr;
      } else {
        const _Some = _bind$4;
        const _idx = _Some;
        idx = _idx;
        break _L$2;
      }
      break _L;
    }
    const _bind$4 = _M0FP36mizchi6kagura4gltf23read__accessor__indices(doc, idx, buffers);
    if (_bind$4.$tag === 1) {
      const _ok = _bind$4;
      indices = _ok._0;
    } else {
      return _bind$4;
    }
  }
  if (!has_normals) {
    _M0FP36mizchi6kagura4gltf22compute__flat__normals(vertex_data, indices);
  }
  return new _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE2Ok(_M0MP36mizchi6kagura6mesh3d6Mesh3D3new(vertex_data, indices));
}
function _M0FP36mizchi6kagura4gltf11build__mesh(doc, mesh_index, buffers) {
  const mesh = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.meshes, mesh_index);
  if (mesh.primitives.length === 1) {
    const _bind = _M0FP36mizchi6kagura4gltf28build__mesh__from__primitive(doc, _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(mesh.primitives, 0), buffers);
    let _tmp;
    if (_bind.$tag === 1) {
      const _ok = _bind;
      _tmp = _ok._0;
    } else {
      return _bind;
    }
    return new _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE2Ok(_tmp);
  }
  const all_vertex_data = [];
  const all_indices = [];
  const _bind = mesh.primitives;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const prim = _bind[_];
      const _bind$3 = _M0FP36mizchi6kagura4gltf28build__mesh__from__primitive(doc, prim, buffers);
      let m;
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        m = _ok._0;
      } else {
        return _bind$3;
      }
      if (8 === 0) {
        $panic();
      }
      const base = all_vertex_data.length / 8 | 0;
      const _bind$4 = m.vertex_data;
      const _bind$5 = _bind$4.length;
      let _tmp$2 = 0;
      while (true) {
        const _$2 = _tmp$2;
        if (_$2 < _bind$5) {
          const v = _bind$4[_$2];
          _M0MPC15array5Array4pushGdE(all_vertex_data, v);
          _tmp$2 = _$2 + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const _bind$6 = m.indices;
      const _bind$7 = _bind$6.length;
      let _tmp$3 = 0;
      while (true) {
        const _$2 = _tmp$3;
        if (_$2 < _bind$7) {
          const idx = _bind$6[_$2];
          _M0MPC15array5Array4pushGiE(all_indices, idx + base | 0);
          _tmp$3 = _$2 + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP36mizchi6kagura6mesh3d6Mesh3DRP36mizchi6kagura4gltf9GltfErrorE2Ok(_M0MP36mizchi6kagura6mesh3d6Mesh3D3new(all_vertex_data, all_indices));
}
function _M0FP36mizchi6kagura4gltf20add__node__recursive(doc, buffers, graph, node_index, parent_id, mesh_cache) {
  if (node_index < 0 || node_index >= doc.nodes.length) {
    return new _M0DTPC16result6ResultGuRP36mizchi6kagura4gltf9GltfErrorE2Ok(undefined);
  }
  const node = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.nodes, node_index);
  let mesh;
  let mi;
  _L: {
    _L$2: {
      const _bind = node.mesh;
      if (_bind === undefined) {
        mesh = undefined;
      } else {
        const _Some = _bind;
        const _mi = _Some;
        mi = _mi;
        break _L$2;
      }
      break _L;
    }
    let m;
    _L$3: {
      _L$4: {
        const _bind = _M0MPB3Map3getGiRP36mizchi6kagura6mesh3d6Mesh3DE(mesh_cache, mi);
        if (_bind === undefined) {
          const _bind$2 = _M0FP36mizchi6kagura4gltf11build__mesh(doc, mi, buffers);
          let m$2;
          if (_bind$2.$tag === 1) {
            const _ok = _bind$2;
            m$2 = _ok._0;
          } else {
            return _bind$2;
          }
          _M0MPB3Map3setGiRP36mizchi6kagura6mesh3d6Mesh3DE(mesh_cache, mi, m$2);
          mesh = m$2;
        } else {
          const _Some = _bind;
          const _m = _Some;
          m = _m;
          break _L$4;
        }
        break _L$3;
      }
      mesh = m;
    }
  }
  let material;
  let mi$2;
  _L$2: {
    _L$3: {
      const _bind = node.mesh;
      if (_bind === undefined) {
        material = undefined;
      } else {
        const _Some = _bind;
        const _mi = _Some;
        mi$2 = _mi;
        break _L$3;
      }
      break _L$2;
    }
    if (mi$2 < doc.meshes.length && _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.meshes, mi$2).primitives.length > 0) {
      let mat_idx;
      _L$4: {
        _L$5: {
          const _bind = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.meshes, mi$2).primitives, 0).material;
          if (_bind === undefined) {
            material = undefined;
          } else {
            const _Some = _bind;
            const _mat_idx = _Some;
            mat_idx = _mat_idx;
            break _L$5;
          }
          break _L$4;
        }
        if (mat_idx < doc.materials.length) {
          const mat = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.materials, mat_idx);
          material = _M0MP36mizchi6kagura7scene3d8Material3new(mat.base_color_factor, undefined, _M0DTPC16option6OptionGdE4None__, _M0DTPC16option6OptionGdE4None__, undefined);
        } else {
          material = undefined;
        }
      }
    } else {
      material = undefined;
    }
  }
  let color;
  let m;
  _L$3: {
    _L$4: {
      if (material === undefined) {
        color = _M0MP36mizchi6kagura6math3d4Vec43new(1, 1, 1, 1);
      } else {
        const _Some = material;
        const _m = _Some;
        m = _m;
        break _L$4;
      }
      break _L$3;
    }
    color = m.color;
  }
  const scene_node = _M0FP36mizchi6kagura7scene3d11scene__node(new _M0DTPC16option6OptionGORP36mizchi6kagura6mesh3d6Mesh3DE4Some(mesh), node.translation, node.rotation, node.scale, color, new _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4Some(material), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__);
  let id;
  let pid;
  _L$4: {
    _L$5: {
      if (parent_id === undefined) {
        id = _M0MP36mizchi6kagura7scene3d10SceneGraph9add__node(graph, scene_node);
      } else {
        const _Some = parent_id;
        const _pid = _Some;
        pid = _pid;
        break _L$5;
      }
      break _L$4;
    }
    id = _M0MP36mizchi6kagura7scene3d10SceneGraph10add__child(graph, pid, scene_node);
  }
  const _bind = node.children;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const child_idx = _bind[_];
      const _bind$3 = _M0FP36mizchi6kagura4gltf20add__node__recursive(doc, buffers, graph, child_idx, id, mesh_cache);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _ok._0;
      } else {
        return _bind$3;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGuRP36mizchi6kagura4gltf9GltfErrorE2Ok(undefined);
}
function _M0FP36mizchi6kagura4gltf19build__scene__graph(doc, scene_index, buffers) {
  const graph = _M0MP36mizchi6kagura7scene3d10SceneGraph3new();
  const _bind = [];
  const mesh_cache = _M0MPB3Map11from__arrayGiRP36mizchi6kagura6mesh3d6Mesh3DE(new _M0TPB9ArrayViewGUiRP36mizchi6kagura6mesh3d6Mesh3DEE(_bind, 0, 0));
  if (scene_index < 0 || scene_index >= doc.scenes.length) {
    return new _M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE2Ok(graph);
  }
  const scene = _M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(doc.scenes, scene_index);
  const _bind$2 = scene.nodes;
  const _bind$3 = _bind$2.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$3) {
      const node_idx = _bind$2[_];
      const _bind$4 = _M0FP36mizchi6kagura4gltf20add__node__recursive(doc, buffers, graph, node_idx, undefined, mesh_cache);
      if (_bind$4.$tag === 1) {
        const _ok = _bind$4;
        _ok._0;
      } else {
        return _bind$4;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE2Ok(graph);
}
function _M0FP36mizchi6kagura4gltf9json__get(obj, key) {
  let map;
  _L: {
    if (obj.$tag === 6) {
      const _Object = obj;
      const _map = _Object._0;
      map = _map;
      break _L;
    } else {
      return undefined;
    }
  }
  return _M0MPB3Map3getGsRPB4JsonE(map, key);
}
function _M0FP36mizchi6kagura4gltf9json__int(val) {
  let n;
  _L: {
    if (val.$tag === 3) {
      const _Number = val;
      const _n = _Number._0;
      n = _n;
      break _L;
    } else {
      return 0;
    }
  }
  return _M0MPC16double6Double7to__int(n);
}
function _M0FP36mizchi6kagura4gltf14json__get__int(obj, key, default_) {
  let v;
  _L: {
    const _bind = _M0FP36mizchi6kagura4gltf9json__get(obj, key);
    if (_bind === undefined) {
      return default_;
    } else {
      const _Some = _bind;
      const _v = _Some;
      v = _v;
      break _L;
    }
  }
  return _M0FP36mizchi6kagura4gltf9json__int(v);
}
function _M0FP36mizchi6kagura4gltf12json__string(val) {
  if (val.$tag === 4) {
    const _String = val;
    const _s = _String._0;
    return _s;
  } else {
    return "";
  }
}
function _M0FP36mizchi6kagura4gltf17json__get__string(obj, key, default_) {
  let v;
  _L: {
    const _bind = _M0FP36mizchi6kagura4gltf9json__get(obj, key);
    if (_bind === undefined) {
      return default_;
    } else {
      const _Some = _bind;
      const _v = _Some;
      v = _v;
      break _L;
    }
  }
  return _M0FP36mizchi6kagura4gltf12json__string(v);
}
function _M0FP36mizchi6kagura4gltf15parse__accessor(obj) {
  return new _M0TP36mizchi6kagura4gltf12GltfAccessor(_M0FP36mizchi6kagura4gltf14json__get__int(obj, "bufferView", 0), _M0FP36mizchi6kagura4gltf14json__get__int(obj, "byteOffset", 0), _M0FP36mizchi6kagura4gltf14json__get__int(obj, "componentType", 5126), _M0FP36mizchi6kagura4gltf14json__get__int(obj, "count", 0), _M0FP36mizchi6kagura4gltf17json__get__string(obj, "type", "SCALAR"));
}
function _M0FP36mizchi6kagura4gltf19parse__buffer__view(obj) {
  return new _M0TP36mizchi6kagura4gltf14GltfBufferView(_M0FP36mizchi6kagura4gltf14json__get__int(obj, "buffer", 0), _M0FP36mizchi6kagura4gltf14json__get__int(obj, "byteOffset", 0), _M0FP36mizchi6kagura4gltf14json__get__int(obj, "byteStride", 0));
}
function _M0FP36mizchi6kagura4gltf14json__int__opt(val) {
  let n;
  _L: {
    if (val.$tag === 3) {
      const _Number = val;
      const _n = _Number._0;
      n = _n;
      break _L;
    } else {
      return undefined;
    }
  }
  return _M0MPC16double6Double7to__int(n);
}
function _M0FP36mizchi6kagura4gltf16parse__primitive(obj) {
  const _bind = [];
  const attributes = _M0MPB3Map11from__arrayGsiE(new _M0TPB9ArrayViewGUsiEE(_bind, 0, 0));
  let map;
  _L: {
    _L$2: {
      const _bind$2 = _M0FP36mizchi6kagura4gltf9json__get(obj, "attributes");
      if (_bind$2 === undefined) {
      } else {
        const _Some = _bind$2;
        const _x = _Some;
        if (_x.$tag === 6) {
          const _Object = _x;
          const _map = _Object._0;
          map = _map;
          break _L$2;
        }
      }
      break _L;
    }
    _M0MPB3Map4eachGsRPB4JsonE(map, (k, v) => {
      _M0MPB3Map3setGsiE(attributes, k, _M0FP36mizchi6kagura4gltf9json__int(v));
    });
  }
  let indices;
  let v;
  _L$2: {
    _L$3: {
      const _bind$2 = _M0FP36mizchi6kagura4gltf9json__get(obj, "indices");
      if (_bind$2 === undefined) {
        indices = undefined;
      } else {
        const _Some = _bind$2;
        const _v = _Some;
        v = _v;
        break _L$3;
      }
      break _L$2;
    }
    indices = _M0FP36mizchi6kagura4gltf14json__int__opt(v);
  }
  let material;
  let v$2;
  _L$3: {
    _L$4: {
      const _bind$2 = _M0FP36mizchi6kagura4gltf9json__get(obj, "material");
      if (_bind$2 === undefined) {
        material = undefined;
      } else {
        const _Some = _bind$2;
        const _v = _Some;
        v$2 = _v;
        break _L$4;
      }
      break _L$3;
    }
    material = _M0FP36mizchi6kagura4gltf14json__int__opt(v$2);
  }
  return new _M0TP36mizchi6kagura4gltf13GltfPrimitive(attributes, indices, material, _M0FP36mizchi6kagura4gltf14json__get__int(obj, "mode", 4));
}
function _M0FP36mizchi6kagura4gltf11json__array(val) {
  if (val.$tag === 5) {
    const _Array = val;
    const _arr = _Array._0;
    return _arr;
  } else {
    return [];
  }
}
function _M0FP36mizchi6kagura4gltf16json__get__array(obj, key) {
  let v;
  _L: {
    const _bind = _M0FP36mizchi6kagura4gltf9json__get(obj, key);
    if (_bind === undefined) {
      return [];
    } else {
      const _Some = _bind;
      const _v = _Some;
      v = _v;
      break _L;
    }
  }
  return _M0FP36mizchi6kagura4gltf11json__array(v);
}
function _M0FP36mizchi6kagura4gltf11parse__mesh(obj) {
  const primitives = [];
  const _bind = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "primitives");
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const p = _bind[_];
      _M0MPC15array5Array4pushGzE(primitives, _M0FP36mizchi6kagura4gltf16parse__primitive(p));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP36mizchi6kagura4gltf8GltfMesh(primitives);
}
function _M0FP36mizchi6kagura4gltf12json__double(val) {
  if (val.$tag === 3) {
    const _Number = val;
    const _n = _Number._0;
    return _n;
  } else {
    return 0;
  }
}
function _M0FP36mizchi6kagura4gltf11parse__node(obj) {
  const children = [];
  const _bind = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "children");
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const c = _bind[_];
      _M0MPC15array5Array4pushGiE(children, _M0FP36mizchi6kagura4gltf9json__int(c));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const t = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "translation");
  const translation = t.length >= 3 ? _M0MP36mizchi6kagura6math3d4Vec33new(_M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(t, 0)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(t, 1)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(t, 2))) : _M0MP36mizchi6kagura6math3d4Vec34zero();
  const r = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "rotation");
  const rotation = r.length >= 4 ? _M0MP36mizchi6kagura6math3d10Quaternion3new(_M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(r, 0)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(r, 1)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(r, 2)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(r, 3))) : _M0MP36mizchi6kagura6math3d10Quaternion8identity();
  const s = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "scale");
  const scale = s.length >= 3 ? _M0MP36mizchi6kagura6math3d4Vec33new(_M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(s, 0)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(s, 1)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(s, 2))) : _M0MP36mizchi6kagura6math3d4Vec33one();
  let mesh;
  let v;
  _L: {
    _L$2: {
      const _bind$3 = _M0FP36mizchi6kagura4gltf9json__get(obj, "mesh");
      if (_bind$3 === undefined) {
        mesh = undefined;
      } else {
        const _Some = _bind$3;
        const _v = _Some;
        v = _v;
        break _L$2;
      }
      break _L;
    }
    mesh = _M0FP36mizchi6kagura4gltf14json__int__opt(v);
  }
  let skin;
  let v$2;
  _L$2: {
    _L$3: {
      const _bind$3 = _M0FP36mizchi6kagura4gltf9json__get(obj, "skin");
      if (_bind$3 === undefined) {
        skin = undefined;
      } else {
        const _Some = _bind$3;
        const _v = _Some;
        v$2 = _v;
        break _L$3;
      }
      break _L$2;
    }
    skin = _M0FP36mizchi6kagura4gltf14json__int__opt(v$2);
  }
  return new _M0TP36mizchi6kagura4gltf8GltfNode(mesh, skin, children, translation, rotation, scale);
}
function _M0FP36mizchi6kagura4gltf12parse__scene(obj) {
  const nodes = [];
  const _bind = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "nodes");
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const n = _bind[_];
      _M0MPC15array5Array4pushGiE(nodes, _M0FP36mizchi6kagura4gltf9json__int(n));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP36mizchi6kagura4gltf9GltfScene(nodes);
}
function _M0FP36mizchi6kagura4gltf15parse__material(obj) {
  const color = new _M0TPC13ref3RefGRP36mizchi6kagura6math3d4Vec4E(_M0MP36mizchi6kagura6math3d4Vec43new(1, 1, 1, 1));
  let pbr;
  _L: {
    _L$2: {
      const _bind = _M0FP36mizchi6kagura4gltf9json__get(obj, "pbrMetallicRoughness");
      if (_bind === undefined) {
      } else {
        const _Some = _bind;
        const _pbr = _Some;
        pbr = _pbr;
        break _L$2;
      }
      break _L;
    }
    const f = _M0FP36mizchi6kagura4gltf16json__get__array(pbr, "baseColorFactor");
    if (f.length >= 4) {
      color.val = _M0MP36mizchi6kagura6math3d4Vec43new(_M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(f, 0)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(f, 1)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(f, 2)), _M0FP36mizchi6kagura4gltf12json__double(_M0MPC15array5Array2atGRP36mizchi6kagura4gltf9GltfSceneE(f, 3)));
    }
  }
  return new _M0TP36mizchi6kagura4gltf12GltfMaterial(color.val);
}
function _M0FP36mizchi6kagura4gltf11parse__skin(obj) {
  const joints = [];
  const _bind = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "joints");
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const j = _bind[_];
      _M0MPC15array5Array4pushGiE(joints, _M0FP36mizchi6kagura4gltf9json__int(j));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let ibm;
  let v;
  _L: {
    _L$2: {
      const _bind$3 = _M0FP36mizchi6kagura4gltf9json__get(obj, "inverseBindMatrices");
      if (_bind$3 === undefined) {
        ibm = undefined;
      } else {
        const _Some = _bind$3;
        const _v = _Some;
        v = _v;
        break _L$2;
      }
      break _L;
    }
    ibm = _M0FP36mizchi6kagura4gltf14json__int__opt(v);
  }
  return new _M0TP36mizchi6kagura4gltf8GltfSkin(joints, ibm);
}
function _M0FP36mizchi6kagura4gltf20parse__anim__sampler(obj) {
  return new _M0TP36mizchi6kagura4gltf15GltfAnimSampler(_M0FP36mizchi6kagura4gltf14json__get__int(obj, "input", 0), _M0FP36mizchi6kagura4gltf14json__get__int(obj, "output", 0), _M0FP36mizchi6kagura4gltf17json__get__string(obj, "interpolation", "LINEAR"));
}
function _M0FP36mizchi6kagura4gltf20parse__anim__channel(obj) {
  const sampler = _M0FP36mizchi6kagura4gltf14json__get__int(obj, "sampler", 0);
  let target_node;
  let t;
  _L: {
    _L$2: {
      const _bind = _M0FP36mizchi6kagura4gltf9json__get(obj, "target");
      if (_bind === undefined) {
        target_node = 0;
      } else {
        const _Some = _bind;
        const _t = _Some;
        t = _t;
        break _L$2;
      }
      break _L;
    }
    target_node = _M0FP36mizchi6kagura4gltf14json__get__int(t, "node", 0);
  }
  let target_path;
  let t$2;
  _L$2: {
    _L$3: {
      const _bind = _M0FP36mizchi6kagura4gltf9json__get(obj, "target");
      if (_bind === undefined) {
        target_path = "translation";
      } else {
        const _Some = _bind;
        const _t = _Some;
        t$2 = _t;
        break _L$3;
      }
      break _L$2;
    }
    target_path = _M0FP36mizchi6kagura4gltf17json__get__string(t$2, "path", "translation");
  }
  return new _M0TP36mizchi6kagura4gltf15GltfAnimChannel(sampler, target_node, target_path);
}
function _M0FP36mizchi6kagura4gltf16parse__animation(obj) {
  const name = _M0FP36mizchi6kagura4gltf17json__get__string(obj, "name", "");
  const channels = [];
  const _bind = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "channels");
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const c = _bind[_];
      _M0MPC15array5Array4pushGzE(channels, _M0FP36mizchi6kagura4gltf20parse__anim__channel(c));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const samplers = [];
  const _bind$3 = _M0FP36mizchi6kagura4gltf16json__get__array(obj, "samplers");
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const s = _bind$3[_];
      _M0MPC15array5Array4pushGzE(samplers, _M0FP36mizchi6kagura4gltf20parse__anim__sampler(s));
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP36mizchi6kagura4gltf13GltfAnimation(name, channels, samplers);
}
function _M0FP36mizchi6kagura4gltf15parse__document(root) {
  const accessors = [];
  const _bind = _M0FP36mizchi6kagura4gltf16json__get__array(root, "accessors");
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const a = _bind[_];
      _M0MPC15array5Array4pushGzE(accessors, _M0FP36mizchi6kagura4gltf15parse__accessor(a));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const buffer_views = [];
  const _bind$3 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "bufferViews");
  const _bind$4 = _bind$3.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const bv = _bind$3[_];
      _M0MPC15array5Array4pushGzE(buffer_views, _M0FP36mizchi6kagura4gltf19parse__buffer__view(bv));
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const meshes = [];
  const _bind$5 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "meshes");
  const _bind$6 = _bind$5.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$6) {
      const m = _bind$5[_];
      _M0MPC15array5Array4pushGzE(meshes, _M0FP36mizchi6kagura4gltf11parse__mesh(m));
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const nodes = [];
  const _bind$7 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "nodes");
  const _bind$8 = _bind$7.length;
  let _tmp$4 = 0;
  while (true) {
    const _ = _tmp$4;
    if (_ < _bind$8) {
      const n = _bind$7[_];
      _M0MPC15array5Array4pushGzE(nodes, _M0FP36mizchi6kagura4gltf11parse__node(n));
      _tmp$4 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const scenes = [];
  const _bind$9 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "scenes");
  const _bind$10 = _bind$9.length;
  let _tmp$5 = 0;
  while (true) {
    const _ = _tmp$5;
    if (_ < _bind$10) {
      const s = _bind$9[_];
      _M0MPC15array5Array4pushGzE(scenes, _M0FP36mizchi6kagura4gltf12parse__scene(s));
      _tmp$5 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const materials = [];
  const _bind$11 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "materials");
  const _bind$12 = _bind$11.length;
  let _tmp$6 = 0;
  while (true) {
    const _ = _tmp$6;
    if (_ < _bind$12) {
      const m = _bind$11[_];
      _M0MPC15array5Array4pushGzE(materials, _M0FP36mizchi6kagura4gltf15parse__material(m));
      _tmp$6 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const skins = [];
  const _bind$13 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "skins");
  const _bind$14 = _bind$13.length;
  let _tmp$7 = 0;
  while (true) {
    const _ = _tmp$7;
    if (_ < _bind$14) {
      const s = _bind$13[_];
      _M0MPC15array5Array4pushGzE(skins, _M0FP36mizchi6kagura4gltf11parse__skin(s));
      _tmp$7 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const animations = [];
  const _bind$15 = _M0FP36mizchi6kagura4gltf16json__get__array(root, "animations");
  const _bind$16 = _bind$15.length;
  let _tmp$8 = 0;
  while (true) {
    const _ = _tmp$8;
    if (_ < _bind$16) {
      const a = _bind$15[_];
      _M0MPC15array5Array4pushGzE(animations, _M0FP36mizchi6kagura4gltf16parse__animation(a));
      _tmp$8 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const default_scene = _M0FP36mizchi6kagura4gltf14json__get__int(root, "scene", 0);
  return new _M0TP36mizchi6kagura4gltf12GltfDocument(accessors, buffer_views, meshes, nodes, scenes, materials, skins, animations, default_scene);
}
function _M0FP36mizchi6kagura4gltf24scene__graph__from__gltf(source, buffers, scene_index) {
  let root;
  let _try_err;
  _L: {
    _L$2: {
      const _bind = _M0FPC14json13parse_2einner(new _M0TPC16string10StringView(source, 0, source.length), 1024);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        root = _ok._0;
      } else {
        const _err = _bind;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP36mizchi6kagura7scene3d10SceneGraphRP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError("invalid JSON"));
  }
  const doc = _M0FP36mizchi6kagura4gltf15parse__document(root);
  let idx;
  if (scene_index === undefined) {
    idx = doc.default_scene;
  } else {
    const _Some = scene_index;
    const _i = _Some;
    idx = _i;
  }
  return _M0FP36mizchi6kagura4gltf19build__scene__graph(doc, idx, buffers);
}
function _M0FP36mizchi6kagura4gltf10parse__glb(data) {
  if (data.length < 12) {
    return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError("GLB data too short for header"));
  }
  const magic = _M0FP36mizchi6kagura4gltf13read__u32__le(data, 0);
  if (magic !== 1179937895) {
    return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError("invalid GLB magic number"));
  }
  const version = _M0FP36mizchi6kagura4gltf13read__u32__le(data, 4);
  if (version !== 2) {
    return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError(`unsupported GLB version: ${_M0MPC13int3Int18to__string_2einner(version, 10)}`));
  }
  const total_length = _M0FP36mizchi6kagura4gltf13read__u32__le(data, 8);
  if (data.length < total_length) {
    return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError("GLB data shorter than declared length"));
  }
  const offset = new _M0TPC13ref3RefGiE(12);
  const json_str = new _M0TPC13ref3RefGOsE(undefined);
  const buffers = [];
  while (true) {
    if ((offset.val + 8 | 0) <= total_length) {
      const chunk_length = _M0FP36mizchi6kagura4gltf13read__u32__le(data, offset.val);
      const chunk_type = _M0FP36mizchi6kagura4gltf13read__u32__le(data, offset.val + 4 | 0);
      const chunk_data_start = offset.val + 8 | 0;
      const chunk_data_end = chunk_data_start + chunk_length | 0;
      if (chunk_data_end > total_length) {
        return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError("GLB chunk exceeds file bounds"));
      }
      if (chunk_type === 1313821514) {
        const chars = [];
        let _tmp = chunk_data_start;
        while (true) {
          const i = _tmp;
          if (i < chunk_data_end) {
            $bound_check(data, i);
            _M0MPC15array5Array4pushGcE(chars, data[i]);
            _tmp = i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        json_str.val = _M0MPC16string6String11from__array(new _M0TPB9ArrayViewGcE(chars, 0, chars.length));
      } else {
        if (chunk_type === 5130562) {
          const bin_bytes = [];
          const _bind = 0;
          let _tmp = _bind;
          while (true) {
            const i = _tmp;
            if (i < chunk_length) {
              const _tmp$2 = chunk_data_start + i | 0;
              $bound_check(data, _tmp$2);
              _M0MPC15array5Array4pushGyE(bin_bytes, data[_tmp$2]);
              _tmp = i + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0MPC15array5Array4pushGzE(buffers, _M0MPC15bytes5Bytes11from__array(new _M0TPB9ArrayViewGyE(bin_bytes, 0, bin_bytes.length)));
        }
      }
      offset.val = chunk_data_end;
      continue;
    } else {
      break;
    }
  }
  let s;
  _L: {
    const _bind = json_str.val;
    if (_bind === undefined) {
      return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE3Err(new _M0DTPC15error5Error47mizchi_2fkagura_2fgltf_2eGltfError_2eParseError("GLB missing JSON chunk"));
    } else {
      const _Some = _bind;
      const _s = _Some;
      s = _s;
      break _L;
    }
  }
  return new _M0DTPC16result6ResultGUsRPB5ArrayGzEERP36mizchi6kagura4gltf9GltfErrorE2Ok({ _0: s, _1: buffers });
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
function _M0FP26mizchi19web__runtime__hooks26clear__gpu__texture__dirty() {
  _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty.val = [];
}
function _M0FP26mizchi19web__runtime__hooks34clear__synced__source__generations() {
  _M0FP26mizchi19web__runtime__hooks27synced__source__generations.val = [];
}
function _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(image_id) {
  const out = new _M0TPC13ref3RefGORP26mizchi19web__runtime__hooks21SourceImageCacheEntryE(undefined);
  const _bind = _M0FP26mizchi19web__runtime__hooks20source__image__cache.val;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const entry = _bind[_];
      if (entry.image_id === image_id) {
        out.val = entry;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
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
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < frames) {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const ch = _tmp$2;
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
          _tmp$2 = ch + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = i + 1 | 0;
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
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < size) {
      _M0MPC15array5Array3setGiE(data, i, _M0FP26mizchi19web__runtime__hooks26js__load__font__data__byte(i));
      _tmp = i + 1 | 0;
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
    const _bind = 0;
    let _tmp = _bind;
    while (true) {
      const i = _tmp;
      if (i < key_count) {
        _M0MPC15array5Array4pushGiE(pressed_keys, _M0FP26mizchi19web__runtime__hooks27js__input__pressed__key__at(i));
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const pressed_mouse_buttons = [];
    const mouse_button_count = _M0FP26mizchi19web__runtime__hooks40js__input__pressed__mouse__button__count();
    const _bind$2 = 0;
    let _tmp$2 = _bind$2;
    while (true) {
      const i = _tmp$2;
      if (i < mouse_button_count) {
        const button = _M0FP26mizchi19web__runtime__hooks37js__input__pressed__mouse__button__at(i);
        if (button >= 0) {
          _M0MPC15array5Array4pushGiE(pressed_mouse_buttons, button);
        }
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const touches = [];
    const touch_count = _M0FP26mizchi19web__runtime__hooks23js__input__touch__count();
    const _bind$3 = 0;
    let _tmp$3 = _bind$3;
    while (true) {
      const i = _tmp$3;
      if (i < touch_count) {
        _M0MPC15array5Array4pushGzE(touches, _M0FP36mizchi6kagura4core17new__touch__point(_M0FP26mizchi19web__runtime__hooks24js__input__touch__id__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__x__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__y__at(i)));
        _tmp$3 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const gamepads = [];
    const gamepad_count = _M0FP26mizchi19web__runtime__hooks25js__input__gamepad__count();
    const _bind$4 = 0;
    let _tmp$4 = _bind$4;
    while (true) {
      const i = _tmp$4;
      if (i < gamepad_count) {
        const axes = [];
        const axis_count = _M0FP26mizchi19web__runtime__hooks31js__input__gamepad__axis__count(i);
        const _bind$5 = 0;
        let _tmp$5 = _bind$5;
        while (true) {
          const j = _tmp$5;
          if (j < axis_count) {
            _M0MPC15array5Array4pushGdE(axes, _M0FP26mizchi19web__runtime__hooks28js__input__gamepad__axis__at(i, j));
            _tmp$5 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        const pressed_buttons = [];
        const button_count = _M0FP26mizchi19web__runtime__hooks42js__input__gamepad__pressed__button__count(i);
        const _bind$6 = 0;
        let _tmp$6 = _bind$6;
        while (true) {
          const j = _tmp$6;
          if (j < button_count) {
            const button_id = _M0FP26mizchi19web__runtime__hooks39js__input__gamepad__pressed__button__at(i, j);
            if (button_id >= 0) {
              _M0MPC15array5Array4pushGiE(pressed_buttons, button_id);
            }
            _tmp$6 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0MPC15array5Array4pushGzE(gamepads, _M0FP36mizchi6kagura4core22new__gamepad__snapshot(_M0FP26mizchi19web__runtime__hooks26js__input__gamepad__id__at(i), axes, pressed_buttons));
        _tmp$4 = i + 1 | 0;
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
    const _bind = dirty.length;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind) {
        const image_id = dirty[_];
        let entry;
        _L: {
          _L$2: {
            const _bind$2 = _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(image_id);
            if (_bind$2 === undefined) {
            } else {
              const _Some = _bind$2;
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
            let _tmp$2 = 0;
            while (true) {
              const i = _tmp$2;
              if (i < pixel_count) {
                const base = Math.imul(i, 4) | 0;
                _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__pixel(i, _M0MPC15array5Array2atGiE(px, base), _M0MPC15array5Array2atGiE(px, base + 1 | 0), _M0MPC15array5Array2atGiE(px, base + 2 | 0), _M0MPC15array5Array2atGiE(px, base + 3 | 0));
                _tmp$2 = i + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            _M0FP26mizchi19web__runtime__hooks29js__gfx__upload__texture__end();
          }
        }
        _tmp = _ + 1 | 0;
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
    const _tmp = command.shader.source;
    const _bind = "@vertex";
    if (_M0MPC16string6String8contains(_tmp, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
      const vf_count = command.vertex_data.length;
      const ic = command.indices.length;
      const u_count = command.uniform_dwords.length;
      const src_count = command.src_image_ids.length;
      const blend = _M0FP36mizchi6kagura3gfx20blend__mode__to__int(command.blend);
      _M0FP26mizchi19web__runtime__hooks28js__gfx__custom__draw__begin(command.shader.id, command.shader.source, vf_count, ic, u_count, src_count, command.dst.id, command.dst.width, command.dst.height, blend, command.instance_count);
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i < vf_count) {
          _M0FP26mizchi19web__runtime__hooks36js__gfx__custom__draw__vertex__float(i, _M0MPC15array5Array2atGdE(command.vertex_data, i));
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$3 = 0;
      while (true) {
        const i = _tmp$3;
        if (i < ic) {
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MPC15array5Array2atGiE(command.indices, i));
          _tmp$3 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$4 = 0;
      while (true) {
        const i = _tmp$4;
        if (i < u_count) {
          _M0FP26mizchi19web__runtime__hooks30js__gfx__custom__draw__uniform(i, _M0MPC15array5Array2atGiE(command.uniform_dwords, i));
          _tmp$4 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$5 = 0;
      while (true) {
        const i = _tmp$5;
        if (i < src_count) {
          _M0FP26mizchi19web__runtime__hooks33js__gfx__custom__draw__src__image(i, _M0MPC15array5Array2atGiE(command.src_image_ids, i));
          _tmp$5 = i + 1 | 0;
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
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i < vc) {
          const base = Math.imul(i, 4) | 0;
          _M0FP26mizchi19web__runtime__hooks21js__gfx__draw__vertex(i, _M0MPC15array5Array2atGdE(command.vertex_data, base), _M0MPC15array5Array2atGdE(command.vertex_data, base + 1 | 0), _M0MPC15array5Array2atGdE(command.vertex_data, base + 2 | 0), _M0MPC15array5Array2atGdE(command.vertex_data, base + 3 | 0));
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$3 = 0;
      while (true) {
        const i = _tmp$3;
        if (i < ic) {
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MPC15array5Array2atGiE(command.indices, i));
          _tmp$3 = i + 1 | 0;
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
  }, (_s, _a) => false, (_s, _a, c) => c, (_s, _a, c) => c));
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
function _M0FP26mizchi12gltf__viewer25default__glb__asset__path() {
  return "./assets/test_scene.glb";
}
function _M0FP26mizchi12gltf__viewer41sample__asset__source__from__query__param(asset) {
  return asset === "" ? new _M0DTP26mizchi12gltf__viewer17SampleAssetSource10DefaultGlb(_M0FP26mizchi12gltf__viewer25default__glb__asset__path()) : new _M0DTP26mizchi12gltf__viewer17SampleAssetSource10DefaultGlb(asset);
}
function _M0FP26mizchi12gltf__viewer26get__initial__asset__query() {
  return _M0FP26mizchi12gltf__viewer21js__get__query__param("asset");
}
function _M0FP26mizchi12gltf__viewer26get__initial__hud__enabled() {
  return _M0FP26mizchi12gltf__viewer27js__get__query__param__bool("hud", true);
}
function _M0MP26mizchi12gltf__viewer11ViewerState4draw(self, ctx) {
  const cmds = _M0FP36mizchi6kagura7scene3d27render__scene3d__graph__gpu(self.graph, _M0MP36mizchi6kagura8camera3d11OrbitCamera12to__camera3d(self.camera), self.lighting, ctx.dst, self.shader3d, ctx.screen_w, ctx.screen_h, new _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4Some(self.shader3d_textured), _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__);
  if (!self.show_hud) {
    return cmds;
  }
  const sw = ctx.screen_w + 0;
  const sh = ctx.screen_h + 0;
  const white = _M0FP36mizchi6kagura9debugutil16color__from__hex(16777215);
  _M0FP36mizchi6kagura9debugutil15draw__dot__text(cmds, ctx.dst, ctx.shader, [78], 4, 4, sw, sh, white, 1);
  _M0FP36mizchi6kagura9debugutil12draw__number(cmds, ctx.dst, ctx.shader, self.node_count, 12, 4, sw, sh, white, 1);
  _M0FP36mizchi6kagura9debugutil15draw__dot__text(cmds, ctx.dst, ctx.shader, [77], 4, 12, sw, sh, white, 1);
  _M0FP36mizchi6kagura9debugutil12draw__number(cmds, ctx.dst, ctx.shader, self.mesh_node_count, 12, 12, sw, sh, white, 1);
  return cmds;
}
function _M0MP26mizchi12gltf__viewer11ViewerState11new_2einner(graph, show_hud) {
  const node_count = _M0MPB3Map6lengthGiRP36mizchi6kagura7scene3d9SceneNodeE(graph.nodes);
  const mesh_count = new _M0TPC13ref3RefGiE(0);
  _M0MPB3Map4eachGiRP36mizchi6kagura7scene3d9SceneNodeE(graph.nodes, (_id, node) => {
    const _bind = node.mesh;
    if (_bind === undefined) {
      return;
    } else {
      mesh_count.val = mesh_count.val + 1 | 0;
      return;
    }
  });
  const ground = _M0FP36mizchi6kagura7scene3d11scene__node(new _M0DTPC16option6OptionGORP36mizchi6kagura6mesh3d6Mesh3DE4Some(_M0MP36mizchi6kagura6mesh3d6Mesh3D13plane_2einner(8, 8, 16)), _M0MP36mizchi6kagura6math3d4Vec33new(0, -0.02, 0), undefined, undefined, _M0MP36mizchi6kagura6math3d4Vec43new(0.35, 0.35, 0.4, 1), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__);
  _M0MP36mizchi6kagura7scene3d10SceneGraph9add__node(graph, ground);
  return new _M0TP26mizchi12gltf__viewer11ViewerState(graph, _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(_M0MP36mizchi6kagura6math3d4Vec33new(0, 0.5, 0), 6, 0.5, 0.4, 0.785398163397448279, (_M0FP26mizchi12gltf__viewer9screen__w + 0) / (_M0FP26mizchi12gltf__viewer9screen__h + 0), 0.01, 50), _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(-0.5, 1, 0.8), _M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 0.8), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 0.3), _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None__, _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None__), _M0FP36mizchi6kagura3gfx19new__shader__handle(100, _M0FP36mizchi6kagura6draw3d31shader3d__lit__untextured__wgsl()), _M0FP36mizchi6kagura3gfx19new__shader__handle(101, _M0FP36mizchi6kagura6draw3d19shader3d__lit__wgsl()), node_count, mesh_count.val, show_hud);
}
function _M0MP26mizchi12gltf__viewer11ViewerState6update(self, input, prev_x, prev_y) {
  const cx = input.cursor_x;
  const cy = input.cursor_y;
  const dx = cx - prev_x.val;
  const dy = cy - prev_y.val;
  prev_x.val = cx;
  prev_y.val = cy;
  const lmb = new _M0TPC13ref3RefGbE(false);
  const _bind = input.pressed_mouse_buttons;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const b = _bind[_];
      if (b === 0) {
        lmb.val = true;
        break;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (lmb.val) {
    self.camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self.camera, dx * -0.005, dy * -0.005);
  }
  if (input.wheel_y !== 0) {
    self.camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera4zoom(self.camera, input.wheel_y * 0.05);
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi12gltf__viewer13start__viewer(graph, show_hud) {
  const state = _M0MP26mizchi12gltf__viewer11ViewerState11new_2einner(graph, show_hud);
  const prev_x = _M0MPC13ref3Ref3newGdE(0);
  const prev_y = _M0MPC13ref3Ref3newGdE(0);
  _M0FP36mizchi6kagura6engine11run_2einner((input) => {
    _M0MP26mizchi12gltf__viewer11ViewerState6update(state, input, prev_x, prev_y);
  }, (ctx) => _M0MP26mizchi12gltf__viewer11ViewerState4draw(state, ctx), undefined, undefined, undefined, 735, _M0FP26mizchi12gltf__viewer9screen__w, _M0FP26mizchi12gltf__viewer9screen__h, "glTF Viewer", "#app");
}
(() => {
  _M0FP26mizchi19web__runtime__hooks7install("#app");
  const show_hud = _M0FP26mizchi12gltf__viewer26get__initial__hud__enabled();
  let path;
  _L: {
    const _bind = _M0FP26mizchi12gltf__viewer41sample__asset__source__from__query__param(_M0FP26mizchi12gltf__viewer26get__initial__asset__query());
    const _DefaultGlb = _bind;
    const _path = _DefaultGlb._0;
    path = _path;
    break _L;
  }
  _M0FP26mizchi12gltf__viewer16js__fetch__bytes(path, (data) => {
    let json;
    let buffers;
    _L$2: {
      let _bind;
      let _try_err;
      _L$3: {
        _L$4: {
          const _bind$2 = _M0FP36mizchi6kagura4gltf10parse__glb(data);
          if (_bind$2.$tag === 1) {
            const _ok = _bind$2;
            _bind = _ok._0;
          } else {
            const _err = _bind$2;
            _try_err = _err._0;
            break _L$4;
          }
          break _L$3;
        }
        _M0FPB7printlnGsE("Failed to parse GLB");
        return undefined;
      }
      const _json = _bind._0;
      const _buffers = _bind._1;
      json = _json;
      buffers = _buffers;
      break _L$2;
    }
    let graph;
    let _try_err;
    _L$3: {
      _L$4: {
        const _bind = _M0FP36mizchi6kagura4gltf24scene__graph__from__gltf(json, buffers, undefined);
        if (_bind.$tag === 1) {
          const _ok = _bind;
          graph = _ok._0;
        } else {
          const _err = _bind;
          _try_err = _err._0;
          break _L$4;
        }
        break _L$3;
      }
      _M0FPB7printlnGsE("Failed to build scene graph");
      return undefined;
    }
    _M0FP26mizchi12gltf__viewer13start__viewer(graph, show_hud);
  });
})();
//# sourceMappingURL=gltf_viewer.js.map
