///|
/// 3D draw command builders.
///
/// Generates DrawTrianglesCommand from 3D mesh data and MVP matrices.
/// Includes lit shaders and lighting-aware draw commands.

///|
/// Encode a Mat4 as 16 f32 dwords for uniform buffer.
pub fn mat4_to_uniform_dwords(m : @math3d.Mat4) -> Array[Int] {
  let dwords : Array[Int] = []
  for i in 0..<16 {
    dwords.push(@gfx.double_to_f32_bits(m.elements[i]))
  }
  dwords
}

///|
/// Compute MVP matrix and encode as uniform dwords.
pub fn mvp_uniform_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
) -> Array[Int] {
  let mvp = view_projection.multiply(model)
  mat4_to_uniform_dwords(mvp)
}

///|
/// Build a DrawTrianglesCommand from a 3D mesh and transformation matrices.
pub fn new_mesh_draw_command(
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
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = mvp_uniform_dwords(model_matrix, view_projection)
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
    src_image_ids,
    uniform_dwords,
  )
}

// ============================================================
// 3D Lit Shaders
// ============================================================

///|
fn lit_uniform_struct_wgsl() -> String {
  "struct Uniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "  model: mat4x4<f32>,\n" +
  "  normal_col0: vec4<f32>,\n" +
  "  normal_col1: vec4<f32>,\n" +
  "  normal_col2: vec4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "};\n\n"
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
/// WGSL shader source for lit 3D rendering with texture sampling.
/// Vertex format: position(3) + normal(3) + uv(2) = stride 8.
/// Uniform struct: 56 dwords (MVP + Model + NormalMatrix + Lighting).
pub fn shader3d_lit_wgsl() -> String {
  lit_uniform_struct_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "  @location(1) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  lit_normal_mat_wgsl() +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  out.uv = input.uv;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let lit_color = tex_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, tex_color.a);\n" +
  "}\n"
}

///|
/// WGSL shader source for lit 3D rendering without texture (white base color).
/// Vertex format: position(3) + normal(3) + uv(2) = stride 8.
/// Uniform struct: 56 dwords (MVP + Model + NormalMatrix + Lighting).
pub fn shader3d_lit_untextured_wgsl() -> String {
  lit_uniform_struct_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  lit_normal_mat_wgsl() +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let lit_color = diffuse + ambient;\n" +
  "  return vec4<f32>(lit_color, 1.0);\n" +
  "}\n"
}

// ============================================================
// Lit Uniform Encoding
// ============================================================

///|
/// Encode lit uniform data as 56 dwords:
/// MVP(16) + Model(16) + NormalMatrix(12) + Light(12).
pub fn lit_uniform_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
) -> Array[Int] {
  let mvp = view_projection.multiply(model)
  let dwords = mat4_to_uniform_dwords(mvp)
  // Model matrix (16 dwords)
  for i in 0..<16 {
    dwords.push(@gfx.double_to_f32_bits(model.elements[i]))
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
  dwords
}

///|
/// Build a lit DrawTrianglesCommand from a 3D mesh with lighting.
pub fn new_lit_mesh_draw_command(
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
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = lit_uniform_dwords(
    model_matrix, view_projection, lighting,
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
    src_image_ids,
    uniform_dwords,
  )
}

// ============================================================
// 3D Lit Normal Map Shader
// ============================================================

///|
/// Fragment lighting with derivative-based TBN and normal map sampling.
fn lit_fragment_normalmap_lighting_wgsl() -> String {
  "  let dpdx_pos = dpdx(in.world_position);\n" +
  "  let dpdy_pos = dpdy(in.world_position);\n" +
  "  let dpdx_uv = dpdx(in.uv);\n" +
  "  let dpdy_uv = dpdy(in.uv);\n" +
  "  let inv_det = 1.0 / max(dpdx_uv.x * dpdy_uv.y - dpdy_uv.x * dpdx_uv.y, 1e-6);\n" +
  "  let tangent = normalize((dpdx_pos * dpdy_uv.y - dpdy_pos * dpdx_uv.y) * inv_det);\n" +
  "  let bitangent = normalize((dpdy_pos * dpdx_uv.x - dpdx_pos * dpdy_uv.x) * inv_det);\n" +
  "  let geom_normal = normalize(in.world_normal);\n" +
  "  let tbn = mat3x3<f32>(tangent, bitangent, geom_normal);\n" +
  "  let normal_sample = textureSample(normal_map, normal_map_sampler, in.uv).xyz * 2.0 - 1.0;\n" +
  "  let normal = normalize(tbn * normal_sample);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let diffuse = uniforms.light_color.xyz * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz;\n"
}

///|
/// WGSL shader source for lit 3D rendering with texture + normal map.
/// Vertex format: position(3) + normal(3) + uv(2) = stride 8.
/// Uniform struct: 56 dwords (MVP + Model + NormalMatrix + Lighting).
/// Textures: @binding(1) diffuse, @binding(3) normal map.
pub fn shader3d_lit_normalmap_wgsl() -> String {
  lit_uniform_struct_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n" +
  "@group(0) @binding(3) var normal_map: texture_2d<f32>;\n" +
  "@group(0) @binding(4) var normal_map_sampler: sampler;\n\n" +
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
  lit_fragment_normalmap_lighting_wgsl() +
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let lit_color = tex_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, tex_color.a);\n" +
  "}\n"
}

