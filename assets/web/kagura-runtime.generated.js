// Generated from platform_web/web_core/*.mbt by just web-runtime-build. DO NOT EDIT.
// Source SHA-256: 2771a6fe5212ea079cdbd17f35d6bee6e9445489b2d369880350cbc933d72c28
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $oob() {
  throw new Error("Index out of bounds");
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
const _M0MPB7JSArray4copy = (arr) => arr.slice(0);
const _M0MPC16double6Double8mod__ffi = (a, b) => (a % b);
const _M0MPB7JSArray11set__length = (arr, len) => { arr.length = len; };
const _M0MPB7JSArray6splice = (arr, idx, cnt) => arr.splice(idx, cnt);
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
function _M0TPC13ref3RefGORP36mizchi2js4core3AnyE(param0) {
  this.val = param0;
}
const _M0FP36mizchi2js4core9undefined = () => undefined;
const _M0MP36mizchi2js4core3Any16__get__by__index = (obj, key) => obj[key];
const _M0MP36mizchi2js4core3Any5__get = (obj, key) => obj[key];
const _M0MP36mizchi2js4core3Any6__call = (obj, key, args) => obj[key](...args);
const _M0FP36mizchi2js4core11is__nullish = (v) => v == null;
const _M0FP36mizchi2js4core12throw__error = (msg) => { throw new Error(msg); };
const _M0MP36mizchi2js4core3Any5__set = (obj, key, value) => { obj[key] = value };
const _M0FP36mizchi2js4core12global__this = () => globalThis;
const _M0FP36mizchi2js4core4null = () => null;
const _M0FP36mizchi2js4core13is__undefined = (v) => v === undefined;
const _M0FP36mizchi2js4core8typeof__ = (v) => typeof v;
const _M0FP36mizchi2js4core5equal = (a, b) => a === b;
const _M0FP36mizchi2js4core13from__entries = (entries) => Object.fromEntries(entries.map(e => [e._0, e._1]));
const _M0FP36mizchi2js4core11array__from = (v) => Array.from(v);
const _M0MP36mizchi2js4core3Any10to__string = (self) => self == null ? String(self) : self.toString();
const _M0MP46mizchi2js8builtins4math4Math5round = (x) => Math.round(x);
const _M0MP46mizchi2js8builtins4math4Math6fround = (x) => Math.fround(x);
const _M0MP46mizchi2js8builtins4math4Math5hypot = (values) => Math.hypot(...values);
const _M0FP46mizchi2js8builtins6object13object__class = () => Object;
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
const _M0FP46mizchi2js8builtins6regexp16ffi__regexp__new = (s, flags) => new RegExp(s, flags);
const _M0MP46mizchi2js8builtins6regexp6RegExp17ffi__regexp__test = (re, string) => re.test(string);
function _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None() {}
_M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None__ = new _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None();
function _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some.prototype.$tag = 1;
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
const _M0FP46mizchi2js8builtins10collection13ffi__new__map = () => new Map();
const _M0FP46mizchi2js8builtins4weak17ffi__new__weakmap = () => new WeakMap();
function _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None() {}
_M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None__ = new _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None();
function _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4Some.prototype.$tag = 1;
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
const _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN7_2abindS108 = "texture";
const _M0FP36mizchi21kagura__platform__web6render17position__pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("position\\s*:\\s*vec3<f32>", undefined);
const _M0FP36mizchi21kagura__platform__web6render16weights__pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("weights\\s*:\\s*vec4<f32>", undefined);
const _M0FP36mizchi21kagura__platform__web6render15joints__pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("joints\\s*:\\s*vec4<f32>", undefined);
const _M0FP36mizchi21kagura__platform__web5input13radial__stickN5tupleS188 = { _0: 0, _1: 0 };
const _M0FP36mizchi21kagura__platform__web5input11victrix__idN6constrS185 = "i";
const _M0FP36mizchi21kagura__platform__web5input11victrix__id = _M0MP46mizchi2js8builtins6regexp6RegExp3new("\\bVendor:\\s*0e6f\\s+Product:\\s*0218\\b", _M0FP36mizchi21kagura__platform__web5input11victrix__idN6constrS185);
const _M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS186 = { _0: 3, _1: 6 };
const _M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS187 = { _0: 4, _1: 7 };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS48 = { _0: "renderCpuMs", _1: "_lastRenderCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS49 = { _0: "renderUploadCpuMs", _1: "_lastRenderUploadCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS50 = { _0: "renderBindGroupCpuMs", _1: "_lastRenderBindGroupCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS51 = { _0: "renderEncodeCpuMs", _1: "_lastRenderEncodeCpuMs" };
const _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS52 = { _0: "renderSubmitCpuMs", _1: "_lastRenderSubmitCpuMs" };
const _M0MPC16string10StringView4findN6constrS9865 = 0;
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS195 = { _0: "@group(0) @binding(0) var<uniform> uniforms: Uniforms;", _1: "struct InstanceUniforms { values: array<Uniforms, 32>, };\n@group(0) @binding(0) var<uniform> instance_uniforms: InstanceUniforms;\nvar<private> uniforms: Uniforms;" };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS196 = { _0: "struct VertexOutput {", _1: "struct VertexOutput {\n  @location(7) @interpolate(flat) instance_id: u32," };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS197 = { _0: "@vertex fn vs_main(input: VertexInput) -> VertexOutput {", _1: "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) instance_id: u32) -> VertexOutput {\n  uniforms = instance_uniforms.values[instance_id];" };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS198 = { _0: "var out: VertexOutput;", _1: "var out: VertexOutput;\n  out.instance_id = instance_id;" };
const _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS199 = { _0: "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {", _1: "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  uniforms = instance_uniforms.values[in.instance_id];" };
const _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN6constrS194 = "g";
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
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
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    const _end = _Some;
    end$2 = _end;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    if (start < len) {
      const _p = self.charCodeAt(start);
      if (!(_p >= 56320 && _p <= 57343)) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      const _p = self.charCodeAt(end$2);
      if (!(_p >= 56320 && _p <= 57343)) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, self);
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string6String20unsafe__range__equal(self, self_off, other, other_off, len) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      const _p = self.charCodeAt(self_off + i | 0);
      const _p$2 = other.charCodeAt(other_off + i | 0);
      if (_p === _p$2) {
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
        let _tmp$2;
        if (k > 0) {
          const _p = pattern.str.charCodeAt(pattern.start + k | 0);
          _tmp$2 = c !== _p;
        } else {
          _tmp$2 = false;
        }
        if (_tmp$2) {
          const _tmp$3 = k - 1 | 0;
          k = _tmp$3 >>> 0 < table.length ? table[_tmp$3] : $oob();
          continue;
        } else {
          break;
        }
      }
      const _p = pattern.str.charCodeAt(pattern.start + k | 0);
      if (c === _p) {
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
        let _tmp$2;
        if (k > 0) {
          const _p = pattern.str.charCodeAt(pattern.start + k | 0);
          _tmp$2 = c !== _p;
        } else {
          _tmp$2 = false;
        }
        if (_tmp$2) {
          const _tmp$3 = k - 1 | 0;
          k = _tmp$3 >>> 0 < table.length ? table[_tmp$3] : $oob();
          continue;
        } else {
          break;
        }
      }
      const _p = pattern.str.charCodeAt(pattern.start + k | 0);
      if (c === _p) {
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
      let _tmp$2;
      const _p = data.charCodeAt(pos);
      if (_p === first) {
        const _p$2 = data.charCodeAt(pos + last_offset | 0);
        _tmp$2 = _p$2 === last;
      } else {
        _tmp$2 = false;
      }
      if (_tmp$2) {
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
      const _p = left.charCodeAt(left_start + i | 0);
      const _p$2 = right.charCodeAt(right_start + i | 0);
      if (_p !== _p$2) {
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
function _M0FPB24find__code__unit__scalar(data, start, end, code) {
  let _tmp = start;
  while (true) {
    const pos = _tmp;
    if (pos < end) {
      const _p = data.charCodeAt(pos);
      if (_p === code) {
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
  return _M0FPB24find__code__unit__scalar(data, start, end, code);
}
function _M0FPB28find__code__unit__from__view(target, start, end, code) {
  const target_start = target.start;
  const found = _M0FPB30find__code__unit__from__string(target.str, target_start + start | 0, target_start + end | 0, code);
  return found < 0 ? -1 : found - target_start | 0;
}
function _M0MPC16string10StringView4find(self, str) {
  const pattern_len = str.end - str.start | 0;
  switch (pattern_len) {
    case 0: {
      return _M0MPC16string10StringView4findN6constrS9865;
    }
    case 1: {
      const found = _M0FPB28find__code__unit__from__view(self, 0, self.end - self.start | 0, str.str.charCodeAt(str.start));
      return found < 0 ? undefined : found;
    }
    default: {
      return pattern_len > (self.end - self.start | 0) ? undefined : _M0FPB22find__by__two__anchors(self, str);
    }
  }
}
function _M0MPC16string10StringView11has__prefix(self, str) {
  const str_len = str.end - str.start | 0;
  if (str_len <= (self.end - self.start | 0)) {
    let _tmp;
    if (str_len === 0) {
      _tmp = true;
    } else {
      const _p = self.str.charCodeAt(self.start);
      const _p$2 = str.str.charCodeAt(str.start);
      _tmp = _p === _p$2;
    }
    if (_tmp) {
      return _M0MPC16string6String20unsafe__range__equal(self.str, self.start, str.str, str.start, str_len);
    } else {
      return false;
    }
  } else {
    return false;
  }
}
function _M0MPC16string6String11has__prefix(self, str) {
  return _M0MPC16string10StringView11has__prefix(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0MPC15array5Array4pushGUdRP36mizchi2js4core3AnyEE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGdE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0FPB36string__contains__code__unit__scalar(str, start, end, code) {
  let _tmp = start;
  while (true) {
    const i = _tmp;
    if (i < end) {
      const _p = str.charCodeAt(i);
      if (_p === code) {
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
function _M0MPC15array5Array28unsafe__truncate__to__lengthGUdRP36mizchi2js4core3AnyEE(self, new_len) {
  _M0MPB7JSArray11set__length(self, new_len);
}
function _M0MPC15array5Array28unsafe__truncate__to__lengthGRP36mizchi2js4core3AnyE(self, new_len) {
  _M0MPB7JSArray11set__length(self, new_len);
}
function _M0MPC15array5Array6removeGRP36mizchi2js4core3AnyE(self, index) {
  if (index >= 0 && index < self.length) {
    const value = index >>> 0 < self.length ? self[index] : $oob();
    _M0MPB7JSArray6splice(self, index, 1);
    return value;
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(60);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "index out of bounds: the len is from 0 to ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.length);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " but the index is ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, index);
    return $panic();
  }
}
function _M0MPC15array5Array6removeGUdRP36mizchi2js4core3AnyEE(self, index) {
  if (index >= 0 && index < self.length) {
    const value = index >>> 0 < self.length ? self[index] : $oob();
    _M0MPB7JSArray6splice(self, index, 1);
    return value;
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(60);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "index out of bounds: the len is from 0 to ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, self.length);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " but the index is ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, index);
    return $panic();
  }
}
function _M0MPC15array5Array4copyGdE(self) {
  return _M0MPB7JSArray4copy(self);
}
function _M0MPC15array5Array2atGUdRP36mizchi2js4core3AnyEE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGbE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
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
function _M0MPC15array5Array3setGUdRP36mizchi2js4core3AnyEE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGRP36mizchi2js4core3AnyE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    self[index] = value;
    return;
  } else {
    $panic();
    return;
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
function _M0FPB20fixed__choose__pivotN7sort__2S568GdE(_env, a, b) {
  const swaps = _env._1;
  const arr = _env._0;
  if (arr.buf[arr.start + a | 0] > arr.buf[arr.start + b | 0]) {
    _M0MPC15array12MutArrayView4swapGdE(arr, a, b);
    swaps.val = swaps.val + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0FPB20fixed__choose__pivotN7sort__3S572GdE(_env, a, b, c) {
  _M0FPB20fixed__choose__pivotN7sort__2S568GdE(_env, a, b);
  _M0FPB20fixed__choose__pivotN7sort__2S568GdE(_env, b, c);
  _M0FPB20fixed__choose__pivotN7sort__2S568GdE(_env, a, b);
}
function _M0FPB20fixed__choose__pivotGdE(arr) {
  const len = arr.end - arr.start | 0;
  const swaps = new _M0TPB8MutLocalGiE(0);
  const b = Math.imul(len / 4 | 0, 2) | 0;
  if (len >= 8) {
    const a = Math.imul(len / 4 | 0, 1) | 0;
    const c = Math.imul(len / 4 | 0, 3) | 0;
    const _env = { _0: arr, _1: swaps };
    if (len > 50) {
      _M0FPB20fixed__choose__pivotN7sort__3S572GdE(_env, a - 1 | 0, a, a + 1 | 0);
      _M0FPB20fixed__choose__pivotN7sort__3S572GdE(_env, b - 1 | 0, b, b + 1 | 0);
      _M0FPB20fixed__choose__pivotN7sort__3S572GdE(_env, c - 1 | 0, c, c + 1 | 0);
    }
    _M0FPB20fixed__choose__pivotN7sort__3S572GdE(_env, a, b, c);
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
  while (true) {
    const i = _tmp;
    if (i >= 0) {
      _M0FPB17fixed__sift__downGdE(arr, i);
      _tmp = i - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = len - 1 | 0;
  while (true) {
    const i = _tmp$2;
    if (i >= 1) {
      _M0MPC15array12MutArrayView4swapGdE(arr, 0, i);
      _M0FPB17fixed__sift__downGdE(_M0MPC15array12MutArrayView5sliceGdE(arr, 0, i), 0);
      _tmp$2 = i - 1 | 0;
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
function _M0FPB24fixed__choose__pivot__byN7sort__2S448GUisEE(_env, a, b) {
  const arr = _env._2;
  const swaps = _env._1;
  const cmp = _env._0;
  if (cmp(arr.buf[arr.start + a | 0], arr.buf[arr.start + b | 0]) > 0) {
    _M0MPC15array12MutArrayView4swapGUisEE(arr, a, b);
    swaps.val = swaps.val + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0FPB24fixed__choose__pivot__byN7sort__3S452GUisEE(_env, a, b, c) {
  _M0FPB24fixed__choose__pivot__byN7sort__2S448GUisEE(_env, a, b);
  _M0FPB24fixed__choose__pivot__byN7sort__2S448GUisEE(_env, b, c);
  _M0FPB24fixed__choose__pivot__byN7sort__2S448GUisEE(_env, a, b);
}
function _M0FPB24fixed__choose__pivot__byGUisEE(arr, cmp) {
  const len = arr.end - arr.start | 0;
  const swaps = new _M0TPB8MutLocalGiE(0);
  const b = Math.imul(len / 4 | 0, 2) | 0;
  if (len >= 8) {
    const a = Math.imul(len / 4 | 0, 1) | 0;
    const c = Math.imul(len / 4 | 0, 3) | 0;
    const _env = { _0: cmp, _1: swaps, _2: arr };
    if (len > 50) {
      _M0FPB24fixed__choose__pivot__byN7sort__3S452GUisEE(_env, a - 1 | 0, a, a + 1 | 0);
      _M0FPB24fixed__choose__pivot__byN7sort__3S452GUisEE(_env, b - 1 | 0, b, b + 1 | 0);
      _M0FPB24fixed__choose__pivot__byN7sort__3S452GUisEE(_env, c - 1 | 0, c, c + 1 | 0);
    }
    _M0FPB24fixed__choose__pivot__byN7sort__3S452GUisEE(_env, a, b, c);
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
  while (true) {
    const i = _tmp;
    if (i >= 0) {
      _M0FPB21fixed__sift__down__byGUisEE(arr, i, cmp);
      _tmp = i - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = len - 1 | 0;
  while (true) {
    const i = _tmp$2;
    if (i >= 1) {
      _M0MPC15array12MutArrayView4swapGUisEE(arr, 0, i);
      _M0FPB21fixed__sift__down__byGUisEE(_M0MPC15array12MutArrayView5sliceGUisEE(arr, 0, i), 0, cmp);
      _tmp$2 = i - 1 | 0;
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
  const _bind = self.length;
  _M0MPC15array12MutArrayView4sortGdE(new _M0TPB12MutArrayViewGdE(self, 0, _bind));
}
function _M0MPC15array5Array8sort__byGUisEE(self, cmp) {
  const _bind = self.length;
  _M0MPC15array12MutArrayView8sort__byGUisEE(new _M0TPB12MutArrayViewGUisEE(self, 0, _bind), cmp);
}
function _M0MPC15array5Array5clearGUdRP36mizchi2js4core3AnyEE(self) {
  _M0MPC15array5Array28unsafe__truncate__to__lengthGUdRP36mizchi2js4core3AnyEE(self, 0);
}
function _M0MPC15array5Array5clearGRP36mizchi2js4core3AnyE(self) {
  _M0MPC15array5Array28unsafe__truncate__to__lengthGRP36mizchi2js4core3AnyE(self, 0);
}
function _M0MPC15array5Array8containsGRP36mizchi2js4core3AnyE(self, value) {
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
      if (_M0IP36mizchi2js4core3AnyPB2Eq5equal(v, value)) {
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
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
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
function _M0MPC15array5Array8containsGiE(self, value) {
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
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
function _M0MPC13ref3Ref3RefGORP36mizchi2js4core3AnyE(x) {
  return new _M0TPC13ref3RefGORP36mizchi2js4core3AnyE(x);
}
function _M0IP36mizchi2js4core3AnyPB2Eq5equal(self, other) {
  return _M0FP36mizchi2js4core5equal(self, other);
}
function _M0MP46mizchi2js8builtins6object6Object4is__(a, b) {
  return _M0MP36mizchi2js4core3Any6__call(_M0FP46mizchi2js8builtins6object13object__class(), "is", [a, b]);
}
function _M0MP46mizchi2js8builtins6object6Object6freeze(obj) {
  return _M0MP36mizchi2js4core3Any6__call(_M0FP46mizchi2js8builtins6object13object__class(), "freeze", [obj]);
}
function _M0FP36mizchi12kagura__core10statistics10percentile(values, p) {
  if (values.length === 0) {
    return 0;
  }
  const sorted = _M0MPC15array5Array4copyGdE(values);
  _M0MPC15array5Array4sortGdE(sorted);
  const _p = _M0MPC16double6Double7to__int((sorted.length + 0) * p);
  const _p$2 = 0;
  const _p$3 = _p > _p$2 ? _p : _p$2;
  const _p$4 = sorted.length - 1 | 0;
  return _M0MPC15array5Array2atGdE(sorted, _p$3 < _p$4 ? _p$3 : _p$4);
}
function _M0FP36mizchi12kagura__core10statistics20summarize__intervals(values) {
  const intervals = [];
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < values.length) {
      _M0MPC15array5Array4pushGdE(intervals, _M0MPC15array5Array2atGdE(values, i) - _M0MPC15array5Array2atGdE(values, i - 1 | 0));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const elapsed = values.length > 1 ? _M0MPC15array5Array2atGdE(values, values.length - 1 | 0) - _M0MPC15array5Array2atGdE(values, 0) : 0;
  return new _M0TP36mizchi12kagura__core10statistics15IntervalSummary(values.length, elapsed, elapsed > 0 ? (intervals.length + 0) / (elapsed / 1000) : 0, _M0FP36mizchi12kagura__core10statistics10percentile(intervals, 0.5), _M0FP36mizchi12kagura__core10statistics10percentile(intervals, 0.95));
}
function _M0FP36mizchi21kagura__platform__web7interop5field(value, key) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? _M0FP36mizchi2js4core9undefined() : _M0MP36mizchi2js4core3Any5__get(value, key);
}
function _M0FP36mizchi21kagura__platform__web7interop8fallback(value, default_) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? default_ : value;
}
function _M0FP36mizchi21kagura__platform__web7interop8argument(value, default_) {
  return _M0FP36mizchi2js4core13is__undefined(value) ? default_ : value;
}
function _M0FP36mizchi21kagura__platform__web7interop13number__field(value, key, default_) {
  return _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(value, key), default_);
}
function _M0FP36mizchi21kagura__platform__web7interop13array__values(value) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? [] : _M0FP36mizchi2js4core11array__from(value);
}
function _M0FP36mizchi21kagura__platform__web7interop5clamp(value, low, high) {
  return _M0MPC16double6Double3min(_M0MPC16double6Double3max(value, low), high);
}
function _M0FP36mizchi21kagura__platform__web7interop6vector(x, y) {
  return _M0FP36mizchi2js4core13from__entries([{ _0: "x", _1: x }, { _0: "y", _1: y }]);
}
function _M0FP36mizchi21kagura__platform__web7interop6length(value) {
  return _M0MP36mizchi2js4core3Any5__get(value, "length");
}
function _M0FP36mizchi21kagura__platform__web11diagnostics10percentile(values, p) {
  const _p = _M0FP36mizchi21kagura__platform__web7interop13array__values(values);
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = _p$5;
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi12kagura__core10statistics10percentile(_p$2, p);
}
function _M0FP36mizchi21kagura__platform__web11diagnostics20summarize__intervals(timestamps) {
  const _p = _M0FP36mizchi21kagura__platform__web7interop13array__values(timestamps);
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = _p$5;
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const result = _M0FP36mizchi12kagura__core10statistics20summarize__intervals(_p$2);
  return _M0FP36mizchi2js4core13from__entries([{ _0: "frames", _1: result.frames }, { _0: "elapsedMs", _1: _M0MP46mizchi2js8builtins4math4Math5round(result.elapsed_ms) }, { _0: "fps", _1: _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal(result.fps, 1) }, { _0: "p50IntervalMs", _1: _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal(result.p50_ms, 2) }, { _0: "p95IntervalMs", _1: _M0FP36mizchi21kagura__platform__web7interop14fixed__decimal(result.p95_ms, 2) }]);
}
function _M0FP36mizchi21kagura__platform__web11diagnostics6timing(value) {
  return _M0FP36mizchi21kagura__platform__web7interop6finite(value) && value >= 0 ? value : _M0FP36mizchi2js4core4null();
}
function _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profile(host) {
  const host$2 = _M0FP36mizchi21kagura__platform__web7interop8argument(host, _M0FP36mizchi2js4core12global__this());
  const runtime = _M0FP36mizchi21kagura__platform__web7interop5field(host$2, "__kaguraWebRuntime");
  const gpu = _M0FP36mizchi21kagura__platform__web7interop5field(runtime, "webgpu");
  if (!_M0FP36mizchi21kagura__platform__web7interop6truthy(gpu)) {
    return _M0FP36mizchi2js4core4null();
  }
  const phases = _M0FP36mizchi21kagura__platform__web7interop5field(runtime, "frameProfile");
  const commands = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "commands"));
  let indices = 0;
  let instances = 0;
  let shared = 0;
  const _bind = commands.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const command = commands[_];
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
  const timing_method = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "_gpuTimingMethod"), _M0FP36mizchi2js4core4null());
  const snapshot = _M0FP36mizchi2js4core13from__entries([{ _0: "version", _1: 1 }, { _0: "frame", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "_submittedFrameCount"), 0) }, { _0: "gpuFrameMs", _1: _M0FP36mizchi2js4core11is__nullish(timing_method) ? _M0FP36mizchi2js4core4null() : _M0FP36mizchi21kagura__platform__web11diagnostics6timing(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, _M0FP36mizchi2js4core5equal(timing_method, "timestamp-query") ? "_lastTimestampFrameMs" : "_lastCompletedFrameMs")) }, { _0: "gpuTimingMethod", _1: timing_method }, { _0: "drawCalls", _1: commands.length }, { _0: "indexCount", _1: indices }, { _0: "instanceCount", _1: instances }, { _0: "sharedGeometryDraws", _1: shared }, { _0: "residentGeometryBuffers", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(_M0FP36mizchi21kagura__platform__web7interop5field(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, "_sharedGeometryBuffers"), "resident"), "size"), 0) }]);
  const _bind$2 = ["updateMs", "drawCallbackMs", "renderCommandsMs"];
  const _bind$3 = _bind$2.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const key = _bind$2[_];
      _M0MP36mizchi2js4core3Any5__set(snapshot, key, _M0FP36mizchi21kagura__platform__web11diagnostics6timing(_M0FP36mizchi21kagura__platform__web7interop5field(phases, key)));
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$4 = [_M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS48, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS49, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS50, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS51, _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profileN5tupleS52];
  const _bind$5 = _bind$4.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$5) {
      const _foreach_element = _bind$4[_];
      const _key = _foreach_element._0;
      const _source = _foreach_element._1;
      _M0MP36mizchi2js4core3Any5__set(snapshot, _key, _M0FP36mizchi21kagura__platform__web11diagnostics6timing(_M0FP36mizchi21kagura__platform__web7interop5field(gpu, _source)));
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MP46mizchi2js8builtins6object6Object6freeze(snapshot);
}
function _M0FP36mizchi21kagura__platform__web11diagnostics24install__frame__profiler(host) {
  const host$2 = _M0FP36mizchi21kagura__platform__web7interop8argument(host, _M0FP36mizchi2js4core12global__this());
  const profiler = _M0MP46mizchi2js8builtins6object6Object6freeze(_M0FP36mizchi2js4core13from__entries([{ _0: "version", _1: 1 }, { _0: "snapshot", _1: () => _M0FP36mizchi21kagura__platform__web11diagnostics20read__frame__profile(host$2) }]));
  _M0MP36mizchi2js4core3Any5__set(host$2, "__kaguraProfiler", profiler);
  return profiler;
}
function _M0MP46mizchi2js8builtins6regexp6RegExp6test__(self, string) {
  return _M0MP46mizchi2js8builtins6regexp6RegExp17ffi__regexp__test(self, string);
}
function _M0MP46mizchi2js8builtins6regexp6RegExp3new(pattern, flags) {
  let flags_str;
  if (flags === undefined) {
    flags_str = "";
  } else {
    const _Some = flags;
    flags_str = _Some;
  }
  return _M0FP46mizchi2js8builtins6regexp16ffi__regexp__new(pattern, flags_str);
}
function _M0FP36mizchi21kagura__platform__web5input9pad__axis(value) {
  return _M0FP36mizchi21kagura__platform__web7interop6finite(value) ? _M0FP36mizchi21kagura__platform__web7interop5clamp(value, -1, 1) : 0;
}
function _M0FP36mizchi21kagura__platform__web5input6button(pressed, value) {
  return _M0FP36mizchi2js4core13from__entries([{ _0: "pressed", _1: pressed }, { _0: "value", _1: value }]);
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
  const mapping = _M0MP36mizchi2js4core3Any5__get(pad, "mapping");
  if (mapping === "standard") {
    return pad;
  }
  const axes = _M0MP36mizchi2js4core3Any5__get(pad, "axes");
  const raw_buttons = _M0MP36mizchi2js4core3Any5__get(pad, "buttons");
  let _tmp;
  const _p = "";
  if (!(mapping === _p)) {
    _tmp = true;
  } else {
    _tmp = !_M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web5input11victrix__id, _M0MP36mizchi2js4core3Any5__get(pad, "id")) || (_M0FP36mizchi21kagura__platform__web7interop6length(axes) !== 10 || _M0FP36mizchi21kagura__platform__web7interop6length(raw_buttons) < 14);
  }
  if (_tmp) {
    return _M0FP36mizchi2js4core4null();
  }
  const order = [1, 2, 0, 3, 4, 5, 6, 7, 8, 9, 10, 11, -1, -1, -1, -1, 12, 13];
  const _p$2 = new Array(order.length);
  const _p$3 = order.length;
  let _tmp$2 = 0;
  while (true) {
    const _p$4 = _tmp$2;
    if (_p$4 < _p$3) {
      const _p$5 = order[_p$4];
      _p$2[_p$4] = _M0FP36mizchi21kagura__platform__web5input11pad__button(_p$5 < 0 ? _M0FP36mizchi2js4core4null() : _M0MP36mizchi2js4core3Any16__get__by__index(raw_buttons, _p$5));
      _tmp$2 = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const buttons = _p$2;
  const _bind = [_M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS186, _M0FP36mizchi21kagura__platform__web5input18normalize__gamepadN5tupleS187];
  const _bind$2 = _bind.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$2) {
      const _foreach_element = _bind[_];
      const _axis_index = _foreach_element._0;
      const _button_index = _foreach_element._1;
      const raw = _M0MP36mizchi2js4core3Any16__get__by__index(axes, _axis_index);
      const value = _M0FP36mizchi21kagura__platform__web7interop6finite(raw) ? (_M0FP36mizchi21kagura__platform__web5input9pad__axis(raw) + 1) / 2 : 0;
      _M0MPC15array5Array3setGRP36mizchi2js4core3AnyE(buttons, _button_index, _M0FP36mizchi21kagura__platform__web5input6button(_M0FP36mizchi21kagura__platform__web5input12button__down(_M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(buttons, _button_index)) || value >= 0.55, value));
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const hat = _M0MP36mizchi2js4core3Any16__get__by__index(axes, 9);
  if (_M0FP36mizchi21kagura__platform__web7interop6finite(hat) && (hat >= -1 && hat <= 1)) {
    const position = (hat + 1) * 3.5;
    const direction = _M0MP46mizchi2js8builtins4math4Math5round(position);
    if (Math.abs(position - (direction + 0)) < 0.1) {
      const hats = [[12], [12, 15], [15], [13, 15], [13], [13, 14], [14], [12, 14]];
      const _bind$3 = _M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(hats, direction);
      const _bind$4 = _bind$3.length;
      let _tmp$4 = 0;
      while (true) {
        const _ = _tmp$4;
        if (_ < _bind$4) {
          const index = _bind$3[_];
          _M0MPC15array5Array3setGRP36mizchi2js4core3AnyE(buttons, index, _M0FP36mizchi21kagura__platform__web5input6button(true, 1));
          _tmp$4 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
    }
  }
  const _tmp$4 = { _0: "index", _1: _M0MP36mizchi2js4core3Any5__get(pad, "index") };
  const _tmp$5 = { _0: "id", _1: _M0MP36mizchi2js4core3Any5__get(pad, "id") };
  const _tmp$6 = { _0: "connected", _1: _M0MP36mizchi2js4core3Any5__get(pad, "connected") };
  const _tmp$7 = { _0: "mapping", _1: "standard" };
  const _tmp$8 = { _0: "profile", _1: "victrix-pro-bfg-ps5-mac" };
  const _p$4 = [0, 1, 2, 5];
  const _p$5 = new Array(_p$4.length);
  const _p$6 = _p$4.length;
  let _tmp$9 = 0;
  while (true) {
    const _p$7 = _tmp$9;
    if (_p$7 < _p$6) {
      const _p$8 = _p$4[_p$7];
      _p$5[_p$7] = _M0FP36mizchi21kagura__platform__web5input9pad__axis(_M0MP36mizchi2js4core3Any16__get__by__index(axes, _p$8));
      _tmp$9 = _p$7 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi2js4core13from__entries([_tmp$4, _tmp$5, _tmp$6, _tmp$7, _tmp$8, { _0: "axes", _1: _p$5 }, { _0: "buttons", _1: buttons }]);
}
function _M0FP36mizchi21kagura__platform__web5input11device__key(pad) {
  const index = _M0MP36mizchi2js4core3Any10to__string(_M0MP36mizchi2js4core3Any5__get(pad, "index"));
  const id = _M0MP36mizchi2js4core3Any5__get(pad, "id");
  const profile = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0MP36mizchi2js4core3Any5__get(pad, "profile"), _M0MP36mizchi2js4core3Any5__get(pad, "mapping"));
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(2);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, index);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ":");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, id);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ":");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, profile);
  return _string_builder.val;
}
function _M0FP36mizchi21kagura__platform__web5input13radial__stick(dx, dy, radius, dead_zone) {
  const length = _M0MP46mizchi2js8builtins4math4Math5hypot([dx, dy]);
  if (length === 0 || length < radius * dead_zone) {
    return _M0FP36mizchi21kagura__platform__web5input13radial__stickN5tupleS188;
  }
  const magnitude = _M0MPC16double6Double3min((length / radius - dead_zone) / (1 - dead_zone), 1);
  return { _0: dx / length * magnitude, _1: dy / length * magnitude };
}
function _M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS53(axes, i) {
  return _M0FP36mizchi21kagura__platform__web5input9pad__axis(_M0FP36mizchi2js4core11is__nullish(axes) ? _M0FP36mizchi2js4core9undefined() : _M0MP36mizchi2js4core3Any16__get__by__index(axes, i));
}
function _M0MP36mizchi21kagura__platform__web5input12GamepadState4step(self, pads, options) {
  const enabled = _M0FP36mizchi21kagura__platform__web7interop6truthy(_M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "enabled"), true));
  const _p = _M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "now"), 0);
  const now = _p;
  const _p$2 = _M0FP36mizchi21kagura__platform__web7interop13array__values(pads);
  const _p$3 = [];
  const _p$4 = _p$2.length;
  let _tmp = 0;
  while (true) {
    const _p$5 = _tmp;
    if (_p$5 < _p$4) {
      const _p$6 = _p$2[_p$5];
      if (_M0FP36mizchi21kagura__platform__web7interop6truthy(_p$6) && !_M0FP36mizchi2js4core5equal(_M0FP36mizchi21kagura__platform__web7interop5field(_p$6, "connected"), false)) {
        _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(_p$3, _p$6);
      }
      _tmp = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const connected = _p$3;
  const _p$5 = new Array(connected.length);
  const _p$6 = connected.length;
  let _tmp$2 = 0;
  while (true) {
    const _p$7 = _tmp$2;
    if (_p$7 < _p$6) {
      const _p$8 = connected[_p$7];
      _p$5[_p$7] = _M0FP36mizchi21kagura__platform__web5input18normalize__gamepad(_p$8);
      _tmp$2 = _p$7 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _p$7 = _p$5;
  const _p$8 = [];
  const _p$9 = _p$7.length;
  let _tmp$3 = 0;
  while (true) {
    const _p$10 = _tmp$3;
    if (_p$10 < _p$9) {
      const _p$11 = _p$7[_p$10];
      if (!_M0FP36mizchi2js4core11is__nullish(_p$11)) {
        _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(_p$8, _p$11);
      }
      _tmp$3 = _p$10 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const candidates = _p$8;
  let selected = _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None__;
  const _bind = candidates.length;
  let _tmp$4 = 0;
  while (true) {
    const _ = _tmp$4;
    if (_ < _bind) {
      const candidate = candidates[_];
      if (_M0IPC16option6OptionPB2Eq5equalGsE(_M0FP36mizchi21kagura__platform__web5input11device__key(candidate), self.identity)) {
        selected = new _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some(candidate);
        break;
      }
      _tmp$4 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$2 = selected;
  let pad;
  if (_bind$2.$tag === 1) {
    const _Some = _bind$2;
    pad = _Some._0;
  } else {
    pad = candidates.length === 0 ? _M0FP36mizchi2js4core4null() : _M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(candidates, 0);
  }
  const supported = !_M0FP36mizchi2js4core11is__nullish(pad);
  const next_identity = supported ? _M0FP36mizchi21kagura__platform__web5input11device__key(pad) : undefined;
  const changed = _M0IP016_24default__implPB2Eq10not__equalGOsE(next_identity, self.identity);
  const _bind$3 = self.last_time;
  let dt;
  if (_bind$3.$tag === 0) {
    dt = 0;
  } else {
    const _Some = _bind$3;
    const _last = _Some._0;
    dt = _M0FP36mizchi21kagura__platform__web7interop5clamp((now - _last) / 1000, 0, 0.05);
  }
  self.last_time = new _M0DTPC16option6OptionGdE4Some(now);
  const old_buttons = self.previous;
  if (changed || !enabled) {
    self.identity = next_identity;
    self.armed = false;
    self.previous = [];
    self.previous_axes = [0, 0, 0, 0];
    self.direction = undefined;
  }
  const axes = _M0FP36mizchi21kagura__platform__web7interop5field(pad, "axes");
  const _bind$4 = _M0FP36mizchi21kagura__platform__web5input13radial__stick(_M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS53(axes, 0), _M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS53(axes, 1), 1, self.dead_zone);
  const _mx = _bind$4._0;
  const _my = _bind$4._1;
  const _bind$5 = _M0FP36mizchi21kagura__platform__web5input13radial__stick(_M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS53(axes, 2), _M0MP36mizchi21kagura__platform__web5input12GamepadState4stepN8axis__atS53(axes, 3), 1, self.dead_zone);
  const _lx = _bind$5._0;
  const _ly = _bind$5._1;
  const _p$10 = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "buttons"));
  const _p$11 = new Array(_p$10.length);
  const _p$12 = _p$10.length;
  let _tmp$5 = 0;
  while (true) {
    const _p$13 = _tmp$5;
    if (_p$13 < _p$12) {
      const _p$14 = _p$10[_p$13];
      _p$11[_p$13] = _M0FP36mizchi21kagura__platform__web5input12button__down(_p$14);
      _tmp$5 = _p$13 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const buttons = _p$11;
  const neutral = !_M0MPC15array5Array8containsGbE(buttons, true) && (_mx === 0 && (_my === 0 && (_lx === 0 && _ly === 0)));
  if (supported && (enabled && neutral)) {
    self.armed = true;
  }
  const ready = supported && (enabled && self.armed);
  const down = [];
  if (ready) {
    let _tmp$6 = 0;
    while (true) {
      const i = _tmp$6;
      if (i < buttons.length) {
        if (_M0MPC15array5Array2atGbE(buttons, i)) {
          _M0MPC15array5Array4pushGiE(down, i);
        }
        _tmp$6 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  const _p$13 = [];
  const _p$14 = down.length;
  let _tmp$6 = 0;
  while (true) {
    const _p$15 = _tmp$6;
    if (_p$15 < _p$14) {
      const _p$16 = down[_p$15];
      if (!_M0MPC15array5Array8containsGiE(self.previous, _p$16)) {
        _M0MPC15array5Array4pushGiE(_p$13, _p$16);
      }
      _tmp$6 = _p$15 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const pressed = _p$13;
  const _p$15 = [];
  const _p$16 = old_buttons.length;
  let _tmp$7 = 0;
  while (true) {
    const _p$17 = _tmp$7;
    if (_p$17 < _p$16) {
      const _p$18 = old_buttons[_p$17];
      if (!_M0MPC15array5Array8containsGiE(down, _p$18)) {
        _M0MPC15array5Array4pushGiE(_p$15, _p$18);
      }
      _tmp$7 = _p$17 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const released = _p$15;
  const vectors = [_mx, _my, _lx, _ly];
  let axis_activity = false;
  let _tmp$8 = 0;
  while (true) {
    const i = _tmp$8;
    if (i < 4) {
      if (Math.abs(_M0MPC15array5Array2atGdE(vectors, i) - _M0MPC15array5Array2atGdE(self.previous_axes, i)) > 0.025) {
        axis_activity = true;
      }
      _tmp$8 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const activity = ready && (!(pressed.length === 0) || (!(released.length === 0) || axis_activity));
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
  const _tmp$9 = { _0: "connected", _1: !(connected.length === 0) };
  const _tmp$10 = { _0: "supported", _1: supported };
  const _tmp$11 = { _0: "ready", _1: ready };
  const _tmp$12 = { _0: "index", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "index"), -1) };
  const _tmp$13 = { _0: "id", _1: _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "id"), connected.length === 0 ? "" : _M0MP36mizchi2js4core3Any5__get(_M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(connected, 0), "id")) };
  const _tmp$14 = { _0: "profile", _1: supported ? _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(pad, "profile"), "standard") : _M0FP36mizchi2js4core4null() };
  const _tmp$15 = { _0: "move", _1: ready ? _M0FP36mizchi21kagura__platform__web7interop6vector(_mx, _my) : _M0FP36mizchi21kagura__platform__web7interop6vector(0, 0) };
  const _tmp$16 = { _0: "look", _1: ready ? _M0FP36mizchi21kagura__platform__web7interop6vector(_lx, _ly) : _M0FP36mizchi21kagura__platform__web7interop6vector(0, 0) };
  const _tmp$17 = { _0: "down", _1: down };
  const _tmp$18 = { _0: "pressed", _1: pressed };
  const _tmp$19 = { _0: "released", _1: released };
  const _tmp$20 = { _0: "activity", _1: activity };
  const _bind$6 = navigation;
  let _tmp$21;
  if (_bind$6 === undefined) {
    _tmp$21 = _M0FP36mizchi2js4core4null();
  } else {
    const _Some = _bind$6;
    const _s = _Some;
    _tmp$21 = _s;
  }
  return _M0FP36mizchi2js4core13from__entries([_tmp$9, _tmp$10, _tmp$11, _tmp$12, _tmp$13, _tmp$14, _tmp$15, _tmp$16, _tmp$17, _tmp$18, _tmp$19, _tmp$20, { _0: "navigation", _1: _tmp$21 }, { _0: "dt", _1: dt }]);
}
function _M0FP36mizchi21kagura__platform__web5input23create__gamepad__reader(options) {
  const dead_zone = _M0FP36mizchi21kagura__platform__web7interop8argument(_M0FP36mizchi21kagura__platform__web7interop5field(options, "deadZone"), 0.18);
  if (!_M0FP36mizchi21kagura__platform__web7interop6finite(dead_zone) || (dead_zone < 0 || dead_zone >= 1)) {
    _M0FP36mizchi21kagura__platform__web7interop12range__error("Stick coordinates must be finite, radius positive, and deadZone in [0, 1)");
  }
  const state = new _M0TP36mizchi21kagura__platform__web5input12GamepadState(dead_zone, undefined, false, [], [0, 0, 0, 0], undefined, 0, _M0DTPC16option6OptionGdE4None__);
  return _M0FP36mizchi2js4core13from__entries([{ _0: "step", _1: (pads, options$2) => _M0MP36mizchi21kagura__platform__web5input12GamepadState4step(state, pads, options$2) }]);
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
  let _tmp = self.held.length - 1 | 0;
  while (true) {
    const i = _tmp;
    if (i >= 0) {
      if (_M0MPC15array5Array2atGUdRP36mizchi2js4core3AnyEE(self.held, i)._0 === id) {
        _M0MPC15array5Array6removeGUdRP36mizchi2js4core3AnyEE(self.held, i);
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
  const state = new _M0TP36mizchi21kagura__platform__web5input12ControlState(capacity, [], [], _M0DTPC16option6OptionGdE4None__, 0, 0, false);
  return _M0FP36mizchi2js4core13from__entries([{ _0: "version", _1: 1 }, { _0: "move", _1: (id, dx, dy) => {
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
      if (i < state.held.length) {
        if (_M0MPC15array5Array2atGUdRP36mizchi2js4core3AnyEE(state.held, i)._0 === id) {
          _M0MPC15array5Array3setGUdRP36mizchi2js4core3AnyEE(state.held, i, { _0: id, _1: action });
          return undefined;
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    _M0MPC15array5Array4pushGUdRP36mizchi2js4core3AnyEE(state.held, { _0: id, _1: action });
  } }, { _0: "release", _1: (id) => {
    _M0MP36mizchi21kagura__platform__web5input12ControlState7release(state, id);
  } }, { _0: "tap", _1: (key, payload) => {
    if (!_M0FP36mizchi21kagura__platform__web7interop13safe__integer(key) || key <= 0) {
      _M0FP36mizchi21kagura__platform__web7interop12range__error("Command key must be a positive integer");
    }
    if (state.commands.length + 0 >= state.capacity) {
      return false;
    }
    _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(state.commands, _M0FP36mizchi2js4core13from__entries([{ _0: "key", _1: key }, { _0: "payload", _1: _M0FP36mizchi21kagura__platform__web7interop8argument(payload, _M0FP36mizchi2js4core4null()) }]));
    return true;
  } }, { _0: "consumeCommand", _1: () => {
    if (state.release_pending) {
      state.release_pending = false;
      return _M0FP36mizchi2js4core4null();
    }
    const _p = state.commands;
    if (_p.length === 0) {
      return _M0FP36mizchi2js4core4null();
    }
    state.release_pending = true;
    return _M0MPC15array5Array6removeGRP36mizchi2js4core3AnyE(state.commands, 0);
  } }, { _0: "snapshot", _1: () => {
    const actions = [];
    const _bind = state.held;
    const _bind$2 = _bind.length;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind$2) {
        const _foreach_element = _bind[_];
        const _action = _foreach_element._1;
        if (!_M0MPC15array5Array8containsGRP36mizchi2js4core3AnyE(actions, _action)) {
          _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(actions, _action);
        }
        _tmp = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _M0FP36mizchi2js4core13from__entries([{ _0: "x", _1: state.x }, { _0: "y", _1: state.y }, { _0: "actions", _1: actions }]);
  } }, { _0: "clear", _1: () => {
    _M0MPC15array5Array5clearGUdRP36mizchi2js4core3AnyEE(state.held);
    _M0MPC15array5Array5clearGRP36mizchi2js4core3AnyE(state.commands);
    state.owner = _M0DTPC16option6OptionGdE4None__;
    state.x = 0;
    state.y = 0;
    state.release_pending = false;
  } }]);
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
    _M0FP36mizchi2js4core12throw__error("Expected finite time");
  }
  return value;
}
function _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(self) {
  const _p = _M0MP36mizchi2js4core3Any5__get(self.clip, "duration");
  return _p;
}
function _M0FP36mizchi21kagura__platform__web8playback22create__motion__player(asset) {
  const clips = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0MP36mizchi2js4core3Any5__get(asset, "clips"));
  const state = new _M0TP36mizchi21kagura__platform__web8playback12MotionPlayer(clips, _M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(clips, 0), _M0MP36mizchi6anim3d8playback8Timeline11new_2einner(false));
  return _M0MP46mizchi2js8builtins6object6Object6freeze(_M0FP36mizchi2js4core13from__entries([{ _0: "snapshot", _1: () => {
    const _p = _M0MP36mizchi2js4core3Any5__get(state.clip, "fps");
    const fps = _p;
    return _M0FP36mizchi2js4core13from__entries([{ _0: "clip", _1: _M0MP36mizchi2js4core3Any5__get(state.clip, "id") }, { _0: "time", _1: state.timeline.time }, { _0: "duration", _1: _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state) }, { _0: "fps", _1: fps }, { _0: "frame", _1: _M0MP46mizchi2js8builtins4math4Math5round(state.timeline.time * fps) }, { _0: "playing", _1: state.timeline.playing }, { _0: "speed", _1: state.timeline.speed }, { _0: "loop", _1: state.timeline.looping }]);
  } }, { _0: "selectClip", _1: (id) => {
    const _bind = state.clips;
    const _bind$2 = _bind.length;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind$2) {
        const clip = _bind[_];
        if (_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(clip, "id"), id)) {
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
    _M0FP36mizchi2js4core12throw__error("Unknown motion clip");
  } }, { _0: "play", _1: () => {
    _M0MP36mizchi6anim3d8playback8Timeline12play_2einner(state.timeline, _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state), true);
  } }, { _0: "pause", _1: () => {
    state.timeline.playing = false;
  } }, { _0: "seek", _1: (value) => {
    _M0MP36mizchi6anim3d8playback8Timeline4seek(state.timeline, _M0FP36mizchi21kagura__platform__web8playback13require__time(value), _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state));
  } }, { _0: "step", _1: (direction) => {
    if (!_M0FP36mizchi2js4core5equal(direction, -1) && !_M0FP36mizchi2js4core5equal(direction, 1)) {
      _M0FP36mizchi2js4core12throw__error("Step must be -1 or 1");
    }
    const _p = _M0MP36mizchi2js4core3Any5__get(state.clip, "fps");
    const fps = _p;
    state.timeline.time = _M0FP36mizchi21kagura__platform__web7interop5clamp((_M0MP46mizchi2js8builtins4math4Math5round(state.timeline.time * fps) + 0 + direction) / fps, 0, _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state));
    state.timeline.playing = false;
  } }, { _0: "setSpeed", _1: (value) => {
    const speed = _M0FP36mizchi21kagura__platform__web8playback13require__time(value);
    if (speed < 0.1 || speed > 4) {
      _M0FP36mizchi2js4core12throw__error("Speed must be 0.1..4");
    }
    state.timeline.speed = speed;
  } }, { _0: "setLoop", _1: (value) => {
    const _p = _M0FP36mizchi2js4core8typeof__(value);
    const _p$2 = "boolean";
    if (!(_p === _p$2)) {
      _M0FP36mizchi2js4core12throw__error("Loop must be boolean");
    }
    state.timeline.looping = value;
  } }, { _0: "tick", _1: (value) => {
    const delta = _M0FP36mizchi21kagura__platform__web8playback13require__time(value);
    if (delta < 0) {
      _M0FP36mizchi2js4core12throw__error("Negative time delta");
    }
    _M0MP36mizchi6anim3d8playback8Timeline15advance_2einner(state.timeline, delta, _M0MP36mizchi21kagura__platform__web8playback12MotionPlayer8duration(state), true, false);
  } }]));
}
function _M0MP46mizchi2js8builtins10collection5JsMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE() {
  return _M0FP46mizchi2js8builtins10collection13ffi__new__map();
}
function _M0MP46mizchi2js8builtins10collection5JsMap3setGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(self, key, value) {
  return _M0MP36mizchi2js4core3Any6__call(self, "set", [key, value]);
}
function _M0MP46mizchi2js8builtins10collection5JsMap3getGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(self, key) {
  const result = _M0MP36mizchi2js4core3Any6__call(self, "get", [key]);
  return _M0FP36mizchi2js4core13is__undefined(result) ? _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None__ : new _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some(result);
}
function _M0MP46mizchi2js8builtins10collection5JsMap6deleteGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(self, key) {
  return _M0MP36mizchi2js4core3Any6__call(self, "delete", [key]);
}
function _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE() {
  return _M0FP46mizchi2js8builtins4weak17ffi__new__weakmap();
}
function _M0MP46mizchi2js8builtins4weak7WeakMap6deleteGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(self, key) {
  return _M0MP36mizchi2js4core3Any6__call(self, "delete", [key]);
}
function _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(self, key) {
  const result = _M0MP36mizchi2js4core3Any6__call(self, "get", [key]);
  return _M0FP36mizchi2js4core13is__undefined(result) ? _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None__ : new _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4Some(result);
}
function _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(self, key, value) {
  return _M0MP36mizchi2js4core3Any6__call(self, "set", [key, value]);
}
function _M0FP36mizchi21kagura__platform__web6render12is__stride32(source) {
  return _M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web6render17position__pattern, source);
}
function _M0FP36mizchi21kagura__platform__web6render12is__stride64(source) {
  return _M0FP36mizchi21kagura__platform__web6render12is__stride32(source) && (_M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web6render15joints__pattern, source) && _M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi21kagura__platform__web6render16weights__pattern, source));
}
function _M0FP36mizchi21kagura__platform__web6render14is__3d__shader(source) {
  return _M0FP36mizchi21kagura__platform__web6render12is__stride32(source) || _M0FP36mizchi21kagura__platform__web6render12is__stride64(source);
}
function _M0FP36mizchi21kagura__platform__web6render21command__needs__depth(command) {
  const hint = _M0FP36mizchi21kagura__platform__web7interop13number__field(command, "vertexStrideHint", 0);
  return _M0FP36mizchi21kagura__platform__web7interop6truthy(_M0MP36mizchi2js4core3Any5__get(command, "isCustom")) && (hint > 0 ? hint >= 8 : _M0FP36mizchi21kagura__platform__web6render14is__3d__shader(_M0MP36mizchi2js4core3Any5__get(command, "shaderSource")));
}
function _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindings(source) {
  const pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("@binding\\((\\d+)\\)\\s+var\\s+\\w+\\s*:\\s*(texture_2d<f32>|texture_2d|sampler)", _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN6constrS194);
  const bindings = [];
  while (true) {
    const matched = _M0MP36mizchi2js4core3Any6__call(pattern, "exec", [source]);
    if (_M0FP36mizchi2js4core11is__nullish(matched)) {
      break;
    }
    const text = _M0MP36mizchi2js4core3Any16__get__by__index(matched, 1);
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
    const raw = _M0MP36mizchi2js4core3Any16__get__by__index(matched, 2);
    _M0MPC15array5Array4pushGUdRP36mizchi2js4core3AnyEE(bindings, { _0: index, _1: _M0MPC16string6String11has__prefix(raw, new _M0TPC16string10StringView(_M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN7_2abindS108, 0, _M0FP36mizchi21kagura__platform__web6render24parse__texture__bindingsN7_2abindS108.length)) ? "texture" : "sampler" });
    continue;
  }
  _M0MPC15array5Array8sort__byGUisEE(bindings, (a, b) => $compare_int(a._0, b._0));
  const _p = new Array(bindings.length);
  const _p$2 = bindings.length;
  let _tmp = 0;
  while (true) {
    const _p$3 = _tmp;
    if (_p$3 < _p$2) {
      const _p$4 = bindings[_p$3];
      _p[_p$3] = _M0FP36mizchi2js4core13from__entries([{ _0: "binding", _1: _p$4._0 }, { _0: "type", _1: _p$4._1 }]);
      _tmp = _p$3 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _p;
}
function _M0FP36mizchi21kagura__platform__web6render20get__instance__count(command) {
  const raw = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(command, "instanceCount"), _M0FP36mizchi21kagura__platform__web7interop5field(command, "instance_count"));
  if (_M0FP36mizchi21kagura__platform__web7interop6finite(raw)) {
    const _p = _M0FP36mizchi21kagura__platform__web6render7to__i32(raw);
    const _p$2 = 1;
    return _p > _p$2 ? _p : _p$2;
  } else {
    return 1;
  }
}
function _M0FP36mizchi21kagura__platform__web6render25get__resource__cache__key(command) {
  const raw = _M0FP36mizchi21kagura__platform__web7interop8fallback(_M0FP36mizchi21kagura__platform__web7interop5field(command, "resourceCacheKey"), _M0FP36mizchi21kagura__platform__web7interop5field(command, "resource_cache_key"));
  return _M0FP36mizchi21kagura__platform__web7interop6finite(raw) ? _M0FP36mizchi21kagura__platform__web6render7to__i32(raw) : 0;
}
function _M0FP36mizchi21kagura__platform__web6render13equal__dwords(a, b, count) {
  if (_M0FP36mizchi2js4core5equal(a, b)) {
    return true;
  }
  if (_M0FP36mizchi2js4core11is__nullish(a) || _M0FP36mizchi2js4core11is__nullish(b)) {
    return false;
  }
  const count$2 = _M0FP36mizchi21kagura__platform__web7interop8argument(count, _M0MP36mizchi2js4core3Any5__get(b, "length"));
  let _tmp;
  if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(a, "length"), count$2)) {
    _tmp = true;
  } else {
    const _p = _M0MP36mizchi2js4core3Any5__get(b, "length");
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
      if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any16__get__by__index(a, i), _M0MP36mizchi2js4core3Any16__get__by__index(b, i))) {
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
  const replacements = [_M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS195, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS196, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS197, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS198, _M0FP36mizchi21kagura__platform__web6render25instance__uniform__shaderN5tupleS199];
  let result = source;
  const _bind = replacements.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const _foreach_element = replacements[_];
      const _from = _foreach_element._0;
      const _to = _foreach_element._1;
      if (!_M0MPC16string6String8contains(result, new _M0TPC16string10StringView(_from, 0, _from.length))) {
        _M0FP36mizchi2js4core12throw__error(`Unsupported instance shader entry-point contract: ${_from}`);
      }
      result = _M0FP36mizchi21kagura__platform__web6render14replace__first(result, _from, _to);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return `// kagura-instance-dwords: ${_M0MP36mizchi2js4core3Any10to__string(dwords)}\n${result}`;
}
function _M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu) {
  const current = _M0MP36mizchi2js4core3Any5__get(gpu, "_registeredGeometry");
  if (!_M0FP36mizchi2js4core11is__nullish(current)) {
    return current;
  }
  const pairs = _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
  _M0MP36mizchi2js4core3Any5__set(gpu, "_registeredGeometry", pairs);
  return pairs;
}
function _M0FP36mizchi21kagura__platform__web6render18geometry__snapshot(vertices, indices) {
  return _M0FP36mizchi2js4core13from__entries([{ _0: "vertexData", _1: _M0FP36mizchi21kagura__platform__web6render13float32__copy(vertices) }, { _0: "indices", _1: _M0FP36mizchi21kagura__platform__web6render12uint32__copy(indices) }, { _0: "immutableGeometry", _1: true }, { _0: "sharedGeometry", _1: true }]);
}
function _M0FP36mizchi21kagura__platform__web6render18register__geometry(gpu, id, revision, vertices, indices) {
  let _tmp;
  let _tmp$2;
  const _p = _M0FP36mizchi2js4core8typeof__(id);
  const _p$2 = "string";
  if (!(_p === _p$2)) {
    let _tmp$3;
    const _p$3 = _M0FP36mizchi2js4core8typeof__(id);
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
  if (_M0FP36mizchi2js4core11is__nullish(_M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry"))) {
    const registry$2 = _M0MP46mizchi2js8builtins10collection5JsMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
    _M0MP36mizchi2js4core3Any5__set(gpu, "_geometryRegistry", registry$2);
    registry = registry$2;
  } else {
    registry = _M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry");
  }
  const pairs = _M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu);
  const old = _M0MP46mizchi2js8builtins10collection5JsMap3getGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id);
  if (old.$tag === 1) {
    const _Some = old;
    const _entry = _Some._0;
    const _p$3 = _M0MP36mizchi2js4core3Any5__get(_entry, "revision");
    const old_revision = _p$3;
    if (revision < old_revision) {
      _M0FP36mizchi21kagura__platform__web7interop12range__error("Stale geometry revision");
    }
    if (revision === old_revision) {
      if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(_entry, "vertices"), vertices) || !_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(_entry, "sourceIndices"), indices)) {
        _M0FP36mizchi2js4core12throw__error("Advance revision when replacing geometry");
      }
      return _M0MP36mizchi2js4core3Any5__get(_entry, "snapshot");
    }
  }
  const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(pairs, vertices);
  let by_index;
  if (_bind.$tag === 1) {
    const _Some = _bind;
    by_index = _Some._0;
  } else {
    by_index = _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
  }
  const _bind$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(by_index, indices);
  if (_bind$2.$tag === 1) {
    const _Some = _bind$2;
    const _owner = _Some._0;
    if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(_owner, "id"), id)) {
      _M0FP36mizchi2js4core12throw__error("Geometry arrays already registered with another ID");
    }
  }
  if (old.$tag === 1) {
    const _Some = old;
    const _entry = _Some._0;
    const _bind$3 = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(pairs, _M0MP36mizchi2js4core3Any5__get(_entry, "vertices"));
    if (_bind$3.$tag === 1) {
      const _Some$2 = _bind$3;
      const _map = _Some$2._0;
      _M0MP46mizchi2js8builtins4weak7WeakMap6deleteGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(_map, _M0MP36mizchi2js4core3Any5__get(_entry, "sourceIndices"));
    }
  }
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(pairs, vertices, by_index);
  const snapshot = _M0FP36mizchi21kagura__platform__web6render18geometry__snapshot(vertices, indices);
  const entry = _M0FP36mizchi2js4core13from__entries([{ _0: "id", _1: id }, { _0: "revision", _1: revision }, { _0: "vertices", _1: vertices }, { _0: "sourceIndices", _1: indices }, { _0: "snapshot", _1: snapshot }]);
  _M0MP46mizchi2js8builtins10collection5JsMap3setGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id, entry);
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(by_index, indices, entry);
  return snapshot;
}
function _M0FP36mizchi21kagura__platform__web6render20unregister__geometry(gpu, id) {
  if (_M0FP36mizchi2js4core11is__nullish(_M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry"))) {
    return undefined;
  }
  const registry = _M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry");
  const _bind = _M0MP46mizchi2js8builtins10collection5JsMap3getGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _entry = _Some._0;
    const _bind$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(_M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu), _M0MP36mizchi2js4core3Any5__get(_entry, "vertices"));
    if (_bind$2.$tag === 1) {
      const _Some$2 = _bind$2;
      const _map = _Some$2._0;
      _M0MP46mizchi2js8builtins4weak7WeakMap6deleteGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(_map, _M0MP36mizchi2js4core3Any5__get(_entry, "sourceIndices"));
    }
    _M0MP46mizchi2js8builtins10collection5JsMap6deleteGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id);
    return;
  } else {
    return;
  }
}
function _M0FP36mizchi21kagura__platform__web6render26register__static__geometry(gpu, vertices, indices) {
  const pairs = _M0FP36mizchi21kagura__platform__web6render15geometry__pairs(gpu);
  const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(pairs, vertices);
  let by_index;
  if (_bind.$tag === 1) {
    const _Some = _bind;
    by_index = _Some._0;
  } else {
    by_index = _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
  }
  const _bind$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(by_index, indices);
  if (_bind$2.$tag === 1) {
    const _Some = _bind$2;
    const _registered = _Some._0;
    return _M0MP36mizchi2js4core3Any5__get(_registered, "snapshot");
  }
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(pairs, vertices, by_index);
  const snapshot = _M0FP36mizchi21kagura__platform__web6render18geometry__snapshot(vertices, indices);
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(by_index, indices, _M0FP36mizchi2js4core13from__entries([{ _0: "id", _1: _M0FP36mizchi21kagura__platform__web6render14unique__symbol() }, { _0: "snapshot", _1: snapshot }]));
  return snapshot;
}
function _M0FP36mizchi21kagura__platform__web6render18snapshot__vertices(cache, source) {
  const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _previous = _Some._0;
    if (_M0FP36mizchi21kagura__platform__web7interop6length(_previous) === _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
      let i = 0;
      while (true) {
        if (i < _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
          const _tmp = _M0MP36mizchi2js4core3Any16__get__by__index(_previous, i);
          const _p = _M0MP36mizchi2js4core3Any16__get__by__index(source, i);
          if (!_M0MP46mizchi2js8builtins6object6Object4is__(_tmp, _M0MP46mizchi2js8builtins4math4Math6fround(_p))) {
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
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source, packed);
  return packed;
}
function _M0FP36mizchi21kagura__platform__web6render17snapshot__indices(cache, source) {
  const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _previous = _Some._0;
    if (_M0FP36mizchi21kagura__platform__web7interop6length(_previous) === _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
      let i = 0;
      while (true) {
        if (i < _M0FP36mizchi21kagura__platform__web7interop6length(source)) {
          if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any16__get__by__index(_previous, i), _M0FP36mizchi21kagura__platform__web6render10to__uint32(_M0MP36mizchi2js4core3Any16__get__by__index(source, i)))) {
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
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source, packed);
  return packed;
}
function _M0FP36mizchi21kagura__platform__web6render24snapshot__draw__geometry(gpu, vertices, indices) {
  const registered = _M0MP36mizchi2js4core3Any5__get(gpu, "_registeredGeometry");
  if (!_M0FP36mizchi2js4core11is__nullish(registered)) {
    const pairs = registered;
    const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(pairs, vertices);
    if (_bind.$tag === 1) {
      const _Some = _bind;
      const _map = _Some._0;
      const _bind$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(_map, indices);
      if (_bind$2.$tag === 1) {
        const _Some$2 = _bind$2;
        const _entry = _Some$2._0;
        return _M0MP36mizchi2js4core3Any5__get(_entry, "snapshot");
      }
    }
  }
  let cache = _M0MP36mizchi2js4core3Any5__get(gpu, "_geometrySnapshots");
  if (_M0FP36mizchi2js4core11is__nullish(cache)) {
    const vertices$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
    const indices$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
    cache = _M0FP36mizchi2js4core13from__entries([{ _0: "vertices", _1: vertices$2 }, { _0: "indices", _1: indices$2 }]);
    _M0MP36mizchi2js4core3Any5__set(gpu, "_geometrySnapshots", cache);
  }
  return _M0FP36mizchi2js4core13from__entries([{ _0: "vertexData", _1: _M0FP36mizchi21kagura__platform__web6render18snapshot__vertices(_M0MP36mizchi2js4core3Any5__get(cache, "vertices"), vertices) }, { _0: "indices", _1: _M0FP36mizchi21kagura__platform__web6render17snapshot__indices(_M0MP36mizchi2js4core3Any5__get(cache, "indices"), indices) }, { _0: "immutableGeometry", _1: true }]);
}
function _M0FP36mizchi21kagura__platform__web8ui__sync20apply__object__patch(previous, patch) {
  const value = _M0FP36mizchi21kagura__platform__web7interop14object__spread(_M0FP36mizchi21kagura__platform__web7interop6truthy(_M0MP36mizchi2js4core3Any5__get(patch, "full")) ? _M0FP36mizchi2js4core4null() : previous, _M0MP36mizchi2js4core3Any5__get(patch, "set"));
  const _bind = _M0FP36mizchi21kagura__platform__web7interop13array__values(_M0MP36mizchi2js4core3Any5__get(patch, "remove"));
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const key = _bind[_];
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
  const previous = _M0MPC13ref3Ref3RefGORP36mizchi2js4core3AnyE(_M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None__);
  return (dependencies) => {
    const count = _M0MP36mizchi2js4core3Any5__get(dependencies, "length");
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
            if (!_M0MP46mizchi2js8builtins6object6Object4is__(_M0MP36mizchi2js4core3Any16__get__by__index(dependencies, i), _M0MP36mizchi2js4core3Any16__get__by__index(_old, i))) {
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
    previous.val = new _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some(dependencies);
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
