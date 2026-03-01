///|
/// Shadow mapping for 3D rendering.
///
/// Depth-to-Color approach: renders linear depth to R channel of a color texture,
/// then samples shadow map in the main pass with PCF filtering.

///|
fn f32(v : Double) -> Int {
  @gfx.double_to_f32_bits(v)
}

// ============================================================
// ShadowConfig
// ============================================================

///|
pub struct ShadowConfig {
  map_size : Int
  half_extent : Double
  near : Double
  far : Double
  distance : Double
  center : @math3d.Vec3
  bias : Double
  pcf_texel_size : Double
}

///|
pub fn ShadowConfig::new(
  map_size : Int,
  half_extent : Double,
  near : Double,
  far : Double,
  distance : Double,
  center : @math3d.Vec3,
  bias : Double,
) -> ShadowConfig {
  {
    map_size,
    half_extent,
    near,
    far,
    distance,
    center,
    bias,
    pcf_texel_size: 1.0 / map_size.to_double(),
  }
}

// ============================================================
// Light Space Matrices
// ============================================================

///|
/// Compute view matrix from light direction.
/// eye = center - light_dir * distance, target = center.
pub fn light_view_matrix(
  light_dir : @math3d.Vec3,
  center : @math3d.Vec3,
  distance : Double,
) -> @math3d.Mat4 {
  let len = (light_dir.x * light_dir.x +
    light_dir.y * light_dir.y +
    light_dir.z * light_dir.z).sqrt()
  if len < 1.0e-8 {
    return @math3d.Mat4::identity()
  }
  let dir = light_dir.normalize()
  let eye = center.sub(dir.scale(distance))
  let up = if (dir.x * 0.0 + dir.y * 1.0 + dir.z * 0.0).abs() > 0.999 {
    @math3d.Vec3::new(1.0, 0.0, 0.0)
  } else {
    @math3d.Vec3::new(0.0, 1.0, 0.0)
  }
  @math3d.Mat4::look_at(eye, center, up)
}

///|
/// Compute orthographic projection for shadow volume.
pub fn light_projection_matrix(
  half_extent : Double,
  near : Double,
  far : Double,
) -> @math3d.Mat4 {
  @math3d.Mat4::orthographic(
    -half_extent,
    half_extent,
    -half_extent,
    half_extent,
    near,
    far,
  )
}

///|
/// Combined light-space matrix: projection * view.
pub fn light_space_matrix(
  light_dir : @math3d.Vec3,
  center : @math3d.Vec3,
  distance : Double,
  half_extent : Double,
  near : Double,
  far : Double,
) -> @math3d.Mat4 {
  let view = light_view_matrix(light_dir, center, distance)
  let proj = light_projection_matrix(half_extent, near, far)
  proj.multiply(view)
}

// ============================================================
// Depth Pass Shader
// ============================================================

///|
/// WGSL shader for shadow depth pass.
/// Renders linear depth to R channel.
/// Uniform: light_mvp (16 dwords).
pub fn shader_shadow_depth_wgsl() -> String {
  "struct Uniforms {\n" +
  "  light_mvp: mat4x4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) depth: f32,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  let light_space_pos = uniforms.light_mvp * vec4<f32>(input.position, 1.0);\n" +
  "  out.clip_position = light_space_pos;\n" +
  "  out.depth = clamp(light_space_pos.z / light_space_pos.w, 0.0, 1.0);\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  return vec4<f32>(in.depth, 0.0, 0.0, 1.0);\n" +
  "}\n"
}

///|
/// Encode depth pass uniform: light_mvp = light_vp * model (16 dwords).
pub fn shadow_depth_uniform_dwords(
  model : @math3d.Mat4,
  light_vp : @math3d.Mat4,
) -> Array[Int] {
  let light_mvp = light_vp.multiply(model)
  let dwords : Array[Int] = []
  for i in 0..<16 {
    dwords.push(f32(light_mvp.elements[i]))
  }
  dwords
}

