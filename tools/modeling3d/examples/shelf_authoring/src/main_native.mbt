///|
let native_capture_config_filename : String = "kagura_native_capture_config.txt"

///|
let native_tile_w : Int = 320

///|
let native_tile_h : Int = 240

///|
struct NativeCaptureConfig {
  screenshot_path : String
  context_path : String
  summary_path : String
  binarize : Bool
}

///|
fn bytes_to_string(data : Bytes) -> String {
  let chars : Array[Char] = []
  for i in 0..<data.length() {
    chars.push(data[i].to_int().unsafe_to_char())
  }
  String::from_array(chars)
}

///|
fn parse_config_map(text : String) -> Map[String, String] {
  let entries : Map[String, String] = {}
  let mut line = StringBuilder::new()
  let commit = fn() {
    let trimmed = line.to_string().trim().to_string()
    line = StringBuilder::new()
    if trimmed.is_empty() {
      return
    }
    let chars = trimmed.to_array()
    let mut split_index = -1
    for i in 0..<chars.length() {
      if chars[i] == '=' {
        split_index = i
        break
      }
    }
    if split_index <= 0 {
      return
    }
    let key_chars : Array[Char] = []
    let value_chars : Array[Char] = []
    for i in 0..<split_index {
      key_chars.push(chars[i])
    }
    for i in (split_index + 1)..<chars.length() {
      value_chars.push(chars[i])
    }
    let key = String::from_array(key_chars).trim().to_string()
    let value = String::from_array(value_chars).trim().to_string()
    if !key.is_empty() {
      entries[key] = value
    }
  }
  for ch in text {
    if ch == '\n' || ch == '\r' {
      commit()
    } else {
      line.write_char(ch)
    }
  }
  commit()
  entries
}

///|
fn config_required(entries : Map[String, String], key : String) -> String {
  match entries.get(key) {
    Some(value) => value
    None => panic()
  }
}

///|
fn config_bool(entries : Map[String, String], key : String) -> Bool {
  match entries.get(key) {
    Some("1") => true
    Some("true") => true
    Some("TRUE") => true
    _ => false
  }
}

///|
fn load_capture_config() -> NativeCaptureConfig {
  let bytes = match
    @wgpu_native.read_file_bytes(native_capture_config_filename) {
    Some(data) => data
    None => panic()
  }
  let entries = parse_config_map(bytes_to_string(bytes))
  {
    screenshot_path: config_required(entries, "screenshot_path"),
    context_path: config_required(entries, "context_path"),
    summary_path: config_required(entries, "summary_path"),
    binarize: config_bool(entries, "binarize"),
  }
}

///|
fn native_default_orbit_camera() -> @camera3d.OrbitCamera {
  @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(0.0, 0.35, 0.0),
    3.8,
    0.45,
    0.3,
    @math.PI / 4.0,
    native_tile_w.to_double() / native_tile_h.to_double(),
    0.01,
    20.0,
  )
}

///|
fn native_camera_for_capture_preset(label : String) -> @camera3d.OrbitCamera {
  match label {
    "front" => native_default_orbit_camera().orbit(-0.45, 0.0)
    "side" => native_default_orbit_camera().orbit(1.1, 0.0)
    "top" => native_default_orbit_camera().orbit(-0.45, 0.8)
    _ => native_default_orbit_camera()
  }
}

///|
fn native_capture_lighting() -> @light3d.LightingEnvironment {
  @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.4, 1.0, 0.7),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      0.9,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.35),
  )
}

///|
fn[T : @gfx.GraphicsDriver] render_view_pixels(
  graphics : T,
  objects : Array[@scene3d.Object3D],
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  lighting : @light3d.LightingEnvironment,
  camera : @camera3d.OrbitCamera,
) -> Array[Int] {
  let mut last_pixels : Array[Int]? = None
  for _ in 0..<2 {
    let scene = @scene3d.scene3d(
      objects~,
      camera=camera.to_camera3d(),
      lighting~,
    )
    let cmds = @renderer3d.render_scene3d_to_dst(
      scene, dst, shader3d, native_tile_w, native_tile_h,
    )
    @engine.render_commands(
      graphics,
      cmds,
      clear_color=@gfx.new_color(0.0, 0.0, 0.0, 1.0),
      clear_enabled=true,
    ) catch {
      _ => panic()
    }
    let current_pixels = @wgpu_native.runtime_read_offscreen_pixels(
      dst.id,
      0,
      0,
      native_tile_w,
      native_tile_h,
    )
    match current_pixels {
      Some(pixels) =>
        if pixels.length() == native_tile_w * native_tile_h * 4 {
          return pixels
        } else {
          last_pixels = Some(pixels)
        }
      None => ()
    }
  }
  match last_pixels {
    Some(pixels) => pixels
    None => panic()
  }
}

