///|
/// A tapered reveal volume between a camera and its subject, in world units.
/// Apply only to geometry that may hide the subject; collision and material
/// classification remain with the caller. softness is the fully clear inner
/// radius as a fraction of the outer radius. end_fraction protects the subject
/// and geometry behind it. All positions/settings must be finite.
pub(all) struct CameraOcclusion {
  eye : @math3d.Vec3
  target : @math3d.Vec3
  enabled : Bool
  eye_radius : Double
  target_radius : Double
  softness : Double
  end_fraction : Double
}

///|
/// Append exactly 12 f32 words (three aligned vec4s), matching the WGSL
/// KaguraCameraOcclusion struct. The existing prefix must end on a vec4 boundary.
/// This adds no draw pass, geometry update or alpha sorting.
pub fn CameraOcclusion::append_uniform_dwords(
  self : CameraOcclusion,
  words : Array[Int],
) -> Unit {
  for
    v in [
      self.eye.x,
      self.eye.y,
      self.eye.z,
      if self.enabled {
        1.0
      } else {
        0.0
      },
      self.target.x,
      self.target.y,
      self.target.z,
      self.target_radius.max(0.001),
      self.eye_radius.max(0.001),
      self.softness.clamp(min=0.0, max=0.999),
      self.end_fraction.clamp(min=0.0, max=1.0),
      0.0,
    ] {
    words.push(f32(v))
  }
}

///|
/// Composable WGSL helpers: prepend to a custom shader, add a
/// KaguraCameraOcclusion field to its uniform struct, then call
/// kagura_camera_opacity(world_position, mask) for selected occluders.
/// kagura_dither_visible(opacity, fragment_position.xy) also supports other
/// opaque-pass fades, such as distance-limited ground cover. Neither function
/// owns a binding, vertex layout, lighting model or material tag.
pub fn shader3d_visibility_wgsl() -> String {
  let source =
    #|struct KaguraCameraOcclusion {
    #| eye: vec4<f32>, subject: vec4<f32>, shape: vec4<f32>,
    #|};
    #|fn kagura_camera_opacity(world: vec3<f32>, mask: KaguraCameraOcclusion) -> f32 {
    #| if mask.eye.w<=0.5 { return 1.0; }
    #| let ray=mask.subject.xyz-mask.eye.xyz;
    #| let t=dot(world-mask.eye.xyz,ray)/max(dot(ray,ray),0.001);
    #| if t<=0.0 || t>=mask.shape.z { return 1.0; }
    #| let radius=mix(mask.shape.x,mask.subject.w,clamp(t,0.0,1.0));
    #| let d=length(world-(mask.eye.xyz+ray*t));
    #| return smoothstep(radius*mask.shape.y,radius,d);
    #|}
    #|fn kagura_dither_visible(opacity: f32, pixel: vec2<f32>) -> bool {
    #| return opacity>=0.999 || fract(52.9829189*fract(dot(floor(pixel),vec2(0.06711056,0.00583715))))<=opacity;
    #|}
  source
}
