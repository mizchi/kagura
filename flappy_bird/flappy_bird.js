const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $f32_reinterpret_i32(a) {
  $reinterpret_view.setInt32(0, a, true);
  return $reinterpret_view.getFloat32(0, true);
}
const Option$None$0$ = { $tag: 0, $name: "None" };
function Option$Some$0$(param0) {
  this._0 = param0;
}
Option$Some$0$.prototype.$tag = 1;
Option$Some$0$.prototype.$name = "Some";
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
const Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$IndexOutOfBounds = { $tag: 1, $name: "moonbitlang/core/builtin.CreatingViewError.IndexOutOfBounds" };
const Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$InvalidIndex = { $tag: 0, $name: "moonbitlang/core/builtin.CreatingViewError.InvalidIndex" };
const _M0FP311moonbitlang4core7builtin19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
const _M0MP311moonbitlang4core7builtin7JSArray4push = (arr, val) => { arr.push(val); };
const _M0MP311moonbitlang4core7builtin7JSArray3pop = (arr) => arr.pop();
const _M0MP311moonbitlang4core7builtin7JSArray6splice = (arr, idx, cnt) => arr.splice(idx, cnt);
function $i32_reinterpret_f32(a) {
  $reinterpret_view.setFloat32(0, a, true);
  return $reinterpret_view.getInt32(0, true);
}
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
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function Result$Err$3$(param0) {
  this._0 = param0;
}
Result$Err$3$.prototype.$tag = 0;
Result$Err$3$.prototype.$name = "Err";
function Result$Ok$3$(param0) {
  this._0 = param0;
}
Result$Ok$3$.prototype.$tag = 1;
Result$Ok$3$.prototype.$name = "Ok";
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Copy = { $tag: 0, $name: "Copy" };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Alpha = { $tag: 1, $name: "Alpha" };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Add = { $tag: 2, $name: "Add" };
const $64$mizchi$47$kagura$47$gfx$46$BlendMode$Multiply = { $tag: 3, $name: "Multiply" };
function $64$mizchi$47$kagura$47$gfx$46$BlendMode$Custom(param0) {
  this._0 = param0;
}
$64$mizchi$47$kagura$47$gfx$46$BlendMode$Custom.prototype.$tag = 4;
$64$mizchi$47$kagura$47$gfx$46$BlendMode$Custom.prototype.$name = "Custom";
const Option$None$4$ = { $tag: 0, $name: "None" };
function Option$Some$4$(param0) {
  this._0 = param0;
}
Option$Some$4$.prototype.$tag = 1;
Option$Some$4$.prototype.$name = "Some";
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
function Result$Err$6$(param0) {
  this._0 = param0;
}
Result$Err$6$.prototype.$tag = 0;
Result$Err$6$.prototype.$name = "Err";
function Result$Ok$6$(param0) {
  this._0 = param0;
}
Result$Ok$6$.prototype.$tag = 1;
Result$Ok$6$.prototype.$name = "Ok";
const _M0FP36mizchi6kagura6engine29js__request__animation__frame = (f) => { requestAnimationFrame(() => f()); };
const _M0FP36mizchi6kagura6engine20js__on__beforeunload = (f) => { window.addEventListener("beforeunload", () => f()); };
const _M0FP36mizchi6kagura6engine20js__performance__now = () => (globalThis.performance?.now?.() ?? Date.now());
function $64$mizchi$47$signals$47$ui$46$Node$Element$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$Element$7$.prototype.$tag = 0;
$64$mizchi$47$signals$47$ui$46$Node$Element$7$.prototype.$name = "Element";
function $64$mizchi$47$signals$47$ui$46$Node$Text$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$Text$7$.prototype.$tag = 1;
$64$mizchi$47$signals$47$ui$46$Node$Text$7$.prototype.$name = "Text";
function $64$mizchi$47$signals$47$ui$46$Node$DynamicText$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$DynamicText$7$.prototype.$tag = 2;
$64$mizchi$47$signals$47$ui$46$Node$DynamicText$7$.prototype.$name = "DynamicText";
function $64$mizchi$47$signals$47$ui$46$Node$Fragment$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$Fragment$7$.prototype.$tag = 3;
$64$mizchi$47$signals$47$ui$46$Node$Fragment$7$.prototype.$name = "Fragment";
function $64$mizchi$47$signals$47$ui$46$Node$Show$7$(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
$64$mizchi$47$signals$47$ui$46$Node$Show$7$.prototype.$tag = 4;
$64$mizchi$47$signals$47$ui$46$Node$Show$7$.prototype.$name = "Show";
function $64$mizchi$47$signals$47$ui$46$Node$For$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$For$7$.prototype.$tag = 5;
$64$mizchi$47$signals$47$ui$46$Node$For$7$.prototype.$name = "For";
function $64$mizchi$47$signals$47$ui$46$Node$Component$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$Component$7$.prototype.$tag = 6;
$64$mizchi$47$signals$47$ui$46$Node$Component$7$.prototype.$name = "Component";
function $64$mizchi$47$signals$47$ui$46$Node$Async$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$Async$7$.prototype.$tag = 7;
$64$mizchi$47$signals$47$ui$46$Node$Async$7$.prototype.$name = "Async";
function $64$mizchi$47$signals$47$ui$46$Node$ErrorBoundary$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$ErrorBoundary$7$.prototype.$tag = 8;
$64$mizchi$47$signals$47$ui$46$Node$ErrorBoundary$7$.prototype.$name = "ErrorBoundary";
function $64$mizchi$47$signals$47$ui$46$Node$Switch$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$Switch$7$.prototype.$tag = 9;
$64$mizchi$47$signals$47$ui$46$Node$Switch$7$.prototype.$name = "Switch";
function $64$mizchi$47$signals$47$ui$46$Node$RawHtml$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Node$RawHtml$7$.prototype.$tag = 10;
$64$mizchi$47$signals$47$ui$46$Node$RawHtml$7$.prototype.$name = "RawHtml";
function $64$mizchi$47$signals$47$ui$46$Attr$VStatic$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Attr$VStatic$7$.prototype.$tag = 0;
$64$mizchi$47$signals$47$ui$46$Attr$VStatic$7$.prototype.$name = "VStatic";
function $64$mizchi$47$signals$47$ui$46$Attr$VDynamic$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Attr$VDynamic$7$.prototype.$tag = 1;
$64$mizchi$47$signals$47$ui$46$Attr$VDynamic$7$.prototype.$name = "VDynamic";
function $64$mizchi$47$signals$47$ui$46$Attr$VHandler$7$(param0) {
  this._0 = param0;
}
$64$mizchi$47$signals$47$ui$46$Attr$VHandler$7$.prototype.$tag = 2;
$64$mizchi$47$signals$47$ui$46$Attr$VHandler$7$.prototype.$name = "VHandler";
function $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt(param0) {
  this._0 = param0;
}
$64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt.prototype.$tag = 0;
$64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt.prototype.$name = "SceneInt";
function $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(param0) {
  this._0 = param0;
}
$64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble.prototype.$tag = 1;
$64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble.prototype.$name = "SceneDouble";
function $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneText(param0) {
  this._0 = param0;
}
$64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneText.prototype.$tag = 2;
$64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneText.prototype.$name = "SceneText";
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
const _M0FP26mizchi7signals17reactive__context = { current_owner: undefined, current_cleanups: Option$None$0$, batch_depth: 0 };
const _M0FP26mizchi7signals15callback__queue = [];
const _M0FP26mizchi7signals22callback__queue__nodes = [];
const _M0FP26mizchi12flappy__bird9screen__h = 240;
const _M0FP26mizchi12flappy__bird9screen__w = 320;
const _M0FP26mizchi12flappy__bird10bird__size = 12;
const _M0FP26mizchi12flappy__bird7bird__x = 60;
const _M0FP26mizchi12flappy__bird7gravity = 0.25;
const _M0FP26mizchi12flappy__bird9ground__h = 20;
const _M0FP26mizchi12flappy__bird14jump__velocity = -4.5;
const _M0FP26mizchi12flappy__bird9pipe__gap = 70;
const _M0FP26mizchi12flappy__bird14pipe__interval = 120;
const _M0FP26mizchi12flappy__bird11pipe__speed = 1.5;
const _M0FP26mizchi12flappy__bird11pipe__width = 36;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f402 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FP36mizchi6kagura8platform18web__canvas__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura8platform14WebCanvasHooksE(_M0FP36mizchi6kagura8platform27default__web__canvas__hooks());
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MP311moonbitlang4core3ref3Ref3newGWEdE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx19NativeGraphicsHooksE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
const _M0FP36mizchi6kagura3gfx20web__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx16WebGraphicsHooksE(_M0FP36mizchi6kagura3gfx29default__web__graphics__hooks());
const _M0FP26mizchi7signals12batch__depth = _M0MP311moonbitlang4core3ref3Ref3newGiE(0);
const _M0FP26mizchi7signals6queued = _M0MP311moonbitlang4core5array5Array4makeGORP26mizchi7signals10EffectNodeE(1024, undefined);
const _M0FP26mizchi7signals11active__sub = _M0MP311moonbitlang4core3ref3Ref3newGORP26mizchi7signals12ReactiveNodeE(undefined);
const _M0FP26mizchi7signals5cycle = _M0MP311moonbitlang4core3ref3Ref3newGiE(0);
const _M0FP26mizchi7signals13notify__index = _M0MP311moonbitlang4core3ref3Ref3newGiE(0);
const _M0FP26mizchi7signals14queued__length = _M0MP311moonbitlang4core3ref3Ref3newGiE(0);
function _M0FP311moonbitlang4core5abort5abortGWEuE(msg) {
  return $panic();
}
function _M0FP311moonbitlang4core5abort5abortGRP26mizchi7signals12ReactiveNodeE(msg) {
  return $panic();
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
function _M0FP311moonbitlang4core7builtin5abortGWEuE(string, loc) {
  return _M0FP311moonbitlang4core5abort5abortGWEuE(`${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(string)}\n  at ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(loc)}\n`);
}
function _M0FP311moonbitlang4core7builtin5abortGRP26mizchi7signals12ReactiveNodeE(string, loc) {
  return _M0FP311moonbitlang4core5abort5abortGRP26mizchi7signals12ReactiveNodeE(`${_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(string)}\n  at ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(loc)}\n`);
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
function _M0MP311moonbitlang4core6uint166UInt1622is__leading__surrogate(self) {
  return _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__geGkE(self, 55296) && _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__leGkE(self, 56319);
}
function _M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__leGkE(self, 57343);
}
function _M0FP311moonbitlang4core7builtin32code__point__of__surrogate__pair(leading, trailing) {
  return (((Math.imul(leading - 55296 | 0, 1024) | 0) + trailing | 0) - 56320 | 0) + 65536 | 0;
}
function _M0MP311moonbitlang4core6uint166UInt1616unsafe__to__char(self) {
  return self;
}
function _M0MP311moonbitlang4core5array5Array2atGRP26mizchi12flappy__bird4PipeE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGORP26mizchi7signals10EffectNodeE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(self, index) {
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
function _M0MP311moonbitlang4core5array5Array2atGdE(self, index) {
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
function _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGRP26mizchi5audio10VoiceStateE(x, y) {
  return !_M0IP26mizchi5audio10VoiceStateP311moonbitlang4core7builtin2Eq5equal(x, y);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__leGkE(x, y) {
  return _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__geGkE(x, y) {
  return _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(x, y) >= 0;
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
      return new Result$Err$1$(Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$InvalidIndex);
    }
    if (end$2 < len && _M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      return new Result$Err$1$(Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$InvalidIndex);
    }
    return new Result$Ok$1$({ str: self, start: start$2, end: end$2 });
  } else {
    return new Result$Err$1$(Error$moonbitlang$47$core$47$builtin$46$CreatingViewError$46$IndexOutOfBounds);
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
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin9SourceLocE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core7builtin9SourceLocP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin17CreatingViewErrorE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core7builtin17CreatingViewErrorP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0MP311moonbitlang4core7builtin4Iter4nextGcE(self) {
  const _func = self;
  return _func();
}
function _M0MP311moonbitlang4core3int3Int18to__string_2einner(self, radix) {
  return _M0FP311moonbitlang4core7builtin19int__to__string__js(self, radix);
}
function _M0MP311moonbitlang4core7builtin4Iter3newGcE(f) {
  return f;
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
function _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__view(self, str) {
  const _bind = self;
  _bind.val = `${_bind.val}${_M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(str)}`;
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi12flappy__bird4PipeE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGiE(self, value) {
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
function _M0MP311moonbitlang4core5array5Array4pushGUORP26mizchi7signals4LinkORP26mizchi7signals4LinkEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGWEuE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi7signals12ReactiveNodeE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi5audio5VoiceE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGdE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core6string6String4iter(self) {
  const len = self.length;
  const index = { val: 0 };
  return _M0MP311moonbitlang4core7builtin4Iter3newGcE(() => {
    if (index.val < len) {
      const c1 = self.charCodeAt(index.val);
      if (_M0MP311moonbitlang4core6uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < len) {
        const c2 = self.charCodeAt(index.val + 1 | 0);
        if (_M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(c2)) {
          const c = _M0FP311moonbitlang4core7builtin32code__point__of__surrogate__pair(c1, c2);
          index.val = index.val + 2 | 0;
          return c;
        }
      }
      index.val = index.val + 1 | 0;
      return _M0MP311moonbitlang4core6uint166UInt1616unsafe__to__char(c1);
    } else {
      return -1;
    }
  });
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
function _M0MP311moonbitlang4core5array5Array4makeGORP26mizchi7signals10EffectNodeE(len, elem) {
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
function _M0MP311moonbitlang4core5array5Array3setGORP26mizchi7signals10EffectNodeE(self, index, value) {
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
function _M0MP311moonbitlang4core7builtin7MyInt643lsr(self, shift) {
  const shift$2 = shift & 63;
  return shift$2 === 0 ? self : shift$2 < 32 ? { hi: self.hi >>> shift$2 | 0, lo: self.lo >>> shift$2 | 0 | self.hi << (32 - shift$2 | 0) } : { hi: 0, lo: self.hi >>> (shift$2 - 32 | 0) | 0 };
}
function _M0MP311moonbitlang4core7builtin7MyInt648to__uint(self) {
  return self.lo;
}
function _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Mul3mul(self, other) {
  return _M0IP311moonbitlang4core7builtin7MyInt64P311moonbitlang4core7builtin3Mul3mul(self, other);
}
function _M0MP311moonbitlang4core6uint646UInt648to__uint(self) {
  return _M0MP311moonbitlang4core7builtin7MyInt648to__uint(self);
}
function _M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(self, shift) {
  return _M0MP311moonbitlang4core7builtin7MyInt643lsr(self, shift);
}
function _M0MP311moonbitlang4core6double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
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
function _M0MP311moonbitlang4core5array5Array11unsafe__popGUORP26mizchi7signals4LinkORP26mizchi7signals4LinkEE(self) {
  return _M0MP311moonbitlang4core7builtin7JSArray3pop(self);
}
function _M0MP311moonbitlang4core5array5Array3popGUORP26mizchi7signals4LinkORP26mizchi7signals4LinkEE(self) {
  if (self.length === 0) {
    return undefined;
  } else {
    const v = _M0MP311moonbitlang4core5array5Array11unsafe__popGUORP26mizchi7signals4LinkORP26mizchi7signals4LinkEE(self);
    return v;
  }
}
function _M0MP311moonbitlang4core5array5Array6removeGWEuE(self, index) {
  if (index >= 0 && index < self.length) {
    $bound_check(self, index);
    const value = self[index];
    _M0MP311moonbitlang4core7builtin7JSArray6splice(self, index, 1);
    return value;
  } else {
    return _M0FP311moonbitlang4core7builtin5abortGWEuE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(self.length)} but the index is ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:arraycore_js.mbt:251:5-253:6");
  }
}
function _M0MP311moonbitlang4core5array5Array6removeGRP26mizchi7signals12ReactiveNodeE(self, index) {
  if (index >= 0 && index < self.length) {
    $bound_check(self, index);
    const value = self[index];
    _M0MP311moonbitlang4core7builtin7JSArray6splice(self, index, 1);
    return value;
  } else {
    return _M0FP311moonbitlang4core7builtin5abortGRP26mizchi7signals12ReactiveNodeE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(self.length)} but the index is ${_M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:arraycore_js.mbt:251:5-253:6");
  }
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
function _M0MP311moonbitlang4core3ref3Ref3newGORP26mizchi7signals4LinkE(x) {
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
function _M0MP311moonbitlang4core3ref3Ref3newGORP26mizchi7signals12ReactiveNodeE(x) {
  return { val: x };
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
  let hi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f402, ind);
  let mi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f402, ind + 1 | 0);
  let lo = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f402, ind + 2 | 0);
  const tp = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f402, ind + 3 | 0);
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
function _M0FP36mizchi6kagura9inpututil30is__any__action__just__pressed(helper, _input) {
  return helper.key_state.just_pressed_keys.length > 0 || (helper.mouse_state.just_pressed_buttons.length > 0 || helper.touch_state.just_pressed_touch_ids.length > 0);
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
  return new Result$Ok$3$(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : { kind: 1, opaque_id: 2, width: self.options.width, height: self.options.height, device_scale_factor: 1 });
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
  return Option$None$4$;
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
  return Option$None$4$;
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
  return new Result$Ok$5$({ id: self.next_id, width: width, height: height });
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver11new__shader(self, source) {
  self.next_id = self.next_id + 1 | 0;
  return new Result$Ok$6$({ id: self.next_id, source: source });
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(self, command) {
  if (self.initialized) {
    self.draw_count = self.draw_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx16native__on__draw(self.native_active, command);
    _M0FP36mizchi6kagura3gfx23web__graphics__on__draw(self.web_active, self.backend, command);
  }
  return new Result$Ok$2$(undefined);
}
function _M0MP36mizchi6kagura6vector4Vec23new(x, y) {
  return { x: x, y: y };
}
function _M0MP36mizchi6kagura6vector4Vec215length__squared(self) {
  return self.x * self.x + self.y * self.y;
}
function _M0MP36mizchi6kagura6vector4Vec26length(self) {
  return Math.sqrt(_M0MP36mizchi6kagura6vector4Vec215length__squared(self));
}
function _M0MP36mizchi6kagura6vector4Vec25scale(self, s) {
  return { x: self.x * s, y: self.y * s };
}
function _M0MP36mizchi6kagura6vector4Vec24zero() {
  return { x: 0, y: 0 };
}
function _M0MP36mizchi6kagura6vector4Vec29normalize(self) {
  const len = _M0MP36mizchi6kagura6vector4Vec26length(self);
  return len < 1e-12 ? _M0MP36mizchi6kagura6vector4Vec24zero() : _M0MP36mizchi6kagura6vector4Vec25scale(self, 1 / len);
}
function _M0MP36mizchi6kagura6vector4Vec213perpendicular(self) {
  return { x: -self.y, y: self.x };
}
function _M0FP36mizchi6kagura9debugutil23color__from__hex__alpha(hex, alpha) {
  const r = ((hex >> 16 & 255) + 0) / 255;
  const g = ((hex >> 8 & 255) + 0) / 255;
  const b = ((hex & 255) + 0) / 255;
  return _M0FP36mizchi6kagura3gfx10new__color(r, g, b, alpha);
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
  return [_M0MP311moonbitlang4core6double6Double7to__int(color.r * 255), _M0MP311moonbitlang4core6double6Double7to__int(color.g * 255), _M0MP311moonbitlang4core6double6Double7to__int(color.b * 255), _M0MP311moonbitlang4core6double6Double7to__int(color.a * 255)];
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
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, _M0MP311moonbitlang4core6double6Double7to__int(screen_w), _M0MP311moonbitlang4core6double6Double7to__int(screen_h), 6)], 0, pipeline_id, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), vertices, indices, [], uniform, 1, 0);
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
      const pattern = _M0FP36mizchi6kagura9debugutil14glyph__pattern(_M0MP311moonbitlang4core5array5Array2atGiE(chars, i));
      const ox = start_x + (i + 0) * (char_w + gap);
      let _tmp$2 = 0;
      while (true) {
        const row = _tmp$2;
        if (row < 5) {
          let _tmp$3 = 0;
          while (true) {
            const col = _tmp$3;
            if (col < 3) {
              if (_M0MP311moonbitlang4core5array5Array2atGiE(pattern, (Math.imul(row, 3) | 0) + col | 0) === 1) {
                const x = ox + (col + 0) * px_size;
                const y = start_y + (row + 0) * px_size;
                _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(dst, shader, x, y, px_size, px_size, sw, sh, color, 0));
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
function _M0FP36mizchi6kagura9debugutil16color__from__hex(hex) {
  const r = ((hex >> 16 & 255) + 0) / 255;
  const g = ((hex >> 8 & 255) + 0) / 255;
  const b = ((hex & 255) + 0) / 255;
  return _M0FP36mizchi6kagura3gfx10new__color(r, g, b, 1);
}
function _M0FP36mizchi6kagura9debugutil14line__vertices(x0, y0, x1, y1, width) {
  const dx = x1 - x0;
  const dy = y1 - y0;
  const dir = _M0MP36mizchi6kagura6vector4Vec29normalize(_M0MP36mizchi6kagura6vector4Vec23new(dx, dy));
  const perp = _M0MP36mizchi6kagura6vector4Vec25scale(_M0MP36mizchi6kagura6vector4Vec213perpendicular(dir), width / 2);
  const vertices = [x0 + perp.x, y0 + perp.y, 0, 0, x1 + perp.x, y1 + perp.y, 1, 0, x1 - perp.x, y1 - perp.y, 1, 1, x0 - perp.x, y0 - perp.y, 0, 1];
  const indices = [0, 1, 2, 2, 3, 0];
  return { _0: vertices, _1: indices };
}
function _M0FP36mizchi6kagura9debugutil23rect__outline__vertices(x, y, w, h, line_width) {
  const all_vertices = [];
  const all_indices = [];
  const lines = [{ _0: x, _1: y, _2: x + w, _3: y }, { _0: x + w, _1: y, _2: x + w, _3: y + h }, { _0: x + w, _1: y + h, _2: x, _3: y + h }, { _0: x, _1: y + h, _2: x, _3: y }];
  const base_index = { val: 0 };
  const _arr = lines;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const line = _arr[_i];
      let x1;
      let x0;
      let y0;
      let y1;
      _L: {
        const _x0 = line._0;
        const _y0 = line._1;
        const _x1 = line._2;
        const _y1 = line._3;
        x1 = _x1;
        x0 = _x0;
        y0 = _y0;
        y1 = _y1;
        break _L;
      }
      let verts;
      let idxs;
      _L$2: {
        const _bind = _M0FP36mizchi6kagura9debugutil14line__vertices(x0, y0, x1, y1, line_width);
        const _verts = _bind._0;
        const _idxs = _bind._1;
        verts = _verts;
        idxs = _idxs;
        break _L$2;
      }
      const _arr$2 = verts;
      const _len$2 = _arr$2.length;
      let _tmp$2 = 0;
      while (true) {
        const _i$2 = _tmp$2;
        if (_i$2 < _len$2) {
          const v = _arr$2[_i$2];
          _M0MP311moonbitlang4core5array5Array4pushGdE(all_vertices, v);
          _tmp$2 = _i$2 + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const _arr$3 = idxs;
      const _len$3 = _arr$3.length;
      let _tmp$3 = 0;
      while (true) {
        const _i$2 = _tmp$3;
        if (_i$2 < _len$3) {
          const idx = _arr$3[_i$2];
          _M0MP311moonbitlang4core5array5Array4pushGiE(all_indices, idx + base_index.val | 0);
          _tmp$3 = _i$2 + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      base_index.val = base_index.val + 4 | 0;
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { _0: all_vertices, _1: all_indices };
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
function _M0FP36mizchi7signals2ui1hGuRP36mizchi6kagura5scene14SceneAttrValueE(tag, attrs, children) {
  return new $64$mizchi$47$signals$47$ui$46$Node$Element$7$({ tag: tag, attrs: attrs, children: children });
}
function _M0FP36mizchi7signals2ui8fragmentGuRP36mizchi6kagura5scene14SceneAttrValueE(children) {
  return new $64$mizchi$47$signals$47$ui$46$Node$Fragment$7$(children);
}
function _M0FP36mizchi7signals2ui4showGuRP36mizchi6kagura5scene14SceneAttrValueE(when, child) {
  return new $64$mizchi$47$signals$47$ui$46$Node$Show$7$(when, child);
}
function _M0FP36mizchi7signals2ui9for__eachGuRP36mizchi6kagura5scene14SceneAttrValueE(items) {
  return new $64$mizchi$47$signals$47$ui$46$Node$For$7$(items);
}
function _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(value) {
  return new $64$mizchi$47$signals$47$ui$46$Attr$VStatic$7$(value);
}
function _M0FP36mizchi6kagura5scene13resolve__attr(attr) {
  let f;
  _L: {
    switch (attr.$tag) {
      case 0: {
        const _VStatic = attr;
        const _value = _VStatic._0;
        return _value;
      }
      case 1: {
        const _VDynamic = attr;
        const _f = _VDynamic._0;
        f = _f;
        break _L;
      }
      default: {
        return new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(0);
      }
    }
  }
  return f();
}
function _M0FP36mizchi6kagura5scene12attr__double(attr, default_) {
  let v;
  _L: {
    const _bind = _M0FP36mizchi6kagura5scene13resolve__attr(attr);
    switch (_bind.$tag) {
      case 1: {
        const _SceneDouble = _bind;
        const _v = _SceneDouble._0;
        return _v;
      }
      case 0: {
        const _SceneInt = _bind;
        const _v$2 = _SceneInt._0;
        v = _v$2;
        break _L;
      }
      default: {
        return default_;
      }
    }
  }
  return v + 0;
}
function _M0FP36mizchi6kagura5scene9attr__int(attr, default_) {
  let v;
  _L: {
    const _bind = _M0FP36mizchi6kagura5scene13resolve__attr(attr);
    switch (_bind.$tag) {
      case 0: {
        const _SceneInt = _bind;
        const _v = _SceneInt._0;
        return _v;
      }
      case 1: {
        const _SceneDouble = _bind;
        const _v$2 = _SceneDouble._0;
        v = _v$2;
        break _L;
      }
      default: {
        return default_;
      }
    }
  }
  return _M0MP311moonbitlang4core6double6Double7to__int(v);
}
function _M0FP36mizchi6kagura5scene12attr__string(attr, default_) {
  const _bind = _M0FP36mizchi6kagura5scene13resolve__attr(attr);
  if (_bind.$tag === 2) {
    const _SceneText = _bind;
    const _v = _SceneText._0;
    return _v;
  } else {
    return default_;
  }
}
function _M0FP36mizchi6kagura5scene23string__to__char__codes(s) {
  const codes = [];
  const _it = _M0MP311moonbitlang4core6string6String4iter(s);
  while (true) {
    let ch;
    _L: {
      const _bind = _M0MP311moonbitlang4core7builtin4Iter4nextGcE(_it);
      if (_bind === -1) {
        break;
      } else {
        const _Some = _bind;
        const _ch = _Some;
        ch = _ch;
        break _L;
      }
    }
    const code = ch;
    if (code >= 48 && code <= 57) {
      _M0MP311moonbitlang4core5array5Array4pushGiE(codes, code - 48 | 0);
    } else {
      _M0MP311moonbitlang4core5array5Array4pushGiE(codes, code);
    }
    continue;
  }
  return codes;
}
function _M0FP36mizchi6kagura5scene13render__label(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  const attrs = el.attrs;
  const x = (attrs.length > 0 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 0)._1, 0) : 0) + offset_x;
  const y = (attrs.length > 1 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 1)._1, 0) : 0) + offset_y;
  const content = attrs.length > 2 ? _M0FP36mizchi6kagura5scene12attr__string(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 2)._1, "") : "";
  const color_hex = attrs.length > 3 ? _M0FP36mizchi6kagura5scene9attr__int(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 3)._1, 16777215) : 16777215;
  const scale = attrs.length > 4 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 4)._1, 1) : 1;
  const color = _M0FP36mizchi6kagura9debugutil16color__from__hex(color_hex);
  const chars = _M0FP36mizchi6kagura5scene23string__to__char__codes(content);
  _M0FP36mizchi6kagura9debugutil15draw__dot__text(cmds, dst, shader, chars, x, y, screen_w, screen_h, color, scale);
}
function _M0FP36mizchi6kagura5scene24pixel__to__ndc__vertices(vertices, screen_w, screen_h) {
  const out = [];
  const i = { val: 0 };
  while (true) {
    if (i.val < vertices.length) {
      const px = _M0MP311moonbitlang4core5array5Array2atGdE(vertices, i.val);
      const py = _M0MP311moonbitlang4core5array5Array2atGdE(vertices, i.val + 1 | 0);
      const u = _M0MP311moonbitlang4core5array5Array2atGdE(vertices, i.val + 2 | 0);
      const v = _M0MP311moonbitlang4core5array5Array2atGdE(vertices, i.val + 3 | 0);
      _M0MP311moonbitlang4core5array5Array4pushGdE(out, px / screen_w * 2 - 1);
      _M0MP311moonbitlang4core5array5Array4pushGdE(out, 1 - py / screen_h * 2);
      _M0MP311moonbitlang4core5array5Array4pushGdE(out, u);
      _M0MP311moonbitlang4core5array5Array4pushGdE(out, v);
      i.val = i.val + 4 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura5scene12render__line(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  const attrs = el.attrs;
  const x0 = (attrs.length > 0 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 0)._1, 0) : 0) + offset_x;
  const y0 = (attrs.length > 1 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 1)._1, 0) : 0) + offset_y;
  const x1 = (attrs.length > 2 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 2)._1, 0) : 0) + offset_x;
  const y1 = (attrs.length > 3 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 3)._1, 0) : 0) + offset_y;
  const width = attrs.length > 4 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 4)._1, 1) : 1;
  const color_hex = attrs.length > 5 ? _M0FP36mizchi6kagura5scene9attr__int(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 5)._1, 16777215) : 16777215;
  const color = _M0FP36mizchi6kagura9debugutil16color__from__hex(color_hex);
  let vertices;
  let indices;
  _L: {
    const _bind = _M0FP36mizchi6kagura9debugutil14line__vertices(x0, y0, x1, y1, width);
    const _vertices = _bind._0;
    const _indices = _bind._1;
    vertices = _vertices;
    indices = _indices;
    break _L;
  }
  const ndc_vertices = _M0FP36mizchi6kagura5scene24pixel__to__ndc__vertices(vertices, screen_w, screen_h);
  const uniform = _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color);
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, _M0MP311moonbitlang4core6double6Double7to__int(screen_w), _M0MP311moonbitlang4core6double6Double7to__int(screen_h), indices.length)], 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), ndc_vertices, indices, [], uniform, 1, 0));
}
function _M0FP36mizchi6kagura5scene21render__rect__outline(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  const attrs = el.attrs;
  const x = (attrs.length > 0 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 0)._1, 0) : 0) + offset_x;
  const y = (attrs.length > 1 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 1)._1, 0) : 0) + offset_y;
  const w = attrs.length > 2 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 2)._1, 0) : 0;
  const h = attrs.length > 3 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 3)._1, 0) : 0;
  const line_width = attrs.length > 4 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 4)._1, 1) : 1;
  const color_hex = attrs.length > 5 ? _M0FP36mizchi6kagura5scene9attr__int(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 5)._1, 16777215) : 16777215;
  const color = _M0FP36mizchi6kagura9debugutil16color__from__hex(color_hex);
  let vertices;
  let indices;
  _L: {
    const _bind = _M0FP36mizchi6kagura9debugutil23rect__outline__vertices(x, y, w, h, line_width);
    const _vertices = _bind._0;
    const _indices = _bind._1;
    vertices = _vertices;
    indices = _indices;
    break _L;
  }
  const ndc_vertices = _M0FP36mizchi6kagura5scene24pixel__to__ndc__vertices(vertices, screen_w, screen_h);
  const uniform = _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color);
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, _M0MP311moonbitlang4core6double6Double7to__int(screen_w), _M0MP311moonbitlang4core6double6Double7to__int(screen_h), indices.length)], 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), ndc_vertices, indices, [], uniform, 1, 0));
}
function _M0FP36mizchi6kagura5scene12render__node(cmds, node, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  let _tmp = cmds;
  let _tmp$2 = node;
  let _tmp$3 = dst;
  let _tmp$4 = shader;
  let _tmp$5 = screen_w;
  let _tmp$6 = screen_h;
  let _tmp$7 = offset_x;
  let _tmp$8 = offset_y;
  _L: while (true) {
    const cmds$2 = _tmp;
    const node$2 = _tmp$2;
    const dst$2 = _tmp$3;
    const shader$2 = _tmp$4;
    const screen_w$2 = _tmp$5;
    const screen_h$2 = _tmp$6;
    const offset_x$2 = _tmp$7;
    const offset_y$2 = _tmp$8;
    let sw;
    _L$2: {
      let render;
      _L$3: {
        let render$2;
        _L$4: {
          let condition;
          let child;
          _L$5: {
            let children;
            _L$6: {
              let el;
              _L$7: {
                switch (node$2.$tag) {
                  case 0: {
                    const _Element = node$2;
                    const _el = _Element._0;
                    el = _el;
                    break _L$7;
                  }
                  case 3: {
                    const _Fragment = node$2;
                    const _children = _Fragment._0;
                    children = _children;
                    break _L$6;
                  }
                  case 4: {
                    const _Show = node$2;
                    const _condition = _Show._0;
                    const _child = _Show._1;
                    condition = _condition;
                    child = _child;
                    break _L$5;
                  }
                  case 5: {
                    const _For = node$2;
                    const _render = _For._0;
                    render$2 = _render;
                    break _L$4;
                  }
                  case 6: {
                    const _Component = node$2;
                    const _render$2 = _Component._0;
                    render = _render$2;
                    break _L$3;
                  }
                  case 9: {
                    const _Switch = node$2;
                    const _sw = _Switch._0;
                    sw = _sw;
                    break _L$2;
                  }
                  case 1: {
                    return;
                  }
                  case 2: {
                    return;
                  }
                  case 7: {
                    return;
                  }
                  case 8: {
                    return;
                  }
                  default: {
                    return;
                  }
                }
              }
              _M0FP36mizchi6kagura5scene15render__element(cmds$2, el, dst$2, shader$2, screen_w$2, screen_h$2, offset_x$2, offset_y$2);
              return;
            }
            const _arr = children;
            const _len = _arr.length;
            let _tmp$9 = 0;
            while (true) {
              const _i = _tmp$9;
              if (_i < _len) {
                const child$2 = _arr[_i];
                _M0FP36mizchi6kagura5scene12render__node(cmds$2, child$2, dst$2, shader$2, screen_w$2, screen_h$2, offset_x$2, offset_y$2);
                _tmp$9 = _i + 1 | 0;
                continue;
              } else {
                return;
              }
            }
          }
          if (condition()) {
            _tmp$2 = child();
            continue;
          } else {
            return;
          }
        }
        const items = render$2();
        const _arr = items;
        const _len = _arr.length;
        let _tmp$9 = 0;
        while (true) {
          const _i = _tmp$9;
          if (_i < _len) {
            const item = _arr[_i];
            _M0FP36mizchi6kagura5scene12render__node(cmds$2, item, dst$2, shader$2, screen_w$2, screen_h$2, offset_x$2, offset_y$2);
            _tmp$9 = _i + 1 | 0;
            continue;
          } else {
            return;
          }
        }
      }
      _tmp$2 = render();
      continue;
    }
    const _arr = sw.cases;
    const _len = _arr.length;
    let _tmp$9 = 0;
    while (true) {
      const _i = _tmp$9;
      if (_i < _len) {
        const c = _arr[_i];
        const _func = c.when;
        if (_func()) {
          const _func$2 = c.render;
          _M0FP36mizchi6kagura5scene12render__node(cmds$2, _func$2(), dst$2, shader$2, screen_w$2, screen_h$2, offset_x$2, offset_y$2);
          return undefined;
        }
        _tmp$9 = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    let fb;
    _L$3: {
      const _bind = sw.fallback;
      if (_bind === undefined) {
        return;
      } else {
        const _Some = _bind;
        const _fb = _Some;
        fb = _fb;
        break _L$3;
      }
    }
    _tmp$2 = fb();
    continue;
  }
}
function _M0FP36mizchi6kagura5scene15render__element(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  const _bind = el.tag;
  switch (_bind) {
    case "rect": {
      _M0FP36mizchi6kagura5scene12render__rect(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y);
      return;
    }
    case "label": {
      _M0FP36mizchi6kagura5scene13render__label(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y);
      return;
    }
    case "group": {
      _M0FP36mizchi6kagura5scene13render__group(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y);
      return;
    }
    case "line": {
      _M0FP36mizchi6kagura5scene12render__line(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y);
      return;
    }
    case "rect_outline": {
      _M0FP36mizchi6kagura5scene21render__rect__outline(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y);
      return;
    }
    default: {
      return;
    }
  }
}
function _M0FP36mizchi6kagura5scene13render__group(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  const attrs = el.attrs;
  const x = (attrs.length > 0 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 0)._1, 0) : 0) + offset_x;
  const y = (attrs.length > 1 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 1)._1, 0) : 0) + offset_y;
  const _arr = el.children;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const child = _arr[_i];
      _M0FP36mizchi6kagura5scene12render__node(cmds, child, dst, shader, screen_w, screen_h, x, y);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura5scene12render__rect(cmds, el, dst, shader, screen_w, screen_h, offset_x, offset_y) {
  const attrs = el.attrs;
  const x = (attrs.length > 0 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 0)._1, 0) : 0) + offset_x;
  const y = (attrs.length > 1 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 1)._1, 0) : 0) + offset_y;
  const w = attrs.length > 2 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 2)._1, 0) : 0;
  const h = attrs.length > 3 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 3)._1, 0) : 0;
  const fill = attrs.length > 4 ? _M0FP36mizchi6kagura5scene9attr__int(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 4)._1, 16777215) : 16777215;
  const alpha = attrs.length > 5 ? _M0FP36mizchi6kagura5scene12attr__double(_M0MP311moonbitlang4core5array5Array2atGUsRP36mizchi7signals2ui4AttrGuRP36mizchi6kagura5scene14SceneAttrValueEEE(attrs, 5)._1, 1) : 1;
  const color = _M0FP36mizchi6kagura9debugutil23color__from__hex__alpha(fill, alpha);
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(dst, shader, x, y, w, h, screen_w, screen_h, color, 0));
  const _arr = el.children;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const child = _arr[_i];
      _M0FP36mizchi6kagura5scene12render__node(cmds, child, dst, shader, screen_w, screen_h, x, y);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP36mizchi6kagura5scene13render__scene(node, dst, shader, screen_w, screen_h) {
  const cmds = [];
  _M0FP36mizchi6kagura5scene12render__node(cmds, node, dst, shader, screen_w, screen_h, 0, 0);
  return cmds;
}
function _M0FP36mizchi6kagura5scene12rect_2einner(x, y, w, h, fill, alpha, children) {
  return _M0FP36mizchi7signals2ui1hGuRP36mizchi6kagura5scene14SceneAttrValueE("rect", [{ _0: "x", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(x)) }, { _0: "y", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(y)) }, { _0: "w", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(w)) }, { _0: "h", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(h)) }, { _0: "fill", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt(fill)) }, { _0: "alpha", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(alpha)) }], children);
}
function _M0FP36mizchi6kagura5scene4rect(x$46$opt, y$46$opt, w, h, fill$46$opt, alpha$46$opt, children$46$opt) {
  let x;
  if (x$46$opt.$tag === 1) {
    const _Some = x$46$opt;
    x = _Some._0;
  } else {
    x = 0;
  }
  let y;
  if (y$46$opt.$tag === 1) {
    const _Some = y$46$opt;
    y = _Some._0;
  } else {
    y = 0;
  }
  let fill;
  if (fill$46$opt === undefined) {
    fill = 16777215;
  } else {
    const _Some = fill$46$opt;
    fill = _Some;
  }
  let alpha;
  if (alpha$46$opt.$tag === 1) {
    const _Some = alpha$46$opt;
    alpha = _Some._0;
  } else {
    alpha = 1;
  }
  let children;
  if (children$46$opt.$tag === 1) {
    const _Some = children$46$opt;
    children = _Some._0;
  } else {
    children = [];
  }
  return _M0FP36mizchi6kagura5scene12rect_2einner(x, y, w, h, fill, alpha, children);
}
function _M0FP36mizchi6kagura5scene13label_2einner(x, y, content, color, scale) {
  return _M0FP36mizchi7signals2ui1hGuRP36mizchi6kagura5scene14SceneAttrValueE("label", [{ _0: "x", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(x)) }, { _0: "y", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(y)) }, { _0: "content", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneText(content)) }, { _0: "color", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt(color)) }, { _0: "scale", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(scale)) }], []);
}
function _M0FP36mizchi6kagura5scene4show(when, child) {
  return _M0FP36mizchi7signals2ui4showGuRP36mizchi6kagura5scene14SceneAttrValueE(when, child);
}
function _M0FP36mizchi6kagura5scene9for__each(items) {
  return _M0FP36mizchi7signals2ui9for__eachGuRP36mizchi6kagura5scene14SceneAttrValueE(items);
}
function _M0FP36mizchi6kagura5scene8fragment(children) {
  return _M0FP36mizchi7signals2ui8fragmentGuRP36mizchi6kagura5scene14SceneAttrValueE(children);
}
function _M0FP36mizchi6kagura5scene11run_2einner(view, update, on_frame, audio_ctx, width, height, title, canvas) {
  const logical_w = width + 0;
  const logical_h = height + 0;
  _M0FP36mizchi6kagura6engine11run_2einner(update, (ctx) => {
    const cmds = _M0FP36mizchi6kagura5scene13render__scene(view(), ctx.dst, ctx.shader, logical_w, logical_h);
    let f;
    _L: {
      _L$2: {
        if (on_frame === undefined) {
        } else {
          const _Some = on_frame;
          const _f = _Some;
          f = _f;
          break _L$2;
        }
        break _L;
      }
      f(cmds, ctx.dst, ctx.shader, logical_w, logical_h);
    }
    return cmds;
  }, undefined, undefined, audio_ctx, 735, width, height, title, canvas);
}
function _M0MP26mizchi7signals5Flags10set__value(self, v) {
  self.value = v;
}
function _M0MP26mizchi7signals13ReactiveFlags7to__int(self) {
  switch (self) {
    case 0: {
      return 0;
    }
    case 1: {
      return 1;
    }
    case 2: {
      return 2;
    }
    case 4: {
      return 4;
    }
    case 8: {
      return 8;
    }
    case 16: {
      return 16;
    }
    default: {
      return 32;
    }
  }
}
function _M0MP26mizchi7signals5Flags10get__value(self) {
  return self.value;
}
function _M0FP26mizchi7signals11purge__deps(sub) {
  let _tmp;
  let dt;
  _L: {
    _L$2: {
      const _bind = sub.deps_tail;
      if (_bind === undefined) {
        _tmp = sub.deps;
      } else {
        const _Some = _bind;
        const _dt = _Some;
        dt = _dt;
        break _L$2;
      }
      break _L;
    }
    _tmp = dt.next_dep;
  }
  const current_dep = { val: _tmp };
  while (true) {
    let d;
    _L$2: {
      const _bind = current_dep.val;
      if (_bind === undefined) {
        return;
      } else {
        const _Some = _bind;
        const _d = _Some;
        d = _d;
        break _L$2;
      }
    }
    current_dep.val = _M0FP26mizchi7signals6unlink(d, sub);
    continue;
  }
}
function _M0FP26mizchi7signals6unlink(lnk, sub) {
  const dep = lnk.dep;
  const prev_dep = lnk.prev_dep;
  const next_dep = lnk.next_dep;
  const next_sub = lnk.next_sub;
  const prev_sub = lnk.prev_sub;
  let nd;
  _L: {
    _L$2: {
      if (next_dep === undefined) {
        sub.deps_tail = prev_dep;
      } else {
        const _Some = next_dep;
        const _nd = _Some;
        nd = _nd;
        break _L$2;
      }
      break _L;
    }
    nd.prev_dep = prev_dep;
  }
  let pd;
  _L$2: {
    _L$3: {
      if (prev_dep === undefined) {
        sub.deps = next_dep;
      } else {
        const _Some = prev_dep;
        const _pd = _Some;
        pd = _pd;
        break _L$3;
      }
      break _L$2;
    }
    pd.next_dep = next_dep;
  }
  let ns;
  _L$3: {
    _L$4: {
      if (next_sub === undefined) {
        dep.subs_tail = prev_sub;
      } else {
        const _Some = next_sub;
        const _ns = _Some;
        ns = _ns;
        break _L$4;
      }
      break _L$3;
    }
    ns.prev_sub = prev_sub;
  }
  let ps;
  _L$4: {
    _L$5: {
      if (prev_sub === undefined) {
        dep.subs = next_sub;
        if (next_sub === undefined) {
          _M0FP26mizchi7signals9unwatched(dep);
        }
      } else {
        const _Some = prev_sub;
        const _ps = _Some;
        ps = _ps;
        break _L$5;
      }
      break _L$4;
    }
    ps.next_sub = next_sub;
  }
  return next_dep;
}
function _M0FP26mizchi7signals9unwatched(node) {
  const flags = _M0MP26mizchi7signals5Flags10get__value(node.flags);
  const is_mutable = (flags & _M0MP26mizchi7signals13ReactiveFlags7to__int(1)) !== 0;
  if (!is_mutable) {
    _M0FP26mizchi7signals13cleanup__node(node);
    return;
  } else {
    const _bind = node.deps_tail;
    if (_bind === undefined) {
      return;
    } else {
      node.deps_tail = undefined;
      _M0MP26mizchi7signals5Flags10set__value(node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1) | _M0MP26mizchi7signals13ReactiveFlags7to__int(16));
      _M0FP26mizchi7signals11purge__deps(node);
      return;
    }
  }
}
function _M0FP26mizchi7signals13cleanup__node(node) {
  node.deps_tail = undefined;
  _M0MP26mizchi7signals5Flags10set__value(node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(0));
  _M0FP26mizchi7signals11purge__deps(node);
  let sub;
  _L: {
    const _bind = node.subs;
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
      const _sub = _Some;
      sub = _sub;
      break _L;
    }
  }
  _M0FP26mizchi7signals6unlink(sub, sub.sub);
}
function _M0FP26mizchi7signals10inc__cycle() {
  _M0FP26mizchi7signals5cycle.val = _M0FP26mizchi7signals5cycle.val + 1 | 0;
}
function _M0FP26mizchi7signals4link(dep, sub, version) {
  const prev_dep = sub.deps_tail;
  let pd;
  _L: {
    _L$2: {
      if (prev_dep === undefined) {
      } else {
        const _Some = prev_dep;
        const _pd = _Some;
        pd = _pd;
        break _L$2;
      }
      break _L;
    }
    if (pd.dep === dep) {
      return undefined;
    }
  }
  let next_dep;
  let pd$2;
  _L$2: {
    _L$3: {
      if (prev_dep === undefined) {
        next_dep = sub.deps;
      } else {
        const _Some = prev_dep;
        const _pd = _Some;
        pd$2 = _pd;
        break _L$3;
      }
      break _L$2;
    }
    next_dep = pd$2.next_dep;
  }
  let nd;
  _L$3: {
    _L$4: {
      if (next_dep === undefined) {
      } else {
        const _Some = next_dep;
        const _nd = _Some;
        nd = _nd;
        break _L$4;
      }
      break _L$3;
    }
    if (nd.dep === dep) {
      nd.version = version;
      sub.deps_tail = nd;
      return undefined;
    }
  }
  let ps;
  _L$4: {
    _L$5: {
      const _bind = dep.subs_tail;
      if (_bind === undefined) {
      } else {
        const _Some = _bind;
        const _ps = _Some;
        ps = _ps;
        break _L$5;
      }
      break _L$4;
    }
    if (ps.version === version && ps.sub === sub) {
      return undefined;
    }
  }
  const _bind = dep.subs_tail;
  const _bind$2 = undefined;
  const new_link = { version: version, dep: dep, sub: sub, prev_sub: _bind, next_sub: _bind$2, prev_dep: prev_dep, next_dep: next_dep };
  sub.deps_tail = new_link;
  let nd$2;
  _L$5: {
    _L$6: {
      if (next_dep === undefined) {
      } else {
        const _Some = next_dep;
        const _nd = _Some;
        nd$2 = _nd;
        break _L$6;
      }
      break _L$5;
    }
    nd$2.prev_dep = new_link;
  }
  let pd$3;
  _L$6: {
    _L$7: {
      if (prev_dep === undefined) {
        sub.deps = new_link;
      } else {
        const _Some = prev_dep;
        const _pd = _Some;
        pd$3 = _pd;
        break _L$7;
      }
      break _L$6;
    }
    pd$3.next_dep = new_link;
  }
  let ps$2;
  _L$7: {
    _L$8: {
      const _bind$3 = new_link.prev_sub;
      if (_bind$3 === undefined) {
        dep.subs = new_link;
      } else {
        const _Some = _bind$3;
        const _ps = _Some;
        ps$2 = _ps;
        break _L$8;
      }
      break _L$7;
    }
    ps$2.next_sub = new_link;
  }
  dep.subs_tail = new_link;
}
function _M0FP26mizchi7signals16set__active__sub(sub) {
  const prev = _M0FP26mizchi7signals11active__sub.val;
  _M0FP26mizchi7signals11active__sub.val = sub;
  return prev;
}
function _M0MP26mizchi7signals5Flags3new(initial) {
  return { value: initial };
}
function _M0MP26mizchi7signals12ReactiveNode3new(flags) {
  return { deps: undefined, deps_tail: undefined, subs: undefined, subs_tail: undefined, flags: _M0MP26mizchi7signals5Flags3new(flags), last_modified_cycle: 0, effect_callback: undefined };
}
function _M0FP26mizchi7signals16get__active__sub() {
  return _M0FP26mizchi7signals11active__sub.val;
}
function _M0FP26mizchi7signals10get__cycle() {
  return _M0FP26mizchi7signals5cycle.val;
}
function _M0MP26mizchi7signals5Flags5unset(self, flag) {
  self.value = self.value & (_M0MP26mizchi7signals13ReactiveFlags7to__int(flag) ^ -1);
}
function _M0FP26mizchi7signals14notify__effect(node) {
  let callback;
  _L: {
    const _bind = node.effect_callback;
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
      const _callback = _Some;
      callback = _callback;
      break _L;
    }
  }
  const already_queued = { val: false };
  const _arr = _M0FP26mizchi7signals22callback__queue__nodes;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const n = _arr[_i];
      if (n === node) {
        already_queued.val = true;
        break;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (!already_queued.val) {
    _M0MP311moonbitlang4core5array5Array4pushGWEuE(_M0FP26mizchi7signals15callback__queue, callback);
    _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi7signals12ReactiveNodeE(_M0FP26mizchi7signals22callback__queue__nodes, node);
    _M0MP26mizchi7signals5Flags5unset(node.flags, 2);
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi7signals18shallow__propagate(start_link) {
  const current_link = { val: start_link };
  while (true) {
    let lnk;
    _L: {
      const _bind = current_link.val;
      if (_bind === undefined) {
        return;
      } else {
        const _Some = _bind;
        const _lnk = _Some;
        lnk = _lnk;
        break _L;
      }
    }
    const sub = lnk.sub;
    const flags = _M0MP26mizchi7signals5Flags10get__value(sub.flags);
    const pending_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(32);
    const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
    const watching_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(2);
    const recursed_check_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(4);
    if ((flags & (pending_flag | dirty_flag)) === pending_flag) {
      _M0MP26mizchi7signals5Flags10set__value(sub.flags, flags | dirty_flag);
      if ((flags & (watching_flag | recursed_check_flag)) === watching_flag) {
        _M0FP26mizchi7signals14notify__effect(sub);
      }
    }
    current_link.val = lnk.next_sub;
    continue;
  }
}
function _M0MP26mizchi7signals10CoreSignal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self) {
  const flags = _M0MP26mizchi7signals5Flags10get__value(self.node.flags);
  const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
  if ((flags & dirty_flag) !== 0) {
    if (!(self.current_value === self.pending_value)) {
      self.current_value = self.pending_value;
      let subs;
      _L: {
        _L$2: {
          const _bind = self.node.subs;
          if (_bind === undefined) {
          } else {
            const _Some = _bind;
            const _subs = _Some;
            subs = _subs;
            break _L$2;
          }
          break _L;
        }
        _M0FP26mizchi7signals18shallow__propagate(subs);
      }
    }
    _M0MP26mizchi7signals5Flags10set__value(self.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1));
  }
  const found_sub = { val: _M0FP26mizchi7signals16get__active__sub() };
  while (true) {
    let s;
    _L: {
      const _bind = found_sub.val;
      if (_bind === undefined) {
        break;
      } else {
        const _Some = _bind;
        const _s = _Some;
        s = _s;
        break _L;
      }
    }
    const sub_flags = _M0MP26mizchi7signals5Flags10get__value(s.flags);
    const mutable_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(1);
    const watching_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(2);
    if ((sub_flags & (mutable_flag | watching_flag)) !== 0) {
      _M0FP26mizchi7signals4link(self.node, s, _M0FP26mizchi7signals10get__cycle());
      break;
    }
    let _tmp;
    let subs;
    _L$2: {
      _L$3: {
        const _bind = s.subs;
        if (_bind === undefined) {
          _tmp = undefined;
        } else {
          const _Some = _bind;
          const _subs = _Some;
          subs = _subs;
          break _L$3;
        }
        break _L$2;
      }
      _tmp = subs.sub;
    }
    found_sub.val = _tmp;
    continue;
  }
  return self.current_value;
}
function _M0MP26mizchi7signals10CoreSignal3getGdE(self) {
  const flags = _M0MP26mizchi7signals5Flags10get__value(self.node.flags);
  const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
  if ((flags & dirty_flag) !== 0) {
    if (!(self.current_value === self.pending_value)) {
      self.current_value = self.pending_value;
      let subs;
      _L: {
        _L$2: {
          const _bind = self.node.subs;
          if (_bind === undefined) {
          } else {
            const _Some = _bind;
            const _subs = _Some;
            subs = _subs;
            break _L$2;
          }
          break _L;
        }
        _M0FP26mizchi7signals18shallow__propagate(subs);
      }
    }
    _M0MP26mizchi7signals5Flags10set__value(self.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1));
  }
  const found_sub = { val: _M0FP26mizchi7signals16get__active__sub() };
  while (true) {
    let s;
    _L: {
      const _bind = found_sub.val;
      if (_bind === undefined) {
        break;
      } else {
        const _Some = _bind;
        const _s = _Some;
        s = _s;
        break _L;
      }
    }
    const sub_flags = _M0MP26mizchi7signals5Flags10get__value(s.flags);
    const mutable_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(1);
    const watching_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(2);
    if ((sub_flags & (mutable_flag | watching_flag)) !== 0) {
      _M0FP26mizchi7signals4link(self.node, s, _M0FP26mizchi7signals10get__cycle());
      break;
    }
    let _tmp;
    let subs;
    _L$2: {
      _L$3: {
        const _bind = s.subs;
        if (_bind === undefined) {
          _tmp = undefined;
        } else {
          const _Some = _bind;
          const _subs = _Some;
          subs = _subs;
          break _L$3;
        }
        break _L$2;
      }
      _tmp = subs.sub;
    }
    found_sub.val = _tmp;
    continue;
  }
  return self.current_value;
}
function _M0MP26mizchi7signals10CoreSignal3getGiE(self) {
  const flags = _M0MP26mizchi7signals5Flags10get__value(self.node.flags);
  const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
  if ((flags & dirty_flag) !== 0) {
    if (!(self.current_value === self.pending_value)) {
      self.current_value = self.pending_value;
      let subs;
      _L: {
        _L$2: {
          const _bind = self.node.subs;
          if (_bind === undefined) {
          } else {
            const _Some = _bind;
            const _subs = _Some;
            subs = _subs;
            break _L$2;
          }
          break _L;
        }
        _M0FP26mizchi7signals18shallow__propagate(subs);
      }
    }
    _M0MP26mizchi7signals5Flags10set__value(self.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1));
  }
  const found_sub = { val: _M0FP26mizchi7signals16get__active__sub() };
  while (true) {
    let s;
    _L: {
      const _bind = found_sub.val;
      if (_bind === undefined) {
        break;
      } else {
        const _Some = _bind;
        const _s = _Some;
        s = _s;
        break _L;
      }
    }
    const sub_flags = _M0MP26mizchi7signals5Flags10get__value(s.flags);
    const mutable_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(1);
    const watching_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(2);
    if ((sub_flags & (mutable_flag | watching_flag)) !== 0) {
      _M0FP26mizchi7signals4link(self.node, s, _M0FP26mizchi7signals10get__cycle());
      break;
    }
    let _tmp;
    let subs;
    _L$2: {
      _L$3: {
        const _bind = s.subs;
        if (_bind === undefined) {
          _tmp = undefined;
        } else {
          const _Some = _bind;
          const _subs = _Some;
          subs = _subs;
          break _L$3;
        }
        break _L$2;
      }
      _tmp = subs.sub;
    }
    found_sub.val = _tmp;
    continue;
  }
  return self.current_value;
}
function _M0MP26mizchi7signals6Signal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self) {
  return _M0MP26mizchi7signals10CoreSignal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.inner);
}
function _M0MP26mizchi7signals6Signal3getGdE(self) {
  return _M0MP26mizchi7signals10CoreSignal3getGdE(self.inner);
}
function _M0MP26mizchi7signals6Signal3getGiE(self) {
  return _M0MP26mizchi7signals10CoreSignal3getGiE(self.inner);
}
function _M0FP26mizchi7signals17get__batch__depth() {
  return _M0FP26mizchi7signals12batch__depth.val;
}
function _M0FP26mizchi7signals12start__batch() {
  _M0FP26mizchi7signals12batch__depth.val = _M0FP26mizchi7signals12batch__depth.val + 1 | 0;
}
function _M0FP26mizchi7signals12check__dirty(start_link, sub, update_fn) {
  const current_link = { val: start_link };
  const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
  const mutable_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(1);
  while (true) {
    let lnk;
    _L: {
      const _bind = current_link.val;
      if (_bind === undefined) {
        break;
      } else {
        const _Some = _bind;
        const _lnk = _Some;
        lnk = _lnk;
        break _L;
      }
    }
    const dep = lnk.dep;
    const flags = _M0MP26mizchi7signals5Flags10get__value(dep.flags);
    if ((_M0MP26mizchi7signals5Flags10get__value(sub.flags) & dirty_flag) !== 0) {
      return true;
    }
    if ((flags & (mutable_flag | dirty_flag)) === (mutable_flag | dirty_flag)) {
      if (update_fn(dep)) {
        let subs;
        _L$2: {
          _L$3: {
            const _bind = dep.subs;
            if (_bind === undefined) {
            } else {
              const _Some = _bind;
              const _subs = _Some;
              subs = _subs;
              break _L$3;
            }
            break _L$2;
          }
          const _bind = subs.next_sub;
          if (_bind === undefined) {
          } else {
            _M0FP26mizchi7signals18shallow__propagate(subs);
          }
        }
        return true;
      }
    }
    current_link.val = lnk.next_dep;
    continue;
  }
  return false;
}
function _M0FP26mizchi7signals11run__effect(e) {
  const flags = _M0MP26mizchi7signals5Flags10get__value(e.node.flags);
  const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
  const pending_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(32);
  let is_deps_dirty;
  let deps;
  _L: {
    _L$2: {
      const _bind = e.node.deps;
      if (_bind === undefined) {
        is_deps_dirty = false;
      } else {
        const _Some = _bind;
        const _deps = _Some;
        deps = _deps;
        break _L$2;
      }
      break _L;
    }
    is_deps_dirty = _M0FP26mizchi7signals12check__dirty(deps, e.node, (_discard_) => false);
  }
  const should_run = (flags & dirty_flag) !== 0 || (flags & pending_flag) !== 0 && is_deps_dirty;
  if (should_run) {
    _M0FP26mizchi7signals10inc__cycle();
    e.node.deps_tail = undefined;
    _M0MP26mizchi7signals5Flags10set__value(e.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(2) | _M0MP26mizchi7signals13ReactiveFlags7to__int(4));
    const prev_sub = _M0FP26mizchi7signals16set__active__sub(e.node);
    const _func = e.run_fn;
    _func();
    _M0FP26mizchi7signals16set__active__sub(prev_sub);
    const current_flags = _M0MP26mizchi7signals5Flags10get__value(e.node.flags);
    _M0MP26mizchi7signals5Flags10set__value(e.node.flags, current_flags & (_M0MP26mizchi7signals13ReactiveFlags7to__int(4) ^ -1));
    _M0FP26mizchi7signals11purge__deps(e.node);
    return;
  } else {
    _M0MP26mizchi7signals5Flags10set__value(e.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(2));
    return;
  }
}
function _M0FP26mizchi7signals5flush() {
  while (true) {
    if (_M0FP26mizchi7signals13notify__index.val < _M0FP26mizchi7signals14queued__length.val) {
      let eff;
      _L: {
        _L$2: {
          const _bind = _M0MP311moonbitlang4core5array5Array2atGORP26mizchi7signals10EffectNodeE(_M0FP26mizchi7signals6queued, _M0FP26mizchi7signals13notify__index.val);
          if (_bind === undefined) {
            _M0FP26mizchi7signals13notify__index.val = _M0FP26mizchi7signals13notify__index.val + 1 | 0;
          } else {
            const _Some = _bind;
            const _eff = _Some;
            eff = _eff;
            break _L$2;
          }
          break _L;
        }
        _M0MP311moonbitlang4core5array5Array3setGORP26mizchi7signals10EffectNodeE(_M0FP26mizchi7signals6queued, _M0FP26mizchi7signals13notify__index.val, undefined);
        _M0FP26mizchi7signals13notify__index.val = _M0FP26mizchi7signals13notify__index.val + 1 | 0;
        _M0FP26mizchi7signals11run__effect(eff);
      }
      continue;
    } else {
      break;
    }
  }
  _M0FP26mizchi7signals13notify__index.val = 0;
  _M0FP26mizchi7signals14queued__length.val = 0;
  while (true) {
    if (_M0FP26mizchi7signals15callback__queue.length > 0) {
      const callback = _M0MP311moonbitlang4core5array5Array6removeGWEuE(_M0FP26mizchi7signals15callback__queue, 0);
      _M0MP311moonbitlang4core5array5Array6removeGRP26mizchi7signals12ReactiveNodeE(_M0FP26mizchi7signals22callback__queue__nodes, 0);
      callback();
      continue;
    } else {
      return;
    }
  }
}
function _M0FP26mizchi7signals10end__batch() {
  _M0FP26mizchi7signals12batch__depth.val = _M0FP26mizchi7signals12batch__depth.val - 1 | 0;
  if (_M0FP26mizchi7signals12batch__depth.val === 0) {
    _M0FP26mizchi7signals5flush();
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi7signals15is__valid__link(check_link, sub) {
  const current_link = { val: sub.deps_tail };
  while (true) {
    let l;
    _L: {
      const _bind = current_link.val;
      if (_bind === undefined) {
        break;
      } else {
        const _Some = _bind;
        const _l = _Some;
        l = _l;
        break _L;
      }
    }
    if (l === check_link) {
      return true;
    }
    current_link.val = l.prev_dep;
    continue;
  }
  return false;
}
function _M0FP26mizchi7signals9propagate(start_link) {
  const link_ref = _M0MP311moonbitlang4core3ref3Ref3newGORP26mizchi7signals4LinkE(start_link);
  const next_ref = _M0MP311moonbitlang4core3ref3Ref3newGORP26mizchi7signals4LinkE(start_link.next_sub);
  const stack = [];
  const running = { val: true };
  while (true) {
    if (running.val) {
      let lnk;
      _L: {
        _L$2: {
          const _bind = link_ref.val;
          if (_bind === undefined) {
            if (stack.length > 0) {
              let l;
              _L$3: {
                _L$4: {
                  const _bind$2 = _M0MP311moonbitlang4core5array5Array3popGUORP26mizchi7signals4LinkORP26mizchi7signals4LinkEE(stack);
                  if (_bind$2 === undefined) {
                    running.val = false;
                  } else {
                    const _Some = _bind$2;
                    const _x = _Some;
                    const _l = _x._0;
                    l = _l;
                    break _L$4;
                  }
                  break _L$3;
                }
                link_ref.val = l;
                let _tmp;
                let lnk$2;
                _L$5: {
                  _L$6: {
                    if (l === undefined) {
                      _tmp = undefined;
                    } else {
                      const _Some = l;
                      const _lnk = _Some;
                      lnk$2 = _lnk;
                      break _L$6;
                    }
                    break _L$5;
                  }
                  _tmp = lnk$2.next_sub;
                }
                next_ref.val = _tmp;
              }
            } else {
              running.val = false;
            }
          } else {
            const _Some = _bind;
            const _lnk = _Some;
            lnk = _lnk;
            break _L$2;
          }
          break _L;
        }
        const sub = lnk.sub;
        const flags = _M0MP26mizchi7signals5Flags10get__value(sub.flags);
        const mutable_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(1);
        const watching_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(2);
        const recursed_check_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(4);
        const recursed_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(8);
        const dirty_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(16);
        const pending_flag = _M0MP26mizchi7signals13ReactiveFlags7to__int(32);
        const new_flags = { val: flags };
        const should_notify = { val: false };
        const should_propagate_subs = { val: false };
        if ((flags & (recursed_check_flag | recursed_flag | dirty_flag | pending_flag)) === 0) {
          new_flags.val = flags | pending_flag;
          _M0MP26mizchi7signals5Flags10set__value(sub.flags, new_flags.val);
        } else {
          if ((flags & (recursed_check_flag | recursed_flag)) === 0) {
            new_flags.val = _M0MP26mizchi7signals13ReactiveFlags7to__int(0);
          } else {
            if ((flags & recursed_check_flag) === 0) {
              new_flags.val = flags & (recursed_flag ^ -1) | pending_flag;
              _M0MP26mizchi7signals5Flags10set__value(sub.flags, new_flags.val);
            } else {
              if ((flags & (dirty_flag | pending_flag)) === 0 && _M0FP26mizchi7signals15is__valid__link(lnk, sub)) {
                new_flags.val = flags | recursed_flag | pending_flag;
                _M0MP26mizchi7signals5Flags10set__value(sub.flags, new_flags.val);
                new_flags.val = new_flags.val & mutable_flag;
              } else {
                new_flags.val = _M0MP26mizchi7signals13ReactiveFlags7to__int(0);
              }
            }
          }
        }
        if ((new_flags.val & watching_flag) !== 0) {
          should_notify.val = true;
        }
        if ((new_flags.val & mutable_flag) !== 0) {
          should_propagate_subs.val = true;
        }
        if (should_notify.val) {
          _M0FP26mizchi7signals14notify__effect(sub);
        }
        if (should_propagate_subs.val) {
          let sub_subs;
          _L$3: {
            _L$4: {
              const _bind = sub.subs;
              if (_bind === undefined) {
                link_ref.val = next_ref.val;
                let l;
                _L$5: {
                  _L$6: {
                    const _bind$2 = link_ref.val;
                    if (_bind$2 === undefined) {
                      next_ref.val = undefined;
                    } else {
                      const _Some = _bind$2;
                      const _l = _Some;
                      l = _l;
                      break _L$6;
                    }
                    break _L$5;
                  }
                  next_ref.val = l.next_sub;
                }
              } else {
                const _Some = _bind;
                const _sub_subs = _Some;
                sub_subs = _sub_subs;
                break _L$4;
              }
              break _L$3;
            }
            const _bind = sub_subs.next_sub;
            if (_bind === undefined) {
            } else {
              _M0MP311moonbitlang4core5array5Array4pushGUORP26mizchi7signals4LinkORP26mizchi7signals4LinkEE(stack, { _0: next_ref.val, _1: undefined });
              next_ref.val = sub_subs.next_sub;
            }
            link_ref.val = sub_subs;
          }
        } else {
          link_ref.val = next_ref.val;
          let l;
          _L$3: {
            _L$4: {
              const _bind = link_ref.val;
              if (_bind === undefined) {
                next_ref.val = undefined;
              } else {
                const _Some = _bind;
                const _l = _Some;
                l = _l;
                break _L$4;
              }
              break _L$3;
            }
            next_ref.val = l.next_sub;
          }
        }
      }
      continue;
    } else {
      return;
    }
  }
}
function _M0FP26mizchi7signals12core__signalGiE(initial) {
  return { node: _M0MP26mizchi7signals12ReactiveNode3new(_M0MP26mizchi7signals13ReactiveFlags7to__int(1)), current_value: initial, pending_value: initial };
}
function _M0FP26mizchi7signals12core__signalGdE(initial) {
  return { node: _M0MP26mizchi7signals12ReactiveNode3new(_M0MP26mizchi7signals13ReactiveFlags7to__int(1)), current_value: initial, pending_value: initial };
}
function _M0FP26mizchi7signals12core__signalGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(initial) {
  return { node: _M0MP26mizchi7signals12ReactiveNode3new(_M0MP26mizchi7signals13ReactiveFlags7to__int(1)), current_value: initial, pending_value: initial };
}
function _M0MP26mizchi7signals6Signal3newGiE(initial) {
  return { inner: _M0FP26mizchi7signals12core__signalGiE(initial) };
}
function _M0MP26mizchi7signals6Signal3newGdE(initial) {
  return { inner: _M0FP26mizchi7signals12core__signalGdE(initial) };
}
function _M0MP26mizchi7signals6Signal3newGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(initial) {
  return { inner: _M0FP26mizchi7signals12core__signalGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(initial) };
}
function _M0FP26mizchi7signals6signalGiE(initial) {
  return _M0MP26mizchi7signals6Signal3newGiE(initial);
}
function _M0FP26mizchi7signals6signalGdE(initial) {
  return _M0MP26mizchi7signals6Signal3newGdE(initial);
}
function _M0FP26mizchi7signals6signalGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(initial) {
  return _M0MP26mizchi7signals6Signal3newGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(initial);
}
function _M0MP26mizchi7signals10CoreSignal3setGiE(self, value) {
  if (!(self.pending_value === value)) {
    self.pending_value = value;
    _M0FP26mizchi7signals10inc__cycle();
    self.node.last_modified_cycle = _M0FP26mizchi7signals10get__cycle();
    _M0MP26mizchi7signals5Flags10set__value(self.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1) | _M0MP26mizchi7signals13ReactiveFlags7to__int(16));
    let subs;
    _L: {
      const _bind = self.node.subs;
      if (_bind === undefined) {
        return;
      } else {
        const _Some = _bind;
        const _subs = _Some;
        subs = _subs;
        break _L;
      }
    }
    _M0FP26mizchi7signals9propagate(subs);
    if (_M0FP26mizchi7signals17get__batch__depth() === 0) {
      _M0FP26mizchi7signals5flush();
      return;
    } else {
      return;
    }
  } else {
    return;
  }
}
function _M0MP26mizchi7signals10CoreSignal3setGdE(self, value) {
  if (!(self.pending_value === value)) {
    self.pending_value = value;
    _M0FP26mizchi7signals10inc__cycle();
    self.node.last_modified_cycle = _M0FP26mizchi7signals10get__cycle();
    _M0MP26mizchi7signals5Flags10set__value(self.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1) | _M0MP26mizchi7signals13ReactiveFlags7to__int(16));
    let subs;
    _L: {
      const _bind = self.node.subs;
      if (_bind === undefined) {
        return;
      } else {
        const _Some = _bind;
        const _subs = _Some;
        subs = _subs;
        break _L;
      }
    }
    _M0FP26mizchi7signals9propagate(subs);
    if (_M0FP26mizchi7signals17get__batch__depth() === 0) {
      _M0FP26mizchi7signals5flush();
      return;
    } else {
      return;
    }
  } else {
    return;
  }
}
function _M0MP26mizchi7signals10CoreSignal3setGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self, value) {
  if (!(self.pending_value === value)) {
    self.pending_value = value;
    _M0FP26mizchi7signals10inc__cycle();
    self.node.last_modified_cycle = _M0FP26mizchi7signals10get__cycle();
    _M0MP26mizchi7signals5Flags10set__value(self.node.flags, _M0MP26mizchi7signals13ReactiveFlags7to__int(1) | _M0MP26mizchi7signals13ReactiveFlags7to__int(16));
    let subs;
    _L: {
      const _bind = self.node.subs;
      if (_bind === undefined) {
        return;
      } else {
        const _Some = _bind;
        const _subs = _Some;
        subs = _subs;
        break _L;
      }
    }
    _M0FP26mizchi7signals9propagate(subs);
    if (_M0FP26mizchi7signals17get__batch__depth() === 0) {
      _M0FP26mizchi7signals5flush();
      return;
    } else {
      return;
    }
  } else {
    return;
  }
}
function _M0MP26mizchi7signals6Signal3setGiE(self, new_value) {
  _M0MP26mizchi7signals10CoreSignal3setGiE(self.inner, new_value);
}
function _M0MP26mizchi7signals6Signal3setGdE(self, new_value) {
  _M0MP26mizchi7signals10CoreSignal3setGdE(self.inner, new_value);
}
function _M0MP26mizchi7signals6Signal3setGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self, new_value) {
  _M0MP26mizchi7signals10CoreSignal3setGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.inner, new_value);
}
function _M0FP26mizchi7signals10batch__end() {
  _M0FP26mizchi7signals17reactive__context.batch_depth = _M0FP26mizchi7signals17reactive__context.batch_depth - 1 | 0;
  _M0FP26mizchi7signals10end__batch();
}
function _M0FP26mizchi7signals12batch__start() {
  _M0FP26mizchi7signals17reactive__context.batch_depth = _M0FP26mizchi7signals17reactive__context.batch_depth + 1 | 0;
  _M0FP26mizchi7signals12start__batch();
}
function _M0FP26mizchi7signals5batchGuE(f) {
  _M0FP26mizchi7signals12batch__start();
  f();
  _M0FP26mizchi7signals10batch__end();
}
function _M0MP26mizchi12flappy__bird4Game3new() {
  return { game_mode: _M0FP26mizchi7signals6signalGiE(0), score: _M0FP26mizchi7signals6signalGiE(0), bird_y: _M0FP26mizchi7signals6signalGdE((_M0FP26mizchi12flappy__bird9screen__h + 0) / 2), frame_count: _M0FP26mizchi7signals6signalGiE(0), pipes: _M0FP26mizchi7signals6signalGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE([]), velocity: 0, pipe_timer: 0, input: _M0FP36mizchi6kagura9inpututil18new__input__helper() };
}
function _M0FP26mizchi12flappy__bird14pseudo__random(seed) {
  const x = (Math.imul(seed, 1103515245) | 0) + 12345 | 0;
  return ((x >> 16 & 32767) + 0) / 32767;
}
function _M0MP26mizchi12flappy__bird4Game5reset(self) {
  _M0MP26mizchi7signals6Signal3setGdE(self.bird_y, (_M0FP26mizchi12flappy__bird9screen__h + 0) / 2);
  self.velocity = 0;
  _M0MP26mizchi7signals6Signal3setGiE(self.game_mode, 0);
  _M0MP26mizchi7signals6Signal3setGiE(self.score, 0);
  _M0MP26mizchi7signals6Signal3setGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes, []);
  self.pipe_timer = 0;
}
function _M0MP26mizchi12flappy__bird4Game6update(self, input) {
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, input);
  _M0FP26mizchi7signals5batchGuE(() => {
    _M0MP26mizchi7signals6Signal3setGiE(self.frame_count, _M0MP26mizchi7signals6Signal3getGiE(self.frame_count) + 1 | 0);
    const action = _M0FP36mizchi6kagura9inpututil30is__any__action__just__pressed(self.input, input);
    const _bind = _M0MP26mizchi7signals6Signal3getGiE(self.game_mode);
    switch (_bind) {
      case 0: {
        if (action) {
          _M0MP26mizchi7signals6Signal3setGiE(self.game_mode, 1);
          self.velocity = _M0FP26mizchi12flappy__bird14jump__velocity;
          return;
        } else {
          return;
        }
      }
      case 1: {
        self.velocity = self.velocity + _M0FP26mizchi12flappy__bird7gravity;
        _M0MP26mizchi7signals6Signal3setGdE(self.bird_y, _M0MP26mizchi7signals6Signal3getGdE(self.bird_y) + self.velocity);
        if (action) {
          self.velocity = _M0FP26mizchi12flappy__bird14jump__velocity;
        }
        self.pipe_timer = self.pipe_timer + 1 | 0;
        if (self.pipe_timer >= _M0FP26mizchi12flappy__bird14pipe__interval) {
          self.pipe_timer = 0;
          const sw = _M0FP26mizchi12flappy__bird9screen__w + 0;
          const sh = _M0FP26mizchi12flappy__bird9screen__h + 0;
          const min_gap_y = 40;
          const max_gap_y = sh - _M0FP26mizchi12flappy__bird9ground__h - _M0FP26mizchi12flappy__bird9pipe__gap - 40;
          const gap_y = min_gap_y + _M0FP26mizchi12flappy__bird14pseudo__random(_M0MP26mizchi7signals6Signal3getGiE(self.frame_count)) * (max_gap_y - min_gap_y);
          const current_pipes = _M0MP26mizchi7signals6Signal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes);
          _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi12flappy__bird4PipeE(current_pipes, { x: sw, gap_y: gap_y });
          _M0MP26mizchi7signals6Signal3setGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes, current_pipes);
        }
        const pipes = _M0MP26mizchi7signals6Signal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes);
        const i = { val: 0 };
        while (true) {
          if (i.val < pipes.length) {
            const pipe = _M0MP311moonbitlang4core5array5Array2atGRP26mizchi12flappy__bird4PipeE(pipes, i.val);
            const old_x = pipe.x;
            pipe.x = pipe.x - _M0FP26mizchi12flappy__bird11pipe__speed;
            const pipe_right = old_x + _M0FP26mizchi12flappy__bird11pipe__width;
            const pipe_right_new = pipe.x + _M0FP26mizchi12flappy__bird11pipe__width;
            if (pipe_right >= _M0FP26mizchi12flappy__bird7bird__x && pipe_right_new < _M0FP26mizchi12flappy__bird7bird__x) {
              _M0MP26mizchi7signals6Signal3setGiE(self.score, _M0MP26mizchi7signals6Signal3getGiE(self.score) + 1 | 0);
            }
            i.val = i.val + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        const new_pipes = [];
        const _arr = pipes;
        const _len = _arr.length;
        let _tmp = 0;
        while (true) {
          const _i = _tmp;
          if (_i < _len) {
            const pipe = _arr[_i];
            if (pipe.x + _M0FP26mizchi12flappy__bird11pipe__width > 0) {
              _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi12flappy__bird4PipeE(new_pipes, pipe);
            }
            _tmp = _i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0MP26mizchi7signals6Signal3setGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes, new_pipes);
        const ground_top = _M0FP26mizchi12flappy__bird9screen__h + 0 - _M0FP26mizchi12flappy__bird9ground__h;
        if (_M0MP26mizchi7signals6Signal3getGdE(self.bird_y) + _M0FP26mizchi12flappy__bird10bird__size > ground_top || _M0MP26mizchi7signals6Signal3getGdE(self.bird_y) < 0) {
          _M0MP26mizchi7signals6Signal3setGiE(self.game_mode, 2);
        }
        const _arr$2 = _M0MP26mizchi7signals6Signal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes);
        const _len$2 = _arr$2.length;
        let _tmp$2 = 0;
        while (true) {
          const _i = _tmp$2;
          if (_i < _len$2) {
            const pipe = _arr$2[_i];
            const bird_right = _M0FP26mizchi12flappy__bird7bird__x + _M0FP26mizchi12flappy__bird10bird__size;
            const bird_bottom = _M0MP26mizchi7signals6Signal3getGdE(self.bird_y) + _M0FP26mizchi12flappy__bird10bird__size;
            const pipe_right = pipe.x + _M0FP26mizchi12flappy__bird11pipe__width;
            if (bird_right > pipe.x && _M0FP26mizchi12flappy__bird7bird__x < pipe_right) {
              const gap_bottom = pipe.gap_y + _M0FP26mizchi12flappy__bird9pipe__gap;
              if (_M0MP26mizchi7signals6Signal3getGdE(self.bird_y) < pipe.gap_y || bird_bottom > gap_bottom) {
                _M0MP26mizchi7signals6Signal3setGiE(self.game_mode, 2);
              }
            }
            _tmp$2 = _i + 1 | 0;
            continue;
          } else {
            return;
          }
        }
      }
      default: {
        if (action) {
          _M0MP26mizchi12flappy__bird4Game5reset(self);
          return;
        } else {
          return;
        }
      }
    }
  });
}
function _M0MP26mizchi12flappy__bird4Game4view(self) {
  const sw = _M0FP26mizchi12flappy__bird9screen__w + 0;
  const sh = _M0FP26mizchi12flappy__bird9screen__h + 0;
  const ground_y = sh - _M0FP26mizchi12flappy__bird9ground__h;
  return _M0FP36mizchi6kagura5scene8fragment([_M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, sw, sh, 8900331, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(0), new Option$Some$8$(ground_y), sw, _M0FP26mizchi12flappy__bird9ground__h, 9127187, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const _arr = _M0MP26mizchi7signals6Signal3getGRP311moonbitlang4core7builtin5ArrayGRP26mizchi12flappy__bird4PipeEE(self.pipes);
    const _len = _arr.length;
    let _tmp = 0;
    while (true) {
      const _i = _tmp;
      if (_i < _len) {
        const pipe = _arr[_i];
        if (pipe.gap_y > 0) {
          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(pipe.x), Option$None$8$, _M0FP26mizchi12flappy__bird11pipe__width, pipe.gap_y, 2263842, Option$None$8$, Option$None$9$));
        }
        const lower_y = pipe.gap_y + _M0FP26mizchi12flappy__bird9pipe__gap;
        const lower_h = ground_y - lower_y;
        if (lower_h > 0) {
          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(pipe.x), new Option$Some$8$(lower_y), _M0FP26mizchi12flappy__bird11pipe__width, lower_h, 2263842, Option$None$8$, Option$None$9$));
        }
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  }), _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(_M0FP26mizchi12flappy__bird7bird__x), new Option$Some$8$(_M0MP26mizchi7signals6Signal3getGdE(self.bird_y)), _M0FP26mizchi12flappy__bird10bird__size, _M0FP26mizchi12flappy__bird10bird__size, 16766720, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene13label_2einner(sw / 2 - 10, 20, _M0MP311moonbitlang4core3int3Int18to__string_2einner(_M0MP26mizchi7signals6Signal3getGiE(self.score), 10), 16777215, 1), _M0FP36mizchi6kagura5scene4show(() => {
    if (_M0MP26mizchi7signals6Signal3getGiE(self.game_mode) === 0) {
      if (30 === 0) {
        $panic();
      }
      if (2 === 0) {
        $panic();
      }
      return ((_M0MP26mizchi7signals6Signal3getGiE(self.frame_count) / 30 | 0) % 2 | 0) === 0;
    } else {
      return false;
    }
  }, () => _M0FP36mizchi6kagura5scene13label_2einner(sw / 2, sh / 2 + 30, "TAP", 16777215, 2)), _M0FP36mizchi6kagura5scene4show(() => _M0MP26mizchi7signals6Signal3getGiE(self.game_mode) === 2, () => _M0FP36mizchi6kagura5scene8fragment([_M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sw / 2 - 50), new Option$Some$8$(sh / 2 - 20), 100, 40, 0, new Option$Some$8$(0.5), Option$None$9$), _M0FP36mizchi6kagura5scene13label_2einner(sw / 2, sh / 2, "END", 16777215, 2)]))]);
}
(() => {
  const game = _M0MP26mizchi12flappy__bird4Game3new();
  _M0FP36mizchi6kagura5scene11run_2einner(() => _M0MP26mizchi12flappy__bird4Game4view(game), (input) => {
    _M0MP26mizchi12flappy__bird4Game6update(game, input);
  }, undefined, undefined, _M0FP26mizchi12flappy__bird9screen__w, _M0FP26mizchi12flappy__bird9screen__h, "Flappy Bird", "#app");
})();
//# sourceMappingURL=flappy_bird.js.map
