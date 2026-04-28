///|
/// 3D draw command builders.
///
/// Generates DrawTrianglesCommand from 3D mesh data and MVP matrices.
/// Includes lit shaders and lighting-aware draw commands.

///|
/// Encode a Mat4 as 16 f32 dwords for uniform buffer.
pub fn mat4_to_uniform_dwords(m : @math3d.Mat4) -> Array[Int] {
  let dwords : Array[Int] = Array::make(16, 0)
  for i in 0..<16 {
    dwords[i] = @gfx.double_to_f32_bits(m.elements[i])
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
    vertex_stride_hint=mesh.format.stride(),
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

///|
/// WGSL shader source for lit 3D rendering with uniform base color.
/// Vertex format: position(3) + normal(3) + uv(2) = stride 8.
/// Uniform struct: 60 dwords (MVP + Model + NormalMatrix + Lighting + BaseColor).
pub fn shader3d_lit_colored_wgsl() -> String {
  "struct ColoredUniforms {\n" +
  "  mvp: mat4x4<f32>,\n" +
  "  model: mat4x4<f32>,\n" +
  "  normal0: vec4<f32>,\n" +
  "  normal1: vec4<f32>,\n" +
  "  normal2: vec4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  base_color: vec4<f32>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: ColoredUniforms;\n\n" +
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
  "  let normal_mat = mat3x3<f32>(uniforms.normal0.xyz, uniforms.normal1.xyz, uniforms.normal2.xyz);\n" +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let normal = normalize(in.world_normal);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let diffuse = uniforms.light_color.xyz * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz;\n" +
  "  let lit_color = uniforms.base_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, uniforms.base_color.a);\n" +
  "}\n"
}

// ============================================================
// Lit Uniform Encoding
// ============================================================

///|
fn lit_uniform_dwords_with_light_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  light_dwords : Array[Int],
) -> Array[Int] {
  let mvp = view_projection.multiply(model)
  let dwords : Array[Int] = Array::make(56, 0)
  for i in 0..<16 {
    dwords[i] = @gfx.double_to_f32_bits(mvp.elements[i])
    dwords[16 + i] = @gfx.double_to_f32_bits(model.elements[i])
  }
  let normal_dw = @light3d.normal_matrix_uniform_dwords(model)
  for i in 0..<12 {
    dwords[32 + i] = normal_dw[i]
    dwords[44 + i] = light_dwords[i]
  }
  dwords
}

///|
/// Encode lit uniform data as 56 dwords:
/// MVP(16) + Model(16) + NormalMatrix(12) + Light(12).
pub fn lit_uniform_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
) -> Array[Int] {
  let light_dw = @light3d.light_uniform_dwords(lighting)
  lit_uniform_dwords_with_light_dwords(model, view_projection, light_dw)
}

///|
/// Encode lit uniform data with uniform base color as 60 dwords.
/// MVP(16) + Model(16) + NormalMatrix(12) + Light(12) + BaseColor(4).
pub fn lit_colored_uniform_dwords(
  model : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  base_color : @math3d.Vec4,
) -> Array[Int] {
  let dwords = lit_uniform_dwords(model, view_projection, lighting)
  dwords.push(@gfx.double_to_f32_bits(base_color.x))
  dwords.push(@gfx.double_to_f32_bits(base_color.y))
  dwords.push(@gfx.double_to_f32_bits(base_color.z))
  dwords.push(@gfx.double_to_f32_bits(base_color.w))
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
  let light_dwords = @light3d.light_uniform_dwords(lighting)
  new_lit_mesh_draw_command_with_light_dwords(
    dst, shader, dst_region, index_offset, pipeline_id, uniform_hash, blend, mesh,
    model_matrix, view_projection, light_dwords, src_image_ids,
  )
}

///|
/// Build a lit DrawTrianglesCommand from a 3D mesh with prepacked light dwords.
pub fn new_lit_mesh_draw_command_with_light_dwords(
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
  light_dwords : Array[Int],
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = lit_uniform_dwords_with_light_dwords(
    model_matrix, view_projection, light_dwords,
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
    vertex_stride_hint=mesh.format.stride(),
  )
}

