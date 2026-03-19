///|
pub(all) struct SSAOConfig {
  enabled : Bool
  radius : Double
  bias : Double
  intensity : Double
}

///|
pub fn SSAOConfig::enabled_default() -> SSAOConfig {
  { enabled: true, radius: 0.5, bias: 0.025, intensity: 1.0 }
}

///|
pub fn SSAOConfig::disabled_default() -> SSAOConfig {
  { ..SSAOConfig::enabled_default(), enabled: false }
}

///|
pub(all) struct PostFXConfig {
  fxaa_enabled : Bool
  ssao_config : SSAOConfig
  bloom_threshold : Double
  bloom_intensity : Double
}

///|
pub fn PostFXConfig::default() -> PostFXConfig {
  {
    fxaa_enabled: false,
    ssao_config: SSAOConfig::disabled_default(),
    bloom_threshold: 0.8,
    bloom_intensity: 0.3,
  }
}

///|
fn half_res(size : Int) -> Int {
  Int::max(1, size / 2)
}

///|
pub struct RenderPipeline3D {
  // Render targets
  scene_target : @gfx.ImageHandle
  bloom_a : @gfx.ImageHandle
  bloom_b : @gfx.ImageHandle
  post_target : @gfx.ImageHandle
  camera_depth_target : @gfx.ImageHandle
  ssao_target : @gfx.ImageHandle
  // Shaders
  bloom_threshold_sh : @gfx.ShaderHandle
  bloom_hblur_sh : @gfx.ShaderHandle
  bloom_vblur_sh : @gfx.ShaderHandle
  bloom_composite_sh : @gfx.ShaderHandle
  tonemap_sh : @gfx.ShaderHandle
  fxaa_sh : @gfx.ShaderHandle
  ssao_sh : @gfx.ShaderHandle
  camera_depth_shader : @gfx.ShaderHandle
  // Config
  mut config : PostFXConfig
}

///|
pub fn RenderPipeline3D::new(
  base_id : Int,
  screen_w : Int,
  screen_h : Int,
  config : PostFXConfig,
) -> RenderPipeline3D {
  let bloom_w = half_res(screen_w)
  let bloom_h = half_res(screen_h)
  {
    // Render targets: base_id + 0..5
    scene_target: @gfx.new_image_handle(base_id, screen_w, screen_h),
    bloom_a: @gfx.new_image_handle(base_id + 1, bloom_w, bloom_h),
    bloom_b: @gfx.new_image_handle(base_id + 2, bloom_w, bloom_h),
    post_target: @gfx.new_image_handle(base_id + 3, screen_w, screen_h),
    ssao_target: @gfx.new_image_handle(base_id + 4, screen_w, screen_h),
    camera_depth_target: @gfx.new_image_handle(base_id + 5, screen_w, screen_h),
    // Shaders: base_id + 0..7
    bloom_threshold_sh: @gfx.new_shader_handle(
      base_id,
      @postfx.bloom_threshold_wgsl(),
    ),
    bloom_hblur_sh: @gfx.new_shader_handle(
      base_id + 1,
      @postfx.bloom_blur_wgsl(true),
    ),
    bloom_vblur_sh: @gfx.new_shader_handle(
      base_id + 2,
      @postfx.bloom_blur_wgsl(false),
    ),
    bloom_composite_sh: @gfx.new_shader_handle(
      base_id + 3,
      @postfx.bloom_composite_wgsl(),
    ),
    fxaa_sh: @gfx.new_shader_handle(base_id + 4, @postfx.fxaa_wgsl()),
    tonemap_sh: @gfx.new_shader_handle(
      base_id + 5,
      @postfx.tonemap_wgsl(@postfx.ACES),
    ),
    ssao_sh: @gfx.new_shader_handle(base_id + 6, @postfx.ssao_wgsl()),
    camera_depth_shader: @gfx.new_shader_handle(
      base_id + 7,
      @shadow3d.shader_camera_depth_wgsl(),
    ),
    config,
  }
}

///|
/// Compose PostFX pipeline: camera depth → (SSAO) → bloom → tonemap → (FXAA).
/// Scene commands must already target `self.scene_target`.
/// Returns PostFX commands to append after scene commands.
pub fn RenderPipeline3D::compose_postfx(
  self : RenderPipeline3D,
  dst : @gfx.ImageHandle,
  depth_casters : Array[@shadow3d.ShadowCaster],
  view_projection : @math3d.Mat4,
  screen_w : Int,
  screen_h : Int,
  hit_flash? : Double = 0.0,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  // Camera depth pass
  let depth_cmds = @shadow3d.camera_depth_pass_commands(
    self.camera_depth_target,
    self.camera_depth_shader,
    depth_casters,
    view_projection,
  )
  for cmd in depth_cmds {
    cmds.push(cmd)
  }
  // SSAO (optional)
  let bloom_input_id = if self.config.ssao_config.enabled {
    cmds.push(
      @postfx.new_ssao_command(
        self.ssao_target,
        self.ssao_sh,
        self.scene_target.id,
        self.camera_depth_target.id,
        self.config.ssao_config.radius,
        self.config.ssao_config.bias,
        self.config.ssao_config.intensity,
        screen_w,
        screen_h,
      ),
    )
    self.ssao_target.id
  } else {
    self.scene_target.id
  }
  // Bloom (threshold → hblur → vblur → composite)
  let bloom_cmds = @postfx.bloom_commands(
    self.post_target,
    bloom_input_id,
    self.bloom_a,
    self.bloom_b,
    self.bloom_threshold_sh,
    self.bloom_hblur_sh,
    self.bloom_vblur_sh,
    self.bloom_composite_sh,
    self.config.bloom_threshold,
    self.config.bloom_intensity,
    screen_w,
    screen_h,
  )
  for cmd in bloom_cmds {
    cmds.push(cmd)
  }
  // Tonemap → optional FXAA
  if self.config.fxaa_enabled {
    cmds.push(
      @postfx.new_tonemap_command(
        self.bloom_b,
        self.tonemap_sh,
        self.post_target.id,
        1.0,
        hit_flash=hit_flash,
      ),
    )
    cmds.push(
      @postfx.new_fxaa_command(
        dst,
        self.fxaa_sh,
        self.bloom_b.id,
        screen_w,
        screen_h,
      ),
    )
  } else {
    cmds.push(
      @postfx.new_tonemap_command(
        dst,
        self.tonemap_sh,
        self.post_target.id,
        1.0,
        hit_flash=hit_flash,
      ),
    )
  }
  cmds
}

///|
pub fn RenderPipeline3D::set_fxaa_enabled(
  self : RenderPipeline3D,
  enabled : Bool,
) -> Unit {
  self.config = { ..self.config, fxaa_enabled: enabled }
}

