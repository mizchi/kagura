// Generated from platform_js/web_core/*.mbt by just web-runtime-build. DO NOT EDIT.
// Source SHA-256: c9c180d52e526c486655626ff94b2007660e4ba505e3e1035861e6f7e6cb0996
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
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
function _M0TPB3MapGsdE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB5EntryGsdE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0DTPC16option6OptionGdE4None() {}
_M0DTPC16option6OptionGdE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGdE4None__ = new _M0DTPC16option6OptionGdE4None();
function _M0DTPC16option6OptionGdE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGdE4Some.prototype.$tag = 1;
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
const _M0FP46mizchi2js8builtins10collection13ffi__new__map = () => new Map();
function _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None() {}
_M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None__ = new _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None();
function _M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4Some.prototype.$tag = 1;
const _M0MP46mizchi2js8builtins4math4Math5floor = (x) => Math.floor(x);
const _M0MP46mizchi2js8builtins4math4Math5round = (x) => Math.round(x);
const _M0MP46mizchi2js8builtins4math4Math6fround = (x) => Math.fround(x);
const _M0MP46mizchi2js8builtins4math4Math5hypot = (values) => Math.hypot(...values);
const _M0FP46mizchi2js8builtins6object13object__class = () => Object;
const _M0FP46mizchi2js8builtins6regexp16ffi__regexp__new = (s, flags) => new RegExp(s, flags);
const _M0MP46mizchi2js8builtins6regexp6RegExp17ffi__regexp__test = (re, string) => re.test(string);
const _M0FP46mizchi2js8builtins4weak17ffi__new__weakmap = () => new WeakMap();
function _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None() {}
_M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None__ = new _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4None();
function _M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE4Some.prototype.$tag = 1;
const _M0FP36mizchi20kagura__platform__js9web__core11delete__key = (value, key) => { delete value[key]; };
const _M0FP36mizchi20kagura__platform__js9web__core14object__spread = (left, right) => ({...left, ...right});
const _M0FP36mizchi20kagura__platform__js9web__core6truthy = (value) => !!value;
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FP36mizchi20kagura__platform__js9web__core7to__i32 = (value) => value | 0;
const _M0FP36mizchi20kagura__platform__js9web__core6finite = (value) => Number.isFinite(value);
const _M0FP36mizchi20kagura__platform__js9web__core14replace__first = (source, from, to) => source.replace(from, to);
const _M0FP36mizchi20kagura__platform__js9web__core12range__error = (message) => { throw new RangeError(message); };
const _M0FP36mizchi20kagura__platform__js9web__core13safe__integer = (value) => Number.isSafeInteger(value);
function _M0TP36mizchi20kagura__platform__js9web__core12MotionPlayer(param0, param1, param2, param3, param4, param5) {
  this.clips = param0;
  this.clip = param1;
  this.time = param2;
  this.playing = param3;
  this.speed = param4;
  this.looping = param5;
}
function _M0TPB9ArrayViewGUsdEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP36mizchi20kagura__platform__js9web__core14fixed__decimal = (value, digits) => Number(value.toFixed(digits));
const _M0FP36mizchi20kagura__platform__js9web__core13float32__copy = (source) => new Float32Array(source);
const _M0FP36mizchi20kagura__platform__js9web__core12uint32__copy = (source) => new Uint32Array(source);
const _M0FP36mizchi20kagura__platform__js9web__core10to__uint32 = (source) => source >>> 0;
const _M0FP36mizchi20kagura__platform__js9web__core14unique__symbol = () => Symbol("static geometry");
const _M0FP36mizchi20kagura__platform__js9web__core11type__error = (message) => { throw new TypeError(message); };
function _M0TP36mizchi20kagura__platform__js9web__core12GamepadState(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.dead_zone = param0;
  this.identity = param1;
  this.armed = param2;
  this.previous = param3;
  this.previous_axes = param4;
  this.direction = param5;
  this.next_repeat = param6;
  this.last_time = param7;
}
function _M0TP36mizchi20kagura__platform__js9web__core12ControlState(param0, param1, param2, param3, param4, param5, param6) {
  this.capacity = param0;
  this.held = param1;
  this.commands = param2;
  this.owner = param3;
  this.x = param4;
  this.y = param5;
  this.release_pending = param6;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindingsN7_2abindS361 = "texture";
const _M0FP36mizchi20kagura__platform__js9web__core17position__pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("position\\s*:\\s*vec3<f32>", undefined);
const _M0FP36mizchi20kagura__platform__js9web__core16weights__pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("weights\\s*:\\s*vec4<f32>", undefined);
const _M0FP36mizchi20kagura__platform__js9web__core15joints__pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("joints\\s*:\\s*vec4<f32>", undefined);
const _M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindingsN6constrS597 = "g";
const _M0MPC16string10StringView4findN6constrS9865 = 0;
const _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS598 = { _0: "@group(0) @binding(0) var<uniform> uniforms: Uniforms;", _1: "struct InstanceUniforms { values: array<Uniforms, 32>, };\n@group(0) @binding(0) var<uniform> instance_uniforms: InstanceUniforms;\nvar<private> uniforms: Uniforms;" };
const _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS599 = { _0: "struct VertexOutput {", _1: "struct VertexOutput {\n  @location(7) @interpolate(flat) instance_id: u32," };
const _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS600 = { _0: "@vertex fn vs_main(input: VertexInput) -> VertexOutput {", _1: "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) instance_id: u32) -> VertexOutput {\n  uniforms = instance_uniforms.values[instance_id];" };
const _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS601 = { _0: "var out: VertexOutput;", _1: "var out: VertexOutput;\n  out.instance_id = instance_id;" };
const _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS602 = { _0: "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {", _1: "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  uniforms = instance_uniforms.values[in.instance_id];" };
const _M0FPB4seed = _M0FPB12random__seed();
const _M0FP36mizchi20kagura__platform__js9web__core11victrix__idN6constrS596 = "i";
const _M0FP36mizchi20kagura__platform__js9web__core11victrix__id = _M0MP46mizchi2js8builtins6regexp6RegExp3new("\\bVendor:\\s*0e6f\\s+Product:\\s*0218\\b", _M0FP36mizchi20kagura__platform__js9web__core11victrix__idN6constrS596);
const _M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepadN5tupleS603 = { _0: 3, _1: 6 };
const _M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepadN5tupleS604 = { _0: 4, _1: 7 };
const _M0FP36mizchi20kagura__platform__js9web__core13radial__stickN5tupleS605 = { _0: 0, _1: 0 };
const _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS606 = { _0: "renderCpuMs", _1: "_lastRenderCpuMs" };
const _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS607 = { _0: "renderUploadCpuMs", _1: "_lastRenderUploadCpuMs" };
const _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS608 = { _0: "renderBindGroupCpuMs", _1: "_lastRenderBindGroupCpuMs" };
const _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS609 = { _0: "renderEncodeCpuMs", _1: "_lastRenderEncodeCpuMs" };
const _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS610 = { _0: "renderSubmitCpuMs", _1: "_lastRenderSubmitCpuMs" };
function _M0FPB13consume4__acc(acc, input) {
  const _p = (acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0;
  const _p$2 = 17;
  return Math.imul(_p << _p$2 | (_p >>> (32 - _p$2 | 0) | 0), 668265263) | 0;
}
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
function _M0FPB14avalanche__acc(acc) {
  let acc$2 = acc;
  acc$2 = acc$2 ^ (acc$2 >>> 15 | 0);
  acc$2 = Math.imul(acc$2, -2048144777) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 13 | 0);
  acc$2 = Math.imul(acc$2, -1028477379) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 16 | 0);
  return acc$2;
}
function _M0FPB13finalize__acc(acc) {
  return _M0FPB14avalanche__acc(acc);
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
function _M0MPC15array5Array4pushGUisEE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGdE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
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
function _M0MPC16option6Option10unwrap__orGdE(self, default_) {
  if (self.$tag === 1) {
    const _Some = self;
    const _t = _Some._0;
    return _t;
  } else {
    return default_;
  }
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
function _M0FPB8new__mapGsdE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = (Math.imul(capacity$2, 13) | 0) / 16 | 0;
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsdE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB21capacity__for__length(length) {
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  const _p = capacity;
  if (length > ((Math.imul(_p, 13) | 0) / 16 | 0)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  return capacity;
}
function _M0MPB3Map20add__entry__to__tailGsdE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    const _p = _bind >>> 0 < _tmp.length ? _tmp[_bind] : $oob();
    let _tmp$2;
    if (_p === undefined) {
      _tmp$2 = $panic();
    } else {
      const _p$2 = _p;
      _tmp$2 = _p$2;
    }
    _tmp$2.next = entry;
  }
  self.tail = idx;
  self.entries[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map10set__entryGsdE(self, entry, new_idx) {
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
  }
  self.entries[new_idx] = entry;
}
function _M0MPB3Map10push__awayGsdE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = idx + 1 & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _bind = self.entries[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGsdE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGsdE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx$2 + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map20rehash__place__entryGsdE(self, outer) {
  const hash = outer.hash;
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _bind = self.entries[idx];
    if (_bind === undefined) {
      outer.psl = psl;
      outer.prev = self.tail;
      _M0MPB3Map20add__entry__to__tailGsdE(self, idx, outer);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr = _Some;
      if (psl > _curr.psl) {
        _M0MPB3Map10push__awayGsdE(self, idx, _curr);
        outer.psl = psl;
        outer.prev = self.tail;
        _M0MPB3Map20add__entry__to__tailGsdE(self, idx, outer);
        return undefined;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = idx + 1 & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map4growGsdE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  const _p = self.capacity;
  self.grow_at = (Math.imul(_p, 13) | 0) / 16 | 0;
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const x = _tmp;
    if (x === undefined) {
      return;
    } else {
      const _Some = x;
      const _e = _Some;
      const next_in_chain = _e.next;
      _e.next = undefined;
      _M0MPB3Map20rehash__place__entryGsdE(self, _e);
      _tmp = next_in_chain;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGsdE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _bind = self.entries[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGsdE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGsdE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGsdE(self, idx, entry);
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
          _M0MPB3Map4growGsdE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGsdE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGsdE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGsdE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3setGsdE(self, key, value) {
  _M0MPB3Map15set__with__hashGsdE(self, key, value, _M0IPC16string6StringPB4Hash4hash(key));
}
function _M0MPB3Map3MapGsdE(arr, capacity) {
  const length = arr.end - arr.start | 0;
  let capacity$2;
  if (capacity === undefined) {
    capacity$2 = length === 0 ? 8 : _M0FPB21capacity__for__length(length);
  } else {
    const _Some = capacity;
    const _capacity = _Some;
    const _p = _M0FPB21capacity__for__length(length);
    capacity$2 = _capacity > _p ? _capacity : _p;
  }
  const m = _M0FPB8new__mapGsdE(capacity$2);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGsdE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map3getGsdE(self, key) {
  const hash = _M0IPC16string6StringPB4Hash4hash(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _bind = self.entries[idx];
    if (_bind === undefined) {
      return _M0DTPC16option6OptionGdE4None__;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return new _M0DTPC16option6OptionGdE4Some(_entry.value);
      }
      if (i > _entry.psl) {
        return _M0DTPC16option6OptionGdE4None__;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = idx + 1 & self.capacity_mask;
      continue;
    }
  }
}
function _M0IPC16string6StringPB4Hash4hash(self) {
  let acc = (_M0FPB4seed >>> 0) + (374761393 >>> 0) | 0;
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      acc = (acc >>> 0) + (4 >>> 0) | 0;
      const v = self.charCodeAt(i);
      acc = _M0FPB13consume4__acc(acc, v);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FPB13finalize__acc(acc);
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
function _M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGUdRP36mizchi2js4core3AnyEE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGbE(self, index) {
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
function _M0MPC15array5Array8containsGUiiEE(self, value) {
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
      if (v._0 === value._0 && v._1 === value._1) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return false;
    }
  }
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
function _M0MP46mizchi2js8builtins6object6Object4is__(a, b) {
  return _M0MP36mizchi2js4core3Any6__call(_M0FP46mizchi2js8builtins6object13object__class(), "is", [a, b]);
}
function _M0MP46mizchi2js8builtins6object6Object6freeze(obj) {
  return _M0MP36mizchi2js4core3Any6__call(_M0FP46mizchi2js8builtins6object13object__class(), "freeze", [obj]);
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
function _M0FP36mizchi20kagura__platform__js9web__core13array__values(value) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? [] : _M0FP36mizchi2js4core11array__from(value);
}
function _M0FP36mizchi20kagura__platform__js9web__core20apply__object__patch(previous, patch) {
  const value = _M0FP36mizchi20kagura__platform__js9web__core14object__spread(_M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0MP36mizchi2js4core3Any5__get(patch, "full")) ? _M0FP36mizchi2js4core4null() : previous, _M0MP36mizchi2js4core3Any5__get(patch, "set"));
  const _bind = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0MP36mizchi2js4core3Any5__get(patch, "remove"));
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const key = _bind[_];
      _M0FP36mizchi20kagura__platform__js9web__core11delete__key(value, key);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return value;
}
function _M0FP36mizchi20kagura__platform__js9web__core6length(value) {
  return _M0MP36mizchi2js4core3Any5__get(value, "length");
}
function _M0FP36mizchi20kagura__platform__js9web__core24create__dependency__gate() {
  const previous = _M0MPC13ref3Ref3RefGORP36mizchi2js4core3AnyE(_M0DTPC16option6OptionGRP36mizchi2js4core3AnyE4None__);
  return (dependencies) => {
    const count = _M0MP36mizchi2js4core3Any5__get(dependencies, "length");
    const _bind = previous.val;
    if (_bind.$tag === 1) {
      const _Some = _bind;
      const _old = _Some._0;
      if (_M0FP36mizchi20kagura__platform__js9web__core6length(_old) === count) {
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
function _M0FP36mizchi20kagura__platform__js9web__core12is__stride32(source) {
  return _M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi20kagura__platform__js9web__core17position__pattern, source);
}
function _M0FP36mizchi20kagura__platform__js9web__core12is__stride64(source) {
  return _M0FP36mizchi20kagura__platform__js9web__core12is__stride32(source) && (_M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi20kagura__platform__js9web__core15joints__pattern, source) && _M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi20kagura__platform__js9web__core16weights__pattern, source));
}
function _M0FP36mizchi20kagura__platform__js9web__core14is__3d__shader(source) {
  return _M0FP36mizchi20kagura__platform__js9web__core12is__stride32(source) || _M0FP36mizchi20kagura__platform__js9web__core12is__stride64(source);
}
function _M0FP36mizchi20kagura__platform__js9web__core8fallback(value, default_) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? default_ : value;
}
function _M0FP36mizchi20kagura__platform__js9web__core5field(value, key) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? _M0FP36mizchi2js4core9undefined() : _M0MP36mizchi2js4core3Any5__get(value, key);
}
function _M0FP36mizchi20kagura__platform__js9web__core13number__field(value, key, default_) {
  return _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(value, key), default_);
}
function _M0FP36mizchi20kagura__platform__js9web__core21command__needs__depth(command) {
  const hint = _M0FP36mizchi20kagura__platform__js9web__core13number__field(command, "vertexStrideHint", 0);
  return _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0MP36mizchi2js4core3Any5__get(command, "isCustom")) && (hint > 0 ? hint >= 8 : _M0FP36mizchi20kagura__platform__js9web__core14is__3d__shader(_M0MP36mizchi2js4core3Any5__get(command, "shaderSource")));
}
function _M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindings(source) {
  const pattern = _M0MP46mizchi2js8builtins6regexp6RegExp3new("@binding\\((\\d+)\\)\\s+var\\s+\\w+\\s*:\\s*(texture_2d<f32>|texture_2d|sampler)", _M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindingsN6constrS597);
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
    _M0MPC15array5Array4pushGUisEE(bindings, { _0: index, _1: _M0MPC16string6String11has__prefix(raw, new _M0TPC16string10StringView(_M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindingsN7_2abindS361, 0, _M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindingsN7_2abindS361.length)) ? "texture" : "sampler" });
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
function _M0FP36mizchi20kagura__platform__js9web__core20get__instance__count(command) {
  const raw = _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(command, "instanceCount"), _M0FP36mizchi20kagura__platform__js9web__core5field(command, "instance_count"));
  if (_M0FP36mizchi20kagura__platform__js9web__core6finite(raw)) {
    const _p = _M0FP36mizchi20kagura__platform__js9web__core7to__i32(raw);
    const _p$2 = 1;
    return _p > _p$2 ? _p : _p$2;
  } else {
    return 1;
  }
}
function _M0FP36mizchi20kagura__platform__js9web__core25get__resource__cache__key(command) {
  const raw = _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(command, "resourceCacheKey"), _M0FP36mizchi20kagura__platform__js9web__core5field(command, "resource_cache_key"));
  return _M0FP36mizchi20kagura__platform__js9web__core6finite(raw) ? _M0FP36mizchi20kagura__platform__js9web__core7to__i32(raw) : 0;
}
function _M0FP36mizchi20kagura__platform__js9web__core8argument(value, default_) {
  return _M0FP36mizchi2js4core13is__undefined(value) ? default_ : value;
}
function _M0FP36mizchi20kagura__platform__js9web__core13equal__dwords(a, b, count) {
  if (_M0FP36mizchi2js4core5equal(a, b)) {
    return true;
  }
  if (_M0FP36mizchi2js4core11is__nullish(a) || _M0FP36mizchi2js4core11is__nullish(b)) {
    return false;
  }
  const count$2 = _M0FP36mizchi20kagura__platform__js9web__core8argument(count, _M0MP36mizchi2js4core3Any5__get(b, "length"));
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
function _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shader(source, dwords) {
  if (!_M0FP36mizchi20kagura__platform__js9web__core13safe__integer(dwords) || (dwords < 4 || (dwords > 128 || _M0IPC16double6DoublePB3Mod3mod(dwords, 4) !== 0))) {
    _M0FP36mizchi20kagura__platform__js9web__core12range__error("Invalid instance uniform layout");
  }
  const replacements = [_M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS598, _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS599, _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS600, _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS601, _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shaderN5tupleS602];
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
      result = _M0FP36mizchi20kagura__platform__js9web__core14replace__first(result, _from, _to);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return `// kagura-instance-dwords: ${_M0MP36mizchi2js4core3Any10to__string(dwords)}\n${result}`;
}
function _M0FP36mizchi20kagura__platform__js9web__core13require__time(value) {
  if (!_M0FP36mizchi20kagura__platform__js9web__core6finite(value)) {
    _M0FP36mizchi2js4core12throw__error("Expected finite time");
  }
  return value;
}
function _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(self) {
  const _p = _M0MP36mizchi2js4core3Any5__get(self.clip, "duration");
  return _p;
}
function _M0FP36mizchi20kagura__platform__js9web__core5clamp(value, low, high) {
  return _M0MPC16double6Double3min(_M0MPC16double6Double3max(value, low), high);
}
function _M0FP36mizchi20kagura__platform__js9web__core22create__motion__player(asset) {
  const clips = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0MP36mizchi2js4core3Any5__get(asset, "clips"));
  const state = new _M0TP36mizchi20kagura__platform__js9web__core12MotionPlayer(clips, _M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(clips, 0), 0, false, 1, true);
  return _M0MP46mizchi2js8builtins6object6Object6freeze(_M0FP36mizchi2js4core13from__entries([{ _0: "snapshot", _1: () => {
    const _p = _M0MP36mizchi2js4core3Any5__get(state.clip, "fps");
    const fps = _p;
    return _M0FP36mizchi2js4core13from__entries([{ _0: "clip", _1: _M0MP36mizchi2js4core3Any5__get(state.clip, "id") }, { _0: "time", _1: state.time }, { _0: "duration", _1: _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state) }, { _0: "fps", _1: fps }, { _0: "frame", _1: _M0MP46mizchi2js8builtins4math4Math5round(state.time * fps) }, { _0: "playing", _1: state.playing }, { _0: "speed", _1: state.speed }, { _0: "loop", _1: state.looping }]);
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
          state.time = 0;
          state.playing = false;
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
    if (state.time >= _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state)) {
      state.time = 0;
    }
    state.playing = true;
  } }, { _0: "pause", _1: () => {
    state.playing = false;
  } }, { _0: "seek", _1: (value) => {
    state.time = _M0FP36mizchi20kagura__platform__js9web__core5clamp(_M0FP36mizchi20kagura__platform__js9web__core13require__time(value), 0, _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state));
    state.playing = false;
  } }, { _0: "step", _1: (direction) => {
    if (!_M0FP36mizchi2js4core5equal(direction, -1) && !_M0FP36mizchi2js4core5equal(direction, 1)) {
      _M0FP36mizchi2js4core12throw__error("Step must be -1 or 1");
    }
    const _p = _M0MP36mizchi2js4core3Any5__get(state.clip, "fps");
    const fps = _p;
    state.time = _M0FP36mizchi20kagura__platform__js9web__core5clamp((_M0MP46mizchi2js8builtins4math4Math5round(state.time * fps) + 0 + direction) / fps, 0, _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state));
    state.playing = false;
  } }, { _0: "setSpeed", _1: (value) => {
    const speed = _M0FP36mizchi20kagura__platform__js9web__core13require__time(value);
    if (speed < 0.1 || speed > 4) {
      _M0FP36mizchi2js4core12throw__error("Speed must be 0.1..4");
    }
    state.speed = speed;
  } }, { _0: "setLoop", _1: (value) => {
    const _p = _M0FP36mizchi2js4core8typeof__(value);
    const _p$2 = "boolean";
    if (!(_p === _p$2)) {
      _M0FP36mizchi2js4core12throw__error("Loop must be boolean");
    }
    state.looping = value;
  } }, { _0: "tick", _1: (value) => {
    const delta = _M0FP36mizchi20kagura__platform__js9web__core13require__time(value);
    if (delta < 0) {
      _M0FP36mizchi2js4core12throw__error("Negative time delta");
    }
    if (!state.playing) {
      return undefined;
    }
    state.time = state.time + delta * state.speed;
    if (state.time >= _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state)) {
      if (state.looping) {
        state.time = _M0IPC16double6DoublePB3Mod3mod(state.time, _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state));
        return;
      } else {
        state.time = _M0MP36mizchi20kagura__platform__js9web__core12MotionPlayer8duration(state);
        state.playing = false;
        return;
      }
    } else {
      return;
    }
  } }]));
}
function _M0FP36mizchi20kagura__platform__js9web__core9footprint(item, rotated) {
  const height = _M0MP36mizchi2js4core3Any5__get(item, "height");
  const _p = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0MP36mizchi2js4core3Any5__get(item, "cells"));
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      const _p$6 = _M0MP36mizchi2js4core3Any16__get__by__index(_p$5, 0);
      const _p$7 = _M0MP36mizchi2js4core3Any16__get__by__index(_p$5, 1);
      _p$2[_p$4] = rotated ? { _0: (height - 1 | 0) - _p$7 | 0, _1: _p$6 } : { _0: _p$6, _1: _p$7 };
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _p$2;
}
function _M0FP36mizchi20kagura__platform__js9web__core13cells__to__js(cells) {
  const _p = new Array(cells.length);
  const _p$2 = cells.length;
  let _tmp = 0;
  while (true) {
    const _p$3 = _tmp;
    if (_p$3 < _p$2) {
      const _p$4 = cells[_p$3];
      _p[_p$3] = [_p$4._0, _p$4._1];
      _tmp = _p$3 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _p;
}
function _M0FP36mizchi20kagura__platform__js9web__core14rotated__cells(item, rotated) {
  return _M0FP36mizchi20kagura__platform__js9web__core13cells__to__js(_M0FP36mizchi20kagura__platform__js9web__core9footprint(item, _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core8argument(rotated, _M0MP36mizchi2js4core3Any5__get(item, "rotated")))));
}
function _M0FP36mizchi20kagura__platform__js9web__core10dimensions(item, rotated) {
  const width = _M0MP36mizchi2js4core3Any5__get(item, "width");
  const height = _M0MP36mizchi2js4core3Any5__get(item, "height");
  return _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core8argument(rotated, _M0MP36mizchi2js4core3Any5__get(item, "rotated"))) ? [height, width] : [width, height];
}
function _M0FP36mizchi20kagura__platform__js9web__core18preview__placement(view, item, x, y, rotated) {
  const _p = _M0FP36mizchi20kagura__platform__js9web__core9footprint(item, _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core8argument(rotated, _M0MP36mizchi2js4core3Any5__get(item, "rotated"))));
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = { _0: x + _p$5._0 | 0, _1: y + _p$5._1 | 0 };
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const cells = _p$2;
  const width = _M0MP36mizchi2js4core3Any5__get(view, "width");
  const height = _M0MP36mizchi2js4core3Any5__get(view, "height");
  let inside = true;
  const _bind = cells.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind) {
      const _foreach_element = cells[_];
      const _cx = _foreach_element._0;
      const _cy = _foreach_element._1;
      if (_cx < 0 || (_cy < 0 || (_cx >= width || _cy >= height))) {
        inside = false;
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let overlaps = 0;
  let matching_slots = true;
  const _bind$2 = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0MP36mizchi2js4core3Any5__get(view, "items"));
  const _bind$3 = _bind$2.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$3) {
      const other = _bind$2[_];
      _L: {
        const ox = _M0MP36mizchi2js4core3Any5__get(other, "x");
        if (_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(other, "source"), _M0MP36mizchi2js4core3Any5__get(item, "source")) || ox < 0) {
          break _L;
        }
        const oy = _M0MP36mizchi2js4core3Any5__get(other, "y");
        const _bind$4 = _M0FP36mizchi20kagura__platform__js9web__core9footprint(other, _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0MP36mizchi2js4core3Any5__get(other, "rotated")));
        const _bind$5 = _bind$4.length;
        let _tmp$4 = 0;
        while (true) {
          const _$2 = _tmp$4;
          if (_$2 < _bind$5) {
            const _foreach_element = _bind$4[_$2];
            const _cx = _foreach_element._0;
            const _cy = _foreach_element._1;
            if (_M0MPC15array5Array8containsGUiiEE(cells, { _0: ox + _cx | 0, _1: oy + _cy | 0 })) {
              overlaps = overlaps + 1 | 0;
              if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(other, "slot"), _M0MP36mizchi2js4core3Any5__get(item, "slot"))) {
                matching_slots = false;
              }
              break;
            }
            _tmp$4 = _$2 + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break _L;
      }
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _tmp$4 = { _0: "cells", _1: _M0FP36mizchi20kagura__platform__js9web__core13cells__to__js(cells) };
  let _tmp$5;
  if (inside) {
    let _tmp$6;
    if (overlaps <= 1) {
      let _tmp$7;
      const _p$4 = _M0MP36mizchi2js4core3Any5__get(item, "source");
      if (_p$4 >= 0) {
        _tmp$7 = true;
      } else {
        _tmp$7 = matching_slots;
      }
      _tmp$6 = _tmp$7;
    } else {
      _tmp$6 = false;
    }
    _tmp$5 = _tmp$6;
  } else {
    _tmp$5 = false;
  }
  return _M0FP36mizchi2js4core13from__entries([_tmp$4, { _0: "valid", _1: _tmp$5 }, { _0: "swap", _1: overlaps === 1 }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core12inside__rect(x, y, rect) {
  const _p = _M0MP36mizchi2js4core3Any5__get(rect, "left");
  if (x >= _p) {
    let _tmp;
    const _p$2 = _M0MP36mizchi2js4core3Any5__get(rect, "top");
    if (y >= _p$2) {
      let _tmp$2;
      const _p$3 = _M0MP36mizchi2js4core3Any5__get(rect, "right");
      if (x < _p$3) {
        const _p$4 = _M0MP36mizchi2js4core3Any5__get(rect, "bottom");
        _tmp$2 = y < _p$4;
      } else {
        _tmp$2 = false;
      }
      _tmp = _tmp$2;
    } else {
      _tmp = false;
    }
    return _tmp;
  } else {
    return false;
  }
}
function _M0FP36mizchi20kagura__platform__js9web__core27is__inventory__ground__drop(x, y, dialog, surface) {
  return _M0FP36mizchi20kagura__platform__js9web__core6truthy(dialog) && (_M0FP36mizchi20kagura__platform__js9web__core6truthy(surface) && (_M0FP36mizchi20kagura__platform__js9web__core12inside__rect(x, y, surface) && !_M0FP36mizchi20kagura__platform__js9web__core12inside__rect(x, y, dialog)));
}
function _M0FP36mizchi20kagura__platform__js9web__core16comparison__rows(view, item) {
  const _bind = [];
  const previous = _M0MPB3Map3MapGsdE(new _M0TPB9ArrayViewGUsdEE(_bind, 0, 0), undefined);
  const _bind$2 = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0MP36mizchi2js4core3Any5__get(view, "equipment"));
  const _bind$3 = _bind$2.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$3) {
      const slot = _bind$2[_];
      if (_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(slot, "id"), _M0MP36mizchi2js4core3Any5__get(item, "slot"))) {
        const _bind$4 = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0FP36mizchi20kagura__platform__js9web__core5field(_M0MP36mizchi2js4core3Any5__get(slot, "item"), "stats"));
        const _bind$5 = _bind$4.length;
        let _tmp$2 = 0;
        while (true) {
          const _$2 = _tmp$2;
          if (_$2 < _bind$5) {
            const stat = _bind$4[_$2];
            const _tmp$3 = _M0MP36mizchi2js4core3Any16__get__by__index(stat, 0);
            const _p = _M0MP36mizchi2js4core3Any16__get__by__index(stat, 1);
            _M0MPB3Map3setGsdE(previous, _tmp$3, _p);
            _tmp$2 = _$2 + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const rows = [];
  const _bind$4 = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0MP36mizchi2js4core3Any5__get(item, "stats"));
  const _bind$5 = _bind$4.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$5) {
      const stat = _bind$4[_];
      const label = _M0MP36mizchi2js4core3Any16__get__by__index(stat, 0);
      const _p = _M0MP36mizchi2js4core3Any16__get__by__index(stat, 1);
      const value = _p;
      const before = _M0MPC16option6Option10unwrap__orGdE(_M0MPB3Map3getGsdE(previous, label), 0);
      if (value !== 0 || before !== 0) {
        _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(rows, _M0FP36mizchi2js4core13from__entries([{ _0: "label", _1: label }, { _0: "value", _1: value }, { _0: "before", _1: before }, { _0: "delta", _1: value - before }]));
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return rows;
}
function _M0FP36mizchi20kagura__platform__js9web__core6vector(x, y) {
  return _M0FP36mizchi2js4core13from__entries([{ _0: "x", _1: x }, { _0: "y", _1: y }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core15geometry__pairs(gpu) {
  const current = _M0MP36mizchi2js4core3Any5__get(gpu, "_registeredGeometry");
  if (!_M0FP36mizchi2js4core11is__nullish(current)) {
    return current;
  }
  const pairs = _M0MP46mizchi2js8builtins4weak7WeakMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
  _M0MP36mizchi2js4core3Any5__set(gpu, "_registeredGeometry", pairs);
  return pairs;
}
function _M0FP36mizchi20kagura__platform__js9web__core18geometry__snapshot(vertices, indices) {
  return _M0FP36mizchi2js4core13from__entries([{ _0: "vertexData", _1: _M0FP36mizchi20kagura__platform__js9web__core13float32__copy(vertices) }, { _0: "indices", _1: _M0FP36mizchi20kagura__platform__js9web__core12uint32__copy(indices) }, { _0: "immutableGeometry", _1: true }, { _0: "sharedGeometry", _1: true }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core18register__geometry(gpu, id, revision, vertices, indices) {
  let _tmp;
  let _tmp$2;
  const _p = _M0FP36mizchi2js4core8typeof__(id);
  const _p$2 = "string";
  if (!(_p === _p$2)) {
    let _tmp$3;
    const _p$3 = _M0FP36mizchi2js4core8typeof__(id);
    const _p$4 = "symbol";
    if (!(_p$3 === _p$4)) {
      _tmp$3 = !_M0FP36mizchi20kagura__platform__js9web__core13safe__integer(id);
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
    _tmp = !_M0FP36mizchi20kagura__platform__js9web__core13safe__integer(revision) || revision < 0;
  }
  if (_tmp) {
    _M0FP36mizchi20kagura__platform__js9web__core11type__error("Invalid geometry identity/revision");
  }
  let registry;
  if (_M0FP36mizchi2js4core11is__nullish(_M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry"))) {
    const registry$2 = _M0MP46mizchi2js8builtins10collection5JsMap3newGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE();
    _M0MP36mizchi2js4core3Any5__set(gpu, "_geometryRegistry", registry$2);
    registry = registry$2;
  } else {
    registry = _M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry");
  }
  const pairs = _M0FP36mizchi20kagura__platform__js9web__core15geometry__pairs(gpu);
  const old = _M0MP46mizchi2js8builtins10collection5JsMap3getGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id);
  if (old.$tag === 1) {
    const _Some = old;
    const _entry = _Some._0;
    const _p$3 = _M0MP36mizchi2js4core3Any5__get(_entry, "revision");
    const old_revision = _p$3;
    if (revision < old_revision) {
      _M0FP36mizchi20kagura__platform__js9web__core12range__error("Stale geometry revision");
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
  const snapshot = _M0FP36mizchi20kagura__platform__js9web__core18geometry__snapshot(vertices, indices);
  const entry = _M0FP36mizchi2js4core13from__entries([{ _0: "id", _1: id }, { _0: "revision", _1: revision }, { _0: "vertices", _1: vertices }, { _0: "sourceIndices", _1: indices }, { _0: "snapshot", _1: snapshot }]);
  _M0MP46mizchi2js8builtins10collection5JsMap3setGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id, entry);
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(by_index, indices, entry);
  return snapshot;
}
function _M0FP36mizchi20kagura__platform__js9web__core20unregister__geometry(gpu, id) {
  if (_M0FP36mizchi2js4core11is__nullish(_M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry"))) {
    return undefined;
  }
  const registry = _M0MP36mizchi2js4core3Any5__get(gpu, "_geometryRegistry");
  const _bind = _M0MP46mizchi2js8builtins10collection5JsMap3getGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyE(registry, id);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _entry = _Some._0;
    const _bind$2 = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(_M0FP36mizchi20kagura__platform__js9web__core15geometry__pairs(gpu), _M0MP36mizchi2js4core3Any5__get(_entry, "vertices"));
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
function _M0FP36mizchi20kagura__platform__js9web__core26register__static__geometry(gpu, vertices, indices) {
  const pairs = _M0FP36mizchi20kagura__platform__js9web__core15geometry__pairs(gpu);
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
  const snapshot = _M0FP36mizchi20kagura__platform__js9web__core18geometry__snapshot(vertices, indices);
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(by_index, indices, _M0FP36mizchi2js4core13from__entries([{ _0: "id", _1: _M0FP36mizchi20kagura__platform__js9web__core14unique__symbol() }, { _0: "snapshot", _1: snapshot }]));
  return snapshot;
}
function _M0FP36mizchi20kagura__platform__js9web__core18snapshot__vertices(cache, source) {
  const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _previous = _Some._0;
    if (_M0FP36mizchi20kagura__platform__js9web__core6length(_previous) === _M0FP36mizchi20kagura__platform__js9web__core6length(source)) {
      let i = 0;
      while (true) {
        if (i < _M0FP36mizchi20kagura__platform__js9web__core6length(source)) {
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
      if (i === _M0FP36mizchi20kagura__platform__js9web__core6length(source)) {
        return _previous;
      }
    }
  }
  const packed = _M0FP36mizchi20kagura__platform__js9web__core13float32__copy(source);
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source, packed);
  return packed;
}
function _M0FP36mizchi20kagura__platform__js9web__core17snapshot__indices(cache, source) {
  const _bind = _M0MP46mizchi2js8builtins4weak7WeakMap3getGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source);
  if (_bind.$tag === 1) {
    const _Some = _bind;
    const _previous = _Some._0;
    if (_M0FP36mizchi20kagura__platform__js9web__core6length(_previous) === _M0FP36mizchi20kagura__platform__js9web__core6length(source)) {
      let i = 0;
      while (true) {
        if (i < _M0FP36mizchi20kagura__platform__js9web__core6length(source)) {
          if (!_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any16__get__by__index(_previous, i), _M0FP36mizchi20kagura__platform__js9web__core10to__uint32(_M0MP36mizchi2js4core3Any16__get__by__index(source, i)))) {
            break;
          }
          i = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      if (i === _M0FP36mizchi20kagura__platform__js9web__core6length(source)) {
        return _previous;
      }
    }
  }
  const packed = _M0FP36mizchi20kagura__platform__js9web__core12uint32__copy(source);
  _M0MP46mizchi2js8builtins4weak7WeakMap3setGRP36mizchi2js4core3AnyRP46mizchi2js8builtins4weak7WeakMapGRP36mizchi2js4core3AnyRP36mizchi2js4core3AnyEE(cache, source, packed);
  return packed;
}
function _M0FP36mizchi20kagura__platform__js9web__core24snapshot__draw__geometry(gpu, vertices, indices) {
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
  return _M0FP36mizchi2js4core13from__entries([{ _0: "vertexData", _1: _M0FP36mizchi20kagura__platform__js9web__core18snapshot__vertices(_M0MP36mizchi2js4core3Any5__get(cache, "vertices"), vertices) }, { _0: "indices", _1: _M0FP36mizchi20kagura__platform__js9web__core17snapshot__indices(_M0MP36mizchi2js4core3Any5__get(cache, "indices"), indices) }, { _0: "immutableGeometry", _1: true }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core9pad__axis(value) {
  return _M0FP36mizchi20kagura__platform__js9web__core6finite(value) ? _M0FP36mizchi20kagura__platform__js9web__core5clamp(value, -1, 1) : 0;
}
function _M0FP36mizchi20kagura__platform__js9web__core6button(pressed, value) {
  return _M0FP36mizchi2js4core13from__entries([{ _0: "pressed", _1: pressed }, { _0: "value", _1: value }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core11pad__button(source) {
  const value = _M0FP36mizchi20kagura__platform__js9web__core5field(source, "value");
  return _M0FP36mizchi20kagura__platform__js9web__core6button(_M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core5field(source, "pressed")), _M0FP36mizchi20kagura__platform__js9web__core6finite(value) ? _M0FP36mizchi20kagura__platform__js9web__core5clamp(value, 0, 1) : 0);
}
function _M0FP36mizchi20kagura__platform__js9web__core12button__down(source) {
  const value = _M0FP36mizchi20kagura__platform__js9web__core5field(source, "value");
  return _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core5field(source, "pressed")) || _M0FP36mizchi20kagura__platform__js9web__core6finite(value) && value >= 0.55;
}
function _M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepad(pad) {
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
    _tmp = !_M0MP46mizchi2js8builtins6regexp6RegExp6test__(_M0FP36mizchi20kagura__platform__js9web__core11victrix__id, _M0MP36mizchi2js4core3Any5__get(pad, "id")) || (_M0FP36mizchi20kagura__platform__js9web__core6length(axes) !== 10 || _M0FP36mizchi20kagura__platform__js9web__core6length(raw_buttons) < 14);
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
      _p$2[_p$4] = _M0FP36mizchi20kagura__platform__js9web__core11pad__button(_p$5 < 0 ? _M0FP36mizchi2js4core4null() : _M0MP36mizchi2js4core3Any16__get__by__index(raw_buttons, _p$5));
      _tmp$2 = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const buttons = _p$2;
  const _bind = [_M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepadN5tupleS603, _M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepadN5tupleS604];
  const _bind$2 = _bind.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$2) {
      const _foreach_element = _bind[_];
      const _axis_index = _foreach_element._0;
      const _button_index = _foreach_element._1;
      const raw = _M0MP36mizchi2js4core3Any16__get__by__index(axes, _axis_index);
      const value = _M0FP36mizchi20kagura__platform__js9web__core6finite(raw) ? (_M0FP36mizchi20kagura__platform__js9web__core9pad__axis(raw) + 1) / 2 : 0;
      _M0MPC15array5Array3setGRP36mizchi2js4core3AnyE(buttons, _button_index, _M0FP36mizchi20kagura__platform__js9web__core6button(_M0FP36mizchi20kagura__platform__js9web__core12button__down(_M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(buttons, _button_index)) || value >= 0.55, value));
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const hat = _M0MP36mizchi2js4core3Any16__get__by__index(axes, 9);
  if (_M0FP36mizchi20kagura__platform__js9web__core6finite(hat) && (hat >= -1 && hat <= 1)) {
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
          _M0MPC15array5Array3setGRP36mizchi2js4core3AnyE(buttons, index, _M0FP36mizchi20kagura__platform__js9web__core6button(true, 1));
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
      _p$5[_p$7] = _M0FP36mizchi20kagura__platform__js9web__core9pad__axis(_M0MP36mizchi2js4core3Any16__get__by__index(axes, _p$8));
      _tmp$9 = _p$7 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi2js4core13from__entries([_tmp$4, _tmp$5, _tmp$6, _tmp$7, _tmp$8, { _0: "axes", _1: _p$5 }, { _0: "buttons", _1: buttons }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core11device__key(pad) {
  const index = _M0MP36mizchi2js4core3Any10to__string(_M0MP36mizchi2js4core3Any5__get(pad, "index"));
  const id = _M0MP36mizchi2js4core3Any5__get(pad, "id");
  const profile = _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0MP36mizchi2js4core3Any5__get(pad, "profile"), _M0MP36mizchi2js4core3Any5__get(pad, "mapping"));
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(2);
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, index);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ":");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, id);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ":");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, profile);
  return _string_builder.val;
}
function _M0FP36mizchi20kagura__platform__js9web__core13radial__stick(dx, dy, radius, dead_zone) {
  const length = _M0MP46mizchi2js8builtins4math4Math5hypot([dx, dy]);
  if (length === 0 || length < radius * dead_zone) {
    return _M0FP36mizchi20kagura__platform__js9web__core13radial__stickN5tupleS605;
  }
  const magnitude = _M0MPC16double6Double3min((length / radius - dead_zone) / (1 - dead_zone), 1);
  return { _0: dx / length * magnitude, _1: dy / length * magnitude };
}
function _M0MP36mizchi20kagura__platform__js9web__core12GamepadState4stepN8axis__atS82(axes, i) {
  return _M0FP36mizchi20kagura__platform__js9web__core9pad__axis(_M0FP36mizchi2js4core11is__nullish(axes) ? _M0FP36mizchi2js4core9undefined() : _M0MP36mizchi2js4core3Any16__get__by__index(axes, i));
}
function _M0MP36mizchi20kagura__platform__js9web__core12GamepadState4step(self, pads, options) {
  const enabled = _M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core8argument(_M0FP36mizchi20kagura__platform__js9web__core5field(options, "enabled"), true));
  const _p = _M0FP36mizchi20kagura__platform__js9web__core8argument(_M0FP36mizchi20kagura__platform__js9web__core5field(options, "now"), 0);
  const now = _p;
  const _p$2 = _M0FP36mizchi20kagura__platform__js9web__core13array__values(pads);
  const _p$3 = [];
  const _p$4 = _p$2.length;
  let _tmp = 0;
  while (true) {
    const _p$5 = _tmp;
    if (_p$5 < _p$4) {
      const _p$6 = _p$2[_p$5];
      if (_M0FP36mizchi20kagura__platform__js9web__core6truthy(_p$6) && !_M0FP36mizchi2js4core5equal(_M0FP36mizchi20kagura__platform__js9web__core5field(_p$6, "connected"), false)) {
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
      _p$5[_p$7] = _M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepad(_p$8);
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
      if (_M0IPC16option6OptionPB2Eq5equalGsE(_M0FP36mizchi20kagura__platform__js9web__core11device__key(candidate), self.identity)) {
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
  const next_identity = supported ? _M0FP36mizchi20kagura__platform__js9web__core11device__key(pad) : undefined;
  const changed = _M0IP016_24default__implPB2Eq10not__equalGOsE(next_identity, self.identity);
  const _bind$3 = self.last_time;
  let dt;
  if (_bind$3.$tag === 0) {
    dt = 0;
  } else {
    const _Some = _bind$3;
    const _last = _Some._0;
    dt = _M0FP36mizchi20kagura__platform__js9web__core5clamp((now - _last) / 1000, 0, 0.05);
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
  const axes = _M0FP36mizchi20kagura__platform__js9web__core5field(pad, "axes");
  const _bind$4 = _M0FP36mizchi20kagura__platform__js9web__core13radial__stick(_M0MP36mizchi20kagura__platform__js9web__core12GamepadState4stepN8axis__atS82(axes, 0), _M0MP36mizchi20kagura__platform__js9web__core12GamepadState4stepN8axis__atS82(axes, 1), 1, self.dead_zone);
  const _mx = _bind$4._0;
  const _my = _bind$4._1;
  const _bind$5 = _M0FP36mizchi20kagura__platform__js9web__core13radial__stick(_M0MP36mizchi20kagura__platform__js9web__core12GamepadState4stepN8axis__atS82(axes, 2), _M0MP36mizchi20kagura__platform__js9web__core12GamepadState4stepN8axis__atS82(axes, 3), 1, self.dead_zone);
  const _lx = _bind$5._0;
  const _ly = _bind$5._1;
  const _p$10 = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0FP36mizchi20kagura__platform__js9web__core5field(pad, "buttons"));
  const _p$11 = new Array(_p$10.length);
  const _p$12 = _p$10.length;
  let _tmp$5 = 0;
  while (true) {
    const _p$13 = _tmp$5;
    if (_p$13 < _p$12) {
      const _p$14 = _p$10[_p$13];
      _p$11[_p$13] = _M0FP36mizchi20kagura__platform__js9web__core12button__down(_p$14);
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
  const _tmp$12 = { _0: "index", _1: _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(pad, "index"), -1) };
  const _tmp$13 = { _0: "id", _1: _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(pad, "id"), connected.length === 0 ? "" : _M0MP36mizchi2js4core3Any5__get(_M0MPC15array5Array2atGRP36mizchi2js4core3AnyE(connected, 0), "id")) };
  const _tmp$14 = { _0: "profile", _1: supported ? _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(pad, "profile"), "standard") : _M0FP36mizchi2js4core4null() };
  const _tmp$15 = { _0: "move", _1: ready ? _M0FP36mizchi20kagura__platform__js9web__core6vector(_mx, _my) : _M0FP36mizchi20kagura__platform__js9web__core6vector(0, 0) };
  const _tmp$16 = { _0: "look", _1: ready ? _M0FP36mizchi20kagura__platform__js9web__core6vector(_lx, _ly) : _M0FP36mizchi20kagura__platform__js9web__core6vector(0, 0) };
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
function _M0FP36mizchi20kagura__platform__js9web__core23create__gamepad__reader(options) {
  const dead_zone = _M0FP36mizchi20kagura__platform__js9web__core8argument(_M0FP36mizchi20kagura__platform__js9web__core5field(options, "deadZone"), 0.18);
  if (!_M0FP36mizchi20kagura__platform__js9web__core6finite(dead_zone) || (dead_zone < 0 || dead_zone >= 1)) {
    _M0FP36mizchi20kagura__platform__js9web__core12range__error("Stick coordinates must be finite, radius positive, and deadZone in [0, 1)");
  }
  const state = new _M0TP36mizchi20kagura__platform__js9web__core12GamepadState(dead_zone, undefined, false, [], [0, 0, 0, 0], undefined, 0, _M0DTPC16option6OptionGdE4None__);
  return _M0FP36mizchi2js4core13from__entries([{ _0: "step", _1: (pads, options$2) => _M0MP36mizchi20kagura__platform__js9web__core12GamepadState4step(state, pads, options$2) }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core10percentile(values, p) {
  const _p = _M0FP36mizchi20kagura__platform__js9web__core13array__values(values);
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
  const sorted = _p$2;
  if (sorted.length === 0) {
    return 0;
  }
  _M0MPC15array5Array4sortGdE(sorted);
  const _p$4 = _M0MP46mizchi2js8builtins4math4Math5floor((sorted.length + 0) * p);
  const _p$5 = sorted.length - 1 | 0;
  return _M0MPC15array5Array2atGdE(sorted, _p$4 < _p$5 ? _p$4 : _p$5);
}
function _M0FP36mizchi20kagura__platform__js9web__core20summarize__intervals(timestamps) {
  const _p = _M0FP36mizchi20kagura__platform__js9web__core13array__values(timestamps);
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
  const values = _p$2;
  const intervals = [];
  let _tmp$2 = 1;
  while (true) {
    const i = _tmp$2;
    if (i < values.length) {
      _M0MPC15array5Array4pushGdE(intervals, _M0MPC15array5Array2atGdE(values, i) - _M0MPC15array5Array2atGdE(values, i - 1 | 0));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const elapsed = values.length > 1 ? _M0MPC15array5Array2atGdE(values, values.length - 1 | 0) - _M0MPC15array5Array2atGdE(values, 0) : 0;
  return _M0FP36mizchi2js4core13from__entries([{ _0: "frames", _1: values.length }, { _0: "elapsedMs", _1: _M0MP46mizchi2js8builtins4math4Math5round(elapsed) }, { _0: "fps", _1: elapsed > 0 ? _M0FP36mizchi20kagura__platform__js9web__core14fixed__decimal((intervals.length + 0) / (elapsed / 1000), 1) : 0 }, { _0: "p50IntervalMs", _1: _M0FP36mizchi20kagura__platform__js9web__core14fixed__decimal(_M0FP36mizchi20kagura__platform__js9web__core10percentile(intervals, 0.5), 2) }, { _0: "p95IntervalMs", _1: _M0FP36mizchi20kagura__platform__js9web__core14fixed__decimal(_M0FP36mizchi20kagura__platform__js9web__core10percentile(intervals, 0.95), 2) }]);
}
function _M0FP36mizchi20kagura__platform__js9web__core6timing(value) {
  return _M0FP36mizchi20kagura__platform__js9web__core6finite(value) && value >= 0 ? value : _M0FP36mizchi2js4core4null();
}
function _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profile(host) {
  const host$2 = _M0FP36mizchi20kagura__platform__js9web__core8argument(host, _M0FP36mizchi2js4core12global__this());
  const runtime = _M0FP36mizchi20kagura__platform__js9web__core5field(host$2, "__kaguraWebRuntime");
  const gpu = _M0FP36mizchi20kagura__platform__js9web__core5field(runtime, "webgpu");
  if (!_M0FP36mizchi20kagura__platform__js9web__core6truthy(gpu)) {
    return _M0FP36mizchi2js4core4null();
  }
  const phases = _M0FP36mizchi20kagura__platform__js9web__core5field(runtime, "frameProfile");
  const commands = _M0FP36mizchi20kagura__platform__js9web__core13array__values(_M0FP36mizchi20kagura__platform__js9web__core5field(gpu, "commands"));
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
      const _p = _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(command, "indexCount"), _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(_M0FP36mizchi20kagura__platform__js9web__core5field(command, "indices"), "length"), 0));
      indices = _tmp$2 + _p;
      instances = instances + _M0MPC16double6Double3max(_M0FP36mizchi20kagura__platform__js9web__core13number__field(command, "instanceCount", 1), 1);
      if (_M0FP36mizchi20kagura__platform__js9web__core6truthy(_M0FP36mizchi20kagura__platform__js9web__core5field(command, "sharedGeometry"))) {
        shared = shared + 1 | 0;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const timing_method = _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(gpu, "_gpuTimingMethod"), _M0FP36mizchi2js4core4null());
  const snapshot = _M0FP36mizchi2js4core13from__entries([{ _0: "version", _1: 1 }, { _0: "frame", _1: _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(gpu, "_submittedFrameCount"), 0) }, { _0: "gpuFrameMs", _1: _M0FP36mizchi2js4core11is__nullish(timing_method) ? _M0FP36mizchi2js4core4null() : _M0FP36mizchi20kagura__platform__js9web__core6timing(_M0FP36mizchi20kagura__platform__js9web__core5field(gpu, _M0FP36mizchi2js4core5equal(timing_method, "timestamp-query") ? "_lastTimestampFrameMs" : "_lastCompletedFrameMs")) }, { _0: "gpuTimingMethod", _1: timing_method }, { _0: "drawCalls", _1: commands.length }, { _0: "indexCount", _1: indices }, { _0: "instanceCount", _1: instances }, { _0: "sharedGeometryDraws", _1: shared }, { _0: "residentGeometryBuffers", _1: _M0FP36mizchi20kagura__platform__js9web__core8fallback(_M0FP36mizchi20kagura__platform__js9web__core5field(_M0FP36mizchi20kagura__platform__js9web__core5field(_M0FP36mizchi20kagura__platform__js9web__core5field(gpu, "_sharedGeometryBuffers"), "resident"), "size"), 0) }]);
  const _bind$2 = ["updateMs", "drawCallbackMs", "renderCommandsMs"];
  const _bind$3 = _bind$2.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const key = _bind$2[_];
      _M0MP36mizchi2js4core3Any5__set(snapshot, key, _M0FP36mizchi20kagura__platform__js9web__core6timing(_M0FP36mizchi20kagura__platform__js9web__core5field(phases, key)));
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$4 = [_M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS606, _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS607, _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS608, _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS609, _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profileN5tupleS610];
  const _bind$5 = _bind$4.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$5) {
      const _foreach_element = _bind$4[_];
      const _key = _foreach_element._0;
      const _source = _foreach_element._1;
      _M0MP36mizchi2js4core3Any5__set(snapshot, _key, _M0FP36mizchi20kagura__platform__js9web__core6timing(_M0FP36mizchi20kagura__platform__js9web__core5field(gpu, _source)));
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MP46mizchi2js8builtins6object6Object6freeze(snapshot);
}
function _M0FP36mizchi20kagura__platform__js9web__core24install__frame__profiler(host) {
  const host$2 = _M0FP36mizchi20kagura__platform__js9web__core8argument(host, _M0FP36mizchi2js4core12global__this());
  const profiler = _M0MP46mizchi2js8builtins6object6Object6freeze(_M0FP36mizchi2js4core13from__entries([{ _0: "version", _1: 1 }, { _0: "snapshot", _1: () => _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profile(host$2) }]));
  _M0MP36mizchi2js4core3Any5__set(host$2, "__kaguraProfiler", profiler);
  return profiler;
}
function _M0FP36mizchi20kagura__platform__js9web__core13stick__vector(dx, dy, radius, options) {
  const dead_zone = _M0FP36mizchi20kagura__platform__js9web__core8argument(_M0FP36mizchi20kagura__platform__js9web__core5field(options, "deadZone"), 0.14);
  if (!_M0FP36mizchi20kagura__platform__js9web__core6finite(dx) || (!_M0FP36mizchi20kagura__platform__js9web__core6finite(dy) || (!_M0FP36mizchi20kagura__platform__js9web__core6finite(radius) || (!_M0FP36mizchi20kagura__platform__js9web__core6finite(dead_zone) || (radius <= 0 || (dead_zone < 0 || dead_zone >= 1)))))) {
    _M0FP36mizchi20kagura__platform__js9web__core12range__error("Stick coordinates must be finite, radius positive, and deadZone in [0, 1)");
  }
  const _bind = _M0FP36mizchi20kagura__platform__js9web__core13radial__stick(dx, dy, radius, dead_zone);
  const _x = _bind._0;
  const _y = _bind._1;
  return _M0FP36mizchi20kagura__platform__js9web__core6vector(_x, _y);
}
function _M0MP36mizchi20kagura__platform__js9web__core12ControlState7release(self, id) {
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
function _M0FP36mizchi20kagura__platform__js9web__core22create__control__input(options) {
  const capacity = _M0FP36mizchi20kagura__platform__js9web__core8argument(_M0FP36mizchi20kagura__platform__js9web__core5field(options, "capacity"), 8);
  if (!_M0FP36mizchi20kagura__platform__js9web__core13safe__integer(capacity) || capacity < 1) {
    _M0FP36mizchi20kagura__platform__js9web__core12range__error("Command capacity must be positive");
  }
  const state = new _M0TP36mizchi20kagura__platform__js9web__core12ControlState(capacity, [], [], _M0DTPC16option6OptionGdE4None__, 0, 0, false);
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
    _M0MPC15array5Array4pushGUisEE(state.held, { _0: id, _1: action });
  } }, { _0: "release", _1: (id) => {
    _M0MP36mizchi20kagura__platform__js9web__core12ControlState7release(state, id);
  } }, { _0: "tap", _1: (key, payload) => {
    if (!_M0FP36mizchi20kagura__platform__js9web__core13safe__integer(key) || key <= 0) {
      _M0FP36mizchi20kagura__platform__js9web__core12range__error("Command key must be a positive integer");
    }
    if (state.commands.length + 0 >= state.capacity) {
      return false;
    }
    _M0MPC15array5Array4pushGRP36mizchi2js4core3AnyE(state.commands, _M0FP36mizchi2js4core13from__entries([{ _0: "key", _1: key }, { _0: "payload", _1: _M0FP36mizchi20kagura__platform__js9web__core8argument(payload, _M0FP36mizchi2js4core4null()) }]));
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
export { _M0FP36mizchi20kagura__platform__js9web__core20apply__object__patch as applyObjectPatch, _M0FP36mizchi20kagura__platform__js9web__core24create__dependency__gate as createDependencyGate, _M0FP36mizchi20kagura__platform__js9web__core12is__stride32 as isStride32, _M0FP36mizchi20kagura__platform__js9web__core12is__stride64 as isStride64, _M0FP36mizchi20kagura__platform__js9web__core14is__3d__shader as is3DShader, _M0FP36mizchi20kagura__platform__js9web__core21command__needs__depth as commandNeedsDepth, _M0FP36mizchi20kagura__platform__js9web__core24parse__texture__bindings as parseTextureBindings, _M0FP36mizchi20kagura__platform__js9web__core20get__instance__count as getInstanceCount, _M0FP36mizchi20kagura__platform__js9web__core25get__resource__cache__key as getResourceCacheKey, _M0FP36mizchi20kagura__platform__js9web__core13equal__dwords as equalDwords, _M0FP36mizchi20kagura__platform__js9web__core25instance__uniform__shader as instanceUniformShader, _M0FP36mizchi20kagura__platform__js9web__core22create__motion__player as createMotionPlayer, _M0FP36mizchi20kagura__platform__js9web__core14rotated__cells as rotatedCells, _M0FP36mizchi20kagura__platform__js9web__core10dimensions as dimensions, _M0FP36mizchi20kagura__platform__js9web__core18preview__placement as previewPlacement, _M0FP36mizchi20kagura__platform__js9web__core27is__inventory__ground__drop as isInventoryGroundDrop, _M0FP36mizchi20kagura__platform__js9web__core16comparison__rows as comparisonRows, _M0FP36mizchi20kagura__platform__js9web__core18register__geometry as registerGeometry, _M0FP36mizchi20kagura__platform__js9web__core20unregister__geometry as unregisterGeometry, _M0FP36mizchi20kagura__platform__js9web__core26register__static__geometry as registerStaticGeometry, _M0FP36mizchi20kagura__platform__js9web__core24snapshot__draw__geometry as snapshotDrawGeometry, _M0FP36mizchi20kagura__platform__js9web__core18normalize__gamepad as normalizeGamepad, _M0FP36mizchi20kagura__platform__js9web__core23create__gamepad__reader as createGamepadReader, _M0FP36mizchi20kagura__platform__js9web__core10percentile as percentile, _M0FP36mizchi20kagura__platform__js9web__core20summarize__intervals as summarizeIntervals, _M0FP36mizchi20kagura__platform__js9web__core20read__frame__profile as readFrameProfile, _M0FP36mizchi20kagura__platform__js9web__core24install__frame__profiler as installFrameProfiler, _M0FP36mizchi20kagura__platform__js9web__core13stick__vector as stickVector, _M0FP36mizchi20kagura__platform__js9web__core22create__control__input as createControlInput }