///|
/// Build a lit DrawTrianglesCommand from a 3D mesh with lighting and uniform base color.
pub fn new_lit_colored_mesh_draw_command(
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
  base_color : @math3d.Vec4,
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = lit_colored_uniform_dwords(
    model_matrix, view_projection, lighting, base_color,
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
    vertex_stride_hint=mesh.format.stride(),
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
    vertex_stride_hint=mesh.format.stride(),
  )
}

// ============================================================
// 3D Lit Skinned Shader (GPU Skinning)
// ============================================================

///|
let max_bones : Int = 64

///|
let max_skinned_instances : Int = 64

///|
pub fn skinned_instanced_max_instances() -> Int {
  max_skinned_instances
}

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
  "  let pre_skinned = uniforms.num_bones.y > 0.5;\n" +
  "  var skinned_pos = vec4<f32>(input.position, 1.0);\n" +
  "  var skinned_normal = input.normal;\n" +
  "  if (!pre_skinned) {\n" +
  "    var skin_mat = mat4x4<f32>();\n" +
  "    for (var i = 0u; i < 4u; i = i + 1u) {\n" +
  "      let joint_idx = u32(input.joints[i]);\n" +
  "      let weight = input.weights[i];\n" +
  "      if (weight > 0.0) {\n" +
  "        skin_mat = skin_mat + weight * uniforms.bone_matrices[joint_idx];\n" +
  "      }\n" +
  "    }\n" +
  "    skinned_pos = skin_mat * vec4<f32>(input.position, 1.0);\n" +
  "    skinned_normal = (skin_mat * vec4<f32>(input.normal, 0.0)).xyz;\n" +
  "  }\n" +
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
fn skinned_instanced_lit_uniform_struct_wgsl() -> String {
  "const MAX_BONES: u32 = 64u;\n" +
  "const MAX_INSTANCES: u32 = 64u;\n\n" +
  "struct InstanceData {\n" +
  "  model: mat4x4<f32>,\n" +
  "  color: vec4<f32>,\n" +
  "};\n\n" +
  "struct Uniforms {\n" +
  "  vp: mat4x4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  num_bones: vec4<f32>,\n" +
  "  bone_matrices: array<mat4x4<f32>, 64>,\n" +
  "  instance_count: vec4<f32>,\n" +
  "  instances: array<InstanceData, 64>,\n" +
  "};\n\n"
}

///|
pub fn shader3d_lit_skinned_instanced_wgsl() -> String {
  skinned_instanced_lit_uniform_struct_wgsl() +
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
  "  @location(2) inst_color: vec4<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) iid: u32) -> VertexOutput {\n" +
  "  let inst = uniforms.instances[iid];\n" +
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
  "  let world_pos = inst.model * skinned_pos;\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.vp * world_pos;\n" +
  "  let normal_mat = mat3x3<f32>(inst.model[0].xyz, inst.model[1].xyz, inst.model[2].xyz);\n" +
  "  out.world_normal = normalize(normal_mat * skinned_normal);\n" +
  "  out.uv = input.uv;\n" +
  "  out.inst_color = inst.color;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let lit_color = tex_color.rgb * in.inst_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, tex_color.a * in.inst_color.a);\n" +
  "}\n"
}

///|
fn skinned_instanced_monochrome_lit_uniform_struct_wgsl() -> String {
  "const MAX_BONES: u32 = 64u;\n" +
  "const MAX_INSTANCES: u32 = 64u;\n\n" +
  "struct Uniforms {\n" +
  "  vp: mat4x4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  num_bones: vec4<f32>,\n" +
  "  bone_matrices: array<mat4x4<f32>, 64>,\n" +
  "  instance_count: vec4<f32>,\n" +
  "  base_color: vec4<f32>,\n" +
  "  instance_models: array<mat4x4<f32>, 64>,\n" +
  "};\n\n"
}