///|
/// Create a DrawTrianglesCommand for the shadow depth pass.
pub fn new_shadow_depth_command(
  shadow_map : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  mesh : @mesh3d.Mesh3D,
  model : @math3d.Mat4,
  light_vp : @math3d.Mat4,
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = shadow_depth_uniform_dwords(model, light_vp)
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    shadow_map.width,
    shadow_map.height,
    mesh.indices.length(),
  )
  @gfx.new_draw_triangles_command(
    shadow_map,
    shader,
    [dst_region],
    0,
    0,
    0,
    @gfx.blend_mode_from_int(0),
    mesh.vertex_data,
    mesh.indices,
    [],
    uniform_dwords,
  )
}

// ============================================================
// ShadowCaster + Batch
// ============================================================

///|
pub struct ShadowCaster {
  mesh : @mesh3d.Mesh3D
  model_matrix : @math3d.Mat4
}

///|
pub fn ShadowCaster::new(
  mesh : @mesh3d.Mesh3D,
  model_matrix : @math3d.Mat4,
) -> ShadowCaster {
  { mesh, model_matrix }
}

///|
/// Generate depth pass commands for all shadow casters.
pub fn shadow_depth_pass_commands(
  shadow_map : @gfx.ImageHandle,
  depth_shader : @gfx.ShaderHandle,
  casters : Array[ShadowCaster],
  lighting : @light3d.LightingEnvironment,
  config : ShadowConfig,
) -> Array[@gfx.DrawTrianglesCommand] {
  let light_vp = light_space_matrix(
    lighting.directional.direction,
    config.center,
    config.distance,
    config.half_extent,
    config.near,
    config.far,
  )
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  for i in 0..<casters.length() {
    let caster = casters[i]
    commands.push(
      new_shadow_depth_command(
        shadow_map, depth_shader, caster.mesh, caster.model_matrix, light_vp,
      ),
    )
  }
  commands
}

// ============================================================
// Shadow Lit Shader (Textured)
// ============================================================

///|
fn shadow_lit_uniform_struct_wgsl() -> String {
  "struct Uniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "  model: mat4x4<f32>,\n" +
  "  normal_col0: vec4<f32>,\n" +
  "  normal_col1: vec4<f32>,\n" +
  "  normal_col2: vec4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  light_vp: mat4x4<f32>,\n" +
  "  shadow_params: vec4<f32>,\n" +
  "};\n\n"
}

///|
fn shadow_calc_wgsl() -> String {
  "fn calc_shadow(world_pos: vec3<f32>) -> f32 {\n" +
  "  let light_space = uniforms.light_vp * vec4<f32>(world_pos, 1.0);\n" +
  "  let proj_coords = light_space.xyz / light_space.w;\n" +
  "  let shadow_uv = vec2<f32>(proj_coords.x * 0.5 + 0.5, 1.0 - (proj_coords.y * 0.5 + 0.5));\n" +
  "  if (shadow_uv.x < 0.0 || shadow_uv.x > 1.0 || shadow_uv.y < 0.0 || shadow_uv.y > 1.0) {\n" +
  "    return 1.0;\n" +
  "  }\n" +
  "  let current_depth = clamp(proj_coords.z, 0.0, 1.0);\n" +
  "  let bias = uniforms.shadow_params.x;\n" +
  "  let texel_size = uniforms.shadow_params.y;\n" +
  "  var shadow = 0.0;\n" +
  "  for (var x = -1; x <= 1; x = x + 1) {\n" +
  "    for (var y = -1; y <= 1; y = y + 1) {\n" +
  "      let offset = vec2<f32>(f32(x), f32(y)) * texel_size;\n" +
  "      let closest_depth = textureSample(shadow_map, shadow_sampler, shadow_uv + offset).r;\n" +
  "      shadow = shadow + select(0.0, 1.0, current_depth - bias > closest_depth);\n" +
  "    }\n" +
  "  }\n" +
  "  return 1.0 - shadow / 9.0;\n" +
  "}\n\n"
}

///|
fn lit_normal_mat_wgsl() -> String {
  "  let normal_mat = mat3x3<f32>(\n" +
  "    uniforms.normal_col0.xyz,\n" +
  "    uniforms.normal_col1.xyz,\n" +
  "    uniforms.normal_col2.xyz,\n" +
  "  );\n"
}

///|
fn lit_fragment_lighting_wgsl() -> String {
  "  let normal = normalize(in.world_normal);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let diffuse = uniforms.light_color.xyz * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz;\n"
}

