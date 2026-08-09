///|
let native_tile_w : Int = 320

///|
let native_tile_h : Int = 240

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
        let v = @capture.binarize_luma(r, g, b)
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
/// Render the authoring scene once and write the capture artifacts (native).
///
/// The paths come from `kagura_native_capture_config.txt`; see
/// `tools/modeling3d/scripts/model-authoring-native-capture-utils.mjs`.
pub fn run_authoring_native(doc : @modeling3d.ModelDocument) -> Unit {
  let config = match @capture_native.read_capture_config() {
    Some(value) => value
    None => {
      println(
        "kagura:capture: no usable " +
        @capture.capture_config_filename +
        " in the working directory",
      )
      return
    }
  }
  let selection = @modeling3d.default_selection(doc)
  let objects = @modeling3d.build_render_objects(doc)
  let context_json = @modeling3d.editor_context_json(doc, selection)
  let summary = @modeling3d.editor_summary(doc, selection)
  let atlas_w = native_tile_w * 2
  let atlas_h = native_tile_h * 2
  @native_hooks.install("kagura:native-review")
  let surface = @gfx.create_offscreen_surface_token(
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
  let png = match @capture.encode_rgba8_png(atlas_w, atlas_h, atlas) {
    Some(bytes) => bytes
    None => {
      println("kagura:capture: could not encode the frame as PNG")
      @native_hooks.shutdown_context()
      return
    }
  }
  match
    @capture_native.write_capture_artifacts(config, png, context_json, summary) {
    Some(path) => println("kagura:capture: could not write " + path)
    None => ()
  }
  @native_hooks.shutdown_context()
}