///|
pub fn shader3d_lit_skinned_instanced_monochrome_wgsl() -> String {
  skinned_instanced_monochrome_lit_uniform_struct_wgsl() +
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
  "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) iid: u32) -> VertexOutput {\n" +
  "  let model = uniforms.instance_models[iid];\n" +
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
  "  let world_pos = model * skinned_pos;\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = uniforms.vp * world_pos;\n" +
  "  let normal_mat = mat3x3<f32>(model[0].xyz, model[1].xyz, model[2].xyz);\n" +
  "  out.world_normal = normalize(normal_mat * skinned_normal);\n" +
  "  out.uv = input.uv;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  lit_fragment_lighting_wgsl() +
  "  let tex_color = textureSample(tex, tex_sampler, in.uv);\n" +
  "  let lit_color = tex_color.rgb * uniforms.base_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, tex_color.a * uniforms.base_color.a);\n" +
  "}\n"
}

///|
/// Compute uniform dwords count for skinned lit shader.
/// 56 (base lit) + 4 (num_bones padded) + MAX_BONES * 16 (bone matrices).
pub fn skinned_lit_uniform_dwords() -> Int {
  56 + 4 + max_bones * 16
}

///|
pub fn skinned_instanced_lit_uniform_dwords(
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  skinning_matrices : Array[@math3d.Mat4],
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
) -> Array[Int] {
  let dwords = mat4_to_uniform_dwords(view_projection)
  let light_dw = @light3d.light_uniform_dwords(lighting)
  for i in 0..<light_dw.length() {
    dwords.push(light_dw[i])
  }
  let bone_count = if skinning_matrices.length() < max_bones {
    skinning_matrices.length()
  } else {
    max_bones
  }
  dwords.push(@gfx.double_to_f32_bits(bone_count.to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  for i in 0..<bone_count {
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(skinning_matrices[i].elements[j]))
    }
  }
  for _i in bone_count..<max_bones {
    for _j in 0..<16 {
      dwords.push(0)
    }
  }
  let count = if instance_matrices.length() < instance_colors.length() {
    instance_matrices.length()
  } else {
    instance_colors.length()
  }
  dwords.push(@gfx.double_to_f32_bits(count.to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  let inst_count = if count < max_skinned_instances {
    count
  } else {
    max_skinned_instances
  }
  for i in 0..<inst_count {
    let m = instance_matrices[i]
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(m.elements[j]))
    }
    let c = instance_colors[i]
    dwords.push(@gfx.double_to_f32_bits(c.x))
    dwords.push(@gfx.double_to_f32_bits(c.y))
    dwords.push(@gfx.double_to_f32_bits(c.z))
    dwords.push(@gfx.double_to_f32_bits(c.w))
  }
  for _i in inst_count..<max_skinned_instances {
    for _j in 0..<20 {
      dwords.push(0)
    }
  }
  dwords
}

///|
pub fn skinned_instanced_monochrome_lit_uniform_dwords(
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  skinning_matrices : Array[@math3d.Mat4],
  instance_matrices : Array[@math3d.Mat4],
  base_color : @math3d.Vec4,
) -> Array[Int] {
  let dwords = mat4_to_uniform_dwords(view_projection)
  let light_dw = @light3d.light_uniform_dwords(lighting)
  for i in 0..<light_dw.length() {
    dwords.push(light_dw[i])
  }
  let bone_count = if skinning_matrices.length() < max_bones {
    skinning_matrices.length()
  } else {
    max_bones
  }
  dwords.push(@gfx.double_to_f32_bits(bone_count.to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  for i in 0..<bone_count {
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(skinning_matrices[i].elements[j]))
    }
  }
  for _i in bone_count..<max_bones {
    for _j in 0..<16 {
      dwords.push(0)
    }
  }
  let inst_count = if instance_matrices.length() < max_skinned_instances {
    instance_matrices.length()
  } else {
    max_skinned_instances
  }
  dwords.push(@gfx.double_to_f32_bits(inst_count.to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(base_color.x))
  dwords.push(@gfx.double_to_f32_bits(base_color.y))
  dwords.push(@gfx.double_to_f32_bits(base_color.z))
  dwords.push(@gfx.double_to_f32_bits(base_color.w))
  for i in 0..<inst_count {
    let m = instance_matrices[i]
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(m.elements[j]))
    }
  }
  for _i in inst_count..<max_skinned_instances {
    for _j in 0..<16 {
      dwords.push(0)
    }
  }
  dwords
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
    vertex_stride_hint=@mesh3d.VertexFormat::skinned_3d().stride(),
  )
}

