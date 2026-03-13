const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $f32_reinterpret_i32(a) {
  $reinterpret_view.setInt32(0, a, true);
  return $reinterpret_view.getFloat32(0, true);
}
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FP311moonbitlang4core7builtin12random__seed = () => {
  if (globalThis.crypto?.getRandomValues) {
    const array = new Uint32Array(1);
    globalThis.crypto.getRandomValues(array);
    return array[0] | 0; // Convert to signed 32
  } else {
    return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
  }
};
function Result$Err$0$(param0) {
  this._0 = param0;
}
Result$Err$0$.prototype.$tag = 0;
Result$Err$0$.prototype.$name = "Err";
function Result$Ok$0$(param0) {
  this._0 = param0;
}
Result$Ok$0$.prototype.$tag = 1;
Result$Ok$0$.prototype.$name = "Ok";
const Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$IndexOutOfBounds = { $tag: 1, $name: "moonbitlang/core/builtin.CreatingViewError.IndexOutOfBounds" };
const Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$InvalidIndex = { $tag: 0, $name: "moonbitlang/core/builtin.CreatingViewError.InvalidIndex" };
const _M0FP311moonbitlang4core7builtin19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
const _M0MP311moonbitlang4core7builtin7JSArray4push = (arr, val) => { arr.push(val); };
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MP311moonbitlang4core7builtin7MyInt6419reinterpret__double = function f(a) {
  let view = f._view;
  if (view === undefined) {
    view = f._view = new DataView(new ArrayBuffer(8));
  }
  view.setFloat64(0, a);
  const hi = view.getInt32(0);
  const lo = view.getInt32(4);
  return { hi, lo };
};
const _M0MP311moonbitlang4core6double6Double8mod__ffi = (a, b) => (a % b);
function $i32_reinterpret_f32(a) {
  $reinterpret_view.setFloat32(0, a, true);
  return $reinterpret_view.getInt32(0, true);
}
const $64$mizchi$47$kagura$47$camera3d$46$ProjectionMode$Perspective = { $tag: 0, $name: "Perspective" };
function $64$mizchi$47$kagura$47$camera3d$46$ProjectionMode$Orthographic(param0, param1, param2, param3) {
  this._0 = param0;
  this._1 = param1;
  this._2 = param2;
  this._3 = param3;
}
$64$mizchi$47$kagura$47$camera3d$46$ProjectionMode$Orthographic.prototype.$tag = 1;
$64$mizchi$47$kagura$47$camera3d$46$ProjectionMode$Orthographic.prototype.$name = "Orthographic";
function Result$Err$1$(param0) {
  this._0 = param0;
}
Result$Err$1$.prototype.$tag = 0;
Result$Err$1$.prototype.$name = "Err";
function Result$Ok$1$(param0) {
  this._0 = param0;
}
Result$Ok$1$.prototype.$tag = 1;
Result$Ok$1$.prototype.$name = "Ok";
function Result$Err$2$(param0) {
  this._0 = param0;
}
Result$Err$2$.prototype.$tag = 0;
Result$Err$2$.prototype.$name = "Err";
function Result$Ok$2$(param0) {
  this._0 = param0;
}
Result$Ok$2$.prototype.$tag = 1;
Result$Ok$2$.prototype.$name = "Ok";
const $1L = { hi: 0, lo: 1 };
const $2047L = { hi: 0, lo: 2047 };
const $4503599627370495L = { hi: 1048575, lo: -1 };
const $0L = { hi: 0, lo: 0 };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Copy = { $tag: 0, $name: "Copy" };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Alpha = { $tag: 1, $name: "Alpha" };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Add = { $tag: 2, $name: "Add" };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Multiply = { $tag: 3, $name: "Multiply" };
function $64$mizchi$47$kagura$47$gfx$46$BlendMode$Custom(param0) {
  this._0 = param0;
}
$64$mizchi$47$kagura$47$gfx$46$BlendMode$Custom.prototype.$tag = 4;
$64$mizchi$47$kagura$47$gfx$46$BlendMode$Custom.prototype.$name = "Custom";
const Option$None$3$ = { $tag: 0, $name: "None" };
function Option$Some$3$(param0) {
  this._0 = param0;
}
Option$Some$3$.prototype.$tag = 1;
Option$Some$3$.prototype.$name = "Some";
function Result$Err$4$(param0) {
  this._0 = param0;
}
Result$Err$4$.prototype.$tag = 0;
Result$Err$4$.prototype.$name = "Err";
function Result$Ok$4$(param0) {
  this._0 = param0;
}
Result$Ok$4$.prototype.$tag = 1;
Result$Ok$4$.prototype.$name = "Ok";
function Result$Err$5$(param0) {
  this._0 = param0;
}
Result$Err$5$.prototype.$tag = 0;
Result$Err$5$.prototype.$name = "Err";
function Result$Ok$5$(param0) {
  this._0 = param0;
}
Result$Ok$5$.prototype.$tag = 1;
Result$Ok$5$.prototype.$name = "Ok";
const _M0FP36mizchi6kagura6engine29js__request__animation__frame = (f) => { requestAnimationFrame(() => f()); };
const _M0FP36mizchi6kagura6engine20js__on__beforeunload = (f) => { window.addEventListener("beforeunload", () => f()); };
const _M0FP36mizchi6kagura6engine20js__performance__now = () => (globalThis.performance?.now?.() ?? Date.now());
function Option$Some$6$(param0) {
  this._0 = param0;
}
Option$Some$6$.prototype.$tag = 1;
Option$Some$6$.prototype.$name = "Some";
const Option$None$7$ = { $tag: 0, $name: "None" };
function Option$Some$7$(param0) {
  this._0 = param0;
}
Option$Some$7$.prototype.$tag = 1;
Option$Some$7$.prototype.$name = "Some";
const Option$None$8$ = { $tag: 0, $name: "None" };
function Option$Some$8$(param0) {
  this._0 = param0;
}
Option$Some$8$.prototype.$tag = 1;
Option$Some$8$.prototype.$name = "Some";
const Option$None$9$ = { $tag: 0, $name: "None" };
function Option$Some$9$(param0) {
  this._0 = param0;
}
Option$Some$9$.prototype.$tag = 1;
Option$Some$9$.prototype.$name = "Some";
const Option$None$10$ = { $tag: 0, $name: "None" };
function Option$Some$10$(param0) {
  this._0 = param0;
}
Option$Some$10$.prototype.$tag = 1;
Option$Some$10$.prototype.$name = "Some";
const Option$None$11$ = { $tag: 0, $name: "None" };
function Option$Some$11$(param0) {
  this._0 = param0;
}
Option$Some$11$.prototype.$tag = 1;
Option$Some$11$.prototype.$name = "Some";
const Option$None$12$ = { $tag: 0, $name: "None" };
function Option$Some$12$(param0) {
  this._0 = param0;
}
Option$Some$12$.prototype.$tag = 1;
Option$Some$12$.prototype.$name = "Some";
const _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger13write__string, method_1: _M0IP016_24default__implP311moonbitlang4core7builtin6Logger16write__substringGRP311moonbitlang4core7builtin13StringBuilderE, method_2: _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__view, method_3: _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__char };
function _M0FP15Error10to__string(_e) {
  if (_e.$tag === 0) {
    return _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin17CreatingViewErrorE(_e);
  } else {
    return _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin17CreatingViewErrorE(_e);
  }
}
const _M0FP311moonbitlang4core5float10min__value = $f32_reinterpret_i32(-8388609);
const _M0FP311moonbitlang4core5float10max__value = $f32_reinterpret_i32(2139095039);
const _M0FP311moonbitlang4core5float14not__a__number = $f32_reinterpret_i32(2143289344);
const _M0FP36mizchi6kagura6mesh3d16vertex3d__stride = 8;
const _M0FP36mizchi6kagura6draw3d10max__bones = 64;
const _M0FP26mizchi14skeletal__anim9screen__h = 480;
const _M0FP26mizchi14skeletal__anim9screen__w = 640;
const _M0FP26mizchi14skeletal__anim10num__bones = 6;
const _M0FP26mizchi14skeletal__anim14anim__duration = 4;
const _M0FP26mizchi14skeletal__anim14num__keyframes = 32;
const _M0FP26mizchi14skeletal__anim12bone__length = 0.5;
const _M0FP26mizchi14skeletal__anim16tentacle__radius = 0.12;
const _M0FP311moonbitlang4core7builtin4seed = _M0FP311moonbitlang4core7builtin12random__seed();
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f664 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FP36mizchi6kagura8platform18web__canvas__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura8platform14WebCanvasHooksE(_M0FP36mizchi6kagura8platform27default__web__canvas__hooks());
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MP311moonbitlang4core3ref3Ref3newGWEdE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx19NativeGraphicsHooksE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
const _M0FP36mizchi6kagura3gfx20web__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx16WebGraphicsHooksE(_M0FP36mizchi6kagura3gfx29default__web__graphics__hooks());
function _M0FP311moonbitlang4core5abort5abortGRP311moonbitlang4core7builtin12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(msg) {
  return $panic();
}
function _M0FP311moonbitlang4core5abort5abortGUiRP36mizchi6kagura7scene3d8Object3DEE(msg) {
  return $panic();
}
function _M0FP311moonbitlang4core5abort5abortGuE(msg) {
  $panic();
}
function _M0FP311moonbitlang4core5abort5abortGRP311moonbitlang4core6string10StringViewE(msg) {
  return $panic();
}
function _M0IP311moonbitlang4core7builtin17CreatingViewErrorP311moonbitlang4core7builtin4Show6output(_x_5142, _x_5143) {
  if (_x_5142.$tag === 1) {
    _x_5143.method_table.method_0(_x_5143.self, "IndexOutOfBounds");
    return;
  } else {
    _x_5143.method_table.method_0(_x_5143.self, "InvalidIndex");
    return;
  }
}
function _M0FP311moonbitlang4core7builtin4rotl(x, r) {
  return x << r | (x >>> (32 - r | 0) | 0);
}
function _M0MP311moonbitlang4core7builtin6Hasher8consume4(self, input) {
  self.acc = Math.imul(_M0FP311moonbitlang4core7builtin4rotl((self.acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0, 17), 668265263) | 0;
}
function _M0MP311moonbitlang4core7builtin6Hasher13combine__uint(self, value) {
  self.acc = (self.acc >>> 0) + (4 >>> 0) | 0;
  _M0MP311moonbitlang4core7builtin6Hasher8consume4(self, value);
}
function _M0FP311moonbitlang4core7builtin5abortGRP311moonbitlang4core7builtin12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(string, loc) {
  return _M0FP311moonbitlang4core5abort5abortGRP311moonbitlang4core7builtin12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(`${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(string)}\n  at ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(loc)}\n`);
}
function _M0FP311moonbitlang4core7builtin5abortGUiRP36mizchi6kagura7scene3d8Object3DEE(string, loc) {
  return _M0FP311moonbitlang4core5abort5abortGUiRP36mizchi6kagura7scene3d8Object3DEE(`${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(string)}\n  at ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(loc)}\n`);
}
function _M0FP311moonbitlang4core7builtin5abortGuE(string, loc) {
  _M0FP311moonbitlang4core5abort5abortGuE(`${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(string)}\n  at ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(loc)}\n`);
}
function _M0FP311moonbitlang4core7builtin5abortGRP311moonbitlang4core6string10StringViewE(string, loc) {
  return _M0FP311moonbitlang4core5abort5abortGRP311moonbitlang4core6string10StringViewE(`${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(string)}\n  at ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(loc)}\n`);
}
function _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(size_hint) {
  return { val: "" };
}
function _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__char(self, ch) {
  const _bind = self;
  _bind.val = `${_bind.val}${String.fromCodePoint(ch)}`;
}
function _M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__leGkE(self, 57343);
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura10skeleton3d4BoneE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura11transform3d11Transform3DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGdE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGiE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGUdddEE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura7scene3d8Object3DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core7builtin13SourceLocRepr5parse(repr) {
  const _bind = { str: repr, start: 0, end: repr.length };
  const _data = _M0MP311moonbitlang4core6string10StringView4data(_bind);
  const _start = _M0MP311moonbitlang4core6string10StringView13start__offset(_bind);
  const _end = _start + _M0MP311moonbitlang4core6string10StringView6length(_bind) | 0;
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
      const next_char = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
      _cursor = _cursor + 1 | 0;
      if (next_char === 64) {
        _L$2: while (true) {
          tag_0 = _cursor;
          if (_cursor < _end) {
            const next_char$2 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char$2 === 58) {
              if (_cursor < _end) {
                _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
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
                              const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$3 < 58) {
                                if (next_char$3 < 48) {
                                  break _L$6;
                                } else {
                                  tag_1 = _cursor;
                                  tag_2_1 = tag_2;
                                  tag_2 = _cursor;
                                  tag_3 = _cursor;
                                  if (_cursor < _end) {
                                    _L$7: {
                                      const next_char$4 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                                      _cursor = _cursor + 1 | 0;
                                      if (next_char$4 < 48) {
                                        if (next_char$4 === 45) {
                                          break _L$4;
                                        } else {
                                          break _L$7;
                                        }
                                      } else {
                                        if (next_char$4 > 57) {
                                          if (next_char$4 < 59) {
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
                                if (next_char$3 > 58) {
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
                              const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$3 < 58) {
                                if (next_char$3 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$3 > 58) {
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
                            const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                            _cursor = _cursor + 1 | 0;
                            if (next_char$3 === 58) {
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
                              const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$3 < 58) {
                                if (next_char$3 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 4;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$3 > 58) {
                                  break _L$6;
                                } else {
                                  tag_1_2 = tag_1_1;
                                  tag_1_1 = tag_1;
                                  tag_1 = _cursor;
                                  if (_cursor < _end) {
                                    _L$7: {
                                      const next_char$4 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                                      _cursor = _cursor + 1 | 0;
                                      if (next_char$4 < 58) {
                                        if (next_char$4 < 48) {
                                          break _L$7;
                                        } else {
                                          tag_1 = _cursor;
                                          tag_2_1 = tag_2;
                                          tag_2 = _cursor;
                                          if (_cursor < _end) {
                                            _L$8: {
                                              const next_char$5 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                                              _cursor = _cursor + 1 | 0;
                                              if (next_char$5 < 58) {
                                                if (next_char$5 < 48) {
                                                  break _L$8;
                                                } else {
                                                  _tmp = 5;
                                                  continue _L$3;
                                                }
                                              } else {
                                                if (next_char$5 > 58) {
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
                                        if (next_char$4 > 58) {
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
                              const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$3 < 58) {
                                if (next_char$3 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 5;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$3 > 58) {
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
                              const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$3 < 48) {
                                if (next_char$3 === 45) {
                                  break _L$4;
                                } else {
                                  break _L$6;
                                }
                              } else {
                                if (next_char$3 > 57) {
                                  if (next_char$3 < 59) {
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
                              const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$3 < 58) {
                                if (next_char$3 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$3 > 58) {
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
                      const next_char$3 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                      _cursor = _cursor + 1 | 0;
                      if (next_char$3 < 58) {
                        if (next_char$3 < 48) {
                          break _L$5;
                        } else {
                          _tmp = 4;
                          continue;
                        }
                      } else {
                        if (next_char$3 > 58) {
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
    const start_line = _M0MP311moonbitlang4core6string6String4view(_data, match_tag_saver_1 + 1 | 0, match_tag_saver_2);
    const start_column = _M0MP311moonbitlang4core6string6String4view(_data, match_tag_saver_2 + 1 | 0, match_tag_saver_3);
    const pkg = _M0MP311moonbitlang4core6string6String4view(_data, _start + 1 | 0, match_tag_saver_0);
    const filename = _M0MP311moonbitlang4core6string6String4view(_data, match_tag_saver_0 + 1 | 0, match_tag_saver_1);
    const end_line = _M0MP311moonbitlang4core6string6String4view(_data, match_tag_saver_3 + 1 | 0, match_tag_saver_4);
    const end_column = _M0MP311moonbitlang4core6string6String4view(_data, match_tag_saver_4 + 1 | 0, match_end);
    return { pkg: pkg, filename: filename, start_line: start_line, start_column: start_column, end_line: end_line, end_column: end_column };
  } else {
    return $panic();
  }
}
function _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger13write__string(self, str) {
  const _bind = self;
  _bind.val = `${_bind.val}${str}`;
}
function _M0MP311moonbitlang4core7builtin7MyInt647to__int(self) {
  return self.lo;
}
function _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0MP311moonbitlang4core7builtin6Hasher12combine__int(self, value) {
  _M0MP311moonbitlang4core7builtin6Hasher13combine__uint(self, value);
}
function _M0MP311moonbitlang4core7builtin6Hasher7combineGiE(self, value) {
  _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Hash13hash__combine(value, self);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGRP26mizchi5audio10VoiceStateE(x, y) {
  return !_M0IP26mizchi5audio10VoiceStateP311moonbitlang4core7builtin2Eq5equal(x, y);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGlE(x, y) {
  return !_M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(x, y);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__leGkE(x, y) {
  return _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__geGkE(x, y) {
  return _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(x, y) >= 0;
}
function _M0MP311moonbitlang4core7builtin6Hasher9avalanche(self) {
  let acc = self.acc;
  acc = acc ^ (acc >>> 15 | 0);
  acc = Math.imul(acc, -2048144777) | 0;
  acc = acc ^ (acc >>> 13 | 0);
  acc = Math.imul(acc, -1028477379) | 0;
  acc = acc ^ (acc >>> 16 | 0);
  return acc;
}
function _M0MP311moonbitlang4core7builtin6Hasher8finalize(self) {
  return _M0MP311moonbitlang4core7builtin6Hasher9avalanche(self);
}
function _M0MP311moonbitlang4core7builtin6Hasher11new_2einner(seed) {
  return { acc: (seed >>> 0) + (374761393 >>> 0) | 0 };
}
function _M0MP311moonbitlang4core7builtin6Hasher3new(seed$46$opt) {
  let seed;
  if (seed$46$opt === undefined) {
    seed = _M0FP311moonbitlang4core7builtin4seed;
  } else {
    const _Some = seed$46$opt;
    seed = _Some;
  }
  return _M0MP311moonbitlang4core7builtin6Hasher11new_2einner(seed);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGiE(self) {
  const h = _M0MP311moonbitlang4core7builtin6Hasher3new(undefined);
  _M0MP311moonbitlang4core7builtin6Hasher7combineGiE(h, self);
  return _M0MP311moonbitlang4core7builtin6Hasher8finalize(h);
}
function _M0MP311moonbitlang4core6string6String11sub_2einner(self, start, end) {
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
    if (start$2 < len && _M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(self.charCodeAt(start$2))) {
      return new Result$Err$0$(Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$InvalidIndex);
    }
    if (end$2 < len && _M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      return new Result$Err$0$(Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$InvalidIndex);
    }
    return new Result$Ok$0$({ str: self, start: start$2, end: end$2 });
  } else {
    return new Result$Err$0$(Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$IndexOutOfBounds);
  }
}
function _M0IP016_24default__implP311moonbitlang4core7builtin6Logger16write__substringGRP311moonbitlang4core7builtin13StringBuilderE(self, value, start, len) {
  let _tmp;
  let _try_err;
  _L: {
    _L$2: {
      const _bind = _M0MP311moonbitlang4core6string6String11sub_2einner(value, start, start + len | 0);
      if (_bind.$tag === 1) {
        const _ok = _bind;
        _tmp = _ok._0;
      } else {
        const _err = _bind;
        _try_err = _err._0;
        break _L$2;
      }
      break _L;
    }
    _tmp = $panic();
  }
  _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__view(self, _tmp);
}
function _M0MP311moonbitlang4core6string10StringView4data(self) {
  return self.str;
}
function _M0MP311moonbitlang4core6string10StringView6length(self) {
  return self.end - self.start | 0;
}
function _M0MP311moonbitlang4core6string10StringView13start__offset(self) {
  return self.start;
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core5error5ErrorP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core7builtin9SourceLocP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin17CreatingViewErrorE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core7builtin17CreatingViewErrorP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0MP311moonbitlang4core3int3Int18to__string_2einner(self, radix) {
  return _M0FP311moonbitlang4core7builtin19int__to__string__js(self, radix);
}
function _M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MP311moonbitlang4core6string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? { str: self, start: start_offset, end: end_offset$2 } : _M0FP311moonbitlang4core7builtin5abortGRP311moonbitlang4core6string10StringViewE("Invalid index for View", "@moonbitlang/core/builtin:stringview.mbt:399:5-399:36");
}
function _M0MP311moonbitlang4core6string6String4view(self, start_offset$46$opt, end_offset) {
  let start_offset;
  if (start_offset$46$opt === undefined) {
    start_offset = 0;
  } else {
    const _Some = start_offset$46$opt;
    start_offset = _Some;
  }
  return _M0MP311moonbitlang4core6string6String12view_2einner(self, start_offset, end_offset);
}
function _M0MP311moonbitlang4core5array9ArrayView6lengthGUiRP36mizchi6kagura11animation3d8NodePoseEE(self) {
  return self.end - self.start | 0;
}
function _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__view(self, str) {
  const _bind = self;
  _bind.val = `${_bind.val}${_M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(str)}`;
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura7scene3d8Object3DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11transform3d11Transform3DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGiE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura10skeleton3d4BoneE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura6math3d4Mat4E(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGdE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11animation3d11AnimChannelE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9inpututil16KeyDurationEntryE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9inpututil24MouseButtonDurationEntryE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9inpututil18TouchDurationEntryE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11animation3d8NodePoseE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi5audio5VoiceE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGUiRP36mizchi6kagura7scene3d8Object3DEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0MP311moonbitlang4core3int3Int18to__string_2einner(self, 10));
}
function _M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(self) {
  return self;
}
function _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGiRP36mizchi6kagura11animation3d8NodePoseEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(self) {
  return self.end - self.start | 0;
}
function _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(self, index) {
  if (index >= 0 && index < (self.end - self.start | 0)) {
    const _tmp = self.buf;
    const _tmp$2 = self.start + index | 0;
    $bound_check(_tmp, _tmp$2);
    return _tmp[_tmp$2];
  } else {
    return _M0FP311moonbitlang4core7builtin5abortGUiRP36mizchi6kagura7scene3d8Object3DEE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(self.end - self.start | 0)} but the index is ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:mutarrayview.mbt:118:5-120:6");
  }
}
function _M0MP311moonbitlang4core5array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(self, index, value) {
  if (index >= 0 && index < (self.end - self.start | 0)) {
    const _tmp = self.buf;
    const _tmp$2 = self.start + index | 0;
    $bound_check(_tmp, _tmp$2);
    _tmp[_tmp$2] = value;
    return;
  } else {
    _M0FP311moonbitlang4core7builtin5abortGuE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(self.end - self.start | 0)} but the index is ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:mutarrayview.mbt:182:5-184:6");
    return;
  }
}
function _M0MP311moonbitlang4core5array5Array17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(self, start, end) {
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
    const _bind = self;
    const _bind$2 = end$2 - start$2 | 0;
    return { buf: _bind, start: start$2, end: start$2 + _bind$2 | 0 };
  } else {
    return _M0FP311moonbitlang4core7builtin5abortGRP311moonbitlang4core7builtin12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE("View index out of bounds", "@moonbitlang/core/builtin:mutarrayview.mbt:258:5-258:38");
  }
}
function _M0MP311moonbitlang4core5array12MutArrayView17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(self, start, end) {
  const len = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(self);
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
    const _bind = self.buf;
    const _bind$2 = self.start + start$2 | 0;
    const _bind$3 = end$2 - start$2 | 0;
    return { buf: _bind, start: _bind$2, end: _bind$2 + _bind$3 | 0 };
  } else {
    return _M0FP311moonbitlang4core7builtin5abortGRP311moonbitlang4core7builtin12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE("View index out of bounds", "@moonbitlang/core/builtin:mutarrayview.mbt:307:5-307:38");
  }
}
function _M0MP311moonbitlang4core5array5Array4makeGRP36mizchi6kagura6math3d4Mat4E(len, elem) {
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
function _M0MP311moonbitlang4core5array5Array4makeGdE(len, elem) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura11transform3d11Transform3DE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura6math3d4Mat4E(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGdE(self, index, value) {
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
function _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity) {
  if (16 === 0) {
    $panic();
  }
  return (Math.imul(capacity, 13) | 0) / 16 | 0;
}
function _M0MP311moonbitlang4core3int3Int20next__power__of__two(self) {
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
function _M0MP311moonbitlang4core7builtin3Map11new_2einnerGiRP36mizchi6kagura11animation3d8NodePoseE(capacity) {
  const capacity$2 = _M0MP311moonbitlang4core3int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return { entries: _bind$3, size: 0, capacity: capacity$2, capacity_mask: _bind, grow_at: _bind$2, head: _bind$4, tail: -1 };
}
function _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGiRP36mizchi6kagura11animation3d8NodePoseE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGiRP36mizchi6kagura11animation3d8NodePoseEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MP311moonbitlang4core7builtin3Map10set__entryGiRP36mizchi6kagura11animation3d8NodePoseE(self, entry, new_idx) {
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
function _M0MP311moonbitlang4core7builtin3Map10push__awayGiRP36mizchi6kagura11animation3d8NodePoseE(self, idx, entry) {
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
      _M0MP311moonbitlang4core7builtin3Map10set__entryGiRP36mizchi6kagura11animation3d8NodePoseE(self, entry$2, idx$2);
      break;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MP311moonbitlang4core7builtin3Map10set__entryGiRP36mizchi6kagura11animation3d8NodePoseE(self, entry$2, idx$2);
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
function _M0MP311moonbitlang4core7builtin3Map15set__with__hashGiRP36mizchi6kagura11animation3d8NodePoseE(self, key, value, hash) {
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
        _M0MP311moonbitlang4core7builtin3Map4growGiRP36mizchi6kagura11animation3d8NodePoseE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
      _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGiRP36mizchi6kagura11animation3d8NodePoseE(self, idx, entry);
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
          _M0MP311moonbitlang4core7builtin3Map4growGiRP36mizchi6kagura11animation3d8NodePoseE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MP311moonbitlang4core7builtin3Map10push__awayGiRP36mizchi6kagura11animation3d8NodePoseE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
        _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGiRP36mizchi6kagura11animation3d8NodePoseE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map4growGiRP36mizchi6kagura11animation3d8NodePoseE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FP311moonbitlang4core7builtin21calc__grow__threshold(self.capacity);
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
      _M0MP311moonbitlang4core7builtin3Map15set__with__hashGiRP36mizchi6kagura11animation3d8NodePoseE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map3setGiRP36mizchi6kagura11animation3d8NodePoseE(self, key, value) {
  _M0MP311moonbitlang4core7builtin3Map15set__with__hashGiRP36mizchi6kagura11animation3d8NodePoseE(self, key, value, _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGiE(key));
}
function _M0MP311moonbitlang4core7builtin3Map11from__arrayGiRP36mizchi6kagura11animation3d8NodePoseE(arr) {
  const length = _M0MP311moonbitlang4core5array9ArrayView6lengthGUiRP36mizchi6kagura11animation3d8NodePoseEE(arr);
  let capacity = _M0MP311moonbitlang4core3int3Int20next__power__of__two(length);
  if (length > _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MP311moonbitlang4core7builtin3Map11new_2einnerGiRP36mizchi6kagura11animation3d8NodePoseE(capacity);
  const _len = _M0MP311moonbitlang4core5array9ArrayView6lengthGUiRP36mizchi6kagura11animation3d8NodePoseEE(arr);
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const e = arr.buf[arr.start + _i | 0];
      _M0MP311moonbitlang4core7builtin3Map3setGiRP36mizchi6kagura11animation3d8NodePoseE(m, e._0, e._1);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MP311moonbitlang4core7builtin3Map3getGiRP36mizchi6kagura11animation3d8NodePoseE(self, key) {
  const hash = _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGiE(key);
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
function _M0MP311moonbitlang4core7builtin3Map4eachGiRP36mizchi6kagura11animation3d8NodePoseE(self, f) {
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
function _M0MP311moonbitlang4core5array10FixedArray12fill_2einnerGfE(self, value, start, end) {
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
function _M0MP311moonbitlang4core7builtin7MyInt6414extend__i32__u(value) {
  return { hi: 0, lo: value };
}
function _M0MP311moonbitlang4core6uint646UInt6412extend__uint(value) {
  return _M0MP311moonbitlang4core7builtin7MyInt6414extend__i32__u(value);
}
function _M0MP311moonbitlang4core4uint4UInt10to__uint64(self) {
  return _M0MP311moonbitlang4core6uint646UInt6412extend__uint(self);
}
function _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(self, idx) {
  return self.charCodeAt(idx);
}
function _M0IP311moonbitlang4core7builtin7MyInt64P311moonbitlang4core7builtin3Mul3mul(self, other) {
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
  return { hi: c48$5 << 16 | c32$8, lo: c16$5 << 16 | c00$2 };
}
function _M0MP311moonbitlang4core7builtin7MyInt644land(self, other) {
  return { hi: self.hi & other.hi, lo: self.lo & other.lo };
}
function _M0MP311moonbitlang4core7builtin7MyInt643lsr(self, shift) {
  const shift$2 = shift & 63;
  return shift$2 === 0 ? self : shift$2 < 32 ? { hi: self.hi >>> shift$2 | 0, lo: self.lo >>> shift$2 | 0 | self.hi << (32 - shift$2 | 0) } : { hi: 0, lo: self.hi >>> (shift$2 - 32 | 0) | 0 };
}
function _M0IP311moonbitlang4core7builtin7MyInt64P311moonbitlang4core7builtin2Eq5equal(self, other) {
  return self.hi === other.hi && self.lo === other.lo;
}
function _M0MP311moonbitlang4core7builtin7MyInt648to__uint(self) {
  return self.lo;
}
function _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin6BitAnd4land(self, other) {
  return _M0MP311moonbitlang4core7builtin7MyInt644land(self, other);
}
function _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(self, other) {
  return _M0IP311moonbitlang4core7builtin7MyInt64P311moonbitlang4core7builtin2Eq5equal(self, other);
}
function _M0MP311moonbitlang4core5int645Int647to__int(self) {
  return _M0MP311moonbitlang4core7builtin7MyInt647to__int(self);
}
function _M0MP311moonbitlang4core6double6Double22reinterpret__as__int64(self) {
  return _M0MP311moonbitlang4core7builtin7MyInt6419reinterpret__double(self);
}
function _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Mul3mul(self, other) {
  return _M0IP311moonbitlang4core7builtin7MyInt64P311moonbitlang4core7builtin3Mul3mul(self, other);
}
function _M0MP311moonbitlang4core6uint646UInt648to__uint(self) {
  return _M0MP311moonbitlang4core7builtin7MyInt648to__uint(self);
}
function _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin6BitAnd4land(self, other) {
  return _M0MP311moonbitlang4core7builtin7MyInt644land(self, other);
}
function _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(self, shift) {
  return _M0MP311moonbitlang4core7builtin7MyInt643lsr(self, shift);
}
function _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Hash13hash__combine(self, hasher) {
  _M0MP311moonbitlang4core7builtin6Hasher12combine__int(hasher, self);
}
function _M0MP311moonbitlang4core6double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0IP311moonbitlang4core6double6DoubleP311moonbitlang4core7builtin3Mod3mod(self, other) {
  return _M0MP311moonbitlang4core6double6Double8mod__ffi(self, other);
}
function _M0FP311moonbitlang4core7builtin7printlnGsE(input) {
  console.log(_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(input));
}
function _M0IP311moonbitlang4core7builtin13SourceLocReprP311moonbitlang4core7builtin4Show6output(self, logger) {
  const pkg = self.pkg;
  const _data = _M0MP311moonbitlang4core6string10StringView4data(pkg);
  const _start = _M0MP311moonbitlang4core6string10StringView13start__offset(pkg);
  const _end = _start + _M0MP311moonbitlang4core6string10StringView6length(pkg) | 0;
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
          const next_char = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
          _cursor = _cursor + 1 | 0;
          if (next_char === 47) {
            _L$4: while (true) {
              tag_0 = _cursor;
              if (_cursor < _end) {
                const next_char$2 = _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
                _cursor = _cursor + 1 | 0;
                if (next_char$2 === 47) {
                  while (true) {
                    if (_cursor < _end) {
                      _M0MP311moonbitlang4core6string6String20unsafe__charcode__at(_data, _cursor);
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
      const package_name = _M0MP311moonbitlang4core6string6String4view(_data, match_tag_saver_0 + 1 | 0, match_end);
      const module_name = _M0MP311moonbitlang4core6string6String4view(_data, _start, match_tag_saver_0);
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
function _M0IP311moonbitlang4core7builtin9SourceLocP311moonbitlang4core7builtin4Show6output(self, logger) {
  _M0IP311moonbitlang4core7builtin13SourceLocReprP311moonbitlang4core7builtin4Show6output(_M0MP311moonbitlang4core7builtin13SourceLocRepr5parse(self), logger);
}
function _M0FP311moonbitlang4core7builtin7minimum(x, y) {
  return x > y ? y : x;
}
function _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, j) {
  const temp = _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i);
  _M0MP311moonbitlang4core5array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j));
  _M0MP311moonbitlang4core5array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, temp);
}
function _M0MP311moonbitlang4core5array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, start, end) {
  return _M0MP311moonbitlang4core5array12MutArrayView17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, start, end);
}
function _M0MP311moonbitlang4core5array12MutArrayView14rev__in__placeGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) {
  const len = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  if (2 === 0) {
    $panic();
  }
  const mid_len = len / 2 | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < mid_len) {
      const j = (len - i | 0) - 1 | 0;
      const temp = _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i);
      _M0MP311moonbitlang4core5array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j));
      _M0MP311moonbitlang4core5array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, temp);
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP311moonbitlang4core7builtin17fixed__get__limit(len) {
  let len$2 = len;
  let limit = 0;
  while (true) {
    if (len$2 > 0) {
      if (2 === 0) {
        $panic();
      }
      len$2 = len$2 / 2 | 0;
      limit = limit + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return limit;
}
function _M0FP311moonbitlang4core7builtin23fixed__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  const _end540 = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < _end540) {
      let _tmp$2 = i;
      while (true) {
        const j = _tmp$2;
        if (j > 0 && cmp(_M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j - 1 | 0), _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j)) > 0) {
          _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, j - 1 | 0);
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
function _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__2_2f545(_env, a, b) {
  const cmp = _env._2;
  const swaps = _env._1;
  const arr = _env._0;
  if (cmp(_M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, a), _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, b)) > 0) {
    _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, a, b);
    swaps.val = swaps.val + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__3_2f546(_env, a, b, c) {
  _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__2_2f545(_env, a, b);
  _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__2_2f545(_env, b, c);
  _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__2_2f545(_env, a, b);
}
function _M0FP311moonbitlang4core7builtin24fixed__choose__pivot__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  const len = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  const swaps = { val: 0 };
  if (4 === 0) {
    $panic();
  }
  const b = Math.imul(len / 4 | 0, 2) | 0;
  if (len >= 8) {
    if (4 === 0) {
      $panic();
    }
    const a = Math.imul(len / 4 | 0, 1) | 0;
    if (4 === 0) {
      $panic();
    }
    const c = Math.imul(len / 4 | 0, 3) | 0;
    const _env = { _0: arr, _1: swaps, _2: cmp };
    if (len > 50) {
      _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__3_2f546(_env, a - 1 | 0, a, a + 1 | 0);
      _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__3_2f546(_env, b - 1 | 0, b, b + 1 | 0);
      _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__3_2f546(_env, c - 1 | 0, c, c + 1 | 0);
    }
    _M0FP311moonbitlang4core7builtin40fixed__choose__pivot__by_2esort__3_2f546(_env, a, b, c);
  }
  if (swaps.val === 12) {
    _M0MP311moonbitlang4core5array12MutArrayView14rev__in__placeGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
    return { _0: (len - b | 0) - 1 | 0, _1: true };
  } else {
    return { _0: b, _1: swaps.val === 0 };
  }
}
function _M0FP311moonbitlang4core7builtin21fixed__sift__down__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, index, cmp) {
  let index$2 = index;
  const len = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  let child = (Math.imul(index$2, 2) | 0) + 1 | 0;
  while (true) {
    if (child < len) {
      if ((child + 1 | 0) < len && cmp(_M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, child), _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, child + 1 | 0)) < 0) {
        child = child + 1 | 0;
      }
      if (cmp(_M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, index$2), _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, child)) >= 0) {
        return undefined;
      }
      _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, index$2, child);
      index$2 = child;
      child = (Math.imul(index$2, 2) | 0) + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP311moonbitlang4core7builtin21fixed__heap__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  const len = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  if (2 === 0) {
    $panic();
  }
  let _tmp = (len / 2 | 0) - 1 | 0;
  while (true) {
    const i = _tmp;
    if (i >= 0) {
      _M0FP311moonbitlang4core7builtin21fixed__sift__down__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, cmp);
      _tmp = i - 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = len - 1 | 0;
  while (true) {
    const i = _tmp$2;
    if (i > 0) {
      _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, 0, i);
      _M0FP311moonbitlang4core7builtin21fixed__sift__down__byGUiRP36mizchi6kagura7scene3d8Object3DEE(_M0MP311moonbitlang4core5array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, 0, i), 0, cmp);
      _tmp$2 = i - 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP311moonbitlang4core7builtin20fixed__partition__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp, pivot_index) {
  _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, pivot_index, _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0);
  const pivot = _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0);
  let i = 0;
  let partitioned = true;
  const _end529 = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0;
  let _tmp = 0;
  while (true) {
    const j = _tmp;
    if (j < _end529) {
      if (cmp(_M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j), pivot) < 0) {
        if (i !== j) {
          _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, j);
          partitioned = false;
        }
        i = i + 1 | 0;
      }
      _tmp = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0);
  return { _0: i, _1: partitioned };
}
function _M0FP311moonbitlang4core7builtin28fixed__try__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  let tries = 0;
  const _end550 = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < _end550) {
      let sorted = true;
      let _tmp$2 = i;
      while (true) {
        const j = _tmp$2;
        if (j > 0 && cmp(_M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j - 1 | 0), _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j)) > 0) {
          sorted = false;
          _M0MP311moonbitlang4core5array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, j - 1 | 0);
          _tmp$2 = j - 1 | 0;
          continue;
        } else {
          break;
        }
      }
      if (!sorted) {
        tries = tries + 1 | 0;
        if (tries > 8) {
          return false;
        }
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return true;
}
function _M0FP311moonbitlang4core7builtin22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp, pred, limit) {
  let limit$2 = limit;
  let arr$2 = arr;
  let pred$2 = pred;
  let was_partitioned = true;
  let balanced = true;
  while (true) {
    const len = _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2);
    if (len <= 16) {
      if (len >= 2) {
        _M0FP311moonbitlang4core7builtin23fixed__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp);
      }
      return undefined;
    }
    if (limit$2 === 0) {
      _M0FP311moonbitlang4core7builtin21fixed__heap__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp);
      return undefined;
    }
    const _bind = _M0FP311moonbitlang4core7builtin24fixed__choose__pivot__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp);
    const _pivot_index = _bind._0;
    const _likely_sorted = _bind._1;
    if (was_partitioned && (balanced && _likely_sorted)) {
      if (_M0FP311moonbitlang4core7builtin28fixed__try__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp)) {
        return undefined;
      }
    }
    const _bind$2 = _M0FP311moonbitlang4core7builtin20fixed__partition__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp, _pivot_index);
    const _pivot = _bind$2._0;
    const _partitioned = _bind$2._1;
    was_partitioned = _partitioned;
    const _tmp = _M0FP311moonbitlang4core7builtin7minimum(_pivot, len - _pivot | 0);
    if (8 === 0) {
      $panic();
    }
    balanced = _tmp >= (len / 8 | 0);
    if (!balanced) {
      limit$2 = limit$2 - 1 | 0;
    }
    const _bind$3 = pred$2;
    if (_bind$3 === undefined) {
    } else {
      const _Some = _bind$3;
      const _pred = _Some;
      if (cmp(_pred, _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot)) === 0) {
        let i = _pivot;
        while (true) {
          if (i < len && cmp(_pred, _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, i)) === 0) {
            i = i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        arr$2 = _M0MP311moonbitlang4core5array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, i, len);
        continue;
      }
    }
    const left = _M0MP311moonbitlang4core5array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, 0, _pivot);
    const right = _M0MP311moonbitlang4core5array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot + 1 | 0, len);
    if (_M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(left) < _M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(right)) {
      _M0FP311moonbitlang4core7builtin22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(left, cmp, pred$2, limit$2);
      pred$2 = _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot);
      arr$2 = right;
    } else {
      _M0FP311moonbitlang4core7builtin22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(right, cmp, _M0MP311moonbitlang4core5array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot), limit$2);
      arr$2 = left;
    }
    continue;
  }
}
function _M0MP311moonbitlang4core5array12MutArrayView8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(self, cmp) {
  _M0FP311moonbitlang4core7builtin22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(self, cmp, undefined, _M0FP311moonbitlang4core7builtin17fixed__get__limit(_M0MP311moonbitlang4core5array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(self)));
}
function _M0MP311moonbitlang4core5array5Array8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(self, cmp) {
  _M0MP311moonbitlang4core5array12MutArrayView8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(_M0MP311moonbitlang4core5array5Array17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(self, 0, undefined), cmp);
}
function _M0MP311moonbitlang4core5array5Array6filterGRP26mizchi5audio5VoiceE(self, f) {
  const arr = [];
  const _len = self.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const v = self[_i];
      if (f(v)) {
        _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi5audio5VoiceE(arr, v);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MP311moonbitlang4core5array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, f) {
  const arr = [];
  const _len = self.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const v = self[_i];
      if (f(v)) {
        _M0MP311moonbitlang4core5array5Array4pushGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(arr, v);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MP311moonbitlang4core5float5Float7to__int(self) {
  return Math.fround(self !== self) ? 0 : Math.fround(self >= Math.fround(2147483647)) ? 2147483647 : Math.fround(self <= Math.fround(-2147483648)) ? -2147483648 : self | 0;
}
function _M0MP311moonbitlang4core5float5Float12is__neg__inf(self) {
  return Math.fround(self < _M0FP311moonbitlang4core5float10min__value);
}
function _M0MP311moonbitlang4core5float5Float12is__pos__inf(self) {
  return Math.fround(self > _M0FP311moonbitlang4core5float10max__value);
}
function _M0MP311moonbitlang4core5float5Float7is__inf(self) {
  return _M0MP311moonbitlang4core5float5Float12is__pos__inf(self) || _M0MP311moonbitlang4core5float5Float12is__neg__inf(self);
}
function _M0MP311moonbitlang4core5float5Float7is__nan(self) {
  return Math.fround(self !== self);
}
function _M0IP311moonbitlang4core5error5ErrorP311moonbitlang4core7builtin4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0FP15Error10to__string(self));
}
function _M0MP311moonbitlang4core3ref3Ref3newGiE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGdE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGWEdE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura8platform14WebCanvasHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx16WebGraphicsHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx19NativeGraphicsHooksE(x) {
  return { val: x };
}
function _M0FP311moonbitlang4core4math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FP311moonbitlang4core4math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0FP311moonbitlang4core4math3tan(_tmp) {
  return Math.tan(_tmp);
}
function _M0FP311moonbitlang4core4math4acos(_tmp) {
  return Math.acos(_tmp);
}
function _M0FP311moonbitlang4core4math4mulh(a, b) {
  const a$2 = _M0MP311moonbitlang4core4uint4UInt10to__uint64(a);
  const b$2 = _M0MP311moonbitlang4core4uint4UInt10to__uint64(b);
  const res = _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Mul3mul(a$2, b$2);
  return _M0MP311moonbitlang4core6uint646UInt648to__uint(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(res, 32));
}
function _M0FP311moonbitlang4core4math3mul(a, b) {
  const a$2 = _M0MP311moonbitlang4core4uint4UInt10to__uint64(a);
  const b$2 = _M0MP311moonbitlang4core4uint4UInt10to__uint64(b);
  const res = _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Mul3mul(a$2, b$2);
  return { _0: _M0MP311moonbitlang4core6uint646UInt648to__uint(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(res, 32)), _1: _M0MP311moonbitlang4core6uint646UInt648to__uint(res) };
}
function _M0FP311moonbitlang4core4math12trig__reduce(x, switch_over) {
  if (Math.fround(Math.fround(Math.abs(x)) <= switch_over)) {
    let j = Math.fround(0);
    let r = Math.fround(0);
    j = Math.fround(Math.fround(x * $f32_reinterpret_i32(1059256707)) + $f32_reinterpret_i32(1262485504));
    j = Math.fround($i32_reinterpret_f32(j) - 1262485504 | 0);
    r = Math.fround(x - Math.fround(j * $f32_reinterpret_i32(1070141312)));
    r = Math.fround(r - Math.fround(j * $f32_reinterpret_i32(926237760)));
    r = Math.fround(r - Math.fround(j * $f32_reinterpret_i32(741630234)));
    return { _0: r, _1: _M0MP311moonbitlang4core5float5Float7to__int(j) };
  }
  const xispos = Math.fround(x > Math.fround(0));
  let exp = ($i32_reinterpret_f32(x) >> 23 & 255) - 126 | 0;
  const ix = ($i32_reinterpret_f32(x) & 8388607) << 8 | -2147483648;
  const ind = exp >> 5;
  exp = exp & 31;
  let hi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f664, ind);
  let mi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f664, ind + 1 | 0);
  let lo = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f664, ind + 2 | 0);
  const tp = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f664, ind + 3 | 0);
  if (exp > 0) {
    hi = hi << exp | (mi >>> (32 - exp | 0) | 0);
    mi = mi << exp | (lo >>> (32 - exp | 0) | 0);
    lo = lo << exp | (tp >>> (32 - exp | 0) | 0);
  }
  const _bind = _M0FP311moonbitlang4core4math3mul(ix, lo);
  const _h = _bind._0;
  const _l = _bind._1;
  const phi = (_h >>> 0) + ((_l >>> 0 < _l >>> 0 ? 1 : 0) >>> 0) | 0;
  const _bind$2 = _M0FP311moonbitlang4core4math3mul(ix, mi);
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
  phi$3 = _M0FP311moonbitlang4core4math4mulh(phi$3, -921707870);
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
function _M0FP311moonbitlang4core4math10sinf__poly(x) {
  const s = Math.fround(x * x);
  let r = $f32_reinterpret_i32(910184448);
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(961557638));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1007192257));
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(1042983595));
  const t = Math.fround(x * s);
  r = Math.fround(Math.fround(r * t) + x);
  return r;
}
function _M0FP311moonbitlang4core4math10cosf__poly(x) {
  const s = Math.fround(x * x);
  let r = $f32_reinterpret_i32(936198144);
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(985007997));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1026206376));
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(1056964608));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1065353216));
  return r;
}
function _M0FP311moonbitlang4core4math14sin__cos__core(x, q) {
  let r = (q & 1) !== 0 ? _M0FP311moonbitlang4core4math10cosf__poly(x) : _M0FP311moonbitlang4core4math10sinf__poly(x);
  if ((q & 2) !== 0) {
    r = -r;
  }
  return r;
}
function _M0FP311moonbitlang4core4math4sinf(x) {
  if (_M0MP311moonbitlang4core5float5Float7is__nan(x) || _M0MP311moonbitlang4core5float5Float7is__inf(x)) {
    return _M0FP311moonbitlang4core5float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return x;
  }
  const _bind = _M0FP311moonbitlang4core4math12trig__reduce(x, Math.fround(201.15625));
  const _x = _bind._0;
  const _q = _bind._1;
  return _M0FP311moonbitlang4core4math14sin__cos__core(_x, _q);
}
function _M0FP311moonbitlang4core4math4cosf(x) {
  if (_M0MP311moonbitlang4core5float5Float7is__nan(x) || _M0MP311moonbitlang4core5float5Float7is__inf(x)) {
    return _M0FP311moonbitlang4core5float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return Math.fround(1);
  }
  const _bind = _M0FP311moonbitlang4core4math12trig__reduce(x, Math.fround(142.90625));
  const _x = _bind._0;
  const _q = _bind._1;
  return _M0FP311moonbitlang4core4math14sin__cos__core(_x, _q + 1 | 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33new(x, y, z) {
  return { x: x, y: y, z: z };
}
function _M0MP36mizchi6kagura6math3d4Vec34zero() {
  return { x: 0, y: 0, z: 0 };
}
function _M0MP36mizchi6kagura6math3d4Vec33one() {
  return { x: 1, y: 1, z: 1 };
}
function _M0MP36mizchi6kagura6math3d4Vec37unit__y() {
  return { x: 0, y: 1, z: 0 };
}
function _M0MP36mizchi6kagura6math3d4Vec33add(self, other) {
  return { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z };
}
function _M0MP36mizchi6kagura6math3d4Vec33sub(self, other) {
  return { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z };
}
function _M0MP36mizchi6kagura6math3d4Vec35scale(self, s) {
  return { x: self.x * s, y: self.y * s, z: self.z * s };
}
function _M0MP36mizchi6kagura6math3d4Vec33dot(self, other) {
  return self.x * other.x + self.y * other.y + self.z * other.z;
}
function _M0MP36mizchi6kagura6math3d4Vec35cross(self, other) {
  return { x: self.y * other.z - self.z * other.y, y: self.z * other.x - self.x * other.z, z: self.x * other.y - self.y * other.x };
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
function _M0MP36mizchi6kagura6math3d4Vec34lerp(self, other, t) {
  return { x: self.x + (other.x - self.x) * t, y: self.y + (other.y - self.y) * t, z: self.z + (other.z - self.z) * t };
}
function _M0MP36mizchi6kagura6math3d4Vec43new(x, y, z, w) {
  return { x: x, y: y, z: z, w: w };
}
function _M0MP36mizchi6kagura6math3d4Mat48identity() {
  return { elements: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1] };
}
function _M0MP36mizchi6kagura6math3d4Mat44zero() {
  return { elements: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
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
  const _start210 = 0;
  const _end211 = 4;
  let _tmp = _start210;
  while (true) {
    const col = _tmp;
    if (col < _end211) {
      const _start215 = 0;
      const _end216 = 4;
      let _tmp$2 = _start215;
      while (true) {
        const row = _tmp$2;
        if (row < _end216) {
          const sum = { val: 0 };
          const _start221 = 0;
          const _end222 = 4;
          let _tmp$3 = _start221;
          while (true) {
            const k = _tmp$3;
            if (k < _end222) {
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
  const _start195 = 0;
  const _end196 = 4;
  let _tmp = _start195;
  while (true) {
    const row = _tmp;
    if (row < _end196) {
      const _start200 = 0;
      const _end201 = 4;
      let _tmp$2 = _start200;
      while (true) {
        const col = _tmp$2;
        if (col < _end201) {
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
  const f = 1 / _M0FP311moonbitlang4core4math3tan(fov_y_rad / 2);
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
  return { x: 0, y: 0, z: 0, w: 1 };
}
function _M0MP36mizchi6kagura6math3d10Quaternion3new(x, y, z, w) {
  return { x: x, y: y, z: z, w: w };
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
function _M0MP36mizchi6kagura6math3d10Quaternion6length(self) {
  return Math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w);
}
function _M0MP36mizchi6kagura6math3d10Quaternion9normalize(self) {
  const len = _M0MP36mizchi6kagura6math3d10Quaternion6length(self);
  if (len < 1e-12) {
    return _M0MP36mizchi6kagura6math3d10Quaternion8identity();
  } else {
    const inv = 1 / len;
    return { x: self.x * inv, y: self.y * inv, z: self.z * inv, w: self.w * inv };
  }
}
function _M0MP36mizchi6kagura6math3d10Quaternion5slerp(self, other, t) {
  const dot = { val: self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w };
  const bx = { val: other.x };
  const by = { val: other.y };
  const bz = { val: other.z };
  const bw = { val: other.w };
  if (dot.val < 0) {
    dot.val = -dot.val;
    bx.val = -bx.val;
    by.val = -by.val;
    bz.val = -bz.val;
    bw.val = -bw.val;
  }
  if (dot.val > 0.9995) {
    const rx = self.x + (bx.val - self.x) * t;
    const ry = self.y + (by.val - self.y) * t;
    const rz = self.z + (bz.val - self.z) * t;
    const rw = self.w + (bw.val - self.w) * t;
    return _M0MP36mizchi6kagura6math3d10Quaternion9normalize(_M0MP36mizchi6kagura6math3d10Quaternion3new(rx, ry, rz, rw));
  } else {
    const theta = _M0FP311moonbitlang4core4math4acos(dot.val);
    const sin_theta = _M0FP311moonbitlang4core4math3sin(theta);
    const s0 = _M0FP311moonbitlang4core4math3sin((1 - t) * theta) / sin_theta;
    const s1 = _M0FP311moonbitlang4core4math3sin(t * theta) / sin_theta;
    return { x: self.x * s0 + bx.val * s1, y: self.y * s0 + by.val * s1, z: self.z * s0 + bz.val * s1, w: self.w * s0 + bw.val * s1 };
  }
}
function _M0MP36mizchi6kagura11transform3d11Transform3D3new() {
  return { position: _M0MP36mizchi6kagura6math3d4Vec34zero(), rotation: _M0MP36mizchi6kagura6math3d10Quaternion8identity(), scale: _M0MP36mizchi6kagura6math3d4Vec33one() };
}
function _M0MP36mizchi6kagura11transform3d11Transform3D14from__position(pos) {
  return { position: pos, rotation: _M0MP36mizchi6kagura6math3d10Quaternion8identity(), scale: _M0MP36mizchi6kagura6math3d4Vec33one() };
}
function _M0MP36mizchi6kagura11transform3d11Transform3D16from__components(pos, rot, scale) {
  return { position: pos, rotation: rot, scale: scale };
}
function _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(self) {
  const t = _M0MP36mizchi6kagura6math3d4Mat411translation(self.position.x, self.position.y, self.position.z);
  const r = _M0MP36mizchi6kagura6math3d10Quaternion8to__mat4(self.rotation);
  const s = _M0MP36mizchi6kagura6math3d4Mat47scaling(self.scale.x, self.scale.y, self.scale.z);
  return _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP36mizchi6kagura6math3d4Mat48multiply(t, r), s);
}
function _M0MP36mizchi6kagura11transform3d11Transform3D14with__position(self, pos) {
  return { position: pos, rotation: self.rotation, scale: self.scale };
}
function _M0MP36mizchi6kagura11transform3d11Transform3D14with__rotation(self, rot) {
  return { position: self.position, rotation: rot, scale: self.scale };
}
function _M0MP36mizchi6kagura11transform3d11Transform3D11with__scale(self, s) {
  return { position: self.position, rotation: self.rotation, scale: s };
}
function _M0MP36mizchi6kagura11animation3d15AnimationPlayer3new(clip) {
  return { clip: clip, time: 0, playing: true, looping: true, speed: 1 };
}
function _M0MP36mizchi6kagura11animation3d15AnimationPlayer6update(self, dt) {
  if (!self.playing) {
    return undefined;
  }
  self.time = self.time + dt * self.speed;
  if (self.looping && self.clip.duration > 0) {
    self.time = _M0IP311moonbitlang4core6double6DoubleP311moonbitlang4core7builtin3Mod3mod(self.time, self.clip.duration);
    if (self.time < 0) {
      self.time = self.time + self.clip.duration;
      return;
    } else {
      return;
    }
  } else {
    if (self.time < 0) {
      self.time = 0;
    }
    if (self.time > self.clip.duration) {
      self.time = self.clip.duration;
      return;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura11animation3d14find__keyframe(times, time) {
  const len = times.length;
  if (len === 0) {
    return 0;
  }
  if (time <= _M0MP311moonbitlang4core5array5Array2atGdE(times, 0)) {
    return 0;
  }
  if (time >= _M0MP311moonbitlang4core5array5Array2atGdE(times, len - 1 | 0)) {
    return len - 1 | 0;
  }
  const lo = { val: 0 };
  const hi = { val: len - 1 | 0 };
  while (true) {
    if (lo.val < (hi.val - 1 | 0)) {
      if (2 === 0) {
        $panic();
      }
      const mid = (lo.val + hi.val | 0) / 2 | 0;
      if (_M0MP311moonbitlang4core5array5Array2atGdE(times, mid) <= time) {
        lo.val = mid;
      } else {
        hi.val = mid;
      }
      continue;
    } else {
      break;
    }
  }
  return lo.val;
}
function _M0FP36mizchi6kagura11animation3d12sample__quat(channel, time) {
  const len = channel.times.length;
  if (len === 0) {
    return _M0MP36mizchi6kagura6math3d10Quaternion8identity();
  }
  if (time <= _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, 0)) {
    return _M0MP36mizchi6kagura6math3d10Quaternion3new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 1), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 2), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 3));
  }
  if (time >= _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, len - 1 | 0)) {
    const i = Math.imul(len - 1 | 0, 4) | 0;
    return _M0MP36mizchi6kagura6math3d10Quaternion3new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i + 2 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i + 3 | 0));
  }
  const idx = _M0FP36mizchi6kagura11animation3d14find__keyframe(channel.times, time);
  const q0 = _M0MP36mizchi6kagura6math3d10Quaternion3new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, Math.imul(idx, 4) | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(idx, 4) | 0) + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(idx, 4) | 0) + 2 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(idx, 4) | 0) + 3 | 0));
  const _bind = channel.interpolation;
  if (_bind === 0) {
    return q0;
  } else {
    const next = idx + 1 | 0;
    if (next >= len) {
      return q0;
    }
    const t0 = _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, idx);
    const t1 = _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, next);
    const dt = t1 - t0;
    const t = dt > 1e-10 ? (time - t0) / dt : 0;
    const q1 = _M0MP36mizchi6kagura6math3d10Quaternion3new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, Math.imul(next, 4) | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(next, 4) | 0) + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(next, 4) | 0) + 2 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(next, 4) | 0) + 3 | 0));
    return _M0MP36mizchi6kagura6math3d10Quaternion5slerp(q0, q1, t);
  }
}
function _M0FP36mizchi6kagura11animation3d12sample__vec3(channel, time) {
  const len = channel.times.length;
  if (len === 0) {
    return _M0MP36mizchi6kagura6math3d4Vec34zero();
  }
  if (time <= _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, 0)) {
    return _M0MP36mizchi6kagura6math3d4Vec33new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 1), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, 2));
  }
  if (time >= _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, len - 1 | 0)) {
    const i = Math.imul(len - 1 | 0, 3) | 0;
    return _M0MP36mizchi6kagura6math3d4Vec33new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, i + 2 | 0));
  }
  const idx = _M0FP36mizchi6kagura11animation3d14find__keyframe(channel.times, time);
  const v0 = _M0MP36mizchi6kagura6math3d4Vec33new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, Math.imul(idx, 3) | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(idx, 3) | 0) + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(idx, 3) | 0) + 2 | 0));
  const _bind = channel.interpolation;
  if (_bind === 0) {
    return v0;
  } else {
    const next = idx + 1 | 0;
    if (next >= len) {
      return v0;
    }
    const t0 = _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, idx);
    const t1 = _M0MP311moonbitlang4core5array5Array2atGdE(channel.times, next);
    const dt = t1 - t0;
    const t = dt > 1e-10 ? (time - t0) / dt : 0;
    const v1 = _M0MP36mizchi6kagura6math3d4Vec33new(_M0MP311moonbitlang4core5array5Array2atGdE(channel.values, Math.imul(next, 3) | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(next, 3) | 0) + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(channel.values, (Math.imul(next, 3) | 0) + 2 | 0));
    return _M0MP36mizchi6kagura6math3d4Vec34lerp(v0, v1, t);
  }
}
function _M0MP36mizchi6kagura11animation3d15AnimationPlayer6sample(self) {
  const _bind = [];
  const pose_map = _M0MP311moonbitlang4core7builtin3Map11from__arrayGiRP36mizchi6kagura11animation3d8NodePoseE({ buf: _bind, start: 0, end: 0 });
  const _arr = self.clip.channels;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const channel = _arr[_i];
      const node_idx = channel.node_index;
      let pose;
      const _bind$2 = _M0MP311moonbitlang4core7builtin3Map3getGiRP36mizchi6kagura11animation3d8NodePoseE(pose_map, node_idx);
      if (_bind$2 === undefined) {
        const p = { node_index: node_idx, translation: undefined, rotation: undefined, scale: undefined };
        _M0MP311moonbitlang4core7builtin3Map3setGiRP36mizchi6kagura11animation3d8NodePoseE(pose_map, node_idx, p);
        pose = p;
      } else {
        const _Some = _bind$2;
        const _p = _Some;
        pose = _p;
      }
      const _bind$3 = channel.target;
      switch (_bind$3) {
        case 0: {
          const v = _M0FP36mizchi6kagura11animation3d12sample__vec3(channel, self.time);
          _M0MP311moonbitlang4core7builtin3Map3setGiRP36mizchi6kagura11animation3d8NodePoseE(pose_map, node_idx, { node_index: pose.node_index, translation: v, rotation: pose.rotation, scale: pose.scale });
          break;
        }
        case 1: {
          const q = _M0FP36mizchi6kagura11animation3d12sample__quat(channel, self.time);
          _M0MP311moonbitlang4core7builtin3Map3setGiRP36mizchi6kagura11animation3d8NodePoseE(pose_map, node_idx, { node_index: pose.node_index, translation: pose.translation, rotation: q, scale: pose.scale });
          break;
        }
        default: {
          const v$2 = _M0FP36mizchi6kagura11animation3d12sample__vec3(channel, self.time);
          _M0MP311moonbitlang4core7builtin3Map3setGiRP36mizchi6kagura11animation3d8NodePoseE(pose_map, node_idx, { node_index: pose.node_index, translation: pose.translation, rotation: pose.rotation, scale: v$2 });
        }
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const result = [];
  _M0MP311moonbitlang4core7builtin3Map4eachGiRP36mizchi6kagura11animation3d8NodePoseE(pose_map, (_k, v) => {
    _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11animation3d8NodePoseE(result, v);
  });
  return result;
}
function _M0MP36mizchi6kagura8camera3d8Camera3D16new__perspective(position, target, up, fov_y_rad, aspect, near, far) {
  return { position: position, target: target, up: up, fov_y_rad: fov_y_rad, aspect: aspect, near: near, far: far, projection_mode: $64$mizchi$47$kagura$47$camera3d$46$ProjectionMode$Perspective };
}
function _M0FP36mizchi6kagura8camera3d12clamp__pitch(pitch) {
  const limit = 1.56079632679489655;
  return pitch > limit ? limit : pitch < -limit ? -limit : pitch;
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(target, distance, yaw, pitch, fov_y_rad, aspect, near, far) {
  return { target: target, distance: distance, yaw: yaw, pitch: _M0FP36mizchi6kagura8camera3d12clamp__pitch(pitch), fov_y_rad: fov_y_rad, aspect: aspect, near: near, far: far };
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self, delta_yaw, delta_pitch) {
  return { ...self, yaw: self.yaw + delta_yaw, pitch: _M0FP36mizchi6kagura8camera3d12clamp__pitch(self.pitch + delta_pitch) };
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera8position(self) {
  const cp = _M0FP311moonbitlang4core4math3cos(self.pitch);
  const sp = _M0FP311moonbitlang4core4math3sin(self.pitch);
  const cy = _M0FP311moonbitlang4core4math3cos(self.yaw);
  const sy = _M0FP311moonbitlang4core4math3sin(self.yaw);
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
  return { width: width, height: height };
}
function _M0FP36mizchi6kagura4core26new__input__snapshot__full(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, pressed_mouse_buttons, touches, gamepads) {
  return { cursor_x: cursor_x, cursor_y: cursor_y, wheel_x: wheel_x, wheel_y: wheel_y, pressed_keys: pressed_keys, pressed_mouse_buttons: pressed_mouse_buttons, touches: touches, gamepads: gamepads };
}
function _M0FP36mizchi6kagura4core20new__input__snapshot(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys) {
  return _M0FP36mizchi6kagura4core26new__input__snapshot__full(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, [], [], []);
}
function _M0FP36mizchi6kagura4core22empty__input__snapshot() {
  return _M0FP36mizchi6kagura4core20new__input__snapshot(0, 0, 0, 0, []);
}
function _M0FP36mizchi6kagura8platform23new__web__canvas__hooks(try_initialize, poll, should_close, outside_size, current_surface, capture_input, set_fullscreen, is_fullscreen, set_cursor_mode, cursor_mode, set_device_scale_factor, device_scale_factor, set_vsync_enabled, is_vsync_enabled, close_window, request_attention, set_mouse_touch_fallback, mouse_touch_fallback_enabled, fullscreen_request_status, cursor_mode_request_status) {
  return { try_initialize: try_initialize, poll: poll, should_close: should_close, outside_size: outside_size, current_surface: current_surface, capture_input: capture_input, set_fullscreen: set_fullscreen, is_fullscreen: is_fullscreen, set_cursor_mode: set_cursor_mode, cursor_mode: cursor_mode, set_device_scale_factor: set_device_scale_factor, device_scale_factor: device_scale_factor, set_vsync_enabled: set_vsync_enabled, is_vsync_enabled: is_vsync_enabled, close_window: close_window, request_attention: request_attention, set_mouse_touch_fallback: set_mouse_touch_fallback, mouse_touch_fallback_enabled: mouse_touch_fallback_enabled, fullscreen_request_status: fullscreen_request_status, cursor_mode_request_status: cursor_mode_request_status };
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
  return { kind: 1, opaque_id: 2, width: options.width, height: options.height, device_scale_factor: 1 };
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
  return { kind: 3, opaque_id: 0, width: width, height: height, device_scale_factor: 1 };
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform15SurfaceProvider16current__surface(self) {
  return new Result$Ok$1$(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : { kind: 1, opaque_id: 2, width: self.options.width, height: self.options.height, device_scale_factor: 1 });
}
function _M0FP36mizchi6kagura8platform28new__window__options_2einner(title, width, height, transparent, resizable, focused) {
  return { title: title, width: width, height: height, transparent: transparent, resizable: resizable, focused: focused };
}
function _M0FP36mizchi6kagura8platform29create__web__canvas__platform(canvas_selector) {
  return { canvas_selector: canvas_selector, initialized: false, poll_count: 0, close_after_polls: 2, web_active: false, options: { title: "kagura-web", width: 800, height: 600, transparent: true, resizable: true, focused: true }, current_input: _M0FP36mizchi6kagura4core22empty__input__snapshot(), fullscreen: false, cursor_mode: 0, device_scale_factor: 1, vsync_enabled: true, close_requested: false, attention_requests: 0, mouse_touch_fallback: false, fullscreen_request_status: 0, cursor_mode_request_status: 0 };
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
  return new Result$Ok$2$(undefined);
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
  const bits = _M0MP311moonbitlang4core6double6Double22reinterpret__as__int64(v);
  const ubits = bits;
  const sign = _M0MP311moonbitlang4core5int645Int647to__int(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin6BitAnd4land(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(ubits, 63), $1L));
  const exp = _M0MP311moonbitlang4core5int645Int647to__int(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin6BitAnd4land(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(ubits, 52), $2047L));
  const mantissa = _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin6BitAnd4land(bits, $4503599627370495L);
  if (exp === 2047) {
    return _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGlE(mantissa, $0L) ? sign << 31 | 2143289344 : sign << 31 | 2139095040;
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
          const f32_mantissa = _M0MP311moonbitlang4core5int645Int647to__int(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(mantissa, 29));
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
  return use_color_m ? `let color_m = mat4x4f(\n    vec4f(1.0, 0.0, 0.0, 0.0),\n    vec4f(0.0, 1.0, 0.0, 0.0),\n    vec4f(0.0, 0.0, 1.0, 0.0),\n    vec4f(0.0, 0.0, 0.0, 1.0),\n  );\n  color = color_m * color;` : "// color matrix disabled";
}
function _M0FP36mizchi6kagura3gfx30build__builtin__shader__source(key) {
  const address_snippet = _M0FP36mizchi6kagura3gfx25builtin__address__snippet(key.address);
  const sample_snippet = _M0FP36mizchi6kagura3gfx24builtin__sample__snippet(key.filter);
  const color_m_snippet = _M0FP36mizchi6kagura3gfx26builtin__color__m__snippet(key.use_color_m);
  const color_m_tag = key.use_color_m ? "on" : "off";
  const header = `// kagura builtin shader\n// filter:${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(_M0FP36mizchi6kagura3gfx20builtin__filter__tag(key.filter))}\n// address:${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(_M0FP36mizchi6kagura3gfx21builtin__address__tag(key.address))}\n// color_m:${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(color_m_tag)}\n`;
  const bindings = `@group(0) @binding(0) var tex: texture_2d<f32>;\n@group(0) @binding(1) var nearest_sampler: sampler;\n@group(0) @binding(2) var linear_sampler: sampler;\n\n`;
  const structs = `struct VertexOutput {\n  @builtin(position) pos: vec4f,\n  @location(0) uv: vec2f,\n};\n\n`;
  const body = `@fragment\nfn fs_main(in: VertexOutput) -> @location(0) vec4f {\n  let uv = in.uv;\n  ${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(address_snippet)}\n  var color = ${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(sample_snippet)};\n  ${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(color_m_snippet)}\n  return color;\n}\n`;
  return `${header}${bindings}${structs}${body}`;
}
function _M0FP36mizchi6kagura3gfx32default__builtin__shader__source() {
  return _M0FP36mizchi6kagura3gfx30build__builtin__shader__source({ filter: 0, address: 0, use_color_m: false });
}
function _M0FP36mizchi6kagura3gfx16new__dst__region(x, y, width, height, index_count) {
  return { x: x, y: y, width: width, height: height, index_count: index_count };
}
function _M0FP36mizchi6kagura3gfx10new__color(r, g, b, a) {
  return { r: r, g: g, b: b, a: a };
}
function _M0FP36mizchi6kagura3gfx31new__render__pass__desc_2einner(clear_color, clear_enabled, present) {
  return { clear_color: clear_color, clear_enabled: clear_enabled, present: present };
}
function _M0FP36mizchi6kagura3gfx22blend__mode__from__int(mode) {
  switch (mode) {
    case 0: {
      return $64$mizchi$47$kagura$47$gfx$46$BlendMode$Copy;
    }
    case 1: {
      return $64$mizchi$47$kagura$47$gfx$46$BlendMode$Alpha;
    }
    case 2: {
      return $64$mizchi$47$kagura$47$gfx$46$BlendMode$Add;
    }
    case 3: {
      return $64$mizchi$47$kagura$47$gfx$46$BlendMode$Multiply;
    }
    default: {
      return $64$mizchi$47$kagura$47$gfx$46$BlendMode$Alpha;
    }
  }
}
function _M0FP36mizchi6kagura3gfx18new__image__handle(id, width, height) {
  return { id: id, width: width, height: height };
}
function _M0FP36mizchi6kagura3gfx19new__shader__handle(id, source) {
  return { id: id, source: source };
}
function _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, dst_regions, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, uniform_dwords, instance_count, resource_cache_key) {
  return { dst: dst, shader: shader, dst_regions: dst_regions, index_offset: index_offset, pipeline_id: pipeline_id, uniform_hash: uniform_hash, blend: blend, vertex_data: vertex_data, indices: indices, src_image_ids: src_image_ids, uniform_dwords: uniform_dwords, instance_count: instance_count, resource_cache_key: resource_cache_key };
}
function _M0FP36mizchi6kagura3gfx30default__web__on__read__pixels(_active, _kind, _x, _y, _width, _height) {
  return Option$None$3$;
}
function _M0FP36mizchi6kagura3gfx25new__web__graphics__hooks(try_initialize, on_begin, on_end, on_draw, on_resize) {
  return { try_initialize: try_initialize, on_begin: on_begin, on_end: on_end, on_draw: on_draw, on_resize: on_resize, on_read_pixels: _M0FP36mizchi6kagura3gfx30default__web__on__read__pixels };
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
  return Option$None$3$;
}
function _M0FP36mizchi6kagura3gfx28new__native__graphics__hooks(try_initialize, on_begin, on_end, on_draw, on_resize) {
  return { try_initialize: try_initialize, on_begin: on_begin, on_end: on_end, on_draw: on_draw, on_resize: on_resize, on_read_pixels: _M0FP36mizchi6kagura3gfx33default__native__on__read__pixels, on_new_image: _M0FP36mizchi6kagura3gfx31default__native__on__new__image };
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
  return { enable_validation: true, prefer_low_power: false, enable_vsync: true };
}
function _M0FP36mizchi6kagura3gfx23default__clock__now__ms() {
  return 0;
}
function _M0FP36mizchi6kagura3gfx24create__webgpu__graphics(surface, options) {
  return { backend: 1, width: surface.width, height: surface.height, initialized: false, native_active: false, web_active: false, next_id: 0, begin_count: 0, end_count: 0, draw_count: 0, resize_count: 0, resize_suppressed_count: 0, last_resize_duration_ms: 0, total_resize_duration_ms: 0 };
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10initialize(self) {
  if (self.initialized) {
    return new Result$Ok$2$(undefined);
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
  return new Result$Ok$2$(undefined);
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
  return new Result$Ok$2$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(self, present) {
  if (self.initialized) {
    self.end_count = self.end_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx15native__on__end(self.native_active, present);
    _M0FP36mizchi6kagura3gfx22web__graphics__on__end(self.web_active, self.backend, present);
  }
  return new Result$Ok$2$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(self, width, height) {
  const next_width = width <= 0 ? 1 : width;
  const next_height = height <= 0 ? 1 : height;
  if (self.width === next_width && self.height === next_height) {
    self.resize_suppressed_count = self.resize_suppressed_count + 1 | 0;
    return new Result$Ok$2$(undefined);
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
  return new Result$Ok$2$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(self, width, height) {
  self.next_id = self.next_id + 1 | 0;
  _M0FP36mizchi6kagura3gfx22native__on__new__image(self.native_active, self.next_id, width, height);
  return new Result$Ok$4$({ id: self.next_id, width: width, height: height });
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver11new__shader(self, source) {
  self.next_id = self.next_id + 1 | 0;
  return new Result$Ok$5$({ id: self.next_id, source: source });
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(self, command) {
  if (self.initialized) {
    self.draw_count = self.draw_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx16native__on__draw(self.native_active, command);
    _M0FP36mizchi6kagura3gfx23web__graphics__on__draw(self.web_active, self.backend, command);
  }
  return new Result$Ok$2$(undefined);
}
function _M0MP36mizchi6kagura7light3d16DirectionalLight3new(direction, color, intensity) {
  return { direction: _M0MP36mizchi6kagura6math3d4Vec39normalize(direction), color: color, intensity: intensity };
}
function _M0MP36mizchi6kagura7light3d12AmbientLight3new(color, intensity) {
  return { color: color, intensity: intensity };
}
function _M0MP36mizchi6kagura7light3d19LightingEnvironment11new_2einner(directional, ambient, point_lights, spot_lights) {
  return { directional: directional, ambient: ambient, point_lights: point_lights, spot_lights: spot_lights };
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
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, px);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, py);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, pz);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, nx);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, ny);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, nz);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, u);
  _M0MP311moonbitlang4core5array5Array4pushGdE(data, v);
}
function _M0FP36mizchi6kagura6mesh3d21compute__mesh__bounds(vertex_data) {
  if (_M0FP36mizchi6kagura6mesh3d16vertex3d__stride === 0) {
    $panic();
  }
  const vertex_count = vertex_data.length / _M0FP36mizchi6kagura6mesh3d16vertex3d__stride | 0;
  if (vertex_count === 0) {
    return { min_x: 0, min_y: 0, min_z: 0, max_x: 0, max_y: 0, max_z: 0 };
  }
  const min_x = { val: _M0MP311moonbitlang4core5array5Array2atGdE(vertex_data, 0) };
  const min_y = { val: _M0MP311moonbitlang4core5array5Array2atGdE(vertex_data, 1) };
  const min_z = { val: _M0MP311moonbitlang4core5array5Array2atGdE(vertex_data, 2) };
  const max_x = { val: min_x.val };
  const max_y = { val: min_y.val };
  const max_z = { val: min_z.val };
  const _start101 = 1;
  const _end102 = vertex_count;
  let _tmp = _start101;
  while (true) {
    const i = _tmp;
    if (i < _end102) {
      const base = Math.imul(i, _M0FP36mizchi6kagura6mesh3d16vertex3d__stride) | 0;
      const x = _M0MP311moonbitlang4core5array5Array2atGdE(vertex_data, base);
      const y = _M0MP311moonbitlang4core5array5Array2atGdE(vertex_data, base + 1 | 0);
      const z = _M0MP311moonbitlang4core5array5Array2atGdE(vertex_data, base + 2 | 0);
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
  return { min_x: min_x.val, min_y: min_y.val, min_z: min_z.val, max_x: max_x.val, max_y: max_y.val, max_z: max_z.val };
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(vertex_data, indices) {
  return { vertex_data: vertex_data, indices: indices, bounds: _M0FP36mizchi6kagura6mesh3d21compute__mesh__bounds(vertex_data) };
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
  const _start48 = 0;
  const _end49 = n;
  let _tmp = _start48;
  while (true) {
    const row = _tmp;
    if (row <= _end49) {
      const t = (row + 0) / (n + 0);
      const z = -hd + t * depth;
      const v = t;
      const _start56 = 0;
      const _end57 = n;
      let _tmp$2 = _start56;
      while (true) {
        const col = _tmp$2;
        if (col <= _end57) {
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
  const _start65 = 0;
  const _end66 = n;
  let _tmp$2 = _start65;
  while (true) {
    const row = _tmp$2;
    if (row < _end66) {
      const _start70 = 0;
      const _end71 = n;
      let _tmp$3 = _start70;
      while (true) {
        const col = _tmp$3;
        if (col < _end71) {
          const tl = (Math.imul(row, cols) | 0) + col | 0;
          const tr = tl + 1 | 0;
          const bl = tl + cols | 0;
          const br = bl + 1 | 0;
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, tl);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, bl);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, tr);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, tr);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, bl);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, br);
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
function _M0FP36mizchi6kagura10skeleton3d28build__skinned__vertex__data(bind_mesh, skin) {
  const src_stride = _M0FP36mizchi6kagura6mesh3d16vertex3d__stride;
  const dst_stride = 16;
  const vertex_count = _M0MP36mizchi6kagura6mesh3d6Mesh3D13vertex__count(bind_mesh);
  const out = _M0MP311moonbitlang4core5array5Array4makeGdE(Math.imul(vertex_count, dst_stride) | 0, 0);
  const _start30 = 0;
  const _end31 = vertex_count;
  let _tmp = _start30;
  while (true) {
    const v = _tmp;
    if (v < _end31) {
      const src_base = Math.imul(v, src_stride) | 0;
      const dst_base = Math.imul(v, dst_stride) | 0;
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 1 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 1 | 0));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 2 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 2 | 0));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 3 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 3 | 0));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 4 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 4 | 0));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 5 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 5 | 0));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 6 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 6 | 0));
      _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 7 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(bind_mesh.vertex_data, src_base + 7 | 0));
      const ji_base = Math.imul(v, 4) | 0;
      const has_skin = v < skin.vertex_count && ((ji_base + 3 | 0) < skin.joint_indices.length && (ji_base + 3 | 0) < skin.weights.length);
      if (has_skin) {
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 8 | 0, _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base) >= 0 ? _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base) + 0 : 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 9 | 0, _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base + 1 | 0) >= 0 ? _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base + 1 | 0) + 0 : 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 10 | 0, _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base + 2 | 0) >= 0 ? _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base + 2 | 0) + 0 : 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 11 | 0, _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base + 3 | 0) >= 0 ? _M0MP311moonbitlang4core5array5Array2atGiE(skin.joint_indices, ji_base + 3 | 0) + 0 : 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 12 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(skin.weights, ji_base));
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 13 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(skin.weights, ji_base + 1 | 0));
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 14 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(skin.weights, ji_base + 2 | 0));
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 15 | 0, _M0MP311moonbitlang4core5array5Array2atGdE(skin.weights, ji_base + 3 | 0));
      } else {
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 8 | 0, 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 9 | 0, 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 10 | 0, 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 11 | 0, 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 12 | 0, 1);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 13 | 0, 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 14 | 0, 0);
        _M0MP311moonbitlang4core5array5Array3setGdE(out, dst_base + 15 | 0, 0);
      }
      _tmp = v + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0MP36mizchi6kagura10skeleton3d8Skeleton3new(bones, inverse_bind_matrices) {
  return { bones: bones, inverse_bind_matrices: inverse_bind_matrices };
}
function _M0MP36mizchi6kagura10skeleton3d8Skeleton26compute__world__transforms(self, local_poses) {
  const count = self.bones.length;
  const world = _M0MP311moonbitlang4core5array5Array4makeGRP36mizchi6kagura6math3d4Mat4E(count, _M0MP36mizchi6kagura6math3d4Mat48identity());
  const _start14 = 0;
  const _end15 = count;
  let _tmp = _start14;
  while (true) {
    const i = _tmp;
    if (i < _end15) {
      const local_mat = _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura11transform3d11Transform3DE(local_poses, i));
      const parent = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura10skeleton3d4BoneE(self.bones, i).parent;
      if (parent < 0) {
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura6math3d4Mat4E(world, i, local_mat);
      } else {
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura6math3d4Mat4E(world, i, _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(world, parent), local_mat));
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return world;
}
function _M0MP36mizchi6kagura10skeleton3d8Skeleton27compute__skinning__matrices(self, world_transforms) {
  const count = self.bones.length;
  const result = _M0MP311moonbitlang4core5array5Array4makeGRP36mizchi6kagura6math3d4Mat4E(count, _M0MP36mizchi6kagura6math3d4Mat48identity());
  const _start5 = 0;
  const _end6 = count;
  let _tmp = _start5;
  while (true) {
    const i = _tmp;
    if (i < _end6) {
      _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura6math3d4Mat4E(result, i, _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(world_transforms, i), _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(self.inverse_bind_matrices, i)));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return result;
}
function _M0FP36mizchi6kagura6draw3d25mat4__to__uniform__dwords(m) {
  const dwords = [];
  const _start410 = 0;
  const _end411 = 16;
  let _tmp = _start410;
  while (true) {
    const i = _tmp;
    if (i < _end411) {
      const _tmp$2 = m.elements;
      $bound_check(_tmp$2, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl() {
  return `struct Uniforms {\n  mvp: mat4x4<f32>,\n  model: mat4x4<f32>,\n  normal_col0: vec4<f32>,\n  normal_col1: vec4<f32>,\n  normal_col2: vec4<f32>,\n  light_dir: vec4<f32>,\n  light_color: vec4<f32>,\n  ambient_color: vec4<f32>,\n};\n\n`;
}
function _M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl() {
  return `  let normal_mat = mat3x3<f32>(\n    uniforms.normal_col0.xyz,\n    uniforms.normal_col1.xyz,\n    uniforms.normal_col2.xyz,\n  );\n`;
}
function _M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl() {
  return `  let normal = normalize(in.world_normal);\n  let light_dir = normalize(-uniforms.light_dir.xyz);\n  let ndotl = max(dot(normal, light_dir), 0.0);\n  let diffuse = uniforms.light_color.xyz * ndotl;\n  let ambient = uniforms.ambient_color.xyz;\n`;
}
function _M0FP36mizchi6kagura6draw3d31shader3d__lit__untextured__wgsl() {
  return `${_M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl()}@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) world_normal: vec3<f32>,\n};\n\n@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n${_M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl()}  out.world_normal = normalize(normal_mat * input.normal);\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n${_M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl()}  let lit_color = diffuse + ambient;\n  return vec4<f32>(lit_color, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model, view_projection, lighting) {
  const mvp = _M0MP36mizchi6kagura6math3d4Mat48multiply(view_projection, model);
  const dwords = _M0FP36mizchi6kagura6draw3d25mat4__to__uniform__dwords(mvp);
  const _start376 = 0;
  const _end377 = 16;
  let _tmp = _start376;
  while (true) {
    const i = _tmp;
    if (i < _end377) {
      const _tmp$2 = model.elements;
      $bound_check(_tmp$2, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const normal_dw = _M0FP36mizchi6kagura7light3d31normal__matrix__uniform__dwords(model);
  const _start382 = 0;
  const _end383 = normal_dw.length;
  let _tmp$2 = _start382;
  while (true) {
    const i = _tmp$2;
    if (i < _end383) {
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0MP311moonbitlang4core5array5Array2atGiE(normal_dw, i));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const light_dw = _M0FP36mizchi6kagura7light3d22light__uniform__dwords(lighting);
  const _start388 = 0;
  const _end389 = light_dw.length;
  let _tmp$3 = _start388;
  while (true) {
    const i = _tmp$3;
    if (i < _end389) {
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0MP311moonbitlang4core5array5Array2atGiE(light_dw, i));
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
function _M0FP36mizchi6kagura6draw3d35skinned__lit__uniform__struct__wgsl() {
  return `const MAX_BONES: u32 = 64u;\n\nstruct Uniforms {\n  mvp: mat4x4<f32>,\n  model: mat4x4<f32>,\n  normal_col0: vec4<f32>,\n  normal_col1: vec4<f32>,\n  normal_col2: vec4<f32>,\n  light_dir: vec4<f32>,\n  light_color: vec4<f32>,\n  ambient_color: vec4<f32>,\n  num_bones: vec4<f32>,\n  bone_matrices: array<mat4x4<f32>, 64>,\n};\n\n`;
}
function _M0FP36mizchi6kagura6draw3d28shader3d__lit__skinned__wgsl() {
  return `${_M0FP36mizchi6kagura6draw3d35skinned__lit__uniform__struct__wgsl()}@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var tex: texture_2d<f32>;\n@group(0) @binding(2) var tex_sampler: sampler;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n  @location(3) joints: vec4<f32>,\n  @location(4) weights: vec4<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) world_normal: vec3<f32>,\n  @location(1) uv: vec2<f32>,\n};\n\n@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  let pre_skinned = uniforms.num_bones.y > 0.5;\n  var skinned_pos = vec4<f32>(input.position, 1.0);\n  var skinned_normal = input.normal;\n  if (!pre_skinned) {\n    var skin_mat = mat4x4<f32>();\n    for (var i = 0u; i < 4u; i = i + 1u) {\n      let joint_idx = u32(input.joints[i]);\n      let weight = input.weights[i];\n      if (weight > 0.0) {\n        skin_mat = skin_mat + weight * uniforms.bone_matrices[joint_idx];\n      }\n    }\n    skinned_pos = skin_mat * vec4<f32>(input.position, 1.0);\n    skinned_normal = (skin_mat * vec4<f32>(input.normal, 0.0)).xyz;\n  }\n  var out: VertexOutput;\n  out.clip_position = uniforms.mvp * skinned_pos;\n${_M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl()}  out.world_normal = normalize(normal_mat * skinned_normal);\n  out.uv = input.uv;\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n${_M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl()}  let tex_color = textureSample(tex, tex_sampler, in.uv);\n  let lit_color = tex_color.rgb * (diffuse + ambient);\n  return vec4<f32>(lit_color, tex_color.a);\n}\n`;
}
function _M0FP36mizchi6kagura6draw3d38new__skinned__lit__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, model_matrix, view_projection, lighting, skinning_matrices, src_image_ids) {
  const dwords = _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model_matrix, view_projection, lighting);
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(skinning_matrices.length + 0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  const bone_count = skinning_matrices.length < _M0FP36mizchi6kagura6draw3d10max__bones ? skinning_matrices.length : _M0FP36mizchi6kagura6draw3d10max__bones;
  const _start193 = 0;
  const _end194 = bone_count;
  let _tmp = _start193;
  while (true) {
    const i = _tmp;
    if (i < _end194) {
      const _start198 = 0;
      const _end199 = 16;
      let _tmp$2 = _start198;
      while (true) {
        const j = _tmp$2;
        if (j < _end199) {
          const _tmp$3 = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(skinning_matrices, i).elements;
          $bound_check(_tmp$3, j);
          _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$3[j]));
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
  const _start203 = bone_count;
  const _end204 = _M0FP36mizchi6kagura6draw3d10max__bones;
  let _tmp$2 = _start203;
  while (true) {
    const _i = _tmp$2;
    if (_i < _end204) {
      const _start208 = 0;
      const _end209 = 16;
      let _tmp$3 = _start208;
      while (true) {
        const _j = _tmp$3;
        if (_j < _end209) {
          _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, 0);
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
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.x));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.y));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.z));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.w));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(metallic));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(roughness));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.x));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.y));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.z));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.x));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.y));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.z));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d29new__pbr__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh, model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos, src_image_ids) {
  const uniform_dwords = _M0FP36mizchi6kagura6draw3d20pbr__uniform__dwords(model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, mesh.vertex_data, mesh.indices, src_image_ids, uniform_dwords, 1, 0);
}
function _M0IP26mizchi5audio13EnvelopePhaseP311moonbitlang4core7builtin2Eq5equal(_x_1440, _x_1441) {
  switch (_x_1440) {
    case 0: {
      if (_x_1441 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_1441 === 1) {
        return true;
      } else {
        return false;
      }
    }
    case 2: {
      if (_x_1441 === 2) {
        return true;
      } else {
        return false;
      }
    }
    case 3: {
      if (_x_1441 === 3) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_1441 === 4) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0IP26mizchi5audio10VoiceStateP311moonbitlang4core7builtin2Eq5equal(_x_1408, _x_1409) {
  switch (_x_1408) {
    case 0: {
      if (_x_1409 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_1409 === 1) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_1409 === 2) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0IP26mizchi5audio7VoiceIdP311moonbitlang4core7builtin2Eq5equal(_x_1326, _x_1327) {
  return _x_1326 === _x_1327;
}
function _M0FP26mizchi5audio11find__voice(mixer, id) {
  const _arr = mixer.voices;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const voice = _arr[_i];
      if (_M0IP26mizchi5audio7VoiceIdP311moonbitlang4core7builtin2Eq5equal(voice.id, id)) {
        return voice;
      }
      _tmp = _i + 1 | 0;
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
  const floor_pos = _M0MP311moonbitlang4core5float5Float7to__int(position);
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
  const floor_pos = _M0MP311moonbitlang4core5float5Float7to__int(position);
  const frac = Math.fround(position - Math.fround(floor_pos));
  const i0 = _M0FP26mizchi5audio12clamp__frame(floor_pos, frame_count);
  const i1 = _M0FP26mizchi5audio12clamp__frame(floor_pos + 1 | 0, frame_count);
  const s0 = _M0FP26mizchi5audio20read__source__sample(source, i0, channel);
  const s1 = _M0FP26mizchi5audio20read__source__sample(source, i1, channel);
  return Math.fround(s0 + Math.fround(Math.fround(s1 - s0) * frac));
}
function _M0FP26mizchi5audio17resample__nearest(source, position, channel, frame_count) {
  const frame = _M0FP26mizchi5audio12clamp__frame(_M0MP311moonbitlang4core5float5Float7to__int(Math.fround(position + Math.fround(0.5))), frame_count);
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
  const left = _M0FP311moonbitlang4core4math4cosf(angle);
  const right = _M0FP311moonbitlang4core4math4sinf(angle);
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
  const result = { val: sample };
  const _arr = effects;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const effect = _arr[_i];
      result.val = _M0FP26mizchi5audio15effect__process(effect, result.val);
      _tmp = _i + 1 | 0;
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
      const attack_samples = _M0MP311moonbitlang4core5float5Float7to__int(Math.fround(env.config.attack * Math.fround(env.sample_rate)));
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
      const decay_samples = _M0MP311moonbitlang4core5float5Float7to__int(Math.fround(env.config.decay * Math.fround(env.sample_rate)));
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
      const release_samples = _M0MP311moonbitlang4core5float5Float7to__int(Math.fround(env.config.release_time * Math.fround(env.sample_rate)));
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
  _M0MP311moonbitlang4core5array10FixedArray12fill_2einnerGfE(output, Math.fround(0), 0, Math.imul(frames, 2) | 0);
  const _arr = mixer.voices;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      _L: {
        const voice = _arr[_i];
        if (_M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGRP26mizchi5audio10VoiceStateE(voice.state, 0)) {
          break _L;
        }
        const src = voice.source;
        const src_channels = _M0FP26mizchi5audio16source__channels(src);
        const src_frames = _M0FP26mizchi5audio20source__frame__count(src);
        let pan_l;
        let pan_r;
        _L$2: {
          const _bind = _M0FP26mizchi5audio10pan__gains(voice.pan);
          const _pan_l = _bind._0;
          const _pan_r = _bind._1;
          pan_l = _pan_l;
          pan_r = _pan_r;
          break _L$2;
        }
        const voice_gain = voice.gain;
        const ratio = _M0FP26mizchi5audio15resample__ratio(voice.sample_rate, mixer.sample_rate);
        const _start279 = 0;
        const _end280 = frames;
        let _tmp$2 = _start279;
        while (true) {
          const f = _tmp$2;
          if (f < _end280) {
            const int_pos = _M0MP311moonbitlang4core5float5Float7to__int(voice.position);
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
                const _bind = voice.envelope;
                if (_bind === undefined) {
                  env_gain = Math.fround(1);
                } else {
                  const _Some = _bind;
                  const _env = _Some;
                  env = _env;
                  break _L$4;
                }
                break _L$3;
              }
              const g = _M0FP26mizchi5audio14envelope__tick(env);
              if (_M0IP26mizchi5audio13EnvelopePhaseP311moonbitlang4core7builtin2Eq5equal(env.phase, 4)) {
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
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (Math.fround(mixer.master_gain !== Math.fround(1))) {
    const _start295 = 0;
    const _end296 = Math.imul(frames, 2) | 0;
    let _tmp$2 = _start295;
    while (true) {
      const i = _tmp$2;
      if (i < _end296) {
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
  mixer.voices = _M0MP311moonbitlang4core5array5Array6filterGRP26mizchi5audio5VoiceE(mixer.voices, (v) => _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGRP26mizchi5audio10VoiceStateE(v.state, 2));
}
function _M0FP36mizchi6kagura5audio22default__audio__format() {
  return { sample_rate: 44100, channels: 2, bits_per_sample: 16 };
}
function _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id) {
  const _arr = self.player_map;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const pair = _arr[_i];
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
      _tmp = _i + 1 | 0;
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
      return new Result$Ok$2$(undefined);
    } else {
      const _Some = _bind;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  _M0FP26mizchi5audio11stop__voice(self.mixer, vid);
  return new Result$Ok$2$(undefined);
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
  self.player_map = _M0MP311moonbitlang4core5array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self.player_map, (pair) => {
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
  const _arr = self.player_map;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const pair = _arr[_i];
      let vid;
      _L: {
        const _vid = pair._1;
        vid = _vid;
        break _L;
      }
      let voice;
      _L$2: {
        _L$3: {
          const _bind = _M0FP26mizchi5audio11find__voice(self.mixer, vid);
          if (_bind === undefined) {
          } else {
            const _Some = _bind;
            const _voice = _Some;
            voice = _voice;
            break _L$3;
          }
          break _L$2;
        }
        if (_M0IP26mizchi5audio10VoiceStateP311moonbitlang4core7builtin2Eq5equal(voice.state, 2)) {
          voice.state = 1;
        }
      }
      _tmp = _i + 1 | 0;
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
  return { try_initialize: try_initialize, write_frames: write_frames, suspend: suspend, resume_playback: resume_playback, close: close, output_latency: _M0FP36mizchi6kagura5audio31default__audio__output__latency };
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
function _M0FP36mizchi6kagura9inpututil13contains__key(keys, key) {
  const found = { val: false };
  const _arr = keys;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const current = _arr[_i];
      if (current === key) {
        found.val = true;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return found.val;
}
function _M0FP36mizchi6kagura9inpututil21normalize__touch__ids(snapshot) {
  const out = [];
  const _arr = snapshot.touches;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const touch = _arr[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(out, touch.id)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(out, touch.id);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura9inpututil20duration__for__touch(entries, id) {
  const out = { val: 0 };
  const _arr = entries;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const entry = _arr[_i];
      if (entry.id === id) {
        out.val = entry.duration;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura9inpututil24new__touch__input__state() {
  return { prev_touch_ids: [], touch_ids: [], just_pressed_touch_ids: [], just_released_touch_ids: [], durations: [] };
}
function _M0FP36mizchi6kagura9inpututil27update__touch__input__state(state, snapshot) {
  const prev_ids = state.touch_ids;
  const next_ids = _M0FP36mizchi6kagura9inpututil21normalize__touch__ids(snapshot);
  const just_pressed = [];
  const _arr = next_ids;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const id = _arr[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(prev_ids, id)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(just_pressed, id);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const just_released = [];
  const _arr$2 = prev_ids;
  const _len$2 = _arr$2.length;
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < _len$2) {
      const id = _arr$2[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(next_ids, id)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(just_released, id);
      }
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_durations = [];
  const _arr$3 = next_ids;
  const _len$3 = _arr$3.length;
  let _tmp$3 = 0;
  while (true) {
    const _i = _tmp$3;
    if (_i < _len$3) {
      const id = _arr$3[_i];
      const duration = _M0FP36mizchi6kagura9inpututil13contains__key(prev_ids, id) ? _M0FP36mizchi6kagura9inpututil20duration__for__touch(state.durations, id) + 1 | 0 : 1;
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9inpututil18TouchDurationEntryE(next_durations, { id: id, duration: duration });
      _tmp$3 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  state.prev_touch_ids = prev_ids;
  state.touch_ids = next_ids;
  state.just_pressed_touch_ids = just_pressed;
  state.just_released_touch_ids = just_released;
  state.durations = next_durations;
}
function _M0FP36mizchi6kagura9inpututil24normalize__pressed__keys(keys) {
  const out = [];
  const _arr = keys;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const key = _arr[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(out, key)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(out, key);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura9inpututil18duration__for__key(entries, key) {
  const out = { val: 0 };
  const _arr = entries;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const entry = _arr[_i];
      if (entry.key === key) {
        out.val = entry.duration;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura9inpututil22new__key__input__state() {
  return { prev_pressed_keys: [], pressed_keys: [], just_pressed_keys: [], just_released_keys: [], durations: [] };
}
function _M0FP36mizchi6kagura9inpututil28duration__for__mouse__button(entries, button) {
  const out = { val: 0 };
  const _arr = entries;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const entry = _arr[_i];
      if (entry.button === button) {
        out.val = entry.duration;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura9inpututil24new__mouse__input__state() {
  return { prev_pressed_buttons: [], pressed_buttons: [], just_pressed_buttons: [], just_released_buttons: [], durations: [] };
}
function _M0FP36mizchi6kagura9inpututil25update__key__input__state(state, snapshot) {
  const prev_pressed = state.pressed_keys;
  const next_pressed = _M0FP36mizchi6kagura9inpututil24normalize__pressed__keys(snapshot.pressed_keys);
  const just_pressed = [];
  const _arr = next_pressed;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const key = _arr[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, key)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(just_pressed, key);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const just_released = [];
  const _arr$2 = prev_pressed;
  const _len$2 = _arr$2.length;
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < _len$2) {
      const key = _arr$2[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(next_pressed, key)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(just_released, key);
      }
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_durations = [];
  const _arr$3 = next_pressed;
  const _len$3 = _arr$3.length;
  let _tmp$3 = 0;
  while (true) {
    const _i = _tmp$3;
    if (_i < _len$3) {
      const key = _arr$3[_i];
      const duration = _M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, key) ? _M0FP36mizchi6kagura9inpututil18duration__for__key(state.durations, key) + 1 | 0 : 1;
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9inpututil16KeyDurationEntryE(next_durations, { key: key, duration: duration });
      _tmp$3 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  state.prev_pressed_keys = prev_pressed;
  state.pressed_keys = next_pressed;
  state.just_pressed_keys = just_pressed;
  state.just_released_keys = just_released;
  state.durations = next_durations;
}
function _M0FP36mizchi6kagura9inpututil27update__mouse__input__state(state, snapshot) {
  const prev_pressed = state.pressed_buttons;
  const next_pressed = _M0FP36mizchi6kagura9inpututil24normalize__pressed__keys(snapshot.pressed_mouse_buttons);
  const just_pressed = [];
  const _arr = next_pressed;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const button = _arr[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, button)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(just_pressed, button);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const just_released = [];
  const _arr$2 = prev_pressed;
  const _len$2 = _arr$2.length;
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < _len$2) {
      const button = _arr$2[_i];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(next_pressed, button)) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(just_released, button);
      }
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_durations = [];
  const _arr$3 = next_pressed;
  const _len$3 = _arr$3.length;
  let _tmp$3 = 0;
  while (true) {
    const _i = _tmp$3;
    if (_i < _len$3) {
      const button = _arr$3[_i];
      const duration = _M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, button) ? _M0FP36mizchi6kagura9inpututil28duration__for__mouse__button(state.durations, button) + 1 | 0 : 1;
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9inpututil24MouseButtonDurationEntryE(next_durations, { button: button, duration: duration });
      _tmp$3 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  state.prev_pressed_buttons = prev_pressed;
  state.pressed_buttons = next_pressed;
  state.just_pressed_buttons = just_pressed;
  state.just_released_buttons = just_released;
  state.durations = next_durations;
}
function _M0FP36mizchi6kagura9inpututil18new__input__helper() {
  return { key_state: _M0FP36mizchi6kagura9inpututil22new__key__input__state(), mouse_state: _M0FP36mizchi6kagura9inpututil24new__mouse__input__state(), touch_state: _M0FP36mizchi6kagura9inpututil24new__touch__input__state() };
}
function _M0FP36mizchi6kagura9inpututil21update__input__helper(helper, snapshot) {
  _M0FP36mizchi6kagura9inpututil25update__key__input__state(helper.key_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__mouse__input__state(helper.mouse_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__touch__input__state(helper.touch_state, snapshot);
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
  const _arr = cmds;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const cmd = _arr[_i];
      const _bind$2 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(graphics, cmd);
      if (_bind$2.$tag === 1) {
        const _ok = _bind$2;
        _ok._0;
      } else {
        return _bind$2;
      }
      _tmp = _i + 1 | 0;
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
    _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] platform.initialize failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
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
    _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] graphics.initialize failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
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
    _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] graphics.new_image failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
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
    _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] graphics.new_shader failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
    shader = _M0FP36mizchi6kagura3gfx19new__shader__handle(1, shader_source);
  }
  const ctx = { dst: dst, shader: shader, screen_w: width, screen_h: height };
  const tick = _M0MP311moonbitlang4core3ref3Ref3newGiE(0);
  if (audio_ctx === undefined) {
  } else {
    _M0FP36mizchi6kagura5audio22audio__try__initialize(_M0FP36mizchi6kagura5audio22default__audio__format());
  }
  const audio_tick_ms = (audio_frames_per_tick + 0) / 44100 * 1000;
  const audio_accum = _M0MP311moonbitlang4core3ref3Ref3newGdE(0);
  const prev_time = _M0MP311moonbitlang4core3ref3Ref3newGdE(_M0FP36mizchi6kagura6engine20js__performance__now());
  const frame = () => {
    _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver12poll__events(platform);
    const outside = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver13outside__size(platform);
    const new_w = _M0MP311moonbitlang4core6double6Double7to__int(outside.width);
    const new_h = _M0MP311moonbitlang4core6double6Double7to__int(outside.height);
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
        _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] graphics.resize failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
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
        _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] graphics.new_image (resize) failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
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
      _M0FP311moonbitlang4core7builtin7printlnGsE(`[engine] render_commands failed: ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(e)}`);
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
function _M0MP36mizchi6kagura7scene3d13SkinningState17new__with__packed(skin, skinning_matrices, packed_vertex_data) {
  return { skin: skin, skinning_matrices: skinning_matrices, packed_vertex_data: new Option$Some$6$(packed_vertex_data) };
}
function _M0FP36mizchi6kagura7scene3d19compute__mesh__aabb(mesh) {
  const bounds = _M0MP36mizchi6kagura6mesh3d6Mesh3D6bounds(mesh);
  return { _0: bounds.min_x, _1: bounds.min_y, _2: bounds.min_z, _3: bounds.max_x, _4: bounds.max_y, _5: bounds.max_z };
}
function _M0FP36mizchi6kagura7scene3d19frustum__cull__aabb(frustum, min_x, min_y, min_z, max_x, max_y, max_z) {
  const _start97 = 0;
  const _end98 = 6;
  let _tmp = _start97;
  while (true) {
    const i = _tmp;
    if (i < _end98) {
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
  const wmin_x = { val: e[12] };
  $bound_check(e, 13);
  const wmin_y = { val: e[13] };
  $bound_check(e, 14);
  const wmin_z = { val: e[14] };
  const wmax_x = { val: wmin_x.val };
  const wmax_y = { val: wmin_y.val };
  const wmax_z = { val: wmin_z.val };
  const mins = [min_x, min_y, min_z];
  const maxs = [max_x, max_y, max_z];
  const _start77 = 0;
  const _end78 = 3;
  let _tmp = _start77;
  while (true) {
    const j = _tmp;
    if (j < _end78) {
      const _tmp$2 = Math.imul(j, 4) | 0;
      $bound_check(e, _tmp$2);
      const a0 = e[_tmp$2] * _M0MP311moonbitlang4core5array5Array2atGdE(mins, j);
      const _tmp$3 = Math.imul(j, 4) | 0;
      $bound_check(e, _tmp$3);
      const b0 = e[_tmp$3] * _M0MP311moonbitlang4core5array5Array2atGdE(maxs, j);
      if (a0 < b0) {
        wmin_x.val = wmin_x.val + a0;
        wmax_x.val = wmax_x.val + b0;
      } else {
        wmin_x.val = wmin_x.val + b0;
        wmax_x.val = wmax_x.val + a0;
      }
      const _tmp$4 = (Math.imul(j, 4) | 0) + 1 | 0;
      $bound_check(e, _tmp$4);
      const a1 = e[_tmp$4] * _M0MP311moonbitlang4core5array5Array2atGdE(mins, j);
      const _tmp$5 = (Math.imul(j, 4) | 0) + 1 | 0;
      $bound_check(e, _tmp$5);
      const b1 = e[_tmp$5] * _M0MP311moonbitlang4core5array5Array2atGdE(maxs, j);
      if (a1 < b1) {
        wmin_y.val = wmin_y.val + a1;
        wmax_y.val = wmax_y.val + b1;
      } else {
        wmin_y.val = wmin_y.val + b1;
        wmax_y.val = wmax_y.val + a1;
      }
      const _tmp$6 = (Math.imul(j, 4) | 0) + 2 | 0;
      $bound_check(e, _tmp$6);
      const a2 = e[_tmp$6] * _M0MP311moonbitlang4core5array5Array2atGdE(mins, j);
      const _tmp$7 = (Math.imul(j, 4) | 0) + 2 | 0;
      $bound_check(e, _tmp$7);
      const b2 = e[_tmp$7] * _M0MP311moonbitlang4core5array5Array2atGdE(maxs, j);
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
  const tinted_lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(lighting.directional.direction, _M0MP36mizchi6kagura6math3d4Vec33new(lighting.directional.color.x * col.x, lighting.directional.color.y * col.y, lighting.directional.color.z * col.z), lighting.directional.intensity), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(lighting.ambient.color.x * col.x, lighting.ambient.color.y * col.y, lighting.ambient.color.z * col.z), lighting.ambient.intensity), Option$None$7$, Option$None$8$);
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
    _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, cmd);
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
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, cmd);
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
    _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, cmd);
    return;
  }
}
function _M0FP36mizchi6kagura7scene3d16normalize__plane(a, b, c, d) {
  const len = Math.sqrt(a * a + b * b + c * c);
  if (len < 1e-10) {
    return { nx: 0, ny: 0, nz: 0, d: 0 };
  } else {
    const inv = 1 / len;
    return { nx: a * inv, ny: b * inv, nz: c * inv, d: d * inv };
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
  const planes = $make_array_len_and_init(6, { nx: 0, ny: 0, nz: 0, d: 0 });
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
  return { planes: planes };
}
function _M0FP36mizchi6kagura7scene3d29has__nonzero__sort__bias__gpu(objects) {
  const _arr = objects;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const obj = _arr[_i];
      if (obj.sort_bias !== 0) {
        return true;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP36mizchi6kagura7scene3d23sort__objects__for__gpu(objects) {
  const ordered = [];
  const _start212 = 0;
  const _end213 = objects.length;
  let _tmp = _start212;
  while (true) {
    const i = _tmp;
    if (i < _end213) {
      _M0MP311moonbitlang4core5array5Array4pushGUiRP36mizchi6kagura7scene3d8Object3DEE(ordered, { _0: i, _1: _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura7scene3d8Object3DE(objects, i) });
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core5array5Array8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(ordered, (a, b) => {
    const bias_a = a._1.sort_bias;
    const bias_b = b._1.sort_bias;
    return bias_a > bias_b ? -1 : bias_a < bias_b ? 1 : a._0 - b._0 | 0;
  });
  const sorted = [];
  const _arr = ordered;
  const _len = _arr.length;
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < _len) {
      const entry = _arr[_i];
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura7scene3d8Object3DE(sorted, entry._1);
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return sorted;
}
function _M0FP36mizchi6kagura7scene3d36push__scene3d__gpu__commands_2einner(objects, camera, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned) {
  const vp = _M0MP36mizchi6kagura8camera3d8Camera3D24view__projection__matrix(camera);
  const frustum = _M0MP36mizchi6kagura7scene3d7Frustum8from__vp(vp);
  const ordered = _M0FP36mizchi6kagura7scene3d29has__nonzero__sort__bias__gpu(objects) ? _M0FP36mizchi6kagura7scene3d23sort__objects__for__gpu(objects) : objects;
  const _arr = ordered;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const obj = _arr[_i];
      const model = _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(obj.transform);
      _M0FP36mizchi6kagura7scene3d27render__object__gpu_2einner(obj.mesh, model, obj.color, obj.material, obj.skinning, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera.position);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura7scene3d28render__scene3d__gpu_2einner(scene, dst, shader3d, screen_w, screen_h, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned) {
  const cmds = [];
  _M0FP36mizchi6kagura7scene3d36push__scene3d__gpu__commands_2einner(scene.objects, scene.camera, scene.lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned);
  return cmds;
}
function _M0FP36mizchi6kagura7scene3d20render__scene3d__gpu(scene, dst, shader3d, screen_w, screen_h, shader3d_textured$46$opt, shader3d_pbr$46$opt, shader3d_pbr_textured$46$opt, shader3d_skinned$46$opt) {
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
  return _M0FP36mizchi6kagura7scene3d28render__scene3d__gpu_2einner(scene, dst, shader3d, screen_w, screen_h, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned);
}
function _M0FP36mizchi6kagura7scene3d16object3d_2einner(mesh, position, rotation, scale, color, material, sort_bias, skinning) {
  return { mesh: mesh, transform: _M0MP36mizchi6kagura11transform3d11Transform3D16from__components(position, rotation, scale), color: color, material: material, sort_bias: sort_bias, skinning: skinning };
}
function _M0FP36mizchi6kagura7scene3d8object3d(mesh, position$46$opt, rotation$46$opt, scale$46$opt, color$46$opt, material$46$opt, sort_bias$46$opt, skinning$46$opt) {
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
  let sort_bias;
  if (sort_bias$46$opt.$tag === 1) {
    const _Some = sort_bias$46$opt;
    sort_bias = _Some._0;
  } else {
    sort_bias = 0;
  }
  let skinning;
  if (skinning$46$opt.$tag === 1) {
    const _Some = skinning$46$opt;
    skinning = _Some._0;
  } else {
    skinning = undefined;
  }
  return _M0FP36mizchi6kagura7scene3d16object3d_2einner(mesh, position, rotation, scale, color, material, sort_bias, skinning);
}
function _M0FP36mizchi6kagura7scene3d15scene3d_2einner(objects, camera, lighting) {
  return { objects: objects, camera: camera, lighting: lighting };
}
function _M0FP26mizchi14skeletal__anim37compute__tentacle__skinning__matrices(t) {
  const _start22 = 0;
  const _end23 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp = _start22;
  while (true) {
    const i = _tmp;
    if (i < _end23) {
      _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, i, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura10skeleton3d4BoneE(t.skeleton.bones, i).local_transform);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const poses = _M0MP36mizchi6kagura11animation3d15AnimationPlayer6sample(t.player);
  const _arr = poses;
  const _len = _arr.length;
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < _len) {
      const pose = _arr[_i];
      const idx = pose.node_index;
      if (idx >= 0 && idx < _M0FP26mizchi14skeletal__anim10num__bones) {
        let q;
        _L: {
          _L$2: {
            const _bind = pose.rotation;
            if (_bind === undefined) {
            } else {
              const _Some = _bind;
              const _q = _Some;
              q = _q;
              break _L$2;
            }
            break _L;
          }
          _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, idx, _M0MP36mizchi6kagura11transform3d11Transform3D14with__rotation(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, idx), q));
        }
        let v;
        _L$2: {
          _L$3: {
            const _bind = pose.translation;
            if (_bind === undefined) {
            } else {
              const _Some = _bind;
              const _v = _Some;
              v = _v;
              break _L$3;
            }
            break _L$2;
          }
          _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, idx, _M0MP36mizchi6kagura11transform3d11Transform3D14with__position(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, idx), v));
        }
        let v$2;
        _L$3: {
          _L$4: {
            const _bind = pose.scale;
            if (_bind === undefined) {
            } else {
              const _Some = _bind;
              const _v = _Some;
              v$2 = _v;
              break _L$4;
            }
            break _L$3;
          }
          _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, idx, _M0MP36mizchi6kagura11transform3d11Transform3D11with__scale(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura11transform3d11Transform3DE(t.local_poses, idx), v$2));
        }
      }
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const world_transforms = _M0MP36mizchi6kagura10skeleton3d8Skeleton26compute__world__transforms(t.skeleton, t.local_poses);
  return _M0MP36mizchi6kagura10skeleton3d8Skeleton27compute__skinning__matrices(t.skeleton, world_transforms);
}
function _M0MP26mizchi14skeletal__anim9DemoState4draw(self, ctx) {
  const objects = [];
  const _arr = self.tentacles;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const t = _arr[_i];
      const skinning_matrices = _M0FP26mizchi14skeletal__anim37compute__tentacle__skinning__matrices(t);
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura7scene3d8Object3DE(objects, _M0FP36mizchi6kagura7scene3d8object3d(t.bind_mesh, t.base_position, undefined, undefined, t.color, Option$None$9$, Option$None$10$, new Option$Some$11$(_M0MP36mizchi6kagura7scene3d13SkinningState17new__with__packed(t.skin_data, skinning_matrices, t.packed_vertex_data))));
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura7scene3d8Object3DE(objects, _M0FP36mizchi6kagura7scene3d8object3d(self.ground_mesh, _M0MP36mizchi6kagura6math3d4Vec33new(0, -0.05, 0), undefined, undefined, _M0MP36mizchi6kagura6math3d4Vec43new(0.4, 0.5, 0.35, 1), Option$None$9$, new Option$Some$10$(100), Option$None$11$));
  const camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera12to__camera3d(self.camera);
  const scene = _M0FP36mizchi6kagura7scene3d15scene3d_2einner(objects, camera, self.lighting);
  return _M0FP36mizchi6kagura7scene3d20render__scene3d__gpu(scene, ctx.dst, self.shader3d, ctx.screen_w, ctx.screen_h, Option$None$12$, Option$None$12$, Option$None$12$, new Option$Some$12$(self.shader3d_skinned));
}
function _M0FP26mizchi14skeletal__anim26build__tentacle__animation(phase_offset) {
  const channels = [];
  const _start54 = 1;
  const _end55 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp = _start54;
  while (true) {
    const bone_i = _tmp;
    if (bone_i < _end55) {
      const times = [];
      const values = [];
      const amplitude = 0.3 * (bone_i + 0) / ((_M0FP26mizchi14skeletal__anim10num__bones - 1 | 0) + 0);
      const freq = 6.28318530717958623 / _M0FP26mizchi14skeletal__anim14anim__duration;
      const _start63 = 0;
      const _end64 = _M0FP26mizchi14skeletal__anim14num__keyframes;
      let _tmp$2 = _start63;
      while (true) {
        const k = _tmp$2;
        if (k < _end64) {
          const t = (k + 0) / ((_M0FP26mizchi14skeletal__anim14num__keyframes - 1 | 0) + 0) * _M0FP26mizchi14skeletal__anim14anim__duration;
          _M0MP311moonbitlang4core5array5Array4pushGdE(times, t);
          const angle = amplitude * _M0FP311moonbitlang4core4math3sin(t * freq + phase_offset + (bone_i + 0) * 0.5);
          const half = angle / 2;
          const sx = _M0FP311moonbitlang4core4math3sin(half);
          const cx = _M0FP311moonbitlang4core4math3cos(half);
          _M0MP311moonbitlang4core5array5Array4pushGdE(values, 0);
          _M0MP311moonbitlang4core5array5Array4pushGdE(values, 0);
          _M0MP311moonbitlang4core5array5Array4pushGdE(values, sx);
          _M0MP311moonbitlang4core5array5Array4pushGdE(values, cx);
          _tmp$2 = k + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11animation3d11AnimChannelE(channels, { node_index: bone_i, target: 1, interpolation: 1, times: times, values: values });
      _tmp = bone_i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { name: "tentacle_wave", channels: channels, duration: _M0FP26mizchi14skeletal__anim14anim__duration };
}
function _M0FP26mizchi14skeletal__anim21build__tentacle__mesh() {
  const verts = [];
  const indices = [];
  const joint_indices = [];
  const weights = [];
  const vertex_count = { val: 0 };
  const _start79 = 1;
  const _end80 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp = _start79;
  while (true) {
    const bone_i = _tmp;
    if (bone_i < _end80) {
      const y_bottom = ((bone_i - 1 | 0) + 0) * _M0FP26mizchi14skeletal__anim12bone__length;
      const y_top = (bone_i + 0) * _M0FP26mizchi14skeletal__anim12bone__length;
      const taper = 1 - (bone_i + 0) / (_M0FP26mizchi14skeletal__anim10num__bones + 0) * 0.6;
      const r = _M0FP26mizchi14skeletal__anim16tentacle__radius * taper;
      const base_idx = vertex_count.val;
      const normals = [{ _0: 0, _1: 0, _2: 1 }, { _0: 1, _1: 0, _2: 0 }, { _0: 0, _1: 0, _2: -1 }, { _0: -1, _1: 0, _2: 0 }];
      const _start91 = 0;
      const _end92 = 4;
      let _tmp$2 = _start91;
      while (true) {
        const face = _tmp$2;
        if (face < _end92) {
          let ny;
          let nx;
          let nz;
          _L: {
            const _bind = _M0MP311moonbitlang4core5array5Array2atGUdddEE(normals, face);
            const _nx = _bind._0;
            const _ny = _bind._1;
            const _nz = _bind._2;
            ny = _ny;
            nx = _nx;
            nz = _nz;
            break _L;
          }
          let corners;
          switch (face) {
            case 0: {
              corners = [{ _0: -r, _1: y_bottom, _2: r }, { _0: r, _1: y_bottom, _2: r }, { _0: r, _1: y_top, _2: r }, { _0: -r, _1: y_top, _2: r }];
              break;
            }
            case 1: {
              corners = [{ _0: r, _1: y_bottom, _2: r }, { _0: r, _1: y_bottom, _2: -r }, { _0: r, _1: y_top, _2: -r }, { _0: r, _1: y_top, _2: r }];
              break;
            }
            case 2: {
              corners = [{ _0: r, _1: y_bottom, _2: -r }, { _0: -r, _1: y_bottom, _2: -r }, { _0: -r, _1: y_top, _2: -r }, { _0: r, _1: y_top, _2: -r }];
              break;
            }
            default: {
              corners = [{ _0: -r, _1: y_bottom, _2: -r }, { _0: -r, _1: y_bottom, _2: r }, { _0: -r, _1: y_top, _2: r }, { _0: -r, _1: y_top, _2: -r }];
            }
          }
          const _start100 = 0;
          const _end101 = 4;
          let _tmp$3 = _start100;
          while (true) {
            const ci = _tmp$3;
            if (ci < _end101) {
              let py;
              let px;
              let pz;
              _L$2: {
                const _bind = _M0MP311moonbitlang4core5array5Array2atGUdddEE(corners, ci);
                const _px = _bind._0;
                const _py = _bind._1;
                const _pz = _bind._2;
                py = _py;
                px = _px;
                pz = _pz;
                break _L$2;
              }
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, px);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, py);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, pz);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, nx);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, 0);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, nz);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, ci === 0 || ci === 3 ? 0 : 1);
              _M0MP311moonbitlang4core5array5Array4pushGdE(verts, ci < 2 ? 0 : 1);
              const assigned_bone = ci < 2 ? ((bone_i - 1 | 0) > 0 ? bone_i - 1 | 0 : 0) : bone_i;
              _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, assigned_bone);
              _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, 0);
              _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, 0);
              _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, 0);
              _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 1);
              _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 0);
              _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 0);
              _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 0);
              vertex_count.val = vertex_count.val + 1 | 0;
              _tmp$3 = ci + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          const fi = base_idx + (Math.imul(face, 4) | 0) | 0;
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, fi);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, fi + 1 | 0);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, fi + 2 | 0);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, fi);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, fi + 2 | 0);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, fi + 3 | 0);
          _tmp$2 = face + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = bone_i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const y_top = ((_M0FP26mizchi14skeletal__anim10num__bones - 1 | 0) + 0) * _M0FP26mizchi14skeletal__anim12bone__length;
  const taper_top = 1 - ((_M0FP26mizchi14skeletal__anim10num__bones - 1 | 0) + 0) / (_M0FP26mizchi14skeletal__anim10num__bones + 0) * 0.6;
  const r_top = _M0FP26mizchi14skeletal__anim16tentacle__radius * taper_top;
  const cap_base = vertex_count.val;
  const cap_corners = [{ _0: -r_top, _1: y_top, _2: -r_top }, { _0: r_top, _1: y_top, _2: -r_top }, { _0: r_top, _1: y_top, _2: r_top }, { _0: -r_top, _1: y_top, _2: r_top }];
  const _start115 = 0;
  const _end116 = 4;
  let _tmp$2 = _start115;
  while (true) {
    const ci = _tmp$2;
    if (ci < _end116) {
      let py;
      let px;
      let pz;
      _L: {
        const _bind = _M0MP311moonbitlang4core5array5Array2atGUdddEE(cap_corners, ci);
        const _px = _bind._0;
        const _py = _bind._1;
        const _pz = _bind._2;
        py = _py;
        px = _px;
        pz = _pz;
        break _L;
      }
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, px);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, py);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, pz);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, 0);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, 1);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, 0);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, ci === 0 || ci === 3 ? 0 : 1);
      _M0MP311moonbitlang4core5array5Array4pushGdE(verts, ci < 2 ? 0 : 1);
      _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, _M0FP26mizchi14skeletal__anim10num__bones - 1 | 0);
      _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, 0);
      _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, 0);
      _M0MP311moonbitlang4core5array5Array4pushGiE(joint_indices, 0);
      _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 1);
      _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 0);
      _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 0);
      _M0MP311moonbitlang4core5array5Array4pushGdE(weights, 0);
      vertex_count.val = vertex_count.val + 1 | 0;
      _tmp$2 = ci + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, cap_base);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, cap_base + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, cap_base + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, cap_base);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, cap_base + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, cap_base + 3 | 0);
  const mesh = _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(verts, indices);
  const skin = { joint_indices: joint_indices, weights: weights, vertex_count: vertex_count.val };
  return { _0: mesh, _1: skin };
}
function _M0FP26mizchi14skeletal__anim25build__tentacle__skeleton() {
  const bones = [];
  const ibms = [];
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura10skeleton3d4BoneE(bones, { name: "root", parent: -1, local_transform: _M0MP36mizchi6kagura11transform3d11Transform3D3new() });
  const _start127 = 1;
  const _end128 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp = _start127;
  while (true) {
    const i = _tmp;
    if (i < _end128) {
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura10skeleton3d4BoneE(bones, { name: `bone_${_M0MP311moonbitlang4core3int3Int18to__string_2einner(i, 10)}`, parent: i - 1 | 0, local_transform: _M0MP36mizchi6kagura11transform3d11Transform3D14from__position(_M0MP36mizchi6kagura6math3d4Vec33new(0, _M0FP26mizchi14skeletal__anim12bone__length, 0)) });
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const rest_poses = [];
  const _start133 = 0;
  const _end134 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp$2 = _start133;
  while (true) {
    const i = _tmp$2;
    if (i < _end134) {
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11transform3d11Transform3DE(rest_poses, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura10skeleton3d4BoneE(bones, i).local_transform);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const world_mats = _M0MP311moonbitlang4core5array5Array4makeGRP36mizchi6kagura6math3d4Mat4E(_M0FP26mizchi14skeletal__anim10num__bones, _M0MP36mizchi6kagura6math3d4Mat48identity());
  const _start139 = 0;
  const _end140 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp$3 = _start139;
  while (true) {
    const i = _tmp$3;
    if (i < _end140) {
      const local_mat = _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura11transform3d11Transform3DE(rest_poses, i));
      const parent = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura10skeleton3d4BoneE(bones, i).parent;
      if (parent < 0) {
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura6math3d4Mat4E(world_mats, i, local_mat);
      } else {
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura6math3d4Mat4E(world_mats, i, _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(world_mats, parent), local_mat));
      }
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _start146 = 0;
  const _end147 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp$4 = _start146;
  while (true) {
    const i = _tmp$4;
    if (i < _end147) {
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura6math3d4Mat4E(ibms, _M0MP36mizchi6kagura6math3d4Mat47inverse(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6math3d4Mat4E(world_mats, i)));
      _tmp$4 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MP36mizchi6kagura10skeleton3d8Skeleton3new(bones, ibms);
}
function _M0FP26mizchi14skeletal__anim16create__tentacle(position, color, phase) {
  const skeleton = _M0FP26mizchi14skeletal__anim25build__tentacle__skeleton();
  let bind_mesh;
  let skin_data;
  _L: {
    const _bind = _M0FP26mizchi14skeletal__anim21build__tentacle__mesh();
    const _bind_mesh = _bind._0;
    const _skin_data = _bind._1;
    bind_mesh = _bind_mesh;
    skin_data = _skin_data;
    break _L;
  }
  const packed_vertex_data = _M0FP36mizchi6kagura10skeleton3d28build__skinned__vertex__data(bind_mesh, skin_data);
  const clip = _M0FP26mizchi14skeletal__anim26build__tentacle__animation(phase);
  const player = _M0MP36mizchi6kagura11animation3d15AnimationPlayer3new(clip);
  const local_poses = [];
  const _start47 = 0;
  const _end48 = _M0FP26mizchi14skeletal__anim10num__bones;
  let _tmp = _start47;
  while (true) {
    const i = _tmp;
    if (i < _end48) {
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura11transform3d11Transform3DE(local_poses, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura10skeleton3d4BoneE(skeleton.bones, i).local_transform);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { skeleton: skeleton, bind_mesh: bind_mesh, skin_data: skin_data, packed_vertex_data: packed_vertex_data, player: player, base_position: position, color: color, local_poses: local_poses };
}
function _M0MP26mizchi14skeletal__anim9DemoState3new() {
  const camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(_M0MP36mizchi6kagura6math3d4Vec33new(0, 1, 0), 6, 0.3, 0.5, 0.785398163397448279, (_M0FP26mizchi14skeletal__anim9screen__w + 0) / (_M0FP26mizchi14skeletal__anim9screen__h + 0), 0.1, 100);
  const lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(-0.5, -1, -0.3), _M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 1), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 0.3), Option$None$7$, Option$None$8$);
  const tentacles = [_M0FP26mizchi14skeletal__anim16create__tentacle(_M0MP36mizchi6kagura6math3d4Vec33new(0, 0, 0), _M0MP36mizchi6kagura6math3d4Vec43new(0.2, 0.8, 0.3, 1), 0), _M0FP26mizchi14skeletal__anim16create__tentacle(_M0MP36mizchi6kagura6math3d4Vec33new(-1.5, 0, -0.5), _M0MP36mizchi6kagura6math3d4Vec43new(0.8, 0.3, 0.2, 1), 2), _M0FP26mizchi14skeletal__anim16create__tentacle(_M0MP36mizchi6kagura6math3d4Vec33new(1.5, 0, 0.5), _M0MP36mizchi6kagura6math3d4Vec43new(0.3, 0.4, 0.9, 1), 4)];
  return { tentacles: tentacles, ground_mesh: _M0MP36mizchi6kagura6mesh3d6Mesh3D13plane_2einner(12, 12, 4), camera: camera, lighting: lighting, input: _M0FP36mizchi6kagura9inpututil18new__input__helper(), shader3d: _M0FP36mizchi6kagura3gfx19new__shader__handle(10, _M0FP36mizchi6kagura6draw3d31shader3d__lit__untextured__wgsl()), shader3d_skinned: _M0FP36mizchi6kagura3gfx19new__shader__handle(11, _M0FP36mizchi6kagura6draw3d28shader3d__lit__skinned__wgsl()), frame: 0 };
}
function _M0MP26mizchi14skeletal__anim9DemoState6update(self, snapshot) {
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, snapshot);
  self.frame = self.frame + 1 | 0;
  self.camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self.camera, 0.003, 0);
  const dt = 0.0166666666666666664;
  const _arr = self.tentacles;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const t = _arr[_i];
      _M0MP36mizchi6kagura11animation3d15AnimationPlayer6update(t.player, dt);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
(() => {
  const state = _M0MP26mizchi14skeletal__anim9DemoState3new();
  _M0FP36mizchi6kagura6engine11run_2einner((input) => {
    _M0MP26mizchi14skeletal__anim9DemoState6update(state, input);
  }, (ctx) => _M0MP26mizchi14skeletal__anim9DemoState4draw(state, ctx), undefined, undefined, undefined, 735, _M0FP26mizchi14skeletal__anim9screen__w, _M0FP26mizchi14skeletal__anim9screen__h, "Skeletal Animation Demo", "#app");
})();
//# sourceMappingURL=skeletal_anim.js.map
