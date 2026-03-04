///|
/// 3D Audio Positioning.
///
/// Distance attenuation and stereo panning for spatial audio.

///|
pub(all) enum AttenuationModel {
  Inverse
  Linear
  Exponential
}

///|
pub(all) struct AudioListener3D {
  position : @math3d.Vec3
  forward : @math3d.Vec3
  up : @math3d.Vec3
}

///|
pub(all) struct AudioSource3D {
  position : @math3d.Vec3
  player_id : @audio.PlayerId
  ref_distance : Double
  max_distance : Double
  rolloff : Double
  attenuation : AttenuationModel
  base_volume : Double
}

///|
pub fn AudioListener3D::from_camera(
  position : @math3d.Vec3,
  forward : @math3d.Vec3,
  up : @math3d.Vec3,
) -> AudioListener3D {
  { position, forward: forward.normalize(), up: up.normalize() }
}

///|
pub fn default_audio_source3d(
  position : @math3d.Vec3,
  player_id : @audio.PlayerId,
) -> AudioSource3D {
  {
    position,
    player_id,
    ref_distance: 1.0,
    max_distance: 100.0,
    rolloff: 1.0,
    attenuation: AttenuationModel::Inverse,
    base_volume: 1.0,
  }
}

///|
/// Compute distance-based attenuation gain (0.0..1.0).
pub fn compute_attenuation(
  source : AudioSource3D,
  listener : AudioListener3D,
) -> Double {
  let d = source.position.distance(listener.position)
  let ref_d = source.ref_distance
  let max_d = source.max_distance
  let rolloff = source.rolloff
  let clamped_d = if d < ref_d {
    ref_d
  } else if d > max_d {
    max_d
  } else {
    d
  }
  match source.attenuation {
    Inverse => {
      // 1 / (1 + (d / ref) * rolloff) -- OpenAL-style
      let ratio = (clamped_d - ref_d) / ref_d
      1.0 / (1.0 + ratio * rolloff)
    }
    Linear => {
      let range = max_d - ref_d
      if range <= 0.0 {
        1.0
      } else {
        let v = 1.0 - rolloff * (clamped_d - ref_d) / range
        if v < 0.0 { 0.0 } else { v }
      }
    }
    Exponential => {
      if ref_d <= 0.0 {
        1.0
      } else {
        let ratio = clamped_d / ref_d
        pow(ratio, -rolloff)
      }
    }
  }
}

///|
/// Simple power function for positive base using repeated squaring
/// and linear interpolation for fractional exponents.
fn pow(base : Double, exponent : Double) -> Double {
  if base <= 0.0 {
    return 0.0
  }
  if exponent == 0.0 {
    return 1.0
  }
  let neg = exponent < 0.0
  let abs_exp = if neg { -exponent } else { exponent }
  let int_part = abs_exp.to_int()
  let frac_part = abs_exp - int_part.to_double()
  // Integer power by repeated squaring
  let mut result = 1.0
  let mut b = base
  let mut n = int_part
  while n > 0 {
    if n % 2 == 1 {
      result = result * b
    }
    b = b * b
    n = n / 2
  }
  // Fractional part approximation: base^frac ~ 1 + frac*(base-1) for small frac
  // More accurate: use sqrt decomposition
  if frac_part > 0.0001 {
    // Approximate base^frac using iterative sqrt
    let mut frac_result = 1.0
    let mut frac_base = base
    let mut frac = frac_part
    for _i = 0; _i < 16; _i = _i + 1 {
      frac_base = frac_base.sqrt()
      frac = frac * 2.0
      if frac >= 1.0 {
        frac_result = frac_result * frac_base
        frac = frac - 1.0
      }
    }
    result = result * frac_result
  }
  if neg { 1.0 / result } else { result }
}

///|
/// Compute stereo pan (-1.0 left, 1.0 right) based on source/listener positions.
pub fn compute_pan(
  source : AudioSource3D,
  listener : AudioListener3D,
) -> Double {
  let to_source = source.position.sub(listener.position)
  let dist = to_source.length()
  if dist < 0.0001 {
    return 0.0
  }
  let direction = to_source.normalize()
  // Listener's right vector = forward x up
  let right = listener.forward.cross(listener.up).normalize()
  let pan = direction.dot(right)
  // Clamp to [-1, 1]
  if pan < -1.0 {
    -1.0
  } else if pan > 1.0 {
    1.0
  } else {
    pan
  }
}

///|
/// Update audio gain and pan for all 3D sources relative to the listener.
pub fn update_audio3d(
  ctx : @audio.MixerAudioContext,
  listener : AudioListener3D,
  sources : Array[AudioSource3D],
) -> Unit {
  for source in sources {
    let gain = compute_attenuation(source, listener) * source.base_volume
    let pan = compute_pan(source, listener)
    ctx.set_volume(source.player_id, gain)
    ctx.set_pan(source.player_id, pan)
  }
}