///|
/// Build a lit DrawTrianglesCommand with normal map support.
/// src_image_ids should contain [diffuse_image_id, normal_map_image_id].
pub fn new_lit_normalmap_mesh_draw_command(
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
  diffuse_image_id : Int,
  normal_map_image_id : Int,
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = lit_uniform_dwords(
    model_matrix, view_projection, lighting,
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
    [diffuse_image_id, normal_map_image_id],
    uniform_dwords,
  )
}

// ============================================================
// 3D Lit Skinned Shader (GPU Skinning)
// ============================================================

///|
let max_bones : Int = 64

///|
/// Uniform struct for skinned lit shader.
/// Layout: MVP(16) + Model(16) + NormalMatrix(12) + Light(12) + num_bones(4, padded) + bone_matrices(MAX_BONES*16).
fn skinned_lit_uniform_struct_wgsl() -> String {
  "const MAX_BONES: u32 = 64u;\n\n" +
  "struct Uniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "  model: mat4x4<f32>,\n" +
  "  normal_col0: vec4<f32>,\n" +
  "  normal_col1: vec4<f32>,\n" +
  "  normal_col2: vec4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  num_bones: vec4<f32>,\n" +
  "  bone_matrices: array<mat4x4<f32>, 64>,\n" +
  "};\n\n"
}

///|
/// WGSL shader source for lit 3D rendering with GPU skinning.
/// Vertex format: position(3) + normal(3) + uv(2) + joints(4) + weights(4) = stride 16.
pub fn shader3d_lit_skinned_wgsl() -> String {
  skinned_lit_uniform_struct_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "  @location(3) joints: vec4<f32>,\n" +
  "  @location(4) weights: vec4<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "  @location(1) uv: vec2<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var skin_mat = mat4x4<f32>();\n" +
  "  for (var i = 0u; i < 4u; i = i + 1u) {\n" +
  "    let joint_idx = u32(input.joints[i]);\n" +
  "    let weight = input.weights[i];\n" +
  "    if (weight > 0.0) {\n" +
  "      skin_mat = skin_mat + weight * uniforms.bone_matrices[joint_idx];\n" +
  "    }\n" +
  "  }\n" +
  "  let skinned_pos = skin_mat * vec4<f32>(input.position, 1.0);\n" +
  "  let skinned_normal = (skin_mat * vec4<f32>(input.normal, 0.0)).xyz;\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * skinned_pos;\n" +
  lit_normal_mat_wgsl() +
  "  out.world_normal = normalize(normal_mat * skinned_normal);\n" +
  "  out.uv = input.uv;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let lit_color = tex_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, tex_color.a);\n" +
  "}\n"
}

///|
/// Compute uniform dwords count for skinned lit shader.
/// 56 (base lit) + 4 (num_bones padded) + MAX_BONES * 16 (bone matrices).
pub fn skinned_lit_uniform_dwords() -> Int {
  56 + 4 + max_bones * 16
}

///|
/// Build a skinned lit DrawTrianglesCommand.
/// `skinning_matrices` are the final bone matrices to upload.
pub fn new_skinned_lit_mesh_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  vertex_data : Array[Double],
  indices : Array[Int],
  model_matrix : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  skinning_matrices : Array[@math3d.Mat4],
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  // Base lit uniforms (56 dwords)
  let dwords = lit_uniform_dwords(model_matrix, view_projection, lighting)
  // num_bones as vec4<f32> (4 dwords, padded)
  dwords.push(@gfx.double_to_f32_bits(skinning_matrices.length().to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  // Bone matrices (each 16 dwords, up to MAX_BONES)
  let bone_count = if skinning_matrices.length() < max_bones {
    skinning_matrices.length()
  } else {
    max_bones
  }
  for i in 0..<bone_count {
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(skinning_matrices[i].elements[j]))
    }
  }
  // Pad remaining bones with zeros
  for _i in bone_count..<max_bones {
    for _j in 0..<16 {
      dwords.push(0)
    }
  }
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    index_offset,
    pipeline_id,
    uniform_hash,
    blend,
    vertex_data,
    indices,
    src_image_ids,
    dwords,
  )
}