///|
/// WGSL shader for lit 3D rendering with shadow mapping and texture.
/// Uniform: 76 dwords. Textures: @binding(1) diffuse, @binding(3) shadow map.
pub fn shader3d_shadow_lit_wgsl() -> String {
  shadow_lit_uniform_struct_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n" +
  "@group(0) @binding(3) var shadow_map: texture_2d<f32>;\n" +
  "@group(0) @binding(4) var shadow_sampler: sampler;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "  @location(1) uv: vec2<f32>,\n" +
  "  @location(2) world_position: vec3<f32>,\n" +
  "};\n\n" +
  shadow_calc_wgsl() +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  lit_normal_mat_wgsl() +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  out.world_position = (uniforms.model * vec4<f32>(input.position, 1.0)).xyz;\n" +
  "  out.uv = input.uv;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let shadow_factor = calc_shadow(in.world_position);\n" +
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let lit_color = tex_color.rgb * (diffuse * shadow_factor + ambient);\n" +
  "  return vec4<f32>(lit_color, tex_color.a);\n" +
  "}\n"
}

///|
/// WGSL shader for lit 3D rendering with shadow mapping, no texture (white base).
/// Uniform: 76 dwords. Textures: @binding(3) shadow map.
pub fn shader3d_shadow_lit_untextured_wgsl() -> String {
  shadow_lit_uniform_struct_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(3) var shadow_map: texture_2d<f32>;\n" +
  "@group(0) @binding(4) var shadow_sampler: sampler;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "  @location(1) world_position: vec3<f32>,\n" +
  "};\n\n" +
  shadow_calc_wgsl() +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  lit_normal_mat_wgsl() +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  out.world_position = (uniforms.model * vec4<f32>(input.position, 1.0)).xyz;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let shadow_factor = calc_shadow(in.world_position);\n" +
  "  let lit_color = diffuse * shadow_factor + ambient;\n" +
  "  return vec4<f32>(lit_color, 1.0);\n" +
  "}\n"
}

// ============================================================
// Shadow Lit Uniform Encoding
// ============================================================

///|
/// Encode shadow-lit uniform data as 76 dwords:
/// MVP(16) + Model(16) + NormalMatrix(12) + Light(12) + LightVP(16) + ShadowParams(4).
pub fn shadow_lit_uniform_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  light_vp : @math3d.Mat4,
  config : ShadowConfig,
) -> Array[Int] {
  let mvp = view_projection.multiply(model)
  let dwords : Array[Int] = []
  // MVP (16 dwords)
  for i in 0..<16 {
    dwords.push(f32(mvp.elements[i]))
  }
  // Model (16 dwords)
  for i in 0..<16 {
    dwords.push(f32(model.elements[i]))
  }
  // Normal matrix (12 dwords)
  let normal_dw = @light3d.normal_matrix_uniform_dwords(model)
  for i in 0..<normal_dw.length() {
    dwords.push(normal_dw[i])
  }
  // Light data (12 dwords)
  let light_dw = @light3d.light_uniform_dwords(lighting)
  for i in 0..<light_dw.length() {
    dwords.push(light_dw[i])
  }
  // Light VP matrix (16 dwords)
  for i in 0..<16 {
    dwords.push(f32(light_vp.elements[i]))
  }
  // Shadow params (4 dwords): bias, texel_size, 0, 0
  dwords.push(f32(config.bias))
  dwords.push(f32(config.pcf_texel_size))
  dwords.push(f32(0.0))
  dwords.push(f32(0.0))
  dwords
}

// ============================================================
// Shadow Lit Draw Commands
// ============================================================

///|
/// Create a DrawTrianglesCommand for shadow-lit textured mesh.
/// src_image_ids: [diffuse_image_id, shadow_map_image_id].
pub fn new_shadow_lit_mesh_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  mesh : @mesh3d.Mesh3D,
  model_matrix : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  light_vp : @math3d.Mat4,
  config : ShadowConfig,
  diffuse_image_id : Int,
  shadow_map_image_id : Int,
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = shadow_lit_uniform_dwords(
    model_matrix, view_projection, lighting, light_vp, config,
  )
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    index_offset,
    pipeline_id,
    uniform_hash,
    blend,
    mesh.vertex_data,
    mesh.indices,
    [diffuse_image_id, shadow_map_image_id],
    uniform_dwords,
  )
}
