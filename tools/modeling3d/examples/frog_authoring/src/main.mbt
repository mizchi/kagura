///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

///|
let min_brush_radius : Double = 0.08

///|
let max_brush_radius : Double = 0.48

///|
let canvas_selector : String = "#app"

///|
let key_z : Int = 90

///|
let key_g : Int = 71

///|
let key_i : Int = 73

///|
let key_j : Int = 74

///|
let key_p : Int = 80

///|
let key_k : Int = 75

///|
let key_l : Int = 76

///|
let key_m : Int = 77

///|
let key_u : Int = 85

///|
let key_1 : Int = 49

///|
let key_2 : Int = 50

///|
let key_3 : Int = 51

///|
let key_4 : Int = 52

///|
fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn debug_text_codes(text : String, max_chars : Int) -> Array[Int] {
  let chars = text.to_upper().to_array()
  let limit = min_int(chars.length(), max_chars)
  let codes : Array[Int] = []
  for i in 0..<limit {
    let ch = chars[i]
    if ch.is_ascii_alphabetic() || ch.is_ascii_digit() {
      codes.push(ch.to_int())
    } else if ch == ' ' || ch == ':' || ch == '-' || ch == '+' || ch == '/' {
      codes.push(ch.to_int())
    } else {
      codes.push(45)
    }
  }
  if codes.is_empty() {
    [45]
  } else {
    codes
  }
}

///|
fn debug_text_width(chars : Array[Int], scale : Double) -> Double {
  let px_size = 3.0 * scale
  let char_w = 3.0 * px_size
  let gap = px_size
  chars.length().to_double() * char_w + (chars.length() - 1).to_double() * gap
}

///|
fn draw_debug_text_left(
  cmds : Array[@gfx.DrawTrianglesCommand],
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  chars : Array[Int],
  left_x : Double,
  top_y : Double,
  screen_w : Double,
  screen_h : Double,
  color : @gfx.Color,
  scale : Double,
) -> Unit {
  let center_x = left_x + debug_text_width(chars, scale) * 0.5
  let center_y = top_y + 7.5 * scale
  @debugutil.draw_dot_text(
    cmds, dst, shader, chars, center_x, center_y, screen_w, screen_h, color, scale,
  )
}

///|
fn selection_kind_char(selection : ModelSelection?) -> Int {
  match selection {
    Some(current) =>
      match current.kind {
        PrimitiveSelection => 80
        SculptLayerSelection => 76
      }
    None => 45
  }
}

///|
fn active_sculpt_layer_label_codes(
  doc : ModelDocument,
  active_layer_index : Int?,
  max_chars : Int,
) -> Array[Int] {
  match active_layer_index {
    Some(index) =>
      match doc.sculpt_layers.get(index) {
        Some(layer) => debug_text_codes(layer.id, max_chars)
        None => [45]
      }
    None => [45]
  }
}

///|
fn history_line_text(entry : StampHistoryEntry) -> String {
  let marker = if entry.enabled {
    match entry.mode {
      Add => "+"
      Subtract => "-"
    }
  } else {
    "X"
  }
  marker +
  " " +
  entry.stamp_id +
  " " +
  (entry.radius * 100.0).to_int().to_string()
}

///|
fn history_slot_just_pressed(key_state : @inpututil.KeyInputState) -> Int? {
  if @inpututil.is_key_just_pressed(key_state, key_1) {
    Some(0)
  } else if @inpututil.is_key_just_pressed(key_state, key_2) {
    Some(1)
  } else if @inpututil.is_key_just_pressed(key_state, key_3) {
    Some(2)
  } else if @inpututil.is_key_just_pressed(key_state, key_4) {
    Some(3)
  } else {
    None
  }
}

///|
fn camera_forward(camera : @camera3d.Camera3D) -> @math3d.Vec3 {
  camera.target.sub(camera.position).normalize()
}

///|
extern "js" fn js_publish_model_context(
  context_json : String,
  summary : String,
) -> Unit =
  #| (contextJson, summary) => {
  #|   let parsed = null;
  #|   try {
  #|     parsed = JSON.parse(contextJson);
  #|   } catch (_err) {}
  #|   globalThis.__kaguraModelingContext = {
  #|     json: contextJson,
  #|     summary,
  #|     parsed,
  #|   };
  #|   console.log("[kagura:modeling:summary]\\n" + summary);
  #| };

