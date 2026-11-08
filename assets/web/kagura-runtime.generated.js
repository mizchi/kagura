// Generated from platform_web/web_core/*.mbt by just web-runtime-build. DO NOT EDIT.
// Source SHA-256: e47bf1739dbc1f12e2ed9f66da5991e61e3ddf74b9a5843ef72fc7fc404fd645
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function $oob() {
  throw new Error("Index out of bounds");
}
class $PanicError extends Error {}
function $panic(message) {
  throw new $PanicError(message);
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
const _M0FPB22js__code__unit__string = (c) => String.fromCharCode(c);
const _M0FPB13js__index__of = (s, start, end, p) => {
  if (end - start < p.length) return -1;
  if (end === s.length) return s.indexOf(p, start);
  const i = s.substring(start, end).indexOf(p);
  return i < 0 ? i : start + i;
};
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0FPB13js__substring = (s, start, end) => start === 0 && end === s.length ? s : s.substring(start, end);
function _M0TPB5ArrayGdE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGbE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGRP26mizchi8js__core3AnyE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
const _M0MPC16double6Double8mod__ffi = (a, b) => (a % b);
function _M0TPB12MutArrayViewGUisEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB12MutArrayViewGdE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function _M0DTPC16option6OptionGdE4None() {}
_M0DTPC16option6OptionGdE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGdE4None__ = new _M0DTPC16option6OptionGdE4None();
function _M0DTPC16option6OptionGdE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGdE4Some.prototype.$tag = 1;
function _M0TPC13ref3RefGORP26mizchi8js__core3AnyE(param0) {
  this.val = param0;
}
const _M0FP26mizchi8js__core9undefined = () => undefined;
const _M0MP26mizchi8js__core3Any16__get__by__index = (obj, key) => obj[key];
const _M0MP26mizchi8js__core3Any5__get = (obj, key) => obj[key];
const _M0MP26mizchi8js__core3Any6__call = (obj, key, args) => obj[key](...args);
const _M0FP26mizchi8js__core11is__nullish = (v) => v == null;
const _M0FP26mizchi8js__core12throw__error = (msg) => { throw new Error(msg); };
const _M0MP26mizchi8js__core3Any5__set = (obj, key, value) => { obj[key] = value };
const _M0FP26mizchi8js__core12global__this = () => globalThis;
const _M0FP26mizchi8js__core4null = () => null;
const _M0FP26mizchi8js__core13is__undefined = (v) => v === undefined;
const _M0FP26mizchi8js__core8typeof__ = (v) => typeof v;
const _M0FP26mizchi8js__core5equal = (a, b) => a === b;
const _M0FP26mizchi8js__core18ffi__from__entries = (entries) => Object.fromEntries(entries.map(e => [e._0, e._1]));
function _M0TPB9ArrayViewGUsRP26mizchi8js__core3AnyEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP26mizchi8js__core16ffi__array__from = (v) => Array.from(v);
const _M0MP26mizchi8js__core3Any10to__string = (self) => self == null ? String(self) : self.toString();
const _M0MP36mizchi11js__builtin4math4Math5round = (x) => Math.round(x);
const _M0MP36mizchi11js__builtin4math4Math6fround = (x) => Math.fround(x);
const _M0MP36mizchi11js__builtin4math4Math5hypot = (values) => Math.hypot(...values);
const _M0FP36mizchi11js__builtin6object13object__class = () => Object;
function _M0TP36mizchi12kagura__core10statistics15IntervalSummary(param0, param1, param2, param3, param4) {
  this.frames = param0;
  this.elapsed_ms = param1;
  this.fps = param2;
  this.p50_ms = param3;
  this.p95_ms = param4;
}
const _M0FP36mizchi21kagura__platform__web7interop6finite = (value) => Number.isFinite(value);
const _M0FP36mizchi21kagura__platform__web7interop13safe__integer = (value) => Number.isSafeInteger(value);
const _M0FP36mizchi21kagura__platform__web7interop6truthy = (value) => !!value;
const _M0FP36mizchi21kagura__platform__web7interop12range__error = (message) => { throw new RangeError(message); };
const _M0FP36mizchi21kagura__platform__web7interop14object__spread = (left, right) => ({...left, ...right});
const _M0FP36mizchi21kagura__platform__web7interop11delete__key = (value, key) => { delete value[key]; };
const _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal = (value, digits) => Number(value.toFixed(digits));
function _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB9ArrayViewGiE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB9ArrayViewGdE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB9ArrayViewGRP26mizchi8js__core3AnyE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP36mizchi11js__builtin6regexp16ffi__regexp__new = (s, flags) => new RegExp(s, flags);
const _M0MP36mizchi11js__builtin6regexp6RegExp17ffi__regexp__test = (re, string) => re.test(string);
function _M0TPB5ArrayGiE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None() {}
_M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None__ = new _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None();
function _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4Some.prototype.$tag = 1;
function _M0TP36mizchi21kagura__platform__web5input12GamepadState(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.dead_zone = param0;
  this.identity = param1;
  this.armed = param2;
  this.previous = param3;
  this.previous_axes = param4;
  this.direction = param5;
  this.next_repeat = param6;
  this.last_time = param7;
}
function _M0TP36mizchi21kagura__platform__web5input12ControlState(param0, param1, param2, param3, param4, param5, param6) {
  this.capacity = param0;
  this.held = param1;
  this.commands = param2;
  this.owner = param3;
  this.x = param4;
  this.y = param5;
  this.release_pending = param6;
}
function _M0TPB5ArrayGUdRP26mizchi8js__core3AnyEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TP36mizchi6anim3d8playback8Timeline(param0, param1, param2, param3) {
  this.time = param0;
  this.playing = param1;
  this.speed = param2;
  this.looping = param3;
}
function _M0TP36mizchi21kagura__platform__web8playback12MotionPlayer(param0, param1, param2) {
  this.clips = param0;
  this.clip = param1;
  this.timeline = param2;
}
const _M0FP36mizchi11js__builtin10collection13ffi__new__map = () => new Map();
const _M0FP36mizchi11js__builtin4weak17ffi__new__weakmap = () => new WeakMap();
function _M0TPB5ArrayGUisEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FP36mizchi21kagura__platform__web6render7to__i32 = (value) => value | 0;
const _M0FP36mizchi21kagura__platform__web6render14replace__first = (source, from, to) => source.replace(from, to);
const _M0FP36mizchi21kagura__platform__web6render13float32__copy = (source) => new Float32Array(source);
const _M0FP36mizchi21kagura__platform__web6render12uint32__copy = (source) => new Uint32Array(source);
const _M0FP36mizchi21kagura__platform__web6render10to__uint32 = (source) => source >>> 0;
const _M0FP36mizchi21kagura__platform__web6render14unique__symbol = () => Symbol("static geometry");
const _M0FP36mizchi21kagura__platform__web6render11type__error = (message) => { throw new TypeError(message); };
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0FP36mizchi21kagura__platform__web6render17position__pattern = _M0MP36mizchi11js__builtin6regexp6RegExp3new("position\\s*:\\s*vec3<f32>", undefined);
const _M0FP36mizchi21kagura__platform__web6render16weights__pattern = _M0MP36mizchi11js__builtin6regexp6RegExp3new("weights\\s*:\\s*vec4<f32>", undefined);
const _M0FP36mizchi21kagura__platform__web6render15joints__pattern = _M0MP36mizchi11js__builtin6regexp6RegExp3new("joints\\s*:\\s*vec4<f32>", undefined);
const _M0FP36mizchi21kagura__platform__web5input13radial__stickN5tupleS962 = { _0: 0, _1: 0 };
const _M0FP36mizchi21kagura__platform__web5input11victrix__idN6constrS915 = "i";
const _M0FP36mizchi21kagura__platform__web5input11victrix__id = _M0MP36mizchi11js__builtin6regexp6RegExp3new("\\bVendor:\\s*0e6f\\s+Product:\\s*0218\\b", _M0FP36mizchi21kagura__platform__web5input11victrix__idN6constrS915);
const _M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS923 = { _0: 3, _1: 6 };
const _M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS924 = { _0: 4, _1: 7 };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS869 = { _0: "renderCpuMs", _1: "_lastRenderCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS870 = { _0: "renderUploadCpuMs", _1: "_lastRenderUploadCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS871 = { _0: "renderBindGroupCpuMs", _1: "_lastRenderBindGroupCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS872 = { _0: "renderEncodeCpuMs", _1: "_lastRenderEncodeCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS873 = { _0: "renderSubmitCpuMs", _1: "_lastRenderSubmitCpuMs" };
const _M0MPC16string10StringView4findN6constrS340 = 0;
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1169 = { _0: "@group(0) @binding(0) var<uniform> uniforms: Uniforms;", _1: "struct InstanceUniforms { values: array<Uniforms, 32>, };\n@group(0) @binding(0) var<uniform> instance_uniforms: InstanceUniforms;\nvar<private> uniforms: Uniforms;" };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1170 = { _0: "struct VertexOutput {", _1: "struct VertexOutput {\n  @location(7) @interpolate(flat) instance_id: u32," };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1171 = { _0: "@vertex fn vs_main(input: VertexInput) -> VertexOutput {", _1: "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) instance_id: u32) -> VertexOutput {\n  uniforms = instance_uniforms.values[instance_id];" };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1172 = { _0: "var out: VertexOutput;", _1: "var out: VertexOutput;\n  out.instance_id = instance_id;" };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1173 = { _0: "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {", _1: "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  uniforms = instance_uniforms.values[in.instance_id];" };
const _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN6constrS1137 = "g";
const _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN6recordS1138 = new _M0TPC16string10StringView("texture", 0, 7);
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGUdRP26mizchi8js__core3AnyEEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGiEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGdEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRP26mizchi8js__core3AnyEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPB18UninitializedArray12unsafe__blitGUisEE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGUdRP26mizchi8js__core3AnyEEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGiE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGiEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGdE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGdEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGRP26mizchi8js__core3AnyE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRP26mizchi8js__core3AnyEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGUisEE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGUisEE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGiE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGiE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGdE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGdE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGRP26mizchi8js__core3AnyE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGRP26mizchi8js__core3AnyE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGUisEE(src, allocate_len, len, src_offset, dst_offset) {
  let _tmp;
  if (allocate_len >= 0) {
    let _tmp$2;
    if (len >= 0) {
      let _tmp$3;
      const _p = src.length;
      if (src_offset >= 0 && src_offset <= (_p - len | 0)) {
        _tmp$3 = dst_offset >= 0 && dst_offset <= (allocate_len - len | 0);
      } else {
        _tmp$3 = false;
      }
      _tmp$2 = _tmp$3;
    } else {
      _tmp$2 = false;
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGUisEE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src.length);
    return $panic(_string_builder.val);
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGiE(src, allocate_len, len, src_offset, dst_offset) {
  let _tmp;
  if (allocate_len >= 0) {
    let _tmp$2;
    if (len >= 0) {
      let _tmp$3;
      const _p = src.length;
      if (src_offset >= 0 && src_offset <= (_p - len | 0)) {
        _tmp$3 = dst_offset >= 0 && dst_offset <= (allocate_len - len | 0);
      } else {
        _tmp$3 = false;
      }
      _tmp$2 = _tmp$3;
    } else {
      _tmp$2 = false;
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGiE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src.length);
    return $panic(_string_builder.val);
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGdE(src, allocate_len, len, src_offset, dst_offset) {
  let _tmp;
  if (allocate_len >= 0) {
    let _tmp$2;
    if (len >= 0) {
      let _tmp$3;
      const _p = src.length;
      if (src_offset >= 0 && src_offset <= (_p - len | 0)) {
        _tmp$3 = dst_offset >= 0 && dst_offset <= (allocate_len - len | 0);
      } else {
        _tmp$3 = false;
      }
      _tmp$2 = _tmp$3;
    } else {
      _tmp$2 = false;
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGdE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src.length);
    return $panic(_string_builder.val);
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGRP26mizchi8js__core3AnyE(src, allocate_len, len, src_offset, dst_offset) {
  let _tmp;
  if (allocate_len >= 0) {
    let _tmp$2;
    if (len >= 0) {
      let _tmp$3;
      const _p = src.length;
      if (src_offset >= 0 && src_offset <= (_p - len | 0)) {
        _tmp$3 = dst_offset >= 0 && dst_offset <= (allocate_len - len | 0);
      } else {
        _tmp$3 = false;
      }
      _tmp$2 = _tmp$3;
    } else {
      _tmp$2 = false;
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGRP26mizchi8js__core3AnyE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src.length);
    return $panic(_string_builder.val);
  }
}
function _M0MPB18UninitializedArray19unsafe__blit__fixedGRP26mizchi8js__core3AnyE(dst, dst_offset, src, src_offset, len) {
  let _tmp = len - 1 | 0;
  let _tmp$2 = len > 0;
  while (true) {
    const i = _tmp;
    const _more = _tmp$2;
    if (_more) {
      const _tmp$3 = dst_offset + i | 0;
      const _tmp$4 = src_offset + i | 0;
      if (_tmp$3 >>> 0 < dst.length) {
        dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
      } else {
        $oob();
      }
      _tmp = i - 1 | 0;
      _tmp$2 = i > 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MPB18UninitializedArray36unsafe__make__and__blit__from__fixedGRP26mizchi8js__core3AnyE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray19unsafe__blit__fixedGRP26mizchi8js__core3AnyE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return size_hint >= 0 ? new _M0TPB13StringBuilder("") : $panic("size_hint must be non-negative");
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0IP016_24default__implPB2Eq10not__equalGOsE(x, y) {
  return !_M0IPC16option6OptionPB2Eq5equalGsE(x, y);
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String21clamped__view_2einner(self, start, end) {
  const len = self.length;
  let lo;
  if (start <= 0) {
    lo = 0;
  } else {
    if (start >= len) {
      lo = len;
    } else {
      let _tmp;
      const _p = self.charCodeAt(start);
      if (_p >= 56320 && _p <= 57343) {
        const _p$2 = self.charCodeAt(start - 1 | 0);
        _tmp = _p$2 >= 55296 && _p$2 <= 56319;
      } else {
        _tmp = false;
      }
      if (_tmp) {
        lo = start + 1 | 0;
      } else {
        lo = start;
      }
    }
  }
  let hi;
  if (end === undefined) {
    hi = len;
  } else {
    const _Some = end;
    const _e = _Some;
    if (_e <= 0) {
      hi = 0;
    } else {
      if (_e >= len) {
        hi = len;
      } else {
        let _tmp;
        const _p = self.charCodeAt(_e);
        if (_p >= 56320 && _p <= 57343) {
          const _p$2 = self.charCodeAt(_e - 1 | 0);
          _tmp = _p$2 >= 55296 && _p$2 <= 56319;
        } else {
          _tmp = false;
        }
        if (_tmp) {
          hi = _e - 1 | 0;
        } else {
          hi = _e;
        }
      }
    }
  }
  return lo >= hi ? new _M0TPC16string10StringView(self, lo, lo) : new _M0TPC16string10StringView(self, lo, hi);
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String21clamped__view_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, self);
}
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string6String20unsafe__range__equal(self, start, other, other_start, len) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      if (self.charCodeAt(start + i | 0) === other.charCodeAt(other_start + i | 0)) {
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
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0FPB24find__code__unit__scalar(data, start, end, code) {
  let _tmp = start;
  while (true) {
    const pos = _tmp;
    if (pos < end) {
      if (data.charCodeAt(pos) === code) {
        return pos;
      }
      _tmp = pos + 1 | 0;
      continue;
    } else {
      return -1;
    }
  }
}
function _M0FPB30find__code__unit__from__string(data, start, end, code) {
  return (end - start | 0) <= 8 ? _M0FPB24find__code__unit__scalar(data, start, end, code) : _M0FPB13js__index__of(data, start, end, _M0FPB22js__code__unit__string(code));
}
function _M0FPB28find__code__unit__from__view(target, start, end, code) {
  const target_start = target.start;
  const found = _M0FPB30find__code__unit__from__string(target.str, target_start + start | 0, target_start + end | 0, code);
  return found < 0 ? -1 : found - target_start | 0;
}
function _M0FPB19kmp__failure__table(pattern) {
  const m = pattern.end - pattern.start | 0;
  const table = $make_array_len_and_init(m, 0);
  let k = 0;
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < m) {
      const c = pattern.str.charCodeAt(pattern.start + i | 0);
      while (true) {
        if (k > 0 && c !== pattern.str.charCodeAt(pattern.start + k | 0)) {
          const _tmp$2 = k - 1 | 0;
          k = _tmp$2 >>> 0 < table.length ? table[_tmp$2] : $oob();
          continue;
        } else {
          break;
        }
      }
      if (c === pattern.str.charCodeAt(pattern.start + k | 0)) {
        k = k + 1 | 0;
      }
      if (i >>> 0 < table.length) {
        table[i] = k;
      } else {
        $oob();
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return table;
}
function _M0FPB24find__pattern__kmp__from(target, pattern, start) {
  const n = target.end - target.start | 0;
  const m = pattern.end - pattern.start | 0;
  const table = _M0FPB19kmp__failure__table(pattern);
  let k = 0;
  let _tmp = start;
  while (true) {
    const i = _tmp;
    if (i < n) {
      const c = target.str.charCodeAt(target.start + i | 0);
      while (true) {
        if (k > 0 && c !== pattern.str.charCodeAt(pattern.start + k | 0)) {
          const _tmp$2 = k - 1 | 0;
          k = _tmp$2 >>> 0 < table.length ? table[_tmp$2] : $oob();
          continue;
        } else {
          break;
        }
      }
      if (c === pattern.str.charCodeAt(pattern.start + k | 0)) {
        k = k + 1 | 0;
      }
      if (k === m) {
        return (i - m | 0) + 1 | 0;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return undefined;
}
function _M0FPB36find__two__anchor__candidate__scalar(data, start, candidate_end, first, last_offset, last) {
  let _tmp = start;
  while (true) {
    const pos = _tmp;
    if (pos < candidate_end) {
      if (data.charCodeAt(pos) === first && data.charCodeAt(pos + last_offset | 0) === last) {
        return pos;
      }
      _tmp = pos + 1 | 0;
      continue;
    } else {
      return -1;
    }
  }
}
function _M0FPB42find__two__anchor__candidate__from__string(data, start, candidate_end, first, last_offset, last) {
  return _M0FPB36find__two__anchor__candidate__scalar(data, start, candidate_end, first, last_offset, last);
}
function _M0FPB21string__ranges__equal(left, left_start, right, right_start, length) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < length) {
      if (left.charCodeAt(left_start + i | 0) !== right.charCodeAt(right_start + i | 0)) {
        return false;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return true;
}
function _M0FPB22find__by__two__anchors(target, pattern) {
  const target_len = target.end - target.start | 0;
  const pattern_len = pattern.end - pattern.start | 0;
  const target_start = target.start;
  const pattern_start = pattern.start;
  const last_offset = pattern_len - 1 | 0;
  const candidate_end = ((target_start + target_len | 0) - pattern_len | 0) + 1 | 0;
  const first = pattern.str.charCodeAt(pattern.start);
  const last = pattern.str.charCodeAt(pattern.start + last_offset | 0);
  const middle_len = last_offset - 1 | 0;
  let _tmp = target_start;
  let _tmp$2 = 0;
  while (true) {
    const pos = _tmp;
    const failures = _tmp$2;
    if (pos < candidate_end) {
      const found = _M0FPB42find__two__anchor__candidate__from__string(target.str, pos, candidate_end, first, last_offset, last);
      if (found < 0) {
        return undefined;
      }
      if (_M0FPB21string__ranges__equal(target.str, found + 1 | 0, pattern.str, pattern_start + 1 | 0, middle_len)) {
        return found - target_start | 0;
      }
      const failures$2 = failures + 1 | 0;
      const scanned = found - target_start | 0;
      if (failures$2 > 64 || failures$2 > (4 + (scanned / 8 | 0) | 0)) {
        return _M0FPB24find__pattern__kmp__from(target, pattern, scanned + 1 | 0);
      }
      _tmp = found + 1 | 0;
      _tmp$2 = failures$2;
      continue;
    } else {
      return undefined;
    }
  }
}
function _M0FPB13find__pattern(target, pattern) {
  if ((pattern.end - pattern.start | 0) <= 250) {
    const target_start = target.start;
    const pattern_start = pattern.start;
    const found = _M0FPB13js__index__of(target.str, target_start, target_start + (target.end - target.start | 0) | 0, _M0FPB13js__substring(pattern.str, pattern_start, pattern_start + (pattern.end - pattern.start | 0) | 0));
    return found < 0 ? undefined : found - target_start | 0;
  } else {
    return _M0FPB22find__by__two__anchors(target, pattern);
  }
}
function _M0MPC16string10StringView4find(self, str) {
  const pattern_len = str.end - str.start | 0;
  switch (pattern_len) {
    case 0: {
      return _M0MPC16string10StringView4findN6constrS340;
    }
    case 1: {
      const found = _M0FPB28find__code__unit__from__view(self, 0, self.end - self.start | 0, str.str.charCodeAt(str.start));
      return found < 0 ? undefined : found;
    }
    default: {
      return pattern_len > (self.end - self.start | 0) ? undefined : _M0FPB13find__pattern(self, str);
    }
  }
}
function _M0MPC16string10StringView11has__prefix(self, str) {
  const str_len = str.end - str.start | 0;
  return str_len <= (self.end - self.start | 0) ? (str_len === 0 || self.str.charCodeAt(self.start) === str.str.charCodeAt(str.start) ? _M0MPC16string6String20unsafe__range__equal(self.str, self.start, str.str, str.start, str_len) : false) : false;
}
function _M0MPC16string6String11has__prefix(self, str) {
  return _M0MPC16string10StringView11has__prefix(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0FPB23array__growth__capacity(current, len, required) {
  if (required < len) {
    $panic("Array capacity overflow");
  }
  const start = current === 0 ? 8 : current;
  let _tmp = start;
  while (true) {
    const space = _tmp;
    if (space < required) {
      const next = Math.imul(space, 2) | 0;
      if (next <= space) {
        return required;
      }
      _tmp = next;
      continue;
    } else {
      return space;
    }
  }
}
function _M0MPC15array5Array8capacityGUisEE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array8capacityGiE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array8capacityGdE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array8capacityGRP26mizchi8js__core3AnyE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array14resize__bufferGUisEE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGUisEE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGiE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGiE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGdE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGdE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGRP26mizchi8js__core3AnyE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGRP26mizchi8js__core3AnyE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array7reallocGUisEE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGUisEE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGUisEE(self, new_cap);
}
function _M0MPC15array5Array7reallocGiE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGiE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGiE(self, new_cap);
}
function _M0MPC15array5Array7reallocGdE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGdE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGdE(self, new_cap);
}
function _M0MPC15array5Array7reallocGRP26mizchi8js__core3AnyE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGRP26mizchi8js__core3AnyE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGRP26mizchi8js__core3AnyE(self, new_cap);
}
function _M0MPC15array5Array4pushGUisEE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGUisEE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGiE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGiE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGdE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGdE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGRP26mizchi8js__core3AnyE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGRP26mizchi8js__core3AnyE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0FPB36string__contains__code__unit__scalar(str, start, end, code) {
  let _tmp = start;
  while (true) {
    const i = _tmp;
    if (i < end) {
      if (str.charCodeAt(i) === code) {
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
function _M0FPB28string__contains__code__unit(str, start, end, code) {
  return _M0FPB36string__contains__code__unit__scalar(str, start, end, code);
}
function _M0MPC16string10StringView20contains__code__unit(self, code) {
  return _M0FPB28string__contains__code__unit(self.str, self.start, self.end, code);
}
function _M0MPC16string10StringView8contains(self, str) {
  const _bind = str.end - str.start | 0;
  switch (_bind) {
    case 0: {
      return true;
    }
    case 1: {
      return _M0MPC16string10StringView20contains__code__unit(self, str.str.charCodeAt(str.start));
    }
    default: {
      const _bind$2 = _M0MPC16string10StringView4find(self, str);
      return !(_bind$2 === undefined);
    }
  }
}
function _M0MPC16string6String8contains(self, str) {
  return _M0MPC16string10StringView8contains(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0IPC13int3IntPB4Show10to__string(self) {
  return _M0MPC13int3Int18to__string_2einner(self, 10);
}
function _M0MPC15array10FixedArray11from__arrayGiE(array) {
  const _p = array.end - array.start | 0;
  if (_p <= 0) {
    return [];
  } else {
    const _p$2 = $make_array_len_and_init(_p, array.buf[array.start + 0 | 0]);
    let _tmp = 1;
    while (true) {
      const _p$3 = _tmp;
      if (_p$3 < _p) {
        if (_p$3 >>> 0 < _p$2.length) {
          _p$2[_p$3] = array.buf[array.start + _p$3 | 0];
        } else {
          $oob();
        }
        _tmp = _p$3 + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _p$2;
  }
}
function _M0MPC15array10FixedArray11from__arrayGUsRP26mizchi8js__core3AnyEE(array) {
  const _p = array.end - array.start | 0;
  if (_p <= 0) {
    return [];
  } else {
    const _p$2 = $make_array_len_and_init(_p, array.buf[array.start + 0 | 0]);
    let _tmp = 1;
    while (true) {
      const _p$3 = _tmp;
      if (_p$3 < _p) {
        if (_p$3 >>> 0 < _p$2.length) {
          _p$2[_p$3] = array.buf[array.start + _p$3 | 0];
        } else {
          $oob();
        }
        _tmp = _p$3 + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _p$2;
  }
}
function _M0MPC15array10FixedArray11from__arrayGdE(array) {
  const _p = array.end - array.start | 0;
  if (_p <= 0) {
    return [];
  } else {
    const _p$2 = $make_array_len_and_init(_p, array.buf[array.start + 0 | 0]);
    let _tmp = 1;
    while (true) {
      const _p$3 = _tmp;
      if (_p$3 < _p) {
        if (_p$3 >>> 0 < _p$2.length) {
          _p$2[_p$3] = array.buf[array.start + _p$3 | 0];
        } else {
          $oob();
        }
        _tmp = _p$3 + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _p$2;
  }
}
function _M0MPC15array10FixedArray11from__arrayGRP26mizchi8js__core3AnyE(array) {
  const _p = array.end - array.start | 0;
  if (_p <= 0) {
    return [];
  } else {
    const _p$2 = $make_array_len_and_init(_p, array.buf[array.start + 0 | 0]);
    let _tmp = 1;
    while (true) {
      const _p$3 = _tmp;
      if (_p$3 < _p) {
        if (_p$3 >>> 0 < _p$2.length) {
          _p$2[_p$3] = array.buf[array.start + _p$3 | 0];
        } else {
          $oob();
        }
        _tmp = _p$3 + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _p$2;
  }
}
function _M0MPC15array5Array20unsafe__make__uninitGdE(len) {
  return new _M0TPB5ArrayGdE(new Array(len), len);
}
function _M0MPC15array5Array20unsafe__make__uninitGbE(len) {
  return new _M0TPB5ArrayGbE(new Array(len), len);
}
function _M0MPC15array5Array20unsafe__make__uninitGRP26mizchi8js__core3AnyE(len) {
  return new _M0TPB5ArrayGRP26mizchi8js__core3AnyE(new Array(len), len);
}
function _M0IPC16option6OptionPB2Eq5equalGsE(self, other) {
  if (self === undefined) {
    return other === undefined;
  } else {
    const _Some = self;
    const _x = _Some;
    if (other === undefined) {
      return false;
    } else {
      const _Some$2 = other;
      const _y = _Some$2;
      return _x === _y;
    }
  }
}
function _M0IPC16option6OptionPB2Eq5equalGdE(self, other) {
  if (self.$tag === 0) {
    if (other.$tag === 0) {
      return true;
    } else {
      return false;
    }
  } else {
    const _Some = self;
    const _x = _Some._0;
    if (other.$tag === 1) {
      const _Some$2 = other;
      const _y = _Some$2._0;
      return _x === _y;
    } else {
      return false;
    }
  }
}
function _M0MPC16double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0IPC16double6DoublePB3Mod3mod(self, other) {
  return _M0MPC16double6Double8mod__ffi(self, other);
}
function _M0MPC16double6Double3min(self, other) {
  return self !== self ? other : other !== other ? self : self < other ? self : other;
}
function _M0MPC16double6Double3max(self, other) {
  return self !== self ? other : other !== other ? self : self > other ? self : other;
}
function _M0MPC15array5Array44unsafe__make__and__blit__from__fixed_2einnerGRP26mizchi8js__core3AnyE(src, allocate_len, len, src_offset, dst_offset) {
  return new _M0TPB5ArrayGRP26mizchi8js__core3AnyE(_M0MPB18UninitializedArray36unsafe__make__and__blit__from__fixedGRP26mizchi8js__core3AnyE(src, allocate_len, src_offset, dst_offset, len), allocate_len);
}
function _M0MPC15array12MutArrayView4swapGUisEE(arr, i, j) {
  const temp = arr.buf[arr.start + i | 0];
  arr.buf[arr.start + i | 0] = arr.buf[arr.start + j | 0];
  arr.buf[arr.start + j | 0] = temp;
}
function _M0MPC15array12MutArrayView4swapGdE(arr, i, j) {
  const temp = arr.buf[arr.start + i | 0];
  arr.buf[arr.start + i | 0] = arr.buf[arr.start + j | 0];
  arr.buf[arr.start + j | 0] = temp;
}
function _M0MPC15array12MutArrayView5sliceGUisEE(arr, start, end) {
  const _bind = arr.end - arr.start | 0;
  if (start < 0 || (start > end || end > _bind)) {
    $panic();
  }
  return new _M0TPB12MutArrayViewGUisEE(arr.buf, start + arr.start | 0, end + arr.start | 0);
}
function _M0MPC15array12MutArrayView5sliceGdE(arr, start, end) {
  const _bind = arr.end - arr.start | 0;
  if (start < 0 || (start > end || end > _bind)) {
    $panic();
  }
  return new _M0TPB12MutArrayViewGdE(arr.buf, start + arr.start | 0, end + arr.start | 0);
}
function _M0MPC15array5Array28unsafe__truncate__to__lengthGUdRP26mizchi8js__core3AnyEE(self, new_len) {
  if (new_len <= self.len) {
    self.len = new_len;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array28unsafe__truncate__to__lengthGRP26mizchi8js__core3AnyE(self, new_len) {
  if (new_len <= self.len) {
    self.len = new_len;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array6removeGUdRP26mizchi8js__core3AnyEE(self, index) {
  if (index >= 0 && index < self.len) {
    const value = self.buf[index];
    _M0MPB18UninitializedArray12unsafe__blitGUisEE(self.buf, index, self.buf, index + 1 | 0, (self.len - index | 0) - 1 | 0);
    _M0MPC15array5Array28unsafe__truncate__to__lengthGUdRP26mizchi8js__core3AnyEE(self, self.len - 1 | 0);
    return value;
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(60);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "index out of bounds: the len is from 0 to ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " but the index is ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, index);
    return $panic(_string_builder.val);
  }
}
function _M0MPC15array5Array6removeGRP26mizchi8js__core3AnyE(self, index) {
  if (index >= 0 && index < self.len) {
    const value = self.buf[index];
    _M0MPB18UninitializedArray12unsafe__blitGRP26mizchi8js__core3AnyE(self.buf, index, self.buf, index + 1 | 0, (self.len - index | 0) - 1 | 0);
    _M0MPC15array5Array28unsafe__truncate__to__lengthGRP26mizchi8js__core3AnyE(self, self.len - 1 | 0);
    return value;
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(60);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "index out of bounds: the len is from 0 to ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " but the index is ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, index);
    return $panic(_string_builder.val);
  }
}
function _M0MPC15array12MutArrayView14rev__in__placeGUisEE(arr) {
  const len = arr.end - arr.start | 0;
  const mid_len = len / 2 | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < mid_len) {
      const j = (len - i | 0) - 1 | 0;
      const temp = arr.buf[arr.start + i | 0];
      arr.buf[arr.start + i | 0] = arr.buf[arr.start + j | 0];
      arr.buf[arr.start + j | 0] = temp;
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MPC15array12MutArrayView14rev__in__placeGdE(arr) {
  const len = arr.end - arr.start | 0;
  const mid_len = len / 2 | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < mid_len) {
      const j = (len - i | 0) - 1 | 0;
      const temp = arr.buf[arr.start + i | 0];
      arr.buf[arr.start + i | 0] = arr.buf[arr.start + j | 0];
      arr.buf[arr.start + j | 0] = temp;
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB17fixed__get__limit(len) {
  let _tmp = len;
  let _tmp$2 = 0;
  while (true) {
    const len$2 = _tmp;
    const limit = _tmp$2;
    if (len$2 > 0) {
      _tmp = len$2 / 2 | 0;
      _tmp$2 = limit + 1 | 0;
      continue;
    } else {
      return limit;
    }
  }
}
function _M0FPB19fixed__bubble__sortGdE(arr) {
  const _bind = arr.end - arr.start | 0;
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      let _tmp$2 = i;
      while (true) {
        const j = _tmp$2;
        if (j > 0 && arr.buf[arr.start + (j - 1 | 0) | 0] > arr.buf[arr.start + j | 0]) {
          _M0MPC15array12MutArrayView4swapGdE(arr, j, j - 1 | 0);
          _tmp$2 = j - 1 | 0;
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
function _M0FPB20fixed__choose__pivotN7sort__2S544GdE(_env, a, b) {
  const arr = _env._1;
  const swaps = _env._0;
  if (arr.buf[arr.start + a | 0] > arr.buf[arr.start + b | 0]) {
    _M0MPC15array12MutArrayView4swapGdE(arr, a, b);
    swaps.val = swaps.val + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0FPB20fixed__choose__pivotN7sort__3S545GdE(_env, a, b, c) {
  _M0FPB20fixed__choose__pivotN7sort__2S544GdE(_env, a, b);
  _M0FPB20fixed__choose__pivotN7sort__2S544GdE(_env, b, c);
  _M0FPB20fixed__choose__pivotN7sort__2S544GdE(_env, a, b);
}
function _M0FPB20fixed__choose__pivotGdE(arr) {
  const len = arr.end - arr.start | 0;
  const swaps = new _M0TPB8MutLocalGiE(0);
  const b = Math.imul(len / 4 | 0, 2) | 0;
  if (len >= 8) {
    const a = Math.imul(len / 4 | 0, 1) | 0;
    const c = Math.imul(len / 4 | 0, 3) | 0;
    const _env = { _0: swaps, _1: arr };
    if (len > 50) {
      _M0FPB20fixed__choose__pivotN7sort__3S545GdE(_env, a - 1 | 0, a, a + 1 | 0);
      _M0FPB20fixed__choose__pivotN7sort__3S545GdE(_env, b - 1 | 0, b, b + 1 | 0);
      _M0FPB20fixed__choose__pivotN7sort__3S545GdE(_env, c - 1 | 0, c, c + 1 | 0);
    }
    _M0FPB20fixed__choose__pivotN7sort__3S545GdE(_env, a, b, c);
  }
  if (swaps.val === 12) {
    _M0MPC15array12MutArrayView14rev__in__placeGdE(arr);
    return { _0: (len - b | 0) - 1 | 0, _1: true };
  } else {
    return { _0: b, _1: swaps.val === 0 };
  }
}
function _M0FPB17fixed__sift__downGdE(arr, index) {
  const len = arr.end - arr.start | 0;
  let _tmp = index;
  let _tmp$2 = (Math.imul(index, 2) | 0) + 1 | 0;
  while (true) {
    const index$2 = _tmp;
    const child = _tmp$2;
    if (child < len) {
      const child$2 = (child + 1 | 0) < len && arr.buf[arr.start + child | 0] < arr.buf[arr.start + (child + 1 | 0) | 0] ? child + 1 | 0 : child;
      if (arr.buf[arr.start + index$2 | 0] >= arr.buf[arr.start + child$2 | 0]) {
        return undefined;
      }
      _M0MPC15array12MutArrayView4swapGdE(arr, index$2, child$2);
      _tmp = child$2;
      _tmp$2 = (Math.imul(child$2, 2) | 0) + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB17fixed__heap__sortGdE(arr) {
  const len = arr.end - arr.start | 0;
  const _bind = len / 2 | 0;
  let _tmp = _bind - 1 | 0;
  let _tmp$2 = _bind > 0;
  while (true) {
    const i = _tmp;
    const _more = _tmp$2;
    if (_more) {
      _M0FPB17fixed__sift__downGdE(arr, i);
      _tmp = i - 1 | 0;
      _tmp$2 = i > 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$3 = len - 1 | 0;
  let _tmp$4 = len > 1;
  while (true) {
    const i = _tmp$3;
    const _more = _tmp$4;
    if (_more) {
      _M0MPC15array12MutArrayView4swapGdE(arr, 0, i);
      _M0FPB17fixed__sift__downGdE(_M0MPC15array12MutArrayView5sliceGdE(arr, 0, i), 0);
      _tmp$3 = i - 1 | 0;
      _tmp$4 = i > 1;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB16fixed__partitionGdE(arr, pivot_index) {
  _M0MPC15array12MutArrayView4swapGdE(arr, pivot_index, (arr.end - arr.start | 0) - 1 | 0);
  const pivot = arr.buf[arr.start + ((arr.end - arr.start | 0) - 1 | 0) | 0];
  const _bind = (arr.end - arr.start | 0) - 1 | 0;
  let _tmp = 0;
  let _tmp$2 = 0;
  let _tmp$3 = true;
  while (true) {
    const j = _tmp;
    const i = _tmp$2;
    const partitioned = _tmp$3;
    if (j < _bind) {
      if (arr.buf[arr.start + j | 0] < pivot) {
        if (i !== j) {
          _M0MPC15array12MutArrayView4swapGdE(arr, i, j);
          _tmp = j + 1 | 0;
          _tmp$2 = i + 1 | 0;
          _tmp$3 = false;
          continue;
        } else {
          _tmp = j + 1 | 0;
          _tmp$2 = i + 1 | 0;
          continue;
        }
      } else {
        _tmp = j + 1 | 0;
        continue;
      }
    } else {
      _M0MPC15array12MutArrayView4swapGdE(arr, i, (arr.end - arr.start | 0) - 1 | 0);
      return { _0: i, _1: partitioned };
    }
  }
}
function _M0FPB24fixed__try__bubble__sortGdE(arr) {
  const _bind = arr.end - arr.start | 0;
  let _tmp = 1;
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp;
    const tries = _tmp$2;
    if (i < _bind) {
      let sorted;
      let _tmp$3 = i;
      let _tmp$4 = true;
      while (true) {
        const j = _tmp$3;
        const sorted$2 = _tmp$4;
        if (j > 0 && arr.buf[arr.start + (j - 1 | 0) | 0] > arr.buf[arr.start + j | 0]) {
          _M0MPC15array12MutArrayView4swapGdE(arr, j, j - 1 | 0);
          _tmp$3 = j - 1 | 0;
          _tmp$4 = false;
          continue;
        } else {
          sorted = sorted$2;
          break;
        }
      }
      if (!sorted) {
        const tries$2 = tries + 1 | 0;
        if (tries$2 > 8) {
          return false;
        }
        _tmp = i + 1 | 0;
        _tmp$2 = tries$2;
        continue;
      } else {
        _tmp = i + 1 | 0;
        continue;
      }
    } else {
      return true;
    }
  }
}
function _M0FPB18fixed__quick__sortGdE(arr, pred, limit) {
  let _tmp = limit;
  let _tmp$2 = arr;
  let _tmp$3 = pred;
  let _tmp$4 = true;
  let _tmp$5 = true;
  while (true) {
    const limit$2 = _tmp;
    const arr$2 = _tmp$2;
    const pred$2 = _tmp$3;
    const was_partitioned = _tmp$4;
    const balanced = _tmp$5;
    const len = arr$2.end - arr$2.start | 0;
    if (len <= 16) {
      if (len >= 2) {
        _M0FPB19fixed__bubble__sortGdE(arr$2);
      }
      return undefined;
    }
    if (limit$2 === 0) {
      _M0FPB17fixed__heap__sortGdE(arr$2);
      return undefined;
    }
    const _bind = _M0FPB20fixed__choose__pivotGdE(arr$2);
    const _pivot_index = _bind._0;
    const _likely_sorted = _bind._1;
    if (was_partitioned && (balanced && _likely_sorted)) {
      if (_M0FPB24fixed__try__bubble__sortGdE(arr$2)) {
        return undefined;
      }
    }
    const _bind$2 = _M0FPB16fixed__partitionGdE(arr$2, _pivot_index);
    const _pivot = _bind$2._0;
    const _partitioned = _bind$2._1;
    const _p = len - _pivot | 0;
    const balanced$2 = (_pivot > _p ? _p : _pivot) >= (len / 8 | 0);
    const limit$3 = !balanced$2 ? limit$2 - 1 | 0 : limit$2;
    if (pred$2.$tag === 1) {
      const _Some = pred$2;
      const _p$2 = _Some._0;
      if (_p$2 === arr$2.buf[arr$2.start + _pivot | 0]) {
        let i;
        let _tmp$6 = _pivot;
        while (true) {
          const i$2 = _tmp$6;
          if (i$2 < len && _p$2 === arr$2.buf[arr$2.start + i$2 | 0]) {
            _tmp$6 = i$2 + 1 | 0;
            continue;
          } else {
            i = i$2;
            break;
          }
        }
        _tmp = limit$3;
        _tmp$2 = _M0MPC15array12MutArrayView5sliceGdE(arr$2, i, len);
        _tmp$4 = _partitioned;
        _tmp$5 = balanced$2;
        continue;
      }
    }
    const left = _M0MPC15array12MutArrayView5sliceGdE(arr$2, 0, _pivot);
    const right = _M0MPC15array12MutArrayView5sliceGdE(arr$2, _pivot + 1 | 0, len);
    if ((left.end - left.start | 0) < (right.end - right.start | 0)) {
      _M0FPB18fixed__quick__sortGdE(left, pred$2, limit$3);
      _tmp = limit$3;
      _tmp$2 = right;
      _tmp$3 = new _M0DTPC16option6OptionGdE4Some(arr$2.buf[arr$2.start + _pivot | 0]);
      _tmp$4 = _partitioned;
      _tmp$5 = balanced$2;
      continue;
    } else {
      _M0FPB18fixed__quick__sortGdE(right, new _M0DTPC16option6OptionGdE4Some(arr$2.buf[arr$2.start + _pivot | 0]), limit$3);
      _tmp = limit$3;
      _tmp$2 = left;
      _tmp$4 = _partitioned;
      _tmp$5 = balanced$2;
      continue;
    }
  }
}
function _M0MPC15array12MutArrayView4sortGdE(self) {
  _M0FPB18fixed__quick__sortGdE(self, _M0DTPC16option6OptionGdE4None__, _M0FPB17fixed__get__limit(self.end - self.start | 0));
}
function _M0FPB23fixed__bubble__sort__byGUisEE(arr, cmp) {
  const _bind = arr.end - arr.start | 0;
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      let _tmp$2 = i;
      while (true) {
        const j = _tmp$2;
        if (j > 0 && cmp(arr.buf[arr.start + (j - 1 | 0) | 0], arr.buf[arr.start + j | 0]) > 0) {
          _M0MPC15array12MutArrayView4swapGUisEE(arr, j, j - 1 | 0);
          _tmp$2 = j - 1 | 0;
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
function _M0FPB24fixed__choose__pivot__byN7sort__2S629GUisEE(_env, a, b) {
  const swaps = _env._2;
  const cmp = _env._1;
  const arr = _env._0;
  if (cmp(arr.buf[arr.start + a | 0], arr.buf[arr.start + b | 0]) > 0) {
    _M0MPC15array12MutArrayView4swapGUisEE(arr, a, b);
    swaps.val = swaps.val + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0FPB24fixed__choose__pivot__byN7sort__3S630GUisEE(_env, a, b, c) {
  _M0FPB24fixed__choose__pivot__byN7sort__2S629GUisEE(_env, a, b);
  _M0FPB24fixed__choose__pivot__byN7sort__2S629GUisEE(_env, b, c);
  _M0FPB24fixed__choose__pivot__byN7sort__2S629GUisEE(_env, a, b);
}
function _M0FPB24fixed__choose__pivot__byGUisEE(arr, cmp) {
  const len = arr.end - arr.start | 0;
  const swaps = new _M0TPB8MutLocalGiE(0);
  const b = Math.imul(len / 4 | 0, 2) | 0;
  if (len >= 8) {
    const a = Math.imul(len / 4 | 0, 1) | 0;
    const c = Math.imul(len / 4 | 0, 3) | 0;
    const _env = { _0: arr, _1: cmp, _2: swaps };
    if (len > 50) {
      _M0FPB24fixed__choose__pivot__byN7sort__3S630GUisEE(_env, a - 1 | 0, a, a + 1 | 0);
      _M0FPB24fixed__choose__pivot__byN7sort__3S630GUisEE(_env, b - 1 | 0, b, b + 1 | 0);
      _M0FPB24fixed__choose__pivot__byN7sort__3S630GUisEE(_env, c - 1 | 0, c, c + 1 | 0);
    }
    _M0FPB24fixed__choose__pivot__byN7sort__3S630GUisEE(_env, a, b, c);
  }
  if (swaps.val === 12) {
    _M0MPC15array12MutArrayView14rev__in__placeGUisEE(arr);
    return { _0: (len - b | 0) - 1 | 0, _1: true };
  } else {
    return { _0: b, _1: swaps.val === 0 };
  }
}
function _M0FPB21fixed__sift__down__byGUisEE(arr, index, cmp) {
  const len = arr.end - arr.start | 0;
  let _tmp = index;
  let _tmp$2 = (Math.imul(index, 2) | 0) + 1 | 0;
  while (true) {
    const index$2 = _tmp;
    const child = _tmp$2;
    if (child < len) {
      const child$2 = (child + 1 | 0) < len && cmp(arr.buf[arr.start + child | 0], arr.buf[arr.start + (child + 1 | 0) | 0]) < 0 ? child + 1 | 0 : child;
      if (cmp(arr.buf[arr.start + index$2 | 0], arr.buf[arr.start + child$2 | 0]) >= 0) {
        return undefined;
      }
      _M0MPC15array12MutArrayView4swapGUisEE(arr, index$2, child$2);
      _tmp = child$2;
      _tmp$2 = (Math.imul(child$2, 2) | 0) + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB21fixed__heap__sort__byGUisEE(arr, cmp) {
  const len = arr.end - arr.start | 0;
  const _bind = len / 2 | 0;
  let _tmp = _bind - 1 | 0;
  let _tmp$2 = _bind > 0;
  while (true) {
    const i = _tmp;
    const _more = _tmp$2;
    if (_more) {
      _M0FPB21fixed__sift__down__byGUisEE(arr, i, cmp);
      _tmp = i - 1 | 0;
      _tmp$2 = i > 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$3 = len - 1 | 0;
  let _tmp$4 = len > 1;
  while (true) {
    const i = _tmp$3;
    const _more = _tmp$4;
    if (_more) {
      _M0MPC15array12MutArrayView4swapGUisEE(arr, 0, i);
      _M0FPB21fixed__sift__down__byGUisEE(_M0MPC15array12MutArrayView5sliceGUisEE(arr, 0, i), 0, cmp);
      _tmp$3 = i - 1 | 0;
      _tmp$4 = i > 1;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB20fixed__partition__byGUisEE(arr, cmp, pivot_index) {
  _M0MPC15array12MutArrayView4swapGUisEE(arr, pivot_index, (arr.end - arr.start | 0) - 1 | 0);
  const pivot = arr.buf[arr.start + ((arr.end - arr.start | 0) - 1 | 0) | 0];
  const _bind = (arr.end - arr.start | 0) - 1 | 0;
  let _tmp = 0;
  let _tmp$2 = 0;
  let _tmp$3 = true;
  while (true) {
    const j = _tmp;
    const i = _tmp$2;
    const partitioned = _tmp$3;
    if (j < _bind) {
      if (cmp(arr.buf[arr.start + j | 0], pivot) < 0) {
        if (i !== j) {
          _M0MPC15array12MutArrayView4swapGUisEE(arr, i, j);
          _tmp = j + 1 | 0;
          _tmp$2 = i + 1 | 0;
          _tmp$3 = false;
          continue;
        } else {
          _tmp = j + 1 | 0;
          _tmp$2 = i + 1 | 0;
          continue;
        }
      } else {
        _tmp = j + 1 | 0;
        continue;
      }
    } else {
      _M0MPC15array12MutArrayView4swapGUisEE(arr, i, (arr.end - arr.start | 0) - 1 | 0);
      return { _0: i, _1: partitioned };
    }
  }
}
function _M0FPB28fixed__try__bubble__sort__byGUisEE(arr, cmp) {
  const _bind = arr.end - arr.start | 0;
  let _tmp = 1;
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp;
    const tries = _tmp$2;
    if (i < _bind) {
      let sorted;
      let _tmp$3 = i;
      let _tmp$4 = true;
      while (true) {
        const j = _tmp$3;
        const sorted$2 = _tmp$4;
        if (j > 0 && cmp(arr.buf[arr.start + (j - 1 | 0) | 0], arr.buf[arr.start + j | 0]) > 0) {
          _M0MPC15array12MutArrayView4swapGUisEE(arr, j, j - 1 | 0);
          _tmp$3 = j - 1 | 0;
          _tmp$4 = false;
          continue;
        } else {
          sorted = sorted$2;
          break;
        }
      }
      if (!sorted) {
        const tries$2 = tries + 1 | 0;
        if (tries$2 > 8) {
          return false;
        }
        _tmp = i + 1 | 0;
        _tmp$2 = tries$2;
        continue;
      } else {
        _tmp = i + 1 | 0;
        continue;
      }
    } else {
      return true;
    }
  }
}
function _M0FPB22fixed__quick__sort__byGUisEE(arr, cmp, pred, limit) {
  let _tmp = limit;
  let _tmp$2 = arr;
  let _tmp$3 = pred;
  let _tmp$4 = true;
  let _tmp$5 = true;
  while (true) {
    const limit$2 = _tmp;
    const arr$2 = _tmp$2;
    const pred$2 = _tmp$3;
    const was_partitioned = _tmp$4;
    const balanced = _tmp$5;
    const len = arr$2.end - arr$2.start | 0;
    if (len <= 16) {
      if (len >= 2) {
        _M0FPB23fixed__bubble__sort__byGUisEE(arr$2, cmp);
      }
      return undefined;
    }
    if (limit$2 === 0) {
      _M0FPB21fixed__heap__sort__byGUisEE(arr$2, cmp);
      return undefined;
    }
    const _bind = _M0FPB24fixed__choose__pivot__byGUisEE(arr$2, cmp);
    const _pivot_index = _bind._0;
    const _likely_sorted = _bind._1;
    if (was_partitioned && (balanced && _likely_sorted)) {
      if (_M0FPB28fixed__try__bubble__sort__byGUisEE(arr$2, cmp)) {
        return undefined;
      }
    }
    const _bind$2 = _M0FPB20fixed__partition__byGUisEE(arr$2, cmp, _pivot_index);
    const _pivot = _bind$2._0;
    const _partitioned = _bind$2._1;
    const _p = len - _pivot | 0;
    const balanced$2 = (_pivot > _p ? _p : _pivot) >= (len / 8 | 0);
    const limit$3 = !balanced$2 ? limit$2 - 1 | 0 : limit$2;
    if (pred$2 === undefined) {
    } else {
      const _Some = pred$2;
      const _p$2 = _Some;
      if (cmp(_p$2, arr$2.buf[arr$2.start + _pivot | 0]) === 0) {
        let i;
        let _tmp$6 = _pivot;
        while (true) {
          const i$2 = _tmp$6;
          if (i$2 < len && cmp(_p$2, arr$2.buf[arr$2.start + i$2 | 0]) === 0) {
            _tmp$6 = i$2 + 1 | 0;
            continue;
          } else {
            i = i$2;
            break;
          }
        }
        _tmp = limit$3;
        _tmp$2 = _M0MPC15array12MutArrayView5sliceGUisEE(arr$2, i, len);
        _tmp$4 = _partitioned;
        _tmp$5 = balanced$2;
        continue;
      }
    }
    const left = _M0MPC15array12MutArrayView5sliceGUisEE(arr$2, 0, _pivot);
    const right = _M0MPC15array12MutArrayView5sliceGUisEE(arr$2, _pivot + 1 | 0, len);
    if ((left.end - left.start | 0) < (right.end - right.start | 0)) {
      _M0FPB22fixed__quick__sort__byGUisEE(left, cmp, pred$2, limit$3);
      _tmp = limit$3;
      _tmp$2 = right;
      _tmp$3 = arr$2.buf[arr$2.start + _pivot | 0];
      _tmp$4 = _partitioned;
      _tmp$5 = balanced$2;
      continue;
    } else {
      _M0FPB22fixed__quick__sort__byGUisEE(right, cmp, arr$2.buf[arr$2.start + _pivot | 0], limit$3);
      _tmp = limit$3;
      _tmp$2 = left;
      _tmp$4 = _partitioned;
      _tmp$5 = balanced$2;
      continue;
    }
  }
}
function _M0MPC15array12MutArrayView8sort__byGUisEE(self, cmp) {
  _M0FPB22fixed__quick__sort__byGUisEE(self, cmp, undefined, _M0FPB17fixed__get__limit(self.end - self.start | 0));
}
function _M0MPC15array5Array4sortGdE(self) {
  const _bind = self.len;
  _M0MPC15array12MutArrayView4sortGdE(new _M0TPB12MutArrayViewGdE(self.buf, 0, _bind));
}
function _M0MPC15array5Array8sort__byGUisEE(self, cmp) {
  const _bind = self.len;
  _M0MPC15array12MutArrayView8sort__byGUisEE(new _M0TPB12MutArrayViewGUisEE(self.buf, 0, _bind), cmp);
}
function _M0MPC15array5Array12unsafe__blitGdE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGdEE(dst.buf, dst_offset, src.buf, src_offset, len);
}
function _M0MPC15array5Array4copyGdE(self) {
  const len = self.len;
  if (len === 0) {
    return new _M0TPB5ArrayGdE([], 0);
  }
  const arr = _M0MPC15array5Array20unsafe__make__uninitGdE(len);
  _M0MPC15array5Array12unsafe__blitGdE(arr, 0, self, 0, len);
  return arr;
}
function _M0MPC15array5Array18from__fixed__arrayGRP26mizchi8js__core3AnyE(arr) {
  const len = arr.length;
  return _M0MPC15array5Array44unsafe__make__and__blit__from__fixed_2einnerGRP26mizchi8js__core3AnyE(arr, len, len, 0, 0);
}
function _M0MPC15array5Array5clearGUdRP26mizchi8js__core3AnyEE(self) {
  _M0MPC15array5Array28unsafe__truncate__to__lengthGUdRP26mizchi8js__core3AnyEE(self, 0);
}
function _M0MPC15array5Array5clearGRP26mizchi8js__core3AnyE(self) {
  _M0MPC15array5Array28unsafe__truncate__to__lengthGRP26mizchi8js__core3AnyE(self, 0);
}
function _M0MPC15array5Array8containsGiE(self, value) {
  const _bind = self.len;
  const _bind$2 = self.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = _bind$2[_];
      if (v === value) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return false;
    }
  }
}
function _M0MPC15array5Array8containsGbE(self, value) {
  const _bind = self.len;
  const _bind$2 = self.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = _bind$2[_];
      if (v === value) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return false;
    }
  }
}
function _M0MPC15array5Array8containsGRP26mizchi8js__core3AnyE(self, value) {
  const _bind = self.len;
  const _bind$2 = self.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = _bind$2[_];
      if (_M0IP26mizchi8js__core3AnyPB2Eq5equal(v, value)) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return false;
    }
  }
}
function _M0MPC13ref3Ref3RefGORP26mizchi8js__core3AnyE(x) {
  return new _M0TPC13ref3RefGORP26mizchi8js__core3AnyE(x);
}
function _M0FP26mizchi8js__core13from__entries(entries) {
  return _M0FP26mizchi8js__core18ffi__from__entries(_M0MPC15array10FixedArray11from__arrayGUsRP26mizchi8js__core3AnyEE(new _M0TPB9ArrayViewGUsRP26mizchi8js__core3AnyEE(entries.buf, 0, entries.len)));
}
function _M0FP26mizchi8js__core11array__from(v) {
  return _M0MPC15array5Array18from__fixed__arrayGRP26mizchi8js__core3AnyE(_M0FP26mizchi8js__core16ffi__array__from(v));
}
function _M0IP26mizchi8js__core3AnyPB2Eq5equal(self, other) {
  return _M0FP26mizchi8js__core5equal(self, other);
}
function _M0MP36mizchi11js__builtin6object6Object4is__(a, b) {
  return _M0MP26mizchi8js__core3Any6__call(_M0FP36mizchi11js__builtin6object13object__class(), "is", [a, b]);
}
function _M0MP36mizchi11js__builtin6object6Object6freeze(obj) {
  return _M0MP26mizchi8js__core3Any6__call(_M0FP36mizchi11js__builtin6object13object__class(), "freeze", [obj]);
}
function _M0FP36mizchi12kagura__core10statistics10percentile(values, p) {
  if (values.len === 0) {
    return 0;
  }
  const sorted = _M0MPC15array5Array4copyGdE(values);
  _M0MPC15array5Array4sortGdE(sorted);
  const _p = _M0MPC16double6Double7to__int((sorted.len + 0) * p);
  const _p$2 = _p > 0 ? _p : 0;
  const _p$3 = sorted.len - 1 | 0;
  const _bind = _p$2 < _p$3 ? _p$2 : _p$3;
  if (_bind < 0 || _bind >= sorted.len) {
    $panic();
  }
  return sorted.buf[_bind];
}
function _M0FP36mizchi12kagura__core10statistics20summarize__intervals(values) {
  const intervals = new _M0TPB5ArrayGdE([], 0);
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < values.len) {
      if (i < 0 || i >= values.len) {
        $panic();
      }
      const _tmp$2 = values.buf[i];
      const _bind = i - 1 | 0;
      if (_bind < 0 || _bind >= values.len) {
        $panic();
      }
      _M0MPC15array5Array4pushGdE(intervals, _tmp$2 - values.buf[_bind]);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let elapsed;
  if (values.len > 1) {
    const _bind = values.len - 1 | 0;
    if (_bind < 0 || _bind >= values.len) {
      $panic();
    }
    const _tmp$2 = values.buf[_bind];
    if (0 >= values.len) {
      $panic();
    }
    elapsed = _tmp$2 - values.buf[0];
  } else {
    elapsed = 0;
  }
  return new _M0TP36mizchi12kagura__core10statistics15IntervalSummary(values.len, elapsed, elapsed > 0 ? (intervals.len + 0) / (elapsed / 1000) : 0, _M0FP36mizchi12kagura__core10statistics10percentile(intervals, 0.5), _M0FP36mizchi12kagura__core10statistics10percentile(intervals, 0.95));
}
function _M0FP36mizchi21kagura__platform__web7interop5field(value, key) {
  return _M0FP26mizchi8js__core11is__nullish(value) ? _M0FP26mizchi8js__core9undefined() : _M0MP26mizchi8js__core3Any5__get(value, key);
}
function _M0FP36mizchi21kagura__platform__web7interop8fallback(value, default_) {
  return _M0FP26mizchi8js__core11is__nullish(value) ? default_ : value;
}
function _M0FP36mizchi21kagura__platform__web7interop8argument(value, default_) {
  return _M0FP26mizchi8js__core13is__undefined(value) ? default_ : value;
}
function _M0FP36mizchi21kagura__platform__web7interop13number__field(value, key, default_) {
  return _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(value, key), default_);
}
function _M0FP36mizchi21kagura__platform__web7interop13array__values(value) {
  return _M0FP26mizchi8js__core11is__nullish(value) ? new _M0TPB5ArrayGRP26mizchi8js__core3AnyE([], 0) : _M0FP26mizchi8js__core11array__from(value);
}
function _M0FP36mizchi21kagura__platform__web7interop5clamp(value, low, high) {
  return _M0MPC16double6Double3min(_M0MPC16double6Double3max(value, low), high);
}
function _M0FP36mizchi21kagura__platform__web7interop6vector(x, y) {
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "x", _1: x }, { _0: "y", _1: y }], 2));
}
function _M0FP36mizchi21kagura__platform__web7interop6length(value) {
  return _M0MP26mizchi8js__core3Any5__get(value, "length");
}
function _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGiE(values) {
  return _M0MPC15array10FixedArray11from__arrayGiE(new _M0TPB9ArrayViewGiE(values.buf, 0, values.len));
}
function _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGdE(values) {
  return _M0MPC15array10FixedArray11from__arrayGdE(new _M0TPB9ArrayViewGdE(values.buf, 0, values.len));
}
function _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGRP26mizchi8js__core3AnyE(values) {
  return _M0MPC15array10FixedArray11from__arrayGRP26mizchi8js__core3AnyE(new _M0TPB9ArrayViewGRP26mizchi8js__core3AnyE(values.buf, 0, values.len));
}
function _M0FP36mizchi21kagura__platform__web11diagnostics10percentile(values, p) {
  const _p = _M0FP36mizchi21kagura__platform__web7interop13array__values(values);
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGdE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp = 0;
  while (true) {
    const _p$5 = _tmp;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = _p$6;
      _p$2.buf[_p$5] = _p$7;
      _tmp = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi12kagura__core10statistics10percentile(_p$2, p);
}
function _M0FP36mizchi21kagura__platform__web11diagnostics20summarize__intervals(timestamps) {
  const _p = _M0FP36mizchi21kagura__platform__web7interop13array__values(timestamps);
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGdE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp = 0;
  while (true) {
    const _p$5 = _tmp;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = _p$6;
      _p$2.buf[_p$5] = _p$7;
      _tmp = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const result = _M0FP36mizchi12kagura__core10statistics20summarize__intervals(_p$2);
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "frames", _1: result.frames }, { _0: "elapsedMs", _1: _M0MP36mizchi11js__builtin4math4Math5round(result.elapsed_ms) }, { _0: "fps", _1: _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal(result.fps, 1) }, { _0: "p50IntervalMs", _1: _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal(result.p50_ms, 2) }, { _0: "p95IntervalMs", _1: _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal(result.p95_ms, 2) }], 5));
}
function _M0FP36mizchi21kagura__platform__web11diagnostics6timing(value) {
  return _M0FP36mizchi21kagura__platform__web7interop6finite(value) && value >= 0 ? value : _M0FP26mizchi8js__core4null();
}
function _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profile(host) {
  const host$2 = _M0FP36mizchi21kagura__platform__web7interop8argument(host, _M0FP26mizchi8js__core12global__this());
  const runtime = _M0FP36mizchi21kagura__platform__web7interop5field(host$2, "__kaguraWebRuntime");
  const gpu = _M0FP36mizchi21kagura__platform__web7interop5field(runtime, "webgpu");
  if (!_M0FP36mizchi21kagura__platform__web7interop6truthy(gpu)) {
    return _M0FP26mizchi8js__core4null();
  }
  const phases = _M0FP36mizchi21kagura__platform__web7interop5field(runtime, "frameProfile");
  const commands = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "commands"));
  let indices = 0;
  let instances = 0;
  let shared = 0;
  const _bind = commands.len;
  const _bind$2 = commands.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const command = _bind$2[_];
      const _tmp$2 = indices;
      const _p = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(command, "indexCount"), _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(_M0FP36mizchi21kagura__platform__web7interop5field(command, "indices"), "length"), 0));
      indices = _tmp$2 + _p;
      instances = instances + _M0MPC16double6Double3max(_M0FP36mizchi21kagura__platform__web7interop13number__field(command, "instanceCount", 1), 1);
      if (_M0FP36mizchi21kagura__platform__web7interop6truthy(_M0FP36mizchi21kagura__platform__web7interop5field(command, "sharedGeometry"))) {
        shared = shared + 1 | 0;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const timing_method = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "_gpuTimingMethod"), _M0FP26mizchi8js__core4null());
  const snapshot = _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "version", _1: 1 }, { _0: "frame", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "_submittedFrameCount"), 0) }, { _0: "gpuFrameMs", _1: _M0FP26mizchi8js__core11is__nullish(timing_method) ? _M0FP26mizchi8js__core4null() : _M0FP36mizchi21kagura__platform__web11diagnostics6timing(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, _M0FP26mizchi8js__core5equal(timing_method, "timestamp-query") ? "_lastTimestampFrameMs" : "_lastCompletedFrameMs")) }, { _0: "gpuTimingMethod", _1: timing_method }, { _0: "drawCalls", _1: commands.len }, { _0: "indexCount", _1: indices }, { _0: "instanceCount", _1: instances }, { _0: "sharedGeometryDraws", _1: shared }, { _0: "residentGeometryBuffers", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(_M0FP36mizchi21kagura__platform__web7interop5field(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "_sharedGeometryBuffers"), "resident"), "size"), 0) }], 9));
  let _bind_buf = ["updateMs", "drawCallbackMs", "renderCommandsMs"];
  let _bind_len = 3;
  const _bind$3 = _bind_len;
  const _bind$4 = _bind_buf;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const key = _bind$4[_];
      _M0MP26mizchi8js__core3Any5__set(snapshot, key, _M0FP36mizchi21kagura__platform__web11diagnostics6timing(_M0FP36mizchi21kagura__platform__web7interop5field(phases, key)));
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _bind_buf$2 = [_M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS869, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS870, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS871, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS872, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS873];
  let _bind_len$2 = 5;
  const _bind$5 = _bind_len$2;
  const _bind$6 = _bind_buf$2;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$5) {
      const _foreach_element = _bind$6[_];
      const _key = _foreach_element._0;
      const _source = _foreach_element._1;
      _M0MP26mizchi8js__core3Any5__set(snapshot, _key, _M0FP36mizchi21kagura__platform__web11diagnostics6timing(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, _source)));
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MP36mizchi11js__builtin6object6Object6freeze(snapshot);
}
function _M0FP36mizchi21kagura__platform__web11diagnostics24install__frame__profiler(host) {
  const host$2 = _M0FP36mizchi21kagura__platform__web7interop8argument(host, _M0FP26mizchi8js__core12global__this());
  const profiler = _M0MP36mizchi11js__builtin6object6Object6freeze(_M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "version", _1: 1 }, { _0: "snapshot", _1: () => _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profile(host$2) }], 2)));
  _M0MP26mizchi8js__core3Any5__set(host$2, "__kaguraProfiler", profiler);
  return profiler;
}
function _M0MP36mizchi11js__builtin6regexp6RegExp6test__(self, string) {
  return _M0MP36mizchi11js__builtin6regexp6RegExp17ffi__regexp__test(self, string);
}
function _M0MP36mizchi11js__builtin6regexp6RegExp3new(pattern, flags) {
  let flags_str;
  if (flags === undefined) {
    flags_str = "";
  } else {
    const _Some = flags;
    flags_str = _Some;
  }
  return _M0FP36mizchi11js__builtin6regexp16ffi__regexp__new(pattern, flags_str);
}
function _M0FP36mizchi21kagura__platform__web5input9pad__axis(value) {
  return _M0FP36mizchi21kagura__platform__web7interop6finite(value) ? _M0FP36mizchi21kagura__platform__web7interop5clamp(value, -1, 1) : 0;
}
function _M0FP36mizchi21kagura__platform__web5input6button(pressed, value) {
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "pressed", _1: pressed }, { _0: "value", _1: value }], 2));
}
function _M0FP36mizchi21kagura__platform__web5input11pad__button(source) {
  const value = _M0FP36mizchi21kagura__platform__web7interop5field(source, "value");
  return _M0FP36mizchi21kagura__platform__web5input6button(_M0FP36mizchi21kagura__platform__web7interop6truthy(_M0FP36mizchi21kagura__platform__web7interop5field(source, "pressed")), _M0FP36mizchi21kagura__platform__web7interop6finite(value) ? _M0FP36mizchi21kagura__platform__web7interop5clamp(value, 0, 1) : 0);
}
function _M0FP36mizchi21kagura__platform__web5input12button__down(source) {
  const value = _M0FP36mizchi21kagura__platform__web7interop5field(source, "value");
  return _M0FP36mizchi21kagura__platform__web7interop6truthy(_M0FP36mizchi21kagura__platform__web7interop5field(source, "pressed")) || _M0FP36mizchi21kagura__platform__web7interop6finite(value) && value >= 0.55;
}
function _M0FP36mizchi21kagura__platform__web5input18normalize__gamepad(pad) {
  const mapping = _M0MP26mizchi8js__core3Any5__get(pad, "mapping");
  if (mapping === "standard") {
    return pad;
  }
  const axes = _M0MP26mizchi8js__core3Any5__get(pad, "axes");
  const raw_buttons = _M0MP26mizchi8js__core3Any5__get(pad, "buttons");
  let _tmp;
  const _p = "";
  if (!(mapping === _p)) {
    _tmp = true;
  } else {
    _tmp = !_M0MP36mizchi11js__builtin6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web5input11victrix__id, _M0MP26mizchi8js__core3Any5__get(pad, "id")) || (_M0FP36mizchi21kagura__platform__web7interop6length(axes) !== 10 || _M0FP36mizchi21kagura__platform__web7interop6length(raw_buttons) < 14);
  }
  if (_tmp) {
    return _M0FP26mizchi8js__core4null();
  }
  const order = new _M0TPB5ArrayGiE([1, 2, 0, 3, 4, 5, 6, 7, 8, 9, 10, 11, -1, -1, -1, -1, 12, 13], 18);
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGRP26mizchi8js__core3AnyE(order.len);
  const _p$3 = order.len;
  const _p$4 = order.buf;
  let _tmp$2 = 0;
  while (true) {
    const _p$5 = _tmp$2;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = _M0FP36mizchi21kagura__platform__web5input11pad__button(_p$6 < 0 ? _M0FP26mizchi8js__core4null() : _M0MP26mizchi8js__core3Any16__get__by__index(raw_buttons, _p$6));
      _p$2.buf[_p$5] = _p$7;
      _tmp$2 = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const buttons = _p$2;
  let _bind_buf = [_M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS923, _M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS924];
  let _bind_len = 2;
  const _bind = _bind_len;
  const _bind$2 = _bind_buf;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind) {
      const _foreach_element = _bind$2[_];
      const _axis_index = _foreach_element._0;
      const _button_index = _foreach_element._1;
      const raw = _M0MP26mizchi8js__core3Any16__get__by__index(axes, _axis_index);
      const value = _M0FP36mizchi21kagura__platform__web7interop6finite(raw) ? (_M0FP36mizchi21kagura__platform__web5input9pad__axis(raw) + 1) / 2 : 0;
      let _tmp$4;
      if (_button_index < 0 || _button_index >= buttons.len) {
        $panic();
      }
      if (_M0FP36mizchi21kagura__platform__web5input12button__down(buttons.buf[_button_index])) {
        _tmp$4 = true;
      } else {
        _tmp$4 = value >= 0.55;
      }
      const _bind$3 = _M0FP36mizchi21kagura__platform__web5input6button(_tmp$4, value);
      if (_button_index < 0 || _button_index >= buttons.len) {
        $panic();
      }
      buttons.buf[_button_index] = _bind$3;
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const hat = _M0MP26mizchi8js__core3Any16__get__by__index(axes, 9);
  if (_M0FP36mizchi21kagura__platform__web7interop6finite(hat) && (hat >= -1 && hat <= 1)) {
    const position = (hat + 1) * 3.5;
    const direction = _M0MP36mizchi11js__builtin4math4Math5round(position);
    if (Math.abs(position - (direction + 0)) < 0.1) {
      let hats_buf = [new _M0TPB5ArrayGiE([12], 1), new _M0TPB5ArrayGiE([12, 15], 2), new _M0TPB5ArrayGiE([15], 1), new _M0TPB5ArrayGiE([13, 15], 2), new _M0TPB5ArrayGiE([13], 1), new _M0TPB5ArrayGiE([13, 14], 2), new _M0TPB5ArrayGiE([14], 1), new _M0TPB5ArrayGiE([12, 14], 2)];
      let hats_len = 8;
      if (direction < 0 || direction >= hats_len) {
        $panic();
      }
      const _bind$3 = hats_buf[direction];
      const _bind$4 = _bind$3.len;
      const _bind$5 = _bind$3.buf;
      let _tmp$4 = 0;
      while (true) {
        const _ = _tmp$4;
        if (_ < _bind$4) {
          const index = _bind$5[_];
          const _bind$6 = _M0FP36mizchi21kagura__platform__web5input6button(true, 1);
          if (index < 0 || index >= buttons.len) {
            $panic();
          }
          buttons.buf[index] = _bind$6;
          _tmp$4 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
    }
  }
  const _tmp$4 = { _0: "index", _1: _M0MP26mizchi8js__core3Any5__get(pad, "index") };
  const _tmp$5 = { _0: "id", _1: _M0MP26mizchi8js__core3Any5__get(pad, "id") };
  const _tmp$6 = { _0: "connected", _1: _M0MP26mizchi8js__core3Any5__get(pad, "connected") };
  const _tmp$7 = { _0: "mapping", _1: "standard" };
  const _tmp$8 = { _0: "profile", _1: "victrix-pro-bfg-ps5-mac" };
  const _p$5 = new _M0TPB5ArrayGiE([0, 1, 2, 5], 4);
  const _p$6 = _M0MPC15array5Array20unsafe__make__uninitGdE(_p$5.len);
  const _p$7 = _p$5.len;
  const _p$8 = _p$5.buf;
  let _tmp$9 = 0;
  while (true) {
    const _p$9 = _tmp$9;
    if (_p$9 < _p$7) {
      const _p$10 = _p$8[_p$9];
      const _p$11 = _M0FP36mizchi21kagura__platform__web5input9pad__axis(_M0MP26mizchi8js__core3Any16__get__by__index(axes, _p$10));
      _p$6.buf[_p$9] = _p$11;
      _tmp$9 = _p$9 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([_tmp$4, _tmp$5, _tmp$6, _tmp$7, _tmp$8, { _0: "axes", _1: _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGdE(_p$6) }, { _0: "buttons", _1: _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGRP26mizchi8js__core3AnyE(buttons) }], 7));
}
function _M0FP36mizchi21kagura__platform__web5input11device__key(pad) {
  const index = _M0MP26mizchi8js__core3Any10to__string(_M0MP26mizchi8js__core3Any5__get(pad, "index"));
  const id = _M0MP26mizchi8js__core3Any5__get(pad, "id");
  const profile = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0MP26mizchi8js__core3Any5__get(pad, "profile"), _M0MP26mizchi8js__core3Any5__get(pad, "mapping"));
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(2);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, index);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ":");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, id);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ":");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, profile);
  return _string_builder.val;
}
function _M0FP36mizchi21kagura__platform__web5input13radial__stick(dx, dy, radius, dead_zone) {
  const length = _M0MP36mizchi11js__builtin4math4Math5hypot([dx, dy]);
  if (length === 0 || length < radius * dead_zone) {
    return _M0FP36mizchi21kagura__platform__web5input13radial__stickN5tupleS962;
  }
  const magnitude = _M0MPC16double6Double3min((length / radius - dead_zone) / (1 - dead_zone), 1);
  return { _0: dx / length * magnitude, _1: dy / length * magnitude };
}
function _M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS969(axes, i) {
  return _M0FP36mizchi21kagura__platform__web5input9pad__axis(_M0FP26mizchi8js__core11is__nullish(axes) ? _M0FP26mizchi8js__core9undefined() : _M0MP26mizchi8js__core3Any16__get__by__index(axes, i));
}
function _M0MP36mizchi21kagura__platform__web5input12GamepadState4step(self, pads, options) {
  const enabled = _M0FP36mizchi21kagura__platform__web7interop6truthy(_M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "enabled"), true));
  const _p = _M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "now"), 0);
  const now = _p;
  const _p$2 = _M0FP36mizchi21kagura__platform__web7interop13array__values(pads);
  const _p$3 = new _M0TPB5ArrayGRP26mizchi8js__core3AnyE([], 0);
  const _p$4 = _p$2.len;
  const _p$5 = _p$2.buf;
  let connected;
  let _tmp = 0;
  while (true) {
    const _p$6 = _tmp;
    if (_p$6 < _p$4) {
      const _p$7 = _p$5[_p$6];
      if (_M0FP36mizchi21kagura__platform__web7interop6truthy(_p$7) && !_M0FP26mizchi8js__core5equal(_M0FP36mizchi21kagura__platform__web7interop5field(_p$7, "connected"), false)) {
        _M0MPC15array5Array4pushGRP26mizchi8js__core3AnyE(_p$3, _p$7);
      }
      _tmp = _p$6 + 1 | 0;
      continue;
    } else {
      connected = _p$3;
      break;
    }
  }
  const _p$6 = _M0MPC15array5Array20unsafe__make__uninitGRP26mizchi8js__core3AnyE(connected.len);
  const _p$7 = connected.len;
  const _p$8 = connected.buf;
  let _tmp$2 = 0;
  while (true) {
    const _p$9 = _tmp$2;
    if (_p$9 < _p$7) {
      const _p$10 = _p$8[_p$9];
      const _p$11 = _M0FP36mizchi21kagura__platform__web5input18normalize__gamepad(_p$10);
      _p$6.buf[_p$9] = _p$11;
      _tmp$2 = _p$9 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _p$9 = _p$6;
  const _p$10 = new _M0TPB5ArrayGRP26mizchi8js__core3AnyE([], 0);
  const _p$11 = _p$9.len;
  const _p$12 = _p$9.buf;
  let candidates;
  let _tmp$3 = 0;
  while (true) {
    const _p$13 = _tmp$3;
    if (_p$13 < _p$11) {
      const _p$14 = _p$12[_p$13];
      if (!_M0FP26mizchi8js__core11is__nullish(_p$14)) {
        _M0MPC15array5Array4pushGRP26mizchi8js__core3AnyE(_p$10, _p$14);
      }
      _tmp$3 = _p$13 + 1 | 0;
      continue;
    } else {
      candidates = _p$10;
      break;
    }
  }
  let selected = _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None__;
  const _bind = candidates.len;
  const _bind$2 = candidates.buf;
  let _tmp$4 = 0;
  while (true) {
    const _ = _tmp$4;
    if (_ < _bind) {
      const candidate = _bind$2[_];
      if (_M0IPC16option6OptionPB2Eq5equalGsE(_M0FP36mizchi21kagura__platform__web5input11device__key(candidate), self.identity)) {
        selected = new _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4Some(candidate);
        break;
      }
      _tmp$4 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$3 = selected;
  let pad;
  if (_bind$3.$tag === 1) {
    const _Some = _bind$3;
    pad = _Some._0;
  } else {
    if (candidates.len === 0) {
      pad = _M0FP26mizchi8js__core4null();
    } else {
      if (0 >= candidates.len) {
        $panic();
      }
      pad = candidates.buf[0];
    }
  }
  const supported = !_M0FP26mizchi8js__core11is__nullish(pad);
  const next_identity = supported ? _M0FP36mizchi21kagura__platform__web5input11device__key(pad) : undefined;
  const changed = _M0IP016_24default__implPB2Eq10not__equalGOsE(next_identity, self.identity);
  const _bind$4 = self.last_time;
  let dt;
  if (_bind$4.$tag === 0) {
    dt = 0;
  } else {
    const _Some = _bind$4;
    const _last = _Some._0;
    dt = _M0FP36mizchi21kagura__platform__web7interop5clamp((now - _last) / 1000, 0, 0.05);
  }
  self.last_time = new _M0DTPC16option6OptionGdE4Some(now);
  const old_buttons = self.previous;
  if (changed || !enabled) {
    self.identity = next_identity;
    self.armed = false;
    self.previous = new _M0TPB5ArrayGiE([], 0);
    self.previous_axes = new _M0TPB5ArrayGdE([0, 0, 0, 0], 4);
    self.direction = undefined;
  }
  const axes = _M0FP36mizchi21kagura__platform__web7interop5field(pad, "axes");
  const _bind$5 = _M0FP36mizchi21kagura__platform__web5input13radial__stick(_M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS969(axes, 0), _M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS969(axes, 1), 1, self.dead_zone);
  const _mx = _bind$5._0;
  const _my = _bind$5._1;
  const _bind$6 = _M0FP36mizchi21kagura__platform__web5input13radial__stick(_M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS969(axes, 2), _M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS969(axes, 3), 1, self.dead_zone);
  const _lx = _bind$6._0;
  const _ly = _bind$6._1;
  const _p$13 = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "buttons"));
  const _p$14 = _M0MPC15array5Array20unsafe__make__uninitGbE(_p$13.len);
  const _p$15 = _p$13.len;
  const _p$16 = _p$13.buf;
  let _tmp$5 = 0;
  while (true) {
    const _p$17 = _tmp$5;
    if (_p$17 < _p$15) {
      const _p$18 = _p$16[_p$17];
      const _p$19 = _M0FP36mizchi21kagura__platform__web5input12button__down(_p$18);
      _p$14.buf[_p$17] = _p$19;
      _tmp$5 = _p$17 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const buttons = _p$14;
  const neutral = !_M0MPC15array5Array8containsGbE(buttons, true) && (_mx === 0 && (_my === 0 && (_lx === 0 && _ly === 0)));
  if (supported && (enabled && neutral)) {
    self.armed = true;
  }
  const ready = supported && (enabled && self.armed);
  const down = new _M0TPB5ArrayGiE([], 0);
  if (ready) {
    let _tmp$6 = 0;
    while (true) {
      const i = _tmp$6;
      if (i < buttons.len) {
        if (i < 0 || i >= buttons.len) {
          $panic();
        }
        if (buttons.buf[i]) {
          _M0MPC15array5Array4pushGiE(down, i);
        }
        _tmp$6 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  const _p$17 = new _M0TPB5ArrayGiE([], 0);
  const _p$18 = down.len;
  const _p$19 = down.buf;
  let pressed;
  let _tmp$6 = 0;
  while (true) {
    const _p$20 = _tmp$6;
    if (_p$20 < _p$18) {
      const _p$21 = _p$19[_p$20];
      if (!_M0MPC15array5Array8containsGiE(self.previous, _p$21)) {
        _M0MPC15array5Array4pushGiE(_p$17, _p$21);
      }
      _tmp$6 = _p$20 + 1 | 0;
      continue;
    } else {
      pressed = _p$17;
      break;
    }
  }
  const _p$20 = new _M0TPB5ArrayGiE([], 0);
  const _p$21 = old_buttons.len;
  const _p$22 = old_buttons.buf;
  let released;
  let _tmp$7 = 0;
  while (true) {
    const _p$23 = _tmp$7;
    if (_p$23 < _p$21) {
      const _p$24 = _p$22[_p$23];
      if (!_M0MPC15array5Array8containsGiE(down, _p$24)) {
        _M0MPC15array5Array4pushGiE(_p$20, _p$24);
      }
      _tmp$7 = _p$23 + 1 | 0;
      continue;
    } else {
      released = _p$20;
      break;
    }
  }
  const vectors = new _M0TPB5ArrayGdE([_mx, _my, _lx, _ly], 4);
  let axis_activity = false;
  let _tmp$8 = 0;
  while (true) {
    const i = _tmp$8;
    if (i < 4) {
      if (i < 0 || i >= vectors.len) {
        $panic();
      }
      const _tmp$9 = vectors.buf[i];
      const _bind$7 = self.previous_axes;
      if (i < 0 || i >= _bind$7.len) {
        $panic();
      }
      if (Math.abs(_tmp$9 - _bind$7.buf[i]) > 0.025) {
        axis_activity = true;
      }
      _tmp$8 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const activity = ready && (!(pressed.len === 0) || (!(released.len === 0) || axis_activity));
  const horizontal = _M0MPC15array5Array8containsGiE(down, 15) ? 1 : _M0MPC15array5Array8containsGiE(down, 14) ? -1 : Math.abs(_mx) > 0.5 ? (_mx > 0 ? 1 : -1) : 0;
  const vertical = _M0MPC15array5Array8containsGiE(down, 13) ? 1 : _M0MPC15array5Array8containsGiE(down, 12) ? -1 : Math.abs(_my) > 0.5 ? (_my > 0 ? 1 : -1) : 0;
  const next_direction = !ready ? undefined : vertical !== 0 ? (vertical > 0 ? "down" : "up") : horizontal !== 0 ? (horizontal > 0 ? "right" : "left") : undefined;
  let navigation = undefined;
  if (_M0IP016_24default__implPB2Eq10not__equalGOsE(next_direction, self.direction)) {
    self.direction = next_direction;
    navigation = next_direction;
    self.next_repeat = now + 400;
  } else {
    if (_M0IP016_24default__implPB2Eq10not__equalGOsE(self.direction, undefined) && now >= self.next_repeat) {
      navigation = self.direction;
      self.next_repeat = now + 140;
    }
  }
  self.previous = down;
  if (activity || !ready) {
    self.previous_axes = vectors;
  }
  const _tmp$9 = { _0: "connected", _1: !(connected.len === 0) };
  const _tmp$10 = { _0: "supported", _1: supported };
  const _tmp$11 = { _0: "ready", _1: ready };
  const _tmp$12 = { _0: "index", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "index"), -1) };
  const _tmp$13 = _M0FP36mizchi21kagura__platform__web7interop5field(pad, "id");
  let _tmp$14;
  if (connected.len === 0) {
    _tmp$14 = "";
  } else {
    if (0 >= connected.len) {
      $panic();
    }
    _tmp$14 = _M0MP26mizchi8js__core3Any5__get(connected.buf[0], "id");
  }
  const _tmp$15 = { _0: "id", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_tmp$13, _tmp$14) };
  const _tmp$16 = { _0: "profile", _1: supported ? _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "profile"), "standard") : _M0FP26mizchi8js__core4null() };
  const _tmp$17 = { _0: "move", _1: ready ? _M0FP36mizchi21kagura__platform__web7interop6vector(_mx, _my) : _M0FP36mizchi21kagura__platform__web7interop6vector(0, 0) };
  const _tmp$18 = { _0: "look", _1: ready ? _M0FP36mizchi21kagura__platform__web7interop6vector(_lx, _ly) : _M0FP36mizchi21kagura__platform__web7interop6vector(0, 0) };
  const _tmp$19 = { _0: "down", _1: _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGiE(down) };
  const _tmp$20 = { _0: "pressed", _1: _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGiE(pressed) };
  const _tmp$21 = { _0: "released", _1: _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGiE(released) };
  const _tmp$22 = { _0: "activity", _1: activity };
  const _bind$7 = navigation;
  let _tmp$23;
  if (_bind$7 === undefined) {
    _tmp$23 = _M0FP26mizchi8js__core4null();
  } else {
    const _Some = _bind$7;
    const _s = _Some;
    _tmp$23 = _s;
  }
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([_tmp$9, _tmp$10, _tmp$11, _tmp$12, _tmp$15, _tmp$16, _tmp$17, _tmp$18, _tmp$19, _tmp$20, _tmp$21, _tmp$22, { _0: "navigation", _1: _tmp$23 }, { _0: "dt", _1: dt }], 14));
}
function _M0FP36mizchi21kagura__platform__web5input23create__gamepad__reader(options) {
  const dead_zone = _M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "deadZone"), 0.18);
  if (!_M0FP36mizchi21kagura__platform__web7interop6finite(dead_zone) || (dead_zone < 0 || dead_zone >= 1)) {
    _M0FP36mizchi21kagura__platform__web7interop12range__error("Stick coordinates must be finite, radius positive, and deadZone in [0, 1)");
  }
  const state = new _M0TP36mizchi21kagura__platform__web5input12GamepadState(dead_zone, undefined, false, new _M0TPB5ArrayGiE([], 0), new _M0TPB5ArrayGdE([0, 0, 0, 0], 4), undefined, 0, _M0DTPC16option6OptionGdE4None__);
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "step", _1: (pads, options$2) => _M0MP36mizchi21kagura__platform__web5input12GamepadState4step(state, pads, options$2) }], 1));
}
function _M0FP36mizchi21kagura__platform__web5input13stick__vector(dx, dy, radius, options) {
  const dead_zone = _M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "deadZone"), 0.14);
  if (!_M0FP36mizchi21kagura__platform__web7interop6finite(dx) || (!_M0FP36mizchi21kagura__platform__web7interop6finite(dy) || (!_M0FP36mizchi21kagura__platform__web7interop6finite(radius) || (!_M0FP36mizchi21kagura__platform__web7interop6finite(dead_zone) || (radius <= 0 || (dead_zone < 0 || dead_zone >= 1)))))) {
    _M0FP36mizchi21kagura__platform__web7interop12range__error("Stick coordinates must be finite, radius positive, and deadZone in [0, 1)");
  }
  const _bind = _M0FP36mizchi21kagura__platform__web5input13radial__stick(dx, dy, radius, dead_zone);
  const _x = _bind._0;
  const _y = _bind._1;
  return _M0FP36mizchi21kagura__platform__web7interop6vector(_x, _y);
}
function _M0MP36mizchi21kagura__platform__web5input12ControlState7release(self, id) {
  let _tmp = self.held.len - 1 | 0;
  while (true) {
    const i = _tmp;
    if (i >= 0) {
      const _bind = self.held;
      if (i < 0 || i >= _bind.len) {
        $panic();
      }
      if (_bind.buf[i]._0 === id) {
        _M0MPC15array5Array6removeGUdRP26mizchi8js__core3AnyEE(self.held, i);
      }
      _tmp = i - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (_M0IPC16option6OptionPB2Eq5equalGdE(self.owner, new _M0DTPC16option6OptionGdE4Some(id))) {
    self.owner = _M0DTPC16option6OptionGdE4None__;
    self.x = 0;
    self.y = 0;
    return;
  } else {
    return;
  }
}
function _M0FP36mizchi21kagura__platform__web5input22create__control__input(options) {
  const capacity = _M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "capacity"), 8);
  if (!_M0FP36mizchi21kagura__platform__web7interop13safe__integer(capacity) || capacity < 1) {
    _M0FP36mizchi21kagura__platform__web7interop12range__error("Command capacity must be positive");
  }
  const state = new _M0TP36mizchi21kagura__platform__web5input12ControlState(capacity, new _M0TPB5ArrayGUdRP26mizchi8js__core3AnyEE([], 0), new _M0TPB5ArrayGRP26mizchi8js__core3AnyE([], 0), _M0DTPC16option6OptionGdE4None__, 0, 0, false);
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "version", _1: 1 }, { _0: "move", _1: (id, dx, dy) => {
    const _bind = state.owner;
    if (_bind.$tag === 1) {
      const _Some = _bind;
      const _owner = _Some._0;
      if (_owner !== id) {
        return false;
      }
    }
    state.owner = new _M0DTPC16option6OptionGdE4Some(id);
    state.x = dx;
    state.y = dy;
    return true;
  } }, { _0: "hold", _1: (id, action) => {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < state.held.len) {
        const _bind = state.held;
        if (i < 0 || i >= _bind.len) {
          $panic();
        }
        if (_bind.buf[i]._0 === id) {
          const _bind$2 = state.held;
          const _bind$3 = { _0: id, _1: action };
          if (i < 0 || i >= _bind$2.len) {
            $panic();
          }
          _bind$2.buf[i] = _bind$3;
          return undefined;
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0MPC15array5Array4pushGUisEE(state.held, { _0: id, _1: action });
  } }, { _0: "release", _1: (id) => {
    _M0MP36mizchi21kagura__platform__web5input12ControlState7release(state, id);
  } }, { _0: "tap", _1: (key, payload) => {
    if (!_M0FP36mizchi21kagura__platform__web7interop13safe__integer(key) || key <= 0) {
      _M0FP36mizchi21kagura__platform__web7interop12range__error("Command key must be a positive integer");
    }
    if (state.commands.len + 0 >= state.capacity) {
      return false;
    }
    _M0MPC15array5Array4pushGRP26mizchi8js__core3AnyE(state.commands, _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "key", _1: key }, { _0: "payload", _1: _M0FP36mizchi21kagura__platform__web7interop8argument(payload, _M0FP26mizchi8js__core4null()) }], 2)));
    return true;
  } }, { _0: "consumeCommand", _1: () => {
    if (state.release_pending) {
      state.release_pending = false;
      return _M0FP26mizchi8js__core4null();
    }
    const _p = state.commands;
    if (_p.len === 0) {
      return _M0FP26mizchi8js__core4null();
    }
    state.release_pending = true;
    return _M0MPC15array5Array6removeGRP26mizchi8js__core3AnyE(state.commands, 0);
  } }, { _0: "snapshot", _1: () => {
    const actions = new _M0TPB5ArrayGRP26mizchi8js__core3AnyE([], 0);
    const _bind = state.held;
    const _bind$2 = _bind.len;
    const _bind$3 = _bind.buf;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind$2) {
        const _foreach_element = _bind$3[_];
        const _action = _foreach_element._1;
        if (!_M0MPC15array5Array8containsGRP26mizchi8js__core3AnyE(actions, _action)) {
          _M0MPC15array5Array4pushGRP26mizchi8js__core3AnyE(actions, _action);
        }
        _tmp = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "x", _1: state.x }, { _0: "y", _1: state.y }, { _0: "actions", _1: _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGRP26mizchi8js__core3AnyE(actions) }], 3));
  } }, { _0: "clear", _1: () => {
    _M0MPC15array5Array5clearGUdRP26mizchi8js__core3AnyEE(state.held);
    _M0MPC15array5Array5clearGRP26mizchi8js__core3AnyE(state.commands);
    state.owner = _M0DTPC16option6OptionGdE4None__;
    state.x = 0;
    state.y = 0;
    state.release_pending = false;
  } }], 8));
}
function _M0MP36mizchi6anim3d8playback8Timeline11new_2einner(playing) {
  return new _M0TP36mizchi6anim3d8playback8Timeline(0, playing, 1, true);
}
function _M0MP36mizchi6anim3d8playback8Timeline15advance_2einner(self, delta, duration, stop_at_end, subtract_wrap) {
  if (!self.playing) {
    return undefined;
  }
  self.time = self.time + delta * self.speed;
  if (self.looping && duration > 0) {
    if (subtract_wrap) {
      while (true) {
        if (self.time >= duration) {
          self.time = self.time - duration;
          continue;
        } else {
          break;
        }
      }
      while (true) {
        if (self.time < 0) {
          self.time = self.time + duration;
          continue;
        } else {
          return;
        }
      }
    } else {
      self.time = _M0IPC16double6DoublePB3Mod3mod(self.time, duration);
      if (self.time < 0) {
        self.time = self.time + duration;
        return;
      } else {
        return;
      }
    }
  } else {
    if (!self.looping || !subtract_wrap) {
      const end = _M0MPC16double6Double3max(duration, 0);
      const finished = self.time >= end || self.time < 0;
      self.time = _M0MPC16double6Double3min(_M0MPC16double6Double3max(self.time, 0), end);
      if (stop_at_end && finished) {
        self.playing = false;
        return;
      } else {
        return;
      }
    } else {
      return;
    }
  }
}
function _M0MP36mizchi6anim3d8playback8Timeline12play_2einner(self, duration, restart_at_end) {
  if (restart_at_end && self.time >= duration) {
    self.time = 0;
  }
  self.playing = true;
}
function _M0MP36mizchi6anim3d8playback8Timeline4seek(self, time, duration) {
  self.time = _M0MPC16double6Double3min(_M0MPC16double6Double3max(time, 0), _M0MPC16double6Double3max(duration, 0));
  self.playing = false;
}
function _M0FP36mizchi21kagura__platform__web8playback13require__time(value) {
  if (!_M0FP36mizchi21kagura__platform__web7interop6finite(value)) {
    _M0FP26mizchi8js__core12throw__error("Expected finite time");
  }
  return value;
}
function _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(self) {
  const _p = _M0MP26mizchi8js__core3Any5__get(self.clip, "duration");
  return _p;
}
function _M0FP36mizchi21kagura__platform__web8playback22create__motion__player(asset) {
  const clips = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0MP26mizchi8js__core3Any5__get(asset, "clips"));
  if (0 >= clips.len) {
    $panic();
  }
  const state = new _M0TP36mizchi21kagura__platform__web8playback12MotionPlayer(clips, clips.buf[0], _M0MP36mizchi6anim3d8playback8Timeline11new_2einner(false));
  return _M0MP36mizchi11js__builtin6object6Object6freeze(_M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "snapshot", _1: () => {
    const _p = _M0MP26mizchi8js__core3Any5__get(state.clip, "fps");
    const fps = _p;
    return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "clip", _1: _M0MP26mizchi8js__core3Any5__get(state.clip, "id") }, { _0: "time", _1: state.timeline.time }, { _0: "duration", _1: _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state) }, { _0: "fps", _1: fps }, { _0: "frame", _1: _M0MP36mizchi11js__builtin4math4Math5round(state.timeline.time * fps) }, { _0: "playing", _1: state.timeline.playing }, { _0: "speed", _1: state.timeline.speed }, { _0: "loop", _1: state.timeline.looping }], 8));
  } }, { _0: "selectClip", _1: (id) => {
    const _bind = state.clips;
    const _bind$2 = _bind.len;
    const _bind$3 = _bind.buf;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind$2) {
        const clip = _bind$3[_];
        if (_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any5__get(clip, "id"), id)) {
          state.clip = clip;
          state.timeline.time = 0;
          state.timeline.playing = false;
          return undefined;
        }
        _tmp = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0FP26mizchi8js__core12throw__error("Unknown motion clip");
  } }, { _0: "play", _1: () => {
    _M0MP36mizchi6anim3d8playback8Timeline12play_2einner(state.timeline, _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state), true);
  } }, { _0: "pause", _1: () => {
    state.timeline.playing = false;
  } }, { _0: "seek", _1: (value) => {
    _M0MP36mizchi6anim3d8playback8Timeline4seek(state.timeline, _M0FP36mizchi21kagura__platform__web8playback13require__time(value), _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state));
  } }, { _0: "step", _1: (direction) => {
    if (!_M0FP26mizchi8js__core5equal(direction, -1) && !_M0FP26mizchi8js__core5equal(direction, 1)) {
      _M0FP26mizchi8js__core12throw__error("Step must be -1 or 1");
    }
    const _p = _M0MP26mizchi8js__core3Any5__get(state.clip, "fps");
    const fps = _p;
    state.timeline.time = _M0FP36mizchi21kagura__platform__web7interop5clamp((_M0MP36mizchi11js__builtin4math4Math5round(state.timeline.time * fps) + 0 + direction) / fps, 0, _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state));
    state.timeline.playing = false;
  } }, { _0: "setSpeed", _1: (value) => {
    const speed = _M0FP36mizchi21kagura__platform__web8playback13require__time(value);
    if (speed < 0.1 || speed > 4) {
      _M0FP26mizchi8js__core12throw__error("Speed must be 0.1..4");
    }
    state.timeline.speed = speed;
  } }, { _0: "setLoop", _1: (value) => {
    const _p = _M0FP26mizchi8js__core8typeof__(value);
    const _p$2 = "boolean";
    if (!(_p === _p$2)) {
      _M0FP26mizchi8js__core12throw__error("Loop must be boolean");
    }
    state.timeline.looping = value;
  } }, { _0: "tick", _1: (value) => {
    const delta = _M0FP36mizchi21kagura__platform__web8playback13require__time(value);
    if (delta < 0) {
      _M0FP26mizchi8js__core12throw__error("Negative time delta");
    }
    _M0MP36mizchi6anim3d8playback8Timeline15advance_2einner(state.timeline, delta, _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state), true, false);
  } }], 9)));
}
function _M0MP36mizchi11js__builtin10collection5JsMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE() {
  return _M0FP36mizchi11js__builtin10collection13ffi__new__map();
}
function _M0MP36mizchi11js__builtin10collection5JsMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(self, key, value) {
  return _M0MP26mizchi8js__core3Any6__call(self, "set", [key, value]);
}
function _M0MP36mizchi11js__builtin10collection5JsMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(self, key) {
  const result = _M0MP26mizchi8js__core3Any6__call(self, "get", [key]);
  return _M0FP26mizchi8js__core13is__undefined(result) ? _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None__ : new _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4Some(result);
}
function _M0MP36mizchi11js__builtin10collection5JsMap6deleteGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(self, key) {
  return _M0MP26mizchi8js__core3Any6__call(self, "delete", [key]);
}
function _M0MP36mizchi11js__builtin4weak7WeakMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE() {
  return _M0FP36mizchi11js__builtin4weak17ffi__new__weakmap();
}
function _M0MP36mizchi11js__builtin4weak7WeakMap6deleteGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(self, key) {
  return _M0MP26mizchi8js__core3Any6__call(self, "delete", [key]);
}
function _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(self, key) {
  const result = _M0MP26mizchi8js__core3Any6__call(self, "get", [key]);
  return _M0FP26mizchi8js__core13is__undefined(result) ? _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None__ : new _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4Some(result);
}
function _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(self, key, value) {
  return _M0MP26mizchi8js__core3Any6__call(self, "set", [key, value]);
}
function _M0FP36mizchi21kagura__platform__web6render12is__stride32(source) {
  return _M0MP36mizchi11js__builtin6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web6render17position__pattern, source);
}
function _M0FP36mizchi21kagura__platform__web6render12is__stride64(source) {
  return _M0FP36mizchi21kagura__platform__web6render12is__stride32(source) && (_M0MP36mizchi11js__builtin6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web6render15joints__pattern, source) && _M0MP36mizchi11js__builtin6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web6render16weights__pattern, source));
}
function _M0FP36mizchi21kagura__platform__web6render14is__3d__shader(source) {
  return _M0FP36mizchi21kagura__platform__web6render12is__stride32(source) || _M0FP36mizchi21kagura__platform__web6render12is__stride64(source);
}
function _M0FP36mizchi21kagura__platform__web6render21command__needs__depth(command) {
  const hint = _M0FP36mizchi21kagura__platform__web7interop13number__field(command, "vertexStrideHint", 0);
  return _M0FP36mizchi21kagura__platform__web7interop6truthy(_M0MP26mizchi8js__core3Any5__get(command, "isCustom")) && (hint > 0 ? hint >= 8 : _M0FP36mizchi21kagura__platform__web6render14is__3d__shader(_M0MP26mizchi8js__core3Any5__get(command, "shaderSource")));
}
function _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindings(source) {
  const pattern = _M0MP36mizchi11js__builtin6regexp6RegExp3new("@binding\\((\\d+)\\)\\s+var\\s+\\w+\\s*:\\s*(texture_2d<f32>|texture_2d|sampler)", _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN6constrS1137);
  const bindings = new _M0TPB5ArrayGUisEE([], 0);
  while (true) {
    const matched = _M0MP26mizchi8js__core3Any6__call(pattern, "exec", [source]);
    if (_M0FP26mizchi8js__core11is__nullish(matched)) {
      break;
    }
    const text = _M0MP26mizchi8js__core3Any16__get__by__index(matched, 1);
    let index = 0;
    const _bind = text.length;
    let _tmp = 0;
    while (true) {
      const _string_index = _tmp;
      if (_string_index < _bind) {
        let _decoded_next_string_index;
        let _decoded_char;
        _L: {
          const _bind$2 = text.charCodeAt(_string_index);
          if (_bind$2 >= 55296 && _bind$2 <= 56319 && (_string_index + 1 | 0) < _bind) {
            const _bind$3 = text.charCodeAt(_string_index + 1 | 0);
            if (_bind$3 >= 56320 && _bind$3 <= 57343) {
              const _tmp$2 = _string_index + 2 | 0;
              const _p = (((Math.imul(_bind$2 - 55296 | 0, 1024) | 0) + _bind$3 | 0) - 56320 | 0) + 65536 | 0;
              _decoded_next_string_index = _tmp$2;
              _decoded_char = _p;
              break _L;
            } else {
              const _tmp$2 = _string_index + 1 | 0;
              const _p = _bind$2;
              _decoded_next_string_index = _tmp$2;
              _decoded_char = _p;
              break _L;
            }
          } else {
            const _tmp$2 = _string_index + 1 | 0;
            const _p = _bind$2;
            _decoded_next_string_index = _tmp$2;
            _decoded_char = _p;
            break _L;
          }
        }
        index = ((Math.imul(index, 10) | 0) + _decoded_char | 0) - 48 | 0;
        _tmp = _decoded_next_string_index;
        continue;
      } else {
        break;
      }
    }
    const raw = _M0MP26mizchi8js__core3Any16__get__by__index(matched, 2);
    _M0MPC15array5Array4pushGUisEE(bindings, { _0: index, _1: _M0MPC16string6String11has__prefix(raw, _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN6recordS1138) ? "texture" : "sampler" });
    continue;
  }
  _M0MPC15array5Array8sort__byGUisEE(bindings, (a, b) => $compare_int(a._0, b._0));
  const _p = _M0MPC15array5Array20unsafe__make__uninitGRP26mizchi8js__core3AnyE(bindings.len);
  const _p$2 = bindings.len;
  const _p$3 = bindings.buf;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$2) {
      const _p$5 = _p$3[_p$4];
      const _p$6 = _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "binding", _1: _p$5._0 }, { _0: "type", _1: _p$5._1 }], 2));
      _p.buf[_p$4] = _p$6;
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi21kagura__platform__web7interop13array__to__jsGRP26mizchi8js__core3AnyE(_p);
}
function _M0FP36mizchi21kagura__platform__web6render20get__instance__count(command) {
  const raw = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(command, "instanceCount"), _M0FP36mizchi21kagura__platform__web7interop5field(command, "instance_count"));
  if (_M0FP36mizchi21kagura__platform__web7interop6finite(raw)) {
    const _p = _M0FP36mizchi21kagura__platform__web6render7to__i32(raw);
    return _p > 1 ? _p : 1;
  } else {
    return 1;
  }
}
function _M0FP36mizchi21kagura__platform__web6render25get__resource__cache__key(command) {
  const raw = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(command, "resourceCacheKey"), _M0FP36mizchi21kagura__platform__web7interop5field(command, "resource_cache_key"));
  return _M0FP36mizchi21kagura__platform__web7interop6finite(raw) ? _M0FP36mizchi21kagura__platform__web6render7to__i32(raw) : 0;
}
function _M0FP36mizchi21kagura__platform__web6render13equal__dwords(a, b, count) {
  if (_M0FP26mizchi8js__core5equal(a, b)) {
    return true;
  }
  if (_M0FP26mizchi8js__core11is__nullish(a) || _M0FP26mizchi8js__core11is__nullish(b)) {
    return false;
  }
  const count$2 = _M0FP36mizchi21kagura__platform__web7interop8argument(count, _M0MP26mizchi8js__core3Any5__get(b, "length"));
  let _tmp;
  if (!_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any5__get(a, "length"), count$2)) {
    _tmp = true;
  } else {
    const _p = _M0MP26mizchi8js__core3Any5__get(b, "length");
    _tmp = _p < count$2;
  }
  if (_tmp) {
    return false;
  }
  const count$3 = count$2;
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < count$3) {
      if (!_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any16__get__by__index(a, i), _M0MP26mizchi8js__core3Any16__get__by__index(b, i))) {
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
function _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shader(source, dwords) {
  if (!_M0FP36mizchi21kagura__platform__web7interop13safe__integer(dwords) || (dwords < 4 || (dwords > 128 || _M0IPC16double6DoublePB3Mod3mod(dwords, 4) !== 0))) {
    _M0FP36mizchi21kagura__platform__web7interop12range__error("Invalid instance uniform layout");
  }
  let replacements_buf = [_M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1169, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1170, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1171, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1172, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS1173];
  let replacements_len = 5;
  let result = source;
  const _bind = replacements_len;
  const _bind$2 = replacements_buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const _foreach_element = _bind$2[_];
      const _from = _foreach_element._0;
      const _to = _foreach_element._1;
      if (!_M0MPC16string6String8contains(result, new _M0TPC16string10StringView(_from, 0, _from.length))) {
        _M0FP26mizchi8js__core12throw__error(`Unsupported instance shader entry-point contract: ${_from}`);
      }
      result = _M0FP36mizchi21kagura__platform__web6render14replace__first(result, _from, _to);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return `// kagura-instance-dwords: ${_M0MP26mizchi8js__core3Any10to__string(dwords)}\n${result}`;
}
function _M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu) {
  const current = _M0MP26mizchi8js__core3Any5__get(gpu, "_registeredGeometry");
  if (!_M0FP26mizchi8js__core11is__nullish(current)) {
    return current;
  }
  const pairs = _M0MP36mizchi11js__builtin4weak7WeakMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE();
  _M0MP26mizchi8js__core3Any5__set(gpu, "_registeredGeometry", pairs);
  return pairs;
}
function _M0FP36mizchi21kagura__platform__web6render18geometry__snapshot(vertices, indices) {
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "vertexData", _1: _M0FP36mizchi21kagura__platform__web6render13float32__copy(vertices) }, { _0: "indices", _1: _M0FP36mizchi21kagura__platform__web6render12uint32__copy(indices) }, { _0: "immutableGeometry", _1: true }, { _0: "sharedGeometry", _1: true }], 4));
}
function _M0FP36mizchi21kagura__platform__web6render18register__geometry(gpu, id, revision, vertices, indices) {
  let _tmp;
  let _tmp$2;
  const _p = _M0FP26mizchi8js__core8typeof__(id);
  const _p$2 = "string";
  if (!(_p === _p$2)) {
    let _tmp$3;
    const _p$3 = _M0FP26mizchi8js__core8typeof__(id);
    const _p$4 = "symbol";
    if (!(_p$3 === _p$4)) {
      _tmp$3 = !_M0FP36mizchi21kagura__platform__web7interop13safe__integer(id);
    } else {
      _tmp$3 = false;
    }
    _tmp$2 = _tmp$3;
  } else {
    _tmp$2 = false;
  }
  if (_tmp$2) {
    _tmp = true;
  } else {
    _tmp = !_M0FP36mizchi21kagura__platform__web7interop13safe__integer(revision) || revision < 0;
  }
  if (_tmp) {
    _M0FP36mizchi21kagura__platform__web6render11type__error("Invalid geometry identity/revision");
  }
  let registry;
  if (_M0FP26mizchi8js__core11is__nullish(_M0MP26mizchi8js__core3Any5__get(gpu, "_geometryRegistry"))) {
    const registry$2 = _M0MP36mizchi11js__builtin10collection5JsMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE();
    _M0MP26mizchi8js__core3Any5__set(gpu, "_geometryRegistry", registry$2);
    registry = registry$2;
  } else {
    registry = _M0MP26mizchi8js__core3Any5__get(gpu, "_geometryRegistry");
  }
  const pairs = _M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu);
  const old = _M0MP36mizchi11js__builtin10collection5JsMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(registry, id);
  if (old.$tag === 1) {
    const _Some = old;
    const _entry = _Some._0;
    const _p$3 = _M0MP26mizchi8js__core3Any5__get(_entry, "revision");
    const old_revision = _p$3;
    if (revision < old_revision) {
      _M0FP36mizchi21kagura__platform__web7interop12range__error("Stale geometry revision");
    }
    if (revision === old_revision) {
      if (!_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any5__get(_entry, "vertices"), vertices) || !_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any5__get(_entry, "sourceIndices"), indices)) {
        _M0FP26mizchi8js__core12throw__error("Advance revision when replacing geometry");
      }
      return _M0MP26mizchi8js__core3Any5__get(_entry, "snapshot");
    }
  }
  const _bind = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(pairs, vertices);
  let by_index;
  if (_bind.$tag === 1) {
    const _Some = _bind;
    by_index = _Some._0;
  } else {
    by_index = _M0MP36mizchi11js__builtin4weak7WeakMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE();
  }
  const _bind$2 = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(by_index, indices);
  if (_bind$2.$tag === 1) {
    const _Some = _bind$2;
    const _owner = _Some._0;
    if (!_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any5__get(_owner, "id"), id)) {
      _M0FP26mizchi8js__core12throw__error("Geometry arrays already registered with another ID");
    }
  }
  if (old.$tag === 1) {
    const _Some = old;
    const _entry = _Some._0;
    const _bind$3 = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(pairs, _M0MP26mizchi8js__core3Any5__get(_entry, "vertices"));
    if (_bind$3.$tag === 1) {
      const _Some$2 = _bind$3;
      const _map = _Some$2._0;
      _M0MP36mizchi11js__builtin4weak7WeakMap6deleteGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(_map, _M0MP26mizchi8js__core3Any5__get(_entry, "sourceIndices"));
    }
  }
  _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(pairs, vertices, by_index);
  const snapshot = _M0FP36mizchi21kagura__platform__web6render18geometry__snapshot(vertices, indices);
  const entry = _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "id", _1: id }, { _0: "revision", _1: revision }, { _0: "vertices", _1: vertices }, { _0: "sourceIndices", _1: indices }, { _0: "snapshot", _1: snapshot }], 5));
  _M0MP36mizchi11js__builtin10collection5JsMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(registry, id, entry);
  _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(by_index, indices, entry);
  return snapshot;
}
function _M0FP36mizchi21kagura__platform__web6render20unregister__geometry(gpu, id) {
  if (_M0FP26mizchi8js__core11is__nullish(_M0MP26mizchi8js__core3Any5__get(gpu, "_geometryRegistry"))) {
    return undefined;
  }
  const registry = _M0MP26mizchi8js__core3Any5__get(gpu, "_geometryRegistry");
  const _bind = _M0MP36mizchi11js__builtin10collection5JsMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(registry, id);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _entry = _Some._0;
    const _bind$2 = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(_M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu), _M0MP26mizchi8js__core3Any5__get(_entry, "vertices"));
    if (_bind$2.$tag === 1) {
      const _Some$2 = _bind$2;
      const _map = _Some$2._0;
      _M0MP36mizchi11js__builtin4weak7WeakMap6deleteGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(_map, _M0MP26mizchi8js__core3Any5__get(_entry, "sourceIndices"));
    }
    _M0MP36mizchi11js__builtin10collection5JsMap6deleteGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(registry, id);
    return;
  } else {
    return;
  }
}
function _M0FP36mizchi21kagura__platform__web6render26register__static__geometry(gpu, vertices, indices) {
  const pairs = _M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu);
  const _bind = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(pairs, vertices);
  let by_index;
  if (_bind.$tag === 1) {
    const _Some = _bind;
    by_index = _Some._0;
  } else {
    by_index = _M0MP36mizchi11js__builtin4weak7WeakMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE();
  }
  const _bind$2 = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(by_index, indices);
  if (_bind$2.$tag === 1) {
    const _Some = _bind$2;
    const _registered = _Some._0;
    return _M0MP26mizchi8js__core3Any5__get(_registered, "snapshot");
  }
  _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(pairs, vertices, by_index);
  const snapshot = _M0FP36mizchi21kagura__platform__web6render18geometry__snapshot(vertices, indices);
  _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(by_index, indices, _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "id", _1: _M0FP36mizchi21kagura__platform__web6render14unique__symbol() }, { _0: "snapshot", _1: snapshot }], 2)));
  return snapshot;
}
function _M0FP36mizchi21kagura__platform__web6render18snapshot__vertices(cache, source) {
  const _bind = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(cache, source);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _previous = _Some._0;
    if (_M0FP36mizchi21kagura__platform__web7interop6length(_previous) === _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
      let i = 0;
      while (true) {
        if (i < _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
          const _tmp = _M0MP26mizchi8js__core3Any16__get__by__index(_previous, i);
          const _p = _M0MP26mizchi8js__core3Any16__get__by__index(source, i);
          if (!_M0MP36mizchi11js__builtin6object6Object4is__(_tmp, _M0MP36mizchi11js__builtin4math4Math6fround(_p))) {
            break;
          }
          i = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      if (i === _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
        return _previous;
      }
    }
  }
  const packed = _M0FP36mizchi21kagura__platform__web6render13float32__copy(source);
  _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(cache, source, packed);
  return packed;
}
function _M0FP36mizchi21kagura__platform__web6render17snapshot__indices(cache, source) {
  const _bind = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(cache, source);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _previous = _Some._0;
    if (_M0FP36mizchi21kagura__platform__web7interop6length(_previous) === _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
      let i = 0;
      while (true) {
        if (i < _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
          if (!_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any16__get__by__index(_previous, i), _M0FP36mizchi21kagura__platform__web6render10to__uint32(_M0MP26mizchi8js__core3Any16__get__by__index(source, i)))) {
            break;
          }
          i = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      if (i === _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
        return _previous;
      }
    }
  }
  const packed = _M0FP36mizchi21kagura__platform__web6render12uint32__copy(source);
  _M0MP36mizchi11js__builtin4weak7WeakMap3setGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(cache, source, packed);
  return packed;
}
function _M0FP36mizchi21kagura__platform__web6render24snapshot__draw__geometry(gpu, vertices, indices) {
  const registered = _M0MP26mizchi8js__core3Any5__get(gpu, "_registeredGeometry");
  if (!_M0FP26mizchi8js__core11is__nullish(registered)) {
    const pairs = registered;
    const _bind = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(pairs, vertices);
    if (_bind.$tag === 1) {
      const _Some = _bind;
      const _map = _Some._0;
      const _bind$2 = _M0MP36mizchi11js__builtin4weak7WeakMap3getGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE(_map, indices);
      if (_bind$2.$tag === 1) {
        const _Some$2 = _bind$2;
        const _entry = _Some$2._0;
        return _M0MP26mizchi8js__core3Any5__get(_entry, "snapshot");
      }
    }
  }
  let cache = _M0MP26mizchi8js__core3Any5__get(gpu, "_geometrySnapshots");
  if (_M0FP26mizchi8js__core11is__nullish(cache)) {
    const vertices$2 = _M0MP36mizchi11js__builtin4weak7WeakMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE();
    const indices$2 = _M0MP36mizchi11js__builtin4weak7WeakMap3newGRP26mizchi8js__core3AnyRP26mizchi8js__core3AnyE();
    cache = _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "vertices", _1: vertices$2 }, { _0: "indices", _1: indices$2 }], 2));
    _M0MP26mizchi8js__core3Any5__set(gpu, "_geometrySnapshots", cache);
  }
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "vertexData", _1: _M0FP36mizchi21kagura__platform__web6render18snapshot__vertices(_M0MP26mizchi8js__core3Any5__get(cache, "vertices"), vertices) }, { _0: "indices", _1: _M0FP36mizchi21kagura__platform__web6render17snapshot__indices(_M0MP26mizchi8js__core3Any5__get(cache, "indices"), indices) }, { _0: "immutableGeometry", _1: true }], 3));
}
function _M0FP36mizchi21kagura__platform__web8ui__sync20apply__object__patch(previous, patch) {
  const value = _M0FP36mizchi21kagura__platform__web7interop14object__spread(_M0FP36mizchi21kagura__platform__web7interop6truthy(_M0MP26mizchi8js__core3Any5__get(patch, "full")) ? _M0FP26mizchi8js__core4null() : previous, _M0MP26mizchi8js__core3Any5__get(patch, "set"));
  const _bind = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0MP26mizchi8js__core3Any5__get(patch, "remove"));
  const _bind$2 = _bind.len;
  const _bind$3 = _bind.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const key = _bind$3[_];
      _M0FP36mizchi21kagura__platform__web7interop11delete__key(value, key);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return value;
}
function _M0FP36mizchi21kagura__platform__web8ui__sync24create__dependency__gate() {
  const previous = _M0MPC13ref3Ref3RefGORP26mizchi8js__core3AnyE(_M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4None__);
  return (dependencies) => {
    const count = _M0MP26mizchi8js__core3Any5__get(dependencies, "length");
    const _bind = previous.val;
    if (_bind.$tag === 1) {
      const _Some = _bind;
      const _old = _Some._0;
      if (_M0FP36mizchi21kagura__platform__web7interop6length(_old) === count) {
        let same = true;
        let _tmp = 0;
        while (true) {
          const i = _tmp;
          if (i < count) {
            if (!_M0MP36mizchi11js__builtin6object6Object4is__(_M0MP26mizchi8js__core3Any16__get__by__index(dependencies, i), _M0MP26mizchi8js__core3Any16__get__by__index(_old, i))) {
              same = false;
              break;
            }
            _tmp = i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        if (same) {
          return false;
        }
      }
    }
    previous.val = new _M0DTPC16option6OptionGRP26mizchi8js__core3AnyE4Some(dependencies);
    return true;
  };
}
function _M0FP36mizchi21kagura__platform__web9web__core20apply__object__patch(a0, a1) {
  return _M0FP36mizchi21kagura__platform__web8ui__sync20apply__object__patch(a0, a1);
}
function _M0FP36mizchi21kagura__platform__web9web__core21command__needs__depth(a0) {
  return _M0FP36mizchi21kagura__platform__web6render21command__needs__depth(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core22create__control__input(a0) {
  return _M0FP36mizchi21kagura__platform__web5input22create__control__input(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core24create__dependency__gate() {
  return _M0FP36mizchi21kagura__platform__web8ui__sync24create__dependency__gate();
}
function _M0FP36mizchi21kagura__platform__web9web__core23create__gamepad__reader(a0) {
  return _M0FP36mizchi21kagura__platform__web5input23create__gamepad__reader(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core22create__motion__player(a0) {
  return _M0FP36mizchi21kagura__platform__web8playback22create__motion__player(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core13equal__dwords(a0, a1, a2) {
  return _M0FP36mizchi21kagura__platform__web6render13equal__dwords(a0, a1, a2);
}
function _M0FP36mizchi21kagura__platform__web9web__core20get__instance__count(a0) {
  return _M0FP36mizchi21kagura__platform__web6render20get__instance__count(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core25get__resource__cache__key(a0) {
  return _M0FP36mizchi21kagura__platform__web6render25get__resource__cache__key(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core24install__frame__profiler(a0) {
  return _M0FP36mizchi21kagura__platform__web11diagnostics24install__frame__profiler(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core25instance__uniform__shader(a0, a1) {
  return _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shader(a0, a1);
}
function _M0FP36mizchi21kagura__platform__web9web__core14is__3d__shader(a0) {
  return _M0FP36mizchi21kagura__platform__web6render14is__3d__shader(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core12is__stride32(a0) {
  return _M0FP36mizchi21kagura__platform__web6render12is__stride32(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core12is__stride64(a0) {
  return _M0FP36mizchi21kagura__platform__web6render12is__stride64(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core18normalize__gamepad(a0) {
  return _M0FP36mizchi21kagura__platform__web5input18normalize__gamepad(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core24parse__texture__bindings(a0) {
  return _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindings(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core10percentile(a0, a1) {
  return _M0FP36mizchi21kagura__platform__web11diagnostics10percentile(a0, a1);
}
function _M0FP36mizchi21kagura__platform__web9web__core20read__frame__profile(a0) {
  return _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profile(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core18register__geometry(a0, a1, a2, a3, a4) {
  return _M0FP36mizchi21kagura__platform__web6render18register__geometry(a0, a1, a2, a3, a4);
}
function _M0FP36mizchi21kagura__platform__web9web__core26register__static__geometry(a0, a1, a2) {
  return _M0FP36mizchi21kagura__platform__web6render26register__static__geometry(a0, a1, a2);
}
function _M0FP36mizchi21kagura__platform__web9web__core24snapshot__draw__geometry(a0, a1, a2) {
  return _M0FP36mizchi21kagura__platform__web6render24snapshot__draw__geometry(a0, a1, a2);
}
function _M0FP36mizchi21kagura__platform__web9web__core13stick__vector(a0, a1, a2, a3) {
  return _M0FP36mizchi21kagura__platform__web5input13stick__vector(a0, a1, a2, a3);
}
function _M0FP36mizchi21kagura__platform__web9web__core20summarize__intervals(a0) {
  return _M0FP36mizchi21kagura__platform__web11diagnostics20summarize__intervals(a0);
}
function _M0FP36mizchi21kagura__platform__web9web__core20unregister__geometry(a0, a1) {
  _M0FP36mizchi21kagura__platform__web6render20unregister__geometry(a0, a1);
}
export { _M0FP36mizchi21kagura__platform__web9web__core20apply__object__patch as applyObjectPatch, _M0FP36mizchi21kagura__platform__web9web__core21command__needs__depth as commandNeedsDepth, _M0FP36mizchi21kagura__platform__web9web__core22create__control__input as createControlInput, _M0FP36mizchi21kagura__platform__web9web__core24create__dependency__gate as createDependencyGate, _M0FP36mizchi21kagura__platform__web9web__core23create__gamepad__reader as createGamepadReader, _M0FP36mizchi21kagura__platform__web9web__core22create__motion__player as createMotionPlayer, _M0FP36mizchi21kagura__platform__web9web__core13equal__dwords as equalDwords, _M0FP36mizchi21kagura__platform__web9web__core20get__instance__count as getInstanceCount, _M0FP36mizchi21kagura__platform__web9web__core25get__resource__cache__key as getResourceCacheKey, _M0FP36mizchi21kagura__platform__web9web__core24install__frame__profiler as installFrameProfiler, _M0FP36mizchi21kagura__platform__web9web__core25instance__uniform__shader as instanceUniformShader, _M0FP36mizchi21kagura__platform__web9web__core14is__3d__shader as is3DShader, _M0FP36mizchi21kagura__platform__web9web__core12is__stride32 as isStride32, _M0FP36mizchi21kagura__platform__web9web__core12is__stride64 as isStride64, _M0FP36mizchi21kagura__platform__web9web__core18normalize__gamepad as normalizeGamepad, _M0FP36mizchi21kagura__platform__web9web__core24parse__texture__bindings as parseTextureBindings, _M0FP36mizchi21kagura__platform__web9web__core10percentile as percentile, _M0FP36mizchi21kagura__platform__web9web__core20read__frame__profile as readFrameProfile, _M0FP36mizchi21kagura__platform__web9web__core18register__geometry as registerGeometry, _M0FP36mizchi21kagura__platform__web9web__core26register__static__geometry as registerStaticGeometry, _M0FP36mizchi21kagura__platform__web9web__core24snapshot__draw__geometry as snapshotDrawGeometry, _M0FP36mizchi21kagura__platform__web9web__core13stick__vector as stickVector, _M0FP36mizchi21kagura__platform__web9web__core20summarize__intervals as summarizeIntervals, _M0FP36mizchi21kagura__platform__web9web__core20unregister__geometry as unregisterGeometry }
