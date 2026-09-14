///|
/// Three.js 0.185.1 MeshStandardMaterial profile, implemented in shaders/*.wgsl.
/// 104 dwords: PBR + PbrEnvironment + PbrShadow. Bindings 1/2 sRGB base texture
/// (use a white texture for uniform color), 3/4 linear RGBA16F PMREM CubeUV,
/// 5/6 packed depth shadow. Default output is display sRGB with ACES Filmic then
/// view-depth fog; do not tone-map or sRGB-encode the result again.
/// linear_output bypasses display processing for HDR composition/diagnostics.
/// srgb_texture=true requires an rgba8unorm-srgb base texture: hardware decodes
/// before filtering. False preserves manual decoding for existing UNORM users.
/// Shadow params: bias, 1/map_size, viewport_height (WebGL screen origin), disabled.
/// Pass viewport_height to the draw command for the source PCF sample rotation.
pub fn shader3d_standard_wgsl(
  linear_output? : Bool = false,
  srgb_texture? : Bool = false,
) -> String {
  "const STANDARD_TEXTURE_SRGB = \{srgb_texture};\n" +
  "const STANDARD_LINEAR_OUTPUT = \{linear_output};\n" +
  standard_uniforms_source() +
  standard_color_source() +
  standard_cube_uv_source() +
  dfg_wgsl() +
  standard_shadow_source() +
  standard_standard_source()
}

///|
/// Display output for basic/unlit surfaces. Same 104-dword uniform contract;
/// only base-color texture/sampler bindings 1/2 are used. No lighting textures.
pub fn shader3d_standard_unlit_wgsl(
  tonemapped? : Bool = true,
  fog? : Bool = true,
  srgb_texture? : Bool = false,
) -> String {
  "const STANDARD_TEXTURE_SRGB = \{srgb_texture};\n" +
  "const STANDARD_TONEMAPPED = \{tonemapped};\n" +
  "const STANDARD_FOG = \{fog};\n" +
  standard_uniforms_source() +
  standard_color_source() +
  standard_unlit_source()
}

///|
/// Copy a resolved display-color image without applying FXAA or tone mapping.
/// Uniform: vec2 UV scale, padded to 4 dwords; pass [1, 1, 0, 0] as f32 bits.
pub fn shader3d_present_wgsl() -> String {
  standard_present_source()
}