///|
extern "js" fn js_download_model_glb(filename : String, data : Bytes) -> Unit =
  #| (filename, data) => {
  #|   const bytes = data instanceof Uint8Array ? data : new Uint8Array(data);
  #|   let binary = "";
  #|   const chunkSize = 0x8000;
  #|   for (let i = 0; i < bytes.length; i += chunkSize) {
  #|     const chunk = bytes.subarray(i, Math.min(i + chunkSize, bytes.length));
  #|     binary += String.fromCharCode(...chunk);
  #|   }
  #|   globalThis.__kaguraModelingExport = {
  #|     filename,
  #|     byteLength: bytes.byteLength,
  #|     bytesBase64: btoa(binary),
  #|   };
  #|   if (globalThis.__kaguraAutomation?.disableDownloads === true) {
  #|     return;
  #|   }
  #|   const blob = new Blob([bytes], { type: "model/gltf-binary" });
  #|   const url = URL.createObjectURL(blob);
  #|   const anchor = document.createElement("a");
  #|   anchor.href = url;
  #|   anchor.download = filename;
  #|   anchor.style.display = "none";
  #|   document.body.appendChild(anchor);
  #|   anchor.click();
  #|   anchor.remove();
  #|   setTimeout(() => URL.revokeObjectURL(url), 0);
  #| };

///|
extern "js" fn js_download_text_file(filename : String, text : String) -> Unit =
  #| (filename, text) => {
  #|   const blob = new Blob([text], { type: "text/plain;charset=utf-8" });
  #|   const url = URL.createObjectURL(blob);
  #|   const anchor = document.createElement("a");
  #|   anchor.href = url;
  #|   anchor.download = filename;
  #|   anchor.style.display = "none";
  #|   document.body.appendChild(anchor);
  #|   anchor.click();
  #|   anchor.remove();
  #|   setTimeout(() => URL.revokeObjectURL(url), 0);
  #| };

///|
extern "js" fn js_publish_model_roundtrip(
  context_json : String,
  summary : String,
) -> Unit =
  #| (contextJson, summary) => {
  #|   let parsed = null;
  #|   try {
  #|     parsed = JSON.parse(contextJson);
  #|   } catch (_err) {}
  #|   globalThis.__kaguraModelingRoundTrip = {
  #|     json: contextJson,
  #|     summary,
  #|     parsed,
  #|   };
  #|   console.log("[kagura:modeling:roundtrip]\\n" + summary);
  #| };

///|
extern "js" fn js_publish_model_patch(
  context_json : String,
  summary : String,
) -> Unit =
  #| (contextJson, summary) => {
  #|   let parsed = null;
  #|   try {
  #|     parsed = JSON.parse(contextJson);
  #|   } catch (_err) {}
  #|   globalThis.__kaguraModelingPatch = {
  #|     json: contextJson,
  #|     summary,
  #|     parsed,
  #|   };
  #|   console.log("[kagura:modeling:patch]\\n" + summary);
  #| };

///|
extern "js" fn js_publish_model_review_assets(
  bundle_filename : String,
  bundle_text : String,
  review_filename : String,
  review_text : String,
) -> Unit =
  #| (bundleFilename, bundleText, reviewFilename, reviewText) => {
  #|   globalThis.__kaguraModelingReviewAssets = {
  #|     bundle: {
  #|       filename: bundleFilename,
  #|       text: bundleText,
  #|     },
  #|     prompt: {
  #|       filename: reviewFilename,
  #|       text: reviewText,
  #|     },
  #|   };
  #| };

///|
extern "js" fn js_clear_model_review_assets() -> Unit =
  #| () => {
  #|   globalThis.__kaguraModelingReviewAssets = null;
  #| };