///|
pub fn new_skinned_instanced_lit_mesh_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  vertex_data : Array[Double],
  indices : Array[Int],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  skinning_matrices : Array[@math3d.Mat4],
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  src_image_ids? : Array[Int] = [],
) -> @gfx.DrawTrianglesCommand {
  let count = if instance_matrices.length() < instance_colors.length() {
    instance_matrices.length()
  } else {
    instance_colors.length()
  }
  let clamped_count = if count < max_skinned_instances {
    count
  } else {
    max_skinned_instances
  }
  let dwords = skinned_instanced_lit_uniform_dwords(
    view_projection, lighting, skinning_matrices, instance_matrices, instance_colors,
  )
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    0,
    0,
    0,
    blend,
    vertex_data,
    indices,
    src_image_ids,
    dwords,
    instance_count=clamped_count,
    vertex_stride_hint=@mesh3d.VertexFormat::skinned_3d().stride(),
  )
}

///|
pub fn new_skinned_instanced_monochrome_lit_mesh_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  vertex_data : Array[Double],
  indices : Array[Int],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  skinning_matrices : Array[@math3d.Mat4],
  instance_matrices : Array[@math3d.Mat4],
  base_color : @math3d.Vec4,
  src_image_ids? : Array[Int] = [],
) -> @gfx.DrawTrianglesCommand {
  let count = if instance_matrices.length() < max_skinned_instances {
    instance_matrices.length()
  } else {
    max_skinned_instances
  }
  let dwords = skinned_instanced_monochrome_lit_uniform_dwords(
    view_projection, lighting, skinning_matrices, instance_matrices, base_color,
  )
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    0,
    0,
    0,
    blend,
    vertex_data,
    indices,
    src_image_ids,
    dwords,
    instance_count=count,
    vertex_stride_hint=@mesh3d.VertexFormat::skinned_3d().stride(),
  )
}

///|
/// Build a skinned lit DrawTrianglesCommand from Mesh3D + SkinData.
/// This packs stride-8 mesh vertices into stride-16 GPU skinning vertices.
pub fn new_skinned_lit_mesh_draw_command_from_skin(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  index_offset : Int,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  mesh : @mesh3d.Mesh3D,
  skin : @skeleton3d.SkinData,
  model_matrix : @math3d.Mat4,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  skinning_matrices : Array[@math3d.Mat4],
  src_image_ids : Array[Int],
) -> @gfx.DrawTrianglesCommand {
  let packed_vertex_data = @skeleton3d.build_skinned_vertex_data(mesh, skin)
  new_skinned_lit_mesh_draw_command(
    dst,
    shader,
    dst_region,
    index_offset,
    pipeline_id,
    uniform_hash,
    blend,
    packed_vertex_data,
    mesh.indices,
    model_matrix,
    view_projection,
    lighting,
    skinning_matrices,
    src_image_ids,
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
    vertex_stride_hint=@mesh3d.vertex3d_stride,
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
    model_matrix, view_projection, lighting, metallic, roughness, base_color, emissive,
    camera_pos,
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
    vertex_stride_hint=mesh.format.stride(),
  )
}

// ============================================================
// 3D Instanced Lit Shader
// ============================================================

///|
let max_instances : Int = 256

///|
let max_monochrome_instances : Int = 64

///|
pub fn instanced_monochrome_max_instances() -> Int {
  max_monochrome_instances
}