///|
fn binarize_channel(r : Int, g : Int, b : Int) -> Int {
  if r * 30 + g * 59 + b * 11 >= 12800 {
    255
  } else {
    0
  }
}

///|
fn copy_view_into_atlas(
  atlas : Array[Int],
  atlas_w : Int,
  atlas_h : Int,
  tile_pixels : Array[Int],
  tile_x : Int,
  tile_y : Int,
  binarize : Bool,
) -> Unit {
  let _ = atlas_h
  for y in 0..<native_tile_h {
    for x in 0..<native_tile_w {
      let src = (y * native_tile_w + x) * 4
      let dst = ((tile_y + y) * atlas_w + (tile_x + x)) * 4
      let r = tile_pixels[src]
      let g = tile_pixels[src + 1]
      let b = tile_pixels[src + 2]
      let a = tile_pixels[src + 3]
      if binarize {
        let v = binarize_channel(r, g, b)
        atlas[dst] = v
        atlas[dst + 1] = v
        atlas[dst + 2] = v
      } else {
        atlas[dst] = r
        atlas[dst + 1] = g
        atlas[dst + 2] = b
      }
      atlas[dst + 3] = a
    }
  }
}

///|
fn encode_atlas_png(atlas_w : Int, atlas_h : Int, pixels : Array[Int]) -> Bytes {
  @asset.encode_png_image_spec(
    @asset.image_spec_with_rgba8(atlas_w, atlas_h, pixels),
  ) catch {
    _ => panic()
  }
}

///|
fn main {
  let config = load_capture_config()
  let doc = default_model_document()
  let selection = default_selection(doc)
  let objects = build_render_objects(doc)
  let context_json = editor_context_json(doc, selection)
  let summary = editor_summary(doc, selection)
  let atlas_w = native_tile_w * 2
  let atlas_h = native_tile_h * 2
  @native_hooks.install("kagura:native-review")
  let surface = @platform.create_offscreen_surface_token(
    native_tile_w, native_tile_h,
  )
  let graphics = @gfx.create_wgpu_native_graphics(
    surface,
    @gfx.default_graphics_backend_options(),
  )
  graphics.initialize() catch {
    _ => panic()
  }
  let dst = graphics.new_image(native_tile_w, native_tile_h) catch {
    _ => panic()
  }
  let shader3d = graphics.new_shader(@draw3d.shader3d_lit_untextured_wgsl()) catch {
    _ => panic()
  }
  let lighting = native_capture_lighting()
  let atlas : Array[Int] = Array::make(atlas_w * atlas_h * 4, 0)
  let tiles = [
    ("angled", 0, 0),
    ("front", native_tile_w, 0),
    ("side", 0, native_tile_h),
    ("top", native_tile_w, native_tile_h),
  ]
  for tile in tiles {
    let (label, tile_x, tile_y) = tile
    let pixels = render_view_pixels(
      graphics,
      objects,
      dst,
      shader3d,
      lighting,
      native_camera_for_capture_preset(label),
    )
    copy_view_into_atlas(
      atlas,
      atlas_w,
      atlas_h,
      pixels,
      tile_x,
      tile_y,
      config.binarize,
    )
  }
  let png = encode_atlas_png(atlas_w, atlas_h, atlas)
  if !@wgpu_native.write_file_bytes(config.screenshot_path, png) {
    panic()
  }
  if !@wgpu_native.write_file_text(config.context_path, context_json) {
    panic()
  }
  if !@wgpu_native.write_file_text(config.summary_path, summary) {
    panic()
  }
  @native_hooks.shutdown_context()
}