///|
extern "js" fn js_pick_model_glb(cb : (String, Bytes) -> Unit) -> Unit =
  #| (cb) => {
  #|   const input = document.createElement("input");
  #|   input.type = "file";
  #|   input.accept = ".glb,model/gltf-binary";
  #|   input.style.display = "none";
  #|   input.addEventListener("change", async () => {
  #|     const file = input.files && input.files[0];
  #|     if (!file) {
  #|       input.remove();
  #|       return;
  #|     }
  #|     const buf = await file.arrayBuffer();
  #|     cb(file.name, new Uint8Array(buf));
  #|     input.remove();
  #|   }, { once: true });
  #|   document.body.appendChild(input);
  #|   input.click();
  #| };

///|
extern "js" fn js_register_model_glb_importer(
  cb : (String, Bytes) -> Unit,
) -> Unit =
  #| (cb) => {
  #|   globalThis.__kaguraModelingImport = {
  #|     load(filename, bytesBase64) {
  #|       const binary = atob(String(bytesBase64));
  #|       const bytes = new Uint8Array(binary.length);
  #|       for (let i = 0; i < binary.length; i += 1) {
  #|         bytes[i] = binary.charCodeAt(i);
  #|       }
  #|       cb(String(filename), bytes);
  #|     },
  #|   };
  #| };

///|
extern "js" fn js_register_model_camera_controller(
  begin_capture : () -> Unit,
  set_preset : (String) -> Unit,
  end_capture : () -> Unit,
) -> Unit =
  #| (beginCapture, setPreset, endCapture) => {
  #|   globalThis.__kaguraModelingCamera = {
  #|     beginCapture() {
  #|       beginCapture();
  #|     },
  #|     setPreset(label) {
  #|       setPreset(String(label));
  #|     },
  #|     endCapture() {
  #|       endCapture();
  #|     },
  #|   };
  #| };

///|
extern "js" fn js_canvas_css_width(selector : String) -> Double =
  #| (selector) => {
  #|   const el = document.querySelector(selector);
  #|   if (el == null || typeof el.getBoundingClientRect !== "function") return 0;
  #|   return Number(el.getBoundingClientRect().width ?? 0) || 0;
  #| };

///|
extern "js" fn js_canvas_css_height(selector : String) -> Double =
  #| (selector) => {
  #|   const el = document.querySelector(selector);
  #|   if (el == null || typeof el.getBoundingClientRect !== "function") return 0;
  #|   return Number(el.getBoundingClientRect().height ?? 0) || 0;
  #| };