///|
/// WGSL instanced lit shader (untextured).
/// Uniform layout: VP(16) + Light(12) + instance_count(4) + InstanceData(N×20).
/// Each instance has model(16) + color(4) dwords.
pub fn shader3d_lit_instanced_wgsl() -> String {
  "const MAX_INSTANCES: u32 = 256u;\n\n" +
  "struct InstanceData {\n" +
  "  model: mat4x4<f32>,\n" +
  "  color: vec4<f32>,\n" +
  "};\n\n" +
  "struct Uniforms {\n" +
  "  vp: mat4x4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  instance_count: vec4<f32>,\n" +
  "  instances: array<InstanceData, 256>,\n" +
  "};\n\n" +
  "@group(0) @binding(0) var<uniform> uniforms: Uniforms;\n\n" +
  "struct VertexInput {\n" +
  "  @location(0) position: vec3<f32>,\n" +
  "  @location(1) normal: vec3<f32>,\n" +
  "  @location(2) uv: vec2<f32>,\n" +
  "};\n\n" +
  "struct VertexOutput {\n" +
  "  @builtin(position) clip_position: vec4<f32>,\n" +
  "  @location(0) world_normal: vec3<f32>,\n" +
  "  @location(1) inst_color: vec4<f32>,\n" +
  "};\n\n" +
  "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) iid: u32) -> VertexOutput {\n" +
  "  let inst = uniforms.instances[iid];\n" +
  "  let mvp = uniforms.vp * inst.model;\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = mvp * vec4<f32>(input.position, 1.0);\n" +
  "  let normal_mat = mat3x3<f32>(inst.model[0].xyz, inst.model[1].xyz, inst.model[2].xyz);\n" +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  out.inst_color = inst.color;\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let normal = normalize(in.world_normal);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let diffuse = uniforms.light_color.xyz * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz;\n" +
  "  let lit_color = in.inst_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, in.inst_color.a);\n" +
  "}\n"
}

///|
/// WGSL instanced lit shader (untextured, uniform color, 64 instance cap).
pub fn shader3d_lit_instanced_monochrome_wgsl() -> String {
  "const MAX_INSTANCES: u32 = 64u;\n\n" +
  "struct Uniforms {\n" +
  "  vp: mat4x4<f32>,\n" +
  "  light_dir: vec4<f32>,\n" +
  "  light_color: vec4<f32>,\n" +
  "  ambient_color: vec4<f32>,\n" +
  "  instance_count: vec4<f32>,\n" +
  "  base_color: vec4<f32>,\n" +
  "  instance_models: array<mat4x4<f32>, 64>,\n" +
  "};\n\n" +
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
  "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) iid: u32) -> VertexOutput {\n" +
  "  let model = uniforms.instance_models[iid];\n" +
  "  let mvp = uniforms.vp * model;\n" +
  "  var out: VertexOutput;\n" +
  "  out.clip_position = mvp * vec4<f32>(input.position, 1.0);\n" +
  "  let normal_mat = mat3x3<f32>(model[0].xyz, model[1].xyz, model[2].xyz);\n" +
  "  out.world_normal = normalize(normal_mat * input.normal);\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  let normal = normalize(in.world_normal);\n" +
  "  let light_dir = normalize(-uniforms.light_dir.xyz);\n" +
  "  let ndotl = max(dot(normal, light_dir), 0.0);\n" +
  "  let diffuse = uniforms.light_color.xyz * ndotl;\n" +
  "  let ambient = uniforms.ambient_color.xyz;\n" +
  "  let lit_color = uniforms.base_color.rgb * (diffuse + ambient);\n" +
  "  return vec4<f32>(lit_color, uniforms.base_color.a);\n" +
  "}\n"
}

