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
    model_matrix,
    view_projection,
    lighting,
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
