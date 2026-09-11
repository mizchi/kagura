///|
/// JS entry point for the headless capture path.
///
/// `run` checks `globalThis.__kaguraHeadless` before it touches a canvas,
/// a platform driver or `requestAnimationFrame`. When the object is present,
/// the game renders N ticks through the CPU rasterizer and the PNG lands on
/// `globalThis.__kaguraHeadlessFrame` instead of a swapchain. Nothing here
/// reaches for `node:` or a DOM global, so importing the built bundle in a
/// browser behaves exactly as before -- the request object is simply absent.
///
/// JS target only -- see `targets` in `moon.pkg`.

///|
/// Number of update ticks requested, or -1 when no headless render was asked
/// for. A request without an explicit `frames` renders one tick, which is
/// what "just show me the first frame" means.
extern "js" fn js_headless_frames() -> Int =
  #| () => {
  #|   const request = globalThis.__kaguraHeadless;
  #|   if (request == null || typeof request !== "object") return -1;
  #|   const value = Number(request.frames);
  #|   if (!Number.isFinite(value) || value < 0) return 1;
  #|   return Math.floor(value);
  #| }

///|
extern "js" fn js_headless_int(key : String, fallback : Int) -> Int =
  #| (key, fallback) => {
  #|   const request = globalThis.__kaguraHeadless;
  #|   if (request == null) return fallback;
  #|   const value = Number(request[key]);
  #|   if (!Number.isFinite(value) || value <= 0) return fallback;
  #|   return Math.floor(value);
  #| }

///|
extern "js" fn js_headless_double(key : String, fallback : Double) -> Double =
  #| (key, fallback) => {
  #|   const request = globalThis.__kaguraHeadless;
  #|   if (request == null) return fallback;
  #|   const value = Number(request[key]);
  #|   return Number.isFinite(value) ? value : fallback;
  #| }

///|
extern "js" fn js_headless_string(key : String) -> String =
  #| (key) => {
  #|   const request = globalThis.__kaguraHeadless;
  #|   if (request == null) return "";
  #|   const value = request[key];
  #|   return value == null ? "" : String(value);
  #| }

///|
/// Hand the encoded frame to the host. `png` arrives as the JS target's byte
/// representation; it is normalized to a `Uint8Array` here so the caller can
/// write it out without knowing anything about the MoonBit ABI.
extern "js" fn js_publish_headless_frame(
  width : Int,
  height : Int,
  frames : Int,
  png : Bytes,
  skipped_commands : Int,
  drawn_triangles : Int,
  draw_commands : Int,
) -> Unit =
  #| (width, height, frames, png, skipped_commands, drawn_triangles, draw_commands) => {
  #|   const bytes = png instanceof Uint8Array
  #|     ? png
  #|     : new Uint8Array(png.buffer ?? png, png.byteOffset ?? 0, png.byteLength ?? png.length);
  #|   globalThis.__kaguraHeadlessFrame = {
  #|     width, height, frames, skipped_commands, drawn_triangles, draw_commands,
  #|     png: bytes,
  #|   };
  #| }

///|
/// Tell the host what viewport the render actually resolved to.
///
/// The size is decided here, not by the caller: a request without an explicit
/// width takes the example's own. Examples read their CSS size back through
/// `document.querySelector("canvas").getBoundingClientRect()` to scale cursor
/// coordinates, so a host stub reporting a different size silently misplaces
/// every pointer -- publishing the resolved size is what keeps the two agreed.
extern "js" fn js_publish_headless_viewport(width : Int, height : Int) -> Unit =
  #| (width, height) => { globalThis.__kaguraHeadlessViewport = { width, height }; }

///|
extern "js" fn js_publish_headless_failure(reason : String) -> Unit =
  #| (reason) => { globalThis.__kaguraHeadlessError = reason; }

