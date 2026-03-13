const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $f32_reinterpret_i32(a) {
  $reinterpret_view.setInt32(0, a, true);
  return $reinterpret_view.getFloat32(0, true);
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
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
const _M0MP311moonbitlang4core7builtin7JSArray4push = (arr, val) => { arr.push(val); };
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const Option$None$1$ = { $tag: 0, $name: "None" };
function Option$Some$1$(param0) {
  this._0 = param0;
}
Option$Some$1$.prototype.$tag = 1;
Option$Some$1$.prototype.$name = "Some";
const _M0MP311moonbitlang4core7builtin7JSArray11set__length = (arr, len) => { arr.length = len; };
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
const $4294967295L = { hi: 0, lo: -1 };
const Option$None$6$ = { $tag: 0, $name: "None" };
function Option$Some$6$(param0) {
  this._0 = param0;
}
Option$Some$6$.prototype.$tag = 1;
Option$Some$6$.prototype.$name = "Some";
function $64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$CircleShape(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
$64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$CircleShape.prototype.$tag = 0;
$64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$CircleShape.prototype.$name = "CircleShape";
function $64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$AABBShape2D(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
$64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$AABBShape2D.prototype.$tag = 1;
$64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$AABBShape2D.prototype.$name = "AABBShape2D";
function $64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$OBBShape2D(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
$64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$OBBShape2D.prototype.$tag = 2;
$64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$OBBShape2D.prototype.$name = "OBBShape2D";
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
const _M0FP36mizchi6kagura9physics2d26sleep__velocity__threshold = 0.5;
const _M0FP36mizchi6kagura9physics2d25sleep__angular__threshold = 0.2;
const _M0FP36mizchi6kagura9physics2d22sleep__time__threshold = 0.5;
const _M0FP36mizchi6kagura9physics2d2pi = 3.14159265358979312;
const _M0FP36mizchi6kagura9physics2d32restitution__velocity__threshold = 1;
const _M0FP36mizchi6kagura9physics2d9joint__pi = 3.14159265358979312;
const _M0FP36mizchi6kagura9physics2d22max__angular__velocity = 20;
const _M0FP36mizchi6kagura9physics2d4slop = 0.005;
const _M0FP26mizchi13ragdoll__demo9screen__h = 480;
const _M0FP26mizchi13ragdoll__demo9screen__w = 640;
const _M0FP26mizchi13ragdoll__demo9color__bg = 1710638;
const _M0FP26mizchi13ragdoll__demo16circle__segments = 16;
const _M0FP26mizchi13ragdoll__demo10color__arm = 5279952;
const _M0FP26mizchi13ragdoll__demo14color__forearm = 6332640;
const _M0FP26mizchi13ragdoll__demo18color__ground__hex = 4473924;
const _M0FP26mizchi13ragdoll__demo16color__highlight = 16776960;
const _M0FP26mizchi13ragdoll__demo11color__shin = 5271696;
const _M0FP26mizchi13ragdoll__demo11color__skin = 15780000;
const _M0FP26mizchi13ragdoll__demo12color__thigh = 4219008;
const _M0FP26mizchi13ragdoll__demo12color__torso = 4227264;
const _M0FP26mizchi13ragdoll__demo13px__per__unit = 40;
const _M0FP26mizchi13ragdoll__demo8id__head = 1;
const _M0FP26mizchi13ragdoll__demo10id__l__arm = 3;
const _M0FP26mizchi13ragdoll__demo11id__l__fore = 5;
const _M0FP26mizchi13ragdoll__demo11id__l__shin = 9;
const _M0FP26mizchi13ragdoll__demo12id__l__thigh = 7;
const _M0FP26mizchi13ragdoll__demo10id__r__arm = 4;
const _M0FP26mizchi13ragdoll__demo11id__r__fore = 6;
const _M0FP26mizchi13ragdoll__demo11id__r__shin = 10;
const _M0FP26mizchi13ragdoll__demo12id__r__thigh = 8;
const _M0FP26mizchi13ragdoll__demo9id__torso = 2;
const _M0FP26mizchi13ragdoll__demo10id__ground = 0;
const _M0FP26mizchi13ragdoll__demo14grab__distance = 2;
const _M0FP26mizchi13ragdoll__demo16spring__strength = 200;
const _M0FP311moonbitlang4core7builtin4seed = _M0FP311moonbitlang4core7builtin12random__seed();
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f713 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FP36mizchi6kagura8platform18web__canvas__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura8platform14WebCanvasHooksE(_M0FP36mizchi6kagura8platform27default__web__canvas__hooks());
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MP311moonbitlang4core3ref3Ref3newGWEdE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx19NativeGraphicsHooksE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
const _M0FP36mizchi6kagura3gfx20web__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx16WebGraphicsHooksE(_M0FP36mizchi6kagura3gfx29default__web__graphics__hooks());
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
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15RevoluteJoint2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGUiiEE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15ManifoldPoint2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGUiiRP36mizchi6kagura9physics2d9Contact2DEE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15DistanceJoint2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d19ContactConstraint2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGUddEE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self, index) {
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
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d25DistanceJointConstraint2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d25RevoluteJointConstraint2DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6vector4Vec2E(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
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
function _M0MP311moonbitlang4core7builtin6Hasher12combine__int(self, value) {
  _M0MP311moonbitlang4core7builtin6Hasher13combine__uint(self, value);
}
function _M0MP311moonbitlang4core7builtin7MyInt649from__int(value) {
  return { hi: value >> 31 & -1, lo: value | 0 };
}
function _M0MP311moonbitlang4core3int3Int9to__int64(self) {
  return _M0MP311moonbitlang4core7builtin7MyInt649from__int(self);
}
function _M0MP311moonbitlang4core7builtin6Hasher7combineGlE(self, value) {
  _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin4Hash13hash__combine(value, self);
}
function _M0MP311moonbitlang4core7builtin6Hasher7combineGiE(self, value) {
  _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Hash13hash__combine(value, self);
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
function _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(self) {
  const h = _M0MP311moonbitlang4core7builtin6Hasher3new(undefined);
  _M0MP311moonbitlang4core7builtin6Hasher7combineGlE(h, self);
  return _M0MP311moonbitlang4core7builtin6Hasher8finalize(h);
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
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core5error5ErrorE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core5error5ErrorP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin4Show10to__stringGRP311moonbitlang4core7builtin17CreatingViewErrorE(self) {
  const logger = _M0MP311moonbitlang4core7builtin13StringBuilder11new_2einner(0);
  _M0IP311moonbitlang4core7builtin17CreatingViewErrorP311moonbitlang4core7builtin4Show6output(self, { self: logger, method_table: _M0FP095_40moonbitlang_2fcore_2fbuiltin_2eStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MP311moonbitlang4core7builtin13StringBuilder10to__string(logger);
}
function _M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MP311moonbitlang4core5array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self) {
  return self.end - self.start | 0;
}
function _M0MP311moonbitlang4core5array9ArrayView6lengthGUibEE(self) {
  return self.end - self.start | 0;
}
function _M0MP311moonbitlang4core5array9ArrayView6lengthGUluEE(self) {
  return self.end - self.start | 0;
}
function _M0MP311moonbitlang4core5array9ArrayView6lengthGUlRP311moonbitlang4core7builtin5ArrayGiEEE(self) {
  return self.end - self.start | 0;
}
function _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__view(self, str) {
  const _bind = self;
  _bind.val = `${_bind.val}${_M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(str)}`;
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d11RigidBody2DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGUiiRP36mizchi6kagura9physics2d9Contact2DEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d19ContactConstraint2DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d25DistanceJointConstraint2DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d25RevoluteJointConstraint2DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGdE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGiE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d15RevoluteJoint2DE(self, value) {
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
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGUiiEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi5audio5VoiceE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(self) {
  return self;
}
function _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGibEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGlRP311moonbitlang4core7builtin5ArrayGiEEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGluEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0MP311moonbitlang4core5array5Array4makeGiE(len, elem) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGiE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d19ContactConstraint2DE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d25DistanceJointConstraint2DE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d25RevoluteJointConstraint2DE(self, index, value) {
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
function _M0MP311moonbitlang4core7builtin3Map11new_2einnerGlRP36mizchi6kagura9physics2d17ContactManifold2DE(capacity) {
  const capacity$2 = _M0MP311moonbitlang4core3int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return { entries: _bind$3, size: 0, capacity: capacity$2, capacity_mask: _bind, grow_at: _bind$2, head: _bind$4, tail: -1 };
}
function _M0MP311moonbitlang4core7builtin3Map11new_2einnerGibE(capacity) {
  const capacity$2 = _M0MP311moonbitlang4core3int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return { entries: _bind$3, size: 0, capacity: capacity$2, capacity_mask: _bind, grow_at: _bind$2, head: _bind$4, tail: -1 };
}
function _M0MP311moonbitlang4core7builtin3Map11new_2einnerGluE(capacity) {
  const capacity$2 = _M0MP311moonbitlang4core3int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return { entries: _bind$3, size: 0, capacity: capacity$2, capacity_mask: _bind, grow_at: _bind$2, head: _bind$4, tail: -1 };
}
function _M0MP311moonbitlang4core7builtin3Map11new_2einnerGlRP311moonbitlang4core7builtin5ArrayGiEE(capacity) {
  const capacity$2 = _M0MP311moonbitlang4core3int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return { entries: _bind$3, size: 0, capacity: capacity$2, capacity_mask: _bind, grow_at: _bind$2, head: _bind$4, tail: -1 };
}
function _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGibE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGibEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGlRP311moonbitlang4core7builtin5ArrayGiEE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGlRP311moonbitlang4core7builtin5ArrayGiEEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGluE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MP311moonbitlang4core6option6Option6unwrapGRP311moonbitlang4core7builtin5EntryGluEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MP311moonbitlang4core7builtin3Map10set__entryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, entry, new_idx) {
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
function _M0MP311moonbitlang4core7builtin3Map10set__entryGibE(self, entry, new_idx) {
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
function _M0MP311moonbitlang4core7builtin3Map10set__entryGlRP311moonbitlang4core7builtin5ArrayGiEE(self, entry, new_idx) {
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
function _M0MP311moonbitlang4core7builtin3Map10set__entryGluE(self, entry, new_idx) {
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
function _M0MP311moonbitlang4core7builtin3Map10push__awayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry) {
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
      _M0MP311moonbitlang4core7builtin3Map10set__entryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, entry$2, idx$2);
      break;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MP311moonbitlang4core7builtin3Map10set__entryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, entry$2, idx$2);
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
function _M0MP311moonbitlang4core7builtin3Map10push__awayGibE(self, idx, entry) {
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
      _M0MP311moonbitlang4core7builtin3Map10set__entryGibE(self, entry$2, idx$2);
      break;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MP311moonbitlang4core7builtin3Map10set__entryGibE(self, entry$2, idx$2);
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
function _M0MP311moonbitlang4core7builtin3Map10push__awayGlRP311moonbitlang4core7builtin5ArrayGiEE(self, idx, entry) {
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
      _M0MP311moonbitlang4core7builtin3Map10set__entryGlRP311moonbitlang4core7builtin5ArrayGiEE(self, entry$2, idx$2);
      break;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MP311moonbitlang4core7builtin3Map10set__entryGlRP311moonbitlang4core7builtin5ArrayGiEE(self, entry$2, idx$2);
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
function _M0MP311moonbitlang4core7builtin3Map10push__awayGluE(self, idx, entry) {
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
      _M0MP311moonbitlang4core7builtin3Map10set__entryGluE(self, entry$2, idx$2);
      break;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MP311moonbitlang4core7builtin3Map10set__entryGluE(self, entry$2, idx$2);
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
function _M0MP311moonbitlang4core7builtin3Map15set__with__hashGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key, value, hash) {
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
        _M0MP311moonbitlang4core7builtin3Map4growGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
      _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(_curr_entry.key, key)) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MP311moonbitlang4core7builtin3Map4growGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MP311moonbitlang4core7builtin3Map10push__awayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
        _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map15set__with__hashGibE(self, key, value, hash) {
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
        _M0MP311moonbitlang4core7builtin3Map4growGibE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
      _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGibE(self, idx, entry);
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
          _M0MP311moonbitlang4core7builtin3Map4growGibE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MP311moonbitlang4core7builtin3Map10push__awayGibE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
        _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGibE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map15set__with__hashGlRP311moonbitlang4core7builtin5ArrayGiEE(self, key, value, hash) {
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
        _M0MP311moonbitlang4core7builtin3Map4growGlRP311moonbitlang4core7builtin5ArrayGiEE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
      _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGlRP311moonbitlang4core7builtin5ArrayGiEE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(_curr_entry.key, key)) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MP311moonbitlang4core7builtin3Map4growGlRP311moonbitlang4core7builtin5ArrayGiEE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MP311moonbitlang4core7builtin3Map10push__awayGlRP311moonbitlang4core7builtin5ArrayGiEE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
        _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGlRP311moonbitlang4core7builtin5ArrayGiEE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map15set__with__hashGluE(self, key, value, hash) {
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
        _M0MP311moonbitlang4core7builtin3Map4growGluE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
      _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGluE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(_curr_entry.key, key)) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MP311moonbitlang4core7builtin3Map4growGluE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MP311moonbitlang4core7builtin3Map10push__awayGluE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = { prev: _bind$2, next: _bind$3, psl: psl, hash: hash, key: key, value: value };
        _M0MP311moonbitlang4core7builtin3Map20add__entry__to__tailGluE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map4growGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self) {
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
      _M0MP311moonbitlang4core7builtin3Map15set__with__hashGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map4growGibE(self) {
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
      _M0MP311moonbitlang4core7builtin3Map15set__with__hashGibE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map4growGlRP311moonbitlang4core7builtin5ArrayGiEE(self) {
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
      _M0MP311moonbitlang4core7builtin3Map15set__with__hashGlRP311moonbitlang4core7builtin5ArrayGiEE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map4growGluE(self) {
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
      _M0MP311moonbitlang4core7builtin3Map15set__with__hashGluE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key, value) {
  _M0MP311moonbitlang4core7builtin3Map15set__with__hashGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key, value, _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(key));
}
function _M0MP311moonbitlang4core7builtin3Map3setGibE(self, key, value) {
  _M0MP311moonbitlang4core7builtin3Map15set__with__hashGibE(self, key, value, _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGiE(key));
}
function _M0MP311moonbitlang4core7builtin3Map3setGlRP311moonbitlang4core7builtin5ArrayGiEE(self, key, value) {
  _M0MP311moonbitlang4core7builtin3Map15set__with__hashGlRP311moonbitlang4core7builtin5ArrayGiEE(self, key, value, _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(key));
}
function _M0MP311moonbitlang4core7builtin3Map3setGluE(self, key, value) {
  _M0MP311moonbitlang4core7builtin3Map15set__with__hashGluE(self, key, value, _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(key));
}
function _M0MP311moonbitlang4core7builtin3Map11from__arrayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(arr) {
  const length = _M0MP311moonbitlang4core5array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(arr);
  let capacity = _M0MP311moonbitlang4core3int3Int20next__power__of__two(length);
  if (length > _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MP311moonbitlang4core7builtin3Map11new_2einnerGlRP36mizchi6kagura9physics2d17ContactManifold2DE(capacity);
  const _len = _M0MP311moonbitlang4core5array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(arr);
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const e = arr.buf[arr.start + _i | 0];
      _M0MP311moonbitlang4core7builtin3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(m, e._0, e._1);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MP311moonbitlang4core7builtin3Map11from__arrayGibE(arr) {
  const length = _M0MP311moonbitlang4core5array9ArrayView6lengthGUibEE(arr);
  let capacity = _M0MP311moonbitlang4core3int3Int20next__power__of__two(length);
  if (length > _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MP311moonbitlang4core7builtin3Map11new_2einnerGibE(capacity);
  const _len = _M0MP311moonbitlang4core5array9ArrayView6lengthGUibEE(arr);
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const e = arr.buf[arr.start + _i | 0];
      _M0MP311moonbitlang4core7builtin3Map3setGibE(m, e._0, e._1);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MP311moonbitlang4core7builtin3Map11from__arrayGluE(arr) {
  const length = _M0MP311moonbitlang4core5array9ArrayView6lengthGUluEE(arr);
  let capacity = _M0MP311moonbitlang4core3int3Int20next__power__of__two(length);
  if (length > _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MP311moonbitlang4core7builtin3Map11new_2einnerGluE(capacity);
  const _len = _M0MP311moonbitlang4core5array9ArrayView6lengthGUluEE(arr);
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const e = arr.buf[arr.start + _i | 0];
      _M0MP311moonbitlang4core7builtin3Map3setGluE(m, e._0, e._1);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MP311moonbitlang4core7builtin3Map11from__arrayGlRP311moonbitlang4core7builtin5ArrayGiEE(arr) {
  const length = _M0MP311moonbitlang4core5array9ArrayView6lengthGUlRP311moonbitlang4core7builtin5ArrayGiEEE(arr);
  let capacity = _M0MP311moonbitlang4core3int3Int20next__power__of__two(length);
  if (length > _M0FP311moonbitlang4core7builtin21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MP311moonbitlang4core7builtin3Map11new_2einnerGlRP311moonbitlang4core7builtin5ArrayGiEE(capacity);
  const _len = _M0MP311moonbitlang4core5array9ArrayView6lengthGUlRP311moonbitlang4core7builtin5ArrayGiEEE(arr);
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const e = arr.buf[arr.start + _i | 0];
      _M0MP311moonbitlang4core7builtin3Map3setGlRP311moonbitlang4core7builtin5ArrayGiEE(m, e._0, e._1);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MP311moonbitlang4core7builtin3Map3getGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key) {
  const hash = _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(key);
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
      if (_entry.hash === hash && _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(_entry.key, key)) {
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
function _M0MP311moonbitlang4core7builtin3Map3getGibE(self, key) {
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
      return -1;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _entry.key === key) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return -1;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map3getGlRP311moonbitlang4core7builtin5ArrayGiEE(self, key) {
  const hash = _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return Option$None$1$;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(_entry.key, key)) {
        return new Option$Some$1$(_entry.value);
      }
      if (i > _entry.psl) {
        return Option$None$1$;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map3getGluE(self, key) {
  const hash = _M0IP016_24default__implP311moonbitlang4core7builtin4Hash4hashGlE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return -1;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(_entry.key, key)) {
        return _entry.value;
      }
      if (i > _entry.psl) {
        return -1;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MP311moonbitlang4core7builtin3Map4eachGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, f) {
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
function _M0MP311moonbitlang4core7builtin3Map4eachGlRP311moonbitlang4core7builtin5ArrayGiEE(self, f) {
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
function _M0MP311moonbitlang4core5array10FixedArray12fill_2einnerGORP311moonbitlang4core7builtin5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self, value, start, end) {
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
function _M0MP311moonbitlang4core5array10FixedArray12fill_2einnerGORP311moonbitlang4core7builtin5EntryGlRP311moonbitlang4core7builtin5ArrayGiEEE(self, value, start, end) {
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
function _M0MP311moonbitlang4core7builtin3Map5clearGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self) {
  _M0MP311moonbitlang4core5array10FixedArray12fill_2einnerGORP311moonbitlang4core7builtin5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self.entries, undefined, 0, undefined);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
}
function _M0MP311moonbitlang4core7builtin3Map5clearGlRP311moonbitlang4core7builtin5ArrayGiEE(self) {
  _M0MP311moonbitlang4core5array10FixedArray12fill_2einnerGORP311moonbitlang4core7builtin5EntryGlRP311moonbitlang4core7builtin5ArrayGiEEE(self.entries, undefined, 0, undefined);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
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
function _M0MP311moonbitlang4core7builtin7MyInt643lor(self, other) {
  return { hi: self.hi | other.hi, lo: self.lo | other.lo };
}
function _M0MP311moonbitlang4core7builtin7MyInt643lsl(self, shift) {
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
      return { hi: hi$2, lo: lo$2 };
    } else {
      return { hi: self.lo << (shift$2 - 32 | 0), lo: 0 };
    }
  }
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
function _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin5BitOr3lor(self, other) {
  return _M0MP311moonbitlang4core7builtin7MyInt643lor(self, other);
}
function _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin3Shl3shl(self, other) {
  return _M0MP311moonbitlang4core7builtin7MyInt643lsl(self, other);
}
function _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin2Eq5equal(self, other) {
  return _M0IP311moonbitlang4core7builtin7MyInt64P311moonbitlang4core7builtin2Eq5equal(self, other);
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
function _M0MP311moonbitlang4core7builtin6Hasher14combine__int64(self, value) {
  self.acc = (self.acc >>> 0) + (8 >>> 0) | 0;
  _M0MP311moonbitlang4core7builtin6Hasher8consume4(self, _M0MP311moonbitlang4core6uint646UInt648to__uint(value));
  _M0MP311moonbitlang4core7builtin6Hasher8consume4(self, _M0MP311moonbitlang4core6uint646UInt648to__uint(_M0IP311moonbitlang4core6uint646UInt64P311moonbitlang4core7builtin3Shr3shr(value, 32)));
}
function _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin4Hash13hash__combine(self, hasher) {
  _M0MP311moonbitlang4core7builtin6Hasher14combine__int64(hasher, self);
}
function _M0IP311moonbitlang4core3int3IntP311moonbitlang4core7builtin4Hash13hash__combine(self, hasher) {
  _M0MP311moonbitlang4core7builtin6Hasher12combine__int(hasher, self);
}
function _M0MP311moonbitlang4core6double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0FP311moonbitlang4core7builtin7printlnGsE(input) {
  console.log(_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(input));
}
function _M0MP311moonbitlang4core5array5Array28unsafe__truncate__to__lengthGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self, new_len) {
  _M0MP311moonbitlang4core7builtin7JSArray11set__length(self, new_len);
}
function _M0MP311moonbitlang4core5array5Array5clearGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self) {
  _M0MP311moonbitlang4core5array5Array28unsafe__truncate__to__lengthGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self, 0);
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
function _M0FP311moonbitlang4core3cmp7maximumGdE(x, y) {
  return x > y ? x : y;
}
function _M0FP311moonbitlang4core3cmp7minimumGdE(x, y) {
  return x > y ? y : x;
}
function _M0FP311moonbitlang4core4math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FP311moonbitlang4core4math3cos(_tmp) {
  return Math.cos(_tmp);
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
  let hi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f713, ind);
  let mi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f713, ind + 1 | 0);
  let lo = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f713, ind + 2 | 0);
  const tp = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f713, ind + 3 | 0);
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
  return new Result$Ok$2$(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : { kind: 1, opaque_id: 2, width: self.options.width, height: self.options.height, device_scale_factor: 1 });
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
  return new Result$Ok$3$(undefined);
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
  return Option$None$1$;
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
  return Option$None$1$;
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
    return new Result$Ok$3$(undefined);
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
  return new Result$Ok$3$(undefined);
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
  return new Result$Ok$3$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(self, present) {
  if (self.initialized) {
    self.end_count = self.end_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx15native__on__end(self.native_active, present);
    _M0FP36mizchi6kagura3gfx22web__graphics__on__end(self.web_active, self.backend, present);
  }
  return new Result$Ok$3$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(self, width, height) {
  const next_width = width <= 0 ? 1 : width;
  const next_height = height <= 0 ? 1 : height;
  if (self.width === next_width && self.height === next_height) {
    self.resize_suppressed_count = self.resize_suppressed_count + 1 | 0;
    return new Result$Ok$3$(undefined);
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
  return new Result$Ok$3$(undefined);
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
  return new Result$Ok$3$(undefined);
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
function _M0FP36mizchi6kagura9inpututil32is__mouse__button__just__pressed(state, button) {
  return _M0FP36mizchi6kagura9inpututil13contains__key(state.just_pressed_buttons, button);
}
function _M0FP36mizchi6kagura9inpututil33is__mouse__button__just__released(state, button) {
  return _M0FP36mizchi6kagura9inpututil13contains__key(state.just_released_buttons, button);
}
function _M0FP36mizchi6kagura9inpututil18new__input__helper() {
  return { key_state: _M0FP36mizchi6kagura9inpututil22new__key__input__state(), mouse_state: _M0FP36mizchi6kagura9inpututil24new__mouse__input__state(), touch_state: _M0FP36mizchi6kagura9inpututil24new__touch__input__state() };
}
function _M0FP36mizchi6kagura9inpututil21update__input__helper(helper, snapshot) {
  _M0FP36mizchi6kagura9inpututil25update__key__input__state(helper.key_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__mouse__input__state(helper.mouse_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__touch__input__state(helper.touch_state, snapshot);
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
function _M0MP36mizchi6kagura6vector4Vec23sub(self, other) {
  return { x: self.x - other.x, y: self.y - other.y };
}
function _M0MP36mizchi6kagura6vector4Vec27unit__y() {
  return { x: 0, y: 1 };
}
function _M0MP36mizchi6kagura6vector4Vec23add(self, other) {
  return { x: self.x + other.x, y: self.y + other.y };
}
function _M0MP36mizchi6kagura6vector4Vec26negate(self) {
  return { x: -self.x, y: -self.y };
}
function _M0MP36mizchi6kagura6vector4Vec23dot(self, other) {
  return self.x * other.x + self.y * other.y;
}
function _M0MP36mizchi6kagura6vector4Vec25cross(self, other) {
  return self.x * other.y - self.y * other.x;
}
function _M0MP36mizchi6kagura6vector4Vec26rotate(self, angle_rad) {
  const cos_a = _M0FP311moonbitlang4core4math3cos(angle_rad);
  const sin_a = _M0FP311moonbitlang4core4math3sin(angle_rad);
  return { x: self.x * cos_a - self.y * sin_a, y: self.x * sin_a + self.y * cos_a };
}
function _M0MP36mizchi6kagura6vector4Vec23min(self, other) {
  return { x: _M0FP311moonbitlang4core3cmp7minimumGdE(self.x, other.x), y: _M0FP311moonbitlang4core3cmp7minimumGdE(self.y, other.y) };
}
function _M0MP36mizchi6kagura6vector4Vec23max(self, other) {
  return { x: _M0FP311moonbitlang4core3cmp7maximumGdE(self.x, other.x), y: _M0FP311moonbitlang4core3cmp7maximumGdE(self.y, other.y) };
}
function _M0MP36mizchi6kagura6vector4Vec25clamp(self, min, max) {
  return _M0MP36mizchi6kagura6vector4Vec23min(_M0MP36mizchi6kagura6vector4Vec23max(self, min), max);
}
function _M0FP36mizchi6kagura9debugutil23color__from__hex__alpha(hex, alpha) {
  const r = ((hex >> 16 & 255) + 0) / 255;
  const g = ((hex >> 8 & 255) + 0) / 255;
  const b = ((hex & 255) + 0) / 255;
  return _M0FP36mizchi6kagura3gfx10new__color(r, g, b, alpha);
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
function _M0FP36mizchi6kagura9debugutil18new__line__command(dst, shader, x0, y0, x1, y1, width, color, pipeline_id) {
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
  const uniform = _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color);
  const min_x = x0 < x1 ? x0 : x1;
  const min_y = y0 < y1 ? y0 : y1;
  const max_x = x0 > x1 ? x0 : x1;
  const max_y = y0 > y1 ? y0 : y1;
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(_M0MP311moonbitlang4core6double6Double7to__int(min_x), _M0MP311moonbitlang4core6double6Double7to__int(min_y), _M0MP311moonbitlang4core6double6Double7to__int(max_x - min_x + width), _M0MP311moonbitlang4core6double6Double7to__int(max_y - min_y + width), 6)], 0, pipeline_id, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), vertices, indices, [], uniform, 1, 0);
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
function _M0FP36mizchi6kagura9debugutil26new__simple__draw__command(dst, shader, vertices, indices, color) {
  const uniform = _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, 0, 0, indices.length)], 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), vertices, indices, [], uniform, 1, 0);
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
      return new Result$Ok$3$(undefined);
    } else {
      const _Some = _bind;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  _M0FP26mizchi5audio11stop__voice(self.mixer, vid);
  return new Result$Ok$3$(undefined);
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
function _M0MP36mizchi6kagura9physics2d14SolverConfig2D7default() {
  return { substeps: 4, velocity_iterations: 1, contact_hertz: 30, contact_damping_ratio: 1 };
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D3new(cell_size) {
  const _tmp = 1 / cell_size;
  const _bind = [];
  return { cell_size: cell_size, inv_cell_size: _tmp, cells: _M0MP311moonbitlang4core7builtin3Map11from__arrayGlRP311moonbitlang4core7builtin5ArrayGiEE({ buf: _bind, start: 0, end: 0 }), entries: [] };
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D11new_2einner(gravity, broadphase_cell_size, solver_config) {
  const _tmp = [];
  const _tmp$2 = _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D3new(broadphase_cell_size);
  const _bind = [];
  return { bodies: _tmp, gravity: gravity, broadphase: _tmp$2, solver_config: solver_config, contact_cache: _M0MP311moonbitlang4core7builtin3Map11from__arrayGlRP36mizchi6kagura9physics2d17ContactManifold2DE({ buf: _bind, start: 0, end: 0 }), joints_distance: [], joints_revolute: [] };
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D3new(gravity, broadphase_cell_size, solver_config$46$opt) {
  let solver_config;
  if (solver_config$46$opt === undefined) {
    solver_config = _M0MP36mizchi6kagura9physics2d14SolverConfig2D7default();
  } else {
    const _Some = solver_config$46$opt;
    solver_config = _Some;
  }
  return _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D11new_2einner(gravity, broadphase_cell_size, solver_config);
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(self, body) {
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, body);
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9get__body(self, id) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < self.bodies.length) {
      if (_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i).id === id) {
        return _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return undefined;
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D12apply__force(self, f) {
  return { ...self, force: _M0MP36mizchi6kagura6vector4Vec23add(self.force, f) };
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D12apply__force(self, body_id, force) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < self.bodies.length) {
      if (_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i).id === body_id) {
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, _M0MP36mizchi6kagura9physics2d11RigidBody2D12apply__force(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i), force));
        break;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(self, joint) {
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d15RevoluteJoint2DE(self.joints_revolute, joint);
}
function _M0FP36mizchi6kagura9physics2d8uf__find(parent, i) {
  const x = { val: i };
  while (true) {
    if (_M0MP311moonbitlang4core5array5Array2atGiE(parent, x.val) === x.val) {
      return x.val;
    }
    _M0MP311moonbitlang4core5array5Array3setGiE(parent, x.val, _M0MP311moonbitlang4core5array5Array2atGiE(parent, _M0MP311moonbitlang4core5array5Array2atGiE(parent, x.val)));
    x.val = _M0MP311moonbitlang4core5array5Array2atGiE(parent, x.val);
    continue;
  }
}
function _M0FP36mizchi6kagura9physics2d9uf__union(parent, rank, a, b) {
  const ra = _M0FP36mizchi6kagura9physics2d8uf__find(parent, a);
  const rb = _M0FP36mizchi6kagura9physics2d8uf__find(parent, b);
  if (ra === rb) {
    return undefined;
  }
  if (_M0MP311moonbitlang4core5array5Array2atGiE(rank, ra) < _M0MP311moonbitlang4core5array5Array2atGiE(rank, rb)) {
    _M0MP311moonbitlang4core5array5Array3setGiE(parent, ra, rb);
    return;
  } else {
    if (_M0MP311moonbitlang4core5array5Array2atGiE(rank, ra) > _M0MP311moonbitlang4core5array5Array2atGiE(rank, rb)) {
      _M0MP311moonbitlang4core5array5Array3setGiE(parent, rb, ra);
      return;
    } else {
      _M0MP311moonbitlang4core5array5Array3setGiE(parent, rb, ra);
      _M0MP311moonbitlang4core5array5Array3setGiE(rank, ra, _M0MP311moonbitlang4core5array5Array2atGiE(rank, ra) + 1 | 0);
      return;
    }
  }
}
function _M0FP36mizchi6kagura9physics2d18contact__pair__key(id_a, id_b) {
  const min_id = id_a < id_b ? id_a : id_b;
  const max_id = id_a < id_b ? id_b : id_a;
  return _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin5BitOr3lor(_M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin3Shl3shl(_M0MP311moonbitlang4core3int3Int9to__int64(min_id), 32), _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin6BitAnd4land(_M0MP311moonbitlang4core3int3Int9to__int64(max_id), $4294967295L));
}
function _M0FP36mizchi6kagura9physics2d19sweep__circle__aabb(circle_pos, circle_vel, circle_radius, aabb_min, aabb_max) {
  const expanded_min = _M0MP36mizchi6kagura6vector4Vec23new(aabb_min.x - circle_radius, aabb_min.y - circle_radius);
  const expanded_max = _M0MP36mizchi6kagura6vector4Vec23new(aabb_max.x + circle_radius, aabb_max.y + circle_radius);
  if (circle_pos.x >= expanded_min.x && (circle_pos.x <= expanded_max.x && (circle_pos.y >= expanded_min.y && circle_pos.y <= expanded_max.y))) {
    return new Option$Some$6$(0);
  }
  const t_min = { val: 0 };
  const t_max = { val: 1 };
  if (Math.abs(circle_vel.x) < 1e-12) {
    if (circle_pos.x < expanded_min.x || circle_pos.x > expanded_max.x) {
      return Option$None$6$;
    }
  } else {
    const inv_d = 1 / circle_vel.x;
    const t1 = { val: (expanded_min.x - circle_pos.x) * inv_d };
    const t2 = { val: (expanded_max.x - circle_pos.x) * inv_d };
    if (t1.val > t2.val) {
      const tmp = t1.val;
      t1.val = t2.val;
      t2.val = tmp;
    }
    if (t1.val > t_min.val) {
      t_min.val = t1.val;
    }
    if (t2.val < t_max.val) {
      t_max.val = t2.val;
    }
    if (t_min.val > t_max.val) {
      return Option$None$6$;
    }
  }
  if (Math.abs(circle_vel.y) < 1e-12) {
    if (circle_pos.y < expanded_min.y || circle_pos.y > expanded_max.y) {
      return Option$None$6$;
    }
  } else {
    const inv_d = 1 / circle_vel.y;
    const t1 = { val: (expanded_min.y - circle_pos.y) * inv_d };
    const t2 = { val: (expanded_max.y - circle_pos.y) * inv_d };
    if (t1.val > t2.val) {
      const tmp = t1.val;
      t1.val = t2.val;
      t2.val = tmp;
    }
    if (t1.val > t_min.val) {
      t_min.val = t1.val;
    }
    if (t2.val < t_max.val) {
      t_max.val = t2.val;
    }
    if (t_min.val > t_max.val) {
      return Option$None$6$;
    }
  }
  return t_min.val >= 0 && t_min.val <= 1 ? new Option$Some$6$(t_min.val) : Option$None$6$;
}
function _M0FP36mizchi6kagura9physics2d21sweep__circle__circle(pos_a, vel_a, radius_a, pos_b, vel_b, radius_b) {
  const r = radius_a + radius_b;
  const d = _M0MP36mizchi6kagura6vector4Vec23sub(pos_a, pos_b);
  const v = _M0MP36mizchi6kagura6vector4Vec23sub(vel_a, vel_b);
  const a = _M0MP36mizchi6kagura6vector4Vec23dot(v, v);
  const b = _M0MP36mizchi6kagura6vector4Vec23dot(d, v);
  const c = _M0MP36mizchi6kagura6vector4Vec23dot(d, d) - r * r;
  if (c <= 0) {
    return new Option$Some$6$(0);
  }
  if (a < 1e-12) {
    return Option$None$6$;
  }
  const discriminant = b * b - a * c;
  if (discriminant < 0) {
    return Option$None$6$;
  }
  const sqrt_disc = Math.sqrt(discriminant);
  const t = (-b - sqrt_disc) / a;
  return t >= 0 && t <= 1 ? new Option$Some$6$(t) : Option$None$6$;
}
function _M0FP36mizchi6kagura9physics2d16ccd__sweep__body(bullet_idx, bodies, dt) {
  const bullet = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, bullet_idx);
  const displacement = _M0MP36mizchi6kagura6vector4Vec25scale(bullet.velocity, dt);
  const speed = _M0MP36mizchi6kagura6vector4Vec26length(displacement);
  let bullet_radius;
  let he;
  _L: {
    _L$2: {
      const _bind = bullet.collider;
      switch (_bind.$tag) {
        case 0: {
          const _CircleShape = _bind;
          const _r = _CircleShape._1;
          bullet_radius = _r;
          break;
        }
        case 1: {
          const _AABBShape2D = _bind;
          const _he = _AABBShape2D._0;
          he = _he;
          break _L$2;
        }
        default: {
          const _OBBShape2D = _bind;
          const _he$2 = _OBBShape2D._0;
          he = _he$2;
          break _L$2;
        }
      }
      break _L;
    }
    const r = _M0MP36mizchi6kagura6vector4Vec26length(he);
    bullet_radius = r < 1e-08 ? 0.5 : r;
  }
  if (speed < bullet_radius * 0.5) {
    return Option$None$6$;
  }
  const min_toi = { val: Option$None$6$ };
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < bodies.length) {
      if (i === bullet_idx) {
      } else {
        const other = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, i);
        const other_vel = _M0MP36mizchi6kagura6vector4Vec25scale(other.velocity, dt);
        let toi;
        _L$2: {
          _L$3: {
            let r_a;
            let off_a;
            let he$2;
            let off_b;
            _L$4: {
              _L$5: {
                let r_a$2;
                let off_a$2;
                let off_b$2;
                let r_b;
                _L$6: {
                  const _bind = bullet.collider;
                  const _bind$2 = other.collider;
                  if (_bind.$tag === 0) {
                    const _CircleShape = _bind;
                    const _off_a = _CircleShape._0;
                    const _r_a = _CircleShape._1;
                    switch (_bind$2.$tag) {
                      case 0: {
                        const _CircleShape$2 = _bind$2;
                        const _off_b = _CircleShape$2._0;
                        const _r_b = _CircleShape$2._1;
                        r_a$2 = _r_a;
                        off_a$2 = _off_a;
                        off_b$2 = _off_b;
                        r_b = _r_b;
                        break _L$6;
                      }
                      case 1: {
                        const _AABBShape2D = _bind$2;
                        const _he = _AABBShape2D._0;
                        const _off_b$2 = _AABBShape2D._1;
                        r_a = _r_a;
                        off_a = _off_a;
                        he$2 = _he;
                        off_b = _off_b$2;
                        break _L$5;
                      }
                      default: {
                        break _L$3;
                      }
                    }
                  } else {
                    break _L$3;
                  }
                }
                toi = _M0FP36mizchi6kagura9physics2d21sweep__circle__circle(_M0MP36mizchi6kagura6vector4Vec23add(bullet.position, off_a$2), displacement, r_a$2, _M0MP36mizchi6kagura6vector4Vec23add(other.position, off_b$2), other_vel, r_b);
                break _L$4;
              }
              const center = _M0MP36mizchi6kagura6vector4Vec23add(other.position, off_b);
              toi = _M0FP36mizchi6kagura9physics2d19sweep__circle__aabb(_M0MP36mizchi6kagura6vector4Vec23add(bullet.position, off_a), _M0MP36mizchi6kagura6vector4Vec23sub(displacement, other_vel), r_a, _M0MP36mizchi6kagura6vector4Vec23sub(center, he$2), _M0MP36mizchi6kagura6vector4Vec23add(center, he$2));
            }
            break _L$2;
          }
          toi = Option$None$6$;
        }
        let t;
        _L$3: {
          _L$4: {
            if (toi.$tag === 1) {
              const _Some = toi;
              const _t = _Some._0;
              t = _t;
              break _L$4;
            }
            break _L$3;
          }
          let prev;
          _L$5: {
            _L$6: {
              const _bind = min_toi.val;
              if (_bind.$tag === 1) {
                const _Some = _bind;
                const _prev = _Some._0;
                prev = _prev;
                break _L$6;
              } else {
                min_toi.val = new Option$Some$6$(t);
              }
              break _L$5;
            }
            if (t < prev) {
              min_toi.val = new Option$Some$6$(t);
            }
          }
        }
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return min_toi.val;
}
function _M0FP36mizchi6kagura9physics2d14aabb2d__aabb2d(a, he_a, off_a, b, he_b, off_b) {
  const center_a = _M0MP36mizchi6kagura6vector4Vec23add(a.position, off_a);
  const center_b = _M0MP36mizchi6kagura6vector4Vec23add(b.position, off_b);
  const diff = _M0MP36mizchi6kagura6vector4Vec23sub(center_b, center_a);
  const overlap_x = he_a.x + he_b.x - Math.abs(diff.x);
  const overlap_y = he_a.y + he_b.y - Math.abs(diff.y);
  if (overlap_x <= 0 || overlap_y <= 0) {
    return undefined;
  }
  let normal;
  let penetration;
  _L: {
    if (overlap_x <= overlap_y) {
      const nx = diff.x >= 0 ? 1 : -1;
      normal = _M0MP36mizchi6kagura6vector4Vec23new(nx, 0);
      penetration = overlap_x;
      break _L;
    } else {
      const ny = diff.y >= 0 ? 1 : -1;
      normal = _M0MP36mizchi6kagura6vector4Vec23new(0, ny);
      penetration = overlap_y;
      break _L;
    }
  }
  const contact_point = _M0MP36mizchi6kagura6vector4Vec25scale(_M0MP36mizchi6kagura6vector4Vec23add(center_a, center_b), 0.5);
  return { body_a_id: a.id, body_b_id: b.id, normal: normal, penetration: penetration, contact_point: contact_point };
}
function _M0MP36mizchi6kagura9physics2d6AABB2D14closest__point(self, point) {
  return _M0MP36mizchi6kagura6vector4Vec25clamp(point, self.min, self.max);
}
function _M0MP36mizchi6kagura9physics2d6AABB2D15contains__point(self, point) {
  return point.x >= self.min.x && (point.x <= self.max.x && (point.y >= self.min.y && point.y <= self.max.y));
}
function _M0MP36mizchi6kagura9physics2d6AABB2D3new(min, max) {
  return { min: min, max: max };
}
function _M0FP36mizchi6kagura9physics2d14circle__aabb2d(circle_body, circle_off, circle_r, box_body, box_he, box_off, swapped) {
  const circle_center = _M0MP36mizchi6kagura6vector4Vec23add(circle_body.position, circle_off);
  const box_center = _M0MP36mizchi6kagura6vector4Vec23add(box_body.position, box_off);
  const box_aabb = _M0MP36mizchi6kagura9physics2d6AABB2D3new(_M0MP36mizchi6kagura6vector4Vec23sub(box_center, box_he), _M0MP36mizchi6kagura6vector4Vec23add(box_center, box_he));
  if (_M0MP36mizchi6kagura9physics2d6AABB2D15contains__point(box_aabb, circle_center)) {
    const dx_left = circle_center.x - box_aabb.min.x;
    const dx_right = box_aabb.max.x - circle_center.x;
    const dy_bottom = circle_center.y - box_aabb.min.y;
    const dy_top = box_aabb.max.y - circle_center.y;
    const min_dist = { val: dx_left };
    const face_outward = { val: _M0MP36mizchi6kagura6vector4Vec23new(-1, 0) };
    if (dx_right < min_dist.val) {
      min_dist.val = dx_right;
      face_outward.val = _M0MP36mizchi6kagura6vector4Vec23new(1, 0);
    }
    if (dy_bottom < min_dist.val) {
      min_dist.val = dy_bottom;
      face_outward.val = _M0MP36mizchi6kagura6vector4Vec23new(0, -1);
    }
    if (dy_top < min_dist.val) {
      min_dist.val = dy_top;
      face_outward.val = _M0MP36mizchi6kagura6vector4Vec23new(0, 1);
    }
    const penetration = min_dist.val + circle_r;
    const contact_point = _M0MP36mizchi6kagura6vector4Vec23add(circle_center, _M0MP36mizchi6kagura6vector4Vec25scale(face_outward.val, min_dist.val));
    return swapped ? { body_a_id: box_body.id, body_b_id: circle_body.id, normal: face_outward.val, penetration: penetration, contact_point: contact_point } : { body_a_id: circle_body.id, body_b_id: box_body.id, normal: _M0MP36mizchi6kagura6vector4Vec26negate(face_outward.val), penetration: penetration, contact_point: contact_point };
  } else {
    const closest = _M0MP36mizchi6kagura9physics2d6AABB2D14closest__point(box_aabb, circle_center);
    const diff = _M0MP36mizchi6kagura6vector4Vec23sub(circle_center, closest);
    const dist_sq = _M0MP36mizchi6kagura6vector4Vec215length__squared(diff);
    if (dist_sq >= circle_r * circle_r) {
      return undefined;
    }
    const dist = Math.sqrt(dist_sq);
    const normal = dist < 1e-12 ? _M0MP36mizchi6kagura6vector4Vec27unit__y() : _M0MP36mizchi6kagura6vector4Vec25scale(diff, 1 / dist);
    const penetration = circle_r - dist;
    return swapped ? { body_a_id: box_body.id, body_b_id: circle_body.id, normal: normal, penetration: penetration, contact_point: closest } : { body_a_id: circle_body.id, body_b_id: box_body.id, normal: _M0MP36mizchi6kagura6vector4Vec26negate(normal), penetration: penetration, contact_point: closest };
  }
}
function _M0FP36mizchi6kagura9physics2d14circle__circle(a, off_a, r_a, b, off_b, r_b) {
  const center_a = _M0MP36mizchi6kagura6vector4Vec23add(a.position, off_a);
  const center_b = _M0MP36mizchi6kagura6vector4Vec23add(b.position, off_b);
  const diff = _M0MP36mizchi6kagura6vector4Vec23sub(center_b, center_a);
  const dist_sq = _M0MP36mizchi6kagura6vector4Vec215length__squared(diff);
  const r_sum = r_a + r_b;
  if (dist_sq >= r_sum * r_sum) {
    return undefined;
  }
  const dist = Math.sqrt(dist_sq);
  const normal = dist < 1e-12 ? _M0MP36mizchi6kagura6vector4Vec27unit__y() : _M0MP36mizchi6kagura6vector4Vec25scale(diff, 1 / dist);
  const penetration = r_sum - dist;
  const contact_point = _M0MP36mizchi6kagura6vector4Vec23add(center_a, _M0MP36mizchi6kagura6vector4Vec25scale(normal, r_a - penetration * 0.5));
  return { body_a_id: a.id, body_b_id: b.id, normal: normal, penetration: penetration, contact_point: contact_point };
}
function _M0FP36mizchi6kagura9physics2d11obb__circle(obb_body, obb_he, obb_off, circle_body, circle_off, circle_r, swapped) {
  const obb_center = _M0MP36mizchi6kagura6vector4Vec23add(obb_body.position, _M0MP36mizchi6kagura6vector4Vec26rotate(obb_off, obb_body.angle));
  const circle_center = _M0MP36mizchi6kagura6vector4Vec23add(circle_body.position, circle_off);
  const diff = _M0MP36mizchi6kagura6vector4Vec23sub(circle_center, obb_center);
  const loc = _M0MP36mizchi6kagura6vector4Vec26rotate(diff, -obb_body.angle);
  const closest_x = { val: loc.x };
  const closest_y = { val: loc.y };
  if (closest_x.val > obb_he.x) {
    closest_x.val = obb_he.x;
  } else {
    if (closest_x.val < -obb_he.x) {
      closest_x.val = -obb_he.x;
    }
  }
  if (closest_y.val > obb_he.y) {
    closest_y.val = obb_he.y;
  } else {
    if (closest_y.val < -obb_he.y) {
      closest_y.val = -obb_he.y;
    }
  }
  const inside = loc.x === closest_x.val && loc.y === closest_y.val;
  if (inside) {
    const dx_pos = obb_he.x - loc.x;
    const dx_neg = obb_he.x + loc.x;
    const dy_pos = obb_he.y - loc.y;
    const dy_neg = obb_he.y + loc.y;
    const min_dist = { val: dx_pos };
    const loc_normal = { val: _M0MP36mizchi6kagura6vector4Vec23new(1, 0) };
    if (dx_neg < min_dist.val) {
      min_dist.val = dx_neg;
      loc_normal.val = _M0MP36mizchi6kagura6vector4Vec23new(-1, 0);
    }
    if (dy_pos < min_dist.val) {
      min_dist.val = dy_pos;
      loc_normal.val = _M0MP36mizchi6kagura6vector4Vec23new(0, 1);
    }
    if (dy_neg < min_dist.val) {
      min_dist.val = dy_neg;
      loc_normal.val = _M0MP36mizchi6kagura6vector4Vec23new(0, -1);
    }
    const penetration = min_dist.val + circle_r;
    const world_normal = _M0MP36mizchi6kagura6vector4Vec26rotate(loc_normal.val, obb_body.angle);
    const cp_local = _M0MP36mizchi6kagura6vector4Vec23new(closest_x.val, closest_y.val);
    const contact_point = _M0MP36mizchi6kagura6vector4Vec23add(obb_center, _M0MP36mizchi6kagura6vector4Vec26rotate(cp_local, obb_body.angle));
    return swapped ? { body_a_id: circle_body.id, body_b_id: obb_body.id, normal: _M0MP36mizchi6kagura6vector4Vec26negate(world_normal), penetration: penetration, contact_point: contact_point } : { body_a_id: obb_body.id, body_b_id: circle_body.id, normal: world_normal, penetration: penetration, contact_point: contact_point };
  } else {
    const closest_local = _M0MP36mizchi6kagura6vector4Vec23new(closest_x.val, closest_y.val);
    const diff_local = _M0MP36mizchi6kagura6vector4Vec23sub(loc, closest_local);
    const dist_sq = _M0MP36mizchi6kagura6vector4Vec215length__squared(diff_local);
    if (dist_sq >= circle_r * circle_r) {
      return undefined;
    }
    const dist = Math.sqrt(dist_sq);
    const loc_normal = dist < 1e-12 ? _M0MP36mizchi6kagura6vector4Vec27unit__y() : _M0MP36mizchi6kagura6vector4Vec25scale(diff_local, 1 / dist);
    const penetration = circle_r - dist;
    const world_normal = _M0MP36mizchi6kagura6vector4Vec26rotate(loc_normal, obb_body.angle);
    const contact_point = _M0MP36mizchi6kagura6vector4Vec23add(obb_center, _M0MP36mizchi6kagura6vector4Vec26rotate(closest_local, obb_body.angle));
    return swapped ? { body_a_id: circle_body.id, body_b_id: obb_body.id, normal: _M0MP36mizchi6kagura6vector4Vec26negate(world_normal), penetration: penetration, contact_point: contact_point } : { body_a_id: obb_body.id, body_b_id: circle_body.id, normal: world_normal, penetration: penetration, contact_point: contact_point };
  }
}
function _M0FP36mizchi6kagura9physics2d14point__in__obb(point, center, half_extents, angle) {
  const diff = _M0MP36mizchi6kagura6vector4Vec23sub(point, center);
  const lx = _M0MP36mizchi6kagura6vector4Vec26rotate(diff, -angle);
  return Math.abs(lx.x) <= half_extents.x && Math.abs(lx.y) <= half_extents.y;
}
function _M0FP36mizchi6kagura9physics2d22project__obb__on__axis(center, axis_x, axis_y, he, axis) {
  const c = _M0MP36mizchi6kagura6vector4Vec23dot(center, axis);
  const r = Math.abs(_M0MP36mizchi6kagura6vector4Vec23dot(axis_x, axis) * he.x) + Math.abs(_M0MP36mizchi6kagura6vector4Vec23dot(axis_y, axis) * he.y);
  return { _0: c - r, _1: c + r };
}
function _M0FP36mizchi6kagura9physics2d8obb__obb(a, he_a, off_a, b, he_b, off_b) {
  const center_a = _M0MP36mizchi6kagura6vector4Vec23add(a.position, _M0MP36mizchi6kagura6vector4Vec26rotate(off_a, a.angle));
  const center_b = _M0MP36mizchi6kagura6vector4Vec23add(b.position, _M0MP36mizchi6kagura6vector4Vec26rotate(off_b, b.angle));
  const ax_a = _M0MP36mizchi6kagura6vector4Vec23new(_M0FP311moonbitlang4core4math3cos(a.angle), _M0FP311moonbitlang4core4math3sin(a.angle));
  const ay_a = _M0MP36mizchi6kagura6vector4Vec23new(-_M0FP311moonbitlang4core4math3sin(a.angle), _M0FP311moonbitlang4core4math3cos(a.angle));
  const ax_b = _M0MP36mizchi6kagura6vector4Vec23new(_M0FP311moonbitlang4core4math3cos(b.angle), _M0FP311moonbitlang4core4math3sin(b.angle));
  const ay_b = _M0MP36mizchi6kagura6vector4Vec23new(-_M0FP311moonbitlang4core4math3sin(b.angle), _M0FP311moonbitlang4core4math3cos(b.angle));
  const axes = [ax_a, ay_a, ax_b, ay_b];
  const min_overlap = { val: 1e+30 };
  const best_axis = { val: _M0MP36mizchi6kagura6vector4Vec24zero() };
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < axes.length) {
      const axis = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6vector4Vec2E(axes, i);
      let min_a;
      let max_a;
      _L: {
        const _bind = _M0FP36mizchi6kagura9physics2d22project__obb__on__axis(center_a, ax_a, ay_a, he_a, axis);
        const _min_a = _bind._0;
        const _max_a = _bind._1;
        min_a = _min_a;
        max_a = _max_a;
        break _L;
      }
      let min_b;
      let max_b;
      _L$2: {
        const _bind = _M0FP36mizchi6kagura9physics2d22project__obb__on__axis(center_b, ax_b, ay_b, he_b, axis);
        const _min_b = _bind._0;
        const _max_b = _bind._1;
        min_b = _min_b;
        max_b = _max_b;
        break _L$2;
      }
      let overlap;
      if (max_a < min_b || max_b < min_a) {
        return undefined;
      } else {
        const o1 = max_a - min_b;
        const o2 = max_b - min_a;
        overlap = o1 < o2 ? o1 : o2;
      }
      if (overlap < min_overlap.val) {
        min_overlap.val = overlap;
        const dir = _M0MP36mizchi6kagura6vector4Vec23sub(center_b, center_a);
        best_axis.val = _M0MP36mizchi6kagura6vector4Vec23dot(dir, axis) >= 0 ? axis : _M0MP36mizchi6kagura6vector4Vec26negate(axis);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const local_corners_a = [_M0MP36mizchi6kagura6vector4Vec23new(-he_a.x, -he_a.y), _M0MP36mizchi6kagura6vector4Vec23new(he_a.x, -he_a.y), _M0MP36mizchi6kagura6vector4Vec23new(he_a.x, he_a.y), _M0MP36mizchi6kagura6vector4Vec23new(-he_a.x, he_a.y)];
  const local_corners_b = [_M0MP36mizchi6kagura6vector4Vec23new(-he_b.x, -he_b.y), _M0MP36mizchi6kagura6vector4Vec23new(he_b.x, -he_b.y), _M0MP36mizchi6kagura6vector4Vec23new(he_b.x, he_b.y), _M0MP36mizchi6kagura6vector4Vec23new(-he_b.x, he_b.y)];
  const cp_sum = { val: _M0MP36mizchi6kagura6vector4Vec24zero() };
  const cp_count = { val: 0 };
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < 4) {
      const v = _M0MP36mizchi6kagura6vector4Vec23add(center_a, _M0MP36mizchi6kagura6vector4Vec26rotate(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6vector4Vec2E(local_corners_a, i), a.angle));
      if (_M0FP36mizchi6kagura9physics2d14point__in__obb(v, center_b, he_b, b.angle)) {
        cp_sum.val = _M0MP36mizchi6kagura6vector4Vec23add(cp_sum.val, v);
        cp_count.val = cp_count.val + 1 | 0;
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$3 = 0;
  while (true) {
    const i = _tmp$3;
    if (i < 4) {
      const v = _M0MP36mizchi6kagura6vector4Vec23add(center_b, _M0MP36mizchi6kagura6vector4Vec26rotate(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura6vector4Vec2E(local_corners_b, i), b.angle));
      if (_M0FP36mizchi6kagura9physics2d14point__in__obb(v, center_a, he_a, a.angle)) {
        cp_sum.val = _M0MP36mizchi6kagura6vector4Vec23add(cp_sum.val, v);
        cp_count.val = cp_count.val + 1 | 0;
      }
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let contact_point;
  if (cp_count.val > 0) {
    contact_point = _M0MP36mizchi6kagura6vector4Vec25scale(cp_sum.val, 1 / (cp_count.val + 0));
  } else {
    const mid = _M0MP36mizchi6kagura6vector4Vec25scale(_M0MP36mizchi6kagura6vector4Vec23add(center_a, center_b), 0.5);
    const proj_diff = _M0MP36mizchi6kagura6vector4Vec23dot(_M0MP36mizchi6kagura6vector4Vec23sub(center_b, center_a), best_axis.val);
    contact_point = _M0MP36mizchi6kagura6vector4Vec23sub(mid, _M0MP36mizchi6kagura6vector4Vec25scale(best_axis.val, proj_diff * 0.5));
  }
  return { body_a_id: a.id, body_b_id: b.id, normal: best_axis.val, penetration: min_overlap.val, contact_point: contact_point };
}
function _M0FP36mizchi6kagura9physics2d19generate__contact2d(a, b) {
  let off_a;
  let he_a;
  let he_b;
  let off_b;
  _L: {
    let off_a$2;
    let he_a$2;
    let he_b$2;
    let off_b$2;
    _L$2: {
      let r_a;
      let off_a$3;
      let he_b$3;
      let off_b$3;
      _L$3: {
        let off_a$4;
        let he_a$3;
        let off_b$4;
        let r_b;
        _L$4: {
          let off_a$5;
          let he_a$4;
          let he_b$4;
          let off_b$5;
          _L$5: {
            let off_a$6;
            let he_a$5;
            let off_b$6;
            let r_b$2;
            _L$6: {
              let r_a$2;
              let off_a$7;
              let he_b$5;
              let off_b$7;
              _L$7: {
                let off_a$8;
                let he_a$6;
                let he_b$6;
                let off_b$8;
                _L$8: {
                  let r_a$3;
                  let off_a$9;
                  let off_b$9;
                  let r_b$3;
                  _L$9: {
                    const _bind = a.collider;
                    const _bind$2 = b.collider;
                    switch (_bind.$tag) {
                      case 0: {
                        const _CircleShape = _bind;
                        const _off_a = _CircleShape._0;
                        const _r_a = _CircleShape._1;
                        switch (_bind$2.$tag) {
                          case 0: {
                            const _CircleShape$2 = _bind$2;
                            const _off_b = _CircleShape$2._0;
                            const _r_b = _CircleShape$2._1;
                            r_a$3 = _r_a;
                            off_a$9 = _off_a;
                            off_b$9 = _off_b;
                            r_b$3 = _r_b;
                            break _L$9;
                          }
                          case 1: {
                            const _AABBShape2D = _bind$2;
                            const _he_b = _AABBShape2D._0;
                            const _off_b$2 = _AABBShape2D._1;
                            r_a$2 = _r_a;
                            off_a$7 = _off_a;
                            he_b$5 = _he_b;
                            off_b$7 = _off_b$2;
                            break _L$7;
                          }
                          default: {
                            const _OBBShape2D = _bind$2;
                            const _he_b$2 = _OBBShape2D._0;
                            const _off_b$3 = _OBBShape2D._1;
                            r_a = _r_a;
                            off_a$3 = _off_a;
                            he_b$3 = _he_b$2;
                            off_b$3 = _off_b$3;
                            break _L$3;
                          }
                        }
                      }
                      case 1: {
                        const _AABBShape2D$2 = _bind;
                        const _he_a = _AABBShape2D$2._0;
                        const _off_a$2 = _AABBShape2D$2._1;
                        switch (_bind$2.$tag) {
                          case 1: {
                            const _AABBShape2D$3 = _bind$2;
                            const _he_b$3 = _AABBShape2D$3._0;
                            const _off_b$4 = _AABBShape2D$3._1;
                            off_a$8 = _off_a$2;
                            he_a$6 = _he_a;
                            he_b$6 = _he_b$3;
                            off_b$8 = _off_b$4;
                            break _L$8;
                          }
                          case 0: {
                            const _CircleShape$3 = _bind$2;
                            const _off_b$5 = _CircleShape$3._0;
                            const _r_b$2 = _CircleShape$3._1;
                            off_a$6 = _off_a$2;
                            he_a$5 = _he_a;
                            off_b$6 = _off_b$5;
                            r_b$2 = _r_b$2;
                            break _L$6;
                          }
                          default: {
                            const _OBBShape2D$2 = _bind$2;
                            const _he_b$4 = _OBBShape2D$2._0;
                            const _off_b$6 = _OBBShape2D$2._1;
                            off_a = _off_a$2;
                            he_a = _he_a;
                            he_b = _he_b$4;
                            off_b = _off_b$6;
                            break _L;
                          }
                        }
                      }
                      default: {
                        const _OBBShape2D$3 = _bind;
                        const _he_a$2 = _OBBShape2D$3._0;
                        const _off_a$3 = _OBBShape2D$3._1;
                        switch (_bind$2.$tag) {
                          case 2: {
                            const _OBBShape2D$4 = _bind$2;
                            const _he_b$5 = _OBBShape2D$4._0;
                            const _off_b$7 = _OBBShape2D$4._1;
                            off_a$5 = _off_a$3;
                            he_a$4 = _he_a$2;
                            he_b$4 = _he_b$5;
                            off_b$5 = _off_b$7;
                            break _L$5;
                          }
                          case 0: {
                            const _CircleShape$4 = _bind$2;
                            const _off_b$8 = _CircleShape$4._0;
                            const _r_b$3 = _CircleShape$4._1;
                            off_a$4 = _off_a$3;
                            he_a$3 = _he_a$2;
                            off_b$4 = _off_b$8;
                            r_b = _r_b$3;
                            break _L$4;
                          }
                          default: {
                            const _AABBShape2D$4 = _bind$2;
                            const _he_b$6 = _AABBShape2D$4._0;
                            const _off_b$9 = _AABBShape2D$4._1;
                            off_a$2 = _off_a$3;
                            he_a$2 = _he_a$2;
                            he_b$2 = _he_b$6;
                            off_b$2 = _off_b$9;
                            break _L$2;
                          }
                        }
                      }
                    }
                  }
                  return _M0FP36mizchi6kagura9physics2d14circle__circle(a, off_a$9, r_a$3, b, off_b$9, r_b$3);
                }
                return _M0FP36mizchi6kagura9physics2d14aabb2d__aabb2d(a, he_a$6, off_a$8, b, he_b$6, off_b$8);
              }
              return _M0FP36mizchi6kagura9physics2d14circle__aabb2d(a, off_a$7, r_a$2, b, he_b$5, off_b$7, false);
            }
            return _M0FP36mizchi6kagura9physics2d14circle__aabb2d(b, off_b$6, r_b$2, a, he_a$5, off_a$6, true);
          }
          return _M0FP36mizchi6kagura9physics2d8obb__obb(a, he_a$4, off_a$5, b, he_b$4, off_b$5);
        }
        return _M0FP36mizchi6kagura9physics2d11obb__circle(a, he_a$3, off_a$4, b, off_b$4, r_b, false);
      }
      return _M0FP36mizchi6kagura9physics2d11obb__circle(b, he_b$3, off_b$3, a, off_a$3, r_a, true);
    }
    return _M0FP36mizchi6kagura9physics2d8obb__obb(a, he_a$2, off_a$2, { ...b, angle: 0 }, he_b$2, off_b$2);
  }
  return _M0FP36mizchi6kagura9physics2d8obb__obb({ ...a, angle: 0 }, he_a, off_a, b, he_b, off_b);
}
function _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(omega, r) {
  return _M0MP36mizchi6kagura6vector4Vec23new(-omega * r.y, omega * r.x);
}
function _M0FP36mizchi6kagura9physics2d24precompute__constraint2d(a, b, idx_a, idx_b, contact, hertz, damping_ratio, sub_dt) {
  const inv_mass_sum = a.inv_mass + b.inv_mass;
  const r_a = _M0MP36mizchi6kagura6vector4Vec23sub(contact.contact_point, a.position);
  const r_b = _M0MP36mizchi6kagura6vector4Vec23sub(contact.contact_point, b.position);
  const n = contact.normal;
  const tangent = _M0MP36mizchi6kagura6vector4Vec23new(-n.y, n.x);
  const r_a_cross_n = _M0MP36mizchi6kagura6vector4Vec25cross(r_a, n);
  const r_b_cross_n = _M0MP36mizchi6kagura6vector4Vec25cross(r_b, n);
  const r_a_cross_t = _M0MP36mizchi6kagura6vector4Vec25cross(r_a, tangent);
  const r_b_cross_t = _M0MP36mizchi6kagura6vector4Vec25cross(r_b, tangent);
  const k_normal = inv_mass_sum + r_a_cross_n * r_a_cross_n * a.inv_inertia + r_b_cross_n * r_b_cross_n * b.inv_inertia;
  const k_tangent = inv_mass_sum + r_a_cross_t * r_a_cross_t * a.inv_inertia + r_b_cross_t * r_b_cross_t * b.inv_inertia;
  const omega = 2 * _M0FP36mizchi6kagura9physics2d2pi * hertz;
  const gamma = 1 / (sub_dt * (2 * damping_ratio * omega + sub_dt * omega * omega));
  const beta = sub_dt * omega * omega * gamma;
  const normal_mass = k_normal + gamma > 1e-12 ? 1 / (k_normal + gamma) : 0;
  const tangent_mass = k_tangent > 1e-12 ? 1 / k_tangent : 0;
  const v_a = _M0MP36mizchi6kagura6vector4Vec23add(a.velocity, _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(a.angular_velocity, r_a));
  const v_b = _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(b.angular_velocity, r_b));
  const v_rel = _M0MP36mizchi6kagura6vector4Vec23sub(v_a, v_b);
  const v_n = _M0MP36mizchi6kagura6vector4Vec23dot(v_rel, n);
  const e = a.restitution < b.restitution ? a.restitution : b.restitution;
  const restitution_bias = v_n > _M0FP36mizchi6kagura9physics2d32restitution__velocity__threshold ? e * v_n : 0;
  return { idx_a: idx_a, idx_b: idx_b, contact: contact, r_a: r_a, r_b: r_b, normal_mass: normal_mass, tangent_mass: tangent_mass, gamma: gamma, bias_coefficient: beta, restitution_bias: restitution_bias, acc_jn: 0, acc_jt: 0 };
}
function _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, id) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < bodies.length) {
      if (_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, i).id === id) {
        return i;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return -1;
}
function _M0FP36mizchi6kagura9physics2d12rotate__vec2(v, angle) {
  const c = _M0FP311moonbitlang4core4math3cos(angle);
  const s = _M0FP311moonbitlang4core4math3sin(angle);
  return _M0MP36mizchi6kagura6vector4Vec23new(v.x * c - v.y * s, v.x * s + v.y * c);
}
function _M0FP36mizchi6kagura9physics2d27precompute__distance__joint(joint, bodies, sub_dt) {
  const idx_a = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_a_id);
  const idx_b = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_b_id);
  if (idx_a < 0 || idx_b < 0) {
    return undefined;
  }
  const a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, idx_a);
  const b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, idx_b);
  const r_a = _M0FP36mizchi6kagura9physics2d12rotate__vec2(joint.local_anchor_a, a.angle);
  const r_b = _M0FP36mizchi6kagura9physics2d12rotate__vec2(joint.local_anchor_b, b.angle);
  const world_a = _M0MP36mizchi6kagura6vector4Vec23add(a.position, r_a);
  const world_b = _M0MP36mizchi6kagura6vector4Vec23add(b.position, r_b);
  const delta = _M0MP36mizchi6kagura6vector4Vec23sub(world_b, world_a);
  const current_length = _M0MP36mizchi6kagura6vector4Vec26length(delta);
  const axis = current_length > 1e-08 ? _M0MP36mizchi6kagura6vector4Vec25scale(delta, 1 / current_length) : _M0MP36mizchi6kagura6vector4Vec23new(1, 0);
  const r_a_cross_n = r_a.x * axis.y - r_a.y * axis.x;
  const r_b_cross_n = r_b.x * axis.y - r_b.y * axis.x;
  const k = a.inv_mass + b.inv_mass + r_a_cross_n * r_a_cross_n * a.inv_inertia + r_b_cross_n * r_b_cross_n * b.inv_inertia;
  const omega = 2 * _M0FP36mizchi6kagura9physics2d9joint__pi * joint.hertz;
  const gamma = 1 / (sub_dt * (2 * joint.damping_ratio * omega + sub_dt * omega * omega));
  const beta = sub_dt * omega * omega * gamma;
  const effective_mass = k + gamma > 1e-12 ? 1 / (k + gamma) : 0;
  return { idx_a: idx_a, idx_b: idx_b, r_a: r_a, r_b: r_b, axis: axis, effective_mass: effective_mass, gamma: gamma, bias_coefficient: beta, acc_impulse: 0 };
}
function _M0FP36mizchi6kagura9physics2d27precompute__revolute__joint(joint, bodies, sub_dt) {
  const idx_a = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_a_id);
  const idx_b = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_b_id);
  if (idx_a < 0 || idx_b < 0) {
    return undefined;
  }
  const a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, idx_a);
  const b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, idx_b);
  const r_a = _M0FP36mizchi6kagura9physics2d12rotate__vec2(joint.local_anchor_a, a.angle);
  const r_b = _M0FP36mizchi6kagura9physics2d12rotate__vec2(joint.local_anchor_b, b.angle);
  const omega = 2 * _M0FP36mizchi6kagura9physics2d9joint__pi * joint.hertz;
  const gamma = 1 / (sub_dt * (2 * joint.damping_ratio * omega + sub_dt * omega * omega));
  const beta = sub_dt * omega * omega * gamma;
  const r_a_cross_x = -r_a.y;
  const r_b_cross_x = -r_b.y;
  const k_x = a.inv_mass + b.inv_mass + r_a_cross_x * r_a_cross_x * a.inv_inertia + r_b_cross_x * r_b_cross_x * b.inv_inertia;
  const r_a_cross_y = r_a.x;
  const r_b_cross_y = r_b.x;
  const k_y = a.inv_mass + b.inv_mass + r_a_cross_y * r_a_cross_y * a.inv_inertia + r_b_cross_y * r_b_cross_y * b.inv_inertia;
  const eff_mass_x = k_x + gamma > 1e-12 ? 1 / (k_x + gamma) : 0;
  const eff_mass_y = k_y + gamma > 1e-12 ? 1 / (k_y + gamma) : 0;
  return { idx_a: idx_a, idx_b: idx_b, r_a: r_a, r_b: r_b, effective_mass_x: eff_mass_x, effective_mass_y: eff_mass_y, gamma: gamma, bias_coefficient: beta, acc_impulse_x: 0, acc_impulse_y: 0 };
}
function _M0FP36mizchi6kagura9physics2d14clamp__angular(omega) {
  return omega > _M0FP36mizchi6kagura9physics2d22max__angular__velocity ? _M0FP36mizchi6kagura9physics2d22max__angular__velocity : omega < -_M0FP36mizchi6kagura9physics2d22max__angular__velocity ? -_M0FP36mizchi6kagura9physics2d22max__angular__velocity : omega;
}
function _M0FP36mizchi6kagura9physics2d19solve__constraint2d(constraints, ci, bodies) {
  const c = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d19ContactConstraint2DE(constraints, ci);
  const a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a);
  const b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b);
  const n = c.contact.normal;
  const tangent = _M0MP36mizchi6kagura6vector4Vec23new(-n.y, n.x);
  const d = _M0MP36mizchi6kagura6vector4Vec23sub(_M0MP36mizchi6kagura6vector4Vec23add(b.position, c.r_b), _M0MP36mizchi6kagura6vector4Vec23add(a.position, c.r_a));
  const separation = _M0MP36mizchi6kagura6vector4Vec23dot(d, n) - c.contact.penetration;
  const bias = separation + _M0FP36mizchi6kagura9physics2d4slop < 0 ? -c.bias_coefficient * (separation + _M0FP36mizchi6kagura9physics2d4slop) : 0;
  const v_a = _M0MP36mizchi6kagura6vector4Vec23add(a.velocity, _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(a.angular_velocity, c.r_a));
  const v_b = _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(b.angular_velocity, c.r_b));
  const v_rel = _M0MP36mizchi6kagura6vector4Vec23sub(v_a, v_b);
  const v_n = _M0MP36mizchi6kagura6vector4Vec23dot(v_rel, n);
  const lambda = -(v_n + c.restitution_bias + bias + c.gamma * c.acc_jn) * c.normal_mass;
  const raw = c.acc_jn + lambda;
  const new_acc_jn = raw > 0 ? 0 : raw;
  const delta_jn = new_acc_jn - c.acc_jn;
  const cur_acc_jn = new_acc_jn;
  const cur_acc_jt = { val: c.acc_jt };
  if (Math.abs(delta_jn) > 1e-15) {
    const impulse_n = _M0MP36mizchi6kagura6vector4Vec25scale(n, delta_jn);
    const r_a_cross_n = _M0MP36mizchi6kagura6vector4Vec25cross(c.r_a, n);
    const r_b_cross_n = _M0MP36mizchi6kagura6vector4Vec25cross(c.r_b, n);
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, { ...a, velocity: _M0MP36mizchi6kagura6vector4Vec23add(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_n, a.inv_mass)), angular_velocity: _M0FP36mizchi6kagura9physics2d14clamp__angular(a.angular_velocity + r_a_cross_n * delta_jn * a.inv_inertia) });
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, { ...b, velocity: _M0MP36mizchi6kagura6vector4Vec23sub(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_n, b.inv_mass)), angular_velocity: _M0FP36mizchi6kagura9physics2d14clamp__angular(b.angular_velocity - r_b_cross_n * delta_jn * b.inv_inertia) });
  }
  const a2 = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a);
  const b2 = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b);
  const v_a2 = _M0MP36mizchi6kagura6vector4Vec23add(a2.velocity, _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(a2.angular_velocity, c.r_a));
  const v_b2 = _M0MP36mizchi6kagura6vector4Vec23add(b2.velocity, _M0FP36mizchi6kagura9physics2d18cross__scalar__vec(b2.angular_velocity, c.r_b));
  const v_rel2 = _M0MP36mizchi6kagura6vector4Vec23sub(v_a2, v_b2);
  const v_t = _M0MP36mizchi6kagura6vector4Vec23dot(v_rel2, tangent);
  const mu = (a.friction + b.friction) * 0.5;
  const friction_limit = Math.abs(cur_acc_jn) * mu;
  if (Math.abs(v_t) > 1e-08) {
    const lambda_t = -v_t * c.tangent_mass;
    const raw_acc_jt = cur_acc_jt.val + lambda_t;
    const new_acc_jt = raw_acc_jt > friction_limit ? friction_limit : raw_acc_jt < -friction_limit ? -friction_limit : raw_acc_jt;
    const delta_jt = new_acc_jt - cur_acc_jt.val;
    cur_acc_jt.val = new_acc_jt;
    if (Math.abs(delta_jt) > 1e-15) {
      const impulse_t = _M0MP36mizchi6kagura6vector4Vec25scale(tangent, delta_jt);
      const r_a_cross_t = _M0MP36mizchi6kagura6vector4Vec25cross(c.r_a, tangent);
      const r_b_cross_t = _M0MP36mizchi6kagura6vector4Vec25cross(c.r_b, tangent);
      _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, { ...a2, velocity: _M0MP36mizchi6kagura6vector4Vec23add(a2.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_t, a2.inv_mass)), angular_velocity: _M0FP36mizchi6kagura9physics2d14clamp__angular(a2.angular_velocity + r_a_cross_t * delta_jt * a2.inv_inertia) });
      _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, { ...b2, velocity: _M0MP36mizchi6kagura6vector4Vec23sub(b2.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_t, b2.inv_mass)), angular_velocity: _M0FP36mizchi6kagura9physics2d14clamp__angular(b2.angular_velocity - r_b_cross_t * delta_jt * b2.inv_inertia) });
    }
  }
  _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d19ContactConstraint2DE(constraints, ci, { ...c, acc_jn: cur_acc_jn, acc_jt: cur_acc_jt.val });
}
function _M0FP36mizchi6kagura9physics2d22solve__distance__joint(constraints, ci, bodies, joint) {
  const c = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d25DistanceJointConstraint2DE(constraints, ci);
  const a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a);
  const b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b);
  const world_a = _M0MP36mizchi6kagura6vector4Vec23add(a.position, c.r_a);
  const world_b = _M0MP36mizchi6kagura6vector4Vec23add(b.position, c.r_b);
  const delta = _M0MP36mizchi6kagura6vector4Vec23sub(world_b, world_a);
  const current_length = _M0MP36mizchi6kagura6vector4Vec23dot(delta, c.axis);
  const error = current_length - joint.rest_length;
  const bias = c.bias_coefficient * error;
  const r_a_perp = _M0MP36mizchi6kagura6vector4Vec23new(-c.r_a.y, c.r_a.x);
  const r_b_perp = _M0MP36mizchi6kagura6vector4Vec23new(-c.r_b.y, c.r_b.x);
  const v_a = _M0MP36mizchi6kagura6vector4Vec23add(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(r_a_perp, a.angular_velocity));
  const v_b = _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(r_b_perp, b.angular_velocity));
  const v_rel = _M0MP36mizchi6kagura6vector4Vec23dot(_M0MP36mizchi6kagura6vector4Vec23sub(v_b, v_a), c.axis);
  const lambda = -(v_rel + bias + c.gamma * c.acc_impulse) * c.effective_mass;
  const new_acc = c.acc_impulse + lambda;
  const delta_impulse = new_acc - c.acc_impulse;
  if (Math.abs(delta_impulse) > 1e-15) {
    const impulse = _M0MP36mizchi6kagura6vector4Vec25scale(c.axis, delta_impulse);
    const r_a_cross = c.r_a.x * c.axis.y - c.r_a.y * c.axis.x;
    const r_b_cross = c.r_b.x * c.axis.y - c.r_b.y * c.axis.x;
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, { ...a, velocity: _M0MP36mizchi6kagura6vector4Vec23sub(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, a.inv_mass)), angular_velocity: a.angular_velocity - r_a_cross * delta_impulse * a.inv_inertia });
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, { ...b, velocity: _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, b.inv_mass)), angular_velocity: b.angular_velocity + r_b_cross * delta_impulse * b.inv_inertia });
  }
  _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d25DistanceJointConstraint2DE(constraints, ci, { ...c, acc_impulse: new_acc });
}
function _M0FP36mizchi6kagura9physics2d22solve__revolute__joint(constraints, ci, bodies) {
  const c = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d25RevoluteJointConstraint2DE(constraints, ci);
  const a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a);
  const b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b);
  const world_a = _M0MP36mizchi6kagura6vector4Vec23add(a.position, c.r_a);
  const world_b = _M0MP36mizchi6kagura6vector4Vec23add(b.position, c.r_b);
  const error = _M0MP36mizchi6kagura6vector4Vec23sub(world_b, world_a);
  const r_a_perp = _M0MP36mizchi6kagura6vector4Vec23new(-c.r_a.y, c.r_a.x);
  const r_b_perp = _M0MP36mizchi6kagura6vector4Vec23new(-c.r_b.y, c.r_b.x);
  const v_a = _M0MP36mizchi6kagura6vector4Vec23add(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(r_a_perp, a.angular_velocity));
  const v_b = _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(r_b_perp, b.angular_velocity));
  const v_rel = _M0MP36mizchi6kagura6vector4Vec23sub(v_b, v_a);
  const bias_x = c.bias_coefficient * error.x;
  const lambda_x = -(v_rel.x + bias_x + c.gamma * c.acc_impulse_x) * c.effective_mass_x;
  const new_acc_x = c.acc_impulse_x + lambda_x;
  const delta_x = new_acc_x - c.acc_impulse_x;
  const bias_y = c.bias_coefficient * error.y;
  const lambda_y = -(v_rel.y + bias_y + c.gamma * c.acc_impulse_y) * c.effective_mass_y;
  const new_acc_y = c.acc_impulse_y + lambda_y;
  const delta_y = new_acc_y - c.acc_impulse_y;
  if (Math.abs(delta_x) > 1e-15 || Math.abs(delta_y) > 1e-15) {
    const impulse = _M0MP36mizchi6kagura6vector4Vec23new(delta_x, delta_y);
    const angular_a = c.r_a.x * impulse.y - c.r_a.y * impulse.x;
    const angular_b = c.r_b.x * impulse.y - c.r_b.y * impulse.x;
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, { ...a, velocity: _M0MP36mizchi6kagura6vector4Vec23sub(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, a.inv_mass)), angular_velocity: a.angular_velocity - angular_a * a.inv_inertia });
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, { ...b, velocity: _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, b.inv_mass)), angular_velocity: b.angular_velocity + angular_b * b.inv_inertia });
  }
  _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d25RevoluteJointConstraint2DE(constraints, ci, { ...c, acc_impulse_x: new_acc_x, acc_impulse_y: new_acc_y });
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(self) {
  const _bind = self.body_type;
  if (_bind === 0) {
    return true;
  } else {
    return false;
  }
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D11world__aabb(self) {
  let half_extents;
  let offset;
  _L: {
    let half_extents$2;
    let offset$2;
    _L$2: {
      let offset$3;
      let radius;
      _L$3: {
        const _bind = self.collider;
        switch (_bind.$tag) {
          case 0: {
            const _CircleShape = _bind;
            const _offset = _CircleShape._0;
            const _radius = _CircleShape._1;
            offset$3 = _offset;
            radius = _radius;
            break _L$3;
          }
          case 1: {
            const _AABBShape2D = _bind;
            const _half_extents = _AABBShape2D._0;
            const _offset$2 = _AABBShape2D._1;
            half_extents$2 = _half_extents;
            offset$2 = _offset$2;
            break _L$2;
          }
          default: {
            const _OBBShape2D = _bind;
            const _half_extents$2 = _OBBShape2D._0;
            const _offset$3 = _OBBShape2D._1;
            half_extents = _half_extents$2;
            offset = _offset$3;
            break _L;
          }
        }
      }
      const center = _M0MP36mizchi6kagura6vector4Vec23add(self.position, offset$3);
      const r = _M0MP36mizchi6kagura6vector4Vec23new(radius, radius);
      return _M0MP36mizchi6kagura9physics2d6AABB2D3new(_M0MP36mizchi6kagura6vector4Vec23sub(center, r), _M0MP36mizchi6kagura6vector4Vec23add(center, r));
    }
    const center = _M0MP36mizchi6kagura6vector4Vec23add(self.position, offset$2);
    return _M0MP36mizchi6kagura9physics2d6AABB2D3new(_M0MP36mizchi6kagura6vector4Vec23sub(center, half_extents$2), _M0MP36mizchi6kagura6vector4Vec23add(center, half_extents$2));
  }
  const center = _M0MP36mizchi6kagura6vector4Vec23add(self.position, _M0MP36mizchi6kagura6vector4Vec26rotate(offset, self.angle));
  const cos_a = Math.abs(_M0FP311moonbitlang4core4math3cos(self.angle));
  const sin_a = Math.abs(_M0FP311moonbitlang4core4math3sin(self.angle));
  const ex = half_extents.x * cos_a + half_extents.y * sin_a;
  const ey = half_extents.x * sin_a + half_extents.y * cos_a;
  const ext = _M0MP36mizchi6kagura6vector4Vec23new(ex, ey);
  return _M0MP36mizchi6kagura9physics2d6AABB2D3new(_M0MP36mizchi6kagura6vector4Vec23sub(center, ext), _M0MP36mizchi6kagura6vector4Vec23add(center, ext));
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D5clear(self) {
  _M0MP311moonbitlang4core7builtin3Map5clearGlRP311moonbitlang4core7builtin5ArrayGiEE(self.cells);
  _M0MP311moonbitlang4core5array5Array5clearGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self.entries);
}
function _M0MP36mizchi6kagura9physics2d6AABB2D10intersects(self, other) {
  return self.min.x <= other.max.x && (self.max.x >= other.min.x && (self.min.y <= other.max.y && self.max.y >= other.min.y));
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D10get__pairs(self) {
  const _bind = [];
  const seen = _M0MP311moonbitlang4core7builtin3Map11from__arrayGluE({ buf: _bind, start: 0, end: 0 });
  const result = [];
  _M0MP311moonbitlang4core7builtin3Map4eachGlRP311moonbitlang4core7builtin5ArrayGiEE(self.cells, (_key, bucket) => {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < bucket.length) {
        let _tmp$2 = i + 1 | 0;
        while (true) {
          const j = _tmp$2;
          if (j < bucket.length) {
            const a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self.entries, _M0MP311moonbitlang4core5array5Array2atGiE(bucket, i));
            const b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self.entries, _M0MP311moonbitlang4core5array5Array2atGiE(bucket, j));
            const min_id = a.id < b.id ? a.id : b.id;
            const max_id = a.id > b.id ? a.id : b.id;
            const pair_key = _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin5BitOr3lor(_M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin3Shl3shl(_M0MP311moonbitlang4core3int3Int9to__int64(min_id), 32), _M0MP311moonbitlang4core3int3Int9to__int64(max_id));
            const _bind$2 = _M0MP311moonbitlang4core7builtin3Map3getGluE(seen, pair_key);
            if (_bind$2 === -1) {
              _M0MP311moonbitlang4core7builtin3Map3setGluE(seen, pair_key, undefined);
              if (_M0MP36mizchi6kagura9physics2d6AABB2D10intersects(a.aabb, b.aabb)) {
                _M0MP311moonbitlang4core5array5Array4pushGUiiEE(result, { _0: min_id, _1: max_id });
              }
            }
            _tmp$2 = j + 1 | 0;
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
  });
  return result;
}
function _M0FP36mizchi6kagura9physics2d11cell__key2d(cx, cy) {
  const mask = $4294967295L;
  const x = _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin6BitAnd4land(_M0MP311moonbitlang4core3int3Int9to__int64(cx), mask);
  const y = _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin6BitAnd4land(_M0MP311moonbitlang4core3int3Int9to__int64(cy), mask);
  return _M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin5BitOr3lor(_M0IP311moonbitlang4core5int645Int64P311moonbitlang4core7builtin3Shl3shl(x, 32), y);
}
function _M0FP36mizchi6kagura9physics2d14floor__to__int(x) {
  const i = _M0MP311moonbitlang4core6double6Double7to__int(x);
  return x < i + 0 ? i - 1 | 0 : i;
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D6insert(self, id, aabb) {
  const idx = self.entries.length;
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self.entries, { id: id, aabb: aabb });
  const min_cx = _M0FP36mizchi6kagura9physics2d14floor__to__int(aabb.min.x * self.inv_cell_size);
  const min_cy = _M0FP36mizchi6kagura9physics2d14floor__to__int(aabb.min.y * self.inv_cell_size);
  const max_cx = _M0FP36mizchi6kagura9physics2d14floor__to__int(aabb.max.x * self.inv_cell_size);
  const max_cy = _M0FP36mizchi6kagura9physics2d14floor__to__int(aabb.max.y * self.inv_cell_size);
  let _tmp = min_cx;
  while (true) {
    const cx = _tmp;
    if (cx <= max_cx) {
      let _tmp$2 = min_cy;
      while (true) {
        const cy = _tmp$2;
        if (cy <= max_cy) {
          const key = _M0FP36mizchi6kagura9physics2d11cell__key2d(cx, cy);
          let bucket;
          _L: {
            _L$2: {
              const _bind = _M0MP311moonbitlang4core7builtin3Map3getGlRP311moonbitlang4core7builtin5ArrayGiEE(self.cells, key);
              if (_bind.$tag === 1) {
                const _Some = _bind;
                const _bucket = _Some._0;
                bucket = _bucket;
                break _L$2;
              } else {
                _M0MP311moonbitlang4core7builtin3Map3setGlRP311moonbitlang4core7builtin5ArrayGiEE(self.cells, key, [idx]);
              }
              break _L;
            }
            _M0MP311moonbitlang4core5array5Array4pushGiE(bucket, idx);
          }
          _tmp$2 = cy + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = cx + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D4step(self, dt) {
  const config = self.solver_config;
  const substeps = config.substeps;
  const sub_dt = dt / (substeps + 0);
  _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D5clear(self.broadphase);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < self.bodies.length) {
      _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D6insert(self.broadphase, i, _M0MP36mizchi6kagura9physics2d11RigidBody2D11world__aabb(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i)));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const pairs = _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D10get__pairs(self.broadphase);
  const raw_contacts = [];
  let _tmp$2 = 0;
  while (true) {
    const p = _tmp$2;
    if (p < pairs.length) {
      let idx_a;
      let idx_b;
      _L: {
        const _bind = _M0MP311moonbitlang4core5array5Array2atGUiiEE(pairs, p);
        const _idx_a = _bind._0;
        const _idx_b = _bind._1;
        idx_a = _idx_a;
        idx_b = _idx_b;
        break _L;
      }
      const body_a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_a);
      const body_b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_b);
      if (body_a.inv_mass >= 1e-12 || body_b.inv_mass >= 1e-12) {
        let contact;
        _L$2: {
          _L$3: {
            const _bind = _M0FP36mizchi6kagura9physics2d19generate__contact2d(body_a, body_b);
            if (_bind === undefined) {
            } else {
              const _Some = _bind;
              const _contact = _Some;
              contact = _contact;
              break _L$3;
            }
            break _L$2;
          }
          _M0MP311moonbitlang4core5array5Array4pushGUiiRP36mizchi6kagura9physics2d9Contact2DEE(raw_contacts, { _0: idx_a, _1: idx_b, _2: contact });
        }
      }
      _tmp$2 = p + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const constraints = [];
  const _bind = [];
  const new_cache = _M0MP311moonbitlang4core7builtin3Map11from__arrayGlRP36mizchi6kagura9physics2d17ContactManifold2DE({ buf: _bind, start: 0, end: 0 });
  let _tmp$3 = 0;
  while (true) {
    const c = _tmp$3;
    if (c < raw_contacts.length) {
      let idx_b;
      let idx_a;
      let contact;
      _L: {
        const _bind$2 = _M0MP311moonbitlang4core5array5Array2atGUiiRP36mizchi6kagura9physics2d9Contact2DEE(raw_contacts, c);
        const _idx_a = _bind$2._0;
        const _idx_b = _bind$2._1;
        const _contact = _bind$2._2;
        idx_b = _idx_b;
        idx_a = _idx_a;
        contact = _contact;
        break _L;
      }
      const body_a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_a);
      const body_b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_b);
      const constraint = { val: _M0FP36mizchi6kagura9physics2d24precompute__constraint2d(body_a, body_b, idx_a, idx_b, contact, config.contact_hertz, config.contact_damping_ratio, sub_dt) };
      const pair_key = _M0FP36mizchi6kagura9physics2d18contact__pair__key(body_a.id, body_b.id);
      let cached;
      _L$2: {
        _L$3: {
          const _bind$2 = _M0MP311moonbitlang4core7builtin3Map3getGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self.contact_cache, pair_key);
          if (_bind$2 === undefined) {
          } else {
            const _Some = _bind$2;
            const _cached = _Some;
            cached = _cached;
            break _L$3;
          }
          break _L$2;
        }
        if (_M0MP36mizchi6kagura6vector4Vec23dot(cached.normal, contact.normal) > 0.9) {
          if (cached.points.length > 0) {
            const pt = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15ManifoldPoint2DE(cached.points, 0);
            const warm_factor = 0.8;
            constraint.val = { ...constraint.val, acc_jn: pt.normal_impulse * warm_factor, acc_jt: pt.tangent_impulse * warm_factor };
            const n = contact.normal;
            const tangent = _M0MP36mizchi6kagura6vector4Vec23new(-n.y, n.x);
            const jn = pt.normal_impulse * warm_factor;
            const jt = pt.tangent_impulse * warm_factor;
            if (Math.abs(jn) > 1e-15 || Math.abs(jt) > 1e-15) {
              const impulse = _M0MP36mizchi6kagura6vector4Vec23add(_M0MP36mizchi6kagura6vector4Vec25scale(n, jn), _M0MP36mizchi6kagura6vector4Vec25scale(tangent, jt));
              _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_a, { ..._M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_a), velocity: _M0MP36mizchi6kagura6vector4Vec23add(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_a).velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, body_a.inv_mass)) });
              _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_b, { ..._M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_b), velocity: _M0MP36mizchi6kagura6vector4Vec23sub(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, idx_b).velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, body_b.inv_mass)) });
            }
          }
        }
      }
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d19ContactConstraint2DE(constraints, constraint.val);
      _tmp$3 = c + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const dist_constraints = [];
  let _tmp$4 = 0;
  while (true) {
    const j = _tmp$4;
    if (j < self.joints_distance.length) {
      let c;
      _L: {
        _L$2: {
          const _bind$2 = _M0FP36mizchi6kagura9physics2d27precompute__distance__joint(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15DistanceJoint2DE(self.joints_distance, j), self.bodies, sub_dt);
          if (_bind$2 === undefined) {
          } else {
            const _Some = _bind$2;
            const _c = _Some;
            c = _c;
            break _L$2;
          }
          break _L;
        }
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d25DistanceJointConstraint2DE(dist_constraints, c);
      }
      _tmp$4 = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const rev_constraints = [];
  let _tmp$5 = 0;
  while (true) {
    const j = _tmp$5;
    if (j < self.joints_revolute.length) {
      let c;
      _L: {
        _L$2: {
          const _bind$2 = _M0FP36mizchi6kagura9physics2d27precompute__revolute__joint(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15RevoluteJoint2DE(self.joints_revolute, j), self.bodies, sub_dt);
          if (_bind$2 === undefined) {
          } else {
            const _Some = _bind$2;
            const _c = _Some;
            c = _c;
            break _L$2;
          }
          break _L;
        }
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura9physics2d25RevoluteJointConstraint2DE(rev_constraints, c);
      }
      _tmp$5 = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$6 = 0;
  while (true) {
    const _s = _tmp$6;
    if (_s < substeps) {
      let _tmp$7 = 0;
      while (true) {
        const i = _tmp$7;
        if (i < self.bodies.length) {
          const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
          if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body) && !body.is_sleeping) {
            const accel = _M0MP36mizchi6kagura6vector4Vec23add(self.gravity, _M0MP36mizchi6kagura6vector4Vec25scale(body.force, body.inv_mass));
            const new_vel = _M0MP36mizchi6kagura6vector4Vec25scale(_M0MP36mizchi6kagura6vector4Vec23add(body.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(accel, sub_dt)), 1 - body.linear_damping * sub_dt);
            const angular_accel = body.torque * body.inv_inertia;
            const new_angular_vel = (body.angular_velocity + angular_accel * sub_dt) * (1 - body.angular_damping * sub_dt);
            _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, velocity: new_vel, angular_velocity: new_angular_vel });
          }
          _tmp$7 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$8 = 0;
      while (true) {
        const _iter = _tmp$8;
        if (_iter < config.velocity_iterations) {
          let _tmp$9 = 0;
          while (true) {
            const ci = _tmp$9;
            if (ci < constraints.length) {
              _M0FP36mizchi6kagura9physics2d19solve__constraint2d(constraints, ci, self.bodies);
              _tmp$9 = ci + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          let _tmp$10 = 0;
          while (true) {
            const di = _tmp$10;
            if (di < dist_constraints.length) {
              _M0FP36mizchi6kagura9physics2d22solve__distance__joint(dist_constraints, di, self.bodies, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15DistanceJoint2DE(self.joints_distance, di));
              _tmp$10 = di + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          let _tmp$11 = 0;
          while (true) {
            const ri = _tmp$11;
            if (ri < rev_constraints.length) {
              _M0FP36mizchi6kagura9physics2d22solve__revolute__joint(rev_constraints, ri, self.bodies);
              _tmp$11 = ri + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _tmp$8 = _iter + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$9 = 0;
      while (true) {
        const i = _tmp$9;
        if (i < self.bodies.length) {
          const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
          if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body) && !body.is_sleeping) {
            if (body.is_bullet) {
              let toi;
              _L: {
                _L$2: {
                  const _bind$2 = _M0FP36mizchi6kagura9physics2d16ccd__sweep__body(i, self.bodies, sub_dt);
                  if (_bind$2.$tag === 1) {
                    const _Some = _bind$2;
                    const _toi = _Some._0;
                    toi = _toi;
                    break _L$2;
                  } else {
                    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, position: _M0MP36mizchi6kagura6vector4Vec23add(body.position, _M0MP36mizchi6kagura6vector4Vec25scale(body.velocity, sub_dt)), angle: body.angle + body.angular_velocity * sub_dt });
                  }
                  break _L;
                }
                const safe_toi = toi > 0.01 ? toi * 0.95 : 0;
                _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, position: _M0MP36mizchi6kagura6vector4Vec23add(body.position, _M0MP36mizchi6kagura6vector4Vec25scale(body.velocity, sub_dt * safe_toi)), angle: body.angle + body.angular_velocity * sub_dt * safe_toi });
              }
            } else {
              _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, position: _M0MP36mizchi6kagura6vector4Vec23add(body.position, _M0MP36mizchi6kagura6vector4Vec25scale(body.velocity, sub_dt)), angle: body.angle + body.angular_velocity * sub_dt });
            }
          }
          _tmp$9 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$6 = _s + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$7 = 0;
  while (true) {
    const c = _tmp$7;
    if (c < constraints.length) {
      const con = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d19ContactConstraint2DE(constraints, c);
      const body_a = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, con.idx_a);
      const body_b = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, con.idx_b);
      const pair_key = _M0FP36mizchi6kagura9physics2d18contact__pair__key(body_a.id, body_b.id);
      const local_a = _M0MP36mizchi6kagura6vector4Vec23sub(con.contact.contact_point, body_a.position);
      const local_b = _M0MP36mizchi6kagura6vector4Vec23sub(con.contact.contact_point, body_b.position);
      _M0MP311moonbitlang4core7builtin3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(new_cache, pair_key, { body_a_id: body_a.id, body_b_id: body_b.id, normal: con.contact.normal, points: [{ local_a: local_a, local_b: local_b, penetration: con.contact.penetration, normal_impulse: con.acc_jn, tangent_impulse: con.acc_jt }] });
      _tmp$7 = c + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core7builtin3Map5clearGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self.contact_cache);
  _M0MP311moonbitlang4core7builtin3Map4eachGlRP36mizchi6kagura9physics2d17ContactManifold2DE(new_cache, (k, v) => {
    _M0MP311moonbitlang4core7builtin3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self.contact_cache, k, v);
  });
  let _tmp$8 = 0;
  while (true) {
    const i = _tmp$8;
    if (i < self.bodies.length) {
      const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
      if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, force: _M0MP36mizchi6kagura6vector4Vec24zero(), torque: 0 });
      }
      _tmp$8 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const n = self.bodies.length;
  if (n > 0) {
    const parent = _M0MP311moonbitlang4core5array5Array4makeGiE(n, 0);
    const rank = _M0MP311moonbitlang4core5array5Array4makeGiE(n, 0);
    let _tmp$9 = 0;
    while (true) {
      const i = _tmp$9;
      if (i < n) {
        _M0MP311moonbitlang4core5array5Array3setGiE(parent, i, i);
        _tmp$9 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    let _tmp$10 = 0;
    while (true) {
      const c = _tmp$10;
      if (c < constraints.length) {
        const con = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d19ContactConstraint2DE(constraints, c);
        _M0FP36mizchi6kagura9physics2d9uf__union(parent, rank, con.idx_a, con.idx_b);
        _tmp$10 = c + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    let _tmp$11 = 0;
    while (true) {
      const i = _tmp$11;
      if (i < n) {
        const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
        if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
          const speed = _M0MP36mizchi6kagura6vector4Vec26length(body.velocity);
          const angular_speed = Math.abs(body.angular_velocity);
          if (speed < _M0FP36mizchi6kagura9physics2d26sleep__velocity__threshold && angular_speed < _M0FP36mizchi6kagura9physics2d25sleep__angular__threshold) {
            _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, sleep_timer: body.sleep_timer + dt });
          } else {
            _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, is_sleeping: false, sleep_timer: 0 });
          }
        }
        _tmp$11 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const _bind$2 = [];
    const island_can_sleep = _M0MP311moonbitlang4core7builtin3Map11from__arrayGibE({ buf: _bind$2, start: 0, end: 0 });
    let _tmp$12 = 0;
    while (true) {
      const i = _tmp$12;
      if (i < n) {
        const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
        if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
          const root = _M0FP36mizchi6kagura9physics2d8uf__find(parent, i);
          const can_sleep = body.sleep_timer >= _M0FP36mizchi6kagura9physics2d22sleep__time__threshold;
          let prev;
          _L: {
            _L$2: {
              const _bind$3 = _M0MP311moonbitlang4core7builtin3Map3getGibE(island_can_sleep, root);
              if (_bind$3 === -1) {
                _M0MP311moonbitlang4core7builtin3Map3setGibE(island_can_sleep, root, can_sleep);
              } else {
                const _Some = _bind$3;
                const _prev = _Some;
                prev = _prev;
                break _L$2;
              }
              break _L;
            }
            _M0MP311moonbitlang4core7builtin3Map3setGibE(island_can_sleep, root, prev && can_sleep);
          }
        }
        _tmp$12 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    let _tmp$13 = 0;
    while (true) {
      const i = _tmp$13;
      if (i < n) {
        const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i);
        if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
          const root = _M0FP36mizchi6kagura9physics2d8uf__find(parent, i);
          _L: {
            _L$2: {
              const _bind$3 = _M0MP311moonbitlang4core7builtin3Map3getGibE(island_can_sleep, root);
              if (_bind$3 === -1) {
                break _L$2;
              } else {
                const _Some = _bind$3;
                const _x = _Some;
                if (_x === true) {
                  if (!body.is_sleeping) {
                    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, is_sleeping: true, velocity: _M0MP36mizchi6kagura6vector4Vec24zero(), angular_velocity: 0 });
                  }
                } else {
                  break _L$2;
                }
              }
              break _L;
            }
            if (body.is_sleeping) {
              _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, { ...body, is_sleeping: false, sleep_timer: 0 });
            }
          }
        }
        _tmp$13 = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    return;
  }
}
function _M0FP36mizchi6kagura9physics2d21compute__inv__inertia(collider, mass) {
  if (mass < 1e-12) {
    return 0;
  }
  let inertia;
  let he;
  _L: {
    _L$2: {
      let radius;
      _L$3: {
        switch (collider.$tag) {
          case 0: {
            const _CircleShape = collider;
            const _radius = _CircleShape._1;
            radius = _radius;
            break _L$3;
          }
          case 1: {
            const _AABBShape2D = collider;
            const _he = _AABBShape2D._0;
            he = _he;
            break _L$2;
          }
          default: {
            const _OBBShape2D = collider;
            const _he$2 = _OBBShape2D._0;
            he = _he$2;
            break _L$2;
          }
        }
      }
      inertia = 0.5 * mass * radius * radius;
      break _L;
    }
    inertia = mass / 3 * (he.x * he.x + he.y * he.y);
  }
  return inertia < 1e-12 ? 0 : 1 / inertia;
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D12new__dynamic(id, position, mass, collider) {
  const _bind = 0;
  const _bind$2 = _M0MP36mizchi6kagura6vector4Vec24zero();
  const _bind$3 = _M0MP36mizchi6kagura6vector4Vec24zero();
  const _bind$4 = 0;
  const _bind$5 = 0;
  const _bind$6 = 0;
  const _bind$7 = 1 / mass;
  const _bind$8 = 0.5;
  const _bind$9 = 0.3;
  const _bind$10 = _M0FP36mizchi6kagura9physics2d21compute__inv__inertia(collider, mass);
  const _bind$11 = 0.05;
  const _bind$12 = 0.01;
  const _bind$13 = false;
  const _bind$14 = 0;
  const _bind$15 = false;
  return { id: id, body_type: _bind, position: position, velocity: _bind$2, force: _bind$3, angle: _bind$4, angular_velocity: _bind$5, torque: _bind$6, mass: mass, inv_mass: _bind$7, restitution: _bind$8, friction: _bind$9, inv_inertia: _bind$10, angular_damping: _bind$11, linear_damping: _bind$12, collider: collider, is_sleeping: _bind$13, sleep_timer: _bind$14, is_bullet: _bind$15 };
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D11new__static(id, position, collider) {
  const _bind = 1;
  const _bind$2 = _M0MP36mizchi6kagura6vector4Vec24zero();
  const _bind$3 = _M0MP36mizchi6kagura6vector4Vec24zero();
  const _bind$4 = 0;
  const _bind$5 = 0;
  const _bind$6 = 0;
  const _bind$7 = 0;
  const _bind$8 = 0;
  const _bind$9 = 0.5;
  const _bind$10 = 0.3;
  const _bind$11 = 0;
  const _bind$12 = 0;
  const _bind$13 = 0;
  const _bind$14 = false;
  const _bind$15 = 0;
  const _bind$16 = false;
  return { id: id, body_type: _bind, position: position, velocity: _bind$2, force: _bind$3, angle: _bind$4, angular_velocity: _bind$5, torque: _bind$6, mass: _bind$7, inv_mass: _bind$8, restitution: _bind$9, friction: _bind$10, inv_inertia: _bind$11, angular_damping: _bind$12, linear_damping: _bind$13, collider: collider, is_sleeping: _bind$14, sleep_timer: _bind$15, is_bullet: _bind$16 };
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D17with__restitution(self, e) {
  return { ...self, restitution: e };
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D14with__friction(self, f) {
  return { ...self, friction: f };
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D13with__damping(self, d) {
  return { ...self, linear_damping: d };
}
function _M0FP26mizchi13ragdoll__demo20draw__filled__circle(cmds, dst, shader, cx, cy, radius, color, sw, sh) {
  const n = _M0FP26mizchi13ragdoll__demo16circle__segments;
  const vertices = [];
  const indices = [];
  const ndc_cx = cx / sw * 2 - 1;
  const ndc_cy = 1 - cy / sh * 2;
  _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, ndc_cx);
  _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, ndc_cy);
  _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, 0.5);
  _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, 0.5);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i <= n) {
      const angle = (i + 0) / (n + 0) * 2 * 3.14159265358979312;
      const px = cx + radius * _M0FP311moonbitlang4core4math3cos(angle);
      const py = cy + radius * _M0FP311moonbitlang4core4math3sin(angle);
      const ndc_x = px / sw * 2 - 1;
      const ndc_y = 1 - py / sh * 2;
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, ndc_x);
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, ndc_y);
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, 0.5);
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, 0.5);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = 1;
  while (true) {
    const i = _tmp$2;
    if (i <= n) {
      _M0MP311moonbitlang4core5array5Array4pushGiE(indices, 0);
      _M0MP311moonbitlang4core5array5Array4pushGiE(indices, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(indices, i + 1 | 0);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil26new__simple__draw__command(dst, shader, vertices, indices, color));
}
function _M0FP26mizchi13ragdoll__demo18draw__rotated__box(cmds, dst, shader, cx, cy, hw, hh, angle, color, sw, sh) {
  const corners = [{ _0: -hw, _1: -hh }, { _0: hw, _1: -hh }, { _0: hw, _1: hh }, { _0: -hw, _1: hh }];
  const cos_a = _M0FP311moonbitlang4core4math3cos(-angle);
  const sin_a = _M0FP311moonbitlang4core4math3sin(-angle);
  const vertices = [];
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < 4) {
      let lx;
      let ly;
      _L: {
        const _bind = _M0MP311moonbitlang4core5array5Array2atGUddEE(corners, i);
        const _lx = _bind._0;
        const _ly = _bind._1;
        lx = _lx;
        ly = _ly;
        break _L;
      }
      const rx = lx * cos_a - ly * sin_a;
      const ry = lx * sin_a + ly * cos_a;
      const px = cx + rx;
      const py = cy + ry;
      const ndc_x = px / sw * 2 - 1;
      const ndc_y = 1 - py / sh * 2;
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, ndc_x);
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, ndc_y);
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, 0.5);
      _M0MP311moonbitlang4core5array5Array4pushGdE(vertices, 0.5);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const indices = [0, 1, 2, 0, 2, 3];
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil26new__simple__draw__command(dst, shader, vertices, indices, color));
}
function _M0FP26mizchi13ragdoll__demo16get__part__color(id, grabbed_id) {
  if (id === grabbed_id) {
    return _M0FP36mizchi6kagura9debugutil16color__from__hex(_M0FP26mizchi13ragdoll__demo16color__highlight);
  }
  let hex;
  _L: {
    _L$2: {
      _L$3: {
        _L$4: {
          _L$5: {
            _L$6: {
              _L$7: {
                _L$8: {
                  switch (id) {
                    case 1: {
                      hex = _M0FP26mizchi13ragdoll__demo11color__skin;
                      break;
                    }
                    case 2: {
                      hex = _M0FP26mizchi13ragdoll__demo12color__torso;
                      break;
                    }
                    case 3: {
                      break _L$8;
                    }
                    case 4: {
                      break _L$8;
                    }
                    case 5: {
                      break _L$6;
                    }
                    case 6: {
                      break _L$6;
                    }
                    case 7: {
                      break _L$4;
                    }
                    case 8: {
                      break _L$4;
                    }
                    case 9: {
                      break _L$2;
                    }
                    case 10: {
                      break _L$2;
                    }
                    default: {
                      hex = _M0FP26mizchi13ragdoll__demo18color__ground__hex;
                    }
                  }
                  break _L$7;
                }
                hex = _M0FP26mizchi13ragdoll__demo10color__arm;
              }
              break _L$5;
            }
            hex = _M0FP26mizchi13ragdoll__demo14color__forearm;
          }
          break _L$3;
        }
        hex = _M0FP26mizchi13ragdoll__demo12color__thigh;
      }
      break _L;
    }
    hex = _M0FP26mizchi13ragdoll__demo11color__shin;
  }
  return _M0FP36mizchi6kagura9debugutil16color__from__hex(hex);
}
function _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(px) {
  return (_M0FP26mizchi13ragdoll__demo9screen__w + 0) / 2 + px * _M0FP26mizchi13ragdoll__demo13px__per__unit;
}
function _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(py) {
  return (_M0FP26mizchi13ragdoll__demo9screen__h + 0) / 2 - py * _M0FP26mizchi13ragdoll__demo13px__per__unit;
}
function _M0FP26mizchi13ragdoll__demo13world__anchor(body, anchor) {
  const c = _M0FP311moonbitlang4core4math3cos(body.angle);
  const s = _M0FP311moonbitlang4core4math3sin(body.angle);
  const rx = anchor.x * c - anchor.y * s;
  const ry = anchor.x * s + anchor.y * c;
  return _M0MP36mizchi6kagura6vector4Vec23new(body.position.x + rx, body.position.y + ry);
}
function _M0MP26mizchi13ragdoll__demo9DemoState4draw(self, ctx) {
  const cmds = [];
  const sw = _M0FP26mizchi13ragdoll__demo9screen__w + 0;
  const sh = _M0FP26mizchi13ragdoll__demo9screen__h + 0;
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(ctx.dst, ctx.shader, 0, 0, sw, sh, sw, sh, _M0FP36mizchi6kagura9debugutil16color__from__hex(_M0FP26mizchi13ragdoll__demo9color__bg), 0));
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < self.world.bodies.length) {
      const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(self.world.bodies, i);
      const color = _M0FP26mizchi13ragdoll__demo16get__part__color(body.id, self.grabbed_id);
      let half_extents;
      let offset;
      _L: {
        _L$2: {
          let half_extents$2;
          let offset$2;
          _L$3: {
            _L$4: {
              let offset$3;
              let radius;
              _L$5: {
                const _bind = body.collider;
                switch (_bind.$tag) {
                  case 0: {
                    const _CircleShape = _bind;
                    const _offset = _CircleShape._0;
                    const _radius = _CircleShape._1;
                    offset$3 = _offset;
                    radius = _radius;
                    break _L$5;
                  }
                  case 1: {
                    const _AABBShape2D = _bind;
                    const _half_extents = _AABBShape2D._0;
                    const _offset$2 = _AABBShape2D._1;
                    half_extents$2 = _half_extents;
                    offset$2 = _offset$2;
                    break _L$4;
                  }
                  default: {
                    const _OBBShape2D = _bind;
                    const _half_extents$2 = _OBBShape2D._0;
                    const _offset$3 = _OBBShape2D._1;
                    half_extents = _half_extents$2;
                    offset = _offset$3;
                    break _L$2;
                  }
                }
              }
              const cx = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(body.position.x + offset$3.x);
              const cy = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(body.position.y + offset$3.y);
              const screen_r = radius * _M0FP26mizchi13ragdoll__demo13px__per__unit;
              _M0FP26mizchi13ragdoll__demo20draw__filled__circle(cmds, ctx.dst, ctx.shader, cx, cy, screen_r, color, sw, sh);
              break _L$3;
            }
            const cx = body.position.x + offset$2.x;
            const cy = body.position.y + offset$2.y;
            const screen_x = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(cx - half_extents$2.x);
            const screen_y = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(cy + half_extents$2.y);
            const screen_w2 = half_extents$2.x * 2 * _M0FP26mizchi13ragdoll__demo13px__per__unit;
            const screen_h2 = half_extents$2.y * 2 * _M0FP26mizchi13ragdoll__demo13px__per__unit;
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(ctx.dst, ctx.shader, screen_x, screen_y, screen_w2, screen_h2, sw, sh, color, 0));
          }
          break _L;
        }
        const phys_cx = body.position.x + offset.x;
        const phys_cy = body.position.y + offset.y;
        const scx = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(phys_cx);
        const scy = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(phys_cy);
        const shw = half_extents.x * _M0FP26mizchi13ragdoll__demo13px__per__unit;
        const shh = half_extents.y * _M0FP26mizchi13ragdoll__demo13px__per__unit;
        _M0FP26mizchi13ragdoll__demo18draw__rotated__box(cmds, ctx.dst, ctx.shader, scx, scy, shw, shh, body.angle, color, sw, sh);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const joint_color = _M0FP36mizchi6kagura9debugutil23color__from__hex__alpha(16777215, 0.6);
  let _tmp$2 = 0;
  while (true) {
    const j = _tmp$2;
    if (j < self.world.joints_revolute.length) {
      const joint = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d15RevoluteJoint2DE(self.world.joints_revolute, j);
      const body_a = _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9get__body(self.world, joint.body_a_id);
      const body_b = _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9get__body(self.world, joint.body_b_id);
      let a;
      let b;
      _L: {
        _L$2: {
          if (body_a === undefined) {
          } else {
            const _Some = body_a;
            const _a = _Some;
            if (body_b === undefined) {
            } else {
              const _Some$2 = body_b;
              const _b = _Some$2;
              a = _a;
              b = _b;
              break _L$2;
            }
          }
          break _L;
        }
        const wa = _M0FP26mizchi13ragdoll__demo13world__anchor(a, joint.local_anchor_a);
        const wb = _M0FP26mizchi13ragdoll__demo13world__anchor(b, joint.local_anchor_b);
        const sx0 = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(wa.x);
        const sy0 = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(wa.y);
        const sx1 = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(wb.x);
        const sy1 = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(wb.y);
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil18new__line__command(ctx.dst, ctx.shader, sx0, sy0, sx1, sy1, 2, joint_color, 0));
      }
      _tmp$2 = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (self.grabbed_id >= 0) {
    let body;
    _L: {
      _L$2: {
        const _bind = _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9get__body(self.world, self.grabbed_id);
        if (_bind === undefined) {
        } else {
          const _Some = _bind;
          const _body = _Some;
          body = _body;
          break _L$2;
        }
        break _L;
      }
      const mx_screen = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(self.mouse_phys_x);
      const my_screen = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(self.mouse_phys_y);
      const bx_screen = _M0FP26mizchi13ragdoll__demo22physics__to__screen__x(body.position.x);
      const by_screen = _M0FP26mizchi13ragdoll__demo22physics__to__screen__y(body.position.y);
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil18new__line__command(ctx.dst, ctx.shader, mx_screen, my_screen, bx_screen, by_screen, 2, _M0FP36mizchi6kagura9debugutil16color__from__hex(16728128), 0));
    }
  }
  return cmds;
}
function _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(id, x, y, hx, hy, mass) {
  return _M0MP36mizchi6kagura9physics2d11RigidBody2D13with__damping(_M0MP36mizchi6kagura9physics2d11RigidBody2D14with__friction(_M0MP36mizchi6kagura9physics2d11RigidBody2D17with__restitution(_M0MP36mizchi6kagura9physics2d11RigidBody2D12new__dynamic(id, _M0MP36mizchi6kagura6vector4Vec23new(x, y), mass, new $64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$OBBShape2D(_M0MP36mizchi6kagura6vector4Vec23new(hx, hy), _M0MP36mizchi6kagura6vector4Vec24zero())), 0.2), 0.5), 0.1);
}
function _M0FP26mizchi13ragdoll__demo21make__ragdoll__circle(id, x, y, radius, mass) {
  return _M0MP36mizchi6kagura9physics2d11RigidBody2D13with__damping(_M0MP36mizchi6kagura9physics2d11RigidBody2D14with__friction(_M0MP36mizchi6kagura9physics2d11RigidBody2D17with__restitution(_M0MP36mizchi6kagura9physics2d11RigidBody2D12new__dynamic(id, _M0MP36mizchi6kagura6vector4Vec23new(x, y), mass, new $64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$CircleShape(_M0MP36mizchi6kagura6vector4Vec24zero(), radius)), 0.2), 0.5), 0.1);
}
function _M0FP26mizchi13ragdoll__demo14make__revolute(a_id, b_id, anchor_a, anchor_b) {
  return { body_a_id: a_id, body_b_id: b_id, local_anchor_a: anchor_a, local_anchor_b: anchor_b, hertz: 8, damping_ratio: 0.5 };
}
function _M0FP26mizchi13ragdoll__demo14build__ragdoll(world) {
  const cx = 0;
  const torso_y = 3;
  const head_y = torso_y + 0.7 + 0.3;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo21make__ragdoll__circle(_M0FP26mizchi13ragdoll__demo8id__head, cx, head_y, 0.3, 2));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo9id__torso, cx, torso_y, 0.4, 0.7, 5));
  const l_arm_x = cx - 0.4 - 0.15;
  const l_arm_y = torso_y + 0.5 - 0.4;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo10id__l__arm, l_arm_x, l_arm_y, 0.15, 0.4, 1.5));
  const r_arm_x = cx + 0.4 + 0.15;
  const r_arm_y = torso_y + 0.5 - 0.4;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo10id__r__arm, r_arm_x, r_arm_y, 0.15, 0.4, 1.5));
  const l_fore_x = l_arm_x;
  const l_fore_y = l_arm_y - 0.4 - 0.35;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo11id__l__fore, l_fore_x, l_fore_y, 0.12, 0.35, 1));
  const r_fore_x = r_arm_x;
  const r_fore_y = r_arm_y - 0.4 - 0.35;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo11id__r__fore, r_fore_x, r_fore_y, 0.12, 0.35, 1));
  const l_thigh_x = cx - 0.2;
  const l_thigh_y = torso_y - 0.7 - 0.45;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo12id__l__thigh, l_thigh_x, l_thigh_y, 0.18, 0.45, 2));
  const r_thigh_x = cx + 0.2;
  const r_thigh_y = torso_y - 0.7 - 0.45;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo12id__r__thigh, r_thigh_x, r_thigh_y, 0.18, 0.45, 2));
  const l_shin_x = l_thigh_x;
  const l_shin_y = l_thigh_y - 0.45 - 0.4;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo11id__l__shin, l_shin_x, l_shin_y, 0.15, 0.4, 1.5));
  const r_shin_x = r_thigh_x;
  const r_shin_y = r_thigh_y - 0.45 - 0.4;
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi13ragdoll__demo18make__ragdoll__box(_M0FP26mizchi13ragdoll__demo11id__r__shin, r_shin_x, r_shin_y, 0.15, 0.4, 1.5));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo8id__head, _M0FP26mizchi13ragdoll__demo9id__torso, _M0MP36mizchi6kagura6vector4Vec23new(0, -0.3), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.7)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo9id__torso, _M0FP26mizchi13ragdoll__demo10id__l__arm, _M0MP36mizchi6kagura6vector4Vec23new(-0.4, 0.5), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.4)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo9id__torso, _M0FP26mizchi13ragdoll__demo10id__r__arm, _M0MP36mizchi6kagura6vector4Vec23new(0.4, 0.5), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.4)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo10id__l__arm, _M0FP26mizchi13ragdoll__demo11id__l__fore, _M0MP36mizchi6kagura6vector4Vec23new(0, -0.4), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.35)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo10id__r__arm, _M0FP26mizchi13ragdoll__demo11id__r__fore, _M0MP36mizchi6kagura6vector4Vec23new(0, -0.4), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.35)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo9id__torso, _M0FP26mizchi13ragdoll__demo12id__l__thigh, _M0MP36mizchi6kagura6vector4Vec23new(-0.2, -0.7), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.45)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo9id__torso, _M0FP26mizchi13ragdoll__demo12id__r__thigh, _M0MP36mizchi6kagura6vector4Vec23new(0.2, -0.7), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.45)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo12id__l__thigh, _M0FP26mizchi13ragdoll__demo11id__l__shin, _M0MP36mizchi6kagura6vector4Vec23new(0, -0.45), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.4)));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D20add__revolute__joint(world, _M0FP26mizchi13ragdoll__demo14make__revolute(_M0FP26mizchi13ragdoll__demo12id__r__thigh, _M0FP26mizchi13ragdoll__demo11id__r__shin, _M0MP36mizchi6kagura6vector4Vec23new(0, -0.45), _M0MP36mizchi6kagura6vector4Vec23new(0, 0.4)));
}
function _M0MP26mizchi13ragdoll__demo9DemoState3new() {
  const world = _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D3new(_M0MP36mizchi6kagura6vector4Vec23new(0, -9.8), 4, undefined);
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0MP36mizchi6kagura9physics2d11RigidBody2D11new__static(_M0FP26mizchi13ragdoll__demo10id__ground, _M0MP36mizchi6kagura6vector4Vec23new(0, -5.5), new $64$mizchi$47$kagura$47$physics2d$46$ColliderShape2D$AABBShape2D(_M0MP36mizchi6kagura6vector4Vec23new(10, 1), _M0MP36mizchi6kagura6vector4Vec24zero())));
  _M0FP26mizchi13ragdoll__demo14build__ragdoll(world);
  return { world: world, input: _M0FP36mizchi6kagura9inpututil18new__input__helper(), frame: 0, grabbed_id: -1, mouse_phys_x: 0, mouse_phys_y: 0 };
}
function _M0FP26mizchi13ragdoll__demo22find__closest__dynamic(world, mx, my) {
  const best_id = { val: -1 };
  const best_dist = { val: _M0FP26mizchi13ragdoll__demo14grab__distance };
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < world.bodies.length) {
      const body = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura9physics2d11RigidBody2DE(world.bodies, i);
      if (!_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
        _tmp = i + 1 | 0;
        continue;
      }
      const dx = body.position.x - mx;
      const dy = body.position.y - my;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < best_dist.val) {
        best_dist.val = dist;
        best_id.val = body.id;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return best_id.val;
}
function _M0FP26mizchi13ragdoll__demo22screen__to__physics__x(sx) {
  return (sx - (_M0FP26mizchi13ragdoll__demo9screen__w + 0) / 2) / _M0FP26mizchi13ragdoll__demo13px__per__unit;
}
function _M0FP26mizchi13ragdoll__demo22screen__to__physics__y(sy) {
  return ((_M0FP26mizchi13ragdoll__demo9screen__h + 0) / 2 - sy) / _M0FP26mizchi13ragdoll__demo13px__per__unit;
}
function _M0MP26mizchi13ragdoll__demo9DemoState6update(self, snapshot) {
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, snapshot);
  self.frame = self.frame + 1 | 0;
  const mx = _M0FP26mizchi13ragdoll__demo22screen__to__physics__x(snapshot.cursor_x);
  const my = _M0FP26mizchi13ragdoll__demo22screen__to__physics__y(snapshot.cursor_y);
  self.mouse_phys_x = mx;
  self.mouse_phys_y = my;
  if (_M0FP36mizchi6kagura9inpututil32is__mouse__button__just__pressed(self.input.mouse_state, 0)) {
    self.grabbed_id = _M0FP26mizchi13ragdoll__demo22find__closest__dynamic(self.world, mx, my);
  }
  if (_M0FP36mizchi6kagura9inpututil33is__mouse__button__just__released(self.input.mouse_state, 0)) {
    self.grabbed_id = -1;
  }
  if (self.grabbed_id >= 0) {
    let body;
    _L: {
      _L$2: {
        const _bind = _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9get__body(self.world, self.grabbed_id);
        if (_bind === undefined) {
          self.grabbed_id = -1;
        } else {
          const _Some = _bind;
          const _body = _Some;
          body = _body;
          break _L$2;
        }
        break _L;
      }
      const dx = mx - body.position.x;
      const dy = my - body.position.y;
      const fx = dx * _M0FP26mizchi13ragdoll__demo16spring__strength;
      const fy = dy * _M0FP26mizchi13ragdoll__demo16spring__strength;
      _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D12apply__force(self.world, self.grabbed_id, _M0MP36mizchi6kagura6vector4Vec23new(fx, fy));
    }
  }
  const sub_steps = 8;
  const dt = 0.0166666666666666664 / (sub_steps + 0);
  let _tmp = 0;
  while (true) {
    const _s = _tmp;
    if (_s < sub_steps) {
      _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D4step(self.world, dt);
      _tmp = _s + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
(() => {
  const state = _M0MP26mizchi13ragdoll__demo9DemoState3new();
  _M0FP36mizchi6kagura6engine11run_2einner((input) => {
    _M0MP26mizchi13ragdoll__demo9DemoState6update(state, input);
  }, (ctx) => _M0MP26mizchi13ragdoll__demo9DemoState4draw(state, ctx), undefined, undefined, undefined, 735, _M0FP26mizchi13ragdoll__demo9screen__w, _M0FP26mizchi13ragdoll__demo9screen__h, "Ragdoll Demo", "#app");
})();
//# sourceMappingURL=ragdoll_demo.js.map
