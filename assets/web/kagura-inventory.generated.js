// Generated from game/inventory_web/*.mbt by just web-runtime-build. DO NOT EDIT.
// Source SHA-256: deac21a94d26c1a7bc8bfaddfacdc06e602d0c16e4ab63428c9b234b531a3adc
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
const _M0FPB12random__seed = () => {
  if (globalThis.crypto?.getRandomValues) {
    const array = new Uint32Array(1);
    globalThis.crypto.getRandomValues(array);
    return array[0] | 0; // Convert to signed 32
  } else {
    return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
  }
};
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function _M0TPB5ArrayGUiiEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGRP26mizchi8js__core3AnyE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
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
const _M0FP26mizchi8js__core9undefined = () => undefined;
const _M0MP26mizchi8js__core3Any16__get__by__index = (obj, key) => obj[key];
const _M0MP26mizchi8js__core3Any5__get = (obj, key) => obj[key];
const _M0FP26mizchi8js__core11is__nullish = (v) => v == null;
const _M0FP26mizchi8js__core12throw__error = (msg) => { throw new Error(msg); };
const _M0FP26mizchi8js__core13is__undefined = (v) => v === undefined;
const _M0FP26mizchi8js__core5equal = (a, b) => a === b;
const _M0FP26mizchi8js__core18ffi__from__entries = (entries) => Object.fromEntries(entries.map(e => [e._0, e._1]));
function _M0TPB9ArrayViewGUsRP26mizchi8js__core3AnyEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP26mizchi8js__core16ffi__array__from = (v) => Array.from(v);
function _M0TP36mizchi12kagura__game9inventory8ItemGrid(param0, param1, param2) {
  this.width = param0;
  this.height = param1;
  this.entries = param2;
}
function _M0TPB5ArrayGRP36mizchi12kagura__game9inventory13GridPlacementE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGiE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TP36mizchi12kagura__game9inventory13GridPlacement(param0, param1, param2, param3, param4) {
  this.id = param0;
  this.footprint = param1;
  this.x = param2;
  this.y = param3;
  this.rotated = param4;
}
function _M0TP36mizchi12kagura__game9inventory16PlacementPreview(param0, param1, param2) {
  this.cells = param0;
  this.valid = param1;
  this.swap = param2;
}
function _M0TPB9ArrayViewGUsdEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB5ArrayGRP36mizchi12kagura__game9inventory14StatComparisonE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TP36mizchi12kagura__game9inventory14StatComparison(param0, param1, param2, param3) {
  this.label = param0;
  this.value = param1;
  this.before = param2;
  this.delta = param3;
}
function _M0TP36mizchi12kagura__game9inventory13GridFootprint(param0, param1, param2) {
  this.width = param0;
  this.height = param1;
  this.cells = param2;
}
function _M0TPB9ArrayViewGAiE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB9ArrayViewGRP26mizchi8js__core3AnyE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP36mizchi12kagura__game14inventory__web6truthy = (value) => !!value;
function _M0TP36mizchi12kagura__game9inventory11PreviewItem(param0, param1, param2, param3, param4, param5) {
  this.source = param0;
  this.slot = param1;
  this.footprint = param2;
  this.x = param3;
  this.y = param4;
  this.rotated = param5;
}
function _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TP36mizchi12kagura__game9inventory8DropRect(param0, param1, param2, param3) {
  this.left = param0;
  this.top = param1;
  this.right = param2;
  this.bottom = param3;
}
function _M0TPB5ArrayGUsdEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0FPB4seed = _M0FPB12random__seed();
function _M0FPB13consume4__acc(acc, input) {
  const _p = (acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0;
  return Math.imul(_p << 17 | (_p >>> 15 | 0), 668265263) | 0;
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRP36mizchi12kagura__game9inventory14StatComparisonEE(dst, dst_offset, src, src_offset, len) {
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
function _M0MPB18UninitializedArray12unsafe__blitGRP36mizchi12kagura__game9inventory13GridPlacementE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRP36mizchi12kagura__game9inventory14StatComparisonEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGiE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGiEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGRP36mizchi12kagura__game9inventory13GridPlacementE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGRP36mizchi12kagura__game9inventory13GridPlacementE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGiE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGiE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGRP36mizchi12kagura__game9inventory13GridPlacementE(src, allocate_len, len, src_offset, dst_offset) {
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
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGRP36mizchi12kagura__game9inventory13GridPlacementE(src, allocate_len, src_offset, dst_offset, len);
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
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
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
function _M0MPC15array5Array8capacityGRP36mizchi12kagura__game9inventory13GridPlacementE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array8capacityGiE(self) {
  return self.buf.length;
}
function _M0MPC15array5Array14resize__bufferGRP36mizchi12kagura__game9inventory13GridPlacementE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGRP36mizchi12kagura__game9inventory13GridPlacementE(old_buf, new_capacity, copy_len, 0, 0);
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
function _M0MPC15array5Array7reallocGRP36mizchi12kagura__game9inventory13GridPlacementE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGRP36mizchi12kagura__game9inventory13GridPlacementE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGRP36mizchi12kagura__game9inventory13GridPlacementE(self, new_cap);
}
function _M0MPC15array5Array7reallocGiE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGiE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGiE(self, new_cap);
}
function _M0MPC15array5Array4pushGRP36mizchi12kagura__game9inventory13GridPlacementE(self, value) {
  if (self.len === self.buf.length) {
    _M0MPC15array5Array7reallocGRP36mizchi12kagura__game9inventory13GridPlacementE(self, self.len + 1 | 0);
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
function _M0IPC13int3IntPB4Show10to__string(self) {
  return _M0MPC13int3Int18to__string_2einner(self, 10);
}
function _M0MPC15array10FixedArray11from__arrayGAiE(array) {
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
function _M0MPC15array5Array20unsafe__make__uninitGUiiEE(len) {
  return new _M0TPB5ArrayGUiiEE(new Array(len), len);
}
function _M0MPC15array5Array20unsafe__make__uninitGRP26mizchi8js__core3AnyE(len) {
  return new _M0TPB5ArrayGRP26mizchi8js__core3AnyE(new Array(len), len);
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
function _M0MPC16option6Option10unwrap__orGRPB5ArrayGiEE(self, default_) {
  if (self === undefined) {
    return default_;
  } else {
    const _Some = self;
    const _t = _Some;
    return _t;
  }
}
function _M0MPC16option6Option16unwrap__or__elseGRP36mizchi12kagura__game9inventory13GridFootprintE(self, default_) {
  if (self === undefined) {
    return default_();
  } else {
    const _Some = self;
    const _t = _Some;
    return _t;
  }
}
function _M0FPB21calc__grow__threshold(capacity) {
  return (Math.imul(capacity / 16 | 0, 13) | 0) + ((Math.imul(capacity % 16 | 0, 13) | 0) / 16 | 0) | 0;
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
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGsdE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB21capacity__for__length(length) {
  if (length <= _M0FPB21calc__grow__threshold(1073741824)) {
    let capacity = _M0MPC13int3Int20next__power__of__two(length);
    if (length > _M0FPB21calc__grow__threshold(capacity)) {
      capacity = Math.imul(capacity, 2) | 0;
    }
    return capacity;
  } else {
    return $panic("Map capacity overflow");
  }
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
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
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
    capacity$2 = _M0FPB21capacity__for__length(_capacity > length ? _capacity : length);
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
function _M0MPC15array5Array44unsafe__make__and__blit__from__fixed_2einnerGRP26mizchi8js__core3AnyE(src, allocate_len, len, src_offset, dst_offset) {
  return new _M0TPB5ArrayGRP26mizchi8js__core3AnyE(_M0MPB18UninitializedArray36unsafe__make__and__blit__from__fixedGRP26mizchi8js__core3AnyE(src, allocate_len, src_offset, dst_offset, len), allocate_len);
}
function _M0MPC15array5Array12unsafe__blitGUiiEE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRP36mizchi12kagura__game9inventory14StatComparisonEE(dst.buf, dst_offset, src.buf, src_offset, len);
}
function _M0MPC15array5Array4copyGUiiEE(self) {
  const len = self.len;
  if (len === 0) {
    return new _M0TPB5ArrayGUiiEE([], 0);
  }
  const arr = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(len);
  _M0MPC15array5Array12unsafe__blitGUiiEE(arr, 0, self, 0, len);
  return arr;
}
function _M0MPC15array5Array18from__fixed__arrayGRP26mizchi8js__core3AnyE(arr) {
  const len = arr.length;
  return _M0MPC15array5Array44unsafe__make__and__blit__from__fixed_2einnerGRP26mizchi8js__core3AnyE(arr, len, len, 0, 0);
}
function _M0MPC15array5Array8containsGUiiEE(self, value) {
  const _bind = self.len;
  const _bind$2 = self.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = _bind$2[_];
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
function _M0FP26mizchi8js__core13from__entries(entries) {
  return _M0FP26mizchi8js__core18ffi__from__entries(_M0MPC15array10FixedArray11from__arrayGAiE(new _M0TPB9ArrayViewGUsRP26mizchi8js__core3AnyEE(entries.buf, 0, entries.len)));
}
function _M0FP26mizchi8js__core11array__from(v) {
  return _M0MPC15array5Array18from__fixed__arrayGRP26mizchi8js__core3AnyE(_M0FP26mizchi8js__core16ffi__array__from(v));
}
function _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(self, rotated) {
  if (rotated) {
    const _p = self.cells;
    const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(_p.len);
    const _p$3 = _p.len;
    const _p$4 = _p.buf;
    let _tmp = 0;
    while (true) {
      const _p$5 = _tmp;
      if (_p$5 < _p$3) {
        const _p$6 = _p$4[_p$5];
        const _p$7 = { _0: (self.height - 1 | 0) - _p$6._1 | 0, _1: _p$6._0 };
        _p$2.buf[_p$5] = _p$7;
        _tmp = _p$5 + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return _p$2;
  } else {
    return _M0MPC15array5Array4copyGUiiEE(self.cells);
  }
}
function _M0MP36mizchi12kagura__game9inventory8ItemGrid3new(width, height) {
  return new _M0TP36mizchi12kagura__game9inventory8ItemGrid(width > 0 ? width : 0, height > 0 ? height : 0, new _M0TPB5ArrayGRP36mizchi12kagura__game9inventory13GridPlacementE([], 0));
}
function _M0MP36mizchi12kagura__game9inventory13GridFootprint12size_2einner(self, rotated) {
  return rotated ? { _0: self.height, _1: self.width } : { _0: self.width, _1: self.height };
}
function _M0MP36mizchi12kagura__game9inventory8ItemGrid20occupied__by_2einner(self, x, y, ignore_id) {
  const _bind = self.entries;
  const _bind$2 = _bind.len;
  const _bind$3 = _bind.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const entry = _bind$3[_];
      _L: {
        if (entry.id === ignore_id) {
          break _L;
        }
        const _bind$4 = _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(entry.footprint, entry.rotated);
        const _bind$5 = _bind$4.len;
        const _bind$6 = _bind$4.buf;
        let _tmp$2 = 0;
        while (true) {
          const _$2 = _tmp$2;
          if (_$2 < _bind$5) {
            const cell = _bind$6[_$2];
            if ((entry.x + cell._0 | 0) === x && (entry.y + cell._1 | 0) === y) {
              return entry.id;
            }
            _tmp$2 = _$2 + 1 | 0;
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
  return undefined;
}
function _M0MP36mizchi12kagura__game9inventory8ItemGrid16overlaps_2einner(self, footprint, x, y, rotated, ignore_id) {
  const _bind = _M0MP36mizchi12kagura__game9inventory13GridFootprint12size_2einner(footprint, rotated);
  const _width = _bind._0;
  const _height = _bind._1;
  if (x < 0 || (y < 0 || (_width > self.width || (_height > self.height || (x > (self.width - _width | 0) || y > (self.height - _height | 0)))))) {
    return undefined;
  }
  const ids = new _M0TPB5ArrayGiE([], 0);
  const _bind$2 = _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(footprint, rotated);
  const _bind$3 = _bind$2.len;
  const _bind$4 = _bind$2.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$3) {
      const cell = _bind$4[_];
      const _bind$5 = _M0MP36mizchi12kagura__game9inventory8ItemGrid20occupied__by_2einner(self, x + cell._0 | 0, y + cell._1 | 0, ignore_id);
      if (_bind$5 === undefined) {
      } else {
        const _Some = _bind$5;
        const _id = _Some;
        if (!_M0MPC15array5Array8containsGiE(ids, _id)) {
          _M0MPC15array5Array4pushGiE(ids, _id);
        }
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return ids;
}
function _M0FP36mizchi12kagura__game9inventory18preview__placement(width, height, items, item, x, y, rotated) {
  const grid = _M0MP36mizchi12kagura__game9inventory8ItemGrid3new(width, height);
  const _bind = items.len;
  const _bind$2 = items.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const other = _bind$2[_];
      if (other.x >= 0 && other.source >= 0) {
        _M0MPC15array5Array4pushGRP36mizchi12kagura__game9inventory13GridPlacementE(grid.entries, new _M0TP36mizchi12kagura__game9inventory13GridPlacement(other.source, other.footprint, other.x, other.y, other.rotated));
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _p = _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(item.footprint, rotated);
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp$2 = 0;
  while (true) {
    const _p$5 = _tmp$2;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = { _0: x + _p$6._0 | 0, _1: y + _p$6._1 | 0 };
      _p$2.buf[_p$5] = _p$7;
      _tmp$2 = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const cells = _p$2;
  const overlaps = _M0MP36mizchi12kagura__game9inventory8ItemGrid16overlaps_2einner(grid, item.footprint, x, y, rotated, item.source);
  const ids = _M0MPC16option6Option10unwrap__orGRPB5ArrayGiEE(overlaps, new _M0TPB5ArrayGiE([], 0));
  let matching = true;
  if (item.source < 0) {
    const _bind$3 = items.len;
    const _bind$4 = items.buf;
    let _tmp$3 = 0;
    while (true) {
      const _ = _tmp$3;
      if (_ < _bind$3) {
        const other = _bind$4[_];
        if (_M0MPC15array5Array8containsGiE(ids, other.source) && other.slot !== item.slot) {
          matching = false;
        }
        _tmp$3 = _ + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  return new _M0TP36mizchi12kagura__game9inventory16PlacementPreview(cells, overlaps === undefined ? false : ids.len <= 1 && matching, ids.len === 1);
}
function _M0FP36mizchi12kagura__game9inventory14compare__stats(current, previous) {
  const _bind = [];
  const old = _M0MPB3Map3MapGsdE(new _M0TPB9ArrayViewGUsdEE(_bind, 0, 0), undefined);
  const _bind$2 = previous.len;
  const _bind$3 = previous.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const _foreach_element = _bind$3[_];
      const _label = _foreach_element._0;
      const _value = _foreach_element._1;
      _M0MPB3Map3setGsdE(old, _label, _value);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const rows = new _M0TPB5ArrayGRP36mizchi12kagura__game9inventory14StatComparisonE([], 0);
  const _bind$4 = current.len;
  const _bind$5 = current.buf;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$4) {
      const _foreach_element = _bind$5[_];
      const _label = _foreach_element._0;
      const _value = _foreach_element._1;
      const before = _M0MPC16option6Option10unwrap__orGdE(_M0MPB3Map3getGsdE(old, _label), 0);
      if (_value !== 0 || before !== 0) {
        _M0MPC15array5Array4pushGRP36mizchi12kagura__game9inventory13GridPlacementE(rows, new _M0TP36mizchi12kagura__game9inventory14StatComparison(_label, _value, before, _value - before));
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return rows;
}
function _M0MP36mizchi12kagura__game9inventory8DropRect8contains(self, x, y) {
  return x >= self.left && (y >= self.top && (x < self.right && y < self.bottom));
}
function _M0FP36mizchi12kagura__game9inventory16is__ground__drop(x, y, dialog, surface) {
  if (dialog === undefined) {
    return false;
  } else {
    const _Some = dialog;
    const _dialog = _Some;
    if (surface === undefined) {
      return false;
    } else {
      const _Some$2 = surface;
      const _surface = _Some$2;
      return _M0MP36mizchi12kagura__game9inventory8DropRect8contains(_surface, x, y) && !_M0MP36mizchi12kagura__game9inventory8DropRect8contains(_dialog, x, y);
    }
  }
}
function _M0MP36mizchi12kagura__game9inventory13GridFootprint3new(cells) {
  if (cells.len === 0) {
    return undefined;
  }
  let width = 0;
  let height = 0;
  const copied = new _M0TPB5ArrayGUiiEE([], 0);
  const _bind = cells.len;
  const _bind$2 = cells.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const cell = _bind$2[_];
      const _x = cell._0;
      const _y = cell._1;
      if (_x < 0 || (_y < 0 || (_x >= 128 || (_y >= 128 || _M0MPC15array5Array8containsGUiiEE(copied, cell))))) {
        return undefined;
      }
      _M0MPC15array5Array4pushGRP36mizchi12kagura__game9inventory13GridPlacementE(copied, cell);
      const _p = width;
      const _p$2 = _x + 1 | 0;
      width = _p > _p$2 ? _p : _p$2;
      const _p$3 = height;
      const _p$4 = _y + 1 | 0;
      height = _p$3 > _p$4 ? _p$3 : _p$4;
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP36mizchi12kagura__game9inventory13GridFootprint(width, height, copied);
}
function _M0FP36mizchi12kagura__game14inventory__web13array__values(value) {
  return _M0FP26mizchi8js__core11is__nullish(value) ? new _M0TPB5ArrayGRP26mizchi8js__core3AnyE([], 0) : _M0FP26mizchi8js__core11array__from(value);
}
function _M0FP36mizchi12kagura__game14inventory__web5shape(item) {
  const _p = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0MP26mizchi8js__core3Any5__get(item, "cells"));
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp = 0;
  while (true) {
    const _p$5 = _tmp;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = { _0: _M0MP26mizchi8js__core3Any16__get__by__index(_p$6, 0), _1: _M0MP26mizchi8js__core3Any16__get__by__index(_p$6, 1) };
      _p$2.buf[_p$5] = _p$7;
      _tmp = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPC16option6Option16unwrap__or__elseGRP36mizchi12kagura__game9inventory13GridFootprintE(_M0MP36mizchi12kagura__game9inventory13GridFootprint3new(_p$2), () => {
    _M0FP26mizchi8js__core12throw__error("Invalid inventory footprint");
    return $panic("unreachable");
  });
}
function _M0FP36mizchi12kagura__game14inventory__web9footprint(item, rotated) {
  return _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(_M0FP36mizchi12kagura__game14inventory__web5shape(item), rotated);
}
function _M0FP36mizchi12kagura__game14inventory__web13array__to__jsGAiE(values) {
  return _M0MPC15array10FixedArray11from__arrayGAiE(new _M0TPB9ArrayViewGAiE(values.buf, 0, values.len));
}
function _M0FP36mizchi12kagura__game14inventory__web13array__to__jsGRP26mizchi8js__core3AnyE(values) {
  return _M0MPC15array10FixedArray11from__arrayGRP26mizchi8js__core3AnyE(new _M0TPB9ArrayViewGRP26mizchi8js__core3AnyE(values.buf, 0, values.len));
}
function _M0FP36mizchi12kagura__game14inventory__web13cells__to__js(cells) {
  const _p = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(cells.len);
  const _p$2 = cells.len;
  const _p$3 = cells.buf;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$2) {
      const _p$5 = _p$3[_p$4];
      const _p$6 = [_p$5._0, _p$5._1];
      _p.buf[_p$4] = _p$6;
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi12kagura__game14inventory__web13array__to__jsGAiE(_p);
}
function _M0FP36mizchi12kagura__game14inventory__web13preview__item(item) {
  return new _M0TP36mizchi12kagura__game9inventory11PreviewItem(_M0MP26mizchi8js__core3Any5__get(item, "source"), _M0MP26mizchi8js__core3Any5__get(item, "slot"), _M0FP36mizchi12kagura__game14inventory__web5shape(item), _M0MP26mizchi8js__core3Any5__get(item, "x"), _M0MP26mizchi8js__core3Any5__get(item, "y"), _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0MP26mizchi8js__core3Any5__get(item, "rotated")));
}
function _M0FP36mizchi12kagura__game14inventory__web8argument(value, default_) {
  return _M0FP26mizchi8js__core13is__undefined(value) ? default_ : value;
}
function _M0FP36mizchi12kagura__game14inventory__web14rotated__cells(item, rotated) {
  return _M0FP36mizchi12kagura__game14inventory__web13cells__to__js(_M0FP36mizchi12kagura__game14inventory__web9footprint(item, _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0FP36mizchi12kagura__game14inventory__web8argument(rotated, _M0MP26mizchi8js__core3Any5__get(item, "rotated")))));
}
function _M0FP36mizchi12kagura__game14inventory__web10dimensions(item, rotated) {
  const _bind = _M0MP36mizchi12kagura__game9inventory13GridFootprint12size_2einner(_M0FP36mizchi12kagura__game14inventory__web5shape(item), _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0FP36mizchi12kagura__game14inventory__web8argument(rotated, _M0MP26mizchi8js__core3Any5__get(item, "rotated"))));
  const _width = _bind._0;
  const _height = _bind._1;
  return [_width, _height];
}
function _M0FP36mizchi12kagura__game14inventory__web18preview__placement(view, item, x, y, rotated) {
  const _tmp = _M0MP26mizchi8js__core3Any5__get(view, "width");
  const _tmp$2 = _M0MP26mizchi8js__core3Any5__get(view, "height");
  const _p = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0MP26mizchi8js__core3Any5__get(view, "items"));
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp$3 = 0;
  while (true) {
    const _p$5 = _tmp$3;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = _M0FP36mizchi12kagura__game14inventory__web13preview__item(_p$6);
      _p$2.buf[_p$5] = _p$7;
      _tmp$3 = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const result = _M0FP36mizchi12kagura__game9inventory18preview__placement(_tmp, _tmp$2, _p$2, _M0FP36mizchi12kagura__game14inventory__web13preview__item(item), x, y, _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0FP36mizchi12kagura__game14inventory__web8argument(rotated, _M0MP26mizchi8js__core3Any5__get(item, "rotated"))));
  return _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "cells", _1: _M0FP36mizchi12kagura__game14inventory__web13cells__to__js(result.cells) }, { _0: "valid", _1: result.valid }, { _0: "swap", _1: result.swap }], 3));
}
function _M0FP36mizchi12kagura__game14inventory__web4rect(value) {
  if (!_M0FP36mizchi12kagura__game14inventory__web6truthy(value)) {
    return undefined;
  }
  const _p = _M0MP26mizchi8js__core3Any5__get(value, "left");
  const _p$2 = _M0MP26mizchi8js__core3Any5__get(value, "top");
  const _p$3 = _M0MP26mizchi8js__core3Any5__get(value, "right");
  const _p$4 = _M0MP26mizchi8js__core3Any5__get(value, "bottom");
  return new _M0TP36mizchi12kagura__game9inventory8DropRect(_p, _p$2, _p$3, _p$4);
}
function _M0FP36mizchi12kagura__game14inventory__web27is__inventory__ground__drop(x, y, dialog, surface) {
  return _M0FP36mizchi12kagura__game9inventory16is__ground__drop(x, y, _M0FP36mizchi12kagura__game14inventory__web4rect(dialog), _M0FP36mizchi12kagura__game14inventory__web4rect(surface));
}
function _M0FP36mizchi12kagura__game14inventory__web5field(value, key) {
  return _M0FP26mizchi8js__core11is__nullish(value) ? _M0FP26mizchi8js__core9undefined() : _M0MP26mizchi8js__core3Any5__get(value, key);
}
function _M0FP36mizchi12kagura__game14inventory__web5stats(item) {
  const _p = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0FP36mizchi12kagura__game14inventory__web5field(item, "stats"));
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGUiiEE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp = 0;
  while (true) {
    const _p$5 = _tmp;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _tmp$2 = _M0MP26mizchi8js__core3Any16__get__by__index(_p$6, 0);
      const _p$7 = _M0MP26mizchi8js__core3Any16__get__by__index(_p$6, 1);
      const _p$8 = { _0: _tmp$2, _1: _p$7 };
      _p$2.buf[_p$5] = _p$8;
      _tmp = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _p$2;
}
function _M0FP36mizchi12kagura__game14inventory__web16comparison__rows(view, item) {
  let previous = new _M0TPB5ArrayGUsdEE([], 0);
  const _bind = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0MP26mizchi8js__core3Any5__get(view, "equipment"));
  const _bind$2 = _bind.len;
  const _bind$3 = _bind.buf;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const slot = _bind$3[_];
      if (_M0FP26mizchi8js__core5equal(_M0MP26mizchi8js__core3Any5__get(slot, "id"), _M0MP26mizchi8js__core3Any5__get(item, "slot"))) {
        previous = _M0FP36mizchi12kagura__game14inventory__web5stats(_M0MP26mizchi8js__core3Any5__get(slot, "item"));
        break;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _p = _M0FP36mizchi12kagura__game9inventory14compare__stats(_M0FP36mizchi12kagura__game14inventory__web5stats(item), previous);
  const _p$2 = _M0MPC15array5Array20unsafe__make__uninitGRP26mizchi8js__core3AnyE(_p.len);
  const _p$3 = _p.len;
  const _p$4 = _p.buf;
  let _tmp$2 = 0;
  while (true) {
    const _p$5 = _tmp$2;
    if (_p$5 < _p$3) {
      const _p$6 = _p$4[_p$5];
      const _p$7 = _M0FP26mizchi8js__core13from__entries(new _M0TPB5ArrayGUsRP26mizchi8js__core3AnyEE([{ _0: "label", _1: _p$6.label }, { _0: "value", _1: _p$6.value }, { _0: "before", _1: _p$6.before }, { _0: "delta", _1: _p$6.delta }], 4));
      _p$2.buf[_p$5] = _p$7;
      _tmp$2 = _p$5 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi12kagura__game14inventory__web13array__to__jsGRP26mizchi8js__core3AnyE(_p$2);
}
export { _M0FP36mizchi12kagura__game14inventory__web14rotated__cells as rotatedCells, _M0FP36mizchi12kagura__game14inventory__web10dimensions as dimensions, _M0FP36mizchi12kagura__game14inventory__web18preview__placement as previewPlacement, _M0FP36mizchi12kagura__game14inventory__web27is__inventory__ground__drop as isInventoryGroundDrop, _M0FP36mizchi12kagura__game14inventory__web16comparison__rows as comparisonRows }
