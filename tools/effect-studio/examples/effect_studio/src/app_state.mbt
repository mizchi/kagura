///|
struct EffectStudioState {
  doc : @effect.EffectDocument
  mut preview_time : Double
  mut playing : Bool
  mut frame_count : Int
  mut camera : @camera3d.OrbitCamera
  mut prev_cursor_x : Double
  mut prev_cursor_y : Double
  key_state : @inpututil.KeyInputState
  mouse_state : @inpututil.MouseButtonInputState
  particle_shader : @gfx.ShaderHandle
  lit_colored_shader : @gfx.ShaderHandle
  lighting : @light3d.LightingEnvironment
  floor_mesh : @mesh3d.Mesh3D
  pedestal_mesh : @mesh3d.Mesh3D
}

///|
fn EffectStudioState::new() -> EffectStudioState {
  let aspect = screen_w.to_double() / screen_h.to_double()
  {
    doc: @effect.default_effect_document(),
    preview_time: 0.0,
    playing: true,
    frame_count: 0,
    camera: @camera3d.OrbitCamera::new(
      @math3d.Vec3::new(0.0, 0.45, 0.0),
      5.4,
      0.2,
      0.45,
      @math.PI / 3.5,
      aspect,
      0.1,
      100.0,
    ),
    prev_cursor_x: 0.0,
    prev_cursor_y: 0.0,
    key_state: @inpututil.new_key_input_state(),
    mouse_state: @inpututil.new_mouse_input_state(),
    particle_shader: @gfx.new_shader_handle(
      8702,
      @draw3d.shader3d_particle_wgsl(),
    ),
    lit_colored_shader: @gfx.new_shader_handle(
      8703,
      @draw3d.shader3d_lit_colored_wgsl(),
    ),
    lighting: @light3d.LightingEnvironment::default(),
    floor_mesh: @mesh3d.Mesh3D::cube(1.0),
    pedestal_mesh: @mesh3d.Mesh3D::cube(1.0),
  }
}

///|
fn EffectStudioState::update(
  self : EffectStudioState,
  input : @core.InputSnapshot,
) -> Unit {
  let dt = 1.0 / 60.0
  self.frame_count += 1
  @inpututil.update_key_input_state(self.key_state, input)
  @inpututil.update_mouse_input_state(self.mouse_state, input)
  if @inpututil.is_key_just_pressed(self.key_state, key_space) {
    self.playing = !self.playing
  }
  if @inpututil.is_key_just_pressed(self.key_state, key_r) {
    self.preview_time = 0.0
  }
  let scrub_step = if @inpututil.is_key_pressed(self.key_state, key_shift) {
    0.24
  } else {
    0.08
  }
  if @inpututil.is_key_pressed(self.key_state, key_left) {
    self.preview_time = if self.preview_time > scrub_step {
      self.preview_time - scrub_step
    } else {
      0.0
    }
  } else if @inpututil.is_key_pressed(self.key_state, key_right) {
    self.preview_time += scrub_step
  } else if self.playing {
    self.preview_time += dt
  }
  if !self.doc.looping && self.preview_time > self.doc.duration {
    self.preview_time = self.doc.duration
    self.playing = false
  }
  let dx = input.cursor_x - self.prev_cursor_x
  let dy = input.cursor_y - self.prev_cursor_y
  self.prev_cursor_x = input.cursor_x
  self.prev_cursor_y = input.cursor_y
  if @inpututil.is_mouse_button_pressed(self.mouse_state, 0) {
    self.camera = self.camera.orbit(dx * -0.005, dy * -0.005)
  }
  if input.wheel_y != 0.0 {
    self.camera = self.camera.zoom(input.wheel_y * 0.08)
  }
}

///|
fn EffectStudioState::context_json(self : EffectStudioState) -> String {
  effect_studio_context_json(self.doc, self.preview_time, self.playing)
}

///|
fn EffectStudioState::context_summary(self : EffectStudioState) -> String {
  effect_studio_summary(self.doc, self.preview_time, self.playing)
}

///|
fn EffectStudioState::patch_bundle_json(self : EffectStudioState) -> String {
  effect_studio_patch_bundle_json(self.doc, self.preview_time, self.playing)
}

///|
fn EffectStudioState::patch_bundle_filename(self : EffectStudioState) -> String {
  effect_studio_patch_bundle_filename(self.doc)
}

///|
fn EffectStudioState::review_prompt_markdown(
  self : EffectStudioState,
) -> String {
  effect_studio_review_prompt_markdown(
    self.doc,
    self.preview_time,
    self.playing,
  )
}

///|
fn EffectStudioState::review_prompt_filename(
  self : EffectStudioState,
) -> String {
  effect_studio_review_prompt_filename(self.doc)
}

///|
fn EffectStudioState::bundle_download_requested(
  self : EffectStudioState,
) -> Bool {
  @inpututil.is_key_just_pressed(self.key_state, key_j)
}

///|
fn EffectStudioState::review_download_requested(
  self : EffectStudioState,
) -> Bool {
  @inpututil.is_key_just_pressed(self.key_state, key_l)
}