// ============================================================
// 3D PBR Shaders (Cook-Torrance BRDF)
// ============================================================

///|
fn pbr_uniform_struct_wgsl() -> String {
  "struct Uniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "  model: mat4x4<f32>,\n" +
  "  normal_col0: vec4<f32>,\n" +
  "  normal_col1: vec4<f32>,\n" +
  "  normal_col2: vec4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  base_color: vec4<f32>,\n" +
  "  pbr_params: vec4<f32>,\n" +
  "  emissive: vec4<f32>,\n" +
  "  camera_pos: vec4<f32>,\n" +
  "};\n\n"
}

///|
fn pbr_brdf_functions_wgsl() -> String {
  "const PI: f32 = 3.14159265359;\n\n" +
  "fn distribution_ggx(n: vec3<f32>, h: vec3<f32>, roughness: f32) -> f32 {\n" +
  "  let a = roughness * roughness;\n" +
  "  let a2 = a * a;\n" +
  "  let ndoth = max(dot(n, h), 0.0);\n" +
  "  let ndoth2 = ndoth * ndoth;\n" +
  "  let denom = ndoth2 * (a2 - 1.0) + 1.0;\n" +
  "  return a2 / (PI * denom * denom);\n" +
  "}\n\n" +
  "fn geometry_schlick_ggx(ndotv: f32, roughness: f32) -> f32 {\n" +
  "  let r = roughness + 1.0;\n" +
  "  let k = (r * r) / 8.0;\n" +
  "  return ndotv / (ndotv * (1.0 - k) + k);\n" +
  "}\n\n" +
  "fn geometry_smith(n: vec3<f32>, v: vec3<f32>, l: vec3<f32>, roughness: f32) -> f32 {\n" +
  "  let ndotv = max(dot(n, v), 0.0);\n" +
  "  let ndotl = max(dot(n, l), 0.0);\n" +
  "  return geometry_schlick_ggx(ndotv, roughness) * geometry_schlick_ggx(ndotl, roughness);\n" +
  "}\n\n" +
  "fn fresnel_schlick(cos_theta: f32, f0: vec3<f32>) -> vec3<f32> {\n" +
  "  return f0 + (1.0 - f0) * pow(clamp(1.0 - cos_theta, 0.0, 1.0), 5.0);\n" +
  "}\n\n"
}

///|
fn pbr_fragment_body_wgsl() -> String {
  "  let normal = normalize(in.world_normal);\n" +
  "  let view_dir = normalize(uniforms.camera_pos.xyz - in.world_position);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let half_dir = normalize(view_dir + light_dir);\n" +
  "  let metallic = uniforms.pbr_params.x;\n" +
  "  let roughness = uniforms.pbr_params.y;\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let f0 = mix(vec3<f32>(0.04), albedo, metallic);\n" +
  "  let ndf = distribution_ggx(normal, half_dir, roughness);\n" +
  "  let g = geometry_smith(normal, view_dir, light_dir, roughness);\n" +
  "  let f = fresnel_schlick(max(dot(half_dir, view_dir), 0.0), f0);\n" +
  "  let numerator = ndf * g * f;\n" +
  "  let denominator = 4.0 * max(dot(normal, view_dir), 0.0) * ndotl + 0.0001;\n" +
  "  let specular = numerator / denominator;\n" +
  "  let kd = (vec3<f32>(1.0) - f) * (1.0 - metallic);\n" +
  "  let radiance = uniforms.light_color.xyz;\n" +
  "  let lo = (kd * albedo / PI + specular) * radiance * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz * albedo;\n" +
  "  let emissive = uniforms.emissive.xyz;\n" +
  "  let color = lo + ambient + emissive;\n"
}