///|
/// Encode instanced lit uniform data.
/// Layout: VP(16) + Light(12) + instance_count(4) + per-instance(model(16)+color(4))×N.
pub fn instanced_lit_uniform_dwords(
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
) -> Array[Int] {
  let dwords = mat4_to_uniform_dwords(view_projection)
  // Light data (12 dwords)
  let light_dw = @light3d.light_uniform_dwords(lighting)
  for i in 0..<light_dw.length() {
    dwords.push(light_dw[i])
  }
  // instance_count as vec4<f32> (4 dwords)
  let count = instance_matrices.length()
  dwords.push(@gfx.double_to_f32_bits(count.to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  // Per-instance data: model(16) + color(4) = 20 dwords each
  let inst_count = if count < max_instances { count } else { max_instances }
  for i in 0..<inst_count {
    let m = instance_matrices[i]
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(m.elements[j]))
    }
    let c = instance_colors[i]
    dwords.push(@gfx.double_to_f32_bits(c.x))
    dwords.push(@gfx.double_to_f32_bits(c.y))
    dwords.push(@gfx.double_to_f32_bits(c.z))
    dwords.push(@gfx.double_to_f32_bits(c.w))
  }
  // Pad remaining instances with zeros
  for _i in inst_count..<max_instances {
    for _j in 0..<20 {
      dwords.push(0)
    }
  }
  dwords
}

///|
/// Encode instanced lit uniform data with uniform base color and 64 instance cap.
pub fn instanced_monochrome_lit_uniform_dwords(
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  instance_matrices : Array[@math3d.Mat4],
  base_color : @math3d.Vec4,
) -> Array[Int] {
  let dwords = mat4_to_uniform_dwords(view_projection)
  let light_dw = @light3d.light_uniform_dwords(lighting)
  for i in 0..<light_dw.length() {
    dwords.push(light_dw[i])
  }
  let count = if instance_matrices.length() < max_monochrome_instances {
    instance_matrices.length()
  } else {
    max_monochrome_instances
  }
  dwords.push(@gfx.double_to_f32_bits(count.to_double()))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(0.0))
  dwords.push(@gfx.double_to_f32_bits(base_color.x))
  dwords.push(@gfx.double_to_f32_bits(base_color.y))
  dwords.push(@gfx.double_to_f32_bits(base_color.z))
  dwords.push(@gfx.double_to_f32_bits(base_color.w))
  for i in 0..<count {
    let m = instance_matrices[i]
    for j in 0..<16 {
      dwords.push(@gfx.double_to_f32_bits(m.elements[j]))
    }
  }
  for _i in count..<max_monochrome_instances {
    for _j in 0..<16 {
      dwords.push(0)
    }
  }
  dwords
}

///|
/// Build an instanced draw command.
pub fn new_instanced_lit_mesh_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  mesh : @mesh3d.Mesh3D,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  instance_matrices : Array[@math3d.Mat4],
  instance_colors : Array[@math3d.Vec4],
  src_image_ids? : Array[Int] = [],
) -> @gfx.DrawTrianglesCommand {
  let count = if instance_matrices.length() < max_instances {
    instance_matrices.length()
  } else {
    max_instances
  }
  let uniform_dwords = instanced_lit_uniform_dwords(
    view_projection, lighting, instance_matrices, instance_colors,
  )
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    0,
    0,
    0,
    blend,
    mesh.vertex_data,
    mesh.indices,
    src_image_ids,
    uniform_dwords,
    instance_count=count,
    vertex_stride_hint=mesh.format.stride(),
  )
}

///|
/// Build a monochrome instanced draw command with a small uniform footprint.
pub fn new_instanced_monochrome_lit_mesh_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  dst_region : @gfx.DstRegion,
  blend : @gfx.BlendMode,
  mesh : @mesh3d.Mesh3D,
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  instance_matrices : Array[@math3d.Mat4],
  base_color : @math3d.Vec4,
  src_image_ids? : Array[Int] = [],
) -> @gfx.DrawTrianglesCommand {
  let count = if instance_matrices.length() < max_monochrome_instances {
    instance_matrices.length()
  } else {
    max_monochrome_instances
  }
  let uniform_dwords = instanced_monochrome_lit_uniform_dwords(
    view_projection, lighting, instance_matrices, base_color,
  )
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [dst_region],
    0,
    0,
    0,
    blend,
    mesh.vertex_data,
    mesh.indices,
    src_image_ids,
    uniform_dwords,
    instance_count=count,
    vertex_stride_hint=mesh.format.stride(),
  )
}
