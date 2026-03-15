class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
const $reinterpret_view = new DataView(new ArrayBuffer(8));
function $f32_reinterpret_i32(a) {
  $reinterpret_view.setInt32(0, a, true);
  return $reinterpret_view.getFloat32(0, true);
}
function _M0TP36mizchi6kagura6engine14LifecycleHooks(param0, param1) {
  this.on_start = param0;
  this.on_stop = param1;
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB13SourceLocRepr(param0, param1, param2, param3, param4, param5) {
  this.pkg = param0;
  this.filename = param1;
  this.start_line = param2;
  this.start_column = param3;
  this.end_line = param4;
  this.end_column = param5;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function _M0TPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TPB7MyInt64(param0, param1) {
  this.hi = param0;
  this.lo = param1;
}
const _M0MPB7MyInt6419reinterpret__double = function f(a) {
  let view = f._view;
  if (view === undefined) {
    view = f._view = new DataView(new ArrayBuffer(8));
  }
  view.setFloat64(0, a);
  const hi = view.getInt32(0);
  const lo = view.getInt32(4);
  return { hi, lo };
};
function _M0TPC13ref3RefGiE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGdE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGORP36mizchi6kagura6engine14LifecycleHooksE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGbE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGsE(param0) {
  this.val = param0;
}
function $i32_reinterpret_f32(a) {
  $reinterpret_view.setFloat32(0, a, true);
  return $reinterpret_view.getInt32(0, true);
}
function _M0TP36mizchi6kagura6math3d4Vec3(param0, param1, param2) {
  this.x = param0;
  this.y = param1;
  this.z = param2;
}
function _M0TP36mizchi6kagura6math3d4Vec4(param0, param1, param2, param3) {
  this.x = param0;
  this.y = param1;
  this.z = param2;
  this.w = param3;
}
function _M0TP36mizchi6kagura6math3d4Mat4(param0) {
  this.elements = param0;
}
function _M0TP36mizchi6kagura6math3d10Quaternion(param0, param1, param2, param3) {
  this.x = param0;
  this.y = param1;
  this.z = param2;
  this.w = param3;
}
function _M0TP36mizchi6kagura8camera3d8Camera3D(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.position = param0;
  this.target = param1;
  this.up = param2;
  this.fov_y_rad = param3;
  this.aspect = param4;
  this.near = param5;
  this.far = param6;
  this.projection_mode = param7;
}
function _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective() {}
_M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective.prototype.$tag = 0;
const _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective__ = new _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective();
function _M0DTP36mizchi6kagura8camera3d14ProjectionMode12Orthographic(param0, param1, param2, param3) {
  this._0 = param0;
  this._1 = param1;
  this._2 = param2;
  this._3 = param3;
}
_M0DTP36mizchi6kagura8camera3d14ProjectionMode12Orthographic.prototype.$tag = 1;
function _M0TP36mizchi6kagura8camera3d11OrbitCamera(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.target = param0;
  this.distance = param1;
  this.yaw = param2;
  this.pitch = param3;
  this.fov_y_rad = param4;
  this.aspect = param5;
  this.near = param6;
  this.far = param7;
}
function _M0TP36mizchi6kagura4core11OutsideSize(param0, param1) {
  this.width = param0;
  this.height = param1;
}
function _M0TP36mizchi6kagura4core10TouchPoint(param0, param1, param2, param3) {
  this.id = param0;
  this.x = param1;
  this.y = param2;
  this.source = param3;
}
function _M0TP36mizchi6kagura4core15GamepadSnapshot(param0, param1, param2) {
  this.id = param0;
  this.axes = param1;
  this.pressed_buttons = param2;
}
function _M0TP36mizchi6kagura4core13InputSnapshot(param0, param1, param2, param3, param4, param5, param6, param7) {
  this.cursor_x = param0;
  this.cursor_y = param1;
  this.wheel_x = param2;
  this.wheel_y = param3;
  this.pressed_keys = param4;
  this.pressed_mouse_buttons = param5;
  this.touches = param6;
  this.gamepads = param7;
}
function _M0TP36mizchi6kagura8platform14WebCanvasHooks(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16, param17, param18, param19) {
  this.try_initialize = param0;
  this.poll = param1;
  this.should_close = param2;
  this.outside_size = param3;
  this.current_surface = param4;
  this.capture_input = param5;
  this.set_fullscreen = param6;
  this.is_fullscreen = param7;
  this.set_cursor_mode = param8;
  this.cursor_mode = param9;
  this.set_device_scale_factor = param10;
  this.device_scale_factor = param11;
  this.set_vsync_enabled = param12;
  this.is_vsync_enabled = param13;
  this.close_window = param14;
  this.request_attention = param15;
  this.set_mouse_touch_fallback = param16;
  this.mouse_touch_fallback_enabled = param17;
  this.fullscreen_request_status = param18;
  this.cursor_mode_request_status = param19;
}
function _M0TP36mizchi6kagura8platform12SurfaceToken(param0, param1, param2, param3, param4) {
  this.kind = param0;
  this.opaque_id = param1;
  this.width = param2;
  this.height = param3;
  this.device_scale_factor = param4;
}
function _M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0TP36mizchi6kagura8platform13WindowOptions(param0, param1, param2, param3, param4, param5) {
  this.title = param0;
  this.width = param1;
  this.height = param2;
  this.transparent = param3;
  this.resizable = param4;
  this.focused = param5;
}
function _M0TP36mizchi6kagura8platform17WebCanvasPlatform(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15) {
  this.canvas_selector = param0;
  this.initialized = param1;
  this.poll_count = param2;
  this.close_after_polls = param3;
  this.web_active = param4;
  this.options = param5;
  this.current_input = param6;
  this.fullscreen = param7;
  this.cursor_mode = param8;
  this.device_scale_factor = param9;
  this.vsync_enabled = param10;
  this.close_requested = param11;
  this.attention_requests = param12;
  this.mouse_touch_fallback = param13;
  this.fullscreen_request_status = param14;
  this.cursor_mode_request_status = param15;
}
function _M0DTPC16result6ResultGuRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRPC15error5ErrorE2Ok.prototype.$tag = 1;
const $1L = { hi: 0, lo: 1 };
const $2047L = { hi: 0, lo: 2047 };
const $4503599627370495L = { hi: 1048575, lo: -1 };
const $0L = { hi: 0, lo: 0 };
function _M0TP36mizchi6kagura3gfx16BuiltinShaderKey(param0, param1, param2) {
  this.filter = param0;
  this.address = param1;
  this.use_color_m = param2;
}
function _M0TP36mizchi6kagura3gfx9DstRegion(param0, param1, param2, param3, param4) {
  this.x = param0;
  this.y = param1;
  this.width = param2;
  this.height = param3;
  this.index_count = param4;
}
function _M0TP36mizchi6kagura3gfx5Color(param0, param1, param2, param3) {
  this.r = param0;
  this.g = param1;
  this.b = param2;
  this.a = param3;
}
function _M0TP36mizchi6kagura3gfx14RenderPassDesc(param0, param1, param2) {
  this.clear_color = param0;
  this.clear_enabled = param1;
  this.present = param2;
}
function _M0DTP36mizchi6kagura3gfx9BlendMode4Copy() {}
_M0DTP36mizchi6kagura3gfx9BlendMode4Copy.prototype.$tag = 0;
const _M0DTP36mizchi6kagura3gfx9BlendMode4Copy__ = new _M0DTP36mizchi6kagura3gfx9BlendMode4Copy();
function _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha() {}
_M0DTP36mizchi6kagura3gfx9BlendMode5Alpha.prototype.$tag = 1;
const _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha__ = new _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha();
function _M0DTP36mizchi6kagura3gfx9BlendMode3Add() {}
_M0DTP36mizchi6kagura3gfx9BlendMode3Add.prototype.$tag = 2;
const _M0DTP36mizchi6kagura3gfx9BlendMode3Add__ = new _M0DTP36mizchi6kagura3gfx9BlendMode3Add();
function _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply() {}
_M0DTP36mizchi6kagura3gfx9BlendMode8Multiply.prototype.$tag = 3;
const _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply__ = new _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply();
function _M0DTP36mizchi6kagura3gfx9BlendMode6Custom(param0) {
  this._0 = param0;
}
_M0DTP36mizchi6kagura3gfx9BlendMode6Custom.prototype.$tag = 4;
function _M0TP36mizchi6kagura3gfx11ImageHandle(param0, param1, param2) {
  this.id = param0;
  this.width = param1;
  this.height = param2;
}
function _M0TP36mizchi6kagura3gfx12ShaderHandle(param0, param1) {
  this.id = param0;
  this.source = param1;
}
function _M0TP36mizchi6kagura3gfx20DrawTrianglesCommand(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12) {
  this.dst = param0;
  this.shader = param1;
  this.dst_regions = param2;
  this.index_offset = param3;
  this.pipeline_id = param4;
  this.uniform_hash = param5;
  this.blend = param6;
  this.vertex_data = param7;
  this.indices = param8;
  this.src_image_ids = param9;
  this.uniform_dwords = param10;
  this.instance_count = param11;
  this.resource_cache_key = param12;
}
function _M0DTPC16option6OptionGRPB5ArrayGiEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGiEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGiEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGiEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGiEE4Some.prototype.$tag = 1;
function _M0TP36mizchi6kagura3gfx16WebGraphicsHooks(param0, param1, param2, param3, param4, param5) {
  this.try_initialize = param0;
  this.on_begin = param1;
  this.on_end = param2;
  this.on_draw = param3;
  this.on_resize = param4;
  this.on_read_pixels = param5;
}
function _M0TP36mizchi6kagura3gfx19NativeGraphicsHooks(param0, param1, param2, param3, param4, param5, param6) {
  this.try_initialize = param0;
  this.on_begin = param1;
  this.on_end = param2;
  this.on_draw = param3;
  this.on_resize = param4;
  this.on_read_pixels = param5;
  this.on_new_image = param6;
}
function _M0TP36mizchi6kagura3gfx22GraphicsBackendOptions(param0, param1, param2) {
  this.enable_validation = param0;
  this.prefer_low_power = param1;
  this.enable_vsync = param2;
}
function _M0TP36mizchi6kagura3gfx18StubGraphicsDriver(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13) {
  this.backend = param0;
  this.width = param1;
  this.height = param2;
  this.initialized = param3;
  this.native_active = param4;
  this.web_active = param5;
  this.next_id = param6;
  this.begin_count = param7;
  this.end_count = param8;
  this.draw_count = param9;
  this.resize_count = param10;
  this.resize_suppressed_count = param11;
  this.last_resize_duration_ms = param12;
  this.total_resize_duration_ms = param13;
}
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE2Ok.prototype.$tag = 1;
function _M0TP36mizchi6kagura7light3d16DirectionalLight(param0, param1, param2) {
  this.direction = param0;
  this.color = param1;
  this.intensity = param2;
}
function _M0TP36mizchi6kagura7light3d12AmbientLight(param0, param1) {
  this.color = param0;
  this.intensity = param1;
}
function _M0TP36mizchi6kagura7light3d19LightingEnvironment(param0, param1, param2, param3) {
  this.directional = param0;
  this.ambient = param1;
  this.point_lights = param2;
  this.spot_lights = param3;
}
function _M0TP36mizchi6kagura6mesh3d12MeshBounds3D(param0, param1, param2, param3, param4, param5) {
  this.min_x = param0;
  this.min_y = param1;
  this.min_z = param2;
  this.max_x = param3;
  this.max_y = param4;
  this.max_z = param5;
}
function _M0TP36mizchi6kagura6mesh3d6Mesh3D(param0, param1, param2) {
  this.vertex_data = param0;
  this.indices = param1;
  this.bounds = param2;
}
function _M0TP36mizchi6kagura11transform3d11Transform3D(param0, param1, param2) {
  this.position = param0;
  this.rotation = param1;
  this.scale = param2;
}
function _M0TPC13ref3RefGfE(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura5audio11AudioFormat(param0, param1, param2) {
  this.sample_rate = param0;
  this.channels = param1;
  this.bits_per_sample = param2;
}
function _M0TP36mizchi6kagura5audio16AudioOutputHooks(param0, param1, param2, param3, param4, param5) {
  this.try_initialize = param0;
  this.write_frames = param1;
  this.suspend = param2;
  this.resume_playback = param3;
  this.close = param4;
  this.output_latency = param5;
}
function _M0TP36mizchi6kagura9inpututil15TouchInputState(param0, param1, param2, param3, param4) {
  this.prev_touch_ids = param0;
  this.touch_ids = param1;
  this.just_pressed_touch_ids = param2;
  this.just_released_touch_ids = param3;
  this.durations = param4;
}
function _M0TP36mizchi6kagura9inpututil18TouchDurationEntry(param0, param1) {
  this.id = param0;
  this.duration = param1;
}
function _M0TP36mizchi6kagura9inpututil13KeyInputState(param0, param1, param2, param3, param4) {
  this.prev_pressed_keys = param0;
  this.pressed_keys = param1;
  this.just_pressed_keys = param2;
  this.just_released_keys = param3;
  this.durations = param4;
}
function _M0TP36mizchi6kagura9inpututil21MouseButtonInputState(param0, param1, param2, param3, param4) {
  this.prev_pressed_buttons = param0;
  this.pressed_buttons = param1;
  this.just_pressed_buttons = param2;
  this.just_released_buttons = param3;
  this.durations = param4;
}
function _M0TP36mizchi6kagura9inpututil16KeyDurationEntry(param0, param1) {
  this.key = param0;
  this.duration = param1;
}
function _M0TP36mizchi6kagura9inpututil24MouseButtonDurationEntry(param0, param1) {
  this.button = param0;
  this.duration = param1;
}
function _M0TP36mizchi6kagura9inpututil11InputHelper(param0, param1, param2) {
  this.key_state = param0;
  this.mouse_state = param1;
  this.touch_state = param2;
}
const _M0FP36mizchi6kagura6engine29js__request__animation__frame = (f) => { requestAnimationFrame(() => f()); };
const _M0FP36mizchi6kagura6engine20js__on__beforeunload = (f) => { window.addEventListener("beforeunload", () => f()); };
const _M0FP36mizchi6kagura6engine20js__performance__now = () => (globalThis.performance?.now?.() ?? Date.now());
function _M0TP36mizchi6kagura6engine13EngineContext(param0, param1, param2, param3) {
  this.dst = param0;
  this.shader = param1;
  this.screen_w = param2;
  this.screen_h = param3;
}
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4Some.prototype.$tag = 1;
function _M0TP36mizchi6kagura7scene3d5Plane(param0, param1, param2, param3) {
  this.nx = param0;
  this.ny = param1;
  this.nz = param2;
  this.d = param3;
}
function _M0TP36mizchi6kagura7scene3d7Frustum(param0) {
  this.planes = param0;
}
function _M0TP36mizchi6kagura7scene3d8Object3D(param0, param1, param2, param3, param4, param5) {
  this.mesh = param0;
  this.transform = param1;
  this.color = param2;
  this.material = param3;
  this.sort_bias = param4;
  this.skinning = param5;
}
function _M0TP36mizchi6kagura7scene3d7Scene3D(param0, param1, param2) {
  this.objects = param0;
  this.camera = param1;
  this.lighting = param2;
}
function _M0TP36mizchi6kagura4text13FontLoadHooks(param0) {
  this.load_font_data = param0;
}
function _M0TPC13ref3RefGORP26mizchi19web__runtime__hooks21SourceImageCacheEntryE(param0) {
  this.val = param0;
}
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
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__ = new _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None();
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGdE4None() {}
_M0DTPC16option6OptionGdE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGdE4None__ = new _M0DTPC16option6OptionGdE4None();
function _M0DTPC16option6OptionGdE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGdE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__ = new _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None();
function _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4Some.prototype.$tag = 1;
function _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None() {}
_M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__ = new _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None();
function _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4Some.prototype.$tag = 1;
function _M0TP26mizchi12postfx__demo9DemoState(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16, param17) {
  this.cube_mesh = param0;
  this.sphere_mesh = param1;
  this.ground_mesh = param2;
  this.scene_target = param3;
  this.bloom_a = param4;
  this.bloom_b = param5;
  this.post_target = param6;
  this.shader3d = param7;
  this.bloom_threshold_sh = param8;
  this.bloom_hblur_sh = param9;
  this.bloom_vblur_sh = param10;
  this.bloom_composite_sh = param11;
  this.fxaa_sh = param12;
  this.tonemap_sh = param13;
  this.camera = param14;
  this.lighting = param15;
  this.input = param16;
  this.frame = param17;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char };
function _M0FP15Error10to__string(_e) {
  return $panic();
}
const _M0FPC15float10min__value = $f32_reinterpret_i32(-8388609);
const _M0FPC15float10max__value = $f32_reinterpret_i32(2139095039);
const _M0FPC15float14not__a__number = $f32_reinterpret_i32(2143289344);
const _M0FP36mizchi6kagura6mesh3d16vertex3d__stride = 8;
const _M0FP36mizchi6kagura6draw3d10max__bones = 64;
const _M0FP26mizchi12postfx__demo9screen__h = 480;
const _M0FP26mizchi12postfx__demo9screen__w = 640;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP26mizchi19web__runtime__hooks21web__canvas__selector = _M0MPC13ref3Ref3newGsE("#app");
const _M0FP26mizchi19web__runtime__hooks21web__hooks__installed = _M0MPC13ref3Ref3newGbE(false);
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FPB33brute__force__find_2econstr_2f182 = 0;
const _M0FPB43boyer__moore__horspool__find_2econstr_2f168 = 0;
const _M0FP26mizchi19web__runtime__hooks20source__image__cache = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE([]);
const _M0FP26mizchi19web__runtime__hooks19gpu__texture__dirty = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE([]);
const _M0FP36mizchi6kagura3gfx20web__graphics__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx29default__web__graphics__hooks());
const _M0FP26mizchi19web__runtime__hooks27synced__source__generations = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE([]);
const _M0FP36mizchi6kagura4text17font__load__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura4text26default__font__load__hooks());
const _M0FP36mizchi6kagura8platform18web__canvas__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura8platform27default__web__canvas__hooks());
(() => {
  _M0FP36mizchi6kagura6engine21set__lifecycle__hooks(new _M0TP36mizchi6kagura6engine14LifecycleHooks((canvas, _title) => {
    _M0FP26mizchi19web__runtime__hooks7install(canvas);
  }, () => {
    _M0FP26mizchi19web__runtime__hooks8shutdown();
  }));
})();
const _M0FPC14math34trig__reduce_2etwo__over__pi_2f565 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
function _M0FPC15abort5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(msg) {
  return $panic();
}
function _M0FPC15abort5abortGuE(msg) {
  $panic();
}
function _M0FPB5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(string, loc) {
  return _M0FPC15abort5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0FPB5abortGuE(string, loc) {
  _M0FPC15abort5abortGuE(`${_M0IPC16string6StringPB4Show10to__string(string)}\n  at ${_M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(loc)}\n`);
}
function _M0MPB13StringBuilder11new_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0MPC15array5Array2atGiE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGRP36mizchi6kagura7scene3d8Object3DE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPB13SourceLocRepr5parse(repr) {
  const _bind = new _M0TPC16string10StringView(repr, 0, repr.length);
  const _data = _M0MPC16string10StringView4data(_bind);
  const _start = _M0MPC16string10StringView13start__offset(_bind);
  const _end = _start + _M0MPC16string10StringView6length(_bind) | 0;
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
      if (_M0MPC16string6String20unsafe__charcode__at(_data, _cursor) === 64) {
        _cursor = _cursor + 1 | 0;
        _L$2: while (true) {
          tag_0 = _cursor;
          if (_cursor < _end) {
            const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
            _cursor = _cursor + 1 | 0;
            if (next_char === 58) {
              if (_cursor < _end) {
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
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  tag_1 = _cursor;
                                  tag_2_1 = tag_2;
                                  tag_2 = _cursor;
                                  tag_3 = _cursor;
                                  if (_cursor < _end) {
                                    _L$7: {
                                      const next_char$3 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                                      _cursor = _cursor + 1 | 0;
                                      if (next_char$3 < 48) {
                                        if (next_char$3 === 45) {
                                          break _L$4;
                                        } else {
                                          break _L$7;
                                        }
                                      } else {
                                        if (next_char$3 > 57) {
                                          if (next_char$3 < 59) {
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
                                if (next_char$2 > 58) {
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
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
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
                            const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                            _cursor = _cursor + 1 | 0;
                            if (next_char$2 === 58) {
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
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 4;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
                                  break _L$6;
                                } else {
                                  tag_1_2 = tag_1_1;
                                  tag_1_1 = tag_1;
                                  tag_1 = _cursor;
                                  if (_cursor < _end) {
                                    _L$7: {
                                      const next_char$3 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                                      _cursor = _cursor + 1 | 0;
                                      if (next_char$3 < 58) {
                                        if (next_char$3 < 48) {
                                          break _L$7;
                                        } else {
                                          tag_1 = _cursor;
                                          tag_2_1 = tag_2;
                                          tag_2 = _cursor;
                                          if (_cursor < _end) {
                                            _L$8: {
                                              const next_char$4 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                                              _cursor = _cursor + 1 | 0;
                                              if (next_char$4 < 58) {
                                                if (next_char$4 < 48) {
                                                  break _L$8;
                                                } else {
                                                  _tmp = 5;
                                                  continue _L$3;
                                                }
                                              } else {
                                                if (next_char$4 > 58) {
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
                                        if (next_char$3 > 58) {
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
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 5;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
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
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 48) {
                                if (next_char$2 === 45) {
                                  break _L$4;
                                } else {
                                  break _L$6;
                                }
                              } else {
                                if (next_char$2 > 57) {
                                  if (next_char$2 < 59) {
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
                              const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                              _cursor = _cursor + 1 | 0;
                              if (next_char$2 < 58) {
                                if (next_char$2 < 48) {
                                  break _L$6;
                                } else {
                                  _tmp = 2;
                                  continue _L$3;
                                }
                              } else {
                                if (next_char$2 > 58) {
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
                      const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                      _cursor = _cursor + 1 | 0;
                      if (next_char$2 < 58) {
                        if (next_char$2 < 48) {
                          break _L$5;
                        } else {
                          _tmp = 4;
                          continue;
                        }
                      } else {
                        if (next_char$2 > 58) {
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
    const start_line = _M0MPC16string6String4view(_data, match_tag_saver_1 + 1 | 0, match_tag_saver_2);
    const start_column = _M0MPC16string6String4view(_data, match_tag_saver_2 + 1 | 0, match_tag_saver_3);
    const pkg = _M0MPC16string6String4view(_data, _start + 1 | 0, match_tag_saver_0);
    const filename = _M0MPC16string6String4view(_data, match_tag_saver_0 + 1 | 0, match_tag_saver_1);
    const end_line = _M0MPC16string6String4view(_data, match_tag_saver_3 + 1 | 0, match_tag_saver_4);
    const end_column = _M0MPC16string6String4view(_data, match_tag_saver_4 + 1 | 0, match_end);
    return new _M0TPB13SourceLocRepr(pkg, filename, start_line, start_column, end_line, end_column);
  } else {
    return $panic();
  }
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0MPB7MyInt647to__int(self) {
  return self.lo;
}
function _M0IPC16uint166UInt16PB2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implPB2Eq10not__equalGsE(x, y) {
  return !(x === y);
}
function _M0IP016_24default__implPB2Eq10not__equalGlE(x, y) {
  return !_M0IPC15int645Int64PB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(x, y) {
  return !_M0IP26mizchi5audio10VoiceStatePB2Eq5equal(x, y);
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) >= 0;
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
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
    if (start$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start$2))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start$2, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0MPC16string10StringView4data(self) {
  return self.str;
}
function _M0MPC16string10StringView6length(self) {
  return self.end - self.start | 0;
}
function _M0MPC16string10StringView13start__offset(self) {
  return self.start;
}
function _M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC15error5ErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGRPB9SourceLocE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPB9SourceLocPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0IP016_24default__implPB4Show10to__stringGiE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC13int3IntPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
}
function _M0IPC16string10StringViewPB4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? new _M0TPC16string10StringView(self, start_offset, end_offset$2) : _M0FPB5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE("Invalid index for View", "@moonbitlang/core/builtin:stringview.mbt:399:5-399:36");
}
function _M0MPC16string6String4view(self, start_offset$46$opt, end_offset) {
  let start_offset;
  if (start_offset$46$opt === undefined) {
    start_offset = 0;
  } else {
    const _Some = start_offset$46$opt;
    start_offset = _Some;
  }
  return _M0MPC16string6String12view_2einner(self, start_offset, end_offset);
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0IPC16string10StringViewPB4Show10to__string(str)}`;
}
function _M0FPB28boyer__moore__horspool__find(haystack, needle) {
  const haystack_len = _M0MPC16string10StringView6length(haystack);
  const needle_len = _M0MPC16string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      const _bind = needle_len - 1 | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < _bind) {
          const _tmp$2 = _M0MPC16string10StringView11unsafe__get(needle, i) & 255;
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
          const _bind$2 = needle_len - 1 | 0;
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j <= _bind$2) {
              if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = _M0MPC16string10StringView11unsafe__get(haystack, (i + needle_len | 0) - 1 | 0) & 255;
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
    return _M0FPB43boyer__moore__horspool__find_2econstr_2f168;
  }
}
function _M0FPB18brute__force__find(haystack, needle) {
  const haystack_len = _M0MPC16string10StringView6length(haystack);
  const needle_len = _M0MPC16string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = _M0MPC16string10StringView11unsafe__get(needle, 0);
      const forward_len = haystack_len - needle_len | 0;
      let i = 0;
      while (true) {
        if (i <= forward_len) {
          while (true) {
            if (i <= forward_len && _M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i), needle_first)) {
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
                if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
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
    return _M0FPB33brute__force__find_2econstr_2f182;
  }
}
function _M0MPC16string10StringView4find(self, str) {
  return _M0MPC16string10StringView6length(str) <= 4 ? _M0FPB18brute__force__find(self, str) : _M0FPB28boyer__moore__horspool__find(self, str);
}
function _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGiE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGdE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16string10StringView8contains(self, str) {
  const _bind = _M0MPC16string10StringView4find(self, str);
  return !(_bind === undefined);
}
function _M0MPC16string6String8contains(self, str) {
  return _M0MPC16string10StringView8contains(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0IPC13int3IntPB4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0MPC13int3Int18to__string_2einner(self, 10));
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC15array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(self) {
  return self.end - self.start | 0;
}
function _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(self, index) {
  if (index >= 0 && index < (self.end - self.start | 0)) {
    const _tmp = self.buf;
    const _tmp$2 = self.start + index | 0;
    $bound_check(_tmp, _tmp$2);
    return _tmp[_tmp$2];
  } else {
    return _M0FPB5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implPB4Show10to__stringGiE(self.end - self.start | 0)} but the index is ${_M0IP016_24default__implPB4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:mutarrayview.mbt:118:5-120:6");
  }
}
function _M0MPC15array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(self, index, value) {
  if (index >= 0 && index < (self.end - self.start | 0)) {
    const _tmp = self.buf;
    const _tmp$2 = self.start + index | 0;
    $bound_check(_tmp, _tmp$2);
    _tmp[_tmp$2] = value;
    return;
  } else {
    _M0FPB5abortGuE(`index out of bounds: the len is from 0 to ${_M0IP016_24default__implPB4Show10to__stringGiE(self.end - self.start | 0)} but the index is ${_M0IP016_24default__implPB4Show10to__stringGiE(index)}`, "@moonbitlang/core/builtin:mutarrayview.mbt:182:5-184:6");
    return;
  }
}
function _M0MPC15array5Array17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(self, start, end) {
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
    return new _M0TPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEE(_bind, start$2, start$2 + _bind$2 | 0);
  } else {
    return _M0FPB5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE("View index out of bounds", "@moonbitlang/core/builtin:mutarrayview.mbt:258:5-258:38");
  }
}
function _M0MPC15array12MutArrayView17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(self, start, end) {
  const len = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(self);
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
    return new _M0TPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEE(_bind, _bind$2, _bind$2 + _bind$3 | 0);
  } else {
    return _M0FPB5abortGRPB12MutArrayViewGUiRP36mizchi6kagura7scene3d8Object3DEEE("View index out of bounds", "@moonbitlang/core/builtin:mutarrayview.mbt:307:5-307:38");
  }
}
function _M0MPC15array5Array4makeGiE(len, elem) {
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
function _M0MPC15array5Array4makeGdE(len, elem) {
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
function _M0MPC15array5Array3setGiE(self, index, value) {
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
function _M0MPC15array5Array3setGdE(self, index, value) {
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
function _M0MPC15array10FixedArray12fill_2einnerGfE(self, value, start, end) {
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
function _M0MPB7MyInt6414extend__i32__u(value) {
  return new _M0TPB7MyInt64(0, value);
}
function _M0MPC16uint646UInt6412extend__uint(value) {
  return _M0MPB7MyInt6414extend__i32__u(value);
}
function _M0MPC14uint4UInt10to__uint64(self) {
  return _M0MPC16uint646UInt6412extend__uint(self);
}
function _M0MPC16string6String20unsafe__charcode__at(self, idx) {
  return self.charCodeAt(idx);
}
function _M0IPB7MyInt64PB3Mul3mul(self, other) {
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
  return new _M0TPB7MyInt64(c48$5 << 16 | c32$8, c16$5 << 16 | c00$2);
}
function _M0MPB7MyInt644land(self, other) {
  return new _M0TPB7MyInt64(self.hi & other.hi, self.lo & other.lo);
}
function _M0MPB7MyInt643lsr(self, shift) {
  const shift$2 = shift & 63;
  return shift$2 === 0 ? self : shift$2 < 32 ? new _M0TPB7MyInt64(self.hi >>> shift$2 | 0, self.lo >>> shift$2 | 0 | self.hi << (32 - shift$2 | 0)) : new _M0TPB7MyInt64(0, self.hi >>> (shift$2 - 32 | 0) | 0);
}
function _M0IPB7MyInt64PB2Eq5equal(self, other) {
  return self.hi === other.hi && self.lo === other.lo;
}
function _M0MPB7MyInt648to__uint(self) {
  return self.lo;
}
function _M0IPC15int645Int64PB6BitAnd4land(self, other) {
  return _M0MPB7MyInt644land(self, other);
}
function _M0IPC15int645Int64PB2Eq5equal(self, other) {
  return _M0IPB7MyInt64PB2Eq5equal(self, other);
}
function _M0MPC15int645Int647to__int(self) {
  return _M0MPB7MyInt647to__int(self);
}
function _M0MPC16double6Double22reinterpret__as__int64(self) {
  return _M0MPB7MyInt6419reinterpret__double(self);
}
function _M0IPC16uint646UInt64PB3Mul3mul(self, other) {
  return _M0IPB7MyInt64PB3Mul3mul(self, other);
}
function _M0MPC16uint646UInt648to__uint(self) {
  return _M0MPB7MyInt648to__uint(self);
}
function _M0IPC16uint646UInt64PB6BitAnd4land(self, other) {
  return _M0MPB7MyInt644land(self, other);
}
function _M0IPC16uint646UInt64PB3Shr3shr(self, shift) {
  return _M0MPB7MyInt643lsr(self, shift);
}
function _M0MPC16double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0FPB7printlnGsE(input) {
  console.log(_M0IPC16string6StringPB4Show10to__string(input));
}
function _M0IPB13SourceLocReprPB4Show6output(self, logger) {
  const pkg = self.pkg;
  const _data = _M0MPC16string10StringView4data(pkg);
  const _start = _M0MPC16string10StringView13start__offset(pkg);
  const _end = _start + _M0MPC16string10StringView6length(pkg) | 0;
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
          const next_char = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
          _cursor = _cursor + 1 | 0;
          if (next_char === 47) {
            _L$4: while (true) {
              tag_0 = _cursor;
              if (_cursor < _end) {
                const next_char$2 = _M0MPC16string6String20unsafe__charcode__at(_data, _cursor);
                _cursor = _cursor + 1 | 0;
                if (next_char$2 === 47) {
                  while (true) {
                    if (_cursor < _end) {
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
      const package_name = _M0MPC16string6String4view(_data, match_tag_saver_0 + 1 | 0, match_end);
      const module_name = _M0MPC16string6String4view(_data, _start, match_tag_saver_0);
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
function _M0IPB9SourceLocPB4Show6output(self, logger) {
  _M0IPB13SourceLocReprPB4Show6output(_M0MPB13SourceLocRepr5parse(self), logger);
}
function _M0FPB7minimum(x, y) {
  return x > y ? y : x;
}
function _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, j) {
  const temp = _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i);
  _M0MPC15array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j));
  _M0MPC15array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, temp);
}
function _M0MPC15array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, start, end) {
  return _M0MPC15array12MutArrayView17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, start, end);
}
function _M0MPC15array12MutArrayView14rev__in__placeGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) {
  const len = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  if (2 === 0) {
    $panic();
  }
  const mid_len = len / 2 | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < mid_len) {
      const j = (len - i | 0) - 1 | 0;
      const temp = _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i);
      _M0MPC15array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j));
      _M0MPC15array12MutArrayView3setGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, temp);
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB17fixed__get__limit(len) {
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
function _M0FPB23fixed__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  const _bind = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      let _tmp$2 = i;
      while (true) {
        const j = _tmp$2;
        if (j > 0 && cmp(_M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j - 1 | 0), _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j)) > 0) {
          _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, j - 1 | 0);
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
function _M0FPB40fixed__choose__pivot__by_2esort__2_2f415(_env, a, b) {
  const swaps = _env._2;
  const arr = _env._1;
  const cmp = _env._0;
  if (cmp(_M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, a), _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, b)) > 0) {
    _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, a, b);
    swaps.val = swaps.val + 1 | 0;
    return;
  } else {
    return;
  }
}
function _M0FPB40fixed__choose__pivot__by_2esort__3_2f416(_env, a, b, c) {
  _M0FPB40fixed__choose__pivot__by_2esort__2_2f415(_env, a, b);
  _M0FPB40fixed__choose__pivot__by_2esort__2_2f415(_env, b, c);
  _M0FPB40fixed__choose__pivot__by_2esort__2_2f415(_env, a, b);
}
function _M0FPB24fixed__choose__pivot__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  const len = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  const swaps = new _M0TPC13ref3RefGiE(0);
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
    const _env = { _0: cmp, _1: arr, _2: swaps };
    if (len > 50) {
      _M0FPB40fixed__choose__pivot__by_2esort__3_2f416(_env, a - 1 | 0, a, a + 1 | 0);
      _M0FPB40fixed__choose__pivot__by_2esort__3_2f416(_env, b - 1 | 0, b, b + 1 | 0);
      _M0FPB40fixed__choose__pivot__by_2esort__3_2f416(_env, c - 1 | 0, c, c + 1 | 0);
    }
    _M0FPB40fixed__choose__pivot__by_2esort__3_2f416(_env, a, b, c);
  }
  if (swaps.val === 12) {
    _M0MPC15array12MutArrayView14rev__in__placeGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
    return { _0: (len - b | 0) - 1 | 0, _1: true };
  } else {
    return { _0: b, _1: swaps.val === 0 };
  }
}
function _M0FPB21fixed__sift__down__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, index, cmp) {
  let index$2 = index;
  const len = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  let child = (Math.imul(index$2, 2) | 0) + 1 | 0;
  while (true) {
    if (child < len) {
      if ((child + 1 | 0) < len && cmp(_M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, child), _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, child + 1 | 0)) < 0) {
        child = child + 1 | 0;
      }
      if (cmp(_M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, index$2), _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, child)) >= 0) {
        return undefined;
      }
      _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, index$2, child);
      index$2 = child;
      child = (Math.imul(index$2, 2) | 0) + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB21fixed__heap__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  const len = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  if (2 === 0) {
    $panic();
  }
  const _bind = len / 2 | 0;
  let _tmp = _bind - 1 | 0;
  while (true) {
    const i = _tmp;
    if (i >= 0) {
      _M0FPB21fixed__sift__down__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, cmp);
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
      _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, 0, i);
      _M0FPB21fixed__sift__down__byGUiRP36mizchi6kagura7scene3d8Object3DEE(_M0MPC15array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, 0, i), 0, cmp);
      _tmp$2 = i - 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FPB20fixed__partition__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp, pivot_index) {
  _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, pivot_index, _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0);
  const pivot = _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0);
  let i = 0;
  let partitioned = true;
  const _bind = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0;
  let _tmp = 0;
  while (true) {
    const j = _tmp;
    if (j < _bind) {
      if (cmp(_M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j), pivot) < 0) {
        if (i !== j) {
          _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, j);
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
  _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, i, _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr) - 1 | 0);
  return { _0: i, _1: partitioned };
}
function _M0FPB28fixed__try__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp) {
  let tries = 0;
  const _bind = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr);
  let _tmp = 1;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      let sorted = true;
      let _tmp$2 = i;
      while (true) {
        const j = _tmp$2;
        if (j > 0 && cmp(_M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j - 1 | 0), _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j)) > 0) {
          sorted = false;
          _M0MPC15array12MutArrayView4swapGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, j, j - 1 | 0);
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
function _M0FPB22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr, cmp, pred, limit) {
  let limit$2 = limit;
  let arr$2 = arr;
  let pred$2 = pred;
  let was_partitioned = true;
  let balanced = true;
  while (true) {
    const len = _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2);
    if (len <= 16) {
      if (len >= 2) {
        _M0FPB23fixed__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp);
      }
      return undefined;
    }
    if (limit$2 === 0) {
      _M0FPB21fixed__heap__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp);
      return undefined;
    }
    const _bind = _M0FPB24fixed__choose__pivot__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp);
    const _pivot_index = _bind._0;
    const _likely_sorted = _bind._1;
    if (was_partitioned && (balanced && _likely_sorted)) {
      if (_M0FPB28fixed__try__bubble__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp)) {
        return undefined;
      }
    }
    const _bind$2 = _M0FPB20fixed__partition__byGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, cmp, _pivot_index);
    const _pivot = _bind$2._0;
    const _partitioned = _bind$2._1;
    was_partitioned = _partitioned;
    const _tmp = _M0FPB7minimum(_pivot, len - _pivot | 0);
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
      if (cmp(_pred, _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot)) === 0) {
        let i = _pivot;
        while (true) {
          if (i < len && cmp(_pred, _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, i)) === 0) {
            i = i + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        arr$2 = _M0MPC15array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, i, len);
        continue;
      }
    }
    const left = _M0MPC15array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, 0, _pivot);
    const right = _M0MPC15array12MutArrayView5sliceGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot + 1 | 0, len);
    if (_M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(left) < _M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(right)) {
      _M0FPB22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(left, cmp, pred$2, limit$2);
      pred$2 = _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot);
      arr$2 = right;
    } else {
      _M0FPB22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(right, cmp, _M0MPC15array12MutArrayView2atGUiRP36mizchi6kagura7scene3d8Object3DEE(arr$2, _pivot), limit$2);
      arr$2 = left;
    }
    continue;
  }
}
function _M0MPC15array12MutArrayView8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(self, cmp) {
  _M0FPB22fixed__quick__sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(self, cmp, undefined, _M0FPB17fixed__get__limit(_M0MPC15array12MutArrayView6lengthGUiRP36mizchi6kagura7scene3d8Object3DEE(self)));
}
function _M0MPC15array5Array8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(self, cmp) {
  _M0MPC15array12MutArrayView8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(_M0MPC15array5Array17mut__view_2einnerGUiRP36mizchi6kagura7scene3d8Object3DEE(self, 0, undefined), cmp);
}
function _M0MPC15array5Array6filterGRP26mizchi5audio5VoiceE(self, f) {
  const arr = [];
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
      if (f(v)) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(arr, v);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self, f) {
  const arr = [];
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const v = self[_];
      if (f(v)) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(arr, v);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15float5Float7to__int(self) {
  return Math.fround(self !== self) ? 0 : Math.fround(self >= Math.fround(2147483647)) ? 2147483647 : Math.fround(self <= Math.fround(-2147483648)) ? -2147483648 : self | 0;
}
function _M0MPC15float5Float12is__neg__inf(self) {
  return Math.fround(self < _M0FPC15float10min__value);
}
function _M0MPC15float5Float12is__pos__inf(self) {
  return Math.fround(self > _M0FPC15float10max__value);
}
function _M0MPC15float5Float7is__inf(self) {
  return _M0MPC15float5Float12is__pos__inf(self) || _M0MPC15float5Float12is__neg__inf(self);
}
function _M0MPC15float5Float7is__nan(self) {
  return Math.fround(self !== self);
}
function _M0MPC13ref3Ref3newGiE(x) {
  return new _M0TPC13ref3RefGiE(x);
}
function _M0MPC13ref3Ref3newGdE(x) {
  return new _M0TPC13ref3RefGdE(x);
}
function _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(x) {
  return new _M0TPC13ref3RefGORP36mizchi6kagura6engine14LifecycleHooksE(x);
}
function _M0MPC13ref3Ref3newGbE(x) {
  return new _M0TPC13ref3RefGbE(x);
}
function _M0MPC13ref3Ref3newGsE(x) {
  return new _M0TPC13ref3RefGsE(x);
}
function _M0IPC15error5ErrorPB4Show6output(self, logger) {
  logger.method_table.method_0(logger.self, _M0FP15Error10to__string(self));
}
function _M0FPC14math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FPC14math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0FPC14math3tan(_tmp) {
  return Math.tan(_tmp);
}
function _M0FPC14math4mulh(a, b) {
  const a$2 = _M0MPC14uint4UInt10to__uint64(a);
  const b$2 = _M0MPC14uint4UInt10to__uint64(b);
  const res = _M0IPC16uint646UInt64PB3Mul3mul(a$2, b$2);
  return _M0MPC16uint646UInt648to__uint(_M0IPC16uint646UInt64PB3Shr3shr(res, 32));
}
function _M0FPC14math3mul(a, b) {
  const a$2 = _M0MPC14uint4UInt10to__uint64(a);
  const b$2 = _M0MPC14uint4UInt10to__uint64(b);
  const res = _M0IPC16uint646UInt64PB3Mul3mul(a$2, b$2);
  return { _0: _M0MPC16uint646UInt648to__uint(_M0IPC16uint646UInt64PB3Shr3shr(res, 32)), _1: _M0MPC16uint646UInt648to__uint(res) };
}
function _M0FPC14math12trig__reduce(x, switch_over) {
  if (Math.fround(Math.fround(Math.abs(x)) <= switch_over)) {
    let j = Math.fround(0);
    let r = Math.fround(0);
    j = Math.fround(Math.fround(x * $f32_reinterpret_i32(1059256707)) + $f32_reinterpret_i32(1262485504));
    j = Math.fround($i32_reinterpret_f32(j) - 1262485504 | 0);
    r = Math.fround(x - Math.fround(j * $f32_reinterpret_i32(1070141312)));
    r = Math.fround(r - Math.fround(j * $f32_reinterpret_i32(926237760)));
    r = Math.fround(r - Math.fround(j * $f32_reinterpret_i32(741630234)));
    return { _0: r, _1: _M0MPC15float5Float7to__int(j) };
  }
  const xispos = Math.fround(x > Math.fround(0));
  let exp = ($i32_reinterpret_f32(x) >> 23 & 255) - 126 | 0;
  const ix = ($i32_reinterpret_f32(x) & 8388607) << 8 | -2147483648;
  const ind = exp >> 5;
  exp = exp & 31;
  let hi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f565, ind);
  let mi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f565, ind + 1 | 0);
  let lo = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f565, ind + 2 | 0);
  const tp = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f565, ind + 3 | 0);
  if (exp > 0) {
    hi = hi << exp | (mi >>> (32 - exp | 0) | 0);
    mi = mi << exp | (lo >>> (32 - exp | 0) | 0);
    lo = lo << exp | (tp >>> (32 - exp | 0) | 0);
  }
  const _bind = _M0FPC14math3mul(ix, lo);
  const _h = _bind._0;
  const _l = _bind._1;
  const phi = (_h >>> 0) + ((_l >>> 0 < _l >>> 0 ? 1 : 0) >>> 0) | 0;
  const _bind$2 = _M0FPC14math3mul(ix, mi);
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
  phi$3 = _M0FPC14math4mulh(phi$3, -921707870);
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
function _M0FPC14math10sinf__poly(x) {
  const s = Math.fround(x * x);
  let r = $f32_reinterpret_i32(910184448);
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(961557638));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1007192257));
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(1042983595));
  const t = Math.fround(x * s);
  r = Math.fround(Math.fround(r * t) + x);
  return r;
}
function _M0FPC14math10cosf__poly(x) {
  const s = Math.fround(x * x);
  let r = $f32_reinterpret_i32(936198144);
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(985007997));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1026206376));
  r = Math.fround(Math.fround(r * s) - $f32_reinterpret_i32(1056964608));
  r = Math.fround(Math.fround(r * s) + $f32_reinterpret_i32(1065353216));
  return r;
}
function _M0FPC14math14sin__cos__core(x, q) {
  let r = (q & 1) !== 0 ? _M0FPC14math10cosf__poly(x) : _M0FPC14math10sinf__poly(x);
  if ((q & 2) !== 0) {
    r = -r;
  }
  return r;
}
function _M0FPC14math4sinf(x) {
  if (_M0MPC15float5Float7is__nan(x) || _M0MPC15float5Float7is__inf(x)) {
    return _M0FPC15float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return x;
  }
  const _bind = _M0FPC14math12trig__reduce(x, Math.fround(201.15625));
  const _x = _bind._0;
  const _q = _bind._1;
  return _M0FPC14math14sin__cos__core(_x, _q);
}
function _M0FPC14math4cosf(x) {
  if (_M0MPC15float5Float7is__nan(x) || _M0MPC15float5Float7is__inf(x)) {
    return _M0FPC15float14not__a__number;
  }
  if (Math.fround(x === Math.fround(0))) {
    return Math.fround(1);
  }
  const _bind = _M0FPC14math12trig__reduce(x, Math.fround(142.90625));
  const _x = _bind._0;
  const _q = _bind._1;
  return _M0FPC14math14sin__cos__core(_x, _q + 1 | 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33new(x, y, z) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(x, y, z);
}
function _M0MP36mizchi6kagura6math3d4Vec34zero() {
  return new _M0TP36mizchi6kagura6math3d4Vec3(0, 0, 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33one() {
  return new _M0TP36mizchi6kagura6math3d4Vec3(1, 1, 1);
}
function _M0MP36mizchi6kagura6math3d4Vec37unit__y() {
  return new _M0TP36mizchi6kagura6math3d4Vec3(0, 1, 0);
}
function _M0MP36mizchi6kagura6math3d4Vec33add(self, other) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.x + other.x, self.y + other.y, self.z + other.z);
}
function _M0MP36mizchi6kagura6math3d4Vec33sub(self, other) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.x - other.x, self.y - other.y, self.z - other.z);
}
function _M0MP36mizchi6kagura6math3d4Vec35scale(self, s) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.x * s, self.y * s, self.z * s);
}
function _M0MP36mizchi6kagura6math3d4Vec33dot(self, other) {
  return self.x * other.x + self.y * other.y + self.z * other.z;
}
function _M0MP36mizchi6kagura6math3d4Vec35cross(self, other) {
  return new _M0TP36mizchi6kagura6math3d4Vec3(self.y * other.z - self.z * other.y, self.z * other.x - self.x * other.z, self.x * other.y - self.y * other.x);
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
function _M0MP36mizchi6kagura6math3d4Vec43new(x, y, z, w) {
  return new _M0TP36mizchi6kagura6math3d4Vec4(x, y, z, w);
}
function _M0MP36mizchi6kagura6math3d4Mat48identity() {
  return new _M0TP36mizchi6kagura6math3d4Mat4([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
}
function _M0MP36mizchi6kagura6math3d4Mat44zero() {
  return new _M0TP36mizchi6kagura6math3d4Mat4([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
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
  const _bind = 0;
  const _bind$2 = 4;
  let _tmp = _bind;
  while (true) {
    const col = _tmp;
    if (col < _bind$2) {
      const _bind$3 = 0;
      const _bind$4 = 4;
      let _tmp$2 = _bind$3;
      while (true) {
        const row = _tmp$2;
        if (row < _bind$4) {
          const sum = new _M0TPC13ref3RefGdE(0);
          const _bind$5 = 0;
          const _bind$6 = 4;
          let _tmp$3 = _bind$5;
          while (true) {
            const k = _tmp$3;
            if (k < _bind$6) {
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
  const _bind = 0;
  const _bind$2 = 4;
  let _tmp = _bind;
  while (true) {
    const row = _tmp;
    if (row < _bind$2) {
      const _bind$3 = 0;
      const _bind$4 = 4;
      let _tmp$2 = _bind$3;
      while (true) {
        const col = _tmp$2;
        if (col < _bind$4) {
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
  const f = 1 / _M0FPC14math3tan(fov_y_rad / 2);
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
  return new _M0TP36mizchi6kagura6math3d10Quaternion(0, 0, 0, 1);
}
function _M0MP36mizchi6kagura6math3d10Quaternion17from__axis__angle(axis, angle_rad) {
  const half = angle_rad / 2;
  const s = _M0FPC14math3sin(half);
  const a = _M0MP36mizchi6kagura6math3d4Vec39normalize(axis);
  return new _M0TP36mizchi6kagura6math3d10Quaternion(a.x * s, a.y * s, a.z * s, _M0FPC14math3cos(half));
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
function _M0MP36mizchi6kagura8camera3d8Camera3D16new__perspective(position, target, up, fov_y_rad, aspect, near, far) {
  return new _M0TP36mizchi6kagura8camera3d8Camera3D(position, target, up, fov_y_rad, aspect, near, far, _M0DTP36mizchi6kagura8camera3d14ProjectionMode11Perspective__);
}
function _M0FP36mizchi6kagura8camera3d12clamp__pitch(pitch) {
  const limit = 1.56079632679489655;
  return pitch > limit ? limit : pitch < -limit ? -limit : pitch;
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(target, distance, yaw, pitch, fov_y_rad, aspect, near, far) {
  return new _M0TP36mizchi6kagura8camera3d11OrbitCamera(target, distance, yaw, _M0FP36mizchi6kagura8camera3d12clamp__pitch(pitch), fov_y_rad, aspect, near, far);
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self, delta_yaw, delta_pitch) {
  return new _M0TP36mizchi6kagura8camera3d11OrbitCamera(self.target, self.distance, self.yaw + delta_yaw, _M0FP36mizchi6kagura8camera3d12clamp__pitch(self.pitch + delta_pitch), self.fov_y_rad, self.aspect, self.near, self.far);
}
function _M0MP36mizchi6kagura8camera3d11OrbitCamera8position(self) {
  const cp = _M0FPC14math3cos(self.pitch);
  const sp = _M0FPC14math3sin(self.pitch);
  const cy = _M0FPC14math3cos(self.yaw);
  const sy = _M0FPC14math3sin(self.yaw);
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
  return new _M0TP36mizchi6kagura4core11OutsideSize(width, height);
}
function _M0FP36mizchi6kagura4core17new__touch__point(id, x, y) {
  return new _M0TP36mizchi6kagura4core10TouchPoint(id, x, y, 3);
}
function _M0FP36mizchi6kagura4core22new__gamepad__snapshot(id, axes, pressed_buttons) {
  return new _M0TP36mizchi6kagura4core15GamepadSnapshot(id, axes, pressed_buttons);
}
function _M0FP36mizchi6kagura4core26new__input__snapshot__full(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, pressed_mouse_buttons, touches, gamepads) {
  return new _M0TP36mizchi6kagura4core13InputSnapshot(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, pressed_mouse_buttons, touches, gamepads);
}
function _M0FP36mizchi6kagura4core20new__input__snapshot(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys) {
  return _M0FP36mizchi6kagura4core26new__input__snapshot__full(cursor_x, cursor_y, wheel_x, wheel_y, pressed_keys, [], [], []);
}
function _M0FP36mizchi6kagura4core22empty__input__snapshot() {
  return _M0FP36mizchi6kagura4core20new__input__snapshot(0, 0, 0, 0, []);
}
function _M0FP36mizchi6kagura8platform23new__web__canvas__hooks(try_initialize, poll, should_close, outside_size, current_surface, capture_input, set_fullscreen, is_fullscreen, set_cursor_mode, cursor_mode, set_device_scale_factor, device_scale_factor, set_vsync_enabled, is_vsync_enabled, close_window, request_attention, set_mouse_touch_fallback, mouse_touch_fallback_enabled, fullscreen_request_status, cursor_mode_request_status) {
  return new _M0TP36mizchi6kagura8platform14WebCanvasHooks(try_initialize, poll, should_close, outside_size, current_surface, capture_input, set_fullscreen, is_fullscreen, set_cursor_mode, cursor_mode, set_device_scale_factor, device_scale_factor, set_vsync_enabled, is_vsync_enabled, close_window, request_attention, set_mouse_touch_fallback, mouse_touch_fallback_enabled, fullscreen_request_status, cursor_mode_request_status);
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
  return new _M0TP36mizchi6kagura8platform12SurfaceToken(1, 2, options.width, options.height, 1);
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
  return new _M0TP36mizchi6kagura8platform12SurfaceToken(3, 0, width, height, 1);
}
function _M0FP36mizchi6kagura8platform30create__webgpu__surface__token(opaque_id, width, height, device_scale_factor) {
  return new _M0TP36mizchi6kagura8platform12SurfaceToken(1, opaque_id, width, height, device_scale_factor);
}
function _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform15SurfaceProvider16current__surface(self) {
  return new _M0DTPC16result6ResultGRP36mizchi6kagura8platform12SurfaceTokenRPC15error5ErrorE2Ok(self.web_active ? _M0FP36mizchi6kagura8platform21web__current__surface(self.canvas_selector, self.options) : new _M0TP36mizchi6kagura8platform12SurfaceToken(1, 2, self.options.width, self.options.height, 1));
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
  return new _M0TP36mizchi6kagura8platform13WindowOptions(title, width, height, transparent, resizable, focused);
}
function _M0FP36mizchi6kagura8platform29create__web__canvas__platform(canvas_selector) {
  return new _M0TP36mizchi6kagura8platform17WebCanvasPlatform(canvas_selector, false, 0, 2, false, new _M0TP36mizchi6kagura8platform13WindowOptions("kagura-web", 800, 600, true, true, true), _M0FP36mizchi6kagura4core22empty__input__snapshot(), false, 0, 1, true, false, 0, false, 0, 0);
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
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
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
  const bits = _M0MPC16double6Double22reinterpret__as__int64(v);
  const ubits = bits;
  const sign = _M0MPC15int645Int647to__int(_M0IPC16uint646UInt64PB6BitAnd4land(_M0IPC16uint646UInt64PB3Shr3shr(ubits, 63), $1L));
  const exp = _M0MPC15int645Int647to__int(_M0IPC16uint646UInt64PB6BitAnd4land(_M0IPC16uint646UInt64PB3Shr3shr(ubits, 52), $2047L));
  const mantissa = _M0IPC15int645Int64PB6BitAnd4land(bits, $4503599627370495L);
  if (exp === 2047) {
    return _M0IP016_24default__implPB2Eq10not__equalGlE(mantissa, $0L) ? sign << 31 | 2143289344 : sign << 31 | 2139095040;
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
          const f32_mantissa = _M0MPC15int645Int647to__int(_M0IPC16uint646UInt64PB3Shr3shr(mantissa, 29));
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
  return use_color_m ? "let color_m = mat4x4f(\n    vec4f(1.0, 0.0, 0.0, 0.0),\n    vec4f(0.0, 1.0, 0.0, 0.0),\n    vec4f(0.0, 0.0, 1.0, 0.0),\n    vec4f(0.0, 0.0, 0.0, 1.0),\n  );\n  color = color_m * color;" : "// color matrix disabled";
}
function _M0FP36mizchi6kagura3gfx30build__builtin__shader__source(key) {
  const address_snippet = _M0FP36mizchi6kagura3gfx25builtin__address__snippet(key.address);
  const sample_snippet = _M0FP36mizchi6kagura3gfx24builtin__sample__snippet(key.filter);
  const color_m_snippet = _M0FP36mizchi6kagura3gfx26builtin__color__m__snippet(key.use_color_m);
  const color_m_tag = key.use_color_m ? "on" : "off";
  const header = `// kagura builtin shader\n// filter:${_M0IPC16string6StringPB4Show10to__string(_M0FP36mizchi6kagura3gfx20builtin__filter__tag(key.filter))}\n// address:${_M0IPC16string6StringPB4Show10to__string(_M0FP36mizchi6kagura3gfx21builtin__address__tag(key.address))}\n// color_m:${_M0IPC16string6StringPB4Show10to__string(color_m_tag)}\n`;
  const bindings = "@group(0) @binding(0) var tex: texture_2d<f32>;\n@group(0) @binding(1) var nearest_sampler: sampler;\n@group(0) @binding(2) var linear_sampler: sampler;\n\n";
  const structs = "struct VertexOutput {\n  @builtin(position) pos: vec4f,\n  @location(0) uv: vec2f,\n};\n\n";
  const body = `@fragment\nfn fs_main(in: VertexOutput) -> @location(0) vec4f {\n  let uv = in.uv;\n  ${_M0IPC16string6StringPB4Show10to__string(address_snippet)}\n  var color = ${_M0IPC16string6StringPB4Show10to__string(sample_snippet)};\n  ${_M0IPC16string6StringPB4Show10to__string(color_m_snippet)}\n  return color;\n}\n`;
  return `${header}${bindings}${structs}${body}`;
}
function _M0FP36mizchi6kagura3gfx32default__builtin__shader__source() {
  return _M0FP36mizchi6kagura3gfx30build__builtin__shader__source(new _M0TP36mizchi6kagura3gfx16BuiltinShaderKey(0, 0, false));
}
function _M0FP36mizchi6kagura3gfx16new__dst__region(x, y, width, height, index_count) {
  return new _M0TP36mizchi6kagura3gfx9DstRegion(x, y, width, height, index_count);
}
function _M0FP36mizchi6kagura3gfx10new__color(r, g, b, a) {
  return new _M0TP36mizchi6kagura3gfx5Color(r, g, b, a);
}
function _M0FP36mizchi6kagura3gfx31new__render__pass__desc_2einner(clear_color, clear_enabled, present) {
  return new _M0TP36mizchi6kagura3gfx14RenderPassDesc(clear_color, clear_enabled, present);
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
      return _M0DTP36mizchi6kagura3gfx9BlendMode4Copy__;
    }
    case 1: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha__;
    }
    case 2: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode3Add__;
    }
    case 3: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode8Multiply__;
    }
    default: {
      return _M0DTP36mizchi6kagura3gfx9BlendMode5Alpha__;
    }
  }
}
function _M0FP36mizchi6kagura3gfx18new__image__handle(id, width, height) {
  return new _M0TP36mizchi6kagura3gfx11ImageHandle(id, width, height);
}
function _M0FP36mizchi6kagura3gfx19new__shader__handle(id, source) {
  return new _M0TP36mizchi6kagura3gfx12ShaderHandle(id, source);
}
function _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, dst_regions, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, uniform_dwords, instance_count, resource_cache_key) {
  return new _M0TP36mizchi6kagura3gfx20DrawTrianglesCommand(dst, shader, dst_regions, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, src_image_ids, uniform_dwords, instance_count, resource_cache_key);
}
function _M0FP36mizchi6kagura3gfx25mix__resource__cache__key(seed, value) {
  return ((Math.imul(seed, 16777619) | 0) + value | 0) + 31 | 0;
}
function _M0FP36mizchi6kagura3gfx27build__resource__cache__key(seed, values) {
  const hash = new _M0TPC13ref3RefGiE(seed === 0 ? 146959810 : seed);
  const _bind = values.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const value = values[_];
      hash.val = _M0FP36mizchi6kagura3gfx25mix__resource__cache__key(hash.val, value);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return hash.val === 0 ? 1 : hash.val;
}
function _M0FP36mizchi6kagura3gfx30default__web__on__read__pixels(_active, _kind, _x, _y, _width, _height) {
  return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
}
function _M0FP36mizchi6kagura3gfx25new__web__graphics__hooks(try_initialize, on_begin, on_end, on_draw, on_resize) {
  return new _M0TP36mizchi6kagura3gfx16WebGraphicsHooks(try_initialize, on_begin, on_end, on_draw, on_resize, _M0FP36mizchi6kagura3gfx30default__web__on__read__pixels);
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
  return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
}
function _M0FP36mizchi6kagura3gfx28new__native__graphics__hooks(try_initialize, on_begin, on_end, on_draw, on_resize) {
  return new _M0TP36mizchi6kagura3gfx19NativeGraphicsHooks(try_initialize, on_begin, on_end, on_draw, on_resize, _M0FP36mizchi6kagura3gfx33default__native__on__read__pixels, _M0FP36mizchi6kagura3gfx31default__native__on__new__image);
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
  return new _M0TP36mizchi6kagura3gfx22GraphicsBackendOptions(true, false, true);
}
function _M0FP36mizchi6kagura3gfx23default__clock__now__ms() {
  return 0;
}
function _M0FP36mizchi6kagura3gfx24create__webgpu__graphics(surface, options) {
  return new _M0TP36mizchi6kagura3gfx18StubGraphicsDriver(1, surface.width, surface.height, false, false, false, 0, 0, 0, 0, 0, 0, 0, 0);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10initialize(self) {
  if (self.initialized) {
    return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
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
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
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
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver3end(self, present) {
  if (self.initialized) {
    self.end_count = self.end_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx15native__on__end(self.native_active, present);
    _M0FP36mizchi6kagura3gfx22web__graphics__on__end(self.web_active, self.backend, present);
  }
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver6resize(self, width, height) {
  const next_width = width <= 0 ? 1 : width;
  const next_height = height <= 0 ? 1 : height;
  if (self.width === next_width && self.height === next_height) {
    self.resize_suppressed_count = self.resize_suppressed_count + 1 | 0;
    return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
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
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver10new__image(self, width, height) {
  self.next_id = self.next_id + 1 | 0;
  _M0FP36mizchi6kagura3gfx22native__on__new__image(self.native_active, self.next_id, width, height);
  return new _M0DTPC16result6ResultGRP36mizchi6kagura3gfx11ImageHandleRPC15error5ErrorE2Ok(new _M0TP36mizchi6kagura3gfx11ImageHandle(self.next_id, width, height));
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver11new__shader(self, source) {
  self.next_id = self.next_id + 1 | 0;
  return new _M0DTPC16result6ResultGRP36mizchi6kagura3gfx12ShaderHandleRPC15error5ErrorE2Ok(new _M0TP36mizchi6kagura3gfx12ShaderHandle(self.next_id, source));
}
function _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(self, command) {
  if (self.initialized) {
    self.draw_count = self.draw_count + 1 | 0;
    _M0FP36mizchi6kagura3gfx16native__on__draw(self.native_active, command);
    _M0FP36mizchi6kagura3gfx23web__graphics__on__draw(self.web_active, self.backend, command);
  }
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
}
function _M0MP36mizchi6kagura7light3d16DirectionalLight3new(direction, color, intensity) {
  return new _M0TP36mizchi6kagura7light3d16DirectionalLight(_M0MP36mizchi6kagura6math3d4Vec39normalize(direction), color, intensity);
}
function _M0MP36mizchi6kagura7light3d12AmbientLight3new(color, intensity) {
  return new _M0TP36mizchi6kagura7light3d12AmbientLight(color, intensity);
}
function _M0MP36mizchi6kagura7light3d19LightingEnvironment11new_2einner(directional, ambient, point_lights, spot_lights) {
  return new _M0TP36mizchi6kagura7light3d19LightingEnvironment(directional, ambient, point_lights, spot_lights);
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
  _M0MPC15array5Array4pushGdE(data, px);
  _M0MPC15array5Array4pushGdE(data, py);
  _M0MPC15array5Array4pushGdE(data, pz);
  _M0MPC15array5Array4pushGdE(data, nx);
  _M0MPC15array5Array4pushGdE(data, ny);
  _M0MPC15array5Array4pushGdE(data, nz);
  _M0MPC15array5Array4pushGdE(data, u);
  _M0MPC15array5Array4pushGdE(data, v);
}
function _M0FP36mizchi6kagura6mesh3d21compute__mesh__bounds(vertex_data) {
  if (_M0FP36mizchi6kagura6mesh3d16vertex3d__stride === 0) {
    $panic();
  }
  const vertex_count = vertex_data.length / _M0FP36mizchi6kagura6mesh3d16vertex3d__stride | 0;
  if (vertex_count === 0) {
    return new _M0TP36mizchi6kagura6mesh3d12MeshBounds3D(0, 0, 0, 0, 0, 0);
  }
  const min_x = new _M0TPC13ref3RefGdE(_M0MPC15array5Array2atGdE(vertex_data, 0));
  const min_y = new _M0TPC13ref3RefGdE(_M0MPC15array5Array2atGdE(vertex_data, 1));
  const min_z = new _M0TPC13ref3RefGdE(_M0MPC15array5Array2atGdE(vertex_data, 2));
  const max_x = new _M0TPC13ref3RefGdE(min_x.val);
  const max_y = new _M0TPC13ref3RefGdE(min_y.val);
  const max_z = new _M0TPC13ref3RefGdE(min_z.val);
  const _bind = 1;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < vertex_count) {
      const base = Math.imul(i, _M0FP36mizchi6kagura6mesh3d16vertex3d__stride) | 0;
      const x = _M0MPC15array5Array2atGdE(vertex_data, base);
      const y = _M0MPC15array5Array2atGdE(vertex_data, base + 1 | 0);
      const z = _M0MPC15array5Array2atGdE(vertex_data, base + 2 | 0);
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
  return new _M0TP36mizchi6kagura6mesh3d12MeshBounds3D(min_x.val, min_y.val, min_z.val, max_x.val, max_y.val, max_z.val);
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(vertex_data, indices) {
  return new _M0TP36mizchi6kagura6mesh3d6Mesh3D(vertex_data, indices, _M0FP36mizchi6kagura6mesh3d21compute__mesh__bounds(vertex_data));
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
function _M0MP36mizchi6kagura6mesh3d6Mesh3D4cube(size) {
  const h = size / 2;
  const data = [];
  const indices = [];
  const base = new _M0TPC13ref3RefGiE(0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, h, 0, 0, 1, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, h, 0, 0, 1, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, h, 0, 0, 1, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, h, 0, 0, 1, 0, 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  _M0MPC15array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, -h, 0, 0, -1, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, -h, 0, 0, -1, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, -h, 0, 0, -1, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, -h, 0, 0, -1, 0, 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  _M0MPC15array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, h, 1, 0, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, -h, 1, 0, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, -h, 1, 0, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, h, 1, 0, 0, 0, 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  _M0MPC15array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, -h, -1, 0, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, h, -1, 0, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, h, -1, 0, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, -h, -1, 0, 0, 0, 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  _M0MPC15array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, h, 0, 1, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, h, 0, 1, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, h, -h, 0, 1, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, h, -h, 0, 1, 0, 0, 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  _M0MPC15array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  base.val = base.val + 4 | 0;
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, -h, 0, -1, 0, 0, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, -h, 0, -1, 0, 1, 1);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, h, -h, h, 0, -1, 0, 1, 0);
  _M0FP36mizchi6kagura6mesh3d12push__vertex(data, -h, -h, h, 0, -1, 0, 0, 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  _M0MPC15array5Array4pushGiE(indices, base.val + 1 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 2 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val + 3 | 0);
  _M0MPC15array5Array4pushGiE(indices, base.val);
  return _M0MP36mizchi6kagura6mesh3d6Mesh3D3new(data, indices);
}
function _M0MP36mizchi6kagura6mesh3d6Mesh3D13plane_2einner(width, depth, subdivisions) {
  const hw = width / 2;
  const hd = depth / 2;
  const n = subdivisions;
  const data = [];
  const indices = [];
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const row = _tmp;
    if (row <= n) {
      const t = (row + 0) / (n + 0);
      const z = -hd + t * depth;
      const v = t;
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const col = _tmp$2;
        if (col <= n) {
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
  const _bind$2 = 0;
  let _tmp$2 = _bind$2;
  while (true) {
    const row = _tmp$2;
    if (row < n) {
      const _bind$3 = 0;
      let _tmp$3 = _bind$3;
      while (true) {
        const col = _tmp$3;
        if (col < n) {
          const tl = (Math.imul(row, cols) | 0) + col | 0;
          const tr = tl + 1 | 0;
          const bl = tl + cols | 0;
          const br = bl + 1 | 0;
          _M0MPC15array5Array4pushGiE(indices, tl);
          _M0MPC15array5Array4pushGiE(indices, bl);
          _M0MPC15array5Array4pushGiE(indices, tr);
          _M0MPC15array5Array4pushGiE(indices, tr);
          _M0MPC15array5Array4pushGiE(indices, bl);
          _M0MPC15array5Array4pushGiE(indices, br);
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
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const ring = _tmp;
    if (ring <= rings) {
      const phi = 3.14159265358979312 * (ring + 0) / (rings + 0);
      const sin_phi = _M0FPC14math3sin(phi);
      const cos_phi = _M0FPC14math3cos(phi);
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const seg = _tmp$2;
        if (seg <= segments) {
          const theta = 6.28318530717958623 * (seg + 0) / (segments + 0);
          const sin_theta = _M0FPC14math3sin(theta);
          const cos_theta = _M0FPC14math3cos(theta);
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
  const _bind$2 = 0;
  let _tmp$2 = _bind$2;
  while (true) {
    const ring = _tmp$2;
    if (ring < rings) {
      const _bind$3 = 0;
      let _tmp$3 = _bind$3;
      while (true) {
        const seg = _tmp$3;
        if (seg < segments) {
          const curr = (Math.imul(ring, cols) | 0) + seg | 0;
          const next = curr + cols | 0;
          _M0MPC15array5Array4pushGiE(indices, curr);
          _M0MPC15array5Array4pushGiE(indices, next);
          _M0MPC15array5Array4pushGiE(indices, curr + 1 | 0);
          _M0MPC15array5Array4pushGiE(indices, curr + 1 | 0);
          _M0MPC15array5Array4pushGiE(indices, next);
          _M0MPC15array5Array4pushGiE(indices, next + 1 | 0);
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
function _M0MP36mizchi6kagura11transform3d11Transform3D16from__components(pos, rot, scale) {
  return new _M0TP36mizchi6kagura11transform3d11Transform3D(pos, rot, scale);
}
function _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(self) {
  const t = _M0MP36mizchi6kagura6math3d4Mat411translation(self.position.x, self.position.y, self.position.z);
  const r = _M0MP36mizchi6kagura6math3d10Quaternion8to__mat4(self.rotation);
  const s = _M0MP36mizchi6kagura6math3d4Mat47scaling(self.scale.x, self.scale.y, self.scale.z);
  return _M0MP36mizchi6kagura6math3d4Mat48multiply(_M0MP36mizchi6kagura6math3d4Mat48multiply(t, r), s);
}
function _M0FP36mizchi6kagura10skeleton3d28build__skinned__vertex__data(bind_mesh, skin) {
  const src_stride = _M0FP36mizchi6kagura6mesh3d16vertex3d__stride;
  const dst_stride = 16;
  const vertex_count = _M0MP36mizchi6kagura6mesh3d6Mesh3D13vertex__count(bind_mesh);
  const out = _M0MPC15array5Array4makeGdE(Math.imul(vertex_count, dst_stride) | 0, 0);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const v = _tmp;
    if (v < vertex_count) {
      const src_base = Math.imul(v, src_stride) | 0;
      const dst_base = Math.imul(v, dst_stride) | 0;
      _M0MPC15array5Array3setGdE(out, dst_base, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base));
      _M0MPC15array5Array3setGdE(out, dst_base + 1 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 1 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 2 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 2 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 3 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 3 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 4 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 4 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 5 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 5 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 6 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 6 | 0));
      _M0MPC15array5Array3setGdE(out, dst_base + 7 | 0, _M0MPC15array5Array2atGdE(bind_mesh.vertex_data, src_base + 7 | 0));
      const ji_base = Math.imul(v, 4) | 0;
      const has_skin = v < skin.vertex_count && ((ji_base + 3 | 0) < skin.joint_indices.length && (ji_base + 3 | 0) < skin.weights.length);
      if (has_skin) {
        _M0MPC15array5Array3setGdE(out, dst_base + 8 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 9 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 1 | 0) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 1 | 0) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 10 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 2 | 0) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 2 | 0) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 11 | 0, _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 3 | 0) >= 0 ? _M0MPC15array5Array2atGiE(skin.joint_indices, ji_base + 3 | 0) + 0 : 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 12 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base));
        _M0MPC15array5Array3setGdE(out, dst_base + 13 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base + 1 | 0));
        _M0MPC15array5Array3setGdE(out, dst_base + 14 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base + 2 | 0));
        _M0MPC15array5Array3setGdE(out, dst_base + 15 | 0, _M0MPC15array5Array2atGdE(skin.weights, ji_base + 3 | 0));
      } else {
        _M0MPC15array5Array3setGdE(out, dst_base + 8 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 9 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 10 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 11 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 12 | 0, 1);
        _M0MPC15array5Array3setGdE(out, dst_base + 13 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 14 | 0, 0);
        _M0MPC15array5Array3setGdE(out, dst_base + 15 | 0, 0);
      }
      _tmp = v + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura6draw3d25mat4__to__uniform__dwords(m) {
  const dwords = [];
  const _bind = 0;
  const _bind$2 = 16;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const _tmp$2 = m.elements;
      $bound_check(_tmp$2, i);
      _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl() {
  return "struct Uniforms {\n  mvp: mat4x4<f32>,\n  model: mat4x4<f32>,\n  normal_col0: vec4<f32>,\n  normal_col1: vec4<f32>,\n  normal_col2: vec4<f32>,\n  light_dir: vec4<f32>,\n  light_color: vec4<f32>,\n  ambient_color: vec4<f32>,\n};\n\n";
}
function _M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl() {
  return "  let normal_mat = mat3x3<f32>(\n    uniforms.normal_col0.xyz,\n    uniforms.normal_col1.xyz,\n    uniforms.normal_col2.xyz,\n  );\n";
}
function _M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl() {
  return "  let normal = normalize(in.world_normal);\n  let light_dir = normalize(-uniforms.light_dir.xyz);\n  let ndotl = max(dot(normal, light_dir), 0.0);\n  let diffuse = uniforms.light_color.xyz * ndotl;\n  let ambient = uniforms.ambient_color.xyz;\n";
}
function _M0FP36mizchi6kagura6draw3d31shader3d__lit__untextured__wgsl() {
  return `${_M0FP36mizchi6kagura6draw3d26lit__uniform__struct__wgsl()}@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\nstruct VertexInput {\n  @location(0) position: vec3<f32>,\n  @location(1) normal: vec3<f32>,\n  @location(2) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) world_normal: vec3<f32>,\n};\n\n@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n${_M0FP36mizchi6kagura6draw3d22lit__normal__mat__wgsl()}  out.world_normal = normalize(normal_mat * input.normal);\n  return out;\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n${_M0FP36mizchi6kagura6draw3d29lit__fragment__lighting__wgsl()}  let lit_color = diffuse + ambient;\n  return vec4<f32>(lit_color, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model, view_projection, lighting) {
  const mvp = _M0MP36mizchi6kagura6math3d4Mat48multiply(view_projection, model);
  const dwords = _M0FP36mizchi6kagura6draw3d25mat4__to__uniform__dwords(mvp);
  const _bind = 0;
  const _bind$2 = 16;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const _tmp$2 = model.elements;
      $bound_check(_tmp$2, i);
      _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$2[i]));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const normal_dw = _M0FP36mizchi6kagura7light3d31normal__matrix__uniform__dwords(model);
  const _bind$3 = 0;
  const _bind$4 = normal_dw.length;
  let _tmp$2 = _bind$3;
  while (true) {
    const i = _tmp$2;
    if (i < _bind$4) {
      _M0MPC15array5Array4pushGiE(dwords, _M0MPC15array5Array2atGiE(normal_dw, i));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const light_dw = _M0FP36mizchi6kagura7light3d22light__uniform__dwords(lighting);
  const _bind$5 = 0;
  const _bind$6 = light_dw.length;
  let _tmp$3 = _bind$5;
  while (true) {
    const i = _tmp$3;
    if (i < _bind$6) {
      _M0MPC15array5Array4pushGiE(dwords, _M0MPC15array5Array2atGiE(light_dw, i));
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
function _M0FP36mizchi6kagura6draw3d38new__skinned__lit__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, vertex_data, indices, model_matrix, view_projection, lighting, skinning_matrices, src_image_ids) {
  const dwords = _M0FP36mizchi6kagura6draw3d20lit__uniform__dwords(model_matrix, view_projection, lighting);
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(skinning_matrices.length + 0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  const bone_count = skinning_matrices.length < _M0FP36mizchi6kagura6draw3d10max__bones ? skinning_matrices.length : _M0FP36mizchi6kagura6draw3d10max__bones;
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < bone_count) {
      const _bind$2 = 0;
      const _bind$3 = 16;
      let _tmp$2 = _bind$2;
      while (true) {
        const j = _tmp$2;
        if (j < _bind$3) {
          const _tmp$3 = _M0MPC15array5Array2atGRP36mizchi6kagura7scene3d8Object3DE(skinning_matrices, i).elements;
          $bound_check(_tmp$3, j);
          _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(_tmp$3[j]));
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
  let _tmp$2 = bone_count;
  while (true) {
    const _i = _tmp$2;
    if (_i < _M0FP36mizchi6kagura6draw3d10max__bones) {
      const _bind$2 = 0;
      const _bind$3 = 16;
      let _tmp$3 = _bind$2;
      while (true) {
        const _j = _tmp$3;
        if (_j < _bind$3) {
          _M0MPC15array5Array4pushGiE(dwords, 0);
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
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.x));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.y));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.z));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(base_color.w));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(metallic));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(roughness));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.x));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.y));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(emissive.z));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.x));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.y));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(camera_pos.z));
  _M0MPC15array5Array4pushGiE(dwords, _M0FP36mizchi6kagura3gfx21double__to__f32__bits(0));
  return dwords;
}
function _M0FP36mizchi6kagura6draw3d29new__pbr__mesh__draw__command(dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh, model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos, src_image_ids) {
  const uniform_dwords = _M0FP36mizchi6kagura6draw3d20pbr__uniform__dwords(model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive, camera_pos);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], index_offset, pipeline_id, uniform_hash, blend, mesh.vertex_data, mesh.indices, src_image_ids, uniform_dwords, 1, 0);
}
function _M0IP26mizchi5audio13EnvelopePhasePB2Eq5equal(_x_1064, _x_1065) {
  switch (_x_1064) {
    case 0: {
      if (_x_1065 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_1065 === 1) {
        return true;
      } else {
        return false;
      }
    }
    case 2: {
      if (_x_1065 === 2) {
        return true;
      } else {
        return false;
      }
    }
    case 3: {
      if (_x_1065 === 3) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_1065 === 4) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0IP26mizchi5audio10VoiceStatePB2Eq5equal(_x_1032, _x_1033) {
  switch (_x_1032) {
    case 0: {
      if (_x_1033 === 0) {
        return true;
      } else {
        return false;
      }
    }
    case 1: {
      if (_x_1033 === 1) {
        return true;
      } else {
        return false;
      }
    }
    default: {
      if (_x_1033 === 2) {
        return true;
      } else {
        return false;
      }
    }
  }
}
function _M0IP26mizchi5audio7VoiceIdPB2Eq5equal(_x_950, _x_951) {
  return _x_950 === _x_951;
}
function _M0FP26mizchi5audio11find__voice(mixer, id) {
  const _bind = mixer.voices;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const voice = _bind[_];
      if (_M0IP26mizchi5audio7VoiceIdPB2Eq5equal(voice.id, id)) {
        return voice;
      }
      _tmp = _ + 1 | 0;
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
  const floor_pos = _M0MPC15float5Float7to__int(position);
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
  const floor_pos = _M0MPC15float5Float7to__int(position);
  const frac = Math.fround(position - Math.fround(floor_pos));
  const i0 = _M0FP26mizchi5audio12clamp__frame(floor_pos, frame_count);
  const i1 = _M0FP26mizchi5audio12clamp__frame(floor_pos + 1 | 0, frame_count);
  const s0 = _M0FP26mizchi5audio20read__source__sample(source, i0, channel);
  const s1 = _M0FP26mizchi5audio20read__source__sample(source, i1, channel);
  return Math.fround(s0 + Math.fround(Math.fround(s1 - s0) * frac));
}
function _M0FP26mizchi5audio17resample__nearest(source, position, channel, frame_count) {
  const frame = _M0FP26mizchi5audio12clamp__frame(_M0MPC15float5Float7to__int(Math.fround(position + Math.fround(0.5))), frame_count);
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
  const left = _M0FPC14math4cosf(angle);
  const right = _M0FPC14math4sinf(angle);
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
  const result = new _M0TPC13ref3RefGfE(sample);
  const _bind = effects.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const effect = effects[_];
      result.val = _M0FP26mizchi5audio15effect__process(effect, result.val);
      _tmp = _ + 1 | 0;
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
      const attack_samples = _M0MPC15float5Float7to__int(Math.fround(env.config.attack * Math.fround(env.sample_rate)));
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
      const decay_samples = _M0MPC15float5Float7to__int(Math.fround(env.config.decay * Math.fround(env.sample_rate)));
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
      const release_samples = _M0MPC15float5Float7to__int(Math.fround(env.config.release_time * Math.fround(env.sample_rate)));
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
  _M0MPC15array10FixedArray12fill_2einnerGfE(output, Math.fround(0), 0, Math.imul(frames, 2) | 0);
  const _bind = mixer.voices;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const voice = _bind[_];
      _L: {
        if (_M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(voice.state, 0)) {
          break _L;
        }
        const src = voice.source;
        const src_channels = _M0FP26mizchi5audio16source__channels(src);
        const src_frames = _M0FP26mizchi5audio20source__frame__count(src);
        let pan_l;
        let pan_r;
        _L$2: {
          const _bind$3 = _M0FP26mizchi5audio10pan__gains(voice.pan);
          const _pan_l = _bind$3._0;
          const _pan_r = _bind$3._1;
          pan_l = _pan_l;
          pan_r = _pan_r;
          break _L$2;
        }
        const voice_gain = voice.gain;
        const ratio = _M0FP26mizchi5audio15resample__ratio(voice.sample_rate, mixer.sample_rate);
        const _bind$3 = 0;
        let _tmp$2 = _bind$3;
        while (true) {
          const f = _tmp$2;
          if (f < frames) {
            const int_pos = _M0MPC15float5Float7to__int(voice.position);
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
                const _bind$4 = voice.envelope;
                if (_bind$4 === undefined) {
                  env_gain = Math.fround(1);
                } else {
                  const _Some = _bind$4;
                  const _env = _Some;
                  env = _env;
                  break _L$4;
                }
                break _L$3;
              }
              const g = _M0FP26mizchi5audio14envelope__tick(env);
              if (_M0IP26mizchi5audio13EnvelopePhasePB2Eq5equal(env.phase, 4)) {
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
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (Math.fround(mixer.master_gain !== Math.fround(1))) {
    const _bind$3 = 0;
    const _bind$4 = Math.imul(frames, 2) | 0;
    let _tmp$2 = _bind$3;
    while (true) {
      const i = _tmp$2;
      if (i < _bind$4) {
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
  mixer.voices = _M0MPC15array5Array6filterGRP26mizchi5audio5VoiceE(mixer.voices, (v) => _M0IP016_24default__implPB2Eq10not__equalGRP26mizchi5audio10VoiceStateE(v.state, 2));
}
function _M0FP36mizchi6kagura5audio22default__audio__format() {
  return new _M0TP36mizchi6kagura5audio11AudioFormat(44100, 2, 16);
}
function _M0MP36mizchi6kagura5audio17MixerAudioContext15find__voice__id(self, id) {
  const _bind = self.player_map;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const pair = _bind[_];
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
      _tmp = _ + 1 | 0;
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
      return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
    } else {
      const _Some = _bind;
      const _vid = _Some;
      vid = _vid;
      break _L;
    }
  }
  _M0FP26mizchi5audio11stop__voice(self.mixer, vid);
  return new _M0DTPC16result6ResultGuRPC15error5ErrorE2Ok(undefined);
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
  self.player_map = _M0MPC15array5Array6filterGURP36mizchi6kagura5audio8PlayerIdRP26mizchi5audio7VoiceIdEE(self.player_map, (pair) => {
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
  const _bind = self.player_map;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const pair = _bind[_];
      let vid;
      _L: {
        const _vid = pair._1;
        vid = _vid;
        break _L;
      }
      let voice;
      _L$2: {
        _L$3: {
          const _bind$3 = _M0FP26mizchi5audio11find__voice(self.mixer, vid);
          if (_bind$3 === undefined) {
          } else {
            const _Some = _bind$3;
            const _voice = _Some;
            voice = _voice;
            break _L$3;
          }
          break _L$2;
        }
        if (_M0IP26mizchi5audio10VoiceStatePB2Eq5equal(voice.state, 2)) {
          voice.state = 1;
        }
      }
      _tmp = _ + 1 | 0;
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
  return new _M0TP36mizchi6kagura5audio16AudioOutputHooks(try_initialize, write_frames, suspend, resume_playback, close, _M0FP36mizchi6kagura5audio31default__audio__output__latency);
}
function _M0FP36mizchi6kagura5audio31new__audio__output__hooks__full(try_initialize, write_frames, suspend, resume_playback, close, output_latency) {
  return new _M0TP36mizchi6kagura5audio16AudioOutputHooks(try_initialize, write_frames, suspend, resume_playback, close, output_latency);
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
function _M0FP36mizchi6kagura9inpututil13contains__key(keys, key) {
  const found = new _M0TPC13ref3RefGbE(false);
  const _bind = keys.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const current = keys[_];
      if (current === key) {
        found.val = true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return found.val;
}
function _M0FP36mizchi6kagura9inpututil21normalize__touch__ids(snapshot) {
  const out = [];
  const _bind = snapshot.touches;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const touch = _bind[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(out, touch.id)) {
        _M0MPC15array5Array4pushGiE(out, touch.id);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura9inpututil20duration__for__touch(entries, id) {
  const out = new _M0TPC13ref3RefGiE(0);
  const _bind = entries.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const entry = entries[_];
      if (entry.id === id) {
        out.val = entry.duration;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura9inpututil24new__touch__input__state() {
  return new _M0TP36mizchi6kagura9inpututil15TouchInputState([], [], [], [], []);
}
function _M0FP36mizchi6kagura9inpututil27update__touch__input__state(state, snapshot) {
  const prev_ids = state.touch_ids;
  const next_ids = _M0FP36mizchi6kagura9inpututil21normalize__touch__ids(snapshot);
  const just_pressed = [];
  const _bind = next_ids.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const id = next_ids[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(prev_ids, id)) {
        _M0MPC15array5Array4pushGiE(just_pressed, id);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const just_released = [];
  const _bind$2 = prev_ids.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$2) {
      const id = prev_ids[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(next_ids, id)) {
        _M0MPC15array5Array4pushGiE(just_released, id);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_durations = [];
  const _bind$3 = next_ids.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$3) {
      const id = next_ids[_];
      const duration = _M0FP36mizchi6kagura9inpututil13contains__key(prev_ids, id) ? _M0FP36mizchi6kagura9inpututil20duration__for__touch(state.durations, id) + 1 | 0 : 1;
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(next_durations, new _M0TP36mizchi6kagura9inpututil18TouchDurationEntry(id, duration));
      _tmp$3 = _ + 1 | 0;
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
  const _bind = keys.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const key = keys[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(out, key)) {
        _M0MPC15array5Array4pushGiE(out, key);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP36mizchi6kagura9inpututil18duration__for__key(entries, key) {
  const out = new _M0TPC13ref3RefGiE(0);
  const _bind = entries.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const entry = entries[_];
      if (entry.key === key) {
        out.val = entry.duration;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura9inpututil22new__key__input__state() {
  return new _M0TP36mizchi6kagura9inpututil13KeyInputState([], [], [], [], []);
}
function _M0FP36mizchi6kagura9inpututil28duration__for__mouse__button(entries, button) {
  const out = new _M0TPC13ref3RefGiE(0);
  const _bind = entries.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const entry = entries[_];
      if (entry.button === button) {
        out.val = entry.duration;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out.val;
}
function _M0FP36mizchi6kagura9inpututil24new__mouse__input__state() {
  return new _M0TP36mizchi6kagura9inpututil21MouseButtonInputState([], [], [], [], []);
}
function _M0FP36mizchi6kagura9inpututil25update__key__input__state(state, snapshot) {
  const prev_pressed = state.pressed_keys;
  const next_pressed = _M0FP36mizchi6kagura9inpututil24normalize__pressed__keys(snapshot.pressed_keys);
  const just_pressed = [];
  const _bind = next_pressed.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const key = next_pressed[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, key)) {
        _M0MPC15array5Array4pushGiE(just_pressed, key);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const just_released = [];
  const _bind$2 = prev_pressed.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$2) {
      const key = prev_pressed[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(next_pressed, key)) {
        _M0MPC15array5Array4pushGiE(just_released, key);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_durations = [];
  const _bind$3 = next_pressed.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$3) {
      const key = next_pressed[_];
      const duration = _M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, key) ? _M0FP36mizchi6kagura9inpututil18duration__for__key(state.durations, key) + 1 | 0 : 1;
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(next_durations, new _M0TP36mizchi6kagura9inpututil16KeyDurationEntry(key, duration));
      _tmp$3 = _ + 1 | 0;
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
  const _bind = next_pressed.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const button = next_pressed[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, button)) {
        _M0MPC15array5Array4pushGiE(just_pressed, button);
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const just_released = [];
  const _bind$2 = prev_pressed.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$2) {
      const button = prev_pressed[_];
      if (!_M0FP36mizchi6kagura9inpututil13contains__key(next_pressed, button)) {
        _M0MPC15array5Array4pushGiE(just_released, button);
      }
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const next_durations = [];
  const _bind$3 = next_pressed.length;
  let _tmp$3 = 0;
  while (true) {
    const _ = _tmp$3;
    if (_ < _bind$3) {
      const button = next_pressed[_];
      const duration = _M0FP36mizchi6kagura9inpututil13contains__key(prev_pressed, button) ? _M0FP36mizchi6kagura9inpututil28duration__for__mouse__button(state.durations, button) + 1 | 0 : 1;
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(next_durations, new _M0TP36mizchi6kagura9inpututil24MouseButtonDurationEntry(button, duration));
      _tmp$3 = _ + 1 | 0;
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
  return new _M0TP36mizchi6kagura9inpututil11InputHelper(_M0FP36mizchi6kagura9inpututil22new__key__input__state(), _M0FP36mizchi6kagura9inpututil24new__mouse__input__state(), _M0FP36mizchi6kagura9inpututil24new__touch__input__state());
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
  const _bind$2 = cmds.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const cmd = cmds[_];
      const _bind$3 = _M0IP36mizchi6kagura3gfx18StubGraphicsDriverP36mizchi6kagura3gfx14GraphicsDriver15draw__triangles(graphics, cmd);
      if (_bind$3.$tag === 1) {
        const _ok = _bind$3;
        _ok._0;
      } else {
        return _bind$3;
      }
      _tmp = _ + 1 | 0;
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
    _M0FPB7printlnGsE(`[engine] platform.initialize failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
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
    _M0FPB7printlnGsE(`[engine] graphics.initialize failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
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
    _M0FPB7printlnGsE(`[engine] graphics.new_image failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
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
    _M0FPB7printlnGsE(`[engine] graphics.new_shader failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
    shader = _M0FP36mizchi6kagura3gfx19new__shader__handle(1, shader_source);
  }
  const ctx = new _M0TP36mizchi6kagura6engine13EngineContext(dst, shader, width, height);
  const tick = _M0MPC13ref3Ref3newGiE(0);
  if (audio_ctx === undefined) {
  } else {
    _M0FP36mizchi6kagura5audio22audio__try__initialize(_M0FP36mizchi6kagura5audio22default__audio__format());
  }
  const audio_tick_ms = (audio_frames_per_tick + 0) / 44100 * 1000;
  const audio_accum = _M0MPC13ref3Ref3newGdE(0);
  const prev_time = _M0MPC13ref3Ref3newGdE(_M0FP36mizchi6kagura6engine20js__performance__now());
  const frame = () => {
    _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver12poll__events(platform);
    const outside = _M0IP36mizchi6kagura8platform17WebCanvasPlatformP36mizchi6kagura8platform14PlatformDriver13outside__size(platform);
    const new_w = _M0MPC16double6Double7to__int(outside.width);
    const new_h = _M0MPC16double6Double7to__int(outside.height);
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
        _M0FPB7printlnGsE(`[engine] graphics.resize failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
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
        _M0FPB7printlnGsE(`[engine] graphics.new_image (resize) failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
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
      _M0FPB7printlnGsE(`[engine] render_commands failed: ${_M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(e)}`);
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
function _M0FP36mizchi6kagura6postfx24fullscreen__vertex__wgsl() {
  return "struct VertexInput {\n  @location(0) position: vec2<f32>,\n  @location(1) uv: vec2<f32>,\n};\n\nstruct VertexOutput {\n  @builtin(position) clip_position: vec4<f32>,\n  @location(0) uv: vec2<f32>,\n};\n\n@vertex fn vs_main(in: VertexInput) -> VertexOutput {\n  var out: VertexOutput;\n  out.clip_position = vec4<f32>(in.position, 0.0, 1.0);\n  out.uv = in.uv;\n  return out;\n}\n\n";
}
function _M0FP36mizchi6kagura6postfx13tonemap__wgsl(op) {
  let tonemap_fn;
  if (op === 0) {
    tonemap_fn = "fn tonemap(color: vec3<f32>) -> vec3<f32> {\n  return color / (color + vec3<f32>(1.0));\n}\n\n";
  } else {
    tonemap_fn = "fn tonemap(color: vec3<f32>) -> vec3<f32> {\n  let a = 2.51;\n  let b = 0.03;\n  let c = 2.43;\n  let d = 0.59;\n  let e = 0.14;\n  return clamp((color * (a * color + b)) / (color * (c * color + d) + e), vec3<f32>(0.0), vec3<f32>(1.0));\n}\n\n";
  }
  return `${_M0FP36mizchi6kagura6postfx24fullscreen__vertex__wgsl()}struct Uniforms {\n  exposure: vec4<f32>,\n};\n\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var tex: texture_2d<f32>;\n@group(0) @binding(2) var tex_sampler: sampler;\n\n${tonemap_fn}@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  let hdr_color = textureSampleLevel(tex, tex_sampler, in.uv, 0.0).rgb;\n  let exposed = hdr_color * uniforms.exposure.x;\n  let ldr_color = tonemap(exposed);\n  // Vignette: darken edges for atmospheric framing\n  let vignette_uv = in.uv * 2.0 - 1.0;\n  let vignette_dist = dot(vignette_uv, vignette_uv);\n  let vignette = smoothstep(2.0, 0.7, vignette_dist);\n  var final_color = ldr_color * vignette;\n  // Hit flash: mix red tint based on uniforms.exposure.y\n  let flash = uniforms.exposure.y;\n  if (flash > 0.0) {\n    let edge_boost = smoothstep(0.3, 1.2, vignette_dist);\n    let red_tint = vec3<f32>(0.6, 0.05, 0.05);\n    final_color = mix(final_color, red_tint, flash * 0.25 * (1.0 + edge_boost));\n  }\n  return vec4<f32>(final_color, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6postfx32tonemap__uniform__dwords_2einner(exposure, hit_flash) {
  return [_M0FP36mizchi6kagura3gfx21double__to__f32__bits(exposure), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(hit_flash), 0, 0];
}
function _M0FP36mizchi6kagura6postfx25fullscreen__quad__indices() {
  return [0, 1, 2, 2, 3, 0];
}
function _M0FP36mizchi6kagura6postfx38fullscreen__quad__resource__cache__key(dst, shader, src_image_ids, uniform_dwords, blend) {
  const values = [dst.id, dst.width, dst.height, shader.id, _M0FP36mizchi6kagura3gfx20blend__mode__to__int(blend), src_image_ids.length, uniform_dwords.length];
  const _bind = src_image_ids.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const image_id = src_image_ids[_];
      _M0MPC15array5Array4pushGiE(values, image_id);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const _bind$2 = uniform_dwords.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$2) {
      const dword = uniform_dwords[_];
      _M0MPC15array5Array4pushGiE(values, dword);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FP36mizchi6kagura3gfx27build__resource__cache__key(1347375956, values);
}
function _M0FP36mizchi6kagura6postfx30fullscreen__quad__vertex__data() {
  return [-1, -1, 0, 1, 1, -1, 1, 1, 1, 1, 1, 0, -1, 1, 0, 0];
}
function _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(dst, shader, src_image_ids, uniform_dwords, blend) {
  const dst_region = _M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, dst.width, dst.height, 6);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [dst_region], 0, 0, 0, blend, _M0FP36mizchi6kagura6postfx30fullscreen__quad__vertex__data(), _M0FP36mizchi6kagura6postfx25fullscreen__quad__indices(), src_image_ids, uniform_dwords, 1, _M0FP36mizchi6kagura6postfx38fullscreen__quad__resource__cache__key(dst, shader, src_image_ids, uniform_dwords, blend));
}
function _M0FP36mizchi6kagura6postfx29new__tonemap__command_2einner(dst, shader, src_image_id, exposure, hit_flash) {
  return _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(dst, shader, [src_image_id], _M0FP36mizchi6kagura6postfx32tonemap__uniform__dwords_2einner(exposure, hit_flash), _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0));
}
function _M0FP36mizchi6kagura6postfx10fxaa__wgsl() {
  return `${_M0FP36mizchi6kagura6postfx24fullscreen__vertex__wgsl()}struct Uniforms {\n  texel_size: vec4<f32>,\n};\n\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var tex: texture_2d<f32>;\n@group(0) @binding(2) var tex_sampler: sampler;\n\nfn luminance(color: vec3<f32>) -> f32 {\n  return dot(color, vec3<f32>(0.299, 0.587, 0.114));\n}\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  let texel = uniforms.texel_size.xy;\n  let color_m = textureSampleLevel(tex, tex_sampler, in.uv, 0.0).rgb;\n  let color_n = textureSampleLevel(tex, tex_sampler, in.uv + vec2<f32>(0.0, -texel.y), 0.0).rgb;\n  let color_s = textureSampleLevel(tex, tex_sampler, in.uv + vec2<f32>(0.0, texel.y), 0.0).rgb;\n  let color_e = textureSampleLevel(tex, tex_sampler, in.uv + vec2<f32>(texel.x, 0.0), 0.0).rgb;\n  let color_w = textureSampleLevel(tex, tex_sampler, in.uv + vec2<f32>(-texel.x, 0.0), 0.0).rgb;\n  let luma_m = luminance(color_m);\n  let luma_n = luminance(color_n);\n  let luma_s = luminance(color_s);\n  let luma_e = luminance(color_e);\n  let luma_w = luminance(color_w);\n  let luma_min = min(luma_m, min(min(luma_n, luma_s), min(luma_e, luma_w)));\n  let luma_max = max(luma_m, max(max(luma_n, luma_s), max(luma_e, luma_w)));\n  let luma_range = luma_max - luma_min;\n  if luma_range < max(0.0312, luma_max * 0.125) {\n    return vec4<f32>(color_m, 1.0);\n  }\n  let dir_x = -((luma_n + luma_s) - (luma_e + luma_w));\n  let dir_y = (luma_n + luma_e) - (luma_s + luma_w);\n  let dir_reduce = max((luma_n + luma_s + luma_e + luma_w) * 0.25 * 0.25, 1.0 / 128.0);\n  let rcp_dir_min = 1.0 / (min(abs(dir_x), abs(dir_y)) + dir_reduce);\n  let dir = clamp(vec2<f32>(dir_x, dir_y) * rcp_dir_min, vec2<f32>(-8.0), vec2<f32>(8.0)) * texel;\n  let result_a = 0.5 * (\n    textureSampleLevel(tex, tex_sampler, in.uv + dir * (1.0 / 3.0 - 0.5), 0.0).rgb +\n    textureSampleLevel(tex, tex_sampler, in.uv + dir * (2.0 / 3.0 - 0.5), 0.0).rgb\n  );\n  let result_b = result_a * 0.5 + 0.25 * (\n    textureSampleLevel(tex, tex_sampler, in.uv + dir * -0.5, 0.0).rgb +\n    textureSampleLevel(tex, tex_sampler, in.uv + dir * 0.5, 0.0).rgb\n  );\n  let luma_b = luminance(result_b);\n  if luma_b < luma_min || luma_b > luma_max {\n    return vec4<f32>(result_a, 1.0);\n  }\n  return vec4<f32>(result_b, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6postfx21fxaa__uniform__dwords(texel_w, texel_h) {
  return [_M0FP36mizchi6kagura3gfx21double__to__f32__bits(texel_w), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(texel_h), 0, 0];
}
function _M0FP36mizchi6kagura6postfx18new__fxaa__command(dst, shader, src_image_id, screen_w, screen_h) {
  const texel_w = 1 / (screen_w + 0);
  const texel_h = 1 / (screen_h + 0);
  return _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(dst, shader, [src_image_id], _M0FP36mizchi6kagura6postfx21fxaa__uniform__dwords(texel_w, texel_h), _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0));
}
function _M0FP36mizchi6kagura6postfx22bloom__threshold__wgsl() {
  return `${_M0FP36mizchi6kagura6postfx24fullscreen__vertex__wgsl()}struct Uniforms {\n  params: vec4<f32>,\n};\n\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var tex: texture_2d<f32>;\n@group(0) @binding(2) var tex_sampler: sampler;\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  let color = textureSampleLevel(tex, tex_sampler, in.uv, 0.0).rgb;\n  let brightness = dot(color, vec3<f32>(0.2126, 0.7152, 0.0722));\n  let threshold = uniforms.params.x;\n  if brightness > threshold {\n    return vec4<f32>(color, 1.0);\n  }\n  return vec4<f32>(0.0, 0.0, 0.0, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6postfx17bloom__blur__wgsl(horizontal) {
  const dir = horizontal ? "vec2<f32>(texel.x, 0.0)" : "vec2<f32>(0.0, texel.y)";
  return `${_M0FP36mizchi6kagura6postfx24fullscreen__vertex__wgsl()}struct Uniforms {\n  texel_size: vec4<f32>,\n};\n\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var tex: texture_2d<f32>;\n@group(0) @binding(2) var tex_sampler: sampler;\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  let texel = uniforms.texel_size.xy;\n  let dir = ${_M0IPC16string6StringPB4Show10to__string(dir)};\n  var result = textureSampleLevel(tex, tex_sampler, in.uv, 0.0).rgb * 0.2270270270;\n  result += textureSampleLevel(tex, tex_sampler, in.uv + dir * 1.0, 0.0).rgb * 0.1945945946;\n  result += textureSampleLevel(tex, tex_sampler, in.uv - dir * 1.0, 0.0).rgb * 0.1945945946;\n  result += textureSampleLevel(tex, tex_sampler, in.uv + dir * 2.0, 0.0).rgb * 0.1216216216;\n  result += textureSampleLevel(tex, tex_sampler, in.uv - dir * 2.0, 0.0).rgb * 0.1216216216;\n  result += textureSampleLevel(tex, tex_sampler, in.uv + dir * 3.0, 0.0).rgb * 0.0540540541;\n  result += textureSampleLevel(tex, tex_sampler, in.uv - dir * 3.0, 0.0).rgb * 0.0540540541;\n  result += textureSampleLevel(tex, tex_sampler, in.uv + dir * 4.0, 0.0).rgb * 0.0162162162;\n  result += textureSampleLevel(tex, tex_sampler, in.uv - dir * 4.0, 0.0).rgb * 0.0162162162;\n  return vec4<f32>(result, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6postfx22bloom__composite__wgsl() {
  return `${_M0FP36mizchi6kagura6postfx24fullscreen__vertex__wgsl()}struct Uniforms {\n  params: vec4<f32>,\n};\n\n@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n@group(0) @binding(1) var scene_tex: texture_2d<f32>;\n@group(0) @binding(2) var scene_sampler: sampler;\n@group(0) @binding(3) var bloom_tex: texture_2d<f32>;\n@group(0) @binding(4) var bloom_sampler: sampler;\n\n@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  let scene_color = textureSampleLevel(scene_tex, scene_sampler, in.uv, 0.0).rgb;\n  let bloom_color = textureSampleLevel(bloom_tex, bloom_sampler, in.uv, 0.0).rgb;\n  let intensity = uniforms.params.x;\n  let result = scene_color + bloom_color * intensity;\n  return vec4<f32>(result, 1.0);\n}\n`;
}
function _M0FP36mizchi6kagura6postfx15bloom__commands(dst, scene_image_id, bloom_a, bloom_b, threshold_shader, hblur_shader, vblur_shader, composite_shader, threshold, intensity, screen_w, screen_h) {
  const blur_w = bloom_a.width > 0 ? bloom_a.width : screen_w;
  const blur_h = bloom_a.height > 0 ? bloom_a.height : screen_h;
  const texel_w = 1 / (blur_w + 0);
  const texel_h = 1 / (blur_h + 0);
  const texel_dwords = [_M0FP36mizchi6kagura3gfx21double__to__f32__bits(texel_w), _M0FP36mizchi6kagura3gfx21double__to__f32__bits(texel_h), 0, 0];
  const cmd1 = _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(bloom_a, threshold_shader, [scene_image_id], [_M0FP36mizchi6kagura3gfx21double__to__f32__bits(threshold), 0, 0, 0], _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0));
  const cmd2 = _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(bloom_b, hblur_shader, [bloom_a.id], texel_dwords, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0));
  const cmd3 = _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(bloom_a, vblur_shader, [bloom_b.id], texel_dwords, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0));
  const cmd4 = _M0FP36mizchi6kagura6postfx30new__fullscreen__quad__command(dst, composite_shader, [scene_image_id, bloom_a.id], [_M0FP36mizchi6kagura3gfx21double__to__f32__bits(intensity), 0, 0, 0], _M0FP36mizchi6kagura3gfx22blend__mode__from__int(0));
  return [cmd1, cmd2, cmd3, cmd4];
}
function _M0FP36mizchi6kagura7scene3d19compute__mesh__aabb(mesh) {
  const bounds = _M0MP36mizchi6kagura6mesh3d6Mesh3D6bounds(mesh);
  return { _0: bounds.min_x, _1: bounds.min_y, _2: bounds.min_z, _3: bounds.max_x, _4: bounds.max_y, _5: bounds.max_z };
}
function _M0FP36mizchi6kagura7scene3d19frustum__cull__aabb(frustum, min_x, min_y, min_z, max_x, max_y, max_z) {
  const _bind = 0;
  const _bind$2 = 6;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
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
  const wmin_x = new _M0TPC13ref3RefGdE(e[12]);
  $bound_check(e, 13);
  const wmin_y = new _M0TPC13ref3RefGdE(e[13]);
  $bound_check(e, 14);
  const wmin_z = new _M0TPC13ref3RefGdE(e[14]);
  const wmax_x = new _M0TPC13ref3RefGdE(wmin_x.val);
  const wmax_y = new _M0TPC13ref3RefGdE(wmin_y.val);
  const wmax_z = new _M0TPC13ref3RefGdE(wmin_z.val);
  const mins = [min_x, min_y, min_z];
  const maxs = [max_x, max_y, max_z];
  const _bind = 0;
  const _bind$2 = 3;
  let _tmp = _bind;
  while (true) {
    const j = _tmp;
    if (j < _bind$2) {
      const _tmp$2 = Math.imul(j, 4) | 0;
      $bound_check(e, _tmp$2);
      const a0 = e[_tmp$2] * _M0MPC15array5Array2atGdE(mins, j);
      const _tmp$3 = Math.imul(j, 4) | 0;
      $bound_check(e, _tmp$3);
      const b0 = e[_tmp$3] * _M0MPC15array5Array2atGdE(maxs, j);
      if (a0 < b0) {
        wmin_x.val = wmin_x.val + a0;
        wmax_x.val = wmax_x.val + b0;
      } else {
        wmin_x.val = wmin_x.val + b0;
        wmax_x.val = wmax_x.val + a0;
      }
      const _tmp$4 = (Math.imul(j, 4) | 0) + 1 | 0;
      $bound_check(e, _tmp$4);
      const a1 = e[_tmp$4] * _M0MPC15array5Array2atGdE(mins, j);
      const _tmp$5 = (Math.imul(j, 4) | 0) + 1 | 0;
      $bound_check(e, _tmp$5);
      const b1 = e[_tmp$5] * _M0MPC15array5Array2atGdE(maxs, j);
      if (a1 < b1) {
        wmin_y.val = wmin_y.val + a1;
        wmax_y.val = wmax_y.val + b1;
      } else {
        wmin_y.val = wmin_y.val + b1;
        wmax_y.val = wmax_y.val + a1;
      }
      const _tmp$6 = (Math.imul(j, 4) | 0) + 2 | 0;
      $bound_check(e, _tmp$6);
      const a2 = e[_tmp$6] * _M0MPC15array5Array2atGdE(mins, j);
      const _tmp$7 = (Math.imul(j, 4) | 0) + 2 | 0;
      $bound_check(e, _tmp$7);
      const b2 = e[_tmp$7] * _M0MPC15array5Array2atGdE(maxs, j);
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
  const tinted_lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(lighting.directional.direction, _M0MP36mizchi6kagura6math3d4Vec33new(lighting.directional.color.x * col.x, lighting.directional.color.y * col.y, lighting.directional.color.z * col.z), lighting.directional.intensity), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(lighting.ambient.color.x * col.x, lighting.ambient.color.y * col.y, lighting.ambient.color.z * col.z), lighting.ambient.intensity), _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None__, _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None__);
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
    _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, cmd);
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
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, cmd);
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
    _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, cmd);
    return;
  }
}
function _M0FP36mizchi6kagura7scene3d16normalize__plane(a, b, c, d) {
  const len = Math.sqrt(a * a + b * b + c * c);
  if (len < 1e-10) {
    return new _M0TP36mizchi6kagura7scene3d5Plane(0, 0, 0, 0);
  } else {
    const inv = 1 / len;
    return new _M0TP36mizchi6kagura7scene3d5Plane(a * inv, b * inv, c * inv, d * inv);
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
  const planes = $make_array_len_and_init(6, new _M0TP36mizchi6kagura7scene3d5Plane(0, 0, 0, 0));
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
  return new _M0TP36mizchi6kagura7scene3d7Frustum(planes);
}
function _M0FP36mizchi6kagura7scene3d29has__nonzero__sort__bias__gpu(objects) {
  const _bind = objects.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const obj = objects[_];
      if (obj.sort_bias !== 0) {
        return true;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0FP36mizchi6kagura7scene3d23sort__objects__for__gpu(objects) {
  const ordered = [];
  const _bind = 0;
  const _bind$2 = objects.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(ordered, { _0: i, _1: _M0MPC15array5Array2atGRP36mizchi6kagura7scene3d8Object3DE(objects, i) });
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MPC15array5Array8sort__byGUiRP36mizchi6kagura7scene3d8Object3DEE(ordered, (a, b) => {
    const bias_a = a._1.sort_bias;
    const bias_b = b._1.sort_bias;
    return bias_a > bias_b ? -1 : bias_a < bias_b ? 1 : a._0 - b._0 | 0;
  });
  const sorted = [];
  const _bind$3 = ordered.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$3) {
      const entry = ordered[_];
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(sorted, entry._1);
      _tmp$2 = _ + 1 | 0;
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
  const _bind = ordered.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const obj = ordered[_];
      const model = _M0MP36mizchi6kagura11transform3d11Transform3D8to__mat4(obj.transform);
      _M0FP36mizchi6kagura7scene3d27render__object__gpu_2einner(obj.mesh, model, obj.color, obj.material, obj.skinning, vp, frustum, lighting, dst, shader3d, screen_w, screen_h, cmds, shader3d_textured, shader3d_pbr, shader3d_pbr_textured, shader3d_skinned, camera.position);
      _tmp = _ + 1 | 0;
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
  return new _M0TP36mizchi6kagura7scene3d8Object3D(mesh, _M0MP36mizchi6kagura11transform3d11Transform3D16from__components(position, rotation, scale), color, material, sort_bias, skinning);
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
  return new _M0TP36mizchi6kagura7scene3d7Scene3D(objects, camera, lighting);
}
function _M0FP36mizchi6kagura4text22new__font__load__hooks(load_font_data) {
  return new _M0TP36mizchi6kagura4text13FontLoadHooks(load_font_data);
}
function _M0FP36mizchi6kagura4text25default__load__font__data(_name) {
  return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
}
function _M0FP36mizchi6kagura4text26default__font__load__hooks() {
  return new _M0TP36mizchi6kagura4text13FontLoadHooks(_M0FP36mizchi6kagura4text25default__load__font__data);
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
  const out = new _M0TPC13ref3RefGORP26mizchi19web__runtime__hooks21SourceImageCacheEntryE(undefined);
  const _bind = _M0FP26mizchi19web__runtime__hooks20source__image__cache.val;
  const _bind$2 = _bind.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const entry = _bind[_];
      if (entry.image_id === image_id) {
        out.val = entry;
      }
      _tmp = _ + 1 | 0;
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
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < frames) {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const ch = _tmp$2;
        if (ch < channels) {
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
    return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
  }
  const data = _M0MPC15array5Array4makeGiE(size, 0);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < size) {
      _M0MPC15array5Array3setGiE(data, i, _M0FP26mizchi19web__runtime__hooks26js__load__font__data__byte(i));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(data);
}
function _M0FP26mizchi19web__runtime__hooks27bridge__web__capture__input(active, _tick) {
  if (active) {
    _M0FP26mizchi19web__runtime__hooks25js__ensure__window__state(_M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val);
    const pressed_keys = [];
    const key_count = _M0FP26mizchi19web__runtime__hooks30js__input__pressed__key__count();
    const _bind = 0;
    let _tmp = _bind;
    while (true) {
      const i = _tmp;
      if (i < key_count) {
        _M0MPC15array5Array4pushGiE(pressed_keys, _M0FP26mizchi19web__runtime__hooks27js__input__pressed__key__at(i));
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const pressed_mouse_buttons = [];
    const mouse_button_count = _M0FP26mizchi19web__runtime__hooks40js__input__pressed__mouse__button__count();
    const _bind$2 = 0;
    let _tmp$2 = _bind$2;
    while (true) {
      const i = _tmp$2;
      if (i < mouse_button_count) {
        const button = _M0FP26mizchi19web__runtime__hooks37js__input__pressed__mouse__button__at(i);
        if (button >= 0) {
          _M0MPC15array5Array4pushGiE(pressed_mouse_buttons, button);
        }
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const touches = [];
    const touch_count = _M0FP26mizchi19web__runtime__hooks23js__input__touch__count();
    const _bind$3 = 0;
    let _tmp$3 = _bind$3;
    while (true) {
      const i = _tmp$3;
      if (i < touch_count) {
        _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(touches, _M0FP36mizchi6kagura4core17new__touch__point(_M0FP26mizchi19web__runtime__hooks24js__input__touch__id__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__x__at(i), _M0FP26mizchi19web__runtime__hooks23js__input__touch__y__at(i)));
        _tmp$3 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const gamepads = [];
    const gamepad_count = _M0FP26mizchi19web__runtime__hooks25js__input__gamepad__count();
    const _bind$4 = 0;
    let _tmp$4 = _bind$4;
    while (true) {
      const i = _tmp$4;
      if (i < gamepad_count) {
        const axes = [];
        const axis_count = _M0FP26mizchi19web__runtime__hooks31js__input__gamepad__axis__count(i);
        const _bind$5 = 0;
        let _tmp$5 = _bind$5;
        while (true) {
          const j = _tmp$5;
          if (j < axis_count) {
            _M0MPC15array5Array4pushGdE(axes, _M0FP26mizchi19web__runtime__hooks28js__input__gamepad__axis__at(i, j));
            _tmp$5 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        const pressed_buttons = [];
        const button_count = _M0FP26mizchi19web__runtime__hooks42js__input__gamepad__pressed__button__count(i);
        const _bind$6 = 0;
        let _tmp$6 = _bind$6;
        while (true) {
          const j = _tmp$6;
          if (j < button_count) {
            const button_id = _M0FP26mizchi19web__runtime__hooks39js__input__gamepad__pressed__button__at(i, j);
            if (button_id >= 0) {
              _M0MPC15array5Array4pushGiE(pressed_buttons, button_id);
            }
            _tmp$6 = j + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(gamepads, _M0FP36mizchi6kagura4core22new__gamepad__snapshot(_M0FP26mizchi19web__runtime__hooks26js__input__gamepad__id__at(i), axes, pressed_buttons));
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
    const _bind = dirty.length;
    let _tmp = 0;
    while (true) {
      const _ = _tmp;
      if (_ < _bind) {
        const image_id = dirty[_];
        let entry;
        _L: {
          _L$2: {
            const _bind$2 = _M0FP26mizchi19web__runtime__hooks31source__image__cache__entry__at(image_id);
            if (_bind$2 === undefined) {
            } else {
              const _Some = _bind$2;
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
                _M0FP26mizchi19web__runtime__hooks31js__gfx__upload__texture__pixel(i, _M0MPC15array5Array2atGiE(px, base), _M0MPC15array5Array2atGiE(px, base + 1 | 0), _M0MPC15array5Array2atGiE(px, base + 2 | 0), _M0MPC15array5Array2atGiE(px, base + 3 | 0));
                _tmp$2 = i + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            _M0FP26mizchi19web__runtime__hooks29js__gfx__upload__texture__end();
          }
        }
        _tmp = _ + 1 | 0;
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
    if (_M0MPC16string6String8contains(_tmp, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
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
          _M0FP26mizchi19web__runtime__hooks36js__gfx__custom__draw__vertex__float(i, _M0MPC15array5Array2atGdE(command.vertex_data, i));
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
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MPC15array5Array2atGiE(command.indices, i));
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
          _M0FP26mizchi19web__runtime__hooks30js__gfx__custom__draw__uniform(i, _M0MPC15array5Array2atGiE(command.uniform_dwords, i));
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
          _M0FP26mizchi19web__runtime__hooks33js__gfx__custom__draw__src__image(i, _M0MPC15array5Array2atGiE(command.src_image_ids, i));
          _tmp$5 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0FP26mizchi19web__runtime__hooks18js__gfx__draw__end();
      return;
    } else {
      const src_id = command.src_image_ids.length > 0 ? _M0MPC15array5Array2atGiE(command.src_image_ids, 0) : 0;
      const ur = command.uniform_dwords.length > 0 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 0) : 255;
      const ug = command.uniform_dwords.length > 1 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 1) : 255;
      const ub = command.uniform_dwords.length > 2 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 2) : 255;
      const ua = command.uniform_dwords.length > 3 ? _M0MPC15array5Array2atGiE(command.uniform_dwords, 3) : 255;
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
          _M0FP26mizchi19web__runtime__hooks21js__gfx__draw__vertex(i, _M0MPC15array5Array2atGdE(command.vertex_data, base), _M0MPC15array5Array2atGdE(command.vertex_data, base + 1 | 0), _M0MPC15array5Array2atGdE(command.vertex_data, base + 2 | 0), _M0MPC15array5Array2atGdE(command.vertex_data, base + 3 | 0));
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
          _M0FP26mizchi19web__runtime__hooks20js__gfx__draw__index(i, _M0MPC15array5Array2atGiE(command.indices, i));
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
  if (!_M0FP26mizchi19web__runtime__hooks21web__hooks__installed.val || _M0IP016_24default__implPB2Eq10not__equalGsE(canvas_selector, _M0FP26mizchi19web__runtime__hooks21web__canvas__selector.val)) {
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
function _M0MP26mizchi12postfx__demo9DemoState12build__scene(self) {
  const objects = [];
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(objects, _M0FP36mizchi6kagura7scene3d8object3d(self.ground_mesh, undefined, undefined, undefined, _M0MP36mizchi6kagura6math3d4Vec43new(0.3, 0.35, 0.3, 1), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__, new _M0DTPC16option6OptionGdE4Some(100), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__));
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(objects, _M0FP36mizchi6kagura7scene3d8object3d(self.cube_mesh, _M0MP36mizchi6kagura6math3d4Vec33new(-2, 0.5, 0), undefined, undefined, _M0MP36mizchi6kagura6math3d4Vec43new(1, 0.2, 0.1, 1), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__, _M0DTPC16option6OptionGdE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__));
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(objects, _M0FP36mizchi6kagura7scene3d8object3d(self.sphere_mesh, _M0MP36mizchi6kagura6math3d4Vec33new(1.5, 0.7, 1), undefined, undefined, _M0MP36mizchi6kagura6math3d4Vec43new(1, 0.95, 0.3, 1), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__, _M0DTPC16option6OptionGdE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__));
  const angle = (self.frame + 0) * 0.015;
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(objects, _M0FP36mizchi6kagura7scene3d8object3d(self.cube_mesh, _M0MP36mizchi6kagura6math3d4Vec33new(0, 0.5, -2), _M0MP36mizchi6kagura6math3d10Quaternion17from__axis__angle(_M0MP36mizchi6kagura6math3d4Vec37unit__y(), angle), undefined, _M0MP36mizchi6kagura6math3d4Vec43new(0.2, 0.9, 1, 1), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__, _M0DTPC16option6OptionGdE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__));
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(objects, _M0FP36mizchi6kagura7scene3d8object3d(self.sphere_mesh, _M0MP36mizchi6kagura6math3d4Vec33new(2.5, 0.7, -1.5), undefined, undefined, _M0MP36mizchi6kagura6math3d4Vec43new(1, 1, 1, 1), _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d8MaterialE4None__, _M0DTPC16option6OptionGdE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura7scene3d13SkinningStateE4None__));
  const camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera12to__camera3d(self.camera);
  return _M0FP36mizchi6kagura7scene3d15scene3d_2einner(objects, camera, self.lighting);
}
function _M0MP26mizchi12postfx__demo9DemoState4draw(self, ctx) {
  const all_cmds = [];
  const scene = _M0MP26mizchi12postfx__demo9DemoState12build__scene(self);
  const scene_cmds = _M0FP36mizchi6kagura7scene3d20render__scene3d__gpu(scene, self.scene_target, self.shader3d, ctx.screen_w, ctx.screen_h, _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__, _M0DTPC16option6OptionGORP36mizchi6kagura3gfx12ShaderHandleE4None__);
  const _bind = scene_cmds.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const cmd = scene_cmds[_];
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(all_cmds, cmd);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const bloom_cmds = _M0FP36mizchi6kagura6postfx15bloom__commands(self.post_target, self.scene_target.id, self.bloom_a, self.bloom_b, self.bloom_threshold_sh, self.bloom_hblur_sh, self.bloom_vblur_sh, self.bloom_composite_sh, 0.4, 2, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h);
  const _bind$2 = bloom_cmds.length;
  let _tmp$2 = 0;
  while (true) {
    const _ = _tmp$2;
    if (_ < _bind$2) {
      const cmd = bloom_cmds[_];
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(all_cmds, cmd);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const tonemap_cmd = _M0FP36mizchi6kagura6postfx29new__tonemap__command_2einner(self.scene_target, self.tonemap_sh, self.post_target.id, 1, 0);
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(all_cmds, tonemap_cmd);
  const fxaa_cmd = _M0FP36mizchi6kagura6postfx18new__fxaa__command(ctx.dst, self.fxaa_sh, self.scene_target.id, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h);
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(all_cmds, fxaa_cmd);
  return all_cmds;
}
function _M0MP26mizchi12postfx__demo9DemoState3new() {
  const scene_target = _M0FP36mizchi6kagura3gfx18new__image__handle(100, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h);
  const bloom_a = _M0FP36mizchi6kagura3gfx18new__image__handle(101, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h);
  const bloom_b = _M0FP36mizchi6kagura3gfx18new__image__handle(102, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h);
  const post_target = _M0FP36mizchi6kagura3gfx18new__image__handle(103, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h);
  const shader3d = _M0FP36mizchi6kagura3gfx19new__shader__handle(10, _M0FP36mizchi6kagura6draw3d31shader3d__lit__untextured__wgsl());
  const bloom_threshold_sh = _M0FP36mizchi6kagura3gfx19new__shader__handle(100, _M0FP36mizchi6kagura6postfx22bloom__threshold__wgsl());
  const bloom_hblur_sh = _M0FP36mizchi6kagura3gfx19new__shader__handle(101, _M0FP36mizchi6kagura6postfx17bloom__blur__wgsl(true));
  const bloom_vblur_sh = _M0FP36mizchi6kagura3gfx19new__shader__handle(102, _M0FP36mizchi6kagura6postfx17bloom__blur__wgsl(false));
  const bloom_composite_sh = _M0FP36mizchi6kagura3gfx19new__shader__handle(103, _M0FP36mizchi6kagura6postfx22bloom__composite__wgsl());
  const fxaa_sh = _M0FP36mizchi6kagura3gfx19new__shader__handle(104, _M0FP36mizchi6kagura6postfx10fxaa__wgsl());
  const tonemap_sh = _M0FP36mizchi6kagura3gfx19new__shader__handle(105, _M0FP36mizchi6kagura6postfx13tonemap__wgsl(1));
  const camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera3new(_M0MP36mizchi6kagura6math3d4Vec33new(0, 1, 0), 10, 0.3, 0.5, 0.785398163397448279, (_M0FP26mizchi12postfx__demo9screen__w + 0) / (_M0FP26mizchi12postfx__demo9screen__h + 0), 0.1, 100);
  const lighting = _M0MP36mizchi6kagura7light3d19LightingEnvironment3new(_M0MP36mizchi6kagura7light3d16DirectionalLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(-0.3, -1, -0.5), _M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 1.2), _M0MP36mizchi6kagura7light3d12AmbientLight3new(_M0MP36mizchi6kagura6math3d4Vec33new(1, 1, 1), 0.3), _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d10PointLightEE4None__, _M0DTPC16option6OptionGRPB5ArrayGRP36mizchi6kagura7light3d9SpotLightEE4None__);
  return new _M0TP26mizchi12postfx__demo9DemoState(_M0MP36mizchi6kagura6mesh3d6Mesh3D4cube(1), _M0MP36mizchi6kagura6mesh3d6Mesh3D6sphere(0.7, 8, 6), _M0MP36mizchi6kagura6mesh3d6Mesh3D13plane_2einner(16, 16, 4), scene_target, bloom_a, bloom_b, post_target, shader3d, bloom_threshold_sh, bloom_hblur_sh, bloom_vblur_sh, bloom_composite_sh, fxaa_sh, tonemap_sh, camera, lighting, _M0FP36mizchi6kagura9inpututil18new__input__helper(), 0);
}
function _M0MP26mizchi12postfx__demo9DemoState6update(self, snapshot) {
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, snapshot);
  self.frame = self.frame + 1 | 0;
  self.camera = _M0MP36mizchi6kagura8camera3d11OrbitCamera5orbit(self.camera, 0.004, 0);
}
(() => {
  const state = _M0MP26mizchi12postfx__demo9DemoState3new();
  _M0FP36mizchi6kagura6engine11run_2einner((input) => {
    _M0MP26mizchi12postfx__demo9DemoState6update(state, input);
  }, (ctx) => _M0MP26mizchi12postfx__demo9DemoState4draw(state, ctx), undefined, undefined, undefined, 735, _M0FP26mizchi12postfx__demo9screen__w, _M0FP26mizchi12postfx__demo9screen__h, "Post-Processing Effects Demo", "#app");
})();
//# sourceMappingURL=postfx_demo.js.map
