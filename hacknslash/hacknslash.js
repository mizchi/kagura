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
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MP311moonbitlang4core7builtin7JSArray4push = (arr, val) => { arr.push(val); };
const _M0MP311moonbitlang4core7builtin7JSArray11set__length = (arr, len) => { arr.length = len; };
const _M0MP311moonbitlang4core7builtin7JSArray3pop = (arr) => arr.pop();
function $i32_reinterpret_f32(a) {
  $reinterpret_view.setFloat32(0, a, true);
  return $reinterpret_view.getInt32(0, true);
}
const Option$None$1$ = { $tag: 0, $name: "None" };
function Option$Some$1$(param0) {
  this._0 = param0;
}
Option$Some$1$.prototype.$tag = 1;
Option$Some$1$.prototype.$name = "Some";
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
const _M0FP36mizchi6kagura9inpututil6key__w = 87;
const _M0FP36mizchi6kagura9inpututil6key__a = 65;
const _M0FP36mizchi6kagura9inpututil6key__s = 83;
const _M0FP36mizchi6kagura9inpututil6key__d = 68;
const _M0FP36mizchi6kagura9inpututil12key__up__web = 38;
const _M0FP36mizchi6kagura9inpututil14key__down__web = 40;
const _M0FP36mizchi6kagura9inpututil14key__left__web = 37;
const _M0FP36mizchi6kagura9inpututil15key__right__web = 39;
const _M0FP36mizchi6kagura9inpututil13key__up__glfw = 265;
const _M0FP36mizchi6kagura9inpututil15key__down__glfw = 264;
const _M0FP36mizchi6kagura9inpututil15key__left__glfw = 263;
const _M0FP36mizchi6kagura9inpututil16key__right__glfw = 262;
const _M0FP36mizchi6kagura9inpututil10key__comma = 188;
const _M0FP36mizchi6kagura9inpututil6key__o = 79;
const _M0FP36mizchi6kagura9inpututil6key__e = 69;
const _M0FP36mizchi6kagura9inpututil10key__space = 32;
const _M0FP36mizchi6kagura9inpututil15key__enter__web = 13;
const _M0FP36mizchi6kagura9inpututil16key__enter__glfw = 257;
const _M0FP26mizchi10hacknslash19enemy__speed__basic = 0.8;
const _M0FP26mizchi10hacknslash11kind__basic = 0;
const _M0FP26mizchi10hacknslash10kind__boss = 4;
const _M0FP26mizchi10hacknslash10tile__size = 16;
const _M0FP26mizchi10hacknslash18enemy__speed__fast = 1.2;
const _M0FP26mizchi10hacknslash18enemy__speed__tank = 0.4;
const _M0FP26mizchi10hacknslash10kind__fast = 1;
const _M0FP26mizchi10hacknslash12kind__ranged = 3;
const _M0FP26mizchi10hacknslash10kind__tank = 2;
const _M0FP26mizchi10hacknslash9screen__h = 240;
const _M0FP26mizchi10hacknslash9screen__w = 320;
const _M0FP26mizchi10hacknslash9map__cols = 40;
const _M0FP26mizchi10hacknslash9map__rows = 30;
const _M0FP26mizchi10hacknslash11mode__title = 0;
const _M0FP26mizchi10hacknslash8world__h = 480;
const _M0FP26mizchi10hacknslash8world__w = 640;
const _M0FP26mizchi10hacknslash14mode__gameover = 2;
const _M0FP26mizchi10hacknslash13mode__playing = 1;
const _M0FP26mizchi10hacknslash16attack__cooldown = 20;
const _M0FP26mizchi10hacknslash23damage__flash__duration = 10;
const _M0FP26mizchi10hacknslash14dash__cooldown = 40;
const _M0FP26mizchi10hacknslash14dash__duration = 8;
const _M0FP26mizchi10hacknslash17dash__speed__mult = 4;
const _M0FP26mizchi10hacknslash16iframe__duration = 30;
const _M0FP26mizchi10hacknslash12item__health = 0;
const _M0FP26mizchi10hacknslash13player__speed = 2;
const _M0FP26mizchi10hacknslash13attack__range = 24;
const _M0FP26mizchi10hacknslash11item__score = 1;
const _M0FP26mizchi10hacknslash19knockback__strength = 4;
const _M0FP26mizchi10hacknslash12chase__range = 120;
const _M0FP26mizchi10hacknslash22path__update__interval = 60;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP26mizchi19web__runtime__hooks21web__canvas__selector = _M0MP311moonbitlang4core3ref3Ref3newGsE("#app");
const _M0FP26mizchi19web__runtime__hooks21web__hooks__installed = _M0MP311moonbitlang4core3ref3Ref3newGbE(false);
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FP311moonbitlang4core7builtin33brute__force__find_2econstr_2f129 = 0;
const _M0FP311moonbitlang4core7builtin43boyer__moore__horspool__find_2econstr_2f115 = 0;
const _M0FP26mizchi19web__runtime__hooks20source__image__cache = _M0MP311moonbitlang4core3ref3Ref3newGRP311moonbitlang4core7builtin5ArrayGRP26mizchi19web__runtime__hooks21SourceImageCacheEntryEE([]);
const _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty = _M0MP311moonbitlang4core3ref3Ref3newGRP311moonbitlang4core7builtin5ArrayGiEE([]);
const _M0FP36mizchi6kagura3gfx20web__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx16WebGraphicsHooksE(_M0FP36mizchi6kagura3gfx29default__web__graphics__hooks());
const _M0FP26mizchi19web__runtime__hooks27synced__source__generations = _M0MP311moonbitlang4core3ref3Ref3newGRP311moonbitlang4core7builtin5ArrayGRP26mizchi19web__runtime__hooks22SyncedSourceGenerationEE([]);
const _M0FP36mizchi6kagura4text17font__load__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura4text13FontLoadHooksE(_M0FP36mizchi6kagura4text26default__font__load__hooks());
const _M0FP36mizchi6kagura8platform18web__canvas__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura8platform14WebCanvasHooksE(_M0FP36mizchi6kagura8platform27default__web__canvas__hooks());
(() => {
  _M0FP36mizchi6kagura6engine21set__lifecycle__hooks({ on_start: (canvas, _title) => {
    _M0FP26mizchi19web__runtime__hooks7install(canvas);
  }, on_stop: () => {
    _M0FP26mizchi19web__runtime__hooks8shutdown();
  } });
})();
const _M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f411 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MP311moonbitlang4core3ref3Ref3newGWEdE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx19NativeGraphicsHooksE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
function _M0IP311moonbitlang4core7builtin17CreatingViewErrorP311moonbitlang4core7builtin4Show6output(_x_5142, _x_5143) {
  if (_x_5142.$tag === 1) {
    _x_5143.method_table.method_0(_x_5143.self, "IndexOutOfBounds");
    return;
  } else {
    _x_5143.method_table.method_0(_x_5143.self, "InvalidIndex");
    return;
  }
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
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4RoomE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP26mizchi10hacknslash10ProjectileE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP26mizchi10hacknslash5EnemyE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4TileE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types5PointE(self, index) {
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
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self, index) {
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
function _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGsE(x, y) {
  return !(x === y);
}
function _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGRP36mizchi7terrain5types4TileE(x, y) {
  return !_M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(x, y);
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
function _M0MP311moonbitlang4core6string10StringView6length(self) {
  return self.end - self.start | 0;
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
function _M0MP311moonbitlang4core7builtin4Iter4nextGcE(self) {
  const _func = self;
  return _func();
}
function _M0MP311moonbitlang4core3int3Int18to__string_2einner(self, radix) {
  return _M0FP311moonbitlang4core7builtin19int__to__string__js(self, radix);
}
function _M0MP311moonbitlang4core6string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
}
function _M0MP311moonbitlang4core7builtin4Iter3newGcE(f) {
  return f;
}
function _M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0IP311moonbitlang4core7builtin13StringBuilderP311moonbitlang4core7builtin6Logger11write__view(self, str) {
  const _bind = self;
  _bind.val = `${_bind.val}${_M0IP311moonbitlang4core6string10StringViewP311moonbitlang4core7builtin4Show10to__string(str)}`;
}
function _M0FP311moonbitlang4core7builtin28boyer__moore__horspool__find(haystack, needle) {
  const haystack_len = _M0MP311moonbitlang4core6string10StringView6length(haystack);
  const needle_len = _M0MP311moonbitlang4core6string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      const _end4308 = needle_len - 1 | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < _end4308) {
          const _tmp$2 = _M0MP311moonbitlang4core6string10StringView11unsafe__get(needle, i) & 255;
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
          const _end4314 = needle_len - 1 | 0;
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j <= _end4314) {
              if (_M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin2Eq10not__equal(_M0MP311moonbitlang4core6string10StringView11unsafe__get(haystack, i + j | 0), _M0MP311moonbitlang4core6string10StringView11unsafe__get(needle, j))) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = _M0MP311moonbitlang4core6string10StringView11unsafe__get(haystack, (i + needle_len | 0) - 1 | 0) & 255;
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
    return _M0FP311moonbitlang4core7builtin43boyer__moore__horspool__find_2econstr_2f115;
  }
}
function _M0FP311moonbitlang4core7builtin18brute__force__find(haystack, needle) {
  const haystack_len = _M0MP311moonbitlang4core6string10StringView6length(haystack);
  const needle_len = _M0MP311moonbitlang4core6string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = _M0MP311moonbitlang4core6string10StringView11unsafe__get(needle, 0);
      const forward_len = haystack_len - needle_len | 0;
      let i = 0;
      while (true) {
        if (i <= forward_len) {
          while (true) {
            if (i <= forward_len && _M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin2Eq10not__equal(_M0MP311moonbitlang4core6string10StringView11unsafe__get(haystack, i), needle_first)) {
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
                if (_M0IP311moonbitlang4core6uint166UInt16P311moonbitlang4core7builtin2Eq10not__equal(_M0MP311moonbitlang4core6string10StringView11unsafe__get(haystack, i + j | 0), _M0MP311moonbitlang4core6string10StringView11unsafe__get(needle, j))) {
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
    return _M0FP311moonbitlang4core7builtin33brute__force__find_2econstr_2f129;
  }
}
function _M0MP311moonbitlang4core6string10StringView4find(self, str) {
  return _M0MP311moonbitlang4core6string10StringView6length(str) <= 4 ? _M0FP311moonbitlang4core7builtin18brute__force__find(self, str) : _M0FP311moonbitlang4core7builtin28boyer__moore__horspool__find(self, str);
}
function _M0MP311moonbitlang4core5array5Array4pushGiE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura4core10TouchPointE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGdE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura4core15GamepadSnapshotE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash5EnemyE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7terrain5types4RoomE(self, value) {
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
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash8ItemDropE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash10ProjectileE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi5audio5VoiceE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura8pathfind7PQEntryE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7terrain5types5PointE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core6string10StringView8contains(self, str) {
  const _bind = _M0MP311moonbitlang4core6string10StringView4find(self, str);
  return !(_bind === undefined);
}
function _M0MP311moonbitlang4core6string6String8contains(self, str) {
  return _M0MP311moonbitlang4core6string10StringView8contains({ str: self, start: 0, end: self.length }, str);
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
function _M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(self) {
  return self;
}
function _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
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
function _M0MP311moonbitlang4core5array5Array4makeGRP36mizchi7terrain5types4TileE(len, elem) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi7terrain5types4TileE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi7terrain5types5PointE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura8pathfind7PQEntryE(self, index, value) {
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
function _M0MP311moonbitlang4core5array5Array28unsafe__truncate__to__lengthGRP36mizchi7terrain5types4RoomE(self, new_len) {
  _M0MP311moonbitlang4core7builtin7JSArray11set__length(self, new_len);
}
function _M0MP311moonbitlang4core5array5Array11unsafe__popGRP36mizchi6kagura8pathfind7PQEntryE(self) {
  return _M0MP311moonbitlang4core7builtin7JSArray3pop(self);
}
function _M0MP311moonbitlang4core5array5Array3popGRP36mizchi6kagura8pathfind7PQEntryE(self) {
  if (self.length === 0) {
    return undefined;
  } else {
    const v = _M0MP311moonbitlang4core5array5Array11unsafe__popGRP36mizchi6kagura8pathfind7PQEntryE(self);
    return v;
  }
}
function _M0MP311moonbitlang4core5array5Array5clearGRP36mizchi7terrain5types4RoomE(self) {
  _M0MP311moonbitlang4core5array5Array28unsafe__truncate__to__lengthGRP36mizchi7terrain5types4RoomE(self, 0);
}
function _M0MP311moonbitlang4core5array5Array6filterGRP26mizchi10hacknslash10ProjectileE(self, f) {
  const arr = [];
  const _len = self.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const v = self[_i];
      if (f(v)) {
        _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash10ProjectileE(arr, v);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MP311moonbitlang4core5array5Array6filterGRP26mizchi10hacknslash8ItemDropE(self, f) {
  const arr = [];
  const _len = self.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const v = self[_i];
      if (f(v)) {
        _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash8ItemDropE(arr, v);
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
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
function _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGbE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGsE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGiE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGdE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP311moonbitlang4core7builtin5ArrayGRP26mizchi19web__runtime__hooks21SourceImageCacheEntryEE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP311moonbitlang4core7builtin5ArrayGRP26mizchi19web__runtime__hooks22SyncedSourceGenerationEE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP311moonbitlang4core7builtin5ArrayGiEE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura8platform14WebCanvasHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx16WebGraphicsHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura4text13FontLoadHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGWEdE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura3gfx19NativeGraphicsHooksE(x) {
  return { val: x };
}
function _M0FP311moonbitlang4core3cmp7maximumGdE(x, y) {
  return x > y ? x : y;
}
function _M0FP311moonbitlang4core3cmp7maximumGiE(x, y) {
  return x > y ? x : y;
}
function _M0FP311moonbitlang4core3cmp7minimumGdE(x, y) {
  return x > y ? y : x;
}
function _M0FP311moonbitlang4core3cmp7minimumGiE(x, y) {
  return x > y ? y : x;
}
function _M0FP311moonbitlang4core4math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FP311moonbitlang4core4math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0FP311moonbitlang4core4math5atan2(_tmp, _tmp$2) {
  return Math.atan2(_tmp, _tmp$2);
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
  let hi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f411, ind);
  let mi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f411, ind + 1 | 0);
  let lo = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f411, ind + 2 | 0);
  const tp = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f411, ind + 3 | 0);
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
function _M0MP36mizchi6kagura8camera2d8Camera2D3new(screen_w, screen_h, world_w, world_h) {
  return { x: 0, y: 0, screen_w: screen_w, screen_h: screen_h, world_w: world_w, world_h: world_h };
}
function _M0MP36mizchi6kagura8camera2d8Camera2D14follow__target(self, target_x, target_y) {
  self.x = target_x - self.screen_w / 2;
  self.y = target_y - self.screen_h / 2;
  self.x = _M0FP311moonbitlang4core3cmp7maximumGdE(0, _M0FP311moonbitlang4core3cmp7minimumGdE(self.world_w - self.screen_w, self.x));
  self.y = _M0FP311moonbitlang4core3cmp7maximumGdE(0, _M0FP311moonbitlang4core3cmp7minimumGdE(self.world_h - self.screen_h, self.y));
}
function _M0FP36mizchi6kagura4core18new__outside__size(width, height) {
  return { width: width, height: height };
}
function _M0FP36mizchi6kagura4core17new__touch__point(id, x, y) {
  return { id: id, x: x, y: y, source: 3 };
}
function _M0FP36mizchi6kagura4core22new__gamepad__snapshot(id, axes, pressed_buttons) {
  return { id: id, axes: axes, pressed_buttons: pressed_buttons };
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
function _M0FP36mizchi6kagura9inpututil16is__key__pressed(state, key) {
  return _M0FP36mizchi6kagura9inpututil13contains__key(state.pressed_keys, key);
}
function _M0FP36mizchi6kagura9inpututil22is__key__just__pressed(state, key) {
  return _M0FP36mizchi6kagura9inpututil13contains__key(state.just_pressed_keys, key);
}
function _M0FP36mizchi6kagura9inpututil18new__input__helper() {
  return { key_state: _M0FP36mizchi6kagura9inpututil22new__key__input__state(), mouse_state: _M0FP36mizchi6kagura9inpututil24new__mouse__input__state(), touch_state: _M0FP36mizchi6kagura9inpututil24new__touch__input__state() };
}
function _M0FP36mizchi6kagura9inpututil21update__input__helper(helper, snapshot) {
  _M0FP36mizchi6kagura9inpututil25update__key__input__state(helper.key_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__mouse__input__state(helper.mouse_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__touch__input__state(helper.touch_state, snapshot);
}
function _M0FP36mizchi6kagura9inpututil12is__move__up(key_state) {
  return _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil6key__w) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil10key__comma) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil12key__up__web) || _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil13key__up__glfw)));
}
function _M0FP36mizchi6kagura9inpututil14is__move__down(key_state) {
  return _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil6key__s) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil6key__o) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil14key__down__web) || _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil15key__down__glfw)));
}
function _M0FP36mizchi6kagura9inpututil14is__move__left(key_state) {
  return _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil6key__a) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil14key__left__web) || _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil15key__left__glfw));
}
function _M0FP36mizchi6kagura9inpututil15is__move__right(key_state) {
  return _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil6key__d) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil6key__e) || (_M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil15key__right__web) || _M0FP36mizchi6kagura9inpututil16is__key__pressed(key_state, _M0FP36mizchi6kagura9inpututil16key__right__glfw)));
}
function _M0FP36mizchi6kagura9inpututil26is__confirm__just__pressed(helper) {
  return _M0FP36mizchi6kagura9inpututil22is__key__just__pressed(helper.key_state, _M0FP36mizchi6kagura9inpututil10key__space) || (_M0FP36mizchi6kagura9inpututil22is__key__just__pressed(helper.key_state, _M0FP36mizchi6kagura9inpututil15key__enter__web) || _M0FP36mizchi6kagura9inpututil22is__key__just__pressed(helper.key_state, _M0FP36mizchi6kagura9inpututil16key__enter__glfw));
}
function _M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(_x_327, _x_328) {
  switch (_x_327) {
    case 0: {
      if (_x_328 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_328 === 1) {
        return true;
      } else {
        return false;
      }
    }
    case 2: {
      if (_x_328 === 2) {
        return true;
      } else {
        return false;
      }
    }
    case 3: {
      if (_x_328 === 3) {
        return true;
      } else {
        return false;
      }
    }
    case 4: {
      if (_x_328 === 4) {
        return true;
      } else {
        return false;
      }
    }
    case 5: {
      if (_x_328 === 5) {
        return true;
      } else {
        return false;
      }
    }
    case 6: {
      if (_x_328 === 6) {
        return true;
      } else {
        return false;
      }
    }
    case 7: {
      if (_x_328 === 7) {
        return true;
      } else {
        return false;
      }
    }
    case 8: {
      if (_x_328 === 8) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_328 === 9) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0MP36mizchi7terrain5types4Rect6center(self) {
  const _tmp = self.x;
  if (2 === 0) {
    $panic();
  }
  const _tmp$2 = _tmp + (self.w / 2 | 0) | 0;
  const _tmp$3 = self.y;
  if (2 === 0) {
    $panic();
  }
  return { x: _tmp$2, y: _tmp$3 + (self.h / 2 | 0) | 0 };
}
function _M0FP36mizchi7terrain5types9make__rng(seed) {
  return { state: seed === 0 ? 1 : seed };
}
function _M0MP36mizchi7terrain5types3RNG4next(self) {
  const s = { val: self.state };
  s.val = s.val ^ s.val << 13;
  s.val = s.val ^ (s.val >>> 17 | 0);
  s.val = s.val ^ s.val << 5;
  self.state = s.val;
  return s.val;
}
function _M0MP36mizchi7terrain5types3RNG9next__int(self, max) {
  if (max <= 0) {
    return 0;
  }
  if (max === 0) {
    $panic();
  }
  return (_M0MP36mizchi7terrain5types3RNG4next(self) & 2147483647) % max | 0;
}
function _M0MP36mizchi7terrain5types3RNG11rand__range(self, min, max) {
  if (min >= max) {
    return min;
  }
  return min + _M0MP36mizchi7terrain5types3RNG9next__int(self, max - min | 0) | 0;
}
function _M0MP36mizchi7terrain5types3RNG10rand__bool(self, probability) {
  const v = ((_M0MP36mizchi7terrain5types3RNG4next(self) & 2147483647) + 0) / 2147483647;
  return v < probability;
}
function _M0MP36mizchi7terrain5types6Grid2D3get(self, x, y) {
  return _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4TileE(self.cells, (Math.imul(y, self.width) | 0) + x | 0);
}
function _M0MP36mizchi7terrain5types6Grid2D10in__bounds(self, x, y) {
  return x >= 0 && (x < self.width && (y >= 0 && y < self.height));
}
function _M0MP36mizchi7terrain5types6Grid2D4make(width, height, fill) {
  return { width: width, height: height, cells: _M0MP311moonbitlang4core5array5Array4makeGRP36mizchi7terrain5types4TileE(Math.imul(width, height) | 0, fill) };
}
function _M0MP36mizchi7terrain5types6Grid2D3set(self, x, y, tile) {
  _M0MP311moonbitlang4core5array5Array3setGRP36mizchi7terrain5types4TileE(self.cells, (Math.imul(y, self.width) | 0) + x | 0, tile);
}
function _M0MP36mizchi7terrain5types6Grid2D10fill__rect(self, rect, tile) {
  const _start56 = rect.y;
  const _end57 = rect.y + rect.h | 0;
  let _tmp = _start56;
  while (true) {
    const y = _tmp;
    if (y < _end57) {
      const _start61 = rect.x;
      const _end62 = rect.x + rect.w | 0;
      let _tmp$2 = _start61;
      while (true) {
        const x = _tmp$2;
        if (x < _end62) {
          if (_M0MP36mizchi7terrain5types6Grid2D10in__bounds(self, x, y)) {
            _M0MP36mizchi7terrain5types6Grid2D3set(self, x, y, tile);
          }
          _tmp$2 = x + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = y + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MP36mizchi7terrain5types6Grid2D11carve__line(self, from, to, tile) {
  const x = { val: from.x };
  const y = { val: from.y };
  while (true) {
    if (x.val !== to.x || y.val !== to.y) {
      if (_M0MP36mizchi7terrain5types6Grid2D10in__bounds(self, x.val, y.val)) {
        _M0MP36mizchi7terrain5types6Grid2D3set(self, x.val, y.val, tile);
      }
      if (x.val !== to.x) {
        if (x.val < to.x) {
          x.val = x.val + 1 | 0;
        } else {
          x.val = x.val - 1 | 0;
        }
      } else {
        if (y.val !== to.y) {
          if (y.val < to.y) {
            y.val = y.val + 1 | 0;
          } else {
            y.val = y.val - 1 | 0;
          }
        }
      }
      continue;
    } else {
      break;
    }
  }
  if (_M0MP36mizchi7terrain5types6Grid2D10in__bounds(self, to.x, to.y)) {
    _M0MP36mizchi7terrain5types6Grid2D3set(self, to.x, to.y, tile);
    return;
  } else {
    return;
  }
}
function _M0MP36mizchi7terrain5types6Grid2D18carve__l__corridor(self, from, to, tile) {
  const mid = { x: to.x, y: from.y };
  _M0MP36mizchi7terrain5types6Grid2D11carve__line(self, from, mid, tile);
  _M0MP36mizchi7terrain5types6Grid2D11carve__line(self, mid, to, tile);
}
function _M0MP36mizchi6kagura8pathfind13PriorityQueue3new() {
  return { data: [] };
}
function _M0MP36mizchi6kagura8pathfind13PriorityQueue8sift__up(self, idx) {
  const i = { val: idx };
  while (true) {
    if (i.val > 0) {
      if (2 === 0) {
        $panic();
      }
      const parent = (i.val - 1 | 0) / 2 | 0;
      if (_M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, i.val).priority < _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, parent).priority) {
        const tmp = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, i.val);
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura8pathfind7PQEntryE(self.data, i.val, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, parent));
        _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura8pathfind7PQEntryE(self.data, parent, tmp);
        i.val = parent;
      } else {
        break;
      }
      continue;
    } else {
      return;
    }
  }
}
function _M0MP36mizchi6kagura8pathfind13PriorityQueue4push(self, point, priority) {
  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura8pathfind7PQEntryE(self.data, { point: point, priority: priority });
  _M0MP36mizchi6kagura8pathfind13PriorityQueue8sift__up(self, self.data.length - 1 | 0);
}
function _M0MP36mizchi6kagura8pathfind13PriorityQueue10sift__down(self, idx) {
  const n = self.data.length;
  const i = { val: idx };
  while (true) {
    const left = (Math.imul(2, i.val) | 0) + 1 | 0;
    const right = (Math.imul(2, i.val) | 0) + 2 | 0;
    const smallest = { val: i.val };
    if (left < n && _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, left).priority < _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, smallest.val).priority) {
      smallest.val = left;
    }
    if (right < n && _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, right).priority < _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, smallest.val).priority) {
      smallest.val = right;
    }
    if (smallest.val === i.val) {
      break;
    }
    const tmp = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, i.val);
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura8pathfind7PQEntryE(self.data, i.val, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, smallest.val));
    _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura8pathfind7PQEntryE(self.data, smallest.val, tmp);
    i.val = smallest.val;
    continue;
  }
}
function _M0MP36mizchi6kagura8pathfind13PriorityQueue3pop(self) {
  if (self.data.length === 0) {
    return undefined;
  }
  const result = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, 0).point;
  const last = self.data.length - 1 | 0;
  _M0MP311moonbitlang4core5array5Array3setGRP36mizchi6kagura8pathfind7PQEntryE(self.data, 0, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8pathfind7PQEntryE(self.data, last));
  _M0MP311moonbitlang4core5array5Array3popGRP36mizchi6kagura8pathfind7PQEntryE(self.data);
  if (self.data.length > 0) {
    _M0MP36mizchi6kagura8pathfind13PriorityQueue10sift__down(self, 0);
  }
  return result;
}
function _M0FP36mizchi6kagura8pathfind17default__walkable(tile) {
  switch (tile) {
    case 0: {
      return true;
    }
    case 7: {
      return true;
    }
    case 2: {
      return true;
    }
    case 5: {
      return true;
    }
    case 6: {
      return true;
    }
    default: {
      return false;
    }
  }
}
function _M0FP36mizchi6kagura8pathfind9manhattan(a, b) {
  const dx = a.x > b.x ? a.x - b.x | 0 : b.x - a.x | 0;
  const dy = a.y > b.y ? a.y - b.y | 0 : b.y - a.y | 0;
  return (dx + dy | 0) + 0;
}
function _M0FP36mizchi6kagura8pathfind17reconstruct__path(came_from, width, goal_idx) {
  const path = [];
  const idx = { val: goal_idx };
  while (true) {
    if (idx.val >= 0) {
      if (width === 0) {
        $panic();
      }
      const x = idx.val % width | 0;
      if (width === 0) {
        $panic();
      }
      const y = idx.val / width | 0;
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7terrain5types5PointE(path, { x: x, y: y });
      idx.val = _M0MP311moonbitlang4core5array5Array2atGiE(came_from, idx.val);
      continue;
    } else {
      break;
    }
  }
  const n = path.length;
  const _start9 = 0;
  if (2 === 0) {
    $panic();
  }
  const _end10 = n / 2 | 0;
  let _tmp = _start9;
  while (true) {
    const i = _tmp;
    if (i < _end10) {
      const tmp = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types5PointE(path, i);
      _M0MP311moonbitlang4core5array5Array3setGRP36mizchi7terrain5types5PointE(path, i, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types5PointE(path, (n - 1 | 0) - i | 0));
      _M0MP311moonbitlang4core5array5Array3setGRP36mizchi7terrain5types5PointE(path, (n - 1 | 0) - i | 0, tmp);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return path;
}
function _M0FP36mizchi6kagura8pathfind18find__path_2einner(grid, start, goal, walkable) {
  if (!_M0MP36mizchi7terrain5types6Grid2D10in__bounds(grid, start.x, start.y) || !_M0MP36mizchi7terrain5types6Grid2D10in__bounds(grid, goal.x, goal.y)) {
    return Option$None$1$;
  }
  if (!walkable(_M0MP36mizchi7terrain5types6Grid2D3get(grid, start.x, start.y)) || !walkable(_M0MP36mizchi7terrain5types6Grid2D3get(grid, goal.x, goal.y))) {
    return Option$None$1$;
  }
  if (start.x === goal.x && start.y === goal.y) {
    return new Option$Some$1$([start]);
  }
  const w = grid.width;
  const h = grid.height;
  const size = Math.imul(w, h) | 0;
  const g_score = _M0MP311moonbitlang4core5array5Array4makeGdE(size, -1);
  const came_from = _M0MP311moonbitlang4core5array5Array4makeGiE(size, -1);
  const start_idx = (Math.imul(start.y, w) | 0) + start.x | 0;
  const goal_idx = (Math.imul(goal.y, w) | 0) + goal.x | 0;
  _M0MP311moonbitlang4core5array5Array3setGdE(g_score, start_idx, 0);
  const open = _M0MP36mizchi6kagura8pathfind13PriorityQueue3new();
  _M0MP36mizchi6kagura8pathfind13PriorityQueue4push(open, start, _M0FP36mizchi6kagura8pathfind9manhattan(start, goal));
  const dx = [-1, 1, 0, 0];
  const dy = [0, 0, -1, 1];
  while (true) {
    let current;
    _L: {
      const _bind = _M0MP36mizchi6kagura8pathfind13PriorityQueue3pop(open);
      if (_bind === undefined) {
        return Option$None$1$;
      } else {
        const _Some = _bind;
        const _current = _Some;
        current = _current;
        break _L;
      }
    }
    const ci = (Math.imul(current.y, w) | 0) + current.x | 0;
    if (ci === goal_idx) {
      return new Option$Some$1$(_M0FP36mizchi6kagura8pathfind17reconstruct__path(came_from, w, goal_idx));
    }
    const cg = _M0MP311moonbitlang4core5array5Array2atGdE(g_score, ci);
    const _start36 = 0;
    const _end37 = 4;
    let _tmp = _start36;
    while (true) {
      const d = _tmp;
      if (d < _end37) {
        const nx = current.x + _M0MP311moonbitlang4core5array5Array2atGiE(dx, d) | 0;
        const ny = current.y + _M0MP311moonbitlang4core5array5Array2atGiE(dy, d) | 0;
        if (nx >= 0 && (nx < w && (ny >= 0 && ny < h))) {
          const ni = (Math.imul(ny, w) | 0) + nx | 0;
          if (walkable(_M0MP36mizchi7terrain5types6Grid2D3get(grid, nx, ny))) {
            const ng = cg + 1;
            if (_M0MP311moonbitlang4core5array5Array2atGdE(g_score, ni) < 0 || ng < _M0MP311moonbitlang4core5array5Array2atGdE(g_score, ni)) {
              _M0MP311moonbitlang4core5array5Array3setGdE(g_score, ni, ng);
              _M0MP311moonbitlang4core5array5Array3setGiE(came_from, ni, ci);
              const f = ng + _M0FP36mizchi6kagura8pathfind9manhattan({ x: nx, y: ny }, goal);
              _M0MP36mizchi6kagura8pathfind13PriorityQueue4push(open, { x: nx, y: ny }, f);
            }
          }
        }
        _tmp = d + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    continue;
  }
}
function _M0FP36mizchi6kagura8pathfind10find__path(grid, start, goal, walkable$46$opt) {
  let walkable;
  if (walkable$46$opt === undefined) {
    walkable = _M0FP36mizchi6kagura8pathfind17default__walkable;
  } else {
    const _Some = walkable$46$opt;
    walkable = _Some;
  }
  return _M0FP36mizchi6kagura8pathfind18find__path_2einner(grid, start, goal, walkable);
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
function _M0FP36mizchi6kagura5audio31new__audio__output__hooks__full(try_initialize, write_frames, suspend, resume_playback, close, output_latency) {
  return { try_initialize: try_initialize, write_frames: write_frames, suspend: suspend, resume_playback: resume_playback, close: close, output_latency: output_latency };
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
  return { kind: 3, opaque_id: 0, width: width, height: height, device_scale_factor: 1 };
}
function _M0FP36mizchi6kagura8platform30create__webgpu__surface__token(opaque_id, width, height, device_scale_factor) {
  return { kind: 1, opaque_id: opaque_id, width: width, height: height, device_scale_factor: device_scale_factor };
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform15SurfaceProvider16current__surface(self) {
  return new Result$Ok$3$(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : { kind: 1, opaque_id: 2, width: self.options.width, height: self.options.height, device_scale_factor: 1 });
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
function _M0FP36mizchi6kagura6vector21aabb__overlap__center(ax, ay, ahw, ahh, bx, by, bhw, bhh) {
  return Math.abs(ax - bx) < ahw + bhw && Math.abs(ay - by) < ahh + bhh;
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
function _M0FP36mizchi6kagura6engine21set__lifecycle__hooks(hooks) {
  _M0FP36mizchi6kagura6engine16lifecycle__hooks.val = hooks;
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
function _M0FP36mizchi6kagura5scene13group_2einner(x, y, children) {
  return _M0FP36mizchi7signals2ui1hGuRP36mizchi6kagura5scene14SceneAttrValueE("group", [{ _0: "x", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(x)) }, { _0: "y", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(y)) }], children);
}
function _M0FP36mizchi6kagura5scene12line_2einner(x0, y0, x1, y1, width, color) {
  return _M0FP36mizchi7signals2ui1hGuRP36mizchi6kagura5scene14SceneAttrValueE("line", [{ _0: "x0", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(x0)) }, { _0: "y0", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(y0)) }, { _0: "x1", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(x1)) }, { _0: "y1", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(y1)) }, { _0: "width", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(width)) }, { _0: "color", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt(color)) }], []);
}
function _M0FP36mizchi6kagura5scene21rect__outline_2einner(x, y, w, h, line_width, color) {
  return _M0FP36mizchi7signals2ui1hGuRP36mizchi6kagura5scene14SceneAttrValueE("rect_outline", [{ _0: "x", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(x)) }, { _0: "y", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(y)) }, { _0: "w", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(w)) }, { _0: "h", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(h)) }, { _0: "line_width", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneDouble(line_width)) }, { _0: "color", _1: _M0FP36mizchi7signals2ui12attr__staticGuRP36mizchi6kagura5scene14SceneAttrValueE(new $64$mizchi$47$kagura$47$scene$46$SceneAttrValue$SceneInt(color)) }], []);
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
  _M0FP36mizchi6kagura6engine11run_2einner(update, (ctx) => {
    const sw = ctx.screen_w + 0;
    const sh = ctx.screen_h + 0;
    const cmds = _M0FP36mizchi6kagura5scene13render__scene(view(), ctx.dst, ctx.shader, sw, sh);
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
      f(cmds, ctx.dst, ctx.shader, sw, sh);
    }
    return cmds;
  }, undefined, undefined, audio_ctx, 735, width, height, title, canvas);
}
function _M0FP36mizchi7terrain3bsp11split__node(rect, depth, max_depth, min_size, rng) {
  if (depth >= max_depth || rect.w < (Math.imul(min_size, 2) | 0) && rect.h < (Math.imul(min_size, 2) | 0)) {
    return { rect: rect, left: undefined, right: undefined, room: undefined };
  }
  const horizontal = rect.w > (Math.imul(rect.h, 2) | 0) ? false : rect.h > (Math.imul(rect.w, 2) | 0) ? true : _M0MP36mizchi7terrain5types3RNG10rand__bool(rng, 0.5);
  if (horizontal) {
    if (rect.h < (Math.imul(min_size, 2) | 0)) {
      return { rect: rect, left: undefined, right: undefined, room: undefined };
    }
    const split_y = _M0MP36mizchi7terrain5types3RNG11rand__range(rng, rect.y + min_size | 0, (rect.y + rect.h | 0) - min_size | 0);
    const top = { x: rect.x, y: rect.y, w: rect.w, h: split_y - rect.y | 0 };
    const bottom = { x: rect.x, y: split_y, w: rect.w, h: (rect.y + rect.h | 0) - split_y | 0 };
    const left = _M0FP36mizchi7terrain3bsp11split__node(top, depth + 1 | 0, max_depth, min_size, rng);
    const right = _M0FP36mizchi7terrain3bsp11split__node(bottom, depth + 1 | 0, max_depth, min_size, rng);
    return { rect: rect, left: left, right: right, room: undefined };
  } else {
    if (rect.w < (Math.imul(min_size, 2) | 0)) {
      return { rect: rect, left: undefined, right: undefined, room: undefined };
    }
    const split_x = _M0MP36mizchi7terrain5types3RNG11rand__range(rng, rect.x + min_size | 0, (rect.x + rect.w | 0) - min_size | 0);
    const left_rect = { x: rect.x, y: rect.y, w: split_x - rect.x | 0, h: rect.h };
    const right_rect = { x: split_x, y: rect.y, w: (rect.x + rect.w | 0) - split_x | 0, h: rect.h };
    const left = _M0FP36mizchi7terrain3bsp11split__node(left_rect, depth + 1 | 0, max_depth, min_size, rng);
    const right = _M0FP36mizchi7terrain3bsp11split__node(right_rect, depth + 1 | 0, max_depth, min_size, rng);
    return { rect: rect, left: left, right: right, room: undefined };
  }
}
function _M0FP36mizchi7terrain3bsp12place__rooms(node, min_size, rng, rooms) {
  _L: {
    let l;
    let r;
    _L$2: {
      const _bind = node.left;
      const _bind$2 = node.right;
      if (_bind === undefined) {
        break _L;
      } else {
        const _Some = _bind;
        const _l = _Some;
        if (_bind$2 === undefined) {
          break _L;
        } else {
          const _Some$2 = _bind$2;
          const _r = _Some$2;
          l = _l;
          r = _r;
          break _L$2;
        }
      }
    }
    const new_left = _M0FP36mizchi7terrain3bsp12place__rooms(l, min_size, rng, rooms);
    const new_right = _M0FP36mizchi7terrain3bsp12place__rooms(r, min_size, rng, rooms);
    return { rect: node.rect, left: new_left, right: new_right, room: node.room };
  }
  const r = node.rect;
  if (r.w >= min_size && r.h >= min_size) {
    const room_w = _M0MP36mizchi7terrain5types3RNG11rand__range(rng, min_size, r.w);
    const room_h = _M0MP36mizchi7terrain5types3RNG11rand__range(rng, min_size, r.h);
    const room_x = _M0MP36mizchi7terrain5types3RNG11rand__range(rng, r.x, (r.x + r.w | 0) - room_w | 0);
    const room_y = _M0MP36mizchi7terrain5types3RNG11rand__range(rng, r.y, (r.y + r.h | 0) - room_h | 0);
    const room_rect = { x: room_x, y: room_y, w: room_w, h: room_h };
    const room = { rect: room_rect, id: rooms.length };
    _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7terrain5types4RoomE(rooms, room);
    return { rect: node.rect, left: node.left, right: node.right, room: room_rect };
  } else {
    return node;
  }
}
function _M0FP36mizchi7terrain3bsp17get__room__center(node) {
  let _tmp = node;
  while (true) {
    const node$2 = _tmp;
    let r;
    _L: {
      const _bind = node$2.room;
      if (_bind === undefined) {
        let l;
        _L$2: {
          const _bind$2 = node$2.left;
          if (_bind$2 === undefined) {
            let r$2;
            _L$3: {
              const _bind$3 = node$2.right;
              if (_bind$3 === undefined) {
                return undefined;
              } else {
                const _Some = _bind$3;
                const _r = _Some;
                r$2 = _r;
                break _L$3;
              }
            }
            _tmp = r$2;
            continue;
          } else {
            const _Some = _bind$2;
            const _l = _Some;
            l = _l;
            break _L$2;
          }
        }
        _tmp = l;
        continue;
      } else {
        const _Some = _bind;
        const _r = _Some;
        r = _r;
        break _L;
      }
    }
    return _M0MP36mizchi7terrain5types4Rect6center(r);
  }
}
function _M0FP36mizchi7terrain3bsp14connect__rooms(node, grid) {
  let l;
  let r;
  _L: {
    const _bind = node.left;
    const _bind$2 = node.right;
    if (_bind === undefined) {
      return;
    } else {
      const _Some = _bind;
      const _l = _Some;
      if (_bind$2 === undefined) {
        return;
      } else {
        const _Some$2 = _bind$2;
        const _r = _Some$2;
        l = _l;
        r = _r;
        break _L;
      }
    }
  }
  _M0FP36mizchi7terrain3bsp14connect__rooms(l, grid);
  _M0FP36mizchi7terrain3bsp14connect__rooms(r, grid);
  const c1 = _M0FP36mizchi7terrain3bsp17get__room__center(l);
  const c2 = _M0FP36mizchi7terrain3bsp17get__room__center(r);
  let p1;
  let p2;
  _L$2: {
    if (c1 === undefined) {
      return;
    } else {
      const _Some = c1;
      const _p1 = _Some;
      if (c2 === undefined) {
        return;
      } else {
        const _Some$2 = c2;
        const _p2 = _Some$2;
        p1 = _p1;
        p2 = _p2;
        break _L$2;
      }
    }
  }
  _M0MP36mizchi7terrain5types6Grid2D18carve__l__corridor(grid, p1, p2, 7);
}
function _M0FP36mizchi7terrain3bsp8generate(config, rng) {
  const grid = _M0MP36mizchi7terrain5types6Grid2D4make(config.width, config.height, 1);
  const full_rect = { x: 1, y: 1, w: config.width - 2 | 0, h: config.height - 2 | 0 };
  const rooms = [];
  const tree = _M0FP36mizchi7terrain3bsp11split__node(full_rect, 0, config.max_depth, config.min_room_size, rng);
  const tree$2 = _M0FP36mizchi7terrain3bsp12place__rooms(tree, config.min_room_size, rng, rooms);
  const _arr = rooms;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const room = _arr[_i];
      _M0MP36mizchi7terrain5types6Grid2D10fill__rect(grid, room.rect, 0);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP36mizchi7terrain3bsp14connect__rooms(tree$2, grid);
  return { grid: grid, rooms: rooms };
}
function _M0FP36mizchi6kagura4text22new__font__load__hooks(load_font_data) {
  return { load_font_data: load_font_data };
}
function _M0FP36mizchi6kagura4text25default__load__font__data(_name) {
  return Option$None$4$;
}
function _M0FP36mizchi6kagura4text26default__font__load__hooks() {
  return { load_font_data: _M0FP36mizchi6kagura4text25default__load__font__data };
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
  const out = { val: undefined };
  const _arr = _M0FP26mizchi19web__runtime__hooks20source__image__cache.val;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const entry = _arr[_i];
      if (entry.image_id === image_id) {
        out.val = entry;
      }
      _tmp = _i + 1 | 0;
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
  const _start102 = 0;
  const _end103 = frames;
  let _tmp = _start102;
  while (true) {
    const i = _tmp;
    if (i < _end103) {
      const _start107 = 0;
      const _end108 = channels;
      let _tmp$2 = _start107;
      while (true) {
        const ch = _tmp$2;
        if (ch < _end108) {
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
    return Option$None$4$;
  }
  const data = _M0MP311moonbitlang4core5array5Array4makeGiE(size, 0);
  const _start125 = 0;
  const _end126 = size;
  let _tmp = _start125;
  while (true) {
    const i = _tmp;
    if (i < _end126) {
      _M0MP311moonbitlang4core5array5Array3setGiE(data, i, _M0FP26mizchi19web__runtime__hooks26js__load__font__data__byte(i));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new Option$Some$4$(data);
}
function _M0FP26mizchi19web__runtime__hooks27bridge__web__capture__input(active, _tick) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    const pressed_keys = [];
    const key_count = _M0FP26mizchi19web__runtime__hooks30js__input__pressed__key__count();
    const _start164 = 0;
    const _end165 = key_count;
    let _tmp = _start164;
    while (true) {
      const i = _tmp;
      if (i < _end165) {
        _M0MP311moonbitlang4core5array5Array4pushGiE(pressed_keys, _M0FP26mizchi19web__runtime__hooks27js__input__pressed__key__at(i));
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const pressed_mouse_buttons = [];
    const mouse_button_count = _M0FP26mizchi19web__runtime__hooks40js__input__pressed__mouse__button__count();
    const _start171 = 0;
    const _end172 = mouse_button_count;
    let _tmp$2 = _start171;
    while (true) {
      const i = _tmp$2;
      if (i < _end172) {
        const button = _M0FP26mizchi19web__runtime__hooks37js__input__pressed__mouse__button__at(i);
        if (button >= 0) {
          _M0MP311moonbitlang4core5array5Array4pushGiE(pressed_mouse_buttons, button);
        }
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const touches = [];
    const touch_count = _M0FP26mizchi19web__runtime__hooks23js__input__touch__count();
    const _start179 = 0;
    const _end180 = touch_count;
    let _tmp$3 = _start179;
    while (true) {
      const i = _tmp$3;
      if (i < _end180) {
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura4core10TouchPointE(touches, _M0FP36mizchi6kagura4core17new__touch__point(_M0FP26mizchi19web__runtime__hooks24js__input__touch__id__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__x__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__y__at(i)));
        _tmp$3 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const gamepads = [];
    const gamepad_count = _M0FP26mizchi19web__runtime__hooks25js__input__gamepad__count();
    const _start186 = 0;
    const _end187 = gamepad_count;
    let _tmp$4 = _start186;
    while (true) {
      const i = _tmp$4;
      if (i < _end187) {
        const axes = [];
        const axis_count = _M0FP26mizchi19web__runtime__hooks31js__input__gamepad__axis__count(i);
        const _start193 = 0;
        const _end194 = axis_count;
        let _tmp$5 = _start193;
        while (true) {
          const j = _tmp$5;
          if (j < _end194) {
            _M0MP311moonbitlang4core5array5Array4pushGdE(axes, _M0FP26mizchi19web__runtime__hooks28js__input__gamepad__axis__at(i, j));
            _tmp$5 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        const pressed_buttons = [];
        const button_count = _M0FP26mizchi19web__runtime__hooks42js__input__gamepad__pressed__button__count(i);
        const _start200 = 0;
        const _end201 = button_count;
        let _tmp$6 = _start200;
        while (true) {
          const j = _tmp$6;
          if (j < _end201) {
            const button_id = _M0FP26mizchi19web__runtime__hooks39js__input__gamepad__pressed__button__at(i, j);
            if (button_id >= 0) {
              _M0MP311moonbitlang4core5array5Array4pushGiE(pressed_buttons, button_id);
            }
            _tmp$6 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura4core15GamepadSnapshotE(gamepads, _M0FP36mizchi6kagura4core22new__gamepad__snapshot(_M0FP26mizchi19web__runtime__hooks26js__input__gamepad__id__at(i), axes, pressed_buttons));
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
    const _arr = dirty;
    const _len = _arr.length;
    let _tmp = 0;
    while (true) {
      const _i = _tmp;
      if (_i < _len) {
        const image_id = _arr[_i];
        let entry;
        _L: {
          _L$2: {
            const _bind = _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(image_id);
            if (_bind === undefined) {
            } else {
              const _Some = _bind;
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
                _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__pixel(i, _M0MP311moonbitlang4core5array5Array2atGiE(px, base), _M0MP311moonbitlang4core5array5Array2atGiE(px, base + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGiE(px, base + 2 | 0), _M0MP311moonbitlang4core5array5Array2atGiE(px, base + 3 | 0));
                _tmp$2 = i + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            _M0FP26mizchi19web__runtime__hooks29js__gfx__upload__texture__end();
          }
        }
        _tmp = _i + 1 | 0;
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
    if (_M0MP311moonbitlang4core6string6String8contains(_tmp, { str: _bind, start: 0, end: _bind.length })) {
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
          _M0FP26mizchi19web__runtime__hooks36js__gfx__custom__draw__vertex__float(i, _M0MP311moonbitlang4core5array5Array2atGdE(command.vertex_data, i));
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
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MP311moonbitlang4core5array5Array2atGiE(command.indices, i));
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
          _M0FP26mizchi19web__runtime__hooks30js__gfx__custom__draw__uniform(i, _M0MP311moonbitlang4core5array5Array2atGiE(command.uniform_dwords, i));
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
          _M0FP26mizchi19web__runtime__hooks33js__gfx__custom__draw__src__image(i, _M0MP311moonbitlang4core5array5Array2atGiE(command.src_image_ids, i));
          _tmp$5 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0FP26mizchi19web__runtime__hooks18js__gfx__draw__end();
      return;
    } else {
      const src_id = command.src_image_ids.length > 0 ? _M0MP311moonbitlang4core5array5Array2atGiE(command.src_image_ids, 0) : 0;
      const ur = command.uniform_dwords.length > 0 ? _M0MP311moonbitlang4core5array5Array2atGiE(command.uniform_dwords, 0) : 255;
      const ug = command.uniform_dwords.length > 1 ? _M0MP311moonbitlang4core5array5Array2atGiE(command.uniform_dwords, 1) : 255;
      const ub = command.uniform_dwords.length > 2 ? _M0MP311moonbitlang4core5array5Array2atGiE(command.uniform_dwords, 2) : 255;
      const ua = command.uniform_dwords.length > 3 ? _M0MP311moonbitlang4core5array5Array2atGiE(command.uniform_dwords, 3) : 255;
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
          _M0FP26mizchi19web__runtime__hooks21js__gfx__draw__vertex(i, _M0MP311moonbitlang4core5array5Array2atGdE(command.vertex_data, base), _M0MP311moonbitlang4core5array5Array2atGdE(command.vertex_data, base + 1 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(command.vertex_data, base + 2 | 0), _M0MP311moonbitlang4core5array5Array2atGdE(command.vertex_data, base + 3 | 0));
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
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MP311moonbitlang4core5array5Array2atGiE(command.indices, i));
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
  if (!_M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val || _M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGsE(canvas_selector, _M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val)) {
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
function _M0FP26mizchi10hacknslash11make__enemy(cx, cy, kind, hp, speed, size) {
  return { x: cx, y: cy, vx: 0, vy: 0, hp: hp, max_hp: hp, speed: speed, size: size, alive: true, damage_timer: 0, kind: kind, path_cache: [], path_index: 0, path_timer: 0, shoot_cooldown: 0, charge_timer: 0, charge_cooldown: 0 };
}
function _M0FP26mizchi10hacknslash11spawn__boss(rooms, player_room_idx, seed, floor) {
  const enemies = [];
  const rng = _M0FP36mizchi7terrain5types9make__rng((seed >>> 0) + (7777 >>> 0) | 0);
  const best_idx = { val: -1 };
  const best_area = { val: 0 };
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < rooms.length) {
      _L: {
        if (i === player_room_idx) {
          break _L;
        }
        const area = Math.imul(_M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4RoomE(rooms, i).rect.w, _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4RoomE(rooms, i).rect.h) | 0;
        if (area > best_area.val) {
          best_area.val = area;
          best_idx.val = i;
        }
        break _L;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (best_idx.val < 0) {
    best_idx.val = rooms.length > 1 ? 1 : 0;
  }
  const room = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4RoomE(rooms, best_idx.val);
  const cx = (room.rect.x + 0) * _M0FP26mizchi10hacknslash10tile__size + (room.rect.w + 0) / 2 * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
  const cy = (room.rect.y + 0) * _M0FP26mizchi10hacknslash10tile__size + (room.rect.h + 0) / 2 * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
  const boss_hp = 20 + (Math.imul(floor, 2) | 0) | 0;
  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash5EnemyE(enemies, _M0FP26mizchi10hacknslash11make__enemy(cx, cy, _M0FP26mizchi10hacknslash10kind__boss, boss_hp, 0.6, 20));
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < 2) {
      const mx = (room.rect.x + 0) * _M0FP26mizchi10hacknslash10tile__size + (_M0MP36mizchi7terrain5types3RNG11rand__range(rng, 1, room.rect.w - 1 | 0) + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
      const my = (room.rect.y + 0) * _M0FP26mizchi10hacknslash10tile__size + (_M0MP36mizchi7terrain5types3RNG11rand__range(rng, 1, room.rect.h - 1 | 0) + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
      _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash5EnemyE(enemies, _M0FP26mizchi10hacknslash11make__enemy(mx, my, _M0FP26mizchi10hacknslash11kind__basic, 3, _M0FP26mizchi10hacknslash19enemy__speed__basic, 10));
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return enemies;
}
function _M0FP26mizchi10hacknslash25spawn__enemies__in__rooms(rooms, player_room_idx, seed) {
  const enemies = [];
  const rng = _M0FP36mizchi7terrain5types9make__rng((seed >>> 0) + (7777 >>> 0) | 0);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < rooms.length) {
      _L: {
        if (i === player_room_idx) {
          break _L;
        }
        const room = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4RoomE(rooms, i);
        const area = Math.imul(room.rect.w, room.rect.h) | 0;
        if (20 === 0) {
          $panic();
        }
        const count = _M0FP311moonbitlang4core3cmp7minimumGiE(3, _M0FP311moonbitlang4core3cmp7maximumGiE(1, area / 20 | 0));
        let _tmp$2 = 0;
        while (true) {
          const _j = _tmp$2;
          if (_j < count) {
            const cx = (room.rect.x + 0) * _M0FP26mizchi10hacknslash10tile__size + (_M0MP36mizchi7terrain5types3RNG11rand__range(rng, 1, room.rect.w - 1 | 0) + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
            const cy = (room.rect.y + 0) * _M0FP26mizchi10hacknslash10tile__size + (_M0MP36mizchi7terrain5types3RNG11rand__range(rng, 1, room.rect.h - 1 | 0) + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
            const kind_roll = _M0MP36mizchi7terrain5types3RNG9next__int(rng, 10);
            let kind;
            let hp;
            let spd;
            let sz;
            _L$2: {
              if (kind_roll < 4) {
                kind = _M0FP26mizchi10hacknslash11kind__basic;
                hp = 3;
                spd = _M0FP26mizchi10hacknslash19enemy__speed__basic;
                sz = 10;
                break _L$2;
              } else {
                if (kind_roll < 7) {
                  kind = _M0FP26mizchi10hacknslash10kind__fast;
                  hp = 2;
                  spd = _M0FP26mizchi10hacknslash18enemy__speed__fast;
                  sz = 8;
                  break _L$2;
                } else {
                  if (kind_roll < 9) {
                    kind = _M0FP26mizchi10hacknslash10kind__tank;
                    hp = 8;
                    spd = _M0FP26mizchi10hacknslash18enemy__speed__tank;
                    sz = 14;
                    break _L$2;
                  } else {
                    kind = _M0FP26mizchi10hacknslash12kind__ranged;
                    hp = 2;
                    spd = 0.5;
                    sz = 8;
                    break _L$2;
                  }
                }
              }
            }
            _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash5EnemyE(enemies, _M0FP26mizchi10hacknslash11make__enemy(cx, cy, kind, hp, spd, sz));
            _tmp$2 = _j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        break _L;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return enemies;
}
function _M0FP26mizchi10hacknslash26spawn__enemies__for__floor(rooms, player_room_idx, seed, floor) {
  let _tmp;
  if (floor > 1) {
    if (5 === 0) {
      $panic();
    }
    _tmp = (floor % 5 | 0) === 0;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    return _M0FP26mizchi10hacknslash11spawn__boss(rooms, player_room_idx, seed, floor);
  }
  return _M0FP26mizchi10hacknslash25spawn__enemies__in__rooms(rooms, player_room_idx, seed);
}
function _M0FP26mizchi10hacknslash17generate__dungeon(seed) {
  const rng = _M0FP36mizchi7terrain5types9make__rng(seed);
  const config = { width: _M0FP26mizchi10hacknslash9map__cols, height: _M0FP26mizchi10hacknslash9map__rows, min_room_size: 4, max_depth: 5 };
  const result = _M0FP36mizchi7terrain3bsp8generate(config, rng);
  const start_room = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types4RoomE(result.rooms, 0);
  const center = _M0MP36mizchi7terrain5types4Rect6center(start_room.rect);
  return { grid: result.grid, rooms: result.rooms, start_x: (center.x + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2, start_y: (center.y + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2 };
}
function _M0MP26mizchi10hacknslash9GameState3new(seed) {
  const dungeon = _M0FP26mizchi10hacknslash17generate__dungeon(seed);
  const player = { x: dungeon.start_x, y: dungeon.start_y, hp: 10, max_hp: 10, size: 12, damage_timer: 0, iframe_timer: 0, facing_angle: 1.5708, dash_timer: 0, dash_cooldown_timer: 0, dash_vx: 0, dash_vy: 0 };
  const camera = _M0MP36mizchi6kagura8camera2d8Camera2D3new(_M0FP26mizchi10hacknslash9screen__w + 0, _M0FP26mizchi10hacknslash9screen__h + 0, _M0FP26mizchi10hacknslash8world__w, _M0FP26mizchi10hacknslash8world__h);
  _M0MP36mizchi6kagura8camera2d8Camera2D14follow__target(camera, player.x, player.y);
  const enemies = _M0FP26mizchi10hacknslash25spawn__enemies__in__rooms(dungeon.rooms, 0, seed);
  return { mode: _M0FP26mizchi10hacknslash11mode__title, frame_count: 0, seed: seed, floor: 1, score: 0, player: player, enemies: enemies, items: [], projectiles: [], dungeon: dungeon, camera: camera, input: _M0FP36mizchi6kagura9inpututil18new__input__helper(), attack_timer: 0, screen_flash: 0, floor_announce_timer: 0 };
}
function _M0MP26mizchi10hacknslash9GameState16update__gameover(self) {
  if (_M0FP36mizchi6kagura9inpututil26is__confirm__just__pressed(self.input)) {
    self.mode = _M0FP26mizchi10hacknslash11mode__title;
    self.floor = 1;
    self.score = 0;
    self.seed = 42;
    const dungeon = _M0FP26mizchi10hacknslash17generate__dungeon(self.seed);
    self.dungeon.grid = dungeon.grid;
    _M0MP311moonbitlang4core5array5Array5clearGRP36mizchi7terrain5types4RoomE(self.dungeon.rooms);
    const _arr = dungeon.rooms;
    const _len = _arr.length;
    let _tmp = 0;
    while (true) {
      const _i = _tmp;
      if (_i < _len) {
        const room = _arr[_i];
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7terrain5types4RoomE(self.dungeon.rooms, room);
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    self.dungeon.start_x = dungeon.start_x;
    self.dungeon.start_y = dungeon.start_y;
    self.player.x = dungeon.start_x;
    self.player.y = dungeon.start_y;
    self.player.hp = self.player.max_hp;
    self.player.damage_timer = 0;
    self.player.iframe_timer = 0;
    self.enemies = _M0FP26mizchi10hacknslash26spawn__enemies__for__floor(dungeon.rooms, 0, self.seed, 1);
    self.items = [];
    self.projectiles = [];
    self.floor_announce_timer = 0;
    self.player.dash_timer = 0;
    self.player.dash_cooldown_timer = 0;
    _M0MP36mizchi6kagura8camera2d8Camera2D14follow__target(self.camera, self.player.x, self.player.y);
    return;
  } else {
    return;
  }
}
function _M0FP26mizchi10hacknslash22check__wall__collision(grid, x, y, size) {
  const half = size / 2;
  const left_col = _M0MP311moonbitlang4core6double6Double7to__int((x - half) / _M0FP26mizchi10hacknslash10tile__size);
  const right_col = _M0MP311moonbitlang4core6double6Double7to__int((x + half) / _M0FP26mizchi10hacknslash10tile__size);
  const top_row = _M0MP311moonbitlang4core6double6Double7to__int((y - half) / _M0FP26mizchi10hacknslash10tile__size);
  const bottom_row = _M0MP311moonbitlang4core6double6Double7to__int((y + half) / _M0FP26mizchi10hacknslash10tile__size);
  let _tmp = top_row;
  while (true) {
    const row = _tmp;
    if (row <= bottom_row) {
      let _tmp$2 = left_col;
      while (true) {
        const col = _tmp$2;
        if (col <= right_col) {
          if (col < 0 || (col >= grid.width || (row < 0 || row >= grid.height))) {
            return true;
          }
          if (_M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(_M0MP36mizchi7terrain5types6Grid2D3get(grid, col, row), 1)) {
            return true;
          }
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
  return false;
}
function _M0FP26mizchi10hacknslash12is__wall__at(grid, x, y) {
  const col = _M0MP311moonbitlang4core6double6Double7to__int(x / _M0FP26mizchi10hacknslash10tile__size);
  const row = _M0MP311moonbitlang4core6double6Double7to__int(y / _M0FP26mizchi10hacknslash10tile__size);
  if (col < 0 || (col >= grid.width || (row < 0 || row >= grid.height))) {
    return true;
  }
  return _M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(_M0MP36mizchi7terrain5types6Grid2D3get(grid, col, row), 1);
}
function _M0FP26mizchi10hacknslash11try__attack(state) {
  const facing = state.player.facing_angle;
  const _arr = state.enemies;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const enemy = _arr[_i];
      if (enemy.alive) {
        const edx = enemy.x - state.player.x;
        const edy = enemy.y - state.player.y;
        const dist = Math.sqrt(edx * edx + edy * edy);
        if (dist < _M0FP26mizchi10hacknslash13attack__range) {
          const enemy_angle = _M0FP311moonbitlang4core4math5atan2(edy, edx);
          const angle_diff = { val: enemy_angle - facing };
          while (true) {
            if (angle_diff.val > 3.14159) {
              angle_diff.val = angle_diff.val - 6.28318;
              continue;
            } else {
              break;
            }
          }
          while (true) {
            if (angle_diff.val < -3.14159) {
              angle_diff.val = angle_diff.val + 6.28318;
              continue;
            } else {
              break;
            }
          }
          if (Math.abs(angle_diff.val) < 1.0472) {
            enemy.hp = enemy.hp - 1 | 0;
            enemy.damage_timer = _M0FP26mizchi10hacknslash23damage__flash__duration;
            if (dist > 0.001) {
              enemy.vx = enemy.vx + edx / dist * _M0FP26mizchi10hacknslash19knockback__strength;
              enemy.vy = enemy.vy + edy / dist * _M0FP26mizchi10hacknslash19knockback__strength;
            }
            if (enemy.hp <= 0) {
              enemy.alive = false;
              const kill_score = enemy.kind === _M0FP26mizchi10hacknslash10kind__boss ? 100 : 10;
              state.score = state.score + kill_score | 0;
              if (100 === 0) {
                $panic();
              }
              const drop_roll = (((Math.imul(state.frame_count, 7) | 0) + (Math.imul(_M0MP311moonbitlang4core6double6Double7to__int(enemy.x), 13) | 0) | 0) + (Math.imul(_M0MP311moonbitlang4core6double6Double7to__int(enemy.y), 17) | 0) | 0) % 100 | 0;
              if (drop_roll < 50) {
                _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash8ItemDropE(state.items, { x: enemy.x, y: enemy.y, kind: _M0FP26mizchi10hacknslash12item__health, alive: true, spawn_frame: state.frame_count });
              } else {
                if (drop_roll < 80) {
                  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash8ItemDropE(state.items, { x: enemy.x, y: enemy.y, kind: _M0FP26mizchi10hacknslash11item__score, alive: true, spawn_frame: state.frame_count });
                }
              }
            }
          }
        }
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP26mizchi10hacknslash17update__enemy__ai(enemies, player, grid, frame_count, projectiles) {
  const player_tile_x = _M0MP311moonbitlang4core6double6Double7to__int(player.x / _M0FP26mizchi10hacknslash10tile__size);
  const player_tile_y = _M0MP311moonbitlang4core6double6Double7to__int(player.y / _M0FP26mizchi10hacknslash10tile__size);
  const _arr = enemies;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      _L: {
        const enemy = _arr[_i];
        if (!enemy.alive) {
          break _L;
        }
        const cdx = player.x - enemy.x;
        const cdy = player.y - enemy.y;
        const dist = Math.sqrt(cdx * cdx + cdy * cdy);
        if (enemy.kind === _M0FP26mizchi10hacknslash10kind__boss) {
          if (enemy.charge_timer > 0) {
            enemy.charge_timer = enemy.charge_timer - 1 | 0;
            break _L;
          }
          if (dist < _M0FP26mizchi10hacknslash12chase__range && enemy.charge_cooldown <= 0) {
            enemy.charge_cooldown = 120;
            enemy.charge_timer = 20;
            if (dist > 0.001) {
              enemy.vx = cdx / dist * enemy.speed * 3;
              enemy.vy = cdy / dist * enemy.speed * 3;
            }
            break _L;
          }
          if (enemy.charge_cooldown > 0) {
            enemy.charge_cooldown = enemy.charge_cooldown - 1 | 0;
          }
        }
        if (dist > _M0FP26mizchi10hacknslash12chase__range) {
          if (360 === 0) {
            $panic();
          }
          const angle = (((frame_count + _M0MP311moonbitlang4core6double6Double7to__int(enemy.x) | 0) % 360 | 0) + 0) * 3.14159 / 180;
          enemy.vx = _M0FP311moonbitlang4core4math3cos(angle) * enemy.speed * 0.3;
          enemy.vy = _M0FP311moonbitlang4core4math3sin(angle) * enemy.speed * 0.3;
          break _L;
        }
        if (enemy.kind === _M0FP26mizchi10hacknslash12kind__ranged && dist > 60) {
          if (enemy.shoot_cooldown <= 0) {
            enemy.shoot_cooldown = 120;
            if (dist > 0.001) {
              const bspeed = 2;
              _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi10hacknslash10ProjectileE(projectiles, { x: enemy.x, y: enemy.y, vx: cdx / dist * bspeed, vy: cdy / dist * bspeed, alive: true, damage: 1 });
            }
          }
          if (dist > 0.001) {
            enemy.vx = -(cdx / dist) * enemy.speed * 0.3;
            enemy.vy = -(cdy / dist) * enemy.speed * 0.3;
          }
          if (enemy.shoot_cooldown > 0) {
            enemy.shoot_cooldown = enemy.shoot_cooldown - 1 | 0;
          }
          break _L;
        }
        if (enemy.shoot_cooldown > 0) {
          enemy.shoot_cooldown = enemy.shoot_cooldown - 1 | 0;
        }
        if (enemy.path_timer <= 0) {
          enemy.path_timer = _M0FP26mizchi10hacknslash22path__update__interval;
          const enemy_tile_x = _M0MP311moonbitlang4core6double6Double7to__int(enemy.x / _M0FP26mizchi10hacknslash10tile__size);
          const enemy_tile_y = _M0MP311moonbitlang4core6double6Double7to__int(enemy.y / _M0FP26mizchi10hacknslash10tile__size);
          const start = { x: enemy_tile_x, y: enemy_tile_y };
          const goal = { x: player_tile_x, y: player_tile_y };
          let path;
          _L$2: {
            _L$3: {
              const _bind = _M0FP36mizchi6kagura8pathfind10find__path(grid, start, goal, undefined);
              if (_bind.$tag === 1) {
                const _Some = _bind;
                const _path = _Some._0;
                path = _path;
                break _L$3;
              } else {
                enemy.path_cache = [];
                enemy.path_index = 0;
              }
              break _L$2;
            }
            enemy.path_cache = path;
            enemy.path_index = 1;
          }
        } else {
          enemy.path_timer = enemy.path_timer - 1 | 0;
        }
        if (enemy.path_cache.length > 0 && enemy.path_index < enemy.path_cache.length) {
          const target = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi7terrain5types5PointE(enemy.path_cache, enemy.path_index);
          const tx = (target.x + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
          const ty = (target.y + 0) * _M0FP26mizchi10hacknslash10tile__size + _M0FP26mizchi10hacknslash10tile__size / 2;
          const pdx = tx - enemy.x;
          const pdy = ty - enemy.y;
          const pdist = Math.sqrt(pdx * pdx + pdy * pdy);
          if (pdist < _M0FP26mizchi10hacknslash10tile__size / 2) {
            enemy.path_index = enemy.path_index + 1 | 0;
          }
          if (pdist > 0.001) {
            enemy.vx = pdx / pdist * enemy.speed;
            enemy.vy = pdy / pdist * enemy.speed;
          }
        } else {
          if (dist > 1) {
            enemy.vx = cdx / dist * enemy.speed;
            enemy.vy = cdy / dist * enemy.speed;
          }
        }
        break _L;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0MP26mizchi10hacknslash9GameState12reset__floor(self) {
  self.seed = self.seed + 1 | 0;
  const dungeon = _M0FP26mizchi10hacknslash17generate__dungeon(self.seed);
  self.dungeon.grid = dungeon.grid;
  _M0MP311moonbitlang4core5array5Array5clearGRP36mizchi7terrain5types4RoomE(self.dungeon.rooms);
  const _arr = dungeon.rooms;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const room = _arr[_i];
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7terrain5types4RoomE(self.dungeon.rooms, room);
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  self.dungeon.start_x = dungeon.start_x;
  self.dungeon.start_y = dungeon.start_y;
  self.player.x = dungeon.start_x;
  self.player.y = dungeon.start_y;
  self.floor = self.floor + 1 | 0;
  self.enemies = _M0FP26mizchi10hacknslash26spawn__enemies__for__floor(dungeon.rooms, 0, self.seed, self.floor);
  self.items = [];
  self.projectiles = [];
  self.floor_announce_timer = 120;
  _M0MP36mizchi6kagura8camera2d8Camera2D14follow__target(self.camera, self.player.x, self.player.y);
}
function _M0MP26mizchi10hacknslash9GameState15update__playing(self) {
  if (self.floor_announce_timer > 0) {
    self.floor_announce_timer = self.floor_announce_timer - 1 | 0;
  }
  const dx = { val: 0 };
  const dy = { val: 0 };
  if (_M0FP36mizchi6kagura9inpututil12is__move__up(self.input.key_state)) {
    dy.val = dy.val - 1;
  }
  if (_M0FP36mizchi6kagura9inpututil14is__move__down(self.input.key_state)) {
    dy.val = dy.val + 1;
  }
  if (_M0FP36mizchi6kagura9inpututil14is__move__left(self.input.key_state)) {
    dx.val = dx.val - 1;
  }
  if (_M0FP36mizchi6kagura9inpututil15is__move__right(self.input.key_state)) {
    dx.val = dx.val + 1;
  }
  if (dx.val !== 0 && dy.val !== 0) {
    const v = _M0MP36mizchi6kagura6vector4Vec29normalize(_M0MP36mizchi6kagura6vector4Vec23new(dx.val, dy.val));
    dx.val = v.x;
    dy.val = v.y;
  }
  if (dx.val !== 0 || dy.val !== 0) {
    self.player.facing_angle = _M0FP311moonbitlang4core4math5atan2(dy.val, dx.val);
  }
  if (self.player.dash_cooldown_timer > 0) {
    self.player.dash_cooldown_timer = self.player.dash_cooldown_timer - 1 | 0;
  }
  if (self.player.dash_timer > 0) {
    self.player.dash_timer = self.player.dash_timer - 1 | 0;
    const next_x = self.player.x + self.player.dash_vx;
    const next_y = self.player.y + self.player.dash_vy;
    if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, next_x, self.player.y, self.player.size)) {
      self.player.x = next_x;
    }
    if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, self.player.x, next_y, self.player.size)) {
      self.player.y = next_y;
    }
  } else {
    const shift_pressed = _M0FP36mizchi6kagura9inpututil22is__key__just__pressed(self.input.key_state, 16);
    if (shift_pressed && (self.player.dash_cooldown_timer <= 0 && (dx.val !== 0 || dy.val !== 0))) {
      self.player.dash_timer = _M0FP26mizchi10hacknslash14dash__duration;
      self.player.dash_cooldown_timer = _M0FP26mizchi10hacknslash14dash__cooldown;
      self.player.dash_vx = dx.val * _M0FP26mizchi10hacknslash13player__speed * _M0FP26mizchi10hacknslash17dash__speed__mult;
      self.player.dash_vy = dy.val * _M0FP26mizchi10hacknslash13player__speed * _M0FP26mizchi10hacknslash17dash__speed__mult;
      self.player.iframe_timer = _M0FP26mizchi10hacknslash14dash__duration;
    } else {
      const next_x = self.player.x + dx.val * _M0FP26mizchi10hacknslash13player__speed;
      const next_y = self.player.y + dy.val * _M0FP26mizchi10hacknslash13player__speed;
      if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, next_x, self.player.y, self.player.size)) {
        self.player.x = next_x;
      }
      if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, self.player.x, next_y, self.player.size)) {
        self.player.y = next_y;
      }
    }
  }
  const half = self.player.size / 2;
  self.player.x = _M0FP311moonbitlang4core3cmp7maximumGdE(half, _M0FP311moonbitlang4core3cmp7minimumGdE(_M0FP26mizchi10hacknslash8world__w - half, self.player.x));
  self.player.y = _M0FP311moonbitlang4core3cmp7maximumGdE(half, _M0FP311moonbitlang4core3cmp7minimumGdE(_M0FP26mizchi10hacknslash8world__h - half, self.player.y));
  _M0MP36mizchi6kagura8camera2d8Camera2D14follow__target(self.camera, self.player.x, self.player.y);
  if (self.attack_timer > 0) {
    self.attack_timer = self.attack_timer - 1 | 0;
  }
  if (_M0FP36mizchi6kagura9inpututil26is__confirm__just__pressed(self.input) && self.attack_timer <= 0) {
    self.attack_timer = _M0FP26mizchi10hacknslash16attack__cooldown;
    self.screen_flash = 2;
    _M0FP26mizchi10hacknslash11try__attack(self);
  }
  _M0FP26mizchi10hacknslash17update__enemy__ai(self.enemies, self.player, self.dungeon.grid, self.frame_count, self.projectiles);
  const _arr = self.enemies;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const enemy = _arr[_i];
      if (enemy.alive) {
        const enx = enemy.x + enemy.vx;
        const eny = enemy.y + enemy.vy;
        if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, enx, enemy.y, enemy.size)) {
          enemy.x = enx;
        }
        if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, enemy.x, eny, enemy.size)) {
          enemy.y = eny;
        }
        enemy.vx = 0;
        enemy.vy = 0;
        if (self.player.iframe_timer <= 0) {
          if (_M0FP36mizchi6kagura6vector21aabb__overlap__center(self.player.x, self.player.y, self.player.size / 2, self.player.size / 2, enemy.x, enemy.y, enemy.size / 2, enemy.size / 2)) {
            self.player.hp = self.player.hp - 1 | 0;
            self.player.damage_timer = _M0FP26mizchi10hacknslash23damage__flash__duration;
            self.player.iframe_timer = _M0FP26mizchi10hacknslash16iframe__duration;
            self.screen_flash = 3;
            if (self.player.hp <= 0) {
              self.mode = _M0FP26mizchi10hacknslash14mode__gameover;
            }
          }
        }
      }
      if (enemy.damage_timer > 0) {
        enemy.damage_timer = enemy.damage_timer - 1 | 0;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const pi = { val: 0 };
  while (true) {
    if (pi.val < self.projectiles.length) {
      const proj = _M0MP311moonbitlang4core5array5Array2atGRP26mizchi10hacknslash10ProjectileE(self.projectiles, pi.val);
      if (proj.alive) {
        proj.x = proj.x + proj.vx;
        proj.y = proj.y + proj.vy;
        if (_M0FP26mizchi10hacknslash12is__wall__at(self.dungeon.grid, proj.x, proj.y)) {
          proj.alive = false;
        }
        if (proj.alive && self.player.iframe_timer <= 0) {
          const pdx = proj.x - self.player.x;
          const pdy = proj.y - self.player.y;
          if (pdx * pdx + pdy * pdy < 64) {
            self.player.hp = self.player.hp - proj.damage | 0;
            self.player.damage_timer = _M0FP26mizchi10hacknslash23damage__flash__duration;
            self.player.iframe_timer = _M0FP26mizchi10hacknslash16iframe__duration;
            self.screen_flash = 3;
            proj.alive = false;
            if (self.player.hp <= 0) {
              self.mode = _M0FP26mizchi10hacknslash14mode__gameover;
            }
          }
        }
      }
      pi.val = pi.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  self.projectiles = _M0MP311moonbitlang4core5array5Array6filterGRP26mizchi10hacknslash10ProjectileE(self.projectiles, (p) => p.alive);
  const _arr$2 = self.items;
  const _len$2 = _arr$2.length;
  let _tmp$2 = 0;
  while (true) {
    const _i = _tmp$2;
    if (_i < _len$2) {
      _L: {
        const item = _arr$2[_i];
        if (item.alive) {
          if ((self.frame_count - item.spawn_frame | 0) > 600) {
            item.alive = false;
            break _L;
          }
          const idx = item.x - self.player.x;
          const idy = item.y - self.player.y;
          if (idx * idx + idy * idy < 64) {
            item.alive = false;
            if (item.kind === _M0FP26mizchi10hacknslash12item__health) {
              self.player.hp = _M0FP311moonbitlang4core3cmp7minimumGiE(self.player.max_hp, self.player.hp + 2 | 0);
            } else {
              self.score = self.score + 5 | 0;
            }
          }
        }
        break _L;
      }
      _tmp$2 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  self.items = _M0MP311moonbitlang4core5array5Array6filterGRP26mizchi10hacknslash8ItemDropE(self.items, (it) => it.alive);
  const _arr$3 = self.enemies;
  const _len$3 = _arr$3.length;
  let _tmp$3 = 0;
  while (true) {
    const _i = _tmp$3;
    if (_i < _len$3) {
      const enemy = _arr$3[_i];
      if (enemy.alive) {
        const sep_dx = self.player.x - enemy.x;
        const sep_dy = self.player.y - enemy.y;
        const sep_dist = Math.sqrt(sep_dx * sep_dx + sep_dy * sep_dy);
        const min_dist = (self.player.size + enemy.size) / 2;
        if (sep_dist < min_dist && sep_dist > 0.001) {
          const push = (min_dist - sep_dist) / 2;
          const nx = sep_dx / sep_dist;
          const ny = sep_dy / sep_dist;
          const px_new = self.player.x + nx * push;
          const py_new = self.player.y + ny * push;
          if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, px_new, self.player.y, self.player.size)) {
            self.player.x = px_new;
          } else {
            enemy.x = enemy.x - nx * push;
          }
          if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, self.player.x, py_new, self.player.size)) {
            self.player.y = py_new;
          } else {
            enemy.y = enemy.y - ny * push;
          }
          const ex_new = enemy.x - nx * push;
          const ey_new = enemy.y - ny * push;
          if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, ex_new, enemy.y, enemy.size)) {
            enemy.x = ex_new;
          }
          if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, enemy.x, ey_new, enemy.size)) {
            enemy.y = ey_new;
          }
        }
      }
      _tmp$3 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$4 = 0;
  while (true) {
    const i = _tmp$4;
    if (i < self.enemies.length) {
      let _tmp$5 = i + 1 | 0;
      while (true) {
        const j = _tmp$5;
        if (j < self.enemies.length) {
          const a = _M0MP311moonbitlang4core5array5Array2atGRP26mizchi10hacknslash5EnemyE(self.enemies, i);
          const b = _M0MP311moonbitlang4core5array5Array2atGRP26mizchi10hacknslash5EnemyE(self.enemies, j);
          if (a.alive && b.alive) {
            const sep_dx = a.x - b.x;
            const sep_dy = a.y - b.y;
            const sep_dist = Math.sqrt(sep_dx * sep_dx + sep_dy * sep_dy);
            const min_dist = (a.size + b.size) / 2;
            if (sep_dist < min_dist && sep_dist > 0.001) {
              const push = (min_dist - sep_dist) / 2;
              const nx = sep_dx / sep_dist;
              const ny = sep_dy / sep_dist;
              const ax_new = a.x + nx * push;
              const ay_new = a.y + ny * push;
              if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, ax_new, a.y, a.size)) {
                a.x = ax_new;
              }
              if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, a.x, ay_new, a.size)) {
                a.y = ay_new;
              }
              const bx_new = b.x - nx * push;
              const by_new = b.y - ny * push;
              if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, bx_new, b.y, b.size)) {
                b.x = bx_new;
              }
              if (!_M0FP26mizchi10hacknslash22check__wall__collision(self.dungeon.grid, b.x, by_new, b.size)) {
                b.y = by_new;
              }
            }
          }
          _tmp$5 = j + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$4 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (self.player.damage_timer > 0) {
    self.player.damage_timer = self.player.damage_timer - 1 | 0;
  }
  if (self.player.iframe_timer > 0) {
    self.player.iframe_timer = self.player.iframe_timer - 1 | 0;
  }
  if (self.screen_flash > 0) {
    self.screen_flash = self.screen_flash - 1 | 0;
  }
  const all_dead = { val: true };
  const _arr$4 = self.enemies;
  const _len$4 = _arr$4.length;
  let _tmp$5 = 0;
  while (true) {
    const _i = _tmp$5;
    if (_i < _len$4) {
      const enemy = _arr$4[_i];
      if (enemy.alive) {
        all_dead.val = false;
        break;
      }
      _tmp$5 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (all_dead.val) {
    _M0MP26mizchi10hacknslash9GameState12reset__floor(self);
    return;
  } else {
    return;
  }
}
function _M0MP26mizchi10hacknslash9GameState13update__title(self) {
  if (_M0FP36mizchi6kagura9inpututil26is__confirm__just__pressed(self.input)) {
    self.mode = _M0FP26mizchi10hacknslash13mode__playing;
    return;
  } else {
    return;
  }
}
function _M0MP26mizchi10hacknslash9GameState6update(self, input) {
  self.frame_count = self.frame_count + 1 | 0;
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, input);
  let m;
  _L: {
    let m$2;
    _L$2: {
      let m$3;
      _L$3: {
        const _bind = self.mode;
        if (_bind === _M0FP26mizchi10hacknslash11mode__title) {
          m$3 = _bind;
          break _L$3;
        } else {
          if (_bind === _M0FP26mizchi10hacknslash13mode__playing) {
            m$2 = _bind;
            break _L$2;
          } else {
            if (_bind === _M0FP26mizchi10hacknslash14mode__gameover) {
              m = _bind;
              break _L;
            } else {
              return;
            }
          }
        }
      }
      _M0MP26mizchi10hacknslash9GameState13update__title(self);
      return;
    }
    _M0MP26mizchi10hacknslash9GameState15update__playing(self);
    return;
  }
  _M0MP26mizchi10hacknslash9GameState16update__gameover(self);
}
function _M0MP26mizchi10hacknslash9GameState14view__gameover(self) {
  return _M0FP36mizchi6kagura5scene8fragment([_M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, _M0FP26mizchi10hacknslash9screen__w + 0, _M0FP26mizchi10hacknslash9screen__h + 0, 3014656, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene13label_2einner((_M0FP26mizchi10hacknslash9screen__w + 0) / 2, (_M0FP26mizchi10hacknslash9screen__h + 0) / 2 - 30, "GAME OVER", 16711680, 2), _M0FP36mizchi6kagura5scene13label_2einner((_M0FP26mizchi10hacknslash9screen__w + 0) / 2, (_M0FP26mizchi10hacknslash9screen__h + 0) / 2 + 5, `FLOOR ${_M0MP311moonbitlang4core3int3Int18to__string_2einner(self.floor, 10)}`, 16763904, 1), _M0FP36mizchi6kagura5scene13label_2einner((_M0FP26mizchi10hacknslash9screen__w + 0) / 2, (_M0FP26mizchi10hacknslash9screen__h + 0) / 2 + 25, `SCORE ${_M0MP311moonbitlang4core3int3Int18to__string_2einner(self.score, 10)}`, 16777215, 1.5), _M0FP36mizchi6kagura5scene4show(() => {
    if (30 === 0) {
      $panic();
    }
    if (2 === 0) {
      $panic();
    }
    return ((self.frame_count / 30 | 0) % 2 | 0) === 0;
  }, () => _M0FP36mizchi6kagura5scene13label_2einner((_M0FP26mizchi10hacknslash9screen__w + 0) / 2, (_M0FP26mizchi10hacknslash9screen__h + 0) / 2 + 55, "PRESS SPACE", 8947848, 1))]);
}
function _M0FP26mizchi10hacknslash15render__minimap(state) {
  const sw = _M0FP26mizchi10hacknslash9screen__w + 0;
  const sh = _M0FP26mizchi10hacknslash9screen__h + 0;
  const mm_w = 60;
  const mm_h = 45;
  const mm_x = sw - mm_w - 4;
  const mm_y = sh - mm_h - 4;
  const scale_x = mm_w / (_M0FP26mizchi10hacknslash9map__cols + 0);
  const scale_y = mm_h / (_M0FP26mizchi10hacknslash9map__rows + 0);
  const _tmp = _M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, mm_w, mm_h, 0, new Option$Some$8$(0.5), Option$None$9$);
  const _tmp$2 = _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    let _tmp$3 = 0;
    while (true) {
      const row = _tmp$3;
      if (row < _M0FP26mizchi10hacknslash9map__rows) {
        let _tmp$4 = 0;
        while (true) {
          const col = _tmp$4;
          if (col < _M0FP26mizchi10hacknslash9map__cols) {
            const tile = _M0MP36mizchi7terrain5types6Grid2D3get(state.dungeon.grid, col, row);
            if (_M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(tile, 0) || (_M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(tile, 7) || _M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(tile, 2))) {
              const tx = (col + 0) * scale_x;
              const ty = (row + 0) * scale_y;
              _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(tx), new Option$Some$8$(ty), scale_x * 2, scale_y * 2, 4473941, new Option$Some$8$(0.6), Option$None$9$));
            }
            _tmp$4 = col + 2 | 0;
            continue;
          } else {
            break;
          }
        }
        _tmp$3 = row + 2 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  });
  const _tmp$3 = _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const _arr = state.items;
    const _len = _arr.length;
    let _tmp$4 = 0;
    while (true) {
      const _i = _tmp$4;
      if (_i < _len) {
        const item = _arr[_i];
        if (item.alive) {
          const ix = item.x / _M0FP26mizchi10hacknslash10tile__size * scale_x;
          const iy = item.y / _M0FP26mizchi10hacknslash10tile__size * scale_y;
          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(ix), new Option$Some$8$(iy), 1, 1, 16776960, Option$None$8$, Option$None$9$));
        }
        _tmp$4 = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  });
  const _tmp$4 = _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const _arr = state.enemies;
    const _len = _arr.length;
    let _tmp$5 = 0;
    while (true) {
      const _i = _tmp$5;
      if (_i < _len) {
        const enemy = _arr[_i];
        if (enemy.alive) {
          const ex = enemy.x / _M0FP26mizchi10hacknslash10tile__size * scale_x;
          const ey = enemy.y / _M0FP26mizchi10hacknslash10tile__size * scale_y;
          const color = enemy.kind === _M0FP26mizchi10hacknslash10kind__boss ? 16720486 : 13378082;
          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(ex), new Option$Some$8$(ey), 1, 1, color, Option$None$8$, Option$None$9$));
        }
        _tmp$5 = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  });
  const ppx = state.player.x / _M0FP26mizchi10hacknslash10tile__size * scale_x;
  const ppy = state.player.y / _M0FP26mizchi10hacknslash10tile__size * scale_y;
  return _M0FP36mizchi6kagura5scene13group_2einner(mm_x, mm_y, [_tmp, _tmp$2, _tmp$3, _tmp$4, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(ppx - 1), new Option$Some$8$(ppy - 1), 2, 2, 65382, Option$None$8$, Option$None$9$)]);
}
function _M0FP26mizchi10hacknslash11render__hud(state) {
  const sw = _M0FP26mizchi10hacknslash9screen__w + 0;
  const hp_ratio = (state.player.hp + 0) / (state.player.max_hp + 0);
  const hp_width = 60 * hp_ratio;
  const hp_color = hp_ratio > 0.5 ? 52224 : hp_ratio > 0.25 ? 13412864 : 13369344;
  const alive_count = { val: 0 };
  const _arr = state.enemies;
  const _len = _arr.length;
  let _tmp = 0;
  while (true) {
    const _i = _tmp;
    if (_i < _len) {
      const enemy = _arr[_i];
      if (enemy.alive) {
        alive_count.val = alive_count.val + 1 | 0;
      }
      _tmp = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi6kagura5scene13group_2einner(0, 0, [_M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(4), new Option$Some$8$(4), 62, 8, 4456448, new Option$Some$8$(0.8), Option$None$9$), _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(5), new Option$Some$8$(5), hp_width, 6, hp_color, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene13label_2einner(36, 8, "HP", 16777215, 0.5), _M0FP36mizchi6kagura5scene13label_2einner(sw / 2, 8, `FLOOR ${_M0MP311moonbitlang4core3int3Int18to__string_2einner(state.floor, 10)}`, 13421772, 0.7), _M0FP36mizchi6kagura5scene13label_2einner(sw - 40, 8, _M0MP311moonbitlang4core3int3Int18to__string_2einner(state.score, 10), 16763904, 0.8), _M0FP36mizchi6kagura5scene13label_2einner(sw - 40, 20, `x${_M0MP311moonbitlang4core3int3Int18to__string_2einner(alive_count.val, 10)}`, 13378082, 0.6), _M0FP36mizchi6kagura5scene4show(() => state.player.dash_cooldown_timer > 0, () => {
    const cd_ratio = (state.player.dash_cooldown_timer + 0) / (_M0FP26mizchi10hacknslash14dash__cooldown + 0);
    return _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(5), new Option$Some$8$(14), 60 * (1 - cd_ratio), 2, 6741503, new Option$Some$8$(0.6), Option$None$9$);
  }), _M0FP26mizchi10hacknslash15render__minimap(state)]);
}
function _M0FP26mizchi10hacknslash19tile__color__varied(tile, col, row) {
  switch (tile) {
    case 0: {
      if (2 === 0) {
        $panic();
      }
      const checker = (col + row | 0) % 2 | 0;
      return checker === 0 ? 2763322 : 3026494;
    }
    case 1: {
      let brick_offset;
      if (2 === 0) {
        $panic();
      }
      if ((row % 2 | 0) === 0) {
        brick_offset = 0;
      } else {
        brick_offset = 2;
      }
      if (4 === 0) {
        $panic();
      }
      const brick_pos = (col + brick_offset | 0) % 4 | 0;
      return brick_pos === 0 ? 5976598 : 7029286;
    }
    case 7: {
      if (3 === 0) {
        $panic();
      }
      const stripe = (col + row | 0) % 3 | 0;
      return stripe === 0 ? 2960702 : 3355460;
    }
    case 2: {
      return 9136404;
    }
    default: {
      return 1710638;
    }
  }
}
function _M0MP26mizchi10hacknslash9GameState13view__playing(self) {
  const sw = _M0FP26mizchi10hacknslash9screen__w + 0;
  const sh = _M0FP26mizchi10hacknslash9screen__h + 0;
  const view_left = self.camera.x;
  const view_top = self.camera.y;
  const px = self.player.x - view_left;
  const py = self.player.y - view_top;
  const phs = self.player.size / 2;
  const player_fill = self.player.dash_timer > 0 ? 6741503 : self.player.damage_timer > 0 ? 16777215 : 65484;
  return _M0FP36mizchi6kagura5scene8fragment([_M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, sw, sh, 1710638, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const start_col = _M0FP311moonbitlang4core3cmp7maximumGiE(0, _M0MP311moonbitlang4core6double6Double7to__int(view_left / _M0FP26mizchi10hacknslash10tile__size));
    const end_col = _M0FP311moonbitlang4core3cmp7minimumGiE(_M0FP26mizchi10hacknslash9map__cols, _M0MP311moonbitlang4core6double6Double7to__int((view_left + sw) / _M0FP26mizchi10hacknslash10tile__size) + 1 | 0);
    const start_row = _M0FP311moonbitlang4core3cmp7maximumGiE(0, _M0MP311moonbitlang4core6double6Double7to__int(view_top / _M0FP26mizchi10hacknslash10tile__size));
    const end_row = _M0FP311moonbitlang4core3cmp7minimumGiE(_M0FP26mizchi10hacknslash9map__rows, _M0MP311moonbitlang4core6double6Double7to__int((view_top + sh) / _M0FP26mizchi10hacknslash10tile__size) + 1 | 0);
    let _tmp = start_row;
    while (true) {
      const row = _tmp;
      if (row < end_row) {
        let _tmp$2 = start_col;
        while (true) {
          const col = _tmp$2;
          if (col < end_col) {
            const tile = _M0MP36mizchi7terrain5types6Grid2D3get(self.dungeon.grid, col, row);
            const sx = (col + 0) * _M0FP26mizchi10hacknslash10tile__size - view_left;
            const sy = (row + 0) * _M0FP26mizchi10hacknslash10tile__size - view_top;
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx), new Option$Some$8$(sy), _M0FP26mizchi10hacknslash10tile__size, _M0FP26mizchi10hacknslash10tile__size, _M0FP26mizchi10hacknslash19tile__color__varied(tile, col, row), Option$None$8$, Option$None$9$));
            if (_M0IP016_24default__implP311moonbitlang4core7builtin2Eq10not__equalGRP36mizchi7terrain5types4TileE(tile, 1) && (row > 0 && _M0IP36mizchi7terrain5types4TileP311moonbitlang4core7builtin2Eq5equal(_M0MP36mizchi7terrain5types6Grid2D3get(self.dungeon.grid, col, row - 1 | 0), 1))) {
              _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx), new Option$Some$8$(sy), _M0FP26mizchi10hacknslash10tile__size, 1, 0, new Option$Some$8$(0.3), Option$None$9$));
            }
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
    return nodes;
  }), _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const _arr = self.items;
    const _len = _arr.length;
    let _tmp = 0;
    while (true) {
      const _i = _tmp;
      if (_i < _len) {
        const item = _arr[_i];
        if (item.alive) {
          const ix = item.x - view_left;
          const iy = item.y - view_top;
          if (ix >= -10 && (ix <= sw + 10 && (iy >= -10 && iy <= sh + 10))) {
            const pulse = 0.6 + 0.4 * _M0FP311moonbitlang4core4math3sin((self.frame_count + 0) * 0.1);
            const color = item.kind === _M0FP26mizchi10hacknslash12item__health ? 65382 : 65535;
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(ix - 3), new Option$Some$8$(iy - 3), 6, 6, color, new Option$Some$8$(pulse), Option$None$9$));
          }
        }
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  }), _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const _arr = self.projectiles;
    const _len = _arr.length;
    let _tmp = 0;
    while (true) {
      const _i = _tmp;
      if (_i < _len) {
        const proj = _arr[_i];
        if (proj.alive) {
          const prx = proj.x - view_left;
          const pry = proj.y - view_top;
          if (prx >= -5 && (prx <= sw + 5 && (pry >= -5 && pry <= sh + 5))) {
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(prx - 2), new Option$Some$8$(pry - 2), 4, 4, 16729190, Option$None$8$, Option$None$9$));
          }
        }
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  }), _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    const _arr = self.enemies;
    const _len = _arr.length;
    let _tmp = 0;
    while (true) {
      const _i = _tmp;
      if (_i < _len) {
        const enemy = _arr[_i];
        if (enemy.alive) {
          const sx = enemy.x - view_left;
          const sy = enemy.y - view_top;
          if (sx >= -25 && (sx <= sw + 25 && (sy >= -25 && sy <= sh + 25))) {
            const ehs = enemy.size / 2;
            let fill;
            if (enemy.damage_timer > 0) {
              fill = 16777215;
            } else {
              let k;
              _L: {
                _L$2: {
                  let k$2;
                  _L$3: {
                    _L$4: {
                      let k$3;
                      _L$5: {
                        _L$6: {
                          let k$4;
                          _L$7: {
                            _L$8: {
                              const _bind = enemy.kind;
                              if (_bind === _M0FP26mizchi10hacknslash10kind__fast) {
                                k$4 = _bind;
                                break _L$8;
                              } else {
                                if (_bind === _M0FP26mizchi10hacknslash10kind__tank) {
                                  k$3 = _bind;
                                  break _L$6;
                                } else {
                                  if (_bind === _M0FP26mizchi10hacknslash12kind__ranged) {
                                    k$2 = _bind;
                                    break _L$4;
                                  } else {
                                    if (_bind === _M0FP26mizchi10hacknslash10kind__boss) {
                                      k = _bind;
                                      break _L$2;
                                    } else {
                                      fill = 13378082;
                                    }
                                  }
                                }
                              }
                              break _L$7;
                            }
                            fill = 16746496;
                          }
                          break _L$5;
                        }
                        fill = 8930508;
                      }
                      break _L$3;
                    }
                    fill = 4500223;
                  }
                  break _L;
                }
                fill = 16720486;
              }
            }
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - ehs), new Option$Some$8$(sy - ehs), enemy.size, enemy.size, fill, Option$None$8$, Option$None$9$));
            let k;
            _L: {
              _L$2: {
                let k$2;
                _L$3: {
                  _L$4: {
                    let k$3;
                    _L$5: {
                      _L$6: {
                        let k$4;
                        _L$7: {
                          _L$8: {
                            const _bind = enemy.kind;
                            if (_bind === _M0FP26mizchi10hacknslash10kind__fast) {
                              k$4 = _bind;
                              break _L$8;
                            } else {
                              if (_bind === _M0FP26mizchi10hacknslash10kind__tank) {
                                k$3 = _bind;
                                break _L$6;
                              } else {
                                if (_bind === _M0FP26mizchi10hacknslash12kind__ranged) {
                                  k$2 = _bind;
                                  break _L$4;
                                } else {
                                  if (_bind === _M0FP26mizchi10hacknslash10kind__boss) {
                                    k = _bind;
                                    break _L$2;
                                  }
                                }
                              }
                            }
                            break _L$7;
                          }
                          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - 1), new Option$Some$8$(sy - ehs - 2), 2, 2, fill, Option$None$8$, Option$None$9$));
                          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - 1), new Option$Some$8$(sy + ehs), 2, 2, fill, Option$None$8$, Option$None$9$));
                        }
                        break _L$5;
                      }
                      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene12line_2einner(sx - ehs + 2, sy, sx + ehs - 2, sy, 1, 2228292));
                      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene12line_2einner(sx, sy - ehs + 2, sx, sy + ehs - 2, 1, 2228292));
                    }
                    break _L$3;
                  }
                  const angle = _M0FP311moonbitlang4core4math5atan2(self.player.y - enemy.y, self.player.x - enemy.x);
                  const tx = sx + _M0FP311moonbitlang4core4math3cos(angle) * (ehs + 3);
                  const ty = sy + _M0FP311moonbitlang4core4math3sin(angle) * (ehs + 3);
                  _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(tx - 1.5), new Option$Some$8$(ty - 1.5), 3, 3, 4500223, Option$None$8$, Option$None$9$));
                }
                break _L;
              }
              _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene21rect__outline_2einner(sx - ehs - 2, sy - ehs - 2, enemy.size + 4, enemy.size + 4, 1, 16720486));
              const pulse = 0.5 + 0.5 * _M0FP311moonbitlang4core4math3sin((self.frame_count + 0) * 0.08);
              _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - ehs), new Option$Some$8$(sy - ehs), enemy.size, enemy.size, 16729224, new Option$Some$8$(pulse * 0.3), Option$None$9$));
              _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene13label_2einner(sx, sy - ehs - 12, "BOSS", 16720486, 0.5));
            }
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - ehs), new Option$Some$8$(sy - ehs - 4), enemy.size, 2, 4456448, Option$None$8$, Option$None$9$));
            const ehp_ratio = (enemy.hp + 0) / (enemy.max_hp + 0);
            _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - ehs), new Option$Some$8$(sy - ehs - 4), enemy.size * ehp_ratio, 2, 13369344, Option$None$8$, Option$None$9$));
          }
        }
        _tmp = _i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  }), _M0FP36mizchi6kagura5scene4show(() => self.player.dash_timer > 0, () => _M0FP36mizchi6kagura5scene9for__each(() => {
    const nodes = [];
    let _tmp = 1;
    while (true) {
      const i = _tmp;
      if (i < 4) {
        const t = (i + 0) * 3;
        const ax = px - self.player.dash_vx / _M0FP26mizchi10hacknslash13player__speed * t;
        const ay = py - self.player.dash_vy / _M0FP26mizchi10hacknslash13player__speed * t;
        const a = 0.3 - (i + 0) * 0.08;
        _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(ax - phs), new Option$Some$8$(ay - phs), self.player.size, self.player.size, 6741503, new Option$Some$8$(a), Option$None$9$));
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return nodes;
  })), _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(px - phs), new Option$Some$8$(py - phs), self.player.size, self.player.size, player_fill, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene4show(() => self.attack_timer > (_M0FP26mizchi10hacknslash16attack__cooldown - 8 | 0), () => {
    const swing_frames = 8;
    const elapsed = (_M0FP26mizchi10hacknslash16attack__cooldown - self.attack_timer | 0) + 0;
    const progress = elapsed / swing_frames;
    const angle = self.player.facing_angle + (-1.0472 + progress * 2.0944);
    const cos_a = _M0FP311moonbitlang4core4math3cos(angle);
    const sin_a = _M0FP311moonbitlang4core4math3sin(angle);
    const fade = 1 - progress;
    return _M0FP36mizchi6kagura5scene9for__each(() => {
      const nodes = [];
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < 8) {
          const dist = 6 + (i + 0) * 2.5;
          const sx = px + cos_a * dist;
          const sy = py + sin_a * dist;
          const size = i < 2 ? 3 : i < 6 ? 2 : 1;
          const color = i < 2 ? 8947848 : 13426175;
          _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi7signals2ui4NodeGuRP36mizchi6kagura5scene14SceneAttrValueEE(nodes, _M0FP36mizchi6kagura5scene4rect(new Option$Some$8$(sx - size / 2), new Option$Some$8$(sy - size / 2), size, size, color, new Option$Some$8$(fade * 0.8), Option$None$9$));
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return nodes;
    });
  }), _M0FP36mizchi6kagura5scene4show(() => self.screen_flash > 0, () => {
    const flash_alpha = (self.screen_flash + 0) / 5 * 0.15;
    return self.player.damage_timer > 0 ? _M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, sw, sh, 16711680, new Option$Some$8$(flash_alpha), Option$None$9$) : _M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, sw, sh, 16777215, new Option$Some$8$(flash_alpha), Option$None$9$);
  }), _M0FP36mizchi6kagura5scene4show(() => self.floor_announce_timer > 0, () => {
    const alpha = (self.floor_announce_timer + 0) / 120;
    return _M0FP36mizchi6kagura5scene8fragment([_M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, sw, sh, 0, new Option$Some$8$(alpha * 0.5), Option$None$9$), _M0FP36mizchi6kagura5scene13label_2einner(sw / 2, sh / 2, `FLOOR ${_M0MP311moonbitlang4core3int3Int18to__string_2einner(self.floor, 10)}`, 16763904, 2)]);
  }), _M0FP26mizchi10hacknslash11render__hud(self)]);
}
function _M0MP26mizchi10hacknslash9GameState11view__title(self) {
  return _M0FP36mizchi6kagura5scene8fragment([_M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, _M0FP26mizchi10hacknslash9screen__w + 0, _M0FP26mizchi10hacknslash9screen__h + 0, 1710638, Option$None$8$, Option$None$9$), _M0FP36mizchi6kagura5scene13label_2einner((_M0FP26mizchi10hacknslash9screen__w + 0) / 2, (_M0FP26mizchi10hacknslash9screen__h + 0) / 2 - 30, "HACK N SLASH", 16729156, 2), _M0FP36mizchi6kagura5scene4show(() => {
    if (30 === 0) {
      $panic();
    }
    if (2 === 0) {
      $panic();
    }
    return ((self.frame_count / 30 | 0) % 2 | 0) === 0;
  }, () => _M0FP36mizchi6kagura5scene13label_2einner((_M0FP26mizchi10hacknslash9screen__w + 0) / 2, (_M0FP26mizchi10hacknslash9screen__h + 0) / 2 + 20, "PRESS SPACE", 16763904, 1))]);
}
function _M0MP26mizchi10hacknslash9GameState4view(self) {
  let m;
  _L: {
    let m$2;
    _L$2: {
      let m$3;
      _L$3: {
        const _bind = self.mode;
        if (_bind === _M0FP26mizchi10hacknslash11mode__title) {
          m$3 = _bind;
          break _L$3;
        } else {
          if (_bind === _M0FP26mizchi10hacknslash13mode__playing) {
            m$2 = _bind;
            break _L$2;
          } else {
            if (_bind === _M0FP26mizchi10hacknslash14mode__gameover) {
              m = _bind;
              break _L;
            } else {
              return _M0FP36mizchi6kagura5scene4rect(Option$None$8$, Option$None$8$, _M0FP26mizchi10hacknslash9screen__w + 0, _M0FP26mizchi10hacknslash9screen__h + 0, 0, Option$None$8$, Option$None$9$);
            }
          }
        }
      }
      return _M0MP26mizchi10hacknslash9GameState11view__title(self);
    }
    return _M0MP26mizchi10hacknslash9GameState13view__playing(self);
  }
  return _M0MP26mizchi10hacknslash9GameState14view__gameover(self);
}
(() => {
  const state = _M0MP26mizchi10hacknslash9GameState3new(42);
  _M0FP36mizchi6kagura5scene11run_2einner(() => _M0MP26mizchi10hacknslash9GameState4view(state), (input) => {
    _M0MP26mizchi10hacknslash9GameState6update(state, input);
  }, undefined, undefined, _M0FP26mizchi10hacknslash9screen__w, _M0FP26mizchi10hacknslash9screen__h, "Hack & Slash", "#app");
})();
//# sourceMappingURL=hacknslash.js.map
