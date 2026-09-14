///|
/// Linear colors for a texture-free outdoor sky. Cloud cover is clamped to 0..1.
/// Sun and clouds remain fixed in world directions as the camera moves.
pub(all) struct SkySettings {
  horizon : @math3d.Vec3
  zenith : @math3d.Vec3
  ground : @math3d.Vec3
  sun_direction : @math3d.Vec3
  sun_color : @math3d.Vec3
  cloud_color : @math3d.Vec3
  cloud_cover : Double
}

///|
pub fn SkySettings::default() -> SkySettings {
  {
    horizon: @math3d.Vec3::new(0.392, 0.498, 0.537),
    zenith: @math3d.Vec3::new(0.10, 0.20, 0.32),
    ground: @math3d.Vec3::new(0.15, 0.23, 0.26),
    sun_direction: @math3d.Vec3::new(-0.75, 0.38, -0.55),
    sun_color: @math3d.Vec3::new(1.0, 0.77, 0.45),
    cloud_color: @math3d.Vec3::new(0.64, 0.68, 0.67),
    cloud_cover: 0.42,
  }
}

///|
/// Cache this inward-facing unit cube once; never include it in shadow/SSAO
/// geometry or frustum culling. The shader places it at the far depth plane.
pub fn sky_mesh() -> @mesh3d.Mesh3D {
  let cube = @mesh3d.Mesh3D::cube(2.0)
  let indices = cube.indices.copy()
  for i = 0; i < indices.length(); i = i + 3 {
    let previous = indices[i + 1]
    indices[i + 1] = indices[i + 2]
    indices[i + 2] = previous
  }
  @mesh3d.Mesh3D::new(cube.vertex_data, indices)
}

///|
/// Draw before opaque scene geometry, using a perspective camera's VP and eye.
/// The cube follows the eye, so there is no parallax or finite-distance edge.
pub fn new_sky_draw_command(
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  mesh : @mesh3d.Mesh3D,
  view_projection : @math3d.Mat4,
  eye : @math3d.Vec3,
  settings : SkySettings,
) -> @gfx.DrawTrianglesCommand {
  let uniforms = mvp_uniform_dwords(
    @math3d.Mat4::translation(eye.x, eye.y, eye.z),
    view_projection,
  )
  for
    color in [
      settings.horizon,
      settings.zenith,
      settings.ground,
      settings.sun_direction,
      settings.sun_color,
      settings.cloud_color,
    ] {
    uniforms.push(f32(color.x))
    uniforms.push(f32(color.y))
    uniforms.push(f32(color.z))
    uniforms.push(0)
  }
  uniforms[19] = f32(settings.cloud_cover.clamp(min=0.0, max=1.0))
  @gfx.new_draw_triangles_command(
    dst,
    shader,
    [@gfx.new_dst_region(0, 0, dst.width, dst.height, mesh.indices.length())],
    0,
    0,
    0,
    @gfx.BlendMode::from_int(0),
    mesh.vertex_data,
    mesh.indices,
    [],
    uniforms,
    vertex_stride_hint=8,
  )
}

///|
/// One opaque pass, twelve triangles, no textures, noise textures or raymarching.
pub fn shader3d_sky_wgsl() -> String {
  let source =
    #|struct SkyUniforms {
    #| mvp: mat4x4<f32>, horizon: vec4<f32>, zenith: vec4<f32>, ground: vec4<f32>,
    #| sun_direction: vec4<f32>, sun_color: vec4<f32>, cloud_color: vec4<f32>,
    #|};
    #|@group(0) @binding(0) var<uniform> u: SkyUniforms;
    #|struct In { @location(0) position: vec3<f32>, @location(1) normal: vec3<f32>, @location(2) uv: vec2<f32> };
    #|struct Out { @builtin(position) position: vec4<f32>, @location(0) direction: vec3<f32> };
    #|@vertex fn vs_main(v: In) -> Out {
    #| var o: Out;
    #| let clip=u.mvp*vec4(v.position,1.0);
    #| // Keep the vertex depth away from the clip boundary. Interpolation of
    #| // z close to w can round beyond the far plane on Metal.
    #| o.position=vec4(clip.xy,0.0,clip.w);
    #| o.direction=v.position;
    #| return o;
    #|}
    #|struct Fragment { @location(0) color: vec4<f32>, @builtin(frag_depth) depth: f32 };
    #|@fragment fn fs_main(v: Out) -> Fragment {
    #| let d=normalize(v.direction);
    #| var color=mix(u.horizon.rgb,u.zenith.rgb,smoothstep(0.0,0.8,d.y));
    #| color=mix(color,u.ground.rgb,smoothstep(0.0,0.65,-d.y));
    #| // Broad, gently layered cloud bands. Direction-based coordinates have no
    #| // longitude seam and remain finite at both poles and the horizon.
    #| let p=d.xz/max(0.18,d.y+0.12);
    #| let bands=sin(p.x*1.6+p.y*0.5+sin(p.y*2.2))*sin(p.y*2.6-p.x*0.7);
    #| let cloud=smoothstep(1.0-u.horizon.w*1.7,1.01,bands)*smoothstep(0.02,0.22,d.y);
    #| color=mix(color,u.cloud_color.rgb,cloud*0.65);
    #| let sun_dir=u.sun_direction.xyz;
    #| let sun=dot(d,sun_dir*inverseSqrt(max(dot(sun_dir,sun_dir),0.000001)));
    #| let glow=pow(max(sun,0.0),32.0)*0.18;
    #| color+=u.sun_color.rgb*(glow+smoothstep(0.9992,0.9997,sun)*0.8)*(1.0-cloud*0.65);
    #| var result: Fragment;
    #| result.color=vec4(color,1.0);
    #| result.depth=0.99999994;
    #| return result;
    #|}
  source
}