///|
/// The source images the runtime hooks mirrored out while the game was loading
/// its assets. See `publish_source_image_for_headless` in
/// `platform/web_runtime_hooks`: the pixels cross on a global because the
/// dependency order forbids a direct call.
extern "js" fn js_headless_texture_count() -> Int =
  #| () => (globalThis.__kaguraSourceImages?.length ?? 0)

///|
extern "js" fn js_headless_texture_field(index : Int, field : String) -> Int =
  #| (index, field) => {
  #|   const value = globalThis.__kaguraSourceImages?.[index]?.[field];
  #|   return Number.isFinite(value) ? Math.floor(value) : 0;
  #| }

///|
extern "js" fn js_headless_texture_pixels(index : Int) -> Bytes =
  #| (index) => {
  #|   const pixels = globalThis.__kaguraSourceImages?.[index]?.pixels;
  #|   return pixels instanceof Uint8Array ? pixels : new Uint8Array(0);
  #| }

///|
fn collect_headless_textures() -> Array[HeadlessTexture] {
  let textures : Array[HeadlessTexture] = []
  for index in 0..<js_headless_texture_count() {
    let width = js_headless_texture_field(index, "width")
    let height = js_headless_texture_field(index, "height")
    let bytes = js_headless_texture_pixels(index)
    if width <= 0 || height <= 0 || bytes.length() < width * height * 4 {
      continue
    }
    let pixels : Array[Int] = []
    for i in 0..<bytes.length() {
      pixels.push(bytes[i].to_int())
    }
    textures.push({
      id: js_headless_texture_field(index, "image_id"),
      width,
      height,
      pixels,
    })
  }
  textures
}

///|
/// Returns true when a headless render was requested and has been published,
/// meaning `run` must not start the interactive loop.
fn try_run_headless(
  update~ : (@core.InputSnapshot) -> Unit,
  draw~ : (EngineContext) -> Array[@gfx.DrawTrianglesCommand],
  on_frame? : () -> Unit,
  width~ : Int,
  height~ : Int,
) -> Bool {
  let frames = js_headless_frames()
  if frames < 0 {
    return false
  }
  let input : HeadlessInput = {
    cursor_x: js_headless_double("cursor_x", -1.0),
    cursor_y: js_headless_double("cursor_y", -1.0),
    pressed_keys: parse_headless_keys(js_headless_string("keys")),
  }
  let render_width = js_headless_int("width", width)
  let render_height = js_headless_int("height", height)
  js_publish_headless_viewport(render_width, render_height)
  let frame = render_headless_frame(
    update~,
    draw~,
    on_frame?,
    width=render_width,
    height=render_height,
    frames~,
    input~,
    input_at=tick => headless_sequence_input(tick, input),
    textures_at=collect_headless_textures,
  )
  match headless_frame_png(frame) {
    Some(png) =>
      js_publish_headless_frame(
        frame.width,
        frame.height,
        frame.frames,
        png,
        frame.skipped_commands,
        frame.drawn_triangles,
        frame.draw_commands,
      )
    None => js_publish_headless_failure("failed to encode the frame as PNG")
  }
  true
}

///|
extern "js" fn js_headless_input_step(tick : Int) -> String =
  #| tick => {
  #|   const inputs = globalThis.__kaguraHeadless?.inputs;
  #|   if (inputs === undefined) return '';
  #|   return JSON.stringify(inputs[tick] ?? {cursor_x:-1,cursor_y:-1,keys:[],mouse_buttons:[],gamepads:[]});
  #| }

///|
fn headless_sequence_input(
  tick : Int,
  fallback : HeadlessInput,
) -> @core.InputSnapshot {
  let json = js_headless_input_step(tick)
  if json == "" {
    return headless_input_snapshot(fallback)
  }
  let step : HeadlessInputStep = @json.from_json(@json.parse(json)) catch {
    error => abort("Invalid headless input step: " + error.to_string())
  }
  step.to_input()
}

///|
pub fn capture_viewport(width : Int, height : Int) -> (Int, Int) {
  (js_headless_int("width", width), js_headless_int("height", height))
}
