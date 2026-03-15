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
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
function _M0TPB7MyInt64(param0, param1) {
  this.hi = param0;
  this.lo = param1;
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
function _M0TPB6Hasher(param0) {
  this.acc = param0;
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function _M0TPB3MapGlRP36mizchi6kagura9physics2d17ContactManifold2DE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGibE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGluE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB3MapGlRPB5ArrayGiEE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGibE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGlRPB5ArrayGiEE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TPB5EntryGluE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0DTPC16option6OptionGRPB5ArrayGiEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGiEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGiEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGiEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGiEE4Some.prototype.$tag = 1;
const _M0MPC16double6Double8mod__ffi = (a, b) => (a % b);
const _M0MPB7JSArray11set__length = (arr, len) => { arr.length = len; };
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
function _M0TP36mizchi6kagura6vector4Vec2(param0, param1) {
  this.x = param0;
  this.y = param1;
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
const _M0FP36mizchi6kagura6engine29js__request__animation__frame = (f) => { requestAnimationFrame(() => f()); };
const _M0FP36mizchi6kagura6engine20js__on__beforeunload = (f) => { window.addEventListener("beforeunload", () => f()); };
const _M0FP36mizchi6kagura6engine20js__performance__now = () => (globalThis.performance?.now?.() ?? Date.now());
function _M0TP36mizchi6kagura6engine13EngineContext(param0, param1, param2, param3) {
  this.dst = param0;
  this.shader = param1;
  this.screen_w = param2;
  this.screen_h = param3;
}
function _M0TP36mizchi6kagura9physics2d14SolverConfig2D(param0, param1, param2, param3) {
  this.substeps = param0;
  this.velocity_iterations = param1;
  this.contact_hertz = param2;
  this.contact_damping_ratio = param3;
}
function _M0TP36mizchi6kagura9physics2d17SpatialHashGrid2D(param0, param1, param2, param3) {
  this.cell_size = param0;
  this.inv_cell_size = param1;
  this.cells = param2;
  this.entries = param3;
}
function _M0TPB9ArrayViewGUlRPB5ArrayGiEEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP36mizchi6kagura9physics2d14PhysicsWorld2D(param0, param1, param2, param3, param4, param5, param6) {
  this.bodies = param0;
  this.gravity = param1;
  this.broadphase = param2;
  this.solver_config = param3;
  this.contact_cache = param4;
  this.joints_distance = param5;
  this.joints_revolute = param6;
}
function _M0TPB9ArrayViewGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const $4294967295L = { hi: 0, lo: -1 };
function _M0DTPC16option6OptionGdE4None() {}
_M0DTPC16option6OptionGdE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGdE4None__ = new _M0DTPC16option6OptionGdE4None();
function _M0DTPC16option6OptionGdE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGdE4Some.prototype.$tag = 1;
function _M0TPC13ref3RefGOdE(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura9physics2d9Contact2D(param0, param1, param2, param3, param4) {
  this.body_a_id = param0;
  this.body_b_id = param1;
  this.normal = param2;
  this.penetration = param3;
  this.contact_point = param4;
}
function _M0TP36mizchi6kagura9physics2d6AABB2D(param0, param1) {
  this.min = param0;
  this.max = param1;
}
function _M0TPC13ref3RefGRP36mizchi6kagura6vector4Vec2E(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura9physics2d11RigidBody2D(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16, param17, param18) {
  this.id = param0;
  this.body_type = param1;
  this.position = param2;
  this.velocity = param3;
  this.force = param4;
  this.angle = param5;
  this.angular_velocity = param6;
  this.torque = param7;
  this.mass = param8;
  this.inv_mass = param9;
  this.restitution = param10;
  this.friction = param11;
  this.inv_inertia = param12;
  this.angular_damping = param13;
  this.linear_damping = param14;
  this.collider = param15;
  this.is_sleeping = param16;
  this.sleep_timer = param17;
  this.is_bullet = param18;
}
function _M0TP36mizchi6kagura9physics2d19ContactConstraint2D(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11) {
  this.idx_a = param0;
  this.idx_b = param1;
  this.contact = param2;
  this.r_a = param3;
  this.r_b = param4;
  this.normal_mass = param5;
  this.tangent_mass = param6;
  this.gamma = param7;
  this.bias_coefficient = param8;
  this.restitution_bias = param9;
  this.acc_jn = param10;
  this.acc_jt = param11;
}
function _M0TP36mizchi6kagura9physics2d25DistanceJointConstraint2D(param0, param1, param2, param3, param4, param5, param6, param7, param8) {
  this.idx_a = param0;
  this.idx_b = param1;
  this.r_a = param2;
  this.r_b = param3;
  this.axis = param4;
  this.effective_mass = param5;
  this.gamma = param6;
  this.bias_coefficient = param7;
  this.acc_impulse = param8;
}
function _M0TP36mizchi6kagura9physics2d25RevoluteJointConstraint2D(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9) {
  this.idx_a = param0;
  this.idx_b = param1;
  this.r_a = param2;
  this.r_b = param3;
  this.effective_mass_x = param4;
  this.effective_mass_y = param5;
  this.gamma = param6;
  this.bias_coefficient = param7;
  this.acc_impulse_x = param8;
  this.acc_impulse_y = param9;
}
function _M0TPB9ArrayViewGUluEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP36mizchi6kagura9physics2d17BroadphaseEntry2D(param0, param1) {
  this.id = param0;
  this.aabb = param1;
}
function _M0TPC13ref3RefGRP36mizchi6kagura9physics2d19ContactConstraint2DE(param0) {
  this.val = param0;
}
function _M0TP36mizchi6kagura9physics2d17ContactManifold2D(param0, param1, param2, param3) {
  this.body_a_id = param0;
  this.body_b_id = param1;
  this.normal = param2;
  this.points = param3;
}
function _M0TP36mizchi6kagura9physics2d15ManifoldPoint2D(param0, param1, param2, param3, param4) {
  this.local_a = param0;
  this.local_b = param1;
  this.penetration = param2;
  this.normal_impulse = param3;
  this.tangent_impulse = param4;
}
function _M0TPB9ArrayViewGUibEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
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
function _M0DTP36mizchi6kagura9physics2d15ColliderShape2D11CircleShape(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP36mizchi6kagura9physics2d15ColliderShape2D11CircleShape.prototype.$tag = 0;
function _M0DTP36mizchi6kagura9physics2d15ColliderShape2D11AABBShape2D(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP36mizchi6kagura9physics2d15ColliderShape2D11AABBShape2D.prototype.$tag = 1;
function _M0DTP36mizchi6kagura9physics2d15ColliderShape2D10OBBShape2D(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP36mizchi6kagura9physics2d15ColliderShape2D10OBBShape2D.prototype.$tag = 2;
function _M0TP26mizchi15physics2d__demo9DemoState(param0, param1, param2, param3) {
  this.world = param0;
  this.input = param1;
  this.frame = param2;
  this.next_id = param3;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char };
function _M0FP15Error10to__string(_e) {
  return $panic();
}
const _M0FPC15float10min__value = $f32_reinterpret_i32(-8388609);
const _M0FPC15float10max__value = $f32_reinterpret_i32(2139095039);
const _M0FPC15float14not__a__number = $f32_reinterpret_i32(2143289344);
const _M0FP36mizchi6kagura9physics2d26sleep__velocity__threshold = 0.5;
const _M0FP36mizchi6kagura9physics2d25sleep__angular__threshold = 0.2;
const _M0FP36mizchi6kagura9physics2d22sleep__time__threshold = 0.5;
const _M0FP36mizchi6kagura9physics2d2pi = 3.14159265358979312;
const _M0FP36mizchi6kagura9physics2d32restitution__velocity__threshold = 1;
const _M0FP36mizchi6kagura9physics2d9joint__pi = 3.14159265358979312;
const _M0FP36mizchi6kagura9physics2d22max__angular__velocity = 20;
const _M0FP36mizchi6kagura9physics2d4slop = 0.005;
const _M0FP26mizchi15physics2d__demo9screen__h = 480;
const _M0FP26mizchi15physics2d__demo9screen__w = 640;
const _M0FP26mizchi15physics2d__demo16circle__segments = 16;
const _M0FP26mizchi15physics2d__demo15dynamic__colors = [14696512, 4235488, 14729280, 4251760, 12607696, 14712896, 6344912, 13656192, 8441952, 10526944];
const _M0FP26mizchi15physics2d__demo13px__per__unit = 40;
const _M0FP36mizchi6kagura6engine16lifecycle__hooks = _M0MPC13ref3Ref3newGORP36mizchi6kagura6engine14LifecycleHooksE(undefined);
const _M0FP26mizchi19web__runtime__hooks21web__canvas__selector = _M0MPC13ref3Ref3newGsE("#app");
const _M0FP26mizchi19web__runtime__hooks21web__hooks__installed = _M0MPC13ref3Ref3newGbE(false);
const _M0FP36mizchi6kagura5audio20audio__output__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura5audio29default__audio__output__hooks());
const _M0FPB33brute__force__find_2econstr_2f156 = 0;
const _M0FPB43boyer__moore__horspool__find_2econstr_2f142 = 0;
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
const _M0FPC14math34trig__reduce_2etwo__over__pi_2f762 = [0, 683565275, -1819212470, 2131351028, 2102212464, 920167782, 1326507024, 0];
const _M0FP36mizchi6kagura3gfx25graphics__clock__provider = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx23default__clock__now__ms);
const _M0FP36mizchi6kagura3gfx23native__graphics__hooks = _M0MPC13ref3Ref3newGsE(_M0FP36mizchi6kagura3gfx32default__native__graphics__hooks());
const _M0FPB4seed = _M0FPB12random__seed();
function _M0FPB4rotl(x, r) {
  return x << r | (x >>> (32 - r | 0) | 0);
}
function _M0MPB6Hasher8consume4(self, input) {
  self.acc = Math.imul(_M0FPB4rotl((self.acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0, 17), 668265263) | 0;
}
function _M0MPB6Hasher13combine__uint(self, value) {
  self.acc = (self.acc >>> 0) + (4 >>> 0) | 0;
  _M0MPB6Hasher8consume4(self, value);
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
function _M0MPC15array5Array2atGUddbdEE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
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
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0IPC16uint166UInt16PB2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0MPB6Hasher12combine__int(self, value) {
  _M0MPB6Hasher13combine__uint(self, value);
}
function _M0MPB7MyInt649from__int(value) {
  return new _M0TPB7MyInt64(value >> 31 & -1, value | 0);
}
function _M0MPC13int3Int9to__int64(self) {
  return _M0MPB7MyInt649from__int(self);
}
function _M0MPB6Hasher7combineGlE(self, value) {
  _M0IPC15int645Int64PB4Hash13hash__combine(value, self);
}
function _M0MPB6Hasher7combineGiE(self, value) {
  _M0IPC13int3IntPB4Hash13hash__combine(value, self);
}
function _M0IP016_24default__implPB2Eq10not__equalGsE(x, y) {
  return !(x === y);
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
function _M0MPB6Hasher9avalanche(self) {
  let acc = self.acc;
  acc = acc ^ (acc >>> 15 | 0);
  acc = Math.imul(acc, -2048144777) | 0;
  acc = acc ^ (acc >>> 13 | 0);
  acc = Math.imul(acc, -1028477379) | 0;
  acc = acc ^ (acc >>> 16 | 0);
  return acc;
}
function _M0MPB6Hasher8finalize(self) {
  return _M0MPB6Hasher9avalanche(self);
}
function _M0MPB6Hasher11new_2einner(seed) {
  return new _M0TPB6Hasher((seed >>> 0) + (374761393 >>> 0) | 0);
}
function _M0MPB6Hasher3new(seed$46$opt) {
  let seed;
  if (seed$46$opt === undefined) {
    seed = _M0FPB4seed;
  } else {
    const _Some = seed$46$opt;
    seed = _Some;
  }
  return _M0MPB6Hasher11new_2einner(seed);
}
function _M0IP016_24default__implPB4Hash4hashGlE(self) {
  const h = _M0MPB6Hasher3new(undefined);
  _M0MPB6Hasher7combineGlE(h, self);
  return _M0MPB6Hasher8finalize(h);
}
function _M0IP016_24default__implPB4Hash4hashGiE(self) {
  const h = _M0MPB6Hasher3new(undefined);
  _M0MPB6Hasher7combineGiE(h, self);
  return _M0MPB6Hasher8finalize(h);
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
function _M0MPC16string10StringView6length(self) {
  return self.end - self.start | 0;
}
function _M0IP016_24default__implPB4Show10to__stringGRPC15error5ErrorE(self) {
  const logger = _M0MPB13StringBuilder11new_2einner(0);
  _M0IPC15error5ErrorPB4Show6output(self, { self: logger, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
  return _M0MPB13StringBuilder10to__string(logger);
}
function _M0MPC16string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
}
function _M0IPC16string10StringViewPB4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC15array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self) {
  return self.end - self.start | 0;
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
    return _M0FPB43boyer__moore__horspool__find_2econstr_2f142;
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
    return _M0FPB33brute__force__find_2econstr_2f156;
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
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC15array13ReadOnlyArray2atGjE(self, index) {
  $bound_check(self, index);
  return self[index];
}
function _M0MPC16option6Option6unwrapGRPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
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
function _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self, index, value) {
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
function _M0FPB21calc__grow__threshold(capacity) {
  if (16 === 0) {
    $panic();
  }
  return (Math.imul(capacity, 13) | 0) / 16 | 0;
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
function _M0MPB3Map11new_2einnerGlRP36mizchi6kagura9physics2d17ContactManifold2DE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGlRP36mizchi6kagura9physics2d17ContactManifold2DE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map11new_2einnerGibE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGibE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map11new_2einnerGluE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGluE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map11new_2einnerGlRPB5ArrayGiEE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGlRPB5ArrayGiEE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0MPB3Map20add__entry__to__tailGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGibE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGlRPB5ArrayGiEE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map20add__entry__to__tailGluE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map10set__entryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, entry, new_idx) {
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
function _M0MPB3Map10set__entryGibE(self, entry, new_idx) {
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
function _M0MPB3Map10set__entryGlRPB5ArrayGiEE(self, entry, new_idx) {
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
function _M0MPB3Map10set__entryGluE(self, entry, new_idx) {
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
function _M0MPB3Map10push__awayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry) {
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
      _M0MPB3Map10set__entryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, entry$2, idx$2);
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
function _M0MPB3Map10push__awayGibE(self, idx, entry) {
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
      _M0MPB3Map10set__entryGibE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGibE(self, entry$2, idx$2);
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
function _M0MPB3Map10push__awayGlRPB5ArrayGiEE(self, idx, entry) {
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
      _M0MPB3Map10set__entryGlRPB5ArrayGiEE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGlRPB5ArrayGiEE(self, entry$2, idx$2);
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
function _M0MPB3Map10push__awayGluE(self, idx, entry) {
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
      _M0MPB3Map10set__entryGluE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGluE(self, entry$2, idx$2);
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
function _M0MPB3Map15set__with__hashGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key, value, hash) {
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
        _M0MPB3Map4growGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _M0IPC15int645Int64PB2Eq5equal(_curr_entry.key, key)) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGibE(self, key, value, hash) {
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
        _M0MPB3Map4growGibE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGibE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGibE(self, idx, entry);
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
          _M0MPB3Map4growGibE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGibE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGibE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGibE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGlRPB5ArrayGiEE(self, key, value, hash) {
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
        _M0MPB3Map4growGlRPB5ArrayGiEE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGlRPB5ArrayGiEE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGlRPB5ArrayGiEE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _M0IPC15int645Int64PB2Eq5equal(_curr_entry.key, key)) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGlRPB5ArrayGiEE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGlRPB5ArrayGiEE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGlRPB5ArrayGiEE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGlRPB5ArrayGiEE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGluE(self, key, value, hash) {
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
        _M0MPB3Map4growGluE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGluE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGluE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _M0IPC15int645Int64PB2Eq5equal(_curr_entry.key, key)) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGluE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGluE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGluE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGluE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map4growGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self) {
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
      _M0MPB3Map15set__with__hashGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4growGibE(self) {
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
      _M0MPB3Map15set__with__hashGibE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4growGlRPB5ArrayGiEE(self) {
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
      _M0MPB3Map15set__with__hashGlRPB5ArrayGiEE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map4growGluE(self) {
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
      _M0MPB3Map15set__with__hashGluE(self, _key, _value, _hash);
      _tmp = _next;
      continue;
    }
  }
}
function _M0MPB3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key, value) {
  _M0MPB3Map15set__with__hashGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key, value, _M0IP016_24default__implPB4Hash4hashGlE(key));
}
function _M0MPB3Map3setGibE(self, key, value) {
  _M0MPB3Map15set__with__hashGibE(self, key, value, _M0IP016_24default__implPB4Hash4hashGiE(key));
}
function _M0MPB3Map3setGlRPB5ArrayGiEE(self, key, value) {
  _M0MPB3Map15set__with__hashGlRPB5ArrayGiEE(self, key, value, _M0IP016_24default__implPB4Hash4hashGlE(key));
}
function _M0MPB3Map3setGluE(self, key, value) {
  _M0MPB3Map15set__with__hashGluE(self, key, value, _M0IP016_24default__implPB4Hash4hashGlE(key));
}
function _M0MPB3Map11from__arrayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGlRP36mizchi6kagura9physics2d17ContactManifold2DE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map11from__arrayGibE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGibE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGibE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map11from__arrayGluE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGluE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGluE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map11from__arrayGlRPB5ArrayGiEE(arr) {
  const length = _M0MPC15array9ArrayView6lengthGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(arr);
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  const m = _M0MPB3Map11new_2einnerGlRPB5ArrayGiEE(capacity);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGlRPB5ArrayGiEE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPB3Map3getGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGlE(key);
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
      if (_entry.hash === hash && _M0IPC15int645Int64PB2Eq5equal(_entry.key, key)) {
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
function _M0MPB3Map3getGibE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGiE(key);
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
function _M0MPB3Map3getGlRPB5ArrayGiEE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGlE(key);
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const i = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
    } else {
      const _Some = _bind;
      const _entry = _Some;
      if (_entry.hash === hash && _M0IPC15int645Int64PB2Eq5equal(_entry.key, key)) {
        return new _M0DTPC16option6OptionGRPB5ArrayGiEE4Some(_entry.value);
      }
      if (i > _entry.psl) {
        return _M0DTPC16option6OptionGRPB5ArrayGiEE4None__;
      }
      _tmp = i + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3getGluE(self, key) {
  const hash = _M0IP016_24default__implPB4Hash4hashGlE(key);
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
      if (_entry.hash === hash && _M0IPC15int645Int64PB2Eq5equal(_entry.key, key)) {
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
function _M0MPB3Map4eachGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self, f) {
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
function _M0MPB3Map4eachGlRPB5ArrayGiEE(self, f) {
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
function _M0MPC15array10FixedArray12fill_2einnerGORPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self, value, start, end) {
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
function _M0MPB3Map5clearGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self) {
  _M0MPC15array10FixedArray12fill_2einnerGORPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self.entries, undefined, 0, undefined);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
}
function _M0MPB3Map5clearGlRPB5ArrayGiEE(self) {
  _M0MPC15array10FixedArray12fill_2einnerGORPB5EntryGlRP36mizchi6kagura9physics2d17ContactManifold2DEE(self.entries, undefined, 0, undefined);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
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
function _M0MPB7MyInt643lor(self, other) {
  return new _M0TPB7MyInt64(self.hi | other.hi, self.lo | other.lo);
}
function _M0MPB7MyInt643lsl(self, shift) {
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
      return new _M0TPB7MyInt64(hi$2, lo$2);
    } else {
      return new _M0TPB7MyInt64(self.lo << (shift$2 - 32 | 0), 0);
    }
  }
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
function _M0IPC15int645Int64PB5BitOr3lor(self, other) {
  return _M0MPB7MyInt643lor(self, other);
}
function _M0IPC15int645Int64PB3Shl3shl(self, other) {
  return _M0MPB7MyInt643lsl(self, other);
}
function _M0IPC15int645Int64PB2Eq5equal(self, other) {
  return _M0IPB7MyInt64PB2Eq5equal(self, other);
}
function _M0IPC16uint646UInt64PB3Mul3mul(self, other) {
  return _M0IPB7MyInt64PB3Mul3mul(self, other);
}
function _M0MPC16uint646UInt648to__uint(self) {
  return _M0MPB7MyInt648to__uint(self);
}
function _M0IPC16uint646UInt64PB3Shr3shr(self, shift) {
  return _M0MPB7MyInt643lsr(self, shift);
}
function _M0MPB6Hasher14combine__int64(self, value) {
  self.acc = (self.acc >>> 0) + (8 >>> 0) | 0;
  _M0MPB6Hasher8consume4(self, _M0MPC16uint646UInt648to__uint(value));
  _M0MPB6Hasher8consume4(self, _M0MPC16uint646UInt648to__uint(_M0IPC16uint646UInt64PB3Shr3shr(value, 32)));
}
function _M0IPC15int645Int64PB4Hash13hash__combine(self, hasher) {
  _M0MPB6Hasher14combine__int64(hasher, self);
}
function _M0IPC13int3IntPB4Hash13hash__combine(self, hasher) {
  _M0MPB6Hasher12combine__int(hasher, self);
}
function _M0MPC16double6Double7to__int(self) {
  return self !== self ? 0 : self >= 2147483647 ? 2147483647 : self <= -2147483648 ? -2147483648 : self | 0;
}
function _M0IPC16double6DoublePB3Mod3mod(self, other) {
  return _M0MPC16double6Double8mod__ffi(self, other);
}
function _M0FPB7printlnGsE(input) {
  console.log(_M0IPC16string6StringPB4Show10to__string(input));
}
function _M0MPC15array5Array28unsafe__truncate__to__lengthGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self, new_len) {
  _M0MPB7JSArray11set__length(self, new_len);
}
function _M0MPC15array5Array5clearGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self) {
  _M0MPC15array5Array28unsafe__truncate__to__lengthGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self, 0);
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
function _M0FPC13cmp7maximumGdE(x, y) {
  return x > y ? x : y;
}
function _M0FPC13cmp7minimumGdE(x, y) {
  return x > y ? y : x;
}
function _M0FPC14math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FPC14math3cos(_tmp) {
  return Math.cos(_tmp);
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
  let hi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f762, ind);
  let mi = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f762, ind + 1 | 0);
  let lo = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f762, ind + 2 | 0);
  const tp = _M0MPC15array13ReadOnlyArray2atGjE(_M0FPC14math34trig__reduce_2etwo__over__pi_2f762, ind + 3 | 0);
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
function _M0FP36mizchi6kagura9inpututil32is__mouse__button__just__pressed(state, button) {
  return _M0FP36mizchi6kagura9inpututil13contains__key(state.just_pressed_buttons, button);
}
function _M0FP36mizchi6kagura9inpututil18new__input__helper() {
  return new _M0TP36mizchi6kagura9inpututil11InputHelper(_M0FP36mizchi6kagura9inpututil22new__key__input__state(), _M0FP36mizchi6kagura9inpututil24new__mouse__input__state(), _M0FP36mizchi6kagura9inpututil24new__touch__input__state());
}
function _M0FP36mizchi6kagura9inpututil21update__input__helper(helper, snapshot) {
  _M0FP36mizchi6kagura9inpututil25update__key__input__state(helper.key_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__mouse__input__state(helper.mouse_state, snapshot);
  _M0FP36mizchi6kagura9inpututil27update__touch__input__state(helper.touch_state, snapshot);
}
function _M0MP36mizchi6kagura6vector4Vec23new(x, y) {
  return new _M0TP36mizchi6kagura6vector4Vec2(x, y);
}
function _M0MP36mizchi6kagura6vector4Vec215length__squared(self) {
  return self.x * self.x + self.y * self.y;
}
function _M0MP36mizchi6kagura6vector4Vec26length(self) {
  return Math.sqrt(_M0MP36mizchi6kagura6vector4Vec215length__squared(self));
}
function _M0MP36mizchi6kagura6vector4Vec25scale(self, s) {
  return new _M0TP36mizchi6kagura6vector4Vec2(self.x * s, self.y * s);
}
function _M0MP36mizchi6kagura6vector4Vec24zero() {
  return new _M0TP36mizchi6kagura6vector4Vec2(0, 0);
}
function _M0MP36mizchi6kagura6vector4Vec23sub(self, other) {
  return new _M0TP36mizchi6kagura6vector4Vec2(self.x - other.x, self.y - other.y);
}
function _M0MP36mizchi6kagura6vector4Vec27unit__y() {
  return new _M0TP36mizchi6kagura6vector4Vec2(0, 1);
}
function _M0MP36mizchi6kagura6vector4Vec23add(self, other) {
  return new _M0TP36mizchi6kagura6vector4Vec2(self.x + other.x, self.y + other.y);
}
function _M0MP36mizchi6kagura6vector4Vec26negate(self) {
  return new _M0TP36mizchi6kagura6vector4Vec2(-self.x, -self.y);
}
function _M0MP36mizchi6kagura6vector4Vec23dot(self, other) {
  return self.x * other.x + self.y * other.y;
}
function _M0MP36mizchi6kagura6vector4Vec25cross(self, other) {
  return self.x * other.y - self.y * other.x;
}
function _M0MP36mizchi6kagura6vector4Vec26rotate(self, angle_rad) {
  const cos_a = _M0FPC14math3cos(angle_rad);
  const sin_a = _M0FPC14math3sin(angle_rad);
  return new _M0TP36mizchi6kagura6vector4Vec2(self.x * cos_a - self.y * sin_a, self.x * sin_a + self.y * cos_a);
}
function _M0MP36mizchi6kagura6vector4Vec23min(self, other) {
  return new _M0TP36mizchi6kagura6vector4Vec2(_M0FPC13cmp7minimumGdE(self.x, other.x), _M0FPC13cmp7minimumGdE(self.y, other.y));
}
function _M0MP36mizchi6kagura6vector4Vec23max(self, other) {
  return new _M0TP36mizchi6kagura6vector4Vec2(_M0FPC13cmp7maximumGdE(self.x, other.x), _M0FPC13cmp7maximumGdE(self.y, other.y));
}
function _M0MP36mizchi6kagura6vector4Vec25clamp(self, min, max) {
  return _M0MP36mizchi6kagura6vector4Vec23min(_M0MP36mizchi6kagura6vector4Vec23max(self, min), max);
}
function _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color) {
  return [_M0MPC16double6Double7to__int(color.r * 255), _M0MPC16double6Double7to__int(color.g * 255), _M0MPC16double6Double7to__int(color.b * 255), _M0MPC16double6Double7to__int(color.a * 255)];
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
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, _M0MPC16double6Double7to__int(screen_w), _M0MPC16double6Double7to__int(screen_h), 6)], 0, pipeline_id, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), vertices, indices, [], uniform, 1, 0);
}
function _M0FP36mizchi6kagura9debugutil16color__from__hex(hex) {
  const r = ((hex >> 16 & 255) + 0) / 255;
  const g = ((hex >> 8 & 255) + 0) / 255;
  const b = ((hex & 255) + 0) / 255;
  return _M0FP36mizchi6kagura3gfx10new__color(r, g, b, 1);
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
function _M0FP36mizchi6kagura9debugutil26new__simple__draw__command(dst, shader, vertices, indices, color) {
  const uniform = _M0FP36mizchi6kagura9debugutil26color__to__uniform__dwords(color);
  return _M0FP36mizchi6kagura3gfx37new__draw__triangles__command_2einner(dst, shader, [_M0FP36mizchi6kagura3gfx16new__dst__region(0, 0, 0, 0, indices.length)], 0, 0, 0, _M0FP36mizchi6kagura3gfx22blend__mode__from__int(1), vertices, indices, [], uniform, 1, 0);
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
function _M0MP36mizchi6kagura9physics2d14SolverConfig2D7default() {
  return new _M0TP36mizchi6kagura9physics2d14SolverConfig2D(4, 1, 30, 1);
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D3new(cell_size) {
  const _tmp = 1 / cell_size;
  const _bind = [];
  return new _M0TP36mizchi6kagura9physics2d17SpatialHashGrid2D(cell_size, _tmp, _M0MPB3Map11from__arrayGlRPB5ArrayGiEE(new _M0TPB9ArrayViewGUlRPB5ArrayGiEEE(_bind, 0, 0)), []);
}
function _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D11new_2einner(gravity, broadphase_cell_size, solver_config) {
  const _tmp = [];
  const _tmp$2 = _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D3new(broadphase_cell_size);
  const _bind = [];
  return new _M0TP36mizchi6kagura9physics2d14PhysicsWorld2D(_tmp, gravity, _tmp$2, solver_config, _M0MPB3Map11from__arrayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(new _M0TPB9ArrayViewGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_bind, 0, 0)), [], []);
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
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self.bodies, body);
}
function _M0FP36mizchi6kagura9physics2d8uf__find(parent, i) {
  const x = new _M0TPC13ref3RefGiE(i);
  while (true) {
    if (_M0MPC15array5Array2atGiE(parent, x.val) === x.val) {
      return x.val;
    }
    _M0MPC15array5Array3setGiE(parent, x.val, _M0MPC15array5Array2atGiE(parent, _M0MPC15array5Array2atGiE(parent, x.val)));
    x.val = _M0MPC15array5Array2atGiE(parent, x.val);
    continue;
  }
}
function _M0FP36mizchi6kagura9physics2d9uf__union(parent, rank, a, b) {
  const ra = _M0FP36mizchi6kagura9physics2d8uf__find(parent, a);
  const rb = _M0FP36mizchi6kagura9physics2d8uf__find(parent, b);
  if (ra === rb) {
    return undefined;
  }
  if (_M0MPC15array5Array2atGiE(rank, ra) < _M0MPC15array5Array2atGiE(rank, rb)) {
    _M0MPC15array5Array3setGiE(parent, ra, rb);
    return;
  } else {
    if (_M0MPC15array5Array2atGiE(rank, ra) > _M0MPC15array5Array2atGiE(rank, rb)) {
      _M0MPC15array5Array3setGiE(parent, rb, ra);
      return;
    } else {
      _M0MPC15array5Array3setGiE(parent, rb, ra);
      _M0MPC15array5Array3setGiE(rank, ra, _M0MPC15array5Array2atGiE(rank, ra) + 1 | 0);
      return;
    }
  }
}
function _M0FP36mizchi6kagura9physics2d18contact__pair__key(id_a, id_b) {
  const min_id = id_a < id_b ? id_a : id_b;
  const max_id = id_a < id_b ? id_b : id_a;
  return _M0IPC15int645Int64PB5BitOr3lor(_M0IPC15int645Int64PB3Shl3shl(_M0MPC13int3Int9to__int64(min_id), 32), _M0IPC15int645Int64PB6BitAnd4land(_M0MPC13int3Int9to__int64(max_id), $4294967295L));
}
function _M0FP36mizchi6kagura9physics2d19sweep__circle__aabb(circle_pos, circle_vel, circle_radius, aabb_min, aabb_max) {
  const expanded_min = _M0MP36mizchi6kagura6vector4Vec23new(aabb_min.x - circle_radius, aabb_min.y - circle_radius);
  const expanded_max = _M0MP36mizchi6kagura6vector4Vec23new(aabb_max.x + circle_radius, aabb_max.y + circle_radius);
  if (circle_pos.x >= expanded_min.x && (circle_pos.x <= expanded_max.x && (circle_pos.y >= expanded_min.y && circle_pos.y <= expanded_max.y))) {
    return new _M0DTPC16option6OptionGdE4Some(0);
  }
  const t_min = new _M0TPC13ref3RefGdE(0);
  const t_max = new _M0TPC13ref3RefGdE(1);
  if (Math.abs(circle_vel.x) < 1e-12) {
    if (circle_pos.x < expanded_min.x || circle_pos.x > expanded_max.x) {
      return _M0DTPC16option6OptionGdE4None__;
    }
  } else {
    const inv_d = 1 / circle_vel.x;
    const t1 = new _M0TPC13ref3RefGdE((expanded_min.x - circle_pos.x) * inv_d);
    const t2 = new _M0TPC13ref3RefGdE((expanded_max.x - circle_pos.x) * inv_d);
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
      return _M0DTPC16option6OptionGdE4None__;
    }
  }
  if (Math.abs(circle_vel.y) < 1e-12) {
    if (circle_pos.y < expanded_min.y || circle_pos.y > expanded_max.y) {
      return _M0DTPC16option6OptionGdE4None__;
    }
  } else {
    const inv_d = 1 / circle_vel.y;
    const t1 = new _M0TPC13ref3RefGdE((expanded_min.y - circle_pos.y) * inv_d);
    const t2 = new _M0TPC13ref3RefGdE((expanded_max.y - circle_pos.y) * inv_d);
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
      return _M0DTPC16option6OptionGdE4None__;
    }
  }
  return t_min.val >= 0 && t_min.val <= 1 ? new _M0DTPC16option6OptionGdE4Some(t_min.val) : _M0DTPC16option6OptionGdE4None__;
}
function _M0FP36mizchi6kagura9physics2d21sweep__circle__circle(pos_a, vel_a, radius_a, pos_b, vel_b, radius_b) {
  const r = radius_a + radius_b;
  const d = _M0MP36mizchi6kagura6vector4Vec23sub(pos_a, pos_b);
  const v = _M0MP36mizchi6kagura6vector4Vec23sub(vel_a, vel_b);
  const a = _M0MP36mizchi6kagura6vector4Vec23dot(v, v);
  const b = _M0MP36mizchi6kagura6vector4Vec23dot(d, v);
  const c = _M0MP36mizchi6kagura6vector4Vec23dot(d, d) - r * r;
  if (c <= 0) {
    return new _M0DTPC16option6OptionGdE4Some(0);
  }
  if (a < 1e-12) {
    return _M0DTPC16option6OptionGdE4None__;
  }
  const discriminant = b * b - a * c;
  if (discriminant < 0) {
    return _M0DTPC16option6OptionGdE4None__;
  }
  const sqrt_disc = Math.sqrt(discriminant);
  const t = (-b - sqrt_disc) / a;
  return t >= 0 && t <= 1 ? new _M0DTPC16option6OptionGdE4Some(t) : _M0DTPC16option6OptionGdE4None__;
}
function _M0FP36mizchi6kagura9physics2d16ccd__sweep__body(bullet_idx, bodies, dt) {
  const bullet = _M0MPC15array5Array2atGUddbdEE(bodies, bullet_idx);
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
    return _M0DTPC16option6OptionGdE4None__;
  }
  const min_toi = new _M0TPC13ref3RefGOdE(_M0DTPC16option6OptionGdE4None__);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < bodies.length) {
      if (i === bullet_idx) {
      } else {
        const other = _M0MPC15array5Array2atGUddbdEE(bodies, i);
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
          toi = _M0DTPC16option6OptionGdE4None__;
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
                min_toi.val = new _M0DTPC16option6OptionGdE4Some(t);
              }
              break _L$5;
            }
            if (t < prev) {
              min_toi.val = new _M0DTPC16option6OptionGdE4Some(t);
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
  return new _M0TP36mizchi6kagura9physics2d9Contact2D(a.id, b.id, normal, penetration, contact_point);
}
function _M0MP36mizchi6kagura9physics2d6AABB2D14closest__point(self, point) {
  return _M0MP36mizchi6kagura6vector4Vec25clamp(point, self.min, self.max);
}
function _M0MP36mizchi6kagura9physics2d6AABB2D15contains__point(self, point) {
  return point.x >= self.min.x && (point.x <= self.max.x && (point.y >= self.min.y && point.y <= self.max.y));
}
function _M0MP36mizchi6kagura9physics2d6AABB2D3new(min, max) {
  return new _M0TP36mizchi6kagura9physics2d6AABB2D(min, max);
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
    const min_dist = new _M0TPC13ref3RefGdE(dx_left);
    const face_outward = new _M0TPC13ref3RefGRP36mizchi6kagura6vector4Vec2E(_M0MP36mizchi6kagura6vector4Vec23new(-1, 0));
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
    return swapped ? new _M0TP36mizchi6kagura9physics2d9Contact2D(box_body.id, circle_body.id, face_outward.val, penetration, contact_point) : new _M0TP36mizchi6kagura9physics2d9Contact2D(circle_body.id, box_body.id, _M0MP36mizchi6kagura6vector4Vec26negate(face_outward.val), penetration, contact_point);
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
    return swapped ? new _M0TP36mizchi6kagura9physics2d9Contact2D(box_body.id, circle_body.id, normal, penetration, closest) : new _M0TP36mizchi6kagura9physics2d9Contact2D(circle_body.id, box_body.id, _M0MP36mizchi6kagura6vector4Vec26negate(normal), penetration, closest);
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
  return new _M0TP36mizchi6kagura9physics2d9Contact2D(a.id, b.id, normal, penetration, contact_point);
}
function _M0FP36mizchi6kagura9physics2d11obb__circle(obb_body, obb_he, obb_off, circle_body, circle_off, circle_r, swapped) {
  const obb_center = _M0MP36mizchi6kagura6vector4Vec23add(obb_body.position, _M0MP36mizchi6kagura6vector4Vec26rotate(obb_off, obb_body.angle));
  const circle_center = _M0MP36mizchi6kagura6vector4Vec23add(circle_body.position, circle_off);
  const diff = _M0MP36mizchi6kagura6vector4Vec23sub(circle_center, obb_center);
  const loc = _M0MP36mizchi6kagura6vector4Vec26rotate(diff, -obb_body.angle);
  const closest_x = new _M0TPC13ref3RefGdE(loc.x);
  const closest_y = new _M0TPC13ref3RefGdE(loc.y);
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
    const min_dist = new _M0TPC13ref3RefGdE(dx_pos);
    const loc_normal = new _M0TPC13ref3RefGRP36mizchi6kagura6vector4Vec2E(_M0MP36mizchi6kagura6vector4Vec23new(1, 0));
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
    return swapped ? new _M0TP36mizchi6kagura9physics2d9Contact2D(circle_body.id, obb_body.id, _M0MP36mizchi6kagura6vector4Vec26negate(world_normal), penetration, contact_point) : new _M0TP36mizchi6kagura9physics2d9Contact2D(obb_body.id, circle_body.id, world_normal, penetration, contact_point);
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
    return swapped ? new _M0TP36mizchi6kagura9physics2d9Contact2D(circle_body.id, obb_body.id, _M0MP36mizchi6kagura6vector4Vec26negate(world_normal), penetration, contact_point) : new _M0TP36mizchi6kagura9physics2d9Contact2D(obb_body.id, circle_body.id, world_normal, penetration, contact_point);
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
  const ax_a = _M0MP36mizchi6kagura6vector4Vec23new(_M0FPC14math3cos(a.angle), _M0FPC14math3sin(a.angle));
  const ay_a = _M0MP36mizchi6kagura6vector4Vec23new(-_M0FPC14math3sin(a.angle), _M0FPC14math3cos(a.angle));
  const ax_b = _M0MP36mizchi6kagura6vector4Vec23new(_M0FPC14math3cos(b.angle), _M0FPC14math3sin(b.angle));
  const ay_b = _M0MP36mizchi6kagura6vector4Vec23new(-_M0FPC14math3sin(b.angle), _M0FPC14math3cos(b.angle));
  const axes = [ax_a, ay_a, ax_b, ay_b];
  const min_overlap = new _M0TPC13ref3RefGdE(1e+30);
  const best_axis = new _M0TPC13ref3RefGRP36mizchi6kagura6vector4Vec2E(_M0MP36mizchi6kagura6vector4Vec24zero());
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < axes.length) {
      const axis = _M0MPC15array5Array2atGUddbdEE(axes, i);
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
  const cp_sum = new _M0TPC13ref3RefGRP36mizchi6kagura6vector4Vec2E(_M0MP36mizchi6kagura6vector4Vec24zero());
  const cp_count = new _M0TPC13ref3RefGiE(0);
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < 4) {
      const v = _M0MP36mizchi6kagura6vector4Vec23add(center_a, _M0MP36mizchi6kagura6vector4Vec26rotate(_M0MPC15array5Array2atGUddbdEE(local_corners_a, i), a.angle));
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
      const v = _M0MP36mizchi6kagura6vector4Vec23add(center_b, _M0MP36mizchi6kagura6vector4Vec26rotate(_M0MPC15array5Array2atGUddbdEE(local_corners_b, i), b.angle));
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
  return new _M0TP36mizchi6kagura9physics2d9Contact2D(a.id, b.id, best_axis.val, min_overlap.val, contact_point);
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
    return _M0FP36mizchi6kagura9physics2d8obb__obb(a, he_a$2, off_a$2, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(b.id, b.body_type, b.position, b.velocity, b.force, 0, b.angular_velocity, b.torque, b.mass, b.inv_mass, b.restitution, b.friction, b.inv_inertia, b.angular_damping, b.linear_damping, b.collider, b.is_sleeping, b.sleep_timer, b.is_bullet), he_b$2, off_b$2);
  }
  return _M0FP36mizchi6kagura9physics2d8obb__obb(new _M0TP36mizchi6kagura9physics2d11RigidBody2D(a.id, a.body_type, a.position, a.velocity, a.force, 0, a.angular_velocity, a.torque, a.mass, a.inv_mass, a.restitution, a.friction, a.inv_inertia, a.angular_damping, a.linear_damping, a.collider, a.is_sleeping, a.sleep_timer, a.is_bullet), he_a, off_a, b, he_b, off_b);
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
  return new _M0TP36mizchi6kagura9physics2d19ContactConstraint2D(idx_a, idx_b, contact, r_a, r_b, normal_mass, tangent_mass, gamma, beta, restitution_bias, 0, 0);
}
function _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, id) {
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < bodies.length) {
      if (_M0MPC15array5Array2atGUddbdEE(bodies, i).id === id) {
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
  const c = _M0FPC14math3cos(angle);
  const s = _M0FPC14math3sin(angle);
  return _M0MP36mizchi6kagura6vector4Vec23new(v.x * c - v.y * s, v.x * s + v.y * c);
}
function _M0FP36mizchi6kagura9physics2d27precompute__distance__joint(joint, bodies, sub_dt) {
  const idx_a = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_a_id);
  const idx_b = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_b_id);
  if (idx_a < 0 || idx_b < 0) {
    return undefined;
  }
  const a = _M0MPC15array5Array2atGUddbdEE(bodies, idx_a);
  const b = _M0MPC15array5Array2atGUddbdEE(bodies, idx_b);
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
  return new _M0TP36mizchi6kagura9physics2d25DistanceJointConstraint2D(idx_a, idx_b, r_a, r_b, axis, effective_mass, gamma, beta, 0);
}
function _M0FP36mizchi6kagura9physics2d27precompute__revolute__joint(joint, bodies, sub_dt) {
  const idx_a = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_a_id);
  const idx_b = _M0FP36mizchi6kagura9physics2d17find__body__index(bodies, joint.body_b_id);
  if (idx_a < 0 || idx_b < 0) {
    return undefined;
  }
  const a = _M0MPC15array5Array2atGUddbdEE(bodies, idx_a);
  const b = _M0MPC15array5Array2atGUddbdEE(bodies, idx_b);
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
  return new _M0TP36mizchi6kagura9physics2d25RevoluteJointConstraint2D(idx_a, idx_b, r_a, r_b, eff_mass_x, eff_mass_y, gamma, beta, 0, 0);
}
function _M0FP36mizchi6kagura9physics2d14clamp__angular(omega) {
  return omega > _M0FP36mizchi6kagura9physics2d22max__angular__velocity ? _M0FP36mizchi6kagura9physics2d22max__angular__velocity : omega < -_M0FP36mizchi6kagura9physics2d22max__angular__velocity ? -_M0FP36mizchi6kagura9physics2d22max__angular__velocity : omega;
}
function _M0FP36mizchi6kagura9physics2d19solve__constraint2d(constraints, ci, bodies) {
  const c = _M0MPC15array5Array2atGUddbdEE(constraints, ci);
  const a = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_a);
  const b = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_b);
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
  const cur_acc_jt = new _M0TPC13ref3RefGdE(c.acc_jt);
  if (Math.abs(delta_jn) > 1e-15) {
    const impulse_n = _M0MP36mizchi6kagura6vector4Vec25scale(n, delta_jn);
    const r_a_cross_n = _M0MP36mizchi6kagura6vector4Vec25cross(c.r_a, n);
    const r_b_cross_n = _M0MP36mizchi6kagura6vector4Vec25cross(c.r_b, n);
    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(a.id, a.body_type, a.position, _M0MP36mizchi6kagura6vector4Vec23add(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_n, a.inv_mass)), a.force, a.angle, _M0FP36mizchi6kagura9physics2d14clamp__angular(a.angular_velocity + r_a_cross_n * delta_jn * a.inv_inertia), a.torque, a.mass, a.inv_mass, a.restitution, a.friction, a.inv_inertia, a.angular_damping, a.linear_damping, a.collider, a.is_sleeping, a.sleep_timer, a.is_bullet));
    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(b.id, b.body_type, b.position, _M0MP36mizchi6kagura6vector4Vec23sub(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_n, b.inv_mass)), b.force, b.angle, _M0FP36mizchi6kagura9physics2d14clamp__angular(b.angular_velocity - r_b_cross_n * delta_jn * b.inv_inertia), b.torque, b.mass, b.inv_mass, b.restitution, b.friction, b.inv_inertia, b.angular_damping, b.linear_damping, b.collider, b.is_sleeping, b.sleep_timer, b.is_bullet));
  }
  const a2 = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_a);
  const b2 = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_b);
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
      _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(a2.id, a2.body_type, a2.position, _M0MP36mizchi6kagura6vector4Vec23add(a2.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_t, a2.inv_mass)), a2.force, a2.angle, _M0FP36mizchi6kagura9physics2d14clamp__angular(a2.angular_velocity + r_a_cross_t * delta_jt * a2.inv_inertia), a2.torque, a2.mass, a2.inv_mass, a2.restitution, a2.friction, a2.inv_inertia, a2.angular_damping, a2.linear_damping, a2.collider, a2.is_sleeping, a2.sleep_timer, a2.is_bullet));
      _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(b2.id, b2.body_type, b2.position, _M0MP36mizchi6kagura6vector4Vec23sub(b2.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse_t, b2.inv_mass)), b2.force, b2.angle, _M0FP36mizchi6kagura9physics2d14clamp__angular(b2.angular_velocity - r_b_cross_t * delta_jt * b2.inv_inertia), b2.torque, b2.mass, b2.inv_mass, b2.restitution, b2.friction, b2.inv_inertia, b2.angular_damping, b2.linear_damping, b2.collider, b2.is_sleeping, b2.sleep_timer, b2.is_bullet));
    }
  }
  _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(constraints, ci, new _M0TP36mizchi6kagura9physics2d19ContactConstraint2D(c.idx_a, c.idx_b, c.contact, c.r_a, c.r_b, c.normal_mass, c.tangent_mass, c.gamma, c.bias_coefficient, c.restitution_bias, cur_acc_jn, cur_acc_jt.val));
}
function _M0FP36mizchi6kagura9physics2d22solve__distance__joint(constraints, ci, bodies, joint) {
  const c = _M0MPC15array5Array2atGUddbdEE(constraints, ci);
  const a = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_a);
  const b = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_b);
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
    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(a.id, a.body_type, a.position, _M0MP36mizchi6kagura6vector4Vec23sub(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, a.inv_mass)), a.force, a.angle, a.angular_velocity - r_a_cross * delta_impulse * a.inv_inertia, a.torque, a.mass, a.inv_mass, a.restitution, a.friction, a.inv_inertia, a.angular_damping, a.linear_damping, a.collider, a.is_sleeping, a.sleep_timer, a.is_bullet));
    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(b.id, b.body_type, b.position, _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, b.inv_mass)), b.force, b.angle, b.angular_velocity + r_b_cross * delta_impulse * b.inv_inertia, b.torque, b.mass, b.inv_mass, b.restitution, b.friction, b.inv_inertia, b.angular_damping, b.linear_damping, b.collider, b.is_sleeping, b.sleep_timer, b.is_bullet));
  }
  _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(constraints, ci, new _M0TP36mizchi6kagura9physics2d25DistanceJointConstraint2D(c.idx_a, c.idx_b, c.r_a, c.r_b, c.axis, c.effective_mass, c.gamma, c.bias_coefficient, new_acc));
}
function _M0FP36mizchi6kagura9physics2d22solve__revolute__joint(constraints, ci, bodies) {
  const c = _M0MPC15array5Array2atGUddbdEE(constraints, ci);
  const a = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_a);
  const b = _M0MPC15array5Array2atGUddbdEE(bodies, c.idx_b);
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
    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_a, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(a.id, a.body_type, a.position, _M0MP36mizchi6kagura6vector4Vec23sub(a.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, a.inv_mass)), a.force, a.angle, a.angular_velocity - angular_a * a.inv_inertia, a.torque, a.mass, a.inv_mass, a.restitution, a.friction, a.inv_inertia, a.angular_damping, a.linear_damping, a.collider, a.is_sleeping, a.sleep_timer, a.is_bullet));
    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(bodies, c.idx_b, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(b.id, b.body_type, b.position, _M0MP36mizchi6kagura6vector4Vec23add(b.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, b.inv_mass)), b.force, b.angle, b.angular_velocity + angular_b * b.inv_inertia, b.torque, b.mass, b.inv_mass, b.restitution, b.friction, b.inv_inertia, b.angular_damping, b.linear_damping, b.collider, b.is_sleeping, b.sleep_timer, b.is_bullet));
  }
  _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(constraints, ci, new _M0TP36mizchi6kagura9physics2d25RevoluteJointConstraint2D(c.idx_a, c.idx_b, c.r_a, c.r_b, c.effective_mass_x, c.effective_mass_y, c.gamma, c.bias_coefficient, new_acc_x, new_acc_y));
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
  const cos_a = Math.abs(_M0FPC14math3cos(self.angle));
  const sin_a = Math.abs(_M0FPC14math3sin(self.angle));
  const ex = half_extents.x * cos_a + half_extents.y * sin_a;
  const ey = half_extents.x * sin_a + half_extents.y * cos_a;
  const ext = _M0MP36mizchi6kagura6vector4Vec23new(ex, ey);
  return _M0MP36mizchi6kagura9physics2d6AABB2D3new(_M0MP36mizchi6kagura6vector4Vec23sub(center, ext), _M0MP36mizchi6kagura6vector4Vec23add(center, ext));
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D5clear(self) {
  _M0MPB3Map5clearGlRPB5ArrayGiEE(self.cells);
  _M0MPC15array5Array5clearGRP36mizchi6kagura9physics2d17BroadphaseEntry2DE(self.entries);
}
function _M0MP36mizchi6kagura9physics2d6AABB2D10intersects(self, other) {
  return self.min.x <= other.max.x && (self.max.x >= other.min.x && (self.min.y <= other.max.y && self.max.y >= other.min.y));
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D10get__pairs(self) {
  const _bind = [];
  const seen = _M0MPB3Map11from__arrayGluE(new _M0TPB9ArrayViewGUluEE(_bind, 0, 0));
  const result = [];
  _M0MPB3Map4eachGlRPB5ArrayGiEE(self.cells, (_key, bucket) => {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < bucket.length) {
        let _tmp$2 = i + 1 | 0;
        while (true) {
          const j = _tmp$2;
          if (j < bucket.length) {
            const a = _M0MPC15array5Array2atGUddbdEE(self.entries, _M0MPC15array5Array2atGiE(bucket, i));
            const b = _M0MPC15array5Array2atGUddbdEE(self.entries, _M0MPC15array5Array2atGiE(bucket, j));
            const min_id = a.id < b.id ? a.id : b.id;
            const max_id = a.id > b.id ? a.id : b.id;
            const pair_key = _M0IPC15int645Int64PB5BitOr3lor(_M0IPC15int645Int64PB3Shl3shl(_M0MPC13int3Int9to__int64(min_id), 32), _M0MPC13int3Int9to__int64(max_id));
            const _bind$2 = _M0MPB3Map3getGluE(seen, pair_key);
            if (_bind$2 === -1) {
              _M0MPB3Map3setGluE(seen, pair_key, undefined);
              if (_M0MP36mizchi6kagura9physics2d6AABB2D10intersects(a.aabb, b.aabb)) {
                _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(result, { _0: min_id, _1: max_id });
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
  const x = _M0IPC15int645Int64PB6BitAnd4land(_M0MPC13int3Int9to__int64(cx), mask);
  const y = _M0IPC15int645Int64PB6BitAnd4land(_M0MPC13int3Int9to__int64(cy), mask);
  return _M0IPC15int645Int64PB5BitOr3lor(_M0IPC15int645Int64PB3Shl3shl(x, 32), y);
}
function _M0FP36mizchi6kagura9physics2d14floor__to__int(x) {
  const i = _M0MPC16double6Double7to__int(x);
  return x < i + 0 ? i - 1 | 0 : i;
}
function _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D6insert(self, id, aabb) {
  const idx = self.entries.length;
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(self.entries, new _M0TP36mizchi6kagura9physics2d17BroadphaseEntry2D(id, aabb));
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
              const _bind = _M0MPB3Map3getGlRPB5ArrayGiEE(self.cells, key);
              if (_bind.$tag === 1) {
                const _Some = _bind;
                const _bucket = _Some._0;
                bucket = _bucket;
                break _L$2;
              } else {
                _M0MPB3Map3setGlRPB5ArrayGiEE(self.cells, key, [idx]);
              }
              break _L;
            }
            _M0MPC15array5Array4pushGiE(bucket, idx);
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
      _M0MP36mizchi6kagura9physics2d17SpatialHashGrid2D6insert(self.broadphase, i, _M0MP36mizchi6kagura9physics2d11RigidBody2D11world__aabb(_M0MPC15array5Array2atGUddbdEE(self.bodies, i)));
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
        const _bind = _M0MPC15array5Array2atGUddbdEE(pairs, p);
        const _idx_a = _bind._0;
        const _idx_b = _bind._1;
        idx_a = _idx_a;
        idx_b = _idx_b;
        break _L;
      }
      const body_a = _M0MPC15array5Array2atGUddbdEE(self.bodies, idx_a);
      const body_b = _M0MPC15array5Array2atGUddbdEE(self.bodies, idx_b);
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
          _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(raw_contacts, { _0: idx_a, _1: idx_b, _2: contact });
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
  const new_cache = _M0MPB3Map11from__arrayGlRP36mizchi6kagura9physics2d17ContactManifold2DE(new _M0TPB9ArrayViewGUlRP36mizchi6kagura9physics2d17ContactManifold2DEE(_bind, 0, 0));
  let _tmp$3 = 0;
  while (true) {
    const c = _tmp$3;
    if (c < raw_contacts.length) {
      let idx_b;
      let idx_a;
      let contact;
      _L: {
        const _bind$2 = _M0MPC15array5Array2atGUddbdEE(raw_contacts, c);
        const _idx_a = _bind$2._0;
        const _idx_b = _bind$2._1;
        const _contact = _bind$2._2;
        idx_b = _idx_b;
        idx_a = _idx_a;
        contact = _contact;
        break _L;
      }
      const body_a = _M0MPC15array5Array2atGUddbdEE(self.bodies, idx_a);
      const body_b = _M0MPC15array5Array2atGUddbdEE(self.bodies, idx_b);
      const constraint = new _M0TPC13ref3RefGRP36mizchi6kagura9physics2d19ContactConstraint2DE(_M0FP36mizchi6kagura9physics2d24precompute__constraint2d(body_a, body_b, idx_a, idx_b, contact, config.contact_hertz, config.contact_damping_ratio, sub_dt));
      const pair_key = _M0FP36mizchi6kagura9physics2d18contact__pair__key(body_a.id, body_b.id);
      let cached;
      _L$2: {
        _L$3: {
          const _bind$2 = _M0MPB3Map3getGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self.contact_cache, pair_key);
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
            const pt = _M0MPC15array5Array2atGUddbdEE(cached.points, 0);
            const warm_factor = 0.8;
            const _tmp$4 = constraint.val;
            constraint.val = new _M0TP36mizchi6kagura9physics2d19ContactConstraint2D(_tmp$4.idx_a, _tmp$4.idx_b, _tmp$4.contact, _tmp$4.r_a, _tmp$4.r_b, _tmp$4.normal_mass, _tmp$4.tangent_mass, _tmp$4.gamma, _tmp$4.bias_coefficient, _tmp$4.restitution_bias, pt.normal_impulse * warm_factor, pt.tangent_impulse * warm_factor);
            const n = contact.normal;
            const tangent = _M0MP36mizchi6kagura6vector4Vec23new(-n.y, n.x);
            const jn = pt.normal_impulse * warm_factor;
            const jt = pt.tangent_impulse * warm_factor;
            if (Math.abs(jn) > 1e-15 || Math.abs(jt) > 1e-15) {
              const impulse = _M0MP36mizchi6kagura6vector4Vec23add(_M0MP36mizchi6kagura6vector4Vec25scale(n, jn), _M0MP36mizchi6kagura6vector4Vec25scale(tangent, jt));
              const _tmp$5 = self.bodies;
              const _tmp$6 = _M0MPC15array5Array2atGUddbdEE(self.bodies, idx_a);
              _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(_tmp$5, idx_a, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(_tmp$6.id, _tmp$6.body_type, _tmp$6.position, _M0MP36mizchi6kagura6vector4Vec23add(_M0MPC15array5Array2atGUddbdEE(self.bodies, idx_a).velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, body_a.inv_mass)), _tmp$6.force, _tmp$6.angle, _tmp$6.angular_velocity, _tmp$6.torque, _tmp$6.mass, _tmp$6.inv_mass, _tmp$6.restitution, _tmp$6.friction, _tmp$6.inv_inertia, _tmp$6.angular_damping, _tmp$6.linear_damping, _tmp$6.collider, _tmp$6.is_sleeping, _tmp$6.sleep_timer, _tmp$6.is_bullet));
              const _tmp$7 = self.bodies;
              const _tmp$8 = _M0MPC15array5Array2atGUddbdEE(self.bodies, idx_b);
              _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(_tmp$7, idx_b, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(_tmp$8.id, _tmp$8.body_type, _tmp$8.position, _M0MP36mizchi6kagura6vector4Vec23sub(_M0MPC15array5Array2atGUddbdEE(self.bodies, idx_b).velocity, _M0MP36mizchi6kagura6vector4Vec25scale(impulse, body_b.inv_mass)), _tmp$8.force, _tmp$8.angle, _tmp$8.angular_velocity, _tmp$8.torque, _tmp$8.mass, _tmp$8.inv_mass, _tmp$8.restitution, _tmp$8.friction, _tmp$8.inv_inertia, _tmp$8.angular_damping, _tmp$8.linear_damping, _tmp$8.collider, _tmp$8.is_sleeping, _tmp$8.sleep_timer, _tmp$8.is_bullet));
            }
          }
        }
      }
      _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(constraints, constraint.val);
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
          const _bind$2 = _M0FP36mizchi6kagura9physics2d27precompute__distance__joint(_M0MPC15array5Array2atGUddbdEE(self.joints_distance, j), self.bodies, sub_dt);
          if (_bind$2 === undefined) {
          } else {
            const _Some = _bind$2;
            const _c = _Some;
            c = _c;
            break _L$2;
          }
          break _L;
        }
        _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(dist_constraints, c);
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
          const _bind$2 = _M0FP36mizchi6kagura9physics2d27precompute__revolute__joint(_M0MPC15array5Array2atGUddbdEE(self.joints_revolute, j), self.bodies, sub_dt);
          if (_bind$2 === undefined) {
          } else {
            const _Some = _bind$2;
            const _c = _Some;
            c = _c;
            break _L$2;
          }
          break _L;
        }
        _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(rev_constraints, c);
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
          const body = _M0MPC15array5Array2atGUddbdEE(self.bodies, i);
          if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body) && !body.is_sleeping) {
            const accel = _M0MP36mizchi6kagura6vector4Vec23add(self.gravity, _M0MP36mizchi6kagura6vector4Vec25scale(body.force, body.inv_mass));
            const new_vel = _M0MP36mizchi6kagura6vector4Vec25scale(_M0MP36mizchi6kagura6vector4Vec23add(body.velocity, _M0MP36mizchi6kagura6vector4Vec25scale(accel, sub_dt)), 1 - body.linear_damping * sub_dt);
            const angular_accel = body.torque * body.inv_inertia;
            const new_angular_vel = (body.angular_velocity + angular_accel * sub_dt) * (1 - body.angular_damping * sub_dt);
            _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, body.position, new_vel, body.force, body.angle, new_angular_vel, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, body.is_sleeping, body.sleep_timer, body.is_bullet));
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
              _M0FP36mizchi6kagura9physics2d22solve__distance__joint(dist_constraints, di, self.bodies, _M0MPC15array5Array2atGUddbdEE(self.joints_distance, di));
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
          const body = _M0MPC15array5Array2atGUddbdEE(self.bodies, i);
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
                    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, _M0MP36mizchi6kagura6vector4Vec23add(body.position, _M0MP36mizchi6kagura6vector4Vec25scale(body.velocity, sub_dt)), body.velocity, body.force, body.angle + body.angular_velocity * sub_dt, body.angular_velocity, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, body.is_sleeping, body.sleep_timer, body.is_bullet));
                  }
                  break _L;
                }
                const safe_toi = toi > 0.01 ? toi * 0.95 : 0;
                _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, _M0MP36mizchi6kagura6vector4Vec23add(body.position, _M0MP36mizchi6kagura6vector4Vec25scale(body.velocity, sub_dt * safe_toi)), body.velocity, body.force, body.angle + body.angular_velocity * sub_dt * safe_toi, body.angular_velocity, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, body.is_sleeping, body.sleep_timer, body.is_bullet));
              }
            } else {
              _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, _M0MP36mizchi6kagura6vector4Vec23add(body.position, _M0MP36mizchi6kagura6vector4Vec25scale(body.velocity, sub_dt)), body.velocity, body.force, body.angle + body.angular_velocity * sub_dt, body.angular_velocity, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, body.is_sleeping, body.sleep_timer, body.is_bullet));
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
      const con = _M0MPC15array5Array2atGUddbdEE(constraints, c);
      const body_a = _M0MPC15array5Array2atGUddbdEE(self.bodies, con.idx_a);
      const body_b = _M0MPC15array5Array2atGUddbdEE(self.bodies, con.idx_b);
      const pair_key = _M0FP36mizchi6kagura9physics2d18contact__pair__key(body_a.id, body_b.id);
      const local_a = _M0MP36mizchi6kagura6vector4Vec23sub(con.contact.contact_point, body_a.position);
      const local_b = _M0MP36mizchi6kagura6vector4Vec23sub(con.contact.contact_point, body_b.position);
      _M0MPB3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(new_cache, pair_key, new _M0TP36mizchi6kagura9physics2d17ContactManifold2D(body_a.id, body_b.id, con.contact.normal, [new _M0TP36mizchi6kagura9physics2d15ManifoldPoint2D(local_a, local_b, con.contact.penetration, con.acc_jn, con.acc_jt)]));
      _tmp$7 = c + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MPB3Map5clearGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self.contact_cache);
  _M0MPB3Map4eachGlRP36mizchi6kagura9physics2d17ContactManifold2DE(new_cache, (k, v) => {
    _M0MPB3Map3setGlRP36mizchi6kagura9physics2d17ContactManifold2DE(self.contact_cache, k, v);
  });
  let _tmp$8 = 0;
  while (true) {
    const i = _tmp$8;
    if (i < self.bodies.length) {
      const body = _M0MPC15array5Array2atGUddbdEE(self.bodies, i);
      if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
        _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, body.position, body.velocity, _M0MP36mizchi6kagura6vector4Vec24zero(), body.angle, body.angular_velocity, 0, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, body.is_sleeping, body.sleep_timer, body.is_bullet));
      }
      _tmp$8 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const n = self.bodies.length;
  if (n > 0) {
    const parent = _M0MPC15array5Array4makeGiE(n, 0);
    const rank = _M0MPC15array5Array4makeGiE(n, 0);
    let _tmp$9 = 0;
    while (true) {
      const i = _tmp$9;
      if (i < n) {
        _M0MPC15array5Array3setGiE(parent, i, i);
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
        const con = _M0MPC15array5Array2atGUddbdEE(constraints, c);
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
        const body = _M0MPC15array5Array2atGUddbdEE(self.bodies, i);
        if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
          const speed = _M0MP36mizchi6kagura6vector4Vec26length(body.velocity);
          const angular_speed = Math.abs(body.angular_velocity);
          if (speed < _M0FP36mizchi6kagura9physics2d26sleep__velocity__threshold && angular_speed < _M0FP36mizchi6kagura9physics2d25sleep__angular__threshold) {
            _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, body.position, body.velocity, body.force, body.angle, body.angular_velocity, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, body.is_sleeping, body.sleep_timer + dt, body.is_bullet));
          } else {
            _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, body.position, body.velocity, body.force, body.angle, body.angular_velocity, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, false, 0, body.is_bullet));
          }
        }
        _tmp$11 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    const _bind$2 = [];
    const island_can_sleep = _M0MPB3Map11from__arrayGibE(new _M0TPB9ArrayViewGUibEE(_bind$2, 0, 0));
    let _tmp$12 = 0;
    while (true) {
      const i = _tmp$12;
      if (i < n) {
        const body = _M0MPC15array5Array2atGUddbdEE(self.bodies, i);
        if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
          const root = _M0FP36mizchi6kagura9physics2d8uf__find(parent, i);
          const can_sleep = body.sleep_timer >= _M0FP36mizchi6kagura9physics2d22sleep__time__threshold;
          let prev;
          _L: {
            _L$2: {
              const _bind$3 = _M0MPB3Map3getGibE(island_can_sleep, root);
              if (_bind$3 === -1) {
                _M0MPB3Map3setGibE(island_can_sleep, root, can_sleep);
              } else {
                const _Some = _bind$3;
                const _prev = _Some;
                prev = _prev;
                break _L$2;
              }
              break _L;
            }
            _M0MPB3Map3setGibE(island_can_sleep, root, prev && can_sleep);
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
        const body = _M0MPC15array5Array2atGUddbdEE(self.bodies, i);
        if (_M0MP36mizchi6kagura9physics2d11RigidBody2D11is__dynamic(body)) {
          const root = _M0FP36mizchi6kagura9physics2d8uf__find(parent, i);
          _L: {
            _L$2: {
              const _bind$3 = _M0MPB3Map3getGibE(island_can_sleep, root);
              if (_bind$3 === -1) {
                break _L$2;
              } else {
                const _Some = _bind$3;
                const _x = _Some;
                if (_x === true) {
                  if (!body.is_sleeping) {
                    _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, body.position, _M0MP36mizchi6kagura6vector4Vec24zero(), body.force, body.angle, 0, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, true, body.sleep_timer, body.is_bullet));
                  }
                } else {
                  break _L$2;
                }
              }
              break _L;
            }
            if (body.is_sleeping) {
              _M0MPC15array5Array3setGRP36mizchi6kagura9physics2d11RigidBody2DE(self.bodies, i, new _M0TP36mizchi6kagura9physics2d11RigidBody2D(body.id, body.body_type, body.position, body.velocity, body.force, body.angle, body.angular_velocity, body.torque, body.mass, body.inv_mass, body.restitution, body.friction, body.inv_inertia, body.angular_damping, body.linear_damping, body.collider, false, 0, body.is_bullet));
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
  return new _M0TP36mizchi6kagura9physics2d11RigidBody2D(id, _bind, position, _bind$2, _bind$3, _bind$4, _bind$5, _bind$6, mass, _bind$7, _bind$8, _bind$9, _bind$10, _bind$11, _bind$12, collider, _bind$13, _bind$14, _bind$15);
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D17with__restitution(self, e) {
  return new _M0TP36mizchi6kagura9physics2d11RigidBody2D(self.id, self.body_type, self.position, self.velocity, self.force, self.angle, self.angular_velocity, self.torque, self.mass, self.inv_mass, e, self.friction, self.inv_inertia, self.angular_damping, self.linear_damping, self.collider, self.is_sleeping, self.sleep_timer, self.is_bullet);
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D14with__friction(self, f) {
  return new _M0TP36mizchi6kagura9physics2d11RigidBody2D(self.id, self.body_type, self.position, self.velocity, self.force, self.angle, self.angular_velocity, self.torque, self.mass, self.inv_mass, self.restitution, f, self.inv_inertia, self.angular_damping, self.linear_damping, self.collider, self.is_sleeping, self.sleep_timer, self.is_bullet);
}
function _M0MP36mizchi6kagura9physics2d11RigidBody2D13with__damping(self, d) {
  return new _M0TP36mizchi6kagura9physics2d11RigidBody2D(self.id, self.body_type, self.position, self.velocity, self.force, self.angle, self.angular_velocity, self.torque, self.mass, self.inv_mass, self.restitution, self.friction, self.inv_inertia, self.angular_damping, d, self.collider, self.is_sleeping, self.sleep_timer, self.is_bullet);
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
function _M0FP26mizchi15physics2d__demo20draw__filled__circle(cmds, dst, shader, cx, cy, radius, color, sw, sh) {
  const n = _M0FP26mizchi15physics2d__demo16circle__segments;
  const vertices = [];
  const indices = [];
  const ndc_cx = cx / sw * 2 - 1;
  const ndc_cy = 1 - cy / sh * 2;
  _M0MPC15array5Array4pushGdE(vertices, ndc_cx);
  _M0MPC15array5Array4pushGdE(vertices, ndc_cy);
  _M0MPC15array5Array4pushGdE(vertices, 0.5);
  _M0MPC15array5Array4pushGdE(vertices, 0.5);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i <= n) {
      const angle = (i + 0) / (n + 0) * 2 * 3.14159265358979312;
      const px = cx + radius * _M0FPC14math3cos(angle);
      const py = cy + radius * _M0FPC14math3sin(angle);
      const ndc_x = px / sw * 2 - 1;
      const ndc_y = 1 - py / sh * 2;
      _M0MPC15array5Array4pushGdE(vertices, ndc_x);
      _M0MPC15array5Array4pushGdE(vertices, ndc_y);
      _M0MPC15array5Array4pushGdE(vertices, 0.5);
      _M0MPC15array5Array4pushGdE(vertices, 0.5);
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
      _M0MPC15array5Array4pushGiE(indices, 0);
      _M0MPC15array5Array4pushGiE(indices, i);
      _M0MPC15array5Array4pushGiE(indices, i + 1 | 0);
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil26new__simple__draw__command(dst, shader, vertices, indices, color));
}
function _M0FP26mizchi15physics2d__demo18draw__rotated__box(cmds, dst, shader, cx, cy, hw, hh, angle, color, sw, sh) {
  const corners = [{ _0: -hw, _1: -hh }, { _0: hw, _1: -hh }, { _0: hw, _1: hh }, { _0: -hw, _1: hh }];
  const cos_a = _M0FPC14math3cos(-angle);
  const sin_a = _M0FPC14math3sin(-angle);
  const vertices = [];
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < 4) {
      let lx;
      let ly;
      _L: {
        const _bind = _M0MPC15array5Array2atGUddbdEE(corners, i);
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
      _M0MPC15array5Array4pushGdE(vertices, ndc_x);
      _M0MPC15array5Array4pushGdE(vertices, ndc_y);
      _M0MPC15array5Array4pushGdE(vertices, 0.5);
      _M0MPC15array5Array4pushGdE(vertices, 0.5);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const indices = [0, 1, 2, 0, 2, 3];
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil26new__simple__draw__command(dst, shader, vertices, indices, color));
}
function _M0FP26mizchi15physics2d__demo14hex__to__color(hex) {
  return _M0FP36mizchi6kagura9debugutil16color__from__hex(hex);
}
function _M0FP26mizchi15physics2d__demo16get__body__color(id) {
  let hex;
  if (id < 3) {
    hex = 6710886;
  } else {
    if (_M0FP26mizchi15physics2d__demo15dynamic__colors.length === 0) {
      $panic();
    }
    hex = _M0MPC15array5Array2atGiE(_M0FP26mizchi15physics2d__demo15dynamic__colors, (id - 3 | 0) % _M0FP26mizchi15physics2d__demo15dynamic__colors.length | 0);
  }
  return _M0FP26mizchi15physics2d__demo14hex__to__color(hex);
}
function _M0FP26mizchi15physics2d__demo22physics__to__screen__x(px) {
  return (_M0FP26mizchi15physics2d__demo9screen__w + 0) / 2 + px * _M0FP26mizchi15physics2d__demo13px__per__unit;
}
function _M0FP26mizchi15physics2d__demo22physics__to__screen__y(py) {
  return (_M0FP26mizchi15physics2d__demo9screen__h + 0) / 2 - py * _M0FP26mizchi15physics2d__demo13px__per__unit;
}
function _M0MP26mizchi15physics2d__demo9DemoState4draw(self, ctx) {
  const cmds = [];
  const sw = _M0FP26mizchi15physics2d__demo9screen__w + 0;
  const sh = _M0FP26mizchi15physics2d__demo9screen__h + 0;
  _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(ctx.dst, ctx.shader, 0, 0, sw, sh, sw, sh, _M0FP36mizchi6kagura9debugutil16color__from__hex(1710638), 0));
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < self.world.bodies.length) {
      const body = _M0MPC15array5Array2atGUddbdEE(self.world.bodies, i);
      const color = _M0FP26mizchi15physics2d__demo16get__body__color(body.id);
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
              const cx = _M0FP26mizchi15physics2d__demo22physics__to__screen__x(body.position.x + offset$3.x);
              const cy = _M0FP26mizchi15physics2d__demo22physics__to__screen__y(body.position.y + offset$3.y);
              const screen_r = radius * _M0FP26mizchi15physics2d__demo13px__per__unit;
              _M0FP26mizchi15physics2d__demo20draw__filled__circle(cmds, ctx.dst, ctx.shader, cx, cy, screen_r, color, sw, sh);
              break _L$3;
            }
            const cx = body.position.x + offset$2.x;
            const cy = body.position.y + offset$2.y;
            const screen_x = _M0FP26mizchi15physics2d__demo22physics__to__screen__x(cx - half_extents$2.x);
            const screen_y = _M0FP26mizchi15physics2d__demo22physics__to__screen__y(cy + half_extents$2.y);
            const screen_w2 = half_extents$2.x * 2 * _M0FP26mizchi15physics2d__demo13px__per__unit;
            const screen_h2 = half_extents$2.y * 2 * _M0FP26mizchi15physics2d__demo13px__per__unit;
            _M0MPC15array5Array4pushGRP36mizchi6kagura3gfx20DrawTrianglesCommandE(cmds, _M0FP36mizchi6kagura9debugutil29new__ndc__rect__fill__command(ctx.dst, ctx.shader, screen_x, screen_y, screen_w2, screen_h2, sw, sh, color, 0));
          }
          break _L;
        }
        const phys_cx = body.position.x + offset.x;
        const phys_cy = body.position.y + offset.y;
        const scx = _M0FP26mizchi15physics2d__demo22physics__to__screen__x(phys_cx);
        const scy = _M0FP26mizchi15physics2d__demo22physics__to__screen__y(phys_cy);
        const shw = half_extents.x * _M0FP26mizchi15physics2d__demo13px__per__unit;
        const shh = half_extents.y * _M0FP26mizchi15physics2d__demo13px__per__unit;
        _M0FP26mizchi15physics2d__demo18draw__rotated__box(cmds, ctx.dst, ctx.shader, scx, scy, shw, shh, body.angle, color, sw, sh);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return cmds;
}
function _M0FP26mizchi15physics2d__demo18make__dynamic__box(id, x, y, hx, hy) {
  const angular_vel = _M0IPC16double6DoublePB3Mod3mod((id + 0) * 1.7, 2) - 1;
  const _tmp = _M0MP36mizchi6kagura9physics2d11RigidBody2D13with__damping(_M0MP36mizchi6kagura9physics2d11RigidBody2D14with__friction(_M0MP36mizchi6kagura9physics2d11RigidBody2D17with__restitution(_M0MP36mizchi6kagura9physics2d11RigidBody2D12new__dynamic(id, _M0MP36mizchi6kagura6vector4Vec23new(x, y), hx * hy * 4, new _M0DTP36mizchi6kagura9physics2d15ColliderShape2D10OBBShape2D(_M0MP36mizchi6kagura6vector4Vec23new(hx, hy), _M0MP36mizchi6kagura6vector4Vec24zero())), 0.3), 0.5), 0.05);
  return new _M0TP36mizchi6kagura9physics2d11RigidBody2D(_tmp.id, _tmp.body_type, _tmp.position, _tmp.velocity, _tmp.force, _tmp.angle, angular_vel, _tmp.torque, _tmp.mass, _tmp.inv_mass, _tmp.restitution, _tmp.friction, _tmp.inv_inertia, _tmp.angular_damping, _tmp.linear_damping, _tmp.collider, _tmp.is_sleeping, _tmp.sleep_timer, _tmp.is_bullet);
}
function _M0FP26mizchi15physics2d__demo21make__dynamic__circle(id, x, y, radius) {
  return _M0MP36mizchi6kagura9physics2d11RigidBody2D13with__damping(_M0MP36mizchi6kagura9physics2d11RigidBody2D14with__friction(_M0MP36mizchi6kagura9physics2d11RigidBody2D17with__restitution(_M0MP36mizchi6kagura9physics2d11RigidBody2D12new__dynamic(id, _M0MP36mizchi6kagura6vector4Vec23new(x, y), radius * radius * 3.14, new _M0DTP36mizchi6kagura9physics2d15ColliderShape2D11CircleShape(_M0MP36mizchi6kagura6vector4Vec24zero(), radius)), 0.3), 0.5), 0.05);
}
function _M0FP26mizchi15physics2d__demo18make__static__body(id, x, y, hx, hy) {
  return new _M0TP36mizchi6kagura9physics2d11RigidBody2D(id, 1, _M0MP36mizchi6kagura6vector4Vec23new(x, y), _M0MP36mizchi6kagura6vector4Vec24zero(), _M0MP36mizchi6kagura6vector4Vec24zero(), 0, 0, 0, 0, 0, 0.3, 0.8, 0, 0, 0, new _M0DTP36mizchi6kagura9physics2d15ColliderShape2D11AABBShape2D(_M0MP36mizchi6kagura6vector4Vec23new(hx, hy), _M0MP36mizchi6kagura6vector4Vec24zero()), false, 0, false);
}
function _M0MP26mizchi15physics2d__demo9DemoState3new() {
  const world = _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D3new(_M0MP36mizchi6kagura6vector4Vec23new(0, -9.8), 4, undefined);
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi15physics2d__demo18make__static__body(0, 0, -6.5, 10, 2));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi15physics2d__demo18make__static__body(1, -9, 0, 2, 10));
  _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi15physics2d__demo18make__static__body(2, 9, 0, 2, 10));
  const spawn_data = [{ _0: -2, _1: 1, _2: true, _3: 0.5 }, { _0: 1, _1: 1.5, _2: false, _3: 0.4 }, { _0: 0, _1: 2.5, _2: true, _3: 0.35 }, { _0: -1.5, _1: 3, _2: false, _3: 0.55 }, { _0: 2, _1: 2, _2: true, _3: 0.6 }, { _0: -0.5, _1: 3.5, _2: false, _3: 0.3 }, { _0: 1.5, _1: 4, _2: true, _3: 0.45 }, { _0: -2.5, _1: 4.5, _2: false, _3: 0.5 }, { _0: 0.5, _1: 5, _2: true, _3: 0.3 }, { _0: 2.5, _1: 5.5, _2: false, _3: 0.35 }, { _0: 0, _1: 6, _2: true, _3: 0.7 }, { _0: -1, _1: 6.5, _2: false, _3: 0.45 }];
  const next_id = new _M0TPC13ref3RefGiE(3);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < spawn_data.length) {
      let is_circle;
      let x;
      let y;
      let size;
      _L: {
        const _bind = _M0MPC15array5Array2atGUddbdEE(spawn_data, i);
        const _x = _bind._0;
        const _y = _bind._1;
        const _is_circle = _bind._2;
        const _size = _bind._3;
        is_circle = _is_circle;
        x = _x;
        y = _y;
        size = _size;
        break _L;
      }
      if (is_circle) {
        _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi15physics2d__demo21make__dynamic__circle(next_id.val, x, y, size));
      } else {
        _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(world, _M0FP26mizchi15physics2d__demo18make__dynamic__box(next_id.val, x, y, size, size));
      }
      next_id.val = next_id.val + 1 | 0;
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP26mizchi15physics2d__demo9DemoState(world, _M0FP36mizchi6kagura9inpututil18new__input__helper(), 0, next_id.val);
}
function _M0FP26mizchi15physics2d__demo22screen__to__physics__x(sx) {
  return (sx - (_M0FP26mizchi15physics2d__demo9screen__w + 0) / 2) / _M0FP26mizchi15physics2d__demo13px__per__unit;
}
function _M0FP26mizchi15physics2d__demo22screen__to__physics__y(sy) {
  return ((_M0FP26mizchi15physics2d__demo9screen__h + 0) / 2 - sy) / _M0FP26mizchi15physics2d__demo13px__per__unit;
}
function _M0MP26mizchi15physics2d__demo9DemoState6update(self, snapshot) {
  _M0FP36mizchi6kagura9inpututil21update__input__helper(self.input, snapshot);
  self.frame = self.frame + 1 | 0;
  if (_M0FP36mizchi6kagura9inpututil32is__mouse__button__just__pressed(self.input.mouse_state, 0)) {
    const px = _M0FP26mizchi15physics2d__demo22screen__to__physics__x(snapshot.cursor_x);
    const py = _M0FP26mizchi15physics2d__demo22screen__to__physics__y(snapshot.cursor_y);
    if (2 === 0) {
      $panic();
    }
    const is_circle = (self.next_id % 2 | 0) === 0;
    if (is_circle) {
      _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(self.world, _M0FP26mizchi15physics2d__demo21make__dynamic__circle(self.next_id, px, py, 0.4));
    } else {
      _M0MP36mizchi6kagura9physics2d14PhysicsWorld2D9add__body(self.world, _M0FP26mizchi15physics2d__demo18make__dynamic__box(self.next_id, px, py, 0.4, 0.4));
    }
    self.next_id = self.next_id + 1 | 0;
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
  const state = _M0MP26mizchi15physics2d__demo9DemoState3new();
  _M0FP36mizchi6kagura6engine11run_2einner((input) => {
    _M0MP26mizchi15physics2d__demo9DemoState6update(state, input);
  }, (ctx) => _M0MP26mizchi15physics2d__demo9DemoState4draw(state, ctx), undefined, undefined, undefined, 735, _M0FP26mizchi15physics2d__demo9screen__w, _M0FP26mizchi15physics2d__demo9screen__h, "Physics 2D Demo", "#app");
})();
//# sourceMappingURL=physics2d_demo.js.map