///|
/// WGSL PBR shader with texture sampling (Cook-Torrance BRDF).
/// Uniform struct: 72 dwords (lit 56 + base_color 4 + pbr_params 4 + emissive 4 + camera_pos 4).
pub fn shader3d_pbr_wgsl() -> String {
  pbr_uniform_struct_wgsl() +
  pbr_brdf_functions_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n" +
  "@group(0) @binding(1) var tex: texture_2d<f32>;\n" +
  "@group(0) @binding(2) var tex_sampler: sampler;\n\n" +
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
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let albedo = tex_color.rgb * uniforms.base_color.rgb;\n" +
  pbr_fragment_body_wgsl() +
  "  return vec4<f32>(color, tex_color.a * uniforms.base_color.a);\n" +
  "}\n"
}

///|
/// WGSL PBR shader without texture (Cook-Torrance BRDF).
/// Uniform struct: 72 dwords.
pub fn shader3d_pbr_untextured_wgsl() -> String {
  pbr_uniform_struct_wgsl() +
  pbr_brdf_functions_wgsl() +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\n" +
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
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  lit_normal_mat_wgsl() +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  out.world_position = (uniforms.model * vec4<f32>(input.position, 1.0)).xyz;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let albedo = uniforms.base_color.rgb;\n" +
  pbr_fragment_body_wgsl() +
  "  return vec4<f32>(color, uniforms.base_color.a);\n" +
  "}\n"
}

// ============================================================
// PBR Uniform Encoding
// ============================================================

///|
/// Encode PBR uniform data as 72 dwords:
/// lit(56) + base_color(4) + pbr_params(4) + emissive(4) + camera_pos(4).
pub fn pbr_uniform_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  metallic : Double,
  roughness : Double,
  base_color : @math3d.Vec4,
  emissive : @math3d.Vec3,
  camera_pos : @math3d.Vec3,
) -> Array[Int] {
  let dwords = lit_uniform_dwords(model, view_projection, lighting)
  // base_color (4 dwords)
  dwords.push(@gfx.double_to_f32_bits(base_color.x))
  dwords.push(@gfx.double_to_f32_bits(base_color.y))
  dwords.push(@gfx.double_to_f32_bits(base_color.z))
  dwords.push(@gfx.double_to_f32_bits(base_color.w))
  // pbr_params (4 dwords)
  dwords.push(@gfx.double_to_f32_bits(metallic))
  dwords.push(@gfx.double_to_f32_bits(roughness))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  // emissive (4 dwords)
  dwords.push(@gfx.double_to_f32_bits(emissive.x))
  dwords.push(@gfx.double_to_f32_bits(emissive.y))
  dwords.push(@gfx.double_to_f32_bits(emissive.z))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  // camera_pos (4 dwords)
  dwords.push(@gfx.double_to_f32_bits(camera_pos.x))
  dwords.push(@gfx.double_to_f32_bits(camera_pos.y))
  dwords.push(@gfx.double_to_f32_bits(camera_pos.z))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords
}

// ============================================================
// 3D Particle Shader (Emissive, No Lighting)
// ============================================================

///|
/// WGSL shader source for particle rendering.
/// Vertex format: position(3) + normal(3) + uv(2) = stride 8.
/// Normal channels (nx,ny,nz) encode RGB color, uv.x encodes alpha.
/// Uniform: MVP only (16 dwords).
pub fn shader3d_particle_wgsl() -> String {
  "struct Uniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) color: vec3<f32>,\n" +
  "  @location(1) alpha: f32,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput) -> VertexOutput {\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.mvp * vec4<f32>(input.position, 1.0);\n" +
  "  out.color = input.normal;\n" +
  "  out.alpha = input.uv.x;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  return vec4<f32>(in.color, in.alpha);\n" +
  "}\n"
}

///|
/// Encode particle uniform data as 16 dwords (MVP only).
pub fn particle_uniform_dwords(vp : @math3d.Mat4) -> Array[Int] {
  mat4_to_uniform_dwords(vp)
}

///|
/// Build a particle DrawTrianglesCommand.
pub fn new_particle_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  vertex_data : Array[Double],
  indices : Array[Int],
  view_projection : @math3d.Mat4,
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = particle_uniform_dwords(view_projection)
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    index_offset,
    pipeline_id,
    uniform_hash,
    blend,
    vertex_data,
    indices,
    src_image_ids,
    uniform_dwords,
  )
}

///|
/// Build a PBR DrawTrianglesCommand.
pub fn new_pbr_mesh_draw_command(
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
  metallic : Double,
  roughness : Double,
  base_color : @math3d.Vec4,
  emissive : @math3d.Vec3,
  camera_pos : @math3d.Vec3,
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = pbr_uniform_dwords(
    model_matrix, view_projection, lighting, metallic, roughness, base_color,
    emissive, camera_pos,
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
    src_image_ids,
    uniform_dwords,
  )
}
