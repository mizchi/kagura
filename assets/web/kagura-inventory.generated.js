// Generated from game/inventory_web/*.mbt by just web-runtime-build. DO NOT EDIT.
// Source SHA-256: 075250ce848f02b302f82e2ea15a22048efe4f6e7da8046a111e7b22410cc2bd
const _M0FPB12random__seed = () => {
  if (globalThis.crypto?.getRandomValues) {
    const array = new Uint32Array(1);
    globalThis.crypto.getRandomValues(array);
    return array[0] | 0; // Convert to signed 32
  } else {
    return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
  }
};
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
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
function $oob() {
  throw new Error("Index out of bounds");
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
const _M0MPB7JSArray4copy = (arr) => arr.slice(0);
const _M0FP36mizchi2js4core9undefined = () => undefined;
const _M0MP36mizchi2js4core3Any16__get__by__index = (obj, key) => obj[key];
const _M0MP36mizchi2js4core3Any5__get = (obj, key) => obj[key];
const _M0FP36mizchi2js4core11is__nullish = (v) => v == null;
const _M0FP36mizchi2js4core12throw__error = (msg) => { throw new Error(msg); };
const _M0FP36mizchi2js4core13is__undefined = (v) => v === undefined;
const _M0FP36mizchi2js4core5equal = (a, b) => a === b;
const _M0FP36mizchi2js4core13from__entries = (entries) => Object.fromEntries(entries.map(e => [e._0, e._1]));
const _M0FP36mizchi2js4core11array__from = (v) => Array.from(v);
function _M0TP36mizchi12kagura__game9inventory8ItemGrid(param0, param1, param2) {
  this.width = param0;
  this.height = param1;
  this.entries = param2;
}
function _M0DTPC16option6OptionGRPB5ArrayGiEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGiEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGiEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGiEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGiEE4Some.prototype.$tag = 1;
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
const _M0FP36mizchi12kagura__game14inventory__web6truthy = (value) => !!value;
function _M0TP36mizchi12kagura__game9inventory11PreviewItem(param0, param1, param2, param3, param4, param5) {
  this.source = param0;
  this.slot = param1;
  this.footprint = param2;
  this.x = param3;
  this.y = param4;
  this.rotated = param5;
}
function _M0TP36mizchi12kagura__game9inventory8DropRect(param0, param1, param2, param3) {
  this.left = param0;
  this.top = param1;
  this.right = param2;
  this.bottom = param3;
}
const _M0FPB4seed = _M0FPB12random__seed();
function _M0FPB13consume4__acc(acc, input) {
  const _p = (acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0;
  const _p$2 = 17;
  return Math.imul(_p << _p$2 | (_p >>> (32 - _p$2 | 0) | 0), 668265263) | 0;
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
function _M0MPC15array5Array4pushGRP36mizchi12kagura__game9inventory13GridPlacementE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16option6Option10unwrap__orGRPB5ArrayGiEE(self, default_) {
  if (self.$tag === 1) {
    const _Some = self;
    const _t = _Some._0;
    return _t;
  } else {
    return default_;
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
function _M0MPC16option6Option16unwrap__or__elseGRP36mizchi12kagura__game9inventory13GridFootprintE(self, default_) {
  if (self === undefined) {
    return default_();
  } else {
    const _Some = self;
    const _t = _Some;
    return _t;
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
function _M0MPC15array5Array4copyGUiiEE(self) {
  return _M0MPB7JSArray4copy(self);
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
function _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(self, rotated) {
  if (rotated) {
    const _p = self.cells;
    const _p$2 = new Array(_p.length);
    const _p$3 = _p.length;
    let _tmp = 0;
    while (true) {
      const _p$4 = _tmp;
      if (_p$4 < _p$3) {
        const _p$5 = _p[_p$4];
        _p$2[_p$4] = { _0: (self.height - 1 | 0) - _p$5._1 | 0, _1: _p$5._0 };
        _tmp = _p$4 + 1 | 0;
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
  const _p = 0;
  const _tmp = width > _p ? width : _p;
  const _p$2 = 0;
  return new _M0TP36mizchi12kagura__game9inventory8ItemGrid(_tmp, height > _p$2 ? height : _p$2, []);
}
function _M0MP36mizchi12kagura__game9inventory13GridFootprint12size_2einner(self, rotated) {
  return rotated ? { _0: self.height, _1: self.width } : { _0: self.width, _1: self.height };
}
function _M0MP36mizchi12kagura__game9inventory8ItemGrid20occupied__by_2einner(self, x, y, ignore_id) {
  const _bind = self.entries;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const entry = _bind[_];
      _L: {
        if (entry.id === ignore_id) {
          break _L;
        }
        const _bind$3 = _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(entry.footprint, entry.rotated);
        const _bind$4 = _bind$3.length;
        let _tmp$2 = 0;
        while (true) {
          const _$2 = _tmp$2;
          if (_$2 < _bind$4) {
            const cell = _bind$3[_$2];
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
    return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
  }
  const ids = [];
  const _bind$2 = _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(footprint, rotated);
  const _bind$3 = _bind$2.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$3) {
      const cell = _bind$2[_];
      const _bind$4 = _M0MP36mizchi12kagura__game9inventory8ItemGrid20occupied__by_2einner(self, x + cell._0 | 0, y + cell._1 | 0, ignore_id);
      if (_bind$4 === undefined) {
      } else {
        const _Some = _bind$4;
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
  return new _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(ids);
}
function _M0FP36mizchi12kagura__game9inventory18preview__placement(width, height, items, item, x, y, rotated) {
  const grid = _M0MP36mizchi12kagura__game9inventory8ItemGrid3new(width, height);
  const _bind = items.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const other = items[_];
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
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp$2 = 0;
  while (true) {
    const _p$4 = _tmp$2;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = { _0: x + _p$5._0 | 0, _1: y + _p$5._1 | 0 };
      _tmp$2 = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const cells = _p$2;
  const overlaps = _M0MP36mizchi12kagura__game9inventory8ItemGrid16overlaps_2einner(grid, item.footprint, x, y, rotated, item.source);
  const ids = _M0MPC16option6Option10unwrap__orGRPB5ArrayGiEE(overlaps, []);
  let matching = true;
  if (item.source < 0) {
    const _bind$2 = items.length;
    let _tmp$3 = 0;
    while (true) {
      const _ = _tmp$3;
      if (_ < _bind$2) {
        const other = items[_];
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
  let _tmp$3;
  if (overlaps.$tag === 1) {
    _tmp$3 = ids.length <= 1 && matching;
  } else {
    _tmp$3 = false;
  }
  return new _M0TP36mizchi12kagura__game9inventory16PlacementPreview(cells, _tmp$3, ids.length === 1);
}
function _M0FP36mizchi12kagura__game9inventory14compare__stats(current, previous) {
  const _bind = [];
  const old = _M0MPB3Map3MapGsdE(new _M0TPB9ArrayViewGUsdEE(_bind, 0, 0), undefined);
  const _bind$2 = previous.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const _foreach_element = previous[_];
      const _label = _foreach_element._0;
      const _value = _foreach_element._1;
      _M0MPB3Map3setGsdE(old, _label, _value);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const rows = [];
  const _bind$3 = current.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const _foreach_element = current[_];
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
  if (cells.length === 0) {
    return undefined;
  }
  let width = 0;
  let height = 0;
  const copied = [];
  const _bind = cells.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const cell = cells[_];
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
  return _M0FP36mizchi2js4core11is__nullish(value) ? [] : _M0FP36mizchi2js4core11array__from(value);
}
function _M0FP36mizchi12kagura__game14inventory__web5shape(item) {
  const _p = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0MP36mizchi2js4core3Any5__get(item, "cells"));
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = { _0: _M0MP36mizchi2js4core3Any16__get__by__index(_p$5, 0), _1: _M0MP36mizchi2js4core3Any16__get__by__index(_p$5, 1) };
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPC16option6Option16unwrap__or__elseGRP36mizchi12kagura__game9inventory13GridFootprintE(_M0MP36mizchi12kagura__game9inventory13GridFootprint3new(_p$2), () => {
    _M0FP36mizchi2js4core12throw__error("Invalid inventory footprint");
    return $panic();
  });
}
function _M0FP36mizchi12kagura__game14inventory__web9footprint(item, rotated) {
  return _M0MP36mizchi12kagura__game9inventory13GridFootprint13cells_2einner(_M0FP36mizchi12kagura__game14inventory__web5shape(item), rotated);
}
function _M0FP36mizchi12kagura__game14inventory__web13cells__to__js(cells) {
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
function _M0FP36mizchi12kagura__game14inventory__web13preview__item(item) {
  return new _M0TP36mizchi12kagura__game9inventory11PreviewItem(_M0MP36mizchi2js4core3Any5__get(item, "source"), _M0MP36mizchi2js4core3Any5__get(item, "slot"), _M0FP36mizchi12kagura__game14inventory__web5shape(item), _M0MP36mizchi2js4core3Any5__get(item, "x"), _M0MP36mizchi2js4core3Any5__get(item, "y"), _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0MP36mizchi2js4core3Any5__get(item, "rotated")));
}
function _M0FP36mizchi12kagura__game14inventory__web8argument(value, default_) {
  return _M0FP36mizchi2js4core13is__undefined(value) ? default_ : value;
}
function _M0FP36mizchi12kagura__game14inventory__web14rotated__cells(item, rotated) {
  return _M0FP36mizchi12kagura__game14inventory__web13cells__to__js(_M0FP36mizchi12kagura__game14inventory__web9footprint(item, _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0FP36mizchi12kagura__game14inventory__web8argument(rotated, _M0MP36mizchi2js4core3Any5__get(item, "rotated")))));
}
function _M0FP36mizchi12kagura__game14inventory__web10dimensions(item, rotated) {
  const _bind = _M0MP36mizchi12kagura__game9inventory13GridFootprint12size_2einner(_M0FP36mizchi12kagura__game14inventory__web5shape(item), _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0FP36mizchi12kagura__game14inventory__web8argument(rotated, _M0MP36mizchi2js4core3Any5__get(item, "rotated"))));
  const _width = _bind._0;
  const _height = _bind._1;
  return [_width, _height];
}
function _M0FP36mizchi12kagura__game14inventory__web18preview__placement(view, item, x, y, rotated) {
  const _tmp = _M0MP36mizchi2js4core3Any5__get(view, "width");
  const _tmp$2 = _M0MP36mizchi2js4core3Any5__get(view, "height");
  const _p = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0MP36mizchi2js4core3Any5__get(view, "items"));
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp$3 = 0;
  while (true) {
    const _p$4 = _tmp$3;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = _M0FP36mizchi12kagura__game14inventory__web13preview__item(_p$5);
      _tmp$3 = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const result = _M0FP36mizchi12kagura__game9inventory18preview__placement(_tmp, _tmp$2, _p$2, _M0FP36mizchi12kagura__game14inventory__web13preview__item(item), x, y, _M0FP36mizchi12kagura__game14inventory__web6truthy(_M0FP36mizchi12kagura__game14inventory__web8argument(rotated, _M0MP36mizchi2js4core3Any5__get(item, "rotated"))));
  return _M0FP36mizchi2js4core13from__entries([{ _0: "cells", _1: _M0FP36mizchi12kagura__game14inventory__web13cells__to__js(result.cells) }, { _0: "valid", _1: result.valid }, { _0: "swap", _1: result.swap }]);
}
function _M0FP36mizchi12kagura__game14inventory__web4rect(value) {
  if (!_M0FP36mizchi12kagura__game14inventory__web6truthy(value)) {
    return undefined;
  }
  const _p = _M0MP36mizchi2js4core3Any5__get(value, "left");
  const _p$2 = _M0MP36mizchi2js4core3Any5__get(value, "top");
  const _p$3 = _M0MP36mizchi2js4core3Any5__get(value, "right");
  const _p$4 = _M0MP36mizchi2js4core3Any5__get(value, "bottom");
  return new _M0TP36mizchi12kagura__game9inventory8DropRect(_p, _p$2, _p$3, _p$4);
}
function _M0FP36mizchi12kagura__game14inventory__web27is__inventory__ground__drop(x, y, dialog, surface) {
  return _M0FP36mizchi12kagura__game9inventory16is__ground__drop(x, y, _M0FP36mizchi12kagura__game14inventory__web4rect(dialog), _M0FP36mizchi12kagura__game14inventory__web4rect(surface));
}
function _M0FP36mizchi12kagura__game14inventory__web5field(value, key) {
  return _M0FP36mizchi2js4core11is__nullish(value) ? _M0FP36mizchi2js4core9undefined() : _M0MP36mizchi2js4core3Any5__get(value, key);
}
function _M0FP36mizchi12kagura__game14inventory__web5stats(item) {
  const _p = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0FP36mizchi12kagura__game14inventory__web5field(item, "stats"));
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp = 0;
  while (true) {
    const _p$4 = _tmp;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      const _tmp$2 = _M0MP36mizchi2js4core3Any16__get__by__index(_p$5, 0);
      const _p$6 = _M0MP36mizchi2js4core3Any16__get__by__index(_p$5, 1);
      _p$2[_p$4] = { _0: _tmp$2, _1: _p$6 };
      _tmp = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _p$2;
}
function _M0FP36mizchi12kagura__game14inventory__web16comparison__rows(view, item) {
  let previous = [];
  const _bind = _M0FP36mizchi12kagura__game14inventory__web13array__values(_M0MP36mizchi2js4core3Any5__get(view, "equipment"));
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const slot = _bind[_];
      if (_M0FP36mizchi2js4core5equal(_M0MP36mizchi2js4core3Any5__get(slot, "id"), _M0MP36mizchi2js4core3Any5__get(item, "slot"))) {
        previous = _M0FP36mizchi12kagura__game14inventory__web5stats(_M0MP36mizchi2js4core3Any5__get(slot, "item"));
        break;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _p = _M0FP36mizchi12kagura__game9inventory14compare__stats(_M0FP36mizchi12kagura__game14inventory__web5stats(item), previous);
  const _p$2 = new Array(_p.length);
  const _p$3 = _p.length;
  let _tmp$2 = 0;
  while (true) {
    const _p$4 = _tmp$2;
    if (_p$4 < _p$3) {
      const _p$5 = _p[_p$4];
      _p$2[_p$4] = _M0FP36mizchi2js4core13from__entries([{ _0: "label", _1: _p$5.label }, { _0: "value", _1: _p$5.value }, { _0: "before", _1: _p$5.before }, { _0: "delta", _1: _p$5.delta }]);
      _tmp$2 = _p$4 + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _p$2;
}
export { _M0FP36mizchi12kagura__game14inventory__web14rotated__cells as rotatedCells, _M0FP36mizchi12kagura__game14inventory__web10dimensions as dimensions, _M0FP36mizchi12kagura__game14inventory__web18preview__placement as previewPlacement, _M0FP36mizchi12kagura__game14inventory__web27is__inventory__ground__drop as isInventoryGroundDrop, _M0FP36mizchi12kagura__game14inventory__web16comparison__rows as comparisonRows }
