///|
/// Camera-space depth pass: renders linear depth (from camera VP) to R channel.
/// Same depth-to-color approach as shadow mapping, but from camera perspective.
/// Used by SSAO to get correct camera-space occlusion.

///|
/// WGSL shader for camera depth pass.
/// Uniform: camera_vp mat4x4 (16 dwords).
/// Vertex format: position(3) + normal(3) + uv(2) = stride 8.
pub fn shader_camera_depth_wgsl() -> String {
  "struct Uniforms {\n" +
  "  camera_vp: mat4x4<f32>,\n" +
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
  "  let clip_pos = uniforms.camera_vp * vec4<f32>(input.position, 1.0);\n" +
  "  out.clip_position = clip_pos;\n" +
  "  out.depth = clamp(clip_pos.z / clip_pos.w, 0.0, 1.0);\n" +
  "  return out;\n" +
  "}\n\n" +
  "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n" +
  "  return vec4<f32>(in.depth, 0.0, 0.0, 1.0);\n" +
  "}\n"
}

///|
/// Encode camera depth uniform: camera_vp (16 dwords).
pub fn camera_depth_uniform_dwords(
  camera_vp : @math3d.Mat4,
) -> Array[Int] {
  let dwords : Array[Int] = []
  for i in 0..<16 {
    dwords.push(f32(camera_vp.elements[i]))
  }
  dwords
}

///|
/// Create a DrawTrianglesCommand for camera depth pass.
pub fn new_camera_depth_command(
  depth_target : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  mesh : @mesh3d.Mesh3D,
  camera_vp : @math3d.Mat4,
) -> @gfx.DrawTrianglesCommand {
  let uniform_dwords = camera_depth_uniform_dwords(camera_vp)
  let dst_region = @gfx.new_dst_region(
    0, 0, depth_target.width, depth_target.height, mesh.indices.length(),
  )
  @gfx.new_draw_triangles_command(
    depth_target,
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

///|
/// Generate camera depth pass commands for all casters.
/// camera_vp is the camera's view-projection matrix.
/// Each caster's model matrix is premultiplied to get the final MVP.
pub fn camera_depth_pass_commands(
  depth_target : @gfx.ImageHandle,
  depth_shader : @gfx.ShaderHandle,
  casters : Array[ShadowCaster],
  camera_vp : @math3d.Mat4,
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  for caster in casters {
    let mvp = camera_vp.multiply(caster.model_matrix)
    commands.push(
      new_camera_depth_command(depth_target, depth_shader, caster.mesh, mvp),
    )
  }
  commands
}