///|
fn main {
  @web_hooks.install(canvas_selector)
  let input = @inpututil.new_input_helper()
  let default_orbit_camera = fn() {
    @camera3d.OrbitCamera::new(
      @math3d.Vec3::new(0.0, 0.35, 0.0),
      3.8,
      0.45,
      0.3,
      @math.PI / 4.0,
      screen_w.to_double() / screen_h.to_double(),
      0.01,
      20.0,
    )
  }
  let camera_for_capture_preset = fn(label : String) {
    match label {
      "front" => default_orbit_camera().orbit(-0.45, 0.0)
      "side" => default_orbit_camera().orbit(1.1, 0.0)
      "top" => default_orbit_camera().orbit(-0.45, 0.8)
      _ => default_orbit_camera()
    }
  }
  let mut doc = default_model_document()
  let mut selection = default_selection(doc)
  let mut objects = build_render_objects(doc)
  let mut selection_overlay_objects = build_selection_overlay_objects(
    doc, selection,
  )
  let mut stats = document_stats(doc)
  let mut active_layer_index = resolve_active_sculpt_layer_index(
    doc,
    selection,
    None,
  )
  let mut recent_history = match active_layer_index {
    Some(index) => recent_sculpt_history(doc, index, 4)
    None => []
  }
  let mut summary = editor_summary(doc, selection)
  let mut context_json = editor_context_json(doc, selection)
  let mut camera = default_orbit_camera()
  let mut saved_capture_camera : @camera3d.OrbitCamera? = None
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.4, 1.0, 0.7),
      @math3d.Vec3::new(1.0, 1.0, 1.0),
      0.9,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::new(1.0, 1.0, 1.0), 0.35),
  )
  let shader3d = @gfx.new_shader_handle(
    130,
    @draw3d.shader3d_lit_untextured_wgsl(),
  )
  let preview_mesh = @mesh3d.Mesh3D::sphere(0.5, 12, 8)
  let prev_x : Ref[Double] = Ref::new(0.0)
  let prev_y : Ref[Double] = Ref::new(0.0)
  let mut brush_mode = Add
  let mut brush_radius = 0.18
  let mut symmetry_x = false
  let mut hover_hit : SurfaceHit? = None
  let mut gizmo_hover : GizmoHandleHit? = None
  let mut gizmo_drag : GizmoDragState? = None
  let roundtrip_badge : Ref[String] = Ref::new("RT NONE")
  let mut pending_roundtrip_import : RoundTripImport? = None
  let mut pending_patch_plan : RoundTripPatchPlan? = None
  let mut pending_patch_snippet : String? = None
  let mut pending_patch_filename : String? = None
  let mut pending_review_prompt : String? = None
  let mut pending_review_filename : String? = None
  let mut pending_review_bundle : String? = None
  let mut pending_review_bundle_filename : String? = None
  let mut scene_only_capture = false
  let sync_roundtrip_artifacts = fn(
    current_doc : ModelDocument,
    imported : RoundTripImport,
    log_summary : Bool,
  ) {
    let artifacts = build_roundtrip_patch_artifacts(current_doc, imported)
    pending_roundtrip_import = Some(imported)
    pending_patch_plan = Some(artifacts.patch_plan)
    pending_patch_snippet = Some(artifacts.patch_snippet)
    pending_patch_filename = Some(artifacts.patch_filename)
    pending_review_prompt = Some(artifacts.review_prompt)
    pending_review_filename = Some(artifacts.review_filename)
    pending_review_bundle = Some(artifacts.review_bundle)
    pending_review_bundle_filename = Some(artifacts.review_bundle_filename)
    roundtrip_badge.val = "RT " + roundtrip_badge_text(artifacts.report)
    js_publish_model_roundtrip(artifacts.report_json, artifacts.report_summary)
    js_publish_model_patch(artifacts.patch_json, artifacts.patch_summary)
    js_publish_model_review_assets(
      artifacts.review_bundle_filename,
      artifacts.review_bundle,
      artifacts.review_filename,
      artifacts.review_prompt,
    )
    if log_summary {
      println(artifacts.report_summary)
      println(artifacts.patch_summary)
    }
  }
  let sync_document = fn(log_summary : Bool) {
    objects = build_render_objects(doc)
    selection_overlay_objects = build_selection_overlay_objects(doc, selection)
    active_layer_index = resolve_active_sculpt_layer_index(doc, selection, None)
    recent_history = match active_layer_index {
      Some(index) => recent_sculpt_history(doc, index, 4)
      None => []
    }
    stats = document_stats(doc)
    summary = editor_summary(doc, selection)
    context_json = editor_context_json(doc, selection)
    if log_summary {
      println(summary)
    }
    js_publish_model_context(context_json, summary)
  }
  let handle_roundtrip_import = fn(filename : String, data : Bytes) {
    let result = try {
      let imported = parse_roundtrip_import(filename, data)
      sync_roundtrip_artifacts(doc, imported, true)
    } catch {
      _ => {
        let message = "ROUNDTRIP " + filename + "\nparse error\n"
        pending_roundtrip_import = None
        pending_patch_plan = None
        pending_patch_snippet = None
        pending_patch_filename = None
        pending_review_prompt = None
        pending_review_filename = None
        pending_review_bundle = None
        pending_review_bundle_filename = None
        roundtrip_badge.val = "RT ERR"
        js_clear_model_review_assets()
        js_publish_model_roundtrip(
          roundtrip_error_json(filename, "parse error"),
          message,
        )
        js_publish_model_patch(
          roundtrip_error_json(filename, "parse error"),
          "PATCH " + filename + "\nparse error\n",
        )
        println(message)
      }
    }
    result
  }
  sync_document(true)
  js_register_model_glb_importer(handle_roundtrip_import)
  js_register_model_camera_controller(
    fn() {
      saved_capture_camera = Some(camera)
      camera = default_orbit_camera()
      scene_only_capture = true
    },
    fn(label) { camera = camera_for_capture_preset(label) },
    fn() {
      match saved_capture_camera {
        Some(saved) => camera = saved
        None => ()
      }
      saved_capture_camera = None
      scene_only_capture = false
    },
  )
  @engine.run(
    update=fn(snapshot) {
      @inpututil.update_input_helper(input, snapshot)
      let cx = snapshot.cursor_x
      let cy = snapshot.cursor_y
      let dx = cx - prev_x.val
      let dy = cy - prev_y.val
      prev_x.val = cx
      prev_y.val = cy
      let mut lmb = false
      for b in snapshot.pressed_mouse_buttons {
        if b == 0 {
          lmb = true
          break
        }
      }
      if @inpututil.is_key_pressed(input.key_state, @inpututil.key_a) {
        brush_mode = Add
      }
      if @inpututil.is_key_pressed(input.key_state, @inpututil.key_s) {
        brush_mode = Subtract
      }
      if @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_e) {
        brush_radius = clamp_double(
          brush_radius + 0.03,
          min_brush_radius,
          max_brush_radius,
        )
      }
      if @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_d) {
        brush_radius = clamp_double(
          brush_radius - 0.03,
          min_brush_radius,
          max_brush_radius,
        )
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_m) {
        symmetry_x = !symmetry_x
      }
      if @inpututil.is_key_just_pressed(input.key_state, @inpututil.key_o) {
        doc = default_model_document()
        selection = default_selection(doc)
        hover_hit = None
        gizmo_hover = None
        gizmo_drag = None
        pending_roundtrip_import = None
        pending_patch_plan = None
        pending_patch_snippet = None
        pending_patch_filename = None
        pending_review_prompt = None
        pending_review_filename = None
        pending_review_bundle = None
        pending_review_bundle_filename = None
        roundtrip_badge.val = "RT NONE"
        js_clear_model_review_assets()
        sync_document(true)
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_g) {
        let filename = document_export_filename(doc)
        let glb = document_glb_bytes(doc)
        js_download_model_glb(filename, glb)
        println(
          "exported " + filename + " (" + glb.length().to_string() + " bytes)",
        )
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_i) {
        js_pick_model_glb(handle_roundtrip_import)
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_k) {
        match (pending_patch_filename, pending_patch_snippet) {
          (Some(patch_filename), Some(patch_text)) =>
            js_download_text_file(patch_filename, patch_text)
          _ => ()
        }
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_j) {
        match (pending_review_bundle_filename, pending_review_bundle) {
          (Some(bundle_filename), Some(bundle_text)) =>
            js_download_text_file(bundle_filename, bundle_text)
          _ => ()
        }
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_l) {
        match (pending_review_filename, pending_review_prompt) {
          (Some(review_filename), Some(review_text)) =>
            js_download_text_file(review_filename, review_text)
          _ => ()
        }
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_p) {
        match (pending_roundtrip_import, pending_patch_plan) {
          (Some(imported), Some(plan)) => {
            doc = apply_roundtrip_auto_patch(doc, plan)
            sync_document(true)
            sync_roundtrip_artifacts(doc, imported, true)
          }
          _ => ()
        }
      }
      if @inpututil.is_key_just_pressed(input.key_state, key_u) {
        match (pending_roundtrip_import, pending_patch_plan) {
          (Some(imported), Some(plan)) => {
            doc = apply_roundtrip_opt_in_patch(doc, imported, plan)
            sync_document(true)
            sync_roundtrip_artifacts(doc, imported, true)
          }
          _ => ()
        }
      }
      let history_slot = history_slot_just_pressed(input.key_state)
      match active_layer_index {
        Some(layer_index) =>
          if @inpututil.is_key_just_pressed(input.key_state, key_z) {
            doc = undo_last_sculpt_stamp(doc, layer_index)
            match doc.sculpt_layers.get(layer_index) {
              Some(layer) =>
                selection = Some({
                  kind: SculptLayerSelection,
                  target_id: layer.id,
                })
              None => ()
            }
            sync_document(true)
          } else {
            match history_slot {
              Some(slot) => {
                doc = toggle_recent_sculpt_stamp_muted(doc, layer_index, slot)
                match doc.sculpt_layers.get(layer_index) {
                  Some(layer) =>
                    selection = Some({
                      kind: SculptLayerSelection,
                      target_id: layer.id,
                    })
                  None => ()
                }
                sync_document(true)
              }
              None => ()
            }
          }
        None => ()
      }

      let ray = camera_ray_from_cursor(
        camera.to_camera3d(),
        {
          let css_w = js_canvas_css_width(canvas_selector).to_int()
          if css_w > 0 {
            css_w
          } else {
            screen_w
          }
        },
        {
          let css_h = js_canvas_css_height(canvas_selector).to_int()
          if css_h > 0 {
            css_h
          } else {
            screen_h
          }
        },
        snapshot.cursor_x,
        snapshot.cursor_y,
      )
      hover_hit = pick_document_surface_hit(doc, ray)
      gizmo_hover = match gizmo_drag {
        Some(current_drag) =>
          Some({
            target_id: current_drag.target_id,
            axis: current_drag.axis,
            distance: 0.0,
            point: @math3d.Vec3::zero(),
          })
        None => pick_selected_primitive_gizmo_handle(doc, selection, ray)
      }
      if @inpututil.is_mouse_button_just_pressed(input.mouse_state, 0) {
        let editing = @inpututil.is_key_pressed(
            input.key_state,
            @inpututil.key_a,
          ) ||
          @inpututil.is_key_pressed(input.key_state, @inpututil.key_s)
        if editing {
          match hover_hit {
            Some(hit) =>
              match
                resolve_active_sculpt_layer_index(doc, selection, Some(hit)) {
                Some(layer_index) => {
                  doc = append_sculpt_stamp_with_symmetry(
                    doc,
                    layer_index,
                    brush_mode,
                    hit.point,
                    brush_radius,
                    symmetry_x,
                  )
                  match doc.sculpt_layers.get(layer_index) {
                    Some(layer) =>
                      selection = Some({
                        kind: SculptLayerSelection,
                        target_id: layer.id,
                      })
                    None => ()
                  }
                  sync_document(true)
                }
                None => ()
              }
            None => ()
          }
        } else {
          match gizmo_hover {
            Some(handle_hit) =>
              match
                begin_gizmo_drag(
                  doc,
                  handle_hit,
                  camera_forward(camera.to_camera3d()),
                ) {
                Some(next_drag) => gizmo_drag = Some(next_drag)
                None => ()
              }
            None =>
              match selection_from_surface_hit(hover_hit) {
                Some(next_selection) => {
                  selection = Some(next_selection)
                  sync_document(true)
                }
                None => ()
              }
          }
        }
      }
      if !@inpututil.is_mouse_button_pressed(input.mouse_state, 0) {
        match gizmo_drag {
          Some(_) => {
            gizmo_drag = None
            sync_document(true)
          }
          None => ()
        }
      }
      let mut dragging_gizmo = false
      match gizmo_drag {
        Some(current_drag) => {
          dragging_gizmo = true
          doc = apply_gizmo_drag(doc, current_drag, ray)
          sync_document(false)
        }
        None => ()
      }

      let editing = @inpututil.is_key_pressed(input.key_state, @inpututil.key_a) ||
        @inpututil.is_key_pressed(input.key_state, @inpututil.key_s)
      if lmb && !editing && !dragging_gizmo {
        camera = camera.orbit(dx * -0.005, dy * -0.005)
      }
      if snapshot.wheel_y != 0.0 {
        camera = camera.zoom(snapshot.wheel_y * 0.03)
      }
    },
    draw=fn(ctx) {
      let draw_objects = objects.copy()
      if !scene_only_capture {
        for overlay in selection_overlay_objects {
          draw_objects.push(overlay)
        }
        for
          gizmo in build_gizmo_handle_objects(
            doc, selection, gizmo_hover, gizmo_drag,
          ) {
          draw_objects.push(gizmo)
        }
        match hover_hit {
          Some(hit) =>
            draw_objects.push(
              @scene3d.object3d(
                mesh=preview_mesh,
                position=hit.point,
                scale=@math3d.Vec3::new(
                  brush_radius * 2.0,
                  brush_radius * 2.0,
                  brush_radius * 2.0,
                ),
                color=match brush_mode {
                  Add => hex_to_vec4(0x4BFF91)
                  Subtract => hex_to_vec4(0xFF6B6B)
                },
              ),
            )
          None => ()
        }
      }
      let scene = @scene3d.scene3d(
        objects=draw_objects,
        camera=camera.to_camera3d(),
        lighting~,
      )
      let cmds = @scene3d.render_scene3d_gpu(
        scene,
        ctx.dst,
        shader3d,
        ctx.screen_w,
        ctx.screen_h,
      )
      if scene_only_capture {
        return cmds
      }
      let mode_char = match brush_mode {
        Add => 65
        Subtract => 83
      }
      let hover_kind_char = match hover_hit {
        Some(hit) =>
          match hit.kind {
            PrimitiveSurface => 80
            SculptSurface => 83
            BakedSculptSurface => 66
          }
        None => 45
      }
      let hover_label = match hover_hit {
        Some(hit) => debug_text_codes(hit.target_id, 6)
        None => [45]
      }
      let selection_label = match selection {
        Some(current) => debug_text_codes(current.target_id, 10)
        None => [45]
      }
      let layer_label = active_sculpt_layer_label_codes(
        doc, active_layer_index, 10,
      )
      let symmetry_label = if symmetry_x {
        debug_text_codes("X ON", 4)
      } else {
        debug_text_codes("X OFF", 5)
      }
      let white = @debugutil.color_from_hex(0xFFFFFF)
      let panel_bg = @debugutil.color_from_hex_alpha(0x101826, 0.78)
      let panel_x = ctx.screen_w.to_double() - 196.0
      let panel_y = 8.0
      cmds.push(
        @debugutil.new_rect_fill_command(
          ctx.dst,
          ctx.shader,
          panel_x,
          panel_y,
          188.0,
          174.0,
          panel_bg,
          0,
        ),
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [77],
        4.0,
        4.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_number(
        cmds,
        ctx.dst,
        ctx.shader,
        stats.render_object_count,
        12.0,
        4.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [86],
        4.0,
        12.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_number(
        cmds,
        ctx.dst,
        ctx.shader,
        stats.occupied_voxel_count,
        12.0,
        12.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [mode_char],
        4.0,
        20.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_number(
        cmds,
        ctx.dst,
        ctx.shader,
        (brush_radius * 100.0).to_int(),
        12.0,
        20.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [72],
        4.0,
        28.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [hover_kind_char],
        12.0,
        28.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        hover_label,
        20.0,
        28.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [83],
        4.0,
        36.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [selection_kind_char(selection)],
        12.0,
        36.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        selection_label,
        34.0,
        36.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        [76],
        4.0,
        44.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      @debugutil.draw_dot_text(
        cmds,
        ctx.dst,
        ctx.shader,
        layer_label,
        26.0,
        44.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        debug_text_codes("SEL", 3),
        panel_x + 10.0,
        panel_y + 10.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        selection_label,
        panel_x + 10.0,
        panel_y + 24.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        debug_text_codes("ACT", 3),
        panel_x + 10.0,
        panel_y + 42.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        layer_label,
        panel_x + 10.0,
        panel_y + 56.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        debug_text_codes("SYM", 3),
        panel_x + 10.0,
        panel_y + 74.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        symmetry_label,
        panel_x + 10.0,
        panel_y + 88.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        debug_text_codes("HIS", 3),
        panel_x + 10.0,
        panel_y + 106.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      for i in 0..<recent_history.length() {
        draw_debug_text_left(
          cmds,
          ctx.dst,
          ctx.shader,
          debug_text_codes(
            (i + 1).to_string() + " " + history_line_text(recent_history[i]),
            14,
          ),
          panel_x + 10.0,
          panel_y + 120.0 + i.to_double() * 12.0,
          ctx.screen_w.to_double(),
          ctx.screen_h.to_double(),
          white,
          0.8,
        )
      }
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        debug_text_codes("RT", 2),
        panel_x + 10.0,
        panel_y + 154.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        1.0,
      )
      draw_debug_text_left(
        cmds,
        ctx.dst,
        ctx.shader,
        debug_text_codes(roundtrip_badge.val, 14),
        panel_x + 10.0,
        panel_y + 168.0,
        ctx.screen_w.to_double(),
        ctx.screen_h.to_double(),
        white,
        0.8,
      )
      cmds
    },
    width=screen_w,
    height=screen_h,
    title="Model Authoring POC",
    canvas=canvas_selector,
  )
}
