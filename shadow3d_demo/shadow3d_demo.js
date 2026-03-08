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
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MP311moonbitlang4core7builtin7JSArray4push = (arr, val) => { arr.push(val); };
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
       webgpu: { context: null, device: null, format: "bgra8unorm", pending: null, _pipeline: null, _pipelineFormat: "", _uniformBGL: null, _texBGL: null, _defaultTexture: null, _defaultTexView: null, _defaultSampler: null, _drawResourceCache: null, _currentDraw: null, _pendingTexture: null, presentScheduled: false, clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "" },
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
       state.webgpu = { context: null, device: null, format: "bgra8unorm", pending: null, _pipeline: null, _pipelineFormat: "", _uniformBGL: null, _texBGL: null, _defaultTexture: null, _defaultTexView: null, _defaultSampler: null, _drawResourceCache: null, _currentDraw: null, _pendingTexture: null, presentScheduled: false, clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "" };
     } else {
       if (!Array.isArray(state.webgpu.clear)) state.webgpu.clear = [0, 0, 0, 1];
       if (!Array.isArray(state.webgpu.commands)) state.webgpu.commands = [];
       if (state.webgpu._pipeline == null) state.webgpu._pipeline = null;
       if (typeof state.webgpu._pipelineFormat !== "string") state.webgpu._pipelineFormat = "";
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
     webgpu: { context: null, device: null, format: "bgra8unorm", pending: null, _pipeline: null, _pipelineFormat: "", _uniformBGL: null, _texBGL: null, _defaultTexture: null, _defaultTexView: null, _defaultSampler: null, _drawResourceCache: null, _currentDraw: null, _pendingTexture: null, presentScheduled: false, clear: [0, 0, 0, 1], commands: [], textures: null, lastError: "" },
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
       .then((adapter) => adapter == null ? null : adapter.requestDevice())
       .then((device) => {
         if (device == null) return;
         const format = typeof nav.gpu.getPreferredCanvasFormat === "function"
           ? nav.gpu.getPreferredCanvasFormat()
           : "bgra8unorm";
         state.webgpu.format = format;
         state.webgpu.device = device;
         state.webgpu._pipeline = null;
         state.webgpu._pipelineFormat = "";
         if (state.webgpu.context != null) {
           state.webgpu.context.configure({
             device,
             format,
             alphaMode: "opaque",
           });
         }
       })
       .catch((error) => {
         state.webgpu.lastError = String(error);
         state.webgpu.device = null;
         state.webgpu._pipeline = null;
         state.webgpu._pipelineFormat = "";
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
     currentContext.configure({ device: currentDevice, format, alphaMode: "opaque" });
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
       pass.drawIndexed(cmd.indices.length);
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
const Option$None$6$ = { $tag: 0, $name: "None" };
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
const _M0FP26mizchi14shadow3d__demo9screen__h = 480;
const _M0FP26mizchi14shadow3d__demo9screen__w = 640;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MP311moonbitlang4core3ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
(() => {
  _M0FP36mizchi6kagura6engine21set__lifecycle__hooks({ on_start: (_canvas, _title) => {
  }, on_stop: () => {
  } });
})();
const _M0FP26mizchi19web__runtime__hooks21web__canvas__selector = _M0MP311moonbitlang4core3ref3Ref3newGsE("#app");
const _M0FP26mizchi19web__runtime__hooks21web__hooks__installed = _M0MP311moonbitlang4core3ref3Ref3newGbE(false);
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MP311moonbitlang4core3ref3Ref3newGRP36mizchi6kagura5audio16AudioOutputHooksE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FP311moonbitlang4core7builtin33brute__force__find_2econstr_2f106 = 0;
const _M0FP311moonbitlang4core7builtin42boyer__moore__horspool__find_2econstr_2f92 = 0;
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
const _M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f308 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
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
function _M0MP311moonbitlang4core6uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implP311moonbitlang4core7builtin7Compare6op__leGkE(self, 57343);
}
function _M0MP311moonbitlang4core5array5Array2atGRP26mizchi14shadow3d__demo11SceneObjectE(self, index) {
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
function _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8shadow3d12ShadowCasterE(self, index) {
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
function _M0MP311moonbitlang4core7builtin7MyInt647to__int(self) {
  return self.lo;
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
function _M0MP311moonbitlang4core6string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
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
    return _M0FP311moonbitlang4core7builtin42boyer__moore__horspool__find_2econstr_2f92;
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
    return _M0FP311moonbitlang4core7builtin33brute__force__find_2econstr_2f106;
  }
}
function _M0MP311moonbitlang4core6string10StringView4find(self, str) {
  return _M0MP311moonbitlang4core6string10StringView6length(str) <= 4 ? _M0FP311moonbitlang4core7builtin18brute__force__find(self, str) : _M0FP311moonbitlang4core7builtin28boyer__moore__horspool__find(self, str);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura8shadow3d12ShadowCasterE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
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
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi14shadow3d__demo11SceneObjectE(self, value) {
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
function _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi5audio5VoiceE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core5array5Array4pushGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, value) {
  _M0MP311moonbitlang4core7builtin7JSArray4push(self, value);
}
function _M0MP311moonbitlang4core6string10StringView8contains(self, str) {
  const _bind = _M0MP311moonbitlang4core6string10StringView4find(self, str);
  return !(_bind === undefined);
}
function _M0MP311moonbitlang4core6string6String8contains(self, str) {
  return _M0MP311moonbitlang4core6string10StringView8contains({ str: self, start: 0, end: self.length }, str);
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
function _M0MP311moonbitlang4core6double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0FP311moonbitlang4core7builtin7printlnGsE(input) {
  console.log(_M0IP311moonbitlang4core6string6StringP311moonbitlang4core7builtin4Show10to__string(input));
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
function _M0MP311moonbitlang4core3ref3Ref3newGbE(x) {
  return { val: x };
}
function _M0MP311moonbitlang4core3ref3Ref3newGsE(x) {
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
function _M0FP311moonbitlang4core4math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FP311moonbitlang4core4math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0FP311moonbitlang4core4math3tan(_tmp) {
  return Math.tan(_tmp);
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
  let hi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f308, ind);
  let mi = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f308, ind + 1 | 0);
  let lo = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f308, ind + 2 | 0);
  const tp = _M0MP311moonbitlang4core5array13ReadOnlyArray2atGjE(_M0FP311moonbitlang4core4math34trig__reduce_2etwo__over__pi_2f308, ind + 3 | 0);
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
function _M0MP36mizchi6kagura6math3d4Mat411rotation__y(angle_rad) {
  const c = _M0FP311moonbitlang4core4math3cos(angle_rad);
  const s = _M0FP311moonbitlang4core4math3sin(angle_rad);
  const m = _M0MP36mizchi6kagura6math3d4Mat48identity();
  const _tmp = m.elements;
  $bound_check(_tmp, 0);
  _tmp[0] = c;
  const _tmp$2 = m.elements;
  $bound_check(_tmp$2, 2);
  _tmp$2[2] = -s;
  const _tmp$3 = m.elements;
  $bound_check(_tmp$3, 8);
  _tmp$3[8] = s;
  const _tmp$4 = m.elements;
  $bound_check(_tmp$4, 10);
  _tmp$4[10] = c;
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
      return new Result$Ok$1$(undefined);
    } else {
      const _Some = _bind;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  _M0FP26mizchi5audio11stop__voice(self.mixer, vid);
  return new Result$Ok$1$(undefined);
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
  return new Result$Ok$2$(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : { kind: 1, opaque_id: 2, width: self.options.width, height: self.options.height, device_scale_factor: 1 });
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
  return new Result$Ok$1$(undefined);
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
function _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, dst_regions, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, uniform_dwords, instance_count) {
  return { dst: dst, shader: shader, dst_regions: dst_regions, index_offset: index_offset, pipeline_id: pipeline_id, uniform_hash: uniform_hash, blend: blend, vertex_data: vertex_data, indices: indices, src_image_ids: src_image_ids, uniform_dwords: uniform_dwords, instance_count: instance_count };
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
    return new Result$Ok$1$(undefined);
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
  return new Result$Ok$1$(undefined);
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
  return new Result$Ok$1$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(self, present) {
  if (self.initialized) {
    self.end_count = self.end_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx15native__on__end(self.native_active, present);
    _M0FP36mizchi6kagura3gfx22web__graphics__on__end(self.web_active, self.backend, present);
  }
  return new Result$Ok$1$(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(self, width, height) {
  const next_width = width <= 0 ? 1 : width;
  const next_height = height <= 0 ? 1 : height;
  if (self.width === next_width && self.height === next_height) {
    self.resize_suppressed_count = self.resize_suppressed_count + 1 | 0;
    return new Result$Ok$1$(undefined);
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
  return new Result$Ok$1$(undefined);
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
  return new Result$Ok$1$(undefined);
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
function _M0FP36mizchi6kagura6engine11run_2einner(update, draw, on_frame, audio_ctx, audio_frames_per_tick, width, height, title, canvas) {
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
    const cmds = draw(ctx);
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
    const now = _M0FP36mizchi6kagura6engine20js__performance__now();
    const elapsed = now - prev_time.val;
    prev_time.val = now;
    let actx;
    _L$8: {
      _L$9: {
        if (audio_ctx === undefined) {
        } else {
          const _Some = audio_ctx;
          const _actx = _Some;
          actx = _actx;
          break _L$9;
        }
        break _L$8;
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
function _M0MP36mizchi6kagura6mesh3d6Mesh3D4cube(size) {
  const h = size / 2;
  const data = [];
  const indices = [];
  const base = { val: 0 };
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, h, 0, 0, 1, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, h, 0, 0, 1, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, h, 0, 0, 1, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, h, 0, 0, 1, 0, 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, -h, 0, 0, -1, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, -h, 0, 0, -1, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, -h, 0, 0, -1, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, -h, 0, 0, -1, 0, 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, h, 1, 0, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, -h, 1, 0, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, -h, 1, 0, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, h, 1, 0, 0, 0, 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, -h, -1, 0, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, h, -1, 0, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, h, -1, 0, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, -h, -1, 0, 0, 0, 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, h, 0, 1, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, h, 0, 1, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, -h, 0, 1, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, -h, 0, 1, 0, 0, 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, -h, 0, -1, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, -h, 0, -1, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, h, 0, -1, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, h, 0, -1, 0, 0, 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MP311moonbitlang4core5array5Array4pushGiE(indices, base.val);
  return _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(data, indices);
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
function _M0MP36mizchi6kagura6mesh3d6Mesh3D6sphere(radius, segments, rings) {
  const data = [];
  const indices = [];
  const _start6 = 0;
  const _end7 = rings;
  let _tmp = _start6;
  while (true) {
    const ring = _tmp;
    if (ring <= _end7) {
      const phi = 3.14159265358979312 * (ring + 0) / (rings + 0);
      const sin_phi = _M0FP311moonbitlang4core4math3sin(phi);
      const cos_phi = _M0FP311moonbitlang4core4math3cos(phi);
      const _start14 = 0;
      const _end15 = segments;
      let _tmp$2 = _start14;
      while (true) {
        const seg = _tmp$2;
        if (seg <= _end15) {
          const theta = 6.28318530717958623 * (seg + 0) / (segments + 0);
          const sin_theta = _M0FP311moonbitlang4core4math3sin(theta);
          const cos_theta = _M0FP311moonbitlang4core4math3cos(theta);
          const nx = cos_theta * sin_phi;
          const ny = cos_phi;
          const nz = sin_theta * sin_phi;
          const u = (seg + 0) / (segments + 0);
          const v = (ring + 0) / (rings + 0);
          _M0FP36mizchi6kagura6mesh3d12push__vertex(data, radius * nx, radius * ny, radius * nz, nx, ny, nz, u, v);
          _tmp$2 = seg + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = ring + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const cols = segments + 1 | 0;
  const _start28 = 0;
  const _end29 = rings;
  let _tmp$2 = _start28;
  while (true) {
    const ring = _tmp$2;
    if (ring < _end29) {
      const _start33 = 0;
      const _end34 = segments;
      let _tmp$3 = _start33;
      while (true) {
        const seg = _tmp$3;
        if (seg < _end34) {
          const curr = (Math.imul(ring, cols) | 0) + seg | 0;
          const next = curr + cols | 0;
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, curr);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, next);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, curr + 1 | 0);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, curr + 1 | 0);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, next);
          _M0MP311moonbitlang4core5array5Array4pushGiE(indices, next + 1 | 0);
          _tmp$3 = seg + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$2 = ring + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(data, indices);
}
function _M0FP36mizchi6kagura8shadow3d3f32(v) {
  return _M0FP36mizchi6kagura3gfx21double__to__f32__bits(v);
}
function _M0MP36mizchi6kagura8shadow3d12ShadowConfig3new(map_size, half_extent, near, far, distance, center, bias) {
  return { map_size: map_size, half_extent: half_extent, near: near, far: far, distance: distance, center: center, bias: bias, pcf_texel_size: 1 / (map_size + 0) };
}
function _M0FP36mizchi6kagura8shadow3d19light__view__matrix(light_dir, center, distance) {
  const len = Math.sqrt(light_dir.x * light_dir.x + light_dir.y * light_dir.y + light_dir.z * light_dir.z);
  if (len < 1e-08) {
    return _M0MP36mizchi6kagura6math3d4Mat48identity();
  }
  const dir = _M0MP36mizchi6kagura6math3d4Vec39normalize(light_dir);
  const eye = _M0MP36mizchi6kagura6math3d4Vec33sub(center, _M0MP36mizchi6kagura6math3d4Vec35scale(dir, distance));
  const up = Math.abs(dir.x * 0 + dir.y * 1 + dir.z * 0) > 0.999 ? _M0MP36mizchi6kagura6math3d4Vec33new(1, 0, 0) : _M0MP36mizchi6kagura6math3d4Vec33new(0, 1, 0);
  return _M0MP36mizchi6kagura6math3d4Mat48look__at(eye, center, up);
}
function _M0FP36mizchi6kagura8shadow3d25light__projection__matrix(half_extent, near, far) {
  return _M0MP36mizchi6kagura6math3d4Mat412orthographic(-half_extent, half_extent, -half_extent, half_extent, near, far);
}
function _M0FP36mizchi6kagura8shadow3d20light__space__matrix(light_dir, center, distance, half_extent, near, far) {
  const view = _M0FP36mizchi6kagura8shadow3d19light__view__matrix(light_dir, center, distance);
  const proj = _M0FP36mizchi6kagura8shadow3d25light__projection__matrix(half_extent, near, far);
  return _M0MP36mizchi6kagura6math3d4Mat48multiply(proj, view);
}
function _M0FP36mizchi6kagura8shadow3d27shader__shadow__depth__wgsl() {
  return `struct Uniforms {\n  light_mvp: mat4x4<f32>,\n};\n\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) depth: f32,\n};\n\n@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  let light_space_pos = uniforms.light_mvp * vec4<f32>(input.position, 1.0);\n  out.clip_position = light_space_pos;\n  out.depth = clamp(light_space_pos.z / light_space_pos.w, 0.0, 1.0);\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  return vec4<f32>(in.depth, 0.0, 0.0, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura8shadow3d30shadow__depth__uniform__dwords(model, light_vp) {
  const light_mvp = _M0MP36mizchi6kagura6math3d4Mat48multiply(light_vp, model);
  const dwords = [];
  const _start100 = 0;
  const _end101 = 16;
  let _tmp = _start100;
  while (true) {
    const i = _tmp;
    if (i < _end101) {
      const _tmp$2 = light_mvp.elements;
      $bound_check(_tmp$2, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return dwords;
}
function _M0FP36mizchi6kagura8shadow3d27new__shadow__depth__command(shadow_map, shader, mesh, model, light_vp) {
  const uniform_dwords = _M0FP36mizchi6kagura8shadow3d30shadow__depth__uniform__dwords(model, light_vp);
  const dst_region = _M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, shadow_map.width, shadow_map.height, mesh.indices.length);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(shadow_map, shader, [dst_region], 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0), mesh.vertex_data, mesh.indices, [], uniform_dwords, 1);
}
function _M0MP36mizchi6kagura8shadow3d12ShadowCaster3new(mesh, model_matrix) {
  return { mesh: mesh, model_matrix: model_matrix };
}
function _M0FP36mizchi6kagura8shadow3d29shadow__depth__pass__commands(shadow_map, depth_shader, casters, lighting, config) {
  const light_vp = _M0FP36mizchi6kagura8shadow3d20light__space__matrix(lighting.directional.direction, config.center, config.distance, config.half_extent, config.near, config.far);
  const commands = [];
  const _start81 = 0;
  const _end82 = casters.length;
  let _tmp = _start81;
  while (true) {
    const i = _tmp;
    if (i < _end82) {
      const caster = _M0MP311moonbitlang4core5array5Array2atGRP36mizchi6kagura8shadow3d12ShadowCasterE(casters, i);
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(commands, _M0FP36mizchi6kagura8shadow3d27new__shadow__depth__command(shadow_map, depth_shader, caster.mesh, caster.model_matrix, light_vp));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return commands;
}
function _M0FP36mizchi6kagura8shadow3d34shadow__lit__uniform__struct__wgsl() {
  return `struct Uniforms {\n  mvp: mat4x4<f32>,\n  model: mat4x4<f32>,\n  normal_col0: vec4<f32>,\n  normal_col1: vec4<f32>,\n  normal_col2: vec4<f32>,\n  light_dir: vec4<f32>,\n  light_color: vec4<f32>,\n  ambient_color: vec4<f32>,\n  light_vp: mat4x4<f32>,\n  shadow_params: vec4<f32>,\n};\n\n`;
}
function _M0FP36mizchi6kagura8shadow3d18shadow__calc__wgsl() {
  return `fn calc_shadow(world_pos: vec3<f32>) -> f32 {\n  let light_space = uniforms.light_vp * vec4<f32>(world_pos, 1.0);\n  let proj_coords = light_space.xyz / light_space.w;\n  let shadow_uv = vec2<f32>(proj_coords.x * 0.5 + 0.5, 1.0 - (proj_coords.y * 0.5 + 0.5));\n  if (shadow_uv.x < 0.0 || shadow_uv.x > 1.0 || shadow_uv.y < 0.0 || shadow_uv.y > 1.0) {\n    return 1.0;\n  }\n  let current_depth = clamp(proj_coords.z, 0.0, 1.0);\n  let bias = uniforms.shadow_params.x;\n  let texel_size = uniforms.shadow_params.y;\n  var shadow = 0.0;\n  for (var x = -1; x <= 1; x = x + 1) {\n    for (var y = -1; y <= 1; y = y + 1) {\n      let offset = vec2<f32>(f32(x), f32(y)) * texel_size;\n      let closest_depth = textureSampleLevel(shadow_map, shadow_sampler, shadow_uv + offset, 0.0).r;\n      shadow = shadow + select(0.0, 1.0, current_depth - bias > closest_depth);\n    }\n  }\n  return 1.0 - shadow / 9.0;\n}\n\n`;
}
function _M0FP36mizchi6kagura8shadow3d22lit__normal__mat__wgsl() {
  return `  let normal_mat = mat3x3<f32>(\n    uniforms.normal_col0.xyz,\n    uniforms.normal_col1.xyz,\n    uniforms.normal_col2.xyz,\n  );\n`;
}
function _M0FP36mizchi6kagura8shadow3d29lit__fragment__lighting__wgsl() {
  return `  let normal = normalize(in.world_normal);\n  let light_dir = normalize(-uniforms.light_dir.xyz);\n  let ndotl = max(dot(normal, light_dir), 0.0);\n  let diffuse = uniforms.light_color.xyz * ndotl;\n  let ambient = uniforms.ambient_color.xyz;\n`;
}
function _M0FP36mizchi6kagura8shadow3d39shader3d__shadow__lit__untextured__wgsl() {
  return `${_M0FP36mizchi6kagura8shadow3d34shadow__lit__uniform__struct__wgsl()}@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(3) var shadow_map: texture_2d<f32>;\n@group(0) @binding(4) var shadow_sampler: sampler;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) world_normal: vec3<f32>,\n  @location(1) world_position: vec3<f32>,\n};\n\n${_M0FP36mizchi6kagura8shadow3d18shadow__calc__wgsl()}@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n${_M0FP36mizchi6kagura8shadow3d22lit__normal__mat__wgsl()}  out.world_normal = normalize(normal_mat * input.normal);\n  out.world_position = (uniforms.model * vec4<f32>(input.position, 1.0)).xyz;\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n${_M0FP36mizchi6kagura8shadow3d29lit__fragment__lighting__wgsl()}  let shadow_factor = calc_shadow(in.world_position);\n  let lit_color = diffuse * shadow_factor + ambient;\n  return vec4<f32>(lit_color, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura8shadow3d28shadow__lit__uniform__dwords(model, view_projection, lighting, light_vp, config) {
  const mvp = _M0MP36mizchi6kagura6math3d4Mat48multiply(view_projection, model);
  const dwords = [];
  const _start47 = 0;
  const _end48 = 16;
  let _tmp = _start47;
  while (true) {
    const i = _tmp;
    if (i < _end48) {
      const _tmp$2 = mvp.elements;
      $bound_check(_tmp$2, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _start52 = 0;
  const _end53 = 16;
  let _tmp$2 = _start52;
  while (true) {
    const i = _tmp$2;
    if (i < _end53) {
      const _tmp$3 = model.elements;
      $bound_check(_tmp$3, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(_tmp$3[i]));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const normal_dw = _M0FP36mizchi6kagura7light3d31normal__matrix__uniform__dwords(model);
  const _start58 = 0;
  const _end59 = normal_dw.length;
  let _tmp$3 = _start58;
  while (true) {
    const i = _tmp$3;
    if (i < _end59) {
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0MP311moonbitlang4core5array5Array2atGiE(normal_dw, i));
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const light_dw = _M0FP36mizchi6kagura7light3d22light__uniform__dwords(lighting);
  const _start64 = 0;
  const _end65 = light_dw.length;
  let _tmp$4 = _start64;
  while (true) {
    const i = _tmp$4;
    if (i < _end65) {
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0MP311moonbitlang4core5array5Array2atGiE(light_dw, i));
      _tmp$4 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _start69 = 0;
  const _end70 = 16;
  let _tmp$5 = _start69;
  while (true) {
    const i = _tmp$5;
    if (i < _end70) {
      const _tmp$6 = light_vp.elements;
      $bound_check(_tmp$6, i);
      _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(_tmp$6[i]));
      _tmp$5 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(config.bias));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(config.pcf_texel_size));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(0));
  _M0MP311moonbitlang4core5array5Array4pushGiE(dwords, _M0FP36mizchi6kagura8shadow3d3f32(0));
  return dwords;
}
function _M0FP36mizchi6kagura8shadow3d37new__shadow__lit__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh, model_matrix, view_projection, lighting, light_vp, config, diffuse_image_id, shadow_map_image_id) {
  const uniform_dwords = _M0FP36mizchi6kagura8shadow3d28shadow__lit__uniform__dwords(model_matrix, view_projection, lighting, light_vp, config);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, mesh.vertex_data, mesh.indices, [diffuse_image_id, shadow_map_image_id], uniform_dwords, 1);
}
function _M0FP36mizchi6kagura4text22new__font__load__hooks(load_font_data) {
  return { load_font_data: load_font_data };
}
function _M0FP36mizchi6kagura4text25default__load__font__data(_name) {
  return Option$None$3$;
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
    return Option$None$3$;
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
  return new Option$Some$3$(data);
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
function _M0MP26mizchi14shadow3d__demo9DemoState14build__objects(self) {
  const objects = [];
  const ground_model = _M0MP36mizchi6kagura6math3d4Mat411translation(0, -0.01, 0);
  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi14shadow3d__demo11SceneObjectE(objects, { mesh: self.ground_mesh, model_matrix: ground_model });
  const cube1_model = _M0MP36mizchi6kagura6math3d4Mat411translation(-2, 0.5, 0);
  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi14shadow3d__demo11SceneObjectE(objects, { mesh: self.cube_mesh, model_matrix: cube1_model });
  const angle = (self.frame + 0) * 0.01;
  const cube2_model = _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP36mizchi6kagura6math3d4Mat411translation(2.5, 0.5, -1.5), _M0MP36mizchi6kagura6math3d4Mat411rotation__y(angle));
  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi14shadow3d__demo11SceneObjectE(objects, { mesh: self.cube_mesh, model_matrix: cube2_model });
  const cube3_model = _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP36mizchi6kagura6math3d4Mat411translation(0, 1.2, 2), _M0MP36mizchi6kagura6math3d4Mat47scaling(0.6, 0.6, 0.6));
  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi14shadow3d__demo11SceneObjectE(objects, { mesh: self.cube_mesh, model_matrix: cube3_model });
  const sphere_model = _M0MP36mizchi6kagura6math3d4Mat411translation(1, 0.6, 1.5);
  _M0MP311moonbitlang4core5array5Array4pushGRP26mizchi14shadow3d__demo11SceneObjectE(objects, { mesh: self.sphere_mesh, model_matrix: sphere_model });
  return objects;
}
function _M0MP26mizchi14shadow3d__demo9DemoState4draw(self, ctx) {
  const objects = _M0MP26mizchi14shadow3d__demo9DemoState14build__objects(self);
  const config = self.shadow_config;
  const lighting = self.lighting;
  const light_vp = _M0FP36mizchi6kagura8shadow3d20light__space__matrix(lighting.directional.direction, config.center, config.distance, config.half_extent, config.near, config.far);
  const casters = [];
  const _start8 = 0;
  const _end9 = objects.length;
  let _tmp = _start8;
  while (true) {
    const i = _tmp;
    if (i < _end9) {
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura8shadow3d12ShadowCasterE(casters, _M0MP36mizchi6kagura8shadow3d12ShadowCaster3new(_M0MP311moonbitlang4core5array5Array2atGRP26mizchi14shadow3d__demo11SceneObjectE(objects, i).mesh, _M0MP311moonbitlang4core5array5Array2atGRP26mizchi14shadow3d__demo11SceneObjectE(objects, i).model_matrix));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const depth_cmds = _M0FP36mizchi6kagura8shadow3d29shadow__depth__pass__commands(self.shadow_map, self.depth_shader, casters, lighting, config);
  const camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera12to__camera3d(self.camera);
  const view_projection = _M0MP36mizchi6kagura8camera3d8Camera3D24view__projection__matrix(camera);
  const lit_cmds = [];
  const _start17 = 0;
  const _end18 = objects.length;
  let _tmp$2 = _start17;
  while (true) {
    const i = _tmp$2;
    if (i < _end18) {
      const obj = _M0MP311moonbitlang4core5array5Array2atGRP26mizchi14shadow3d__demo11SceneObjectE(objects, i);
      const dst_region = _M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, ctx.screen_w, ctx.screen_h, obj.mesh.indices.length);
      const cmd = _M0FP36mizchi6kagura8shadow3d37new__shadow__lit__mesh__draw__command(ctx.dst, self.lit_shader, dst_region, 0, 0, i, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0), obj.mesh, obj.model_matrix, view_projection, lighting, light_vp, config, self.shadow_map.id, self.shadow_map.id);
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(lit_cmds, cmd);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const all_cmds = [];
  const _arr = depth_cmds;
  const _len = _arr.length;
  let _tmp$3 = 0;
  while (true) {
    const _i = _tmp$3;
    if (_i < _len) {
      const cmd = _arr[_i];
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(all_cmds, cmd);
      _tmp$3 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _arr$2 = lit_cmds;
  const _len$2 = _arr$2.length;
  let _tmp$4 = 0;
  while (true) {
    const _i = _tmp$4;
    if (_i < _len$2) {
      const cmd = _arr$2[_i];
      _M0MP311moonbitlang4core5array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(all_cmds, cmd);
      _tmp$4 = _i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return all_cmds;
}
function _M0MP26mizchi14shadow3d__demo9DemoState3new() {
  const shadow_config = _M0MP36mizchi6kagura8shadow3d12ShadowConfig3new(1024, 8, 0.1, 50, 20, _M0MP36mizchi6kagura6math3d4Vec34zero(), 0.005);
  const shadow_map = _M0FP36mizchi6kagura3gfx18new__image__handle(100, 1024, 1024);
  const depth_shader = _M0FP36mizchi6kagura3gfx19new__shader__handle(100, _M0FP36mizchi6kagura8shadow3d27shader__shadow__depth__wgsl());
  const lit_shader = _M0FP36mizchi6kagura3gfx19new__shader__handle(101, _M0FP36mizchi6kagura8shadow3d39shader3d__shadow__lit__untextured__wgsl());
  const camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(_M0MP36mizchi6kagura6math3d4Vec33new(0, 1, 0), 12, 0.5, 0.6, 0.785398163397448279, (_M0FP26mizchi14shadow3d__demo9screen__w + 0) / (_M0FP26mizchi14shadow3d__demo9screen__h + 0), 0.1, 100);
  const lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(-0.4, -1, -0.6), _M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 0.95), 0.9), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 0.25), Option$None$6$, Option$None$7$);
  return { cube_mesh: _M0MP36mizchi6kagura6mesh3d6Mesh3D4cube(1), sphere_mesh: _M0MP36mizchi6kagura6mesh3d6Mesh3D6sphere(0.6, 8, 6), ground_mesh: _M0MP36mizchi6kagura6mesh3d6Mesh3D13plane_2einner(20, 20, 4), shadow_map: shadow_map, depth_shader: depth_shader, lit_shader: lit_shader, shadow_config: shadow_config, camera: camera, lighting: lighting, input: _M0FP36mizchi6kagura9inpututil18new__input__helper(), frame: 0 };
}
function _M0MP26mizchi14shadow3d__demo9DemoState6update(self, snapshot) {
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, snapshot);
  self.frame = self.frame + 1 | 0;
  self.camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self.camera, 0.005, 0);
}
(() => {
  const state = _M0MP26mizchi14shadow3d__demo9DemoState3new();
  _M0FP36mizchi6kagura6engine11run_2einner((input) => {
    _M0MP26mizchi14shadow3d__demo9DemoState6update(state, input);
  }, (ctx) => _M0MP26mizchi14shadow3d__demo9DemoState4draw(state, ctx), undefined, undefined, 735, _M0FP26mizchi14shadow3d__demo9screen__w, _M0FP26mizchi14shadow3d__demo9screen__h, "Shadow Mapping Demo", "#app");
})();
//# sourceMappingURL=shadow3d_demo.js.map
